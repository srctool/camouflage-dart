import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../checkbox/camo_checkbox.dart';
import '../radio/camo_radio.dart';
import '../stepper/camo_stepper.dart';
import '../switch/camo_switch.dart';
import '../text/camo_text.dart';
import '../textfield/camo_formats.dart';
import '../textfield/camo_text_field.dart';
import 'camo_form.dart';
import 'camo_rule.dart';

// The ready-made form fields: each is a CamoFormField drawing the plain component with the field's value and
// error. Rules see the raw value, even when a display format shows dashes.

/// A [CamoTextField] in a [CamoForm]. It takes the text field's parameters, minus `value`, `onChanged` and
/// `error`.
class CamoTextFormField extends StatelessWidget {
  /// Creates a text form field.
  const CamoTextFormField({
    super.key,
    this.fieldKey,
    this.initialValue = '',
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.placeholder,
    this.supportingText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
    this.singleLine = true,
    this.secure = false,
    this.inputFilter,
    this.displayFormat,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  /// The entry's key in the form.
  final String? fieldKey;

  /// The first value.
  final String initialValue;

  /// The checks, in order.
  final List<CamoRule<String>> rules;

  /// Called by `save()`.
  final ValueChanged<String>? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// `false` keeps the value but hides the field and skips it.
  final bool visible;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// A decorative icon at the start.
  final Widget? prefixIcon;

  /// An icon or a `CamoFieldAction` at the end.
  final Widget? suffixIcon;

  /// Fixed text before the input.
  final String? prefixText;

  /// Fixed text after the input.
  final String? suffixText;

  /// `false` disables it (and skips validation).
  final bool enabled;

  /// One line.
  final bool singleLine;

  /// A password.
  final bool secure;

  /// Which input is accepted.
  final CamoInputFilter? inputFilter;

  /// How the raw value is shown.
  final CamoDisplayFormat? displayFormat;

  /// The keyboard.
  final TextInputType? keyboardType;

  /// The keyboard's action button.
  final TextInputAction? textInputAction;

  /// Called by the keyboard's action.
  final ValueChanged<String>? onSubmitted;

  /// Autofill hints for password managers.
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) => CamoFormField<String>(
    fieldKey: fieldKey,
    initialValue: initialValue,
    rules: rules,
    onSaved: onSaved == null ? null : (v) => onSaved!(v ?? ''),
    validateMode: validateMode,
    enabled: enabled,
    visible: visible,
    forceError: forceError,
    builder: (context, field) => !visible
        ? const SizedBox.shrink()
        : CamoTextField(
            value: field.value ?? '',
            onChanged: field.didChange,
            label: label,
            placeholder: placeholder,
            supportingText: supportingText,
            error: field.error,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            suffixText: suffixText,
            enabled: enabled,
            singleLine: singleLine,
            secure: secure,
            onFocusChanged: field.onFocusChanged,
            inputFilter: inputFilter,
            displayFormat: displayFormat,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            autofillHints: autofillHints,
            focusNode: field.focusNode,
          ),
  );
}

/// A [CamoCheckbox] in a [CamoForm], e.g. a consent box with `CamoRules.requiredTrue`.
class CamoCheckboxFormField extends StatelessWidget {
  /// Creates a checkbox form field.
  const CamoCheckboxFormField({
    super.key,
    this.fieldKey,
    this.initialValue = false,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.labelSpans,
    this.description,
    this.enabled = true,
  });

  /// The entry's key in the form.
  final String? fieldKey;

  /// The first value.
  final bool initialValue;

  /// The checks, in order.
  final List<CamoRule<bool>> rules;

  /// Called by `save()`.
  final ValueChanged<bool>? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// `false` keeps the value but hides the field and skips it.
  final bool visible;

  /// The label.
  final String? label;

  /// A rich label, instead of [label].
  final List<CamoSpan>? labelSpans;

  /// A second line under the label.
  final String? description;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<bool>(
    fieldKey: fieldKey,
    initialValue: initialValue,
    rules: rules,
    onSaved: onSaved == null ? null : (v) => onSaved!(v ?? false),
    validateMode: validateMode,
    enabled: enabled,
    visible: visible,
    forceError: forceError,
    builder: (context, field) => !visible
        ? const SizedBox.shrink()
        : CamoCheckbox(
            checked: field.value ?? false,
            onChanged: field.didChange,
            label: label,
            labelSpans: labelSpans,
            description: description,
            error: field.error,
            enabled: enabled,
            focusNode: field.focusNode,
          ),
  );
}

/// A [CamoSwitch] in a [CamoForm].
class CamoSwitchFormField extends StatelessWidget {
  /// Creates a switch form field.
  const CamoSwitchFormField({
    super.key,
    this.fieldKey,
    this.initialValue = false,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.labelSpans,
    this.description,
    this.enabled = true,
  });

  /// The entry's key in the form.
  final String? fieldKey;

  /// The first value.
  final bool initialValue;

  /// The checks, in order.
  final List<CamoRule<bool>> rules;

  /// Called by `save()`.
  final ValueChanged<bool>? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// `false` keeps the value but hides the field and skips it.
  final bool visible;

  /// The label.
  final String? label;

  /// A rich label, instead of [label].
  final List<CamoSpan>? labelSpans;

  /// A second line under the label.
  final String? description;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<bool>(
    fieldKey: fieldKey,
    initialValue: initialValue,
    rules: rules,
    onSaved: onSaved == null ? null : (v) => onSaved!(v ?? false),
    validateMode: validateMode,
    enabled: enabled,
    visible: visible,
    forceError: forceError,
    builder: (context, field) => !visible
        ? const SizedBox.shrink()
        : CamoSwitch(
            checked: field.value ?? false,
            onChanged: field.didChange,
            label: label,
            labelSpans: labelSpans,
            description: description,
            error: field.error,
            enabled: enabled,
            focusNode: field.focusNode,
          ),
  );
}

/// A [CamoRadioGroup] in a [CamoForm], e.g. with `CamoRules.required` for "pick one".
class CamoRadioGroupFormField<T> extends StatelessWidget {
  /// Creates a radio group form field.
  const CamoRadioGroupFormField({
    super.key,
    this.fieldKey,
    required this.options,
    this.initialValue,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.direction = Axis.vertical,
    this.enabled = true,
  });

  /// The entry's key in the form.
  final String? fieldKey;

  /// The choices.
  final List<RadioOption<T>> options;

  /// The first value.
  final T? initialValue;

  /// The checks, in order.
  final List<CamoRule<T>> rules;

  /// Called by `save()`.
  final void Function(T? value)? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// `false` keeps the value but hides the field and skips it.
  final bool visible;

  /// The group's label.
  final String? label;

  /// Vertical or horizontal.
  final Axis direction;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<T>(
    fieldKey: fieldKey,
    initialValue: initialValue,
    rules: rules,
    onSaved: onSaved,
    validateMode: validateMode,
    enabled: enabled,
    visible: visible,
    forceError: forceError,
    builder: (context, field) => !visible
        ? const SizedBox.shrink()
        : CamoRadioGroup<T>(
            value: field.value,
            onChanged: enabled ? field.didChange : null,
            options: options,
            label: label,
            error: field.error,
            direction: direction,
          ),
  );
}

/// A whole-number [CamoStepper] in a [CamoForm].
class CamoStepperFormField extends StatelessWidget {
  /// Creates a stepper form field.
  const CamoStepperFormField({
    super.key,
    this.fieldKey,
    this.initialValue = 0,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.min = 0,
    this.max,
    this.step = 1,
    this.semanticLabel,
    this.allowTyping = true,
    this.valueText,
    this.enabled = true,
  });

  /// The entry's key in the form.
  final String? fieldKey;

  /// The first value.
  final int initialValue;

  /// The checks, in order.
  final List<CamoRule<int>> rules;

  /// Called by `save()`.
  final ValueChanged<int>? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// `false` keeps the value but hides the field and skips it.
  final bool visible;

  /// The smallest value.
  final int min;

  /// The largest value.
  final int? max;

  /// How much a press changes the value.
  final int step;

  /// Names the value.
  final String? semanticLabel;

  /// The value is an editable number field.
  final bool allowTyping;

  /// Formats the shown value.
  final String Function(int value)? valueText;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<int>(
    fieldKey: fieldKey,
    initialValue: initialValue,
    rules: rules,
    onSaved: onSaved == null ? null : (v) => onSaved!(v ?? initialValue),
    validateMode: validateMode,
    enabled: enabled,
    visible: visible,
    forceError: forceError,
    builder: (context, field) => !visible
        ? const SizedBox.shrink()
        : CamoStepper(
            value: field.value ?? initialValue,
            onChanged: enabled ? field.didChange : null,
            min: min,
            max: max,
            step: step,
            semanticLabel: semanticLabel,
            allowTyping: allowTyping,
            valueText: valueText,
            error: field.error,
          ),
  );
}
