import 'dart:math' as math;
import 'dart:ui';

import 'chart_data.dart';

/// The form of a sparkline.
enum SparklineKind {
  /// A line.
  line,

  /// A line with the area below it filled.
  area,

  /// One bar per value.
  bars,
}

/// Which points of a sparkline get a dot.
enum SparklineHighlight {
  /// None.
  none,

  /// The last point.
  last,

  /// The highest and the lowest point.
  extremes,
}

/// The data's own extent; bars always include zero so they grow from a baseline.
(double, double) sparklineRange(
  List<double?> values, {
  bool includeZero = false,
}) {
  final present = values.whereType<double>().toList();
  if (present.isEmpty) return (0, 1);
  final low = present.reduce(math.min);
  final high = present.reduce(math.max);
  return includeZero ? (math.min(low, 0), math.max(high, 0)) : (low, high);
}

/// The text a screen reader gets for a sparkline: "Trend from 3 to 9, up 200%", led by [description] when given.
String sparklineSummary(List<double?> values, [String? description]) {
  final present = values.whereType<double>().toList();
  final String body;
  if (present.isEmpty) {
    body = 'no data';
  } else if (present.length == 1) {
    body = 'at ${formatChartNumber(present.first)}';
  } else {
    body =
        'from ${formatChartNumber(present.first)} to '
        '${formatChartNumber(present.last)}, '
        '${_change(present.first, present.last)}';
  }
  return description == null ? 'Trend $body' : '$description: $body';
}

String _change(double first, double last) {
  if (last == first) return 'flat';
  final direction = last > first ? 'up' : 'down';
  if (first == 0) {
    return '$direction by ${formatChartNumber((last - first).abs())}';
  }
  return '$direction ${((last - first).abs() / first.abs() * 100).round()}%';
}

/// Reduces [values] to about [buckets] columns, keeping each column's lowest and highest value (in their original
/// order) so a peak survives; a column of only gaps stays a gap.
List<double?> downsample(List<double?> values, int buckets) {
  if (values.length <= buckets * 2) return values;
  final result = <double?>[];
  for (var bucket = 0; bucket < buckets; bucket++) {
    final from = bucket * values.length ~/ buckets;
    final to = (bucket + 1) * values.length ~/ buckets;
    final slice = [
      for (var i = from; i < to; i++)
        if (values[i] != null) i,
    ];
    if (slice.isEmpty) {
      result.add(null);
      continue;
    }
    var low = slice.first;
    var high = slice.first;
    for (final i in slice) {
      if (values[i]! < values[low]!) low = i;
      if (values[i]! > values[high]!) high = i;
    }
    for (final i in {low, high}.toList()..sort()) {
      result.add(values[i]);
    }
  }
  return result;
}

/// The pixel position of each value inside [area] (inset by [inset]); `null` stays a gap.
List<Offset?> sparklinePoints(
  List<double?> values,
  (double, double) range,
  Size area,
  double inset,
) {
  final span = range.$2 - range.$1;
  return [
    for (var i = 0; i < values.length; i++)
      if (values[i] == null)
        null
      else
        Offset(
          values.length == 1
              ? inset + area.width / 2
              : inset + area.width * i / (values.length - 1),
          inset +
              area.height *
                  (1 - (span == 0 ? 0.5 : (values[i]! - range.$1) / span)),
        ),
  ];
}

/// The runs of points between gaps.
List<List<Offset>> sparklineSegments(List<Offset?> points) {
  final runs = <List<Offset>>[];
  var current = <Offset>[];
  for (final point in points) {
    if (point == null) {
      if (current.isNotEmpty) runs.add(current);
      current = <Offset>[];
    } else {
      current.add(point);
    }
  }
  if (current.isNotEmpty) runs.add(current);
  return runs;
}

/// The highest and the lowest point (one when they're the same).
List<Offset> sparklineExtremes(List<Offset?> points) {
  final present = points.whereType<Offset>().toList();
  if (present.isEmpty) return const [];
  final top = present.reduce((a, b) => b.dy < a.dy ? b : a);
  final bottom = present.reduce((a, b) => b.dy > a.dy ? b : a);
  return top == bottom ? [top] : [top, bottom];
}
