/// The Cupertino skin: Apple's HIG dialect. Opaque grouped surfaces, blur materials (or Liquid Glass) for bars, sheets
/// and menus, press-fade feedback, and Apple's anatomy (stacked alerts, wheel pickers, inset grouped lists,
/// segmented tabs, a collapsing large title).
library;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'src/cupertino_material.dart';
import 'src/opacity.dart';
import 'src/cupertino_theme.dart';
import 'src/renderer/cupertino_actions.dart';
import 'src/renderer/cupertino_data_display.dart';
import 'src/renderer/cupertino_feedback.dart';
import 'src/renderer/cupertino_inputs.dart';
import 'src/renderer/cupertino_navigation.dart';
import 'src/renderer/cupertino_collections.dart';
import 'src/renderer/cupertino_groups.dart';
import 'src/renderer/cupertino_indicators.dart';
import 'src/renderer/cupertino_lists.dart';
import 'src/renderer/cupertino_navigation_chrome.dart';
import 'src/renderer/cupertino_panels.dart';
import 'src/renderer/cupertino_pickers.dart';
import 'src/renderer/cupertino_primitives.dart';
import 'src/renderer/cupertino_structure.dart';
import 'src/renderer/cupertino_text.dart';

export 'src/cupertino_material.dart';
export 'src/opacity.dart';
export 'src/cupertino_theme.dart';
export 'src/renderer/cupertino_actions.dart'
    show
        CupertinoButtonRenderer,
        CupertinoIconButtonRenderer,
        CupertinoProgressCircleRenderer;
export 'src/renderer/cupertino_data_display.dart'
    show CupertinoAvatarRenderer, CupertinoBadgeRenderer, CupertinoChipRenderer;
export 'src/renderer/cupertino_feedback.dart'
    show
        CupertinoBannerRenderer,
        CupertinoProgressBarRenderer,
        CupertinoSnackbarRenderer;
export 'src/renderer/cupertino_inputs.dart'
    show
        CupertinoCheckboxRenderer,
        CupertinoRadioRenderer,
        CupertinoSegmentedControlRenderer,
        CupertinoSliderRenderer,
        CupertinoStepperRenderer,
        CupertinoSwitchRenderer;
export 'src/renderer/cupertino_navigation.dart'
    show CupertinoFabRenderer, CupertinoTabsRenderer;
export 'src/renderer/cupertino_lists.dart'
    show CupertinoDataTableRenderer, CupertinoTreeRenderer;
export 'src/renderer/cupertino_indicators.dart'
    show
        CupertinoBreadcrumbRenderer,
        CupertinoImageRenderer,
        CupertinoPaginationRenderer,
        CupertinoProgressStepsRenderer,
        CupertinoRatingRenderer;
export 'src/renderer/cupertino_collections.dart'
    show CupertinoCarouselRenderer, CupertinoFileUploaderRenderer;
export 'src/renderer/cupertino_groups.dart'
    show
        CupertinoButtonGroupRenderer,
        CupertinoSplitButtonRenderer,
        CupertinoToolbarRenderer;
export 'src/renderer/cupertino_panels.dart'
    show CupertinoPopoverRenderer, CupertinoSideSheetRenderer;
export 'src/renderer/cupertino_navigation_chrome.dart'
    show
        CupertinoNavigationBarRenderer,
        CupertinoNavigationDrawerRenderer,
        CupertinoNavigationRailRenderer;
export 'src/renderer/cupertino_pickers.dart'
    show
        CupertinoBottomSheetRenderer,
        CupertinoDatePickerRenderer,
        CupertinoDialogRenderer,
        CupertinoMenuRenderer,
        CupertinoTimePickerRenderer;
export 'src/renderer/cupertino_primitives.dart';
export 'src/renderer/cupertino_structure.dart'
    show
        CupertinoAccordionRenderer,
        CupertinoCardRenderer,
        CupertinoListItemRenderer,
        CupertinoPagedListRenderer,
        CupertinoSkeletonRenderer,
        CupertinoTopBarRenderer;
export 'src/renderer/cupertino_text.dart'
    show CupertinoSearchFieldRenderer, CupertinoTextFieldRenderer;

/// The Cupertino skin (Classic surfaces). Skins also serve as renderer libraries, so each renderer is public for
/// borrowing (ADR-28). Pair it with [cupertinoTheme]; [cupertinoSkinWith] has the Liquid Glass option. Text fields
/// put the label above them; for a floating label by default, use `cupertinoSkin.copyWith(textField: const
/// CupertinoTextFieldRenderer(labelPlacement: LabelPlacement.floating))`.
const CamoSkin cupertinoSkin = CamoSkin(
  name: 'cupertino',
  surfaceTreatment: Classic(),
  feedback: OpacityFeedback(),
  text: CupertinoTextRenderer(),
  icon: CupertinoIconRenderer(),
  surface: CupertinoSurfaceRenderer(),
  divider: CupertinoDividerRenderer(),
  button: CupertinoButtonRenderer(),
  iconButton: CupertinoIconButtonRenderer(),
  progressCircle: CupertinoProgressCircleRenderer(),
  progressBar: CupertinoProgressBarRenderer(),
  tooltip: CupertinoTooltipRenderer(),
  checkbox: CupertinoCheckboxRenderer(),
  switchRenderer: CupertinoSwitchRenderer(),
  radio: CupertinoRadioRenderer(),
  segmentedControl: CupertinoSegmentedControlRenderer(),
  slider: CupertinoSliderRenderer(),
  stepper: CupertinoStepperRenderer(),
  textField: CupertinoTextFieldRenderer(),
  searchField: CupertinoSearchFieldRenderer(),
  menu: CupertinoMenuRenderer(),
  bottomSheet: CupertinoBottomSheetRenderer(),
  datePicker: CupertinoDatePickerRenderer(),
  timePicker: CupertinoTimePickerRenderer(),
  card: CupertinoCardRenderer(),
  listItem: CupertinoListItemRenderer(),
  accordion: CupertinoAccordionRenderer(),
  skeleton: CupertinoSkeletonRenderer(),
  topBar: CupertinoTopBarRenderer(),
  pagedList: CupertinoPagedListRenderer(),
  dialog: CupertinoDialogRenderer(),
  chip: CupertinoChipRenderer(),
  badge: CupertinoBadgeRenderer(),
  avatar: CupertinoAvatarRenderer(),
  snackbar: CupertinoSnackbarRenderer(),
  banner: CupertinoBannerRenderer(),
  tabs: CupertinoTabsRenderer(),
  fab: CupertinoFabRenderer(),
  navigationBar: CupertinoNavigationBarRenderer(),
  navigationRail: CupertinoNavigationRailRenderer(),
  navigationDrawer: CupertinoNavigationDrawerRenderer(),
  popover: CupertinoPopoverRenderer(),
  sideSheet: CupertinoSideSheetRenderer(),
  buttonGroup: CupertinoButtonGroupRenderer(),
  splitButton: CupertinoSplitButtonRenderer(),
  toolbar: CupertinoToolbarRenderer(),
  image: CupertinoImageRenderer(),
  rating: CupertinoRatingRenderer(),
  pagination: CupertinoPaginationRenderer(),
  breadcrumb: CupertinoBreadcrumbRenderer(),
  progressSteps: CupertinoProgressStepsRenderer(),
  dataTable: CupertinoDataTableRenderer(),
  tree: CupertinoTreeRenderer(),
  carousel: CupertinoCarouselRenderer(),
  fileUploader: CupertinoFileUploaderRenderer(),
);

/// The Cupertino skin with its surface option: [CupertinoSurface.liquidGlass] draws bars, sheets, menus and the
/// tinted buttons as Liquid Glass; its buttons are capsules.
CamoSkin cupertinoSkinWith({
  CupertinoSurface surface = CupertinoSurface.classic,
}) => surface == CupertinoSurface.classic
    ? cupertinoSkin
    : cupertinoSkin.copyWith(
        surfaceTreatment: const LiquidGlass(),
        button: const CupertinoButtonRenderer(glass: true),
        iconButton: const CupertinoIconButtonRenderer(glass: true),
      );

/// A provider for widget previews and golden setups with [cupertinoSkin] and [cupertinoLight] or [cupertinoDark].
class CupertinoPreview extends StatelessWidget {
  /// Creates a preview of [child].
  const CupertinoPreview({
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
    skin: cupertinoSkin,
    theme: brightness == Brightness.dark ? cupertinoDark : cupertinoLight,
    child: child,
  );
}
