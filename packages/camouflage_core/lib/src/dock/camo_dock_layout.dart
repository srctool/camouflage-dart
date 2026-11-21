import 'dart:ui' show PointMode;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../menu/camo_menu_anchor.dart';
import '../provider/camouflage.dart';
import '../split_pane/camo_split_pane.dart';
import '../surface/camo_surface.dart';
import '../text/camo_text.dart';
import '../theme/roles.dart';
import 'camo_dock_model.dart';

const _defaultStripe = 36.0;
const _defaultMinDock = 160.0;
const _minStacked = 80.0;
const _minCenterShare = 0.1;
const _buttonGap = 4.0;
const _narrowHeader = 150.0;

/// IDE-style tool windows around [center]: side and bottom docks that open from icon stripes on the window's
/// edges. A stripe button toggles its tool window; several open windows on one edge stack in a split of their own.
/// Docks resize through the split pane's divider (keys and screen reader included), a window's header hides,
/// maximizes and moves it to another edge, and `state.focus(id)` opens a window and moves keyboard focus into it;
/// Esc inside one returns focus to the center. The [state] is the app's; it can be saved and restored. Left and
/// right mean start and end, so they swap in right-to-left layouts.
///
/// Built from the split pane, icon buttons and menus, so every skin draws it and it needs no renderer of its own.
class CamoDockLayout extends StatefulWidget {
  /// Creates a dock layout.
  const CamoDockLayout({
    super.key,
    required this.state,
    required this.toolWindows,
    required this.center,
  });

  /// The layout, owned by the app.
  final CamoDockState state;

  /// Every tool window; the state holds where each one is.
  final List<CamoToolWindow> toolWindows;

  /// The main content.
  final Widget center;

  @override
  State<CamoDockLayout> createState() => _CamoDockLayoutState();
}

class _CamoDockLayoutState extends State<CamoDockLayout> {
  final _centerNode = FocusNode(
    debugLabel: 'dock center',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final _nodes = <Object, FocusNode>{};
  final _splits = <String, CamoSplitState>{};
  int _generation = 0;
  int _focusSeen = 0;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_changed);
    _generation = widget.state.generation;
    _focusSeen = widget.state.focusCount;
  }

  @override
  void didUpdateWidget(CamoDockLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_changed);
      widget.state.addListener(_changed);
      _resetSplits();
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_changed);
    _centerNode.dispose();
    for (final node in _nodes.values) {
      node.dispose();
    }
    for (final split in _splits.values) {
      split.dispose();
    }
    super.dispose();
  }

  void _resetSplits() {
    for (final split in _splits.values) {
      split.dispose();
    }
    _splits.clear();
  }

  void _changed() {
    final state = widget.state;
    if (state.generation != _generation) {
      _generation = state.generation;
      _resetSplits();
    }
    setState(() {});
    if (state.focusCount != _focusSeen) {
      _focusSeen = state.focusCount;
      final target = state.focusTarget;
      // After the window has been built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && target != null) _focusInto(_node(target));
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  FocusNode _node(Object id) => _nodes.putIfAbsent(
    id,
    () => FocusNode(
      debugLabel: 'tool window $id',
      canRequestFocus: false,
      skipTraversal: true,
    ),
  );

  // The first focusable thing inside [node], or the node itself.
  void _focusInto(FocusNode node) {
    final inside = node.traversalDescendants.firstOrNull;
    (inside ?? node).requestFocus();
  }

  // Esc inside a window: focus goes to the center, or just out of the window when the center has nothing to focus.
  void _leaveToCenter() {
    final inside = _centerNode.traversalDescendants.firstOrNull;
    if (inside != null) {
      inside.requestFocus();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  // A split of docks keeps its own state, which writes the dragged sizes back.
  CamoSplitState _split(String key, List<DockEdge?> edges) =>
      _splits.putIfAbsent(key, () {
        final state = widget.state;
        final docks = edges.nonNulls.fold<double>(
          0,
          (sum, e) => sum + state.sizeOf(e),
        );
        final split = CamoSplitState([
          for (final e in edges)
            e == null
                ? (1 - docks).clamp(_minCenterShare, 1.0)
                : state.sizeOf(e),
        ]);
        split.addListener(() {
          final f = split.fractions;
          for (var i = 0; i < edges.length; i++) {
            final edge = edges[i];
            if (edge != null) state.setSize(edge, f[i]);
          }
        });
        return split;
      });

  CamoSplitState _equal(String key, int count) =>
      _splits.putIfAbsent(key, () => CamoSplitState(List.filled(count, 1)));

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final byId = {for (final w in widget.toolWindows) w.id: w};
    assert(
      state.ids.every(byId.containsKey),
      'CamoDockLayout: the state has tool windows that were not passed in.',
    );
    final o = Camouflage.themeOf(
      context,
      component: 'CamoDockLayout',
    ).components.dock;
    final strings = o?.strings ?? const DockStrings();
    final stripe = o?.stripeSize ?? _defaultStripe;
    final minDock = o?.minDock ?? _defaultMinDock;
    Widget stripeOf(DockEdge edge) {
      final onEdge = [for (final id in state.windowsOn(edge)) byId[id]!];
      return onEdge.isEmpty
          ? const SizedBox.shrink()
          : _Stripe(edge, onEdge, state, stripe, strings);
    }

    final maximized = state.maximized == null ? null : byId[state.maximized];
    return Row(
      children: [
        stripeOf(DockEdge.left),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: maximized != null
                    ? _panel(maximized, strings)
                    : _docks(byId, strings, minDock),
              ),
              stripeOf(DockEdge.bottom),
            ],
          ),
        ),
        stripeOf(DockEdge.right),
      ],
    );
  }

  Widget _docks(
    Map<Object, CamoToolWindow> byId,
    DockStrings strings,
    double minDock,
  ) {
    final state = widget.state;
    Widget? stack(DockEdge edge) {
      final open = [for (final id in state.openOn(edge)) byId[id]!];
      if (open.isEmpty) return null;
      if (open.length == 1) return _panel(open.single, strings);
      final key =
          'stack:${edge.name}:${[for (final w in open) w.id].join(',')}';
      return CamoSplitPane(
        axis: edge == DockEdge.bottom ? Axis.horizontal : Axis.vertical,
        state: _equal(key, open.length),
        panes: [
          for (final w in open)
            CamoPane(minSize: _minStacked, child: _panel(w, strings)),
        ],
      );
    }

    final center = Focus(
      focusNode: _centerNode,
      canRequestFocus: false,
      skipTraversal: true,
      child: widget.center,
    );
    final left = stack(DockEdge.left);
    final right = stack(DockEdge.right);
    final bottom = stack(DockEdge.bottom);
    final upper = _splitOf(Axis.horizontal, [
      if (left != null) (DockEdge.left, left, minDock),
      (null, center, minDock),
      if (right != null) (DockEdge.right, right, minDock),
    ]);
    return _splitOf(Axis.vertical, [
      (null, upper, minDock),
      if (bottom != null) (DockEdge.bottom, bottom, _minStacked),
    ]);
  }

  Widget _splitOf(Axis axis, List<(DockEdge?, Widget, double)> slots) {
    if (slots.length == 1) return slots.single.$2;
    final edges = [for (final s in slots) s.$1];
    final key = 'split:${axis.name}:${edges.map((e) => e?.name).join(',')}';
    return CamoSplitPane(
      axis: axis,
      state: _split(key, edges),
      panes: [for (final s in slots) CamoPane(minSize: s.$3, child: s.$2)],
    );
  }

  Widget _panel(CamoToolWindow window, DockStrings strings) {
    final state = widget.state;
    return Semantics(
      container: true,
      label: window.title,
      child: CamoSurface(
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          // After the window's own content: a text field that takes Esc keeps it.
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent ||
                event.logicalKey != LogicalKeyboardKey.escape) {
              return KeyEventResult.ignored;
            }
            _leaveToCenter();
            return KeyEventResult.handled;
          },
          child: Column(
            children: [
              _Header(
                window,
                state.edgeOf(window.id) ?? window.defaultEdge,
                state,
                strings,
              ),
              Expanded(
                child: Focus(
                  focusNode: _node(window.id),
                  canRequestFocus: false,
                  skipTraversal: true,
                  child: window.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The strip of icon buttons along an edge: one toggle per tool window of that edge.
class _Stripe extends StatelessWidget {
  const _Stripe(this.edge, this.windows, this.state, this.size, this.strings);

  final DockEdge edge;
  final List<CamoToolWindow> windows;
  final CamoDockState state;
  final double size;
  final DockStrings strings;

  @override
  Widget build(BuildContext context) {
    final vertical = edge != DockEdge.bottom;
    final buttons = [
      for (final w in windows)
        CamoIconButton(
          key: ValueKey('dock-stripe-${w.id}'),
          icon: w.icon,
          semanticLabel: w.title,
          onPressed: () => state.toggle(w.id),
          appearance: Appearance.ghost,
          checked: state.isOpen(w.id),
          tooltip: w.title,
        ),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: strings.stripe(edge),
      child: CamoSurface(
        level: SurfaceLevel.low,
        child: Padding(
          padding: const EdgeInsets.all(_buttonGap),
          child: vertical
              ? Column(
                  spacing: _buttonGap,
                  mainAxisSize: MainAxisSize.max,
                  children: buttons,
                )
              : Row(spacing: _buttonGap, children: buttons),
        ),
      ),
    );
  }
}

// The title row of a tool window: its title, the "Move to" menu, maximize or restore, and hide.
class _Header extends StatelessWidget {
  const _Header(this.window, this.edge, this.state, this.strings);

  final CamoToolWindow window;
  final DockEdge edge;
  final CamoDockState state;
  final DockStrings strings;

  @override
  Widget build(BuildContext context) {
    final maximized = state.maximized == window.id;
    final spacing = Camouflage.spacingOf(context);
    final moves = [
      for (final target in DockEdge.values)
        if (target != edge)
          CamoMenuItem(
            text: strings.edge(target),
            onPressed: () => state.move(window.id, target),
          ),
    ];
    final toggle = maximized ? strings.restore : strings.maximize;
    void toggleMaximize() =>
        maximized ? state.restore() : state.maximize(window.id);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: spacing.m, end: spacing.xs),
      // A narrow dock keeps the title and one menu; maximize and hide move into it.
      child: LayoutBuilder(
        builder: (context, box) {
          final narrow = box.maxWidth < _narrowHeader;
          return Row(
            children: [
              Expanded(
                child: CamoText(
                  window.title,
                  style: Camouflage.typographyOf(context).titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CamoMenuAnchor(
                items: [
                  CamoMenuSubmenu(text: strings.moveTo, items: moves),
                  if (narrow) ...[
                    CamoMenuItem(text: toggle, onPressed: toggleMaximize),
                    CamoMenuItem(
                      text: strings.hide,
                      onPressed: () => state.close(window.id),
                    ),
                  ],
                ],
                builder: (context, open) =>
                    _HeaderButton(_Glyph.more, strings.more, open),
              ),
              if (!narrow) ...[
                _HeaderButton(
                  maximized ? _Glyph.restore : _Glyph.maximize,
                  toggle,
                  toggleMaximize,
                ),
                _HeaderButton(
                  _Glyph.hide,
                  strings.hide,
                  () => state.close(window.id),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton(this.glyph, this.label, this.onPressed);

  final _Glyph glyph;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CamoIconButton(
    icon: CamoIcon(glyph.source),
    semanticLabel: label,
    onPressed: onPressed,
    appearance: Appearance.ghost,
  );
}

// The header's own glyphs, so a skin without them still draws a complete header.
enum _Glyph {
  hide,
  maximize,
  restore,
  more;

  IconSource get source => IconSource.builder(
    (size, color) => CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(this, color ?? const Color(0xFF000000)),
    ),
  );
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.glyph, this.color);

  final _Glyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final round = glyph == _Glyph.more;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (round ? 2.5 : 1.6) * k
      ..strokeCap = round ? StrokeCap.round : StrokeCap.butt;
    Offset p(double x, double y) => Offset(x * k, y * k);
    switch (glyph) {
      case _Glyph.hide:
        canvas.drawLine(p(6, 12), p(18, 12), paint);
      case _Glyph.maximize:
        canvas.drawRect(Rect.fromPoints(p(6, 6), p(18, 18)), paint);
      case _Glyph.restore:
        canvas.drawRect(Rect.fromPoints(p(9, 9), p(18, 18)), paint);
        final back = Path()
          ..moveTo(6 * k, 15 * k)
          ..lineTo(6 * k, 6 * k)
          ..lineTo(15 * k, 6 * k);
        canvas.drawPath(back, paint);
      case _Glyph.more:
        for (final y in [6.0, 12.0, 18.0]) {
          canvas.drawPoints(PointMode.points, [p(12, y)], paint);
        }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
