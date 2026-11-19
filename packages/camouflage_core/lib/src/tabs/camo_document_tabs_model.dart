import 'package:flutter/widgets.dart';

/// A document of a [CamoDocumentTabs]: [id] identifies it, [title] names its tab, [modified] draws the unsaved
/// dot, and a document that is not [closable] has no close button. [icon] is drawn before the title.
@immutable
class CamoDocument {
  /// Creates a document.
  const CamoDocument({
    required this.id,
    required this.title,
    this.icon,
    this.modified = false,
    this.closable = true,
  });

  /// Identifies the document.
  final Object id;

  /// The tab's title.
  final String title;

  /// An icon before the title.
  final Widget? icon;

  /// Whether it has unsaved changes.
  final bool modified;

  /// `false` hides the close button and the Close action.
  final bool closable;
}

/// A saved tab layout: the order of the document ids and which are pinned.
@immutable
class CamoDocumentTabsSnapshot {
  /// Creates a snapshot.
  const CamoDocumentTabsSnapshot(this.order, this.pinned);

  /// The ids in tab order.
  final List<Object> order;

  /// The pinned ids.
  final Set<Object> pinned;
}

/// The order and the pinned set of a [CamoDocumentTabs] row, owned by the app so a layout survives restarts
/// ([snapshot] and [apply]). Pinned tabs always sit at the start and reorder among themselves; the others
/// follow. The row adds new documents at the end and forgets closed ones.
class CamoDocumentTabsState extends ChangeNotifier {
  /// Creates a state.
  CamoDocumentTabsState({
    List<Object> order = const [],
    Set<Object> pinned = const {},
  }) : _layout = _normalized(order, pinned);

  _TabLayout _layout;

  /// The ids in tab order, pinned first.
  List<Object> get order => List.unmodifiable(_layout.order);

  /// The pinned ids.
  Set<Object> get pinned => Set.unmodifiable(_layout.pinned);

  /// Whether [id] is pinned.
  bool isPinned(Object id) => _layout.pinned.contains(id);

  void _set(_TabLayout next) {
    if (next.same(_layout)) return;
    _layout = next;
    notifyListeners();
  }

  /// Moves [id] to position [to], staying inside its group (pinned tabs among pinned, others among others).
  void move(Object id, int to) => _set(_layout.moved(id, to));

  /// Moves [id] [delta] places along the order (negative: toward the start), staying inside its group.
  void moveBy(Object id, int delta) {
    final at = _layout.order.indexOf(id);
    if (at >= 0) move(id, at + delta);
  }

  /// Pins [id]: it moves to the end of the pinned tabs.
  void pin(Object id) => _set(_layout.withPinned(id, true));

  /// Unpins [id]: it moves to the start of the other tabs.
  void unpin(Object id) => _set(_layout.withPinned(id, false));

  /// The layout to save.
  CamoDocumentTabsSnapshot snapshot() =>
      CamoDocumentTabsSnapshot(order, pinned);

  /// Restores a saved [snapshot].
  void apply(CamoDocumentTabsSnapshot snapshot) =>
      _set(_normalized(snapshot.order, snapshot.pinned));

  /// Adds ids the state doesn't know at the end and drops ids that are gone.
  void sync(List<Object> ids) => _set(_layout.synced(ids));

  /// [ids] in this state's order; unknown ids at the end in their own order.
  List<Object> sorted(List<Object> ids) => _layout.synced(ids).order;
}

// The pure ordering rules: [order] with the pinned ids first.
class _TabLayout {
  const _TabLayout(this.order, this.pinned);

  final List<Object> order;
  final Set<Object> pinned;

  int get _pinnedCount => order.where(pinned.contains).length;

  bool same(_TabLayout other) =>
      other.order.length == order.length &&
      other.pinned.length == pinned.length &&
      [for (var i = 0; i < order.length; i++) order[i] == other.order[i]]
          .every((e) => e) &&
      other.pinned.containsAll(pinned);

  _TabLayout moved(Object id, int to) {
    final from = order.indexOf(id);
    if (from < 0) return this;
    final first = pinned.contains(id) ? 0 : _pinnedCount;
    final last = pinned.contains(id) ? _pinnedCount - 1 : order.length - 1;
    final target = to.clamp(first, last < first ? first : last);
    if (target == from) return this;
    final next = [...order]
      ..removeAt(from)
      ..insert(target, id);
    return _TabLayout(next, pinned);
  }

  _TabLayout withPinned(Object id, bool value) {
    if (!order.contains(id) || pinned.contains(id) == value) return this;
    final rest = [...order]..remove(id);
    final count = rest.where(pinned.contains).length;
    final pins = value ? {...pinned, id} : ({...pinned}..remove(id));
    return _TabLayout([...rest.take(count), id, ...rest.skip(count)], pins);
  }

  _TabLayout synced(List<Object> ids) {
    final known = ids.toSet();
    final kept = order.where(known.contains).toList();
    final added = ids.where((i) => !kept.contains(i));
    return _normalized([
      ...kept,
      ...added,
    ], pinned.where(known.contains).toSet());
  }
}

_TabLayout _normalized(List<Object> order, Set<Object> pinned) {
  final distinct = order.toSet().toList();
  final pins = pinned.where(distinct.contains).toSet();
  return _TabLayout([
    ...distinct.where(pins.contains),
    ...distinct.where((i) => !pins.contains(i)),
  ], pins);
}
