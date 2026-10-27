import 'package:flutter/foundation.dart';

import '../button/camo_button.dart';
import '../checkbox/camo_checkbox.dart';
import '../divider/camo_divider.dart';
import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../progress/camo_progress.dart';
import '../radio/camo_radio.dart';
import '../segmented/camo_segmented_control.dart';
import '../slider/camo_slider.dart';
import '../stepper/camo_stepper.dart';
import '../surface/camo_surface.dart';
import '../switch/camo_switch.dart';
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
      other.stepper == stepper;

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
  ]);

  @override
  String toString() => 'CamoSkin($name)';
}
