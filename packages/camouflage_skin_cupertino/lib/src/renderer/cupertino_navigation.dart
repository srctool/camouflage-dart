import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_primitives.dart' show thumbColor;

// Cupertino's tabs and FAB (base Cupertino Skin §3.2): tabs are a segmented control (a gray track with a white thumb
// that slides to the selected tab; solid and ghost look the same); `scrollable` falls back to an underline row, since a
// segmented control can't scroll. The FAB is a circular prominent button.

const double _hairline = 0.5;
const double _trackPadding = 2;
const double _segmentRadius = 6;
const double _disabledAlpha = 0.38;
const _clear = Color(0x00000000);

/// Cupertino's tabs: a segmented control (an underline row when scrollable).
class CupertinoTabsRenderer implements CamoTabsRenderer {
  /// Creates the renderer.
  const CupertinoTabsRenderer();

  @override
  CamoTabsStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final segmented = TabsColors(
      container: c.secondaryContainer,
      selected: c.onSurface,
      unselected: c.onSurface,
      indicator: thumbColor(theme),
      divider: c.outlineVariant,
    );
    return CamoTabsStyle(
      defaultAppearance: Appearance.solid,
      height: 32,
      heightWithIcon: 48,
      indicatorHeight: 2,
      indicatorWidth: IndicatorWidth.tab,
      labelStyle: theme.typography.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
      ),
      iconSize: 16,
      iconGap: 6,
      tabPadding: 12,
      minTabWidth: 72,
      showDivider: true,
      solidColors: segmented,
      ghostColors: segmented,
    );
  }

  // The underline row a scrollable tab list falls back to (a segmented control can't scroll).
  static TabsColors _underline(CamoTheme theme) => TabsColors(
    container: _clear,
    selected: theme.colors.primary,
    unselected: theme.colors.onSurfaceVariant,
    indicator: theme.colors.primary,
    divider: theme.colors.outlineVariant,
  );

  @override
  Widget renderContainer(
    BuildContext context,
    TabsState state,
    CamoTheme theme,
    CamoTabsStyle style,
    Widget Function(CustomPainter indicatorPainter) row,
  ) {
    if (state.scrollable) {
      final lines = _underline(theme);
      return DecoratedBox(
        decoration: BoxDecoration(
          border: style.showDivider
              ? Border(
                  bottom: BorderSide(color: lines.divider, width: _hairline),
                )
              : null,
        ),
        child: row(
          _IndicatorPainter(
            indicator: state.indicator,
            color: lines.indicator,
            thickness: style.indicatorHeight,
          ),
        ),
      );
    }
    final colors = style.colorsFor(state.appearance);
    // The tabs fill the track (the whole node takes the press); the thumb is inset 2 inside the selected tab.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: theme.shapes.small,
      ),
      child: row(
        _ThumbPainter(
          indicator: state.indicator,
          color: colors.indicator,
          edge: colors.divider,
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
    final colors = state.scrollable
        ? _underline(theme)
        : style.colorsFor(state.appearance);
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

class _ThumbPainter extends CustomPainter {
  _ThumbPainter({
    required this.indicator,
    required this.color,
    required this.edge,
  }) : super(repaint: indicator);

  final ValueListenable<TabIndicator?> indicator;
  final Color color;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final place = indicator.value;
    if (place == null) return;
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        place.start + _trackPadding,
        _trackPadding,
        place.width - _trackPadding * 2,
        size.height - _trackPadding * 2,
      ),
      const Radius.circular(_segmentRadius),
    );
    canvas
      ..drawRRect(box, Paint()..color = color)
      ..drawRRect(
        box,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = _hairline,
      );
  }

  @override
  bool shouldRepaint(_ThumbPainter old) =>
      old.indicator != indicator || old.color != color || old.edge != edge;
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
    canvas.drawRect(
      Rect.fromLTWH(
        place.start,
        size.height - thickness,
        place.width,
        thickness,
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

/// Cupertino's FAB: a circular prominent button (capsule when extended), accent by default.
class CupertinoFabRenderer implements CamoFabRenderer {
  /// Creates the renderer.
  const CupertinoFabRenderer();

  @override
  CamoFabStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoFabStyle(
      defaultAppearance: Appearance.solid,
      size: FabSize.regular,
      sizeSmall: 44,
      sizeRegular: 56,
      sizeLarge: 64,
      extendedHeight: 50,
      shapeSmall: theme.shapes.full,
      shapeRegular: theme.shapes.full,
      shapeLarge: theme.shapes.full,
      iconSizeRegular: 24,
      iconSizeLarge: 28,
      iconGap: 8,
      extendedPadding: 20,
      textStyle: theme.typography.labelLarge,
      elevation: ElevationLevel.level2,
      softColors: FabColors(
        container: c.surfaceContainerHigh,
        content: c.onSurface,
      ),
      solidColors: FabColors(container: c.primary, content: c.onPrimary),
      raisedColors: FabColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
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
      elevation: raised ? theme.elevation.of(style.elevation) : 0,
      theme: theme,
      child: body,
    );
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: colors.content,
      shape: style.shape,
      theme: theme,
      child: Opacity(opacity: state.enabled ? 1 : _disabledAlpha, child: body),
    );
  }
}
