import 'package:alchemist/alchemist.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';

// Screenshot goldens: light and dark for every component so far, plus one brand theme (an accent), light only
// (Testing §3). Update with `flutter test --update-goldens --tags golden`.
void main() {
  final themes = {
    'light': cupertinoLight,
    'dark': cupertinoDark,
    'brand': cupertinoTheme(accent: const Color(0xFF0B57D0)),
  };

  Widget scenario(CamoTheme theme, Widget child) =>
      CamouflagePreview(skin: cupertinoSkin, theme: theme, child: child);

  for (final (name, gallery) in [
    ('button', const ButtonGallery()),
    ('iconbutton', const IconButtonGallery()),
    ('primitives', const PrimitiveGallery()),
    ('inputs', const InputGallery()),
    ('textinputs', const TextInputGallery()),
    ('pickers', const PickerGallery()),
    ('structure', const StructureGallery()),
    ('dialogs', const DialogGallery()),
    ('menus', const MenuGallery()),
    ('datadisplay', const DataDisplayGallery()),
    ('feedback', const FeedbackGallery()),
    ('navigation', const NavigationGallery()),
    ('navchrome', const NavigationChromeGallery()),
    ('panels', const PanelsGallery()),
    ('actions', const ActionsGallery()),
    ('smalldata', const SmallDataGallery()),
    ('lists', const ListsGallery()),
    ('collections', const CollectionsGallery()),
  ]) {
    goldenTest(
      'cupertino $name',
      fileName: '${name}_cupertino',
      constraints: const BoxConstraints(maxWidth: 1000),
      // Skeletons and spinners animate forever, so those scenes can't settle: one frame, at the start of the cycle.
      pumpBeforeTest: name == 'structure' || name == 'lists'
          ? pumpOnce
          : onlyPumpAndSettle,
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

  // The materials chain (ADR-42), step by step, with the capability forced: no backdrop blur (opaque) and Reduce
  // Transparency (opaque), for Classic and Glass, light and dark. (Glass without shaders is the glass golden below:
  // Flutter never draws the refraction.)
  const caps = CamoCapabilities(
    backdropBlur: true,
    runtimeShaders: true,
    windowMaterial: false,
    reduceTransparency: false,
  );
  for (final (name, capabilities) in [
    ('noblur', caps.copyWith(backdropBlur: false)),
    ('reduced', caps.copyWith(reduceTransparency: true)),
  ]) {
    goldenTest(
      'cupertino materials $name',
      fileName: 'materials_${name}_cupertino',
      constraints: const BoxConstraints(maxWidth: 1000),
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          for (final (skinKey, skin) in [
            ('classic', cupertinoSkin),
            ('glass', cupertinoSkinWith(surface: CupertinoSurface.liquidGlass)),
          ])
            for (final (themeKey, theme) in [
              ('light', cupertinoLight),
              ('dark', cupertinoDark),
            ])
              GoldenTestScenario(
                name: '$skinKey $themeKey',
                constraints: const BoxConstraints.tightFor(
                  width: 420,
                  height: 320,
                ),
                child: CamouflageProvider(
                  skin: skin,
                  theme: theme,
                  environment: CamoEnvironment(
                    windowSize: WindowSizeClass.compact,
                    input: InputMode.touch,
                    platform: CamoPlatform.ios,
                    capabilities: capabilities,
                  ),
                  child: const _MaterialsScene(),
                ),
              ),
        ],
      ),
    );
  }

  // The materials: Classic and Liquid Glass panels over a colorful app, so the blur shows.
  goldenTest(
    'cupertino materials',
    fileName: 'materials_cupertino',
    constraints: const BoxConstraints(maxWidth: 1000),
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final (skinKey, skin) in [
          ('classic', cupertinoSkin),
          ('glass', cupertinoSkinWith(surface: CupertinoSurface.liquidGlass)),
        ])
          for (final (themeKey, theme) in [
            ('light', cupertinoLight),
            ('dark', cupertinoDark),
          ])
            GoldenTestScenario(
              name: '$skinKey $themeKey',
              constraints: const BoxConstraints.tightFor(
                width: 420,
                height: 320,
              ),
              child: CamouflagePreview(
                skin: skin,
                theme: theme,
                child: const _MaterialsScene(),
              ),
            ),
      ],
    ),
  );
}

// Bars of color for the materials to blur, with a panel, a capsule bar and two buttons on top.
class _MaterialsScene extends StatelessWidget {
  const _MaterialsScene();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFE53935),
          Color(0xFFFFB300),
          Color(0xFF43A047),
          Color(0xFF1E88E5),
        ],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        spacing: 16,
        children: [
          const SizedBox(
            height: 96,
            width: double.infinity,
            child: CamoSurface(
              shape: ShapeRole.large,
              elevation: ElevationLevel.level3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CamoText('A material panel'),
              ),
            ),
          ),
          const SizedBox(
            height: 56,
            width: double.infinity,
            child: CamoSurface(
              shape: ShapeRole.full,
              elevation: ElevationLevel.level2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CamoText('A capsule bar'),
              ),
            ),
          ),
          Row(
            spacing: 12,
            children: [
              CamoButton(text: 'Solid', onPressed: () {}),
              CamoButton(
                text: 'Soft',
                onPressed: () {},
                appearance: Appearance.soft,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
