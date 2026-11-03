import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M10 milestone screen: an admin tool that uploads files in three steps: choose a folder in a tree (with its
// path as breadcrumbs), add files to upload (the uploader, with fake progress), then review them in a sortable,
// paged table next to a carousel of previews.

const _steps = ['Folder', 'Upload', 'Review'];
const _pageSize = 4;
const _slides = [Color(0xFF6D8FB5), Color(0xFFB58F6D), Color(0xFF8FB56D)];

const _folders = [
  CamoTreeNode<String>(
    id: 'docs',
    value: 'Documents',
    children: [
      CamoTreeNode<String>(id: 'reports', value: 'Reports'),
      CamoTreeNode<String>(id: 'invoices', value: 'Invoices'),
    ],
  ),
  CamoTreeNode<String>(
    id: 'media',
    value: 'Media',
    children: [CamoTreeNode<String>(id: 'photos', value: 'Photos')],
  ),
];

const _paths = {
  'docs': ['Home', 'Documents'],
  'reports': ['Home', 'Documents', 'Reports'],
  'invoices': ['Home', 'Documents', 'Invoices'],
  'media': ['Home', 'Media'],
  'photos': ['Home', 'Media', 'Photos'],
};

class _Entry {
  const _Entry(this.id, this.name, this.kb);

  final int id;
  final String name;
  final int kb;
}

/// A three-step admin flow: pick a folder, add files, review them in a table with pages and previews.
class AdminDemo extends StatefulWidget {
  /// Creates the demo.
  const AdminDemo({super.key});

  @override
  State<AdminDemo> createState() => _AdminDemoState();
}

class _AdminDemoState extends State<AdminDemo> {
  var _step = 0;
  var _folder = 'docs';
  var _expanded = <Object>{'docs'};
  var _files = <UploadFile>[];
  var _sort = const TableSort('name');
  var _page = 0;

  Widget _folderStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).s,
    children: [
      SizedBox(
        height: 48,
        child: CamoBreadcrumb(
          items: [
            for (final name in _paths[_folder]!)
              CamoBreadcrumbItem(id: name, label: name, onPressed: () {}),
          ],
        ),
      ),
      SizedBox(
        height: 180,
        child: CamoTree<String>(
          roots: _folders,
          expanded: _expanded,
          onExpandedChanged: (e) => setState(() => _expanded = e),
          selected: {_folder},
          onSelectedChanged: (s) => setState(() => _folder = s.first as String),
          label: (v) => v,
          semanticLabel: 'Folders',
        ),
      ),
    ],
  );

  Widget _uploadStep() => CamoFileUploader(
    files: _files,
    semanticLabel: 'Add files',
    hint: 'Pressing adds a sample file; the app runs the real upload',
    onPick: () {
      final n = _files.length + 1;
      setState(
        () => _files = [
          ..._files,
          UploadFile(
            id: n,
            name: 'scan-$n.pdf',
            sizeBytes: n * 300 * 1024,
            progress: n.isEven ? 0.6 : 1,
            status: n.isEven
                ? const UploadStatus.uploading()
                : const UploadStatus.done(),
          ),
        ],
      );
    },
    onRemove: (f) => setState(() => _files = [..._files]..remove(f)),
  );

  Widget _reviewStep() {
    final source = _files.isEmpty
        ? [
            for (var i = 0; i < 9; i++)
              UploadFile(
                id: i,
                name: 'sample-${i + 1}.png',
                sizeBytes: (i + 1) * 100 * 1024,
              ),
          ]
        : _files;
    final entries =
        [
          for (final (i, f) in source.indexed)
            _Entry(i, f.name, (f.sizeBytes ?? 0) ~/ 1024),
        ]..sort((a, b) {
          final order = _sort.columnId == 'kb'
              ? a.kb.compareTo(b.kb)
              : a.name.compareTo(b.name);
          return _sort.ascending ? order : -order;
        });
    final pages = (entries.length + _pageSize - 1) ~/ _pageSize;
    final shown = entries.skip(_page * _pageSize).take(_pageSize).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Camouflage.spacingOf(context).s,
      children: [
        SizedBox(
          height: 250,
          child: CamoDataTable<_Entry>(
            columns: [
              CamoColumn(
                id: 'name',
                header: 'File',
                sortable: true,
                cell: (context, e) => CamoText(e.name),
              ),
              CamoColumn(
                id: 'kb',
                header: 'Size (KB)',
                width: const ColumnWidth.fixed(96),
                align: ColumnAlign.end,
                sortable: true,
                cell: (context, e) => CamoText('${e.kb}'),
              ),
            ],
            rows: shown,
            rowKey: (e) => e.id,
            semanticLabel: 'Uploaded files',
            sort: _sort,
            onSortChanged: (s) => setState(() {
              _sort = s;
              _page = 0;
            }),
          ),
        ),
        CamoPagination(
          pageCount: pages,
          page: _page.clamp(0, pages - 1),
          onPageChanged: (p) => setState(() => _page = p),
          variant: PaginationVariant.compact,
        ),
        SizedBox(
          height: 100,
          child: CamoCarousel<Color>(
            items: _slides,
            itemKey: (c) => c,
            semanticLabel: 'Previews',
            itemBuilder: (context, c) => ColoredBox(
              color: c,
              child: const Align(
                alignment: Alignment.topLeft,
                child: CamoText('Preview'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).m,
    children: [
      CamoProgressSteps(
        current: _step,
        steps: [
          for (final (i, name) in _steps.indexed)
            CamoStep(
              id: name,
              label: name,
              onPressed: i < _step ? () => setState(() => _step = i) : null,
            ),
        ],
      ),
      switch (_step) {
        0 => _folderStep(),
        1 => _uploadStep(),
        _ => _reviewStep(),
      },
      Wrap(
        spacing: Camouflage.spacingOf(context).s,
        runSpacing: Camouflage.spacingOf(context).s,
        children: [
          CamoButton(
            text: 'Back',
            appearance: Appearance.outline,
            onPressed: _step > 0 ? () => setState(() => _step--) : null,
          ),
          CamoButton(
            text: 'Next',
            onPressed: _step < _steps.length - 1
                ? () => setState(() => _step++)
                : null,
          ),
        ],
      ),
    ],
  );
}
