import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_tokens.dart';

/// Fluent's default surface: the fill plus Fluent's two-layer shadow (an ambient glow and a key shadow below).
/// `level0` and `level1` are flat; `level2` is shadow4 (cards), `level3` shadow8, `level4` shadow16 (flyouts),
/// `level5` shadow64 (dialogs). Shadow colors come from [FluentTokens], or default black alphas without them.
class FluentSolid implements SurfaceTreatment {
  /// Creates the treatment.
  const FluentSolid();

  // utils/shadows: shadowN = "0 0 <ambient>px ambient, 0 <N/2>px <N>px key" (ambient blur, key offset, key blur).
  static const _ramp = {
    ElevationLevel.level2: (2.0, 2.0, 4.0),
    ElevationLevel.level3: (2.0, 4.0, 8.0),
    ElevationLevel.level4: (2.0, 8.0, 16.0),
    ElevationLevel.level5: (8.0, 32.0, 64.0),
  };

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) {
    final layers = _ramp[theme.elevation.levelOf(elevation)];
    final tokens = theme.tokens<FluentTokens>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: shape,
        boxShadow: layers == null
            ? null
            : [
                // CSS blur radius ≈ 2 σ; Flutter's blurRadius is the CSS value.
                BoxShadow(
                  color: tokens?.shadowAmbient ?? const Color(0x1F000000),
                  blurRadius: layers.$1,
                ),
                BoxShadow(
                  color: tokens?.shadowKey ?? const Color(0x24000000),
                  offset: Offset(0, layers.$2),
                  blurRadius: layers.$3,
                ),
              ],
      ),
      child: child,
    );
  }
}
