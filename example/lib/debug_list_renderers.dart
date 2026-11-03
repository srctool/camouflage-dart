import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M10 data table and tree in the debug skin: boxes, rows and text.

/// A placeholder icon.
Widget _listIcon(double size, Color? color) => SizedBox.square(dimension: size);

/// The debug skin's data table renderer.
class DebugDataTable implements CamoDataTableRenderer {
  /// Creates the renderer.
  const DebugDataTable();

  @override
  CamoTableStyle defaults(CamoTheme theme) => CamoTableStyle(
    headerHeight: 40,
    rowHeight: 44,
    cellPadding: 8,
    striped: true,
    dividers: true,
    headerStyle: theme.typography.labelLarge,
    cellStyle: theme.typography.bodyMedium,
    sortIcon: const IconSource.builder(_listIcon),
    colors: const TableColors(
      container: Color(0xFFFFFFFF),
      header: Color(0xFFCCCCCC),
      row: Color(0x00000000),
      stripedRow: Color(0xFFEEEEEE),
      selectedRow: Color(0xFF00FFFF),
      divider: Color(0xFF888888),
      text: Color(0xFF000000),
      headerText: Color(0xFF444444),
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    TableState state,
    CamoTheme theme,
    CamoTableStyle style,
    Widget child,
  ) {
    return ColoredBox(color: style.colors.container, child: child);
  }

  @override
  Widget renderHeaderRow(
    BuildContext context,
    CamoTheme theme,
    CamoTableStyle style,
    List<Widget> cells,
  ) => SizedBox(
    height: style.headerHeight,
    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
  );

  @override
  Widget renderHeaderCell(
    BuildContext context,
    HeaderCellState state,
    String label,
    CamoTheme theme,
    CamoTableStyle style,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (state.sorted != null) Text(state.sorted! ? '^' : 'v'),
        ],
      ),
    );
  }

  @override
  Widget renderRow(
    BuildContext context,
    RowState state,
    CamoTheme theme,
    CamoTableStyle style,
    List<Widget> cells,
  ) {
    return ColoredBox(
      color: state.selected ? style.colors.selectedRow : style.colors.row,
      child: Row(children: cells),
    );
  }

  @override
  Widget renderCell(
    BuildContext context,
    ColumnAlign align,
    CamoTheme theme,
    CamoTableStyle style,
    Widget child,
  ) => Padding(padding: const EdgeInsets.all(8), child: child);
}

/// The debug skin's tree renderer.
class DebugTree implements CamoTreeRenderer {
  /// Creates the renderer.
  const DebugTree();

  @override
  CamoTreeStyle defaults(CamoTheme theme) => CamoTreeStyle(
    rowHeight: 32,
    indent: 16,
    showLines: false,
    chevron: const IconSource.builder(_listIcon),
    iconSize: 20,
    textStyle: theme.typography.bodyMedium,
    colors: const TreeColors(
      selected: Color(0xFF00FFFF),
      hover: Color(0xFFCCCCCC),
      line: Color(0xFF888888),
      text: Color(0xFF000000),
      chevron: Color(0xFF444444),
    ),
  );

  @override
  Widget renderNode(
    BuildContext context,
    TreeNodeState state,
    TreeNodeSlots slots,
    CamoTheme theme,
    CamoTreeStyle style,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.0 * state.level),
      child: Row(
        children: [
          slots.wrapToggle(
            SizedBox.square(
              dimension: 24,
              child: state.hasChildren
                  ? Text(state.expanded ? '-' : '+')
                  : null,
            ),
          ),
          ?slots.icon,
          Text(slots.label),
        ],
      ),
    );
  }
}
