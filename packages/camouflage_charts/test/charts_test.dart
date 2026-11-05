import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_material/camouflage_skin_material.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {CamoSkin? skin, CamoTheme? theme}) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: Directionality(
    textDirection: TextDirection.ltr,
    child: CamouflageProvider(
      skin: skin ?? minimalSkin,
      theme: theme ?? minimalLight,
      child: Align(alignment: AlignmentDirectional.topStart, child: child),
    ),
  ),
);

class _Capture extends StatelessWidget {
  const _Capture(this.into, {this.overrides});

  final void Function(ResolvedChartStyle style) into;
  final ChartStyle? overrides;

  @override
  Widget build(BuildContext context) {
    into(CamoCharts.styleOf(context, overrides: overrides));
    return const SizedBox();
  }
}

void main() {
  testWidgets('a sparkline is one image with its summary', (tester) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 80,
          height: 20,
          child: CamoSparkline(values: [3, 5, 9], description: 'Signups'),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Signups: from 3 to 9, up 200%'),
      findsOneWidget,
    );
  });

  testWidgets('a sparkline with no data still draws', (tester) async {
    await tester.pumpWidget(_app(const CamoSparkline(values: [])));
    expect(find.bySemanticsLabel('Trend no data'), findsOneWidget);
  });

  testWidgets('a sparkline sizes to its parent, or to 100 x 28', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const CamoSparkline(values: [1, 2])));
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(100, 28));
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 60,
          height: 12,
          child: CamoSparkline(values: [1, 2]),
        ),
      ),
    );
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(60, 12));
  });

  testWidgets("the skin's preset shapes the style", (tester) async {
    late ResolvedChartStyle minimal;
    late ResolvedChartStyle fluent;
    late ResolvedChartStyle material;
    await tester.pumpWidget(
      _app(_Capture((s) => minimal = s), skin: minimalSkin),
    );
    await tester.pumpWidget(
      _app(
        _Capture((s) => material = s),
        skin: materialSkin,
        theme: materialBaselineLight,
      ),
    );
    await tester.pumpWidget(
      _app(
        _Capture((s) => fluent = s),
        skin: fluentSkinDefault,
        theme: fluentTheme(),
      ),
    );
    expect(minimal.lineWidth, 1.5);
    expect(fluent.lineWidth, 2);
    expect(fluent.gridDashed, isTrue);
    expect(minimal.gridDashed, isFalse);
    expect(material.lineWidth, 3);
    expect(material.barRadius, 8);
    expect(material.donutThickness, 0.3);
  });

  testWidgets('tokens, then parameters, override presets', (tester) async {
    late ResolvedChartStyle byTokens;
    late ResolvedChartStyle byParameter;
    final branded = minimalLight.copyWith(
      tokenSets: [const ChartTokens(ChartStyle(lineWidth: 4, barGap: 9))],
    );
    await tester.pumpWidget(
      _app(_Capture((s) => byTokens = s), theme: branded),
    );
    await tester.pumpWidget(
      _app(
        _Capture(
          (s) => byParameter = s,
          overrides: const ChartStyle(lineWidth: 7),
        ),
        theme: branded,
      ),
    );
    expect(byTokens.lineWidth, 4);
    expect(byTokens.barGap, 9);
    expect(byParameter.lineWidth, 7);
    expect(byParameter.barGap, 9);
  });

  testWidgets('a registered preset styles a skin by name', (tester) async {
    CamoCharts.registerPreset(
      'minimal-test-brand',
      const ChartStyle(barRadius: 11),
    );
    late ResolvedChartStyle style;
    await tester.pumpWidget(
      _app(
        _Capture((s) => style = s),
        skin: minimalSkin.copyWith(name: 'minimal-test-brand'),
      ),
    );
    expect(style.barRadius, 11);
  });

  testWidgets('the palette cycles and leaves out colors lost on the surface', (
    tester,
  ) async {
    late ResolvedChartStyle style;
    await tester.pumpWidget(_app(_Capture((s) => style = s)));
    expect(style.palette.length >= 3, isTrue);
    expect(style.seriesColor(0), isNot(style.seriesColor(1)));
    expect(style.seriesColor(0), style.seriesColor(style.palette.length));
  });

  testWidgets('the legend toggles series', (tester) async {
    var items = [
      const LegendItem(label: 'Sales', color: Color(0xFFFF0000)),
      const LegendItem(label: 'Costs', color: Color(0xFF0000FF)),
    ];
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, set) => CamoChartFrame(
            title: 'Revenue',
            summary: '2 series',
            legend: items,
            onLegendToggle: (i) => set(
              () => items = [
                for (var j = 0; j < items.length; j++)
                  j == i ? items[j].withVisible(!items[j].visible) : items[j],
              ],
            ),
            child: const CamoText('plot'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Costs'));
    await tester.pump();
    expect(items[1].visible, isFalse);
    expect(items[0].visible, isTrue);
  });

  testWidgets('the plot is an image named by title and summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const CamoChartFrame(
          title: 'Revenue',
          summary: 'Line chart, 2 series',
          child: SizedBox(),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Revenue. Line chart, 2 series'),
      findsOneWidget,
    );
  });

  testWidgets('the table switch shows the data as rows', (tester) async {
    var shown = false;
    const series = [
      ChartSeries(name: 'Sales', values: [1, null]),
    ];
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 400,
          height: 400,
          child: StatefulBuilder(
            builder: (context, set) => CamoChartFrame(
              title: 'Revenue',
              summary: 'summary',
              table: const CamoChartDataTable(
                categories: ['Jan', 'Feb'],
                series: series,
                caption: 'Revenue data',
              ),
              showTable: shown,
              onShowTableChanged: (v) => set(() => shown = v),
              child: const CamoText('plot'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Jan'), findsNothing);
    await tester.tap(find.text('View as table'));
    await tester.pump();
    expect(find.text('Jan'), findsOneWidget);
    expect(find.text('Feb'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('loading and empty replace the plot', (tester) async {
    await tester.pumpWidget(
      _app(
        const CamoChartFrame(
          title: 'Revenue',
          summary: 's',
          loading: true,
          isEmpty: true,
          child: CamoText('plot'),
        ),
      ),
    );
    expect(find.text('plot'), findsNothing);
    expect(find.text('No data'), findsNothing);
    await tester.pumpWidget(
      _app(
        const CamoChartFrame(
          title: 'Revenue',
          summary: 's',
          isEmpty: true,
          child: CamoText('plot'),
        ),
      ),
    );
    expect(find.text('No data'), findsOneWidget);
    expect(find.text('plot'), findsNothing);
  });

  testWidgets('a custom renderer takes over the drawing', (tester) async {
    final renderer = _Counting();
    await tester.pumpWidget(
      _app(
        CamoChartsProvider(
          renderer: renderer,
          child: const SizedBox(
            width: 50,
            height: 20,
            child: CamoSparkline(values: [1, 2]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(renderer.painted > 0, isTrue);
    expect(renderer.lastProgress, 1);
  });

  testWidgets('no motion draws at once', (tester) async {
    final renderer = _Counting();
    await tester.pumpWidget(
      _app(
        CamoChartsProvider(
          renderer: renderer,
          child: const SizedBox(
            width: 50,
            height: 20,
            child: CamoSparkline(values: [1, 2]),
          ),
        ),
        theme: minimalLight.copyWith(
          motion: const CamoMotion(
            durationShort: Duration.zero,
            durationMedium: Duration.zero,
            durationLong: Duration.zero,
          ),
        ),
      ),
    );
    expect(renderer.lastProgress, 1);
  });
}

class _Counting extends ChartRenderer {
  int painted = 0;
  double lastProgress = -1;

  @override
  void paintSparkline(
    Canvas canvas,
    Size size,
    SparklineSpec spec,
    ResolvedChartStyle style,
  ) {
    painted++;
    lastProgress = spec.progress;
  }
}
