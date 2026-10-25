import 'package:flutter/widgets.dart';

import '../skin/camo_skin.dart';
import '../skin/content_style.dart';
import '../theme/camo_colors.dart';
import '../theme/camo_scales.dart';
import '../theme/camo_theme.dart';
import '../theme/camo_token_set.dart';
import '../theme/camo_typography.dart';

/// The skin and theme a `CamouflageProvider` puts into the tree. Either may be `null` when no provider
/// above sets it; the accessors in [Camouflage] fail fast on that.
class CamouflageScope extends InheritedWidget {
  /// Creates a scope. Apps use `CamouflageProvider` instead.
  const CamouflageScope({
    super.key,
    required this.skin,
    required this.theme,
    required super.child,
  });

  /// The effective skin.
  final CamoSkin? skin;

  /// The effective theme, with reduced motion applied.
  final CamoTheme? theme;

  /// The nearest scope, or `null` without a provider.
  static CamouflageScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CamouflageScope>();

  @override
  bool updateShouldNotify(CamouflageScope old) =>
      skin != old.skin || theme != old.theme;
}

/// The nearest `CamouflageProvider`'s values. Every accessor fails fast when there's no provider.
abstract final class Camouflage {
  /// The nearest effective skin. The error names [component].
  static CamoSkin skinOf(BuildContext context, {String component = 'widget'}) =>
      CamouflageScope.maybeOf(context)?.skin ??
      _missing(context, component, 'skin');

  /// The nearest effective theme, with reduced motion applied. The error names [component].
  static CamoTheme themeOf(
    BuildContext context, {
    String component = 'widget',
  }) =>
      CamouflageScope.maybeOf(context)?.theme ??
      _missing(context, component, 'theme');

  /// `themeOf(context).colors`.
  static CamoColors colorsOf(BuildContext context) => themeOf(context).colors;

  /// `themeOf(context).typography`.
  static CamoTypography typographyOf(BuildContext context) =>
      themeOf(context).typography;

  /// `themeOf(context).shapes`.
  static CamoShapes shapesOf(BuildContext context) => themeOf(context).shapes;

  /// `themeOf(context).spacing`.
  static CamoSpacing spacingOf(BuildContext context) =>
      themeOf(context).spacing;

  /// `themeOf(context).elevation`.
  static CamoElevation elevationOf(BuildContext context) =>
      themeOf(context).elevation;

  /// `themeOf(context).motion`.
  static CamoMotion motionOf(BuildContext context) => themeOf(context).motion;

  /// The content color set by the nearest container (`onSurface` at a provider).
  static Color contentColorOf(BuildContext context) =>
      CamoContentStyle.maybeColorOf(context) ??
      _missing(context, 'contentColorOf', 'content color');

  /// The icon size and color set by the nearest container.
  static CamoIconStyle iconStyleOf(BuildContext context) =>
      CamoContentStyle.maybeIconStyleOf(context) ??
      _missing(context, 'iconStyleOf', 'icon style');

  /// The theme's token set of type [T] (ADR-32). Fails fast, naming the set, when the theme lacks it.
  static T tokensOf<T extends CamoTokenSet<T>>(BuildContext context) =>
      themeOf(context).tokens<T>() ??
      _missing(context, 'tokensOf', 'token set $T in the theme');

  /// The nearest scope, or `null` without a provider.
  static CamouflageScope? maybeOf(BuildContext context) =>
      CamouflageScope.maybeOf(context);

  /// The skin, or `null` without a provider. For family packages only; `Camo*` widgets fail fast.
  static CamoSkin? maybeSkinOf(BuildContext context) => maybeOf(context)?.skin;

  /// The theme, or `null` without a provider. For family packages only; `Camo*` widgets fail fast.
  static CamoTheme? maybeThemeOf(BuildContext context) =>
      maybeOf(context)?.theme;

  static Never _missing(
    BuildContext context,
    String component,
    String missing,
  ) => throw FlutterError.fromParts([
    ErrorSummary(
      'No CamouflageProvider found above $component: missing $missing.',
    ),
    ErrorHint(
      'Wrap your app in CamouflageProvider(skin: …, theme: …), usually above WidgetsApp/MaterialApp '
      'so every route (dialogs included) can see it.',
    ),
    ...context.describeMissingAncestor(expectedAncestorType: CamouflageScope),
  ]);
}
