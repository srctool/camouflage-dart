import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A [ClipRRect] that clips only what is painted. The semantics of its subtree keep their own bounds, so a control
/// that is drawn smaller than the minimum touch target and extends its semantics to it (`CamoTouchSemantics`) is
/// not cut off by the rounded container it sits in.
class CamoClipRRect extends ClipRRect {
  /// Creates the clip.
  const CamoClipRRect({
    super.key,
    super.borderRadius,
    super.clipBehavior,
    super.child,
  });

  @override
  RenderClipRRect createRenderObject(BuildContext context) =>
      _RenderPaintOnlyClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        textDirection: Directionality.of(context),
      );
}

class _RenderPaintOnlyClipRRect extends RenderClipRRect {
  _RenderPaintOnlyClipRRect({
    super.borderRadius,
    super.clipBehavior,
    super.textDirection,
  });

  // Neither the semantics clip nor the approximate paint clip is reported, so nothing in the subtree is cut off
  // from the screen reader's point of view (what is painted is still clipped).
  @override
  Rect? describeSemanticsClip(RenderObject? child) => null;

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => null;
}

/// A [PhysicalShape] that clips only what is painted, like [CamoClipRRect]: the semantics of its subtree keep their
/// own bounds, so a small control with a larger touch target (a chip's remove button) is not cut off by the
/// shape.
class CamoPhysicalShape extends PhysicalShape {
  /// Creates the shape.
  const CamoPhysicalShape({
    super.key,
    required super.clipper,
    super.clipBehavior,
    super.elevation,
    required super.color,
    super.shadowColor,
    super.child,
  });

  @override
  RenderPhysicalShape createRenderObject(BuildContext context) =>
      _RenderPaintOnlyPhysicalShape(
        clipper: clipper,
        clipBehavior: clipBehavior,
        elevation: elevation,
        color: color,
        shadowColor: shadowColor,
      );
}

class _RenderPaintOnlyPhysicalShape extends RenderPhysicalShape {
  _RenderPaintOnlyPhysicalShape({
    required super.clipper,
    super.clipBehavior,
    super.elevation = 0,
    required super.color,
    super.shadowColor,
  });

  // What is painted is still clipped; neither the semantics clip nor the approximate paint clip is reported.
  @override
  Rect? describeSemanticsClip(RenderObject? child) => null;

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => null;
}
