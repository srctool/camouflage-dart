import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../skin/positions.dart';

/// The row a checkbox, switch or radio renderer draws: [control] and [label] side by side in reading order
/// ([labelPosition] `start` puts the label first and pushes the control to the end), and [below] (an error
/// message) under them. With [centerControl] the control is centered on the whole label block (a switch);
/// otherwise it's centered on the label's first line, [firstLineHeight] tall (a checkbox, a radio).
class CamoLabelledControl extends StatelessWidget {
  /// Creates the row.
  const CamoLabelledControl({
    super.key,
    required this.labelPosition,
    required this.gap,
    required this.centerControl,
    required this.firstLineHeight,
    required this.control,
    this.label,
    this.below,
  });

  /// Which side the label sits on.
  final CamoLabelPosition labelPosition;

  /// The space between the control and the label.
  final double gap;

  /// Center the control on the label block instead of its first line.
  final bool centerControl;

  /// The label's first line height, for centering the control on it.
  final double firstLineHeight;

  /// The box, the circle or the track.
  final Widget control;

  /// The label and its description, if any.
  final Widget? label;

  /// Shown under the row, e.g. the error.
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final Widget row = label == null
        ? control
        : _LabelledRow(
            labelPosition: labelPosition,
            gap: gap,
            centerControl: centerControl,
            firstLineHeight: firstLineHeight,
            textDirection: Directionality.of(context),
            children: [control, label],
          );
    final below = this.below;
    if (below == null) return row;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [row, below],
    );
  }
}

// Lays out [control, label]: the control at its own size, the label in the rest of the width. A label at the
// start fills the bounded width, pushing the control to the end; otherwise the row is as wide as its content.
// Unlike a LayoutBuilder it reports intrinsic sizes, so it works inside IntrinsicHeight, tables and goldens.
class _LabelledRow extends MultiChildRenderObjectWidget {
  const _LabelledRow({
    required this.labelPosition,
    required this.gap,
    required this.centerControl,
    required this.firstLineHeight,
    required this.textDirection,
    required super.children,
  });

  final CamoLabelPosition labelPosition;
  final double gap;
  final bool centerControl;
  final double firstLineHeight;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderLabelledRow()
    ..labelPosition = labelPosition
    ..gap = gap
    ..centerControl = centerControl
    ..firstLineHeight = firstLineHeight
    ..textDirection = textDirection;

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLabelledRow renderObject,
  ) {
    renderObject
      ..labelPosition = labelPosition
      ..gap = gap
      ..centerControl = centerControl
      ..firstLineHeight = firstLineHeight
      ..textDirection = textDirection;
  }
}

class _RowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderLabelledRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RowParentData> {
  CamoLabelPosition _labelPosition = CamoLabelPosition.end;
  set labelPosition(CamoLabelPosition v) {
    if (v == _labelPosition) return;
    _labelPosition = v;
    markNeedsLayout();
  }

  double _gap = 0;
  set gap(double v) {
    if (v == _gap) return;
    _gap = v;
    markNeedsLayout();
  }

  bool _centerControl = true;
  set centerControl(bool v) {
    if (v == _centerControl) return;
    _centerControl = v;
    markNeedsLayout();
  }

  double _firstLineHeight = 0;
  set firstLineHeight(double v) {
    if (v == _firstLineHeight) return;
    _firstLineHeight = v;
    markNeedsLayout();
  }

  TextDirection _textDirection = TextDirection.ltr;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  RenderBox get _control => firstChild!;
  RenderBox get _label => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RowParentData) {
      child.parentData = _RowParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _control.getMinIntrinsicWidth(height) +
      _gap +
      _label.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _control.getMaxIntrinsicWidth(height) +
      _gap +
      _label.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) {
    final control = _control.getMaxIntrinsicWidth(double.infinity);
    final label = math.max(0.0, width - control - _gap);
    return math.max(
      _control.getMinIntrinsicHeight(control),
      _label.getMinIntrinsicHeight(label),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _layout(constraints, dry: true);

  @override
  void performLayout() => size = _layout(constraints, dry: false);

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    final loose = BoxConstraints(maxWidth: constraints.maxWidth);
    final controlSize = dry
        ? _control.getDryLayout(loose)
        : (_control..layout(loose, parentUsesSize: true)).size;
    final room = math.max(0.0, constraints.maxWidth - controlSize.width - _gap);
    final labelConstraints = BoxConstraints(maxWidth: room);
    final labelSize = dry
        ? _label.getDryLayout(labelConstraints)
        : (_label..layout(labelConstraints, parentUsesSize: true)).size;
    final fill =
        _labelPosition == CamoLabelPosition.start &&
        constraints.hasBoundedWidth;
    final width = fill
        ? constraints.maxWidth
        : controlSize.width + _gap + labelSize.width;
    final height = math.max(controlSize.height, labelSize.height);
    final size = constraints.constrain(Size(width, height));
    if (dry) return size;
    // Positions in reading order, then mirrored for RTL.
    final labelFirst = _labelPosition == CamoLabelPosition.start;
    final controlStart = labelFirst ? size.width - controlSize.width : 0.0;
    final labelStart = labelFirst ? 0.0 : controlSize.width + _gap;
    final controlTop = _centerControl
        ? (size.height - controlSize.height) / 2
        : math.max(0.0, (_firstLineHeight - controlSize.height) / 2);
    final labelTop = _centerControl
        ? (size.height - labelSize.height) / 2
        : 0.0;
    double x(double start, double w) =>
        _textDirection == TextDirection.rtl ? size.width - start - w : start;
    (_control.parentData! as _RowParentData).offset = Offset(
      x(controlStart, controlSize.width),
      controlTop,
    );
    (_label.parentData! as _RowParentData).offset = Offset(
      x(labelStart, labelSize.width),
      labelTop,
    );
    return size;
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
