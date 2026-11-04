import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'camo_chart_frame.dart';
import 'cartesian_plot.dart';
import 'chart_data.dart';
import 'chart_renderer.dart';
import 'chart_style.dart';
import 'pie_geometry.dart';

/// Parts of a whole, as a pie or (with [donut]) a ring with [center] content in the hole.
///
/// Each slice shows its share when it is wide enough ([ResolvedChartStyle.labelThreshold]); the legend lists every
/// slice with its value and share and hides or shows slices. The app owns the selection ([selected],
/// [onSelected]): tapping a slice, or Enter or Space on the focused one, calls [onSelected] with its index (`null`
/// when it was already selected), and the selected slice moves out. The plot is one image node; focusing it walks
/// the slices clockwise (Left, Right, Up and Down) and announces "Search, 45%, 4,500". Negative values count as
/// zero; with every value zero the empty state shows. Angles keep their clockwise direction in right-to-left
/// layouts.
class CamoPieChart extends StatefulWidget {
  /// Creates a pie chart.
  const CamoPieChart({
    super.key,
    required this.slices,
    required this.title,
    this.donut = false,
    this.center,
    this.selected,
    this.onSelected,
    this.startAngle = pieTop,
    this.valueFormat = formatChartNumber,
    this.loading = false,
    this.empty,
    this.showTable = false,
    this.plotHeight = 220,
    this.style,
  });

  /// The slices.
  final List<PieSlice> slices;

  /// The chart's title.
  final String title;

  /// Whether the pie has a hole.
  final bool donut;

  /// What shows in the donut's hole.
  final Widget? center;

  /// The selected slice's index, which moves out.
  final int? selected;

  /// Called with the tapped slice's index, or `null` to clear it.
  final ValueChanged<int?>? onSelected;

  /// Where the first slice starts, in degrees clockwise from 3 o'clock; 12 o'clock by default.
  final double startAngle;

  /// How a value reads.
  final String Function(double value) valueFormat;

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
  State<CamoPieChart> createState() => _CamoPieChartState();
}

class _CamoPieChartState extends State<CamoPieChart> {
  Set<int> _hidden = {};
  late bool _table = widget.showTable;

  @override
  void didUpdateWidget(CamoPieChart old) {
    super.didUpdateWidget(old);
    if (old.slices.length != widget.slices.length) _hidden = {};
    if (old.showTable != widget.showTable) _table = widget.showTable;
  }

  @override
  Widget build(BuildContext context) {
    final style = CamoCharts.styleOf(context, overrides: widget.style);
    final slices = widget.slices;
    final colors = [
      for (var i = 0; i < slices.length; i++)
        slices[i].color ?? style.seriesColor(i),
    ];
    final shown = [
      for (var i = 0; i < slices.length; i++)
        if (!_hidden.contains(i)) i,
    ];
    final input = _PieInput(
      slices: slices,
      shown: shown,
      colors: colors,
      donut: widget.donut,
      startAngle: widget.startAngle,
      selected: widget.selected,
      format: widget.valueFormat,
    );
    return CamoChartFrame(
      title: widget.title,
      summary: pieSummary(widget.donut ? 'Donut chart' : 'Pie chart', slices),
      legend: [
        for (var i = 0; i < slices.length; i++)
          LegendItem(
            label:
                '${slices[i].label}: ${widget.valueFormat(slices[i].value)}'
                '${_hidden.contains(i) ? '' : ', ${shareText(input.share(i))}'}',
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
      isEmpty: slices.isEmpty || slices.every((s) => s.value <= 0),
      empty: widget.empty,
      plotHeight: widget.plotHeight,
      table: CamoChartDataTable(
        categories: [for (final s in slices) s.label],
        series: [
          ChartSeries(
            name: 'Value',
            values: [for (final s in slices) math.max(0, s.value)],
          ),
        ],
        caption: '${widget.title} data',
        format: widget.valueFormat,
      ),
      showTable: _table,
      onShowTableChanged: (value) => setState(() => _table = value),
      child: SizedBox(
        height: widget.plotHeight,
        width: double.infinity,
        child: _PiePlot(
          input: input,
          style: style,
          center: widget.center,
          onSelected: widget.onSelected,
        ),
      ),
    );
  }
}

class _PieInput {
  _PieInput({
    required this.slices,
    required this.shown,
    required this.colors,
    required this.donut,
    required this.startAngle,
    required this.selected,
    required this.format,
  }) : total = shown.fold(0.0, (sum, i) => sum + math.max(0, slices[i].value));

  final List<PieSlice> slices;
  final List<int> shown;
  final List<Color> colors;
  final bool donut;
  final double startAngle;
  final int? selected;
  final String Function(double value) format;
  final double total;

  double share(int index) =>
      total <= 0 ? 0 : math.max(0, slices[index].value) / total;
}

// Everything the pie draws for one size: the circle, the slices that are shown and their angles.
class _PieScene {
  const _PieScene(this.center, this.outer, this.inner, this.angles);

  final Offset center;
  final double outer;
  final double inner;
  final List<(double, double)> angles;
}

_PieScene _pieScene(_PieInput input, Size size, ResolvedChartStyle style) {
  final room = style.selectedOffset * 2;
  final outer = math.max(
    0.0,
    math.min(size.width, size.height) / 2 - plotPadding - room,
  );
  final inner = input.donut ? outer * (1 - style.donutThickness) : 0.0;
  final angles = sliceAngles([
    for (final i in input.shown) input.slices[i].value,
  ], input.startAngle);
  return _PieScene(size.center(Offset.zero), outer, inner, angles);
}

class _PiePlot extends StatefulWidget {
  const _PiePlot({
    required this.input,
    required this.style,
    required this.center,
    required this.onSelected,
  });

  final _PieInput input;
  final ResolvedChartStyle style;
  final Widget? center;
  final ValueChanged<int?>? onSelected;

  @override
  State<_PiePlot> createState() => _PiePlotState();
}

class _PiePlotState extends State<_PiePlot>
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
  void didUpdateWidget(_PiePlot old) {
    super.didUpdateWidget(old);
    final a = [for (final i in old.input.shown) old.input.slices[i].value];
    final b = [
      for (final i in widget.input.shown) widget.input.slices[i].value,
    ];
    if (a.length != b.length ||
        [for (var i = 0; i < a.length; i++) a[i] == b[i]].contains(false)) {
      restartDrawIn();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _toggle(int shownIndex) {
    final input = widget.input;
    final index = input.shown[shownIndex];
    widget.onSelected?.call(index == input.selected ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
    final style = widget.style;
    final env = plotEnv(context, CamoChartsProvider.of(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        final scene = _pieScene(input, constraints.biggest, style);
        final pointer = _input.pointer;
        final hover = pointer == null
            ? null
            : sliceAt(
                pointer,
                scene.center,
                scene.outer,
                scene.inner,
                scene.angles,
              );
        final walk = _input.walk?.$1;
        final walked = walk != null && walk < input.shown.length ? walk : null;
        final active = hover ?? walked;
        final announce = walked == null
            ? null
            : _pieText(input, input.shown[walked]);
        return PlotInputRegion(
          controller: _input,
          categories: input.shown.length,
          series: 1,
          announce: announce,
          linear: true,
          onActivate: walked == null ? null : () => _toggle(walked),
          onTap: (point) {
            final hit = sliceAt(
              point,
              scene.center,
              scene.outer,
              scene.inner,
              scene.angles,
            );
            if (hit != null) _toggle(hit);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PiePainter(
                    scene,
                    input,
                    env,
                    style,
                    active,
                    drawIn,
                  ),
                ),
              ),
              if (widget.center != null && input.donut && scene.inner > 0)
                SizedBox.square(
                  dimension: scene.inner * 2,
                  child: Semantics(
                    container: true,
                    child: Center(child: widget.center),
                  ),
                ),
              if (active != null) _tooltip(input, scene, active),
            ],
          ),
        );
      },
    );
  }

  Widget _tooltip(_PieInput input, _PieScene scene, int active) {
    final index = input.shown[active];
    final (start, sweep) = scene.angles[active];
    final anchor = polar(
      scene.center,
      (scene.outer + scene.inner) / 2,
      start + sweep / 2,
    );
    return Positioned.fill(
      child: ChartTooltip(
        title: input.slices[index].label,
        rows: [
          TooltipRow(
            input.colors[index],
            '${input.format(input.slices[index].value)} (${shareText(input.share(index))})',
          ),
        ],
        x: anchor.dx,
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(
    this.scene,
    this.input,
    this.env,
    this.style,
    this.active,
    this.progress,
  ) : super(repaint: progress);

  final _PieScene scene;
  final _PieInput input;
  final PlotEnv env;
  final ResolvedChartStyle style;
  final int? active;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final marks = [
      for (var i = 0; i < scene.angles.length; i++)
        PieSliceMark(
          scene.angles[i].$1,
          scene.angles[i].$2,
          input.colors[input.shown[i]],
        ),
    ];
    final selected = input.selected == null
        ? null
        : input.shown.indexOf(input.selected!);
    final shownSelected = selected != null && selected >= 0 ? selected : null;
    env.renderer.paintPieChart(
      canvas,
      size,
      PieChartSpec(
        center: scene.center,
        outerRadius: scene.outer,
        innerRadius: scene.inner,
        slices: marks,
        selected: shownSelected,
        active: active,
        progress: progress.value,
      ),
      style,
    );
    if (progress.value < 1) return;
    final radius = input.donut
        ? (scene.outer + scene.inner) / 2
        : scene.outer * 0.62;
    for (var i = 0; i < scene.angles.length; i++) {
      final (start, sweep) = scene.angles[i];
      final share = input.share(input.shown[i]);
      if (sweep <= 0 || share < style.labelThreshold) continue;
      final offset = i == shownSelected ? style.selectedOffset : 0.0;
      final middle = start + sweep / 2;
      final at = polar(polar(scene.center, offset, middle), radius, middle);
      final color = marks[i].color.computeLuminance() > 0.5
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF);
      env.paintLabels(canvas, [
        AxisLabel(shareText(share), at, LabelSide.center),
      ], color: color);
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => true;
}

String _pieText(_PieInput input, int index) {
  final slice = input.slices[index];
  final selected = index == input.selected ? ', selected' : '';
  return '${slice.label}, ${shareText(input.share(index))}, ${input.format(slice.value)}$selected';
}
