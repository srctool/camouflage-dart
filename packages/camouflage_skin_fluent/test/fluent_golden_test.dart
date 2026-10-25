import 'package:alchemist/alchemist.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';

// Screenshot goldens: light and dark at medium density, small density in light, and one brand theme
// (Testing §3). Update with `flutter test --update-goldens --tags golden`.
void main() {
  final themes = {
    'light': fluentTheme(),
    'dark': fluentTheme(brightness: Brightness.dark),
    'small': fluentTheme(density: FluentDensity.small),
    'brand': fluentTheme(brand: const Color(0xFF8A3FFC)),
  };

  Widget scenario(CamoTheme theme, Widget child) =>
      CamouflagePreview(skin: fluentSkinDefault, theme: theme, child: child);

  for (final (name, gallery) in [
    ('button', const ButtonGallery()),
    ('iconbutton', const IconButtonGallery()),
    ('primitives', const PrimitiveGallery()),
  ]) {
    goldenTest(
      'fluent $name',
      fileName: '${name}_fluent',
      constraints: const BoxConstraints(maxWidth: 1000),
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          for (final MapEntry(:key, :value) in themes.entries)
            GoldenTestScenario(
              name: key,
              constraints: const BoxConstraints(maxWidth: 1000),
              child: scenario(value, gallery),
            ),
        ],
      ),
    );
  }
}
