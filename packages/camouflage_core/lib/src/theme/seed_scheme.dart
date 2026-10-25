import 'package:flutter/widgets.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'camo_colors.dart';

/// Builds [CamoColors] from seeds: `material_color_utilities` supplies the tonal palettes, Camouflage the tone table.
abstract final class SeedScheme {
  // Material's "tonal spot" derivation when no secondary / tertiary seed is given.
  static const double _secondaryChroma = 16;
  static const double _tertiaryChroma = 24;
  static const double _tertiaryHueShift = 60;

  // A `neutral` seed keeps only a hint of its hue, so surfaces stay readable (Material uses the same chroma).
  static const double _tintedNeutralChroma = 6;

  /// Camouflage's default status seeds (settled 2026-09-27). Only their hue and chroma matter.
  static const Color defaultError = Color(0xFFB3261E);

  /// The default success seed.
  static const Color defaultSuccess = Color(0xFF2E7D32);

  /// The default warning seed.
  static const Color defaultWarning = Color(0xFFF9A825);

  /// The default info seed.
  static const Color defaultInfo = Color(0xFF0288D1);

  /// The four colors of one family from [palette]: tones 40 / 100 / 90 / 10 in light, 80 / 20 / 30 / 90 in dark.
  static ToneColors family(TonalPalette palette, {required bool dark}) => dark
      ? ToneColors(
          _c(palette, 80),
          _c(palette, 20),
          _c(palette, 30),
          _c(palette, 90),
        )
      : ToneColors(
          _c(palette, 40),
          _c(palette, 100),
          _c(palette, 90),
          _c(palette, 10),
        );

  /// See [CamoColors.fromSeed].
  static CamoColors build({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? neutral,
    required bool dark,
  }) {
    final p = palette(primary);
    final s = secondary != null
        ? palette(secondary)
        : TonalPalette.of(p.hue, _secondaryChroma);
    final t = tertiary != null
        ? palette(tertiary)
        : TonalPalette.of((p.hue + _tertiaryHueShift) % 360, _tertiaryChroma);
    final n = neutral != null
        ? TonalPalette.of(palette(neutral).hue, _tintedNeutralChroma)
        : TonalPalette.of(0, 0);

    final pf = family(p, dark: dark);
    final sf = family(s, dark: dark);
    final tf = family(t, dark: dark);
    final ef = family(palette(error ?? defaultError), dark: dark);
    final okf = family(palette(success ?? defaultSuccess), dark: dark);
    final wf = family(palette(warning ?? defaultWarning), dark: dark);
    final inf = family(palette(info ?? defaultInfo), dark: dark);

    // Camouflage's neutral tones (base Theme §3.4).
    Color nt({required int light, required int darkTone}) =>
        _c(n, dark ? darkTone : light);

    return CamoColors(
      primary: pf.strong,
      onPrimary: pf.onStrong,
      primaryContainer: pf.container,
      onPrimaryContainer: pf.onContainer,
      secondary: sf.strong,
      onSecondary: sf.onStrong,
      secondaryContainer: sf.container,
      onSecondaryContainer: sf.onContainer,
      tertiary: tf.strong,
      onTertiary: tf.onStrong,
      tertiaryContainer: tf.container,
      onTertiaryContainer: tf.onContainer,
      surface: nt(light: 100, darkTone: 6),
      surfaceContainerLowest: nt(light: 100, darkTone: 4),
      surfaceContainerLow: nt(light: 98, darkTone: 10),
      surfaceContainer: nt(light: 96, darkTone: 12),
      surfaceContainerHigh: nt(light: 94, darkTone: 17),
      surfaceContainerHighest: nt(light: 92, darkTone: 22),
      onSurface: nt(light: 10, darkTone: 92),
      onSurfaceVariant: nt(light: 35, darkTone: 75),
      outline: nt(light: 50, darkTone: 60),
      outlineVariant: nt(light: 90, darkTone: 25),
      error: ef.strong,
      onError: ef.onStrong,
      errorContainer: ef.container,
      onErrorContainer: ef.onContainer,
      success: okf.strong,
      onSuccess: okf.onStrong,
      successContainer: okf.container,
      onSuccessContainer: okf.onContainer,
      warning: wf.strong,
      onWarning: wf.onStrong,
      warningContainer: wf.container,
      onWarningContainer: wf.onContainer,
      info: inf.strong,
      onInfo: inf.onStrong,
      infoContainer: inf.container,
      onInfoContainer: inf.onContainer,
      inverseSurface: nt(light: 20, darkTone: 90),
      inverseOnSurface: nt(light: 95, darkTone: 20),
      inversePrimary: _c(p, dark ? 40 : 80),
      scrim: _c(n, 0),
    );
  }

  /// The HCT tonal palette of a seed color.
  static TonalPalette palette(Color seed) {
    final hct = Hct.fromInt(seed.toARGB32());
    return TonalPalette.of(hct.hue, hct.chroma);
  }

  static Color _c(TonalPalette palette, int tone) => Color(palette.get(tone));
}
