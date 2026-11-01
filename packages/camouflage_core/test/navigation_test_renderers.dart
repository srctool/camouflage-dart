import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// The M8 tabs and FAB in the plain test skin: boxes, rows and text, no decoration.

/// The indicator the plain tab bar last drew, for tests to read.
TabIndicator? lastIndicator;

class _Probe extends CustomPainter {
  _Probe(this.indicator) : super(repaint: indicator);

  final ValueListenable<TabIndicator?> indicator;

  @override
  void paint(Canvas canvas, Size size) => lastIndicator = indicator.value;

  @override
  bool shouldRepaint(_Probe old) => old.indicator != indicator;
}

class PlainTabs implements CamoTabsRenderer {
  const PlainTabs();

  @override
  CamoTabsStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final colors = TabsColors(
      container: c.surface,
      selected: c.primary,
      unselected: c.onSurfaceVariant,
      indicator: c.primary,
      divider: c.outlineVariant,
    );
    return CamoTabsStyle(
      defaultAppearance: Appearance.solid,
      height: 48,
      heightWithIcon: 64,
      indicatorHeight: 3,
      indicatorWidth: IndicatorWidth.tab,
      labelStyle: theme.typography.titleSmall,
      iconSize: 24,
      iconGap: 8,
      tabPadding: 16,
      minTabWidth: 90,
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
  ) => row(_Probe(state.indicator));

  @override
  Widget renderTab(
    BuildContext context,
    TabState state,
    TabSlots slots,
    CamoTheme theme,
    CamoTabsStyle style,
  ) => Padding(
    padding: EdgeInsets.symmetric(horizontal: style.tabPadding),
    child: Row(
      key: slots.contentKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (slots.child != null)
          slots.child!
        else ...[
          if (slots.icon != null) slots.icon!,
          if (slots.label != null) Text(slots.label!),
          if (slots.badge != null) slots.badge!,
        ],
      ],
    ),
  );
}

class PlainFab implements CamoFabRenderer {
  const PlainFab();

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
    return ColoredBox(
      color: colors.container,
      child: SizedBox(
        width: state.extended ? null : style.containerSize,
        height: state.extended ? style.extendedHeight : style.containerSize,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            slots.icon,
            if (state.extended && state.expanded) Text(state.text!),
          ],
        ),
      ),
    );
  }
}
