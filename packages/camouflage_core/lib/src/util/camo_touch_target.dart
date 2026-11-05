import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The smallest touch target a component gets, whatever its visual size (WCAG 2.5.8, platform guidelines).
const double kCamoMinTouchTarget = 48;

/// Sizes itself to at least [minSize] and centers [child] in it. Taps anywhere in the target reach the child,
/// while the child paints at its own size.
class CamoTouchTarget extends SingleChildRenderObjectWidget {
  /// Creates a touch target around [child].
  const CamoTouchTarget({
    super.key,
    this.minSize = const Size.square(kCamoMinTouchTarget),
    super.child,
  });

  /// The smallest size of the target.
  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTouchTarget(minSize);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderTouchTarget).minSize = minSize;
  }
}

class _RenderTouchTarget extends RenderShiftedBox {
  _RenderTouchTarget(this._minSize) : super(null);

  Size _minSize;
  set minSize(Size value) {
    if (value == _minSize) return;
    _minSize = value;
    markNeedsLayout();
  }

  Size _sizeFor(Size childSize, BoxConstraints constraints) =>
      constraints.constrain(
        Size(
          math.max(childSize.width, _minSize.width),
          math.max(childSize.height, _minSize.height),
        ),
      );

  // Intrinsic sizes include the whole target, so IntrinsicWidth / IntrinsicHeight measure it right.
  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), _minSize.width);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(super.computeMaxIntrinsicWidth(height), _minSize.width);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), _minSize.height);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(super.computeMaxIntrinsicHeight(width), _minSize.height);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.constrain(_minSize);
    return _sizeFor(child.getDryLayout(constraints), constraints);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.constrain(_minSize);
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = _sizeFor(child.size, constraints);
    (child.parentData! as BoxParentData).offset = Alignment.center.alongOffset(
      size - child.size as Offset,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    final child = this.child;
    if (child == null || !size.contains(position)) return false;
    // Outside the child but inside the target: hit the child at its center.
    final center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => child.hitTest(result, position: center),
    );
  }
}

/// Makes the semantics of [child] cover at least [minSize], centered on it, without changing layout or painting:
/// the merged node a screen reader's explore-by-touch finds is the platform-sized target even when the control is
/// drawn smaller (the Kotlin `minimumTouchTarget` does the same for its touch bounds). The semantics of the
/// descendants merge into this one node, so use it around one interactive control, not around a group.
class CamoTouchSemantics extends SingleChildRenderObjectWidget {
  /// Creates the wrapper around [child].
  const CamoTouchSemantics({
    super.key,
    this.minSize = const Size.square(kCamoMinTouchTarget),
    super.child,
  });

  /// The smallest semantic size.
  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTouchSemantics(minSize);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderTouchSemantics).minSize = minSize;
  }
}

class _RenderTouchSemantics extends RenderProxyBox {
  _RenderTouchSemantics(this._minSize);

  Size _minSize;
  set minSize(Size value) {
    if (value == _minSize) return;
    _minSize = value;
    markNeedsSemanticsUpdate();
  }

  @override
  Rect get semanticBounds {
    final dx = math.max(0.0, (_minSize.width - size.width) / 2);
    final dy = math.max(0.0, (_minSize.height - size.height) / 2);
    return Rect.fromLTRB(-dx, -dy, size.width + dx, size.height + dy);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = true;
  }
}
