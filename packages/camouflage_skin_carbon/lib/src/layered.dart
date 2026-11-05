import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Carbon's surfaces: opaque layer tokens, never a hairline and no shadow, except that overlays (from `level3`:
/// dialogs, menus, popovers) get Carbon's one overlay shadow. Depth is the gray of the layer the renderer asks
/// for (`layer-01` to `layer-03`), which steps with the nesting.
class Layered implements SurfaceTreatment {
  /// Creates the treatment.
  const Layered();

  static const double _overlayBlur = 12;
  static const double _overlayOffset = 4;
  static const double _shadowAlpha = 0.3;

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) {
    final overlay =
        theme.elevation.levelOf(elevation).index >= ElevationLevel.level3.index;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: shape,
        boxShadow: overlay
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, _shadowAlpha),
                  blurRadius: _overlayBlur,
                  offset: Offset(0, _overlayOffset),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
