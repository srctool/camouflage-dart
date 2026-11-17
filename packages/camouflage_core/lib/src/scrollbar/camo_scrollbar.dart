import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../environment/camo_environment.dart';
import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// When a scrollbar shows: [auto] is the skin's choice, [onScroll] while scrolling and a moment after, [always]
/// always.
enum CamoScrollbarVisibility {
  /// The skin's default.
  auto,

  /// While scrolling, and a moment after.
  onScroll,

  /// Always.
  always,
}

/// Every color a scrollbar uses.
@immutable
class CamoScrollbarColors {
  /// Creates the colors.
  const CamoScrollbarColors({
    required this.thumb,
    required this.thumbHover,
    required this.thumbDrag,
    required this.track,
  });

  /// The thumb at rest.
  final Color thumb;

  /// The thumb under the pointer.
  final Color thumbHover;

  /// The thumb while dragged.
  final Color thumbDrag;

  /// The track, drawn while the pointer is over the bar (transparent for none).
  final Color track;
}

/// Overrides for scrollbars; `null` keeps the skin's default.
@immutable
class CamoScrollbarTheme {
  /// Creates scrollbar overrides.
  const CamoScrollbarTheme({
    this.thickness,
    this.hoverThickness,
    this.minThumb,
    this.visibility,
    this.hideDelay,
    this.colors,
  });

  /// The thumb's width at rest.
  final double? thickness;

  /// The thumb's width under the pointer or while dragged.
  final double? hoverThickness;

  /// The shortest thumb.
  final double? minThumb;

  /// What [CamoScrollbarVisibility.auto] means for this skin.
  final CamoScrollbarVisibility? visibility;

  /// How long the bar stays after scrolling stops (`onScroll`).
  final Duration? hideDelay;

  /// Every color it uses.
  final CamoScrollbarColors? colors;
}

/// The resolved scrollbar style: every field set; [visibility] is never `auto`.
@immutable
class CamoScrollbarStyle {
  /// Creates a style.
  const CamoScrollbarStyle({
    required this.thickness,
    required this.hoverThickness,
    required this.minThumb,
    required this.visibility,
    required this.hideDelay,
    required this.colors,
  });

  /// The thumb's width at rest.
  final double thickness;

  /// The thumb's width under the pointer or while dragged.
  final double hoverThickness;

  /// The shortest thumb.
  final double minThumb;

  /// When it shows.
  final CamoScrollbarVisibility visibility;

  /// How long it stays after scrolling stops.
  final Duration hideDelay;

  /// Every color.
  final CamoScrollbarColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoScrollbarStyle merge(CamoScrollbarTheme? o) => o == null
      ? this
      : CamoScrollbarStyle(
          thickness: o.thickness ?? thickness,
          hoverThickness: o.hoverThickness ?? hoverThickness,
          minThumb: o.minThumb ?? minThumb,
          visibility:
              o.visibility == null ||
                  o.visibility == CamoScrollbarVisibility.auto
              ? visibility
              : o.visibility!,
          hideDelay: o.hideDelay ?? hideDelay,
          colors: o.colors ?? colors,
        );
}

/// What a scrollbar renderer draws inside its lane (as wide as the thickest thumb, as long as the track): the
/// optional track, and the thumb at [thumbStart] for [thumbLength] logical pixels along [axis], thin at rest and
/// `hoverThickness` while [hovered] or [dragging], against the end edge (the right in left-to-right).
@immutable
class CamoScrollbarState {
  /// Creates a scrollbar state.
  const CamoScrollbarState({
    required this.axis,
    required this.thumbStart,
    required this.thumbLength,
    required this.hovered,
    required this.dragging,
  });

  /// The scrolling axis.
  final Axis axis;

  /// Where the thumb starts along the track.
  final double thumbStart;

  /// The thumb's length.
  final double thumbLength;

  /// The pointer is over the bar.
  final bool hovered;

  /// The thumb is being dragged.
  final bool dragging;
}

/// Draws the scrollbar; core owns the geometry, the drag, the track click and the fade.
abstract interface class CamoScrollbarRenderer {
  /// The complete scrollbar style for [theme].
  CamoScrollbarStyle defaults(CamoTheme theme);

  /// Draws [state] filling the lane it is given.
  Widget scrollbar(
    BuildContext context,
    CamoScrollbarState state,
    CamoTheme theme,
    CamoScrollbarStyle style,
  );
}

// The scrollbar's geometry as pure functions: thumb size and place from the scroll fraction, and the scroll offset
// a drag or a track click asks for. All lengths are logical pixels along the scrolling axis.

double _thumbLength(double viewport, double content, double track, double min) {
  if (content <= viewport || viewport <= 0 || track <= 0) return 0;
  return math.min(
    track,
    math.max(math.min(min, track), viewport / content * track),
  );
}

double _thumbStart(
  double offset,
  double viewport,
  double content,
  double track,
  double thumb,
) {
  final scrollable = content - viewport;
  if (scrollable <= 0) return 0;
  return (offset / scrollable).clamp(0.0, 1.0) * (track - thumb);
}

double _scrollForThumbDrag(
  double delta,
  double viewport,
  double content,
  double track,
  double thumb,
) {
  final room = track - thumb;
  return room <= 0 ? 0 : delta * (content - viewport) / room;
}

int _pageDirection(double position, double thumbStart, double thumbLength) {
  if (position < thumbStart) return -1;
  if (position > thumbStart + thumbLength) return 1;
  return 0;
}

// Touch platforms keep their native indicators; with a pointer on desktop or the web, Camouflage draws the bar.
bool _showsScrollbars(BuildContext context) {
  final environment = Camouflage.environmentOf(context);
  return environment.input == InputMode.pointer &&
      environment.platform != CamoPlatform.android &&
      environment.platform != CamoPlatform.ios;
}

/// A scrollable with a scrollbar over it, in the skin's look: a thumb that grows under the pointer, dragged to scroll,
/// and a click on the track pages by a viewport. It reads the [child]'s scroll position from its scroll
/// notifications, so the child needs no controller. It shows only with pointer input on desktop and the web (it is
/// just [child] on touch platforms), takes no focus and is hidden from screen readers, which scroll the content
/// themselves; wheel events go to the content. A bar with nothing to scroll draws nothing. Camouflage's own
/// scrolling widgets (the tree, data table, paged list, menus and the select's list) use it already.
class CamoScrollArea extends StatefulWidget {
  /// Creates a scroll area around the scrollable [child].
  const CamoScrollArea({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.visibility = CamoScrollbarVisibility.auto,
  });

  /// The scrolling content (a `ListView`, a `SingleChildScrollView`).
  final Widget child;

  /// The axis the bar follows.
  final Axis axis;

  /// When the bar shows.
  final CamoScrollbarVisibility visibility;

  @override
  State<CamoScrollArea> createState() => _CamoScrollAreaState();
}

class _CamoScrollAreaState extends State<CamoScrollArea> {
  ScrollMetrics? _metrics;
  ScrollPosition? _position;
  bool _hovered = false;
  bool _dragging = false;
  // Set at once when a drag starts on the thumb (the rebuild that shows it comes a frame later).
  bool _active = false;
  bool _recent = false;
  Timer? _hide;

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  // The scroll metrics arrive in two kinds of notification: a metrics change (the first layout, a longer list) and
  // a scroll. Only the nearest scrollable on the bar's axis counts.
  bool _onNotification(Notification n, CamoScrollbarStyle style) {
    final ScrollMetrics metrics;
    final BuildContext? context;
    final int depth;
    final bool scrolled;
    if (n is ScrollMetricsNotification) {
      metrics = n.metrics;
      context = n.context;
      depth = n.depth;
      scrolled = false;
    } else if (n is ScrollNotification) {
      metrics = n.metrics;
      context = n.context;
      depth = n.depth;
      scrolled = n is ScrollUpdateNotification || n is OverscrollNotification;
    } else {
      return false;
    }
    if (depth != 0 || metrics.axis != widget.axis) return false;
    final position = context == null
        ? null
        : Scrollable.maybeOf(context)?.position;
    // A notification arrives in the middle of a frame: schedule the rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _metrics = metrics.copyWith();
        _position = position ?? _position;
        if (scrolled) {
          _recent = true;
          _hide?.cancel();
          _hide = Timer(style.hideDelay, () {
            if (mounted) setState(() => _recent = false);
          });
        }
      });
    });
    return false;
  }

  void _drag(double delta, double track, double thumb) {
    if (!_active) return;
    final m = _metrics;
    final position = _position;
    if (m == null || position == null || !position.hasPixels) return;
    final content = m.maxScrollExtent + m.viewportDimension;
    final next =
        position.pixels +
        _scrollForThumbDrag(delta, m.viewportDimension, content, track, thumb);
    position.jumpTo(
      next.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  void _page(int direction) {
    final m = _metrics;
    final position = _position;
    if (m == null || position == null || !position.hasPixels) return;
    position.jumpTo(
      (position.pixels + direction * m.viewportDimension).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showsScrollbars(context)) return widget.child;
    final skin = Camouflage.skinOf(context, component: 'CamoScrollArea');
    final theme = Camouflage.themeOf(context, component: 'CamoScrollArea');
    final style = skin.scrollbar
        .defaults(theme)
        .merge(theme.components.scrollbar);
    final vertical = widget.axis == Axis.vertical;
    final mode = widget.visibility == CamoScrollbarVisibility.auto
        ? style.visibility
        : widget.visibility;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        NotificationListener<Notification>(
          onNotification: (n) => _onNotification(n, style),
          child: widget.child,
        ),
        PositionedDirectional(
          end: vertical ? 0 : null,
          top: vertical ? 0 : null,
          bottom: 0,
          start: vertical ? null : 0,
          width: vertical ? style.hoverThickness : null,
          height: vertical ? null : style.hoverThickness,
          child: ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final track = vertical
                    ? constraints.maxHeight
                    : constraints.maxWidth;
                final m = _metrics;
                final viewport = m?.viewportDimension ?? 0;
                final content = m == null
                    ? 0.0
                    : m.maxScrollExtent + m.viewportDimension;
                final thumb = _thumbLength(
                  viewport,
                  content,
                  track,
                  style.minThumb,
                );
                final start = _thumbStart(
                  m?.pixels ?? 0,
                  viewport,
                  content,
                  track,
                  thumb,
                );
                final shown =
                    thumb > 0 &&
                    (mode == CamoScrollbarVisibility.always ||
                        _hovered ||
                        _dragging ||
                        _recent);
                return MouseRegion(
                  onEnter: (_) => setState(() => _hovered = true),
                  onExit: (_) => setState(() => _hovered = false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (d) {
                      final at = vertical
                          ? d.localPosition.dy
                          : d.localPosition.dx;
                      final direction = _pageDirection(at, start, thumb);
                      if (thumb > 0 && direction != 0) _page(direction);
                    },
                    onVerticalDragStart: vertical
                        ? (d) => _beginDrag(d.localPosition.dy, start, thumb)
                        : null,
                    onVerticalDragUpdate: vertical
                        ? (d) => _drag(d.delta.dy, track, thumb)
                        : null,
                    onVerticalDragEnd: vertical ? (_) => _endDrag() : null,
                    onHorizontalDragStart: vertical
                        ? null
                        : (d) => _beginDrag(d.localPosition.dx, start, thumb),
                    onHorizontalDragUpdate: !vertical
                        ? (d) => _drag(d.delta.dx, track, thumb)
                        : null,
                    onHorizontalDragEnd: vertical ? null : (_) => _endDrag(),
                    child: AnimatedOpacity(
                      opacity: shown ? 1 : 0,
                      duration: shown
                          ? theme.motion.durationShort
                          : theme.motion.durationLong,
                      child: thumb > 0
                          ? skin.scrollbar.scrollbar(
                              context,
                              CamoScrollbarState(
                                axis: widget.axis,
                                thumbStart: start,
                                thumbLength: thumb,
                                hovered: _hovered,
                                dragging: _dragging,
                              ),
                              theme,
                              style,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Only a drag that starts on the thumb moves it.
  void _beginDrag(double at, double start, double thumb) {
    if (_pageDirection(at, start, thumb) == 0 && thumb > 0) {
      _active = true;
      setState(() => _dragging = true);
    }
  }

  void _endDrag() {
    _active = false;
    setState(() => _dragging = false);
  }
}
