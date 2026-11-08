# camouflage_skin_cupertino

[![pub package](https://img.shields.io/pub/v/camouflage_skin_cupertino.svg)](https://pub.dev/packages/camouflage_skin_cupertino)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**The Cupertino skin for [Camouflage](https://pub.dev/packages/camouflage_core).** Apple's design language for Camouflage, from the `widgets` layer: Apple's system colors, inset grouped lists, wheel pickers, a large collapsing title and glass materials.

A *skin* is the part of Camouflage that decides how every component looks and feels; the components themselves (`CamoButton`, `CamoTextField`, `CamoDialog`, ...) live in [`camouflage_core`](https://pub.dev/packages/camouflage_core) and know nothing about it. Swap the skin and the same screen is restyled, with no change to your widgets.

## Features

- Apple's HIG colors (systemBlue and friends, light and dark) and SF-style type
- Opacity feedback instead of a ripple; a 3 px focus ring for the keyboard
- Two surfaces: **Classic** (blur materials) and **Liquid Glass** (blur, tint and a specular edge)
- Inset grouped lists, centered alerts, wheel date and time pickers, segmented-control tabs
- All 52 components

## Getting started

```sh
flutter pub add camouflage_core camouflage_skin_cupertino
```

Wrap your app once with a `CamouflageProvider`, giving it this skin and one of its themes. The provider goes above the `Navigator`, so dialogs, menus and sheets inherit it:

```dart
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) => CamouflageProvider(
      skin: cupertinoSkin,
      theme: cupertinoTheme(),
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
cupertinoTheme()                 // the default light theme
cupertinoTheme(brightness: Brightness.dark)                  // dark
cupertinoTheme(accent: const Color(0xFF34C759))                 // your brand color
```

Choose the glass surface with `cupertinoSkinWith(surface: CupertinoSurface.liquidGlass)`; `cupertinoSkin` is Classic. On Flutter the glass has no edge refraction (that needs an Impeller-only shader); the Kotlin version has it. Apple's published system colors do not all reach WCAG AA, and the theme keeps them as published.

Every theme can be checked with `theme.validate()`, which reports contrast and value problems without changing a color.

## Other skins

Minimal, Fluent, Material, Cupertino and Carbon share the same components and the same contract: `camouflage_skin_minimal`, `camouflage_skin_fluent`, `camouflage_skin_material`, `camouflage_skin_cupertino`, `camouflage_skin_carbon`. You can write your own skin against the contract in `camouflage_core`; `camouflage_skin_testing` has the checks for it.

## Learn more

- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart
- The same library for Kotlin Multiplatform: [srctool/camouflage-kotlin](https://github.com/srctool/camouflage-kotlin)

## License

Apache License 2.0, see [LICENSE](LICENSE).
