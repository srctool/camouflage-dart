import 'package:flutter/widgets.dart';

import '../checkbox/camo_checkbox.dart';
import '../icon/camo_icon.dart';
import '../progress/camo_progress.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';

/// Every color a data table uses.
@immutable
class TableColors {
  /// Creates TableColors.
  const TableColors({
    required this.container,
    required this.header,
    required this.row,
    required this.stripedRow,
    required this.selectedRow,
    required this.divider,
    required this.text,
    required this.headerText,
  });

  /// The table's fill.
  final Color container;

  /// The header row.
  final Color header;

  /// A body row.
  final Color row;

  /// An alternate row.
  final Color stripedRow;

  /// A selected row and a hovered sortable header.
  final Color selectedRow;

  /// Lines.
  final Color divider;

  /// Cells.
  final Color text;

  /// Header labels.
  final Color headerText;

  @override
  bool operator ==(Object other) =>
      other is TableColors &&
      other.container == container &&
      other.header == header &&
      other.row == row &&
      other.stripedRow == stripedRow &&
      other.selectedRow == selectedRow &&
      other.divider == divider &&
      other.text == text &&
      other.headerText == headerText;

  @override
  int get hashCode => Object.hash(
    container,
    header,
    row,
    stripedRow,
    selectedRow,
    divider,
    text,
    headerText,
  );
}

/// Overrides for data tables. `null` keeps the skin's default.
@immutable
class CamoTableTheme {
  /// Creates overrides.
  const CamoTableTheme({
    this.headerHeight,
    this.rowHeight,
    this.cellPadding,
    this.striped,
    this.dividers,
    this.headerStyle,
    this.cellStyle,
    this.sortIcon,
    this.colors,
  });

  /// The header row.
  final double? headerHeight;

  /// A body row (at least; cells may grow it).
  final double? rowHeight;

  /// Start and end of a cell.
  final double? cellPadding;

  /// Alternate row fill.
  final bool? striped;

  /// Lines between rows.
  final bool? dividers;

  /// Header labels.
  final TextStyle? headerStyle;

  /// The text of cells that show text.
  final TextStyle? cellStyle;

  /// The sort arrow (up; it turns for descending).
  final IconSource? sortIcon;

  /// Every color it uses.
  final TableColors? colors;

  /// A copy with the given fields replaced.
  CamoTableTheme copyWith({
    double? headerHeight,
    double? rowHeight,
    double? cellPadding,
    bool? striped,
    bool? dividers,
    TextStyle? headerStyle,
    TextStyle? cellStyle,
    IconSource? sortIcon,
    TableColors? colors,
  }) => CamoTableTheme(
    headerHeight: headerHeight ?? this.headerHeight,
    rowHeight: rowHeight ?? this.rowHeight,
    cellPadding: cellPadding ?? this.cellPadding,
    striped: striped ?? this.striped,
    dividers: dividers ?? this.dividers,
    headerStyle: headerStyle ?? this.headerStyle,
    cellStyle: cellStyle ?? this.cellStyle,
    sortIcon: sortIcon ?? this.sortIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoTableTheme &&
      other.headerHeight == headerHeight &&
      other.rowHeight == rowHeight &&
      other.cellPadding == cellPadding &&
      other.striped == striped &&
      other.dividers == dividers &&
      other.headerStyle == headerStyle &&
      other.cellStyle == cellStyle &&
      other.sortIcon == sortIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    headerHeight,
    rowHeight,
    cellPadding,
    striped,
    dividers,
    headerStyle,
    cellStyle,
    sortIcon,
    colors,
  );
}

/// The resolved data table style: every field set.
@immutable
class CamoTableStyle {
  /// Creates a style.
  const CamoTableStyle({
    required this.headerHeight,
    required this.rowHeight,
    required this.cellPadding,
    required this.striped,
    required this.dividers,
    required this.headerStyle,
    required this.cellStyle,
    required this.sortIcon,
    required this.colors,
  });

  /// The header row.
  final double headerHeight;

  /// A body row (at least; cells may grow it).
  final double rowHeight;

  /// Start and end of a cell.
  final double cellPadding;

  /// Alternate row fill.
  final bool striped;

  /// Lines between rows.
  final bool dividers;

  /// Header labels.
  final TextStyle headerStyle;

  /// The text of cells that show text.
  final TextStyle cellStyle;

  /// The sort arrow (up; it turns for descending).
  final IconSource sortIcon;

  /// Every color it uses.
  final TableColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoTableStyle merge(CamoTableTheme? o) => o == null
      ? this
      : CamoTableStyle(
          headerHeight: o.headerHeight ?? headerHeight,
          rowHeight: o.rowHeight ?? rowHeight,
          cellPadding: o.cellPadding ?? cellPadding,
          striped: o.striped ?? striped,
          dividers: o.dividers ?? dividers,
          headerStyle: o.headerStyle ?? headerStyle,
          cellStyle: o.cellStyle ?? cellStyle,
          sortIcon: o.sortIcon ?? sortIcon,
          colors: o.colors ?? colors,
        );
}

/// How wide a column is: a fixed width, or a share of what the fixed columns leave.
@immutable
sealed class ColumnWidth {
  const ColumnWidth();

  /// Exactly [width].
  const factory ColumnWidth.fixed(double width) = FixedColumnWidth;

  /// [weight] parts of the remaining width.
  const factory ColumnWidth.weight([double weight]) = WeightColumnWidth;
}

/// A fixed column width.
class FixedColumnWidth extends ColumnWidth {
  /// Creates the width.
  const FixedColumnWidth(this.width);

  /// Logical pixels.
  final double width;
}

/// A weighted column width.
class WeightColumnWidth extends ColumnWidth {
  /// Creates the width.
  const WeightColumnWidth([this.weight = 1]);

  /// Parts of the remaining width.
  final double weight;
}

/// How a column's content lines up.
enum ColumnAlign {
  /// At the start.
  start,

  /// Centered.
  center,

  /// At the end (numbers).
  end,
}

/// A column: its [header], [width], whether it can be sorted, and how to draw its [cell] for a row.
@immutable
class CamoColumn<T> {
  /// Creates a column.
  const CamoColumn({
    required this.id,
    required this.header,
    required this.cell,
    this.width = const ColumnWidth.weight(),
    this.align = ColumnAlign.start,
    this.sortable = false,
  });

  /// Identifies the column; [TableSort] refers to it.
  final Object id;

  /// The header text.
  final String header;

  /// Draws the cell for a row.
  final Widget Function(BuildContext context, T row) cell;

  /// The column's width.
  final ColumnWidth width;

  /// How its content lines up.
  final ColumnAlign align;

  /// Whether a click on its header sorts by it.
  final bool sortable;
}

/// The sort the table shows: by the column with [columnId], ascending or not. The app sorts the rows.
@immutable
class TableSort {
  /// Creates a sort.
  const TableSort(this.columnId, {this.ascending = true});

  /// The column sorted by.
  final Object columnId;

  /// Whether the order is ascending.
  final bool ascending;

  @override
  bool operator ==(Object other) =>
      other is TableSort &&
      other.columnId == columnId &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(columnId, ascending);
}

/// What the container renderer draws: the frame around the header and the body.
@immutable
class TableState {
  /// Creates the state.
  const TableState({
    required this.columnCount,
    required this.rowCount,
    required this.selectable,
    required this.loading,
  });

  /// How many columns.
  final int columnCount;

  /// How many rows.
  final int rowCount;

  /// Whether rows can be selected.
  final bool selectable;

  /// Whether rows are loading.
  final bool loading;
}

/// What a header cell draws: [sorted] is `null` unless the table is sorted by this column.
@immutable
class HeaderCellState {
  /// Creates the state.
  const HeaderCellState({
    required this.sortable,
    required this.sorted,
    required this.align,
    required this.interaction,
    required this.controller,
  });

  /// Whether it can be pressed to sort.
  final bool sortable;

  /// `true` ascending, `false` descending, `null` not sorted by this column.
  final bool? sorted;

  /// How the label lines up.
  final ColumnAlign align;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// What a body row draws: [selected] rows and [striped] alternate rows get their fills; show hover and focus.
@immutable
class RowState {
  /// Creates the state.
  const RowState({
    required this.index,
    required this.selected,
    required this.striped,
    required this.interaction,
    required this.controller,
  });

  /// The row, zero-based.
  final int index;

  /// Whether it is selected.
  final bool selected;

  /// Whether it is an alternate row.
  final bool striped;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws data tables in parts. Core sizes the columns (the same widths in the header and every row), so the cells
/// and header cells the renderer draws are the contents of those columns.
abstract interface class CamoDataTableRenderer {
  /// The complete data table style for [theme].
  CamoTableStyle defaults(CamoTheme theme);

  /// The frame around the header and the body.
  Widget renderContainer(
    BuildContext context,
    TableState state,
    CamoTheme theme,
    CamoTableStyle style,
    Widget child,
  );

  /// The header row around [cells].
  Widget renderHeaderRow(
    BuildContext context,
    CamoTheme theme,
    CamoTableStyle style,
    List<Widget> cells,
  );

  /// A header cell with [label] and the sort arrow.
  Widget renderHeaderCell(
    BuildContext context,
    HeaderCellState state,
    String label,
    CamoTheme theme,
    CamoTableStyle style,
  );

  /// A body row around [cells].
  Widget renderRow(
    BuildContext context,
    RowState state,
    CamoTheme theme,
    CamoTableStyle style,
    List<Widget> cells,
  );

  /// A cell's frame (padding and alignment) around the app's [child].
  Widget renderCell(
    BuildContext context,
    ColumnAlign align,
    CamoTheme theme,
    CamoTableStyle style,
    Widget child,
  );
}

const double _selectColumn = 48;

/// Rows of records in columns, with sorting, selection and an optional footer. The app owns the data, the [sort]
/// (and does the sorting) and the [selection] (a set of [rowKey]s; `null` means rows can't be selected). A press
/// on a header of a sortable column calls [onSortChanged]; a press or Space on a row toggles its selection (it
/// calls [onRowPressed] instead when that is set); Up and Down move between rows. [semanticLabel] names the table.
/// Rows are lazy and the header stays above them: give the table a height.
class CamoDataTable<T> extends StatelessWidget {
  /// Creates a data table.
  const CamoDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowKey,
    required this.semanticLabel,
    this.sort,
    this.onSortChanged,
    this.selection,
    this.onSelectionChanged,
    this.onRowPressed,
    this.empty,
    this.loading = false,
    this.footer,
  });

  /// The columns.
  final List<CamoColumn<T>> columns;

  /// The rows, already sorted.
  final List<T> rows;

  /// A row's stable key.
  final Object Function(T row) rowKey;

  /// Names the table.
  final String semanticLabel;

  /// The sort to show.
  final TableSort? sort;

  /// Called when a sortable header is pressed.
  final ValueChanged<TableSort>? onSortChanged;

  /// The selected row keys; `null` makes rows not selectable.
  final Set<Object>? selection;

  /// Called with the new selection.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Called when a row is pressed (instead of toggling its selection).
  final ValueChanged<T>? onRowPressed;

  /// Shown when there are no rows.
  final Widget? empty;

  /// Whether the rows are loading.
  final bool loading;

  /// Below the rows.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDataTable');
    final theme = Camouflage.themeOf(context, component: 'CamoDataTable');
    final style = skin.dataTable
        .defaults(theme)
        .merge(theme.components.dataTable);
    final selection = this.selection;
    final selectable = selection != null;
    final allSelected =
        selectable &&
        rows.isNotEmpty &&
        rows.every((r) => selection.contains(rowKey(r)));
    void toggleAll() => onSelectionChanged?.call(
      allSelected ? <Object>{} : {for (final r in rows) rowKey(r)},
    );
    void toggle(Object key) {
      final current = selection ?? const <Object>{};
      onSelectionChanged?.call(
        current.contains(key) ? ({...current}..remove(key)) : {...current, key},
      );
    }

    Widget sized(ColumnWidth width, Widget child) => switch (width) {
      FixedColumnWidth(:final width) => SizedBox(width: width, child: child),
      WeightColumnWidth(:final weight) => Expanded(
        flex: (weight * 1000).round(),
        child: child,
      ),
    };
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      value: loading ? 'Loading' : null,
      child: skin.dataTable.renderContainer(
        context,
        TableState(
          columnCount: columns.length,
          rowCount: rows.length,
          selectable: selectable,
          loading: loading,
        ),
        theme,
        style,
        CamoRovingFocus(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              skin.dataTable.renderHeaderRow(context, theme, style, [
                if (selectable)
                  SizedBox(
                    width: _selectColumn,
                    child: Center(
                      child: Semantics(
                        label: 'Select all rows',
                        child: CamoCheckbox(
                          checked: allSelected,
                          onChanged: (_) => toggleAll(),
                        ),
                      ),
                    ),
                  ),
                for (final column in columns)
                  sized(
                    column.width,
                    _HeaderCell(
                      column: column,
                      sort: sort,
                      onSortChanged: onSortChanged,
                    ),
                  ),
              ]),
              Flexible(
                child: rows.isEmpty
                    ? Center(
                        child: loading
                            ? const CamoProgressCircle(semanticLabel: 'Loading')
                            : empty,
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: rows.length,
                        itemBuilder: (context, i) => _BodyRow<T>(
                          key: ValueKey(rowKey(rows[i])),
                          index: i,
                          row: rows[i],
                          rowKey: rowKey(rows[i]),
                          columns: columns,
                          selection: selection,
                          toggle: toggle,
                          onRowPressed: onRowPressed,
                          sized: sized,
                        ),
                      ),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell<T> extends StatefulWidget {
  const _HeaderCell({
    required this.column,
    required this.sort,
    required this.onSortChanged,
  });

  final CamoColumn<T> column;
  final TableSort? sort;
  final ValueChanged<TableSort>? onSortChanged;

  @override
  State<_HeaderCell<T>> createState() => _HeaderCellState<T>();
}

class _HeaderCellState<T> extends State<_HeaderCell<T>> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDataTable');
    final theme = Camouflage.themeOf(context, component: 'CamoDataTable');
    final style = skin.dataTable
        .defaults(theme)
        .merge(theme.components.dataTable);
    final column = widget.column;
    final sorted = widget.sort?.columnId == column.id
        ? widget.sort!.ascending
        : null;
    final sortable = column.sortable && widget.onSortChanged != null;
    return CamoBehavior(
      controller: _interaction,
      enabled: sortable,
      onActivate: () => widget.onSortChanged?.call(
        TableSort(column.id, ascending: sorted != true),
      ),
      semantics: (child) => Semantics(
        button: sortable,
        label: column.header,
        value: sorted == null
            ? null
            : sorted
            ? 'sorted ascending'
            : 'sorted descending',
        excludeSemantics: true,
        child: child,
      ),
      child: ListenableBuilder(
        listenable: _interaction,
        builder: (context, _) => skin.dataTable.renderHeaderCell(
          context,
          HeaderCellState(
            sortable: sortable,
            sorted: sorted,
            align: column.align,
            interaction: _interaction.value,
            controller: _interaction,
          ),
          column.header,
          theme,
          style,
        ),
      ),
    );
  }
}

class _BodyRow<T> extends StatefulWidget {
  const _BodyRow({
    super.key,
    required this.index,
    required this.row,
    required this.rowKey,
    required this.columns,
    required this.selection,
    required this.toggle,
    required this.onRowPressed,
    required this.sized,
  });

  final int index;
  final T row;
  final Object rowKey;
  final List<CamoColumn<T>> columns;
  final Set<Object>? selection;
  final void Function(Object key) toggle;
  final ValueChanged<T>? onRowPressed;
  final Widget Function(ColumnWidth width, Widget child) sized;

  @override
  State<_BodyRow<T>> createState() => _BodyRowState<T>();
}

class _BodyRowState<T> extends State<_BodyRow<T>> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDataTable');
    final theme = Camouflage.themeOf(context, component: 'CamoDataTable');
    final style = skin.dataTable
        .defaults(theme)
        .merge(theme.components.dataTable);
    final selection = widget.selection;
    final selected = selection?.contains(widget.rowKey) ?? false;
    void act() {
      final press = widget.onRowPressed;
      if (press != null) {
        press(widget.row);
      } else if (selection != null) {
        widget.toggle(widget.rowKey);
      }
    }

    return CamoRovingFocusItem(
      index: widget.index,
      enabled: true,
      selected: selected,
      onSelect: () {},
      builder: (context, node) => Semantics(
        // Names the row's own tap node (selection); the cells keep their nodes.
        label: 'Row ${widget.index + 1}',
        child: CamoBehavior(
          controller: _interaction,
          enabled: true,
          focusNode: node,
          onActivate: act,
          semantics: (child) => Semantics(
            container: true,
            selected: selected,
            label: 'Row ${widget.index + 1}',
            child: child,
          ),
          child: ListenableBuilder(
            listenable: _interaction,
            builder: (context, _) => skin.dataTable.renderRow(
              context,
              RowState(
                index: widget.index,
                selected: selected,
                striped: widget.index.isOdd,
                interaction: _interaction.value,
                controller: _interaction,
              ),
              theme,
              style,
              [
                if (selection != null)
                  SizedBox(
                    width: _selectColumn,
                    child: Center(
                      child: Semantics(
                        label: 'Select row',
                        child: CamoCheckbox(
                          checked: selected,
                          onChanged: (_) => widget.toggle(widget.rowKey),
                        ),
                      ),
                    ),
                  ),
                for (final column in widget.columns)
                  widget.sized(
                    column.width,
                    skin.dataTable.renderCell(
                      context,
                      column.align,
                      theme,
                      style,
                      column.cell(context, widget.row),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
