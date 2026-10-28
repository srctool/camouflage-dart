import 'package:flutter/foundation.dart';

import '../accordion/camo_accordion.dart';
import '../avatar/camo_avatar.dart';
import '../badge/camo_badge.dart';
import '../banner/camo_banner.dart';
import '../bottom_sheet/camo_bottom_sheet.dart';
import '../button/camo_button.dart';
import '../card/camo_card.dart';
import '../checkbox/camo_checkbox.dart';
import '../chip/camo_chip.dart';
import '../datepicker/camo_calendar.dart';
import '../dialog/camo_dialog.dart';
import '../divider/camo_divider.dart';
import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../list/camo_list_item.dart';
import '../menu/camo_menu.dart';
import '../paged_list/camo_paged_list.dart';
import '../progress/camo_progress.dart';
import '../radio/camo_radio.dart';
import '../search/camo_search_field.dart';
import '../segmented/camo_segmented_control.dart';
import '../skeleton/camo_skeleton.dart';
import '../slider/camo_slider.dart';
import '../snackbar/camo_snackbar.dart';
import '../stepper/camo_stepper.dart';
import '../surface/camo_surface.dart';
import '../switch/camo_switch.dart';
import '../text/camo_text.dart';
import '../textfield/camo_text_field.dart';
import '../timepicker/camo_time_picker.dart';
import '../tooltip/camo_tooltip.dart';
import '../topbar/camo_top_bar.dart';
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
    required this.progressBar,
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
    required this.card,
    required this.listItem,
    required this.accordion,
    required this.skeleton,
    required this.topBar,
    required this.pagedList,
    required this.dialog,
    required this.chip,
    required this.badge,
    required this.avatar,
    required this.snackbar,
    required this.banner,
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

  /// Progress bars.
  final CamoProgressBarRenderer progressBar;

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

  /// Cards.
  final CamoCardRenderer card;

  /// List rows and sections.
  final CamoListItemRenderer listItem;

  /// Accordions.
  final CamoAccordionRenderer accordion;

  /// Skeleton placeholders.
  final CamoSkeletonRenderer skeleton;

  /// Top bars.
  final CamoTopBarRenderer topBar;

  /// Paged lists.
  final CamoPagedListRenderer pagedList;

  /// Dialogs.
  final CamoDialogRenderer dialog;

  /// Chips.
  final CamoChipRenderer chip;

  /// Badges.
  final CamoBadgeRenderer badge;

  /// Avatars.
  final CamoAvatarRenderer avatar;

  /// Snackbars.
  final CamoSnackbarRenderer snackbar;

  /// Banners.
  final CamoBannerRenderer banner;

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
    CamoProgressBarRenderer? progressBar,
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
    CamoCardRenderer? card,
    CamoListItemRenderer? listItem,
    CamoAccordionRenderer? accordion,
    CamoSkeletonRenderer? skeleton,
    CamoTopBarRenderer? topBar,
    CamoPagedListRenderer? pagedList,
    CamoDialogRenderer? dialog,
    CamoChipRenderer? chip,
    CamoBadgeRenderer? badge,
    CamoAvatarRenderer? avatar,
    CamoSnackbarRenderer? snackbar,
    CamoBannerRenderer? banner,
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
    progressBar: progressBar ?? this.progressBar,
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
    card: card ?? this.card,
    listItem: listItem ?? this.listItem,
    accordion: accordion ?? this.accordion,
    skeleton: skeleton ?? this.skeleton,
    topBar: topBar ?? this.topBar,
    pagedList: pagedList ?? this.pagedList,
    dialog: dialog ?? this.dialog,
    chip: chip ?? this.chip,
    badge: badge ?? this.badge,
    avatar: avatar ?? this.avatar,
    snackbar: snackbar ?? this.snackbar,
    banner: banner ?? this.banner,
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
      other.progressBar == progressBar &&
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
      other.timePicker == timePicker &&
      other.card == card &&
      other.listItem == listItem &&
      other.accordion == accordion &&
      other.skeleton == skeleton &&
      other.topBar == topBar &&
      other.pagedList == pagedList &&
      other.dialog == dialog &&
      other.chip == chip &&
      other.badge == badge &&
      other.avatar == avatar &&
      other.snackbar == snackbar &&
      other.banner == banner;

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
    progressBar,
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
    card,
    listItem,
    accordion,
    skeleton,
    topBar,
    pagedList,
    dialog,
    chip,
    badge,
    avatar,
    snackbar,
    banner,
  ]);

  @override
  String toString() => 'CamoSkin($name)';
}
