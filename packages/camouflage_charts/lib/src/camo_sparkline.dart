import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'chart_renderer.dart';
import 'chart_style.dart';
import 'sparkline_geometry.dart';

/// A small trend with no axes, grid or legend, for a row or a card.
///
/// It sizes to what it is given (100 x 28 when that says nothing), scales to the data or to [range], and breaks
/// the line at `null` values. A sparkline is one image node whose text is [sparklineSummary]: [description] names
/// it ("Signups, last 30 days") and the text adds the first and last values and the change, so the direction is
/// never only a color. It is not focusable.
class CamoSparkline extends StatefulWidget {
  /// Creates a sparkline.
  const CamoSparkline({
    super.key,
    required this.values,
    this.kind = SparklineKind.line,
    this.range,
    this.highlight = SparklineHighlight.last,
    this.tone = Tone.defaultTone,
    this.description,
    this.style,
  });

  /// The values, `null` for gaps.
  final List<double?> values;

  /// The form.
  final SparklineKind kind;

  /// The `(min, max)` the values scale to; `null` reads the data.
  final (double, double)? range;

  /// Which points get a dot.
  final SparklineHighlight highlight;

  /// The color family of the marks.
  final Tone tone;

  /// Names the sparkline for a screen reader.
  final String? description;

  /// Style changes for this sparkline, on top of the theme, the skin's preset and the tokens.
  final ChartStyle? style;

  @override
  State<CamoSparkline> createState() => _CamoSparklineState();
}

class _CamoSparklineState extends State<CamoSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this);
  Duration _duration = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = Camouflage.motionOf(context);
    final animate = CamoCharts.styleOf(
      context,
      overrides: widget.style,
    ).animate;
    final next = animate ? motion.durationLong : Duration.zero;
    if (next != _duration || !_progress.isAnimating && _progress.value == 0) {
      _duration = next;
      _run();
    }
  }

  @override
  void didUpdateWidget(CamoSparkline old) {
    super.didUpdateWidget(old);
    if (!identical(old.values, widget.values) &&
        !_sameValues(old.values, widget.values)) {
      _run();
    }
  }

  bool _sameValues(List<double?> a, List<double?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _run() {
    if (_duration == Duration.zero) {
      _progress.value = 1;
    } else {
      _progress.duration = _duration;
      _progress.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = CamoCharts.styleOf(context, overrides: widget.style);
    final theme = Camouflage.themeOf(context, component: 'CamoSparkline');
    final renderer = CamoChartsProvider.of(context);
    final color = theme.colors.family(widget.tone).strong;
    final range =
        widget.range ??
        sparklineRange(
          widget.values,
          includeZero: widget.kind == SparklineKind.bars,
        );
    return Semantics(
      image: true,
      label: sparklineSummary(widget.values, widget.description),
      excludeSemantics: true,
      child: CustomPaint(
        size: const Size(100, 28),
        painter: _SparklinePainter(
          widget.values,
          widget.kind,
          range,
          widget.highlight,
          color,
          style,
          renderer,
          _progress,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(
    this.values,
    this.kind,
    this.range,
    this.highlight,
    this.color,
    this.style,
    this.renderer,
    this.progress,
  ) : super(repaint: progress);

  final List<double?> values;
  final SparklineKind kind;
  final (double, double) range;
  final SparklineHighlight highlight;
  final Color color;
  final ResolvedChartStyle style;
  final ChartRenderer renderer;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final spec = SparklineSpec(
      values: values,
      kind: kind,
      range: range,
      highlight: highlight,
      color: color,
      progress: progress.value,
    );
    renderer.paintSparkline(canvas, size, spec, style);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values ||
      old.kind != kind ||
      old.range != range ||
      old.highlight != highlight ||
      old.color != color ||
      old.style != style ||
      old.renderer != renderer;
}
