import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';

/// The window edge a side frame slides in from: the start edge (the navigation drawer) or the end edge (a side
/// sheet).
enum SideEdge {
  /// The start edge.
  start,

  /// The end edge.
  end,
}

/// The modal frame shared by the modal drawer and the modal side sheet (ADR-30): a scrim, a panel of [width] (at
/// most 80% of the window) sliding in from [edge], drag toward the edge to dismiss, Esc and back, and focus kept
/// inside. Its visibility is state ([open]); the overlay stays until the slide-out has finished. Every dismissal
/// is [onDismissRequest], and the app decides whether to close it by setting [open] to `false`. Place it where an
/// `Overlay` is above it (inside a route).
class CamoSideFrame extends StatefulWidget {
  /// Creates a side frame.
  const CamoSideFrame({
    super.key,
    required this.edge,
    required this.open,
    required this.onDismissRequest,
    required this.width,
    required this.scrimAlpha,
    required this.child,
  });

  /// The edge it slides in from.
  final SideEdge edge;

  /// Whether the frame is shown.
  final bool open;

  /// Called by a scrim tap, back, Esc or a drag toward the edge.
  final VoidCallback onDismissRequest;

  /// The panel's width, at most 80% of the window.
  final double width;

  /// The scrim's alpha while the panel is fully in.
  final double scrimAlpha;

  /// The panel's content.
  final Widget child;

  @override
  State<CamoSideFrame> createState() => _CamoSideFrameState();
}

class _CamoSideFrameState extends State<CamoSideFrame>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  late final _controller = AnimationController(vsync: this);
  var _duration = const Duration(milliseconds: 200);
  Curve _curve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _portal.isShowing) {
        _portal.hide();
      }
    });
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(CamoSideFrame old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      if (widget.open) {
        // The portal can't be shown while the tree is building.
        WidgetsBinding.instance.addPostFrameCallback((_) => _show());
      } else {
        _controller.animateBack(0, duration: _duration, curve: _curve);
      }
    }
  }

  void _show() {
    if (!mounted) return;
    _portal.show();
    _controller.animateTo(1, duration: _duration, curve: _curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoSideFrame');
    _duration = theme.motion.durationMedium;
    _curve = theme.motion.easingEmphasized;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // The direction of a horizontal drag that closes the panel: toward the edge it is attached to.
    final closeDirection = (widget.edge == SideEdge.start) != rtl ? -1.0 : 1.0;
    return PopScope(
      canPop: !widget.open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onDismissRequest();
      },
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape):
                widget.onDismissRequest,
          },
          child: FocusScope(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = widget.width < constraints.maxWidth * 0.8
                    ? widget.width
                    : constraints.maxWidth * 0.8;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;
                    final panel = GestureDetector(
                      onHorizontalDragUpdate: (d) => _controller.value -=
                          d.delta.dx * closeDirection / width,
                      onHorizontalDragEnd: (d) {
                        final velocity =
                            (d.primaryVelocity ?? 0) * closeDirection;
                        if (_controller.value < 0.6 || velocity > 1200) {
                          widget.onDismissRequest();
                        } else {
                          _controller.animateTo(
                            1,
                            duration: _duration,
                            curve: _curve,
                          );
                        }
                      },
                      child: child,
                    );
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onDismissRequest,
                            child: ColoredBox(
                              color: theme.colors.scrim.withValues(
                                alpha: widget.scrimAlpha * t,
                              ),
                            ),
                          ),
                        ),
                        if (widget.edge == SideEdge.start)
                          PositionedDirectional(
                            start: -width * (1 - t),
                            top: 0,
                            bottom: 0,
                            width: width,
                            child: panel,
                          )
                        else
                          PositionedDirectional(
                            end: -width * (1 - t),
                            top: 0,
                            bottom: 0,
                            width: width,
                            child: panel,
                          ),
                      ],
                    );
                  },
                  child: widget.child,
                );
              },
            ),
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
