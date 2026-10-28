import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// Minimal's buttons, icon buttons and progress circle (base Minimal Skin §3.3 and §3.4).

const double _hairline = 1;
const double _disabledContainer = 0.12;
const double _disabledContent = 0.38;
const _clear = Color(0x00000000);

/// Minimal's button: 40 tall, radius 8, ink solid, hairlines for raised and outline.
class MinimalButtonRenderer implements CamoButtonRenderer {
  /// Creates the renderer.
  const MinimalButtonRenderer();

  @override
  CamoButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoButtonStyle(
      defaultAppearance: Appearance.solid,
      height: 40,
      minWidth: 64,
      shape: theme.shapes.medium,
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.l),
      paddingWithIcon: EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing.m,
      ),
      textStyle: theme.typography.labelLarge,
      iconSize: 16,
      iconGap: theme.spacing.s,
      borderWidth: _hairline,
      raisedElevation: ElevationLevel.level0,
      solidColors: ButtonColors(container: c.primary, content: c.onPrimary),
      softColors: ButtonColors(
        container: c.surfaceContainerHigh,
        content: c.onSurface,
      ),
      raisedColors: ButtonColors(
        container: c.surface,
        content: c.onSurface,
        border: c.outline,
      ),
      outlineColors: ButtonColors(
        container: _clear,
        content: c.primary,
        border: c.outlineVariant,
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
    final depth = state.appearance == Appearance.raised
        ? style.raisedElevation
        : ElevationLevel.level0;
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
              decoration: link ? TextDecoration.underline : null,
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

/// Minimal's icon button: 36, radius 8, icon 20, ghost by default.
class MinimalIconButtonRenderer implements CamoIconButtonRenderer {
  /// Creates the renderer.
  const MinimalIconButtonRenderer();

  @override
  CamoIconButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoIconButtonStyle(
      defaultAppearance: Appearance.ghost,
      containerSize: 36,
      shape: theme.shapes.medium,
      iconSize: 20,
      borderWidth: _hairline,
      solidColors: IconButtonColors(container: c.primary, content: c.onPrimary),
      softColors: IconButtonColors(
        container: c.surfaceContainerHigh,
        content: c.onSurface,
      ),
      outlineColors: IconButtonColors(
        container: _clear,
        content: c.onSurfaceVariant,
        border: c.outlineVariant,
      ),
      ghostColors: IconButtonColors(
        container: _clear,
        content: c.onSurfaceVariant,
      ),
      checkedColors: IconButtonColors(
        container: c.surfaceContainerHigh,
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
          elevation: 0,
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

/// Minimal's progress circle: a 2 px ink arc on an `outlineVariant` track.
class MinimalProgressCircleRenderer implements CamoProgressCircleRenderer {
  /// Creates the renderer.
  const MinimalProgressCircleRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) => CamoProgressStyle(
    circleStroke: 2,
    circleSizeSmall: 16,
    circleSizeMedium: 32,
    circleSizeLarge: 48,
    colors: ProgressColors(
      active: theme.colors.primary,
      track: theme.colors.outlineVariant,
    ),
    // A 2 px ink bar on a hairline track, no gap, no stop dot.
    barHeight: 2,
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
    return MinimalCircle(
      value: state.value,
      diameter: style.circleSizeOf(state.size),
      stroke: style.circleStroke,
      colors: colors,
      theme: theme,
    );
  }
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
    return MinimalCircle(
      value: null,
      diameter: size,
      stroke: style.circleStroke,
      colors: ProgressColors(active: color, track: _clear),
      theme: theme,
    );
  }
}

/// A Minimal progress arc: determinate, spinning, or (under reduced motion) a slow opacity pulse.
class MinimalCircle extends StatefulWidget {
  /// Creates the arc.
  const MinimalCircle({
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
  State<MinimalCircle> createState() => _MinimalCircleState();
}

const int _spinCycles = 3;
const Duration _pulse = Duration(milliseconds: 1200);
const double _pulseLow = 0.4;
const double _arc = 0.75;

class _MinimalCircleState extends State<MinimalCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this);

  bool get _reduced => widget.theme.motion.durationLong == Duration.zero;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(MinimalCircle old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.value != null) {
      _spin.stop();
      return;
    }
    _spin.duration = _reduced
        ? _pulse
        : widget.theme.motion.durationLong * _spinCycles;
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
                        painter: _Arc(widget.colors, widget.stroke, 0, 1),
                      ),
                    )
                  : CustomPaint(
                      painter: _Arc(
                        widget.colors,
                        widget.stroke,
                        _spin.value,
                        _arc,
                      ),
                    ),
            ),
    );
  }
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
