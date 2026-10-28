import 'package:flutter/widgets.dart';

import '../button/camo_button.dart';
import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../provider/camouflage_provider.dart';
import '../textfield/camo_text_field.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// The default status icon per tone, so a brand can use its own icon set. Snackbars use the same icons.
@immutable
class ToneIcons {
  /// Creates ToneIcons.
  const ToneIcons({
    required this.info,
    required this.success,
    required this.warning,
    required this.error,
  });

  /// Info.
  final IconSource info;

  /// Success.
  final IconSource success;

  /// Warning.
  final IconSource warning;

  /// Error.
  final IconSource error;

  /// The icon for [tone], or `null` for the default tone.
  IconSource? ofTone(Tone tone) => switch (tone) {
    Tone.info => info,
    Tone.success => success,
    Tone.warning => warning,
    Tone.error => error,
    Tone.defaultTone => null,
  };

  @override
  bool operator ==(Object other) =>
      other is ToneIcons &&
      other.info == info &&
      other.success == success &&
      other.warning == warning &&
      other.error == error;

  @override
  int get hashCode => Object.hash(info, success, warning, error);
}

/// A banner's colors: [accent] is the tone's strong color (actions, the accent border, an outline).
@immutable
class BannerColors {
  /// Creates BannerColors.
  const BannerColors({
    required this.container,
    required this.content,
    required this.accent,
    this.border,
  });

  /// The fill.
  final Color container;

  /// The texts.
  final Color content;

  /// The icon and actions.
  final Color accent;

  /// The outline, if any.
  final Color? border;

  @override
  bool operator ==(Object other) =>
      other is BannerColors &&
      other.container == container &&
      other.content == content &&
      other.accent == accent &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, content, accent, border);
}

/// The words banners say themselves: the ✕ button's name.
@immutable
class BannerStrings {
  /// Creates BannerStrings.
  const BannerStrings({this.dismiss = 'Dismiss'});

  /// The ✕ button's name.
  final String dismiss;

  @override
  bool operator ==(Object other) =>
      other is BannerStrings && other.dismiss == dismiss;

  @override
  int get hashCode => dismiss.hashCode;
}

/// Overrides for banners; `null` keeps the skin's default.
@immutable
class CamoBannerTheme {
  /// Creates CamoBannerTheme.
  const CamoBannerTheme({
    this.defaultAppearance,
    this.shape,
    this.padding,
    this.titleStyle,
    this.messageStyle,
    this.iconSize,
    this.accentBorder,
    this.accentWidth,
    this.borderWidth,
    this.toneIcons,
    this.dismissIcon,
    this.strings,
  });

  /// The appearance when a banner passes none.
  final Appearance? defaultAppearance;

  /// The corners.
  final BorderRadius? shape;

  /// Inside the banner.
  final EdgeInsetsDirectional? padding;

  /// The title.
  final TextStyle? titleStyle;

  /// The message.
  final TextStyle? messageStyle;

  /// The status icon.
  final double? iconSize;

  /// A start border in the tone's strong color (Carbon style).
  final bool? accentBorder;

  /// The accent border.
  final double? accentWidth;

  /// The outline appearance.
  final double? borderWidth;

  /// The default status icons.
  final ToneIcons? toneIcons;

  /// The ✕ button's icon.
  final IconSource? dismissIcon;

  /// The words banners say.
  final BannerStrings? strings;

  /// A copy with the given fields replaced.
  CamoBannerTheme copyWith({
    Appearance? defaultAppearance,
    BorderRadius? shape,
    EdgeInsetsDirectional? padding,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    double? iconSize,
    bool? accentBorder,
    double? accentWidth,
    double? borderWidth,
    ToneIcons? toneIcons,
    IconSource? dismissIcon,
    BannerStrings? strings,
  }) => CamoBannerTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    shape: shape ?? this.shape,
    padding: padding ?? this.padding,
    titleStyle: titleStyle ?? this.titleStyle,
    messageStyle: messageStyle ?? this.messageStyle,
    iconSize: iconSize ?? this.iconSize,
    accentBorder: accentBorder ?? this.accentBorder,
    accentWidth: accentWidth ?? this.accentWidth,
    borderWidth: borderWidth ?? this.borderWidth,
    toneIcons: toneIcons ?? this.toneIcons,
    dismissIcon: dismissIcon ?? this.dismissIcon,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoBannerTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.shape == shape &&
      other.padding == padding &&
      other.titleStyle == titleStyle &&
      other.messageStyle == messageStyle &&
      other.iconSize == iconSize &&
      other.accentBorder == accentBorder &&
      other.accentWidth == accentWidth &&
      other.borderWidth == borderWidth &&
      other.toneIcons == toneIcons &&
      other.dismissIcon == dismissIcon &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    shape,
    padding,
    titleStyle,
    messageStyle,
    iconSize,
    accentBorder,
    accentWidth,
    borderWidth,
    toneIcons,
    dismissIcon,
    strings,
  );
}

/// The resolved banner style: every field set.
@immutable
class CamoBannerStyle {
  /// Creates CamoBannerStyle.
  const CamoBannerStyle({
    required this.defaultAppearance,
    required this.shape,
    required this.padding,
    required this.titleStyle,
    required this.messageStyle,
    required this.iconSize,
    required this.accentBorder,
    required this.accentWidth,
    required this.borderWidth,
    required this.toneIcons,
    required this.dismissIcon,
    this.strings = const BannerStrings(),
  });

  /// The appearance when a banner passes none.
  final Appearance defaultAppearance;

  /// The corners.
  final BorderRadius shape;

  /// Inside the banner.
  final EdgeInsetsDirectional padding;

  /// The title.
  final TextStyle titleStyle;

  /// The message.
  final TextStyle messageStyle;

  /// The status icon.
  final double iconSize;

  /// A start border in the tone's strong color (Carbon style).
  final bool accentBorder;

  /// The accent border.
  final double accentWidth;

  /// The outline appearance.
  final double borderWidth;

  /// The default status icons.
  final ToneIcons toneIcons;

  /// The ✕ button's icon.
  final IconSource dismissIcon;

  /// The words banners say.
  final BannerStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoBannerStyle merge(CamoBannerTheme? o) => o == null
      ? this
      : CamoBannerStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          shape: o.shape ?? shape,
          padding: o.padding ?? padding,
          titleStyle: o.titleStyle ?? titleStyle,
          messageStyle: o.messageStyle ?? messageStyle,
          iconSize: o.iconSize ?? iconSize,
          accentBorder: o.accentBorder ?? accentBorder,
          accentWidth: o.accentWidth ?? accentWidth,
          borderWidth: o.borderWidth ?? borderWidth,
          toneIcons: o.toneIcons ?? toneIcons,
          dismissIcon: o.dismissIcon ?? dismissIcon,
          strings: o.strings ?? strings,
        );

  /// The colors for [appearance] in [tone] (the default tone is the primary family): soft the tone's container,
  /// solid its strong fill, outline the surface with a border in the strong color.
  BannerColors colorsFor(Appearance appearance, Tone tone, CamoTheme theme) {
    final f = theme.colors.family(tone);
    return switch (appearance) {
      Appearance.solid => BannerColors(
        container: f.strong,
        content: f.onStrong,
        accent: f.onStrong,
      ),
      Appearance.outline => BannerColors(
        container: theme.colors.surface,
        content: theme.colors.onSurface,
        accent: f.strong,
        border: f.strong,
      ),
      _ => BannerColors(
        container: f.container,
        content: f.onContainer,
        accent: f.strong,
      ),
    };
  }
}

/// What a banner renderer draws. [appearance] is resolved (soft, solid or outline).
@immutable
class BannerState {
  /// Creates BannerState.
  const BannerState({
    required this.title,
    required this.message,
    required this.tone,
    required this.appearance,
    required this.dismissible,
  });

  /// The title, if any.
  final String? title;

  /// The message.
  final String message;

  /// The status tone.
  final Tone tone;

  /// The resolved appearance.
  final Appearance appearance;

  /// Whether it has a ✕.
  final bool dismissible;

  @override
  bool operator ==(Object other) =>
      other is BannerState &&
      other.title == title &&
      other.message == message &&
      other.tone == tone &&
      other.appearance == appearance &&
      other.dismissible == dismissible;

  @override
  int get hashCode =>
      Object.hash(title, message, tone, appearance, dismissible);
}

/// The appearance a banner draws for [a]: soft, solid or outline (the others fall back to soft).
Appearance bannerAppearance(Appearance a) => switch (a) {
  Appearance.solid || Appearance.outline => a,
  _ => Appearance.soft,
};

/// A banner's parts: the status [icon] (`null` for none), the app's [actions] (usually ghost `CamoButton`s; the
/// renderer lays them out, below the texts or at the end), and the [dismiss] ✕ core builds when it's dismissible.
@immutable
class BannerSlots {
  /// Creates the slots.
  const BannerSlots({this.icon, this.actions = const [], this.dismiss});

  /// The status icon.
  final Widget? icon;

  /// The actions.
  final List<Widget> actions;

  /// The ✕ button.
  final Widget? dismiss;
}

/// Draws banners. Provide the texts' color to the slots, and the accent color around the actions: core gives
/// their ghost and link buttons that color.
abstract interface class CamoBannerRenderer {
  /// The complete banner style for [theme].
  CamoBannerStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    BannerState state,
    BannerSlots slots,
    CamoTheme theme,
    CamoBannerStyle style,
  );
}

/// An inline message that stays in the page until it's resolved ("Couldn't sync · Retry", a form's error
/// summary), in a [tone] with its status icon (the theme's by default; `icon: SizedBox.shrink()` shows none).
/// [actions] are usually ghost `CamoButton`s, at most two, and take the banner's accent color; [onDismiss] adds a
/// ✕. Tone isn't carried by color alone: the icon and the texts carry it too. A warning or error banner is a
/// live region, so one that appears after the page loaded is announced.
class CamoBanner extends StatelessWidget {
  /// Creates a banner.
  const CamoBanner({
    super.key,
    required this.message,
    this.tone = Tone.info,
    this.title,
    this.icon,
    this.actions = const [],
    this.onDismiss,
    this.appearance,
  });

  /// The message.
  final String message;

  /// The status tone.
  final Tone tone;

  /// An optional title.
  final String? title;

  /// `null` uses the theme's icon for the tone.
  final Widget? icon;

  /// Usually ghost `CamoButton`s.
  final List<Widget> actions;

  /// Non-null adds a ✕.
  final VoidCallback? onDismiss;

  /// `null` uses `CamoBannerTheme.defaultAppearance`.
  final Appearance? appearance;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoBanner');
    final theme = Camouflage.themeOf(context, component: 'CamoBanner');
    final style = skin.banner.defaults(theme).merge(theme.components.banner);
    final toneIcon = style.toneIcons.ofTone(tone);
    final onDismiss = this.onDismiss;
    final buttons = theme.components.button ?? const CamoButtonTheme();
    // Ghost and link buttons among the actions take the accent the renderer provides around them: the tone on a
    // soft or outline banner, the on-color on a solid one.
    final toned = [
      for (final action in actions)
        Builder(
          builder: (context) {
            final accent = Camouflage.contentColorOf(context);
            final colors = ButtonColors(
              container: const Color(0x00000000),
              content: accent,
            );
            return CamouflageProvider(
              theme: theme.copyWith(
                components: theme.components.copyWith(
                  button: buttons.copyWith(
                    ghostColors: colors,
                    linkColors: colors,
                  ),
                ),
              ),
              child: action,
            );
          },
        ),
    ];
    final alert = tone == Tone.error || tone == Tone.warning;
    return Semantics(
      container: true,
      liveRegion: alert,
      child: skin.banner.render(
        context,
        BannerState(
          title: title,
          message: message,
          tone: tone,
          appearance: bannerAppearance(appearance ?? style.defaultAppearance),
          dismissible: onDismiss != null,
        ),
        BannerSlots(
          icon: icon ?? (toneIcon == null ? null : CamoIcon(toneIcon)),
          actions: toned,
          // Its own node, so it isn't merged into the banner's.
          dismiss: onDismiss == null
              ? null
              : Semantics(
                  container: true,
                  child: CamoFieldAction(
                    icon: CamoIcon(style.dismissIcon),
                    semanticLabel: style.strings.dismiss,
                    onPressed: onDismiss,
                  ),
                ),
        ),
        theme,
        style,
      ),
    );
  }
}
