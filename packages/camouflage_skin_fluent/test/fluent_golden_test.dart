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
    ('inputs', const InputGallery()),
    ('textinputs', const TextInputGallery()),
    ('pickers', const PickerGallery()),
    ('structure', const StructureGallery()),
    ('dialogs', const DialogGallery()),
  ]) {
    goldenTest(
      'fluent $name',
      fileName: '${name}_fluent',
      constraints: const BoxConstraints(maxWidth: 1000),
      // Skeletons animate forever, so the structure scene can't settle: one frame, at the start of the cycle.
      pumpBeforeTest: name == 'structure' ? pumpOnce : onlyPumpAndSettle,
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

  // Acrylic: a panel at flyout depth over stripes, blurring them.
  goldenTest(
    'fluent acrylic',
    fileName: 'acrylic_fluent',
    builder: () => GoldenTestScenario(
      name: 'light',
      child: CamouflagePreview(
        skin: fluentSkin(surface: FluentSurface.acrylic),
        theme: fluentTheme(),
        child: SizedBox(
          width: 360,
          height: 200,
          child: Stack(
            children: [
              Column(
                children: [
                  for (var i = 0; i < 8; i++)
                    Expanded(
                      child: ColoredBox(
                        color: i.isEven
                            ? const Color(0xFF0F6CBD)
                            : const Color(0xFFF7630C),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
              const Center(
                child: CamoMenuPanel(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CamoText('Acrylic'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
