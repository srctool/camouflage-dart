import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// Nested menus (base CamoMenu, Submenus M16): hover, tap and arrow keys open a submenu beside its row.

// The direction wraps the Navigator, so the popup route has it too.
Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      builder: (context, child) =>
          Directionality(textDirection: direction, child: child!),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: CamouflageProvider(
        skin: skinA,
        theme: themeT,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

List<CamoMenuEntry> _reset(List<String> log) => [
  CamoMenuItem(text: 'Copy', onPressed: () => log.add('copy')),
  CamoMenuSubmenu(
    text: 'Reset',
    items: [
      CamoMenuItem(text: 'Soft', onPressed: () => log.add('soft')),
      CamoMenuItem(text: 'Mixed', onPressed: () => log.add('mixed')),
      CamoMenuSubmenu(
        text: 'Hard',
        items: [
          CamoMenuItem(text: 'Really', onPressed: () => log.add('really')),
        ],
      ),
    ],
  ),
  CamoMenuItem(text: 'Paste', onPressed: () => log.add('paste')),
];

Widget _more(List<CamoMenuEntry> items) => CamoMenuAnchor(
  items: items,
  builder: (context, open) => CamoButton(text: 'More', onPressed: open),
);

bool _hasFocus(String text) {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  return find
      .descendant(
        of: find.byElementPredicate((e) => e == focused),
        matching: find.text(text),
      )
      .evaluate()
      .isNotEmpty;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('More'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a tap opens the submenu and a leaf closes every level', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(_app(_more(_reset(log))));
    await _open(tester);
    expect(find.text('Soft'), findsNothing);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('Soft'), findsOneWidget);
    await tester.tap(find.text('Mixed'));
    await tester.pumpAndSettle();
    expect(log, ['mixed']);
    expect(find.text('Reset'), findsNothing);
    expect(find.text('Mixed'), findsNothing);
  });

  testWidgets('hovering a row opens it after a moment', (tester) async {
    // A mouse hover shows the row's highlight only in the traditional (desktop) focus mode.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.pumpWidget(_app(_more(_reset([]))));
    await _open(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Reset')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Soft'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Soft'), findsOneWidget);
  });

  testWidgets(
    'the arrow opens it and focuses the first item, the other closes',
    (tester) async {
      await tester.pumpWidget(_app(_more(_reset([]))));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_hasFocus('Copy'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_hasFocus('Reset'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_hasFocus('Soft'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(find.text('Soft'), findsNothing);
      expect(_hasFocus('Reset'), isTrue);
    },
  );

  testWidgets('Esc closes only the submenu, then the menu', (tester) async {
    await tester.pumpWidget(_app(_more(_reset([]))));
    await _open(tester);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Soft'), findsNothing);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets(
    'a tap on a parent row while the submenu is open is not an outside tap',
    (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_app(_more(_reset(log))));
      await _open(tester);
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();
      expect(log, ['paste']);
    },
  );

  testWidgets('the left arrow opens it in right-to-left', (tester) async {
    await tester.pumpWidget(
      _app(_more(_reset([])), direction: TextDirection.rtl),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_hasFocus('Soft'), isTrue);
  });

  testWidgets('the row says it can expand and then collapse', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(_more(_reset([]))));
    await _open(tester);
    var data = tester.getSemantics(find.text('Reset')).getSemanticsData();
    expect(data.hasAction(SemanticsAction.expand), isTrue);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    data = tester.getSemantics(find.text('Reset')).getSemanticsData();
    expect(data.hasAction(SemanticsAction.collapse), isTrue);
    handle.dispose();
  });

  testWidgets('a submenu may hold a submenu', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_app(_more(_reset(log))));
    await _open(tester);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Really'));
    await tester.pumpAndSettle();
    expect(log, ['really']);
  });
}
