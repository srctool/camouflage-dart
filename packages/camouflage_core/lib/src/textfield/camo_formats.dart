import 'package:flutter/services.dart';

/// Which input a text field accepts. Core applies it before `onChanged`, so the app never sees rejected
/// characters: [filter] gets the raw text before and after an edit and returns the accepted text (return `old`
/// to reject the edit).
abstract interface class CamoInputFilter {
  /// A filter from a function.
  const factory CamoInputFilter.from(
    String Function(String old, String next) filter,
  ) = _FnFilter;

  /// Digits only, at most [maxLength] of them when set.
  factory CamoInputFilter.digitsOnly({int? maxLength}) => _FnFilter((_, next) {
    final digits = next.replaceAll(RegExp('[^0-9]'), '');
    return maxLength == null || digits.length <= maxLength
        ? digits
        : digits.substring(0, maxLength);
  });

  /// At most [n] characters.
  factory CamoInputFilter.maxLength(int n) =>
      _FnFilter((_, next) => next.length <= n ? next : next.substring(0, n));

  /// Only the characters [allowed] matches, one at a time (e.g. `RegExp('[A-Za-z ]')`).
  factory CamoInputFilter.pattern(RegExp allowed) =>
      _FnFilter((_, next) => next.split('').where(allowed.hasMatch).join());

  /// A decimal number: digits and one [decimalSeparator], at most [decimals] digits after it. Pair it with
  /// `CamoDisplayFormat.decimal` (which only groups the shown integer part).
  factory CamoInputFilter.decimal({
    int decimals = 2,
    String decimalSeparator = ',',
  }) => _FnFilter((old, next) {
    final kept = next
        .split('')
        .where((c) => c == decimalSeparator || RegExp('[0-9]').hasMatch(c))
        .join();
    final parts = kept.split(decimalSeparator);
    if (parts.length > 2) return old;
    if (parts.length == 1 || decimals == 0) return parts.first;
    final fraction = parts[1].length > decimals
        ? parts[1].substring(0, decimals)
        : parts[1];
    return '${parts.first}$decimalSeparator$fraction';
  });

  /// The accepted raw text after an edit from [old] to [next].
  String filter(String old, String next);
}

class _FnFilter implements CamoInputFilter {
  const _FnFilter(this._filter);

  final String Function(String old, String next) _filter;

  @override
  String filter(String old, String next) => _filter(old, next);
}

/// How a raw value is shown without storing the formatting: `081234567890` shown as `0812-3456-7890`. The value
/// stays raw; core maps the cursor between the two, so it never jumps.
abstract interface class CamoDisplayFormat {
  /// A mask where each `#` is one raw character: `pattern('####-####-#####')`. Other characters are shown.
  factory CamoDisplayFormat.pattern(String mask) =>
      _InsertionFormat(mask.split('').where((c) => c != '#').toSet(), (raw) {
        final out = <(int, String)>[];
        var r = 0;
        for (final c in mask.split('')) {
          if (r >= raw.length) break;
          if (c == '#') {
            r++;
          } else {
            out.add((r, c));
          }
        }
        return out;
      });

  /// Groups digits from the right: `grouping(separator: '.', size: 3)` shows `1250000` as `1.250.000`.
  factory CamoDisplayFormat.grouping({String separator = '.', int size = 3}) =>
      _InsertionFormat({
        separator,
      }, (raw) => _groups(raw, raw.length, separator, size));

  /// Groups the integer part and keeps the decimal part as typed: `1250000,50` shows as `1.250.000,50`. At
  /// most [decimals] digits after [decimalSeparator] come from `CamoInputFilter.decimal`.
  factory CamoDisplayFormat.decimal({
    int decimals = 2,
    String decimalSeparator = ',',
    String groupSeparator = '.',
  }) => _InsertionFormat({groupSeparator}, (raw) {
    assert(decimals >= 0, 'decimals must not be negative');
    final at = raw.indexOf(decimalSeparator);
    return _groups(raw, at < 0 ? raw.length : at, groupSeparator, 3);
  });

  /// What the user sees for [raw].
  String format(String raw);

  /// The raw text behind [shown].
  String toRaw(String shown);

  /// The shown cursor position for raw position [offset].
  int rawToShown(int offset, String raw);

  /// The raw cursor position for shown position [offset].
  int shownToRaw(int offset, String shown);
}

class _InsertionFormat implements CamoDisplayFormat {
  _InsertionFormat(this._inserted, this._at);

  final Set<String> _inserted;
  final List<(int, String)> Function(String raw) _at;

  @override
  String format(String raw) {
    final out = StringBuffer();
    var r = 0;
    for (final (at, text) in _at(raw)) {
      out
        ..write(raw.substring(r, at))
        ..write(text);
      r = at;
    }
    return (out..write(raw.substring(r))).toString();
  }

  @override
  String toRaw(String shown) =>
      shown.split('').where((c) => !_inserted.contains(c)).join();

  @override
  int rawToShown(int offset, String raw) =>
      offset +
      _at(raw).where((i) => i.$1 < offset).fold(0, (n, i) => n + i.$2.length);

  @override
  int shownToRaw(int offset, String shown) => shown
      .substring(0, offset.clamp(0, shown.length))
      .split('')
      .where((c) => !_inserted.contains(c))
      .length;
}

// A separator before every group of `size` digits counted back from `end`, after an optional leading minus.
List<(int, String)> _groups(String raw, int end, String separator, int size) {
  final start = raw.startsWith('-') ? 1 : 0;
  return [
    for (var i = start + 1; i < end; i++)
      if ((end - i) % size == 0) (i, separator),
  ];
}

/// Applies [filter] and [format] to each edit of the shown text, keeping the cursor next to the same raw
/// character. The controller holds the shown text; [raw] reads the value back.
class CamoTextFormatter extends TextInputFormatter {
  /// Creates the formatter.
  CamoTextFormatter({this.filter, this.format});

  /// Which input is accepted.
  final CamoInputFilter? filter;

  /// How the raw value is shown.
  final CamoDisplayFormat? format;

  /// The raw value behind [shown].
  String raw(String shown) => format?.toRaw(shown) ?? shown;

  /// What [raw] looks like.
  String show(String raw) => format?.format(raw) ?? raw;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue; // the IME is composing: format once the text is committed
    }
    final oldRaw = raw(oldValue.text);
    final nextRaw = raw(newValue.text);
    final accepted = filter?.filter(oldRaw, nextRaw) ?? nextRaw;
    if (accepted == oldRaw && nextRaw != oldRaw) return oldValue;
    final cursor = format == null
        ? newValue.selection.end
        : format!.shownToRaw(newValue.selection.end, newValue.text);
    final rawCursor = cursor.clamp(0, accepted.length);
    final shown = show(accepted);
    final at = format?.rawToShown(rawCursor, accepted) ?? rawCursor;
    return TextEditingValue(
      text: shown,
      selection: TextSelection.collapsed(offset: at.clamp(0, shown.length)),
    );
  }
}
