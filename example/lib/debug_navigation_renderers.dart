import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// The M8 tabs and FAB in the debug skin: outlined boxes, a square indicator and plain text.

/// The debug skin's tabs renderer.
class DebugTabsRenderer implements CamoTabsRenderer {
  /// Creates the renderer.
  const DebugTabsRenderer();

  @override
  CamoTabsStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final colors = TabsColors(
      container: c.surface,
      selected: c.primary,
      unselected: c.onSurfaceVariant,
      indicator: c.primary,
      divider: c.outline,
    );
    return CamoTabsStyle(
      defaultAppearance: Appearance.solid,
      height: 48,
      heightWithIcon: 64,
      indicatorHeight: 3,
      indicatorWidth: IndicatorWidth.tab,
      labelStyle: theme.typography.labelLarge,
      iconSize: 18,
      iconGap: 4,
      tabPadding: 16,
      minTabWidth: 80,
      showDivider: true,
      solidColors: colors,
      ghostColors: colors,
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    TabsState state,
    CamoTheme theme,
    CamoTabsStyle style,
    Widget Function(CustomPainter indicatorPainter) row,
  ) {
    final colors = style.colorsFor(state.appearance);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: Border.all(color: colors.divider),
      ),
      child: row(
        _Indicator(state.indicator, colors.indicator, style.indicatorHeight),
      ),
    );
  }

  @override
  Widget renderTab(
    BuildContext context,
    TabState state,
    TabSlots slots,
    CamoTheme theme,
    CamoTabsStyle style,
  ) {
    final colors = style.colorsFor(state.appearance);
    final content = state.selected ? colors.selected : colors.unselected;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: style.height,
        minWidth: state.scrollable ? style.minTabWidth : 0,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: style.tabPadding),
        child: Center(
          widthFactor: 1,
          child: CamoContentStyle(
            color: content,
            iconStyle: CamoIconStyle(size: style.iconSize, color: content),
            child: Row(
              key: slots.contentKey,
              mainAxisSize: MainAxisSize.min,
              spacing: style.iconGap,
              children: [
                if (slots.child != null)
                  slots.child!
                else ...[
                  ?slots.icon,
                  if (slots.label != null)
                    Flexible(
                      child: Text(
                        slots.label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.labelStyle.copyWith(color: content),
                      ),
                    ),
                  ?slots.badge,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Indicator extends CustomPainter {
  _Indicator(this.indicator, this.color, this.thickness)
    : super(repaint: indicator);

  final ValueListenable<TabIndicator?> indicator;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final place = indicator.value;
    if (place == null) return;
    canvas.drawRect(
      Rect.fromLTWH(
        place.start,
        size.height - thickness,
        place.width,
        thickness,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_Indicator old) =>
      old.indicator != indicator ||
      old.color != color ||
      old.thickness != thickness;
}

/// The debug skin's FAB renderer.
class DebugFabRenderer implements CamoFabRenderer {
  /// Creates the renderer.
  const DebugFabRenderer();

  @override
  CamoFabStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoFabStyle(
      defaultAppearance: Appearance.soft,
      size: FabSize.regular,
      sizeSmall: 40,
      sizeRegular: 56,
      sizeLarge: 96,
      extendedHeight: 56,
      shapeSmall: BorderRadius.zero,
      shapeRegular: BorderRadius.zero,
      shapeLarge: BorderRadius.zero,
      iconSizeRegular: 24,
      iconSizeLarge: 36,
      iconGap: 8,
      extendedPadding: 16,
      textStyle: theme.typography.labelLarge,
      elevation: ElevationLevel.level3,
      softColors: FabColors(
        container: c.primaryContainer,
        content: c.onPrimaryContainer,
      ),
      solidColors: FabColors(container: c.primary, content: c.onPrimary),
      raisedColors: FabColors(
        container: c.surfaceContainerHigh,
        content: c.primary,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    FabState state,
    FabSlots slots,
    CamoTheme theme,
    CamoFabStyle style,
  ) {
    final colors = style.colorsFor(state, theme);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: Border.all(color: colors.content),
      ),
      child: ConstrainedBox(
        constraints: state.extended
            ? BoxConstraints(
                minHeight: style.extendedHeight,
                minWidth: style.extendedHeight,
              )
            : BoxConstraints.tightFor(
                width: style.containerSize,
                height: style.containerSize,
              ),
        child: Center(
          widthFactor: 1,
          child: CamoContentStyle(
            color: colors.content,
            iconStyle: CamoIconStyle(
              size: style.iconSize,
              color: colors.content,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: style.iconGap,
              children: [
                slots.icon,
                if (state.extended && state.expanded)
                  Text(
                    state.text!,
                    style: style.textStyle.copyWith(color: colors.content),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
