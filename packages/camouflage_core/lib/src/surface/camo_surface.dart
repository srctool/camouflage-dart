import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_colors.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// Overrides for surfaces' borders; `null` keeps the skin's default.
@immutable
class CamoSurfaceTheme {
  /// Creates surface overrides.
  const CamoSurfaceTheme({this.borderWidth, this.borderColor});

  /// The outline's width when `border` is on.
  final double? borderWidth;

  /// The outline's color.
  final Color? borderColor;

  /// A copy with the given fields replaced.
  CamoSurfaceTheme copyWith({double? borderWidth, Color? borderColor}) =>
      CamoSurfaceTheme(
        borderWidth: borderWidth ?? this.borderWidth,
        borderColor: borderColor ?? this.borderColor,
      );

  @override
  bool operator ==(Object other) =>
      other is CamoSurfaceTheme &&
      other.borderWidth == borderWidth &&
      other.borderColor == borderColor;

  @override
  int get hashCode => Object.hash(borderWidth, borderColor);
}

/// The resolved surface style: every field set.
@immutable
class CamoSurfaceStyle {
  /// Creates a surface style.
  const CamoSurfaceStyle({
    required this.borderWidth,
    required this.borderColor,
  });

  /// The outline's width.
  final double borderWidth;

  /// The outline's color.
  final Color borderColor;

  /// This style with [o]'s non-null fields applied.
  CamoSurfaceStyle merge(CamoSurfaceTheme? o) => o == null
      ? this
      : CamoSurfaceStyle(
          borderWidth: o.borderWidth ?? borderWidth,
          borderColor: o.borderColor ?? borderColor,
        );
}

/// What a surface renderer draws.
@immutable
class SurfaceState {
  /// Creates a surface state.
  const SurfaceState({
    required this.level,
    required this.shape,
    required this.elevation,
    required this.border,
  });

  /// Which surface role to paint.
  final SurfaceLevel level;

  /// The corner radius role.
  final ShapeRole shape;

  /// The semantic depth.
  final ElevationLevel elevation;

  /// Whether to draw the outline.
  final bool border;
}

/// The surface's content.
@immutable
class SurfaceSlots {
  /// Creates the slots.
  const SurfaceSlots({required this.child});

  /// The content.
  final Widget child;
}

/// Draws a container: a surface role, a shape and a depth, through the skin's surface treatment.
abstract interface class CamoSurfaceRenderer {
  /// The complete surface style for [theme].
  CamoSurfaceStyle defaults(CamoTheme theme);

  /// Draws [state] around [slots].
  Widget render(
    BuildContext context,
    SurfaceState state,
    SurfaceSlots slots,
    CamoTheme theme,
    CamoSurfaceStyle style,
  );
}

/// The color of each surface level.
extension CamoSurfaceColors on CamoColors {
  /// The color of [level].
  Color surfaceOf(SurfaceLevel level) => switch (level) {
    SurfaceLevel.surface => surface,
    SurfaceLevel.lowest => surfaceContainerLowest,
    SurfaceLevel.low => surfaceContainerLow,
    SurfaceLevel.container => surfaceContainer,
    SurfaceLevel.high => surfaceContainerHigh,
    SurfaceLevel.highest => surfaceContainerHighest,
  };
}

/// A neutral container: one of the six surface levels, clipped to a shape, at a semantic depth. It sets
/// `onSurface` as the content color for what's inside. Not interactive.
class CamoSurface extends StatelessWidget {
  /// Creates a surface around [child].
  const CamoSurface({
    super.key,
    this.level = SurfaceLevel.surface,
    this.shape = ShapeRole.none,
    this.elevation = ElevationLevel.level0,
    this.border = false,
    required this.child,
  });

  /// Which surface role to paint.
  final SurfaceLevel level;

  /// The corner radius role.
  final ShapeRole shape;

  /// The semantic depth.
  final ElevationLevel elevation;

  /// Whether to draw a hairline outline (panels).
  final bool border;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSurface');
    final theme = Camouflage.themeOf(context, component: 'CamoSurface');
    final style = skin.surface.defaults(theme).merge(theme.components.surface);
    return skin.surface.render(
      context,
      SurfaceState(
        level: level,
        shape: shape,
        elevation: elevation,
        border: border,
      ),
      SurfaceSlots(child: child),
      theme,
      style,
    );
  }
}
