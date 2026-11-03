import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'list_test_renderers.dart';
import 'test_skins.dart';

// The M10 data table and tree tests from their Flutter notes.

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

bool _focused(WidgetTester tester, Finder finder) =>
    Focus.of(tester.element(finder)).hasFocus;

class _Person {
  const _Person(this.id, this.name, this.age);

  final int id;
  final String name;
  final int age;
}

const _people = [
  _Person(1, 'Ada', 36),
  _Person(2, 'Grace', 45),
  _Person(3, 'Linus', 28),
];

final _columns = <CamoColumn<_Person>>[
  CamoColumn(
    id: 'name',
    header: 'Name',
    sortable: true,
    cell: (context, p) => Text(p.name),
  ),
  CamoColumn(
    id: 'age',
    header: 'Age',
    width: const ColumnWidth.fixed(80),
    cell: (context, p) => Text('${p.age}'),
  ),
];

Widget _table({
  List<_Person> rows = _people,
  TableSort? sort,
  ValueChanged<TableSort>? onSortChanged,
  Set<Object>? selection,
  ValueChanged<Set<Object>>? onSelectionChanged,
  ValueChanged<_Person>? onRowPressed,
  Widget? empty,
  bool loading = false,
}) => SizedBox(
  width: 600,
  height: 300,
  child: CamoDataTable<_Person>(
    columns: _columns,
    rows: rows,
    rowKey: (p) => p.id,
    semanticLabel: 'People',
    sort: sort,
    onSortChanged: onSortChanged,
    selection: selection,
    onSelectionChanged: onSelectionChanged,
    onRowPressed: onRowPressed,
    empty: empty,
    loading: loading,
  ),
);

final _tree = [
  const CamoTreeNode<String>(
    id: 'docs',
    value: 'Documents',
    children: [
      CamoTreeNode<String>(id: 'cv', value: 'CV'),
      CamoTreeNode<String>(
        id: 'notes',
        value: 'Notes',
        children: [CamoTreeNode<String>(id: 'n1', value: 'Note 1')],
      ),
    ],
  ),
  const CamoTreeNode<String>(
    id: 'pics',
    value: 'Pictures',
    children: [CamoTreeNode<String>(id: 'p1', value: 'Photo')],
  ),
  const CamoTreeNode<String>(id: 'readme', value: 'Readme'),
];

// A tree whose expanded and selected sets live in this widget, like an app's state.
class _TreeHost extends StatefulWidget {
  const _TreeHost({
    this.roots,
    this.expanded = const {},
    this.multi = false,
    this.onLoad,
    this.onExpanded,
    this.onSelected,
  });

  final List<CamoTreeNode<String>>? roots;
  final Set<Object> expanded;
  final bool multi;
  final ValueChanged<CamoTreeNode<String>>? onLoad;
  final ValueChanged<Set<Object>>? onExpanded;
  final ValueChanged<Set<Object>>? onSelected;

  @override
  State<_TreeHost> createState() => _TreeHostState();
}

class _TreeHostState extends State<_TreeHost> {
  late Set<Object> _expanded = widget.expanded;
  Set<Object> _selected = {};

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 400,
    height: 300,
    child: CamoTree<String>(
      roots: widget.roots ?? _tree,
      expanded: _expanded,
      onExpandedChanged: (v) {
        setState(() => _expanded = v);
        widget.onExpanded?.call(v);
      },
      selected: _selected,
      onSelectedChanged: (v) {
        setState(() => _selected = v);
        widget.onSelected?.call(v);
      },
      label: (v) => v,
      semanticLabel: 'Files',
      multiSelect: widget.multi,
      onLoadChildren: widget.onLoad,
    ),
  );
}

void main() {
  group('data table', () {
    testWidgets('a sortable header reports the new sort', (tester) async {
      TableSort? sort;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => _table(
              sort: sort,
              onSortChanged: (s) => setState(() => sort = s),
            ),
          ),
        ),
      );
      expect(headerCells.map((h) => h.sortable), [true, false]);
      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(sort, const TableSort('name'));
      expect(headerCells.first.sorted, isTrue);
      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(sort, const TableSort('name', ascending: false));
      await tester.tap(find.text('Age'));
      await tester.pump();
      expect(sort, const TableSort('name', ascending: false));
    });

    testWidgets('is named and reports its size', (tester) async {
      await tester.pumpWidget(_app(_table()));
      expect(find.bySemanticsLabel('People'), findsOneWidget);
      expect(lastTable!.rowCount, 3);
      expect(lastTable!.columnCount, 2);
      expect(lastTable!.selectable, isFalse);
    });

    testWidgets(
      'a row press toggles its selection and select all selects every row',
      (tester) async {
        var selection = <Object>{};
        await tester.pumpWidget(
          _app(
            StatefulBuilder(
              builder: (context, setState) => _table(
                selection: selection,
                onSelectionChanged: (s) => setState(() => selection = s),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Grace'));
        await tester.pump();
        expect(selection, {2});
        expect(tableRows[1]!.selected, isTrue);
        await tester.tap(find.text('Grace'));
        await tester.pump();
        expect(selection, isEmpty);
        await tester.tap(find.bySemanticsLabel('Select all rows'));
        await tester.pump();
        expect(selection, {1, 2, 3});
        await tester.tap(find.bySemanticsLabel('Select all rows'));
        await tester.pump();
        expect(selection, isEmpty);
      },
    );

    testWidgets('a row press calls the callback instead when it is set', (
      tester,
    ) async {
      _Person? pressed;
      var selection = <Object>{};
      await tester.pumpWidget(
        _app(
          _table(
            selection: selection,
            onSelectionChanged: (s) => selection = s,
            onRowPressed: (p) => pressed = p,
          ),
        ),
      );
      await tester.tap(find.text('Ada'));
      expect(pressed, _people.first);
      expect(selection, isEmpty);
    });

    testWidgets('arrows move between rows and Space toggles the focused one', (
      tester,
    ) async {
      var selection = <Object>{};
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => _table(
              selection: selection,
              onSelectionChanged: (s) => setState(() => selection = s),
            ),
          ),
        ),
      );
      // The sortable header takes the first Tab stop; the rows are the next.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focused(tester, find.text('Ada')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_focused(tester, find.text('Grace')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(selection, {2});
    });

    testWidgets('an empty table shows its slot and a loading one says so', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_table(rows: [], empty: const Text('No people'))),
      );
      expect(find.text('No people'), findsOneWidget);
      await tester.pumpWidget(_app(_table(rows: [], loading: true)));
      await tester.pump();
      expect(
        tester.getSemantics(find.bySemanticsLabel('People')).value,
        'Loading',
      );
    });

    testWidgets('many rows stay lazy', (tester) async {
      final many = [for (var i = 0; i < 1000; i++) _Person(i, 'person-$i', i)];
      await tester.pumpWidget(_app(_table(rows: many)));
      expect(find.text('person-0'), findsOneWidget);
      expect(find.text('person-999'), findsNothing);
    });
  });

  group('tree', () {
    testWidgets('only the expanded nodes show, with their levels', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const _TreeHost(expanded: {'docs', 'notes'})),
      );
      for (final name in [
        'Documents',
        'CV',
        'Notes',
        'Note 1',
        'Pictures',
        'Readme',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Photo'), findsNothing);
      expect(treeNodes['Documents']!.level, 0);
      expect(treeNodes['CV']!.level, 1);
      expect(treeNodes['Note 1']!.level, 2);
      expect(treeNodes['Documents']!.expanded, isTrue);
      expect(treeNodes['Pictures']!.expanded, isFalse);
      expect(treeNodes['Readme']!.hasChildren, isFalse);
    });

    testWidgets(
      'Right expands then enters, Left collapses then goes to the parent',
      (tester) async {
        Set<Object> expanded = {};
        await tester.pumpWidget(
          _app(_TreeHost(onExpanded: (v) => expanded = v)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(expanded, {'docs'});
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(_focused(tester, find.text('CV')), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(_focused(tester, find.text('Documents')), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(expanded, isEmpty);
      },
    );

    testWidgets('Home and End jump to the ends', (tester) async {
      await tester.pumpWidget(_app(const _TreeHost()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(_focused(tester, find.text('Readme')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(_focused(tester, find.text('Documents')), isTrue);
    });

    testWidgets('a press selects and multi-select toggles', (tester) async {
      Set<Object> selected = {};
      await tester.pumpWidget(_app(_TreeHost(onSelected: (v) => selected = v)));
      await tester.tap(find.text('Pictures'));
      await tester.tap(find.text('Readme'));
      expect(selected, {'readme'});
      await tester.pumpWidget(
        _app(_TreeHost(multi: true, onSelected: (v) => selected = v)),
      );
      await tester.tap(find.text('Pictures'));
      expect(selected, {'readme', 'pics'});
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Pictures'));
      expect(selected, {'readme'});
    });

    testWidgets('a node announces its state and offers the expand action', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const _TreeHost()));
      final node = tester.getSemantics(find.bySemanticsLabel('Documents'));
      expect(node.value, 'Collapsed');
      expect(node.getSemanticsData().hasAction(SemanticsAction.expand), isTrue);
    });

    testWidgets('a node with unloaded children asks for them once', (
      tester,
    ) async {
      var asked = 0;
      await tester.pumpWidget(
        _app(
          _TreeHost(
            roots: const [
              CamoTreeNode<String>(
                id: 'remote',
                value: 'Remote',
                hasChildren: true,
              ),
            ],
            expanded: const {'remote'},
            onLoad: (_) => asked++,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(asked, 1);
      expect(treeNodes['Remote']!.loading, isTrue);
    });
  });
}
