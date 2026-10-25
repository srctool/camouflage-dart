import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// A seed with no chroma: the neutral palette, for the ink primary and the neutral secondary and tertiary.
const _gray = Color(0xFF777777);

/// The Minimal starter theme: true-gray surfaces, status colors only for status, and an **ink** primary
/// (near-black in light, near-white in dark) unless an [accent] is given. With an accent, only the `primary`
/// family takes its color; secondary and tertiary stay neutral.
CamoTheme minimalTheme({
  Color? accent,
  Brightness brightness = Brightness.light,
  CamoTypography? typography,
}) {
  final dark = brightness == Brightness.dark;
  final seeded = CamoColors.fromSeed(
    primary: accent ?? _gray,
    secondary: _gray,
    tertiary: _gray,
    brightness: brightness,
  );
  // Ink is the neutral palette's text tones (base Minimal Skin §3.2): primary 10 / 92, onPrimary 100 / 10,
  // primaryContainer 92 / 22, onPrimaryContainer 10 / 92 — the same tones as these surface roles.
  final colors = accent != null
      ? seeded
      : seeded.copyWith(
          primary: seeded.onSurface,
          onPrimary: dark ? seeded.surfaceContainerLow : seeded.surface,
          primaryContainer: seeded.surfaceContainerHighest,
          onPrimaryContainer: seeded.onSurface,
        );
  return CamoTheme(
    colors: colors,
    typography: typography ?? CamoTypography.system(),
  );
}

/// [minimalTheme] in light mode, with the ink primary.
final CamoTheme minimalLight = minimalTheme();

/// [minimalTheme] in dark mode, with the ink primary.
final CamoTheme minimalDark = minimalTheme(brightness: Brightness.dark);
