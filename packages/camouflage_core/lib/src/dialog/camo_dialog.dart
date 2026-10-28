import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../bottom_sheet/camo_bottom_sheet.dart' show StackedScrim;
import '../icon/camo_icon.dart';
import '../overlay/scrim_hole.dart';
import '../provider/camouflage.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// How a dialog arranges its actions.
enum DialogActionsLayout {
  /// Side by side at the end.
  end,

  /// Side by side, centered.
  center,

  /// A full-width row with equal halves.
  fullWidthRow,

  /// One above the other, `confirm` on top, full width.
  stacked,
}

/// Every color a dialog uses.
@immutable
class DialogColors {
  /// Creates DialogColors.
  const DialogColors({
    required this.container,
    required this.title,
    required this.message,
  });

  /// The dialog's fill.
  final Color container;

  /// The title.
  final Color title;

  /// The message.
  final Color message;

  @override
  bool operator ==(Object other) =>
      other is DialogColors &&
      other.container == container &&
      other.title == title &&
      other.message == message;

  @override
  int get hashCode => Object.hash(container, title, message);
}

/// Overrides for dialogs; `null` keeps the skin's default.
@immutable
class CamoDialogTheme {
  /// Creates CamoDialogTheme.
  const CamoDialogTheme({
    this.shape,
    this.minWidth,
    this.maxWidth,
    this.padding,
    this.titleStyle,
    this.messageStyle,
    this.titleAlign,
    this.actionsLayout,
    this.actionGap,
    this.sectionGap,
    this.showCloseButton,
    this.closeIcon,
    this.elevation,
    this.scrimAlpha,
    this.stackedScrim,
    this.colors,
  });

  /// The corners.
  final BorderRadius? shape;

  /// The narrowest dialog.
  final double? minWidth;

  /// The widest dialog (and 48 narrower than the window).
  final double? maxWidth;

  /// Inside the dialog.
  final EdgeInsetsDirectional? padding;

  /// The title.
  final TextStyle? titleStyle;

  /// The message.
  final TextStyle? messageStyle;

  /// Where the title and message align.
  final CamoTitleAlign? titleAlign;

  /// How the actions are arranged.
  final DialogActionsLayout? actionsLayout;

  /// Between the actions.
  final double? actionGap;

  /// Between the title, the message, the content and the actions.
  final double? sectionGap;

  /// A close button at the top end, shown only when the dialog is dismissible.
  final bool? showCloseButton;

  /// The close button's icon.
  final IconSource? closeIcon;

  /// Depth.
  final ElevationLevel? elevation;

  /// The scrim's opacity over `colors.scrim`.
  final double? scrimAlpha;

  /// Above another overlay: its own scrim or the one below.
  final StackedScrim? stackedScrim;

  /// Every color it uses.
  final DialogColors? colors;

  /// A copy with the given fields replaced.
  CamoDialogTheme copyWith({
    BorderRadius? shape,
    double? minWidth,
    double? maxWidth,
    EdgeInsetsDirectional? padding,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    CamoTitleAlign? titleAlign,
    DialogActionsLayout? actionsLayout,
    double? actionGap,
    double? sectionGap,
    bool? showCloseButton,
    IconSource? closeIcon,
    ElevationLevel? elevation,
    double? scrimAlpha,
    StackedScrim? stackedScrim,
    DialogColors? colors,
  }) => CamoDialogTheme(
    shape: shape ?? this.shape,
    minWidth: minWidth ?? this.minWidth,
    maxWidth: maxWidth ?? this.maxWidth,
    padding: padding ?? this.padding,
    titleStyle: titleStyle ?? this.titleStyle,
    messageStyle: messageStyle ?? this.messageStyle,
    titleAlign: titleAlign ?? this.titleAlign,
    actionsLayout: actionsLayout ?? this.actionsLayout,
    actionGap: actionGap ?? this.actionGap,
    sectionGap: sectionGap ?? this.sectionGap,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    closeIcon: closeIcon ?? this.closeIcon,
    elevation: elevation ?? this.elevation,
    scrimAlpha: scrimAlpha ?? this.scrimAlpha,
    stackedScrim: stackedScrim ?? this.stackedScrim,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoDialogTheme &&
      other.shape == shape &&
      other.minWidth == minWidth &&
      other.maxWidth == maxWidth &&
      other.padding == padding &&
      other.titleStyle == titleStyle &&
      other.messageStyle == messageStyle &&
      other.titleAlign == titleAlign &&
      other.actionsLayout == actionsLayout &&
      other.actionGap == actionGap &&
      other.sectionGap == sectionGap &&
      other.showCloseButton == showCloseButton &&
      other.closeIcon == closeIcon &&
      other.elevation == elevation &&
      other.scrimAlpha == scrimAlpha &&
      other.stackedScrim == stackedScrim &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    shape,
    minWidth,
    maxWidth,
    padding,
    titleStyle,
    messageStyle,
    titleAlign,
    actionsLayout,
    actionGap,
    sectionGap,
    showCloseButton,
    closeIcon,
    elevation,
    scrimAlpha,
    stackedScrim,
    colors,
  );
}

/// The resolved dialog style: every field set.
@immutable
class CamoDialogStyle {
  /// Creates CamoDialogStyle.
  const CamoDialogStyle({
    required this.shape,
    required this.minWidth,
    required this.maxWidth,
    required this.padding,
    required this.titleStyle,
    required this.messageStyle,
    required this.titleAlign,
    required this.actionsLayout,
    required this.actionGap,
    required this.sectionGap,
    required this.showCloseButton,
    required this.closeIcon,
    required this.elevation,
    required this.scrimAlpha,
    required this.stackedScrim,
    required this.colors,
  });

  /// The corners.
  final BorderRadius shape;

  /// The narrowest dialog.
  final double minWidth;

  /// The widest dialog (and 48 narrower than the window).
  final double maxWidth;

  /// Inside the dialog.
  final EdgeInsetsDirectional padding;

  /// The title.
  final TextStyle titleStyle;

  /// The message.
  final TextStyle messageStyle;

  /// Where the title and message align.
  final CamoTitleAlign titleAlign;

  /// How the actions are arranged.
  final DialogActionsLayout actionsLayout;

  /// Between the actions.
  final double actionGap;

  /// Between the title, the message, the content and the actions.
  final double sectionGap;

  /// A close button at the top end, shown only when the dialog is dismissible.
  final bool showCloseButton;

  /// The close button's icon.
  final IconSource closeIcon;

  /// Depth.
  final ElevationLevel elevation;

  /// The scrim's opacity over `colors.scrim`.
  final double scrimAlpha;

  /// Above another overlay: its own scrim or the one below.
  final StackedScrim stackedScrim;

  /// Every color it uses.
  final DialogColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoDialogStyle merge(CamoDialogTheme? o) => o == null
      ? this
      : CamoDialogStyle(
          shape: o.shape ?? shape,
          minWidth: o.minWidth ?? minWidth,
          maxWidth: o.maxWidth ?? maxWidth,
          padding: o.padding ?? padding,
          titleStyle: o.titleStyle ?? titleStyle,
          messageStyle: o.messageStyle ?? messageStyle,
          titleAlign: o.titleAlign ?? titleAlign,
          actionsLayout: o.actionsLayout ?? actionsLayout,
          actionGap: o.actionGap ?? actionGap,
          sectionGap: o.sectionGap ?? sectionGap,
          showCloseButton: o.showCloseButton ?? showCloseButton,
          closeIcon: o.closeIcon ?? closeIcon,
          elevation: o.elevation ?? elevation,
          scrimAlpha: o.scrimAlpha ?? scrimAlpha,
          stackedScrim: o.stackedScrim ?? stackedScrim,
          colors: o.colors ?? colors,
        );
}

/// What a dialog renderer draws: the container, the [title] (aligned by `titleAlign`), the [message], the
/// content and the actions arranged by `actionsLayout`. With `showCloseButton` and [dismissible], a close button
/// at the top end calls [onDismissRequest], the same path as Esc and back. Keep the title and actions fixed and
/// let the message and content scroll when they don't fit.
@immutable
class DialogState {
  /// Creates a dialog state.
  const DialogState({
    required this.title,
    required this.message,
    required this.dismissible,
    required this.onDismissRequest,
  });

  /// The heading, if any.
  final String? title;

  /// The main text.
  final String message;

  /// Whether the user may close it (scrim, back, Esc, the close button).
  final bool dismissible;

  /// Asks to close it, through the frame (a `PopScope` may veto).
  final VoidCallback onDismissRequest;
}

/// The caller's actions and optional content (a radio list, a small form).
@immutable
class DialogSlots {
  /// Creates the slots.
  const DialogSlots({required this.confirm, this.dismiss, this.content});

  /// The main action.
  final Widget confirm;

  /// The action that closes without a result.
  final Widget? dismiss;

  /// Content below the message.
  final Widget? content;
}

/// Draws dialogs. Core frames, centers and dismisses them.
abstract interface class CamoDialogRenderer {
  /// The complete dialog style for [theme].
  CamoDialogStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    DialogState state,
    DialogSlots slots,
    CamoTheme theme,
    CamoDialogStyle style,
  );
}

class _DialogFrameScope extends InheritedWidget {
  const _DialogFrameScope({
    required this.dismissible,
    required this.onDismissRequest,
    required super.child,
  });

  final bool dismissible;
  final VoidCallback onDismissRequest;

  @override
  bool updateShouldNotify(_DialogFrameScope old) =>
      old.dismissible != dismissible ||
      old.onDismissRequest != onDismissRequest;
}

const _maxHeightFraction = 0.9;

/// The frame of a dialog (base Overlays §3.1): the dialog centered at most `maxWidth` wide (and 48 narrower than
/// the window) and 90% of the window tall, above the keyboard. The route around it (`showCamoDialog`) draws the
/// scrim, traps focus and turns a scrim tap, back and Esc into [onDismissRequest].
class CamoDialogFrame extends StatelessWidget {
  /// Creates a frame around [child].
  const CamoDialogFrame({
    super.key,
    required this.onDismissRequest,
    this.dismissible = true,
    required this.child,
  });

  /// Asks to close the dialog.
  final VoidCallback onDismissRequest;

  /// `false`: only the app closes it.
  final bool dismissible;

  /// Usually a `CamoDialog`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDialogFrame');
    final theme = Camouflage.themeOf(context, component: 'CamoDialogFrame');
    final style = skin.dialog.defaults(theme).merge(theme.components.dialog);
    final insets = MediaQuery.viewInsetsOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      // The space the route gives it (the window), so a small window gets a narrower dialog, never a negative one.
      child: LayoutBuilder(
        builder: (context, space) {
          final width = math.max(
            0.0,
            math.min(style.maxWidth, space.maxWidth - theme.spacing.xl * 2),
          );
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: math.min(style.minWidth, width),
                maxWidth: width,
                maxHeight: space.maxHeight * _maxHeightFraction,
              ),
              child: _enter(
                context,
                theme,
                _DialogFrameScope(
                  dismissible: dismissible,
                  onDismissRequest: onDismissRequest,
                  child: _hole(context, child),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

const _enterScale = 0.9;

Widget _hole(BuildContext context, Widget child) {
  final hole = ScrimHole.maybeOf(context);
  return hole == null ? child : ScrimHoleBox(box: hole.box, child: child);
}

// In a Camouflage route the frame fades and scales the dialog in; the route only fades the scrim.
Widget _enter(BuildContext context, CamoTheme theme, Widget dialog) {
  final route = ScrimHole.maybeOf(context) == null
      ? null
      : ModalRoute.of(context)?.animation;
  if (route == null) return dialog;
  final curved = CurvedAnimation(
    parent: route,
    curve: theme.motion.easingEmphasized,
  );
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween(begin: _enterScale, end: 1.0).animate(curved),
      child: dialog,
    ),
  );
}

/// A dialog's content: an optional [title] (its accessible name), the [message], optional [content] (a radio
/// list, a small form) and the actions. [confirm] and [dismiss] are usually `CamoButton`s that close it with
/// `Navigator.pop(context, result)`. Open it with `showCamoDialog`.
class CamoDialog extends StatelessWidget {
  /// Creates a dialog.
  const CamoDialog({
    super.key,
    required this.message,
    required this.confirm,
    this.title,
    this.dismiss,
    this.content,
  });

  /// The main text.
  final String message;

  /// The main action.
  final Widget confirm;

  /// The heading and accessible name.
  final String? title;

  /// The action that closes without a result.
  final Widget? dismiss;

  /// Content below the message.
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDialog');
    final theme = Camouflage.themeOf(context, component: 'CamoDialog');
    final style = skin.dialog.defaults(theme).merge(theme.components.dialog);
    final frame = context
        .dependOnInheritedWidgetOfExactType<_DialogFrameScope>();
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title ?? message,
      child: skin.dialog.render(
        context,
        DialogState(
          title: title,
          message: message,
          dismissible: frame?.dismissible ?? false,
          onDismissRequest: frame?.onDismissRequest ?? () {},
        ),
        DialogSlots(confirm: confirm, dismiss: dismiss, content: content),
        theme,
        style,
      ),
    );
  }
}
