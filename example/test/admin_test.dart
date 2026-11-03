import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/admin.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M10 sample end to end: the wizard moves from the tree to the uploader to the paged table.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: AdminDemo()),
  ),
);

void main() {
  testWidgets('the wizard walks from the folders to the upload to the review', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Documents'), findsWidgets);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Add files'), findsOneWidget);
    await tester.tap(find.text('Add files'));
    await tester.pump();
    expect(find.text('scan-1.pdf'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('scan-1.pdf'), findsOneWidget);
    expect(find.text('Size (KB)'), findsOneWidget);
  });

  testWidgets('the review step pages through the sample files', (tester) async {
    tester.view.physicalSize = const Size(3000, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Page 1 of 3'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next page').first);
    await tester.pump();
    expect(find.text('Page 2 of 3'), findsOneWidget);
  });
}
