import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/camo_theme.dart';

/// The window's width class, from the theme's [CamoBreakpoints]: a phone, a tablet or foldable, a desktop
/// window.
enum WindowSizeClass {
  /// Below `medium` (phones).
  compact,

  /// From `medium` (small tablets, foldables).
  medium,

  /// From `expanded` (tablets, small desktop windows).
  expanded,

  /// From `large` (desktop windows).
  large,
}

/// How the user points: fingers (larger targets) or a mouse or trackpad (hover, denser UI).
enum InputMode {
  /// Fingers.
  touch,

  /// A mouse or trackpad.
  pointer,
}

/// The operating system the app runs on (`web` for a browser, whatever the OS underneath).
enum CamoPlatform {
  /// Android.
  android,

  /// iOS and iPadOS.
  ios,

  /// macOS.
  macOs,

  /// Windows.
  windows,

  /// Linux.
  linux,

  /// A browser.
  web,
}

/// What the platform can draw and what the user asked for (ADR-42). Skins pick a material's fallback from it:
/// [reduceTransparency] always wins, then [backdropBlur] / [runtimeShaders] / [windowMaterial] decide how far
/// down the chain a surface goes.
@immutable
class CamoCapabilities {
  /// Creates capabilities.
  const CamoCapabilities({
    required this.backdropBlur,
    required this.runtimeShaders,
    required this.windowMaterial,
    required this.reduceTransparency,
  });

  /// A blur of what's behind a surface (Acrylic, frosted bars).
  final bool backdropBlur;

  /// Custom fragment shaders (Liquid Glass's refraction).
  final bool runtimeShaders;

  /// A system window backdrop such as Windows 11's Mica.
  final bool windowMaterial;

  /// The user asked for opaque surfaces.
  final bool reduceTransparency;

  /// A copy with the given fields replaced.
  CamoCapabilities copyWith({
    bool? backdropBlur,
    bool? runtimeShaders,
    bool? windowMaterial,
    bool? reduceTransparency,
  }) => CamoCapabilities(
    backdropBlur: backdropBlur ?? this.backdropBlur,
    runtimeShaders: runtimeShaders ?? this.runtimeShaders,
    windowMaterial: windowMaterial ?? this.windowMaterial,
    reduceTransparency: reduceTransparency ?? this.reduceTransparency,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoCapabilities &&
      other.backdropBlur == backdropBlur &&
      other.runtimeShaders == runtimeShaders &&
      other.windowMaterial == windowMaterial &&
      other.reduceTransparency == reduceTransparency;

  @override
  int get hashCode => Object.hash(
    backdropBlur,
    runtimeShaders,
    windowMaterial,
    reduceTransparency,
  );
}

/// Where the app runs (ADR-41): the window's [windowSize], the [input] in use, the [platform] and its
/// [capabilities]. The root `CamouflageProvider` computes it; any provider can override it. Adaptive themes and
/// skins read it, so a theme can get denser with a pointer or a skin follow a platform convention.
@immutable
class CamoEnvironment {
  /// Creates an environment.
  const CamoEnvironment({
    required this.windowSize,
    required this.input,
    required this.platform,
    required this.capabilities,
  });

  /// The window's width class.
  final WindowSizeClass windowSize;

  /// The input in use.
  final InputMode input;

  /// The operating system.
  final CamoPlatform platform;

  /// What the platform can draw.
  final CamoCapabilities capabilities;

  /// A copy with the given fields replaced.
  CamoEnvironment copyWith({
    WindowSizeClass? windowSize,
    InputMode? input,
    CamoPlatform? platform,
    CamoCapabilities? capabilities,
  }) => CamoEnvironment(
    windowSize: windowSize ?? this.windowSize,
    input: input ?? this.input,
    platform: platform ?? this.platform,
    capabilities: capabilities ?? this.capabilities,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoEnvironment &&
      other.windowSize == windowSize &&
      other.input == input &&
      other.platform == platform &&
      other.capabilities == capabilities;

  @override
  int get hashCode => Object.hash(windowSize, input, platform, capabilities);
}

/// The window widths where each [WindowSizeClass] starts: below [medium] is `compact`. The defaults are
/// Material's window size classes (600 / 840 / 1200); a brand can move them in its theme.
@immutable
class CamoBreakpoints {
  /// Creates breakpoints.
  const CamoBreakpoints({
    this.medium = 600,
    this.expanded = 840,
    this.large = 1200,
  });

  /// Where `medium` starts.
  final double medium;

  /// Where `expanded` starts.
  final double expanded;

  /// Where `large` starts.
  final double large;

  /// The class of a window [width] wide.
  WindowSizeClass classify(double width) {
    if (width >= large) return WindowSizeClass.large;
    if (width >= expanded) return WindowSizeClass.expanded;
    if (width >= medium) return WindowSizeClass.medium;
    return WindowSizeClass.compact;
  }

  @override
  bool operator ==(Object other) =>
      other is CamoBreakpoints &&
      other.medium == medium &&
      other.expanded == expanded &&
      other.large == large;

  @override
  int get hashCode => Object.hash(medium, expanded, large);
}

/// A theme rule for an environment (ADR-41): returns the theme to use there, usually a copy with denser
/// component themes on `pointer` or another type scale on `expanded`. Add it with [CamoThemeAdapt.adapt].
typedef ThemeAdaptation = CamoTheme Function(
  CamoTheme theme,
  CamoEnvironment environment,
);

/// Adaptive themes (ADR-41).
extension CamoThemeAdapt on CamoTheme {
  /// This theme with an adaptive [rule] added after any it already has. The provider applies the rules once
  /// per environment change, so components still read one plain theme:
  /// `minimalLight.adapt((t, env) => env.input == InputMode.pointer ? t.copyWith(components: dense) : t)`.
  CamoTheme adapt(ThemeAdaptation rule) {
    final before = adaptation;
    return copyWith(
      adaptation: (theme, env) => rule(before?.call(theme, env) ?? theme, env),
    );
  }

  /// This theme for [environment]: its rules applied, the environment attached. A theme already adapted for that
  /// environment (one read from a provider and passed on) is returned as is, so its rules never run twice.
  CamoTheme forEnvironment(CamoEnvironment environment) {
    if (this.environment == environment) return this;
    final adapted = adaptation?.call(this, environment) ?? this;
    return adapted.copyWith(environment: environment, adaptation: adaptation);
  }
}

/// The usual input on [platform]: touch on phones and tablets, a pointer on desktops and in browsers.
InputMode defaultInput(CamoPlatform platform) => switch (platform) {
  CamoPlatform.android || CamoPlatform.ios => InputMode.touch,
  _ => InputMode.pointer,
};

/// The platform this code runs on.
CamoPlatform currentPlatform() {
  if (kIsWeb) return CamoPlatform.web;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.fuchsia => CamoPlatform.android,
    TargetPlatform.iOS => CamoPlatform.ios,
    TargetPlatform.macOS => CamoPlatform.macOs,
    TargetPlatform.windows => CamoPlatform.windows,
    TargetPlatform.linux => CamoPlatform.linux,
  };
}

/// The environment the platform reports: the window's width class by [breakpoints], the platform's usual
/// input, the platform and its capabilities. Flutter blurs with `BackdropFilter` and runs fragment shaders
/// everywhere; it reports no Reduce Transparency setting, and Mica is detected by the Fluent skin.
CamoEnvironment systemEnvironmentOf(
  BuildContext context,
  CamoBreakpoints breakpoints,
) {
  final width = MediaQuery.maybeSizeOf(context)?.width ?? 0;
  final platform = currentPlatform();
  return CamoEnvironment(
    windowSize: breakpoints.classify(width),
    input: defaultInput(platform),
    platform: platform,
    capabilities: const CamoCapabilities(
      backdropBlur: true,
      runtimeShaders: true,
      windowMaterial: false,
      reduceTransparency: false,
    ),
  );
}
