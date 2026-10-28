import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// DebugSkin's renderers: the contract's reference implementations (Skin Contract §3.5). They draw plain,
// labelled boxes from the style and theme, plus a magenta border for keyboard focus, so a skin's behavior can be
// checked before any real dialect exists.

const _debugFocus = Color(0xFFFF00FF);
const _clear = Color(0x00000000);

/// Plain text; links underlined in `primary`.
class DebugTextRenderer implements CamoTextRenderer {
  /// Creates the renderer.
  const DebugTextRenderer();

  @override
  TextStyle linkStyle(CamoTheme theme) => TextStyle(
    color: theme.colors.primary,
    decoration: TextDecoration.underline,
  );

  @override
  Widget render(BuildContext context, TextState state, CamoTheme theme) =>
      Text.rich(
        state.content,
        style: state.style.copyWith(color: state.color),
        maxLines: state.maxLines,
        overflow: state.overflow,
        textAlign: state.textAlign,
      );
}

/// The asset at its size and tint.
class DebugIconRenderer implements CamoIconRenderer {
  /// Creates the renderer.
  const DebugIconRenderer();

  @override
  CamoIconStyle defaults(CamoTheme theme) =>
      CamoIconStyle(size: 24, color: theme.colors.onSurface);

  @override
  Widget render(BuildContext context, IconState state, CamoTheme theme) =>
      IconImage(state);
}

/// The surface color through the skin's treatment.
class DebugSurfaceRenderer implements CamoSurfaceRenderer {
  /// Creates the renderer.
  const DebugSurfaceRenderer();

  @override
  CamoSurfaceStyle defaults(CamoTheme theme) => CamoSurfaceStyle(
    borderWidth: 1,
    borderColor: theme.colors.outlineVariant,
  );

  @override
  Widget render(
    BuildContext context,
    SurfaceState state,
    SurfaceSlots slots,
    CamoTheme theme,
    CamoSurfaceStyle style,
  ) {
    final shape = theme.shapes.of(state.shape);
    return Camouflage.skinOf(context).surfaceTreatment.decorate(
      color: theme.colors.surfaceOf(state.level),
      shape: shape,
      elevation: theme.elevation.of(state.elevation),
      theme: theme,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: shape,
          border: state.border
              ? Border.all(color: style.borderColor, width: style.borderWidth)
              : null,
        ),
        child: CamoContentStyle(
          color: theme.colors.onSurface,
          iconStyle: Camouflage.iconStyleOf(context)
              .copyWith(color: theme.colors.onSurface),
          child: slots.child,
        ),
      ),
    );
  }
}

/// A line from the style.
class DebugDividerRenderer implements CamoDividerRenderer {
  /// Creates the renderer.
  const DebugDividerRenderer();

  @override
  CamoDividerStyle defaults(CamoTheme theme) => CamoDividerStyle(
    thickness: 1,
    color: theme.colors.outlineVariant,
    startInset: 16,
    endInset: 16,
  );

  @override
  Widget render(
    BuildContext context,
    DividerState state,
    CamoTheme theme,
    CamoDividerStyle style,
  ) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: state.inset == DividerInset.none ? 0 : style.startInset,
      end: state.inset == DividerInset.middle ? style.endInset : 0,
    ),
    child: SizedBox(
      width: state.orientation == Axis.horizontal
          ? double.infinity
          : style.thickness,
      height: state.orientation == Axis.horizontal
          ? style.thickness
          : double.infinity,
      child: ColoredBox(color: style.color),
    ),
  );
}

/// A labelled box: `[appearance] text`, icons before and after.
class DebugButtonRenderer implements CamoButtonRenderer {
  /// Creates the renderer.
  const DebugButtonRenderer();

  @override
  CamoButtonStyle defaults(CamoTheme t) {
    final c = t.colors;
    return CamoButtonStyle(
      defaultAppearance: Appearance.solid,
      height: 40,
      minWidth: 64,
      shape: t.shapes.small,
      padding: EdgeInsetsDirectional.symmetric(horizontal: t.spacing.l),
      paddingWithIcon: EdgeInsetsDirectional.symmetric(horizontal: t.spacing.m),
      textStyle: t.typography.labelLarge,
      iconSize: 18,
      iconGap: t.spacing.s,
      borderWidth: 1,
      raisedElevation: ElevationLevel.level1,
      solidColors: ButtonColors(container: c.primary, content: c.onPrimary),
      softColors: ButtonColors(
        container: c.secondaryContainer,
        content: c.onSecondaryContainer,
      ),
      raisedColors: ButtonColors(
        container: c.surfaceContainerLow,
        content: c.primary,
        border: c.outlineVariant,
      ),
      outlineColors: ButtonColors(
        container: _clear,
        content: c.primary,
        border: c.outline,
      ),
      ghostColors: ButtonColors(container: _clear, content: c.primary),
      linkColors: ButtonColors(container: _clear, content: c.primary),
      disabledContainerAlpha: 0.12,
      disabledContentAlpha: 0.38,
    );
  }

  @override
  Widget render(
    BuildContext context,
    ButtonState s,
    ButtonSlots slots,
    CamoTheme t,
    CamoButtonStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final colors = style.colorsFor(s.appearance, s.tone, t);
    final content = s.enabled
        ? colors.content
        : disabled(t.colors.onSurface, style.disabledContentAlpha);
    final container = s.enabled || colors.container.a == 0
        ? colors.container
        : disabled(t.colors.onSurface, style.disabledContainerAlpha);
    final hasIcon = slots.prefixIcon != null || slots.suffixIcon != null;
    return skin.feedback.wrap(
      controller: s.controller,
      contentColor: content,
      shape: style.shape,
      theme: t,
      child: skin.surfaceTreatment.decorate(
        color: container,
        shape: style.shape,
        elevation: 0,
        theme: t,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: style.shape,
            border: s.controller.focusedByKeyboard && s.interaction.focused
                ? Border.all(color: _debugFocus, width: 2)
                : (colors.border == null
                      ? null
                      : Border.all(
                          color: colors.border!,
                          width: style.borderWidth,
                        )),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: style.height,
              minWidth: style.minWidth,
            ),
            child: Padding(
              padding: hasIcon ? style.paddingWithIcon : style.padding,
              child: CamoContentStyle(
                color: content,
                iconStyle: CamoIconStyle(size: style.iconSize, color: content),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: s.loading ? 0 : 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: style.iconGap,
                        children: [
                          ?slots.prefixIcon,
                          Flexible(
                            child: Text(
                              '[${s.appearance.name}] ${s.text}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: style.textStyle.copyWith(
                                color: content,
                                decoration: s.appearance == Appearance.link
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          ),
                          ?slots.suffixIcon,
                        ],
                      ),
                    ),
                    if (s.loading)
                      CamoProgressCircle(
                        size: ProgressSize.small,
                        tone: s.tone,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A square box around the icon.
class DebugIconButtonRenderer implements CamoIconButtonRenderer {
  /// Creates the renderer.
  const DebugIconButtonRenderer();

  @override
  CamoIconButtonStyle defaults(CamoTheme t) {
    final c = t.colors;
    return CamoIconButtonStyle(
      defaultAppearance: Appearance.ghost,
      containerSize: 40,
      shape: t.shapes.full,
      iconSize: 24,
      borderWidth: 1,
      solidColors: IconButtonColors(container: c.primary, content: c.onPrimary),
      softColors: IconButtonColors(
        container: c.secondaryContainer,
        content: c.onSecondaryContainer,
      ),
      outlineColors: IconButtonColors(
        container: _clear,
        content: c.onSurfaceVariant,
        border: c.outline,
      ),
      ghostColors: IconButtonColors(
        container: _clear,
        content: c.onSurfaceVariant,
      ),
      checkedColors: IconButtonColors(
        container: c.primary,
        content: c.onPrimary,
      ),
      disabledContainerAlpha: 0.12,
      disabledContentAlpha: 0.38,
    );
  }

  @override
  Widget render(
    BuildContext context,
    IconButtonState s,
    IconButtonSlots slots,
    CamoTheme t,
    CamoIconButtonStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final colors = style.colorsFor(
      s.appearance,
      s.tone,
      t,
      checked: s.checked ?? false,
    );
    final content = s.enabled
        ? colors.content
        : disabled(t.colors.onSurface, style.disabledContentAlpha);
    return skin.feedback.wrap(
      controller: s.controller,
      contentColor: content,
      shape: style.shape,
      theme: t,
      child: skin.surfaceTreatment.decorate(
        color: colors.container,
        shape: style.shape,
        elevation: 0,
        theme: t,
        child: SizedBox.square(
          dimension: style.containerSize,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: style.shape,
              border: s.controller.focusedByKeyboard && s.interaction.focused
                  ? Border.all(color: _debugFocus, width: 2)
                  : null,
            ),
            child: Center(
              child: s.loading
                  ? CamoProgressCircle(size: ProgressSize.small, tone: s.tone)
                  : CamoContentStyle(
                      color: content,
                      iconStyle: CamoIconStyle(
                        size: style.iconSize,
                        color: content,
                      ),
                      child: slots.icon,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A filled square for the fraction (debug: no animation needed).
class DebugProgressCircleRenderer implements CamoProgressCircleRenderer {
  /// Creates the renderer.
  const DebugProgressCircleRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) => CamoProgressStyle(
    circleStroke: 4,
    circleSizeSmall: 18,
    circleSizeMedium: 40,
    circleSizeLarge: 56,
    colors: ProgressColors(
      active: theme.colors.primary,
      track: theme.colors.outlineVariant,
    ),
    barHeight: 4,
    trackGap: 4,
    showStopIndicator: true,
  );

  @override
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  ) {
    final size = style.circleSizeOf(state.size);
    final active = state.tone == Tone.defaultTone
        ? style.colors.active
        : theme.colors.family(state.tone).strong;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: style.colors.track,
            width: style.circleStroke,
          ),
        ),
        child: FractionallySizedBox(
          heightFactor: state.value ?? 0.5,
          alignment: Alignment.bottomCenter,
          child: ColoredBox(color: active),
        ),
      ),
    );
  }
}

/// `[tooltip] text` on the inverse surface.
class DebugTooltipRenderer implements CamoTooltipRenderer {
  /// Creates the renderer.
  const DebugTooltipRenderer();

  @override
  CamoTooltipStyle defaults(CamoTheme theme) => CamoTooltipStyle(
    shape: const BorderRadius.all(Radius.circular(4)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    offset: 8,
    textStyle: theme.typography.bodySmall,
    showDelay: const Duration(milliseconds: 500),
    hideDelay: const Duration(milliseconds: 1500),
    maxWidth: 200,
    colors: TooltipColors(
      container: theme.colors.inverseSurface,
      text: theme.colors.inverseOnSurface,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    TooltipState state,
    CamoTheme theme,
    CamoTooltipStyle style,
  ) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: style.maxWidth),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: style.colors.container,
        borderRadius: style.shape,
      ),
      child: Padding(
        padding: style.padding,
        child: Text(
          '[tooltip] ${state.text}',
          style: style.textStyle.copyWith(color: style.colors.text),
        ),
      ),
    ),
  );
}
