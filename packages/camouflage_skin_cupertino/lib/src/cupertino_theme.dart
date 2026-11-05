import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Apple's `systemBlue` (light): the default accent. The dark appearance's is `0xFF0A84FF`.
const Color systemBlue = Color(0xFF007AFF);

const Color _systemBlueDark = Color(0xFF0A84FF);

/// The Cupertino starter theme: Apple's system colors from the HIG tables, mapped to roles (base Cupertino Skin §3):
/// `primary` is the [accent] (systemBlue by default, and its dark variant in the dark appearance unless the accent
/// is custom), `error` systemRed, `success` systemGreen, `warning` systemOrange, `info` systemTeal; `surface` is
/// the grouped background, the containers step through the system backgrounds and fills. The type scale is SF's
/// text styles, set in [fontFamily] (`null`: the platform font; skins never bundle fonts, ADR-33), the shapes
/// iOS's radii, the motion its 0.35 s springs.
CamoTheme cupertinoTheme({
  Color accent = systemBlue,
  Brightness brightness = Brightness.light,
  String? fontFamily,
}) => CamoTheme(
  colors: _colors(accent, brightness),
  typography: _typography(fontFamily),
  shapes: _shapes,
  motion: _motion,
);

/// [cupertinoTheme] with systemBlue, light.
final CamoTheme cupertinoLight = cupertinoTheme();

/// [cupertinoTheme] with systemBlue, dark.
final CamoTheme cupertinoDark = cupertinoTheme(brightness: Brightness.dark);

// Continuous-corner radii of iOS controls and groups: 6, 8, 12 (grouped sections), 14 (alerts), 26 (sheets).
const CamoShapes _shapes = CamoShapes(
  extraSmall: BorderRadius.all(Radius.circular(6)),
  small: BorderRadius.all(Radius.circular(8)),
  medium: BorderRadius.all(Radius.circular(12)),
  large: BorderRadius.all(Radius.circular(14)),
  extraLarge: BorderRadius.all(Radius.circular(26)),
);

// iOS animations are springs of about 0.35 s; the durations are those, the easings the ease curves it settles on.
const CamoMotion _motion = CamoMotion(
  durationShort: Duration(milliseconds: 200),
  durationMedium: Duration(milliseconds: 350),
  durationLong: Duration(milliseconds: 500),
  easingStandard: Cubic(0.25, 0.1, 0.25, 1),
  easingEmphasized: Cubic(0.2, 0.9, 0.1, 1),
);

// The system colors and the HIG backgrounds, written out (developer.apple.com/design/human-interface-guidelines/
// color). The theme test pins them.
CamoColors _colors(Color accent, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final blue = dark && accent == systemBlue ? _systemBlueDark : accent;
  return dark ? _dark(blue) : _light(blue);
}

Color _over(Color color, double alpha, Color background) =>
    Color.alphaBlend(color.withValues(alpha: alpha), background);

CamoColors _light(Color blue) {
  const surface = Color(0xFFF2F2F7); // systemGroupedBackground
  return CamoColors.fromSeed(
    primary: blue,
    brightness: Brightness.light,
  ).copyWith(
    primary: blue,
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: _over(blue, 0.15, const Color(0xFFFFFFFF)),
    onPrimaryContainer: blue,
    secondary: const Color(0xFF8E8E93), // systemGray
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFE5E5EA), // systemGray5
    onSecondaryContainer: const Color(0xFF000000),
    tertiary: const Color(0xFF5856D6), // systemIndigo
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFE0E0F8),
    onTertiaryContainer: const Color(0xFF5856D6),
    surface: surface,
    surfaceContainerLowest: const Color(0xFFFFFFFF), // systemBackground
    surfaceContainerLow: const Color(
      0xFFFFFFFF,
    ), // secondarySystemGroupedBackground
    surfaceContainer: surface, // secondarySystemBackground
    surfaceContainerHigh: const Color(0xFFE5E5EA), // systemGray5
    surfaceContainerHighest: const Color(0xFFD1D1D6), // systemGray4
    onSurface: const Color(0xFF000000),
    onSurfaceVariant: const Color(0xFF8A8A8E), // label, secondaryLabel
    outline: const Color(0xFFC7C7CC), // systemGray3
    outlineVariant: const Color(0xFFC6C6C8), // opaqueSeparator
    error: const Color(0xFFFF3B30),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFE1DF),
    onErrorContainer: const Color(0xFFFF3B30),
    success: const Color(0xFF34C759),
    onSuccess: const Color(0xFFFFFFFF),
    successContainer: const Color(0xFFDDF6E3),
    onSuccessContainer: const Color(0xFF248A3D),
    warning: const Color(0xFFFF9500),
    onWarning: const Color(0xFFFFFFFF),
    warningContainer: const Color(0xFFFFEACC),
    onWarningContainer: const Color(0xFFC93400),
    info: const Color(0xFF30B0C7),
    onInfo: const Color(0xFFFFFFFF),
    infoContainer: const Color(0xFFDAF1F5),
    onInfoContainer: const Color(0xFF008299),
    inverseSurface: const Color(0xFF1C1C1E),
    inverseOnSurface: const Color(0xFFF2F2F7),
    inversePrimary: _systemBlueDark,
    scrim: const Color(0xFF000000),
  );
}

CamoColors _dark(Color blue) =>
    CamoColors.fromSeed(primary: blue, brightness: Brightness.dark).copyWith(
      primary: blue,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: _over(blue, 0.22, const Color(0xFF000000)),
      onPrimaryContainer: blue,
      secondary: const Color(0xFF8E8E93),
      onSecondary: const Color(0xFF000000),
      secondaryContainer: const Color(0xFF2C2C2E),
      onSecondaryContainer: const Color(0xFFFFFFFF),
      tertiary: const Color(0xFF5E5CE6),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFF26264F),
      onTertiaryContainer: const Color(0xFF7D7AFF),
      surface: const Color(0xFF000000), // systemGroupedBackground
      surfaceContainerLowest: const Color(0xFF000000), // systemBackground
      surfaceContainerLow: const Color(
        0xFF1C1C1E,
      ), // secondarySystemGroupedBackground
      surfaceContainer: const Color(0xFF1C1C1E), // secondarySystemBackground
      surfaceContainerHigh: const Color(0xFF2C2C2E), // tertiarySystemBackground
      surfaceContainerHighest: const Color(0xFF3A3A3C), // systemGray4
      onSurface: const Color(0xFFFFFFFF),
      onSurfaceVariant: const Color(0xFF8E8E93),
      outline: const Color(0xFF48484A),
      outlineVariant: const Color(0xFF38383A),
      error: const Color(0xFFFF453A),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFF4A1A17),
      onErrorContainer: const Color(0xFFFF453A),
      success: const Color(0xFF30D158),
      onSuccess: const Color(0xFF000000),
      successContainer: const Color(0xFF123F1D),
      onSuccessContainer: const Color(0xFF30D158),
      warning: const Color(0xFFFF9F0A),
      onWarning: const Color(0xFF000000),
      warningContainer: const Color(0xFF4A2F05),
      onWarningContainer: const Color(0xFFFF9F0A),
      info: const Color(0xFF40CBE0),
      onInfo: const Color(0xFF000000),
      infoContainer: const Color(0xFF123C44),
      onInfoContainer: const Color(0xFF40CBE0),
      inverseSurface: const Color(0xFFF2F2F7),
      inverseOnSurface: const Color(0xFF1C1C1E),
      inversePrimary: systemBlue,
      scrim: const Color(0xFF000000),
    );

// SF's text styles (largeTitle 34, title1 28, title2 22, title3 20, headline 17, body 17, callout 16, subheadline
// 15, footnote 13, caption1 12, caption2 11), size / line height, weight and the SF tracking at that size.
CamoTypography _typography(String? family) {
  TextStyle style(double size, double line, int weight, double tracking) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: line / size,
        fontWeight: FontWeight.values[weight ~/ 100 - 1],
        letterSpacing: tracking,
      );
  return CamoTypography(
    displayLarge: style(48, 56, 700, 0.37),
    displayMedium: style(40, 48, 700, 0.37),
    displaySmall: style(34, 41, 700, 0.37), // largeTitle
    headlineLarge: style(28, 34, 700, 0.36), // title1
    headlineMedium: style(22, 28, 700, 0.35), // title2
    headlineSmall: style(20, 25, 600, 0.38), // title3
    titleLarge: style(20, 25, 600, 0.38),
    titleMedium: style(17, 22, 600, -0.41), // headline
    titleSmall: style(15, 20, 600, -0.24),
    bodyLarge: style(17, 22, 400, -0.41), // body
    bodyMedium: style(15, 20, 400, -0.24), // subheadline
    bodySmall: style(13, 18, 400, -0.08), // footnote
    labelLarge: style(16, 21, 500, -0.32), // callout
    labelMedium: style(12, 16, 500, 0), // caption1
    labelSmall: style(11, 13, 500, 0.07), // caption2
  );
}
