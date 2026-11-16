import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:flutter_test/flutter_test.dart';

// Carbon's density (base Carbon Skin §3.5): one theme-level value that every control's size follows.
void main() {
  const caps = CamoCapabilities(
    backdropBlur: false,
    runtimeShaders: false,
    windowMaterial: false,
    reduceTransparency: false,
  );
  const desktop = CamoEnvironment(
    windowSize: WindowSizeClass.expanded,
    input: InputMode.pointer,
    platform: CamoPlatform.windows,
    capabilities: caps,
  );
  final phone = desktop.copyWith(
    windowSize: WindowSizeClass.compact,
    input: InputMode.touch,
    platform: CamoPlatform.android,
  );

  List<double> heights(CamoTheme theme) => [
    carbonSkin.button.defaults(theme).height,
    carbonSkin.iconButton.defaults(theme).containerSize,
    carbonSkin.textField.defaults(theme).height,
    carbonSkin.searchField.defaults(theme).height,
    carbonSkin.stepper.defaults(theme).height,
    carbonSkin.menu.defaults(theme).itemHeight,
    carbonSkin.listItem.defaults(theme).minHeightOneLine,
    carbonSkin.tree.defaults(theme).rowHeight,
    carbonSkin.dataTable.defaults(theme).rowHeight,
    carbonSkin.tabs.defaults(theme).height,
    carbonSkin.toolbar.defaults(theme).actionSize,
  ];

  test('every control follows the density', () {
    for (final density in CarbonDensity.values) {
      expect(
        heights(carbonTheme(density: density)),
        List.filled(11, density.size),
        reason: '$density',
      );
    }
    expect(CarbonDensity.values.map((d) => d.size), [24, 32, 40, 48]);
  });

  test('the default follows the input', () {
    final theme = carbonTheme();
    expect(
      carbonSkin.button.defaults(theme.forEnvironment(desktop)).height,
      40,
    );
    expect(carbonSkin.button.defaults(theme.forEnvironment(phone)).height, 48);
    expect(
      carbonSkin.dataTable.defaults(theme.forEnvironment(desktop)).rowHeight,
      40,
    );
  });

  test('an explicit density wins over the input', () {
    final theme = carbonTheme(density: CarbonDensity.sm);
    expect(carbonSkin.button.defaults(theme.forEnvironment(phone)).height, 32);
    expect(
      carbonSkin.button.defaults(theme.forEnvironment(desktop)).height,
      32,
    );
  });

  test('the smallest size draws 12 point text', () {
    final xs = carbonTheme(density: CarbonDensity.xs);
    expect(carbonSkin.button.defaults(xs).textStyle.fontSize, 12);
    expect(carbonLight.tokens<CarbonDensityTokens>(), isNotNull);
    final md = carbonTheme(density: CarbonDensity.md);
    expect(carbonSkin.button.defaults(md).textStyle.fontSize, 14);
  });

  test('a theme without the tokens keeps the large size', () {
    final bare = carbonTheme(density: CarbonDensity.sm)
        .copyWith(tokenSets: const []);
    expect(carbonSkin.button.defaults(bare).height, 48);
  });
}
