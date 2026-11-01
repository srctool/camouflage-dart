import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:flutter_test/flutter_test.dart';

// Fluent's environment-driven defaults (ADR-41): density follows the input, the toast's place the window.
void main() {
  const caps = CamoCapabilities(
    backdropBlur: true,
    runtimeShaders: true,
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

  test('the default density follows the input', () {
    expect(fluentTheme().forEnvironment(desktop).components.button?.height, 32);
    expect(fluentTheme().forEnvironment(phone).components.button?.height, 40);
    expect(
      fluentTheme().forEnvironment(phone).components.iconButton?.containerSize,
      40,
    );
  });

  test('an explicit density stays', () {
    expect(
      fluentTheme(density: FluentDensity.small)
          .forEnvironment(phone)
          .components
          .button
          ?.height,
      24,
    );
  });

  test("the touch density keeps a brand's button overrides", () {
    final base = fluentTheme();
    final brand = base.copyWith(
      components: base.components.copyWith(
        button: base.components.button?.copyWith(
          raisedElevation: ElevationLevel.level3,
        ),
      ),
    );
    final button = brand.forEnvironment(phone).components.button;
    expect(button?.height, 40);
    expect(button?.raisedElevation, ElevationLevel.level3);
  });

  test('the toast sits at the end except on a phone', () {
    final theme = fluentTheme();
    expect(
      fluentSkinDefault.snackbar
          .defaults(theme.forEnvironment(desktop))
          .alignment,
      SnackbarAlignment.end,
    );
    expect(
      fluentSkinDefault.snackbar
          .defaults(theme.forEnvironment(phone))
          .alignment,
      SnackbarAlignment.center,
    );
  });
}
