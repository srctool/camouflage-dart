import 'dart:convert';

// Initials and the initials color, the same on every platform (and in the Kotlin library).

const _fnvOffset = 0x811C9DC5;
const _mask32 = 0xFFFFFFFF;
const _primeLow = 0x193; // the FNV prime is 2^24 + 0x193

/// The 32-bit FNV-1a hash of [name]'s UTF-8 bytes: the seed that picks a person's initials color. Unlike
/// `hashCode` it's specified, so a name gets the same color on every platform and in Kotlin. The multiply is
/// split so it stays exact on the web, where integers are doubles.
int avatarColorSeed(String name) {
  var hash = _fnvOffset;
  for (final byte in utf8.encode(name)) {
    hash = (hash ^ byte) & _mask32;
    hash = (((hash << 24) & _mask32) + hash * _primeLow) & _mask32;
  }
  return hash;
}

/// The initials for [name]: the first grapheme of its first and last words, uppercased ("Dwiki Riyadi" → "DR",
/// "Dwiki" → "D"). A name in a script without word spaces gets its first grapheme. `null` when there's nothing to
/// show: an empty name, or one that starts with an emoji or a symbol (the avatar shows its person icon instead).
String? avatarInitials(String? name) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return null;
  final first = _firstLetterGrapheme(words.first);
  if (first == null) return null;
  final last = words.length > 1 ? _firstLetterGrapheme(words.last) : null;
  return (first + (last ?? '')).toUpperCase();
}

// The word's first grapheme when it's a letter; null for an emoji, a digit or a symbol.
String? _firstLetterGrapheme(String word) {
  final clusters = graphemes(word);
  if (clusters.isEmpty) return null;
  final grapheme = clusters.first;
  return _isLetter(grapheme.runes.first) ? grapheme : null;
}

// A letter has distinct cases, or is a letter of a caseless script (CJK, Arabic, Hebrew, Thai, Devanagari, …).
bool _isLetter(int rune) {
  final c = String.fromCharCode(rune);
  if (c.toUpperCase() != c.toLowerCase()) return true;
  return _caselessLetters.any((r) => rune >= r.$1 && rune <= r.$2);
}

const _caselessLetters = [
  (0x0590, 0x08FF), // Hebrew, Arabic, Syriac, Thaana, …
  (0x0900, 0x0DFF), // Indic scripts
  (0x0E00, 0x0FFF), // Thai, Lao, Tibetan
  (0x1100, 0x11FF), // Hangul Jamo
  (0x3040, 0x30FF), // Hiragana, Katakana
  (0x3400, 0x4DBF), // CJK extension A
  (0x4E00, 0x9FFF), // CJK unified ideographs
  (0xAC00, 0xD7AF), // Hangul syllables
];

/// Splits [text] into user-perceived characters, close enough for initials: a code point plus any combining
/// marks, variation selectors, emoji modifiers, tag characters and zero-width-joined parts that follow it, and
/// regional-indicator pairs (flags). The same rules as the Kotlin library's.
List<String> graphemes(String text) {
  final clusters = <StringBuffer>[];
  var previous = -1;
  var regionalRun = 0;
  for (final rune in text.runes) {
    final regional = rune >= 0x1F1E6 && rune <= 0x1F1FF;
    final extends_ =
        clusters.isNotEmpty &&
        (_isExtending(rune) ||
            previous == _zwj ||
            (regional && regionalRun.isOdd));
    if (extends_) {
      clusters.last.writeCharCode(rune);
    } else {
      clusters.add(StringBuffer()..writeCharCode(rune));
    }
    regionalRun = regional ? regionalRun + 1 : 0;
    previous = rune;
  }
  return [for (final c in clusters) c.toString()];
}

const _zwj = 0x200D;

const _extending = [
  (0x0300, 0x036F),
  (0x1AB0, 0x1AFF),
  (0x1DC0, 0x1DFF),
  (0x20D0, 0x20FF),
  (0xFE20, 0xFE2F), // combining marks
  (0xFE00, 0xFE0F), (0xE0100, 0xE01EF), // variation selectors
  (0x1F3FB, 0x1F3FF), // emoji skin tones
  (0xE0020, 0xE007F), // tag characters
  (_zwj, _zwj),
];

bool _isExtending(int rune) =>
    _extending.any((r) => rune >= r.$1 && rune <= r.$2);
