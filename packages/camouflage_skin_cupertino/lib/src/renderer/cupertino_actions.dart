import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// Cupertino's buttons, icon buttons and activity indicator (base Cupertino Skin §3.1 and §3.2): a prominent button
// is the accent filled, Soft is the accent at 15%, Raised and Outline fold into Soft, Ghost and Link are plain accent
// text (Apple has no outlined or underlined buttons). With Liquid Glass the shape is a capsule and Soft is glass.

const double _hairline = 0;
const double _disabledContainer = 0.12;
const double _disabledContent = 0.38;
const _clear = Color(0x00000000);

/// Cupertino's button: 44 tall, radius 12 (a capsule with Liquid Glass), accent solid, accent-tinted soft.
class CupertinoButtonRenderer implements CamoButtonRenderer {
  /// Creates the renderer; [glass] draws capsules and glass for the tinted buttons.
  const CupertinoButtonRenderer({this.glass = false});

  /// Whether this is the Liquid Glass look.
  final bool glass;

  @override
  CamoButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoButtonStyle(
      defaultAppearance: Appearance.solid,
      height: 44,
      minWidth: 44,
      shape: glass ? theme.shapes.full : theme.shapes.medium,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      paddingWithIcon: EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing.m,
      ),
      textStyle: theme.typography.labelLarge,
      iconSize: 20,
      iconGap: theme.spacing.s,
      borderWidth: _hairline,
      raisedElevation: ElevationLevel.level0,
      solidColors: ButtonColors(container: c.primary, content: c.onPrimary),
      softColors: ButtonColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
      raisedColors: ButtonColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
      outlineColors: ButtonColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
      ghostColors: ButtonColors(container: _clear, content: c.primary),
      linkColors: ButtonColors(container: _clear, content: c.primary),
      disabledContainerAlpha: _disabledContainer,
      disabledContentAlpha: _disabledContent,
    );
  }

  @override
  Widget render(
    BuildContext context,
    ButtonState state,
    ButtonSlots slots,
    CamoTheme theme,
    CamoButtonStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final colors = state.enabled
        ? style.colorsFor(state.appearance, state.tone, theme)
        : _disabled(
            style.colorsFor(state.appearance, state.tone, theme),
            theme,
            style.disabledContainerAlpha,
            style.disabledContentAlpha,
          );
    final link = state.appearance == Appearance.link;
    final depth = _glassDepth(glass, state.appearance, colors.container);
    Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: style.iconGap,
      children: [
        ?slots.prefixIcon,
        Flexible(
          child: Text(
            state.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style.textStyle.copyWith(
              color: colors.content,
              fontWeight: state.appearance == Appearance.solid
                  ? FontWeight.w600
                  : null,
            ),
          ),
        ),
        ?slots.suffixIcon,
      ],
    );
    label = CamoContentStyle(
      color: colors.content,
      iconStyle: CamoIconStyle(size: style.iconSize, color: colors.content),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: state.loading ? 0 : 1, child: label),
          if (state.loading)
            _Spinner(color: colors.content, size: style.iconSize, theme: theme),
        ],
      ),
    );
    if (!link) {
      label = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: style.height,
          minWidth: style.minWidth,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: slots.prefixIcon != null
                ? style.paddingWithIcon.start
                : style.padding.start,
            top: style.padding.top,
            end: slots.suffixIcon != null
                ? style.paddingWithIcon.end
                : style.padding.end,
            bottom: style.padding.bottom,
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: label),
        ),
      );
    }
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: colors.content,
      shape: style.shape,
      theme: theme,
      child: _bordered(
        colors.border,
        style.borderWidth,
        style.shape,
        skin.surfaceTreatment.decorate(
          color: colors.container,
          shape: style.shape,
          elevation: theme.elevation.of(depth),
          theme: theme,
          child: label,
        ),
      ),
    );
  }
}

/// Cupertino's icon button: 44, radius 12 (a circle with Liquid Glass), icon 22, ghost by default.
class CupertinoIconButtonRenderer implements CamoIconButtonRenderer {
  /// Creates the renderer; [glass] draws circles and glass for the tinted buttons.
  const CupertinoIconButtonRenderer({this.glass = false});

  /// Whether this is the Liquid Glass look.
  final bool glass;

  @override
  CamoIconButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoIconButtonStyle(
      defaultAppearance: Appearance.ghost,
      containerSize: 44,
      shape: glass ? theme.shapes.full : theme.shapes.medium,
      iconSize: 22,
      borderWidth: _hairline,
      solidColors: IconButtonColors(container: c.primary, content: c.onPrimary),
      softColors: IconButtonColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
      outlineColors: IconButtonColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
      ghostColors: IconButtonColors(container: _clear, content: c.primary),
      checkedColors: IconButtonColors(
        container: c.primaryContainer,
        content: c.primary,
      ),
      disabledContainerAlpha: _disabledContainer,
      disabledContentAlpha: _disabledContent,
    );
  }

  @override
  Widget render(
    BuildContext context,
    IconButtonState state,
    IconButtonSlots slots,
    CamoTheme theme,
    CamoIconButtonStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final rest = style.colorsFor(
      state.appearance,
      state.tone,
      theme,
      checked: state.checked ?? false,
    );
    final colors = state.enabled
        ? ButtonColors(
            container: rest.container,
            content: rest.content,
            border: rest.border,
          )
        : _disabled(
            ButtonColors(
              container: rest.container,
              content: rest.content,
              border: rest.border,
            ),
            theme,
            style.disabledContainerAlpha,
            style.disabledContentAlpha,
          );
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: colors.content,
      shape: style.shape,
      theme: theme,
      child: _bordered(
        colors.border,
        style.borderWidth,
        style.shape,
        skin.surfaceTreatment.decorate(
          color: colors.container,
          shape: style.shape,
          elevation: theme.elevation.of(
            _glassDepth(glass, Appearance.soft, colors.container),
          ),
          theme: theme,
          child: SizedBox.square(
            dimension: style.containerSize,
            child: Center(
              child: state.loading
                  ? _Spinner(
                      color: colors.content,
                      size: style.iconSize,
                      theme: theme,
                    )
                  : CamoContentStyle(
                      color: colors.content,
                      iconStyle: CamoIconStyle(
                        size: style.iconSize,
                        color: colors.content,
                      ),
                      child: slots.icon,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cupertino's progress circle: the activity indicator (twelve spokes lit in turn) when indeterminate, a ring when
/// determinate.
class CupertinoProgressCircleRenderer implements CamoProgressCircleRenderer {
  /// Creates the renderer.
  const CupertinoProgressCircleRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) => CamoProgressStyle(
    circleStroke: 3,
    circleSizeSmall: 20, // UIActivityIndicator regular
    circleSizeMedium: 28,
    circleSizeLarge: 37, // UIActivityIndicator large
    colors: ProgressColors(
      active: theme.colors.primary,
      track: theme.colors.secondaryContainer,
    ),
    // The bar: a 4 px capsule on a gray fill, no gap, no stop dot (UIProgressView).
    barHeight: 4,
    trackGap: 0,
    showStopIndicator: false,
  );

  @override
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  ) {
    final colors = state.tone == Tone.defaultTone
        ? style.colors
        : ProgressColors(
            active: theme.colors.family(state.tone).strong,
            track: style.colors.track,
          );
    return CupertinoCircle(
      value: state.value,
      diameter: style.circleSizeOf(state.size),
      stroke: style.circleStroke,
      colors: colors,
      theme: theme,
    );
  }
}

// Liquid Glass: the tinted buttons (soft, and raised and outline folded into it) are glass, a material at level2;
// the prominent one and the plain text ones stay as they are. Classic buttons are always flat.
ElevationLevel _glassDepth(bool glass, Appearance appearance, Color container) {
  final tinted =
      appearance == Appearance.soft ||
      appearance == Appearance.raised ||
      appearance == Appearance.outline;
  return glass && tinted && container.a > 0
      ? ElevationLevel.level2
      : ElevationLevel.level0;
}

ButtonColors _disabled(
  ButtonColors rest,
  CamoTheme theme,
  double containerAlpha,
  double contentAlpha,
) {
  final onSurface = theme.colors.onSurface;
  return ButtonColors(
    container: rest.container.a == 0
        ? _clear
        : disabled(onSurface, containerAlpha),
    content: disabled(onSurface, contentAlpha),
    border: rest.border == null ? null : disabled(onSurface, containerAlpha),
  );
}

Widget _bordered(
  Color? border,
  double width,
  BorderRadius shape,
  Widget child,
) => border == null
    ? child
    : DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(color: border, width: width),
        ),
        child: child,
      );

// The loading indicator inside a button: an indeterminate circle in the button's content color, at its icon size.
class _Spinner extends StatelessWidget {
  const _Spinner({
    required this.color,
    required this.size,
    required this.theme,
  });

  final Color color;
  final double size;
  final CamoTheme theme;

  @override
  Widget build(BuildContext context) {
    final style = Camouflage.skinOf(context).progressCircle
        .defaults(theme)
        .merge(theme.components.progress);
    return CupertinoCircle(
      value: null,
      diameter: size,
      stroke: style.circleStroke,
      colors: ProgressColors(active: color, track: _clear),
      theme: theme,
    );
  }
}

/// A Cupertino progress arc: determinate, spinning, or (under reduced motion) a slow opacity pulse.
class CupertinoCircle extends StatefulWidget {
  /// Creates the arc.
  const CupertinoCircle({
    super.key,
    required this.value,
    required this.diameter,
    required this.stroke,
    required this.colors,
    required this.theme,
  });

  /// The fraction done, or `null` to spin.
  final double? value;

  /// The diameter.
  final double diameter;

  /// The stroke width.
  final double stroke;

  /// The arc and track colors.
  final ProgressColors colors;

  /// The theme, for motion.
  final CamoTheme theme;

  @override
  State<CupertinoCircle> createState() => _CupertinoCircleState();
}

const int _spokes = 12;
const Duration _spinDuration = Duration(milliseconds: 1000);
const Duration _pulse = Duration(milliseconds: 1200);
const double _pulseLow = 0.4;

class _CupertinoCircleState extends State<CupertinoCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this);

  bool get _reduced => widget.theme.motion.durationLong == Duration.zero;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(CupertinoCircle old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.value != null) {
      _spin.stop();
      return;
    }
    _spin.duration = _reduced ? _pulse : _spinDuration;
    _reduced ? _spin.repeat(reverse: true) : _spin.repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    return SizedBox.square(
      dimension: widget.diameter,
      child: value != null
          ? TweenAnimationBuilder<double>(
              tween: Tween(end: value),
              duration: widget.theme.motion.durationMedium,
              builder: (context, v, _) => CustomPaint(
                painter: _Arc(widget.colors, widget.stroke, 0, v),
              ),
            )
          : AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => _reduced
                  ? Opacity(
                      opacity: _pulseLow + (1 - _pulseLow) * _spin.value,
                      child: CustomPaint(
                        painter: _Spokes(widget.colors.active, 0),
                      ),
                    )
                  : CustomPaint(
                      painter: _Spokes(
                        widget.colors.active,
                        (_spin.value * _spokes).floor() % _spokes,
                      ),
                    ),
            ),
    );
  }
}

// The activity indicator: twelve rounded spokes, the one at [head] brightest and a trail fading behind it.
class _Spokes extends CustomPainter {
  _Spokes(this.color, this.head);

  final Color color;
  final int head;

  static const double _inner = 0.55;
  static const double _trail = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final width = radius * 0.2;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _spokes; i++) {
      final fade = ((head - i + _spokes) % _spokes) / _spokes;
      final angle = (i * 2 * math.pi / _spokes) - math.pi / 2;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius * _inner),
        center + direction * (radius - width / 2),
        paint..color = color.withValues(alpha: color.a * (1 - fade * _trail)),
      );
    }
  }

  @override
  bool shouldRepaint(_Spokes old) => old.color != color || old.head != head;
}

class _Arc extends CustomPainter {
  _Arc(this.colors, this.stroke, this.start, this.sweep);

  final ProgressColors colors;
  final double stroke;
  final double start;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    if (colors.track.a > 0) {
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = colors.track);
    }
    canvas.drawArc(
      rect,
      -math.pi / 2 + start * 2 * math.pi,
      sweep * 2 * math.pi,
      false,
      paint..color = colors.active,
    );
  }

  @override
  bool shouldRepaint(_Arc old) =>
      old.start != start ||
      old.sweep != sweep ||
      old.colors != colors ||
      old.stroke != stroke;
}
