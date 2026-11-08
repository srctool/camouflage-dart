# camouflage_skin_carbon

[![pub package](https://img.shields.io/pub/v/camouflage_skin_carbon.svg)](https://pub.dev/packages/camouflage_skin_carbon)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**The Carbon skin for [Camouflage](https://pub.dev/packages/camouflage_core).** IBM Carbon for Camouflage, from the `widgets` layer: square corners, layered surfaces with no shadows, an inset focus border and a bold blue interactive color.

A *skin* is the part of Camouflage that decides how every component looks and feels; the components themselves (`CamoButton`, `CamoTextField`, `CamoDialog`, ...) live in [`camouflage_core`](https://pub.dev/packages/camouflage_core) and know nothing about it. Swap the skin and the same screen is restyled, with no change to your widgets.

## Features

- The White, G10, G90 and G100 themes from Carbon's published tokens
- Layered surfaces: each nested layer is one gray step, shadows only on overlays
- Text fields with a bottom border only, a 48 px square button with the label at the start
- An inset 2 px focus border that never moves the layout
- All 52 components

## Getting started

```sh
flutter pub add camouflage_core camouflage_skin_carbon
```

Wrap your app once with a `CamouflageProvider`, giving it this skin and one of its themes. The provider goes above the `Navigator`, so dialogs, menus and sheets inherit it:

```dart
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) => CamouflageProvider(
      skin: carbonSkin,
      theme: carbonTheme(),
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
carbonTheme()                 // the default light theme
carbonTheme(family: CarbonThemeFamily.g100)                  // dark
carbonTheme(accent: const Color(0xFF8A3FFC))                 // your brand color
```

`carbonTheme(family:)` takes `CarbonThemeFamily.white`, `g10`, `g90` or `g100`; `accent:` replaces only the `primary` family. The dark families use blue 50 with gray 100 text for contrast, and G90 fails WCAG AA on text over its two highest layers, as Carbon's own tokens do.

Every theme can be checked with `theme.validate()`, which reports contrast and value problems without changing a color.

## Other skins

Minimal, Fluent, Material, Cupertino and Carbon share the same components and the same contract: `camouflage_skin_minimal`, `camouflage_skin_fluent`, `camouflage_skin_material`, `camouflage_skin_cupertino`, `camouflage_skin_carbon`. You can write your own skin against the contract in `camouflage_core`; `camouflage_skin_testing` has the checks for it.

## Learn more

- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart
- The same library for Kotlin Multiplatform: [srctool/camouflage-kotlin](https://github.com/srctool/camouflage-kotlin)

## License

Apache License 2.0, see [LICENSE](LICENSE).
