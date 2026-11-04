import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Material 3's surface: the given color clipped to the shape, with a shadow from `level1`. Separation from the
/// background mostly comes from the surface level (`surfaceContainer*`); the shadow is the elevation of raised
/// components (1, 3, 6, 8 and 12 for `level1` to `level5`).
class Paper implements SurfaceTreatment {
  /// Creates the treatment.
  const Paper();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) => PhysicalShape(
    color: color,
    elevation: elevation,
    shadowColor: const Color(0xFF000000),
    clipper: ShapeBorderClipper(
      shape: RoundedRectangleBorder(borderRadius: shape),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}
