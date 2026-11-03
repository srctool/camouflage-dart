import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'debug_data_display_renderers.dart';
import 'debug_feedback_renderers.dart';
import 'debug_input_renderers.dart';
import 'debug_navigation_chrome_renderers.dart';
import 'debug_action_renderers.dart';
import 'debug_collection_renderers.dart';
import 'debug_data_renderers.dart';
import 'debug_list_renderers.dart';
import 'debug_panel_renderers.dart';
import 'debug_navigation_renderers.dart';
import 'debug_picker_renderers.dart';
import 'debug_renderers.dart';
import 'debug_structure_renderers.dart';
import 'debug_text_renderers.dart';

export 'debug_renderers.dart';

/// A skin for proving the contract before any real skin exists: plain fills, no press feedback, and labelled
/// boxes from the reference renderers in `debug_renderers.dart`.
const CamoSkin debugSkin = CamoSkin(
  name: 'debug',
  surfaceTreatment: NoTreatment(),
  feedback: NoFeedback(),
  text: DebugTextRenderer(),
  icon: DebugIconRenderer(),
  surface: DebugSurfaceRenderer(),
  divider: DebugDividerRenderer(),
  button: DebugButtonRenderer(),
  iconButton: DebugIconButtonRenderer(),
  progressCircle: DebugProgressCircleRenderer(),
  progressBar: DebugProgressBarRenderer(),
  tooltip: DebugTooltipRenderer(),
  checkbox: DebugCheckboxRenderer(),
  switchRenderer: DebugSwitchRenderer(),
  radio: DebugRadioRenderer(),
  segmentedControl: DebugSegmentedControlRenderer(),
  slider: DebugSliderRenderer(),
  stepper: DebugStepperRenderer(),
  textField: DebugTextFieldRenderer(),
  searchField: DebugSearchFieldRenderer(),
  menu: DebugMenuRenderer(),
  bottomSheet: DebugBottomSheetRenderer(),
  datePicker: DebugDatePickerRenderer(),
  timePicker: DebugTimePickerRenderer(),
  card: DebugCardRenderer(),
  listItem: DebugListItemRenderer(),
  accordion: DebugAccordionRenderer(),
  skeleton: DebugSkeletonRenderer(),
  topBar: DebugTopBarRenderer(),
  pagedList: DebugPagedListRenderer(),
  dialog: DebugDialogRenderer(),
  chip: DebugChipRenderer(),
  badge: DebugBadgeRenderer(),
  avatar: DebugAvatarRenderer(),
  snackbar: DebugSnackbarRenderer(),
  banner: DebugBannerRenderer(),
  tabs: DebugTabsRenderer(),
  fab: DebugFabRenderer(),
  navigationBar: DebugNavigationBar(),
  navigationRail: DebugNavigationRail(),
  navigationDrawer: DebugNavigationDrawer(),
  popover: DebugPopover(),
  sideSheet: DebugSideSheet(),
  buttonGroup: DebugButtonGroup(),
  splitButton: DebugSplitButton(),
  toolbar: DebugToolbar(),
  image: DebugImage(),
  rating: DebugRating(),
  pagination: DebugPagination(),
  breadcrumb: DebugBreadcrumb(),
  progressSteps: DebugProgressSteps(),
  dataTable: DebugDataTable(),
  tree: DebugTree(),
  carousel: DebugCarousel(),
  fileUploader: DebugFileUploader(),
);

/// Fills the container and nothing else: no depth, no border.
class NoTreatment implements SurfaceTreatment {
  /// Creates the treatment.
  const NoTreatment();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: shape),
    child: child,
  );
}

/// An outline in `outline` instead of depth.
class OutlineTreatment implements SurfaceTreatment {
  /// Creates the treatment.
  const OutlineTreatment();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: shape,
      border: Border.all(color: theme.colors.outline),
    ),
    child: child,
  );
}

/// Draws no feedback. DebugSkin's placeholders draw their own focus border.
class NoFeedback implements InteractionFeedback {
  /// Creates the feedback.
  const NoFeedback();

  @override
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  }) => child;
}

/// A content-color tint while pressed.
class PressTint implements InteractionFeedback {
  /// Creates the feedback.
  const PressTint();

  static const double _pressedAlpha = 0.12;

  @override
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  }) => ValueListenableBuilder<InteractionState>(
    valueListenable: controller,
    child: child,
    builder: (context, state, child) => DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: shape,
        color: state.pressed
            ? contentColor.withValues(alpha: _pressedAlpha)
            : null,
      ),
      child: child,
    ),
  );
}
