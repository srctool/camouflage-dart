import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M8 navigation chrome in the plain test skin: boxes, rows and text, no decoration.

NavColors _colors(CamoTheme theme) => NavColors(
  container: theme.colors.surface,
  indicator: theme.colors.secondaryContainer,
  selectedIcon: theme.colors.primary,
  selectedLabel: theme.colors.primary,
  icon: theme.colors.onSurfaceVariant,
  label: theme.colors.onSurfaceVariant,
);

Widget _item(NavItemState state, NavItemSlots slots) => Padding(
  padding: const EdgeInsets.all(8),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      slots.icon,
      if (state.showLabel) Text(slots.label),
      ?slots.badge,
    ],
  ),
);

/// The insets the plain bar was last given, for tests.
EdgeInsets? lastBarInsets;

class PlainNavigationBar implements CamoNavigationBarRenderer {
  const PlainNavigationBar();

  @override
  CamoNavigationBarStyle defaults(CamoTheme theme) => CamoNavigationBarStyle(
    placement: NavPlacement.pinned,
    floatingMargin: 12,
    floatingShape: BorderRadius.zero,
    floatingElevation: ElevationLevel.level2,
    indicator: NavIndicator.pill,
    showLabels: LabelVisibility.always,
    height: 64,
    indicatorSize: const Size(48, 28),
    indicatorShape: BorderRadius.zero,
    labelStyle: theme.typography.labelSmall,
    iconSize: 24,
    colors: _colors(theme),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    NavBarState state,
    CamoTheme theme,
    CamoNavigationBarStyle style,
    List<Widget> items,
  ) {
    lastBarInsets = state.insets;
    return ColoredBox(
      color: style.colors.container,
      child: SizedBox(
        height: style.height,
        child: Row(children: items),
      ),
    );
  }

  @override
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationBarStyle style,
  ) => _item(state, slots);
}

class PlainNavigationRail implements CamoNavigationRailRenderer {
  const PlainNavigationRail();

  @override
  CamoNavigationRailStyle defaults(CamoTheme theme) => CamoNavigationRailStyle(
    indicator: NavIndicator.pill,
    alignment: RailAlignment.top,
    showLabels: LabelVisibility.always,
    width: 160,
    itemSpacing: 12,
    indicatorSize: const Size(56, 32),
    indicatorShape: BorderRadius.zero,
    labelStyle: theme.typography.labelSmall,
    iconSize: 24,
    colors: _colors(theme),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    NavRailState state,
    CamoTheme theme,
    CamoNavigationRailStyle style,
    Widget? header,
    List<Widget> items,
  ) => ColoredBox(
    color: style.colors.container,
    child: SizedBox(
      width: style.width,
      child: Column(children: [?header, ...items]),
    ),
  );

  @override
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationRailStyle style,
  ) => _item(state, slots);
}

class PlainNavigationDrawer implements CamoNavigationDrawerRenderer {
  const PlainNavigationDrawer();

  @override
  CamoNavigationDrawerStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoNavigationDrawerStyle(
      indicator: NavIndicator.pill,
      width: 280,
      itemHeight: 48,
      iconSize: 24,
      itemShape: BorderRadius.zero,
      modalShape: BorderRadius.zero,
      labelStyle: theme.typography.labelLarge,
      sectionTitleStyle: theme.typography.titleSmall,
      scrimAlpha: 0.32,
      colors: DrawerColors(
        container: c.surface,
        modalContainer: c.surfaceContainerLow,
        indicator: c.secondaryContainer,
        selectedContent: c.primary,
        content: c.onSurfaceVariant,
        sectionTitle: c.onSurface,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    DrawerState state,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
    Widget? header,
    List<Widget> children,
  ) => ColoredBox(
    color: style.colors.container,
    child: SizedBox(
      width: style.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [?header, ...children],
      ),
    ),
  );

  @override
  Widget renderSectionTitle(
    BuildContext context,
    String title,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
  ) => Text(title);

  @override
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
  ) => _item(state, slots);
}
