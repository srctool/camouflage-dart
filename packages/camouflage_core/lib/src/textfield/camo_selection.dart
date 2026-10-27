import 'package:flutter/widgets.dart';

/// Plain round selection handles in [color], for skins that draw text selection without Material or Cupertino.
class CamoTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  /// Creates the controls.
  CamoTextSelectionControls(this.color);

  /// The handles' color.
  final Color color;

  static const double _size = 18;

  @override
  Size getHandleSize(double textLineHeight) => const Size(_size, _size);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      switch (type) {
        TextSelectionHandleType.left => const Offset(_size, 0),
        TextSelectionHandleType.right => Offset.zero,
        TextSelectionHandleType.collapsed => const Offset(_size / 2, 0),
      };

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    // A drop: round, with the corner that points at the text squared off.
    const r = Radius.circular(_size / 2);
    final shape = switch (type) {
      TextSelectionHandleType.left => const BorderRadius.only(
        topLeft: r,
        bottomLeft: r,
        bottomRight: r,
      ),
      TextSelectionHandleType.right => const BorderRadius.only(
        topRight: r,
        bottomLeft: r,
        bottomRight: r,
      ),
      TextSelectionHandleType.collapsed => const BorderRadius.all(r),
    };
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: _size,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, borderRadius: shape),
        ),
      ),
    );
  }
}

/// The platform's own context menu where Flutter supports it (iOS), and none elsewhere: copy and paste still work
/// from the keyboard.
Widget camoSystemContextMenu(
  BuildContext context,
  EditableTextState editableTextState,
) => SystemContextMenu.isSupported(context)
    ? SystemContextMenu.editableText(editableTextState: editableTextState)
    : const SizedBox.shrink();
