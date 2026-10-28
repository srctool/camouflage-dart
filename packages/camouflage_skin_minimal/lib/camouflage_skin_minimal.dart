/// The Minimal skin: Camouflage's own neutral dialect. Flat surfaces with hairlines, a quiet fade for
/// feedback, ink as the primary, and a clear focus ring.
library;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'src/fade.dart';
import 'src/flat.dart';
import 'src/minimal_theme.dart';
import 'src/renderer/minimal_actions.dart';
import 'src/renderer/minimal_data_display.dart';
import 'src/renderer/minimal_inputs.dart';
import 'src/renderer/minimal_pickers.dart';
import 'src/renderer/minimal_primitives.dart';
import 'src/renderer/minimal_structure.dart';
import 'src/renderer/minimal_text.dart';

export 'src/fade.dart';
export 'src/flat.dart';
export 'src/minimal_theme.dart';
export 'src/renderer/minimal_actions.dart'
    show
        MinimalButtonRenderer,
        MinimalIconButtonRenderer,
        MinimalProgressCircleRenderer;
export 'src/renderer/minimal_data_display.dart'
    show MinimalAvatarRenderer, MinimalBadgeRenderer, MinimalChipRenderer;
export 'src/renderer/minimal_inputs.dart'
    show
        MinimalCheckboxRenderer,
        MinimalRadioRenderer,
        MinimalSegmentedControlRenderer,
        MinimalSliderRenderer,
        MinimalStepperRenderer,
        MinimalSwitchRenderer;
export 'src/renderer/minimal_pickers.dart'
    show
        MinimalBottomSheetRenderer,
        MinimalDatePickerRenderer,
        MinimalDialogRenderer,
        MinimalMenuRenderer,
        MinimalTimePickerRenderer;
export 'src/renderer/minimal_primitives.dart';
export 'src/renderer/minimal_structure.dart'
    show
        MinimalAccordionRenderer,
        MinimalCardRenderer,
        MinimalListItemRenderer,
        MinimalPagedListRenderer,
        MinimalSkeletonRenderer,
        MinimalTopBarRenderer;
export 'src/renderer/minimal_text.dart'
    show MinimalSearchFieldRenderer, MinimalTextFieldRenderer;

/// The Minimal skin. Each component's renderer joins in its milestone; skins also serve as renderer libraries,
/// so each renderer is public for borrowing (ADR-28). Text fields put the label above them; for a floating
/// label by default, use `minimalSkin.copyWith(textField: const MinimalTextFieldRenderer(labelPlacement:
/// LabelPlacement.floating))`.
const CamoSkin minimalSkin = CamoSkin(
  name: 'minimal',
  surfaceTreatment: Flat(),
  feedback: Fade(),
  text: MinimalTextRenderer(),
  icon: MinimalIconRenderer(),
  surface: MinimalSurfaceRenderer(),
  divider: MinimalDividerRenderer(),
  button: MinimalButtonRenderer(),
  iconButton: MinimalIconButtonRenderer(),
  progressCircle: MinimalProgressCircleRenderer(),
  tooltip: MinimalTooltipRenderer(),
  checkbox: MinimalCheckboxRenderer(),
  switchRenderer: MinimalSwitchRenderer(),
  radio: MinimalRadioRenderer(),
  segmentedControl: MinimalSegmentedControlRenderer(),
  slider: MinimalSliderRenderer(),
  stepper: MinimalStepperRenderer(),
  textField: MinimalTextFieldRenderer(),
  searchField: MinimalSearchFieldRenderer(),
  menu: MinimalMenuRenderer(),
  bottomSheet: MinimalBottomSheetRenderer(),
  datePicker: MinimalDatePickerRenderer(),
  timePicker: MinimalTimePickerRenderer(),
  card: MinimalCardRenderer(),
  listItem: MinimalListItemRenderer(),
  accordion: MinimalAccordionRenderer(),
  skeleton: MinimalSkeletonRenderer(),
  topBar: MinimalTopBarRenderer(),
  pagedList: MinimalPagedListRenderer(),
  dialog: MinimalDialogRenderer(),
  chip: MinimalChipRenderer(),
  badge: MinimalBadgeRenderer(),
  avatar: MinimalAvatarRenderer(),
);

/// A provider for widget previews and golden setups with [minimalSkin] and [minimalLight] or [minimalDark].
class MinimalPreview extends StatelessWidget {
  /// Creates a preview of [child].
  const MinimalPreview({
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
    skin: minimalSkin,
    theme: brightness == Brightness.dark ? minimalDark : minimalLight,
    child: child,
  );
}
