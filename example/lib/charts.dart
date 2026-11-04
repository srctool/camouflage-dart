import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M11 milestone screen: a dashboard of charts that follow the skin, the brand and dark mode. KPI cards with
// sparklines, revenue as a line, area or stacked area, regional bars (grouped or stacked, vertical or horizontal)
// and a traffic donut with its total in the hole, selectable by touch and keys. Every chart reads as a table too.

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
const _revenue = [
  ChartSeries(name: 'Subscriptions', values: [12, 15, 14, 19, 22, 21, 27, 31]),
  ChartSeries(name: 'Services', values: [6, 7, null, 9, 8, 12, 11, 14]),
  ChartSeries(name: 'Hardware', values: [4, 3, 5, 4, 6, 5, 7, 6]),
];
const _quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
const _regions = [
  ChartSeries(name: 'North', values: [42, 38, 51, 47]),
  ChartSeries(name: 'South', values: [28, 35, 30, 44]),
  ChartSeries(name: 'West', values: [19, 22, 31, 26]),
];
const _traffic = [
  PieSlice(label: 'Search', value: 4500),
  PieSlice(label: 'Social', value: 3000),
  PieSlice(label: 'Email', value: 1500),
  PieSlice(label: 'Direct', value: 900),
];
const _kpis = [
  ('Revenue', '31k', <double?>[12, 15, 14, 19, 22, 21, 27, 31]),
  ('Orders', '1,204', <double?>[40, 38, 45, 41, 52, 49, 60, 58]),
  ('Refunds', '18', <double?>[9, 7, 8, 6, 7, 5, 6, 4]),
];
const _donutTotal = '9,900';

/// A dashboard: KPI sparklines, a revenue line chart, regional bars and a traffic donut.
class ChartsDemo extends StatefulWidget {
  /// Creates the demo.
  const ChartsDemo({super.key});

  @override
  State<ChartsDemo> createState() => _ChartsDemoState();
}

class _ChartsDemoState extends State<ChartsDemo> {
  var _kind = LineKind.line;
  var _curve = LineCurve.smooth;
  var _mode = BarMode.grouped;
  var _orientation = BarOrientation.vertical;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.spacing.l,
      children: [
        Row(
          spacing: theme.spacing.m,
          children: [
            for (final (i, (label, value, trend)) in _kpis.indexed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.spacing.xs,
                  children: [
                    CamoText(label, style: theme.typography.labelMedium),
                    CamoText(value, style: theme.typography.titleLarge),
                    SizedBox(
                      height: 28,
                      width: double.infinity,
                      child: CamoSparkline(
                        values: trend,
                        kind: i == 1 ? SparklineKind.bars : SparklineKind.area,
                        tone: i == 2 ? Tone.error : Tone.defaultTone,
                        description: '$label, last 8 months',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        _Options<LineKind>(
          label: 'Revenue as',
          options: LineKind.values,
          chosen: _kind,
          onChoose: (v) => setState(() => _kind = v),
        ),
        _Options<LineCurve>(
          label: 'Curve',
          options: LineCurve.values,
          chosen: _curve,
          onChoose: (v) => setState(() => _curve = v),
        ),
        CamoLineChart(
          categories: _months,
          series: _revenue,
          title: 'Revenue by line, in thousands',
          kind: _kind,
          curve: _curve,
          xAxis: const ChartAxis(title: 'Month'),
          yAxis: const ChartAxis(title: 'USD k'),
        ),
        _Options<BarMode>(
          label: 'Regions',
          options: BarMode.values,
          chosen: _mode,
          onChoose: (v) => setState(() => _mode = v),
        ),
        _Options<BarOrientation>(
          label: 'Direction',
          options: BarOrientation.values,
          chosen: _orientation,
          onChoose: (v) => setState(() => _orientation = v),
        ),
        CamoBarChart(
          categories: _quarters,
          series: _regions,
          title: 'Orders by region',
          orientation: _orientation,
          mode: _mode,
          valueLabels: true,
        ),
        CamoPieChart(
          slices: _traffic,
          title: 'Traffic by source',
          donut: true,
          selected: _selected,
          onSelected: (i) => setState(() => _selected = i),
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CamoText(_donutTotal, style: theme.typography.titleMedium),
              CamoText('visits', style: theme.typography.labelSmall),
            ],
          ),
        ),
        CamoText(
          _selected == null
              ? 'Select a slice by tap, click or Enter'
              : '${_traffic[_selected!].label} selected',
          style: theme.typography.bodySmall,
        ),
      ],
    );
  }
}

// A labelled row of options; the chosen one is solid.
class _Options<T extends Enum> extends StatelessWidget {
  const _Options({
    required this.label,
    required this.options,
    required this.chosen,
    required this.onChoose,
  });

  final String label;
  final List<T> options;
  final T chosen;
  final ValueChanged<T> onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return Wrap(
      spacing: theme.spacing.s,
      runSpacing: theme.spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CamoText(label, style: theme.typography.labelMedium),
        for (final option in options)
          CamoButton(
            text: option.name,
            onPressed: () => onChoose(option),
            appearance: option == chosen
                ? Appearance.solid
                : Appearance.outline,
          ),
      ],
    );
  }
}
