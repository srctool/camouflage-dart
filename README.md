[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-Website-blue.svg)](https://camouflage-dev.srctool.com)

# camouflage-dart

Dart implementation of Camouflage (part of the SRC Tool). This repository is also included as the `dart-lib` submodule of the umbrella repository [srctool/camouflage](https://github.com/srctool/camouflage), which holds the documentation.

- Issues and pull requests for the Dart code go here, into `main`.
- Cross-platform design questions and documentation changes go to [srctool/camouflage](https://github.com/srctool/camouflage).

---

## Documentation

- Usage docs: https://camouflage.srctool.com
- Contributor docs (design, architecture, components, contributing): https://camouflage-dev.srctool.com

---

## Packages

| Package | Holds |
|---|---|
| `camouflage_core` | the components, `CamoTheme` and the Skin contract; visually neutral, no Material |
| `camouflage_skin_minimal` | the Minimal skin and `minimalTheme` |
| `camouflage_skin_testing` | test-only checks for any skin (M3) |
| `example` | the example app for Android, iOS, web, macOS, Windows and Linux, built on `WidgetsApp` |

Status: milestone **M0** (skeleton): every package holds a placeholder until its milestone.

---

## Development

The packages form a pub workspace managed by Melos:

```bash
dart pub global activate melos
flutter pub get          # resolves the whole workspace
melos run analyze
melos run format
melos run test
melos run layers         # the dependency layers, tool/layers.yaml
melos run no-material    # no Material or Cupertino imports in the packages
```

Run the example from `example/`: `flutter run` (pick a device), or `flutter run -d chrome --wasm`.
- Branch from `main`, open a PR into `main`, squash merge; releases are tags on `main`. See CONTRIBUTING.md.

---

## Code of Conduct

Participation is governed by CODE_OF_CONDUCT.md. For sensitive reports, email contact@srctool.com.

---

## License

Licensed under the Apache License, Version 2.0 (see LICENSE).