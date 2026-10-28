import 'package:flutter/widgets.dart';

import '../bottom_sheet/camo_bottom_sheet.dart';
import '../dialog/camo_dialog.dart';
import '../theme/camo_theme.dart';
import 'scrim_hole.dart';
import '../menu/camo_menu.dart';
import '../provider/camouflage.dart';
import '../provider/camouflage_provider.dart';

// The overlay routes (base Overlays §3.2): sheets and dialogs as routes on the app's Navigator, like Material's
// showModalBottomSheet / showDialog. Each captures the skin and theme where it's opened (routes are built under
// the Navigator) and is non-opaque, so the page below stays drawn. The page paints the skin's scrim with a hole
// where the overlay sits (ScrimHole), so a see-through overlay samples the page undimmed; the barrier stays, clear,
// for taps. A scrim tap, back, Esc and a drag all go through maybePop, so one PopScope in the content can veto
// them. The frames animate the overlay in themselves, so the scrim never slides or scales.

// Whether [context] is inside a Camouflage overlay route (for StackedScrim.topOnly).
bool _onOverlay(BuildContext context) {
  final route = ModalRoute.of(context);
  return route is CamoSheetRoute || route is CamoDialogRoute;
}

Color _scrim(
  BuildContext context,
  CamoTheme theme,
  double alpha,
  StackedScrim stacked,
) => _onOverlay(context) && stacked == StackedScrim.topOnly
    ? const Color(0x00000000)
    : theme.colors.scrim.withValues(alpha: alpha);

// The page: the holed scrim under the frame.
Widget _scrimmed({
  required Animation<double> animation,
  required Color scrim,
  required BorderRadius shape,
  required HoleBox box,
  required GlobalKey self,
  required ScrimMoves moved,
  required Widget frame,
}) => Stack(
  children: [
    Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          key: self,
          painter: ScrimPainter(
            color: scrim,
            opacity: animation,
            hole: box,
            radius: shape,
            self: self,
            repaint: Listenable.merge([animation, moved]),
          ),
        ),
      ),
    ),
    ScrimHole(box: box, moved: moved, child: frame),
  ],
);

const _clear = Color(0x00000000);

/// A bottom sheet as a route: [builder]'s content (usually a `CamoBottomSheet`) in a [CamoSheetFrame] over the
/// skin's scrim, sliding up. `Navigator.pop(context, result)` closes it with a result; a dismissal pops with
/// `null`. With [dismissible] `false`, only the app closes it (back included).
class CamoSheetRoute<T> extends PopupRoute<T> {
  /// Creates the route, capturing the skin and theme at [context].
  CamoSheetRoute({
    required BuildContext context,
    required this.builder,
    this.dismissible = true,
    this.dragToDismiss = true,
    super.settings,
  }) : _scope = CamouflageScope.maybeOf(context),
       _theme = Camouflage.themeOf(context, component: 'CamoSheetRoute'),
       _scrimColor = _sheetScrim(context),
       _shape = _sheetShape(context);

  static BorderRadius _sheetShape(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSheetRoute');
    final theme = Camouflage.themeOf(context, component: 'CamoSheetRoute');
    return skin.bottomSheet
        .defaults(theme)
        .merge(theme.components.bottomSheet)
        .shape;
  }

  static Color _sheetScrim(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSheetRoute');
    final theme = Camouflage.themeOf(context, component: 'CamoSheetRoute');
    final style = skin.bottomSheet
        .defaults(theme)
        .merge(theme.components.bottomSheet);
    return _scrim(context, theme, style.scrimAlpha, style.stackedScrim);
  }

  /// The sheet's content.
  final WidgetBuilder builder;

  /// `false`: only the app closes it.
  final bool dismissible;

  /// `false`: dragging doesn't close it.
  final bool dragToDismiss;

  final CamouflageScope? _scope;
  final CamoTheme _theme;
  final Color _scrimColor;
  final BorderRadius _shape;
  final _box = HoleBox();
  final _self = GlobalKey();
  final _moved = ScrimMoves();

  @override
  Color get barrierColor => _clear;

  @override
  void dispose() {
    _moved.dispose();
    super.dispose();
  }

  @override
  bool get barrierDismissible => dismissible;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  RoutePopDisposition get popDisposition =>
      dismissible ? super.popDisposition : RoutePopDisposition.doNotPop;

  @override
  Duration get transitionDuration => _theme.motion.durationMedium;

  @override
  Duration get reverseTransitionDuration => _theme.motion.durationShort;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => _scrimmed(
    animation: animation,
    scrim: _scrimColor,
    shape: _shape,
    box: _box,
    self: _self,
    moved: _moved,
    frame: CamouflageProvider(
      skin: _scope?.skin,
      theme: _scope?.theme,
      child: Builder(
        builder: (context) => CamoSheetFrame(
          dismissible: dismissible,
          dragToDismiss: dragToDismiss,
          onDismissRequest: () => Navigator.maybePop(context),
          child: builder(context),
        ),
      ),
    ),
  );

  // The frame slides the sheet in itself (the scrim only fades).
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

/// A dialog as a route: [builder]'s content (usually a `CamoDialog`) in a [CamoDialogFrame] over the skin's
/// scrim, fading and scaling in. `Navigator.pop(context, result)` closes it with a result; a dismissal pops with
/// `null`. With [dismissible] `false`, only the app closes it (back included).
class CamoDialogRoute<T> extends PopupRoute<T> {
  /// Creates the route, capturing the skin and theme at [context].
  CamoDialogRoute({
    required BuildContext context,
    required this.builder,
    this.dismissible = true,
    super.settings,
  }) : _scope = CamouflageScope.maybeOf(context),
       _theme = Camouflage.themeOf(context, component: 'CamoDialogRoute'),
       _scrimColor = _dialogScrim(context),
       _shape = _dialogShape(context);

  static BorderRadius _dialogShape(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDialogRoute');
    final theme = Camouflage.themeOf(context, component: 'CamoDialogRoute');
    return skin.dialog.defaults(theme).merge(theme.components.dialog).shape;
  }

  static Color _dialogScrim(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDialogRoute');
    final theme = Camouflage.themeOf(context, component: 'CamoDialogRoute');
    final style = skin.dialog.defaults(theme).merge(theme.components.dialog);
    return _scrim(context, theme, style.scrimAlpha, style.stackedScrim);
  }

  /// The dialog's content.
  final WidgetBuilder builder;

  /// `false`: only the app closes it.
  final bool dismissible;

  final CamouflageScope? _scope;
  final CamoTheme _theme;
  final Color _scrimColor;
  final BorderRadius _shape;
  final _box = HoleBox();
  final _self = GlobalKey();
  final _moved = ScrimMoves();

  @override
  Color get barrierColor => _clear;

  @override
  void dispose() {
    _moved.dispose();
    super.dispose();
  }

  @override
  bool get barrierDismissible => dismissible;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  RoutePopDisposition get popDisposition =>
      dismissible ? super.popDisposition : RoutePopDisposition.doNotPop;

  @override
  Duration get transitionDuration => _theme.motion.durationMedium;

  @override
  Duration get reverseTransitionDuration => _theme.motion.durationShort;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => _scrimmed(
    animation: animation,
    scrim: _scrimColor,
    shape: _shape,
    box: _box,
    self: _self,
    moved: _moved,
    frame: CamouflageProvider(
      skin: _scope?.skin,
      theme: _scope?.theme,
      child: Builder(
        builder: (context) => CamoDialogFrame(
          dismissible: dismissible,
          onDismissRequest: () => Navigator.maybePop(context),
          child: builder(context),
        ),
      ),
    ),
  );

  // The frame fades and scales the dialog in itself (the scrim only fades).
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

/// Opens [builder]'s content as a bottom sheet and returns the value it's popped with (`null` when dismissed).
/// The one-file pattern: give the sheet a `static Future<T?> show(BuildContext context)` calling this.
/// [useRootNavigator] (the default) makes it cover bottom navigation bars and shell routes.
Future<T?> showCamoBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
  bool dragToDismiss = true,
  bool useRootNavigator = true,
}) => Navigator.of(context, rootNavigator: useRootNavigator).push(
  CamoSheetRoute<T>(
    context: context,
    builder: builder,
    dismissible: dismissible,
    dragToDismiss: dragToDismiss,
  ),
);

/// Opens [builder]'s content as a dialog and returns the value it's popped with (`null` when dismissed).
Future<T?> showCamoDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
  bool useRootNavigator = true,
}) => Navigator.of(context, rootNavigator: useRootNavigator).push(
  CamoDialogRoute<T>(
    context: context,
    builder: builder,
    dismissible: dismissible,
  ),
);

/// A bottom sheet as a `Page`, for routers built on pages (GoRouter's `pageBuilder`): it creates the same
/// [CamoSheetRoute] as [showCamoBottomSheet], so `await context.push<T>('/…')` returns the popped value.
class CamoSheetPage<T> extends Page<T> {
  /// Creates the page.
  const CamoSheetPage({
    super.key,
    super.name,
    super.arguments,
    required this.child,
    this.dismissible = true,
    this.dragToDismiss = true,
  });

  /// The sheet's content.
  final Widget child;

  /// `false`: only the app closes it.
  final bool dismissible;

  /// `false`: dragging doesn't close it.
  final bool dragToDismiss;

  @override
  Route<T> createRoute(BuildContext context) => CamoSheetRoute<T>(
    context: context,
    settings: this,
    builder: (_) => child,
    dismissible: dismissible,
    dragToDismiss: dragToDismiss,
  );
}

/// A dialog as a `Page` (GoRouter's `pageBuilder`): it creates the same [CamoDialogRoute] as [showCamoDialog].
class CamoDialogPage<T> extends Page<T> {
  /// Creates the page.
  const CamoDialogPage({
    super.key,
    super.name,
    super.arguments,
    required this.child,
    this.dismissible = true,
  });

  /// The dialog's content.
  final Widget child;

  /// `false`: only the app closes it.
  final bool dismissible;

  @override
  Route<T> createRoute(BuildContext context) => CamoDialogRoute<T>(
    context: context,
    settings: this,
    builder: (_) => child,
    dismissible: dismissible,
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
