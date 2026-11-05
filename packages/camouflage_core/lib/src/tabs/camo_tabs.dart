import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';

/// How wide the selected-tab indicator is.
enum IndicatorWidth {
  /// As wide as the tab's content.
  content,

  /// As wide as the whole tab.
  tab,
}

/// Every color a tab bar uses.
@immutable
class TabsColors {
  /// Creates TabsColors.
  const TabsColors({
    required this.container,
    required this.selected,
    required this.unselected,
    required this.indicator,
    required this.divider,
  });

  /// The bar's fill.
  final Color container;

  /// The selected tab's label and icon.
  final Color selected;

  /// The other tabs' labels and icons.
  final Color unselected;

  /// The indicator under the selected tab.
  final Color indicator;

  /// The line below the bar.
  final Color divider;

  @override
  bool operator ==(Object other) =>
      other is TabsColors &&
      other.container == container &&
      other.selected == selected &&
      other.unselected == unselected &&
      other.indicator == indicator &&
      other.divider == divider;

  @override
  int get hashCode =>
      Object.hash(container, selected, unselected, indicator, divider);
}

/// Overrides for tab bars; `null` keeps the skin's default.
@immutable
class CamoTabsTheme {
  /// Creates overrides.
  const CamoTabsTheme({
    this.defaultAppearance,
    this.height,
    this.heightWithIcon,
    this.indicatorHeight,
    this.indicatorWidth,
    this.labelStyle,
    this.iconSize,
    this.iconGap,
    this.tabPadding,
    this.minTabWidth,
    this.showDivider,
    this.solidColors,
    this.ghostColors,
  });

  /// The appearance used when a call passes none (ADR-28): solid is prominent, ghost quiet.
  final Appearance? defaultAppearance;

  /// The bar height.
  final double? height;

  /// The bar height when tabs show an icon and a label.
  final double? heightWithIcon;

  /// The indicator thickness.
  final double? indicatorHeight;

  /// Whether the indicator is as wide as the content or the whole tab.
  final IndicatorWidth? indicatorWidth;

  /// The labels.
  final TextStyle? labelStyle;

  /// The icons.
  final double? iconSize;

  /// The gap between a tab's icon, label and badge.
  final double? iconGap;

  /// The horizontal padding of a tab.
  final double? tabPadding;

  /// The narrowest a tab gets when the bar scrolls.
  final double? minTabWidth;

  /// The line below the bar.
  final bool? showDivider;

  /// The prominent bar's colors.
  final TabsColors? solidColors;

  /// The quiet bar's colors.
  final TabsColors? ghostColors;

  /// A copy with the given fields replaced.
  CamoTabsTheme copyWith({
    Appearance? defaultAppearance,
    double? height,
    double? heightWithIcon,
    double? indicatorHeight,
    IndicatorWidth? indicatorWidth,
    TextStyle? labelStyle,
    double? iconSize,
    double? iconGap,
    double? tabPadding,
    double? minTabWidth,
    bool? showDivider,
    TabsColors? solidColors,
    TabsColors? ghostColors,
  }) => CamoTabsTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    height: height ?? this.height,
    heightWithIcon: heightWithIcon ?? this.heightWithIcon,
    indicatorHeight: indicatorHeight ?? this.indicatorHeight,
    indicatorWidth: indicatorWidth ?? this.indicatorWidth,
    labelStyle: labelStyle ?? this.labelStyle,
    iconSize: iconSize ?? this.iconSize,
    iconGap: iconGap ?? this.iconGap,
    tabPadding: tabPadding ?? this.tabPadding,
    minTabWidth: minTabWidth ?? this.minTabWidth,
    showDivider: showDivider ?? this.showDivider,
    solidColors: solidColors ?? this.solidColors,
    ghostColors: ghostColors ?? this.ghostColors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoTabsTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.height == height &&
      other.heightWithIcon == heightWithIcon &&
      other.indicatorHeight == indicatorHeight &&
      other.indicatorWidth == indicatorWidth &&
      other.labelStyle == labelStyle &&
      other.iconSize == iconSize &&
      other.iconGap == iconGap &&
      other.tabPadding == tabPadding &&
      other.minTabWidth == minTabWidth &&
      other.showDivider == showDivider &&
      other.solidColors == solidColors &&
      other.ghostColors == ghostColors;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    height,
    heightWithIcon,
    indicatorHeight,
    indicatorWidth,
    labelStyle,
    iconSize,
    iconGap,
    tabPadding,
    minTabWidth,
    showDivider,
    solidColors,
    ghostColors,
  );
}

/// The resolved tab bar style: every field set.
@immutable
class CamoTabsStyle {
  /// Creates a style.
  const CamoTabsStyle({
    required this.defaultAppearance,
    required this.height,
    required this.heightWithIcon,
    required this.indicatorHeight,
    required this.indicatorWidth,
    required this.labelStyle,
    required this.iconSize,
    required this.iconGap,
    required this.tabPadding,
    required this.minTabWidth,
    required this.showDivider,
    required this.solidColors,
    required this.ghostColors,
  });

  /// The appearance used when a call passes none (ADR-28): solid is prominent, ghost quiet.
  final Appearance defaultAppearance;

  /// The bar height.
  final double height;

  /// The bar height when tabs show an icon and a label.
  final double heightWithIcon;

  /// The indicator thickness.
  final double indicatorHeight;

  /// Whether the indicator is as wide as the content or the whole tab.
  final IndicatorWidth indicatorWidth;

  /// The labels.
  final TextStyle labelStyle;

  /// The icons.
  final double iconSize;

  /// The gap between a tab's icon, label and badge.
  final double iconGap;

  /// The horizontal padding of a tab.
  final double tabPadding;

  /// The narrowest a tab gets when the bar scrolls.
  final double minTabWidth;

  /// The line below the bar.
  final bool showDivider;

  /// The prominent bar's colors.
  final TabsColors solidColors;

  /// The quiet bar's colors.
  final TabsColors ghostColors;

  /// This style with [o]'s non-null fields applied.
  CamoTabsStyle merge(CamoTabsTheme? o) => o == null
      ? this
      : CamoTabsStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          height: o.height ?? height,
          heightWithIcon: o.heightWithIcon ?? heightWithIcon,
          indicatorHeight: o.indicatorHeight ?? indicatorHeight,
          indicatorWidth: o.indicatorWidth ?? indicatorWidth,
          labelStyle: o.labelStyle ?? labelStyle,
          iconSize: o.iconSize ?? iconSize,
          iconGap: o.iconGap ?? iconGap,
          tabPadding: o.tabPadding ?? tabPadding,
          minTabWidth: o.minTabWidth ?? minTabWidth,
          showDivider: o.showDivider ?? showDivider,
          solidColors: o.solidColors ?? solidColors,
          ghostColors: o.ghostColors ?? ghostColors,
        );

  /// The colors for [appearance]: ghost is the quiet bar, everything else the prominent one.
  TabsColors colorsFor(Appearance appearance) =>
      appearance == Appearance.ghost ? ghostColors : solidColors;
}

/// The appearance a tab bar draws for [appearance]: solid (prominent) or ghost (quiet); the others are solid.
Appearance tabsAppearance(Appearance appearance) =>
    appearance == Appearance.ghost ? Appearance.ghost : Appearance.solid;

/// One tab of a [CamoTabs]. It needs a [label] or an [icon]; an icon-only tab needs a [semanticLabel]. The
/// [badge] is the app's own (a `CamoBadge`).
@immutable
class CamoTab<T> {
  /// Creates a tab.
  const CamoTab(
    this.value, {
    this.label,
    this.icon,
    this.badge,
    this.semanticLabel,
    this.enabled = true,
  });

  /// What choosing it selects.
  final T value;

  /// The tab's label.
  final String? label;

  /// The tab's icon.
  final Widget? icon;

  /// A badge after the label.
  final Widget? badge;

  /// Names an icon-only tab.
  final String? semanticLabel;

  /// `false` disables this tab only.
  final bool enabled;
}

/// Where the selected tab's indicator is, in logical pixels from the start of the tab row.
@immutable
class TabIndicator {
  /// Creates an indicator place.
  const TabIndicator(this.start, this.width);

  /// Its left edge.
  final double start;

  /// Its width.
  final double width;

  /// The place [t] of the way from [a] to [b].
  static TabIndicator? lerp(TabIndicator? a, TabIndicator? b, double t) {
    if (a == null || b == null) return t < 0.5 ? a : b;
    return TabIndicator(
      a.start + (b.start - a.start) * t,
      a.width + (b.width - a.width) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TabIndicator && other.start == start && other.width == width;

  @override
  int get hashCode => Object.hash(start, width);
}

/// What the container renderer draws. [indicator] changes while the indicator animates, so a painter should
/// listen to it instead of rebuilding; it is `null` while no tab is selected.
@immutable
class TabsState {
  /// Creates the container state.
  const TabsState({
    required this.count,
    required this.selectedIndex,
    required this.scrollable,
    required this.appearance,
    required this.indicator,
  });

  /// How many tabs.
  final int count;

  /// The selected tab, or `-1`.
  final int selectedIndex;

  /// Whether the row scrolls.
  final bool scrollable;

  /// Solid (prominent) or ghost (quiet).
  final Appearance appearance;

  /// Where the indicator is.
  final ValueListenable<TabIndicator?> indicator;
}

/// What a tab renderer draws: one tab at [position].
@immutable
class TabState {
  /// Creates a tab state.
  const TabState({
    required this.selected,
    required this.enabled,
    required this.position,
    required this.scrollable,
    required this.appearance,
    required this.interaction,
    required this.controller,
  });

  /// Whether it's the selected tab.
  final bool selected;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Its place in the row.
  final CamoItemPosition position;

  /// Whether the row scrolls (tabs keep their natural width).
  final bool scrollable;

  /// Solid (prominent) or ghost (quiet).
  final Appearance appearance;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// A tab's content: its [label], [icon] and [badge], or a building block's custom [child] instead of all three.
/// The renderer puts [contentKey] on the node that wraps what it draws, so the indicator can be as wide as the
/// content.
@immutable
class TabSlots {
  /// Creates the slots.
  const TabSlots({
    this.label,
    this.icon,
    this.badge,
    this.child,
    required this.contentKey,
  });

  /// The label.
  final String? label;

  /// The icon.
  final Widget? icon;

  /// The badge.
  final Widget? badge;

  /// Custom content, replacing the label, icon and badge.
  final Widget? child;

  /// For the node that wraps the tab's content.
  final GlobalKey contentKey;
}

/// Draws tab bars in two parts: the container (the surface, the divider and the indicator around the row of
/// tabs) and each tab.
abstract interface class CamoTabsRenderer {
  /// The complete tab bar style for [theme].
  CamoTabsStyle defaults(CamoTheme theme);

  /// Draws the bar around the tab row. Call [row] once with a painter that draws the indicator behind the tabs
  /// (inside the scrolled content, so it moves with them) and place the result; draw the divider on the bar.
  Widget renderContainer(
    BuildContext context,
    TabsState state,
    CamoTheme theme,
    CamoTabsStyle style,
    Widget Function(CustomPainter indicatorPainter) row,
  );

  /// Draws one tab with [slots].
  Widget renderTab(
    BuildContext context,
    TabState state,
    TabSlots slots,
    CamoTheme theme,
    CamoTabsStyle style,
  );
}

// A tab's place in the row: the whole tab and its content.
class _TabBounds {
  const _TabBounds(
    this.start,
    this.width,
    this.contentStart,
    this.contentWidth,
  );

  final double start;
  final double width;
  final double contentStart;
  final double contentWidth;

  TabIndicator indicator(IndicatorWidth mode) => mode == IndicatorWidth.content
      ? TabIndicator(contentStart, contentWidth)
      : TabIndicator(start, width);
}

// The keys each tab registers so the container can measure it.
class _TabsRegistry {
  final tabKeys = <int, GlobalKey>{};
  final contentKeys = <int, GlobalKey>{};

  void register(int index, GlobalKey tab, GlobalKey content) {
    tabKeys[index] = tab;
    contentKeys[index] = content;
  }

  void unregister(int index, GlobalKey tab) {
    if (tabKeys[index] == tab) {
      tabKeys.remove(index);
      contentKeys.remove(index);
    }
  }
}

class _TabsScope extends InheritedWidget {
  const _TabsScope({
    required this.registry,
    required this.scrollable,
    required this.appearance,
    required this.enabled,
    required super.child,
  });

  final _TabsRegistry registry;
  final bool scrollable;
  final Appearance appearance;
  final bool enabled;

  @override
  bool updateShouldNotify(_TabsScope oldWidget) =>
      scrollable != oldWidget.scrollable ||
      appearance != oldWidget.appearance ||
      enabled != oldWidget.enabled;
}

/// A bar of tabs ("Overview / Reviews / Specs"): [selected] in, [onChanged] out, an animated indicator under
/// the selected tab, one Tab stop with the arrow keys moving and selecting. Fixed tabs share the width; with
/// [scrollable] they keep their natural width, the row scrolls and the selection stays in view. The content
/// below is the app's layout; [CamoTabsPageSync] keeps a `PageView` in step and, passed as [position], makes
/// the indicator follow a swipe. `onChanged: null` disables the bar.
class CamoTabs<T> extends StatelessWidget {
  /// Creates a tab bar.
  const CamoTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.tabs,
    this.scrollable = false,
    this.appearance,
    this.position,
  });

  /// The selected value.
  final T selected;

  /// Called with the chosen value.
  final ValueChanged<T>? onChanged;

  /// The tabs.
  final List<CamoTab<T>> tabs;

  /// `true` keeps tabs at their natural width and scrolls the row.
  final bool scrollable;

  /// `null` uses `CamoTabsTheme.defaultAppearance`: solid (prominent) or ghost (quiet).
  final Appearance? appearance;

  /// A fractional tab index (a page position) the indicator follows instead of animating.
  final ValueListenable<double>? position;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return CamoTabsContainer(
      selectedIndex: tabs.indexWhere((t) => t.value == selected),
      scrollable: scrollable,
      appearance: appearance,
      position: position,
      enabled: onChanged != null,
      children: [
        for (final (i, tab) in tabs.indexed)
          CamoTabItem<T>(
            tab: tab,
            selected: tab.value == selected,
            onPressed: () => onChanged?.call(tab.value),
            position: CamoItemPosition(i, tabs.length),
          ),
      ],
    );
  }
}

/// The building block (ADR-30) for custom tab bars: the skin's bar, the animated indicator, the scrolling and
/// the tab-list semantics around the [CamoTabItem]s in [children]. [selectedIndex] is the selected tab's index
/// (`-1` for none, which draws no indicator).
class CamoTabsContainer extends StatefulWidget {
  /// Creates the container.
  const CamoTabsContainer({
    super.key,
    required this.selectedIndex,
    required this.children,
    this.scrollable = false,
    this.appearance,
    this.position,
    this.enabled = true,
  });

  /// The selected tab's index, or `-1`.
  final int selectedIndex;

  /// The [CamoTabItem]s.
  final List<Widget> children;

  /// `true` keeps tabs at their natural width and scrolls the row.
  final bool scrollable;

  /// `null` uses `CamoTabsTheme.defaultAppearance`.
  final Appearance? appearance;

  /// A fractional tab index the indicator follows instead of animating.
  final ValueListenable<double>? position;

  /// `false` disables every tab.
  final bool enabled;

  @override
  State<CamoTabsContainer> createState() => _CamoTabsContainerState();
}

class _CamoTabsContainerState extends State<CamoTabsContainer>
    with SingleTickerProviderStateMixin {
  final _registry = _TabsRegistry();
  final _rowKey = GlobalKey();
  final _scroll = ScrollController();
  final _indicator = ValueNotifier<TabIndicator?>(null);
  late final _animation = AnimationController(vsync: this);
  var _bounds = <int, _TabBounds>{};
  IndicatorWidth _mode = IndicatorWidth.tab;
  Duration _duration = const Duration(milliseconds: 200);
  Curve _curve = Curves.easeInOut;
  TabIndicator? _from;
  TabIndicator? _target;
  var _measureScheduled = false;
  var _scrolledInitially = false;

  @override
  void initState() {
    super.initState();
    _animation.addListener(_tick);
    widget.position?.addListener(_follow);
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(CamoTabsContainer old) {
    super.didUpdateWidget(old);
    if (old.position != widget.position) {
      old.position?.removeListener(_follow);
      widget.position?.addListener(_follow);
    }
    _scheduleMeasure();
    if (widget.scrollable && old.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    widget.position?.removeListener(_follow);
    _animation.dispose();
    _scroll.dispose();
    _indicator.dispose();
    super.dispose();
  }

  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (mounted) _measure();
    });
  }

  void _measure() {
    final row = _rowKey.currentContext?.findRenderObject();
    if (row is! RenderBox || !row.attached) return;
    double startOf(GlobalKey? key) {
      final box = key?.currentContext?.findRenderObject();
      return box is RenderBox && box.attached
          ? box.localToGlobal(Offset.zero, ancestor: row).dx
          : 0;
    }

    double widthOf(GlobalKey? key) {
      final box = key?.currentContext?.findRenderObject();
      return box is RenderBox && box.hasSize ? box.size.width : 0;
    }

    final next = <int, _TabBounds>{};
    for (final entry in _registry.tabKeys.entries) {
      final content = _registry.contentKeys[entry.key];
      final width = widthOf(entry.value);
      final hasContent = widthOf(content) > 0;
      next[entry.key] = _TabBounds(
        startOf(entry.value),
        width,
        hasContent ? startOf(content) : startOf(entry.value),
        hasContent ? widthOf(content) : width,
      );
    }
    _bounds = next;
    _retarget();
    if (widget.scrollable && !_scrolledInitially && next.isNotEmpty) {
      _scrolledInitially = true;
      _scrollToSelected(animate: false);
    }
  }

  TabIndicator? _targetFor(int index) => _bounds[index]?.indicator(_mode);

  void _retarget() {
    if (widget.position != null) {
      _follow();
      return;
    }
    final target = _targetFor(widget.selectedIndex);
    if (target == _target) return;
    _target = target;
    if (target == null || _indicator.value == null) {
      _animation.stop();
      _indicator.value = target;
      return;
    }
    _from = _indicator.value;
    _animation
      ..duration = _duration
      ..forward(from: 0);
  }

  void _tick() {
    final target = _target;
    if (target == null) return;
    _indicator.value = TabIndicator.lerp(
      _from,
      target,
      _curve.transform(_animation.value),
    );
  }

  // The indicator follows a fractional page position between two tabs.
  void _follow() {
    final position = widget.position?.value;
    if (position == null) return;
    final lower = position.floor().clamp(0, 1 << 20);
    final from = _targetFor(lower);
    final to = _targetFor(lower + 1);
    _animation.stop();
    _indicator.value = to == null
        ? from
        : TabIndicator.lerp(from, to, (position - lower).clamp(0, 1));
  }

  // Centers the selected tab in the bar's own scroll view, and only there: `Scrollable.ensureVisible` would also
  // scroll every scrollable the bar sits in (the page).
  void _scrollToSelected({bool animate = true}) {
    final bounds = _bounds[widget.selectedIndex];
    if (!mounted || bounds == null || !_scroll.hasClients) return;
    final position = _scroll.position;
    final centered =
        bounds.start + bounds.width / 2 - position.viewportDimension / 2;
    final target = centered.clamp(0.0, position.maxScrollExtent);
    if (animate && _duration > Duration.zero) {
      _scroll.animateTo(target, duration: _duration, curve: _curve);
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTabsContainer');
    final theme = Camouflage.themeOf(context, component: 'CamoTabsContainer');
    final style = skin.tabs.defaults(theme).merge(theme.components.tabs);
    final appearance = tabsAppearance(
      widget.appearance ?? style.defaultAppearance,
    );
    _mode = style.indicatorWidth;
    _duration = theme.motion.durationMedium;
    _curve = theme.motion.easingEmphasized;
    final state = TabsState(
      count: widget.children.length,
      selectedIndex: widget.selectedIndex,
      scrollable: widget.scrollable,
      appearance: appearance,
      indicator: _indicator,
    );
    Widget row(CustomPainter indicatorPainter) {
      Widget content = NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (_) {
          _scheduleMeasure();
          return false;
        },
        child: SizeChangedLayoutNotifier(
          child: KeyedSubtree(
            key: _rowKey,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
          ),
        ),
      );
      content = CustomPaint(painter: indicatorPainter, child: content);
      // Inside the scroll view, so the tab bar's only semantic children are tabs.
      content = Semantics(
        role: SemanticsRole.tabBar,
        container: true,
        child: content,
      );
      return widget.scrollable
          ? SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: content,
            )
          : content;
    }

    return _TabsScope(
      registry: _registry,
      scrollable: widget.scrollable,
      appearance: appearance,
      enabled: widget.enabled,
      child: CamoRovingFocus(
        child: skin.tabs.renderContainer(context, state, theme, style, row),
      ),
    );
  }
}

/// One skin-styled tab inside a [CamoTabsContainer], with tab semantics. [child] replaces the tab's label, icon
/// and badge (a counter, two lines); the tab's label still names it.
class CamoTabItem<T> extends StatefulWidget {
  /// Creates a tab item.
  const CamoTabItem({
    super.key,
    required this.tab,
    required this.selected,
    required this.onPressed,
    required this.position,
    this.child,
  });

  /// The tab.
  final CamoTab<T> tab;

  /// Whether it's the selected tab.
  final bool selected;

  /// Called when chosen.
  final VoidCallback onPressed;

  /// Its place in the row.
  final CamoItemPosition position;

  /// Custom content.
  final Widget? child;

  @override
  State<CamoTabItem<T>> createState() => _CamoTabItemState<T>();
}

class _CamoTabItemState<T> extends State<CamoTabItem<T>> {
  final _interaction = CamoInteractionController();
  final _tabKey = GlobalKey();
  final _contentKey = GlobalKey();
  _TabsRegistry? _registry;

  @override
  void dispose() {
    _registry?.unregister(widget.position.index, _tabKey);
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    assert(
      tab.label != null || tab.icon != null || widget.child != null,
      'A CamoTab needs a label or an icon.',
    );
    assert(
      tab.label != null || tab.semanticLabel != null || widget.child != null,
      'An icon-only CamoTab needs a semanticLabel.',
    );
    final skin = Camouflage.skinOf(context, component: 'CamoTabItem');
    final theme = Camouflage.themeOf(context, component: 'CamoTabItem');
    final scope = context.dependOnInheritedWidgetOfExactType<_TabsScope>();
    assert(scope != null, 'CamoTabItem must be inside a CamoTabsContainer.');
    final style = skin.tabs.defaults(theme).merge(theme.components.tabs);
    final enabled = (scope?.enabled ?? true) && tab.enabled;
    final scrollable = scope?.scrollable ?? false;
    _registry = scope?.registry;
    _registry?.register(widget.position.index, _tabKey, _contentKey);
    final item = CamoRovingFocusItem(
      index: widget.position.index,
      enabled: enabled,
      selected: widget.selected,
      onSelect: widget.onPressed,
      builder: (context, node) => CamoBehavior(
        controller: _interaction,
        enabled: enabled,
        focusNode: node,
        onActivate: widget.onPressed,
        touchSemantics: true,
        semantics: (child) => Semantics(
          role: SemanticsRole.tab,
          enabled: enabled,
          selected: widget.selected,
          label: tab.semanticLabel ?? tab.label,
          excludeSemantics: true,
          child: child,
        ),
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => KeyedSubtree(
            key: _tabKey,
            child: skin.tabs.renderTab(
              context,
              TabState(
                selected: widget.selected,
                enabled: enabled,
                position: widget.position,
                scrollable: scrollable,
                appearance: scope?.appearance ?? Appearance.solid,
                interaction: _interaction.value,
                controller: _interaction,
              ),
              TabSlots(
                label: tab.label,
                icon: tab.icon,
                badge: tab.badge,
                child: widget.child,
                contentKey: _contentKey,
              ),
              theme,
              style,
            ),
          ),
        ),
      ),
    );
    return scrollable ? item : Expanded(child: item);
  }
}

/// A pager and a tab bar kept in step: the page controller is the truth. Pass [selected] and [select] to
/// `CamoTabs` (a tap animates the pager to that page) and the sync itself as its `position` (the indicator
/// follows a swipe); rebuild the tabs when it notifies. The selected tab follows the current page, so it
/// changes once a swipe passes the halfway point.
class CamoTabsPageSync<T> extends ChangeNotifier
    implements ValueListenable<double> {
  /// Syncs [pageController] with the tab bar for [tabs], one tab per page.
  CamoTabsPageSync({required this.pageController, required this.tabs}) {
    assert(tabs.isNotEmpty, 'CamoTabsPageSync needs at least one tab.');
    pageController.addListener(notifyListeners);
  }

  /// The pager's controller.
  final PageController pageController;

  /// One tab per page.
  final List<CamoTab<T>> tabs;

  /// The fractional page the pager is at.
  @override
  double get value => pageController.hasClients
      ? (pageController.page ?? pageController.initialPage.toDouble())
      : pageController.initialPage.toDouble();

  /// The value of the tab on the current page.
  T get selected => tabs[value.round().clamp(0, tabs.length - 1)].value;

  /// Animates the pager to the page of [value].
  void select(T value) {
    final index = tabs.indexWhere((t) => t.value == value);
    if (index < 0 || !pageController.hasClients) return;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    pageController.removeListener(notifyListeners);
    super.dispose();
  }
}
