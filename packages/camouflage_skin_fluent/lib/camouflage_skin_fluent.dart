/// The Fluent 2 skin, drawn with widgets: Solid surfaces with Fluent's shadows, Subtle feedback with the
/// double-stroke focus, and Fluent's proportions. Pair it with [fluentTheme].
library;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'src/fluent_solid.dart';
import 'src/fluent_theme.dart';
import 'src/renderer/fluent_actions.dart';
import 'src/renderer/fluent_inputs.dart';
import 'src/renderer/fluent_pickers.dart';
import 'src/renderer/fluent_primitives.dart';
import 'src/renderer/fluent_structure.dart';
import 'src/renderer/fluent_text.dart';
import 'src/subtle.dart';

export 'src/fluent_palette.dart' show fluentBrandBlue;
export 'src/fluent_solid.dart';
export 'src/fluent_theme.dart';
export 'src/fluent_tokens.dart';
export 'src/renderer/fluent_actions.dart';
export 'src/renderer/fluent_inputs.dart';
export 'src/renderer/fluent_pickers.dart'
    show
        FluentBottomSheetRenderer,
        FluentDatePickerRenderer,
        FluentMenuRenderer,
        FluentTimePickerRenderer;
export 'src/renderer/fluent_primitives.dart';
export 'src/renderer/fluent_structure.dart'
    show
        FluentAccordionRenderer,
        FluentCardRenderer,
        FluentListItemRenderer,
        FluentPagedListRenderer,
        FluentSkeletonRenderer,
        FluentTopBarRenderer;
export 'src/renderer/fluent_text.dart';
export 'src/subtle.dart';

/// The surface treatments Fluent offers. `acrylic` joins with the overlays (M6) and `mica` with M8.
enum FluentSurface {
  /// Fills and Fluent's shadows.
  solid,
}

/// The Fluent skin with the given [surface]. Each component's renderer joins in its milestone.
CamoSkin fluentSkin({FluentSurface surface = FluentSurface.solid}) =>
    fluentSkinDefault;

/// The Fluent skin with the `solid` surface.
const CamoSkin fluentSkinDefault = CamoSkin(
  name: 'fluent',
  surfaceTreatment: FluentSolid(),
  feedback: Subtle(),
  text: FluentTextRenderer(),
  icon: FluentIconRenderer(),
  surface: FluentSurfaceRenderer(),
  divider: FluentDividerRenderer(),
  button: FluentButtonRenderer(),
  iconButton: FluentIconButtonRenderer(),
  progressCircle: FluentProgressCircleRenderer(),
  tooltip: FluentTooltipRenderer(),
  checkbox: FluentCheckboxRenderer(),
  switchRenderer: FluentSwitchRenderer(),
  radio: FluentRadioRenderer(),
  segmentedControl: FluentSegmentedControlRenderer(),
  slider: FluentSliderRenderer(),
  stepper: FluentStepperRenderer(),
  textField: FluentTextFieldRenderer(),
  searchField: FluentSearchFieldRenderer(),
  menu: FluentMenuRenderer(),
  bottomSheet: FluentBottomSheetRenderer(),
  datePicker: FluentDatePickerRenderer(),
  timePicker: FluentTimePickerRenderer(),
  card: FluentCardRenderer(),
  listItem: FluentListItemRenderer(),
  accordion: FluentAccordionRenderer(),
  skeleton: FluentSkeletonRenderer(),
  topBar: FluentTopBarRenderer(),
  pagedList: FluentPagedListRenderer(),
);

/// A provider for widget previews and golden setups with [fluentSkinDefault] and [fluentTheme].
class FluentPreview extends StatelessWidget {
  /// Creates a preview of [child].
  const FluentPreview({
    super.key,
    this.brightness = Brightness.light,
    this.density = FluentDensity.medium,
    required this.child,
  });

  /// Light or dark.
  final Brightness brightness;

  /// The control sizes.
  final FluentDensity density;

  /// The widget to preview.
  final Widget child;

  @override
  Widget build(BuildContext context) => CamouflagePreview(
    skin: fluentSkinDefault,
    theme: fluentTheme(brightness: brightness, density: density),
    child: child,
  );
}
