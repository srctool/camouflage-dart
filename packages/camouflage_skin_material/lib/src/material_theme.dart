import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// The seed of Material 3's baseline scheme (`#6750A4`).
const Color materialBaselineSeed = Color(0xFF6750A4);

/// Material 3's starter theme: the baseline scheme when [seed] is `null`, else M3's tonal-spot colors from
/// [seed]; M3's shapes (4, 8, 12, 16, 28), motion (150, 300, 500 ms) and type scale. [fontFamily] `null` is the
/// platform font: skins never bundle fonts, so pass Roboto for the authentic look.
CamoTheme materialTheme({
  Color? seed,
  Brightness brightness = Brightness.light,
  String? fontFamily,
}) => CamoTheme(
  colors: seed == null
      ? _baselineColors(brightness)
      : materialColors(seed, brightness: brightness),
  typography: _materialTypography(fontFamily),
  shapes: _shapes,
  motion: _motion,
);

/// M3 "tonal spot" colors from [seed]: `fromSeed(primary: seed, neutral: seed)`, so the surfaces carry the seed's
/// hue (surface 98, containers 100 to 90 in light). Status families are Camouflage's.
CamoColors materialColors(
  Color seed, {
  Brightness brightness = Brightness.light,
}) => CamoColors.fromSeed(primary: seed, neutral: seed, brightness: brightness);

/// [materialTheme] with the M3 baseline scheme, light.
final CamoTheme materialBaselineLight = materialTheme();

/// [materialTheme] with the M3 baseline scheme, dark.
final CamoTheme materialBaselineDark = materialTheme(
  brightness: Brightness.dark,
);

// M3 shape scale: extra small 4, small 8, medium 12, large 16, extra large 28, full.
const CamoShapes _shapes = CamoShapes(
  extraSmall: BorderRadius.all(Radius.circular(4)),
  small: BorderRadius.all(Radius.circular(8)),
  medium: BorderRadius.all(Radius.circular(12)),
  large: BorderRadius.all(Radius.circular(16)),
  extraLarge: BorderRadius.all(Radius.circular(28)),
);

// M3 durations (short 150 / medium 300 / long 500) and easings (standard, emphasized decelerate).
const CamoMotion _motion = CamoMotion(
  durationShort: Duration(milliseconds: 150),
  durationMedium: Duration(milliseconds: 300),
  durationLong: Duration(milliseconds: 500),
  easingStandard: Cubic(0.2, 0, 0, 1),
  easingEmphasized: Cubic(0.05, 0.7, 0.1, 1),
);

// The M3 baseline roles (m3.material.io, seed #6750A4). The status families aren't M3's: they come from the
// default status seeds, written out here once; the baseline test fails if a color-library update would change them.
CamoColors _baselineColors(Brightness brightness) {
  final seeded = materialColors(materialBaselineSeed, brightness: brightness);
  if (brightness == Brightness.dark) {
    return seeded.copyWith(
      primary: const Color(0xFFD0BCFF),
      onPrimary: const Color(0xFF381E72),
      primaryContainer: const Color(0xFF4F378B),
      onPrimaryContainer: const Color(0xFFEADDFF),
      secondary: const Color(0xFFCCC2DC),
      onSecondary: const Color(0xFF332D41),
      secondaryContainer: const Color(0xFF4A4458),
      onSecondaryContainer: const Color(0xFFE8DEF8),
      tertiary: const Color(0xFFEFB8C8),
      onTertiary: const Color(0xFF492532),
      tertiaryContainer: const Color(0xFF633B48),
      onTertiaryContainer: const Color(0xFFFFD8E4),
      surface: const Color(0xFF141218),
      surfaceContainerLowest: const Color(0xFF0F0D13),
      surfaceContainerLow: const Color(0xFF1D1B20),
      surfaceContainer: const Color(0xFF211F26),
      surfaceContainerHigh: const Color(0xFF2B2930),
      surfaceContainerHighest: const Color(0xFF36343B),
      onSurface: const Color(0xFFE6E0E9),
      onSurfaceVariant: const Color(0xFFCAC4D0),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      inverseSurface: const Color(0xFFE6E0E9),
      inverseOnSurface: const Color(0xFF322F35),
      inversePrimary: const Color(0xFF6750A4),
      scrim: const Color(0xFF000000),
      success: const Color(0xFF88D982),
      onSuccess: const Color(0xFF003909),
      successContainer: const Color(0xFF005312),
      onSuccessContainer: const Color(0xFFA3F69C),
      warning: const Color(0xFFFFB957),
      onWarning: const Color(0xFF462B00),
      warningContainer: const Color(0xFF643F00),
      onWarningContainer: const Color(0xFFFFDDB5),
      info: const Color(0xFF96CCFF),
      onInfo: const Color(0xFF003353),
      infoContainer: const Color(0xFF004A75),
      onInfoContainer: const Color(0xFFCEE5FF),
    );
  }
  return seeded.copyWith(
    primary: const Color(0xFF6750A4),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFEADDFF),
    onPrimaryContainer: const Color(0xFF21005D),
    secondary: const Color(0xFF625B71),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFE8DEF8),
    onSecondaryContainer: const Color(0xFF1D192B),
    tertiary: const Color(0xFF7D5260),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFFFD8E4),
    onTertiaryContainer: const Color(0xFF31111D),
    surface: const Color(0xFFFEF7FF),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF7F2FA),
    surfaceContainer: const Color(0xFFF3EDF7),
    surfaceContainerHigh: const Color(0xFFECE6F0),
    surfaceContainerHighest: const Color(0xFFE6E0E9),
    onSurface: const Color(0xFF1D1B20),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: const Color(0xFFCAC4D0),
    error: const Color(0xFFB3261E),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFF9DEDC),
    onErrorContainer: const Color(0xFF410E0B),
    inverseSurface: const Color(0xFF322F35),
    inverseOnSurface: const Color(0xFFF5EFF7),
    inversePrimary: const Color(0xFFD0BCFF),
    scrim: const Color(0xFF000000),
    success: const Color(0xFF1B6D24),
    onSuccess: const Color(0xFFFFFFFF),
    successContainer: const Color(0xFFA3F69C),
    onSuccessContainer: const Color(0xFF002204),
    warning: const Color(0xFF835400),
    onWarning: const Color(0xFFFFFFFF),
    warningContainer: const Color(0xFFFFDDB5),
    onWarningContainer: const Color(0xFF2A1800),
    info: const Color(0xFF00639A),
    onInfo: const Color(0xFFFFFFFF),
    infoContainer: const Color(0xFFCEE5FF),
    onInfoContainer: const Color(0xFF001D32),
  );
}

// The M3 baseline type scale (size / line height, weight, tracking).
CamoTypography _materialTypography(String? family) {
  TextStyle style(double size, double line, int weight, double tracking) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: line / size,
        fontWeight: FontWeight.values[weight ~/ 100 - 1],
        letterSpacing: tracking,
      );
  return CamoTypography(
    displayLarge: style(57, 64, 400, -0.25),
    displayMedium: style(45, 52, 400, 0),
    displaySmall: style(36, 44, 400, 0),
    headlineLarge: style(32, 40, 400, 0),
    headlineMedium: style(28, 36, 400, 0),
    headlineSmall: style(24, 32, 400, 0),
    titleLarge: style(22, 28, 400, 0),
    titleMedium: style(16, 24, 500, 0.15),
    titleSmall: style(14, 20, 500, 0.1),
    bodyLarge: style(16, 24, 400, 0.5),
    bodyMedium: style(14, 20, 400, 0.25),
    bodySmall: style(12, 16, 400, 0.4),
    labelLarge: style(14, 20, 500, 0.1),
    labelMedium: style(12, 16, 500, 0.5),
    labelSmall: style(11, 16, 500, 0.5),
  );
}
