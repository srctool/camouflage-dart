import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// How placeholders move.
enum SkeletonAnimation {
  /// A highlight sweeping across.
  shimmer,

  /// A slow fade in and out.
  pulse,

  /// Static.
  none,
}

/// The leading placeholder of `CamoSkeleton.listItem`.
enum SkeletonLeading {
  /// An avatar circle.
  circle,

  /// A square image.
  square,

  /// Nothing.
  none,
}

/// Overrides for skeletons; `null` keeps the skin's default.
@immutable
class CamoSkeletonTheme {
  /// Creates CamoSkeletonTheme.
  const CamoSkeletonTheme({
    this.animation,
    this.baseColor,
    this.highlightColor,
    this.cycleDuration,
    this.textLineGap,
  });

  /// How placeholders move.
  final SkeletonAnimation? animation;

  /// The block.
  final Color? baseColor;

  /// The moving highlight.
  final Color? highlightColor;

  /// One shimmer or pulse cycle.
  final Duration? cycleDuration;

  /// Space between text lines.
  final double? textLineGap;

  /// A copy with the given fields replaced.
  CamoSkeletonTheme copyWith({
    SkeletonAnimation? animation,
    Color? baseColor,
    Color? highlightColor,
    Duration? cycleDuration,
    double? textLineGap,
  }) => CamoSkeletonTheme(
    animation: animation ?? this.animation,
    baseColor: baseColor ?? this.baseColor,
    highlightColor: highlightColor ?? this.highlightColor,
    cycleDuration: cycleDuration ?? this.cycleDuration,
    textLineGap: textLineGap ?? this.textLineGap,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSkeletonTheme &&
      other.animation == animation &&
      other.baseColor == baseColor &&
      other.highlightColor == highlightColor &&
      other.cycleDuration == cycleDuration &&
      other.textLineGap == textLineGap;

  @override
  int get hashCode => Object.hash(
    animation,
    baseColor,
    highlightColor,
    cycleDuration,
    textLineGap,
  );
}

/// The resolved skeleton style: every field set.
@immutable
class CamoSkeletonStyle {
  /// Creates CamoSkeletonStyle.
  const CamoSkeletonStyle({
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
    required this.cycleDuration,
    required this.textLineGap,
  });

  /// How placeholders move.
  final SkeletonAnimation animation;

  /// The block.
  final Color baseColor;

  /// The moving highlight.
  final Color highlightColor;

  /// One shimmer or pulse cycle.
  final Duration cycleDuration;

  /// Space between text lines.
  final double textLineGap;

  /// This style with [o]'s non-null fields applied.
  CamoSkeletonStyle merge(CamoSkeletonTheme? o) => o == null
      ? this
      : CamoSkeletonStyle(
          animation: o.animation ?? animation,
          baseColor: o.baseColor ?? baseColor,
          highlightColor: o.highlightColor ?? highlightColor,
          cycleDuration: o.cycleDuration ?? cycleDuration,
          textLineGap: o.textLineGap ?? textLineGap,
        );
}

/// What a skeleton renderer draws: one block in [shape]. [animation] is already `none` under reduced motion.
/// [phase] runs from 0 to 1 once per cycle and is shared by every block in a [CamoSkeletonGroup]: repaint from
/// it (a `CustomPaint` with `repaint: phase`, or [CamoSkeletonPaint]) instead of rebuilding.
@immutable
class SkeletonState {
  /// Creates a skeleton state.
  const SkeletonState({
    required this.shape,
    required this.animation,
    required this.phase,
  });

  /// The block's corners.
  final BorderRadius shape;

  /// How it moves.
  final SkeletonAnimation animation;

  /// The shared clock, 0 to 1.
  final Animation<double> phase;
}

/// Draws skeleton blocks. Core sizes them and hides them from screen readers.
abstract interface class CamoSkeletonRenderer {
  /// The complete skeleton style for [theme].
  CamoSkeletonStyle defaults(CamoTheme theme);

  /// Draws one block filling the space it's given.
  Widget render(
    BuildContext context,
    SkeletonState state,
    CamoTheme theme,
    CamoSkeletonStyle style,
  );
}

class _SkeletonPhase extends InheritedWidget {
  const _SkeletonPhase({required this.phase, required super.child});

  final Animation<double> phase;

  @override
  bool updateShouldNotify(_SkeletonPhase oldWidget) => phase != oldWidget.phase;
}

CamoSkeletonStyle _styleOf(BuildContext context) {
  final skin = Camouflage.skinOf(context, component: 'CamoSkeleton');
  final theme = Camouflage.themeOf(context, component: 'CamoSkeleton');
  return skin.skeleton.defaults(theme).merge(theme.components.skeleton);
}

// Reduced motion (zero durations) makes skeletons static.
bool _animated(BuildContext context, CamoSkeletonStyle style) =>
    style.animation != SkeletonAnimation.none &&
    Camouflage.themeOf(context, component: 'CamoSkeleton').motion.durationLong >
        Duration.zero;

/// Placeholders inside share one animation clock, so a screen of skeletons moves together. With [active]
/// `false` the clock stops (a list that shows skeletons only now and then).
class CamoSkeletonGroup extends StatefulWidget {
  /// Creates a group.
  const CamoSkeletonGroup({super.key, this.active = true, required this.child});

  /// Whether the clock runs.
  final bool active;

  /// The content with skeletons.
  final Widget child;

  @override
  State<CamoSkeletonGroup> createState() => _CamoSkeletonGroupState();
}

class _CamoSkeletonGroupState extends State<CamoSkeletonGroup>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(vsync: this);

  void _sync() {
    final style = _styleOf(context);
    _clock.duration = style.cycleDuration;
    if (widget.active && _animated(context, style)) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(CamoSkeletonGroup old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _SkeletonPhase(phase: _clock, child: widget.child);
}

enum _Kind { block, text, circle, listItem }

const _avatar = 40.0;
const _headlineFraction = 0.5;
const _supportingFraction = 0.8;

/// A placeholder for content that hasn't loaded. Hidden from screen readers: the screen that shows skeletons
/// announces "Loading" once. Outside a [CamoSkeletonGroup] each one runs its own clock.
class CamoSkeleton extends StatelessWidget {
  /// A block (an image, a button); a `null` [width] fills the available width.
  const CamoSkeleton({
    super.key,
    required double this.height,
    this.width,
    this.shape = ShapeRole.small,
  }) : _kind = _Kind.block,
       lines = 1,
       style = null,
       lastLineFraction = 1,
       leading = SkeletonLeading.none;

  /// [lines] placeholder lines as tall as text in [style] (so they match the real text at any font scale), the
  /// last one [lastLineFraction] of the width.
  const CamoSkeleton.text({
    super.key,
    this.lines = 1,
    this.style,
    this.lastLineFraction = 0.6,
  }) : _kind = _Kind.text,
       height = null,
       width = null,
       shape = ShapeRole.extraSmall,
       leading = SkeletonLeading.none;

  /// A round placeholder (an avatar).
  const CamoSkeleton.circle({super.key, required double size})
    : _kind = _Kind.circle,
      height = size,
      width = size,
      shape = ShapeRole.full,
      lines = 1,
      style = null,
      lastLineFraction = 1,
      leading = SkeletonLeading.none;

  /// A placeholder list row with the proportions of a `CamoListItem` with [lines] lines of text.
  const CamoSkeleton.listItem({
    super.key,
    this.lines = 2,
    this.leading = SkeletonLeading.circle,
  }) : _kind = _Kind.listItem,
       height = null,
       width = null,
       shape = ShapeRole.small,
       style = null,
       lastLineFraction = 1;

  final _Kind _kind;

  /// The block's height (and the circle's size).
  final double? height;

  /// The block's width; `null` fills.
  final double? width;

  /// The block's corners.
  final ShapeRole shape;

  /// How many text lines (or the row's line count).
  final int lines;

  /// The text style the lines match; `null` is `bodyMedium`.
  final TextStyle? style;

  /// The last text line's share of the width.
  final double lastLineFraction;

  /// The row's leading placeholder.
  final SkeletonLeading leading;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoSkeleton');
    return ExcludeSemantics(
      child: switch (_kind) {
        _Kind.block => SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: _Block(theme.shapes.of(shape)),
        ),
        _Kind.circle => SizedBox.square(
          dimension: height,
          child: _Block(theme.shapes.full),
        ),
        _Kind.text => _text(
          context,
          theme,
          style ?? theme.typography.bodyMedium,
        ),
        _Kind.listItem => _row(context, theme),
      },
    );
  }

  Widget _text(BuildContext context, CamoTheme theme, TextStyle text) {
    final gap = _styleOf(context).textLineGap;
    final lineHeight = MediaQuery.textScalerOf(context)
        .scale((text.fontSize ?? 14) * (text.height ?? 1.2));
    final block = (lineHeight - gap).clamp(gap, double.infinity);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++)
          SizedBox(
            height: lineHeight,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: i == lines - 1 && lines > 1 ? lastLineFraction : 1,
                child: SizedBox(
                  height: block,
                  child: _Block(theme.shapes.extraSmall),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, CamoTheme theme) {
    final skin = Camouflage.skinOf(context, component: 'CamoSkeleton');
    final list = skin.listItem.defaults(theme).merge(theme.components.listItem);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: list.minHeight(lines)),
      child: Padding(
        padding: list.contentPadding,
        child: Row(
          children: [
            if (leading != SkeletonLeading.none) ...[
              SizedBox.square(
                dimension: _avatar,
                child: _Block(
                  leading == SkeletonLeading.circle
                      ? theme.shapes.full
                      : theme.shapes.small,
                ),
              ),
              SizedBox(width: list.leadingGap),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: _headlineFraction,
                    child: CamoSkeleton.text(style: list.headlineStyle),
                  ),
                  for (var i = 1; i < lines; i++)
                    FractionallySizedBox(
                      widthFactor: _supportingFraction,
                      child: CamoSkeleton.text(style: list.supportingStyle),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// One block: the shared phase, or its own clock outside a group.
class _Block extends StatelessWidget {
  const _Block(this.shape);

  final BorderRadius shape;

  @override
  Widget build(BuildContext context) {
    final shared = context
        .dependOnInheritedWidgetOfExactType<_SkeletonPhase>()
        ?.phase;
    if (shared != null) return _paint(context, shared);
    return CamoSkeletonGroup(
      child: Builder(
        builder: (context) => _paint(
          context,
          context.dependOnInheritedWidgetOfExactType<_SkeletonPhase>()!.phase,
        ),
      ),
    );
  }

  Widget _paint(BuildContext context, Animation<double> phase) {
    final skin = Camouflage.skinOf(context, component: 'CamoSkeleton');
    final theme = Camouflage.themeOf(context, component: 'CamoSkeleton');
    final style = _styleOf(context);
    return skin.skeleton.render(
      context,
      SkeletonState(
        shape: shape,
        animation: _animated(context, style)
            ? style.animation
            : SkeletonAnimation.none,
        phase: phase,
      ),
      theme,
      style,
    );
  }
}

const _pulseLow = 0.45;

/// Paints a skeleton block for a renderer: the base color in the state's shape, with the highlight swept across
/// it (`shimmer`, start to end in the reading direction) or the block fading in and out (`pulse`). It repaints
/// from the phase without rebuilding.
class CamoSkeletonPaint extends StatelessWidget {
  /// Creates the paint for [state] in [style].
  const CamoSkeletonPaint({
    super.key,
    required this.state,
    required this.style,
  });

  /// The block.
  final SkeletonState state;

  /// The colors.
  final CamoSkeletonStyle style;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: state.shape,
    child: CustomPaint(
      painter: _SkeletonPainter(
        state,
        style,
        Directionality.of(context) == TextDirection.rtl,
      ),
      child: const SizedBox.expand(),
    ),
  );
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter(this.state, this.style, this.rtl)
    : super(repaint: state.phase);

  final SkeletonState state;
  final CamoSkeletonStyle style;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final phase = state.phase.value;
    switch (state.animation) {
      case SkeletonAnimation.none:
        canvas.drawRect(rect, Paint()..color = style.baseColor);
      case SkeletonAnimation.pulse:
        // 1 → _pulseLow → 1 over a cycle.
        final wave = 1 - (1 - _pulseLow) * (1 - (2 * phase - 1).abs());
        canvas.drawRect(
          rect,
          Paint()
            ..color = style.baseColor.withValues(
              alpha: style.baseColor.a * wave,
            ),
        );
      case SkeletonAnimation.shimmer:
        canvas.drawRect(rect, Paint()..color = style.baseColor);
        final band = size.width <= 0 ? 1.0 : size.width;
        // The highlight travels from fully before the block to fully past it.
        final x = (phase * 3 - 1) * band;
        final from = rtl ? size.width - x : x;
        final to = rtl ? from - band : from + band;
        final clear = style.highlightColor.withValues(alpha: 0);
        canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              colors: [clear, style.highlightColor, clear],
            ).createShader(Rect.fromPoints(Offset(from, 0), Offset(to, 0))),
        );
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) =>
      old.state != state || old.style != style || old.rtl != rtl;
}
