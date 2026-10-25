import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_tokens.dart';

/// Fluent's feedback. Under a Fluent theme the renderers swap fills to [FluentTokens]' hover and pressed steps
/// themselves, so `Subtle` draws only the keyboard focus indicator: Fluent's double stroke, 2 px `strokeFocus2`
/// outside and 1 px `strokeFocus1` inside. Under another theme it also draws a 4% / 8% content overlay, so hover
/// and press still show.
class Subtle implements InteractionFeedback {
  /// Creates the feedback.
  const Subtle();

  static const double _hover = 0.04;
  static const double _pressed = 0.08;

  @override
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  }) {
    final tokens = theme.tokens<FluentTokens>();
    final outer = tokens?.strokeFocus2 ?? theme.colors.onSurface;
    final inner = tokens?.strokeFocus1 ?? theme.colors.surface;
    return ListenableBuilder(
      listenable: controller,
      child: child,
      builder: (context, child) {
        final state = controller.value;
        final target = tokens != null
            ? 0.0
            : (state.pressed ? _pressed : (state.hovered ? _hover : 0.0));
        return TweenAnimationBuilder<double>(
          tween: Tween(end: target),
          duration: theme.motion.durationShort,
          child: child,
          builder: (context, alpha, child) => CustomPaint(
            foregroundPainter: _SubtlePainter(
              overlay: contentColor.withValues(alpha: contentColor.a * alpha),
              focus: controller.focusedByKeyboard && state.focused,
              outer: outer,
              inner: inner,
              shape: shape,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _SubtlePainter extends CustomPainter {
  _SubtlePainter({
    required this.overlay,
    required this.focus,
    required this.outer,
    required this.inner,
    required this.shape,
  });

  final Color overlay;
  final bool focus;
  final Color outer;
  final Color inner;
  final BorderRadius shape;

  static const double _outer = 2;
  static const double _inner = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final box = shape.toRRect(Offset.zero & size);
    if (overlay.a > 0) canvas.drawRRect(box, Paint()..color = overlay);
    if (!focus) return;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    // Both strokes sit inside the bounds: the outer one along the edge, the inner one just within it.
    canvas.drawRRect(box.deflate(_outer / 2), stroke(outer, _outer));
    canvas.drawRRect(box.deflate(_outer + _inner / 2), stroke(inner, _inner));
  }

  @override
  bool shouldRepaint(_SubtlePainter old) =>
      old.overlay != overlay ||
      old.focus != focus ||
      old.outer != outer ||
      old.inner != inner ||
      old.shape != shape;
}
