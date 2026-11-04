import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/charts.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M11 sample end to end: the dashboard switches chart forms and selects a donut slice.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: ChartsDemo()),
  ),
);

void main() {
  testWidgets('the dashboard switches forms and hides a slice', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Revenue by line, in thousands'), findsOneWidget);
    await tester.tap(find.text('stackedArea'));
    await tester.pump();
    await tester.tap(find.text('stacked'));
    await tester.pump();
    expect(find.text('Orders by region'), findsOneWidget);
    expect(find.text('9,900'), findsOneWidget);
    expect(find.text('Select a slice by tap, click or Enter'), findsOneWidget);
    await tester.ensureVisible(find.text('Search: 4500, 45%'));
    await tester.pump();
    await tester.tap(find.text('Search: 4500, 45%'));
    await tester.pump();
    expect(find.text('Search: 4500'), findsOneWidget);
  });
}
