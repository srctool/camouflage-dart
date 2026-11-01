import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_touch_target.dart';

/// The FAB sizes. Only Material has three, so a brand picks one in [CamoFabTheme.size] (ADR-23).
enum FabSize {
  /// 40 in Material.
  small,

  /// 56 in Material.
  regular,

  /// 96 in Material.
  large,
}

/// A FAB's colors for one appearance.
@immutable
class FabColors {
  /// Creates FabColors.
  const FabColors({required this.container, required this.content});

  /// The fill.
  final Color container;

  /// The icon and label.
  final Color content;

  @override
  bool operator ==(Object other) =>
      other is FabColors &&
      other.container == container &&
      other.content == content;

  @override
  int get hashCode => Object.hash(container, content);
}

/// Overrides for FABs; `null` keeps the skin's default.
@immutable
class CamoFabTheme {
  /// Creates overrides.
  const CamoFabTheme({
    this.defaultAppearance,
    this.size,
    this.sizeSmall,
    this.sizeRegular,
    this.sizeLarge,
    this.extendedHeight,
    this.shapeSmall,
    this.shapeRegular,
    this.shapeLarge,
    this.iconSizeRegular,
    this.iconSizeLarge,
    this.iconGap,
    this.extendedPadding,
    this.textStyle,
    this.elevation,
    this.softColors,
    this.solidColors,
    this.raisedColors,
  });

  /// The appearance used when a call passes none (ADR-28).
  final Appearance? defaultAppearance;

  /// Which size the FAB uses (ADR-23: only Material has three, so a theme chooses).
  final FabSize? size;

  /// The small container size.
  final double? sizeSmall;

  /// The regular container size.
  final double? sizeRegular;

  /// The large container size.
  final double? sizeLarge;

  /// The height of an extended FAB.
  final double? extendedHeight;

  /// The small corners.
  final BorderRadius? shapeSmall;

  /// The regular corners.
  final BorderRadius? shapeRegular;

  /// The large corners.
  final BorderRadius? shapeLarge;

  /// The icon size of the small and regular FABs.
  final double? iconSizeRegular;

  /// The icon size of the large FAB.
  final double? iconSizeLarge;

  /// The gap between the icon and the label.
  final double? iconGap;

  /// The horizontal padding of an extended FAB.
  final double? extendedPadding;

  /// The label.
  final TextStyle? textStyle;

  /// The FAB's depth.
  final ElevationLevel? elevation;

  /// Colors for `Appearance.soft` with `Tone.defaultTone`.
  final FabColors? softColors;

  /// Colors for `Appearance.solid` with `Tone.defaultTone`.
  final FabColors? solidColors;

  /// Colors for `Appearance.raised` with `Tone.defaultTone`.
  final FabColors? raisedColors;

  /// A copy with the given fields replaced.
  CamoFabTheme copyWith({
    Appearance? defaultAppearance,
    FabSize? size,
    double? sizeSmall,
    double? sizeRegular,
    double? sizeLarge,
    double? extendedHeight,
    BorderRadius? shapeSmall,
    BorderRadius? shapeRegular,
    BorderRadius? shapeLarge,
    double? iconSizeRegular,
    double? iconSizeLarge,
    double? iconGap,
    double? extendedPadding,
    TextStyle? textStyle,
    ElevationLevel? elevation,
    FabColors? softColors,
    FabColors? solidColors,
    FabColors? raisedColors,
  }) => CamoFabTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    size: size ?? this.size,
    sizeSmall: sizeSmall ?? this.sizeSmall,
    sizeRegular: sizeRegular ?? this.sizeRegular,
    sizeLarge: sizeLarge ?? this.sizeLarge,
    extendedHeight: extendedHeight ?? this.extendedHeight,
    shapeSmall: shapeSmall ?? this.shapeSmall,
    shapeRegular: shapeRegular ?? this.shapeRegular,
    shapeLarge: shapeLarge ?? this.shapeLarge,
    iconSizeRegular: iconSizeRegular ?? this.iconSizeRegular,
    iconSizeLarge: iconSizeLarge ?? this.iconSizeLarge,
    iconGap: iconGap ?? this.iconGap,
    extendedPadding: extendedPadding ?? this.extendedPadding,
    textStyle: textStyle ?? this.textStyle,
    elevation: elevation ?? this.elevation,
    softColors: softColors ?? this.softColors,
    solidColors: solidColors ?? this.solidColors,
    raisedColors: raisedColors ?? this.raisedColors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoFabTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.size == size &&
      other.sizeSmall == sizeSmall &&
      other.sizeRegular == sizeRegular &&
      other.sizeLarge == sizeLarge &&
      other.extendedHeight == extendedHeight &&
      other.shapeSmall == shapeSmall &&
      other.shapeRegular == shapeRegular &&
      other.shapeLarge == shapeLarge &&
      other.iconSizeRegular == iconSizeRegular &&
      other.iconSizeLarge == iconSizeLarge &&
      other.iconGap == iconGap &&
      other.extendedPadding == extendedPadding &&
      other.textStyle == textStyle &&
      other.elevation == elevation &&
      other.softColors == softColors &&
      other.solidColors == solidColors &&
      other.raisedColors == raisedColors;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    size,
    sizeSmall,
    sizeRegular,
    sizeLarge,
    extendedHeight,
    shapeSmall,
    shapeRegular,
    shapeLarge,
    iconSizeRegular,
    iconSizeLarge,
    iconGap,
    extendedPadding,
    textStyle,
    elevation,
    softColors,
    solidColors,
    raisedColors,
  );
}

/// The resolved FAB style: every field set.
@immutable
class CamoFabStyle {
  /// Creates a style.
  const CamoFabStyle({
    required this.defaultAppearance,
    required this.size,
    required this.sizeSmall,
    required this.sizeRegular,
    required this.sizeLarge,
    required this.extendedHeight,
    required this.shapeSmall,
    required this.shapeRegular,
    required this.shapeLarge,
    required this.iconSizeRegular,
    required this.iconSizeLarge,
    required this.iconGap,
    required this.extendedPadding,
    required this.textStyle,
    required this.elevation,
    required this.softColors,
    required this.solidColors,
    required this.raisedColors,
  });

  /// The appearance used when a call passes none (ADR-28).
  final Appearance defaultAppearance;

  /// Which size the FAB uses (ADR-23: only Material has three, so a theme chooses).
  final FabSize size;

  /// The small container size.
  final double sizeSmall;

  /// The regular container size.
  final double sizeRegular;

  /// The large container size.
  final double sizeLarge;

  /// The height of an extended FAB.
  final double extendedHeight;

  /// The small corners.
  final BorderRadius shapeSmall;

  /// The regular corners.
  final BorderRadius shapeRegular;

  /// The large corners.
  final BorderRadius shapeLarge;

  /// The icon size of the small and regular FABs.
  final double iconSizeRegular;

  /// The icon size of the large FAB.
  final double iconSizeLarge;

  /// The gap between the icon and the label.
  final double iconGap;

  /// The horizontal padding of an extended FAB.
  final double extendedPadding;

  /// The label.
  final TextStyle textStyle;

  /// The FAB's depth.
  final ElevationLevel elevation;

  /// Colors for `Appearance.soft` with `Tone.defaultTone`.
  final FabColors softColors;

  /// Colors for `Appearance.solid` with `Tone.defaultTone`.
  final FabColors solidColors;

  /// Colors for `Appearance.raised` with `Tone.defaultTone`.
  final FabColors raisedColors;

  /// This style with [o]'s non-null fields applied.
  CamoFabStyle merge(CamoFabTheme? o) => o == null
      ? this
      : CamoFabStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          size: o.size ?? size,
          sizeSmall: o.sizeSmall ?? sizeSmall,
          sizeRegular: o.sizeRegular ?? sizeRegular,
          sizeLarge: o.sizeLarge ?? sizeLarge,
          extendedHeight: o.extendedHeight ?? extendedHeight,
          shapeSmall: o.shapeSmall ?? shapeSmall,
          shapeRegular: o.shapeRegular ?? shapeRegular,
          shapeLarge: o.shapeLarge ?? shapeLarge,
          iconSizeRegular: o.iconSizeRegular ?? iconSizeRegular,
          iconSizeLarge: o.iconSizeLarge ?? iconSizeLarge,
          iconGap: o.iconGap ?? iconGap,
          extendedPadding: o.extendedPadding ?? extendedPadding,
          textStyle: o.textStyle ?? textStyle,
          elevation: o.elevation ?? elevation,
          softColors: o.softColors ?? softColors,
          solidColors: o.solidColors ?? solidColors,
          raisedColors: o.raisedColors ?? raisedColors,
        );

  /// The container size of the chosen [size].
  double get containerSize => switch (size) {
    FabSize.small => sizeSmall,
    FabSize.regular => sizeRegular,
    FabSize.large => sizeLarge,
  };

  /// The corners of the chosen [size].
  BorderRadius get shape => switch (size) {
    FabSize.small => shapeSmall,
    FabSize.regular => shapeRegular,
    FabSize.large => shapeLarge,
  };

  /// The icon size of the chosen [size] (small uses the regular one).
  double get iconSize =>
      size == FabSize.large ? iconSizeLarge : iconSizeRegular;

  /// The colors for a FAB in [state]: this style's colors for `Tone.defaultTone`, and the tone's family
  /// otherwise (solid a strong fill, soft a container fill, raised a lifted surface with the tone's strong
  /// content).
  FabColors colorsFor(FabState state, CamoTheme theme) {
    final f = theme.colors.family(state.tone);
    if (state.tone == Tone.defaultTone) {
      return switch (state.appearance) {
        Appearance.solid => solidColors,
        Appearance.raised => raisedColors,
        _ => softColors,
      };
    }
    return switch (state.appearance) {
      Appearance.solid => FabColors(container: f.strong, content: f.onStrong),
      Appearance.raised => FabColors(
        container: raisedColors.container,
        content: f.strong,
      ),
      _ => FabColors(container: f.container, content: f.onContainer),
    };
  }
}

/// The appearance a FAB draws for [appearance]: soft, solid or raised (the others fall back to soft).
Appearance fabAppearance(Appearance appearance) => switch (appearance) {
  Appearance.solid || Appearance.raised => appearance,
  _ => Appearance.soft,
};

/// What a FAB renderer draws. [appearance] is already resolved (soft, solid or raised). A FAB with a [text] is
/// extended; while it isn't [expanded] only the icon shows, and the renderer animates the width between the two.
/// Core hides the FAB itself (`visible: false`), so the renderer only draws a visible one.
@immutable
class FabState {
  /// Creates the state.
  const FabState({
    required this.text,
    required this.expanded,
    required this.enabled,
    required this.appearance,
    required this.tone,
    required this.interaction,
    required this.controller,
  });

  /// The label, shown while [expanded]; `null` for a plain FAB.
  final String? text;

  /// Extended only: `false` collapses to the icon.
  final bool expanded;

  /// `false` shows the disabled look (`onPressed: null`).
  final bool enabled;

  /// Soft, solid or raised.
  final Appearance appearance;

  /// The color family.
  final Tone tone;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;

  /// Whether this FAB has a label (shown while [expanded]).
  bool get extended => text != null;
}

/// A FAB's icon.
@immutable
class FabSlots {
  /// Creates the slots.
  const FabSlots({required this.icon});

  /// The icon.
  final Widget icon;
}

/// Draws FABs.
abstract interface class CamoFabRenderer {
  /// The complete FAB style for [theme].
  CamoFabStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots], with press feedback.
  Widget render(
    BuildContext context,
    FabState state,
    FabSlots slots,
    CamoTheme theme,
    CamoFabStyle style,
  );
}

/// The screen's one main action: an [icon] button, or an extended FAB with a [text] label. The accessible name
/// is the [text] when there is one and [semanticLabel] otherwise, in both states, so collapsing it while the
/// list scrolls (`expanded: false`) doesn't rename it. `visible: false` scales it out and takes it out of
/// focus, pointer and semantics (pair it with `CamoHideOnScroll`). `onPressed: null` disables it. Placement is
/// the app's layout.
class CamoFab extends StatefulWidget {
  /// Creates a FAB.
  const CamoFab({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.text,
    this.expanded = true,
    this.visible = true,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.focusNode,
  });

  /// The icon.
  final Widget icon;

  /// Names the FAB when it has no [text] (and when it is collapsed).
  final String semanticLabel;

  /// Called on a tap; `null` disables the FAB.
  final VoidCallback? onPressed;

  /// Non-null makes an extended FAB.
  final String? text;

  /// Extended only: `false` collapses it to the icon.
  final bool expanded;

  /// `false` scales it out and removes it from focus and semantics.
  final bool visible;

  /// `null` uses `CamoFabTheme.defaultAppearance`.
  final Appearance? appearance;

  /// The color family.
  final Tone tone;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoFab> createState() => _CamoFabState();
}

class _CamoFabState extends State<CamoFab> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.semanticLabel.trim().isNotEmpty,
      'CamoFab needs a semanticLabel.',
    );
    final skin = Camouflage.skinOf(context, component: 'CamoFab');
    final theme = Camouflage.themeOf(context, component: 'CamoFab');
    final style = skin.fab.defaults(theme).merge(theme.components.fab);
    final enabled = widget.onPressed != null;
    final visible = widget.visible;
    final duration = theme.motion.durationMedium;
    final fab = CamoTouchTarget(
      child: CamoBehavior(
        controller: _interaction,
        enabled: enabled && visible,
        focusNode: widget.focusNode,
        onActivate: widget.onPressed,
        semantics: (child) => Semantics(
          button: true,
          enabled: enabled,
          label: widget.text ?? widget.semanticLabel,
          excludeSemantics: true,
          child: child,
        ),
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.fab.render(
            context,
            FabState(
              text: widget.text,
              expanded: widget.expanded,
              enabled: enabled,
              appearance: fabAppearance(
                widget.appearance ?? style.defaultAppearance,
              ),
              tone: widget.tone,
              interaction: _interaction.value,
              controller: _interaction,
            ),
            FabSlots(icon: widget.icon),
            theme,
            style,
          ),
        ),
      ),
    );
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: ExcludeSemantics(
          excluding: !visible,
          child: AnimatedScale(
            scale: visible ? 1 : 0.6,
            duration: duration,
            curve: theme.motion.easingStandard,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: duration,
              curve: theme.motion.easingStandard,
              child: fab,
            ),
          ),
        ),
      ),
    );
  }
}
