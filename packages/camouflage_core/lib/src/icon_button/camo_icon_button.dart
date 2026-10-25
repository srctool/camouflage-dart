import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../tooltip/camo_tooltip.dart';
import '../util/camo_behavior.dart';
import '../util/camo_touch_target.dart';

/// An icon button's colors for one appearance. [border] is drawn only when set.
@immutable
class IconButtonColors {
  /// Creates icon button colors.
  const IconButtonColors({
    required this.container,
    required this.content,
    this.border,
  });

  /// The fill.
  final Color container;

  /// The icon.
  final Color content;

  /// The outline, if any.
  final Color? border;

  @override
  bool operator ==(Object other) =>
      other is IconButtonColors &&
      other.container == container &&
      other.content == content &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, content, border);
}

/// Overrides for icon buttons; `null` keeps the skin's default.
@immutable
class CamoIconButtonTheme {
  /// Creates icon button overrides.
  const CamoIconButtonTheme({
    this.defaultAppearance,
    this.containerSize,
    this.shape,
    this.iconSize,
    this.borderWidth,
    this.solidColors,
    this.softColors,
    this.outlineColors,
    this.ghostColors,
    this.checkedColors,
    this.disabledContainerAlpha,
    this.disabledContentAlpha,
  });

  /// The appearance used when a call passes none.
  final Appearance? defaultAppearance;

  /// The visual container's size (the touch target stays at least 48).
  final double? containerSize;

  /// The corners.
  final BorderRadius? shape;

  /// The ambient icon size.
  final double? iconSize;

  /// The Outline border's width.
  final double? borderWidth;

  /// Solid colors for the default tone.
  final IconButtonColors? solidColors;

  /// Soft colors for the default tone.
  final IconButtonColors? softColors;

  /// Outline colors for the default tone.
  final IconButtonColors? outlineColors;

  /// Ghost colors for the default tone.
  final IconButtonColors? ghostColors;

  /// The look when `checked` is `true`.
  final IconButtonColors? checkedColors;

  /// The disabled container's alpha.
  final double? disabledContainerAlpha;

  /// The disabled content's alpha.
  final double? disabledContentAlpha;

  @override
  bool operator ==(Object other) =>
      other is CamoIconButtonTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.containerSize == containerSize &&
      other.shape == shape &&
      other.iconSize == iconSize &&
      other.borderWidth == borderWidth &&
      other.solidColors == solidColors &&
      other.softColors == softColors &&
      other.outlineColors == outlineColors &&
      other.ghostColors == ghostColors &&
      other.checkedColors == checkedColors &&
      other.disabledContainerAlpha == disabledContainerAlpha &&
      other.disabledContentAlpha == disabledContentAlpha;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    containerSize,
    shape,
    iconSize,
    borderWidth,
    solidColors,
    softColors,
    outlineColors,
    ghostColors,
    checkedColors,
    disabledContainerAlpha,
    disabledContentAlpha,
  );
}

/// The resolved icon button style: every field set. The per-appearance colors are for the default tone.
@immutable
class CamoIconButtonStyle {
  /// Creates an icon button style.
  const CamoIconButtonStyle({
    required this.defaultAppearance,
    required this.containerSize,
    required this.shape,
    required this.iconSize,
    required this.borderWidth,
    required this.solidColors,
    required this.softColors,
    required this.outlineColors,
    required this.ghostColors,
    required this.checkedColors,
    required this.disabledContainerAlpha,
    required this.disabledContentAlpha,
  });

  /// The appearance used when a call passes none.
  final Appearance defaultAppearance;

  /// The visual container's size.
  final double containerSize;

  /// The corners.
  final BorderRadius shape;

  /// The icon size.
  final double iconSize;

  /// The Outline border's width.
  final double borderWidth;

  /// Solid colors.
  final IconButtonColors solidColors;

  /// Soft colors.
  final IconButtonColors softColors;

  /// Outline colors.
  final IconButtonColors outlineColors;

  /// Ghost colors.
  final IconButtonColors ghostColors;

  /// The checked look.
  final IconButtonColors checkedColors;

  /// The disabled container alpha.
  final double disabledContainerAlpha;

  /// The disabled content alpha.
  final double disabledContentAlpha;

  /// This style with [o]'s non-null fields applied.
  CamoIconButtonStyle merge(CamoIconButtonTheme? o) => o == null
      ? this
      : CamoIconButtonStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          containerSize: o.containerSize ?? containerSize,
          shape: o.shape ?? shape,
          iconSize: o.iconSize ?? iconSize,
          borderWidth: o.borderWidth ?? borderWidth,
          solidColors: o.solidColors ?? solidColors,
          softColors: o.softColors ?? softColors,
          outlineColors: o.outlineColors ?? outlineColors,
          ghostColors: o.ghostColors ?? ghostColors,
          checkedColors: o.checkedColors ?? checkedColors,
          disabledContainerAlpha:
              o.disabledContainerAlpha ?? disabledContainerAlpha,
          disabledContentAlpha: o.disabledContentAlpha ?? disabledContentAlpha,
        );

  /// The colors for [a] in [tone], or [checkedColors] when [checked]. Icon buttons have no raised or link:
  /// core maps them to soft and ghost first.
  IconButtonColors colorsFor(
    Appearance a,
    Tone tone,
    CamoTheme theme, {
    bool checked = false,
  }) {
    if (checked) return checkedColors;
    if (tone == Tone.defaultTone) {
      return switch (a) {
        Appearance.solid => solidColors,
        Appearance.soft || Appearance.raised => softColors,
        Appearance.outline => outlineColors,
        Appearance.ghost || Appearance.link => ghostColors,
      };
    }
    final f = theme.colors.family(tone);
    const clear = Color(0x00000000);
    return switch (a) {
      Appearance.solid => IconButtonColors(
        container: f.strong,
        content: f.onStrong,
      ),
      Appearance.soft || Appearance.raised => IconButtonColors(
        container: f.container,
        content: f.onContainer,
      ),
      Appearance.outline => IconButtonColors(
        container: clear,
        content: f.strong,
        border: f.strong,
      ),
      Appearance.ghost ||
      Appearance.link => IconButtonColors(container: clear, content: f.strong),
    };
  }
}

/// What an icon button renderer draws. `checked != null` makes it a toggle.
@immutable
class IconButtonState {
  /// Creates an icon button state.
  const IconButtonState({
    required this.enabled,
    required this.checked,
    required this.loading,
    required this.appearance,
    required this.tone,
    required this.interaction,
    required this.controller,
  });

  /// `false` shows the disabled look.
  final bool enabled;

  /// The toggle state, or `null` for a plain button.
  final bool? checked;

  /// `true` shows a progress circle in place of the icon.
  final bool loading;

  /// The visual weight (never raised or link).
  final Appearance appearance;

  /// The color family.
  final Tone tone;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction].
  final CamoInteractionController controller;
}

/// The caller's icon. Core hides its semantics: the button carries the label.
@immutable
class IconButtonSlots {
  /// Creates the slots.
  const IconButtonSlots({required this.icon});

  /// The icon.
  final Widget icon;
}

/// Draws icon buttons.
abstract interface class CamoIconButtonRenderer {
  /// The complete icon button style for [theme].
  CamoIconButtonStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    IconButtonState state,
    IconButtonSlots slots,
    CamoTheme theme,
    CamoIconButtonStyle style,
  );
}

/// An icon-only button. [semanticLabel] names the action ("Close", "Add to favorites"), not the icon.
/// `onPressed: null` disables it; a non-null [checked] makes it a toggle; [tooltip] shows on hover, keyboard focus
/// and long press.
class CamoIconButton extends StatefulWidget {
  /// Creates an icon button.
  const CamoIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.checked,
    this.loading = false,
    this.tooltip,
    this.focusNode,
  });

  /// The icon, usually an app icon widget.
  final Widget icon;

  /// Describes the action.
  final String semanticLabel;

  /// Called on a tap or Enter / Space; `null` disables the button.
  final VoidCallback? onPressed;

  /// The visual weight; `null` uses `CamoIconButtonTheme.defaultAppearance`.
  final Appearance? appearance;

  /// The color family.
  final Tone tone;

  /// The toggle state, or `null` for a plain button.
  final bool? checked;

  /// Shows a progress circle and ignores taps.
  final bool loading;

  /// A tooltip, often the same as [semanticLabel].
  final String? tooltip;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoIconButton> createState() => _CamoIconButtonState();
}

class _CamoIconButtonState extends State<CamoIconButton> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoIconButton');
    final theme = Camouflage.themeOf(context, component: 'CamoIconButton');
    final style = skin.iconButton
        .defaults(theme)
        .merge(theme.components.iconButton);
    final enabled = widget.onPressed != null;
    final loading = widget.loading && enabled;
    final appearance = switch (widget.appearance ?? style.defaultAppearance) {
      Appearance.raised => Appearance.soft,
      Appearance.link => Appearance.ghost,
      final a => a,
    };
    final Widget button = CamoBehavior(
      controller: _interaction,
      enabled: enabled,
      focusNode: widget.focusNode,
      onActivate: loading ? null : widget.onPressed,
      semantics: (child) => Semantics(
        button: true,
        enabled: enabled,
        toggled: widget.checked,
        label: widget.semanticLabel,
        value: loading ? 'Busy' : null,
        excludeSemantics: true,
        child: child,
      ),
      child: CamoTouchTarget(
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.iconButton.render(
            context,
            IconButtonState(
              enabled: enabled,
              checked: widget.checked,
              loading: loading,
              appearance: appearance,
              tone: widget.tone,
              interaction: _interaction.value,
              controller: _interaction,
            ),
            IconButtonSlots(icon: ExcludeSemantics(child: widget.icon)),
            theme,
            style,
          ),
        ),
      ),
    );
    final tooltip = widget.tooltip;
    return tooltip == null
        ? button
        : CamoTooltip(
            message: tooltip,
            anchorLabel: widget.semanticLabel,
            child: button,
          );
  }
}
