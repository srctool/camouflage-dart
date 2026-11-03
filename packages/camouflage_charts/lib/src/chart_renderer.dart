import 'package:flutter/widgets.dart';

import 'chart_style.dart';
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

/// Draws chart marks. The default draws lines, areas and bars from the [ResolvedChartStyle]; supply your own
/// through [CamoChartsProvider] to take over the drawing completely (the frame, legend and tables stay).
abstract interface class ChartRenderer {
  /// Draws a sparkline into [canvas], which is exactly the sparkline's [size].
  void paintSparkline(
    Canvas canvas,
    Size size,
    SparklineSpec spec,
    ResolvedChartStyle style,
  );
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
class DefaultChartRenderer implements ChartRenderer {
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
}
