import 'package:flutter/foundation.dart';

/// How [CamoMatcher] compares a query with a text.
enum MatchKind {
  /// The text starts with the query.
  prefix,

  /// The text contains the query.
  substring,

  /// Each query letter starts a word or hump of the text, or continues the one before (`fLog`: `featureLogin`).
  camelHump,

  /// The query letters appear in order, anywhere (`ftl` finds `featureLogin`).
  fuzzy,

  /// [prefix], then [substring], then [camelHump]: the first that matches.
  auto,
}

/// A matched stretch of a text: the characters from [start] up to, not including, [end].
@immutable
class MatchRange {
  /// Creates a range.
  const MatchRange(this.start, this.end);

  /// The first matched index.
  final int start;

  /// One past the last matched index.
  final int end;

  @override
  bool operator ==(Object other) =>
      other is MatchRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MatchRange($start, $end)';
}

/// Matches a typed query against a text, case- and accent-insensitively ("zur" finds "Zürich"), and says which
/// characters matched so they can be highlighted. Pure and window-free: the same rules back speed search and the
/// command palette.
abstract final class CamoMatcher {
  /// The ranges of [text] that match [query], or `null` when it doesn't match. An empty query matches everything
  /// with no ranges. Ranges are indexes into [text]; they never overlap and are in order.
  static List<MatchRange>? match(
    String query,
    String text, {
    MatchKind kind = MatchKind.auto,
  }) {
    if (query.isEmpty) return const [];
    final q = _fold(query);
    final t = _fold(text);
    return switch (kind) {
      MatchKind.prefix => _prefix(q, t),
      MatchKind.substring => _substring(q, t),
      MatchKind.camelHump => _hump(q, t, text),
      MatchKind.fuzzy => _fuzzy(q, t),
      MatchKind.auto => _prefix(q, t) ?? _substring(q, t) ?? _hump(q, t, text),
    };
  }

  static List<MatchRange>? _prefix(String q, String t) =>
      t.startsWith(q) ? [MatchRange(0, q.length)] : null;

  static List<MatchRange>? _substring(String q, String t) {
    final at = t.indexOf(q);
    return at < 0 ? null : [MatchRange(at, at + q.length)];
  }

  static List<MatchRange>? _fuzzy(String q, String t) {
    final hits = <int>[];
    var from = 0;
    for (var i = 0; i < q.length; i++) {
      final at = t.indexOf(q[i], from);
      if (at < 0) return null;
      hits.add(at);
      from = at + 1;
    }
    return _merge(hits);
  }

  // The query's letters, each starting a hump or continuing the previous letter's hump.
  static List<MatchRange>? _hump(String q, String t, String original) {
    final starts = [
      for (var i = 0; i < t.length; i++) _isHumpStart(original, i),
    ];
    final hits = List<int>.filled(q.length, 0);
    bool place(int qi, int from, int afterHit) {
      if (qi == q.length) return true;
      for (var ti = from; ti < t.length; ti++) {
        final continues = afterHit >= 0 && ti == afterHit + 1;
        if (t[ti] == q[qi] && (starts[ti] || continues)) {
          hits[qi] = ti;
          if (place(qi + 1, ti + 1, ti)) return true;
        }
      }
      return false;
    }

    return place(0, 0, -1) ? _merge(hits) : null;
  }

  static bool _isLetterOrDigit(String c) =>
      RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(c);

  static bool _isUpper(String c) =>
      c != c.toLowerCase() && c == c.toUpperCase();

  static bool _isDigit(String c) => RegExp(r'\p{N}', unicode: true).hasMatch(c);

  static bool _isHumpStart(String text, int i) {
    if (i == 0) return true;
    final c = text[i];
    final before = text[i - 1];
    return (_isUpper(c) && !_isUpper(before)) ||
        (!_isLetterOrDigit(before) && _isLetterOrDigit(c)) ||
        (_isDigit(c) != _isDigit(before) && _isLetterOrDigit(c));
  }

  // Adjacent indexes become one range.
  static List<MatchRange> _merge(List<int> hits) {
    final out = <MatchRange>[];
    var start = hits.first;
    var end = start;
    for (var i = 1; i < hits.length; i++) {
      if (hits[i] == end + 1) {
        end = hits[i];
      } else {
        out.add(MatchRange(start, end + 1));
        start = hits[i];
        end = start;
      }
    }
    out.add(MatchRange(start, end + 1));
    return out;
  }
}

const _accents = {
  'aàáâãäåā': 'a',
  'cçćč': 'c',
  'eèéêëēė': 'e',
  'iìíîïī': 'i',
  'nñń': 'n',
  'oòóôõöøō': 'o',
  'sśš': 's',
  'uùúûüū': 'u',
  'yýÿ': 'y',
  'zźżž': 'z',
};

final _foldMap = {
  for (final e in _accents.entries)
    for (final c in e.key.split('')) c: e.value,
};

String _fold(String text) {
  final out = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final lower = text[i].toLowerCase();
    // One character in, one out, so a folded text keeps the indexes of the original.
    final c = lower.length == 1 ? lower : text[i];
    out.write(_foldMap[c] ?? c);
  }
  return out.toString();
}
