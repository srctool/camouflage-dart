import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark validate', () {
    expect(fluentTheme().validate(), isEmpty);
    expect(fluentTheme(brightness: Brightness.dark).validate(), isEmpty);
  });

  // Pinned to @fluentui/tokens 1.0.0-alpha.24 (alias/lightColor, alias/darkColor), like the Kotlin skin.
  test("the default brand matches Fluent's published tokens", () {
    final light = fluentTheme();
    final dark = fluentTheme(brightness: Brightness.dark);
    expect(light.colors.primary, const Color(0xFF0F6CBD));
    expect(light.colors.onSurface, const Color(0xFF242424));
    expect(light.colors.outlineVariant, const Color(0xFFD1D1D1));
    expect(light.colors.error, const Color(0xFFC50F1F));
    expect(dark.colors.surface, const Color(0xFF292929));
    final tokens = light.tokens<FluentTokens>()!;
    expect(tokens.brandBackgroundHover, const Color(0xFF115EA3));
    expect(tokens.brandBackgroundPressed, const Color(0xFF0C3B5E));
    expect(tokens.neutralBackground1Hover, const Color(0xFFF5F5F5));
    expect(
      dark.tokens<FluentTokens>()!.brandBackground,
      const Color(0xFF115EA3),
    );
  });

  test('a custom brand is step 80', () {
    const brand = Color(0xFF8A3FFC);
    expect(fluentTheme(brand: brand).colors.primary, brand);
  });

  test('density sets control heights', () {
    expect(
      fluentTheme(density: FluentDensity.small).components.button?.height,
      24,
    );
    expect(fluentTheme().components.button?.height, 32);
    expect(
      fluentTheme(density: FluentDensity.touch)
          .components
          .iconButton
          ?.containerSize,
      40,
    );
  });

  test('the skin is the Fluent skin', () {
    expect(fluentSkin().name, 'fluent');
    expect(fluentSkinDefault.surfaceTreatment, isA<FluentSolid>());
  });
}
