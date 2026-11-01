import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Fluent's TabList (a short rounded brand underline, no divider) and its FAB: Fluent has none, so the skin draws a
// prominent circular brand button with depth (base Fluent Skin §3.4).

const double _hairline = 1;
const double _disabledAlpha = 0.38;
const _clear = Color(0x00000000);

/// Fluent's TabList: a short rounded brand indicator under the content, no divider.
class FluentTabsRenderer implements CamoTabsRenderer {
  /// Creates the renderer.
  const FluentTabsRenderer();

  @override
  CamoTabsStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoTabsStyle(
      defaultAppearance: Appearance.solid,
      height: 44,
      heightWithIcon: 60,
      indicatorHeight: 2,
      indicatorWidth: IndicatorWidth.content,
      labelStyle: theme.typography.bodyMedium,
      iconSize: 20,
      iconGap: 6,
      tabPadding: 12,
      minTabWidth: 80,
      showDivider: false,
      solidColors: TabsColors(
        container: _clear,
        selected: c.onSurface,
        unselected: c.onSurfaceVariant,
        indicator: c.primary,
        divider: c.outlineVariant,
      ),
      ghostColors: TabsColors(
        container: _clear,
        selected: c.onSurface,
        unselected: c.onSurfaceVariant,
        indicator: c.onSurfaceVariant,
        divider: _clear,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    TabsState state,
    CamoTheme theme,
    CamoTabsStyle style,
    Widget Function(CustomPainter indicatorPainter) row,
  ) {
    final colors = style.colorsFor(state.appearance);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        border: style.showDivider
            ? Border(
                bottom: BorderSide(color: colors.divider, width: _hairline),
              )
            : null,
      ),
      child: row(
        _IndicatorPainter(
          indicator: state.indicator,
          color: colors.indicator,
          thickness: style.indicatorHeight,
        ),
      ),
    );
  }

  @override
  Widget renderTab(
    BuildContext context,
    TabState state,
    TabSlots slots,
    CamoTheme theme,
    CamoTabsStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final colors = style.colorsFor(state.appearance);
    final content = state.selected ? colors.selected : colors.unselected;
    final stacked =
        slots.child == null && slots.icon != null && slots.label != null;
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: theme.shapes.small,
      theme: theme,
      child: Opacity(
        opacity: state.enabled ? 1 : _disabledAlpha,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: stacked ? style.heightWithIcon : style.height,
            minWidth: state.scrollable ? style.minTabWidth : 0,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: style.tabPadding),
            child: Center(
              widthFactor: 1,
              child: CamoContentStyle(
                color: content,
                iconStyle: CamoIconStyle(size: style.iconSize, color: content),
                child: Row(
                  key: slots.contentKey,
                  mainAxisSize: MainAxisSize.min,
                  spacing: style.iconGap,
                  children: [
                    if (slots.child != null)
                      slots.child!
                    else ...[
                      ?slots.icon,
                      if (slots.label != null)
                        Flexible(
                          child: Text(
                            slots.label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style.labelStyle.copyWith(color: content),
                          ),
                        ),
                      ?slots.badge,
                    ],
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

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({
    required this.indicator,
    required this.color,
    required this.thickness,
  }) : super(repaint: indicator);

  final ValueListenable<TabIndicator?> indicator;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final place = indicator.value;
    if (place == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          place.start,
          size.height - thickness,
          place.width,
          thickness,
        ),
        Radius.circular(thickness / 2),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) =>
      old.indicator != indicator ||
      old.color != color ||
      old.thickness != thickness;
}

/// Fluent's FAB: a prominent circular brand button with depth.
class FluentFabRenderer implements CamoFabRenderer {
  /// Creates the renderer.
  const FluentFabRenderer();

  @override
  CamoFabStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoFabStyle(
      defaultAppearance: Appearance.solid,
      size: FabSize.regular,
      sizeSmall: 40,
      sizeRegular: 48,
      sizeLarge: 56,
      extendedHeight: 48,
      shapeSmall: theme.shapes.full,
      shapeRegular: theme.shapes.full,
      shapeLarge: theme.shapes.full,
      iconSizeRegular: 24,
      iconSizeLarge: 28,
      iconGap: 8,
      extendedPadding: 12,
      textStyle: theme.typography.labelLarge,
      elevation: ElevationLevel.level3,
      softColors: FabColors(
        container: c.surfaceContainerHigh,
        content: c.onSurface,
      ),
      solidColors: FabColors(container: c.primary, content: c.onPrimary),
      raisedColors: FabColors(container: c.surface, content: c.primary),
    );
  }

  @override
  Widget render(
    BuildContext context,
    FabState state,
    FabSlots slots,
    CamoTheme theme,
    CamoFabStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final colors = style.colorsFor(state, theme);
    final extended = state.extended;
    final raised = state.appearance == Appearance.raised;
    Widget body = ConstrainedBox(
      constraints: extended
          ? BoxConstraints(
              minWidth: style.extendedHeight,
              minHeight: style.extendedHeight,
            )
          : BoxConstraints.tightFor(
              width: style.containerSize,
              height: style.containerSize,
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: extended ? style.extendedPadding : 0,
        ),
        child: Center(
          widthFactor: 1,
          child: CamoContentStyle(
            color: colors.content,
            iconStyle: CamoIconStyle(
              size: style.iconSize,
              color: colors.content,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                slots.icon,
                if (extended)
                  AnimatedSize(
                    duration: theme.motion.durationMedium,
                    curve: theme.motion.easingStandard,
                    alignment: AlignmentDirectional.centerStart,
                    child: state.expanded
                        ? Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: style.iconGap,
                            ),
                            child: Text(
                              state.text!,
                              maxLines: 1,
                              style: style.textStyle.copyWith(
                                color: colors.content,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    body = skin.surfaceTreatment.decorate(
      color: colors.container,
      shape: style.shape,
      elevation: theme.elevation.of(style.elevation),
      theme: theme,
      child: body,
    );
    if (raised) {
      body = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: style.shape,
          border: Border.all(
            color: theme.colors.outlineVariant,
            width: _hairline,
          ),
        ),
        child: body,
      );
    }
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: colors.content,
      shape: style.shape,
      theme: theme,
      child: Opacity(opacity: state.enabled ? 1 : _disabledAlpha, child: body),
    );
  }
}
