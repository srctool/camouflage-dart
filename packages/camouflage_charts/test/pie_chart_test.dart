import 'dart:ui';

import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_charts/src/cartesian_plot.dart' show PlotInputRegion;
import 'package:camouflage_charts/src/pie_geometry.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ChartRenderer? renderer}) {
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
      textDirection: TextDirection.ltr,
      child: CamouflageProvider(
        skin: minimalSkin,
        theme: theme,
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: 300,
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
  PieChartSpec? pie;

  @override
  void paintSparkline(
    Canvas canvas,
    Size size,
    SparklineSpec spec,
    ResolvedChartStyle style,
  ) {}

  @override
  void paintPieChart(
    Canvas canvas,
    Size size,
    PieChartSpec spec,
    ResolvedChartStyle style,
  ) => pie = spec;
}

const _slices = [
  PieSlice(label: 'A', value: 3),
  PieSlice(label: 'B', value: 1),
];

void main() {
  const center = Offset(100, 100);
  final angles = sliceAngles([1, 1, 2], -90);

  test('angles share a full turn by value', () {
    expect(angles, [(-90.0, 90.0), (0.0, 90.0), (90.0, 180.0)]);
  });

  test('one slice gets the full turn and negatives count as zero', () {
    expect(sliceAngles([5], -90), [(-90.0, 360.0)]);
    expect(sliceAngles([3, -1], -90), [(-90.0, 360.0), (270.0, 0.0)]);
    expect(sliceAngles([0, 0], 0), [(0.0, 0.0), (0.0, 0.0)]);
    expect(sliceAngles(const [], 0), isEmpty);
  });

  test('a point finds its slice by angle and radius', () {
    expect(sliceAt(const Offset(100, 10), center, 100, 0, angles), 0);
    expect(sliceAt(const Offset(190, 100), center, 100, 0, angles), 1);
    expect(sliceAt(const Offset(100, 190), center, 100, 0, angles), 2);
    expect(sliceAt(const Offset(10, 100), center, 100, 0, angles), 2);
    expect(sliceAt(const Offset(300, 100), center, 100, 0, angles), isNull);
  });

  test('a donut hole has no slice, and a zero slice is never hit', () {
    expect(sliceAt(center, center, 100, 50, angles), isNull);
    expect(sliceAt(const Offset(170, 100), center, 100, 50, angles), 1);
    final withZero = sliceAngles([1, 0, 1], -90);
    expect(sliceAt(const Offset(10, 100), center, 100, 0, withZero), 2);
  });

  test('polar points clockwise from 3 o clock', () {
    final down = polar(Offset.zero, 10, 90);
    expect(down.dx, closeTo(0, 0.001));
    expect(down.dy, closeTo(10, 0.001));
    expect(polar(Offset.zero, 10, 0), const Offset(10, 0));
  });

  test('shares read as percents and slivers', () {
    expect(shareText(0.45), '45%');
    expect(shareText(0.004), '<1%');
    expect(shareText(0), '0%');
    expect(shareText(1), '100%');
  });

  test('the summary names the largest slice', () {
    const slices = [
      PieSlice(label: 'Search', value: 4500),
      PieSlice(label: 'Social', value: 3000),
      PieSlice(label: 'Mail', value: 1500),
    ];
    expect(
      pieSummary('Pie chart', slices),
      'Pie chart, 3 slices, largest: Search 50%',
    );
    expect(
      pieSummary('Pie chart', const [PieSlice(label: 'A', value: 2)]),
      'Pie chart, 1 slice, largest: A 100%',
    );
    expect(pieSummary('Pie chart', const []), 'Pie chart, 0 slices');
  });

  testWidgets('a pie is one image and the legend lists value and share', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const CamoPieChart(slices: _slices, title: 'Traffic')),
    );
    expect(
      find.bySemanticsLabel('Traffic. Pie chart, 2 slices, largest: A 75%'),
      findsOneWidget,
    );
    expect(find.text('A: 3, 75%'), findsOneWidget);
    expect(find.text('B: 1, 25%'), findsOneWidget);
  });

  testWidgets('a donut shows its center content', (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoPieChart(
          slices: _slices,
          title: 'Traffic',
          donut: true,
          center: CamoText('Total 4'),
        ),
      ),
    );
    expect(find.text('Total 4'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Traffic. Donut chart, 2 slices, largest: A 75%'),
      findsOneWidget,
    );
  });

  testWidgets('hovering shows the slice', (tester) async {
    await tester.pumpWidget(
      _app(const CamoPieChart(slices: _slices, title: 'Traffic')),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(PlotInputRegion)));
    await tester.pump();
    expect(find.text('3 (75%)'), findsOneWidget);
  });

  testWidgets('tapping selects, and the selection reaches the renderer', (
    tester,
  ) async {
    final recorder = _Recorder();
    final picks = <int?>[];
    await tester.pumpWidget(
      _app(
        CamoPieChart(
          slices: _slices,
          title: 'Traffic',
          selected: 1,
          onSelected: picks.add,
        ),
        renderer: recorder,
      ),
    );
    expect(recorder.pie!.selected, 1);
    expect(recorder.pie!.slices, hasLength(2));
    await tester.tap(find.byType(PlotInputRegion));
    await tester.pump();
    expect(picks, [0]);
  });

  testWidgets('the legend hides a slice', (tester) async {
    final recorder = _Recorder();
    await tester.pumpWidget(
      _app(
        const CamoPieChart(slices: _slices, title: 'Traffic'),
        renderer: recorder,
      ),
    );
    await tester.tap(find.text('B: 1, 25%'));
    await tester.pump();
    expect(recorder.pie!.slices, hasLength(1));
    expect(recorder.pie!.slices.single.sweep, 360);
  });

  testWidgets('the keyboard walks slices and Enter selects', (tester) async {
    final semantics = tester.ensureSemantics();
    final picks = <int?>[];
    await tester.pumpWidget(
      _app(
        CamoPieChart(slices: _slices, title: 'Traffic', onSelected: picks.add),
      ),
    );
    await tester.tap(find.byType(PlotInputRegion));
    await tester.pump();
    expect(find.bySemanticsLabel('A, 75%, 3'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.bySemanticsLabel('B, 25%, 1'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(picks.last, 1);
    semantics.dispose();
  });

  testWidgets('all zero is empty', (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoPieChart(
          slices: [PieSlice(label: 'A', value: 0)],
          title: 'Traffic',
        ),
      ),
    );
    expect(find.text('No data'), findsOneWidget);
  });
}
