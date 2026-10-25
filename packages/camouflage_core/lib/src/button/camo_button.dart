import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_touch_target.dart';

/// A button's colors for one appearance. [border] is drawn only when set.
@immutable
class ButtonColors {
  /// Creates button colors.
  const ButtonColors({
    required this.container,
    required this.content,
    this.border,
  });

  /// The fill.
  final Color container;

  /// Text and icons.
  final Color content;

  /// The outline, if any.
  final Color? border;

  /// A copy with the given colors replaced.
  ButtonColors copyWith({Color? container, Color? content, Color? border}) =>
      ButtonColors(
        container: container ?? this.container,
        content: content ?? this.content,
        border: border ?? this.border,
      );

  @override
  bool operator ==(Object other) =>
      other is ButtonColors &&
      other.container == container &&
      other.content == content &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, content, border);
}

/// Overrides for buttons. Every field is optional; `null` keeps the skin's default.
@immutable
class CamoButtonTheme {
  /// Creates button overrides.
  const CamoButtonTheme({
    this.defaultAppearance,
    this.height,
    this.minWidth,
    this.shape,
    this.padding,
    this.paddingWithIcon,
    this.textStyle,
    this.iconSize,
    this.iconGap,
    this.borderWidth,
    this.raisedElevation,
    this.solidColors,
    this.softColors,
    this.raisedColors,
    this.outlineColors,
    this.ghostColors,
    this.linkColors,
    this.disabledContainerAlpha,
    this.disabledContentAlpha,
  });

  /// The appearance used when a call passes none.
  final Appearance? defaultAppearance;

  /// The container's height; it grows with text at large font scale.
  final double? height;

  /// Keeps short labels from making tiny buttons.
  final double? minWidth;

  /// The corners.
  final BorderRadius? shape;

  /// Inner padding without icons.
  final EdgeInsetsDirectional? padding;

  /// Inner padding beside an icon: `start` beside a prefix, `end` beside a suffix.
  final EdgeInsetsDirectional? paddingWithIcon;

  /// The text style.
  final TextStyle? textStyle;

  /// The ambient icon size for prefix and suffix icons.
  final double? iconSize;

  /// The space between an icon and the text.
  final double? iconGap;

  /// The Outline border's width.
  final double? borderWidth;

  /// The Raised depth.
  final ElevationLevel? raisedElevation;

  /// Solid colors for the default tone.
  final ButtonColors? solidColors;

  /// Soft colors for the default tone.
  final ButtonColors? softColors;

  /// Raised colors for the default tone.
  final ButtonColors? raisedColors;

  /// Outline colors for the default tone.
  final ButtonColors? outlineColors;

  /// Ghost colors for the default tone.
  final ButtonColors? ghostColors;

  /// Link colors for the default tone.
  final ButtonColors? linkColors;

  /// The disabled container's alpha of `onSurface`.
  final double? disabledContainerAlpha;

  /// The disabled content's alpha of `onSurface`.
  final double? disabledContentAlpha;

  /// A copy with the given fields replaced.
  CamoButtonTheme copyWith({
    Appearance? defaultAppearance,
    double? height,
    double? minWidth,
    BorderRadius? shape,
    EdgeInsetsDirectional? padding,
    EdgeInsetsDirectional? paddingWithIcon,
    TextStyle? textStyle,
    double? iconSize,
    double? iconGap,
    double? borderWidth,
    ElevationLevel? raisedElevation,
    ButtonColors? solidColors,
    ButtonColors? softColors,
    ButtonColors? raisedColors,
    ButtonColors? outlineColors,
    ButtonColors? ghostColors,
    ButtonColors? linkColors,
    double? disabledContainerAlpha,
    double? disabledContentAlpha,
  }) => CamoButtonTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    height: height ?? this.height,
    minWidth: minWidth ?? this.minWidth,
    shape: shape ?? this.shape,
    padding: padding ?? this.padding,
    paddingWithIcon: paddingWithIcon ?? this.paddingWithIcon,
    textStyle: textStyle ?? this.textStyle,
    iconSize: iconSize ?? this.iconSize,
    iconGap: iconGap ?? this.iconGap,
    borderWidth: borderWidth ?? this.borderWidth,
    raisedElevation: raisedElevation ?? this.raisedElevation,
    solidColors: solidColors ?? this.solidColors,
    softColors: softColors ?? this.softColors,
    raisedColors: raisedColors ?? this.raisedColors,
    outlineColors: outlineColors ?? this.outlineColors,
    ghostColors: ghostColors ?? this.ghostColors,
    linkColors: linkColors ?? this.linkColors,
    disabledContainerAlpha:
        disabledContainerAlpha ?? this.disabledContainerAlpha,
    disabledContentAlpha: disabledContentAlpha ?? this.disabledContentAlpha,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoButtonTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.height == height &&
      other.minWidth == minWidth &&
      other.shape == shape &&
      other.padding == padding &&
      other.paddingWithIcon == paddingWithIcon &&
      other.textStyle == textStyle &&
      other.iconSize == iconSize &&
      other.iconGap == iconGap &&
      other.borderWidth == borderWidth &&
      other.raisedElevation == raisedElevation &&
      other.solidColors == solidColors &&
      other.softColors == softColors &&
      other.raisedColors == raisedColors &&
      other.outlineColors == outlineColors &&
      other.ghostColors == ghostColors &&
      other.linkColors == linkColors &&
      other.disabledContainerAlpha == disabledContainerAlpha &&
      other.disabledContentAlpha == disabledContentAlpha;

  @override
  int get hashCode => Object.hashAll([
    defaultAppearance,
    height,
    minWidth,
    shape,
    padding,
    paddingWithIcon,
    textStyle,
    iconSize,
    iconGap,
    borderWidth,
    raisedElevation,
    solidColors,
    softColors,
    raisedColors,
    outlineColors,
    ghostColors,
    linkColors,
    disabledContainerAlpha,
    disabledContentAlpha,
  ]);
}

/// The resolved button style: every field set. The per-appearance colors are for the default tone.
@immutable
class CamoButtonStyle {
  /// Creates a button style.
  const CamoButtonStyle({
    required this.defaultAppearance,
    required this.height,
    required this.minWidth,
    required this.shape,
    required this.padding,
    required this.paddingWithIcon,
    required this.textStyle,
    required this.iconSize,
    required this.iconGap,
    required this.borderWidth,
    required this.raisedElevation,
    required this.solidColors,
    required this.softColors,
    required this.raisedColors,
    required this.outlineColors,
    required this.ghostColors,
    required this.linkColors,
    required this.disabledContainerAlpha,
    required this.disabledContentAlpha,
  });

  /// The appearance used when a call passes none.
  final Appearance defaultAppearance;

  /// The container's minimum height.
  final double height;

  /// The container's minimum width.
  final double minWidth;

  /// The corners.
  final BorderRadius shape;

  /// Inner padding without icons.
  final EdgeInsetsDirectional padding;

  /// Inner padding beside an icon.
  final EdgeInsetsDirectional paddingWithIcon;

  /// The text style.
  final TextStyle textStyle;

  /// The icon size.
  final double iconSize;

  /// The icon-to-text gap.
  final double iconGap;

  /// The Outline border's width.
  final double borderWidth;

  /// The Raised depth.
  final ElevationLevel raisedElevation;

  /// Solid colors.
  final ButtonColors solidColors;

  /// Soft colors.
  final ButtonColors softColors;

  /// Raised colors.
  final ButtonColors raisedColors;

  /// Outline colors.
  final ButtonColors outlineColors;

  /// Ghost colors.
  final ButtonColors ghostColors;

  /// Link colors.
  final ButtonColors linkColors;

  /// The disabled container alpha.
  final double disabledContainerAlpha;

  /// The disabled content alpha.
  final double disabledContentAlpha;

  /// This style with [o]'s non-null fields applied.
  CamoButtonStyle merge(CamoButtonTheme? o) => o == null
      ? this
      : CamoButtonStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          height: o.height ?? height,
          minWidth: o.minWidth ?? minWidth,
          shape: o.shape ?? shape,
          padding: o.padding ?? padding,
          paddingWithIcon: o.paddingWithIcon ?? paddingWithIcon,
          textStyle: o.textStyle ?? textStyle,
          iconSize: o.iconSize ?? iconSize,
          iconGap: o.iconGap ?? iconGap,
          borderWidth: o.borderWidth ?? borderWidth,
          raisedElevation: o.raisedElevation ?? raisedElevation,
          solidColors: o.solidColors ?? solidColors,
          softColors: o.softColors ?? softColors,
          raisedColors: o.raisedColors ?? raisedColors,
          outlineColors: o.outlineColors ?? outlineColors,
          ghostColors: o.ghostColors ?? ghostColors,
          linkColors: o.linkColors ?? linkColors,
          disabledContainerAlpha:
              o.disabledContainerAlpha ?? disabledContainerAlpha,
          disabledContentAlpha: o.disabledContentAlpha ?? disabledContentAlpha,
        );

  /// The colors for [a] in [tone]: this style's for the default tone, the tone's family otherwise.
  ButtonColors colorsFor(Appearance a, Tone tone, CamoTheme theme) {
    if (tone == Tone.defaultTone) {
      return switch (a) {
        Appearance.solid => solidColors,
        Appearance.soft => softColors,
        Appearance.raised => raisedColors,
        Appearance.outline => outlineColors,
        Appearance.ghost => ghostColors,
        Appearance.link => linkColors,
      };
    }
    final f = theme.colors.family(tone);
    const clear = Color(0x00000000);
    return switch (a) {
      Appearance.solid => ButtonColors(
        container: f.strong,
        content: f.onStrong,
      ),
      Appearance.soft => ButtonColors(
        container: f.container,
        content: f.onContainer,
      ),
      Appearance.raised => ButtonColors(
        container: raisedColors.container,
        content: f.strong,
        border: raisedColors.border,
      ),
      Appearance.outline => ButtonColors(
        container: clear,
        content: f.strong,
        border: f.strong,
      ),
      Appearance.ghost ||
      Appearance.link => ButtonColors(container: clear, content: f.strong),
    };
  }
}

/// What a button renderer draws. [controller] carries the interaction, press positions included.
@immutable
class ButtonState {
  /// Creates a button state.
  const ButtonState({
    required this.text,
    required this.enabled,
    required this.loading,
    required this.appearance,
    required this.tone,
    required this.interaction,
    required this.controller,
  });

  /// The label.
  final String text;

  /// `false` shows the disabled look.
  final bool enabled;

  /// `true` shows a progress circle in place of the text.
  final bool loading;

  /// The visual weight.
  final Appearance appearance;

  /// The color family.
  final Tone tone;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for feedback animations.
  final CamoInteractionController controller;
}

/// The caller's icons, placed before and after the text.
@immutable
class ButtonSlots {
  /// Creates button slots.
  const ButtonSlots({this.prefixIcon, this.suffixIcon});

  /// Before the text (the right in RTL).
  final Widget? prefixIcon;

  /// After the text.
  final Widget? suffixIcon;
}

/// Draws buttons. The component wraps the result in its behavior, so the renderer only draws.
abstract interface class CamoButtonRenderer {
  /// The complete button style for [theme].
  CamoButtonStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    ButtonState state,
    ButtonSlots slots,
    CamoTheme theme,
    CamoButtonStyle style,
  );
}

var _blankLabelLogged = false;

// A blank label fails in debug builds; release builds render it and log once (server text, a missing translation).
void _checkLabel(String text, String component) {
  if (text.trim().isNotEmpty) return;
  assert(
    false,
    '$component needs a non-blank text. An icon-only action is a CamoIconButton.',
  );
  if (!_blankLabelLogged) {
    _blankLabelLogged = true;
    debugPrint('Camouflage: $component was given a blank text.');
  }
}

/// A button with a text label. `onPressed: null` disables it. [appearance] is its visual weight (`null` uses the
/// theme's default) and [tone] its color family. While [loading], it shows a progress circle in place of the
/// text, keeps its width and focus, and ignores taps. The parent sets the width.
class CamoButton extends StatefulWidget {
  /// Creates a button.
  const CamoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.loading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
  });

  /// The label.
  final String text;

  /// Called on a tap or Enter / Space; `null` disables the button.
  final VoidCallback? onPressed;

  /// The visual weight; `null` uses `CamoButtonTheme.defaultAppearance`.
  final Appearance? appearance;

  /// The color family.
  final Tone tone;

  /// Shows a progress circle and ignores taps.
  final bool loading;

  /// An icon before the text, e.g. `const AppIcon.save()`.
  final Widget? prefixIcon;

  /// An icon after the text.
  final Widget? suffixIcon;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoButton> createState() => _CamoButtonState();
}

class _CamoButtonState extends State<CamoButton> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkLabel(widget.text, 'CamoButton');
    final skin = Camouflage.skinOf(context, component: 'CamoButton');
    final theme = Camouflage.themeOf(context, component: 'CamoButton');
    final style = skin.button.defaults(theme).merge(theme.components.button);
    final enabled = widget.onPressed != null;
    final loading = widget.loading && enabled;
    return CamoBehavior(
      controller: _interaction,
      enabled: enabled,
      focusNode: widget.focusNode,
      onActivate: loading ? null : widget.onPressed,
      semantics: (child) => Semantics(
        button: true,
        enabled: enabled,
        label: widget.text,
        value: loading ? 'Busy' : null,
        excludeSemantics: true,
        child: child,
      ),
      child: CamoTouchTarget(
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.button.render(
            context,
            ButtonState(
              text: widget.text,
              enabled: enabled,
              loading: loading,
              appearance: widget.appearance ?? style.defaultAppearance,
              tone: widget.tone,
              interaction: _interaction.value,
              controller: _interaction,
            ),
            ButtonSlots(
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
            ),
            theme,
            style,
          ),
        ),
      ),
    );
  }
}
