import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../environment/camo_environment.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';

/// How a navigation item marks the selected destination (ADR-28). Each skin draws the ones it supports.
enum NavIndicator {
  /// A pill behind the icon.
  pill,

  /// A line on the item's edge (the top on a bar, the start on a rail and drawer).
  line,

  /// A dot under the icon.
  dot,

  /// A filled row.
  fill,

  /// None: the selected item only changes color.
  none,
}

/// Whether items show their labels: an app-wide choice, so it is a theme field (ADR-23).
enum LabelVisibility {
  /// Every label.
  always,

  /// Only the selected item's label.
  selected,

  /// No labels.
  never,
}

/// Where the bar sits: edge to edge on the bottom inset, or detached above it (ADR-30).
enum NavPlacement {
  /// Edge to edge.
  pinned,

  /// Detached.
  floating,
}

/// Where a rail's items sit (ADR-23: only Material centers them).
enum RailAlignment {
  /// At the top.
  top,

  /// Centered.
  center,
}

/// A top-level destination, shared by the bar, the rail and the drawer. [value] is the app's own key (a route
/// name); navigation chrome only shows and reports the selection, routing stays with the app's router
/// (ADR-19). [selectedIcon] is an optional filled variant; [badge] is a `CamoBadge`.
@immutable
class CamoNavItem<T> {
  /// Creates a destination.
  const CamoNavItem({
    required this.value,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.enabled = true,
  });

  /// The app's key for the destination.
  final T value;

  /// The label.
  final String label;

  /// The icon.
  final Widget icon;

  /// The icon while selected.
  final Widget? selectedIcon;

  /// A badge on the icon.
  final Widget? badge;

  /// `false` disables this destination.
  final bool enabled;
}

/// A titled group of destinations in a drawer; one untitled section makes a plain list.
@immutable
class CamoNavSection<T> {
  /// Creates a section.
  const CamoNavSection({this.title, required this.items});

  /// The section's heading.
  final String? title;

  /// Its destinations.
  final List<CamoNavItem<T>> items;
}

/// Every color a navigation bar or rail uses.
@immutable
class NavColors {
  /// Creates NavColors.
  const NavColors({
    required this.container,
    required this.indicator,
    required this.selectedIcon,
    required this.selectedLabel,
    required this.icon,
    required this.label,
  });

  /// The fill.
  final Color container;

  /// The selected indicator.
  final Color indicator;

  /// The selected icon.
  final Color selectedIcon;

  /// The selected label.
  final Color selectedLabel;

  /// The other icons.
  final Color icon;

  /// The other labels.
  final Color label;

  @override
  bool operator ==(Object other) =>
      other is NavColors &&
      other.container == container &&
      other.indicator == indicator &&
      other.selectedIcon == selectedIcon &&
      other.selectedLabel == selectedLabel &&
      other.icon == icon &&
      other.label == label;

  @override
  int get hashCode => Object.hash(
    container,
    indicator,
    selectedIcon,
    selectedLabel,
    icon,
    label,
  );
}

/// Every color a navigation drawer uses; [modalContainer] is the container while it slides over the content.
@immutable
class DrawerColors {
  /// Creates DrawerColors.
  const DrawerColors({
    required this.container,
    required this.modalContainer,
    required this.indicator,
    required this.selectedContent,
    required this.content,
    required this.sectionTitle,
  });

  /// The fill.
  final Color container;

  /// The fill while modal.
  final Color modalContainer;

  /// The selected row.
  final Color indicator;

  /// The selected icon and label.
  final Color selectedContent;

  /// The other icons and labels.
  final Color content;

  /// Section titles.
  final Color sectionTitle;

  @override
  bool operator ==(Object other) =>
      other is DrawerColors &&
      other.container == container &&
      other.modalContainer == modalContainer &&
      other.indicator == indicator &&
      other.selectedContent == selectedContent &&
      other.content == content &&
      other.sectionTitle == sectionTitle;

  @override
  int get hashCode => Object.hash(
    container,
    modalContainer,
    indicator,
    selectedContent,
    content,
    sectionTitle,
  );
}

/// What an item renderer draws: one destination at [position]. [showLabel] is already decided from the theme's
/// [LabelVisibility]; [indicator] is the style's. Draw press feedback from [controller].
@immutable
class NavItemState {
  /// Creates an item state.
  const NavItemState({
    required this.selected,
    required this.enabled,
    required this.position,
    required this.showLabel,
    required this.indicator,
    required this.interaction,
    required this.controller,
  });

  /// Whether it's the selected destination.
  final bool selected;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Its place in the group.
  final CamoItemPosition position;

  /// Whether the label shows.
  final bool showLabel;

  /// The indicator style.
  final NavIndicator indicator;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// An item's content: the [icon] already chosen for its state, the [label] and the optional [badge].
@immutable
class NavItemSlots {
  /// Creates the slots.
  const NavItemSlots({required this.label, required this.icon, this.badge});

  /// The label.
  final String label;

  /// The icon for the item's state.
  final Widget icon;

  /// The badge.
  final Widget? badge;
}

enum _NavHost { bar, rail, drawer }

class _NavGroup extends InheritedWidget {
  const _NavGroup({
    required this.host,
    required this.enabled,
    required super.child,
  });

  final _NavHost host;
  final bool enabled;

  @override
  bool updateShouldNotify(_NavGroup old) =>
      host != old.host || enabled != old.enabled;
}

class _DrawerScope extends InheritedWidget {
  const _DrawerScope({required this.onNavigate, required super.child});

  final VoidCallback onNavigate;

  @override
  bool updateShouldNotify(_DrawerScope old) => false;
}

// --------------------------------------------------------------------------------------------- bar

/// Overrides for navigation bars; `null` keeps the skin's default.
@immutable
class CamoNavigationBarTheme {
  /// Creates overrides.
  const CamoNavigationBarTheme({
    this.placement,
    this.floatingMargin,
    this.floatingShape,
    this.floatingElevation,
    this.indicator,
    this.showLabels,
    this.height,
    this.indicatorSize,
    this.indicatorShape,
    this.labelStyle,
    this.iconSize,
    this.colors,
  });

  /// Pinned or floating.
  final NavPlacement? placement;

  /// The gap around a floating bar.
  final double? floatingMargin;

  /// A floating bar corners.
  final BorderRadius? floatingShape;

  /// A floating bar depth.
  final ElevationLevel? floatingElevation;

  /// The selected item indicator.
  final NavIndicator? indicator;

  /// Label visibility.
  final LabelVisibility? showLabels;

  /// The bar height, without the bottom inset.
  final double? height;

  /// The indicator size.
  final Size? indicatorSize;

  /// The indicator corners.
  final BorderRadius? indicatorShape;

  /// Labels.
  final TextStyle? labelStyle;

  /// Icons.
  final double? iconSize;

  /// Every color it uses.
  final NavColors? colors;

  /// A copy with the given fields replaced.
  CamoNavigationBarTheme copyWith({
    NavPlacement? placement,
    double? floatingMargin,
    BorderRadius? floatingShape,
    ElevationLevel? floatingElevation,
    NavIndicator? indicator,
    LabelVisibility? showLabels,
    double? height,
    Size? indicatorSize,
    BorderRadius? indicatorShape,
    TextStyle? labelStyle,
    double? iconSize,
    NavColors? colors,
  }) => CamoNavigationBarTheme(
    placement: placement ?? this.placement,
    floatingMargin: floatingMargin ?? this.floatingMargin,
    floatingShape: floatingShape ?? this.floatingShape,
    floatingElevation: floatingElevation ?? this.floatingElevation,
    indicator: indicator ?? this.indicator,
    showLabels: showLabels ?? this.showLabels,
    height: height ?? this.height,
    indicatorSize: indicatorSize ?? this.indicatorSize,
    indicatorShape: indicatorShape ?? this.indicatorShape,
    labelStyle: labelStyle ?? this.labelStyle,
    iconSize: iconSize ?? this.iconSize,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoNavigationBarTheme &&
      other.placement == placement &&
      other.floatingMargin == floatingMargin &&
      other.floatingShape == floatingShape &&
      other.floatingElevation == floatingElevation &&
      other.indicator == indicator &&
      other.showLabels == showLabels &&
      other.height == height &&
      other.indicatorSize == indicatorSize &&
      other.indicatorShape == indicatorShape &&
      other.labelStyle == labelStyle &&
      other.iconSize == iconSize &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    placement,
    floatingMargin,
    floatingShape,
    floatingElevation,
    indicator,
    showLabels,
    height,
    indicatorSize,
    indicatorShape,
    labelStyle,
    iconSize,
    colors,
  );
}

/// The resolved navigation bar style: every field set.
@immutable
class CamoNavigationBarStyle {
  /// Creates a style.
  const CamoNavigationBarStyle({
    required this.placement,
    required this.floatingMargin,
    required this.floatingShape,
    required this.floatingElevation,
    required this.indicator,
    required this.showLabels,
    required this.height,
    required this.indicatorSize,
    required this.indicatorShape,
    required this.labelStyle,
    required this.iconSize,
    required this.colors,
  });

  /// Pinned or floating.
  final NavPlacement placement;

  /// The gap around a floating bar.
  final double floatingMargin;

  /// A floating bar corners.
  final BorderRadius floatingShape;

  /// A floating bar depth.
  final ElevationLevel floatingElevation;

  /// The selected item indicator.
  final NavIndicator indicator;

  /// Label visibility.
  final LabelVisibility showLabels;

  /// The bar height, without the bottom inset.
  final double height;

  /// The indicator size.
  final Size indicatorSize;

  /// The indicator corners.
  final BorderRadius indicatorShape;

  /// Labels.
  final TextStyle labelStyle;

  /// Icons.
  final double iconSize;

  /// Every color it uses.
  final NavColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoNavigationBarStyle merge(CamoNavigationBarTheme? o) => o == null
      ? this
      : CamoNavigationBarStyle(
          placement: o.placement ?? placement,
          floatingMargin: o.floatingMargin ?? floatingMargin,
          floatingShape: o.floatingShape ?? floatingShape,
          floatingElevation: o.floatingElevation ?? floatingElevation,
          indicator: o.indicator ?? indicator,
          showLabels: o.showLabels ?? showLabels,
          height: o.height ?? height,
          indicatorSize: o.indicatorSize ?? indicatorSize,
          indicatorShape: o.indicatorShape ?? indicatorShape,
          labelStyle: o.labelStyle ?? labelStyle,
          iconSize: o.iconSize ?? iconSize,
          colors: o.colors ?? colors,
        );
}

/// What the bar renderer draws. [insets] is the bottom system inset (the gesture bar): the renderer pads its
/// content by it, after painting its background under it.
@immutable
class NavBarState {
  /// Creates the state.
  const NavBarState({
    required this.count,
    required this.selectedIndex,
    required this.insets,
  });

  /// How many items.
  final int count;

  /// The selected item, or `-1`.
  final int selectedIndex;

  /// The system insets around the bar.
  final EdgeInsets insets;
}

/// Draws navigation bars in two parts: the container (the surface, placement and spacing around the items) and
/// each item.
abstract interface class CamoNavigationBarRenderer {
  /// The complete navigation bar style for [theme].
  CamoNavigationBarStyle defaults(CamoTheme theme);

  /// Draws the bar around [items], one widget per destination.
  Widget renderContainer(
    BuildContext context,
    NavBarState state,
    CamoTheme theme,
    CamoNavigationBarStyle style,
    List<Widget> items,
  );

  /// Draws one item with [slots].
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationBarStyle style,
  );
}

/// The bottom bar for a phone's top-level destinations (3 to 5). [selected] in, [onChanged] out; routing stays
/// with the app's router (ADR-19). Items are tabs with their badge, the arrow keys move between them, and
/// `visible: false` slides the bar out (pair it with `CamoHideOnScroll`). Reselecting the current item calls
/// [onChanged] again, so apps can scroll to the top. `onChanged: null` disables the bar.
class CamoNavigationBar<T> extends StatelessWidget {
  /// Creates a navigation bar.
  const CamoNavigationBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.visible = true,
  });

  /// The destinations, 3 to 5.
  final List<CamoNavItem<T>> items;

  /// The selected value.
  final T selected;

  /// Called with the chosen value.
  final ValueChanged<T>? onChanged;

  /// `false` slides the bar out and removes it from focus and semantics.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    assert(
      items.length >= 3 && items.length <= 5,
      'CamoNavigationBar takes 3 to 5 items.',
    );
    final onChanged = this.onChanged;
    return CamoNavBarContainer(
      selectedIndex: items.indexWhere((i) => i.value == selected),
      visible: visible,
      enabled: onChanged != null,
      children: [
        for (final (i, item) in items.indexed)
          CamoNavItemButton<T>(
            item: item,
            selected: item.value == selected,
            onPressed: () => onChanged?.call(item.value),
            position: CamoItemPosition(i, items.length),
          ),
      ],
    );
  }
}

/// The building block (ADR-30) for custom bars: the skin's bar surface, placement and bottom inset, the
/// navigation-group semantics and the arrow keys across the [CamoNavItemButton]s in [children].
/// [selectedIndex] is the selected one (`-1` for none).
class CamoNavBarContainer extends StatelessWidget {
  /// Creates the container.
  const CamoNavBarContainer({
    super.key,
    required this.selectedIndex,
    required this.children,
    this.visible = true,
    this.enabled = true,
  });

  /// The selected item, or `-1`.
  final int selectedIndex;

  /// The [CamoNavItemButton]s.
  final List<Widget> children;

  /// `false` slides the bar out and removes it from focus and semantics.
  final bool visible;

  /// `false` disables every item.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoNavBarContainer');
    final theme = Camouflage.themeOf(context, component: 'CamoNavBarContainer');
    final style = skin.navigationBar
        .defaults(theme)
        .merge(theme.components.navigationBar);
    final insets = MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    final bar = Semantics(
      role: SemanticsRole.tabBar,
      container: true,
      child: _NavGroup(
        host: _NavHost.bar,
        enabled: enabled,
        child: CamoRovingFocus(
          child: skin.navigationBar.renderContainer(
            context,
            NavBarState(
              count: children.length,
              selectedIndex: selectedIndex,
              insets: EdgeInsets.only(bottom: insets.bottom),
            ),
            theme,
            style,
            children,
          ),
        ),
      ),
    );
    return _Hideable(
      visible: visible,
      duration: theme.motion.durationMedium,
      curve: theme.motion.easingEmphasized,
      child: bar,
    );
  }
}

// Slides a bar out (and gives back its space) while `visible` is false; hidden, it can't be focused or read.
class _Hideable extends StatelessWidget {
  const _Hideable({
    required this.visible,
    required this.duration,
    required this.curve,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: visible ? 1 : 0),
    duration: duration,
    curve: curve,
    child: child,
    builder: (context, t, child) => IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: ExcludeSemantics(
          excluding: !visible,
          child: ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: t,
              child: Opacity(opacity: t, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

/// One skin-styled destination inside a [CamoNavBarContainer], [CamoNavigationRail] or
/// [CamoNavigationDrawer], drawn by the renderer of the chrome it's in. Tab semantics and arrow keys are built
/// in; the badge's description joins the item's.
class CamoNavItemButton<T> extends StatefulWidget {
  /// Creates an item button.
  const CamoNavItemButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onPressed,
    required this.position,
  });

  /// The destination.
  final CamoNavItem<T> item;

  /// Whether it's the selected one.
  final bool selected;

  /// Called when chosen.
  final VoidCallback onPressed;

  /// Its place in the group.
  final CamoItemPosition position;

  @override
  State<CamoNavItemButton<T>> createState() => _CamoNavItemButtonState<T>();
}

class _CamoNavItemButtonState<T> extends State<CamoNavItemButton<T>> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  bool _showsLabel(LabelVisibility v) => switch (v) {
    LabelVisibility.always => true,
    LabelVisibility.selected => widget.selected,
    LabelVisibility.never => false,
  };

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoNavItemButton');
    final theme = Camouflage.themeOf(context, component: 'CamoNavItemButton');
    final group = context.dependOnInheritedWidgetOfExactType<_NavGroup>();
    assert(
      group != null,
      'CamoNavItemButton must be inside a navigation bar, rail or drawer container.',
    );
    final item = widget.item;
    final enabled = (group?.enabled ?? true) && item.enabled;
    final slots = NavItemSlots(
      label: item.label,
      icon: widget.selected ? item.selectedIcon ?? item.icon : item.icon,
      badge: item.badge,
    );
    NavItemState state(NavIndicator indicator, bool showLabel) => NavItemState(
      selected: widget.selected,
      enabled: enabled,
      position: widget.position,
      showLabel: showLabel,
      indicator: indicator,
      interaction: _interaction.value,
      controller: _interaction,
    );
    Widget visual(BuildContext context, _) =>
        switch (group?.host ?? _NavHost.bar) {
          _NavHost.bar => () {
            final style = skin.navigationBar
                .defaults(theme)
                .merge(theme.components.navigationBar);
            return skin.navigationBar.renderItem(
              context,
              state(style.indicator, _showsLabel(style.showLabels)),
              slots,
              theme,
              style,
            );
          }(),
          _NavHost.rail => () {
            final style = skin.navigationRail
                .defaults(theme)
                .merge(theme.components.navigationRail);
            return skin.navigationRail.renderItem(
              context,
              state(style.indicator, _showsLabel(style.showLabels)),
              slots,
              theme,
              style,
            );
          }(),
          _NavHost.drawer => () {
            final style = skin.navigationDrawer
                .defaults(theme)
                .merge(theme.components.navigationDrawer);
            return skin.navigationDrawer.renderItem(
              context,
              state(style.indicator, true),
              slots,
              theme,
              style,
            );
          }(),
        };
    final drawer = context.dependOnInheritedWidgetOfExactType<_DrawerScope>();
    void press() {
      widget.onPressed();
      drawer?.onNavigate();
    }

    return CamoRovingFocusItem(
      index: widget.position.index,
      enabled: enabled,
      selected: widget.selected,
      onSelect: press,
      builder: (context, node) => CamoBehavior(
        controller: _interaction,
        enabled: enabled,
        focusNode: node,
        onActivate: press,
        semantics: (child) => Semantics(
          role: SemanticsRole.tab,
          enabled: enabled,
          selected: widget.selected,
          child: child,
        ),
        child: ListenableBuilder(listenable: _interaction, builder: visual),
      ),
    );
  }
}

// --------------------------------------------------------------------------------------------- rail

/// Overrides for navigation rails; `null` keeps the skin's default.
@immutable
class CamoNavigationRailTheme {
  /// Creates overrides.
  const CamoNavigationRailTheme({
    this.indicator,
    this.alignment,
    this.showLabels,
    this.width,
    this.itemSpacing,
    this.indicatorSize,
    this.indicatorShape,
    this.labelStyle,
    this.iconSize,
    this.colors,
  });

  /// The selected item indicator.
  final NavIndicator? indicator;

  /// Where the item group sits.
  final RailAlignment? alignment;

  /// Label visibility.
  final LabelVisibility? showLabels;

  /// The rail width.
  final double? width;

  /// The vertical gap between items.
  final double? itemSpacing;

  /// The indicator size.
  final Size? indicatorSize;

  /// The indicator corners.
  final BorderRadius? indicatorShape;

  /// Labels.
  final TextStyle? labelStyle;

  /// Icons.
  final double? iconSize;

  /// Every color it uses.
  final NavColors? colors;

  /// A copy with the given fields replaced.
  CamoNavigationRailTheme copyWith({
    NavIndicator? indicator,
    RailAlignment? alignment,
    LabelVisibility? showLabels,
    double? width,
    double? itemSpacing,
    Size? indicatorSize,
    BorderRadius? indicatorShape,
    TextStyle? labelStyle,
    double? iconSize,
    NavColors? colors,
  }) => CamoNavigationRailTheme(
    indicator: indicator ?? this.indicator,
    alignment: alignment ?? this.alignment,
    showLabels: showLabels ?? this.showLabels,
    width: width ?? this.width,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    indicatorSize: indicatorSize ?? this.indicatorSize,
    indicatorShape: indicatorShape ?? this.indicatorShape,
    labelStyle: labelStyle ?? this.labelStyle,
    iconSize: iconSize ?? this.iconSize,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoNavigationRailTheme &&
      other.indicator == indicator &&
      other.alignment == alignment &&
      other.showLabels == showLabels &&
      other.width == width &&
      other.itemSpacing == itemSpacing &&
      other.indicatorSize == indicatorSize &&
      other.indicatorShape == indicatorShape &&
      other.labelStyle == labelStyle &&
      other.iconSize == iconSize &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    indicator,
    alignment,
    showLabels,
    width,
    itemSpacing,
    indicatorSize,
    indicatorShape,
    labelStyle,
    iconSize,
    colors,
  );
}

/// The resolved navigation rail style: every field set.
@immutable
class CamoNavigationRailStyle {
  /// Creates a style.
  const CamoNavigationRailStyle({
    required this.indicator,
    required this.alignment,
    required this.showLabels,
    required this.width,
    required this.itemSpacing,
    required this.indicatorSize,
    required this.indicatorShape,
    required this.labelStyle,
    required this.iconSize,
    required this.colors,
  });

  /// The selected item indicator.
  final NavIndicator indicator;

  /// Where the item group sits.
  final RailAlignment alignment;

  /// Label visibility.
  final LabelVisibility showLabels;

  /// The rail width.
  final double width;

  /// The vertical gap between items.
  final double itemSpacing;

  /// The indicator size.
  final Size indicatorSize;

  /// The indicator corners.
  final BorderRadius indicatorShape;

  /// Labels.
  final TextStyle labelStyle;

  /// Icons.
  final double iconSize;

  /// Every color it uses.
  final NavColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoNavigationRailStyle merge(CamoNavigationRailTheme? o) => o == null
      ? this
      : CamoNavigationRailStyle(
          indicator: o.indicator ?? indicator,
          alignment: o.alignment ?? alignment,
          showLabels: o.showLabels ?? showLabels,
          width: o.width ?? width,
          itemSpacing: o.itemSpacing ?? itemSpacing,
          indicatorSize: o.indicatorSize ?? indicatorSize,
          indicatorShape: o.indicatorShape ?? indicatorShape,
          labelStyle: o.labelStyle ?? labelStyle,
          iconSize: o.iconSize ?? iconSize,
          colors: o.colors ?? colors,
        );
}

/// What the rail renderer draws. [insets] is the start-side system inset (a landscape notch).
@immutable
class NavRailState {
  /// Creates the state.
  const NavRailState({
    required this.count,
    required this.selectedIndex,
    required this.insets,
  });

  /// How many items.
  final int count;

  /// The selected item, or `-1`.
  final int selectedIndex;

  /// The system insets around the rail.
  final EdgeInsets insets;
}

/// Draws navigation rails in two parts: the container (the surface, the optional header and the item column)
/// and each item.
abstract interface class CamoNavigationRailRenderer {
  /// The complete navigation rail style for [theme].
  CamoNavigationRailStyle defaults(CamoTheme theme);

  /// Draws the rail: [header] on top, fixed, and [items], one widget per destination, in a scrolling column.
  Widget renderContainer(
    BuildContext context,
    NavRailState state,
    CamoTheme theme,
    CamoNavigationRailStyle style,
    Widget? header,
    List<Widget> items,
  );

  /// Draws one item with [slots].
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationRailStyle style,
  );
}

/// The side rail for medium windows: the bar's destinations in a column on the start edge, with an optional
/// [header] (a `CamoFab` or a menu button). It scrolls when the items don't fit, and the header stays. The same
/// [CamoNavItem]s, semantics and keys as the bar, with up and down moving between items.
class CamoNavigationRail<T> extends StatelessWidget {
  /// Creates a navigation rail.
  const CamoNavigationRail({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.header,
  });

  /// The destinations.
  final List<CamoNavItem<T>> items;

  /// The selected value.
  final T selected;

  /// Called with the chosen value; `null` disables the rail.
  final ValueChanged<T>? onChanged;

  /// A FAB, a menu button.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoNavigationRail');
    final theme = Camouflage.themeOf(context, component: 'CamoNavigationRail');
    final style = skin.navigationRail
        .defaults(theme)
        .merge(theme.components.navigationRail);
    final onChanged = this.onChanged;
    final insets = MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    // No tab-bar role here: the rail scrolls, and its scroll view would sit between the bar and its tabs, which
    // Flutter's semantics rules for a tab bar don't allow.
    return Semantics(
      container: true,
      child: _NavGroup(
        host: _NavHost.rail,
        enabled: onChanged != null,
        child: CamoRovingFocus(
          child: skin.navigationRail.renderContainer(
            context,
            NavRailState(
              count: items.length,
              selectedIndex: items.indexWhere((i) => i.value == selected),
              insets: EdgeInsetsDirectional.only(
                start: insets.left,
                top: insets.top,
                bottom: insets.bottom,
              ).resolve(Directionality.of(context)),
            ),
            theme,
            style,
            header,
            [
              for (final (i, item) in items.indexed)
                CamoNavItemButton<T>(
                  item: item,
                  selected: item.value == selected,
                  onPressed: () => onChanged?.call(item.value),
                  position: CamoItemPosition(i, items.length),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------------------------- drawer

/// Overrides for navigation drawers; `null` keeps the skin's default.
@immutable
class CamoNavigationDrawerTheme {
  /// Creates overrides.
  const CamoNavigationDrawerTheme({
    this.indicator,
    this.width,
    this.itemHeight,
    this.iconSize,
    this.itemShape,
    this.modalShape,
    this.labelStyle,
    this.sectionTitleStyle,
    this.scrimAlpha,
    this.colors,
  });

  /// The selected item indicator.
  final NavIndicator? indicator;

  /// The drawer width (at most 80% of a phone window).
  final double? width;

  /// Item rows.
  final double? itemHeight;

  /// Icons.
  final double? iconSize;

  /// The selected item shape.
  final BorderRadius? itemShape;

  /// The modal container end corners.
  final BorderRadius? modalShape;

  /// Item labels.
  final TextStyle? labelStyle;

  /// Section titles.
  final TextStyle? sectionTitleStyle;

  /// The modal scrim.
  final double? scrimAlpha;

  /// Every color it uses.
  final DrawerColors? colors;

  /// A copy with the given fields replaced.
  CamoNavigationDrawerTheme copyWith({
    NavIndicator? indicator,
    double? width,
    double? itemHeight,
    double? iconSize,
    BorderRadius? itemShape,
    BorderRadius? modalShape,
    TextStyle? labelStyle,
    TextStyle? sectionTitleStyle,
    double? scrimAlpha,
    DrawerColors? colors,
  }) => CamoNavigationDrawerTheme(
    indicator: indicator ?? this.indicator,
    width: width ?? this.width,
    itemHeight: itemHeight ?? this.itemHeight,
    iconSize: iconSize ?? this.iconSize,
    itemShape: itemShape ?? this.itemShape,
    modalShape: modalShape ?? this.modalShape,
    labelStyle: labelStyle ?? this.labelStyle,
    sectionTitleStyle: sectionTitleStyle ?? this.sectionTitleStyle,
    scrimAlpha: scrimAlpha ?? this.scrimAlpha,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoNavigationDrawerTheme &&
      other.indicator == indicator &&
      other.width == width &&
      other.itemHeight == itemHeight &&
      other.iconSize == iconSize &&
      other.itemShape == itemShape &&
      other.modalShape == modalShape &&
      other.labelStyle == labelStyle &&
      other.sectionTitleStyle == sectionTitleStyle &&
      other.scrimAlpha == scrimAlpha &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    indicator,
    width,
    itemHeight,
    iconSize,
    itemShape,
    modalShape,
    labelStyle,
    sectionTitleStyle,
    scrimAlpha,
    colors,
  );
}

/// The resolved navigation drawer style: every field set.
@immutable
class CamoNavigationDrawerStyle {
  /// Creates a style.
  const CamoNavigationDrawerStyle({
    required this.indicator,
    required this.width,
    required this.itemHeight,
    required this.iconSize,
    required this.itemShape,
    required this.modalShape,
    required this.labelStyle,
    required this.sectionTitleStyle,
    required this.scrimAlpha,
    required this.colors,
  });

  /// The selected item indicator.
  final NavIndicator indicator;

  /// The drawer width (at most 80% of a phone window).
  final double width;

  /// Item rows.
  final double itemHeight;

  /// Icons.
  final double iconSize;

  /// The selected item shape.
  final BorderRadius itemShape;

  /// The modal container end corners.
  final BorderRadius modalShape;

  /// Item labels.
  final TextStyle labelStyle;

  /// Section titles.
  final TextStyle sectionTitleStyle;

  /// The modal scrim.
  final double scrimAlpha;

  /// Every color it uses.
  final DrawerColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoNavigationDrawerStyle merge(CamoNavigationDrawerTheme? o) => o == null
      ? this
      : CamoNavigationDrawerStyle(
          indicator: o.indicator ?? indicator,
          width: o.width ?? width,
          itemHeight: o.itemHeight ?? itemHeight,
          iconSize: o.iconSize ?? iconSize,
          itemShape: o.itemShape ?? itemShape,
          modalShape: o.modalShape ?? modalShape,
          labelStyle: o.labelStyle ?? labelStyle,
          sectionTitleStyle: o.sectionTitleStyle ?? sectionTitleStyle,
          scrimAlpha: o.scrimAlpha ?? scrimAlpha,
          colors: o.colors ?? colors,
        );
}

/// What the drawer renderer draws: [modal] while it slides over the content, permanent beside it.
@immutable
class DrawerState {
  /// Creates the state.
  const DrawerState({required this.modal});

  /// Whether it is modal.
  final bool modal;
}

/// Draws navigation drawers in three parts: the container (the surface, the optional header and the scrolling
/// column), the section titles and each item.
abstract interface class CamoNavigationDrawerRenderer {
  /// The complete navigation drawer style for [theme].
  CamoNavigationDrawerStyle defaults(CamoTheme theme);

  /// Draws the drawer: [header] on top, fixed, and [children] (titles and items) in a scrolling column.
  Widget renderContainer(
    BuildContext context,
    DrawerState state,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
    Widget? header,
    List<Widget> children,
  );

  /// Draws a section [title].
  Widget renderSectionTitle(
    BuildContext context,
    String title,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
  );

  /// Draws one item with [slots].
  Widget renderItem(
    BuildContext context,
    NavItemState state,
    NavItemSlots slots,
    CamoTheme theme,
    CamoNavigationDrawerStyle style,
  );
}

class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoNavigationDrawer');
    final theme = Camouflage.themeOf(
      context,
      component: 'CamoNavigationDrawer',
    );
    final style = skin.navigationDrawer
        .defaults(theme)
        .merge(theme.components.navigationDrawer);
    return Semantics(
      header: true,
      child: skin.navigationDrawer.renderSectionTitle(
        context,
        title,
        theme,
        style,
      ),
    );
  }
}

/// A drawer with full labels and section headers: permanent beside the content on wide windows, or inside a
/// [CamoModalDrawer]. Selecting an item inside a modal drawer closes it. Section titles are headings; the
/// column scrolls and the [header] (a logo, an account switcher) stays.
class CamoNavigationDrawer<T> extends StatelessWidget {
  /// Creates a navigation drawer.
  const CamoNavigationDrawer({
    super.key,
    required this.sections,
    required this.selected,
    required this.onChanged,
    this.header,
  });

  /// The sections; one untitled section for a plain list.
  final List<CamoNavSection<T>> sections;

  /// The selected value.
  final T selected;

  /// Called with the chosen value; `null` disables the drawer.
  final ValueChanged<T>? onChanged;

  /// A logo, an account switcher.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoNavigationDrawer');
    final theme = Camouflage.themeOf(
      context,
      component: 'CamoNavigationDrawer',
    );
    final style = skin.navigationDrawer
        .defaults(theme)
        .merge(theme.components.navigationDrawer);
    final onChanged = this.onChanged;
    final count = sections.fold<int>(0, (n, s) => n + s.items.length);
    var index = 0;
    final modal =
        context.dependOnInheritedWidgetOfExactType<_DrawerScope>() != null;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Navigation',
      child: _NavGroup(
        host: _NavHost.drawer,
        enabled: onChanged != null,
        child: CamoRovingFocus(
          child: skin.navigationDrawer.renderContainer(
            context,
            DrawerState(modal: modal),
            theme,
            style,
            header,
            [
              for (final section in sections) ...[
                if (section.title != null) _DrawerSectionTitle(section.title!),
                for (final item in section.items)
                  CamoNavItemButton<T>(
                    item: item,
                    selected: item.value == selected,
                    onPressed: () => onChanged?.call(item.value),
                    position: CamoItemPosition(index++, count),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The modal mode (a phone with many destinations): slides in from the start edge over the content, with a
/// scrim. Its visibility is state ([open]), not a route: a menu button opens it and a selection closes it. A
/// scrim tap, back, Esc and a drag toward the start edge all call [onDismissRequest]; focus moves in and stays
/// in. [child] is a [CamoNavigationDrawer]. Place it where an `Overlay` is above it (inside a `WidgetsApp`).
class CamoModalDrawer extends StatefulWidget {
  /// Creates a modal drawer.
  const CamoModalDrawer({
    super.key,
    required this.open,
    required this.onDismissRequest,
    required this.child,
  });

  /// Whether the drawer is shown.
  final bool open;

  /// Called by a scrim tap, back, Esc or a drag toward the start edge.
  final VoidCallback onDismissRequest;

  /// A [CamoNavigationDrawer].
  final Widget child;

  @override
  State<CamoModalDrawer> createState() => _CamoModalDrawerState();
}

class _CamoModalDrawerState extends State<CamoModalDrawer>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  late final _controller = AnimationController(vsync: this);
  var _duration = const Duration(milliseconds: 200);
  Curve _curve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _portal.isShowing) {
        _portal.hide();
      }
    });
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(CamoModalDrawer old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      if (widget.open) {
        // The portal can't be shown while the tree is building.
        WidgetsBinding.instance.addPostFrameCallback((_) => _show());
      } else {
        _controller.animateBack(0, duration: _duration, curve: _curve);
      }
    }
  }

  void _show() {
    if (!mounted) return;
    _portal.show();
    _controller.animateTo(1, duration: _duration, curve: _curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoModalDrawer');
    final theme = Camouflage.themeOf(context, component: 'CamoModalDrawer');
    final style = skin.navigationDrawer
        .defaults(theme)
        .merge(theme.components.navigationDrawer);
    _duration = theme.motion.durationMedium;
    _curve = theme.motion.easingEmphasized;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return PopScope(
      canPop: !widget.open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onDismissRequest();
      },
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape):
                widget.onDismissRequest,
          },
          child: FocusScope(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = style.width < constraints.maxWidth * 0.8
                    ? style.width
                    : constraints.maxWidth * 0.8;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onDismissRequest,
                            child: ColoredBox(
                              color: theme.colors.scrim.withValues(
                                alpha: style.scrimAlpha * t,
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: -width * (1 - t),
                          top: 0,
                          bottom: 0,
                          width: width,
                          child: GestureDetector(
                            onHorizontalDragUpdate: (d) => _controller.value +=
                                (rtl ? d.delta.dx : -d.delta.dx) / width,
                            onHorizontalDragEnd: (d) {
                              final v = (rtl ? 1 : -1) * d.primaryVelocity!;
                              if (_controller.value < 0.6 || v > 1200) {
                                widget.onDismissRequest();
                              } else {
                                _controller.animateTo(1);
                              }
                            },
                            child: child,
                          ),
                        ),
                      ],
                    );
                  },
                  child: _DrawerScope(
                    onNavigate: widget.onDismissRequest,
                    child: widget.child,
                  ),
                );
              },
            ),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

// --------------------------------------------------------------------------------------------- adaptive

/// Picks the navigation chrome for the window (ADR-41): a bottom [CamoNavigationBar] on a compact window, a
/// [CamoNavigationRail] on medium and expanded ones, and a permanent [CamoNavigationDrawer] on large ones, by
/// the theme's `breakpoints`. The [child] keeps its state when the window resizes and the layout switches.
/// [header] (a FAB, a logo) goes on the rail and the drawer.
class CamoAdaptiveNavigation<T> extends StatefulWidget {
  /// Creates the adaptive layout.
  const CamoAdaptiveNavigation({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.child,
    this.header,
  });

  /// The destinations.
  final List<CamoNavItem<T>> items;

  /// The selected value.
  final T selected;

  /// Called with the chosen value.
  final ValueChanged<T>? onChanged;

  /// The current destination's screen.
  final Widget child;

  /// A FAB or logo for the rail and the drawer.
  final Widget? header;

  @override
  State<CamoAdaptiveNavigation<T>> createState() =>
      _CamoAdaptiveNavigationState<T>();
}

class _CamoAdaptiveNavigationState<T> extends State<CamoAdaptiveNavigation<T>> {
  final _bodyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // A global key lets the screen move between the layouts below without losing its state.
    final body = KeyedSubtree(key: _bodyKey, child: widget.child);
    return switch (Camouflage.environmentOf(context).windowSize) {
      WindowSizeClass.compact => Column(
        children: [
          Expanded(child: body),
          CamoNavigationBar<T>(
            items: widget.items,
            selected: widget.selected,
            onChanged: widget.onChanged,
          ),
        ],
      ),
      WindowSizeClass.medium || WindowSizeClass.expanded => Row(
        children: [
          CamoNavigationRail<T>(
            items: widget.items,
            selected: widget.selected,
            onChanged: widget.onChanged,
            header: widget.header,
          ),
          Expanded(child: body),
        ],
      ),
      WindowSizeClass.large => Row(
        children: [
          CamoNavigationDrawer<T>(
            sections: [CamoNavSection(items: widget.items)],
            selected: widget.selected,
            onChanged: widget.onChanged,
            header: widget.header,
          ),
          Expanded(child: body),
        ],
      ),
    };
  }
}
