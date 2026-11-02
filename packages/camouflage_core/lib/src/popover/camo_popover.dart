import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// Where a popover opens relative to its anchor. `start` and `end` follow the reading direction.
enum PopoverPlacement {
  /// Below, flipping above when there is no room.
  auto,

  /// Below.
  bottom,

  /// Above.
  top,

  /// On the start side.
  start,

  /// On the end side.
  end,
}

/// Every color a popover uses; [border] is drawn only when set.
@immutable
class PopoverColors {
  /// Creates PopoverColors.
  const PopoverColors({
    required this.container,
    required this.title,
    required this.content,
    this.border,
  });

  /// The fill.
  final Color container;

  /// The title.
  final Color title;

  /// The content text.
  final Color content;

  /// The outline, if any.
  final Color? border;

  @override
  bool operator ==(Object other) =>
      other is PopoverColors &&
      other.container == container &&
      other.title == title &&
      other.content == content &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, title, content, border);
}

/// Overrides for popovers; `null` keeps the skin's default.
@immutable
class CamoPopoverTheme {
  /// Creates overrides.
  const CamoPopoverTheme({
    this.shape,
    this.maxWidth,
    this.padding,
    this.showArrow,
    this.arrowSize,
    this.elevation,
    this.titleStyle,
    this.gap,
    this.colors,
  });

  /// The container corners.
  final BorderRadius? shape;

  /// The widest the panel gets.
  final double? maxWidth;

  /// Around the content.
  final double? padding;

  /// An arrow pointing at the anchor.
  final bool? showArrow;

  /// The arrow: its base along the edge and its height.
  final Size? arrowSize;

  /// The depth.
  final ElevationLevel? elevation;

  /// The title.
  final TextStyle? titleStyle;

  /// The space between the anchor and the panel.
  final double? gap;

  /// Every color it uses.
  final PopoverColors? colors;

  /// A copy with the given fields replaced.
  CamoPopoverTheme copyWith({
    BorderRadius? shape,
    double? maxWidth,
    double? padding,
    bool? showArrow,
    Size? arrowSize,
    ElevationLevel? elevation,
    TextStyle? titleStyle,
    double? gap,
    PopoverColors? colors,
  }) => CamoPopoverTheme(
    shape: shape ?? this.shape,
    maxWidth: maxWidth ?? this.maxWidth,
    padding: padding ?? this.padding,
    showArrow: showArrow ?? this.showArrow,
    arrowSize: arrowSize ?? this.arrowSize,
    elevation: elevation ?? this.elevation,
    titleStyle: titleStyle ?? this.titleStyle,
    gap: gap ?? this.gap,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoPopoverTheme &&
      other.shape == shape &&
      other.maxWidth == maxWidth &&
      other.padding == padding &&
      other.showArrow == showArrow &&
      other.arrowSize == arrowSize &&
      other.elevation == elevation &&
      other.titleStyle == titleStyle &&
      other.gap == gap &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    shape,
    maxWidth,
    padding,
    showArrow,
    arrowSize,
    elevation,
    titleStyle,
    gap,
    colors,
  );
}

/// The resolved popover style: every field set.
@immutable
class CamoPopoverStyle {
  /// Creates a style.
  const CamoPopoverStyle({
    required this.shape,
    required this.maxWidth,
    required this.padding,
    required this.showArrow,
    required this.arrowSize,
    required this.elevation,
    required this.titleStyle,
    required this.gap,
    required this.colors,
  });

  /// The container corners.
  final BorderRadius shape;

  /// The widest the panel gets.
  final double maxWidth;

  /// Around the content.
  final double padding;

  /// An arrow pointing at the anchor.
  final bool showArrow;

  /// The arrow: its base along the edge and its height.
  final Size arrowSize;

  /// The depth.
  final ElevationLevel elevation;

  /// The title.
  final TextStyle titleStyle;

  /// The space between the anchor and the panel.
  final double gap;

  /// Every color it uses.
  final PopoverColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoPopoverStyle merge(CamoPopoverTheme? o) => o == null
      ? this
      : CamoPopoverStyle(
          shape: o.shape ?? shape,
          maxWidth: o.maxWidth ?? maxWidth,
          padding: o.padding ?? padding,
          showArrow: o.showArrow ?? showArrow,
          arrowSize: o.arrowSize ?? arrowSize,
          elevation: o.elevation ?? elevation,
          titleStyle: o.titleStyle ?? titleStyle,
          gap: o.gap ?? gap,
          colors: o.colors ?? colors,
        );
}

/// What the popover renderer draws. [placement] is the side it opened on after any flipping (never `auto`);
/// [arrowOffset] is where the anchor's center is along the panel's edge, measured from the panel's top (for
/// `start` and `end`) or its left edge (for `bottom` and `top`), so an arrow can point at the anchor.
@immutable
class PopoverState {
  /// Creates the state.
  const PopoverState({required this.placement, required this.arrowOffset});

  /// The side it opened on.
  final PopoverPlacement placement;

  /// Where the anchor's center is along the edge.
  final double arrowOffset;
}

/// A popover's content: the optional [title], the [child] and the [actions] at the bottom end.
@immutable
class PopoverSlots {
  /// Creates the slots.
  const PopoverSlots({this.title, required this.child, this.actions});

  /// The title.
  final String? title;

  /// The content.
  final Widget child;

  /// The actions at the bottom end.
  final Widget? actions;
}

/// Draws popovers.
abstract interface class CamoPopoverRenderer {
  /// The complete popover style for [theme].
  CamoPopoverStyle defaults(CamoTheme theme);

  /// Draws the panel (and its arrow, when the style asks for one) with [slots].
  Widget render(
    BuildContext context,
    PopoverState state,
    PopoverSlots slots,
    CamoTheme theme,
    CamoPopoverStyle style,
  );
}

/// Where a popover ended up: the side, the top-left corner of its panel and where the arrow points.
@immutable
class PopoverLayout {
  /// Creates a layout.
  const PopoverLayout(this.placement, this.offset, this.arrow);

  /// The side it opened on.
  final PopoverPlacement placement;

  /// The panel's top-left corner.
  final Offset offset;

  /// Where the anchor's center is along the panel's edge.
  final double arrow;

  @override
  bool operator ==(Object other) =>
      other is PopoverLayout &&
      other.placement == placement &&
      other.offset == offset &&
      other.arrow == arrow;

  @override
  int get hashCode => Object.hash(placement, offset, arrow);
}

/// Places a panel of [size] next to [anchor] inside a window of [window]: on the [requested] side when it fits,
/// else the opposite one, else the other axis; centered on the anchor and kept inside the window. `auto` is
/// below, then above. `start` and `end` are left and right in a left-to-right layout.
@visibleForTesting
PopoverLayout placePopover({
  required Rect anchor,
  required Size size,
  required Size window,
  required PopoverPlacement requested,
  required double gap,
  required bool ltr,
}) {
  final order = switch (requested) {
    PopoverPlacement.auto ||
    PopoverPlacement.bottom => [PopoverPlacement.bottom, PopoverPlacement.top],
    PopoverPlacement.top => [PopoverPlacement.top, PopoverPlacement.bottom],
    PopoverPlacement.start => [
      PopoverPlacement.start,
      PopoverPlacement.end,
      PopoverPlacement.bottom,
    ],
    PopoverPlacement.end => [
      PopoverPlacement.end,
      PopoverPlacement.start,
      PopoverPlacement.bottom,
    ],
  };
  bool fits(PopoverPlacement side) => switch (side) {
    PopoverPlacement.bottom =>
      anchor.bottom + gap + size.height <= window.height,
    PopoverPlacement.top => anchor.top - gap - size.height >= 0,
    _ =>
      ((side == PopoverPlacement.end) == ltr)
          ? anchor.right + gap + size.width <= window.width
          : anchor.left - gap - size.width >= 0,
  };
  final side = order.firstWhere(fits, orElse: () => order.first);
  final maxX = (window.width - size.width).clamp(0.0, double.infinity);
  final maxY = (window.height - size.height).clamp(0.0, double.infinity);
  if (side == PopoverPlacement.bottom || side == PopoverPlacement.top) {
    final x = (anchor.center.dx - size.width / 2).clamp(0.0, maxX);
    final y = side == PopoverPlacement.bottom
        ? anchor.bottom + gap
        : anchor.top - gap - size.height;
    return PopoverLayout(
      side,
      Offset(x, y.clamp(0.0, maxY)),
      (anchor.center.dx - x).clamp(0.0, size.width),
    );
  }
  final left = (side == PopoverPlacement.start) == ltr;
  final x = left ? anchor.left - gap - size.width : anchor.right + gap;
  final y = (anchor.center.dy - size.height / 2).clamp(0.0, maxY);
  return PopoverLayout(
    side,
    Offset(x.clamp(0.0, maxX), y),
    (anchor.center.dy - y).clamp(0.0, size.height),
  );
}

class _PopoverDelegate extends SingleChildLayoutDelegate {
  _PopoverDelegate({
    required this.anchor,
    required this.requested,
    required this.gap,
    required this.ltr,
    required this.onLayout,
  });

  final Rect anchor;
  final PopoverPlacement requested;
  final double gap;
  final bool ltr;
  final ValueChanged<PopoverLayout> onLayout;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final layout = placePopover(
      anchor: anchor,
      size: childSize,
      window: size,
      requested: requested,
      gap: gap,
      ltr: ltr,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) => onLayout(layout));
    return layout.offset;
  }

  @override
  bool shouldRelayout(_PopoverDelegate old) =>
      anchor != old.anchor ||
      requested != old.requested ||
      gap != old.gap ||
      ltr != old.ltr;
}

/// A non-modal panel anchored to [anchor] for content richer than a menu and lighter than a dialog: a few lines,
/// a small form, one or two [actions]. Its visibility is state ([open]), like every controlled component: the
/// app's button toggles it. It opens on the [placement] side (below by default, above when there is no room),
/// and an outside tap, back and Esc all call [onDismissRequest]. Focus moves into it when it opens and back to
/// the anchor when it closes. The anchor should be one control (a button): it announces that it has a popup.
/// Place it where an `Overlay` is above it (inside a route).
class CamoPopover extends StatefulWidget {
  /// Creates a popover.
  const CamoPopover({
    super.key,
    required this.open,
    required this.onDismissRequest,
    required this.anchor,
    required this.child,
    this.title,
    this.actions,
    this.placement = PopoverPlacement.auto,
  });

  /// Whether the popover is shown.
  final bool open;

  /// Called by an outside tap, back or Esc.
  final VoidCallback onDismissRequest;

  /// The element the popover points at; it stays in the layout.
  final Widget anchor;

  /// The content.
  final Widget child;

  /// The title; it also names the panel for screen readers.
  final String? title;

  /// Buttons at the bottom end.
  final Widget? actions;

  /// The preferred side.
  final PopoverPlacement placement;

  @override
  State<CamoPopover> createState() => _CamoPopoverState();
}

class _CamoPopoverState extends State<CamoPopover> {
  final _portal = OverlayPortalController();
  final _anchorKey = GlobalKey();
  final _anchorScope = FocusScopeNode();
  PopoverLayout? _layout;
  ScrollPosition? _scrolling;

  @override
  void initState() {
    super.initState();
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(CamoPopover old) {
    super.didUpdateWidget(old);
    if (widget.open == old.open) return;
    if (widget.open) {
      // The portal can't be shown while the tree is building.
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    } else {
      _hide();
    }
  }

  // The popover follows its anchor when the page around it scrolls.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scrolling) {
      _scrolling?.removeListener(_reposition);
      _scrolling = position?..addListener(_reposition);
    }
  }

  void _reposition() {
    if (mounted && widget.open) setState(() {});
  }

  void _show() {
    if (!mounted || !widget.open) return;
    _portal.show();
  }

  void _hide() {
    _layout = null;
    // The portal can't change while the tree is building either; the anchor then gets its focus back.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.open) return;
      if (_portal.isShowing) _portal.hide();
      _anchorScope.requestFocus();
    });
  }

  @override
  void dispose() {
    _scrolling?.removeListener(_reposition);
    _anchorScope.dispose();
    super.dispose();
  }

  // The anchor's rectangle in the overlay's own coordinates.
  Rect? _anchorRect(BuildContext overlayContext) {
    final box = _anchorKey.currentContext?.findRenderObject();
    final overlay = Overlay.maybeOf(overlayContext)?.context.findRenderObject();
    if (box is! RenderBox || !box.attached || overlay is! RenderBox) {
      return null;
    }
    final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
    return origin & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoPopover');
    final theme = Camouflage.themeOf(context, component: 'CamoPopover');
    final style = skin.popover.defaults(theme).merge(theme.components.popover);
    final ltr = Directionality.of(context) == TextDirection.ltr;
    // A resize rebuilds the overlay, so the panel is placed again.
    MediaQuery.maybeSizeOf(context);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (overlayContext) {
        final anchor = _anchorRect(overlayContext);
        if (anchor == null) return const SizedBox.shrink();
        final resolved = _layout;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape):
                widget.onDismissRequest,
          },
          child: FocusScope(
            autofocus: true,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: widget.onDismissRequest,
                  ),
                ),
                Positioned.fill(
                  child: CustomSingleChildLayout(
                    delegate: _PopoverDelegate(
                      anchor: anchor,
                      requested: widget.placement,
                      gap: style.gap,
                      ltr: ltr,
                      onLayout: (layout) {
                        if (mounted && _layout != layout) {
                          setState(() => _layout = layout);
                        }
                      },
                    ),
                    child: Opacity(
                      opacity: resolved == null ? 0 : 1,
                      child: Semantics(
                        container: true,
                        explicitChildNodes: true,
                        label: widget.title,
                        child: skin.popover.render(
                          overlayContext,
                          PopoverState(
                            placement:
                                resolved?.placement ?? PopoverPlacement.bottom,
                            arrowOffset: resolved?.arrow ?? 0,
                          ),
                          PopoverSlots(
                            title: widget.title,
                            child: widget.child,
                            actions: widget.actions,
                          ),
                          theme,
                          style,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Semantics(
        container: true,
        expanded: widget.open,
        child: FocusScope(
          node: _anchorScope,
          child: KeyedSubtree(key: _anchorKey, child: widget.anchor),
        ),
      ),
    );
  }
}
