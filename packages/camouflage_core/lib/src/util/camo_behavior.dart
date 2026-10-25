import 'package:flutter/widgets.dart';

import '../skin/interaction.dart';

/// The behavior a component wraps around its renderer's output: focus and keyboard activation (Enter, Space),
/// hover, press positions for the [controller], and the [semantics] builder. Because it wraps the visual, a
/// renderer can't lose clicks or semantics.
class CamoBehavior extends StatelessWidget {
  /// Creates the behavior around [child].
  const CamoBehavior({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onActivate,
    required this.semantics,
    required this.child,
    this.focusNode,
  });

  /// Receives press, hover and focus.
  final CamoInteractionController controller;

  /// `false` blocks focus, hover and activation.
  final bool enabled;

  /// Called on a completed tap or on Enter / Space. `null` keeps the component focusable but inert.
  final VoidCallback? onActivate;

  /// Wraps [child] in the component's semantics.
  final Widget Function(Widget child) semantics;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  /// The renderer's output, usually inside a `CamoTouchTarget`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      enabled: enabled,
      focusNode: focusNode,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onFocusChange: (focused) => controller.setFocused(
        focused,
        byKeyboard:
            focused &&
            FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional,
      ),
      onShowHoverHighlight: controller.setHovered,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => onActivate?.call(),
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled
            ? (d) => controller.pressDown(d.localPosition)
            : null,
        onTapUp: enabled ? (_) => controller.pressEnd() : null,
        onTapCancel: enabled ? controller.pressEnd : null,
        onTap: enabled ? onActivate : null,
        child: semantics(child),
      ),
    );
  }
}
