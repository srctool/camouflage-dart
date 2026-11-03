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
      SizedBox(
        height: 260,
        child: CamoDataTable<_Member>(
          columns: [
            CamoColumn(
              id: 'name',
              header: 'Name',
              sortable: true,
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
