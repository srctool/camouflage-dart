import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_palette.dart';
import 'fluent_tokens.dart';

/// Fluent's control sizes: `small` 24 and `medium` 32 for desktop (pointer), `touch` 40.
enum FluentDensity {
  /// 24 tall controls.
  small,

  /// 32 tall controls (Fluent's default).
  medium,

  /// 40 tall controls, for touch.
  touch,
}

/// Fluent 2's starter theme: the brand ramp for the `primary` family, Fluent's neutral ramp for surfaces and
/// text, the danger, success and warning palettes for status (info is the brand), Fluent's type ramp, radii and
/// motion, plus [FluentTokens] for the hover and press steps. [density] sets the controls' sizes through the
/// component themes. [fontFamily] `null` is the platform font (Segoe UI on Windows); fonts are never bundled.
CamoTheme fluentTheme({
  Color brand = fluentBrandBlue,
  Brightness brightness = Brightness.light,
  FluentDensity density = FluentDensity.medium,
  String? fontFamily,
}) {
  final ramp = BrandRamp.of(brand);
  final dark = brightness == Brightness.dark;
  final typography = _typography(fontFamily);
  return CamoTheme(
    colors: dark ? _dark(ramp) : _light(ramp),
    typography: typography,
    components: _density(density, typography),
    shapes: _shapes,
    motion: _motion,
    tokenSets: [dark ? _darkTokens(ramp) : _lightTokens(ramp)],
  );
}

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);

// Fluent's colorNeutral*/colorBrand* aliases (alias/lightColor) mapped to core's roles.
CamoColors _light(BrandRamp b) => CamoColors(
  primary: b[80],
  onPrimary: _white,
  primaryContainer: b[160],
  onPrimaryContainer: b[70],
  secondary: grey(38),
  onSecondary: _white,
  secondaryContainer: grey(94),
  onSecondaryContainer: grey(14),
  tertiary: b[60],
  onTertiary: _white,
  tertiaryContainer: b[150],
  onTertiaryContainer: b[40],
  surface: _white,
  surfaceContainerLowest: _white,
  surfaceContainerLow: grey(98),
  surfaceContainer: grey(96),
  surfaceContainerHigh: grey(94),
  surfaceContainerHighest: grey(92),
  onSurface: grey(14),
  onSurfaceVariant: grey(26),
  outline: grey(38),
  outlineVariant: grey(82),
  error: cranberry.primary,
  onError: _white,
  errorContainer: cranberry.tint60,
  onErrorContainer: cranberry.foreground,
  success: green.primary,
  onSuccess: _white,
  successContainer: green.tint60,
  onSuccessContainer: green.foreground,
  warning: orange.primary,
  onWarning: grey(14),
  warningContainer: orange.tint60,
  onWarningContainer: orange.foreground,
  info: b[80],
  onInfo: _white,
  infoContainer: b[160],
  onInfoContainer: b[70],
  inverseSurface: grey(16),
  inverseOnSurface: _white,
  inversePrimary: b[100],
  scrim: _black,
);

// alias/darkColor. `primary` is the brand foreground (readable as text on dark surfaces); the filled brand
// background is darker and lives in FluentTokens.brandBackground.
CamoColors _dark(BrandRamp b) => CamoColors(
  primary: b[100],
  onPrimary: _black,
  primaryContainer: b[20],
  onPrimaryContainer: b[110],
  secondary: grey(68),
  onSecondary: grey(14),
  secondaryContainer: grey(24),
  onSecondaryContainer: _white,
  tertiary: b[120],
  onTertiary: b[20],
  tertiaryContainer: b[40],
  onTertiaryContainer: b[150],
  surface: grey(16),
  surfaceContainerLowest: grey(12),
  surfaceContainerLow: grey(20),
  surfaceContainer: grey(22),
  surfaceContainerHigh: grey(24),
  surfaceContainerHighest: grey(28),
  onSurface: _white,
  onSurfaceVariant: grey(84),
  outline: grey(68),
  outlineVariant: grey(40),
  error: cranberry.tint30,
  onError: _black,
  errorContainer: cranberry.shade40,
  onErrorContainer: cranberry.tint30,
  success: green.tint30,
  onSuccess: _black,
  successContainer: green.shade40,
  onSuccessContainer: green.tint40,
  warning: orange.tint30,
  onWarning: _black,
  warningContainer: orange.shade40,
  onWarningContainer: orange.tint30,
  info: b[100],
  onInfo: _black,
  infoContainer: b[30],
  onInfoContainer: b[130],
  inverseSurface: _white,
  inverseOnSurface: grey(14),
  inversePrimary: b[80],
  scrim: _black,
);

FluentTokens _lightTokens(BrandRamp b) => FluentTokens(
  brandBackground: b[80],
  brandBackgroundHover: b[70],
  brandBackgroundPressed: b[40],
  neutralForegroundOnBrand: _white,
  neutralBackground1Hover: grey(96),
  neutralBackground1Pressed: grey(88),
  subtleBackgroundHover: grey(96),
  subtleBackgroundPressed: grey(88),
  neutralForeground2Hover: grey(14),
  neutralStroke1: grey(82),
  neutralStroke1Hover: grey(78),
  neutralStroke1Pressed: grey(70),
  neutralStroke2: grey(88),
  brandForegroundLinkHover: b[60],
  brandForegroundLinkPressed: b[40],
  strokeFocus1: _white,
  strokeFocus2: _black,
  shadowAmbient: const Color(0x1F000000),
  shadowKey: const Color(0x24000000),
);

FluentTokens _darkTokens(BrandRamp b) => FluentTokens(
  brandBackground: b[70],
  brandBackgroundHover: b[80],
  brandBackgroundPressed: b[40],
  neutralForegroundOnBrand: _white,
  neutralBackground1Hover: grey(24),
  neutralBackground1Pressed: grey(12),
  subtleBackgroundHover: grey(22),
  subtleBackgroundPressed: grey(18),
  neutralForeground2Hover: _white,
  neutralStroke1: grey(40),
  neutralStroke1Hover: grey(46),
  neutralStroke1Pressed: grey(42),
  neutralStroke2: grey(32),
  brandForegroundLinkHover: b[110],
  brandForegroundLinkPressed: b[90],
  strokeFocus1: _black,
  strokeFocus2: _white,
  shadowAmbient: const Color(0x3D000000),
  shadowKey: const Color(0x47000000),
);

// Fluent's type ramp (global/fonts): caption2 10/14, caption1 12/16, body1 14/20, body2 and subtitle2 16/22,
// subtitle1 20/28, title3 24/32, title2 28/36, title1 32/40, largeTitle 40/52, display 68/92.
CamoTypography _typography(String? family) {
  TextStyle s(double size, double line, FontWeight weight) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: line / size,
    fontWeight: weight,
  );
  const semibold = FontWeight.w600;
  const regular = FontWeight.w400;
  return CamoTypography(
    displayLarge: s(68, 92, semibold),
    displayMedium: s(40, 52, semibold),
    displaySmall: s(32, 40, semibold),
    headlineLarge: s(28, 36, semibold),
    headlineMedium: s(24, 32, semibold),
    headlineSmall: s(20, 28, semibold),
    titleLarge: s(20, 28, semibold),
    titleMedium: s(16, 22, semibold),
    titleSmall: s(14, 20, semibold),
    bodyLarge: s(16, 22, regular),
    bodyMedium: s(14, 20, regular),
    bodySmall: s(12, 16, regular),
    labelLarge: s(14, 20, semibold),
    labelMedium: s(12, 16, semibold),
    labelSmall: s(10, 14, regular),
  );
}

// global/borderRadius: small 2, medium 4, large 6, xLarge 8, 2xLarge 12, circular.
const _shapes = CamoShapes(
  extraSmall: BorderRadius.all(Radius.circular(2)),
  small: BorderRadius.all(Radius.circular(4)),
  medium: BorderRadius.all(Radius.circular(6)),
  large: BorderRadius.all(Radius.circular(8)),
  extraLarge: BorderRadius.all(Radius.circular(12)),
);

// global/durations (faster 100, normal 200, slow 300) and curves (easyEase, decelerateMid).
const _motion = CamoMotion(
  durationShort: Duration(milliseconds: 100),
  durationMedium: Duration(milliseconds: 200),
  durationLong: Duration(milliseconds: 300),
  easingStandard: Cubic(0.33, 0, 0.67, 1),
  easingEmphasized: Cubic(0.1, 0.9, 0.2, 1),
);

// Fluent Button's sizes: small 24 (caption1, padding 8), medium 32 (body1Strong, padding 12), large 40
// (subtitle2, padding 16); icon-only buttons are square at the same heights.
CamoComponentThemes _density(FluentDensity density, CamoTypography type) {
  final (height, minWidth, padding, iconSize, text) = switch (density) {
    FluentDensity.small => (24.0, 64.0, 8.0, 16.0, type.bodySmall),
    FluentDensity.medium => (32.0, 96.0, 12.0, 20.0, type.labelLarge),
    FluentDensity.touch => (40.0, 96.0, 16.0, 24.0, type.titleMedium),
  };
  return CamoComponentThemes(
    button: CamoButtonTheme(
      height: height,
      minWidth: minWidth,
      padding: EdgeInsetsDirectional.symmetric(horizontal: padding),
      paddingWithIcon: EdgeInsetsDirectional.symmetric(horizontal: padding),
      textStyle: text,
      iconSize: iconSize,
    ),
    iconButton: CamoIconButtonTheme(containerSize: height, iconSize: iconSize),
  );
}
