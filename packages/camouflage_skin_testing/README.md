# camouflage_skin_testing

**Camouflage skin testing.** Test-only checks for any Camouflage skin: renderers keep the component's behavior, honor every component-theme field, and the galleries meet the accessibility guidelines. Use it in your own skin's tests.

```dart
await expectAccessibleScreen(tester, skin: mySkin, theme: myTheme, child: const ButtonGallery());
```

Part of [Camouflage](https://github.com/srctool/camouflage-dart), a UI library whose look comes from a swappable skin and theme, for Flutter and Kotlin Multiplatform. Documentation: https://github.com/srctool/camouflage.

Licensed under the Apache License 2.0.
