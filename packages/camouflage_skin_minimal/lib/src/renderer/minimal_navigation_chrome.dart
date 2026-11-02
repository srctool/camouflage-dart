import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// Minimal's navigation chrome (base Minimal Skin §3.4): hairlines, no indicator on the bar and the rail (the
// selected item turns ink), and a quiet filled row in the drawer.

const double _hairline = 1;
const double _disabledAlpha = 0.38;
const double _gap = 4;
const double _rowGap = 12;
const double _lineWidth = 2;

// Which edge of an item a `line` indicator runs along: the top (the bar) or the start (the rail and drawer).
enum _Edge { top, start }

// How one item is painted, from whichever style the chrome has.
class _Paint {
  const _Paint({
    required this.indicator,
    required this.selectedIcon,
    required this.selectedLabel,
    required this.icon,
    required this.label,
    required this.indicatorColor,
    required this.iconSize,
    required this.labelStyle,
    required this.indicatorSize,
    required this.indicatorShape,
    required this.row,
    required this.rowHeight,
    required this.edge,
    required this.lineColor,
  });

  final NavIndicator indicator;
  final Color selectedIcon;
  final Color selectedLabel;
  final Color icon;
  final Color label;
  final Color indicatorColor;
  final double iconSize;
  final TextStyle labelStyle;
  final Size indicatorSize;
  final BorderRadius indicatorShape;
  final bool row;
  final double rowHeight;
  final _Edge edge;
  final Color lineColor;
}

Widget _navItem(
  BuildContext context,
  NavItemState state,
  NavItemSlots slots,
  _Paint paint,
) {
  final skin = Camouflage.skinOf(context);
  final iconColor = state.selected ? paint.selectedIcon : paint.icon;
  final labelColor = state.selected ? paint.selectedLabel : paint.label;
  final marked = state.selected && state.indicator != NavIndicator.none;
  final line = marked && state.indicator == NavIndicator.line;
  final badge = slots.badge;
  final icon = CamoContentStyle(
    color: iconColor,
    iconStyle: CamoIconStyle(size: paint.iconSize, color: iconColor),
    child: badge != null
        ? CamoBadgedBox(badge: badge, child: slots.icon)
        : slots.icon,
  );
  final Widget body;
  if (paint.row) {
    body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: paint.rowHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: marked ? paint.indicatorColor : null,
          borderRadius: paint.indicatorShape,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _rowGap),
          child: Row(
            spacing: _rowGap,
            children: [
              icon,
              Expanded(
                child: Text(
                  slots.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: paint.labelStyle.copyWith(color: labelColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    final pill = marked && state.indicator == NavIndicator.pill;
    body = Padding(
      padding: const EdgeInsets.symmetric(vertical: _gap),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: paint.indicatorSize.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap,
          children: [
            pill
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: paint.indicatorColor,
                      borderRadius: paint.indicatorShape,
                    ),
                    child: SizedBox.fromSize(
                      size: paint.indicatorSize,
                      child: Center(child: icon),
                    ),
                  )
                : icon,
            if (state.showLabel)
              Text(
                slots.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: paint.labelStyle.copyWith(color: labelColor),
              ),
          ],
        ),
      ),
    );
  }
  final marker = line
      ? DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: paint.edge == _Edge.top
              ? BoxDecoration(
                  border: Border(
                    top: BorderSide(color: paint.lineColor, width: _lineWidth),
                  ),
                )
              : BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(
                      color: paint.lineColor,
                      width: _lineWidth,
                    ),
                  ),
                ),
          child: body,
        )
      : body;
  return skin.feedback.wrap(
    controller: state.controller,
    contentColor: iconColor,
    shape: paint.indicatorShape,
    theme: Camouflage.themeOf(context),
    child: Opacity(opacity: state.enabled ? 1 : _disabledAlpha, child: marker),
  );
}

NavColors _navColors(CamoTheme theme) {
  final c = theme.colors;
  return NavColors(
    container: c.surface,
    indicator: c.surfaceContainerHigh,
    selectedIcon: c.onSurface,
    selectedLabel: c.onSurface,
    icon: c.onSurfaceVariant,
    label: c.onSurfaceVariant,
  );
}

_Paint _paintOf(
  NavColors colors, {
  required NavIndicator indicator,
  required double iconSize,
  required TextStyle labelStyle,
  required Size size,
  required BorderRadius shape,
  required _Edge edge,
}) => _Paint(
  indicator: indicator,
  selectedIcon: colors.selectedIcon,
  selectedLabel: colors.selectedLabel,
  icon: colors.icon,
  label: colors.label,
  indicatorColor: colors.indicator,
  iconSize: iconSize,
  labelStyle: labelStyle,
  indicatorSize: size,
  indicatorShape: shape,
  row: false,
  rowHeight: 0,
  edge: edge,
  lineColor: colors.selectedIcon,
);

/// Minimal's navigation bar: 64 tall, a hairline on top, no indicator.
class MinimalNavigationBarRenderer implements CamoNavigationBarRenderer {
  /// Creates the renderer.
  const MinimalNavigationBarRenderer();

  @override
  CamoNavigationBarStyle defaults(CamoTheme theme) => CamoNavigationBarStyle(
    placement: NavPlacement.pinned,
    floatingMargin: 12,
    floatingShape: theme.shapes.large,
    floatingElevation: ElevationLevel.level2,
    indicator: NavIndicator.none,
    showLabels: LabelVisibility.always,
    height: 64,
    indicatorSize: const Size(48, 28),
    indicatorShape: theme.shapes.full,
    labelStyle: theme.typography.labelSmall,
    iconSize: 22,
    colors: _navColors(theme),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    NavBarState state,
    CamoTheme theme,
    CamoNavigationBarStyle style,
    List<Widget> items,
  ) {
    final skin = Camouflage.skinOf(context);
    final floating = style.placement == NavPlacement.floating;
    final shape = floating ? style.floatingShape : BorderRadius.zero;
    Widget bar = skin.surfaceTreatment.decorate(
      color: style.colors.container,
      shape: shape,
      elevation: floating ? theme.elevation.of(style.floatingElevation) : 0,
      theme: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: floating
              ? null
              : Border(
                  top: BorderSide(
                    color: theme.colors.outlineVariant,
                    width: _hairline,
                  ),
                ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: state.insets.bottom),
          child: SizedBox(
            height: style.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: items,
            ),
          ),
        ),
      ),
    );
    if (floating) {
      bar = Padding(padding: EdgeInsets.all(style.floatingMargin), child: bar);
    }
    return bar;
  }

  @override
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationBarStyle style,
  ) => _navItem(
    context,
    state,
    slots,
    _paintOf(
      style.colors,
      indicator: style.indicator,
      iconSize: style.iconSize,
      labelStyle: style.labelStyle,
      size: style.indicatorSize,
      shape: style.indicatorShape,
      edge: _Edge.top,
    ),
  );
}

/// Minimal's navigation rail: 72 wide, a hairline on the end edge, no indicator.
class MinimalNavigationRailRenderer implements CamoNavigationRailRenderer {
  /// Creates the renderer.
  const MinimalNavigationRailRenderer();

  @override
  CamoNavigationRailStyle defaults(CamoTheme theme) => CamoNavigationRailStyle(
    indicator: NavIndicator.none,
    alignment: RailAlignment.top,
    showLabels: LabelVisibility.always,
    width: 72,
    itemSpacing: 8,
    indicatorSize: const Size(48, 28),
    indicatorShape: theme.shapes.full,
    labelStyle: theme.typography.labelSmall,
    iconSize: 22,
    colors: _navColors(theme),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    NavRailState state,
    CamoTheme theme,
    CamoNavigationRailStyle style,
    Widget? header,
    List<Widget> items,
  ) {
    final skin = Camouflage.skinOf(context);
    return skin.surfaceTreatment.decorate(
      color: style.colors.container,
      shape: BorderRadius.zero,
      elevation: 0,
      theme: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(
              color: theme.colors.outlineVariant,
              width: _hairline,
            ),
          ),
        ),
        child: SizedBox(
          width: style.width,
          child: Padding(
            padding: state.insets.add(const EdgeInsets.symmetric(vertical: 12)),
            child: Column(
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: header,
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              style.alignment == RailAlignment.center
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          spacing: style.itemSpacing,
                          children: items,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationRailStyle style,
  ) => _navItem(
    context,
    state,
    slots,
    _paintOf(
      style.colors,
      indicator: style.indicator,
      iconSize: style.iconSize,
      labelStyle: style.labelStyle,
      size: style.indicatorSize,
      shape: style.indicatorShape,
      edge: _Edge.start,
    ),
  );
}

/// Minimal's navigation drawer: 280 wide, items 40, a quiet filled selected row.
class MinimalNavigationDrawerRenderer implements CamoNavigationDrawerRenderer {
  /// Creates the renderer.
  const MinimalNavigationDrawerRenderer();

  @override
  CamoNavigationDrawerStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoNavigationDrawerStyle(
      indicator: NavIndicator.fill,
      width: 280,
      itemHeight: 40,
      iconSize: 20,
      itemShape: theme.shapes.medium,
      modalShape: BorderRadius.zero,
      labelStyle: theme.typography.labelLarge,
      sectionTitleStyle: theme.typography.titleSmall,
      scrimAlpha: 0.4,
      colors: DrawerColors(
        container: c.surface,
        modalContainer: c.surface,
        indicator: c.surfaceContainerHigh,
        selectedContent: c.onSurface,
        content: c.onSurfaceVariant,
        sectionTitle: c.onSurfaceVariant,
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
  ) {
    final skin = Camouflage.skinOf(context);
    return skin.surfaceTreatment.decorate(
      color: state.modal ? style.colors.modalContainer : style.colors.container,
      shape: state.modal ? style.modalShape : BorderRadius.zero,
      elevation: 0,
      theme: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(
              color: theme.colors.outlineVariant,
              width: _hairline,
            ),
          ),
        ),
        child: SizedBox(
          width: style.width,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: header,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 2,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget renderSectionTitle(
    BuildContext context,
    String title,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
  ) => Padding(
    padding: const EdgeInsetsDirectional.only(
      start: _rowGap,
      top: 16,
      bottom: 8,
    ),
    child: Text(
      title,
      maxLines: 1,
      style: style.sectionTitleStyle.copyWith(color: style.colors.sectionTitle),
    ),
  );

  @override
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
  ) {
    final c = style.colors;
    return _navItem(
      context,
      state,
      slots,
      _Paint(
        indicator: state.indicator,
        selectedIcon: c.selectedContent,
        selectedLabel: c.selectedContent,
        icon: c.content,
        label: c.content,
        indicatorColor: c.indicator,
        iconSize: style.iconSize,
        labelStyle: style.labelStyle,
        indicatorSize: Size(style.width, style.itemHeight),
        indicatorShape: style.itemShape,
        row: true,
        rowHeight: style.itemHeight,
        edge: _Edge.start,
        lineColor: c.selectedContent,
      ),
    );
  }
}
