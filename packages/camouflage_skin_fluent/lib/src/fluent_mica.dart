import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_solid.dart';

/// Fluent's Mica: the window backdrop Windows 11 paints from the wallpaper. Camouflage doesn't draw it. Where the
/// platform reports `CamoCapabilities.windowMaterial`, the base layers (the window, the navigation chrome:
/// elevation below `level2`) draw nothing, so the backdrop the app enabled on its window shows through them.
/// Everywhere else, and with Reduce Transparency, they are the opaque Fluent surface ([FluentSolid]), so the
/// layout and behavior are the same (ADR-42). Raised surfaces (cards, flyouts, dialogs) are always [FluentSolid].
///
/// Choosing it is the opt-in: the app must also give its window the Mica backdrop (and no opaque background of its
/// own), or the base layers show the window's own color. Flutter reports no window material by itself, so supply
/// it through the provider's `environment` (`capabilities.windowMaterial`) where you set the backdrop up.
class FluentMica implements SurfaceTreatment {
  /// Creates the treatment.
  const FluentMica();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) {
    final capabilities = theme.environment?.capabilities;
    final base = elevation < theme.elevation.level2;
    if (base &&
        (capabilities?.windowMaterial ?? false) &&
        !capabilities!.reduceTransparency) {
      return child;
    }
    return const FluentSolid().decorate(
      color: color,
      shape: shape,
      elevation: elevation,
      theme: theme,
      child: child,
    );
  }
}
