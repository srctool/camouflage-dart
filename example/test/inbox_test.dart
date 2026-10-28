import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/inbox.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M7 milestone screen end to end: Archive with Undo, sync Retry, the failed upload's Retry snackbar.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  builder: (context, _) => CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: InboxScreen()),
  ),
);

// A few frames, so a snackbar's slide finishes.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('archiving shows Undo, which puts the message back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Notes on the analytical engine'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Archive').first);
    await _settle(tester);
    expect(find.text('Notes on the analytical engine'), findsNothing);
    expect(find.text('Message archived'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await _settle(tester);
    expect(find.text('Notes on the analytical engine'), findsOneWidget);
    // Let the uploads and the snackbars finish before the tree goes.
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('Retry syncs, shows a bar, then confirms', (tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text("Couldn't sync"), findsOneWidget);
    await tester.tap(find.text('Retry').first);
    await tester.pump();
    expect(find.text("Couldn't sync"), findsNothing);
    expect(find.bySemanticsLabel('Syncing'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.bySemanticsLabel('Syncing'), findsNothing);
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('the failing upload offers Retry, which finishes it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.text('report.pdf · failed'), findsOneWidget);
    expect(find.text("Couldn't upload report.pdf"), findsOneWidget);
    await _settle(tester);
    // The snackbar's Retry, not the sync banner's.
    await tester.tap(find.text('Retry').last);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.text('report.pdf'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
  });
}
