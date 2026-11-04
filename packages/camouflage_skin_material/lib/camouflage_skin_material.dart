/// The Material 3 skin: [Paper] surfaces, [Ripple] feedback, M3's proportions and the baseline theme. It draws
/// every component on widgets and uses `material_ui` only for the ink ripple.
library;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'src/material_theme.dart';
import 'src/paper.dart';
import 'src/ripple.dart';
import 'src/renderer/material_actions.dart';
import 'src/renderer/material_data_display.dart';
import 'src/renderer/material_feedback.dart';
import 'src/renderer/material_inputs.dart';
import 'src/renderer/material_navigation.dart';
import 'src/renderer/material_collections.dart';
import 'src/renderer/material_groups.dart';
import 'src/renderer/material_indicators.dart';
import 'src/renderer/material_lists.dart';
import 'src/renderer/material_navigation_chrome.dart';
import 'src/renderer/material_panels.dart';
import 'src/renderer/material_pickers.dart';
import 'src/renderer/material_primitives.dart';
import 'src/renderer/material_structure.dart';
import 'src/renderer/material_text.dart';
import 'src/renderer/material_wavy.dart';

export 'src/material_theme.dart';
export 'src/paper.dart';
export 'src/ripple.dart';
export 'src/renderer/material_actions.dart'
    show
        MaterialButtonRenderer,
        MaterialIconButtonRenderer,
        MaterialProgressCircleRenderer;
export 'src/renderer/material_data_display.dart'
    show MaterialAvatarRenderer, MaterialBadgeRenderer, MaterialChipRenderer;
export 'src/renderer/material_feedback.dart'
    show
        MaterialBannerRenderer,
        MaterialProgressBarRenderer,
        MaterialSnackbarRenderer;
export 'src/renderer/material_inputs.dart'
    show
        MaterialCheckboxRenderer,
        MaterialRadioRenderer,
        MaterialSegmentedControlRenderer,
        MaterialSliderRenderer,
        MaterialStepperRenderer,
        MaterialSwitchRenderer;
export 'src/renderer/material_navigation.dart'
    show MaterialFabRenderer, MaterialTabsRenderer;
export 'src/renderer/material_lists.dart'
    show MaterialDataTableRenderer, MaterialTreeRenderer;
export 'src/renderer/material_indicators.dart'
    show
        MaterialBreadcrumbRenderer,
        MaterialImageRenderer,
        MaterialPaginationRenderer,
        MaterialProgressStepsRenderer,
        MaterialRatingRenderer;
export 'src/renderer/material_collections.dart'
    show MaterialCarouselRenderer, MaterialFileUploaderRenderer;
export 'src/renderer/material_groups.dart'
    show
        MaterialButtonGroupRenderer,
        MaterialSplitButtonRenderer,
        MaterialToolbarRenderer;
export 'src/renderer/material_panels.dart'
    show MaterialPopoverRenderer, MaterialSideSheetRenderer;
export 'src/renderer/material_navigation_chrome.dart'
    show
        MaterialNavigationBarRenderer,
        MaterialNavigationDrawerRenderer,
        MaterialNavigationRailRenderer;
export 'src/renderer/material_pickers.dart'
    show
        MaterialBottomSheetRenderer,
        MaterialDatePickerRenderer,
        MaterialDialogRenderer,
        MaterialMenuRenderer,
        MaterialTimePickerRenderer;
export 'src/renderer/material_primitives.dart';
export 'src/renderer/material_structure.dart'
    show
        MaterialAccordionRenderer,
        MaterialCardRenderer,
        MaterialListItemRenderer,
        MaterialPagedListRenderer,
        MaterialSkeletonRenderer,
        MaterialTopBarRenderer;
export 'src/renderer/material_text.dart'
    show MaterialSearchFieldRenderer, MaterialTextFieldRenderer;
export 'src/renderer/material_wavy.dart' show MaterialWavyProgressBarRenderer;

/// The Material skin. Skins also serve as renderer libraries, so each renderer is public for borrowing (ADR-28).
/// Pair it with [materialTheme]; [materialSkinWith] has the options for looks only this dialect draws.
const CamoSkin materialSkin = CamoSkin(
  name: 'material',
  surfaceTreatment: Paper(),
  feedback: Ripple(),
  text: MaterialTextRenderer(),
  icon: MaterialIconRenderer(),
  surface: MaterialSurfaceRenderer(),
  divider: MaterialDividerRenderer(),
  button: MaterialButtonRenderer(),
  iconButton: MaterialIconButtonRenderer(),
  progressCircle: MaterialProgressCircleRenderer(),
  progressBar: MaterialProgressBarRenderer(),
  tooltip: MaterialTooltipRenderer(),
  checkbox: MaterialCheckboxRenderer(),
  switchRenderer: MaterialSwitchRenderer(),
  radio: MaterialRadioRenderer(),
  segmentedControl: MaterialSegmentedControlRenderer(),
  slider: MaterialSliderRenderer(),
  stepper: MaterialStepperRenderer(),
  textField: MaterialTextFieldRenderer(),
  searchField: MaterialSearchFieldRenderer(),
  menu: MaterialMenuRenderer(),
  bottomSheet: MaterialBottomSheetRenderer(),
  datePicker: MaterialDatePickerRenderer(),
  timePicker: MaterialTimePickerRenderer(),
  card: MaterialCardRenderer(),
  listItem: MaterialListItemRenderer(),
  accordion: MaterialAccordionRenderer(),
  skeleton: MaterialSkeletonRenderer(),
  topBar: MaterialTopBarRenderer(),
  pagedList: MaterialPagedListRenderer(),
  dialog: MaterialDialogRenderer(),
  chip: MaterialChipRenderer(),
  badge: MaterialBadgeRenderer(),
  avatar: MaterialAvatarRenderer(),
  snackbar: MaterialSnackbarRenderer(),
  banner: MaterialBannerRenderer(),
  tabs: MaterialTabsRenderer(),
  fab: MaterialFabRenderer(),
  navigationBar: MaterialNavigationBarRenderer(),
  navigationRail: MaterialNavigationRailRenderer(),
  navigationDrawer: MaterialNavigationDrawerRenderer(),
  popover: MaterialPopoverRenderer(),
  sideSheet: MaterialSideSheetRenderer(),
  buttonGroup: MaterialButtonGroupRenderer(),
  splitButton: MaterialSplitButtonRenderer(),
  toolbar: MaterialToolbarRenderer(),
  image: MaterialImageRenderer(),
  rating: MaterialRatingRenderer(),
  pagination: MaterialPaginationRenderer(),
  breadcrumb: MaterialBreadcrumbRenderer(),
  progressSteps: MaterialProgressStepsRenderer(),
  dataTable: MaterialDataTableRenderer(),
  tree: MaterialTreeRenderer(),
  carousel: MaterialCarouselRenderer(),
  fileUploader: MaterialFileUploaderRenderer(),
);

/// The Material skin with its options: [expressiveProgress] draws the linear progress indicator as M3
/// Expressive's wave.
CamoSkin materialSkinWith({bool expressiveProgress = false}) =>
    expressiveProgress
    ? materialSkin.copyWith(
        progressBar: const MaterialWavyProgressBarRenderer(),
      )
    : materialSkin;

/// A provider for widget previews and golden setups with [materialSkin] and the baseline theme.
class MaterialPreview extends StatelessWidget {
  /// Creates a preview of [child].
  const MaterialPreview({
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
    skin: materialSkin,
    theme: brightness == Brightness.dark
        ? materialBaselineDark
        : materialBaselineLight,
    child: child,
  );
}
