import 'package:flutter/widgets.dart';

import '../datepicker/camo_date_field.dart';
import '../datepicker/camo_dates.dart';
import '../timepicker/camo_time_picker.dart';
import '../timepicker/camo_times.dart';
import 'camo_form.dart';
import 'camo_rule.dart';

// The date and time fields in a form. Values are null until picked, so CamoRules.required applies as is.

/// A [CamoDateField] in a [CamoForm]. It takes the date field's parameters, minus `value`, `onChanged` and
/// `error`.
class CamoDateFormField extends StatelessWidget {
  /// Creates a date form field.
  const CamoDateFormField({
    super.key,
    this.fieldKey,
    this.initialValue,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.placeholder,
    this.supportingText,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.presentation = PickerPresentation.auto,
    this.enabled = true,
  });

  /// The field's key in the form.
  final String? fieldKey;

  /// The starting date.
  final DateTime? initialValue;

  /// The rules, checked in order.
  final List<CamoRule<DateTime?>> rules;

  /// Called by the form's save.
  final ValueChanged<DateTime?>? onSaved;

  /// Overrides the form's mode for this field.
  final ValidateMode? validateMode;

  /// An error shown regardless of the rules.
  final String? forceError;

  /// `false` hides it and leaves it out of validation.
  final bool visible;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The earliest date.
  final DateTime? firstDate;

  /// The latest date.
  final DateTime? lastDate;

  /// `false` disables a day.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Popup, sheet, or by window width.
  final PickerPresentation presentation;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<DateTime?>(
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
        : CamoDateField(
            value: field.value,
            onChanged: field.didChange,
            label: label,
            placeholder: placeholder,
            supportingText: supportingText,
            error: field.error,
            firstDate: firstDate,
            lastDate: lastDate,
            selectableDayPredicate: selectableDayPredicate,
            presentation: presentation,
            enabled: enabled,
            onFocusChanged: field.onFocusChanged,
            focusNode: field.focusNode,
          ),
  );
}

/// A [CamoDateRangeField] in a [CamoForm].
class CamoDateRangeFormField extends StatelessWidget {
  /// Creates a date range form field.
  const CamoDateRangeFormField({
    super.key,
    this.fieldKey,
    this.initialValue,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.placeholder,
    this.supportingText,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.maxLength,
    this.presentation = PickerPresentation.auto,
    this.enabled = true,
  });

  /// The field's key in the form.
  final String? fieldKey;

  /// The starting range.
  final CamoDateRange? initialValue;

  /// The rules, checked in order.
  final List<CamoRule<CamoDateRange?>> rules;

  /// Called by the form's save.
  final ValueChanged<CamoDateRange?>? onSaved;

  /// Overrides the form's mode for this field.
  final ValidateMode? validateMode;

  /// An error shown regardless of the rules.
  final String? forceError;

  /// `false` hides it and leaves it out of validation.
  final bool visible;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The earliest date.
  final DateTime? firstDate;

  /// The latest date.
  final DateTime? lastDate;

  /// `false` disables a day.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The longest range in days.
  final int? maxLength;

  /// Popup, sheet, or by window width.
  final PickerPresentation presentation;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<CamoDateRange?>(
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
        : CamoDateRangeField(
            value: field.value,
            onChanged: field.didChange,
            label: label,
            placeholder: placeholder,
            supportingText: supportingText,
            error: field.error,
            firstDate: firstDate,
            lastDate: lastDate,
            selectableDayPredicate: selectableDayPredicate,
            maxLength: maxLength,
            presentation: presentation,
            enabled: enabled,
            onFocusChanged: field.onFocusChanged,
            focusNode: field.focusNode,
          ),
  );
}

/// A [CamoTimeField] in a [CamoForm].
class CamoTimeFormField extends StatelessWidget {
  /// Creates a time form field.
  const CamoTimeFormField({
    super.key,
    this.fieldKey,
    this.initialValue,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.placeholder,
    this.supportingText,
    this.minuteStep = 1,
    this.use24Hour,
    this.minTime,
    this.maxTime,
    this.presentation = PickerPresentation.auto,
    this.enabled = true,
  });

  /// The field's key in the form.
  final String? fieldKey;

  /// The starting time.
  final CamoTime? initialValue;

  /// The rules, checked in order.
  final List<CamoRule<CamoTime?>> rules;

  /// Called by the form's save.
  final ValueChanged<CamoTime?>? onSaved;

  /// Overrides the form's mode for this field.
  final ValidateMode? validateMode;

  /// An error shown regardless of the rules.
  final String? forceError;

  /// `false` hides it and leaves it out of validation.
  final bool visible;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The minute step.
  final int minuteStep;

  /// 24-hour digits; `null` follows the device.
  final bool? use24Hour;

  /// The earliest time.
  final CamoTime? minTime;

  /// The latest time.
  final CamoTime? maxTime;

  /// Popup, sheet, or by window width.
  final PickerPresentation presentation;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<CamoTime?>(
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
        : CamoTimeField(
            value: field.value,
            onChanged: field.didChange,
            label: label,
            placeholder: placeholder,
            supportingText: supportingText,
            error: field.error,
            minuteStep: minuteStep,
            use24Hour: use24Hour,
            minTime: minTime,
            maxTime: maxTime,
            presentation: presentation,
            enabled: enabled,
            onFocusChanged: field.onFocusChanged,
            focusNode: field.focusNode,
          ),
  );
}
