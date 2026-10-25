import 'package:alchemist/alchemist.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';

// Screenshot goldens: light and dark for every M3 component, plus one brand theme (an accent), light only
// (Testing §3). Update with `flutter test --update-goldens --tags golden`.
void main() {
  final themes = {
    'light': minimalLight,
    'dark': minimalDark,
    'brand': minimalTheme(accent: const Color(0xFF0B57D0)),
  };

  Widget scenario(CamoTheme theme, Widget child) =>
      CamouflagePreview(skin: minimalSkin, theme: theme, child: child);

  for (final (name, gallery) in [
    ('button', const ButtonGallery()),
    ('iconbutton', const IconButtonGallery()),
    ('primitives', const PrimitiveGallery()),
  ]) {
    goldenTest(
      'minimal $name',
      fileName: '${name}_minimal',
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
