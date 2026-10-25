import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// A tooltip's colors.
@immutable
class TooltipColors {
  /// Creates tooltip colors.
  const TooltipColors({required this.container, required this.text});

  /// The bubble's fill.
  final Color container;

  /// The text.
  final Color text;

  @override
  bool operator ==(Object other) =>
      other is TooltipColors &&
      other.container == container &&
      other.text == text;

  @override
  int get hashCode => Object.hash(container, text);
}

/// Overrides for tooltips; `null` keeps the skin's default.
@immutable
class CamoTooltipTheme {
  /// Creates tooltip overrides.
  const CamoTooltipTheme({
    this.shape,
    this.padding,
    this.offset,
    this.textStyle,
    this.showDelay,
    this.hideDelay,
    this.maxWidth,
    this.colors,
  });

  /// The corners.
  final BorderRadius? shape;

  /// The inner padding.
  final EdgeInsetsGeometry? padding;

  /// The gap from the anchor.
  final double? offset;

  /// The text style.
  final TextStyle? textStyle;

  /// The hover delay.
  final Duration? showDelay;

  /// How long it stays after a long press on touch.
  final Duration? hideDelay;

  /// Text wraps beyond this width.
  final double? maxWidth;

  /// The colors.
  final TooltipColors? colors;

  /// A copy with the given fields replaced.
  CamoTooltipTheme copyWith({
    BorderRadius? shape,
    EdgeInsetsGeometry? padding,
    double? offset,
    TextStyle? textStyle,
    Duration? showDelay,
    Duration? hideDelay,
    double? maxWidth,
    TooltipColors? colors,
  }) => CamoTooltipTheme(
    shape: shape ?? this.shape,
    padding: padding ?? this.padding,
    offset: offset ?? this.offset,
    textStyle: textStyle ?? this.textStyle,
    showDelay: showDelay ?? this.showDelay,
    hideDelay: hideDelay ?? this.hideDelay,
    maxWidth: maxWidth ?? this.maxWidth,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoTooltipTheme &&
      other.shape == shape &&
      other.padding == padding &&
      other.offset == offset &&
      other.textStyle == textStyle &&
      other.showDelay == showDelay &&
      other.hideDelay == hideDelay &&
      other.maxWidth == maxWidth &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    shape,
    padding,
    offset,
    textStyle,
    showDelay,
    hideDelay,
    maxWidth,
    colors,
  );
}

/// The resolved tooltip style: every field set.
@immutable
class CamoTooltipStyle {
  /// Creates a tooltip style.
  const CamoTooltipStyle({
    required this.shape,
    required this.padding,
    required this.offset,
    required this.textStyle,
    required this.showDelay,
    required this.hideDelay,
    required this.maxWidth,
    required this.colors,
  });

  /// The corners.
  final BorderRadius shape;

  /// The inner padding.
  final EdgeInsetsGeometry padding;

  /// The gap from the anchor.
  final double offset;

  /// The text style.
  final TextStyle textStyle;

  /// The hover delay.
  final Duration showDelay;

  /// How long it stays after a long press on touch.
  final Duration hideDelay;

  /// Text wraps beyond this width.
  final double maxWidth;

  /// The colors.
  final TooltipColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoTooltipStyle merge(CamoTooltipTheme? o) => o == null
      ? this
      : CamoTooltipStyle(
          shape: o.shape ?? shape,
          padding: o.padding ?? padding,
          offset: o.offset ?? offset,
          textStyle: o.textStyle ?? textStyle,
          showDelay: o.showDelay ?? showDelay,
          hideDelay: o.hideDelay ?? hideDelay,
          maxWidth: o.maxWidth ?? maxWidth,
          colors: o.colors ?? colors,
        );
}

/// What a tooltip renderer draws. Core owns when it shows and where.
@immutable
class TooltipState {
  /// Creates a tooltip state.
  const TooltipState({required this.text, required this.visible});

  /// The message.
  final String text;

  /// Whether it's showing.
  final bool visible;
}

/// Draws a tooltip's bubble. Core places it above its anchor (below at the top edge) and never focuses it.
abstract interface class CamoTooltipRenderer {
  /// The complete tooltip style for [theme].
  CamoTooltipStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    TooltipState state,
    CamoTheme theme,
    CamoTooltipStyle style,
  );
}

/// Shows [message] next to [child] on hover (after a delay), on keyboard focus, and on a long press on touch.
/// It never takes focus, and Esc hides it.
class CamoTooltip extends StatefulWidget {
  /// Creates a tooltip for [child].
  const CamoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.enabled = true,
    this.anchorLabel,
  });

  /// The text shown.
  final String message;

  /// The anchor.
  final Widget child;

  /// `false` never shows it.
  final bool enabled;

  /// The anchor's own label; when it equals [message], screen readers aren't told twice.
  final String? anchorLabel;

  @override
  State<CamoTooltip> createState() => _CamoTooltipState();
}

class _CamoTooltipState extends State<CamoTooltip> {
  final _portal = OverlayPortalController();
  Timer? _timer;

  void _after(Duration delay, {required bool show}) {
    _timer?.cancel();
    void apply() {
      if (!mounted) return;
      show ? _portal.show() : _portal.hide();
    }

    delay == Duration.zero ? apply() : _timer = Timer(delay, apply);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTooltip');
    final theme = Camouflage.themeOf(context, component: 'CamoTooltip');
    final style = skin.tooltip.defaults(theme).merge(theme.components.tooltip);
    Widget anchor = widget.child;
    if (widget.enabled) {
      anchor = MouseRegion(
        onEnter: (_) => _after(style.showDelay, show: true),
        onExit: (_) => _after(Duration.zero, show: false),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) => _after(
            Duration.zero,
            show:
                focused &&
                FocusManager.instance.highlightMode ==
                    FocusHighlightMode.traditional,
          ),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () =>
                  _after(Duration.zero, show: false),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () => _after(Duration.zero, show: true),
              onLongPressEnd: (_) => _after(style.hideDelay, show: false),
              child: anchor,
            ),
          ),
        ),
      );
    }
    if (widget.message != widget.anchorLabel) {
      anchor = Semantics(tooltip: widget.message, child: anchor);
    }
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (overlayContext) {
        final box = context.findRenderObject()! as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final top = box.localToGlobal(Offset.zero, ancestor: overlay);
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomSingleChildLayout(
              delegate: _AboveAnchor(top & box.size, style.offset),
              child: skin.tooltip.render(
                context,
                TooltipState(text: widget.message, visible: true),
                theme,
                style,
              ),
            ),
          ),
        );
      },
      child: anchor,
    );
  }
}

// Centered above the anchor; below it when there's no room above. Kept inside the overlay horizontally.
class _AboveAnchor extends SingleChildLayoutDelegate {
  _AboveAnchor(this.anchor, this.offset);

  final Rect anchor;
  final double offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = (anchor.center.dx - childSize.width / 2).clamp(
      0.0,
      (size.width - childSize.width).clamp(0.0, double.infinity),
    );
    final above = anchor.top - offset - childSize.height;
    return Offset(x, above >= 0 ? above : anchor.bottom + offset);
  }

  @override
  bool shouldRelayout(_AboveAnchor old) =>
      old.anchor != anchor || old.offset != offset;
}
