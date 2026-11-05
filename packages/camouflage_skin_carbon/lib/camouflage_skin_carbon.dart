/// The Carbon skin: IBM Carbon's dialect. Square corners, opaque layered surfaces with no shadows (but for
/// overlays), hover and active fills, an inset focus border and a bold blue interactive color.
library;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'src/carbon_states.dart';
import 'src/layered.dart';
import 'src/carbon_theme.dart';
import 'src/renderer/carbon_actions.dart';
import 'src/renderer/carbon_data_display.dart';
import 'src/renderer/carbon_feedback.dart';
import 'src/renderer/carbon_inputs.dart';
import 'src/renderer/carbon_navigation.dart';
import 'src/renderer/carbon_collections.dart';
import 'src/renderer/carbon_groups.dart';
import 'src/renderer/carbon_indicators.dart';
import 'src/renderer/carbon_lists.dart';
import 'src/renderer/carbon_navigation_chrome.dart';
import 'src/renderer/carbon_panels.dart';
import 'src/renderer/carbon_pickers.dart';
import 'src/renderer/carbon_primitives.dart';
import 'src/renderer/carbon_structure.dart';
import 'src/renderer/carbon_text.dart';

export 'src/carbon_states.dart';
export 'src/layered.dart';
export 'src/carbon_theme.dart';
export 'src/renderer/carbon_actions.dart'
    show
        CarbonButtonRenderer,
        CarbonIconButtonRenderer,
        CarbonProgressCircleRenderer;
export 'src/renderer/carbon_data_display.dart'
    show CarbonAvatarRenderer, CarbonBadgeRenderer, CarbonChipRenderer;
export 'src/renderer/carbon_feedback.dart'
    show
        CarbonBannerRenderer,
        CarbonProgressBarRenderer,
        CarbonSnackbarRenderer;
export 'src/renderer/carbon_inputs.dart'
    show
        CarbonCheckboxRenderer,
        CarbonRadioRenderer,
        CarbonSegmentedControlRenderer,
        CarbonSliderRenderer,
        CarbonStepperRenderer,
        CarbonSwitchRenderer;
export 'src/renderer/carbon_navigation.dart'
    show CarbonFabRenderer, CarbonTabsRenderer;
export 'src/renderer/carbon_lists.dart'
    show CarbonDataTableRenderer, CarbonTreeRenderer;
export 'src/renderer/carbon_indicators.dart'
    show
        CarbonBreadcrumbRenderer,
        CarbonImageRenderer,
        CarbonPaginationRenderer,
        CarbonProgressStepsRenderer,
        CarbonRatingRenderer;
export 'src/renderer/carbon_collections.dart'
    show CarbonCarouselRenderer, CarbonFileUploaderRenderer;
export 'src/renderer/carbon_groups.dart'
    show
        CarbonButtonGroupRenderer,
        CarbonSplitButtonRenderer,
        CarbonToolbarRenderer;
export 'src/renderer/carbon_panels.dart'
    show CarbonPopoverRenderer, CarbonSideSheetRenderer;
export 'src/renderer/carbon_navigation_chrome.dart'
    show
        CarbonNavigationBarRenderer,
        CarbonNavigationDrawerRenderer,
        CarbonNavigationRailRenderer;
export 'src/renderer/carbon_pickers.dart'
    show
        CarbonBottomSheetRenderer,
        CarbonDatePickerRenderer,
        CarbonDialogRenderer,
        CarbonMenuRenderer,
        CarbonTimePickerRenderer;
export 'src/renderer/carbon_primitives.dart';
export 'src/renderer/carbon_structure.dart'
    show
        CarbonAccordionRenderer,
        CarbonCardRenderer,
        CarbonListItemRenderer,
        CarbonPagedListRenderer,
        CarbonSkeletonRenderer,
        CarbonTopBarRenderer;
export 'src/renderer/carbon_text.dart'
    show CarbonSearchFieldRenderer, CarbonTextFieldRenderer;

/// The Carbon skin. Skins also serve as renderer libraries, so each renderer is public for borrowing (ADR-28). Text fields put the label above them; for a floating
/// label by default, use `carbonSkin.copyWith(textField: const CarbonTextFieldRenderer(labelPlacement:
/// LabelPlacement.floating))`.
const CamoSkin carbonSkin = CamoSkin(
  name: 'carbon',
  surfaceTreatment: Layered(),
  feedback: CarbonStates(),
  text: CarbonTextRenderer(),
  icon: CarbonIconRenderer(),
  surface: CarbonSurfaceRenderer(),
  divider: CarbonDividerRenderer(),
  button: CarbonButtonRenderer(),
  iconButton: CarbonIconButtonRenderer(),
  progressCircle: CarbonProgressCircleRenderer(),
  progressBar: CarbonProgressBarRenderer(),
  tooltip: CarbonTooltipRenderer(),
  checkbox: CarbonCheckboxRenderer(),
  switchRenderer: CarbonSwitchRenderer(),
  radio: CarbonRadioRenderer(),
  segmentedControl: CarbonSegmentedControlRenderer(),
  slider: CarbonSliderRenderer(),
  stepper: CarbonStepperRenderer(),
  textField: CarbonTextFieldRenderer(),
  searchField: CarbonSearchFieldRenderer(),
  menu: CarbonMenuRenderer(),
  bottomSheet: CarbonBottomSheetRenderer(),
  datePicker: CarbonDatePickerRenderer(),
  timePicker: CarbonTimePickerRenderer(),
  card: CarbonCardRenderer(),
  listItem: CarbonListItemRenderer(),
  accordion: CarbonAccordionRenderer(),
  skeleton: CarbonSkeletonRenderer(),
  topBar: CarbonTopBarRenderer(),
  pagedList: CarbonPagedListRenderer(),
  dialog: CarbonDialogRenderer(),
  chip: CarbonChipRenderer(),
  badge: CarbonBadgeRenderer(),
  avatar: CarbonAvatarRenderer(),
  snackbar: CarbonSnackbarRenderer(),
  banner: CarbonBannerRenderer(),
  tabs: CarbonTabsRenderer(),
  fab: CarbonFabRenderer(),
  navigationBar: CarbonNavigationBarRenderer(),
  navigationRail: CarbonNavigationRailRenderer(),
  navigationDrawer: CarbonNavigationDrawerRenderer(),
  popover: CarbonPopoverRenderer(),
  sideSheet: CarbonSideSheetRenderer(),
  buttonGroup: CarbonButtonGroupRenderer(),
  splitButton: CarbonSplitButtonRenderer(),
  toolbar: CarbonToolbarRenderer(),
  image: CarbonImageRenderer(),
  rating: CarbonRatingRenderer(),
  pagination: CarbonPaginationRenderer(),
  breadcrumb: CarbonBreadcrumbRenderer(),
  progressSteps: CarbonProgressStepsRenderer(),
  dataTable: CarbonDataTableRenderer(),
  tree: CarbonTreeRenderer(),
  carousel: CarbonCarouselRenderer(),
  fileUploader: CarbonFileUploaderRenderer(),
);

/// A provider for widget previews and golden setups with [carbonSkin] and [carbonLight] or [carbonDark].
class CarbonPreview extends StatelessWidget {
  /// Creates a preview of [child].
  const CarbonPreview({
    super.key,
    this.brightness = Brightness.light,
    required this.child,
  });

  /// Light or dark.
  final Brightness brightness;

  /// The widget to preview.
  final Widget child;

  @override
  Widget build(BuildContext context) => CamouflagePreview(
    skin: carbonSkin,
    theme: brightness == Brightness.dark ? carbonDark : carbonLight,
    child: child,
  );
}
