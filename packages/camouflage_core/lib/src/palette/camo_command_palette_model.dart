import 'package:flutter/widgets.dart';

import '../speed_search/camo_matcher.dart';

/// One result of a [CamoCommandSource]. [id] identifies it across sessions (the palette remembers the recent
/// ones by it). [shortcut] is the key hint shown at the row's end ("Ctrl+Shift+P"), [subtitle] a second line of
/// context (a file's folder) that is read by screen readers and shown when there is no shortcut. [onSelect] runs
/// after the palette has closed.
@immutable
class CamoCommandItem {
  /// Creates an item.
  const CamoCommandItem({
    required this.id,
    required this.title,
    required this.onSelect,
    this.subtitle,
    this.icon,
    this.shortcut,
  });

  /// Identifies the item across queries and sessions.
  final Object id;

  /// The row's text.
  final String title;

  /// Runs after the palette has closed.
  final VoidCallback onSelect;

  /// Context for the title (a folder).
  final String? subtitle;

  /// An icon before the title.
  final Widget? icon;

  /// The shortcut hint at the end of the row.
  final String? shortcut;
}

/// A group of results: "Actions", "Files", "Symbols". [search] answers a query (empty for the recents view) with
/// at most [limit] items, best first; it may take its time: the other groups show at once and this one shows a
/// loading row, and the answer to an older query is dropped. The palette highlights each title with [matchKind]
/// (`null` for none, when the source ranks by something else).
///
/// For an in-memory list use [CamoCommandSource.of].
@immutable
class CamoCommandSource {
  /// Creates a source.
  const CamoCommandSource({
    required this.title,
    required this.search,
    this.matchKind = MatchKind.fuzzy,
    this.limit = 8,
  });

  /// A source over [items]: scores every title against the query and keeps the best [limit]. An empty query lists
  /// the first [limit] items. (On the calling isolate: ten thousand items take a few milliseconds.)
  factory CamoCommandSource.of({
    required String title,
    required List<CamoCommandItem> items,
    MatchKind matchKind = MatchKind.fuzzy,
    int limit = 8,
  }) => CamoCommandSource(
    title: title,
    matchKind: matchKind,
    limit: limit,
    search: (query) async => rankCommandItems(items, query, matchKind, limit),
  );

  /// The group heading.
  final String title;

  /// Answers [query] with the group's items.
  final Future<List<CamoCommandItem>> Function(String query) search;

  /// How titles are highlighted.
  final MatchKind? matchKind;

  /// The most rows the group shows.
  final int limit;
}

/// The best [limit] of [items] for [query], best score first and in list order among equals.
@visibleForTesting
List<CamoCommandItem> rankCommandItems(
  List<CamoCommandItem> items,
  String query,
  MatchKind kind,
  int limit,
) {
  if (query.isEmpty) return items.take(limit).toList();
  final scored = <(int, int, CamoCommandItem)>[];
  for (var i = 0; i < items.length; i++) {
    final m = CamoMatcher.score(query, items[i].title, kind: kind);
    if (m != null) scored.add((m.score, i, items[i]));
  }
  scored.sort(
    (a, b) => b.$1 != a.$1 ? b.$1.compareTo(a.$1) : a.$2.compareTo(b.$2),
  );
  return [for (final s in scored.take(limit)) s.$3];
}

/// The command palette's state: whether it is [open], the typed [query] and the [recent] item ids, newest first.
/// The app owns it: open it from its own shortcut (Ctrl+K, double Shift), and persist [recent] (see [snapshot])
/// if recents should outlive the process.
class CamoCommandPaletteState extends ChangeNotifier {
  /// Creates a state with the [recent] ids a previous session saved.
  CamoCommandPaletteState({List<Object> recent = const [], this.maxRecent = 20})
    : _recent = [...recent.take(maxRecent)];

  /// How many recent ids are kept.
  final int maxRecent;

  final List<Object> _recent;
  bool _open = false;
  String _query = '';

  /// Whether the palette is showing.
  bool get open => _open;

  /// What the user typed. Reset when the palette opens.
  String get query => _query;

  set query(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  /// The ids of the items run most recently, newest first.
  List<Object> get recent => List.unmodifiable(_recent);

  /// Shows the palette with an empty query.
  void show() {
    _query = '';
    _open = true;
    notifyListeners();
  }

  /// Hides the palette.
  void hide() {
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  /// Shows the palette when hidden, hides it when showing.
  void toggle() => _open ? hide() : show();

  /// Records [id] as the most recent item. The palette does this when an item runs.
  void remember(Object id) {
    _recent
      ..remove(id)
      ..insert(0, id);
    while (_recent.length > maxRecent) {
      _recent.removeLast();
    }
    notifyListeners();
  }

  /// The [recent] ids, for the app to save and give back to the constructor.
  List<Object> snapshot() => List.of(_recent);
}
