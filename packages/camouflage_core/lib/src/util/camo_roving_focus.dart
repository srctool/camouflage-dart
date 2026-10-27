import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One Tab stop for a group of items (radios, segments, tabs): Tab enters on the focused, selected, last focused
/// or first enabled item and leaves with the next Tab. The arrow keys move between the enabled items, wrapping
/// around, and select the item they land on. Left and Right follow the reading direction. Give each item a
/// [CamoRovingFocusItem].
class CamoRovingFocus extends StatefulWidget {
  /// Creates the group around [child].
  const CamoRovingFocus({super.key, required this.child});

  /// The items, anywhere below.
  final Widget child;

  @override
  State<CamoRovingFocus> createState() => _CamoRovingFocusState();
}

class _CamoRovingFocusState extends State<CamoRovingFocus> {
  final Map<int, _CamoRovingFocusItemState> _items = {};
  int? _lastFocused;

  List<int> get _enabled =>
      (_items.entries
          .where((e) => e.value.widget.enabled)
          .map((e) => e.key)
          .toList()
        ..sort());

  bool isTabStop(int index) {
    final enabled = _enabled;
    int? stop;
    for (final i in enabled) {
      if (_items[i]!._node.hasFocus) stop = i;
    }
    stop ??= enabled.where((i) => _items[i]!.widget.selected).firstOrNull;
    stop ??= enabled.contains(_lastFocused) ? _lastFocused : null;
    stop ??= enabled.firstOrNull;
    return stop == index;
  }

  void focused(int index) => _lastFocused = index;

  bool move(int from, int step) {
    final enabled = _enabled;
    final at = enabled.indexOf(from);
    if (enabled.length < 2 || at < 0) return false;
    final target = _items[enabled[(at + step) % enabled.length]]!;
    _lastFocused = target.widget.index;
    target.widget.onSelect();
    target._node.requestFocus();
    return true;
  }

  @override
  Widget build(BuildContext context) => _RovingScope(this, child: widget.child);
}

class _RovingScope extends InheritedWidget {
  const _RovingScope(this.state, {required super.child});

  final _CamoRovingFocusState state;

  @override
  bool updateShouldNotify(_RovingScope oldWidget) => state != oldWidget.state;
}

/// Item [index] of the nearest [CamoRovingFocus]: [builder] gets the focus node to give the item's behavior.
/// The node takes part in Tab traversal only as the group's Tab stop; arrow keys on it move and [onSelect].
class CamoRovingFocusItem extends StatefulWidget {
  /// Creates an item.
  const CamoRovingFocusItem({
    super.key,
    required this.index,
    required this.enabled,
    required this.selected,
    required this.onSelect,
    required this.builder,
  });

  /// The item's place in the group.
  final int index;

  /// Disabled items are skipped by the arrows.
  final bool enabled;

  /// The selected item is the Tab stop while focus is outside the group.
  final bool selected;

  /// Called when an arrow key lands on this item.
  final VoidCallback onSelect;

  /// Builds the item with its focus node.
  final Widget Function(BuildContext context, FocusNode focusNode) builder;

  @override
  State<CamoRovingFocusItem> createState() => _CamoRovingFocusItemState();
}

class _CamoRovingFocusItemState extends State<CamoRovingFocusItem> {
  _CamoRovingFocusState? _group;
  late final _RovingNode _node = _RovingNode(this)..addListener(_focusChanged);

  void _focusChanged() {
    if (_node.hasFocus) _group?.focused(widget.index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final group = context
        .dependOnInheritedWidgetOfExactType<_RovingScope>()
        ?.state;
    assert(
      group != null,
      'CamoRovingFocusItem must be inside a CamoRovingFocus.',
    );
    if (group != _group) {
      _group?._items.remove(widget.index);
      _group = group;
    }
    _group?._items[widget.index] = this;
  }

  @override
  void didUpdateWidget(CamoRovingFocusItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (_group?._items[oldWidget.index] == this) {
        _group?._items.remove(oldWidget.index);
      }
      _group?._items[widget.index] = this;
    }
  }

  @override
  void dispose() {
    if (_group?._items[widget.index] == this) {
      _group?._items.remove(widget.index);
    }
    _node.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final int step;
    if (key == LogicalKeyboardKey.arrowDown) {
      step = 1;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      step = -1;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      step = rtl ? -1 : 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      step = rtl ? 1 : -1;
    } else {
      return KeyEventResult.ignored;
    }
    return (_group?.move(widget.index, step) ?? false)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _node);
}

// Skips Tab traversal unless it's the group's Tab stop, decided when traversal asks.
class _RovingNode extends FocusNode {
  _RovingNode(this._item) : super(debugLabel: 'CamoRovingFocusItem');

  final _CamoRovingFocusItemState _item;

  @override
  bool get skipTraversal =>
      !(_item._group?.isTabStop(_item.widget.index) ?? true);

  @override
  FocusOnKeyEventCallback? get onKeyEvent =>
      (node, event) => _item._onKey(event);
}
