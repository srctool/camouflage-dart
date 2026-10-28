import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import '../fluent_tokens.dart';

// Fluent's Button, icon-only Button and Spinner (base Fluent Skin §3.1 and §3.2). Medium density by default;
// fluentTheme(density: …) changes the sizes through the component themes.

const double _stroke1 = 1;
const double _disabledContainer = 0.12;
const double _disabledContent = 0.38;
const _clear = Color(0x00000000);

// Status tones have no hover/pressed tokens in Fluent: their fills step toward the content color instead.
const double _hoverStep = 0.08;
const double _pressedStep = 0.16;

/// Fluent's Button: 32 tall, radius 4, primary in the brand, the default (soft) with a stroke.
class FluentButtonRenderer implements CamoButtonRenderer {
  /// Creates the renderer.
  const FluentButtonRenderer();

  @override
  CamoButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    final stroke = t?.neutralStroke1 ?? c.outlineVariant;
    final secondary = ButtonColors(
      container: c.surface,
      content: c.onSurface,
      border: stroke,
    );
    return CamoButtonStyle(
      defaultAppearance: Appearance.solid,
      height: 32,
      minWidth: 96,
      shape: theme.shapes.small,
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.m),
      paddingWithIcon: EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing.m,
      ),
      textStyle: theme.typography.labelLarge,
      iconSize: 20,
      iconGap: 6,
      borderWidth: _stroke1,
      raisedElevation: ElevationLevel.level0,
      solidColors: ButtonColors(
        container: t?.brandBackground ?? c.primary,
        content: t?.neutralForegroundOnBrand ?? c.onPrimary,
      ),
      softColors: secondary,
      raisedColors: secondary,
      outlineColors: ButtonColors(
        container: _clear,
        content: c.onSurface,
        border: stroke,
      ),
      ghostColors: ButtonColors(container: _clear, content: c.onSurfaceVariant),
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
    final rest = style.colorsFor(state.appearance, state.tone, theme);
    final colors = state.enabled
        ? _stepped(
            rest,
            state.appearance,
            state.tone,
            state.interaction,
            theme.tokens<FluentTokens>(),
          )
        : _disabled(
            rest,
            theme,
            style.disabledContainerAlpha,
            style.disabledContentAlpha,
          );
    final link = state.appearance == Appearance.link;
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
              decoration: link && state.interaction.hovered
                  ? TextDecoration.underline
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
          elevation: 0,
          theme: theme,
          child: label,
        ),
      ),
    );
  }

  // Fluent's state tokens for the default tone; a step toward the content color for status tones.
  static ButtonColors _stepped(
    ButtonColors rest,
    Appearance a,
    Tone tone,
    InteractionState i,
    FluentTokens? t,
  ) {
    if (!i.hovered && !i.pressed) return rest;
    if (t == null || tone != Tone.defaultTone) return _toward(rest, i);
    Color pick(Color hover, Color pressed) => i.pressed ? pressed : hover;
    return switch (a) {
      Appearance.solid => rest.copyWith(
        container: pick(t.brandBackgroundHover, t.brandBackgroundPressed),
      ),
      Appearance.soft || Appearance.raised => rest.copyWith(
        container: pick(t.neutralBackground1Hover, t.neutralBackground1Pressed),
        border: pick(t.neutralStroke1Hover, t.neutralStroke1Pressed),
      ),
      Appearance.outline => rest.copyWith(
        border: pick(t.neutralStroke1Hover, t.neutralStroke1Pressed),
      ),
      Appearance.ghost => rest.copyWith(
        container: pick(t.subtleBackgroundHover, t.subtleBackgroundPressed),
        content: t.neutralForeground2Hover,
      ),
      Appearance.link => rest.copyWith(
        content: pick(t.brandForegroundLinkHover, t.brandForegroundLinkPressed),
      ),
    };
  }
}

/// Fluent's icon-only Button: 32 square, radius 4, subtle by default.
class FluentIconButtonRenderer implements CamoIconButtonRenderer {
  /// Creates the renderer.
  const FluentIconButtonRenderer();

  @override
  CamoIconButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    final stroke = t?.neutralStroke1 ?? c.outlineVariant;
    return CamoIconButtonStyle(
      defaultAppearance: Appearance.ghost,
      containerSize: 32,
      shape: theme.shapes.small,
      iconSize: 20,
      borderWidth: _stroke1,
      solidColors: IconButtonColors(
        container: t?.brandBackground ?? c.primary,
        content: t?.neutralForegroundOnBrand ?? c.onPrimary,
      ),
      softColors: IconButtonColors(
        container: c.surface,
        content: c.onSurface,
        border: stroke,
      ),
      outlineColors: IconButtonColors(
        container: _clear,
        content: c.onSurface,
        border: stroke,
      ),
      ghostColors: IconButtonColors(
        container: _clear,
        content: c.onSurfaceVariant,
      ),
      checkedColors: IconButtonColors(
        container: c.surfaceContainerHighest,
        content: c.onSurface,
        border: stroke,
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
    final colors = _iconColors(state, style, theme);
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

  static ButtonColors _iconColors(
    IconButtonState state,
    CamoIconButtonStyle style,
    CamoTheme theme,
  ) {
    final r = style.colorsFor(
      state.appearance,
      state.tone,
      theme,
      checked: state.checked ?? false,
    );
    final rest = ButtonColors(
      container: r.container,
      content: r.content,
      border: r.border,
    );
    final i = state.interaction;
    final t = theme.tokens<FluentTokens>();
    if (!state.enabled) {
      return _disabled(
        rest,
        theme,
        style.disabledContainerAlpha,
        style.disabledContentAlpha,
      );
    }
    if (!i.hovered && !i.pressed) return rest;
    if (t == null || state.tone != Tone.defaultTone || state.checked == true) {
      return _toward(rest, i);
    }
    if (state.appearance == Appearance.solid) {
      return rest.copyWith(
        container: i.pressed
            ? t.brandBackgroundPressed
            : t.brandBackgroundHover,
      );
    }
    if (rest.container.a == 0 && rest.border == null) {
      return rest.copyWith(
        container: i.pressed
            ? t.subtleBackgroundPressed
            : t.subtleBackgroundHover,
        content: t.neutralForeground2Hover,
      );
    }
    return rest.copyWith(
      container: rest.container.a == 0
          ? rest.container
          : (i.pressed
                ? t.neutralBackground1Pressed
                : t.neutralBackground1Hover),
      border: i.pressed ? t.neutralStroke1Pressed : t.neutralStroke1Hover,
    );
  }
}

/// Fluent's Spinner: a brand arc on a light brand track, 3 px.
class FluentProgressCircleRenderer implements CamoProgressCircleRenderer {
  /// Creates the renderer.
  const FluentProgressCircleRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) => CamoProgressStyle(
    circleStroke: 3,
    circleSizeSmall: 20,
    circleSizeMedium: 32,
    circleSizeLarge: 40,
    colors: ProgressColors(
      active: theme.colors.primary,
      track: theme.colors.primaryContainer,
    ),
    // Fluent's ProgressBar: 2 px, rounded, no gap or stop dot.
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
    final f = theme.colors.family(state.tone);
    final colors = state.tone == Tone.defaultTone
        ? style.colors
        : ProgressColors(active: f.strong, track: f.container);
    return _Circle(
      value: state.value,
      diameter: style.circleSizeOf(state.size),
      stroke: style.circleStroke,
      colors: colors,
      theme: theme,
    );
  }
}

ButtonColors _toward(ButtonColors rest, InteractionState i) =>
    rest.container.a == 0
    ? rest
    : rest.copyWith(
        container: Color.lerp(
          rest.container,
          rest.content,
          i.pressed ? _pressedStep : _hoverStep,
        ),
      );

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
    return _Circle(
      value: null,
      diameter: size,
      stroke: style.circleStroke,
      colors: ProgressColors(active: color, track: _clear),
      theme: theme,
    );
  }
}

const int _spinCycles = 5;
const Duration _pulse = Duration(milliseconds: 1200);
const double _pulseLow = 0.4;
const double _arc = 0.25;

class _Circle extends StatefulWidget {
  const _Circle({
    required this.value,
    required this.diameter,
    required this.stroke,
    required this.colors,
    required this.theme,
  });

  final double? value;
  final double diameter;
  final double stroke;
  final ProgressColors colors;
  final CamoTheme theme;

  @override
  State<_Circle> createState() => _CircleState();
}

class _CircleState extends State<_Circle> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this);

  bool get _reduced => widget.theme.motion.durationLong == Duration.zero;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Circle old) {
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
