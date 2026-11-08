# camouflage_skin_material

[![pub package](https://img.shields.io/pub/v/camouflage_skin_material.svg)](https://pub.dev/packages/camouflage_skin_material)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**The Material skin for [Camouflage](https://pub.dev/packages/camouflage_core).** Material 3 for Camouflage, drawn from the `widgets` layer: no `material.dart`, no `MaterialApp`, no Material theme to double-handle.

A *skin* is the part of Camouflage that decides how every component looks and feels; the components themselves (`CamoButton`, `CamoTextField`, `CamoDialog`, ...) live in [`camouflage_core`](https://pub.dev/packages/camouflage_core) and know nothing about it. Swap the skin and the same screen is restyled, with no change to your widgets.

## Features

- M3 proportions, shapes and state layers
- The M3 ink ripple, from the small `material_ui` package (the only Material code this skin uses)
- `materialTheme(seed:)` builds the whole color scheme from one seed color; without a seed, the M3 baseline
- All 52 components

## Getting started

```sh
flutter pub add camouflage_core camouflage_skin_material
```

Wrap your app once with a `CamouflageProvider`, giving it this skin and one of its themes. The provider goes above the `Navigator`, so dialogs, menus and sheets inherit it:

```dart
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_material/camouflage_skin_material.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) => CamouflageProvider(
      skin: materialSkin,
      theme: materialTheme(),
      child: child!,
    ),
    home: const MyHome(),
  ),
);
```

You do not need `MaterialApp`.

## Usage

Build screens from Camouflage components; they read the skin and theme from the provider:

```dart
CamoSurface(
  child: Column(
    children: [
      const CamoText('Create your account'),
      CamoTextField(value: email, onChanged: setEmail, label: 'Email'),
      CamoButton(text: 'Sign up', onPressed: submit),
    ],
  ),
)
```

A complete app is in [`example/main.dart`](example/main.dart). The [example app](https://github.com/srctool/camouflage-dart/tree/main/example) in the repository shows every component and lets you switch skin, brand and light or dark live.

## Themes

```dart
materialTheme()                 // the default light theme
materialTheme(brightness: Brightness.dark)                  // dark
materialTheme(seed: const Color(0xFF0B57D0))                 // your brand color
```

The package does not import `package:flutter/material.dart` and needs no `MaterialApp`: your app can use `WidgetsApp` and still get Material 3 components. Its one Material dependency is `material_ui`, for the ink ripple.

Every theme can be checked with `theme.validate()`, which reports contrast and value problems without changing a color.

## Other skins

Minimal, Fluent, Material, Cupertino and Carbon share the same components and the same contract: `camouflage_skin_minimal`, `camouflage_skin_fluent`, `camouflage_skin_material`, `camouflage_skin_cupertino`, `camouflage_skin_carbon`. You can write your own skin against the contract in `camouflage_core`; `camouflage_skin_testing` has the checks for it.

## Learn more

- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart
- The same library for Kotlin Multiplatform: [srctool/camouflage-kotlin](https://github.com/srctool/camouflage-kotlin)

## License

Apache License 2.0, see [LICENSE](LICENSE).
