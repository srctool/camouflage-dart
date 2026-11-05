import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'material_actions.dart';

const double _amplitude = 3;
const double _waveLength = 40;
const double _waveHeight = 12;
const double _segment = 0.4;
const double _step = 2;
const int _loopMillis = 1600;
const int _pulseMillis = 1200;
const double _pulseLow = 0.4;

/// M3 Expressive's linear indicator: the active part is a drifting wave on a straight track, the stop dot stays.
/// Under reduced motion the wave holds still (and indeterminate bars pulse instead of sweeping).
class MaterialWavyProgressBarRenderer implements CamoProgressBarRenderer {
  /// Creates the renderer.
  const MaterialWavyProgressBarRenderer();

  @override
  CamoProgressStyle defaults(CamoTheme theme) =>
      const MaterialProgressCircleRenderer().defaults(theme);

  @override
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  ) => _WavyBar(state: state, theme: theme, style: style);
}

class _WavyBar extends StatefulWidget {
  const _WavyBar({
    required this.state,
    required this.theme,
    required this.style,
  });

  final ProgressState state;
  final CamoTheme theme;
  final CamoProgressStyle style;

  @override
  State<_WavyBar> createState() => _WavyBarState();
}

class _WavyBarState extends State<_WavyBar>
    with SingleTickerProviderStateMixin {
  late final _loop = AnimationController(vsync: this);

  bool get _reduced => widget.theme.motion.durationLong == Duration.zero;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_WavyBar old) {
    super.didUpdateWidget(old);
    _sync();
  }

  // The wave drifts forever, unless motion is reduced; then only an indeterminate bar pulses.
  void _sync() {
    final indeterminate = widget.state.value == null;
    if (_reduced && !indeterminate) {
      _loop.stop();
      return;
    }
    _loop.duration = Duration(
      milliseconds: _reduced ? _pulseMillis : _loopMillis,
    );
    if (_loop.isAnimating) return;
    if (_reduced) {
      _loop.repeat(reverse: true);
    } else {
      _loop.repeat();
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
      height: _waveHeight,
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
              painter: _WavyPainter(
                value: value == null ? null : shown,
                phase: _reduced ? 0 : _loop.value,
                reduced: _reduced,
                active: colors.active,
                track: colors.track,
                thickness: style.barHeight,
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

class _WavyPainter extends CustomPainter {
  _WavyPainter({
    required this.value,
    required this.phase,
    required this.reduced,
    required this.active,
    required this.track,
    required this.thickness,
    required this.gap,
    required this.stop,
    required this.rtl,
  });

  final double? value;
  final double phase;
  final bool reduced;
  final Color active;
  final Color track;
  final double thickness;
  final double gap;
  final bool stop;
  final bool rtl;

  double _x(Size size, double x) => rtl ? size.width - x : x;

  void _straight(Canvas canvas, Size size, double from, double to) {
    if (to <= from) return;
    final y = size.height / 2;
    canvas.drawLine(
      Offset(_x(size, from), y),
      Offset(_x(size, to), y),
      Paint()
        ..color = track
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round,
    );
  }

  void _wave(Canvas canvas, Size size, double from, double to) {
    if (to <= from) return;
    final mid = size.height / 2;
    double y(double x) =>
        mid + _amplitude * math.sin(2 * math.pi * (x / _waveLength - phase));
    final path = Path()..moveTo(_x(size, from), y(from));
    for (var x = from + _step; x < to; x += _step) {
      path.lineTo(_x(size, x), y(x));
    }
    path.lineTo(_x(size, to), y(to));
    canvas.drawPath(
      path,
      Paint()
        ..color = active
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final value = this.value;
    if (value == null && reduced) return _wave(canvas, size, 0, w);
    if (value == null) {
      final length = w * _segment;
      final start = -length + (w + length) * phase;
      _straight(canvas, size, 0, w);
      return _wave(
        canvas,
        size,
        math.max(0, start),
        math.min(w, start + length),
      );
    }
    final end = w * value;
    _wave(canvas, size, 0, end);
    _straight(canvas, size, math.min(w, end > 0 ? end + gap : 0), w);
    if (stop) {
      final r = thickness / 2;
      canvas.drawCircle(
        Offset(_x(size, w - r), size.height / 2),
        r,
        Paint()..color = active,
      );
    }
  }

  @override
  bool shouldRepaint(_WavyPainter old) =>
      old.value != value ||
      old.phase != phase ||
      old.reduced != reduced ||
      old.active != active ||
      old.track != track ||
      old.thickness != thickness ||
      old.gap != gap ||
      old.stop != stop ||
      old.rtl != rtl;
}
