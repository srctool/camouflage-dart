import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Carbon's four themes: [white] and [g10] are light, [g90] and [g100] dark.
enum CarbonThemeFamily {
  /// The light default.
  white,

  /// A light theme with a gray background.
  g10,

  /// A dark theme with a gray 90 background.
  g90,

  /// The dark default, on gray 100.
  g100,
}

const Color _blue60 = Color(0xFF0F62FE);
const Color _blue50 = Color(0xFF4589FF);

/// Carbon's gray 100: the UI shell header in every family.
const Color carbonGray100 = Color(0xFF161616);

/// Carbon's gray 10: text on the dark header.
const Color carbonGray10 = Color(0xFFF4F4F4);

/// The Carbon starter theme for a [family] (base Carbon Skin §3): `background` is `surface`, `layer-01` to
/// `layer-03` the containers, `text-primary` and `text-secondary` `onSurface` and `onSurfaceVariant`,
/// `border-strong` and `border-subtle` `outline` and `outlineVariant`, `interactive` the `primary` (blue 60, blue
/// 50 in the dark families, or the brand [accent]), and the support colors the status families. Square shapes,
/// productive motion and the IBM Plex type set in [fontFamily] (`null`: the platform font; skins never bundle
/// fonts, ADR-33).
CamoTheme carbonTheme({
  CarbonThemeFamily family = CarbonThemeFamily.white,
  Color? accent,
  String? fontFamily,
}) {
  final dark =
      family == CarbonThemeFamily.g90 || family == CarbonThemeFamily.g100;
  final base = switch (family) {
    CarbonThemeFamily.white => _light(
      background: const Color(0xFFFFFFFF),
      l1: carbonGray10,
      l2: const Color(0xFFFFFFFF),
      l3: carbonGray10,
      subtle: const Color(0xFFC6C6C6),
    ),
    CarbonThemeFamily.g10 => _light(
      background: carbonGray10,
      l1: const Color(0xFFFFFFFF),
      l2: carbonGray10,
      l3: const Color(0xFFFFFFFF),
      subtle: const Color(0xFFE0E0E0),
    ),
    CarbonThemeFamily.g90 => _dark(
      background: const Color(0xFF262626),
      l1: const Color(0xFF393939),
      l2: const Color(0xFF525252),
      l3: const Color(0xFF6F6F6F),
      subtle: const Color(0xFF525252),
      highest: const Color(0xFF6F6F6F),
    ),
    CarbonThemeFamily.g100 => _dark(
      background: carbonGray100,
      l1: const Color(0xFF262626),
      l2: const Color(0xFF393939),
      l3: const Color(0xFF525252),
      subtle: const Color(0xFF393939),
      highest: const Color(0xFF525252),
    ),
  };
  return CamoTheme(
    colors: _withAccent(base, accent, dark),
    typography: _typography(fontFamily),
    shapes: _shapes,
    motion: _motion,
  );
}

/// [carbonTheme] in the White family.
final CamoTheme carbonLight = carbonTheme();

/// [carbonTheme] in the G100 family.
final CamoTheme carbonDark = carbonTheme(family: CarbonThemeFamily.g100);

// Square everything; `full` is for toggles and tags, the only rounded elements.
const CamoShapes _shapes = CamoShapes(
  none: BorderRadius.zero,
  extraSmall: BorderRadius.zero,
  small: BorderRadius.zero,
  medium: BorderRadius.zero,
  large: BorderRadius.zero,
  extraLarge: BorderRadius.zero,
);

// Carbon's productive motion: fast-02 110 ms, moderate-01 150 ms, moderate-02 240 ms; the standard productive
// curve, and the expressive one for entrances.
const CamoMotion _motion = CamoMotion(
  durationShort: Duration(milliseconds: 110),
  durationMedium: Duration(milliseconds: 150),
  durationLong: Duration(milliseconds: 240),
  easingStandard: Cubic(0.2, 0, 0.38, 0.9),
  easingEmphasized: Cubic(0.4, 0.14, 0.3, 1),
);

// A brand accent takes only the `primary` family; every other token stays Carbon's.
CamoColors _withAccent(CamoColors base, Color? accent, bool dark) {
  if (accent == null) return base;
  final seeded = CamoColors.fromSeed(
    primary: accent,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  return base.copyWith(
    primary: seeded.primary,
    onPrimary: seeded.onPrimary,
    primaryContainer: seeded.primaryContainer,
    onPrimaryContainer: seeded.onPrimaryContainer,
    inversePrimary: seeded.inversePrimary,
  );
}

CamoColors _light({
  required Color background,
  required Color l1,
  required Color l2,
  required Color l3,
  required Color subtle,
}) => CamoColors.fromSeed(primary: _blue60, brightness: Brightness.light)
    .copyWith(
      primary: _blue60,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFD0E2FF),
      onPrimaryContainer: const Color(0xFF001D6C),
      secondary: const Color(0xFF393939), // the secondary button
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFE0E0E0),
      onSecondaryContainer: carbonGray100,
      tertiary: const Color(0xFF8A3FFC),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFF6F2FF),
      onTertiaryContainer: const Color(0xFF491D8B),
      surface: background,
      surfaceContainerLowest: background,
      surfaceContainerLow: l1,
      surfaceContainer: l2,
      surfaceContainerHigh: l3,
      surfaceContainerHighest: const Color(0xFFE0E0E0),
      onSurface: carbonGray100,
      onSurfaceVariant: const Color(0xFF525252),
      outline: const Color(0xFF8D8D8D),
      outlineVariant: subtle,
      error: const Color(0xFFDA1E28),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFF1F1),
      onErrorContainer: const Color(0xFFA2191F),
      success: const Color(0xFF198038),
      onSuccess: const Color(0xFFFFFFFF),
      successContainer: const Color(0xFFDEFBE6),
      onSuccessContainer: const Color(0xFF0E6027),
      warning: const Color(0xFFF1C21B),
      onWarning: carbonGray100,
      warningContainer: const Color(0xFFFCF4D6),
      onWarningContainer: const Color(0xFF5E4800),
      info: const Color(0xFF0043CE),
      onInfo: const Color(0xFFFFFFFF),
      infoContainer: const Color(0xFFEDF5FF),
      onInfoContainer: const Color(0xFF002D9C),
      inverseSurface: const Color(0xFF393939),
      inverseOnSurface: carbonGray10,
      inversePrimary: _blue50,
      scrim: carbonGray100,
    );

CamoColors _dark({
  required Color background,
  required Color l1,
  required Color l2,
  required Color l3,
  required Color subtle,
  required Color highest,
}) =>
    CamoColors.fromSeed(primary: _blue50, brightness: Brightness.dark).copyWith(
      primary: _blue50,
      onPrimary: carbonGray100,
      primaryContainer: const Color(0xFF001D6C),
      onPrimaryContainer: const Color(0xFFA6C8FF),
      secondary: const Color(0xFF6F6F6F),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFF393939),
      onSecondaryContainer: carbonGray10,
      tertiary: const Color(0xFFA56EFF),
      onTertiary: carbonGray100,
      tertiaryContainer: const Color(0xFF31135E),
      onTertiaryContainer: const Color(0xFFD4BBFF),
      surface: background,
      surfaceContainerLowest: background,
      surfaceContainerLow: l1,
      surfaceContainer: l2,
      surfaceContainerHigh: l3,
      surfaceContainerHighest: highest,
      onSurface: carbonGray10,
      onSurfaceVariant: const Color(0xFFC6C6C6),
      outline: const Color(0xFF8D8D8D),
      outlineVariant: subtle,
      error: const Color(0xFFFA4D56),
      onError: carbonGray100,
      errorContainer: const Color(0xFF520408),
      onErrorContainer: const Color(0xFFFFB3B8),
      success: const Color(0xFF42BE65),
      onSuccess: carbonGray100,
      successContainer: const Color(0xFF022D0D),
      onSuccessContainer: const Color(0xFFA7F0BA),
      warning: const Color(0xFFF1C21B),
      onWarning: carbonGray100,
      warningContainer: const Color(0xFF302400),
      onWarningContainer: const Color(0xFFF1C21B),
      info: const Color(0xFF78A9FF),
      onInfo: carbonGray100,
      infoContainer: const Color(0xFF001141),
      onInfoContainer: const Color(0xFFA6C8FF),
      inverseSurface: carbonGray10,
      inverseOnSurface: carbonGray100,
      inversePrimary: _blue60,
      scrim: const Color(0xFF000000),
    );

// IBM Plex Sans in Carbon's type sets: size / line height, weight and the tracking at that size.
CamoTypography _typography(String? family) {
  TextStyle style(
    double size,
    double line,
    int weight, [
    double tracking = 0,
  ]) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: line / size,
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    letterSpacing: tracking,
  );
  return CamoTypography(
    displayLarge: style(54, 60, 300), // heading-07
    displayMedium: style(42, 50, 300), // heading-06
    displaySmall: style(32, 40, 400), // heading-05
    headlineLarge: style(28, 36, 400), // heading-04
    headlineMedium: style(20, 28, 400), // heading-03
    headlineSmall: style(16, 24, 600), // heading-02
    titleLarge: style(20, 28, 400), // heading-03
    titleMedium: style(16, 22, 600, 0.16), // heading-compact-02
    titleSmall: style(14, 18, 600, 0.16), // heading-compact-01
    bodyLarge: style(16, 24, 400), // body-02
    bodyMedium: style(14, 18, 400, 0.16), // body-compact-01
    bodySmall: style(12, 16, 400, 0.32), // helper-text-01
    labelLarge: style(14, 18, 400, 0.16), // the button text
    labelMedium: style(12, 16, 400, 0.32), // label-01
    labelSmall: style(12, 16, 400, 0.32),
  );
}
