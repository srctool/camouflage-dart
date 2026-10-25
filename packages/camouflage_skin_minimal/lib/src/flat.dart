import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Minimal's surfaces: never a shadow. From `level1` a 1 px `outlineVariant` hairline shows depth, and from
/// `level3` a surface fill also steps up one container level.
class Flat implements SurfaceTreatment {
  /// Creates the treatment.
  const Flat();

  static const double _hairline = 1;

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) {
    final level = theme.elevation.levelOf(elevation);
    final fill = level.index >= ElevationLevel.level3.index
        ? _oneLevelUp(theme.colors, color)
        : color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: shape,
        border: level.index >= ElevationLevel.level1.index
            ? Border.all(color: theme.colors.outlineVariant, width: _hairline)
            : null,
      ),
      child: child,
    );
  }

  // The next surface role up; colors that aren't surface roles (a solid button's ink) are unchanged.
  static Color _oneLevelUp(CamoColors c, Color color) {
    final up = <Color, Color>{
      c.surfaceContainerHighest: c.surfaceContainerHighest,
      c.surfaceContainerHigh: c.surfaceContainerHighest,
      c.surfaceContainer: c.surfaceContainerHigh,
      c.surfaceContainerLow: c.surfaceContainer,
      c.surfaceContainerLowest: c.surfaceContainerLow,
      c.surface: c.surfaceContainerLow,
    };
    return up[color] ?? color;
  }
}
