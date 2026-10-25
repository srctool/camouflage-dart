import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Minimal's feedback: a content-color overlay (4% hovered, 8% pressed), no ripple and no scale, and a 2 px
/// focus ring in `primary`, 2 px outside the shape, for keyboard focus only.
class Fade implements InteractionFeedback {
  /// Creates the feedback.
  const Fade();

  static const double _hover = 0.04;
  static const double _pressed = 0.08;

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
          foregroundPainter: _FadePainter(
            overlay: contentColor.withValues(alpha: contentColor.a * alpha),
            ring: controller.focusedByKeyboard && state.focused
                ? theme.colors.primary
                : null,
            shape: shape,
          ),
          child: child,
        ),
      );
    },
  );
}

class _FadePainter extends CustomPainter {
  _FadePainter({
    required this.overlay,
    required this.ring,
    required this.shape,
  });

  final Color overlay;
  final Color? ring;
  final BorderRadius shape;

  static const double _ringWidth = 2;
  static const double _ringOffset = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final box = shape.toRRect(Offset.zero & size);
    if (overlay.a > 0) canvas.drawRRect(box, Paint()..color = overlay);
    final ring = this.ring;
    if (ring != null) {
      canvas.drawRRect(
        box.inflate(_ringOffset + _ringWidth / 2),
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_FadePainter old) =>
      old.overlay != overlay || old.ring != ring || old.shape != shape;
}
