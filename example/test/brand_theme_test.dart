import 'package:camouflage_example/brands.dart';
import 'package:camouflage_example/main.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Issue acceptance: every brand passes the contrast check, on every skin, light and dark.
  test('every brand on every skin validates', () {
    for (final skin in SampleSkin.values) {
      for (final brand in Brand.values) {
        for (final b in Brightness.values) {
          expect(
            sampleTheme(skin, brand, b).validate(),
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
