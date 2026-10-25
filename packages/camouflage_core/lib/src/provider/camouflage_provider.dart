import 'package:flutter/widgets.dart';

import '../skin/camo_skin.dart';
import '../skin/content_style.dart';
import '../theme/camo_theme.dart';
import 'camouflage.dart';

/// Puts a skin and a theme into the tree for every `Camo*` widget below. A `null` argument inherits the
/// value from the provider above, so nested providers can override just the skin or just the theme.
///
/// It applies reduced motion (`MediaQuery.disableAnimations`) to the theme once, and resets the content
/// color and icon style for its subtree. A provider with nothing to provide doesn't throw: the first
/// widget that needs the value does, by name.
class CamouflageProvider extends StatelessWidget {
  /// Creates a provider for [child].
  const CamouflageProvider({
    super.key,
    this.skin,
    this.theme,
    required this.child,
  });

  /// The skin for the subtree, or `null` to inherit it.
  final CamoSkin? skin;

  /// The theme for the subtree, or `null` to inherit it.
  final CamoTheme? theme;

  /// The subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parent = CamouflageScope.maybeOf(context);
    final effectiveSkin = skin ?? parent?.skin;
    final baseTheme = theme ?? parent?.theme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final effectiveTheme = baseTheme != null && reduceMotion
        ? baseTheme.copyWith(motion: baseTheme.motion.reduced())
        : baseTheme;
    // The root icon style is the icon component theme: the skin's defaults, then the theme's overrides.
    final rootIcon = effectiveSkin == null || effectiveTheme == null
        ? null
        : effectiveSkin.icon
              .defaults(effectiveTheme)
              .merge(effectiveTheme.components.icon);
    return CamouflageScope(
      skin: effectiveSkin,
      theme: effectiveTheme,
      child: rootIcon == null
          ? child
          : CamoContentStyle(
              color: effectiveTheme!.colors.onSurface,
              iconStyle: rootIcon,
              child: child,
            ),
    );
  }
}

/// A provider for widget previews and golden setups, on the theme's `surface`. Core has no default skin
/// (ADR-9), so both are required; skin packages ship their own shortcut, like `MinimalPreview`.
class CamouflagePreview extends StatelessWidget {
  /// Creates a preview of [child].
  const CamouflagePreview({
    super.key,
    required this.skin,
    required this.theme,
    required this.child,
  });

  /// The skin to preview with.
  final CamoSkin skin;

  /// The theme to preview with.
  final CamoTheme theme;

  /// The widget to preview.
  final Widget child;

  @override
  Widget build(BuildContext context) => CamouflageProvider(
    skin: skin,
    theme: theme,
    child: ColoredBox(color: theme.colors.surface, child: child),
  );
}

/// Pushes the route [route] builds, re-providing the skin and theme in effect at [context] inside it.
///
/// Routes are built under the `Navigator`, outside the caller's subtree, so a nested provider (a promo
/// section's theme) wouldn't reach a dialog it opens. This captures the values at the call site, as
/// `showCamoDialog` and `showCamoBottomSheet` do. The re-provided subtree is a new surface, so its content
/// color and icon style reset too.
Future<T?> pushCamoRoute<T extends Object?>(
  BuildContext context, {
  required WidgetBuilder builder,
  required Route<T> Function(WidgetBuilder builder) route,
  bool rootNavigator = true,
}) {
  final skin = Camouflage.skinOf(context, component: 'pushCamoRoute');
  final theme = Camouflage.themeOf(context, component: 'pushCamoRoute');
  return Navigator.of(context, rootNavigator: rootNavigator).push(
    route(
      (routeContext) => CamouflageProvider(
        skin: skin,
        theme: theme,
        child: Builder(builder: builder),
      ),
    ),
  );
}
