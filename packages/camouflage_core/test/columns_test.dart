import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The data table's resizable, hideable and reorderable columns (base CamoDataTable, M16).

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Directionality(
        textDirection: direction,
        child: CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

class _Person {
  const _Person(this.id, this.name, this.age);

  final int id;
  final String name;
  final int age;
}

const _people = [_Person(1, 'Ada', 36), _Person(2, 'Grace', 45)];

final _columns = <CamoColumn<_Person>>[
  CamoColumn(
    id: 'name',
    header: 'Name',
    width: const ColumnWidth.fixed(120),
    minWidth: 80,
    text: (p) => p.name,
    cell: (context, p) => Text(p.name),
  ),
  CamoColumn(
    id: 'age',
    header: 'Age',
    width: const ColumnWidth.fixed(80),
    cell: (context, p) => Text('${p.age}'),
  ),
  CamoColumn(
    id: 'id',
    header: 'Id',
    width: const ColumnWidth.fixed(60),
    cell: (context, p) => Text('${p.id}'),
  ),
];

Widget _table(CamoColumnState state) => SizedBox(
  width: 600,
  height: 300,
  child: CamoDataTable<_Person>(
    columns: _columns,
    rows: _people,
    rowKey: (p) => p.id,
    semanticLabel: 'People',
    columnState: state,
  ),
);

CamoColumnState _newState() => CamoColumnState(['name', 'age', 'id']);

// The header cells' labels, left to right.
List<String> _order(WidgetTester tester) {
  final found = [
    for (final label in ['Name', 'Age', 'Id'])
      if (find.text(label).evaluate().isNotEmpty) label,
  ];
  found.sort(
    (a, b) => tester
        .getTopLeft(find.text(a).first)
        .dx
        .compareTo(tester.getTopLeft(find.text(b).first).dx),
  );
  return found;
}

Future<void> _custom(WidgetTester tester, String node, String label) async {
  tester.semantics.performAction(
    find.semantics.byLabel(node),
    SemanticsAction.customAction,
    args: CustomSemanticsAction.getIdentifier(
      CustomSemanticsAction(label: label),
    ),
  );
  await tester.pump();
}

Future<void> _focusHeader(WidgetTester tester, String id) async {
  final focus = tester.widget<Focus>(
    find
        .descendant(
          of: find.byKey(ValueKey<Object>(id)),
          matching: find.byType(Focus),
        )
        .first,
  );
  focus.focusNode!.requestFocus();
  await tester.pump();
}

Future<void> _chord(
  WidgetTester tester,
  LogicalKeyboardKey modifier,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(modifier);
  await tester.pump();
}

void main() {
  group('CamoColumnState', () {
    test('moves among the visible columns and keeps the last one', () {
      final s = _newState()..hide('age');
      s.moveBy('name', 1);
      expect(s.order, ['age', 'id', 'name']); // went past the hidden one
      s.hide('name');
      s.hide('id'); // the last visible column stays
      expect(s.hidden, {'age', 'name'});
    });

    test('a width is at least its minimum and can be forgotten', () {
      final s = _newState()..resize('name', 10);
      expect(s.widths['name'], CamoColumnState.defaultMinWidth);
      s.resize('name', 200);
      s.resetWidths();
      expect(s.widths, isEmpty);
    });

    test('a snapshot restores the layout and ignores unknown ids', () {
      final s = _newState()
        ..resize('age', 90)
        ..move('id', 0)
        ..hide('name');
      final saved = s.snapshot();
      final t = CamoColumnState(['name', 'age', 'id', 'extra'])
        ..apply(
          CamoColumnSnapshot(
            order: [...saved.order, 'gone'],
            widths: {...saved.widths, 'gone': 1},
            hidden: saved.hidden,
          ),
        );
      expect(t.order, ['id', 'name', 'age', 'extra']);
      expect(t.widths, {'age': 90});
      expect(t.hidden, {'name'});
      t.reset();
      expect(t.order, ['name', 'age', 'id', 'extra']);
      expect(t.hidden, isEmpty);
    });

    test('a snapshot that hides every column shows them all', () {
      final s = _newState()
        ..apply(
          const CamoColumnSnapshot(
            order: ['name', 'age', 'id'],
            widths: {},
            hidden: {'name', 'age', 'id'},
          ),
        );
      expect(s.hidden, isEmpty);
    });
  });

  group('CamoDataTable columns', () {
    testWidgets('the state reorders and hides the columns', (tester) async {
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      expect(_order(tester), ['Name', 'Age', 'Id']);
      state.move('id', 0);
      await tester.pump();
      expect(_order(tester), ['Id', 'Name', 'Age']);
      state.hide('name');
      await tester.pump();
      expect(_order(tester), ['Id', 'Age']);
    });

    testWidgets('a saved width is used; the others keep their own', (
      tester,
    ) async {
      final state = _newState()..resize('name', 200);
      await tester.pumpWidget(_app(_table(state)));
      expect(tester.getSize(find.byType(LayoutBuilder).first).width, 200);
      expect(tester.getSize(find.byType(LayoutBuilder).at(1)).width, 80);
    });

    testWidgets('Ctrl+arrows resize a header by a step, down to its minimum', (
      tester,
    ) async {
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      await _focusHeader(tester, 'name');
      await _chord(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.arrowRight,
      );
      expect(state.widths['name'], 136);
      for (var i = 0; i < 20; i++) {
        await _chord(
          tester,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.arrowLeft,
        );
      }
      expect(state.widths['name'], 80);
    });

    testWidgets('Alt+arrows move a header', (tester) async {
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      await _focusHeader(tester, 'name');
      await _chord(
        tester,
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.arrowRight,
      );
      expect(_order(tester), ['Age', 'Name', 'Id']);
    });

    testWidgets('a screen reader can widen, move and hide a column', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      await _custom(tester, 'Age', 'Widen column');
      expect(state.widths['age'], 96);
      await _custom(tester, 'Age', 'Move column earlier');
      expect(_order(tester), ['Age', 'Name', 'Id']);
      await _custom(tester, 'Id', 'Hide column');
      expect(state.hidden, {'id'});
      handle.dispose();
    });

    testWidgets('dragging the resize edge widens the column', (tester) async {
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      final header = tester.getRect(find.byType(LayoutBuilder).first);
      final gesture = await tester.startGesture(
        Offset(header.right - 3, header.center.dy),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 500));
      expect(state.widths['name'], greaterThan(120));
    });

    testWidgets('dragging a header past its neighbor reorders', (tester) async {
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      final name = tester.getCenter(find.text('Name'));
      final gesture = await tester.startGesture(
        name,
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(20, 0));
      }
      await gesture.up();
      await tester.pump();
      expect(_order(tester), ['Age', 'Name', 'Id']);
    });

    testWidgets('a right-click opens the columns menu', (tester) async {
      final state = _newState();
      await tester.pumpWidget(_app(_table(state)));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Age')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Hide column'), findsOneWidget);
      expect(find.text('Columns'), findsOneWidget);
      expect(find.text('Reset widths'), findsOneWidget);
    });
  });
}
