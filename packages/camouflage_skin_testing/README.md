# camouflage_skin_testing

[![pub package](https://img.shields.io/pub/v/camouflage_skin_testing.svg)](https://pub.dev/packages/camouflage_skin_testing)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**Test-only checks for any Camouflage skin.** Use it in the tests of a skin you write (or of an app that customizes one) to prove that renderers keep the component's behavior, honor every component-theme field, and meet the accessibility guidelines.

Add it as a **dev dependency**:

```sh
flutter pub add --dev camouflage_skin_testing
```

## Features

- **`assertRendererAppliesBehavior`**: a click at the corner and one at the center of the rendered box both fire, and the node has a role. A renderer that applies the behavior inside its padding fails.
- **`assertNoLiterals`**: renders with a theme full of odd values and checks the result, so a renderer with a hard-coded height or color fails.
- **`expectAccessibleScreen`**: runs Flutter's tap-target and label guidelines over a gallery, in a theme, at a text scale and in a text direction.
- **Galleries** (`ButtonGallery`, `InputGallery`, `DialogGallery`, ...): one screen per component family, for screenshot goldens and the checks above.
- **`camoTestApp`**: your widget under a provider, with an overlay and the default shortcuts, at a text scale and direction.

## Usage

```dart
testWidgets('my skin keeps the button accessible', (tester) async {
  await expectAccessibleScreen(
    tester,
    skin: mySkin,
    theme: myTheme,
    child: const ButtonGallery(),
    textScale: 2,
  );
});
```

Every Camouflage skin package runs these checks in its own tests; see for example the `*_accessibility_test.dart` files in the [repository](https://github.com/srctool/camouflage-dart/tree/main/packages).

## Learn more

- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart

## License

Apache License 2.0, see [LICENSE](LICENSE).
