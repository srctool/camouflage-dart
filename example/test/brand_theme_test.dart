import 'package:camouflage_example/brands.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/main.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Set<String> failing(CamoTheme theme) => theme
      .validate()
      .map((i) => i is LowContrast ? i.pair : i.toString())
      .toSet();

  // Issue acceptance: every brand passes the contrast check, on every skin, light and dark. Cupertino keeps Apple's
  // published system colors, a few of which are below AA by themselves (its own theme test lists them): a brand there
  // may not add a failing pair beyond those of the plain Cupertino theme.
  test('every brand on every skin validates', () {
    for (final skin in SampleSkin.values) {
      for (final brand in Brand.values) {
        for (final b in Brightness.values) {
          final allowed =
              skin == SampleSkin.cupertino || skin == SampleSkin.cupertinoGlass
              ? failing(sampleTheme(skin, Brand.defaultBrand, b))
              : <String>{};
          expect(
            failing(sampleTheme(skin, brand, b)).difference(allowed),
            isEmpty,
            reason: '$brand on $skin, $b',
          );
        }
      }
    }
  });

  test('a brand carries its tokens and the default none', () {
    expect(
      sampleTheme(
        SampleSkin.minimal,
        Brand.ocean,
        Brightness.light,
      ).tokens<BrandTokens>(),
      isNotNull,
    );
    expect(
      sampleTheme(
        SampleSkin.minimal,
        Brand.defaultBrand,
        Brightness.light,
      ).tokens<BrandTokens>(),
      isNull,
    );
  });

  // Fluent fills primary buttons from its own tokens: a brand must reach them, not only the roles.
  test("a brand reaches Fluent's own tokens", () {
    final fluent = sampleTheme(
      SampleSkin.fluent,
      Brand.ember,
      Brightness.light,
    );
    expect(
      fluent.tokens<FluentTokens>()!.brandBackground,
      Brand.ember.tokens!.brand[600],
    );
  });
}
