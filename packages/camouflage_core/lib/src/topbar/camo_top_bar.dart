import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';

/// When a top bar draws the line under it.
enum TopBarDivider {
  /// Never.
  never,

  /// While content is scrolled under the bar.
  whenScrolled,

  /// Always.
  always,
}

/// Every color a top bar uses.
@immutable
class TopBarColors {
  /// Creates TopBarColors.
  const TopBarColors({
    required this.container,
    required this.scrolledContainer,
    required this.title,
    required this.navigation,
    required this.actions,
    required this.divider,
  });

  /// The bar at rest.
  final Color container;

  /// The bar with content under it.
  final Color scrolledContainer;

  /// The title.
  final Color title;

  /// The navigation icon.
  final Color navigation;

  /// The action icons.
  final Color actions;

  /// The line under the bar.
  final Color divider;

  @override
  bool operator ==(Object other) =>
      other is TopBarColors &&
      other.container == container &&
      other.scrolledContainer == scrolledContainer &&
      other.title == title &&
      other.navigation == navigation &&
      other.actions == actions &&
      other.divider == divider;

  @override
  int get hashCode => Object.hash(
    container,
    scrolledContainer,
    title,
    navigation,
    actions,
    divider,
  );
}

/// Overrides for top bars; `null` keeps the skin's default.
@immutable
class CamoTopBarTheme {
  /// Creates CamoTopBarTheme.
  const CamoTopBarTheme({
    this.titleAlign,
    this.divider,
    this.height,
    this.titleStyle,
    this.iconSize,
    this.padding,
    this.actionGap,
    this.dividerWidth,
    this.colors,
  });

  /// Where the title sits.
  final CamoTitleAlign? titleAlign;

  /// When the line under the bar shows.
  final TopBarDivider? divider;

  /// The bar's height (it grows with a large title).
  final double? height;

  /// The title.
  final TextStyle? titleStyle;

  /// The ambient icon size for navigation and actions.
  final double? iconSize;

  /// The row's padding.
  final EdgeInsetsDirectional? padding;

  /// Between actions.
  final double? actionGap;

  /// The line's thickness.
  final double? dividerWidth;

  /// Every color it uses.
  final TopBarColors? colors;

  /// A copy with the given fields replaced.
  CamoTopBarTheme copyWith({
    CamoTitleAlign? titleAlign,
    TopBarDivider? divider,
    double? height,
    TextStyle? titleStyle,
    double? iconSize,
    EdgeInsetsDirectional? padding,
    double? actionGap,
    double? dividerWidth,
    TopBarColors? colors,
  }) => CamoTopBarTheme(
    titleAlign: titleAlign ?? this.titleAlign,
    divider: divider ?? this.divider,
    height: height ?? this.height,
    titleStyle: titleStyle ?? this.titleStyle,
    iconSize: iconSize ?? this.iconSize,
    padding: padding ?? this.padding,
    actionGap: actionGap ?? this.actionGap,
    dividerWidth: dividerWidth ?? this.dividerWidth,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoTopBarTheme &&
      other.titleAlign == titleAlign &&
      other.divider == divider &&
      other.height == height &&
      other.titleStyle == titleStyle &&
      other.iconSize == iconSize &&
      other.padding == padding &&
      other.actionGap == actionGap &&
      other.dividerWidth == dividerWidth &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    titleAlign,
    divider,
    height,
    titleStyle,
    iconSize,
    padding,
    actionGap,
    dividerWidth,
    colors,
  );
}

/// The resolved top bar style: every field set.
@immutable
class CamoTopBarStyle {
  /// Creates CamoTopBarStyle.
  const CamoTopBarStyle({
    required this.titleAlign,
    required this.divider,
    required this.height,
    required this.titleStyle,
    required this.iconSize,
    required this.padding,
    required this.actionGap,
    required this.dividerWidth,
    required this.colors,
  });

  /// Where the title sits.
  final CamoTitleAlign titleAlign;

  /// When the line under the bar shows.
  final TopBarDivider divider;

  /// The bar's height (it grows with a large title).
  final double height;

  /// The title.
  final TextStyle titleStyle;

  /// The ambient icon size for navigation and actions.
  final double iconSize;

  /// The row's padding.
  final EdgeInsetsDirectional padding;

  /// Between actions.
  final double actionGap;

  /// The line's thickness.
  final double dividerWidth;

  /// Every color it uses.
  final TopBarColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoTopBarStyle merge(CamoTopBarTheme? o) => o == null
      ? this
      : CamoTopBarStyle(
          titleAlign: o.titleAlign ?? titleAlign,
          divider: o.divider ?? divider,
          height: o.height ?? height,
          titleStyle: o.titleStyle ?? titleStyle,
          iconSize: o.iconSize ?? iconSize,
          padding: o.padding ?? padding,
          actionGap: o.actionGap ?? actionGap,
          dividerWidth: o.dividerWidth ?? dividerWidth,
          colors: o.colors ?? colors,
        );

  /// Whether the bar shows its divider at [scrollOffset].
  bool showsDivider(double scrollOffset) => switch (divider) {
    TopBarDivider.never => false,
    TopBarDivider.whenScrolled => scrollOffset > 0,
    TopBarDivider.always => true,
  };
}

/// What a top bar renderer draws. [scrollOffset] is how far content has scrolled under the bar
/// (`double.infinity` when the exact distance is unknown: fully scrolled). Draw the background behind the
/// status bar and pad only the content row by [insets].
@immutable
class TopBarState {
  /// Creates a top bar state.
  const TopBarState({
    required this.title,
    required this.scrollOffset,
    required this.insets,
  });

  /// The bar's title (empty for a custom header).
  final String title;

  /// How far content is scrolled under the bar.
  final double scrollOffset;

  /// The status bar and cutout padding for the content row.
  final EdgeInsets insets;

  /// Whether any content is under the bar.
  bool get scrolled => scrollOffset > 0;
}

/// The caller's parts. [titleContent] replaces the drawn title (a search field, a logo); core has already
/// added the title as a header in front of it. Draw the [TopBarState.title] otherwise, in
/// `Semantics(header: true)`. Set the ambient icon style around [navigation] and [actions].
@immutable
class TopBarSlots {
  /// Creates the slots.
  const TopBarSlots({
    required this.navigation,
    required this.actions,
    required this.titleContent,
  });

  /// The back or menu button.
  final Widget? navigation;

  /// The action buttons.
  final List<Widget> actions;

  /// A custom title.
  final Widget? titleContent;
}

/// Draws top bars.
abstract interface class CamoTopBarRenderer {
  /// The complete top bar style for [theme].
  CamoTopBarStyle defaults(CamoTheme theme);

  /// Draws the bar: navigation, the title placed by `style.titleAlign`, and the actions at the end.
  Widget render(
    BuildContext context,
    TopBarState state,
    TopBarSlots slots,
    CamoTheme theme,
    CamoTopBarStyle style,
  );

  /// Draws the bar's surface, scrolled tint, divider and insets around a custom header's [child].
  Widget container(
    BuildContext context,
    TopBarState state,
    Widget child,
    CamoTheme theme,
    CamoTopBarStyle style,
  );
}

EdgeInsets _barInsets(BuildContext context) {
  final p = MediaQuery.paddingOf(context);
  return EdgeInsets.only(left: p.left, top: p.top, right: p.right);
}

/// A screen's top bar: a [title], a [navigation] button, and [actions] (icon buttons; extras go in a "More"
/// menu). The skin decides where they sit. Pass [scrollOffset] from a [CamoTopBarScrollOffset] so the bar
/// separates from content scrolled under it. [titleContent] replaces the drawn title; [title] stays the bar's
/// header for screen readers. `visible: false` slides the bar up out of view (with [CamoHideOnScroll]).
/// [insets] defaults to the status bar and cutout padding.
class CamoTopBar extends StatelessWidget {
  /// Creates a top bar.
  const CamoTopBar({
    super.key,
    required this.title,
    this.navigation,
    this.actions = const [],
    this.scrollOffset = 0,
    this.titleContent,
    this.visible = true,
    this.insets,
  });

  /// The screen's name.
  final String title;

  /// Usually a back `CamoIconButton`.
  final Widget? navigation;

  /// Usually `CamoIconButton`s.
  final List<Widget> actions;

  /// How far content has scrolled under the bar.
  final double scrollOffset;

  /// Replaces the drawn title.
  final Widget? titleContent;

  /// `false` slides the bar out of view.
  final bool visible;

  /// The padding for the status bar and cutouts; `null` reads `MediaQuery`.
  final EdgeInsets? insets;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTopBar');
    final theme = Camouflage.themeOf(context, component: 'CamoTopBar');
    final style = skin.topBar.defaults(theme).merge(theme.components.topBar);
    final custom = titleContent;
    return _HideOnScroll(
      visible: visible,
      theme: theme,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: skin.topBar.render(
          context,
          TopBarState(
            title: title,
            scrollOffset: scrollOffset,
            insets: insets ?? _barInsets(context),
          ),
          TopBarSlots(
            navigation: navigation,
            actions: actions,
            titleContent: custom == null
                ? null
                : Stack(
                    children: [
                      // The bar's name, first in reading order, over the custom title.
                      Positioned.fill(
                        child: Semantics(
                          header: true,
                          label: title,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      custom,
                    ],
                  ),
          ),
          theme,
          style,
        ),
      ),
    );
  }
}

/// A custom header (a profile hero, a big search header) with the top bar's surface, scrolled tint, divider
/// and insets. Place your own title (in `Semantics(header: true)`) and buttons in [child].
class CamoTopBarContainer extends StatelessWidget {
  /// Creates a container around [child].
  const CamoTopBarContainer({
    super.key,
    this.scrollOffset = 0,
    this.visible = true,
    this.insets,
    required this.child,
  });

  /// How far content has scrolled under the header.
  final double scrollOffset;

  /// `false` slides the header out of view.
  final bool visible;

  /// The padding for the status bar and cutouts; `null` reads `MediaQuery`.
  final EdgeInsets? insets;

  /// The header's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTopBarContainer');
    final theme = Camouflage.themeOf(context, component: 'CamoTopBarContainer');
    final style = skin.topBar.defaults(theme).merge(theme.components.topBar);
    return _HideOnScroll(
      visible: visible,
      theme: theme,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: skin.topBar.container(
          context,
          TopBarState(
            title: '',
            scrollOffset: scrollOffset,
            insets: insets ?? _barInsets(context),
          ),
          child,
          theme,
          style,
        ),
      ),
    );
  }
}

class _HideOnScroll extends StatelessWidget {
  const _HideOnScroll({
    required this.visible,
    required this.theme,
    required this.child,
  });

  final bool visible;
  final CamoTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: AnimatedAlign(
      alignment: AlignmentDirectional.bottomStart,
      heightFactor: visible ? 1 : 0,
      duration: theme.motion.durationMedium,
      curve: theme.motion.easingStandard,
      child: child,
    ),
  );
}

/// How far a scrollable has scrolled under a top bar, from its [ScrollController] (clamped at 0). Dispose it
/// with the controller's owner.
class CamoTopBarScrollOffset extends ValueNotifier<double> {
  /// Follows [controller].
  CamoTopBarScrollOffset(this.controller) : super(0) {
    controller.addListener(_update);
  }

  /// The followed controller.
  final ScrollController controller;

  void _update() {
    if (!controller.hasClients) return;
    value = controller.offset.clamp(0, double.infinity);
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    super.dispose();
  }
}

/// Whether a bar over a scrollable should show: hidden while scrolling down, shown when scrolling up or at the
/// top. Dispose it with the controller's owner.
class CamoHideOnScroll extends ValueNotifier<bool> {
  /// Follows [controller].
  CamoHideOnScroll(this.controller) : super(true) {
    controller.addListener(_update);
  }

  /// The followed controller.
  final ScrollController controller;
  double _last = 0;

  void _update() {
    if (!controller.hasClients) return;
    final offset = controller.offset;
    if (offset <= 0) {
      value = true;
    } else if (offset > _last) {
      value = false;
    } else if (offset < _last) {
      value = true;
    }
    _last = offset;
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    super.dispose();
  }
}

enum _Part { navigation, title, actions }

/// The top bar's row, for renderers: [navigation] at the start, [actions] at the end ([actionGap] apart), and
/// [title] at the start between them or centered in the bar's width. A centered title shrinks only when a side
/// would overlap it. Children are centered vertically; the row is [minHeight] tall.
class CamoTopBarRow extends StatelessWidget {
  /// Creates the row.
  const CamoTopBarRow({
    super.key,
    required this.titleAlign,
    required this.minHeight,
    required this.actionGap,
    required this.navigation,
    required this.title,
    required this.actions,
  });

  /// Where the title sits.
  final CamoTitleAlign titleAlign;

  /// The row's minimum height.
  final double minHeight;

  /// Between actions.
  final double actionGap;

  /// At the start.
  final Widget? navigation;

  /// The title.
  final Widget title;

  /// At the end.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final nav = navigation;
    return CustomMultiChildLayout(
      delegate: _BarLayout(titleAlign, minHeight, Directionality.of(context)),
      children: [
        if (nav != null) LayoutId(id: _Part.navigation, child: nav),
        LayoutId(id: _Part.title, child: title),
        LayoutId(
          id: _Part.actions,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: actionGap,
            children: actions,
          ),
        ),
      ],
    );
  }
}

class _BarLayout extends MultiChildLayoutDelegate {
  _BarLayout(this.align, this.minHeight, this.direction);

  final CamoTitleAlign align;
  final double minHeight;
  final TextDirection direction;

  // CustomMultiChildLayout can't size itself from its children, so the row is minHeight tall (within the
  // constraints); the title is measured in full and centered.
  @override
  void performLayout(Size size) {
    final loose = BoxConstraints.loose(size);
    final nav = hasChild(_Part.navigation)
        ? layoutChild(_Part.navigation, loose)
        : Size.zero;
    final act = layoutChild(_Part.actions, loose);
    final free = (size.width - nav.width - act.width).clamp(0.0, size.width);
    // Centered in the full width: as wide as the wider side leaves on both sides.
    final side = math.max(nav.width, act.width);
    final titleMax = align == CamoTitleAlign.center
        ? math.max(0.0, (size.width / 2 - side) * 2)
        : free;
    final ttl = layoutChild(
      _Part.title,
      BoxConstraints(maxWidth: titleMax, maxHeight: size.height),
    );
    double x(double start, double width) =>
        direction == TextDirection.rtl ? size.width - start - width : start;
    if (hasChild(_Part.navigation)) {
      positionChild(
        _Part.navigation,
        Offset(x(0, nav.width), (size.height - nav.height) / 2),
      );
    }
    final titleStart = align == CamoTitleAlign.center
        ? (size.width - ttl.width) / 2
        : nav.width;
    positionChild(
      _Part.title,
      Offset(x(titleStart, ttl.width), (size.height - ttl.height) / 2),
    );
    positionChild(
      _Part.actions,
      Offset(
        x(size.width - act.width, act.width),
        (size.height - act.height) / 2,
      ),
    );
  }

  @override
  Size getSize(BoxConstraints constraints) =>
      Size(constraints.maxWidth, constraints.constrainHeight(minHeight));

  @override
  bool shouldRelayout(_BarLayout old) =>
      old.align != align ||
      old.minHeight != minHeight ||
      old.direction != direction;
}
