import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'bar_geometry.dart';
import 'chart_style.dart';
import 'line_geometry.dart';
import 'sparkline_geometry.dart';

/// What a sparkline draws: its [values], [kind], the [range] they scale to, the [highlight] and the draw-in
/// [progress].
class SparklineSpec {
  /// Creates a sparkline spec.
  const SparklineSpec({
    required this.values,
    required this.kind,
    required this.range,
    required this.highlight,
    required this.color,
    required this.progress,
  });

  /// The values, `null` for gaps.
  final List<double?> values;

  /// The form.
  final SparklineKind kind;

  /// The data range the values scale to.
  final (double, double) range;

  /// Which points get a dot.
  final SparklineHighlight highlight;

  /// The color of the line, area or bars.
  final Color color;

  /// How far the draw-in has come, 0 to 1.
  final double progress;
}

/// One series of a line chart: its [upper] edge (`null` is a gap) and, for areas, the [lower] edge it fills down
/// to.
class LineSeriesSpec {
  /// Creates a series spec.
  const LineSeriesSpec({
    required this.color,
    required this.upper,
    required this.lower,
  });

  /// The color of the line and area.
  final Color color;

  /// The line's points, one per category.
  final List<Offset?> upper;

  /// The area's lower edge, or `null` for a plain line.
  final List<Offset?>? lower;
}

/// What a line chart draws inside [plot]: the [series] (areas first, then lines) joined by [curve], a dot on every
/// point when [markers], on [activeCategory] (hovered or focused) and a ring on [focusedSeries]' dot, with the
/// draw-in [progress].
class LineChartSpec {
  /// Creates a line chart spec.
  const LineChartSpec({
    required this.plot,
    required this.series,
    required this.curve,
    required this.markers,
    required this.activeCategory,
    required this.focusedSeries,
    required this.progress,
  });

  /// The plot rectangle.
  final Rect plot;

  /// The series.
  final List<LineSeriesSpec> series;

  /// How points connect.
  final LineCurve curve;

  /// Whether every point has a dot.
  final bool markers;

  /// The hovered or focused category.
  final int? activeCategory;

  /// The series the keyboard is on.
  final int? focusedSeries;

  /// How far the draw-in has come, 0 to 1.
  final double progress;
}

/// One bar: its [rect] at full size, its [color] and the [edge] that is its free end (`null` inside a stack).
class BarMark {
  /// Creates a bar mark.
  const BarMark(this.rect, this.color, this.edge);

  /// The bar at full size.
  final Rect rect;

  /// The bar's color.
  final Color color;

  /// The free end, which gets the radius.
  final BarEdge? edge;
}

/// What a bar chart draws inside [plot]: the [bars], growing from [baseline] (a pixel position along the value
/// axis; [vertical] bars grow up or down, the others left or right) by [progress]; [active] is the bar under the
/// pointer or focus.
class BarChartSpec {
  /// Creates a bar chart spec.
  const BarChartSpec({
    required this.plot,
    required this.bars,
    required this.baseline,
    required this.vertical,
    required this.active,
    required this.progress,
  });

  /// The plot rectangle.
  final Rect plot;

  /// The bars.
  final List<BarMark> bars;

  /// The zero line's pixel position.
  final double baseline;

  /// Whether bars run up and down.
  final bool vertical;

  /// The index of the bar under the pointer or focus.
  final int? active;

  /// How far the draw-in has come, 0 to 1.
  final double progress;
}

/// Draws chart marks. The default draws lines, areas and bars from the [ResolvedChartStyle]; supply your own
/// through [CamoChartsProvider] to take over the drawing completely (the frame, legend and tables stay).
///
/// Extend it to override only some marks; the others keep the default drawing.
abstract class ChartRenderer {
  /// Creates a renderer.
  const ChartRenderer();

  /// Draws a sparkline into [canvas], which is exactly the sparkline's [size].
  void paintSparkline(
    Canvas canvas,
    Size size,
    SparklineSpec spec,
    ResolvedChartStyle style,
  );

  /// Draws the lines, areas and markers of a line chart into [canvas], the whole chart box (the grid is drawn).
  void paintLineChart(
    Canvas canvas,
    Size size,
    LineChartSpec spec,
    ResolvedChartStyle style,
  ) => const DefaultChartRenderer().paintLineChart(canvas, size, spec, style);

  /// Draws the bars of a bar chart into [canvas], the whole chart box.
  void paintBarChart(
    Canvas canvas,
    Size size,
    BarChartSpec spec,
    ResolvedChartStyle style,
  ) => const DefaultChartRenderer().paintBarChart(canvas, size, spec, style);
}

/// Makes [renderer] the drawing for every chart below it.
class CamoChartsProvider extends InheritedWidget {
  /// Creates a provider.
  const CamoChartsProvider({
    super.key,
    required this.renderer,
    required super.child,
  });

  /// The renderer.
  final ChartRenderer renderer;

  /// The nearest renderer, or the default.
  static ChartRenderer of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CamoChartsProvider>()
          ?.renderer ??
      const DefaultChartRenderer();

  @override
  bool updateShouldNotify(CamoChartsProvider oldWidget) =>
      oldWidget.renderer != renderer;
}

/// The default drawing.
class DefaultChartRenderer extends ChartRenderer {
  /// Creates the default renderer.
  const DefaultChartRenderer();

  @override
  void paintSparkline(
    Canvas canvas,
    Size size,
    SparklineSpec spec,
    ResolvedChartStyle style,
  ) {
    final inset =
        (style.lineWidth > style.markerSize
            ? style.lineWidth
            : style.markerSize) *
        0.5;
    final area = Size(size.width - inset * 2, size.height - inset * 2);
    if (area.width <= 0 || area.height <= 0) return;
    final points = sparklinePoints(
      downsample(spec.values, area.width.floor().clamp(1, 1 << 20)),
      spec.range,
      area,
      inset,
    );
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width * spec.progress, size.height));
    if (spec.kind == SparklineKind.bars) {
      _bars(canvas, size, points, spec, style, inset);
    } else {
      _trend(canvas, size, points, spec, style, inset);
    }
    canvas.restore();
    if (spec.progress >= 1) _highlight(canvas, points, spec, style);
  }

  void _trend(
    Canvas canvas,
    Size size,
    List<Offset?> points,
    SparklineSpec spec,
    ResolvedChartStyle style,
    double inset,
  ) {
    final stroke = Paint()
      ..color = spec.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final baseline = size.height - inset;
    for (final run in sparklineSegments(points)) {
      if (run.length == 1) {
        canvas.drawCircle(
          run.first,
          style.lineWidth * 1.5 / 2 + 1,
          Paint()..color = spec.color,
        );
        continue;
      }
      final line = Path()..moveTo(run.first.dx, run.first.dy);
      for (final p in run.skip(1)) {
        line.lineTo(p.dx, p.dy);
      }
      if (spec.kind == SparklineKind.area) {
        final fill = Path.from(line)
          ..lineTo(run.last.dx, baseline)
          ..lineTo(run.first.dx, baseline)
          ..close();
        canvas.drawPath(
          fill,
          Paint()..color = spec.color.withValues(alpha: style.areaOpacity),
        );
      }
      canvas.drawPath(line, stroke);
    }
  }

  void _bars(
    Canvas canvas,
    Size size,
    List<Offset?> points,
    SparklineSpec spec,
    ResolvedChartStyle style,
    double inset,
  ) {
    final slot =
        (size.width - inset * 2) / (points.isEmpty ? 1 : points.length);
    final width = (slot - style.barGap) < 1 ? 1.0 : slot - style.barGap;
    final baseline = size.height - inset;
    final paint = Paint()..color = spec.color;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      if (point == null) continue;
      final left = inset + (i + 0.5) * slot - width / 2;
      final height = (baseline - point.dy) < 1 ? 1.0 : baseline - point.dy;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, point.dy, width, height),
          Radius.circular(style.barRadius),
        ),
        paint,
      );
    }
  }

  void _highlight(
    Canvas canvas,
    List<Offset?> points,
    SparklineSpec spec,
    ResolvedChartStyle style,
  ) {
    final shown = switch (spec.highlight) {
      SparklineHighlight.none => const <Offset>[],
      SparklineHighlight.last => [
        ?points.lastWhere((p) => p != null, orElse: () => null),
      ],
      SparklineHighlight.extremes => sparklineExtremes(points),
    };
    final paint = Paint()..color = spec.color;
    for (final point in shown) {
      canvas.drawCircle(point, style.markerSize / 2, paint);
    }
  }

  @override
  void paintLineChart(
    Canvas canvas,
    Size size,
    LineChartSpec spec,
    ResolvedChartStyle style,
  ) {
    final reveal = spec.progress >= 1
        ? size.width
        : spec.plot.left + spec.plot.width * spec.progress;
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, 0, reveal, size.height));
    for (final series in spec.series) {
      final lower = series.lower;
      if (lower == null) continue;
      for (final (from, to) in gapRuns(series.upper)) {
        if (to - from < 2) continue;
        final top = [for (var i = from; i < to; i++) series.upper[i]!];
        final bottom = [for (var i = to - 1; i >= from; i--) lower[i]!];
        final area = Path();
        addCurve(area, top, spec.curve);
        addCurve(area, bottom, spec.curve, connect: true);
        canvas.drawPath(
          area..close(),
          Paint()..color = series.color.withValues(alpha: style.areaOpacity),
        );
      }
    }
    for (final series in spec.series) {
      final stroke = Paint()
        ..color = series.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final (from, to) in gapRuns(series.upper)) {
        final points = [for (var i = from; i < to; i++) series.upper[i]!];
        if (points.length == 1) {
          canvas.drawCircle(
            points.first,
            style.lineWidth * 1.5 / 2 + 1,
            Paint()..color = series.color,
          );
        } else {
          final line = Path();
          addCurve(line, points, spec.curve);
          canvas.drawPath(line, stroke);
        }
      }
    }
    _markers(canvas, spec, style);
    canvas.restore();
  }

  void _markers(Canvas canvas, LineChartSpec spec, ResolvedChartStyle style) {
    final radius = style.markerSize / 2;
    for (var s = 0; s < spec.series.length; s++) {
      final series = spec.series[s];
      for (var i = 0; i < series.upper.length; i++) {
        final point = series.upper[i];
        if (point == null) continue;
        final active = i == spec.activeCategory;
        if (!spec.markers && !active) continue;
        if (active && s == spec.focusedSeries) {
          canvas.drawCircle(
            point,
            radius * 2,
            Paint()..color = series.color.withValues(alpha: 0.3),
          );
        }
        canvas.drawCircle(point, radius, Paint()..color = series.color);
      }
    }
  }

  @override
  void paintBarChart(
    Canvas canvas,
    Size size,
    BarChartSpec spec,
    ResolvedChartStyle style,
  ) {
    for (var i = 0; i < spec.bars.length; i++) {
      final bar = spec.bars[i];
      final rect = _grown(bar.rect, spec);
      final dim = spec.active != null && spec.active != i;
      final paint = Paint()
        ..color = dim ? bar.color.withValues(alpha: 0.55) : bar.color;
      final round = math.min(
        style.barRadius,
        math.min(rect.width, rect.height) / 2,
      );
      final edge = bar.edge;
      if (edge == null || round <= 0) {
        canvas.drawRect(rect, paint);
      } else {
        canvas.drawRRect(_roundedAt(rect, edge, round), paint);
      }
    }
  }

  // The rect between the baseline and its full size, by the draw-in progress.
  Rect _grown(Rect rect, BarChartSpec spec) {
    double at(double edge) =>
        spec.baseline + (edge - spec.baseline) * spec.progress;
    return spec.vertical
        ? Rect.fromLTRB(rect.left, at(rect.top), rect.right, at(rect.bottom))
        : Rect.fromLTRB(at(rect.left), rect.top, at(rect.right), rect.bottom);
  }

  RRect _roundedAt(Rect rect, BarEdge edge, double radius) {
    final corner = Radius.circular(radius);
    return switch (edge) {
      BarEdge.top => RRect.fromRectAndCorners(
        rect,
        topLeft: corner,
        topRight: corner,
      ),
      BarEdge.bottom => RRect.fromRectAndCorners(
        rect,
        bottomLeft: corner,
        bottomRight: corner,
      ),
      BarEdge.left => RRect.fromRectAndCorners(
        rect,
        topLeft: corner,
        bottomLeft: corner,
      ),
      BarEdge.right => RRect.fromRectAndCorners(
        rect,
        topRight: corner,
        bottomRight: corner,
      ),
    };
  }
}
