import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Carbon's feedback: the fill moves to its hover and active step, drawn as a content-color overlay (8% hovered,
/// 20% pressed; no ripple, no scale), and keyboard focus is a 2 px `primary` border *inside* the bounds with a 1 px
/// `surface` line inside it (Carbon's focus never changes the layout and reads on a filled button).
class CarbonStates implements InteractionFeedback {
  /// Creates the feedback.
  const CarbonStates();

  static const double _hover = 0.08;
  static const double _pressed = 0.2;

  @override
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  }) => ListenableBuilder(
    listenable: controller,
    child: child,
    builder: (context, child) {
      final state = controller.value;
      final target = state.pressed ? _pressed : (state.hovered ? _hover : 0.0);
      return TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: theme.motion.durationShort,
        child: child,
        builder: (context, alpha, child) => CustomPaint(
          foregroundPainter: _StatesPainter(
            overlay: contentColor.withValues(alpha: contentColor.a * alpha),
            ring: controller.focusedByKeyboard && state.focused
                ? theme.colors.primary
                : null,
            inner: theme.colors.surface,
            shape: shape,
          ),
          child: child,
        ),
      );
    },
  );
}

class _StatesPainter extends CustomPainter {
  _StatesPainter({
    required this.overlay,
    required this.ring,
    required this.inner,
    required this.shape,
  });

  final Color overlay;
  final Color? ring;
  final Color inner;
  final BorderRadius shape;

  static const double _ringWidth = 2;
  static const double _innerWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final box = shape.toRRect(Offset.zero & size);
    if (overlay.a > 0) canvas.drawRRect(box, Paint()..color = overlay);
    final ring = this.ring;
    if (ring != null) {
      _stroke(canvas, box, _ringWidth, 0, ring);
      _stroke(canvas, box, _innerWidth, _ringWidth, inner);
    }
  }

  // A border of `width` inside the bounds, `offset` in from the edge (a stroke is centered on its path).
  void _stroke(Canvas canvas, RRect box, double width, double offset, Color c) {
    final path = box.deflate(offset + width / 2);
    if (path.width <= 0 || path.height <= 0) return;
    canvas.drawRRect(
      path,
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_StatesPainter old) =>
      old.overlay != overlay ||
      old.ring != ring ||
      old.inner != inner ||
      old.shape != shape;
}
