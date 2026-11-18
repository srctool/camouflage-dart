import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M10 table and tree together: a table you can sort and select, and a tree whose branch loads when opened.

class _Member {
  const _Member(this.id, this.name, this.role, this.age);

  final int id;
  final String name;
  final String role;
  final int age;
}

const _members = [
  _Member(1, 'Ada Lovelace', 'Mathematician', 36),
  _Member(2, 'Grace Hopper', 'Admiral', 85),
  _Member(3, 'Linus Torvalds', 'Maintainer', 55),
  _Member(4, 'Margaret Hamilton', 'Engineer', 88),
  _Member(5, 'Alan Turing', 'Cryptanalyst', 41),
];

/// A sortable, selectable table and a tree with a lazily loaded branch.
class ListsDemo extends StatefulWidget {
  /// Creates the demo.
  const ListsDemo({super.key});

  @override
  State<ListsDemo> createState() => _ListsDemoState();
}

class _ListsDemoState extends State<ListsDemo> {
  var _sort = const TableSort('name');
  var _selection = <Object>{};
  var _expanded = <Object>{'docs'};
  var _selected = <Object>{};
  List<CamoTreeNode<String>>? _remote;
  final _columns = CamoColumnState(['name', 'role', 'age']);
  final _search = CamoSpeedSearchState();
  final _palette = CamoCommandPaletteState();
  var _lastRun = 'Nothing yet';
  late final List<CamoCommandSource> _sources = _buildSources();

  CamoCommandItem _item(String title, [String? shortcut]) => CamoCommandItem(
    id: title,
    title: title,
    shortcut: shortcut,
    onSelect: () => setState(() => _lastRun = title),
  );

  List<CamoCommandSource> _buildSources() => [
    CamoCommandSource.of(
      title: 'Actions',
      items: [
        _item('Open Repository', 'Ctrl+O'),
        _item('Commit', 'Ctrl+Enter'),
        _item('Toggle Theme'),
      ],
    ),
    CamoCommandSource.of(
      title: 'Files',
      items: [for (final m in _members) _item('${m.name}.md')],
    ),
    // A slow source: the others answer at once and this group shows a loading row.
    CamoCommandSource(
      title: 'Remote',
      limit: 3,
      search: (query) async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        return query.isEmpty
            ? const []
            : [_item('origin/main'), _item('origin/$query')];
      },
    ),
  ];

  @override
  void dispose() {
    _columns.dispose();
    _search.dispose();
    _palette.dispose();
    super.dispose();
  }

  List<_Member> get _rows {
    final rows = [..._members]
      ..sort((a, b) {
        final order = _sort.columnId == 'age'
            ? a.age.compareTo(b.age)
            : a.name.compareTo(b.name);
        return _sort.ascending ? order : -order;
      });
    return rows;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).m,
    children: [
      CamoButton(text: 'Find action', onPressed: _palette.show),
      Text('Last run: $_lastRun'),
      CamoCommandPalette(state: _palette, sources: _sources),
      SizedBox(
        height: 260,
        child: CamoDataTable<_Member>(
          columnState: _columns,
          columns: [
            CamoColumn(
              id: 'name',
              header: 'Name',
              sortable: true,
              text: (m) => m.name,
              cell: (context, m) => CamoText(m.name),
            ),
            CamoColumn(
              id: 'role',
              header: 'Role',
              width: const ColumnWidth.weight(0.8),
              cell: (context, m) => CamoText(m.role),
            ),
            CamoColumn(
              id: 'age',
              header: 'Age',
              width: const ColumnWidth.fixed(72),
              align: ColumnAlign.end,
              sortable: true,
              cell: (context, m) => CamoText('${m.age}'),
            ),
          ],
          rows: _rows,
          rowKey: (m) => m.id,
          semanticLabel: 'Members',
          sort: _sort,
          onSortChanged: (s) => setState(() => _sort = s),
          selection: _selection,
          onSelectionChanged: (s) => setState(() => _selection = s),
        ),
      ),
      CamoText('${_selection.length} selected'),
      SizedBox(
        height: 200,
        child: CamoTree<String>(
          speedSearch: _search,
          roots: [
            const CamoTreeNode<String>(
              id: 'docs',
              value: 'Documents',
              children: [
                CamoTreeNode<String>(id: 'cv', value: 'CV.pdf'),
                CamoTreeNode<String>(id: 'notes', value: 'Notes.md'),
              ],
            ),
            CamoTreeNode<String>(
              id: 'remote',
              value: 'Shared drive',
              children: _remote,
              hasChildren: true,
            ),
          ],
          expanded: _expanded,
          onExpandedChanged: (e) => setState(() => _expanded = e),
          selected: _selected,
          onSelectedChanged: (s) => setState(() => _selected = s),
          label: (v) => v,
          semanticLabel: 'Files',
          onLoadChildren: (_) => setState(
            () => _remote = const [
              CamoTreeNode<String>(id: 'backup', value: 'Backup.zip'),
              CamoTreeNode<String>(id: 'photos', value: 'Photos'),
            ],
          ),
        ),
      ),
    ],
  );
}
