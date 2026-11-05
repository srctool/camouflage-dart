import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'carbon_indicators.dart' show arrowUpGlyph, chevronRightGlyph;

// Carbon's data table and tree: a hairline grid with soft selection.

const double _hairline = 1;
const double _sortIconSize = 14;
const double _toggleSize = 24;
const double _chevronShare = 0.8;

/// Carbon's data table.
class CarbonDataTableRenderer implements CamoDataTableRenderer {
  /// Creates the renderer.
  const CarbonDataTableRenderer();

  @override
  CamoTableStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoTableStyle(
      headerHeight: 48,
      rowHeight: 48,
      cellPadding: theme.spacing.l,
      striped: false,
      dividers: true,
      headerStyle: theme.typography.labelLarge,
      cellStyle: theme.typography.bodyMedium,
      sortIcon: const IconSource.builder(arrowUpGlyph),
      colors: TableColors(
        container: c.surface,
        header: c.surfaceContainerLow,
        row: c.surface,
        stripedRow: c.surfaceContainerLow,
        selectedRow: c.surfaceContainerHigh,
        divider: c.outlineVariant,
        text: c.onSurface,
        headerText: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    TableState state,
    CamoTheme theme,
    CamoTableStyle style,
    Widget child,
  ) {
    final shape = theme.shapes.medium;
    return ClipRRect(
      borderRadius: shape,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(color: style.colors.divider, width: _hairline),
        ),
        child: ColoredBox(color: style.colors.container, child: child),
      ),
    );
  }

  @override
  Widget renderHeaderRow(
    BuildContext context,
    CamoTheme theme,
    CamoTableStyle style,
    List<Widget> cells,
  ) => SizedBox(
    height: style.headerHeight,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: style.colors.header,
        border: Border(
          bottom: BorderSide(color: style.colors.divider, width: _hairline),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    ),
  );

  @override
  Widget renderHeaderCell(
    BuildContext context,
    HeaderCellState state,
    String label,
    CamoTheme theme,
    CamoTableStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: c.headerText,
      shape: BorderRadius.zero,
      theme: theme,
      child: ColoredBox(
        color: state.interaction.hovered && state.sortable
            ? c.selectedRow
            : const Color(0x00000000),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: style.cellPadding),
          child: Row(
            mainAxisAlignment: _arrange(state.align),
            spacing: 4,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.headerStyle.copyWith(
                    color: c.headerText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (state.sorted != null)
                Transform.rotate(
                  angle: state.sorted! ? 0 : math.pi,
                  child: CamoIcon(
                    style.sortIcon,
                    size: _sortIconSize,
                    color: c.headerText,
                  ),
                ),
            ],
          ),
        ),
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
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final fill = state.selected
        ? c.selectedRow
        : state.striped && style.striped
        ? c.stripedRow
        : c.row;
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: c.text,
      shape: BorderRadius.zero,
      theme: theme,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: style.rowHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            border: style.dividers
                ? Border(
                    bottom: BorderSide(color: c.divider, width: _hairline),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: cells,
          ),
        ),
      ),
    );
  }

  @override
  Widget renderCell(
    BuildContext context,
    ColumnAlign align,
    CamoTheme theme,
    CamoTableStyle style,
    Widget child,
  ) => Padding(
    padding: EdgeInsets.symmetric(horizontal: style.cellPadding, vertical: 4),
    child: Align(
      alignment: switch (align) {
        ColumnAlign.start => AlignmentDirectional.centerStart,
        ColumnAlign.center => Alignment.center,
        ColumnAlign.end => AlignmentDirectional.centerEnd,
      },
      child: CamoContentStyle(
        color: style.colors.text,
        iconStyle: CamoIconStyle(size: 20, color: style.colors.text),
        child: child,
      ),
    ),
  );
}

MainAxisAlignment _arrange(ColumnAlign align) => switch (align) {
  ColumnAlign.start => MainAxisAlignment.start,
  ColumnAlign.center => MainAxisAlignment.center,
  ColumnAlign.end => MainAxisAlignment.end,
};

/// Carbon's tree.
class CarbonTreeRenderer implements CamoTreeRenderer {
  /// Creates the renderer.
  const CarbonTreeRenderer();

  @override
  CamoTreeStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoTreeStyle(
      rowHeight: 32,
      indent: 20,
      showLines: false,
      chevron: const IconSource.builder(chevronRightGlyph),
      iconSize: 20,
      textStyle: theme.typography.bodyMedium,
      colors: TreeColors(
        selected: c.surfaceContainerHigh,
        hover: c.surfaceContainerLow,
        line: c.outlineVariant,
        text: c.onSurface,
        chevron: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget renderNode(
    BuildContext context,
    TreeNodeState state,
    TreeNodeSlots slots,
    CamoTheme theme,
    CamoTreeStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final fill = state.selected
        ? c.selected
        : state.interaction.hovered
        ? c.hover
        : const Color(0x00000000);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    Widget row = Padding(
      padding: EdgeInsetsDirectional.only(
        start: style.indent * state.level,
        end: 8,
      ),
      child: Row(
        spacing: 4,
        children: [
          slots.wrapToggle(
            SizedBox.square(
              dimension: _toggleSize,
              child: Center(
                child: state.loading
                    ? const CamoProgressCircle(size: ProgressSize.small)
                    : state.hasChildren
                    ? Transform.flip(
                        flipX: rtl,
                        child: Transform.rotate(
                          angle: state.expanded ? math.pi / 2 : 0,
                          child: CamoIcon(
                            style.chevron,
                            size: style.iconSize * _chevronShare,
                            color: c.chevron,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          CamoContentStyle(
            color: c.text,
            iconStyle: CamoIconStyle(size: style.iconSize, color: c.text),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                ?slots.icon,
                Text(
                  slots.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.textStyle.copyWith(color: c.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (style.showLines && state.level > 0) {
      row = CustomPaint(
        painter: _GuidePainter(
          levels: state.level,
          indent: style.indent,
          color: c.line,
          rtl: rtl,
        ),
        child: row,
      );
    }
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: c.text,
      shape: BorderRadius.zero,
      theme: theme,
      child: ColoredBox(
        color: fill,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: style.rowHeight),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            heightFactor: 1,
            child: row,
          ),
        ),
      ),
    );
  }
}

// A vertical hairline through each ancestor level, at the center of that level's chevron column.
class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.levels,
    required this.indent,
    required this.color,
    required this.rtl,
  });

  final int levels;
  final double indent;
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _hairline;
    for (var level = 0; level < levels; level++) {
      final x = indent * level + _toggleSize / 2;
      final at = rtl ? size.width - x : x;
      canvas.drawLine(Offset(at, 0), Offset(at, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.levels != levels || old.color != color || old.rtl != rtl;
}
