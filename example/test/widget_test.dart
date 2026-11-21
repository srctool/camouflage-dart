import 'package:camouflage_example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The paged list's fake API answers a page a second and asks for the next after each frame: a frame a
// second until its five pages are in, so no request is left pending when the tree goes.
Future<void> settleProducts(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 4000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const CamouflageExampleApp());
  await tester.pump();
}

// Opens the catalog entry's page from the home.
Future<void> _open(WidgetTester tester, String entry) async {
  await tester.ensureVisible(find.text(entry));
  await tester.pump();
  await tester.tap(find.text(entry));
  await tester.pump(const Duration(milliseconds: 600));
}

// The theme page, from anywhere: its top bar action is named "Theme".
Future<void> _theme(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Theme'));
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(
    find.bySemanticsLabel('Back').first,
  ); // the app bar's, before a demo's own
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('the home lists the components and a card opens its page', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpApp(tester);
    expect(find.text('Components'), findsOneWidget);
    expect(find.text('Split panes'), findsOneWidget);
    expect(find.text('Dock layout'), findsOneWidget);
    await _open(tester, 'Buttons');
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('solid'), findsNWidgets(4));
    await _back(tester);
    expect(find.text('Components'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the example switches skins through the root provider', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpApp(tester);
    await _theme(tester);
    await tester.tap(find.text('Debug'));
    await tester.pump(const Duration(milliseconds: 400));
    await _back(tester);
    await _open(tester, 'Buttons');
    expect(find.text('[solid] solid'), findsNWidgets(4));
    await _theme(tester);
    await tester.tap(find.text('[outline] Fluent'));
    await tester.pump(const Duration(milliseconds: 400));
    await _back(tester);
    await _open(tester, 'Buttons');
    expect(find.text('solid'), findsNWidgets(4));
    handle.dispose();
  });

  testWidgets('the example switches to the Cupertino skin and its glass', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpApp(tester);
    await _theme(tester);
    await tester.tap(find.text('Cupertino'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Cupertino Glass'));
    await tester.pump(const Duration(milliseconds: 600));
    await _back(tester);
    await _open(tester, 'Buttons');
    expect(find.text('solid'), findsNWidgets(4));
    handle.dispose();
  });

  testWidgets('the example switches to the Material skin', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpApp(tester);
    await _theme(tester);
    await tester.tap(find.text('Material'));
    await tester.pump(const Duration(milliseconds: 600));
    await _back(tester);
    await _open(tester, 'Buttons');
    expect(find.text('solid'), findsNWidgets(4));
    handle.dispose();
  });

  testWidgets('every catalog page opens without errors', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpApp(tester);
    for (final entry in const [
      'Checkout',
      'Forms',
      'Split panes',
      'Dock layout',
      'Toolbars',
      'Table and tree',
      'Charts',
    ]) {
      await _open(tester, entry);
      expect(tester.takeException(), isNull, reason: entry);
      await _back(tester);
    }
    handle.dispose();
  });

  testWidgets('the paged list page settles its fake API', (tester) async {
    await _pumpApp(tester);
    await _open(tester, 'Paged list');
    await settleProducts(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the example starts in dark mode when the platform is dark', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _pumpApp(tester);
    await _theme(tester);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    handle.dispose();
  });
}
