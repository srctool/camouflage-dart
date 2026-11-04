import 'dart:math' as math;
import 'dart:ui';

import 'bar_geometry.dart';
import 'chart_data.dart';
import 'chart_renderer.dart';
import 'chart_scale.dart';
import 'chart_style.dart';
import 'line_geometry.dart';
import 'sparkline_geometry.dart';

/// The value axis of a chart: nice [ticks] and the [low]..[high] range they (or the axis' own bounds) give.
class ValueDomain {
  /// Creates a value domain.
  const ValueDomain(this.ticks, this.low, this.high);

  /// The tick values.
  final List<double> ticks;

  /// The lowest value on the axis.
  final double low;

  /// The highest value on the axis.
  final double high;

  /// `(low, high)`.
  (double, double) get range => (low, high);
}

/// The value axis for data between [dataLow] and [dataHigh] (`null` for no data): the bounds [axis] fixes, else
/// nice ticks around the data, widened to include zero when [includeZero].
ValueDomain valueDomain(
  double? dataLow,
  double? dataHigh,
  ChartAxis axis, {
  required bool includeZero,
}) {
  var low = dataLow ?? 0;
  var high = dataHigh ?? 1;
  if (includeZero) {
    low = math.min(low, 0);
    high = math.max(high, 0);
  }
  final ticks = niceTicks(axis.min ?? low, axis.max ?? high, axis.tickCount);
  final from = axis.min ?? ticks.first;
  final to = axis.max ?? ticks.last;
  return ValueDomain(
    [
      for (final t in ticks)
        if (t >= from && t <= to) t,
    ],
    from,
    to,
  );
}

/// The color of each series: its own, else the style's palette entry.
List<Color> seriesColors(List<ChartSeries> series, ResolvedChartStyle style) =>
    [
      for (var i = 0; i < series.length; i++)
        series[i].color ?? style.seriesColor(i),
    ];

/// True when there is nothing to draw: no categories, or every value is a gap.
bool noChartData(List<String> categories, List<ChartSeries> series) =>
    categories.isEmpty || series.every((s) => s.values.every((v) => v == null));

/// The screen reader text of a chart: "Line chart, 2 series, 12 categories", then each series' trend through
/// [sparklineSummary] ("Sales: from 3 to 9, up 200%").
String chartSummary(
  String kind,
  List<String> categories,
  List<ChartSeries> series,
) {
  final noun = categories.length == 1 ? 'category' : 'categories';
  final head = '$kind, ${series.length} series, ${categories.length} $noun';
  if (series.isEmpty) return head;
  return '$head. ${series.map((s) => sparklineSummary(s.values, s.name)).join('; ')}';
}

/// The line chart's `times` when they can place the categories on a time axis: one per category, ascending.
List<int>? validTimes(List<int>? times, int count) {
  if (times == null || times.length != count || count < 2) return null;
  for (var i = 1; i < times.length; i++) {
    if (times[i - 1] >= times[i]) return null;
  }
  return times;
}

/// The x position of each category: evenly spread, or by [times] (epoch milliseconds, strictly ascending).
List<double> categoryPositions(Rect plot, int count, List<int>? times) {
  final ascending = validTimes(times, count);
  if (count == 0) return const [];
  if (ascending != null) {
    final scale = LinearScale(
      ascending.first.toDouble(),
      ascending.last.toDouble(),
      plot.left,
      plot.right,
    );
    return [for (final t in ascending) scale.map(t.toDouble())];
  }
  if (count == 1) return [plot.center.dx];
  return [
    for (var i = 0; i < count; i++) plot.left + plot.width * i / (count - 1),
  ];
}

/// The value axis for [values] (one list per visible series) drawn as [kind], stacked into [bands] when given.
ValueDomain lineDomain(
  LineKind kind,
  List<List<double?>> values,
  List<List<StackBand?>>? bands,
  ChartAxis axis,
) {
  final flat = bands != null
      ? [
          for (final row in bands)
            for (final band in row)
              if (band != null) band.$2,
        ]
      : [for (final row in values) ...row.whereType<double>()];
  return valueDomain(
    flat.isEmpty ? null : flat.reduce(math.min),
    flat.isEmpty ? null : flat.reduce(math.max),
    axis,
    includeZero: kind != LineKind.line,
  );
}

/// The points of a line chart, ready to draw: a [LineSeriesSpec] per visible series over the positions [xs].
class LineModel {
  /// Creates a line model.
  const LineModel(this.domain, this.yScale, this.xs, this.specs);

  /// The value axis.
  final ValueDomain domain;

  /// Maps values to y pixels.
  final LinearScale yScale;

  /// The x position of each category.
  final List<double> xs;

  /// One entry per visible series.
  final List<LineSeriesSpec> specs;
}

/// The drawing model: [values] per visible series placed on [xs] and the [domain] in [plot].
LineModel lineModel({
  required LineKind kind,
  required Rect plot,
  required List<List<double?>> values,
  required List<List<StackBand?>>? bands,
  required List<Color> colors,
  required ValueDomain domain,
  required List<double> xs,
}) {
  final yScale = LinearScale(domain.low, domain.high, plot.bottom, plot.top);
  final baseline = yScale.map(0.clamp(domain.low, domain.high).toDouble());
  final specs = <LineSeriesSpec>[];
  for (var s = 0; s < values.length; s++) {
    final upper = <Offset?>[
      for (var c = 0; c < xs.length; c++)
        () {
          final top = bands != null
              ? bands[s][c]?.$2
              : (c < values[s].length ? values[s][c] : null);
          return top == null ? null : Offset(xs[c], yScale.map(top));
        }(),
    ];
    final List<Offset?>? lower = switch (kind) {
      LineKind.line => null,
      LineKind.area => [
        for (final p in upper) p == null ? null : Offset(p.dx, baseline),
      ],
      LineKind.stackedArea => [
        for (var c = 0; c < xs.length; c++)
          bands![s][c] == null
              ? null
              : Offset(xs[c], yScale.map(bands[s][c]!.$1)),
      ],
    };
    specs.add(LineSeriesSpec(color: colors[s], upper: upper, lower: lower));
  }
  return LineModel(domain, yScale, xs, specs);
}

/// The value axis of a bar chart: bars start at zero, and a stacked category reaches its positive and negative
/// sums.
ValueDomain barDomain(
  List<List<double?>> values,
  BarMode mode,
  ChartAxis axis,
) {
  var categories = 0;
  for (final row in values) {
    categories = math.max(categories, row.length);
  }
  final extents = <double>[];
  if (mode == BarMode.stacked) {
    for (var c = 0; c < categories; c++) {
      var positive = 0.0;
      var negative = 0.0;
      for (final row in values) {
        final v = c < row.length ? row[c] : null;
        if (v == null) continue;
        if (v > 0) positive += v;
        if (v < 0) negative += v;
      }
      extents
        ..add(positive)
        ..add(negative);
    }
  } else {
    for (final row in values) {
      extents.addAll(row.whereType<double>());
    }
  }
  return valueDomain(
    extents.isEmpty ? null : extents.reduce(math.min),
    extents.isEmpty ? null : extents.reduce(math.max),
    axis,
    includeZero: true,
  );
}
