import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'bar_geometry.dart';
import 'camo_chart_frame.dart';
import 'cartesian_plot.dart';
import 'chart_data.dart';
import 'chart_model.dart';
import 'chart_renderer.dart';
import 'chart_scale.dart';
import 'chart_style.dart';

/// Bars comparing values across categories: vertical or horizontal, grouped side by side or stacked, with a legend
/// that toggles series, a tooltip on the bar under the pointer and a data table.
///
/// [yAxis] is always the value axis and [xAxis] the category axis, whichever way the bars run. [valueLabels]
/// writes each bar's value at its free end (a stack's total at its end). The plot is one image node; focusing it
/// walks the bars (Left and Right between categories, Up and Down between series) and announces "Q1, North, 42".
/// Bars grow from zero; negative bars go the other way. In a right-to-left layout vertical bars run from the right
/// and horizontal bars start at the right edge.
class CamoBarChart extends StatefulWidget {
  /// Creates a bar chart.
  const CamoBarChart({
    super.key,
    required this.categories,
    required this.series,
    required this.title,
    this.orientation = BarOrientation.vertical,
    this.mode = BarMode.grouped,
    this.valueLabels = false,
    this.xAxis = const ChartAxis(),
    this.yAxis = const ChartAxis(),
    this.loading = false,
    this.empty,
    this.showTable = false,
    this.plotHeight = 220,
    this.style,
  });

  /// The category labels.
  final List<String> categories;

  /// The series.
  final List<ChartSeries> series;

  /// The chart's title.
  final String title;

  /// Which way bars run.
  final BarOrientation orientation;

  /// Side by side or stacked.
  final BarMode mode;

  /// Whether values are written at the bars' ends.
  final bool valueLabels;

  /// The category axis (its title).
  final ChartAxis xAxis;

  /// The value axis.
  final ChartAxis yAxis;

  /// Whether a skeleton stands in for the plot.
  final bool loading;

  /// What shows with no data; "No data" by default.
  final Widget? empty;

  /// Whether the data shows as a table at first.
  final bool showTable;

  /// The height of the plot.
  final double plotHeight;

  /// Style changes for this chart.
  final ChartStyle? style;

  @override
  State<CamoBarChart> createState() => _CamoBarChartState();
}

class _CamoBarChartState extends State<CamoBarChart> {
  Set<int> _hidden = {};
  late bool _table = widget.showTable;

  @override
  void didUpdateWidget(CamoBarChart old) {
    super.didUpdateWidget(old);
    if (old.series.length != widget.series.length) _hidden = {};
    if (old.showTable != widget.showTable) _table = widget.showTable;
  }

  @override
  Widget build(BuildContext context) {
    final style = CamoCharts.styleOf(context, overrides: widget.style);
    final series = widget.series;
    final colors = seriesColors(series, style);
    final shown = [
      for (var i = 0; i < series.length; i++)
        if (!_hidden.contains(i)) i,
    ];
    return CamoChartFrame(
      title: widget.title,
      summary: chartSummary('Bar chart', widget.categories, series),
      legend: [
        for (var i = 0; i < series.length; i++)
          LegendItem(
            label: series[i].name,
            color: colors[i],
            visible: !_hidden.contains(i),
          ),
      ],
      onLegendToggle: (i) => setState(
        () => _hidden = _hidden.contains(i)
            ? ({..._hidden}..remove(i))
            : {..._hidden, i},
      ),
      loading: widget.loading,
      isEmpty: noChartData(widget.categories, series),
      empty: widget.empty,
      plotHeight: widget.plotHeight,
      table: CamoChartDataTable(
        categories: widget.categories,
        series: series,
        caption: '${widget.title} data',
        format: widget.yAxis.format,
      ),
      showTable: _table,
      onShowTableChanged: (value) => setState(() => _table = value),
      child: SizedBox(
        height: widget.plotHeight,
        width: double.infinity,
        child: _BarPlot(
          input: _BarInput(
            categories: widget.categories,
            series: [for (final i in shown) series[i]],
            colors: [for (final i in shown) colors[i]],
            orientation: widget.orientation,
            mode: widget.mode,
            valueLabels: widget.valueLabels,
            xAxis: widget.xAxis,
            yAxis: widget.yAxis,
          ),
          style: style,
        ),
      ),
    );
  }
}

class _BarInput {
  const _BarInput({
    required this.categories,
    required this.series,
    required this.colors,
    required this.orientation,
    required this.mode,
    required this.valueLabels,
    required this.xAxis,
    required this.yAxis,
  });

  final List<String> categories;
  final List<ChartSeries> series;
  final List<Color> colors;
  final BarOrientation orientation;
  final BarMode mode;
  final bool valueLabels;
  final ChartAxis xAxis;
  final ChartAxis yAxis;

  bool get vertical => orientation == BarOrientation.vertical;
  List<List<double?>> get values => [for (final s in series) s.values];
}

// Everything the bar chart draws for one size: the plot rectangle, the bars and the labels.
class _BarScene {
  const _BarScene(this.layout, this.domain, this.scale, this.bars, this.labels);

  final PlotLayout layout;
  final ValueDomain domain;
  final LinearScale scale;
  final List<BarRect> bars;
  final List<AxisLabel> labels;
}

_BarScene _barScene(
  _BarInput input,
  Size size,
  ResolvedChartStyle style,
  PlotEnv env,
) {
  final values = input.values;
  final domain = barDomain(values, input.mode, input.yAxis);
  final valueTexts = [for (final t in domain.ticks) input.yAxis.format(t)];
  final valueTitle = input.yAxis.title;
  final categoryTitle = input.xAxis.title;
  final topTitle = input.vertical ? valueTitle : categoryTitle;
  final bottomTitle = input.vertical ? categoryTitle : valueTitle;
  final insets = env.insets(
    input.vertical ? valueTexts : input.categories,
    topTitle: topTitle != null,
    bottomTitle: bottomTitle != null,
  );
  final layout = plotLayout(size, insets, rtl: env.rtl);
  final plot = layout.plot;
  final scale = input.vertical
      ? LinearScale(domain.low, domain.high, plot.bottom, plot.top)
      : env.rtl
      ? LinearScale(domain.low, domain.high, plot.right, plot.left)
      : LinearScale(domain.low, domain.high, plot.left, plot.right);
  final bars = barRects(
    plot: plot,
    categories: input.categories.length,
    series: values,
    mode: input.mode,
    orientation: input.orientation,
    domain: domain.range,
    barGap: style.barGap,
    groupGap: style.groupGap,
    rtl: env.rtl,
  );
  final labels = [
    ..._axisLabels(input, layout, scale, domain.ticks, valueTexts, bars, env),
    ...env.titles(layout, topTitle, bottomTitle),
  ];
  return _BarScene(layout, domain, scale, bars, labels);
}

// Value labels on the value axis, categories on the other.
List<AxisLabel> _axisLabels(
  _BarInput input,
  PlotLayout layout,
  LinearScale scale,
  List<double> ticks,
  List<String> valueTexts,
  List<BarRect> bars,
  PlotEnv env,
) {
  final plot = layout.plot;
  final startX = env.rtl ? plot.right + labelGap : plot.left - labelGap;
  final startSide = env.rtl ? LabelSide.after : LabelSide.before;
  final below = plot.bottom + labelGap;
  final values = [
    for (var i = 0; i < ticks.length; i++)
      input.vertical
          ? AxisLabel(
              valueTexts[i],
              Offset(startX, scale.map(ticks[i])),
              startSide,
            )
          : AxisLabel(
              valueTexts[i],
              Offset(scale.map(ticks[i]), below),
              LabelSide.below,
            ),
  ];
  final band =
      (input.vertical ? plot.width : plot.height) / input.categories.length;
  final across = input.vertical
      ? env.widest(input.categories)
      : env.labelHeight;
  final step = math.max(1, (across * 1.4 / band).ceil());
  final names = <AxisLabel>[];
  for (var c = 0; c < input.categories.length; c += step) {
    final center = _categoryCenter(bars, c, vertical: input.vertical);
    if (center == null) continue;
    names.add(
      input.vertical
          ? AxisLabel(
              input.categories[c],
              Offset(center, below),
              LabelSide.below,
            )
          : AxisLabel(input.categories[c], Offset(startX, center), startSide),
    );
  }
  return [...values, ...names];
}

// The center of a category's bars across the category axis, or `null` when it has none.
double? _categoryCenter(
  List<BarRect> bars,
  int category, {
  required bool vertical,
}) {
  final own = [
    for (final bar in bars)
      if (bar.category == category) bar.rect,
  ];
  if (own.isEmpty) return null;
  if (vertical) {
    return (own.map((r) => r.left).reduce(math.min) +
            own.map((r) => r.right).reduce(math.max)) /
        2;
  }
  return (own.map((r) => r.top).reduce(math.min) +
          own.map((r) => r.bottom).reduce(math.max)) /
      2;
}

// A value at each bar's free end; a stack gets its side's total there.
List<AxisLabel> _valueLabels(_BarInput input, List<BarRect> bars) {
  const gap = 3.0;
  final format = input.yAxis.format;
  return [
    for (final bar in bars)
      if (bar.end != null)
        () {
          final shown = input.mode == BarMode.stacked
              ? bars
                    .where(
                      (b) =>
                          b.category == bar.category &&
                          (b.value >= 0) == (bar.value >= 0),
                    )
                    .fold(0.0, (sum, b) => sum + b.value)
              : bar.value;
          final r = bar.rect;
          final text = format(shown);
          return switch (bar.end!) {
            BarEdge.top => AxisLabel(
              text,
              Offset(r.center.dx, r.top - gap),
              LabelSide.above,
            ),
            BarEdge.bottom => AxisLabel(
              text,
              Offset(r.center.dx, r.bottom + gap),
              LabelSide.below,
            ),
            BarEdge.right => AxisLabel(
              text,
              Offset(r.right + gap, r.center.dy),
              LabelSide.after,
            ),
            BarEdge.left => AxisLabel(
              text,
              Offset(r.left - gap, r.center.dy),
              LabelSide.before,
            ),
          };
        }(),
  ];
}

class _BarPlot extends StatefulWidget {
  const _BarPlot({required this.input, required this.style});

  final _BarInput input;
  final ResolvedChartStyle style;

  @override
  State<_BarPlot> createState() => _BarPlotState();
}

class _BarPlotState extends State<_BarPlot>
    with SingleTickerProviderStateMixin, DrawInStateMixin {
  late final PlotInputController _input = PlotInputController()
    ..addListener(() => setState(() {}));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = Camouflage.motionOf(context);
    configureDrawIn(widget.style.animate ? motion.durationLong : Duration.zero);
  }

  @override
  void didUpdateWidget(_BarPlot old) {
    super.didUpdateWidget(old);
    if (!_sameData(old.input.series, widget.input.series) ||
        old.input.mode != widget.input.mode) {
      restartDrawIn();
    }
  }

  bool _sameData(List<ChartSeries> a, List<ChartSeries> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].values.length != b[i].values.length) return false;
      for (var j = 0; j < a[i].values.length; j++) {
        if (a[i].values[j] != b[i].values[j]) return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
    final env = plotEnv(context, CamoChartsProvider.of(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        final scene = _barScene(input, constraints.biggest, widget.style, env);
        final bars = scene.bars;
        final pointer = _input.pointer;
        final hit = pointer != null && scene.layout.plot.contains(pointer)
            ? nearestBar(bars, pointer, vertical: input.vertical)
            : null;
        final walk = _input.walk;
        BarRect? focus;
        if (walk != null) {
          for (final bar in bars) {
            if (bar.category == walk.$1 && bar.series == walk.$2) focus = bar;
          }
        }
        final current = hit ?? focus;
        final announce = walk == null
            ? null
            : _barText(input, walk.$1, walk.$2);
        return PlotInputRegion(
          controller: _input,
          categories: input.categories.length,
          series: input.series.length,
          announce: announce,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BarPainter(
                    scene,
                    input,
                    env,
                    widget.style,
                    current == null ? null : bars.indexOf(current),
                    drawIn,
                  ),
                ),
              ),
              if (current != null)
                Positioned.fill(
                  child: ChartTooltip(
                    title: input.categories[current.category],
                    rows: _barRows(input, current.category, current.series),
                    x: current.rect.center.dx,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(
    this.scene,
    this.input,
    this.env,
    this.style,
    this.active,
    this.progress,
  ) : super(repaint: progress);

  final _BarScene scene;
  final _BarInput input;
  final PlotEnv env;
  final ResolvedChartStyle style;
  final int? active;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = scene.layout.plot;
    paintGrid(
      canvas,
      plot,
      [for (final t in scene.domain.ticks) scene.scale.map(t)],
      vertical: !input.vertical,
      style: style,
      grid: env.colors.outlineVariant,
      axis: env.colors.outline,
    );
    env.paintLabels(canvas, scene.labels);
    final marks = [
      for (final bar in scene.bars)
        BarMark(bar.rect, input.colors[bar.series], bar.end),
    ];
    final baseline = scene.scale.map(
      0.clamp(scene.domain.low, scene.domain.high).toDouble(),
    );
    env.renderer.paintBarChart(
      canvas,
      size,
      BarChartSpec(
        plot: plot,
        bars: marks,
        baseline: baseline,
        vertical: input.vertical,
        active: active,
        progress: progress.value,
      ),
      style,
    );
    if (input.valueLabels && progress.value >= 1) {
      env.paintLabels(canvas, _valueLabels(input, scene.bars));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}

// The hovered or focused bar's series and value; a stacked category adds its total.
List<TooltipRow> _barRows(_BarInput input, int category, int series) {
  final format = input.yAxis.format;
  final item = input.series[series];
  final v = category < item.values.length ? item.values[category] : null;
  final own = TooltipRow(
    input.colors[series],
    '${item.name}: ${v == null ? '-' : format(v)}',
  );
  if (input.mode != BarMode.stacked) return [own];
  var total = 0.0;
  for (final s in input.series) {
    total += category < s.values.length ? (s.values[category] ?? 0) : 0;
  }
  return [own, TooltipRow(null, 'Total: ${format(total)}')];
}

String _barText(_BarInput input, int category, int series) {
  final label = category < input.categories.length
      ? input.categories[category]
      : '';
  if (series >= input.series.length) return label;
  final item = input.series[series];
  final v = category < item.values.length ? item.values[category] : null;
  return '$label, ${item.name}, ${v == null ? 'no data' : input.yAxis.format(v)}';
}
