import 'dart:ui' as ui;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// How Cupertino draws its materials (bars, sheets, menus, popovers, glass controls): see `cupertinoSkinWith`.
enum CupertinoSurface {
  /// Opaque grouped surfaces and blur materials.
  classic,

  /// Liquid Glass (iOS 26): the same materials, lighter, with a specular edge.
  liquidGlass,
}

const double _classicSigma = 20;
const double _glassSigma = 6;
const double _classicTint = 0.8;
const double _glassTint = 0.45;

/// Cupertino's Classic surfaces: opaque fills below `level2`; from `level2` a system blur material, what's painted
/// behind it blurred (20) under the surface color at 80%, with a soft shadow from `level3`. Where the platform
/// can't blur (`CamoCapabilities.backdropBlur`) or with Reduce Transparency the material is the plain surface color,
/// the end of the chain (ADR-42).
class Classic implements SurfaceTreatment {
  /// Creates the treatment.
  const Classic();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) => _material(child, color, shape, elevation, theme, glass: false);
}

/// Cupertino's Liquid Glass: the [Classic] material, lighter, with a specular edge highlight. (The edge refraction
/// of iOS 26's glass needs a fragment shader on the backdrop, which Flutter only has under Impeller: it is the one
/// part not drawn here, so this is the "glass without refraction" step of the chain.)
class LiquidGlass implements SurfaceTreatment {
  /// Creates the treatment.
  const LiquidGlass();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) => _material(child, color, shape, elevation, theme, glass: true);
}

Widget _material(
  Widget child,
  Color color,
  BorderRadius shape,
  double elevation,
  CamoTheme theme, {
  required bool glass,
}) {
  final level = theme.elevation.levelOf(elevation).index;
  final capabilities = theme.environment?.capabilities;
  final opaque =
      level < ElevationLevel.level2.index ||
      (capabilities?.reduceTransparency ?? false) ||
      !(capabilities?.backdropBlur ?? true);
  if (opaque) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: shape),
      child: child,
    );
  }
  // Glass is always lifted: over a light page its tint matches the page, so the shadow and the rim show it.
  final shadow = glass && level < ElevationLevel.level3.index
      ? const BoxShadow(
          color: Color(0x29000000),
          blurRadius: 5,
          offset: Offset(0, 1),
        )
      : level >= ElevationLevel.level4.index
      ? const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        )
      : level >= ElevationLevel.level3.index
      ? const BoxShadow(
          color: Color(0x29000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        )
      : null;
  final sigma = glass ? _glassSigma : _classicSigma;
  final tint = color.withValues(
    alpha: color.a * (glass ? _glassTint : _classicTint),
  );
  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: shape,
      boxShadow: shadow == null ? null : [shadow],
    ),
    child: ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: CustomPaint(
          foregroundPainter: glass ? _Specular(shape) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(color: tint),
            child: child,
          ),
        ),
      ),
    ),
  );
}

// The edge of the glass: a faint dark rim all round (what shows it on a light page, where the white highlight and the
// tint vanish), then the lit edge, bright where the light hits (top start), fading across, a faint rim opposite.
class _Specular extends CustomPainter {
  _Specular(this.shape);

  final BorderRadius shape;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final edge = ui.Gradient.linear(
      Offset.zero,
      size.bottomRight(Offset.zero),
      [
        const Color(0xB3FFFFFF),
        const Color(0x14FFFFFF),
        const Color(0x14FFFFFF),
        const Color(0x59FFFFFF),
      ],
      [0, 0.45, 0.55, 1],
    );
    canvas.drawRRect(
      shape.toRRect(rect),
      Paint()
        ..color = const Color(0x1F000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      shape.toRRect(rect),
      Paint()
        ..shader = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_Specular old) => old.shape != shape;
}
