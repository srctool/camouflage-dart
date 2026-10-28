import 'package:flutter/foundation.dart';

import '../bottom_sheet/camo_bottom_sheet.dart';
import '../button/camo_button.dart';
import '../checkbox/camo_checkbox.dart';
import '../datepicker/camo_calendar.dart';
import '../dialog/camo_dialog.dart';
import '../divider/camo_divider.dart';
import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../menu/camo_menu.dart';
import '../progress/camo_progress.dart';
import '../radio/camo_radio.dart';
import '../search/camo_search_field.dart';
import '../segmented/camo_segmented_control.dart';
import '../slider/camo_slider.dart';
import '../stepper/camo_stepper.dart';
import '../surface/camo_surface.dart';
import '../switch/camo_switch.dart';
import '../textfield/camo_text_field.dart';
import '../timepicker/camo_time_picker.dart';
import '../card/camo_card.dart';
import '../list/camo_list_item.dart';
import '../accordion/camo_accordion.dart';
import '../skeleton/camo_skeleton.dart';
import '../topbar/camo_top_bar.dart';
import '../paged_list/camo_paged_list.dart';
import '../tooltip/camo_tooltip.dart';

/// Per-component overrides: one nullable `CamoXTheme` per component, `null` meaning the skin's default.
/// Each component adds its field here in its own milestone (ADR-39).
@immutable
class CamoComponentThemes {
  /// Creates component themes.
  const CamoComponentThemes({
    this.icon,
    this.surface,
    this.divider,
    this.button,
    this.iconButton,
    this.progress,
    this.tooltip,
    this.checkbox,
    this.switchTheme,
    this.radio,
    this.segmentedControl,
    this.slider,
    this.stepper,
    this.textField,
    this.searchField,
    this.menu,
    this.bottomSheet,
    this.datePicker,
    this.timePicker,
    this.card,
    this.listItem,
    this.accordion,
    this.skeleton,
    this.topBar,
    this.pagedList,
    this.dialog,
  });

  /// Icons outside any component.
  final CamoIconTheme? icon;

  /// Surfaces.
  final CamoSurfaceTheme? surface;

  /// Dividers.
  final CamoDividerTheme? divider;

  /// Buttons.
  final CamoButtonTheme? button;

  /// Icon buttons.
  final CamoIconButtonTheme? iconButton;

  /// Progress indicators.
  final CamoProgressTheme? progress;

  /// Tooltips.
  final CamoTooltipTheme? tooltip;

  /// Checkboxes.
  final CamoCheckboxTheme? checkbox;

  /// Switches (`switch` is a Dart keyword).
  final CamoSwitchTheme? switchTheme;

  /// Radios.
  final CamoRadioTheme? radio;

  /// Segmented controls.
  final CamoSegmentedControlTheme? segmentedControl;

  /// Sliders.
  final CamoSliderTheme? slider;

  /// Steppers.
  final CamoStepperTheme? stepper;

  /// Text fields and the fields built on their frame.
  final CamoTextFieldTheme? textField;

  /// Search fields.
  final CamoSearchFieldTheme? searchField;

  /// Overrides for menus and popup panels.
  final CamoMenuTheme? menu;

  /// Overrides for bottom sheets.
  final CamoBottomSheetTheme? bottomSheet;

  /// Overrides for date pickers and date fields.
  final CamoDatePickerTheme? datePicker;

  /// Overrides for time pickers and time fields.
  final CamoTimePickerTheme? timePicker;

  /// Cards.
  final CamoCardTheme? card;

  /// List rows and sections.
  final CamoListItemTheme? listItem;

  /// Accordions.
  final CamoAccordionTheme? accordion;

  /// Skeleton placeholders.
  final CamoSkeletonTheme? skeleton;

  /// Top bars.
  final CamoTopBarTheme? topBar;

  /// Paged lists.
  final CamoPagedListTheme? pagedList;

  /// Dialogs.
  final CamoDialogTheme? dialog;

  /// A copy with the given fields replaced.
  CamoComponentThemes copyWith({
    CamoIconTheme? icon,
    CamoSurfaceTheme? surface,
    CamoDividerTheme? divider,
    CamoButtonTheme? button,
    CamoIconButtonTheme? iconButton,
    CamoProgressTheme? progress,
    CamoTooltipTheme? tooltip,
    CamoCheckboxTheme? checkbox,
    CamoSwitchTheme? switchTheme,
    CamoRadioTheme? radio,
    CamoSegmentedControlTheme? segmentedControl,
    CamoSliderTheme? slider,
    CamoStepperTheme? stepper,
    CamoTextFieldTheme? textField,
    CamoSearchFieldTheme? searchField,
    CamoMenuTheme? menu,
    CamoBottomSheetTheme? bottomSheet,
    CamoDatePickerTheme? datePicker,
    CamoTimePickerTheme? timePicker,
    CamoCardTheme? card,
    CamoListItemTheme? listItem,
    CamoAccordionTheme? accordion,
    CamoSkeletonTheme? skeleton,
    CamoTopBarTheme? topBar,
    CamoPagedListTheme? pagedList,
    CamoDialogTheme? dialog,
  }) => CamoComponentThemes(
    icon: icon ?? this.icon,
    surface: surface ?? this.surface,
    divider: divider ?? this.divider,
    button: button ?? this.button,
    iconButton: iconButton ?? this.iconButton,
    progress: progress ?? this.progress,
    tooltip: tooltip ?? this.tooltip,
    checkbox: checkbox ?? this.checkbox,
    switchTheme: switchTheme ?? this.switchTheme,
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
    card: card ?? this.card,
    listItem: listItem ?? this.listItem,
    accordion: accordion ?? this.accordion,
    skeleton: skeleton ?? this.skeleton,
    topBar: topBar ?? this.topBar,
    pagedList: pagedList ?? this.pagedList,
    dialog: dialog ?? this.dialog,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoComponentThemes &&
      other.icon == icon &&
      other.surface == surface &&
      other.divider == divider &&
      other.button == button &&
      other.iconButton == iconButton &&
      other.progress == progress &&
      other.tooltip == tooltip &&
      other.checkbox == checkbox &&
      other.switchTheme == switchTheme &&
      other.radio == radio &&
      other.segmentedControl == segmentedControl &&
      other.slider == slider &&
      other.stepper == stepper &&
      other.textField == textField &&
      other.searchField == searchField &&
      other.menu == menu &&
      other.bottomSheet == bottomSheet &&
      other.datePicker == datePicker &&
      other.timePicker == timePicker &&
      other.card == card &&
      other.listItem == listItem &&
      other.accordion == accordion &&
      other.skeleton == skeleton &&
      other.topBar == topBar &&
      other.pagedList == pagedList &&
      other.dialog == dialog;

  @override
  int get hashCode => Object.hashAll([
    icon,
    surface,
    divider,
    button,
    iconButton,
    progress,
    tooltip,
    checkbox,
    switchTheme,
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
    card,
    listItem,
    accordion,
    skeleton,
    topBar,
    pagedList,
    dialog,
  ]);
}
