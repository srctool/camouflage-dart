import 'dart:io';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/charts.dart';
import 'package:camouflage_example/checkout.dart';
import 'package:camouflage_example/selection.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_material/camouflage_skin_material.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The pub.dev screenshots of the packages. Not a test of anything: it renders the example's screens in every skin,
// light and dark, with a real font (Roboto, from the Flutter SDK), and writes the PNGs into each package's
// `screenshots/` folder. Run it with
//   CAMO_SCREENSHOTS=1 flutter test --update-goldens test/screenshots_test.dart
final _enabled = Platform.environment.containsKey('CAMO_SCREENSHOTS');

const _font = 'Roboto';

Future<void> _loadRoboto() async {
  final root = Platform.environment['FLUTTER_ROOT']!;
  final loader = FontLoader(_font);
  for (final name in ['Regular', 'Medium', 'Bold']) {
    final bytes = File(
      '$root/bin/cache/artifacts/material_fonts/Roboto-$name.ttf',
    ).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

typedef _Skin = ({
  String package,
  String label,
  CamoSkin skin,
  CamoTheme Function(Brightness) theme,
});

final _skins = <_Skin>[
  (
    package: 'camouflage_skin_minimal',
    label: 'Minimal',
    skin: minimalSkin,
    theme: (b) => minimalTheme(
      brightness: b,
      typography: CamoTypography.system(fontFamily: _font),
    ),
  ),
  (
    package: 'camouflage_skin_fluent',
    label: 'Fluent',
    skin: fluentSkinDefault,
    theme: (b) => fluentTheme(brightness: b, fontFamily: _font),
  ),
  (
    package: 'camouflage_skin_material',
    label: 'Material',
    skin: materialSkin,
    theme: (b) => materialTheme(brightness: b, fontFamily: _font),
  ),
  (
    package: 'camouflage_skin_cupertino',
    label: 'Cupertino',
    skin: cupertinoSkin,
    theme: (b) => cupertinoTheme(brightness: b, fontFamily: _font),
  ),
  (
    package: 'camouflage_skin_carbon',
    label: 'Carbon',
    skin: carbonSkin,
    theme: (b) => carbonTheme(
      family: b == Brightness.dark
          ? CarbonThemeFamily.g100
          : CarbonThemeFamily.white,
      fontFamily: _font,
    ),
  ),
];

final _boundary = GlobalKey();

/// The top [height] of [child], however tall it is (a long demo cut to a phone-sized picture).
Widget _top(double height, Widget child) => ClipRect(
  child: SizedBox(
    height: height,
    child: OverflowBox(
      alignment: Alignment.topCenter,
      maxHeight: double.infinity,
      child: child,
    ),
  ),
);

Widget _frame(CamoSkin skin, CamoTheme theme, Widget child, {double? width}) =>
    RepaintBoundary(
      key: _boundary,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => CamouflageProvider(
                  skin: skin,
                  theme: theme,
                  child: CamoSurface(
                    child: SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

Future<void> _shoot(
  WidgetTester tester,
  Widget app,
  String path, {
  required Size size,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(Align(alignment: Alignment.topLeft, child: app));
  await tester.pump(const Duration(milliseconds: 600));
  await expectLater(find.byKey(_boundary), matchesGoldenFile(path));
}

void main() {
  setUpAll(() async {
    if (_enabled) await _loadRoboto();
  });

  for (final s in _skins) {
    for (final b in Brightness.values) {
      testWidgets('${s.label} ${b.name}', (tester) async {
        await _shoot(
          tester,
          _frame(
            s.skin,
            s.theme(b),
            // The checkout card and the selection controls, cut above the sliders (which overflow a phone frame).
            _top(
              840,
              const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [Checkout(), SelectionControls()],
              ),
            ),
            width: 430,
          ),
          '../../packages/${s.package}/screenshots/${b.name}.png',
          size: const Size(430, 880),
        );
      }, skip: !_enabled);
    }
  }

  for (final b in Brightness.values) {
    testWidgets('charts ${b.name}', (tester) async {
      await _shoot(
        tester,
        _frame(
          minimalSkin,
          minimalTheme(
            brightness: b,
            typography: CamoTypography.system(fontFamily: _font),
          ),
          _top(860, const ChartsDemo()),
          width: 430,
        ),
        '../../packages/camouflage_charts/screenshots/${b.name}.png',
        size: const Size(430, 900),
      );
    }, skip: !_enabled);
  }

  testWidgets('core: the same screen in five skins', (tester) async {
    await _shoot(
      tester,
      _frame(
        minimalSkin,
        minimalTheme(typography: CamoTypography.system(fontFamily: _font)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            for (final s in _skins)
              SizedBox(
                width: 400,
                child: CamouflageProvider(
                  skin: s.skin,
                  theme: s.theme(Brightness.light),
                  child: const CamoSurface(
                    shape: ShapeRole.large,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Checkout(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      '../../packages/camouflage_core/screenshots/skins.png',
      size: const Size(2100, 440),
    );
  }, skip: !_enabled);
}
