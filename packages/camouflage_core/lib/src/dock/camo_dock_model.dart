import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An edge of a [CamoDockLayout]. `left` and `right` mean start and end: they swap in right-to-left layouts.
enum DockEdge {
  /// The start side.
  left,

  /// The end side.
  right,

  /// The bottom.
  bottom,
}

/// A tool window: [id] identifies it, [title] names it on its stripe button and header, [icon] is the stripe
/// button's glyph, [defaultEdge] is where it starts (the state may have moved it) and [child] is what it shows.
@immutable
class CamoToolWindow {
  /// Creates a tool window.
  const CamoToolWindow({
    required this.id,
    required this.title,
    required this.icon,
    required this.defaultEdge,
    required this.child,
  });

  /// Identifies the window in the state.
  final Object id;

  /// Names it.
  final String title;

  /// The stripe button's glyph.
  final Widget icon;

  /// Where it starts.
  final DockEdge defaultEdge;

  /// The content.
  final Widget child;
}

/// A saved dock layout: where each tool window is (stripe order), which are open, the sizes and the maximized one.
@immutable
class CamoDockSnapshot {
  /// Creates a snapshot.
  const CamoDockSnapshot({
    required this.order,
    required this.edges,
    required this.open,
    required this.sizes,
    this.maximized,
  });

  /// Every window id in stripe order.
  final List<Object> order;

  /// The edge of each window.
  final Map<Object, DockEdge> edges;

  /// The open windows.
  final Set<Object> open;

  /// Each dock's size as a fraction of the window.
  final Map<DockEdge, double> sizes;

  /// The maximized window, if any.
  final Object? maximized;

  @override
  bool operator ==(Object other) =>
      other is CamoDockSnapshot &&
      listEquals(other.order, order) &&
      mapEquals(other.edges, edges) &&
      setEquals(other.open, open) &&
      mapEquals(other.sizes, sizes) &&
      other.maximized == maximized;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(order),
    Object.hashAll(edges.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAll(open),
    Object.hashAll(sizes.entries.map((e) => Object.hash(e.key, e.value))),
    maximized,
  );
}

const _defaultSizes = {
  DockEdge.left: 0.22,
  DockEdge.right: 0.22,
  DockEdge.bottom: 0.3,
};

/// The layout of a `CamoDockLayout`, owned by the app so it survives restarts ([snapshot] and [apply]): the edge
/// each tool window sits on and its place on that edge's stripe, which windows are open, how big each dock is (a
/// **fraction** of the window, so a saved layout restores at another size) and which window is maximized.
/// [defaults] gives every tool window's id and starting edge, in stripe order; [open] the ones that start open.
/// Several open windows on one edge stack in a split of their own.
class CamoDockState extends ChangeNotifier {
  /// Creates a state for the windows in [defaults].
  CamoDockState(Map<Object, DockEdge> defaults, {Set<Object> open = const {}})
    : _first = Map.of(defaults),
      _order = defaults.keys.toList(),
      _edges = Map.of(defaults),
      _open = {
        for (final id in open)
          if (defaults.containsKey(id)) id,
      };

  final Map<Object, DockEdge> _first;
  List<Object> _order;
  Map<Object, DockEdge> _edges;
  Set<Object> _open;
  Map<DockEdge, double> _sizes = _defaultSizes;
  Object? _maximized;
  int _generation = 0;
  int _focusCount = 0;
  Object? _focusTarget;

  /// Every tool window's id in stripe order.
  List<Object> get ids => List.unmodifiable(_order);

  /// The id of the maximized tool window, or `null`.
  Object? get maximized => _maximized;

  /// The edge [id] sits on.
  DockEdge? edgeOf(Object id) => _edges[id];

  /// The windows on [edge], in stripe order.
  List<Object> windowsOn(DockEdge edge) => [
    for (final id in _order)
      if (_edges[id] == edge) id,
  ];

  /// The open windows on [edge], in stripe order.
  List<Object> openOn(DockEdge edge) => [
    for (final id in windowsOn(edge))
      if (_open.contains(id)) id,
  ];

  /// Whether [id] is open.
  bool isOpen(Object id) => _open.contains(id);

  /// The size of the dock on [edge] as a fraction of the window.
  double sizeOf(DockEdge edge) => _sizes[edge]!;

  /// Bumped by [apply]: the layout rebuilds its splits from the restored sizes.
  int get generation => _generation;

  /// Bumped by [focus]; the layout moves focus into [focusTarget] when it changes.
  int get focusCount => _focusCount;

  /// The window [focus] last named.
  Object? get focusTarget => _focusTarget;

  /// Records a dragged size without rebuilding for it when nothing changed.
  void setSize(DockEdge edge, double fraction) {
    if (fraction <= 0 || fraction >= 1 || _sizes[edge] == fraction) return;
    _sizes = {..._sizes, edge: fraction};
    notifyListeners();
  }

  /// Opens [id] if it is closed, closes it if it is open.
  void toggle(Object id) => isOpen(id) ? close(id) : open(id);

  /// Opens [id]. Another window's maximize ends.
  void open(Object id) {
    if (!_edges.containsKey(id)) return;
    _open = {..._open, id};
    if (_maximized != null && _maximized != id) _maximized = null;
    notifyListeners();
  }

  /// Hides [id]; it keeps its place on the stripe.
  void close(Object id) {
    _open = {..._open}..remove(id);
    if (_maximized == id) _maximized = null;
    notifyListeners();
  }

  /// Moves [id] to the end of [edge]'s stripe; it stays open if it was.
  void move(Object id, DockEdge edge) {
    if (!_edges.containsKey(id) || _edges[id] == edge) return;
    _edges = {..._edges, id: edge};
    _order = [..._order.where((o) => o != id), id];
    notifyListeners();
  }

  /// Opens [id] and has it fill the window: the other docks and the center hide, the stripes stay.
  void maximize(Object id) {
    if (!_edges.containsKey(id)) return;
    _open = {..._open, id};
    _maximized = id;
    notifyListeners();
  }

  /// Brings back what [maximize] hid.
  void restore() {
    if (_maximized == null) return;
    _maximized = null;
    notifyListeners();
  }

  /// Opens [id] and moves keyboard focus into it (an app's "Show Git" shortcut).
  void focus(Object id) {
    if (!_edges.containsKey(id)) return;
    _focusTarget = id;
    _focusCount++;
    open(id);
  }

  /// The layout to save.
  CamoDockSnapshot snapshot() => CamoDockSnapshot(
    order: List.of(_order),
    edges: Map.of(_edges),
    open: Set.of(_open),
    sizes: Map.of(_sizes),
    maximized: _maximized,
  );

  /// Restores a saved layout. Windows it doesn't know keep their place at the end; ids that are gone are dropped.
  void apply(CamoDockSnapshot snapshot) {
    final known = [
      for (final id in snapshot.order)
        if (_first.containsKey(id)) id,
    ];
    _order = [
      ...known,
      for (final id in _first.keys)
        if (!known.contains(id)) id,
    ];
    _edges = {
      ..._first,
      for (final e in snapshot.edges.entries)
        if (_first.containsKey(e.key)) e.key: e.value,
    };
    _open = {
      for (final id in snapshot.open)
        if (_first.containsKey(id)) id,
    };
    _sizes = {
      ..._defaultSizes,
      for (final e in snapshot.sizes.entries)
        if (e.value > 0 && e.value < 1) e.key: e.value,
    };
    _maximized = _open.contains(snapshot.maximized) ? snapshot.maximized : null;
    _generation++;
    notifyListeners();
  }
}

/// The words a dock says; set them to translate.
@immutable
class DockStrings {
  /// Creates the strings.
  const DockStrings({
    this.stripe = _defaultStripe,
    this.moveTo = 'Move to',
    this.edge = _defaultEdge,
    this.hide = 'Hide',
    this.maximize = 'Maximize',
    this.restore = 'Restore',
    this.more = 'Tool window options',
  });

  /// Names a stripe.
  final String Function(DockEdge edge) stripe;

  /// The "Move to" submenu's title.
  final String moveTo;

  /// Names an edge in the "Move to" submenu.
  final String Function(DockEdge edge) edge;

  /// The hide button.
  final String hide;

  /// The maximize button.
  final String maximize;

  /// The restore button.
  final String restore;

  /// The header's menu button.
  final String more;

  @override
  bool operator ==(Object other) =>
      other is DockStrings &&
      other.stripe == stripe &&
      other.moveTo == moveTo &&
      other.edge == edge &&
      other.hide == hide &&
      other.maximize == maximize &&
      other.restore == restore &&
      other.more == more;

  @override
  int get hashCode =>
      Object.hash(stripe, moveTo, edge, hide, maximize, restore, more);
}

String _defaultStripe(DockEdge edge) => '${_name(edge)} tool windows';
String _defaultEdge(DockEdge edge) => _name(edge);
String _name(DockEdge edge) => switch (edge) {
  DockEdge.left => 'Left',
  DockEdge.right => 'Right',
  DockEdge.bottom => 'Bottom',
};

/// Overrides for dock layouts; `null` keeps the default.
@immutable
class CamoDockTheme {
  /// Creates overrides.
  const CamoDockTheme({this.stripeSize, this.minDock, this.strings});

  /// The stripe's thickness.
  final double? stripeSize;

  /// The smallest a dock or the center gets.
  final double? minDock;

  /// The words.
  final DockStrings? strings;

  @override
  bool operator ==(Object other) =>
      other is CamoDockTheme &&
      other.stripeSize == stripeSize &&
      other.minDock == minDock &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(stripeSize, minDock, strings);
}
