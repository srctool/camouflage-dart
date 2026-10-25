import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import '../fluent_tokens.dart';

// Fluent's text, icons, surfaces, dividers and tooltips (base Fluent Skin §3.2).

const double _stroke = 1;

/// Fluent's text: theme styles, links in the brand foreground, underlined.
class FluentTextRenderer implements CamoTextRenderer {
  /// Creates the renderer.
  const FluentTextRenderer();

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

/// Fluent's icons: 20 regular, `onSurface` by default.
class FluentIconRenderer implements CamoIconRenderer {
  /// Creates the renderer.
  const FluentIconRenderer();

  @override
  CamoIconStyle defaults(CamoTheme theme) =>
      CamoIconStyle(size: 20, color: theme.colors.onSurface);

  @override
  Widget render(BuildContext context, IconState state, CamoTheme theme) =>
      IconImage(state);
}

/// Fluent's surfaces: the skin's treatment, and a `neutralStroke2` border when `border` is on.
class FluentSurfaceRenderer implements CamoSurfaceRenderer {
  /// Creates the renderer.
  const FluentSurfaceRenderer();

  @override
  CamoSurfaceStyle defaults(CamoTheme theme) => CamoSurfaceStyle(
    borderWidth: _stroke,
    borderColor:
        theme.tokens<FluentTokens>()?.neutralStroke2 ??
        theme.colors.outlineVariant,
  );

  @override
  Widget render(
    BuildContext context,
    SurfaceState state,
    SurfaceSlots slots,
    CamoTheme theme,
    CamoSurfaceStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final shape = theme.shapes.of(state.shape);
    final icons = skin.icon.defaults(theme).merge(theme.components.icon);
    Widget content = ClipRRect(
      borderRadius: shape,
      child: CamoContentStyle(
        color: theme.colors.onSurface,
        iconStyle: icons.copyWith(color: theme.colors.onSurface),
        child: slots.child,
      ),
    );
    if (state.border) {
      content = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(
            color: style.borderColor,
            width: style.borderWidth,
          ),
        ),
        child: content,
      );
    }
    return skin.surfaceTreatment.decorate(
      color: theme.colors.surfaceOf(state.level),
      shape: shape,
      elevation: theme.elevation.of(state.elevation),
      theme: theme,
      child: content,
    );
  }
}

/// Fluent's divider: 1 px `neutralStroke2`.
class FluentDividerRenderer implements CamoDividerRenderer {
  /// Creates the renderer.
  const FluentDividerRenderer();

  @override
  CamoDividerStyle defaults(CamoTheme theme) => CamoDividerStyle(
    thickness: _stroke,
    color:
        theme.tokens<FluentTokens>()?.neutralStroke2 ??
        theme.colors.outlineVariant,
    startInset: theme.spacing.l,
    endInset: theme.spacing.l,
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

/// Fluent's tooltip: a neutral card with shadow16 (`level4`), caption1 text, padding 4 / 11 / 6.
class FluentTooltipRenderer implements CamoTooltipRenderer {
  /// Creates the renderer.
  const FluentTooltipRenderer();

  @override
  CamoTooltipStyle defaults(CamoTheme theme) => CamoTooltipStyle(
    shape: theme.shapes.small,
    padding: const EdgeInsets.fromLTRB(11, 4, 11, 6),
    offset: theme.spacing.xs,
    textStyle: theme.typography.bodySmall,
    showDelay: const Duration(milliseconds: 250),
    hideDelay: const Duration(milliseconds: 1500),
    maxWidth: 240,
    colors: TooltipColors(
      container: theme.colors.surface,
      text: theme.colors.onSurface,
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
    child: Camouflage.skinOf(context).surfaceTreatment.decorate(
      color: style.colors.container,
      shape: style.shape,
      elevation: theme.elevation.of(ElevationLevel.level4),
      theme: theme,
      child: Padding(
        padding: style.padding,
        child: Text(
          state.text,
          style: style.textStyle.copyWith(color: style.colors.text),
        ),
      ),
    ),
  );
}
