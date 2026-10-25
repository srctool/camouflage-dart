import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// A labelled placeholder drawn through the current skin, the way a renderer will draw a component (M3):
/// the behavior wrapper outside, then the skin's feedback and surface treatment, then the content style.
class DebugPlaceholder extends StatefulWidget {
  /// Creates a placeholder labelled [label].
  const DebugPlaceholder(this.label, {super.key, this.onPressed});

  /// The text after the skin's name.
  final String label;

  /// Called on tap, Enter or Space.
  final VoidCallback? onPressed;

  @override
  State<DebugPlaceholder> createState() => _DebugPlaceholderState();
}

class _DebugPlaceholderState extends State<DebugPlaceholder> {
  final _controller = CamoInteractionController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'DebugPlaceholder');
    final theme = Camouflage.themeOf(context, component: 'DebugPlaceholder');
    final colors = theme.colors;
    final shape = theme.shapes.medium;
    final rendered = skin.feedback.wrap(
      controller: _controller,
      contentColor: colors.onPrimaryContainer,
      shape: shape,
      theme: theme,
      child: skin.surfaceTreatment.decorate(
        color: colors.primaryContainer,
        shape: shape,
        elevation: 0,
        theme: theme,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.l,
              vertical: theme.spacing.s,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 1,
              child: CamoContentStyle(
                color: colors.onPrimaryContainer,
                iconStyle: CamoIconStyle(
                  size: 18,
                  color: colors.onPrimaryContainer,
                ),
                child: Text(
                  '[${skin.name}] ${widget.label}',
                  style: theme.typography.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // The behavior wraps what the renderer returns, so the whole box is tappable and focusable.
    // In a stretched column it keeps its own width, as the Kotlin placeholder does.
    final placeholder = Semantics(
      button: true,
      child: FocusableActionDetector(
        onShowFocusHighlight: (on) =>
            _controller.setFocused(on, byKeyboard: on),
        onShowHoverHighlight: _controller.setHovered,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed?.call(),
          ),
        },
        child: GestureDetector(
          onTapDown: (d) => _controller.pressDown(d.localPosition),
          onTapUp: (_) => _controller.pressEnd(),
          onTapCancel: _controller.pressEnd,
          onTap: widget.onPressed,
          child: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) => DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: shape,
                border: _controller.focusedByKeyboard
                    ? Border.all(color: const Color(0xFFFF00FF), width: 2)
                    : null,
              ),
              child: child,
            ),
            child: rendered,
          ),
        ),
      ),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: placeholder,
    );
  }
}
