import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../text/camo_text.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_error_semantics.dart';
import '../util/camo_roving_focus.dart';
import '../util/camo_touch_target.dart';

/// Every color a radio uses.
@immutable
class RadioColors {
  /// Creates radio colors.
  const RadioColors({
    required this.selected,
    required this.unselected,
    required this.error,
    required this.label,
  });

  /// The ring and dot when selected.
  final Color selected;

  /// The ring when not selected.
  final Color unselected;

  /// The ring in a group with an error.
  final Color error;

  /// The option label.
  final Color label;

  @override
  bool operator ==(Object other) =>
      other is RadioColors &&
      other.selected == selected &&
      other.unselected == unselected &&
      other.error == error &&
      other.label == label;

  @override
  int get hashCode => Object.hash(selected, unselected, error, label);
}

/// Overrides for radios; `null` keeps the skin's default.
@immutable
class CamoRadioTheme {
  /// Creates radio overrides.
  const CamoRadioTheme({
    this.size,
    this.dotSize,
    this.borderWidth,
    this.labelStyle,
    this.descriptionStyle,
    this.labelPosition,
    this.labelGap,
    this.colors,
  });

  /// The visual circle.
  final double? size;

  /// The inner dot when selected.
  final double? dotSize;

  /// The ring's thickness.
  final double? borderWidth;

  /// The option label.
  final TextStyle? labelStyle;

  /// An option's description line, color included.
  final TextStyle? descriptionStyle;

  /// Which side of the circle the label sits on.
  final CamoLabelPosition? labelPosition;

  /// The space between the circle and the label.
  final double? labelGap;

  /// Every color the radio uses.
  final RadioColors? colors;

  /// A copy with the given fields replaced.
  CamoRadioTheme copyWith({
    double? size,
    double? dotSize,
    double? borderWidth,
    TextStyle? labelStyle,
    TextStyle? descriptionStyle,
    CamoLabelPosition? labelPosition,
    double? labelGap,
    RadioColors? colors,
  }) => CamoRadioTheme(
    size: size ?? this.size,
    dotSize: dotSize ?? this.dotSize,
    borderWidth: borderWidth ?? this.borderWidth,
    labelStyle: labelStyle ?? this.labelStyle,
    descriptionStyle: descriptionStyle ?? this.descriptionStyle,
    labelPosition: labelPosition ?? this.labelPosition,
    labelGap: labelGap ?? this.labelGap,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoRadioTheme &&
      other.size == size &&
      other.dotSize == dotSize &&
      other.borderWidth == borderWidth &&
      other.labelStyle == labelStyle &&
      other.descriptionStyle == descriptionStyle &&
      other.labelPosition == labelPosition &&
      other.labelGap == labelGap &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    size,
    dotSize,
    borderWidth,
    labelStyle,
    descriptionStyle,
    labelPosition,
    labelGap,
    colors,
  );
}

/// The resolved radio style: every field set.
@immutable
class CamoRadioStyle {
  /// Creates a radio style.
  const CamoRadioStyle({
    required this.size,
    required this.dotSize,
    required this.borderWidth,
    required this.labelStyle,
    required this.descriptionStyle,
    required this.labelPosition,
    required this.labelGap,
    required this.colors,
  });

  /// The visual circle.
  final double size;

  /// The inner dot when selected.
  final double dotSize;

  /// The ring's thickness.
  final double borderWidth;

  /// The option label.
  final TextStyle labelStyle;

  /// An option's description line, color included.
  final TextStyle descriptionStyle;

  /// Which side of the circle the label sits on.
  final CamoLabelPosition labelPosition;

  /// The space between the circle and the label.
  final double labelGap;

  /// Every color the radio uses.
  final RadioColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoRadioStyle merge(CamoRadioTheme? o) => o == null
      ? this
      : CamoRadioStyle(
          size: o.size ?? size,
          dotSize: o.dotSize ?? dotSize,
          borderWidth: o.borderWidth ?? borderWidth,
          labelStyle: o.labelStyle ?? labelStyle,
          descriptionStyle: o.descriptionStyle ?? descriptionStyle,
          labelPosition: o.labelPosition ?? labelPosition,
          labelGap: o.labelGap ?? labelGap,
          colors: o.colors ?? colors,
        );
}

/// What a radio renderer draws: the circle and (when [label] is set) the label and [description] on the style's
/// `labelPosition` side. [error] draws the ring in the error color; the group shows the message.
@immutable
class RadioState {
  /// Creates a radio state.
  const RadioState({
    required this.selected,
    required this.label,
    required this.description,
    required this.enabled,
    required this.error,
    required this.interaction,
    required this.controller,
  });

  /// Whether this option is the chosen one.
  final bool selected;

  /// The label as spans, or `null` for a bare circle.
  final List<CamoSpan>? label;

  /// A second line under the label.
  final String? description;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The group has an error.
  final bool error;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws radios.
abstract interface class CamoRadioRenderer {
  /// The complete radio style for [theme].
  CamoRadioStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    RadioState state,
    CamoTheme theme,
    CamoRadioStyle style,
  );
}

/// One choice in a [CamoRadioGroup].
@immutable
class RadioOption<T> {
  /// Creates an option.
  const RadioOption(
    this.value,
    this.label, {
    this.description,
    this.enabled = true,
  });

  /// What choosing it selects.
  final T value;

  /// The option's label.
  final String label;

  /// A second line under the label.
  final String? description;

  /// `false` disables this option only.
  final bool enabled;
}

/// A single radio, for custom layouts (a radio inside a card). Prefer [CamoRadioGroup], which adds the keyboard
/// and the "2 of 3" announcement. `onChanged: null` makes it display-only, for a parent row that handles it.
class CamoRadio extends StatelessWidget {
  /// Creates a radio.
  const CamoRadio({
    super.key,
    required this.selected,
    required this.onChanged,
    this.label,
    this.labelSpans,
    this.enabled = true,
    this.focusNode,
  });

  /// Whether it's the chosen one.
  final bool selected;

  /// Called when chosen; `null` makes it display-only.
  final VoidCallback? onChanged;

  /// The label; the whole row becomes the target.
  final String? label;

  /// A rich label, instead of [label].
  final List<CamoSpan>? labelSpans;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => _Radio(
    selected: selected,
    onChanged: onChanged,
    label: labelSpans ?? (label == null ? null : [CamoSpan(label!)]),
    description: null,
    enabled: enabled,
    error: false,
    focusNode: focusNode,
  );
}

class _Radio extends StatefulWidget {
  const _Radio({
    required this.selected,
    required this.onChanged,
    required this.label,
    required this.description,
    required this.enabled,
    required this.error,
    this.focusNode,
  });

  final bool selected;
  final VoidCallback? onChanged;
  final List<CamoSpan>? label;
  final String? description;
  final bool enabled;
  final bool error;
  final FocusNode? focusNode;

  @override
  State<_Radio> createState() => _RadioState();
}

class _RadioState extends State<_Radio> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoRadio');
    final theme = Camouflage.themeOf(context, component: 'CamoRadio');
    final style = skin.radio.defaults(theme).merge(theme.components.radio);
    final onChanged = widget.onChanged;
    final enabled = widget.enabled && onChanged != null;
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.radio.render(
        context,
        RadioState(
          selected: widget.selected,
          label: widget.label,
          description: widget.description,
          enabled: widget.enabled,
          error: widget.error,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        theme,
        style,
      ),
    );
    if (onChanged == null) return visual;
    return CamoBehavior(
      controller: _interaction,
      enabled: enabled,
      focusNode: widget.focusNode,
      onActivate: onChanged,
      semantics: (child) => Semantics(
        enabled: enabled,
        checked: widget.selected,
        inMutuallyExclusiveGroup: true,
        label: widget.label?.map((s) => s.text).join(),
        hint: widget.description,
        excludeSemantics: true,
        child: child,
      ),
      child: CamoTouchTarget(child: visual),
    );
  }
}

/// Exactly one choice from a small visible set (2 to 5 options; more belong in a select). Tab enters the group
/// on the selected option, the arrow keys move and select, and each option is announced "Weekly, radio button,
/// 2 of 3". `value: null` selects nothing yet. A horizontal group wraps when it doesn't fit.
class CamoRadioGroup<T> extends StatelessWidget {
  /// Creates a radio group.
  const CamoRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    this.label,
    this.error,
    this.direction = Axis.vertical,
    this.enabled = true,
  });

  /// The chosen value, or `null`.
  final T? value;

  /// Called with the chosen value; `null` disables the group.
  final ValueChanged<T>? onChanged;

  /// The choices.
  final List<RadioOption<T>> options;

  /// The group's label, announced with it.
  final String? label;

  /// Shown below the group; marks it invalid.
  final String? error;

  /// Vertical (a column) or horizontal (a wrapping row).
  final Axis direction;

  /// `false` disables every option.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoRadioGroup');
    final onChanged = this.onChanged;
    final groupEnabled = enabled && onChanged != null;
    final items = [
      for (final (i, option) in options.indexed)
        CamoRovingFocusItem(
          index: i,
          enabled: groupEnabled && option.enabled,
          selected: option.value == value,
          onSelect: () => onChanged?.call(option.value),
          builder: (context, node) => _Radio(
            selected: option.value == value,
            onChanged: groupEnabled && option.enabled
                ? () => onChanged(option.value)
                : null,
            label: [CamoSpan(option.label)],
            description: option.description,
            enabled: groupEnabled && option.enabled,
            error: this.error != null,
            focusNode: node,
          ),
        ),
    ];
    final label = this.label;
    final error = this.error;
    final disabled = theme.colors.onSurface.withValues(
      alpha: theme.colors.onSurface.a * 0.38,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(bottom: theme.spacing.xs),
            child: ExcludeSemantics(
              child: CamoText(
                label,
                style: theme.typography.labelLarge,
                color: groupEnabled ? theme.colors.onSurface : disabled,
              ),
            ),
          ),
        CamoErrorSemantics(
          message: error,
          child: Semantics(
            role: SemanticsRole.radioGroup,
            label: label,
            container: true,
            child: CamoRovingFocus(
              child: direction == Axis.vertical
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items,
                    )
                  : Wrap(spacing: theme.spacing.l, children: items),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: theme.spacing.xs),
            child: ExcludeSemantics(
              child: CamoText(
                error,
                style: theme.typography.bodySmall,
                color: theme.colors.error,
              ),
            ),
          ),
      ],
    );
  }
}
