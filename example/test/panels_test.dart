import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/panels.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M9 sample end to end: the popover opens and closes, the docked sheet closes, the modal one opens.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: PanelsDemo()),
  ),
);

void main() {
  testWidgets('the popover opens from its button and Cancel closes it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Share this file'), findsNothing);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(find.text('Share this file'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Share this file'), findsNothing);
  });

  testWidgets('the docked sheet closes and the modal one opens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Modified: today'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Modified: today'), findsNothing);
    await tester.tap(find.text('Details (modal)'));
    await tester.pumpAndSettle();
    expect(find.text('Modified: today'), findsOneWidget);
  });
}
