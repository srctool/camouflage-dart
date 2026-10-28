import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'debug_renderers.dart';

// The M7 feedback components in the debug skin: boxes, rows and plain text.

Widget _square(double size, Color? color) => SizedBox.square(dimension: size);

/// The debug skin's progressBar renderer.
class DebugProgressBarRenderer implements CamoProgressBarRenderer {
  /// Creates the renderer.
  const DebugProgressBarRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) =>
      const DebugProgressCircleRenderer().defaults(theme);

  @override
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  ) {
    final colors = style.colorsFor(state.tone, theme);
    return Container(
      height: style.barHeight,
      color: colors.track,
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: state.value ?? 1,
        child: ColoredBox(color: colors.active),
      ),
    );
  }
}

/// The debug skin's snackbar renderer.
class DebugSnackbarRenderer implements CamoSnackbarRenderer {
  /// Creates the renderer.
  const DebugSnackbarRenderer();

  @override
  CamoSnackbarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSnackbarStyle(
      shape: BorderRadius.zero,
      maxWidth: 560,
      margin: 16,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      minHeight: 48,
      textStyle: theme.typography.bodyMedium,
      actionStyle: theme.typography.labelLarge,
      elevation: ElevationLevel.level3,
      position: SnackbarPosition.bottom,
      alignment: SnackbarAlignment.center,
      showDismiss: false,
      showToneIcon: false,
      durationShort: const Duration(seconds: 4),
      durationLong: const Duration(seconds: 10),
      colors: SnackbarColors(
        container: c.inverseSurface,
        text: c.inverseOnSurface,
        action: c.inversePrimary,
      ),
      dismissIcon: const IconSource.builder(_square),
    );
  }

  @override
  Widget render(
    BuildContext context,
    SnackbarState state,
    SnackbarSlots slots,
    CamoTheme theme,
    CamoSnackbarStyle style,
  ) {
    final colors = style.colorsFor(state.tone, theme);
    Widget tinted(Color color, Widget child) => CamoContentStyle(
      color: color,
      iconStyle: CamoIconStyle(size: 24, color: color),
      child: child,
    );
    return Container(
      constraints: BoxConstraints(minHeight: style.minHeight),
      color: colors.container,
      padding: style.padding,
      child: Row(
        children: [
          if (slots.icon != null) tinted(colors.text, slots.icon!),
          Expanded(child: Text(state.message)),
          if (slots.action != null) tinted(colors.action, slots.action!),
          if (slots.dismiss != null) tinted(colors.text, slots.dismiss!),
        ],
      ),
    );
  }
}

/// The debug skin's banner renderer.
class DebugBannerRenderer implements CamoBannerRenderer {
  /// Creates the renderer.
  const DebugBannerRenderer();

  @override
  CamoBannerStyle defaults(CamoTheme theme) => CamoBannerStyle(
    defaultAppearance: Appearance.soft,
    shape: BorderRadius.zero,
    padding: const EdgeInsetsDirectional.all(16),
    titleStyle: theme.typography.titleSmall,
    messageStyle: theme.typography.bodyMedium,
    iconSize: 24,
    accentBorder: false,
    accentWidth: 4,
    borderWidth: 1,
    toneIcons: const ToneIcons(
      info: IconSource.builder(_square),
      success: IconSource.builder(_square),
      warning: IconSource.builder(_square),
      error: IconSource.builder(_square),
    ),
    dismissIcon: const IconSource.builder(_square),
  );

  @override
  Widget render(
    BuildContext context,
    BannerState state,
    BannerSlots slots,
    CamoTheme theme,
    CamoBannerStyle style,
  ) {
    final colors = style.colorsFor(state.appearance, state.tone, theme);
    return Container(
      color: colors.container,
      padding: style.padding,
      child: CamoContentStyle(
        color: colors.content,
        iconStyle: CamoIconStyle(size: style.iconSize, color: colors.content),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?slots.icon,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.title != null) Text(state.title!),
                  Text(state.message),
                  if (slots.actions.isNotEmpty)
                    CamoContentStyle(
                      color: colors.accent,
                      iconStyle: CamoIconStyle(
                        size: style.iconSize,
                        color: colors.accent,
                      ),
                      child: Row(children: slots.actions),
                    ),
                ],
              ),
            ),
            ?slots.dismiss,
          ],
        ),
      ),
    );
  }
}
