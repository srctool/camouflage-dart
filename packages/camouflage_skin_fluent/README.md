# camouflage_skin_fluent

[![pub package](https://img.shields.io/pub/v/camouflage_skin_fluent.svg)](https://pub.dev/packages/camouflage_skin_fluent)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**The Fluent skin for [Camouflage](https://pub.dev/packages/camouflage_core).** Microsoft's Fluent 2 for Camouflage: Solid, Acrylic and Mica surfaces, subtle feedback and a density that follows the input.

A *skin* is the part of Camouflage that decides how every component looks and feels; the components themselves (`CamoButton`, `CamoTextField`, `CamoDialog`, ...) live in [`camouflage_core`](https://pub.dev/packages/camouflage_core) and know nothing about it. Swap the skin and the same screen is restyled, with no change to your widgets.

## Features

- Three surface treatments: solid, **Acrylic** (blur for flyouts and dialogs) and **Mica**
- Subtle hover and press layers, a focus ring in the brand color
- Density that follows the input device (`FluentDensity`)
- A brand ramp derived from one color: `fluentTheme(brand:)`
- All 52 components

## Getting started

```sh
flutter pub add camouflage_core camouflage_skin_fluent
```

Wrap your app once with a `CamouflageProvider`, giving it this skin and one of its themes. The provider goes above the `Navigator`, so dialogs, menus and sheets inherit it:

```dart
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) => CamouflageProvider(
      skin: fluentSkinDefault,
      theme: fluentTheme(),
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
fluentTheme()                 // the default light theme
fluentTheme(brightness: Brightness.dark)                  // dark
fluentTheme(brand: const Color(0xFF8A3FFC))                 // your brand color
```

Pick a surface with `fluentSkin(surface: FluentSurface.acrylic)`; `fluentSkinDefault` is the solid one. The Acrylic blur falls back to a solid fill when `CamoCapabilities.reduceTransparency` is on. Flutter cannot detect that platform setting by itself, so set it through the `environment` of `CamouflageProvider` if you need it.

Every theme can be checked with `theme.validate()`, which reports contrast and value problems without changing a color.

## Other skins

Minimal, Fluent, Material, Cupertino and Carbon share the same components and the same contract: `camouflage_skin_minimal`, `camouflage_skin_fluent`, `camouflage_skin_material`, `camouflage_skin_cupertino`, `camouflage_skin_carbon`. You can write your own skin against the contract in `camouflage_core`; `camouflage_skin_testing` has the checks for it.

## Learn more

- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart
- The same library for Kotlin Multiplatform: [srctool/camouflage-kotlin](https://github.com/srctool/camouflage-kotlin)

## License

Apache License 2.0, see [LICENSE](LICENSE).
