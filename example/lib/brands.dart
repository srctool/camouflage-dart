import 'dart:ui' show lerpDouble;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// A brand's own vocabulary (Theme §3.14): a numbered color scale and two radii. Hand-written here; the `camo`
/// generator writes these from a tokens file. Roles and component themes refer to it, and the example's screen
/// reads it with `theme.tokens<BrandTokens>()`.
@immutable
class BrandTokens extends CamoTokenSet<BrandTokens> {
  /// Creates the tokens.
  const BrandTokens({
    required this.brand,
    required this.controlRadius,
    required this.panelRadius,
  });

  /// The brand scale, `brand[50]` to `brand[900]`.
  final CamoColorScale brand;

  /// Buttons' corners.
  final double controlRadius;

  /// Panels' corners.
  final double panelRadius;

  @override
  BrandTokens lerp(BrandTokens other, double t) => BrandTokens(
    brand: CamoColorScale.lerp(brand, other.brand, t),
    controlRadius: lerpDouble(controlRadius, other.controlRadius, t)!,
    panelRadius: lerpDouble(panelRadius, other.panelRadius, t)!,
  );
}

// Controls rounder than this are drawn as pills; icon buttons become circles.
const double _pillFrom = 8;

/// Two brands designed on top of a skin (ADR-28), plus the skin's own starter theme.
enum Brand {
  /// The skin's own starter theme.
  defaultBrand('Default', null),

  /// Teal, pill-shaped controls.
  ocean(
    'Ocean',
    BrandTokens(
      brand: CamoColorScale({
        50: Color(0xFFE6F6F7),
        100: Color(0xFFC0E9EC),
        200: Color(0xFF8FD8DE),
        300: Color(0xFF57C3CC),
        400: Color(0xFF2AAEBA),
        500: Color(0xFF0B98A6),
        600: Color(0xFF087F8C),
        700: Color(0xFF066570),
        800: Color(0xFF054D55),
        900: Color(0xFF03363C),
      }),
      controlRadius: 22,
      panelRadius: 20,
    ),
  ),

  /// Orange-red, square controls, bold labels.
  ember(
    'Ember',
    BrandTokens(
      brand: CamoColorScale({
        50: Color(0xFFFFF1EC),
        100: Color(0xFFFFDCCF),
        200: Color(0xFFFFB8A0),
        300: Color(0xFFFF8F6B),
        400: Color(0xFFF96A3F),
        500: Color(0xFFE94E21),
        600: Color(0xFFC93D14),
        700: Color(0xFFA12F0F),
        800: Color(0xFF7A240C),
        900: Color(0xFF541908),
      }),
      controlRadius: 2,
      panelRadius: 4,
    ),
    boldLabels: true,
  );

  const Brand(this.label, this.tokens, {this.boldLabels = false});

  /// The switcher's label.
  final String label;

  /// The brand's tokens, or `null` for the skin's own theme.
  final BrandTokens? tokens;

  /// Whether labels are bold.
  final bool boldLabels;

  /// This brand on [base], a skin's starter theme: the primary family and the control shapes come from the
  /// brand's tokens, everything else stays the skin's.
  CamoTheme on(CamoTheme base, Brightness brightness) {
    final t = tokens;
    if (t == null) return base;
    final dark = brightness == Brightness.dark;
    final button = base.components.button ?? const CamoButtonTheme();
    final iconButton =
        base.components.iconButton ?? const CamoIconButtonTheme();
    final label = button.textStyle ?? base.typography.labelLarge;
    return base.copyWith(
      colors: base.colors.copyWith(
        primary: dark ? t.brand[300] : t.brand[600],
        onPrimary: dark ? t.brand[900] : const Color(0xFFFFFFFF),
        primaryContainer: dark ? t.brand[800] : t.brand[100],
        onPrimaryContainer: dark ? t.brand[100] : t.brand[900],
      ),
      components: base.components.copyWith(
        button: button.copyWith(
          shape: BorderRadius.circular(t.controlRadius),
          textStyle: boldLabels
              ? label.copyWith(fontWeight: FontWeight.bold)
              : label,
        ),
        iconButton: iconButton.copyWith(
          shape: BorderRadius.circular(
            t.controlRadius > _pillFrom ? 1000 : t.controlRadius,
          ),
        ),
      ),
      tokenSets: [...base.tokenSets, t],
    );
  }
}
