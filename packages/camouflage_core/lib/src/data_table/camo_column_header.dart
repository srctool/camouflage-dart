part of 'camo_data_table.dart';

const double _keyStep = 16;
const double _grabWidth = 8;
const double _lineWidth = 2;
const double _draggedOpacity = 0.6;
const int _fitRows = 200;
const double _sortRoom = 24;

// What a header needs to know about its table: every column, the visible ones, the rows and the state.
class _ColumnContext<T> {
  const _ColumnContext(this.all, this.shown, this.rows, this.state);

  final List<CamoColumn<T>> all;
  final List<CamoColumn<T>> shown;
  final List<T> rows;
  final CamoColumnState state;
}

// A header cell of a table with a columnState: the cell's sort press, a resize edge (drag; a double-tap fits the
// content), a drag and Alt+arrows to reorder, Ctrl+arrows to resize, a context menu to hide columns, and the same
// as screen reader actions.
class _ColumnHeader<T> extends StatefulWidget {
  const _ColumnHeader({
    super.key,
    required this.column,
    required this.index,
    required this.table,
    required this.sort,
    required this.onSortChanged,
  });

  final CamoColumn<T> column;
  final int index;
  final _ColumnContext<T> table;
  final TableSort? sort;
  final ValueChanged<TableSort>? onSortChanged;

  @override
  State<_ColumnHeader<T>> createState() => _ColumnHeaderState<T>();
}

class _ColumnHeaderState<T> extends State<_ColumnHeader<T>> {
  final _focus = FocusNode(debugLabel: 'column header');
  bool _dragging = false;
  double _offset = 0;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  CamoColumnState get _state => widget.table.state;
  Object get _id => widget.column.id;
  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  void _widen(double by) => _state.resize(
    _id,
    (_state._measured[_id] ?? 0) + by,
    min: widget.column.minWidth,
  );

  void _move(int step) => _state.moveBy(_id, _rtl ? -step : step);

  // A double-tap on the edge: the width of the widest of the first rows' text, or the column's own width.
  void _fit() {
    final texts = widget.column.text;
    if (texts == null) {
      _state.resizeToOwn(_id);
      return;
    }
    final skin = Camouflage.skinOf(context, component: 'CamoDataTable');
    final theme = Camouflage.themeOf(context, component: 'CamoDataTable');
    final style = skin.dataTable
        .defaults(theme)
        .merge(theme.components.dataTable);
    double measure(String text, TextStyle style) => (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout()).width;
    final cells = widget.table.rows
        .take(_fitRows)
        .map((r) => measure(texts(r), style.cellStyle));
    final label = measure(widget.column.header, style.headerStyle);
    final widest = cells.fold<double>(label + _sortRoom, math.max);
    _state.resize(
      _id,
      widest + style.cellPadding * 2,
      min: widget.column.minWidth,
    );
  }

  // Alt+Left and Alt+Right move the column, Ctrl+Left and Ctrl+Right resize it; arrows keep their visual meaning.
  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final right = event.logicalKey == LogicalKeyboardKey.arrowRight;
    final left = event.logicalKey == LogicalKeyboardKey.arrowLeft;
    if (!right && !left) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    if (keys.isAltPressed && widget.column.reorderable) {
      _move(right ? 1 : -1);
      return KeyEventResult.handled;
    }
    if (keys.isControlPressed && widget.column.resizable) {
      // The trailing edge is on the right, or on the left in right-to-left.
      _widen(right != _rtl ? _keyStep : -_keyStep);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _dragUpdate(DragUpdateDetails d) {
    _offset += d.delta.dx * (_rtl ? -1 : 1);
    final widths = [
      for (final c in widget.table.shown) _state._measured[c.id] ?? 0,
    ];
    _state._dropTarget.value = _dropIndex(widths, widget.index, _offset);
  }

  void _dragEnd() {
    final target = _state._dropTarget.value;
    if (target >= 0 && target != widget.index) {
      final over = widget.table.shown[target];
      _state.move(_id, _state._order.indexOf(over.id));
    }
    _finishDrag();
  }

  void _finishDrag() {
    _state._dropTarget.value = -1;
    setState(() => _dragging = false);
  }

  Map<CustomSemanticsAction, VoidCallback> _actions() {
    final c = widget.column;
    return {
      if (c.resizable) ...{
        const CustomSemanticsAction(label: 'Widen column'): () =>
            _widen(_keyStep),
        const CustomSemanticsAction(label: 'Narrow column'): () =>
            _widen(-_keyStep),
      },
      if (c.reorderable) ...{
        const CustomSemanticsAction(label: 'Move column earlier'): () =>
            _state.moveBy(_id, -1),
        const CustomSemanticsAction(label: 'Move column later'): () =>
            _state.moveBy(_id, 1),
      },
      if (c.hideable)
        const CustomSemanticsAction(label: 'Hide column'): () =>
            _state.hide(_id),
    };
  }

  // The header's context menu: hide it, choose the visible columns, reset the widths.
  List<CamoMenuEntry> _menu() {
    final table = widget.table;
    return [
      if (widget.column.hideable && table.shown.length > 1)
        CamoMenuItem(text: 'Hide column', onPressed: () => _state.hide(_id)),
      CamoMenuSubmenu(
        text: 'Columns',
        items: [
          for (final other in table.all)
            CamoMenuItem(
              text: other.header,
              checked: !_state._hidden.contains(other.id),
              enabled: other.hideable || _state._hidden.contains(other.id),
              onPressed: () => _state._hidden.contains(other.id)
                  ? _state.show(other.id)
                  : _state.hide(other.id),
            ),
        ],
      ),
      CamoMenuItem(
        text: 'Reset widths',
        enabled: _state._widths.isNotEmpty,
        onPressed: _state.resetWidths,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoDataTable');
    final column = widget.column;
    // A sortable header's own focus node takes the keys; the others are focusable here.
    Widget header = Focus(
      focusNode: _focus,
      canRequestFocus: !column.sortable,
      skipTraversal: column.sortable,
      onKeyEvent: _key,
      child: Semantics(
        customSemanticsActions: _actions(),
        child: _HeaderCell<T>(
          column: column,
          sort: widget.sort,
          onSortChanged: widget.onSortChanged,
        ),
      ),
    );
    if (column.reorderable) {
      header = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => setState(() {
          _dragging = true;
          _offset = 0;
        }),
        onHorizontalDragUpdate: _dragUpdate,
        onHorizontalDragEnd: (_) => _dragEnd(),
        onHorizontalDragCancel: _finishDrag,
        child: header,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        _state._measured[_id] = constraints.maxWidth;
        return Opacity(
          opacity: _dragging ? _draggedOpacity : 1,
          child: CamoContextMenuArea(
            items: _menu(),
            child: Stack(
              children: [
                header,
                if (column.resizable)
                  PositionedDirectional(
                    end: 0,
                    top: 0,
                    bottom: 0,
                    width: _grabWidth,
                    child: _ResizeEdge(
                      onDrag: (dx) => _widen(dx * (_rtl ? -1 : 1)),
                      onFit: _fit,
                    ),
                  ),
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: _lineWidth,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _state._dropTarget,
                    builder: (context, target, _) => target == widget.index
                        ? ColoredBox(color: theme.colors.primary)
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// The edge of a header that is dragged to resize; a double-tap fits the content.
class _ResizeEdge extends StatefulWidget {
  const _ResizeEdge({required this.onDrag, required this.onFit});

  final ValueChanged<double> onDrag;
  final VoidCallback onFit;

  @override
  State<_ResizeEdge> createState() => _ResizeEdgeState();
}

class _ResizeEdgeState extends State<_ResizeEdge> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoDataTable');
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _dragging = true),
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onHorizontalDragCancel: () => setState(() => _dragging = false),
        onDoubleTap: widget.onFit,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _hovered || _dragging
              ? SizedBox(
                  width: _lineWidth,
                  child: ColoredBox(
                    color: _dragging
                        ? theme.colors.primary
                        : theme.colors.outline,
                    child: const SizedBox.expand(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
