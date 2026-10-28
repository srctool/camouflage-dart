import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';

/// A card's colors for one appearance; [border] is drawn only when set.
@immutable
class CardColors {
  /// Creates CardColors.
  const CardColors({
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

  @override
  bool operator ==(Object other) =>
      other is CardColors &&
      other.container == container &&
      other.content == content &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, content, border);
}

/// Overrides for cards; `null` keeps the skin's default.
@immutable
class CamoCardTheme {
  /// Creates CamoCardTheme.
  const CamoCardTheme({
    this.defaultAppearance,
    this.shape,
    this.contentPadding,
    this.solidColors,
    this.softColors,
    this.raisedColors,
    this.outlineColors,
    this.raisedElevation,
    this.hoveredElevation,
    this.borderWidth,
    this.toneBorderWidth,
    this.selectedBorderColor,
    this.selectedBorderWidth,
    this.showSelectedCheck,
  });

  /// The appearance when a card passes none.
  final Appearance? defaultAppearance;

  /// The corners.
  final BorderRadius? shape;

  /// Inside the card (0 by default, so images reach the edges).
  final EdgeInsetsDirectional? contentPadding;

  /// Solid, in the default tone.
  final CardColors? solidColors;

  /// Soft, in the default tone.
  final CardColors? softColors;

  /// Raised, in the default tone.
  final CardColors? raisedColors;

  /// Outline, in the default tone.
  final CardColors? outlineColors;

  /// The Raised card's depth.
  final ElevationLevel? raisedElevation;

  /// The Raised card's depth while hovered (clickable cards only).
  final ElevationLevel? hoveredElevation;

  /// The outline's width.
  final double? borderWidth;

  /// The start strip a Raised card shows in a status tone.
  final double? toneBorderWidth;

  /// A selected card's border.
  final Color? selectedBorderColor;

  /// A selected card's border width.
  final double? selectedBorderWidth;

  /// A check badge in a selected card's top-end corner.
  final bool? showSelectedCheck;

  /// A copy with the given fields replaced.
  CamoCardTheme copyWith({
    Appearance? defaultAppearance,
    BorderRadius? shape,
    EdgeInsetsDirectional? contentPadding,
    CardColors? solidColors,
    CardColors? softColors,
    CardColors? raisedColors,
    CardColors? outlineColors,
    ElevationLevel? raisedElevation,
    ElevationLevel? hoveredElevation,
    double? borderWidth,
    double? toneBorderWidth,
    Color? selectedBorderColor,
    double? selectedBorderWidth,
    bool? showSelectedCheck,
  }) => CamoCardTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    shape: shape ?? this.shape,
    contentPadding: contentPadding ?? this.contentPadding,
    solidColors: solidColors ?? this.solidColors,
    softColors: softColors ?? this.softColors,
    raisedColors: raisedColors ?? this.raisedColors,
    outlineColors: outlineColors ?? this.outlineColors,
    raisedElevation: raisedElevation ?? this.raisedElevation,
    hoveredElevation: hoveredElevation ?? this.hoveredElevation,
    borderWidth: borderWidth ?? this.borderWidth,
    toneBorderWidth: toneBorderWidth ?? this.toneBorderWidth,
    selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
    selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
    showSelectedCheck: showSelectedCheck ?? this.showSelectedCheck,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoCardTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.shape == shape &&
      other.contentPadding == contentPadding &&
      other.solidColors == solidColors &&
      other.softColors == softColors &&
      other.raisedColors == raisedColors &&
      other.outlineColors == outlineColors &&
      other.raisedElevation == raisedElevation &&
      other.hoveredElevation == hoveredElevation &&
      other.borderWidth == borderWidth &&
      other.toneBorderWidth == toneBorderWidth &&
      other.selectedBorderColor == selectedBorderColor &&
      other.selectedBorderWidth == selectedBorderWidth &&
      other.showSelectedCheck == showSelectedCheck;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    shape,
    contentPadding,
    solidColors,
    softColors,
    raisedColors,
    outlineColors,
    raisedElevation,
    hoveredElevation,
    borderWidth,
    toneBorderWidth,
    selectedBorderColor,
    selectedBorderWidth,
    showSelectedCheck,
  );
}

/// The resolved card style: every field set. The per-appearance colors are for `Tone.defaultTone`.
@immutable
class CamoCardStyle {
  /// Creates CamoCardStyle.
  const CamoCardStyle({
    required this.defaultAppearance,
    required this.shape,
    required this.contentPadding,
    required this.solidColors,
    required this.softColors,
    required this.raisedColors,
    required this.outlineColors,
    required this.raisedElevation,
    required this.hoveredElevation,
    required this.borderWidth,
    required this.toneBorderWidth,
    required this.selectedBorderColor,
    required this.selectedBorderWidth,
    required this.showSelectedCheck,
  });

  /// The appearance when a card passes none.
  final Appearance defaultAppearance;

  /// The corners.
  final BorderRadius shape;

  /// Inside the card (0 by default, so images reach the edges).
  final EdgeInsetsDirectional contentPadding;

  /// Solid, in the default tone.
  final CardColors solidColors;

  /// Soft, in the default tone.
  final CardColors softColors;

  /// Raised, in the default tone.
  final CardColors raisedColors;

  /// Outline, in the default tone.
  final CardColors outlineColors;

  /// The Raised card's depth.
  final ElevationLevel raisedElevation;

  /// The Raised card's depth while hovered (clickable cards only).
  final ElevationLevel hoveredElevation;

  /// The outline's width.
  final double borderWidth;

  /// The start strip a Raised card shows in a status tone.
  final double toneBorderWidth;

  /// A selected card's border.
  final Color selectedBorderColor;

  /// A selected card's border width.
  final double selectedBorderWidth;

  /// A check badge in a selected card's top-end corner.
  final bool showSelectedCheck;

  /// This style with [o]'s non-null fields applied.
  CamoCardStyle merge(CamoCardTheme? o) => o == null
      ? this
      : CamoCardStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          shape: o.shape ?? shape,
          contentPadding: o.contentPadding ?? contentPadding,
          solidColors: o.solidColors ?? solidColors,
          softColors: o.softColors ?? softColors,
          raisedColors: o.raisedColors ?? raisedColors,
          outlineColors: o.outlineColors ?? outlineColors,
          raisedElevation: o.raisedElevation ?? raisedElevation,
          hoveredElevation: o.hoveredElevation ?? hoveredElevation,
          borderWidth: o.borderWidth ?? borderWidth,
          toneBorderWidth: o.toneBorderWidth ?? toneBorderWidth,
          selectedBorderColor: o.selectedBorderColor ?? selectedBorderColor,
          selectedBorderWidth: o.selectedBorderWidth ?? selectedBorderWidth,
          showSelectedCheck: o.showSelectedCheck ?? showSelectedCheck,
        );

  /// The colors for [a] in [tone]: this style's for the default tone, the tone's family otherwise (Solid a
  /// strong fill, Soft a container fill, Raised the Raised colors with a tone border, Outline a tone border).
  /// `ghost` and `link` fall back to `outline`.
  CardColors colorsFor(Appearance a, Tone tone, CamoTheme theme) {
    final appearance = cardAppearance(a);
    if (tone == Tone.defaultTone) {
      return switch (appearance) {
        Appearance.solid => solidColors,
        Appearance.soft => softColors,
        Appearance.raised => raisedColors,
        _ => outlineColors,
      };
    }
    final f = theme.colors.family(tone);
    return switch (appearance) {
      Appearance.solid => CardColors(container: f.strong, content: f.onStrong),
      Appearance.soft => CardColors(
        container: f.container,
        content: f.onContainer,
      ),
      Appearance.raised => CardColors(
        container: raisedColors.container,
        content: raisedColors.content,
        border: f.strong,
      ),
      _ => CardColors(
        container: outlineColors.container,
        content: outlineColors.content,
        border: f.strong,
      ),
    };
  }
}

/// The appearance a card draws for [a]: `ghost` and `link` fall back to `outline`.
Appearance cardAppearance(Appearance a) => switch (a) {
  Appearance.ghost || Appearance.link => Appearance.outline,
  _ => a,
};

/// What a card renderer draws. [appearance] is already resolved (never `ghost` or `link`). [selected] is
/// `null` for a card that isn't selectable. Draw press feedback only when [clickable].
@immutable
class CardState {
  /// Creates a card state.
  const CardState({
    required this.appearance,
    required this.tone,
    required this.clickable,
    required this.enabled,
    required this.selected,
    required this.interaction,
    required this.controller,
  });

  /// The resolved appearance.
  final Appearance appearance;

  /// The status tone.
  final Tone tone;

  /// Whether the card has an `onPressed`.
  final bool clickable;

  /// `false` shows the disabled look (clickable cards only).
  final bool enabled;

  /// The selection of a selectable card, `null` otherwise.
  final bool? selected;

  /// Press, hover and focus.
  final InteractionState interaction;

  /// For the skin's feedback.
  final CamoInteractionController controller;
}

/// The card's content.
@immutable
class CardSlots {
  /// Creates the slots.
  const CardSlots({required this.child});

  /// The content.
  final Widget child;
}

/// Draws cards.
abstract interface class CamoCardRenderer {
  /// The complete card style for [theme].
  CamoCardStyle defaults(CamoTheme theme);

  /// Draws [state] around [slots].
  Widget render(
    BuildContext context,
    CardState state,
    CardSlots slots,
    CamoTheme theme,
    CamoCardStyle style,
  );
}

/// A group of related content (a product, an article, a setting) on a surface. With [onPressed] the whole
/// card is one button, its content the name; without it the card is plain content. A non-null [selected]
/// makes it a selectable card (plans, payment methods). It has no padding of its own by default, so images can
/// reach its edges: pad the content.
class CamoCard extends StatefulWidget {
  /// Creates a card around [child].
  const CamoCard({
    super.key,
    this.onPressed,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.enabled = true,
    this.selected,
    this.focusNode,
    required this.child,
  });

  /// Makes the card one button; `null` keeps it plain content.
  final VoidCallback? onPressed;

  /// `null` uses `CamoCardTheme.defaultAppearance`.
  final Appearance? appearance;

  /// A status tone for status panels.
  final Tone tone;

  /// `false` disables a clickable card.
  final bool enabled;

  /// Non-null makes a selectable card.
  final bool? selected;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  /// The content.
  final Widget child;

  @override
  State<CamoCard> createState() => _CamoCardState();
}

class _CamoCardState extends State<CamoCard> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoCard');
    final theme = Camouflage.themeOf(context, component: 'CamoCard');
    final style = skin.card.defaults(theme).merge(theme.components.card);
    final onPressed = widget.onPressed;
    final selected = widget.selected;
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.card.render(
        context,
        CardState(
          appearance: cardAppearance(
            widget.appearance ?? style.defaultAppearance,
          ),
          tone: widget.tone,
          clickable: onPressed != null,
          enabled: widget.enabled,
          selected: selected,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        CardSlots(child: widget.child),
        theme,
        style,
      ),
    );
    if (onPressed == null) {
      return selected == null
          ? visual
          : Semantics(container: true, selected: selected, child: visual);
    }
    // The merge sits outside the behavior, so the tap action joins the button node.
    return MergeSemantics(
      child: CamoBehavior(
        controller: _interaction,
        enabled: widget.enabled,
        focusNode: widget.focusNode,
        onActivate: onPressed,
        semantics: (child) => Semantics(
          button: true,
          enabled: widget.enabled,
          selected: selected,
          child: child,
        ),
        child: visual,
      ),
    );
  }
}
