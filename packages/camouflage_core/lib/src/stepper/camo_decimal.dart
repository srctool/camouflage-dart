import 'package:flutter/foundation.dart';

/// A fixed-point decimal: [unscaled] units of 10^-[scale] (`12.50` is `CamoDecimal(1250, 2)`). Adding and
/// subtracting are exact, so steps never drift (0.1 × 3 is 0.3). Equality is by representation, like
/// `BigDecimal`: `1.0` and `1.00` compare equal but aren't `==`. Convert to an app's money or quantity type at
/// the edge.
@immutable
class CamoDecimal implements Comparable<CamoDecimal> {
  /// Creates a decimal from its units and scale.
  const CamoDecimal(this.unscaled, this.scale)
    : assert(scale >= 0 && scale <= maxScale, 'scale must be 0 to $maxScale');

  /// Parses [text] like "12.50", "-3" or "0,25" (either separator). Throws a [FormatException] otherwise.
  factory CamoDecimal.parse(String text) {
    final t = text.trim();
    final negative = t.startsWith('-');
    final body = negative || t.startsWith('+') ? t.substring(1) : t;
    final separators = body.split('').where((c) => c == '.' || c == ',').length;
    if (body.isEmpty ||
        separators > 1 ||
        !RegExp(r'^[0-9.,]+$').hasMatch(body)) {
      throw FormatException('Not a decimal', text);
    }
    final parts = body.split(RegExp('[.,]'));
    final whole = parts[0];
    final fraction = parts.length > 1 ? parts[1] : '';
    if (whole.isEmpty && fraction.isEmpty) {
      throw FormatException('Not a decimal', text);
    }
    final units = int.parse(
      (whole + fraction).isEmpty ? '0' : whole + fraction,
    );
    return CamoDecimal(negative ? -units : units, fraction.length);
  }

  /// A whole number.
  const CamoDecimal.of(int value) : this(value, 0);

  /// [text] parsed, or `null` when it isn't a plain decimal ("1.2.3", "abc", "").
  static CamoDecimal? tryParse(String text) {
    try {
      return CamoDecimal.parse(text);
    } on FormatException {
      return null;
    }
  }

  /// The largest scale: 18 digits after the separator.
  static const int maxScale = 18;

  /// Zero.
  static const CamoDecimal zero = CamoDecimal(0, 0);

  /// The value in units of 10^-[scale].
  final int unscaled;

  /// Digits after the separator.
  final int scale;

  /// The exact sum. Its scale is the larger of the two.
  CamoDecimal operator +(CamoDecimal other) {
    final s = scale > other.scale ? scale : other.scale;
    return CamoDecimal(rescaled(s) + other.rescaled(s), s);
  }

  /// The exact difference. Its scale is the larger of the two.
  CamoDecimal operator -(CamoDecimal other) {
    final s = scale > other.scale ? scale : other.scale;
    return CamoDecimal(rescaled(s) - other.rescaled(s), s);
  }

  /// This value [times] times, exactly.
  CamoDecimal operator *(int times) => CamoDecimal(unscaled * times, scale);

  /// Less than.
  bool operator <(CamoDecimal other) => compareTo(other) < 0;

  /// Greater than.
  bool operator >(CamoDecimal other) => compareTo(other) > 0;

  @override
  int compareTo(CamoDecimal other) {
    final s = scale > other.scale ? scale : other.scale;
    return rescaled(s).compareTo(other.rescaled(s));
  }

  /// This value between [low] and [high].
  CamoDecimal clamp(CamoDecimal low, CamoDecimal high) =>
      this < low ? low : (this > high ? high : this);

  /// This value with [newScale] digits after the separator; extra digits round half away from zero.
  CamoDecimal withScale(int newScale) {
    if (newScale >= scale) return CamoDecimal(rescaled(newScale), newScale);
    final divisor = _pow10(scale - newScale);
    final half = divisor ~/ 2;
    final rounded = unscaled >= 0
        ? (unscaled + half) ~/ divisor
        : (unscaled - half) ~/ divisor;
    return CamoDecimal(rounded, newScale);
  }

  /// The value with [decimalSeparator] and every digit of its scale: `format(',')` of 12.50 is "12,50".
  String format([String decimalSeparator = '.']) {
    final digits = unscaled.abs().toString().padLeft(scale + 1, '0');
    final sign = unscaled < 0 ? '-' : '';
    if (scale == 0) return sign + digits;
    final cut = digits.length - scale;
    return '$sign${digits.substring(0, cut)}$decimalSeparator${digits.substring(cut)}';
  }

  /// The value as a `double`, for display math only (never for stepping).
  double toDouble() => unscaled / _pow10(scale);

  /// [unscaled] at scale [to] (at least [scale]).
  @visibleForTesting
  int rescaled(int to) => unscaled * _pow10(to - scale);

  @override
  bool operator ==(Object other) =>
      other is CamoDecimal &&
      other.unscaled == unscaled &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(unscaled, scale);

  @override
  String toString() => format();
}

int _pow10(int n) {
  var p = 1;
  for (var i = 0; i < n; i++) {
    p *= 10;
  }
  return p;
}

/// The nearest value `start + n × step`.
CamoDecimal camoSnapToStep(
  CamoDecimal value,
  CamoDecimal start,
  CamoDecimal step,
) {
  final s = [
    value.scale,
    start.scale,
    step.scale,
  ].reduce((a, b) => a > b ? a : b);
  final unit = step.rescaled(s);
  if (unit <= 0) return value;
  final offset = (value - start).rescaled(s);
  final half = unit ~/ 2;
  final n = offset >= 0 ? (offset + half) ~/ unit : (offset - half) ~/ unit;
  return start + step * n;
}
