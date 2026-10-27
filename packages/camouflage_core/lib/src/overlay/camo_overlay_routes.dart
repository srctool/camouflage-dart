import 'package:flutter/widgets.dart';

import '../bottom_sheet/camo_bottom_sheet.dart';
import '../menu/camo_menu.dart';
import '../provider/camouflage.dart';
import '../provider/camouflage_provider.dart';

// The M5 overlay routes behind the date and time fields: a bottom sheet and an anchored popup. Both capture the
// skin and theme where they're opened (routes are built under the Navigator). M6 makes the sheet public as
// showCamoBottomSheet / CamoSheetRoute and builds CamoMenuAnchor on the popup.

/// Opens [builder]'s content in a [CamoSheetFrame] over a scrim; a pop with a value is the result.
Future<T?> showCamoSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  final scope = CamouflageScope.maybeOf(context);
  final skin = Camouflage.skinOf(context, component: 'CamoSheetFrame');
  final theme = Camouflage.themeOf(context, component: 'CamoSheetFrame');
  final style = skin.bottomSheet
      .defaults(theme)
      .merge(theme.components.bottomSheet);
  final stacked = ModalRoute.of(context) is _SheetRoute;
  final scrim = stacked && style.stackedScrim == StackedScrim.topOnly
      ? const Color(0x00000000)
      : theme.colors.scrim.withValues(alpha: style.scrimAlpha);
  return Navigator.of(context).push(
    _SheetRoute<T>(
      barrierColor: scrim,
      barrierDismissible: dismissible,
      duration: theme.motion.durationMedium,
      curve: theme.motion.easingEmphasized,
      builder: (context) => CamouflageProvider(
        skin: scope?.skin,
        theme: scope?.theme,
        child: Builder(
          builder: (context) => CamoSheetFrame(
            dismissible: dismissible,
            onDismissRequest: () => Navigator.maybePop(context),
            child: builder(context),
          ),
        ),
      ),
    ),
  );
}

class _SheetRoute<T> extends PopupRoute<T> {
  _SheetRoute({
    required this.barrierColor,
    required this.barrierDismissible,
    required this.duration,
    required this.curve,
    required this.builder,
  });

  @override
  final Color barrierColor;

  @override
  final bool barrierDismissible;

  final Duration duration;
  final Curve curve;
  final WidgetBuilder builder;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SlideTransition(
    position: Tween(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve)),
    child: child,
  );
}

/// Opens [builder]'s content in the skin's popup panel under [anchor] (above it when there's no room below),
/// with an invisible barrier: an outside tap, back and Esc close it.
Future<T?> showCamoAnchoredPopup<T>(
  BuildContext anchor, {
  required WidgetBuilder builder,
}) {
  final scope = CamouflageScope.maybeOf(anchor);
  final theme = Camouflage.themeOf(anchor, component: 'CamoAnchoredPopup');
  final navigator = Navigator.of(anchor);
  final box = anchor.findRenderObject()! as RenderBox;
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final rect = MatrixUtils.transformRect(
    box.getTransformTo(overlay),
    Offset.zero & box.size,
  );
  return navigator.push(
    _AnchoredRoute<T>(
      anchor: rect,
      gap: theme.spacing.xs,
      textDirection: Directionality.of(anchor),
      duration: theme.motion.durationShort,
      builder: (context) => CamouflageProvider(
        skin: scope?.skin,
        theme: scope?.theme,
        child: Builder(
          builder: (context) => CamoMenuPanel(child: builder(context)),
        ),
      ),
    ),
  );
}

class _AnchoredRoute<T> extends PopupRoute<T> {
  _AnchoredRoute({
    required this.anchor,
    required this.gap,
    required this.textDirection,
    required this.duration,
    required this.builder,
  });

  final Rect anchor;
  final double gap;
  final TextDirection textDirection;
  final Duration duration;
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => CustomSingleChildLayout(
    delegate: _BelowAnchor(anchor, gap, textDirection),
    child: FocusScope(autofocus: true, child: builder(context)),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);
}

// Below the anchor, start-aligned; above it when it doesn't fit below; otherwise against the bottom edge.
class _BelowAnchor extends SingleChildLayoutDelegate {
  _BelowAnchor(this.anchor, this.gap, this.textDirection);

  final Rect anchor;
  final double gap;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size child) {
    final start = textDirection == TextDirection.ltr
        ? anchor.left
        : anchor.right - child.width;
    final x = start.clamp(
      0.0,
      (size.width - child.width).clamp(0.0, double.infinity),
    );
    final below = anchor.bottom + gap;
    final above = anchor.top - gap - child.height;
    final y = below + child.height <= size.height
        ? below
        : above >= 0
        ? above
        : (size.height - child.height).clamp(0.0, double.infinity);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_BelowAnchor old) =>
      old.anchor != anchor ||
      old.gap != gap ||
      old.textDirection != textDirection;
}
