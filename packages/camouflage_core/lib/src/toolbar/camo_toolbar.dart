import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../menu/camo_menu_anchor.dart';
import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_roving_focus.dart';

/// Where a toolbar sits: edge to edge, or detached from the edges.
enum ToolbarPlacement {
  /// Edge to edge.
  docked,

  /// Detached, with a margin and depth.
  floating,
}

/// Every color a toolbar uses.
@immutable
class ToolbarColors {
  /// Creates ToolbarColors.
  const ToolbarColors({required this.container, required this.divider});

  /// The fill.
  final Color container;

  /// The hairline on the docked edge.
  final Color divider;

  @override
  bool operator ==(Object other) =>
      other is ToolbarColors &&
      other.container == container &&
      other.divider == divider;

  @override
  int get hashCode => Object.hash(container, divider);
}

/// Overrides for toolbars. `null` keeps the skin's default.
@immutable
class CamoToolbarTheme {
  /// Creates overrides.
  const CamoToolbarTheme({
    this.placement,
    this.height,
    this.actionSize,
    this.floatingMargin,
    this.floatingShape,
    this.floatingElevation,
    this.actionSpacing,
    this.padding,
    this.showDivider,
    this.overflowIcon,
    this.colors,
  });

  /// Docked: edge to edge. Floating: detached.
  final ToolbarPlacement? placement;

  /// The toolbar height.
  final double? height;

  /// The width one action takes, for the overflow measuring.
  final double? actionSize;

  /// Around a floating toolbar.
  final double? floatingMargin;

  /// The floating container.
  final BorderRadius? floatingShape;

  /// The floating depth.
  final ElevationLevel? floatingElevation;

  /// Between actions.
  final double? actionSpacing;

  /// Start and end padding.
  final double? padding;

  /// A hairline on the docked edge.
  final bool? showDivider;

  /// The overflow button.
  final IconSource? overflowIcon;

  /// Every color it uses.
  final ToolbarColors? colors;

  /// A copy with the given fields replaced.
  CamoToolbarTheme copyWith({
    ToolbarPlacement? placement,
    double? height,
    double? actionSize,
    double? floatingMargin,
    BorderRadius? floatingShape,
    ElevationLevel? floatingElevation,
    double? actionSpacing,
    double? padding,
    bool? showDivider,
    IconSource? overflowIcon,
    ToolbarColors? colors,
  }) => CamoToolbarTheme(
    placement: placement ?? this.placement,
    height: height ?? this.height,
    actionSize: actionSize ?? this.actionSize,
    floatingMargin: floatingMargin ?? this.floatingMargin,
    floatingShape: floatingShape ?? this.floatingShape,
    floatingElevation: floatingElevation ?? this.floatingElevation,
    actionSpacing: actionSpacing ?? this.actionSpacing,
    padding: padding ?? this.padding,
    showDivider: showDivider ?? this.showDivider,
    overflowIcon: overflowIcon ?? this.overflowIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoToolbarTheme &&
      other.placement == placement &&
      other.height == height &&
      other.actionSize == actionSize &&
      other.floatingMargin == floatingMargin &&
      other.floatingShape == floatingShape &&
      other.floatingElevation == floatingElevation &&
      other.actionSpacing == actionSpacing &&
      other.padding == padding &&
      other.showDivider == showDivider &&
      other.overflowIcon == overflowIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    placement,
    height,
    actionSize,
    floatingMargin,
    floatingShape,
    floatingElevation,
    actionSpacing,
    padding,
    showDivider,
    overflowIcon,
    colors,
  );
}

/// The resolved toolbar style: every field set.
@immutable
class CamoToolbarStyle {
  /// Creates a style.
  const CamoToolbarStyle({
    required this.placement,
    required this.height,
    required this.actionSize,
    required this.floatingMargin,
    required this.floatingShape,
    required this.floatingElevation,
    required this.actionSpacing,
    required this.padding,
    required this.showDivider,
    required this.overflowIcon,
    required this.colors,
  });

  /// Docked: edge to edge. Floating: detached.
  final ToolbarPlacement placement;

  /// The toolbar height.
  final double height;

  /// The width one action takes, for the overflow measuring.
  final double actionSize;

  /// Around a floating toolbar.
  final double floatingMargin;

  /// The floating container.
  final BorderRadius floatingShape;

  /// The floating depth.
  final ElevationLevel floatingElevation;

  /// Between actions.
  final double actionSpacing;

  /// Start and end padding.
  final double padding;

  /// A hairline on the docked edge.
  final bool showDivider;

  /// The overflow button.
  final IconSource overflowIcon;

  /// Every color it uses.
  final ToolbarColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoToolbarStyle merge(CamoToolbarTheme? o) => o == null
      ? this
      : CamoToolbarStyle(
          placement: o.placement ?? placement,
          height: o.height ?? height,
          actionSize: o.actionSize ?? actionSize,
          floatingMargin: o.floatingMargin ?? floatingMargin,
          floatingShape: o.floatingShape ?? floatingShape,
          floatingElevation: o.floatingElevation ?? floatingElevation,
          actionSpacing: o.actionSpacing ?? actionSpacing,
          padding: o.padding ?? padding,
          showDivider: o.showDivider ?? showDivider,
          overflowIcon: o.overflowIcon ?? overflowIcon,
          colors: o.colors ?? colors,
        );
}

/// One action of a [CamoToolbar]. [label] names it for screen readers and in the overflow menu. A non-null
/// [selected] makes it a toggle (Bold, Italic): the app owns the state and flips it in [onPressed].
@immutable
class CamoToolbarAction {
  /// Creates an action.
  const CamoToolbarAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.selected,
    this.tone = Tone.defaultTone,
  });

  /// Identifies the action across rebuilds.
  final Object id;

  /// Names the action.
  final String label;

  /// The icon.
  final Widget icon;

  /// Runs when it's pressed.
  final VoidCallback onPressed;

  /// `false` disables it.
  final bool enabled;

  /// `null` for a command; otherwise whether the toggle is pressed.
  final bool? selected;

  /// The color family.
  final Tone tone;
}

/// What the toolbar renderer draws: the [placement] and how many actions the toolbar was given.
@immutable
class ToolbarState {
  /// Creates the state.
  const ToolbarState({required this.placement, required this.count});

  /// Docked or floating.
  final ToolbarPlacement placement;

  /// How many actions it was given.
  final int count;
}

/// Draws toolbars: the container (surface, shape, depth, padding) around [child], which fills the width with the
/// leading content, the actions and the trailing content. The actions are `skin.iconButton`s.
abstract interface class CamoToolbarRenderer {
  /// The complete toolbar style for [theme].
  CamoToolbarStyle defaults(CamoTheme theme);

  /// Draws the container around [child].
  Widget renderContainer(
    BuildContext context,
    ToolbarState state,
    CamoTheme theme,
    CamoToolbarStyle style,
    Widget child,
  );
}

/// How many of [count] actions of [action] logical pixels with [spacing] between them show in [available]: all, or
/// those that fit beside the overflow button (which is the width of one more action).
@visibleForTesting
int fitActions(int count, double available, double action, double spacing) {
  double width(int n) => n * action + math.max(n - 1, 0) * spacing;
  if (width(count) <= available) return count;
  var shown = count - 1;
  while (shown > 0 && width(shown + 1) > available) {
    shown--;
  }
  return shown;
}

/// A row of actions for the current context: formatting buttons in an editor, the bar under a message list.
/// Actions that don't fit collapse, in order, into a trailing "more" menu (a toggle there becomes a checkable
/// item). [leading] and [trailing] (a menu button, a title, a primary action) always show; custom content such as
/// button groups goes there or in a [CamoToolbarContainer]. One Tab stop: the arrow keys move between the
/// actions. [semanticLabel] names the toolbar. A toolbar is neither navigation nor a title bar. It measures its
/// room as it lays out, so it doesn't support intrinsic sizing: give it a width.
class CamoToolbar extends StatelessWidget {
  /// Creates a toolbar.
  const CamoToolbar({
    super.key,
    required this.actions,
    this.placement,
    this.semanticLabel,
    this.overflowLabel = 'More',
    this.leading,
    this.trailing,
  });

  /// The actions, in order.
  final List<CamoToolbarAction> actions;

  /// Docked or floating; `null` uses the theme's.
  final ToolbarPlacement? placement;

  /// Names the toolbar.
  final String? semanticLabel;

  /// Names the overflow button.
  final String overflowLabel;

  /// Content before the actions.
  final Widget? leading;

  /// Content after the actions.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoToolbar');
    final theme = Camouflage.themeOf(context, component: 'CamoToolbar');
    final style = skin.toolbar.defaults(theme).merge(theme.components.toolbar);
    // The leading and trailing content take what they need; the actions share the rest.
    return _toolbarSurface(
      context,
      placement ?? style.placement,
      actions.length,
      semanticLabel,
      CamoRovingFocus(
        child: Row(
          children: [
            ?leading,
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final fit = fitActions(
                    actions.length,
                    constraints.maxWidth,
                    style.actionSize,
                    style.actionSpacing,
                  );
                  // Clipped, not squeezed: with less room than one action, the overflow button is cut off.
                  return UnconstrainedBox(
                    alignment: AlignmentDirectional.centerStart,
                    constrainedAxis: Axis.vertical,
                    clipBehavior: Clip.hardEdge,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: style.actionSpacing,
                      children: [
                        for (final (i, action) in actions.take(fit).indexed)
                          _ToolbarButton(
                            key: ValueKey(action.id),
                            action: action,
                            index: i,
                          ),
                        if (fit < actions.length)
                          _Overflow(
                            actions: actions.skip(fit).toList(),
                            label: overflowLabel,
                            index: fit,
                            icon: style.overflowIcon,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// The building block (ADR-30) for custom toolbar content: the skin's toolbar surface in [placement], named
/// [semanticLabel], around [child]. Nothing in it overflows.
class CamoToolbarContainer extends StatelessWidget {
  /// Creates the container.
  const CamoToolbarContainer({
    super.key,
    required this.child,
    this.placement,
    this.semanticLabel,
  });

  /// The content.
  final Widget child;

  /// Docked or floating; `null` uses the theme's.
  final ToolbarPlacement? placement;

  /// Names the toolbar.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoToolbarContainer');
    final theme = Camouflage.themeOf(
      context,
      component: 'CamoToolbarContainer',
    );
    final style = skin.toolbar.defaults(theme).merge(theme.components.toolbar);
    return _toolbarSurface(
      context,
      placement ?? style.placement,
      0,
      semanticLabel,
      child,
    );
  }
}

Widget _toolbarSurface(
  BuildContext context,
  ToolbarPlacement placement,
  int count,
  String? semanticLabel,
  Widget child,
) {
  final skin = Camouflage.skinOf(context, component: 'CamoToolbar');
  final theme = Camouflage.themeOf(context, component: 'CamoToolbar');
  final style = skin.toolbar.defaults(theme).merge(theme.components.toolbar);
  return Semantics(
    container: true,
    explicitChildNodes: true,
    label: semanticLabel,
    child: skin.toolbar.renderContainer(
      context,
      ToolbarState(placement: placement, count: count),
      theme,
      style,
      child,
    ),
  );
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({super.key, required this.action, required this.index});

  final CamoToolbarAction action;
  final int index;

  @override
  Widget build(BuildContext context) => CamoRovingFocusItem(
    index: index,
    enabled: action.enabled,
    selected: false,
    onSelect: () {},
    builder: (context, node) => CamoIconButton(
      icon: action.icon,
      semanticLabel: action.label,
      onPressed: action.enabled ? action.onPressed : null,
      appearance: Appearance.ghost,
      tone: action.tone,
      checked: action.selected,
      focusNode: node,
    ),
  );
}

class _Overflow extends StatefulWidget {
  const _Overflow({
    required this.actions,
    required this.label,
    required this.index,
    required this.icon,
  });

  final List<CamoToolbarAction> actions;
  final String label;
  final int index;
  final IconSource icon;

  @override
  State<_Overflow> createState() => _OverflowState();
}

class _OverflowState extends State<_Overflow> {
  final _menu = CamoMenuController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CamoMenuAnchor(
    controller: _menu,
    items: [
      for (final action in widget.actions)
        CamoMenuItem(
          text: action.label,
          onPressed: action.onPressed,
          leadingIcon: action.icon,
          tone: action.tone,
          enabled: action.enabled,
          checked: action.selected,
        ),
    ],
    builder: (context, open) => CamoRovingFocusItem(
      index: widget.index,
      enabled: true,
      selected: false,
      onSelect: () {},
      builder: (context, node) => ListenableBuilder(
        listenable: _menu,
        builder: (context, _) => Semantics(
          expanded: _menu.isOpen,
          child: CamoIconButton(
            icon: CamoIcon(widget.icon),
            semanticLabel: widget.label,
            onPressed: open,
            appearance: Appearance.ghost,
            focusNode: node,
          ),
        ),
      ),
    ),
  );
}
