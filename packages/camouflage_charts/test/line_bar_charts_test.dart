import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_charts/src/cartesian_plot.dart' show PlotInputRegion;
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Widget child, {
  ChartRenderer? renderer,
  TextDirection direction = TextDirection.ltr,
}) {
  final theme = minimalLight.copyWith(
    motion: const CamoMotion(
      durationShort: Duration.zero,
      durationMedium: Duration.zero,
      durationLong: Duration.zero,
    ),
  );
  return WidgetsApp(
    color: const Color(0xFFFFFFFF),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    home: Directionality(
      textDirection: direction,
      child: CamouflageProvider(
        skin: minimalSkin,
        theme: theme,
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: 400,
            child: renderer == null
                ? child
                : CamoChartsProvider(renderer: renderer, child: child),
          ),
        ),
      ),
    ),
  );
}

class _Recorder extends ChartRenderer {
  LineChartSpec? lines;
  BarChartSpec? bars;

  @override
  void paintSparkline(
    Canvas canvas,
    Size size,
    SparklineSpec spec,
    ResolvedChartStyle style,
  ) {}

  @override
  void paintLineChart(
    Canvas canvas,
    Size size,
    LineChartSpec spec,
    ResolvedChartStyle style,
  ) => lines = spec;

  @override
  void paintBarChart(
    Canvas canvas,
    Size size,
    BarChartSpec spec,
    ResolvedChartStyle style,
  ) => bars = spec;
}

const _months = ['Jan', 'Feb', 'Mar'];
const _sales = ChartSeries(name: 'Sales', values: [1, 2.5, 4]);
const _costs = ChartSeries(name: 'Costs', values: [0.5, null, 3]);
const _summary =
    'Revenue. Line chart, 2 series, 3 categories. '
    'Sales: from 1 to 4, up 300%; Costs: from 0.5 to 3, up 500%';

Future<void> _hover(WidgetTester tester, Finder finder) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(finder));
  await tester.pump();
}

void main() {
  testWidgets('a line chart is one image with each series trend', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const CamoLineChart(
          categories: _months,
          series: [_sales, _costs],
          title: 'Revenue',
        ),
      ),
    );
    expect(find.bySemanticsLabel(_summary), findsOneWidget);
  });

  testWidgets('the legend hides a series from the chart', (tester) async {
    final recorder = _Recorder();
    await tester.pumpWidget(
      _app(
        const CamoLineChart(
          categories: _months,
          series: [_sales, _costs],
          title: 'Revenue',
        ),
        renderer: recorder,
      ),
    );
    expect(recorder.lines!.series, hasLength(2));
    await tester.tap(find.text('Costs'));
    await tester.pump();
    expect(recorder.lines!.series, hasLength(1));
  });

  testWidgets("hovering shows the nearest category's values", (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoLineChart(
          categories: _months,
          series: [_sales, _costs],
          title: 'Revenue',
        ),
      ),
    );
    expect(find.text('Sales: 2.5'), findsNothing);
    await _hover(tester, find.byType(PlotInputRegion));
    expect(find.text('Sales: 2.5'), findsOneWidget);
    expect(find.text('Feb'), findsOneWidget);
  });

  testWidgets('a stacked area tooltip adds the total', (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoLineChart(
          categories: _months,
          series: [_sales, _costs],
          title: 'Revenue',
          kind: LineKind.stackedArea,
        ),
      ),
    );
    await _hover(tester, find.byType(PlotInputRegion));
    expect(find.text('Total: 2.5'), findsOneWidget);
  });

  testWidgets('the keyboard walks points and announces them', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const CamoLineChart(
          categories: _months,
          series: [_sales, _costs],
          title: 'Revenue',
        ),
      ),
    );
    await tester.tap(find.byType(PlotInputRegion));
    await tester.pump();
    expect(find.bySemanticsLabel('Jan, Sales, 1'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.bySemanticsLabel('Feb, Sales, 2.5'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.bySemanticsLabel('Feb, Costs, no data'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(find.bySemanticsLabel('Mar, Costs, 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the table shows the same data', (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoLineChart(
          categories: _months,
          series: [_sales, _costs],
          title: 'Revenue',
        ),
      ),
    );
    await tester.tap(find.text('View as table'));
    await tester.pump();
    expect(find.text('Mar'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('no data says so', (tester) async {
    await tester.pumpWidget(
      _app(const CamoLineChart(categories: [], series: [], title: 'Revenue')),
    );
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('a bar chart is one image and the keyboard walks the bars', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const CamoBarChart(
          categories: ['Q1', 'Q2'],
          series: [
            ChartSeries(name: 'North', values: [42, 10]),
            ChartSeries(name: 'South', values: [7, 30]),
          ],
          title: 'Regions',
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(
        'Regions. Bar chart, 2 series, 2 categories. '
        'North: from 42 to 10, down 76%; South: from 7 to 30, up 329%',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byType(PlotInputRegion));
    await tester.pump();
    expect(find.bySemanticsLabel('Q1, North, 42'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.bySemanticsLabel('Q1, South, 7'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a stacked bar tooltip adds the total', (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoBarChart(
          categories: ['Q1'],
          series: [
            ChartSeries(name: 'A', values: [4]),
            ChartSeries(name: 'B', values: [3]),
          ],
          title: 'Stack',
          mode: BarMode.stacked,
        ),
      ),
    );
    await _hover(tester, find.byType(PlotInputRegion));
    expect(find.text('Total: 7'), findsOneWidget);
  });

  testWidgets('bars mirror in a right-to-left layout', (tester) async {
    const chart = CamoBarChart(
      categories: ['x', 'y'],
      series: [
        ChartSeries(name: 'A', values: [1, 2]),
      ],
      title: 'Bars',
    );
    final ltr = _Recorder();
    final rtl = _Recorder();
    await tester.pumpWidget(_app(chart, renderer: ltr));
    await tester.pumpWidget(
      _app(chart, renderer: rtl, direction: TextDirection.rtl),
    );
    expect(ltr.bars!.bars.first.rect.left, lessThan(ltr.bars!.plot.center.dx));
    expect(
      rtl.bars!.bars.first.rect.left,
      greaterThan(rtl.bars!.plot.center.dx),
    );
  });
}
