import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'camo_chart_frame.dart';
import 'cartesian_plot.dart';
import 'chart_data.dart';
import 'chart_model.dart';
import 'chart_renderer.dart';
import 'chart_scale.dart';
import 'chart_style.dart';
import 'line_geometry.dart';
import 'time_axis.dart';

/// A chart of values over an ordered axis, as lines, areas or stacked areas, with a legend that toggles series, a
/// tooltip and crosshair at the nearest category, and a data table.
///
/// [categories] label the x axis (one per value); [times] (epoch milliseconds, ascending, [timeZoneOffsetMinutes]
/// from UTC) places them on a time axis with calendar ticks instead. The plot is one image node whose text is
/// [title] and each series' trend; focusing it walks the points (Left and Right between categories, Up and Down
/// between series, Home and End) and announces "Jan, Sales, 42". A `null` value breaks the line; stacked areas
/// treat negative values as zero. The time axis keeps its direction in a right-to-left layout, as time does.
class CamoLineChart extends StatefulWidget {
  /// Creates a line chart.
  const CamoLineChart({
    super.key,
    required this.categories,
    required this.series,
    required this.title,
    this.kind = LineKind.line,
    this.curve = LineCurve.linear,
    this.markers = MarkerVisibility.onHover,
    this.xAxis = const ChartAxis(),
    this.yAxis = const ChartAxis(),
    this.times,
    this.timeZoneOffsetMinutes = 0,
    this.loading = false,
    this.empty,
    this.showTable = false,
    this.plotHeight = 220,
    this.style,
  });

  /// The x labels, one per value.
  final List<String> categories;

  /// The series.
  final List<ChartSeries> series;

  /// The chart's title.
  final String title;

  /// Lines, areas or stacked areas.
  final LineKind kind;

  /// How points connect.
  final LineCurve curve;

  /// When points get a dot.
  final MarkerVisibility markers;

  /// The category axis (its title).
  final ChartAxis xAxis;

  /// The value axis.
  final ChartAxis yAxis;

  /// Epoch milliseconds per category, ascending, for a time axis.
  final List<int>? times;

  /// The zone of the time axis, minutes from UTC.
  final int timeZoneOffsetMinutes;

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
  State<CamoLineChart> createState() => _CamoLineChartState();
}

class _CamoLineChartState extends State<CamoLineChart> {
  Set<int> _hidden = {};
  late bool _table = widget.showTable;

  @override
  void didUpdateWidget(CamoLineChart old) {
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
      summary: chartSummary('Line chart', widget.categories, series),
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
        child: _LinePlot(
          input: _LineInput(
            categories: widget.categories,
            series: [for (final i in shown) series[i]],
            colors: [for (final i in shown) colors[i]],
            kind: widget.kind,
            curve: widget.curve,
            markers: widget.markers,
            xAxis: widget.xAxis,
            yAxis: widget.yAxis,
            times: widget.times,
            offsetMinutes: widget.timeZoneOffsetMinutes,
          ),
          style: style,
        ),
      ),
    );
  }
}

class _LineInput {
  const _LineInput({
    required this.categories,
    required this.series,
    required this.colors,
    required this.kind,
    required this.curve,
    required this.markers,
    required this.xAxis,
    required this.yAxis,
    required this.times,
    required this.offsetMinutes,
  });

  final List<String> categories;
  final List<ChartSeries> series;
  final List<Color> colors;
  final LineKind kind;
  final LineCurve curve;
  final MarkerVisibility markers;
  final ChartAxis xAxis;
  final ChartAxis yAxis;
  final List<int>? times;
  final int offsetMinutes;

  List<List<double?>> get values => [for (final s in series) s.values];
}

// Everything the line chart draws for one size: the plot rectangle, the points and the labels.
class _LineScene {
  const _LineScene(this.layout, this.model, this.labels);

  final PlotLayout layout;
  final LineModel model;
  final List<AxisLabel> labels;
}

_LineScene _lineScene(_LineInput input, Size size, PlotEnv env) {
  final values = input.values;
  final bands = input.kind == LineKind.stackedArea ? stack(values) : null;
  final domain = lineDomain(input.kind, values, bands, input.yAxis);
  final yTexts = [for (final t in domain.ticks) input.yAxis.format(t)];
  final insets = env.insets(
    yTexts,
    topTitle: input.yAxis.title != null,
    bottomTitle: input.xAxis.title != null,
  );
  final layout = plotLayout(size, insets, rtl: env.rtl);
  final xs = categoryPositions(
    layout.plot,
    input.categories.length,
    input.times,
  );
  final model = lineModel(
    kind: input.kind,
    plot: layout.plot,
    values: values,
    bands: bands,
    colors: input.colors,
    domain: domain,
    xs: xs,
  );
  final labels = [
    ..._valueLabels(model, yTexts, layout.plot, env),
    ..._xLabels(input, model, layout.plot, env),
    ...env.titles(layout, input.yAxis.title, input.xAxis.title),
  ];
  return _LineScene(layout, model, labels);
}

// The value labels on the start side of the plot.
List<AxisLabel> _valueLabels(
  LineModel model,
  List<String> texts,
  Rect plot,
  PlotEnv env,
) {
  final x = env.rtl ? plot.right + labelGap : plot.left - labelGap;
  final side = env.rtl ? LabelSide.after : LabelSide.before;
  return [
    for (var i = 0; i < model.domain.ticks.length; i++)
      AxisLabel(
        texts[i],
        Offset(x, model.yScale.map(model.domain.ticks[i])),
        side,
      ),
  ];
}

// The labels below the plot: calendar ticks on a time axis, else the categories, thinned out to fit.
List<AxisLabel> _xLabels(
  _LineInput input,
  LineModel model,
  Rect plot,
  PlotEnv env,
) {
  final below = plot.bottom + labelGap;
  final times = validTimes(input.times, input.categories.length);
  if (times != null) {
    final widest = env.widest(const ['00:00', 'Mar 30', '2030']);
    final max = math.max(2, (plot.width / (widest * 1.6)).floor());
    final ticks = timeTicks(
      times.first,
      times.last,
      max,
      offsetMinutes: input.offsetMinutes,
    );
    final scale = LinearScale(
      times.first.toDouble(),
      times.last.toDouble(),
      model.xs.first,
      model.xs.last,
    );
    return [
      for (final tick in ticks.ticks)
        AxisLabel(
          formatChartTime(tick, ticks.step, offsetMinutes: input.offsetMinutes),
          Offset(scale.map(tick.toDouble()), below),
          LabelSide.below,
        ),
    ];
  }
  final widest = env.widest(input.categories) * 1.6;
  final slot = model.xs.length < 2
      ? plot.width
      : plot.width / (model.xs.length - 1);
  final step = math.max(1, (widest / slot).ceil());
  return [
    for (var i = 0; i < input.categories.length; i += step)
      AxisLabel(
        input.categories[i],
        Offset(model.xs[i], below),
        LabelSide.below,
      ),
  ];
}

class _LinePlot extends StatefulWidget {
  const _LinePlot({required this.input, required this.style});

  final _LineInput input;
  final ResolvedChartStyle style;

  @override
  State<_LinePlot> createState() => _LinePlotState();
}

class _LinePlotState extends State<_LinePlot>
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
  void didUpdateWidget(_LinePlot old) {
    super.didUpdateWidget(old);
    if (!_sameData(old.input.series, widget.input.series) ||
        old.input.kind != widget.input.kind) {
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
        final scene = _lineScene(input, constraints.biggest, env);
        final xs = scene.model.xs;
        final hovered = _input.pointer == null
            ? null
            : nearestIndex(xs, _input.pointer!.dx);
        final walk = _input.walk;
        final active = input.markers == MarkerVisibility.never
            ? null
            : hovered ?? walk?.$1;
        final announce = walk == null
            ? null
            : _pointText(input, walk.$1, walk.$2);
        return PlotInputRegion(
          controller: _input,
          categories: input.categories.length,
          series: input.series.length,
          announce: announce,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LinePainter(
                    scene,
                    input,
                    env,
                    widget.style,
                    active,
                    walk?.$2,
                    drawIn,
                  ),
                ),
              ),
              if (active != null)
                Positioned.fill(
                  child: ChartTooltip(
                    title: input.categories[active],
                    rows: _tooltipRows(input, active),
                    x: xs[active],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(
    this.scene,
    this.input,
    this.env,
    this.style,
    this.active,
    this.focusedSeries,
    this.progress,
  ) : super(repaint: progress);

  final _LineScene scene;
  final _LineInput input;
  final PlotEnv env;
  final ResolvedChartStyle style;
  final int? active;
  final int? focusedSeries;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = scene.layout.plot;
    final model = scene.model;
    paintGrid(
      canvas,
      plot,
      [for (final t in model.domain.ticks) model.yScale.map(t)],
      vertical: false,
      style: style,
      grid: env.colors.outlineVariant,
      axis: env.colors.outline,
    );
    env.paintLabels(canvas, scene.labels);
    final at = active;
    if (at != null) {
      canvas.drawLine(
        Offset(model.xs[at], plot.top),
        Offset(model.xs[at], plot.bottom),
        Paint()
          ..color = env.colors.outline
          ..strokeWidth = 1,
      );
    }
    env.renderer.paintLineChart(
      canvas,
      size,
      LineChartSpec(
        plot: plot,
        series: model.specs,
        curve: input.curve,
        markers: input.markers == MarkerVisibility.always,
        activeCategory: at,
        focusedSeries: focusedSeries,
        progress: progress.value,
      ),
      style,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

// What the pointer or focus points at: the category's values, and for stacked areas their total.
List<TooltipRow> _tooltipRows(_LineInput input, int category) {
  final format = input.yAxis.format;
  final rows = <TooltipRow>[
    for (var i = 0; i < input.series.length; i++)
      if (category < input.series[i].values.length &&
          input.series[i].values[category] != null)
        TooltipRow(
          input.colors[i],
          '${input.series[i].name}: ${format(input.series[i].values[category]!)}',
        ),
  ];
  if (input.kind != LineKind.stackedArea) return rows;
  var total = 0.0;
  for (final s in input.series) {
    final v = category < s.values.length ? s.values[category] : null;
    total += math.max(0, v ?? 0);
  }
  return [...rows, TooltipRow(null, 'Total: ${format(total)}')];
}

String _pointText(_LineInput input, int category, int series) {
  final label = category < input.categories.length
      ? input.categories[category]
      : '';
  if (series >= input.series.length) return label;
  final item = input.series[series];
  final v = category < item.values.length ? item.values[category] : null;
  return '$label, ${item.name}, ${v == null ? 'no data' : input.yAxis.format(v)}';
}
