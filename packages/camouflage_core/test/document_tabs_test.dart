import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// Document tabs: ordering rules, close, reorder, pin, overflow and screen reader actions (M16).

Widget _app(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Directionality(
        textDirection: dir,
        child: CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

List<CamoDocument> _docs(int n, {Set<int> modified = const {}}) => [
  for (var i = 1; i <= n; i++)
    CamoDocument(id: i, title: 'Doc $i', modified: modified.contains(i)),
];

class _Host extends StatefulWidget {
  const _Host(this.documents, this.state, this.closed, {this.width = 2000});

  final List<CamoDocument> documents;
  final CamoDocumentTabsState state;
  final List<Object> closed;
  final double width;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  Object _selected = 1;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: CamoDocumentTabs(
      documents: widget.documents,
      selected: _selected,
      onSelect: (id) => setState(() => _selected = id),
      onClose: widget.closed.add,
      state: widget.state,
    ),
  );
}

Future<void> _act(WidgetTester tester, String tab, String label) async {
  tester.semantics.performAction(
    find.semantics.byLabel(tab),
    SemanticsAction.customAction,
    args: CustomSemanticsAction.getIdentifier(
      CustomSemanticsAction(label: label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CamoDocumentTabsState', () {
    CamoDocumentTabsState state() =>
        CamoDocumentTabsState(order: ['a', 'b', 'c', 'd'], pinned: {'b'});

    test('pinned tabs sit at the start', () {
      expect(state().order, ['b', 'a', 'c', 'd']);
    });

    test('a tab moves within its own group only', () {
      final s = state()..move('d', 0);
      expect(s.order, ['b', 'd', 'a', 'c']);
      s.move('b', 3);
      expect(s.order, ['b', 'd', 'a', 'c']);
      s.moveBy('a', 1);
      expect(s.order, ['b', 'd', 'c', 'a']);
    });

    test('pinning goes to the end of the pinned, unpinning to the start of the rest', () {
      final s = state()..pin('d');
      expect(s.order, ['b', 'd', 'a', 'c']);
      s.unpin('b');
      expect(s.order, ['d', 'b', 'a', 'c']);
      expect(s.pinned, {'d'});
    });

    test('sync adds new ids at the end and drops closed ones', () {
      final s = state()..sync(['a', 'c', 'e', 'b']);
      expect(s.order, ['b', 'a', 'c', 'e']);
      s.sync(['a', 'e']);
      expect(s.order, ['a', 'e']);
      expect(s.pinned, isEmpty);
    });

    test('a snapshot round-trips', () {
      final s = state()..move('d', 1);
      final copy = CamoDocumentTabsState()..apply(s.snapshot());
      expect(copy.order, s.order);
      expect(copy.pinned, s.pinned);
    });
  });

  group('CamoDocumentTabs', () {
    testWidgets('every tab has a Close action that asks the app', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final closed = <Object>[];
      await tester.pumpWidget(
        _app(_Host(_docs(3), CamoDocumentTabsState(), closed)),
      );
      await tester.pumpAndSettle();
      await _act(tester, 'Doc 2', 'Close');
      expect(closed, [2]);
      handle.dispose();
    });

    testWidgets('a modified document is announced as modified', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(_Host(_docs(3, modified: {2}), CamoDocumentTabsState(), [])),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Doc 2')).value,
        contains('modified'),
      );
      handle.dispose();
    });

    testWidgets('Alt+arrows move the focused tab', (tester) async {
      final state = CamoDocumentTabsState();
      await tester.pumpWidget(_app(_Host(_docs(3), state, [])));
      await tester.pumpAndSettle();
      // Tab enters the bar on the selected tab.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(state.order, [2, 1, 3]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      expect(state.order, [2, 3, 1]);
    });

    testWidgets(
      'in right to left Alt+Left moves the tab visually left, which is later',
      (tester) async {
        final state = CamoDocumentTabsState();
        await tester.pumpWidget(
          _app(_Host(_docs(3), state, [], width: 700), dir: TextDirection.rtl),
        );
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
        expect(state.order, [2, 1, 3]);
      },
    );

    testWidgets('Move and Pin actions reorder; pinned tabs stay first', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final state = CamoDocumentTabsState();
      await tester.pumpWidget(_app(_Host(_docs(4), state, [])));
      await tester.pumpAndSettle();
      await _act(tester, 'Doc 3', 'Move earlier');
      expect(state.order, [1, 3, 2, 4]);
      await _act(tester, 'Doc 4', 'Pin');
      expect(state.order, [4, 1, 3, 2]);
      expect(tester.getSemantics(find.text('Doc 4')).value, contains('pinned'));
      await _act(tester, 'Doc 4', 'Unpin');
      expect(state.pinned, isEmpty);
      handle.dispose();
    });

    testWidgets('a middle click closes', (tester) async {
      final closed = <Object>[];
      await tester.pumpWidget(
        _app(_Host(_docs(3), CamoDocumentTabsState(), closed)),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kMiddleMouseButton,
      );
      await gesture.down(tester.getCenter(find.text('Doc 3')));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(closed, [3]);
    });

    testWidgets('dragging a tab past its neighbor swaps them', (tester) async {
      final state = CamoDocumentTabsState();
      await tester.pumpWidget(_app(_Host(_docs(3), state, [])));
      await tester.pumpAndSettle();
      final width = tester.getSize(find.text('Doc 1')).width + 60;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Doc 1')),
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(Offset(width / 3, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(state.order.first, isNot(1));
    });

    testWidgets('twenty tabs in a narrow bar overflow into a show all menu', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final state = CamoDocumentTabsState();
      await tester.pumpWidget(_app(_Host(_docs(20), state, [], width: 300)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Show all tabs'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Show all tabs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Doc 20').last);
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('a bar that fits has no overflow menu', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(_Host(_docs(3), CamoDocumentTabsState(), [])),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Show all tabs'), findsNothing);
      handle.dispose();
    });

    testWidgets('a right-click menu keeps every child of the bar a tab', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 2000,
            child: CamoDocumentTabs(
              documents: _docs(3),
              selected: 1,
              onSelect: (_) {},
              onClose: (_) {},
              state: CamoDocumentTabsState(),
              onContextMenu: (doc) => [
                CamoMenuItem(text: 'Pin', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  });
}
