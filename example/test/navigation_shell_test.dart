import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/navigation_shell.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M8 milestone screen end to end: the layout follows the window size and the screen keeps its state.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: NavigationShellDemo()),
  ),
);

// The chrome widgets are generic over the app's destination type, so they're found by name.
Finder _chrome(String name) =>
    find.byWidgetPredicate((w) => w.runtimeType.toString().startsWith(name));

void main() {
  testWidgets('the layout follows the window size and keeps the screen state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(_chrome('CamoNavigationBar'), findsOneWidget);
    expect(_chrome('CamoNavigationRail'), findsNothing);
    await tester.tap(find.text('Tap'));
    await tester.pump();
    expect(find.textContaining('1 taps'), findsOneWidget);
    await tester.tap(find.text('medium'));
    await tester.pumpAndSettle();
    expect(_chrome('CamoNavigationRail'), findsOneWidget);
    expect(_chrome('CamoNavigationBar'), findsNothing);
    expect(find.textContaining('1 taps'), findsOneWidget);
    await tester.tap(find.text('large'));
    await tester.pumpAndSettle();
    expect(_chrome('CamoNavigationDrawer'), findsOneWidget);
    expect(find.textContaining('1 taps'), findsOneWidget);
    expect(find.text('Home (large window)'), findsOneWidget);
  });
}
