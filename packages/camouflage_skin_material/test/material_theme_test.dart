import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_material/camouflage_skin_material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baseline and seeded themes validate', () {
    const seed = Color(0xFF0B57D0);
    for (final theme in [
      materialBaselineLight,
      materialBaselineDark,
      materialTheme(seed: seed),
      materialTheme(seed: seed, brightness: Brightness.dark),
    ]) {
      expect(theme.validate(), isEmpty);
    }
  });

  test('the baseline has the M3 roles', () {
    final light = materialBaselineLight.colors;
    expect(light.primary, const Color(0xFF6750A4));
    expect(light.surface, const Color(0xFFFEF7FF));
    expect(light.surfaceContainer, const Color(0xFFF3EDF7));
    expect(light.error, const Color(0xFFB3261E));
    final dark = materialBaselineDark.colors;
    expect(dark.primary, const Color(0xFFD0BCFF));
    expect(dark.surface, const Color(0xFF141218));
    expect(dark.inversePrimary, const Color(0xFF6750A4));
  });

  test('the theme carries M3 shapes, motion and type', () {
    final theme = materialTheme();
    expect(theme.shapes.extraLarge, BorderRadius.circular(28));
    expect(theme.motion.durationShort, const Duration(milliseconds: 150));
    expect(theme.typography.displayLarge.fontSize, 57);
  });

  // The baseline writes the status families out as literals so they never shift silently. If a color-library
  // update changes what `fromSeed` generates, this fails and you decide whether to update the literals.
  test('the status literals still equal what fromSeed generates', () {
    List<Color> status(CamoColors c) => [
      c.success,
      c.onSuccess,
      c.successContainer,
      c.onSuccessContainer,
      c.warning,
      c.onWarning,
      c.warningContainer,
      c.onWarningContainer,
      c.info,
      c.onInfo,
      c.infoContainer,
      c.onInfoContainer,
    ];
    for (final brightness in Brightness.values) {
      final pinned =
          (brightness == Brightness.dark
                  ? materialBaselineDark
                  : materialBaselineLight)
              .colors;
      final generated = materialColors(
        materialBaselineSeed,
        brightness: brightness,
      );
      expect(status(pinned), status(generated), reason: '$brightness');
    }
  });

  test('the skin is named and uses Paper and Ripple', () {
    expect(materialSkin.name, 'material');
    expect(materialSkin.surfaceTreatment, isA<Paper>());
    expect(materialSkin.feedback, isA<Ripple>());
    expect(
      materialSkinWith(expressiveProgress: true).progressBar,
      isA<MaterialWavyProgressBarRenderer>(),
    );
  });
}
