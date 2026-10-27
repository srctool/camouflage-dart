import 'package:flutter/foundation.dart';

import '../bottom_sheet/camo_bottom_sheet.dart';
import '../datepicker/camo_calendar.dart';
import '../menu/camo_menu.dart';
import '../timepicker/camo_time_picker.dart';
import '../button/camo_button.dart';
import '../checkbox/camo_checkbox.dart';
import '../divider/camo_divider.dart';
import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../progress/camo_progress.dart';
import '../radio/camo_radio.dart';
import '../search/camo_search_field.dart';
import '../segmented/camo_segmented_control.dart';
import '../slider/camo_slider.dart';
import '../stepper/camo_stepper.dart';
import '../surface/camo_surface.dart';
import '../switch/camo_switch.dart';
import '../textfield/camo_text_field.dart';
import '../text/camo_text.dart';
import '../tooltip/camo_tooltip.dart';
import 'contract.dart';

/// A design language: how each component is built, how it reacts to touch and what its surfaces are made of.
///
/// Every field is required, so a skin that misses one doesn't compile. Each component adds its renderer
/// field here in its own milestone (ADR-39). `copyWith(button: …)` replaces part of a skin and keeps the rest.
/// Renderers read `Camouflage.skinOf(context).surfaceTreatment` and `.feedback`, so a borrowed renderer takes
/// the host skin's.
@immutable
class CamoSkin {
  /// Creates a skin.
  const CamoSkin({
    required this.name,
    required this.surfaceTreatment,
    required this.feedback,
    required this.text,
    required this.icon,
    required this.surface,
    required this.divider,
    required this.button,
    required this.iconButton,
    required this.progressCircle,
    required this.tooltip,
    required this.checkbox,
    required this.switchRenderer,
    required this.radio,
    required this.segmentedControl,
    required this.slider,
    required this.stepper,
    required this.textField,
    required this.searchField,
    required this.menu,
    required this.bottomSheet,
    required this.datePicker,
    required this.timePicker,
  });

  /// For debugging and tests, e.g. `'minimal'`.
  final String name;

  /// What this skin's containers are made of.
  final SurfaceTreatment surfaceTreatment;

  /// How this skin responds to press, hover and focus.
  final InteractionFeedback feedback;

  /// Draws `CamoText`.
  final CamoTextRenderer text;

  /// Draws `CamoIcon`.
  final CamoIconRenderer icon;

  /// Draws `CamoSurface`.
  final CamoSurfaceRenderer surface;

  /// Draws `CamoDivider`.
  final CamoDividerRenderer divider;

  /// Draws `CamoButton`.
  final CamoButtonRenderer button;

  /// Draws `CamoIconButton`.
  final CamoIconButtonRenderer iconButton;

  /// Draws `CamoProgressCircle`.
  final CamoProgressCircleRenderer progressCircle;

  /// Draws `CamoTooltip`'s bubble.
  final CamoTooltipRenderer tooltip;

  /// Draws `CamoCheckbox`.
  final CamoCheckboxRenderer checkbox;

  /// Draws `CamoSwitch` (`switch` is a Dart keyword).
  final CamoSwitchRenderer switchRenderer;

  /// Draws `CamoRadio` and `CamoRadioGroup`'s options.
  final CamoRadioRenderer radio;

  /// Draws `CamoSegmentedControl` and its building blocks.
  final CamoSegmentedControlRenderer segmentedControl;

  /// Draws `CamoSlider`.
  final CamoSliderRenderer slider;

  /// Draws `CamoStepper`.
  final CamoStepperRenderer stepper;

  /// Draws `CamoTextField` and every field built on its frame, with the text-editing visuals.
  final CamoTextFieldRenderer textField;

  /// Draws `CamoSearchField`.
  final CamoSearchFieldRenderer searchField;

  /// Draws `CamoMenuPanel` (M5) and the menus (M6).
  final CamoMenuRenderer menu;

  /// Draws `CamoBottomSheet`.
  final CamoBottomSheetRenderer bottomSheet;

  /// Draws `CamoCalendar` and the date fields' pickers.
  final CamoDatePickerRenderer datePicker;

  /// Draws `CamoTimeInput` and the time field's picker.
  final CamoTimePickerRenderer timePicker;

  /// A copy with the given fields replaced; the others stay `identical`.
  CamoSkin copyWith({
    String? name,
    SurfaceTreatment? surfaceTreatment,
    InteractionFeedback? feedback,
    CamoTextRenderer? text,
    CamoIconRenderer? icon,
    CamoSurfaceRenderer? surface,
    CamoDividerRenderer? divider,
    CamoButtonRenderer? button,
    CamoIconButtonRenderer? iconButton,
    CamoProgressCircleRenderer? progressCircle,
    CamoTooltipRenderer? tooltip,
    CamoCheckboxRenderer? checkbox,
    CamoSwitchRenderer? switchRenderer,
    CamoRadioRenderer? radio,
    CamoSegmentedControlRenderer? segmentedControl,
    CamoSliderRenderer? slider,
    CamoStepperRenderer? stepper,
    CamoTextFieldRenderer? textField,
    CamoSearchFieldRenderer? searchField,
    CamoMenuRenderer? menu,
    CamoBottomSheetRenderer? bottomSheet,
    CamoDatePickerRenderer? datePicker,
    CamoTimePickerRenderer? timePicker,
  }) => CamoSkin(
    name: name ?? this.name,
    surfaceTreatment: surfaceTreatment ?? this.surfaceTreatment,
    feedback: feedback ?? this.feedback,
    text: text ?? this.text,
    icon: icon ?? this.icon,
    surface: surface ?? this.surface,
    divider: divider ?? this.divider,
    button: button ?? this.button,
    iconButton: iconButton ?? this.iconButton,
    progressCircle: progressCircle ?? this.progressCircle,
    tooltip: tooltip ?? this.tooltip,
    checkbox: checkbox ?? this.checkbox,
    switchRenderer: switchRenderer ?? this.switchRenderer,
    radio: radio ?? this.radio,
    segmentedControl: segmentedControl ?? this.segmentedControl,
    slider: slider ?? this.slider,
    stepper: stepper ?? this.stepper,
    textField: textField ?? this.textField,
    searchField: searchField ?? this.searchField,
    menu: menu ?? this.menu,
    bottomSheet: bottomSheet ?? this.bottomSheet,
    datePicker: datePicker ?? this.datePicker,
    timePicker: timePicker ?? this.timePicker,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSkin &&
      other.name == name &&
      other.surfaceTreatment == surfaceTreatment &&
      other.feedback == feedback &&
      other.text == text &&
      other.icon == icon &&
      other.surface == surface &&
      other.divider == divider &&
      other.button == button &&
      other.iconButton == iconButton &&
      other.progressCircle == progressCircle &&
      other.tooltip == tooltip &&
      other.checkbox == checkbox &&
      other.switchRenderer == switchRenderer &&
      other.radio == radio &&
      other.segmentedControl == segmentedControl &&
      other.slider == slider &&
      other.stepper == stepper &&
      other.textField == textField &&
      other.searchField == searchField &&
      other.menu == menu &&
      other.bottomSheet == bottomSheet &&
      other.datePicker == datePicker &&
      other.timePicker == timePicker;

  @override
  int get hashCode => Object.hashAll([
    name,
    surfaceTreatment,
    feedback,
    text,
    icon,
    surface,
    divider,
    button,
    iconButton,
    progressCircle,
    tooltip,
    checkbox,
    switchRenderer,
    radio,
    segmentedControl,
    slider,
    stepper,
    textField,
    searchField,
    menu,
    bottomSheet,
    datePicker,
    timePicker,
  ]);

  @override
  String toString() => 'CamoSkin($name)';
}
