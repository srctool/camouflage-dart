import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_actions.dart' show FluentProgressCircleRenderer;

// Fluent's feedback components (base Fluent Skin §3): ProgressBar, a Toast card at the bottom end with its intent
// icon, MessageBar banners with an intent border.

const _snackbarIconSize = 20.0;
const _segmentFraction = 0.4;
const _sweepCycles = 4;
const _pulseMillis = 1200;
const _pulseLow = 0.4;
const _intentBorder = 0.35;

/// Fluent's ProgressBar: 2 px brand on its track, no gap, no stop dot.
class FluentProgressBarRenderer implements CamoProgressBarRenderer {
  /// Creates the renderer.
  const FluentProgressBarRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) =>
      const FluentProgressCircleRenderer().defaults(theme);

  @override
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  ) => PaintProgressBar(state: state, theme: theme, style: style);
}

/// A bar: the active part from the start (the right in RTL), the track after a gap, a stop dot on determinate
/// bars when the style asks; indeterminate bars sweep a segment, or pulse under reduced motion.
class PaintProgressBar extends StatefulWidget {
  /// Creates the bar.
  const PaintProgressBar({
    super.key,
    required this.state,
    required this.theme,
    required this.style,
  });

  /// What to draw.
  final ProgressState state;

  /// The theme.
  final CamoTheme theme;

  /// The style.
  final CamoProgressStyle style;

  @override
  State<PaintProgressBar> createState() => _PaintProgressBarState();
}

class _PaintProgressBarState extends State<PaintProgressBar>
    with SingleTickerProviderStateMixin {
  late final _loop = AnimationController(vsync: this);

  bool get _reduced => widget.theme.motion.durationLong == Duration.zero;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(PaintProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  // Only an indeterminate bar animates forever.
  void _sync() {
    if (widget.state.value != null) {
      _loop.stop();
      return;
    }
    if (_reduced) {
      _loop.duration = const Duration(milliseconds: _pulseMillis);
      if (!_loop.isAnimating) _loop.repeat(reverse: true);
    } else {
      final long = widget.theme.motion.durationLong * _sweepCycles;
      _loop.duration = long;
      if (!_loop.isAnimating) _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final colors = style.colorsFor(widget.state.tone, widget.theme);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final value = widget.state.value;
    return SizedBox(
      height: style.barHeight,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value ?? 0),
        duration: widget.theme.motion.durationMedium,
        builder: (context, shown, _) => AnimatedBuilder(
          animation: _loop,
          builder: (context, _) => Opacity(
            opacity: value == null && _reduced
                ? _pulseLow + (1 - _pulseLow) * _loop.value
                : 1,
            child: CustomPaint(
              painter: _BarPainter(
                value: value == null ? null : shown,
                sweep: _loop.value,
                reduced: _reduced,
                active: colors.active,
                track: colors.track,
                gap: style.trackGap,
                stop: style.showStopIndicator,
                rtl: rtl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.value,
    required this.sweep,
    required this.reduced,
    required this.active,
    required this.track,
    required this.gap,
    required this.stop,
    required this.rtl,
  });

  final double? value;
  final double sweep;
  final bool reduced;
  final Color active;
  final Color track;
  final double gap;
  final bool stop;
  final bool rtl;

  // A rounded segment from `from` to `to`, measured from the start edge.
  void _segment(Canvas canvas, Size size, double from, double to, Color color) {
    if (to <= from) return;
    final x = rtl ? size.width - to : from;
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, to - from, size.height), r),
      Paint()..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final v = value;
    if (v == null && reduced) {
      _segment(canvas, size, 0, w, active);
    } else if (v == null) {
      final length = w * _segmentFraction;
      final start = -length + (w + length) * sweep;
      _segment(canvas, size, 0, w, track);
      _segment(
        canvas,
        size,
        math.max(0, start),
        math.min(w, start + length),
        active,
      );
    } else {
      final end = w * v;
      _segment(canvas, size, 0, end, active);
      _segment(canvas, size, math.min(w, end > 0 ? end + gap : 0), w, track);
      if (stop) {
        final r = size.height / 2;
        canvas.drawCircle(
          Offset(rtl ? r : w - r, r),
          r,
          Paint()..color = active,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.value != value ||
      old.sweep != sweep ||
      old.active != active ||
      old.track != track ||
      old.rtl != rtl;
}

/// Fluent's Toast: a neutral card (shadow16) at the bottom end, the intent shown by its icon.
class FluentSnackbarRenderer implements CamoSnackbarRenderer {
  /// Creates the renderer.
  const FluentSnackbarRenderer();

  @override
  CamoSnackbarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final type = theme.typography;
    return CamoSnackbarStyle(
      shape: theme.shapes.small,
      maxWidth: 400,
      margin: theme.spacing.l,
      padding: EdgeInsetsDirectional.only(
        start: theme.spacing.m,
        end: theme.spacing.xs,
      ),
      minHeight: 44,
      textStyle: type.bodyMedium,
      actionStyle: type.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      elevation: ElevationLevel.level4,
      position: SnackbarPosition.bottom,
      alignment: SnackbarAlignment.end,
      showDismiss: false,
      showToneIcon: true,
      durationShort: const Duration(seconds: 4),
      durationLong: const Duration(seconds: 10),
      colors: SnackbarColors(
        container: c.surface,
        text: c.onSurface,
        action: c.primary,
      ),
      dismissIcon: const IconSource.builder(feedbackCloseIcon),
    );
  }

  @override
  Widget render(
    BuildContext context,
    SnackbarState state,
    SnackbarSlots slots,
    CamoTheme theme,
    CamoSnackbarStyle style,
  ) => paintSnackbar(
    context,
    state,
    slots,
    theme,
    style,
    style.colors,
    iconColor: style.colorsFor(state.tone, theme).container,
  );
}

/// A snackbar: one row of the tone icon, the message, the action and the ✕ on the surface treatment.
Widget paintSnackbar(
  BuildContext context,
  SnackbarState state,
  SnackbarSlots slots,
  CamoTheme theme,
  CamoSnackbarStyle style,
  SnackbarColors colors, {
  Color? iconColor,
}) {
  final skin = Camouflage.skinOf(context);
  Widget tinted(Color color, Widget child) => CamoContentStyle(
    color: color,
    iconStyle: CamoIconStyle(size: _snackbarIconSize, color: color),
    child: child,
  );
  final icon = slots.icon;
  final action = slots.action;
  final dismiss = slots.dismiss;
  return skin.surfaceTreatment.decorate(
    color: colors.container,
    shape: style.shape,
    elevation: theme.elevation.of(style.elevation),
    theme: theme,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.minHeight),
      child: Padding(
        padding: style.padding,
        child: Row(
          spacing: theme.spacing.s,
          children: [
            if (icon != null) tinted(iconColor ?? colors.text, icon),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: theme.spacing.s),
                child: Text(
                  state.message,
                  style: style.textStyle.copyWith(color: colors.text),
                ),
              ),
            ),
            if (action != null) tinted(colors.action, action),
            if (dismiss != null) tinted(colors.text, dismiss),
          ],
        ),
      ),
    ),
  );
}

/// Fluent's MessageBar: the intent's background with its border, radius 4.
class FluentBannerRenderer implements CamoBannerRenderer {
  /// Creates the renderer.
  const FluentBannerRenderer();

  @override
  CamoBannerStyle defaults(CamoTheme theme) => CamoBannerStyle(
    defaultAppearance: Appearance.soft,
    shape: theme.shapes.small,
    padding: EdgeInsetsDirectional.all(theme.spacing.m),
    titleStyle: theme.typography.titleSmall.copyWith(
      fontWeight: FontWeight.w600,
    ),
    messageStyle: theme.typography.bodyMedium,
    iconSize: 20,
    accentBorder: false,
    accentWidth: 4,
    borderWidth: 1,
    toneIcons: const ToneIcons(
      info: IconSource.builder(feedbackInfoIcon),
      success: IconSource.builder(feedbackSuccessIcon),
      warning: IconSource.builder(feedbackWarningIcon),
      error: IconSource.builder(feedbackErrorIcon),
    ),
    dismissIcon: const IconSource.builder(feedbackCloseIcon),
  );

  @override
  Widget render(
    BuildContext context,
    BannerState state,
    BannerSlots slots,
    CamoTheme theme,
    CamoBannerStyle style,
  ) => paintBanner(
    context,
    state,
    slots,
    theme,
    style,
    border: style
        .colorsFor(state.appearance, state.tone, theme)
        .accent
        .withValues(alpha: _intentBorder),
  );
}

/// A banner: the tone's surface (a border for outline), the icon in the accent, texts, actions below, the ✕.
Widget paintBanner(
  BuildContext context,
  BannerState state,
  BannerSlots slots,
  CamoTheme theme,
  CamoBannerStyle style, {
  Color? border,
}) {
  final skin = Camouflage.skinOf(context);
  final colors = style.colorsFor(state.appearance, state.tone, theme);
  final spacing = theme.spacing;
  final outline = colors.border ?? border;
  Widget tinted(Color color, Widget child) => CamoContentStyle(
    color: color,
    iconStyle: CamoIconStyle(size: style.iconSize, color: color),
    child: child,
  );
  final icon = slots.icon;
  final dismiss = slots.dismiss;
  final title = state.title;
  Widget body = Padding(
    padding: style.padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.m,
      children: [
        if (icon != null) tinted(colors.accent, icon),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              if (title != null)
                Text(
                  title,
                  style: style.titleStyle.copyWith(color: colors.content),
                ),
              Text(
                state.message,
                style: style.messageStyle.copyWith(color: colors.content),
              ),
              if (slots.actions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: spacing.xs),
                  child: tinted(
                    colors.accent,
                    Wrap(
                      spacing: spacing.s,
                      runSpacing: spacing.xs,
                      children: slots.actions,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (dismiss != null) tinted(colors.content, dismiss),
      ],
    ),
  );
  if (style.accentBorder) {
    body = DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: colors.accent, width: style.accentWidth),
        ),
      ),
      child: body,
    );
  }
  Widget banner = skin.surfaceTreatment.decorate(
    color: colors.container,
    shape: style.shape,
    elevation: 0,
    theme: theme,
    child: ClipRRect(borderRadius: style.shape, child: body),
  );
  if (outline != null) {
    banner = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: style.shape,
        border: Border.all(color: outline, width: style.borderWidth),
      ),
      child: banner,
    );
  }
  return banner;
}

Widget _glyph(double size, Color? color, void Function(Path p) draw) =>
    CustomPaint(
      size: Size.square(size),
      painter: _StrokePainter(color ?? const Color(0xFF000000), draw),
    );

void _ring(Path p) =>
    p.addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9));

/// An ⓘ in a ring.
Widget feedbackInfoIcon(double size, Color? color) => _glyph(size, color, (p) {
  _ring(p);
  p
    ..moveTo(12, 11)
    ..lineTo(12, 16.5)
    ..moveTo(12, 7.5)
    ..lineTo(12, 7.6);
});

/// A ✓ in a ring.
Widget feedbackSuccessIcon(double size, Color? color) =>
    _glyph(size, color, (p) {
      _ring(p);
      p
        ..moveTo(8, 12.5)
        ..lineTo(11, 15.5)
        ..lineTo(16, 9);
    });

/// A ! in a triangle.
Widget feedbackWarningIcon(double size, Color? color) =>
    _glyph(size, color, (p) {
      p
        ..moveTo(12, 3.5)
        ..lineTo(21.5, 20)
        ..lineTo(2.5, 20)
        ..close()
        ..moveTo(12, 10)
        ..lineTo(12, 14)
        ..moveTo(12, 17)
        ..lineTo(12, 17.1);
    });

/// A ✕ in a ring.
Widget feedbackErrorIcon(double size, Color? color) => _glyph(size, color, (p) {
  _ring(p);
  p
    ..moveTo(9, 9)
    ..lineTo(15, 15)
    ..moveTo(15, 9)
    ..lineTo(9, 15);
});

/// A ✕.
Widget feedbackCloseIcon(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(6, 6)
    ..lineTo(18, 18)
    ..moveTo(18, 6)
    ..lineTo(6, 18);
});

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.color, this.draw);

  final Color color;
  final void Function(Path p) draw;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path();
    draw(path);
    canvas
      ..scale(s)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.color != color;
}
