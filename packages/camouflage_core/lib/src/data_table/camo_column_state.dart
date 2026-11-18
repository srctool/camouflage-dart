part of 'camo_data_table.dart';

/// The columns' layout as plain data the app can save (Camouflage stores nothing itself) and hand back to
/// [CamoColumnState.apply].
@immutable
class CamoColumnSnapshot {
  /// Creates a snapshot.
  const CamoColumnSnapshot({
    required this.order,
    required this.widths,
    required this.hidden,
  });

  /// Every column id, in the order shown.
  final List<Object> order;

  /// The widths the user set, in logical pixels.
  final Map<Object, double> widths;

  /// The hidden columns.
  final Set<Object> hidden;
}

/// The layout of a [CamoDataTable]'s columns, owned by the app: their [order], the [widths] the user dragged them
/// to (a column without one keeps its own width) and which are [hidden]. [columns] are the ids of the table's
/// columns in their first order. Hand it to `CamoDataTable(columnState: …)`; save [snapshot] to restore the
/// layout after a restart.
class CamoColumnState extends ChangeNotifier {
  /// Creates a state for the columns with these ids, in their first order.
  CamoColumnState(List<Object> columns) : _initial = columns.toSet().toList() {
    _order = _initial;
  }

  /// The narrowest a column may be when it doesn't say.
  static const double defaultMinWidth = 48;

  final List<Object> _initial;
  late List<Object> _order;
  Map<Object, double> _widths = const {};
  Set<Object> _hidden = const {};

  // The widths the headers last measured, for the keyboard and the drop target (no rebuild).
  final Map<Object, double> _measured = {};

  // Where a header drag would drop the column: an index among the visible columns, -1 when none.
  final ValueNotifier<int> _dropTarget = ValueNotifier(-1);

  /// Every column's id in the order shown (hidden ones keep their place).
  List<Object> get order => List.unmodifiable(_order);

  /// The widths set by the user.
  Map<Object, double> get widths => Map.unmodifiable(_widths);

  /// The hidden columns.
  Set<Object> get hidden => Set.unmodifiable(_hidden);

  /// Sets [column]'s width to [to], at least [min].
  void resize(
    Object column,
    double to, {
    double min = CamoColumnState.defaultMinWidth,
  }) {
    if (!_order.contains(column)) return;
    _widths = {..._widths, column: math.max(to, min)};
    notifyListeners();
  }

  /// Moves [column] to position [to] among all columns.
  void move(Object column, int to) {
    final from = _order.indexOf(column);
    if (from < 0) return;
    final next = [..._order]..removeAt(from);
    next.insert(to.clamp(0, next.length), column);
    _order = next;
    notifyListeners();
  }

  /// Moves [column] one step toward the start (`-1`) or the end (`1`) among the visible columns.
  void moveBy(Object column, int step) {
    final visible = [
      for (final id in _order)
        if (!_hidden.contains(id)) id,
    ];
    final at = visible.indexOf(column);
    final to = at + step;
    if (at < 0 || to < 0 || to >= visible.length) return;
    move(column, _order.indexOf(visible[to]));
  }

  /// Hides [column]; the last visible column stays.
  void hide(Object column) {
    final visible = _order.where((id) => !_hidden.contains(id)).length;
    if (!_order.contains(column) || _hidden.contains(column) || visible <= 1) {
      return;
    }
    _hidden = {..._hidden, column};
    notifyListeners();
  }

  /// Shows a hidden [column].
  void show(Object column) {
    if (!_hidden.contains(column)) return;
    _hidden = {..._hidden}..remove(column);
    notifyListeners();
  }

  /// Forgets the width the user set for [column] (it keeps its own again).
  void resizeToOwn(Object column) {
    if (!_widths.containsKey(column)) return;
    _widths = {..._widths}..remove(column);
    notifyListeners();
  }

  /// Forgets every width the user set (each column keeps its own again).
  void resetWidths() {
    if (_widths.isEmpty) return;
    _widths = const {};
    notifyListeners();
  }

  /// Back to the first order and the columns' own widths, with nothing hidden.
  void reset() {
    _order = _initial;
    _widths = const {};
    _hidden = const {};
    notifyListeners();
  }

  /// The layout as plain data to save.
  CamoColumnSnapshot snapshot() =>
      CamoColumnSnapshot(order: order, widths: widths, hidden: hidden);

  /// Restores a saved layout; ids the table does not have are ignored and new columns go to the end.
  void apply(CamoColumnSnapshot snapshot) {
    final known = _initial.toSet();
    final saved = snapshot.order.where(known.contains).toSet().toList();
    _order = [...saved, ..._initial.where((id) => !saved.contains(id))];
    _widths = {
      for (final e in snapshot.widths.entries)
        if (known.contains(e.key)) e.key: e.value,
    };
    final hidden = snapshot.hidden.where(known.contains).toSet();
    _hidden = hidden.length >= known.length ? const {} : hidden;
    notifyListeners();
  }

  @override
  void dispose() {
    _dropTarget.dispose();
    super.dispose();
  }
}

// The table's columns in the state's order, minus the hidden ones, each with the width the user set.
List<CamoColumn<T>> _shown<T>(
  CamoColumnState state,
  List<CamoColumn<T>> columns,
) {
  final byId = {for (final c in columns) c.id: c};
  final ids = [
    for (final id in state._order)
      if (byId.containsKey(id)) id,
    for (final c in columns)
      if (!state._order.contains(c.id)) c.id,
  ];
  return [
    for (final id in ids)
      if (!state._hidden.contains(id))
        state._widths[id] == null
            ? byId[id]!
            : byId[id]!._withWidth(ColumnWidth.fixed(state._widths[id]!)),
  ];
}

// Where a dragged header of width widths[from], moved by [offset] pixels, would drop: the index among the visible
// columns whose span holds the dragged header's center.
int _dropIndex(List<double> widths, int from, double offset) {
  if (from < 0 || from >= widths.length) return from;
  final center =
      widths.take(from).fold<double>(0, (a, b) => a + b) +
      widths[from] / 2 +
      offset;
  var edge = 0.0;
  for (var i = 0; i < widths.length; i++) {
    edge += widths[i];
    if (center < edge) return i;
  }
  return widths.length - 1;
}
