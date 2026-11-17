import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Carbon's scrollbar: a square 6 dp thumb that grows to 10 dp on a transparent track; shows while scrolling.
class CarbonScrollbarRenderer implements CamoScrollbarRenderer {
  /// Creates the renderer.
  const CarbonScrollbarRenderer();

  @override
  CamoScrollbarStyle defaults(CamoTheme theme) {
    final ink = theme.colors.onSurfaceVariant;
    return CamoScrollbarStyle(
      thickness: 6,
      hoverThickness: 10,
      minThumb: 32,
      visibility: CamoScrollbarVisibility.onScroll,
      hideDelay: const Duration(milliseconds: 1200),
      colors: CamoScrollbarColors(
        thumb: ink.withValues(alpha: 0.4),
        thumbHover: ink.withValues(alpha: 0.6),
        thumbDrag: ink.withValues(alpha: 0.8),
        track: const Color(0x00000000),
      ),
    );
  }

  @override
  Widget scrollbar(
    BuildContext context,
    CamoScrollbarState state,
    CamoTheme theme,
    CamoScrollbarStyle style,
  ) => SizedBox.expand(
    child: CustomPaint(
      painter: _ScrollbarPainter(
        state,
        style,
        Directionality.of(context) == TextDirection.rtl,
      ),
    ),
  );
}

class _ScrollbarPainter extends CustomPainter {
  const _ScrollbarPainter(this.state, this.style, this.rtl);

  final CamoScrollbarState state;
  final CamoScrollbarStyle style;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final active = state.hovered || state.dragging;
    final colors = style.colors;
    final color = state.dragging
        ? colors.thumbDrag
        : state.hovered
        ? colors.thumbHover
        : colors.thumb;
    final width = active ? style.hoverThickness : style.thickness;
    final vertical = state.axis == Axis.vertical;
    // The lane is as wide as the widest thumb; the thumb sits against the end edge.
    if (active && colors.track.a > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = colors.track);
    }
    final lateral = vertical
        ? (rtl ? 0.0 : size.width - width)
        : size.height - width;
    final rect = vertical
        ? Rect.fromLTWH(lateral, state.thumbStart, width, state.thumbLength)
        : Rect.fromLTWH(state.thumbStart, lateral, state.thumbLength, width);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.zero),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ScrollbarPainter old) =>
      old.state != state || old.style != style || old.rtl != rtl;
}
