import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Cupertino's feedback: pressed content fades to 35% (no ripple, no overlay on touch), a pointer hovering adds a 4%
/// content-color layer, and keyboard focus draws a 3 px ring in `primary` just outside the shape. (Named
/// `OpacityFeedback` because Flutter has an `Opacity` widget.)
class OpacityFeedback implements InteractionFeedback {
  /// Creates the feedback.
  const OpacityFeedback();

  static const double _hover = 0.04;
  static const double _pressedContent = 0.35;

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
      return TweenAnimationBuilder<double>(
        tween: Tween(end: state.pressed ? 1.0 : 0.0),
        duration: theme.motion.durationShort,
        child: child,
        builder: (context, pressed, child) {
          final content = 1 - pressed * (1 - _pressedContent);
          final painted = CustomPaint(
            foregroundPainter: _OpacityPainter(
              overlay: state.hovered && !state.pressed
                  ? contentColor.withValues(alpha: contentColor.a * _hover)
                  : null,
              ring: controller.focusedByKeyboard && state.focused
                  ? theme.colors.primary
                  : null,
              shape: shape,
            ),
            child: child,
          );
          // The content as one group (a layer only while it is faded).
          return content >= 1
              ? painted
              : Opacity(opacity: content, child: painted);
        },
      );
    },
  );
}

class _OpacityPainter extends CustomPainter {
  _OpacityPainter({
    required this.overlay,
    required this.ring,
    required this.shape,
  });

  final Color? overlay;
  final Color? ring;
  final BorderRadius shape;

  static const double _ringWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final box = shape.toRRect(Offset.zero & size);
    final overlay = this.overlay;
    if (overlay != null) canvas.drawRRect(box, Paint()..color = overlay);
    final ring = this.ring;
    if (ring != null) {
      canvas.drawRRect(
        box.inflate(_ringWidth / 2),
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_OpacityPainter old) =>
      old.overlay != overlay || old.ring != ring || old.shape != shape;
}
