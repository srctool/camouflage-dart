import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/editor.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M9 sample end to end: the toolbars act on the document, the split button's menu runs, and the properties
// sheet opens and closes.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: EditorDemo()),
  ),
);

void main() {
  testWidgets('the formatting toggles and the clipboard commands act', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.textContaining('Text style: plain'), findsOneWidget);
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(find.textContaining('Text style: bold.'), findsOneWidget);
    await tester.tap(find.text('Copy'));
    await tester.pump();
    expect(find.textContaining('Last command: Copy.'), findsOneWidget);
  });

  testWidgets('the split button saves, and its menu saves a copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Last command: Save.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save a copy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last command: Save a copy.'), findsOneWidget);
  });

  testWidgets('the link popover opens, and the properties sheet closes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Link'));
    await tester.pumpAndSettle();
    expect(find.text('Insert link'), findsOneWidget);
    await tester.tap(find.text('Insert'));
    await tester.pumpAndSettle();
    expect(find.text('Insert link'), findsNothing);
    expect(find.text('Words: 214'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Words: 214'), findsNothing);
  });
}
