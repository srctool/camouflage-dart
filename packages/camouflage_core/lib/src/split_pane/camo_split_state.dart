part of 'camo_split_pane.dart';

/// A split's layout as plain data the app can save (Camouflage stores nothing itself) and hand back to
/// [CamoSplitState.apply].
@immutable
class CamoSplitSnapshot {
  /// Creates a snapshot.
  const CamoSplitSnapshot({required this.fractions, required this.collapsed});

  /// Each pane's share of the container.
  final List<double> fractions;

  /// The collapsed panes.
  final Set<int> collapsed;
}

/// One pane's size limits in logical pixels; [max] is infinite when the pane has none.
class _Limits {
  const _Limits(this.min, [this.max = double.infinity]);

  final double min;
  final double max;
}

const _clampRounds = 8;
const _slack = 0.5;

// The split pane's layout rule as pure functions: fractions in, pixel sizes out, and the effect of moving one
// divider. Collapsed panes have no size; the visible panes share the container by their fractions.

// The visible panes' sizes: each pane's share of [total] by its fraction, clamped to its limits, the excess or the
// shortfall going to the panes that are not pinned. A container smaller than the sum of the minimums shrinks every
// pane in proportion, so nothing is cut off.
List<double> _layoutSizes(
  List<double> fractions,
  Set<int> collapsed,
  double total,
  List<_Limits> limits,
) {
  final sizes = List<double>.filled(fractions.length, 0);
  final visible = [
    for (var i = 0; i < fractions.length; i++)
      if (!collapsed.contains(i)) i,
  ];
  if (visible.isEmpty || total <= 0) return sizes;
  final share = visible.fold<double>(0, (a, i) => a + fractions[i]);
  final minimums = visible.fold<double>(0, (a, i) => a + limits[i].min);
  if (minimums >= total) {
    for (final i in visible) {
      sizes[i] = minimums > 0
          ? limits[i].min / minimums * total
          : total / visible.length;
    }
    return sizes;
  }
  for (final i in visible) {
    sizes[i] = fractions[i] / share * total;
  }
  final pinned = List<bool>.filled(fractions.length, false);
  for (var round = 0; round < _clampRounds; round++) {
    for (final i in visible) {
      final clamped = sizes[i]
          .clamp(limits[i].min, math.max(limits[i].min, limits[i].max))
          .toDouble();
      if (clamped != sizes[i]) pinned[i] = true;
      sizes[i] = clamped;
    }
    final residual = total - visible.fold<double>(0, (a, i) => a + sizes[i]);
    if (residual.abs() < _slack) return sizes;
    final free = visible.where((i) => !pinned[i]).toList();
    if (free.isEmpty) {
      sizes[visible.last] += residual;
      return sizes;
    }
    final freeTotal = free.fold<double>(0, (a, i) => a + sizes[i]);
    for (final i in free) {
      sizes[i] +=
          residual * (freeTotal > 0 ? sizes[i] / freeTotal : 1 / free.length);
    }
  }
  return sizes;
}

// The result of moving a divider: the new fractions, and the pane it collapsed (or null).
class _Resized {
  const _Resized(this.fractions, this.collapsed);

  final List<double> fractions;
  final int? collapsed;
}

// Moves [divider] (between panes `divider` and `divider + 1`) by [delta]: space moves between those two panes only,
// within both panes' limits. A pane in [collapsible] dragged below half its minimum collapses instead. Nothing
// moves when a neighbour is collapsed.
_Resized _resizeSplit(
  List<double> fractions,
  Set<int> collapsed,
  int divider,
  double delta,
  double total,
  List<_Limits> limits,
  Set<int> collapsible,
) {
  final a = divider;
  final b = divider + 1;
  if (collapsed.contains(a) || collapsed.contains(b) || total <= 0) {
    return _Resized(fractions, null);
  }
  final sizes = _layoutSizes(fractions, collapsed, total, limits);
  final pair = sizes[a] + sizes[b];
  final wanted = sizes[a] + delta;
  final collapseA = collapsible.contains(a) && wanted < limits[a].min / 2;
  final collapseB =
      collapsible.contains(b) && pair - wanted < limits[b].min / 2;
  if (collapseA || collapseB) return _Resized(fractions, collapseA ? a : b);
  final low = math.max(limits[a].min, pair - limits[b].max);
  final high = math.min(limits[a].max, pair - limits[b].min);
  final newA = wanted.clamp(low, math.max(low, high)).toDouble();
  final share = [
    for (var i = 0; i < fractions.length; i++)
      if (!collapsed.contains(i)) fractions[i],
  ].fold<double>(0, (x, y) => x + y);
  final next = [...fractions];
  next[a] = newA / total * share;
  next[b] = (pair - newA) / total * share;
  return _Resized(next, null);
}

List<double> _normalized(List<double> fractions) {
  if (fractions.length < 2) {
    throw ArgumentError('CamoSplitState: a split has two or more panes.');
  }
  if (fractions.any((f) => f <= 0)) {
    throw ArgumentError(
      "CamoSplitState: every pane's fraction must be positive.",
    );
  }
  final sum = fractions.fold<double>(0, (a, f) => a + f);
  return [for (final f in fractions) f / sum];
}

/// The layout of a [CamoSplitPane], owned by the app: each pane's size as a **fraction** of the container (so a saved
/// layout restores on a different window size) and which panes are collapsed. [initial] are the fractions of the
/// panes (they are scaled to sum to 1). The pane limits (`minSize`, `maxSize`) clamp what the layout draws and what
/// [resize] does; they reach the state when the pane has been laid out.
class CamoSplitState extends ChangeNotifier {
  /// Creates a state for [initial] fractions, one per pane.
  CamoSplitState(List<double> initial)
    : _start = _normalized(initial),
      _fractions = _normalized(initial);

  final List<double> _start;
  List<double> _fractions;
  Set<int> _collapsed = const {};

  // What the layout last measured: the container's length and each pane's limits.
  double _total = 0;
  List<_Limits> _limits = const [];
  Set<int> _collapsible = const {};

  /// Each pane's share of the container, summing to 1 across all panes.
  List<double> get fractions => List.unmodifiable(_fractions);

  /// The collapsed panes: they leave the tree, and their divider stays so they can be restored.
  Set<int> get collapsed => Set.unmodifiable(_collapsed);

  /// Moves [divider] (between panes `divider` and `divider + 1`) by [delta] pixels, within both panes' limits.
  void resize(int divider, double delta) =>
      _resize(divider, delta, allowCollapse: true);

  // [allowCollapse] false clamps at the minimum (Home and End never collapse a pane).
  void _resize(int divider, double delta, {required bool allowCollapse}) {
    if (divider < 0 ||
        divider >= _fractions.length - 1 ||
        _limits.length != _fractions.length) {
      return;
    }
    final result = _resizeSplit(
      _fractions,
      _collapsed,
      divider,
      delta,
      _total,
      _limits,
      allowCollapse ? _collapsible : const {},
    );
    if (result.collapsed != null) {
      collapse(result.collapsed!);
    } else {
      _fractions = result.fractions;
      notifyListeners();
    }
  }

  /// Collapses [pane]; it restores to its previous fraction. The last visible pane cannot collapse.
  void collapse(int pane) {
    if (pane < 0 || pane >= _fractions.length || _collapsed.contains(pane)) {
      return;
    }
    if (_collapsed.length >= _fractions.length - 1) return;
    _collapsed = {..._collapsed, pane};
    notifyListeners();
  }

  /// Brings a collapsed [pane] back at its previous fraction.
  void restore(int pane) {
    if (!_collapsed.contains(pane)) return;
    _collapsed = {..._collapsed}..remove(pane);
    notifyListeners();
  }

  /// Back to the initial fractions, with nothing collapsed.
  void reset() {
    _fractions = [..._start];
    _collapsed = const {};
    notifyListeners();
  }

  /// Puts the two panes beside [divider] back to their initial sizes, keeping the space they share.
  void resetDivider(int divider) {
    if (divider < 0 || divider >= _fractions.length - 1) return;
    final shared = _fractions[divider] + _fractions[divider + 1];
    final initial = _start[divider] + _start[divider + 1];
    if (initial <= 0) return;
    _fractions = [..._fractions];
    _fractions[divider] = _start[divider] / initial * shared;
    _fractions[divider + 1] = _start[divider + 1] / initial * shared;
    _collapsed = {..._collapsed}
      ..remove(divider)
      ..remove(divider + 1);
    notifyListeners();
  }

  /// The layout as plain data to save.
  CamoSplitSnapshot snapshot() =>
      CamoSplitSnapshot(fractions: fractions, collapsed: collapsed);

  /// Restores a saved layout; one for a different number of panes is ignored.
  void apply(CamoSplitSnapshot snapshot) {
    if (snapshot.fractions.length != _start.length) return;
    _fractions = _normalized(snapshot.fractions);
    _collapsed = {
      for (final i in snapshot.collapsed)
        if (i >= 0 && i < _start.length) i,
    };
    notifyListeners();
  }
}
