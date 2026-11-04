import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'chart_renderer.dart';
import 'chart_style.dart';

/// Space between a plot and the edge of its chart, and between a label and the plot.
const double plotPadding = 8;

/// Space between a label and the plot.
const double labelGap = 6;

/// Where the plot sits inside a chart's [size]: the rectangle the marks are drawn in, leaving room for labels.
class PlotLayout {
  /// Creates a layout.
  const PlotLayout(this.size, this.plot);

  /// The whole chart box.
  final Size size;

  /// The rectangle of the marks.
  final Rect plot;
}

/// Room around the plot: [start] pixels on the start side (the labels), [top] and [bottom], [pad] on the other side.
class PlotInsets {
  /// Creates insets.
  const PlotInsets({
    required this.start,
    required this.top,
    required this.bottom,
    required this.pad,
  });

  /// The start side, the right in a right-to-left layout.
  final double start;

  /// Above the plot.
  final double top;

  /// Below the plot.
  final double bottom;

  /// The side opposite the start, and the top edge.
  final double pad;
}

/// The plot rectangle for a chart [size] with [insets]; the start side is the right in a right-to-left layout.
PlotLayout plotLayout(Size size, PlotInsets insets, {required bool rtl}) {
  final left = rtl ? insets.pad : insets.start;
  final right = size.width - (rtl ? insets.start : insets.pad);
  final top = insets.pad + insets.top;
  final bottom = size.height - insets.bottom;
  return PlotLayout(
    size,
    Rect.fromLTRB(left, top, math.max(left, right), math.max(top, bottom)),
  );
}

/// Which side of its anchor an axis label sits.
enum LabelSide {
  /// To the left of the anchor, centered on it.
  before,

  /// To the right of the anchor, centered on it.
  after,

  /// Below the anchor, centered on it.
  below,

  /// Above the anchor, centered on it.
  above,

  /// Centered on the anchor.
  center,
}

/// An axis label: [text] next to the pixel position [anchor].
class AxisLabel {
  /// Creates a label.
  const AxisLabel(this.text, this.anchor, this.side);

  /// The text.
  final String text;

  /// Where it is anchored.
  final Offset anchor;

  /// Which side of the anchor it sits.
  final LabelSide side;
}

/// The measuring and drawing tools every cartesian chart needs, gathered once per build.
class PlotEnv {
  /// Creates the environment.
  PlotEnv({
    required this.renderer,
    required this.style,
    required this.colors,
    required this.rtl,
    required this.textScaler,
  }) {
    labelHeight = _paint('0').height;
  }

  /// Draws the marks.
  final ChartRenderer renderer;

  /// The style of axis labels.
  final TextStyle style;

  /// The theme's colors.
  final CamoColors colors;

  /// Whether the layout is right-to-left.
  final bool rtl;

  /// The text scale.
  final TextScaler textScaler;

  /// The height of one line of label text.
  late final double labelHeight;

  TextPainter _paint(String text, [TextStyle? override]) => TextPainter(
    text: TextSpan(text: text, style: override ?? style),
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();

  /// The width of the widest of [texts].
  double widest(List<String> texts) =>
      texts.fold(0.0, (widest, t) => math.max(widest, _paint(t).width));

  /// The insets for value labels [startLabels] on the start side and axis titles above and below.
  PlotInsets insets(
    List<String> startLabels, {
    required bool topTitle,
    required bool bottomTitle,
  }) {
    final titleRoom = labelHeight + labelGap;
    return PlotInsets(
      start: widest(startLabels) + labelGap * 2,
      top: topTitle ? titleRoom : 0,
      bottom: labelHeight + labelGap * 2 + (bottomTitle ? titleRoom : 0),
      pad: plotPadding,
    );
  }

  /// The titles: [bottom] centered below the labels, [top] at the start edge above the plot.
  List<AxisLabel> titles(PlotLayout layout, String? top, String? bottom) => [
    if (bottom != null)
      AxisLabel(
        bottom,
        Offset(
          layout.plot.center.dx,
          layout.plot.bottom + labelGap * 2 + labelHeight,
        ),
        LabelSide.below,
      ),
    if (top != null)
      AxisLabel(
        top,
        Offset(
          rtl ? layout.size.width - plotPadding : plotPadding,
          plotPadding + labelHeight / 2,
        ),
        rtl ? LabelSide.before : LabelSide.after,
      ),
  ];

  /// Draws [labels] on [canvas], in [color] when given.
  void paintLabels(Canvas canvas, List<AxisLabel> labels, {Color? color}) {
    for (final label in labels) {
      final text = _paint(
        label.text,
        color == null ? null : style.copyWith(color: color),
      );
      final w = text.width;
      final h = text.height;
      final a = label.anchor;
      final topLeft = switch (label.side) {
        LabelSide.before => Offset(a.dx - w, a.dy - h / 2),
        LabelSide.after => Offset(a.dx, a.dy - h / 2),
        LabelSide.below => Offset(a.dx - w / 2, a.dy),
        LabelSide.above => Offset(a.dx - w / 2, a.dy - h),
        LabelSide.center => Offset(a.dx - w / 2, a.dy - h / 2),
      };
      text.paint(canvas, topLeft);
    }
  }
}

/// The environment from the theme and the surrounding renderer.
PlotEnv plotEnv(BuildContext context, ChartRenderer renderer) {
  final theme = Camouflage.themeOf(context);
  return PlotEnv(
    renderer: renderer,
    style: theme.typography.labelSmall.copyWith(
      color: theme.colors.onSurfaceVariant,
    ),
    colors: theme.colors,
    rtl: Directionality.of(context) == TextDirection.rtl,
    textScaler: MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
  );
}

/// The grid: a line at each of [positions] across the plot (vertical lines when [vertical]), and the axis line.
void paintGrid(
  Canvas canvas,
  Rect plot,
  List<double> positions, {
  required bool vertical,
  required ResolvedChartStyle style,
  required Color grid,
  required Color axis,
}) {
  if (style.gridLines) {
    final paint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final position in positions) {
      final from = vertical
          ? Offset(position, plot.top)
          : Offset(plot.left, position);
      final to = vertical
          ? Offset(position, plot.bottom)
          : Offset(plot.right, position);
      if (style.gridDashed) {
        _dashed(canvas, from, to, paint);
      } else {
        canvas.drawLine(from, to, paint);
      }
    }
  }
  canvas.drawLine(
    Offset(plot.left, plot.bottom),
    Offset(plot.right, plot.bottom),
    Paint()
      ..color = axis
      ..strokeWidth = 1,
  );
}

void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
  const dash = 4.0;
  final length = (to - from).distance;
  final direction = length == 0 ? Offset.zero : (to - from) / length;
  for (var at = 0.0; at < length; at += dash * 2) {
    canvas.drawLine(
      from + direction * at,
      from + direction * math.min(at + dash, length),
      paint,
    );
  }
}

/// One tooltip row: a [color] key, then [text].
class TooltipRow {
  /// Creates a row.
  const TooltipRow(this.color, this.text);

  /// The series color, or `null` for a row with no key.
  final Color? color;

  /// The text.
  final String text;
}

/// A tooltip: [title] and its [rows], beside the pixel position [x] (it flips to the other side near the edge).
class ChartTooltip extends StatelessWidget {
  /// Creates a tooltip.
  const ChartTooltip({
    super.key,
    required this.title,
    required this.rows,
    required this.x,
  });

  /// The category.
  final String title;

  /// The values.
  final List<TooltipRow> rows;

  /// The x position it sits beside.
  final double x;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final colors = theme.colors;
    final spacing = theme.spacing;
    return ExcludeSemantics(
      child: CustomSingleChildLayout(
        delegate: _TooltipLayout(x),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.inverseSurface,
            borderRadius: theme.shapes.small,
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xxs,
              children: [
                CamoText(
                  title,
                  style: theme.typography.labelSmall,
                  color: colors.inverseOnSurface,
                ),
                for (final row in rows)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: spacing.xs,
                    children: [
                      if (row.color != null)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: row.color,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(dimension: 8),
                        ),
                      CamoText(
                        row.text,
                        style: theme.typography.labelMedium,
                        color: colors.inverseOnSurface,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipLayout extends SingleChildLayoutDelegate {
  _TooltipLayout(this.x);

  static const double _gap = 12;
  final double x;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final after = x + _gap;
    final left = after + childSize.width > size.width
        ? x - _gap - childSize.width
        : after;
    return Offset(math.max(0, left), 0);
  }

  @override
  bool shouldRelayout(_TooltipLayout old) => old.x != x;
}

/// The (category, series) a key moves to: Left and Right walk categories, Up and Down series, Home and End jump.
(int, int)? walkTarget(
  LogicalKeyboardKey pressed,
  (int, int) at,
  int categories,
  int series, {
  bool linear = false,
}) {
  if (categories == 0 || series == 0) return null;
  final (category, current) = at;
  // A pie walks one way: Down is Right and Up is Left.
  final key = !linear
      ? pressed
      : pressed == LogicalKeyboardKey.arrowDown
      ? LogicalKeyboardKey.arrowRight
      : pressed == LogicalKeyboardKey.arrowUp
      ? LogicalKeyboardKey.arrowLeft
      : pressed;
  if (key == LogicalKeyboardKey.arrowRight) {
    return (math.min(category + 1, categories - 1), current);
  }
  if (key == LogicalKeyboardKey.arrowLeft) {
    return (math.max(category - 1, 0), current);
  }
  if (key == LogicalKeyboardKey.arrowDown) {
    return (category, math.min(current + 1, series - 1));
  }
  if (key == LogicalKeyboardKey.arrowUp) {
    return (category, math.max(current - 1, 0));
  }
  if (key == LogicalKeyboardKey.home) return (0, current);
  if (key == LogicalKeyboardKey.end) return (categories - 1, current);
  return null;
}

/// What the pointer and the keyboard point at in a chart: a [pointer] position and a [walk] of (category, series).
class PlotInputController extends ChangeNotifier {
  /// The focus of the plot.
  final FocusNode focusNode = FocusNode(debugLabel: 'chart plot');

  Offset? _pointer;
  (int, int)? _walk;

  /// Where the pointer went down, until it goes up.
  Offset? pressedAt;

  /// The pointer's position in the plot, or `null` when it is away.
  Offset? get pointer => _pointer;
  set pointer(Offset? value) {
    if (value == _pointer) return;
    _pointer = value;
    notifyListeners();
  }

  /// The point the keyboard is on, or `null` while the plot has no focus.
  (int, int)? get walk => _walk;
  set walk((int, int)? value) {
    if (value == _walk) return;
    _walk = value;
    notifyListeners();
  }

  /// Starts the walk at the first point when the plot gains focus; ends it when it loses it.
  void focusChanged(bool focused) {
    walk = focused ? _walk ?? (0, 0) : null;
  }

  /// Moves the walk for an arrow, Home or End key.
  KeyEventResult key(
    KeyEvent event,
    int categories,
    int series, {
    bool linear = false,
    VoidCallback? onActivate,
  }) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final activate =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space;
    if (activate && onActivate != null) {
      onActivate();
      return KeyEventResult.handled;
    }
    final next = walkTarget(
      event.logicalKey,
      _walk ?? (0, 0),
      categories,
      series,
      linear: linear,
    );
    if (next == null) return KeyEventResult.ignored;
    _pointer = null;
    walk = next;
    notifyListeners();
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}

/// The pointer, focus and keys of a chart over [categories] and [series]; [announce] says the walk's current point
/// to a screen reader.
class PlotInputRegion extends StatelessWidget {
  /// Creates the input region.
  const PlotInputRegion({
    super.key,
    required this.controller,
    required this.categories,
    required this.series,
    required this.announce,
    required this.child,
    this.linear = false,
    this.onActivate,
    this.onTap,
  });

  /// Whether all four arrows walk the categories (a pie).
  final bool linear;

  /// Called for Enter or Space.
  final VoidCallback? onActivate;

  /// Called with the position of a tap.
  final ValueChanged<Offset>? onTap;

  /// The shared state.
  final PlotInputController controller;

  /// How many categories the keys walk through.
  final int categories;

  /// How many series the keys walk through.
  final int series;

  /// The current point as text, or `null` while the plot has no focus.
  final String? announce;

  /// The plot.
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: announce != null,
    liveRegion: announce != null,
    label: announce,
    child: Focus(
      focusNode: controller.focusNode,
      onFocusChange: controller.focusChanged,
      onKeyEvent: (node, event) => controller.key(
        event,
        categories,
        series,
        linear: linear,
        onActivate: onActivate,
      ),
      child: MouseRegion(
        onExit: (_) => controller.pointer = null,
        child: Listener(
          onPointerHover: (e) => controller.pointer = e.localPosition,
          onPointerDown: (e) {
            controller.focusNode.requestFocus();
            controller.pointer = e.localPosition;
            controller.pressedAt = e.localPosition;
          },
          onPointerMove: (e) => controller.pointer = e.localPosition,
          onPointerUp: (e) {
            final pressed = controller.pressedAt;
            controller.pressedAt = null;
            if (pressed != null && (pressed - e.localPosition).distance < 18) {
              onTap?.call(e.localPosition);
            }
            if (e.kind == PointerDeviceKind.touch) controller.pointer = null;
          },
          child: child,
        ),
      ),
    ),
  );
}

/// Runs a chart's draw-in: [drawIn] goes from 0 to 1 when the data changes, at once when motion is off.
mixin DrawInStateMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  /// The progress, 0 to 1.
  late final AnimationController drawIn = AnimationController(vsync: this);

  Duration _duration = Duration.zero;
  bool _started = false;

  /// Starts the draw-in again.
  void restartDrawIn() {
    if (_duration == Duration.zero) {
      drawIn.value = 1;
    } else {
      drawIn.duration = _duration;
      drawIn.forward(from: 0);
    }
  }

  /// Sets how long the draw-in takes (zero for none); restarts it on the first call and when that changes.
  void configureDrawIn(Duration duration) {
    if (_started && duration == _duration) return;
    _started = true;
    _duration = duration;
    restartDrawIn();
  }

  @override
  void dispose() {
    drawIn.dispose();
    super.dispose();
  }
}
