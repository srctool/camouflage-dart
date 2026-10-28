import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// How long a snackbar stays. `auto` is `short`, or `long` when it has an action.
enum SnackbarDuration {
  /// The short duration (4 s by default).
  short,

  /// The long duration (10 s by default).
  long,

  /// Until it's dismissed or its action is tapped.
  indefinite,

  /// `short`, or `long` with an action.
  auto,
}

/// How a snackbar left: its action was tapped, or it was dismissed (timeout, swipe, ✕, `dismissCurrent`).
enum SnackbarResult {
  /// The action was tapped.
  actionPerformed,

  /// It timed out or was dismissed.
  dismissed,
}

/// Where snackbars appear, on every window size.
enum SnackbarPosition {
  /// The bottom edge.
  bottom,

  /// The top edge, below the status bar.
  top,
}

/// Where a snackbar narrower than the window sits along its edge (start and end follow the reading direction).
enum SnackbarAlignment {
  /// The start side.
  start,

  /// Centered.
  center,

  /// The end side.
  end,
}

/// A snackbar's colors for the default tone.
@immutable
class SnackbarColors {
  /// Creates SnackbarColors.
  const SnackbarColors({
    required this.container,
    required this.text,
    required this.action,
  });

  /// The fill.
  final Color container;

  /// The message and icons.
  final Color text;

  /// The action.
  final Color action;

  @override
  bool operator ==(Object other) =>
      other is SnackbarColors &&
      other.container == container &&
      other.text == text &&
      other.action == action;

  @override
  int get hashCode => Object.hash(container, text, action);
}

/// The words snackbars say themselves: the ✕ button's name.
@immutable
class SnackbarStrings {
  /// Creates SnackbarStrings.
  const SnackbarStrings({this.dismiss = 'Dismiss'});

  /// The ✕ button's name.
  final String dismiss;

  @override
  bool operator ==(Object other) =>
      other is SnackbarStrings && other.dismiss == dismiss;

  @override
  int get hashCode => dismiss.hashCode;
}

/// Overrides for snackbars; `null` keeps the skin's default.
@immutable
class CamoSnackbarTheme {
  /// Creates CamoSnackbarTheme.
  const CamoSnackbarTheme({
    this.shape,
    this.maxWidth,
    this.margin,
    this.padding,
    this.minHeight,
    this.textStyle,
    this.actionStyle,
    this.elevation,
    this.position,
    this.alignment,
    this.showDismiss,
    this.showToneIcon,
    this.durationShort,
    this.durationLong,
    this.colors,
    this.dismissIcon,
    this.strings,
  });

  /// The corners.
  final BorderRadius? shape;

  /// The widest a snackbar gets; centered or aligned on wide windows.
  final double? maxWidth;

  /// The distance from the window's edges (beyond the safe area and `CamoMessengerInsets`).
  final double? margin;

  /// Inside the snackbar.
  final EdgeInsetsDirectional? padding;

  /// The shortest a snackbar gets.
  final double? minHeight;

  /// The message.
  final TextStyle? textStyle;

  /// The action.
  final TextStyle? actionStyle;

  /// The depth.
  final ElevationLevel? elevation;

  /// Where snackbars appear (a brand choice).
  final SnackbarPosition? position;

  /// Where a snackbar sits along its edge.
  final SnackbarAlignment? alignment;

  /// A ✕ on every snackbar whose call passes no `withDismiss`.
  final bool? showDismiss;

  /// A leading status icon for the status tones (`CamoBannerTheme.toneIcons`, so banners and snackbars match).
  final bool? showToneIcon;

  /// The short duration.
  final Duration? durationShort;

  /// The long duration.
  final Duration? durationLong;

  /// The colors for the default tone.
  final SnackbarColors? colors;

  /// The ✕ button's icon.
  final IconSource? dismissIcon;

  /// The words snackbars say.
  final SnackbarStrings? strings;

  /// A copy with the given fields replaced.
  CamoSnackbarTheme copyWith({
    BorderRadius? shape,
    double? maxWidth,
    double? margin,
    EdgeInsetsDirectional? padding,
    double? minHeight,
    TextStyle? textStyle,
    TextStyle? actionStyle,
    ElevationLevel? elevation,
    SnackbarPosition? position,
    SnackbarAlignment? alignment,
    bool? showDismiss,
    bool? showToneIcon,
    Duration? durationShort,
    Duration? durationLong,
    SnackbarColors? colors,
    IconSource? dismissIcon,
    SnackbarStrings? strings,
  }) => CamoSnackbarTheme(
    shape: shape ?? this.shape,
    maxWidth: maxWidth ?? this.maxWidth,
    margin: margin ?? this.margin,
    padding: padding ?? this.padding,
    minHeight: minHeight ?? this.minHeight,
    textStyle: textStyle ?? this.textStyle,
    actionStyle: actionStyle ?? this.actionStyle,
    elevation: elevation ?? this.elevation,
    position: position ?? this.position,
    alignment: alignment ?? this.alignment,
    showDismiss: showDismiss ?? this.showDismiss,
    showToneIcon: showToneIcon ?? this.showToneIcon,
    durationShort: durationShort ?? this.durationShort,
    durationLong: durationLong ?? this.durationLong,
    colors: colors ?? this.colors,
    dismissIcon: dismissIcon ?? this.dismissIcon,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSnackbarTheme &&
      other.shape == shape &&
      other.maxWidth == maxWidth &&
      other.margin == margin &&
      other.padding == padding &&
      other.minHeight == minHeight &&
      other.textStyle == textStyle &&
      other.actionStyle == actionStyle &&
      other.elevation == elevation &&
      other.position == position &&
      other.alignment == alignment &&
      other.showDismiss == showDismiss &&
      other.showToneIcon == showToneIcon &&
      other.durationShort == durationShort &&
      other.durationLong == durationLong &&
      other.colors == colors &&
      other.dismissIcon == dismissIcon &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    shape,
    maxWidth,
    margin,
    padding,
    minHeight,
    textStyle,
    actionStyle,
    elevation,
    position,
    alignment,
    showDismiss,
    showToneIcon,
    durationShort,
    durationLong,
    colors,
    dismissIcon,
    strings,
  );
}

/// The resolved snackbar style: every field set. [colors] is for the default tone.
@immutable
class CamoSnackbarStyle {
  /// Creates CamoSnackbarStyle.
  const CamoSnackbarStyle({
    required this.shape,
    required this.maxWidth,
    required this.margin,
    required this.padding,
    required this.minHeight,
    required this.textStyle,
    required this.actionStyle,
    required this.elevation,
    required this.position,
    required this.alignment,
    required this.showDismiss,
    required this.showToneIcon,
    required this.durationShort,
    required this.durationLong,
    required this.colors,
    required this.dismissIcon,
    this.strings = const SnackbarStrings(),
  });

  /// The corners.
  final BorderRadius shape;

  /// The widest a snackbar gets; centered or aligned on wide windows.
  final double maxWidth;

  /// The distance from the window's edges (beyond the safe area and `CamoMessengerInsets`).
  final double margin;

  /// Inside the snackbar.
  final EdgeInsetsDirectional padding;

  /// The shortest a snackbar gets.
  final double minHeight;

  /// The message.
  final TextStyle textStyle;

  /// The action.
  final TextStyle actionStyle;

  /// The depth.
  final ElevationLevel elevation;

  /// Where snackbars appear (a brand choice).
  final SnackbarPosition position;

  /// Where a snackbar sits along its edge.
  final SnackbarAlignment alignment;

  /// A ✕ on every snackbar whose call passes no `withDismiss`.
  final bool showDismiss;

  /// A leading status icon for the status tones (`CamoBannerTheme.toneIcons`, so banners and snackbars match).
  final bool showToneIcon;

  /// The short duration.
  final Duration durationShort;

  /// The long duration.
  final Duration durationLong;

  /// The colors for the default tone.
  final SnackbarColors colors;

  /// The ✕ button's icon.
  final IconSource dismissIcon;

  /// The words snackbars say.
  final SnackbarStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoSnackbarStyle merge(CamoSnackbarTheme? o) => o == null
      ? this
      : CamoSnackbarStyle(
          shape: o.shape ?? shape,
          maxWidth: o.maxWidth ?? maxWidth,
          margin: o.margin ?? margin,
          padding: o.padding ?? padding,
          minHeight: o.minHeight ?? minHeight,
          textStyle: o.textStyle ?? textStyle,
          actionStyle: o.actionStyle ?? actionStyle,
          elevation: o.elevation ?? elevation,
          position: o.position ?? position,
          alignment: o.alignment ?? alignment,
          showDismiss: o.showDismiss ?? showDismiss,
          showToneIcon: o.showToneIcon ?? showToneIcon,
          durationShort: o.durationShort ?? durationShort,
          durationLong: o.durationLong ?? durationLong,
          colors: o.colors ?? colors,
          dismissIcon: o.dismissIcon ?? dismissIcon,
          strings: o.strings ?? strings,
        );

  /// The colors for [tone]: this style's for the default tone, the tone's strong family otherwise.
  SnackbarColors colorsFor(Tone tone, CamoTheme theme) {
    if (tone == Tone.defaultTone) return colors;
    final f = theme.colors.family(tone);
    return SnackbarColors(
      container: f.strong,
      text: f.onStrong,
      action: f.onStrong,
    );
  }
}

/// What a snackbar renderer draws. [withDismiss] and [showToneIcon] are resolved; the slots hold those parts.
@immutable
class SnackbarState {
  /// Creates SnackbarState.
  const SnackbarState({
    required this.message,
    required this.action,
    required this.tone,
    required this.withDismiss,
    required this.showToneIcon,
    required this.position,
    required this.interaction,
  });

  /// The message.
  final String message;

  /// The action's label, if any.
  final String? action;

  /// The status tone.
  final Tone tone;

  /// Whether it has a ✕.
  final bool withDismiss;

  /// Whether it shows the tone icon.
  final bool showToneIcon;

  /// Its edge.
  final SnackbarPosition position;

  /// Hover and focus.
  final InteractionState interaction;

  @override
  bool operator ==(Object other) =>
      other is SnackbarState &&
      other.message == message &&
      other.action == action &&
      other.tone == tone &&
      other.withDismiss == withDismiss &&
      other.showToneIcon == showToneIcon &&
      other.position == position &&
      other.interaction == interaction;

  @override
  int get hashCode => Object.hash(
    message,
    action,
    tone,
    withDismiss,
    showToneIcon,
    position,
    interaction,
  );
}

/// The parts core builds and the renderer places: the tone's [icon] (before the message), the [action] button
/// and the [dismiss] ✕ (after it). Each is `null` when the snackbar has none. The buttons are their own focusable
/// nodes. They draw in the content color the renderer provides with `CamoContentStyle`: the action color around
/// [action], the text or icon color around the others.
@immutable
class SnackbarSlots {
  /// Creates the slots.
  const SnackbarSlots({this.icon, this.action, this.dismiss});

  /// The tone icon.
  final Widget? icon;

  /// The action button.
  final Widget? action;

  /// The ✕ button.
  final Widget? dismiss;
}

/// Draws snackbars, as wide as they're allowed (core caps them at `maxWidth`).
abstract interface class CamoSnackbarRenderer {
  /// The complete snackbar style for [theme].
  CamoSnackbarStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    SnackbarState state,
    SnackbarSlots slots,
    CamoTheme theme,
    CamoSnackbarStyle style,
  );
}
