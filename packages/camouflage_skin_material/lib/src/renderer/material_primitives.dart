import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// Material's defaults for text, icons, surfaces, dividers and tooltips (base Material Skin §3.4).

const double _hairline = 1;

/// Material's text: theme styles, links in the primary color and underlined.
class MaterialTextRenderer implements CamoTextRenderer {
  /// Creates the renderer.
  const MaterialTextRenderer();

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

/// Material's icons: 20, `onSurface` by default (quieter than Material's 24).
class MaterialIconRenderer implements CamoIconRenderer {
  /// Creates the renderer.
  const MaterialIconRenderer();

  @override
  CamoIconStyle defaults(CamoTheme theme) =>
      CamoIconStyle(size: 24, color: theme.colors.onSurface);

  @override
  Widget render(BuildContext context, IconState state, CamoTheme theme) =>
      IconImage(state);
}

/// Material's surfaces: the skin's treatment, and a hairline when `border` is on.
class MaterialSurfaceRenderer implements CamoSurfaceRenderer {
  /// Creates the renderer.
  const MaterialSurfaceRenderer();

  @override
  CamoSurfaceStyle defaults(CamoTheme theme) => CamoSurfaceStyle(
    borderWidth: _hairline,
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

/// Material's dividers: a 1 px `outlineVariant` hairline, insets 16.
class MaterialDividerRenderer implements CamoDividerRenderer {
  /// Creates the renderer.
  const MaterialDividerRenderer();

  @override
  CamoDividerStyle defaults(CamoTheme theme) => CamoDividerStyle(
    thickness: _hairline,
    color: theme.colors.outlineVariant,
    startInset: theme.spacing.l,
    endInset: theme.spacing.l,
  );

  @override
  Widget render(
    BuildContext context,
    DividerState state,
    CamoTheme theme,
    CamoDividerStyle style,
  ) => _dividerLine(state, style);
}

/// Material's tooltip: `inverseSurface`, radius 6, `bodySmall`.
class MaterialTooltipRenderer implements CamoTooltipRenderer {
  /// Creates the renderer.
  const MaterialTooltipRenderer();

  @override
  CamoTooltipStyle defaults(CamoTheme theme) => CamoTooltipStyle(
    shape: theme.shapes.extraSmall,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    offset: 4,
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
          state.text,
          style: style.textStyle.copyWith(color: style.colors.text),
        ),
      ),
    ),
  );
}

// A divider line from the style: the thickness, the color and the directional insets.
Widget _dividerLine(DividerState state, CamoDividerStyle style) => Padding(
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
