import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

part 'camo_split_state.dart';

/// One pane of a split: [child] between [minSize] and [maxSize] (logical pixels; the state keeps fractions). A
/// [collapsible] pane dragged below half its minimum collapses and leaves the tree; its divider stays so it restores.
@immutable
class CamoPane {
  /// Creates a pane.
  const CamoPane({
    this.minSize = 80,
    this.maxSize,
    this.collapsible = false,
    required this.child,
  });

  /// The smallest the pane may be.
  final double minSize;

  /// The largest the pane may be, if limited.
  final double? maxSize;

  /// Whether dragging below half of [minSize] collapses it.
  final bool collapsible;

  /// The pane's content.
  final Widget child;
}

/// Every color a split pane's divider uses.
@immutable
class CamoSplitPaneColors {
  /// Creates the colors.
  const CamoSplitPaneColors({
    required this.line,
    required this.hover,
    required this.dragging,
    required this.focus,
  });

  /// The idle line.
  final Color line;

  /// The line under the pointer.
  final Color hover;

  /// The line while dragged.
  final Color dragging;

  /// The focus ring.
  final Color focus;
}

/// The words a divider says to a screen reader.
@immutable
class CamoSplitPaneStrings {
  /// Creates the strings.
  const CamoSplitPaneStrings({
    this.label = 'Resize panel',
    this.percent = _percent,
  });

  /// The divider's name.
  final String label;

  /// Its value, for the pane's share (`35` becomes "35 percent").
  final String Function(int percent) percent;

  static String _percent(int value) => '$value percent';
}

/// Overrides for split panes; `null` keeps the skin's default.
@immutable
class CamoSplitPaneTheme {
  /// Creates split pane overrides.
  const CamoSplitPaneTheme({
    this.thickness,
    this.hitSize,
    this.keyStep,
    this.keyStepLarge,
    this.grip,
    this.colors,
    this.strings,
  });

  /// The drawn line.
  final double? thickness;

  /// The grab area, centred on the line.
  final double? hitSize;

  /// Arrow keys move the divider this far; Shift moves it [keyStepLarge].
  final double? keyStep;

  /// The larger key step.
  final double? keyStepLarge;

  /// A small grip in the middle of the divider (some skins).
  final bool? grip;

  /// Every color it uses.
  final CamoSplitPaneColors? colors;

  /// What a screen reader hears.
  final CamoSplitPaneStrings? strings;
}

/// The resolved split pane style: every field set.
@immutable
class CamoSplitPaneStyle {
  /// Creates a style.
  const CamoSplitPaneStyle({
    required this.thickness,
    required this.hitSize,
    required this.keyStep,
    required this.keyStepLarge,
    required this.grip,
    required this.colors,
    this.strings = const CamoSplitPaneStrings(),
  });

  /// The drawn line.
  final double thickness;

  /// The grab area, centred on the line.
  final double hitSize;

  /// Arrow key step.
  final double keyStep;

  /// Shift+arrow key step.
  final double keyStepLarge;

  /// Whether to draw a grip.
  final bool grip;

  /// Every color.
  final CamoSplitPaneColors colors;

  /// What a screen reader hears.
  final CamoSplitPaneStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoSplitPaneStyle merge(CamoSplitPaneTheme? o) => o == null
      ? this
      : CamoSplitPaneStyle(
          thickness: o.thickness ?? thickness,
          hitSize: o.hitSize ?? hitSize,
          keyStep: o.keyStep ?? keyStep,
          keyStepLarge: o.keyStepLarge ?? keyStepLarge,
          grip: o.grip ?? grip,
          colors: o.colors ?? colors,
          strings: o.strings ?? strings,
        );
}

/// What a divider renderer draws: the line along [axis] (a vertical line for a `horizontal` split), in the idle,
/// hover, dragging or focus color, with a focus ring when [focused]. The renderer draws inside the hit area it is
/// given and keeps the line centred; [collapsedBefore] and [collapsedAfter] say a neighbouring pane is collapsed.
@immutable
class SplitDividerState {
  /// Creates a divider state.
  const SplitDividerState({
    required this.axis,
    required this.hovered,
    required this.focused,
    required this.dragging,
    required this.collapsedBefore,
    required this.collapsedAfter,
  });

  /// The split's axis: `horizontal` for panes side by side.
  final Axis axis;

  /// The pointer is over it.
  final bool hovered;

  /// It has keyboard focus.
  final bool focused;

  /// It is being dragged.
  final bool dragging;

  /// The pane before it is collapsed.
  final bool collapsedBefore;

  /// The pane after it is collapsed.
  final bool collapsedAfter;
}

/// Draws the divider between a split's panes; core owns the layout, the hit area and the interaction.
abstract interface class CamoSplitPaneRenderer {
  /// The complete split pane style for [theme].
  CamoSplitPaneStyle defaults(CamoTheme theme);

  /// Draws one divider; it fills the hit area it is given.
  Widget divider(
    BuildContext context,
    SplitDividerState state,
    CamoTheme theme,
    CamoSplitPaneStyle style,
  );
}

const _pageRange = 1000000.0;

/// Panes side by side ([axis] `horizontal`, the first at the start) or stacked, with a draggable, keyboard and screen
/// reader accessible divider between each pair. The [state] is the app's: fractions of the container and the
/// collapsed panes, which it can [snapshot][CamoSplitState.snapshot] and restore. A divider moves space between its
/// two neighbours only, within their `minSize` and `maxSize`. Arrow keys resize (Shift for a larger step), Home and
/// End go to a limit, Enter collapses or restores a collapsible neighbour, a double tap resets the two neighbours; a
/// screen reader adjusts it like a slider. Right to left mirrors a horizontal split.
class CamoSplitPane extends StatelessWidget {
  /// Creates a split pane.
  const CamoSplitPane({
    super.key,
    required this.axis,
    required this.panes,
    required this.state,
  });

  /// `horizontal`: panes side by side; `vertical`: stacked.
  final Axis axis;

  /// Two or more panes.
  final List<CamoPane> panes;

  /// The layout, owned by the app.
  final CamoSplitState state;

  @override
  Widget build(BuildContext context) {
    assert(
      panes.length == state._fractions.length,
      'CamoSplitPane: ${panes.length} panes for ${state._fractions.length} fractions.',
    );
    final skin = Camouflage.skinOf(context, component: 'CamoSplitPane');
    final theme = Camouflage.themeOf(context, component: 'CamoSplitPane');
    final style = skin.splitPane
        .defaults(theme)
        .merge(theme.components.splitPane);
    final mirrored =
        axis == Axis.horizontal &&
        Directionality.of(context) == TextDirection.rtl;
    final dividers = panes.length - 1;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => CustomMultiChildLayout(
        delegate: _SplitLayout(axis, panes, state, style, mirrored, dividers),
        children: [
          for (var i = 0; i < panes.length; i++)
            if (!state._collapsed.contains(i))
              LayoutId(
                id: 'pane$i',
                child: ClipRect(child: panes[i].child),
              ),
          for (var i = 0; i < dividers; i++)
            LayoutId(
              id: 'divider$i',
              child: _SplitDivider(
                index: i,
                axis: axis,
                mirrored: mirrored,
                state: state,
                style: style,
                theme: theme,
                renderer: skin.splitPane,
              ),
            ),
        ],
      ),
    );
  }
}

class _SplitLayout extends MultiChildLayoutDelegate {
  _SplitLayout(
    this.axis,
    this.panes,
    this.state,
    this.style,
    this.mirrored,
    this.dividers,
  ) : super(relayout: state);

  final Axis axis;
  final List<CamoPane> panes;
  final CamoSplitState state;
  final CamoSplitPaneStyle style;
  final bool mirrored;
  final int dividers;

  @override
  void performLayout(Size size) {
    final horizontal = axis == Axis.horizontal;
    final main = horizontal ? size.width : size.height;
    final cross = horizontal ? size.height : size.width;
    final thickness = math.max(1.0, style.thickness);
    final available = math.max(0.0, main - thickness * dividers);
    state
      .._total = available
      .._collapsible = {
        for (var i = 0; i < panes.length; i++)
          if (panes[i].collapsible) i,
      }
      .._limits = [
        for (final p in panes) _Limits(p.minSize, p.maxSize ?? double.infinity),
      ];
    final sizes = _layoutSizes(
      state._fractions,
      state._collapsed,
      available,
      state._limits,
    );
    final visible = [
      for (var i = 0; i < panes.length; i++)
        if (!state._collapsed.contains(i)) i,
    ];
    final hit = math.max(style.hitSize, thickness);
    var position = 0.0;
    for (var i = 0; i < panes.length; i++) {
      final length = sizes[i];
      if (hasChild('pane$i')) {
        layoutChild(
          'pane$i',
          BoxConstraints.tight(
            horizontal ? Size(length, cross) : Size(cross, length),
          ),
        );
        final at = mirrored ? main - position - length : position;
        positionChild('pane$i', horizontal ? Offset(at, 0) : Offset(0, at));
      }
      position += length;
      if (i < dividers) {
        layoutChild(
          'divider$i',
          BoxConstraints.tight(
            horizontal ? Size(hit, cross) : Size(cross, hit),
          ),
        );
        final line = mirrored ? main - position - thickness : position;
        final at = line + (thickness - hit) / 2;
        positionChild('divider$i', horizontal ? Offset(at, 0) : Offset(0, at));
        position += thickness;
      }
    }
    assert(visible.isNotEmpty || panes.isEmpty);
  }

  @override
  bool shouldRelayout(_SplitLayout old) =>
      old.axis != axis ||
      old.panes != panes ||
      old.style != style ||
      old.mirrored != mirrored;
}

class _SplitDivider extends StatefulWidget {
  const _SplitDivider({
    required this.index,
    required this.axis,
    required this.mirrored,
    required this.state,
    required this.style,
    required this.theme,
    required this.renderer,
  });

  final int index;
  final Axis axis;
  final bool mirrored;
  final CamoSplitState state;
  final CamoSplitPaneStyle style;
  final CamoTheme theme;
  final CamoSplitPaneRenderer renderer;

  @override
  State<_SplitDivider> createState() => _SplitDividerState();
}

class _SplitDividerState extends State<_SplitDivider> {
  bool _hovered = false;
  bool _focused = false;
  bool _dragging = false;

  double get _sign => widget.mirrored ? -1 : 1;

  double get _share {
    final fractions = widget.state._fractions;
    final shown = [
      for (var i = 0; i < fractions.length; i++)
        if (!widget.state._collapsed.contains(i)) fractions[i],
    ].fold<double>(0, (a, b) => a + b);
    return shown > 0 ? fractions[widget.index] / shown : 0;
  }

  void _by(double delta, {bool collapse = false}) => widget.state._resize(
    widget.index,
    delta * _sign,
    allowCollapse: collapse,
  );

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final horizontal = widget.axis == Axis.horizontal;
    final key = event.logicalKey;
    final toward = horizontal
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowDown;
    final away = horizontal
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowUp;
    final step = HardwareKeyboard.instance.isShiftPressed
        ? widget.style.keyStepLarge
        : widget.style.keyStep;
    if (key == toward) {
      _by(step);
    } else if (key == away) {
      _by(-step);
    } else if (key == LogicalKeyboardKey.home) {
      _by(-_pageRange);
    } else if (key == LogicalKeyboardKey.end) {
      _by(_pageRange);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _toggleCollapse();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // Enter restores a collapsed neighbour, or collapses a collapsible one.
  void _toggleCollapse() {
    final state = widget.state;
    final neighbours = [widget.index, widget.index + 1];
    final collapsed = neighbours.where(state._collapsed.contains).firstOrNull;
    if (collapsed != null) {
      state.restore(collapsed);
      return;
    }
    final collapsible = neighbours
        .where(state._collapsible.contains)
        .firstOrNull;
    if (collapsible != null) state.collapse(collapsible);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final horizontal = w.axis == Axis.horizontal;
    final share = _share;
    final percent = (share * 100).round();
    final strings = w.style.strings;
    final step = w.style.keyStep / math.max(1, w.state._total);
    Widget divider = w.renderer.divider(
      context,
      SplitDividerState(
        axis: w.axis,
        hovered: _hovered,
        focused: _focused,
        dragging: _dragging,
        collapsedBefore: w.state._collapsed.contains(w.index),
        collapsedAfter: w.state._collapsed.contains(w.index + 1),
      ),
      w.theme,
      w.style,
    );
    divider = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: horizontal
          ? (_) => setState(() => _dragging = true)
          : null,
      onHorizontalDragUpdate: horizontal
          ? (d) => _by(d.delta.dx, collapse: true)
          : null,
      onHorizontalDragEnd: horizontal
          ? (_) => setState(() => _dragging = false)
          : null,
      onHorizontalDragCancel: horizontal
          ? () => setState(() => _dragging = false)
          : null,
      onVerticalDragStart: horizontal
          ? null
          : (_) => setState(() => _dragging = true),
      onVerticalDragUpdate: horizontal
          ? null
          : (d) => _by(d.delta.dy, collapse: true),
      onVerticalDragEnd: horizontal
          ? null
          : (_) => setState(() => _dragging = false),
      onVerticalDragCancel: horizontal
          ? null
          : () => setState(() => _dragging = false),
      onDoubleTap: () => w.state.resetDivider(w.index),
      child: divider,
    );
    return Semantics(
      slider: true,
      label: strings.label,
      value: strings.percent(percent),
      increasedValue: strings.percent(
        ((share + step) * 100).round().clamp(0, 100),
      ),
      decreasedValue: strings.percent(
        ((share - step) * 100).round().clamp(0, 100),
      ),
      onIncrease: () => _by(w.style.keyStep),
      onDecrease: () => _by(-w.style.keyStep),
      child: Focus(
        onKeyEvent: _keys,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: MouseRegion(
          cursor: horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: divider,
        ),
      ),
    );
  }
}
