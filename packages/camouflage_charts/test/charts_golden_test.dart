import 'package:alchemist/alchemist.dart';
import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';

// Screenshot goldens of the charts in both skins, light and dark. Update with
// `flutter test --update-goldens --tags golden`.
const _trend = <double?>[3, 5, 4, 8, 6, 9, 7, 12];
const _gappy = <double?>[3, 5, null, 8, 6, null, null, 12];
const _box = Size(120, 36);

Widget _spark(
  List<double?> values, {
  SparklineKind kind = SparklineKind.line,
  SparklineHighlight highlight = SparklineHighlight.last,
  Tone tone = Tone.defaultTone,
}) => SizedBox.fromSize(
  size: _box,
  child: CamoSparkline(
    values: values,
    kind: kind,
    highlight: highlight,
    tone: tone,
  ),
);

class _ChartsGallery extends StatelessWidget {
  const _ChartsGallery();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 480,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 16,
            children: [
              _spark(_trend),
              _spark(_trend, kind: SparklineKind.area),
              _spark(_trend, kind: SparklineKind.bars),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              _spark(_gappy, highlight: SparklineHighlight.extremes),
              _spark(const [5]),
              _spark(
                const [4, 4, 4],
                kind: SparklineKind.area,
                tone: Tone.success,
              ),
            ],
          ),
          CamoChartFrame(
            title: 'Revenue',
            summary: '2 series, 3 categories',
            legend: const [
              LegendItem(label: 'Sales', color: Color(0xFF3366CC)),
              LegendItem(
                label: 'Costs',
                color: Color(0xFFCC6633),
                visible: false,
              ),
            ],
            onLegendToggle: (_) {},
            plotHeight: 150,
            showTable: true,
            onShowTableChanged: (_) {},
            table: const CamoChartDataTable(
              categories: ['Jan', 'Feb', 'Mar'],
              series: [
                ChartSeries(name: 'Sales', values: [1, 2.5, 4]),
                ChartSeries(name: 'Costs', values: [0.5, null, 3]),
              ],
              caption: 'Revenue data',
            ),
            child: const CamoText('plot'),
          ),
          const CamoChartFrame(
            title: 'Loading',
            summary: '',
            loading: true,
            plotHeight: 40,
            child: SizedBox(),
          ),
          const CamoChartFrame(
            title: 'Empty',
            summary: '',
            isEmpty: true,
            child: SizedBox(),
          ),
        ],
      ),
    ),
  );
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const _sales = ChartSeries(name: 'Sales', values: [12, 18, 15, 24, 21, 30]);
const _costs = ChartSeries(name: 'Costs', values: [8, 10, null, 14, 13, 16]);

const _traffic = [
  PieSlice(label: 'Search', value: 45),
  PieSlice(label: 'Social', value: 30),
  PieSlice(label: 'Mail', value: 20),
  PieSlice(label: 'Other', value: 5),
];

class _CartesianGallery extends StatelessWidget {
  const _CartesianGallery();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 480,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          CamoLineChart(
            categories: _months,
            series: [_sales, _costs],
            title: 'Line',
            markers: MarkerVisibility.always,
            xAxis: ChartAxis(title: 'Month'),
            yAxis: ChartAxis(title: 'Units'),
            plotHeight: 130,
          ),
          CamoLineChart(
            categories: _months,
            series: [_sales, _costs],
            title: 'Stacked area, smooth',
            kind: LineKind.stackedArea,
            curve: LineCurve.smooth,
            plotHeight: 130,
          ),
          CamoBarChart(
            categories: _months,
            series: [_sales, _costs],
            title: 'Grouped',
            valueLabels: true,
            plotHeight: 130,
          ),
          CamoBarChart(
            categories: ['Jan', 'Feb', 'Mar'],
            series: [_sales, _costs],
            title: 'Stacked, horizontal',
            orientation: BarOrientation.horizontal,
            mode: BarMode.stacked,
            plotHeight: 130,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              SizedBox(
                width: 222,
                child: CamoPieChart(
                  slices: _traffic,
                  title: 'Pie',
                  selected: 0,
                  plotHeight: 150,
                ),
              ),
              SizedBox(
                width: 222,
                child: CamoPieChart(
                  slices: _traffic,
                  title: 'Donut',
                  donut: true,
                  center: CamoText('100'),
                  plotHeight: 150,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

CamoTheme _still(CamoTheme theme) => theme.copyWith(
  motion: const CamoMotion(
    durationShort: Duration.zero,
    durationMedium: Duration.zero,
    durationLong: Duration.zero,
  ),
);

void main() {
  final scenes = {
    'minimal light': (minimalSkin, minimalLight),
    'minimal dark': (minimalSkin, minimalDark),
    'fluent light': (fluentSkinDefault, fluentTheme()),
    'fluent dark': (
      fluentSkinDefault,
      fluentTheme(brightness: Brightness.dark),
    ),
  };
  goldenTest(
    'charts',
    fileName: 'charts',
    constraints: const BoxConstraints(maxWidth: 1000),
    // The loading skeleton animates forever, so the scene can't settle: one frame.
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final MapEntry(:key, :value) in scenes.entries)
          GoldenTestScenario(
            name: key,
            constraints: const BoxConstraints(maxWidth: 1000),
            child: CamouflagePreview(
              skin: value.$1,
              theme: _still(value.$2),
              child: const _ChartsGallery(),
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'cartesian charts',
    fileName: 'cartesian',
    constraints: const BoxConstraints(maxWidth: 1000),
    // The legend chips don't animate, but the frame's skeleton-free scene still settles in one frame.
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final MapEntry(:key, :value) in scenes.entries)
          GoldenTestScenario(
            name: key,
            constraints: const BoxConstraints(maxWidth: 1000),
            child: CamouflagePreview(
              skin: value.$1,
              theme: _still(value.$2),
              child: const _CartesianGallery(),
            ),
          ),
      ],
    ),
  );
}
