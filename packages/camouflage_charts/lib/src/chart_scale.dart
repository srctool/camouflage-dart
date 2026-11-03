import 'dart:math' as math;

import 'chart_data.dart';

// The nearest "nice" step (1, 2, 5 times a power of ten) to [range].
double _niceNumber(double range, {required bool round}) {
  final exponent = (math.log(range) / math.ln10).floorToDouble();
  final fraction = range / math.pow(10, exponent);
  final double nice;
  if (round) {
    nice = fraction < 1.5
        ? 1
        : fraction < 3
        ? 2
        : fraction < 7
        ? 5
        : 10;
  } else {
    nice = fraction <= 1
        ? 1
        : fraction <= 2
        ? 2
        : fraction <= 5
        ? 5
        : 10;
  }
  return nice * math.pow(10, exponent);
}

/// Tick values for an axis over [min]..[max], about [count] of them, at steps of 1, 2 or 5 times a power of ten.
///
/// The first tick is at or below [min] and the last at or above [max]. A zero-height range widens around its
/// value.
List<double> niceTicks(double min, double max, [int count = defaultTickCount]) {
  if (count < 2) throw ArgumentError.value(count, 'count', 'at least 2');
  var low = math.min(min, max);
  var high = math.max(min, max);
  if (low == high) {
    final pad = low == 0 ? 1.0 : low.abs() * 0.1;
    low -= pad;
    high += pad;
  }
  final range = _niceNumber(high - low, round: false);
  final step = _niceNumber(range / (count - 1), round: true);
  final first = (low / step).floorToDouble() * step;
  final last = (high / step).ceilToDouble() * step;
  final ticks = <double>[];
  for (var i = 0; first + i * step <= last + step / 10; i++) {
    // Multiplying (not adding) keeps 0.1 + 0.2 style drift out of the ticks.
    ticks.add(first + i * step);
  }
  return ticks;
}

/// A linear map from a data domain to a pixel range; the range may run backwards (a y axis does).
class LinearScale {
  /// Maps `domainStart..domainEnd` onto `rangeStart..rangeEnd`.
  const LinearScale(
    this.domainStart,
    this.domainEnd,
    this.rangeStart,
    this.rangeEnd,
  );

  /// The data value at the start of the range.
  final double domainStart;

  /// The data value at the end of the range.
  final double domainEnd;

  /// The pixel at the start of the domain.
  final double rangeStart;

  /// The pixel at the end of the domain.
  final double rangeEnd;

  /// The pixel position of [value].
  double map(double value) {
    final span = domainEnd - domainStart;
    final t = span == 0 ? 0.0 : (value - domainStart) / span;
    return rangeStart + (rangeEnd - rangeStart) * t;
  }

  /// The data value at pixel [position].
  double invert(double position) {
    final span = rangeEnd - rangeStart;
    final t = span == 0 ? 0.0 : (position - rangeStart) / span;
    return domainStart + (domainEnd - domainStart) * t;
  }
}
