import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M7 data display components in the plain test skin: boxes and text, no decoration.

Widget _testIcon(double size, Color? color) => SizedBox.square(dimension: size);

class PlainChip implements CamoChipRenderer {
  const PlainChip();

  @override
  CamoChipStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final plain = ChipColors(
      container: c.surface,
      content: c.onSurface,
      border: c.outline,
    );
    return CamoChipStyle(
      defaultAppearance: Appearance.outline,
      height: 32,
      shape: BorderRadius.zero,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      iconPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      iconGap: 8,
      textStyle: theme.typography.labelLarge,
      iconSize: 18,
      borderWidth: 1,
      showCheckWhenSelected: true,
      outlineColors: plain,
      softColors: plain,
      solidColors: plain,
      selectedColors: ChipColors(container: c.primary, content: c.onPrimary),
      groupSpacing: 8,
      checkIcon: const IconSource.builder(_testIcon),
      removeIcon: const IconSource.builder(_testIcon),
    );
  }

  @override
  Widget render(
    BuildContext context,
    ChipState state,
    ChipSlots slots,
    CamoTheme theme,
    CamoChipStyle style,
  ) {
    final colors = style.colorsFor(state, theme);
    final showCheck = state.selected == true && style.showCheckWhenSelected;
    return Container(
      height: style.height,
      color: colors.container,
      padding: style.padding,
      child: CamoContentStyle(
        color: colors.content,
        iconStyle: CamoIconStyle(size: style.iconSize, color: colors.content),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheck) CamoIcon(style.checkIcon) else ?slots.leading,
            Text(state.label, maxLines: 1),
            ?slots.remove,
          ],
        ),
      ),
    );
  }
}

class PlainBadge implements CamoBadgeRenderer {
  const PlainBadge();

  @override
  CamoBadgeStyle defaults(CamoTheme theme) => CamoBadgeStyle(
    defaultAppearance: Appearance.solid,
    defaultTone: Tone.error,
    dotSize: 6,
    height: 16,
    minWidth: 16,
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
    textStyle: theme.typography.labelSmall,
    offset: const Offset(-4, 4),
    borderWidth: 1,
  );

  @override
  Widget render(
    BuildContext context,
    BadgeState state,
    CamoTheme theme,
    CamoBadgeStyle style,
  ) {
    final colors = style.colorsFor(state.appearance, state.tone, theme);
    final text = state.text;
    if (text == null) {
      return Container(
        width: style.dotSize,
        height: style.dotSize,
        color: colors.container,
      );
    }
    return Container(
      constraints: BoxConstraints(
        minHeight: style.height,
        minWidth: style.minWidth,
      ),
      color: colors.container,
      child: Text(text),
    );
  }
}

class PlainAvatar implements CamoAvatarRenderer {
  const PlainAvatar();

  @override
  CamoAvatarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoAvatarStyle(
      shape: AvatarShape.circle,
      roundedShape: theme.shapes.small,
      sizeSmall: 24,
      sizeMedium: 40,
      sizeLarge: 56,
      textStyleSmall: t.labelLarge,
      textStyleMedium: t.titleMedium,
      textStyleLarge: t.titleLarge,
      initialsPalette: [
        AvatarColors(
          container: c.primaryContainer,
          content: c.onPrimaryContainer,
        ),
        AvatarColors(container: c.infoContainer, content: c.onInfoContainer),
      ],
      neutralColors: AvatarColors(
        container: c.surfaceContainerHighest,
        content: c.onSurface,
      ),
      presenceSize: 10,
      presenceColors: PresenceColors(
        online: c.success,
        away: c.warning,
        busy: c.error,
        offline: c.outline,
        ring: c.surface,
      ),
      ringWidth: 2,
      groupOverlap: 8,
      personIcon: const IconSource.builder(_testIcon),
    );
  }

  @override
  Widget render(
    BuildContext context,
    AvatarState state,
    AvatarSlots slots,
    CamoTheme theme,
    CamoAvatarStyle style,
  ) {
    final colors = style.colorsFor(state);
    final initials = state.initials;
    return ClipRRect(
      borderRadius: style.shapeOf(state.shape, theme),
      child: Container(
        width: style.sizeOf(state.size),
        height: style.sizeOf(state.size),
        color: colors.container,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (initials != null)
              Text(initials)
            else
              CamoIcon(style.personIcon),
            ?slots.image,
          ],
        ),
      ),
    );
  }
}
