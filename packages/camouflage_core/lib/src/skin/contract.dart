import 'package:flutter/widgets.dart';

import '../theme/camo_theme.dart';
import 'interaction.dart';

/// What a skin's surfaces are made of: how a container is filled, shown at depth and clipped.
abstract interface class SurfaceTreatment {
  /// Wraps [child] in this skin's surface for [color], [shape] and [elevation].
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  });
}

/// How a skin responds to press, hover and keyboard focus. It must always make keyboard focus visible.
abstract interface class InteractionFeedback {
  /// Wraps [child] with feedback driven by [controller], drawn in [contentColor].
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  });
}
