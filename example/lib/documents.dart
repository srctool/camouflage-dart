import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

// The M6 milestone screen, the same as the Kotlin sample: a documents list with a top bar (tooltips, a sort
// menu, an overflow menu), filters as selects (a menu on desktop and a sheet on phones, a searchable sheet, an
// API-backed sheet), rows with a context menu and a "More" menu, and overlays as routes (rename in a sheet,
// delete in a dialog). Under Fluent Acrylic, the menus and the sheet are Acrylic flyouts.

class _Doc {
  const _Doc(this.name, this.kind, this.owner, this.day);

  final String name;
  final String kind;
  final String owner;
  final int day;
}

const _initialDocs = [
  _Doc('Budget 2027', 'Spreadsheet', 'Ayu', 27),
  _Doc('Launch plan', 'Document', 'Bima', 25),
  _Doc('Team photo', 'Image', 'Citra', 22),
  _Doc('Release notes', 'Document', 'Ayu', 20),
  _Doc('Invoices Q3', 'Spreadsheet', 'Dewi', 14),
];

final _kinds = [
  for (final k in ['All', 'Document', 'Spreadsheet', 'Image'])
    SelectOption(k, k),
];

final _owners = [
  for (final o in [
    'Anyone',
    'Ayu',
    'Bima',
    'Citra',
    'Dewi',
    'Eko',
    'Fajar',
    'Gita',
    'Hadi',
    'Intan',
    'Joko',
    'Kartika',
    'Lestari',
  ])
    SelectOption(o, o),
];

enum _Sort {
  newest('Newest'),
  oldest('Oldest'),
  name('Name');

  const _Sort(this.label);

  final String label;
}

/// The documents screen.
class DocumentsScreen extends StatefulWidget {
  /// Creates the screen.
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _docs = [..._initialDocs];
  var _sort = _Sort.newest;
  var _showOwner = true;
  String? _kind = 'All';
  String? _owner = 'Anyone';
  String? _city;

  List<_Doc> get _shown {
    final matching = _docs
        .where(
          (d) =>
              (_kind == 'All' || d.kind == _kind) &&
              (_owner == 'Anyone' || d.owner == _owner),
        )
        .toList();
    return switch (_sort) {
      _Sort.newest => matching..sort((a, b) => b.day.compareTo(a.day)),
      _Sort.oldest => matching..sort((a, b) => a.day.compareTo(b.day)),
      _Sort.name => matching..sort((a, b) => a.name.compareTo(b.name)),
    };
  }

  Future<void> _rename(_Doc doc) async {
    final name = await RenameSheet.show(context, doc.name);
    if (name == null || name.isEmpty) return;
    setState(() {
      final at = _docs.indexOf(doc);
      if (at >= 0) _docs[at] = _Doc(name, doc.kind, doc.owner, doc.day);
    });
  }

  Future<void> _delete(List<_Doc> docs) async {
    final confirmed = await DeleteDocsDialog.show(context, docs.length);
    if (confirmed ?? false) setState(() => _docs.removeWhere(docs.contains));
  }

  List<CamoMenuEntry> _rowMenu(_Doc doc) => [
    CamoMenuItem(
      text: 'Rename',
      onPressed: () => _rename(doc),
      leadingIcon: const AppIcon.edit(),
    ),
    CamoMenuItem(
      text: 'Share',
      onPressed: () {},
      leadingIcon: const AppIcon.share(),
      trailingText: 'Ctrl+S',
    ),
    const CamoMenuDivider(),
    CamoMenuItem(
      text: 'Delete',
      onPressed: () => _delete([doc]),
      leadingIcon: const AppIcon.delete(),
      tone: Tone.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.themeOf(context).spacing;
    final shown = _shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DocumentsTopBar(
          sort: _sort,
          onSort: (s) => setState(() => _sort = s),
          showOwner: _showOwner,
          onToggleOwner: () => setState(() => _showOwner = !_showOwner),
          canDelete: _docs.isNotEmpty,
          onDeleteAll: () => _delete([..._docs]),
        ),
        Padding(
          padding: EdgeInsets.all(spacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.m,
            children: [
              Wrap(
                spacing: spacing.s,
                runSpacing: spacing.s,
                children: [
                  // Four options: a menu on a desktop window, a sheet on a phone.
                  SizedBox(
                    width: 220,
                    child: CamoSelect<String>(
                      value: _kind,
                      onChanged: (k) => setState(() => _kind = k),
                      options: _kinds,
                      label: 'Type',
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: CamoSelect<String>(
                      value: _owner,
                      onChanged: (o) => setState(() => _owner = o),
                      options: _owners,
                      label: 'Owner',
                      searchable: true,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: _SharedFromCity(
                      city: _city,
                      onPicked: (c) => setState(() => _city = c),
                    ),
                  ),
                ],
              ),
              CamoListSection(
                title: shown.length == 1
                    ? '1 document'
                    : '${shown.length} documents',
                children: [
                  for (final doc in shown)
                    CamoContextMenuArea(
                      items: _rowMenu(doc),
                      child: CamoListItem(
                        headline: doc.name,
                        supporting: [
                          doc.kind,
                          if (_showOwner) doc.owner,
                          'Oct ${doc.day}',
                        ].join(' · '),
                        onPressed: () {},
                        trailing: CamoMenuAnchor(
                          items: _rowMenu(doc),
                          builder: (context, open) => CamoIconButton(
                            icon: const AppIcon.more(),
                            semanticLabel: 'More for ${doc.name}',
                            onPressed: open,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (shown.isEmpty) const CamoText('No documents match.'),
            ],
          ),
        ),
      ],
    );
  }
}

// Tooltips on the icon buttons, an exclusive "Sort by" group, and an overflow menu with a checkable item and a
// destructive one.
class _DocumentsTopBar extends StatelessWidget {
  const _DocumentsTopBar({
    required this.sort,
    required this.onSort,
    required this.showOwner,
    required this.onToggleOwner,
    required this.canDelete,
    required this.onDeleteAll,
  });

  final _Sort sort;
  final ValueChanged<_Sort> onSort;
  final bool showOwner;
  final VoidCallback onToggleOwner;
  final bool canDelete;
  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) => CamoTopBar(
    title: 'Documents',
    insets: EdgeInsets.zero,
    actions: [
      CamoIconButton(
        icon: const AppIcon.search(),
        semanticLabel: 'Search',
        onPressed: () {},
        tooltip: 'Search documents',
      ),
      CamoMenuAnchor(
        items: [
          CamoMenuGroup(
            exclusive: true,
            items: [
              for (final s in _Sort.values)
                CamoMenuItem(
                  text: s.label,
                  onPressed: () => onSort(s),
                  checked: sort == s,
                ),
            ],
          ),
        ],
        builder: (context, open) => CamoIconButton(
          icon: const AppIcon.sort(),
          semanticLabel: 'Sort by',
          onPressed: open,
          tooltip: 'Sort by',
        ),
      ),
      CamoMenuAnchor(
        items: [
          CamoMenuItem(
            text: 'Show owner',
            onPressed: onToggleOwner,
            checked: showOwner,
          ),
          const CamoMenuDivider(),
          CamoMenuItem(
            text: 'Delete all',
            onPressed: onDeleteAll,
            tone: Tone.error,
            enabled: canDelete,
          ),
        ],
        builder: (context, open) => CamoIconButton(
          icon: const AppIcon.more(),
          semanticLabel: 'More options',
          onPressed: open,
          tooltip: 'More options',
        ),
      ),
    ],
  );
}

const _cityPage = 8;
const _cityDelay = Duration(milliseconds: 600);

const _cities = [
  'Ambon',
  'Balikpapan',
  'Bandung',
  'Banjarmasin',
  'Batam',
  'Bekasi',
  'Bogor',
  'Denpasar',
  'Depok',
  'Jakarta',
  'Jambi',
  'Jayapura',
  'Kupang',
  'Makassar',
  'Malang',
  'Manado',
  'Mataram',
  'Medan',
  'Padang',
  'Palembang',
  'Pekanbaru',
  'Pontianak',
  'Samarinda',
  'Semarang',
  'Surabaya',
  'Surakarta',
  'Tangerang',
  'Yogyakarta',
];

// An API-backed select: a fake paged search over cities, one page per load.
class _SharedFromCity extends StatefulWidget {
  const _SharedFromCity({required this.city, required this.onPicked});

  final String? city;
  final ValueChanged<String> onPicked;

  @override
  State<_SharedFromCity> createState() => _SharedFromCityState();
}

class _SharedFromCityState extends State<_SharedFromCity> {
  String _query = '';
  var _state = const CamoPagedListState<SelectOption<String>>();
  var _request = 0;

  Future<void> _load(PagedLoad kind) async {
    final keep = kind == PagedLoad.more
        ? _state.items
        : <SelectOption<String>>[];
    final request = ++_request;
    setState(() => _state = CamoPagedListState(items: keep, loading: kind));
    await Future<void>.delayed(_cityDelay);
    // A newer search replaced this one.
    if (!mounted || request != _request) return;
    final page = _cities
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .skip(keep.length)
        .take(_cityPage)
        .toList();
    setState(
      () => _state = CamoPagedListState(
        items: [...keep, for (final c in page) SelectOption(c, c)],
        endReached: page.length < _cityPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CamoAsyncSelect<String>(
    value: widget.city,
    onChanged: widget.onPicked,
    options: _state,
    onOpen: () {
      _query = '';
      unawaited(_load(PagedLoad.initial));
    },
    onQueryChanged: (q) {
      _query = q;
      unawaited(_load(PagedLoad.initial));
    },
    onLoadMore: () => unawaited(_load(PagedLoad.more)),
    onRetry: () => unawaited(_load(PagedLoad.initial)),
    selectedLabel: widget.city,
    label: 'Shared from',
    placeholder: 'Any city',
  );
}

/// Renames a document in a sheet: the new name, or `null` when cancelled.
class RenameSheet extends StatefulWidget {
  /// Creates the sheet.
  const RenameSheet({super.key, required this.name});

  /// The current name.
  final String name;

  /// Opens it; `null` when cancelled or dismissed.
  static Future<String?> show(BuildContext context, String name) =>
      showCamoBottomSheet<String>(
        context: context,
        builder: (_) => RenameSheet(name: name),
      );

  @override
  State<RenameSheet> createState() => _RenameSheetState();
}

class _RenameSheetState extends State<RenameSheet> {
  late var _text = widget.name;

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.themeOf(context).spacing;
    return CamoBottomSheet(
      title: 'Rename',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.m,
        children: [
          CamoTextField(
            value: _text,
            onChanged: (t) => setState(() => _text = t),
            label: 'Name',
          ),
          Wrap(
            spacing: spacing.s,
            children: [
              CamoButton(
                text: 'Save',
                onPressed: _text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, _text.trim()),
              ),
              CamoButton(
                text: 'Cancel',
                appearance: Appearance.ghost,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Confirms deleting [count] documents: `true` to delete.
class DeleteDocsDialog extends StatelessWidget {
  /// Creates the dialog.
  const DeleteDocsDialog({super.key, required this.count});

  /// How many documents.
  final int count;

  /// Opens it; `null` when dismissed.
  static Future<bool?> show(BuildContext context, int count) =>
      showCamoDialog<bool>(
        context: context,
        builder: (_) => DeleteDocsDialog(count: count),
      );

  @override
  Widget build(BuildContext context) => CamoDialog(
    title: count == 1 ? 'Delete this document?' : 'Delete $count documents?',
    message: "This can't be undone.",
    confirm: CamoButton(
      text: 'Delete',
      tone: Tone.error,
      onPressed: () => Navigator.pop(context, true),
    ),
    dismiss: CamoButton(
      text: 'Cancel',
      appearance: Appearance.ghost,
      onPressed: () => Navigator.pop(context, false),
    ),
  );
}
