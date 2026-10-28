import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../text/camo_text.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_error_semantics.dart';
import '../util/camo_touch_target.dart';
import '../util/camo_row_toggle.dart';

/// Every color a checkbox uses. Disabled and error colors come from the theme.
@immutable
class CheckboxColors {
  /// Creates checkbox colors.
  const CheckboxColors({
    required this.checkedBox,
    required this.checkmark,
    required this.uncheckedBorder,
    required this.label,
  });

  /// The checked box's fill.
  final Color checkedBox;

  /// The check mark.
  final Color checkmark;

  /// The unchecked box's border.
  final Color uncheckedBorder;

  /// The label text.
  final Color label;

  @override
  bool operator ==(Object other) =>
      other is CheckboxColors &&
      other.checkedBox == checkedBox &&
      other.checkmark == checkmark &&
      other.uncheckedBorder == uncheckedBorder &&
      other.label == label;

  @override
  int get hashCode =>
      Object.hash(checkedBox, checkmark, uncheckedBorder, label);
}

/// Overrides for checkboxes; `null` keeps the skin's default.
@immutable
class CamoCheckboxTheme {
  /// Creates checkbox overrides.
  const CamoCheckboxTheme({
    this.boxSize,
    this.shape,
    this.borderWidth,
    this.labelStyle,
    this.labelPosition,
    this.labelGap,
    this.descriptionStyle,
    this.colors,
  });

  /// The visual box.
  final double? boxSize;

  /// The box's corners.
  final BorderRadius? shape;

  /// The unchecked border.
  final double? borderWidth;

  /// The label.
  final TextStyle? labelStyle;

  /// Which side of the box the label sits on.
  final CamoLabelPosition? labelPosition;

  /// The space between the box and the label.
  final double? labelGap;

  /// The description line, color included.
  final TextStyle? descriptionStyle;

  /// Every color the checkbox uses.
  final CheckboxColors? colors;

  /// A copy with the given fields replaced.
  CamoCheckboxTheme copyWith({
    double? boxSize,
    BorderRadius? shape,
    double? borderWidth,
    TextStyle? labelStyle,
    CamoLabelPosition? labelPosition,
    double? labelGap,
    TextStyle? descriptionStyle,
    CheckboxColors? colors,
  }) => CamoCheckboxTheme(
    boxSize: boxSize ?? this.boxSize,
    shape: shape ?? this.shape,
    borderWidth: borderWidth ?? this.borderWidth,
    labelStyle: labelStyle ?? this.labelStyle,
    labelPosition: labelPosition ?? this.labelPosition,
    labelGap: labelGap ?? this.labelGap,
    descriptionStyle: descriptionStyle ?? this.descriptionStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoCheckboxTheme &&
      other.boxSize == boxSize &&
      other.shape == shape &&
      other.borderWidth == borderWidth &&
      other.labelStyle == labelStyle &&
      other.labelPosition == labelPosition &&
      other.labelGap == labelGap &&
      other.descriptionStyle == descriptionStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    boxSize,
    shape,
    borderWidth,
    labelStyle,
    labelPosition,
    labelGap,
    descriptionStyle,
    colors,
  );
}

/// The resolved checkbox style: every field set.
@immutable
class CamoCheckboxStyle {
  /// Creates a checkbox style.
  const CamoCheckboxStyle({
    required this.boxSize,
    required this.shape,
    required this.borderWidth,
    required this.labelStyle,
    required this.labelPosition,
    required this.labelGap,
    required this.descriptionStyle,
    required this.colors,
  });

  /// The visual box.
  final double boxSize;

  /// The box's corners.
  final BorderRadius shape;

  /// The unchecked border.
  final double borderWidth;

  /// The label.
  final TextStyle labelStyle;

  /// Which side of the box the label sits on.
  final CamoLabelPosition labelPosition;

  /// The space between the box and the label.
  final double labelGap;

  /// The description line, color included.
  final TextStyle descriptionStyle;

  /// Every color the checkbox uses.
  final CheckboxColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoCheckboxStyle merge(CamoCheckboxTheme? o) => o == null
      ? this
      : CamoCheckboxStyle(
          boxSize: o.boxSize ?? boxSize,
          shape: o.shape ?? shape,
          borderWidth: o.borderWidth ?? borderWidth,
          labelStyle: o.labelStyle ?? labelStyle,
          labelPosition: o.labelPosition ?? labelPosition,
          labelGap: o.labelGap ?? labelGap,
          descriptionStyle: o.descriptionStyle ?? descriptionStyle,
          colors: o.colors ?? colors,
        );
}

/// What a checkbox renderer draws: the box, then (when [label] is set) the label and [description] on the
/// style's `labelPosition` side, and [error] below the row. A plain label arrives as one span. The error text
/// excludes its own semantics: core already announces it.
@immutable
class CheckboxState {
  /// Creates a checkbox state.
  const CheckboxState({
    required this.checked,
    required this.label,
    required this.description,
    required this.error,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// Whether the box is checked.
  final bool checked;

  /// The label as spans, or `null` for a bare box.
  final List<CamoSpan>? label;

  /// A second line under the label.
  final String? description;

  /// The error shown below the row.
  final String? error;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws checkboxes.
abstract interface class CamoCheckboxRenderer {
  /// The complete checkbox style for [theme].
  CamoCheckboxStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    CheckboxState state,
    CamoTheme theme,
    CamoCheckboxStyle style,
  );
}

/// A checkbox: selects something for later (a form that is submitted). With a [label] (or [labelSpans], for
/// links and bold), the whole row is one target, announced as "Remember me, checkbox, not checked". A link in
/// the spans stays its own target. `onChanged: null` makes it display-only, for a parent that handles taps
/// and semantics. [error] marks it invalid and shows below the row.
class CamoCheckbox extends StatefulWidget {
  /// Creates a checkbox.
  const CamoCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.label,
    this.labelSpans,
    this.description,
    this.error,
    this.enabled = true,
    this.focusNode,
  });

  /// Whether it's checked.
  final bool checked;

  /// Called with the new value; `null` makes it display-only.
  final ValueChanged<bool>? onChanged;

  /// The label; the whole row becomes the target.
  final String? label;

  /// A rich label (links, bold), instead of [label].
  final List<CamoSpan>? labelSpans;

  /// A second line under the label.
  final String? description;

  /// Marks it invalid and shows below the row.
  final String? error;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoCheckbox> createState() => _CamoCheckboxState();
}

class _CamoCheckboxState extends State<CamoCheckbox> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoCheckbox');
    final theme = Camouflage.themeOf(context, component: 'CamoCheckbox');
    final style = skin.checkbox
        .defaults(theme)
        .merge(theme.components.checkbox);
    final spans =
        widget.labelSpans ??
        (widget.label == null ? null : [CamoSpan(widget.label!)]);
    final onChanged = widget.onChanged;
    final enabled = widget.enabled && onChanged != null;
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.checkbox.render(
        context,
        CheckboxState(
          checked: widget.checked,
          label: spans,
          description: widget.description,
          error: widget.error,
          enabled: widget.enabled,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        theme,
        style,
      ),
    );
    if (onChanged == null) {
      return reportRowToggle(context, checked: widget.checked, child: visual);
    }
    return CamoErrorSemantics(
      message: widget.error,
      child: CamoBehavior(
        controller: _interaction,
        enabled: enabled,
        focusNode: widget.focusNode,
        onActivate: () => onChanged(!widget.checked),
        semantics: (child) => toggleSemantics(
          spans: spans,
          description: widget.description,
          enabled: enabled,
          checked: widget.checked,
          isSwitch: false,
          child: child,
        ),
        child: CamoTouchTarget(child: visual),
      ),
    );
  }
}

/// A toggle's semantics: one node with its checked state and label. A plain label merges into it; a label with
/// links keeps its text below so each link stays its own node.
Widget toggleSemantics({
  required List<CamoSpan>? spans,
  required String? description,
  required bool enabled,
  required bool checked,
  required bool isSwitch,
  required Widget child,
}) {
  final hasLinks = spans?.any((s) => s.onTap != null) ?? false;
  final text = spans?.map((s) => s.text).join();
  return Semantics(
    enabled: enabled,
    checked: isSwitch ? null : checked,
    toggled: isSwitch ? checked : null,
    label: hasLinks ? null : text,
    hint: hasLinks ? null : description,
    excludeSemantics: !hasLinks,
    child: child,
  );
}
