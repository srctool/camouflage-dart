import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Material's split pane divider: a 1 dp outlineVariant line with an 8 dp hit area; outline on hover, primary while dragged.
class MaterialSplitPaneRenderer implements CamoSplitPaneRenderer {
  /// Creates the renderer.
  const MaterialSplitPaneRenderer();

  @override
  CamoSplitPaneStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSplitPaneStyle(
      thickness: 1,
      hitSize: 8,
      keyStep: 16,
      keyStepLarge: 64,
      grip: false,
      colors: CamoSplitPaneColors(
        line: c.outlineVariant,
        hover: c.outline,
        dragging: c.primary,
        focus: c.primary,
      ),
    );
  }

  @override
  Widget divider(
    BuildContext context,
    SplitDividerState state,
    CamoTheme theme,
    CamoSplitPaneStyle style,
  ) => SizedBox.expand(
    child: CustomPaint(painter: _DividerPainter(state, style)),
  );
}

class _DividerPainter extends CustomPainter {
  const _DividerPainter(this.state, this.style);

  final SplitDividerState state;
  final CamoSplitPaneStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = style.colors;
    final color = state.dragging
        ? colors.dragging
        : state.hovered
        ? colors.hover
        : colors.line;
    final line = style.thickness;
    final vertical =
        state.axis ==
        Axis.horizontal; // a side-by-side split has vertical lines
    final rect = vertical
        ? Rect.fromLTWH((size.width - line) / 2, 0, line, size.height)
        : Rect.fromLTWH(0, (size.height - line) / 2, size.width, line);
    canvas.drawRect(rect, Paint()..color = color);
    if (state.focused) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = colors.focus
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_DividerPainter old) =>
      old.state != state || old.style != style;
}
