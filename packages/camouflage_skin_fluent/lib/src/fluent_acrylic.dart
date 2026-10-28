import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_solid.dart';

const _blurSigma = 15.0; // a 30 dp blur radius
const _tintAlpha = 0.75;
const _noiseAlpha = 0.02;
const _noiseSize = 64;
const _noiseSeed = 7;

/// Fluent's Acrylic surface: frosted glass for flyouts, menus and dialogs (elevation `level4` and up). It blurs
/// what's painted behind it (30 dp), adds a luminosity tint of the surface color and a light noise, inside
/// Fluent's shadow. Lower containers (cards) stay [FluentSolid].
class FluentAcrylic implements SurfaceTreatment {
  /// Creates the treatment.
  const FluentAcrylic();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) {
    if (elevation < theme.elevation.level4) {
      return const FluentSolid().decorate(
        color: color,
        shape: shape,
        elevation: elevation,
        theme: theme,
        child: child,
      );
    }
    // The shadow alone, around a clear box; the glass goes inside it.
    return const FluentSolid().decorate(
      color: const Color(0x00000000),
      shape: shape,
      elevation: elevation,
      theme: theme,
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: CustomPaint(
            painter: _Glass(color.withValues(alpha: color.a * _tintAlpha)),
            child: child,
          ),
        ),
      ),
    );
  }
}

// A tile of grey speckles, generated once at runtime (nothing bundled); the same every run, for goldens.
final ui.Image _noise = () {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final random = math.Random(_noiseSeed);
  final white = Paint()..color = const Color(0xFFFFFFFF);
  final black = Paint()..color = const Color(0xFF000000);
  for (var x = 0; x < _noiseSize; x++) {
    for (var y = 0; y < _noiseSize; y++) {
      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
        random.nextBool() ? white : black,
      );
    }
  }
  return recorder.endRecording().toImageSync(_noiseSize, _noiseSize);
}();

class _Glass extends CustomPainter {
  _Glass(this.tint);

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawRect(rect, Paint()..color = tint)
      ..drawRect(
        rect,
        Paint()
          ..shader = ui.ImageShader(
            _noise,
            TileMode.repeated,
            TileMode.repeated,
            Matrix4.identity().storage,
          )
          ..color = const Color(0xFF000000).withValues(alpha: _noiseAlpha),
      );
  }

  @override
  bool shouldRepaint(_Glass old) => old.tint != tint;
}
