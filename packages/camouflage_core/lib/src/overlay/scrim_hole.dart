import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// The overlay routes' scrim, painted by the page instead of the route's barrier, with a hole where the dialog or
// sheet sits. A see-through overlay (a backdrop blur, Fluent's Acrylic) then samples the page undimmed, the way
// Kotlin's recorded backdrop does; an opaque overlay looks the same either way.

/// What the route shares with the frame inside it: where the overlay box is, and a signal when it moves.
class ScrimHole extends InheritedWidget {
  /// Creates the scope.
  const ScrimHole({
    super.key,
    required this.box,
    required this.moved,
    required super.child,
  });

  /// Where the overlay's box registers itself (the frame wraps the box in a [ScrimHoleBox]).
  final HoleBox box;

  /// Bumped by the frame whenever the box moves (a drag), so the scrim repaints.
  final ScrimMoves moved;

  /// The nearest scope, or `null` outside a Camouflage route.
  static ScrimHole? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ScrimHole>();

  @override
  bool updateShouldNotify(ScrimHole old) =>
      old.box != box || old.moved != moved;
}

/// The overlay box's render object while it's attached.
class HoleBox {
  RenderBox? _render;

  /// The box, or `null` while it isn't laid out in the tree.
  RenderBox? get render {
    final r = _render;
    return r != null && r.attached && r.hasSize ? r : null;
  }
}

/// Marks [child] as the hole in the scrim.
class ScrimHoleBox extends SingleChildRenderObjectWidget {
  /// Creates the marker.
  const ScrimHoleBox({super.key, required this.box, super.child});

  /// Where to register.
  final HoleBox box;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHole(box);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderHole).box = box;
}

class _RenderHole extends RenderProxyBox {
  _RenderHole(this.box);

  HoleBox box;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    box._render = this;
  }

  @override
  void detach() {
    if (box._render == this) box._render = null;
    super.detach();
  }
}

/// A [ChangeNotifier] the frame can poke.
class ScrimMoves extends ChangeNotifier {
  /// Tells the scrim to repaint.
  void bump() => notifyListeners();
}

/// The scrim over the whole page, [opacity] of [color], minus the overlay box (found through [hole]) with the
/// corners [radius].
class ScrimPainter extends CustomPainter {
  /// Creates the painter.
  ScrimPainter({
    required this.color,
    required this.opacity,
    required this.hole,
    required this.radius,
    required this.self,
    required Listenable repaint,
  }) : super(repaint: repaint);

  /// The scrim at full opacity.
  final Color color;

  /// The route's animation: the scrim fades with it.
  final Animation<double> opacity;

  /// The overlay box.
  final HoleBox hole;

  /// The box's corners.
  final BorderRadius radius;

  /// The painter's own box, for the hole's position relative to it.
  final GlobalKey self;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = color.a * opacity.value.clamp(0.0, 1.0);
    if (alpha <= 0) return;
    final paint = Paint()..color = color.withValues(alpha: alpha);
    final page = Path()..addRect(Offset.zero & size);
    final box = hole.render;
    final own = self.currentContext?.findRenderObject();
    if (box == null || own is! RenderBox || !own.attached) {
      canvas.drawPath(page, paint);
      return;
    }
    // Through every transform between them (the slide, the scale), as it is this frame.
    final rect = MatrixUtils.transformRect(
      box.getTransformTo(own),
      Offset.zero & box.size,
    );
    final cut = Path()..addRRect(radius.toRRect(rect));
    canvas.drawPath(Path.combine(PathOperation.difference, page, cut), paint);
  }

  @override
  bool shouldRepaint(ScrimPainter old) => true;
}
