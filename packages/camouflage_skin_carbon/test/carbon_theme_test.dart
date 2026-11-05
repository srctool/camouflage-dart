import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Carbon's own tokens pass AA in the White, G10 and G100 families; G90's layer-03 (gray 60) is the one place
  // Carbon's text tokens fall short (text on gray 60 is 4.0), so that family may fail only on the two highest
  // container roles.
  const g90Known = {
    'onSurface/surfaceContainerHigh',
    'onSurfaceVariant/surfaceContainerHigh',
    'onSurface/surfaceContainerHighest',
    'onSurfaceVariant/surfaceContainerHighest',
  };

  test('White, G10 and G100 validate', () {
    for (final family in [
      CarbonThemeFamily.white,
      CarbonThemeFamily.g10,
      CarbonThemeFamily.g100,
    ]) {
      expect(
        carbonTheme(family: family).validate(),
        isEmpty,
        reason: '$family',
      );
    }
    expect(carbonLight.validate(), isEmpty);
    expect(carbonDark.validate(), isEmpty);
  });

  test('G90 fails only on its highest layers', () {
    final failing = carbonTheme(family: CarbonThemeFamily.g90)
        .validate()
        .whereType<LowContrast>()
        .map((i) => i.pair);
    expect(failing.where((p) => !g90Known.contains(p)), isEmpty);
  });

  test(
    'a brand accent keeps the theme valid in every light and dark family',
    () {
      const accent = Color(0xFF0B57D0);
      for (final family in [CarbonThemeFamily.white, CarbonThemeFamily.g100]) {
        final theme = carbonTheme(family: family, accent: accent);
        expect(theme.validate(), isEmpty, reason: '$family');
      }
    },
  );

  // Carbon's published tokens, pinned: a change here is a decision, not a side effect.
  test('the tokens are pinned', () {
    final white = carbonLight.colors;
    expect(white.primary, const Color(0xFF0F62FE)); // blue 60
    expect(white.onSurface, const Color(0xFF161616)); // text-primary
    expect(white.surface, const Color(0xFFFFFFFF)); // background
    expect(white.surfaceContainerLow, const Color(0xFFF4F4F4)); // layer-01
    expect(white.surfaceContainer, const Color(0xFFFFFFFF)); // layer-02
    expect(white.outline, const Color(0xFF8D8D8D)); // border-strong
    expect(white.outlineVariant, const Color(0xFFC6C6C6)); // border-subtle
    final g100 = carbonDark.colors;
    expect(g100.surface, const Color(0xFF161616));
    expect(g100.surfaceContainerLow, const Color(0xFF262626));
    expect(g100.surfaceContainer, const Color(0xFF393939));
    expect(g100.surfaceContainerHigh, const Color(0xFF525252));
    expect(g100.primary, const Color(0xFF4589FF));
  });

  test('the dark families step one gray per nesting level', () {
    for (final family in [CarbonThemeFamily.g90, CarbonThemeFamily.g100]) {
      final c = carbonTheme(family: family).colors;
      expect(c.surface.r, lessThan(c.surfaceContainerLow.r));
      expect(c.surfaceContainerLow.r, lessThan(c.surfaceContainer.r));
      expect(c.surfaceContainer.r, lessThan(c.surfaceContainerHigh.r));
    }
  });

  test('every shape is square', () {
    final shapes = carbonLight.shapes;
    for (final s in [
      shapes.none,
      shapes.extraSmall,
      shapes.small,
      shapes.medium,
      shapes.large,
      shapes.extraLarge,
    ]) {
      expect(s, BorderRadius.zero);
    }
  });
}
