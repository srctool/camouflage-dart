import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// Material 3's feedback: a bounded ripple from the touch point, a state layer (8% hovered, 10% focused or
/// pressed) over the bounds, and a 3 px `primary` focus ring outside the shape for keyboard focus only. The ink
/// is `material_ui`'s `InkRipple`; the skin supplies a transparent `Material` so apps never need a `MaterialApp`.
class Ripple implements InteractionFeedback {
  /// Creates the feedback.
  const Ripple();

  @override
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  }) => mui.Material(
    type: mui.MaterialType.transparency,
    child: _InkLayer(
      controller: controller,
      color: contentColor,
      ring: theme.colors.primary,
      shape: shape,
      duration: theme.motion.durationShort,
      child: child,
    ),
  );
}

// The stateful part sits below the transparent `Material`, so the ripples it starts are disposed before it, as
// `InkWell` does.
class _InkLayer extends StatefulWidget {
  const _InkLayer({
    required this.controller,
    required this.color,
    required this.ring,
    required this.shape,
    required this.duration,
    required this.child,
  });

  final CamoInteractionController controller;
  final Color color;
  final Color ring;
  final BorderRadius shape;
  final Duration duration;
  final Widget child;

  @override
  State<_InkLayer> createState() => _InkLayerState();
}

class _InkLayerState extends State<_InkLayer> {
  static const double _hover = 0.08;
  static const double _focus = 0.10;
  static const double _pressed = 0.10;
  static const double _ringWidth = 3;

  final GlobalKey _box = GlobalKey();
  StreamSubscription<Offset>? _downs;
  StreamSubscription<void>? _ends;
  // Every ripple still on screen: a press that follows another one starts a new ripple beside the fading one.
  final Set<mui.InteractiveInkFeature> _inks = {};
  mui.InteractiveInkFeature? _latest;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(_InkLayer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _cancel();
      _listen();
    }
  }

  void _listen() {
    _downs = widget.controller.pressDowns.listen(_start);
    _ends = widget.controller.pressEnds.listen((_) => _latest?.confirm());
  }

  void _cancel() {
    _downs?.cancel();
    _ends?.cancel();
  }

  void _start(Offset position) {
    final box = _box.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    late final mui.InteractiveInkFeature ink;
    ink = mui.InkRipple(
      controller: mui.Material.of(_box.currentContext!),
      referenceBox: box,
      position: position,
      color: widget.color.withValues(alpha: widget.color.a * _pressed),
      containedInkWell: true,
      borderRadius: widget.shape,
      textDirection: Directionality.of(context),
      onRemoved: () {
        _inks.remove(ink);
        if (_latest == ink) _latest = null;
      },
    );
    _inks.add(ink);
    _latest = ink;
  }

  @override
  void dispose() {
    _cancel();
    for (final ink in _inks.toList()) {
      ink.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    child: KeyedSubtree(key: _box, child: widget.child),
    builder: (context, child) {
      final state = widget.controller.value;
      final ring = widget.controller.focusedByKeyboard && state.focused;
      final target = ring ? _focus : (state.hovered ? _hover : 0.0);
      return TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: widget.duration,
        child: child,
        builder: (context, alpha, child) => CustomPaint(
          foregroundPainter: _LayerPainter(
            overlay: widget.color.withValues(alpha: widget.color.a * alpha),
            ring: ring ? widget.ring : null,
            ringWidth: _ringWidth,
            shape: widget.shape,
          ),
          child: child,
        ),
      );
    },
  );
}

class _LayerPainter extends CustomPainter {
  _LayerPainter({
    required this.overlay,
    required this.ring,
    required this.ringWidth,
    required this.shape,
  });

  final Color overlay;
  final Color? ring;
  final double ringWidth;
  final BorderRadius shape;

  @override
  void paint(Canvas canvas, Size size) {
    final box = shape.toRRect(Offset.zero & size);
    if (overlay.a > 0) canvas.drawRRect(box, Paint()..color = overlay);
    final ring = this.ring;
    if (ring != null) {
      canvas.drawRRect(
        box.inflate(ringWidth / 2),
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_LayerPainter old) =>
      old.overlay != overlay ||
      old.ring != ring ||
      old.ringWidth != ringWidth ||
      old.shape != shape;
}
