# camouflage_core

[![pub package](https://img.shields.io/pub/v/camouflage_core.svg)](https://pub.dev/packages/camouflage_core)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**Components whose look comes from a swappable skin and theme.** Build a screen once; change the skin (Material, Cupertino, Fluent, Carbon, Minimal, or your own) or the theme (colors, type, shapes, motion, dark mode) and the whole app is restyled, with no change to your widgets.

`camouflage_core` holds the components, the theme, the skin contract and the provider. It is visually neutral and has **no Material or Cupertino dependency**: the look comes from a skin package you add next to it.

## Features

- **52 components** across actions, inputs and forms, structure, overlays, feedback, navigation and data (see the table below), all driven by the skin and theme.
- **Five ready skins:** [Minimal](https://pub.dev/packages/camouflage_skin_minimal), [Fluent](https://pub.dev/packages/camouflage_skin_fluent), [Material](https://pub.dev/packages/camouflage_skin_material), [Cupertino](https://pub.dev/packages/camouflage_skin_cupertino) and [Carbon](https://pub.dev/packages/camouflage_skin_carbon); and a contract to write your own.
- **A real theme system:** colors built from a seed (`CamoColors.fromSeed`), type scale, shapes, spacing, elevation, motion, component-level overrides and your own brand token sets. `theme.validate()` reports low-contrast pairs; it never silently changes a color.
- **Adaptive:** the provider reads the window size, input kind and platform and applies the theme's adaptive rules; a navigation bar, rail and drawer can be one adaptive layout.
- **Accessible by construction:** roles, names and states in the semantics, 48 dp touch targets, keyboard focus and arrow-key traversal, text scaling, right-to-left, and the platform's reduced-motion setting.
- **Works with `WidgetsApp`:** no `MaterialApp` required.

## Getting started

Add the core and one skin:

```sh
flutter pub add camouflage_core camouflage_skin_minimal
```

Wrap your app with a `CamouflageProvider` above the `Navigator`, so dialogs, menus and sheets inherit the skin and theme:

```dart
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) => CamouflageProvider(
      skin: minimalSkin,
      theme: minimalTheme(),
      child: child!,
    ),
    home: const MyHome(),
  ),
);
```

Using Material, Cupertino, Fluent or Carbon instead is a one-line change of `skin` and `theme`.

## Usage

```dart
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _email = '';
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.themeOf(context).spacing;
    return CamoSurface(
      child: Padding(
        padding: EdgeInsets.all(spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.m,
          children: [
            const CamoText('Create your account'),
            CamoTextField(
              value: _email,
              onChanged: (value) => setState(() => _email = value),
              label: 'Email',
            ),
            CamoCheckbox(
              checked: _terms,
              onChanged: (value) => setState(() => _terms = value),
              label: 'I agree to the terms',
            ),
            CamoButton(
              text: 'Sign up',
              onPressed: _terms && _email.isNotEmpty ? () {} : null,
            ),
          ],
        ),
      ),
    );
  }
}
```

Components take an `appearance` (`solid`, `soft`, `raised`, `outline`, `ghost`, `link`) and a `tone` (`defaultTone`, `error`, `success`, `warning`, `info`) instead of colors; the skin decides what they look like.

## Themes

```dart
// Colors from one seed color, light or dark.
final colors = CamoColors.fromSeed(primary: const Color(0xFF0B57D0));

// Every skin has its own starter theme and takes your brand color.
minimalTheme(accent: const Color(0xFF0B57D0));
materialTheme(seed: const Color(0xFF0B57D0), brightness: Brightness.dark);

// Check a theme: low-contrast pairs and invalid values are reported, never "fixed".
final issues = theme.validate();

// Animate between themes (a brand or dark-mode switch).
CamoAnimatedTheme(theme: theme, builder: (context, theme) => CamouflageProvider(...));
```

Per-component overrides (`CamoComponentThemes`) and your own token sets live on the theme too, so a brand can be a package of data.

## Components

| Family | Components |
|---|---|
| Text and surfaces | `CamoText`, `CamoIcon`, `CamoSurface`, `CamoDivider`, `CamoSkeleton` |
| Actions | `CamoButton`, `CamoIconButton`, `CamoFab`, `CamoButtonGroup`, `CamoSplitButton`, `CamoToolbar` |
| Inputs and forms | `CamoTextField`, `CamoSearchField`, `CamoCheckbox`, `CamoRadio`, `CamoSwitch`, `CamoSegmentedControl`, `CamoSlider`, `CamoStepper`, `CamoSelect`, `CamoDatePicker`, `CamoTimePicker`, `CamoRating`, `CamoFileUploader`, `CamoForm` and its rules |
| Structure and lists | `CamoCard`, `CamoListItem`, `CamoAccordion`, `CamoTopBar`, `CamoPagedList`, `CamoDataTable`, `CamoTree`, `CamoCarousel`, `CamoImage` |
| Overlays | `CamoDialog`, `CamoBottomSheet`, `CamoSideSheet`, `CamoPopover`, `CamoMenu`, `CamoTooltip` |
| Feedback and status | `CamoProgressCircle`, `CamoProgressBar`, `CamoProgressSteps`, `CamoSnackbar` and the messenger, `CamoBanner`, `CamoChip`, `CamoBadge`, `CamoAvatar` |
| Navigation | `CamoTabs`, `CamoNavigationBar`, `CamoNavigationRail`, `CamoNavigationDrawer`, `CamoBreadcrumb`, `CamoPagination` |

## Skins

| Package | Look |
|---|---|
| [`camouflage_skin_minimal`](https://pub.dev/packages/camouflage_skin_minimal) | flat, hairlines, ink primary |
| [`camouflage_skin_fluent`](https://pub.dev/packages/camouflage_skin_fluent) | Fluent 2: Solid, Acrylic, Mica |
| [`camouflage_skin_material`](https://pub.dev/packages/camouflage_skin_material) | Material 3 |
| [`camouflage_skin_cupertino`](https://pub.dev/packages/camouflage_skin_cupertino) | Apple HIG: Classic and glass materials |
| [`camouflage_skin_carbon`](https://pub.dev/packages/camouflage_skin_carbon) | IBM Carbon: square, layered |

Charts that follow the active skin are in [`camouflage_charts`](https://pub.dev/packages/camouflage_charts). To write your own skin, implement the renderers in the skin contract and test them with [`camouflage_skin_testing`](https://pub.dev/packages/camouflage_skin_testing).

## Example

[`example/`](https://github.com/srctool/camouflage-dart/tree/main/example) in the repository is an app that shows every component, with the skin, brand and light or dark switched live. It runs on Android, iOS, web, macOS, Windows and Linux.

## Learn more

- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart
- The same library for Kotlin Multiplatform: [srctool/camouflage-kotlin](https://github.com/srctool/camouflage-kotlin)

## License

Apache License 2.0, see [LICENSE](LICENSE).
