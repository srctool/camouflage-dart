import 'dart:math' as math;
import 'dart:ui';

/// The form of a line chart.
enum LineKind {
  /// Lines.
  line,

  /// Lines with the area below each filled.
  area,

  /// Areas on top of each other; the top edge is the running total.
  stackedArea,
}

/// How a line connects its points.
enum LineCurve {
  /// Straight segments.
  linear,

  /// Monotone cubic: smooth, and never overshoots the data between two points.
  smooth,

  /// Catmull-Rom: smooth through every point; it can overshoot a sharp peak.
  catmullRom,

  /// Horizontal to the next x, then vertical.
  step,
}

/// When a line chart marks its points.
enum MarkerVisibility {
  /// Every point.
  always,

  /// The points at the hovered or focused category.
  onHover,

  /// No points.
  never,
}

/// One series' band in a stack: from `base` up to `top`.
typedef StackBand = (double base, double top);

/// Stacks [series] (one list of values per series, one value per category) in order.
///
/// A `null` value leaves a gap in that series; a negative value adds nothing (stacked areas treat negatives as
/// zero).
List<List<StackBand?>> stack(List<List<double?>> series) {
  var categories = 0;
  for (final values in series) {
    categories = math.max(categories, values.length);
  }
  final running = List<double>.filled(categories, 0);
  return [
    for (final values in series)
      [
        for (var c = 0; c < categories; c++)
          if (c >= values.length || values[c] == null)
            null
          else
            () {
              final base = running[c];
              running[c] += math.max(0, values[c]!);
              return (base, running[c]);
            }(),
      ],
  ];
}

/// The index of the entry of [positions] nearest to [x], or `null` for an empty list.
int? nearestIndex(List<double> positions, double x) {
  int? best;
  for (var i = 0; i < positions.length; i++) {
    if (best == null ||
        (positions[i] - x).abs() < (positions[best] - x).abs()) {
      best = i;
    }
  }
  return best;
}

/// The index ranges (start inclusive, end exclusive) of [points] between gaps.
List<(int, int)> gapRuns(List<Offset?> points) {
  final runs = <(int, int)>[];
  var start = -1;
  for (var i = 0; i < points.length; i++) {
    if (points[i] == null) {
      if (start >= 0) runs.add((start, i));
      start = -1;
    } else if (start < 0) {
      start = i;
    }
  }
  if (start >= 0) runs.add((start, points.length));
  return runs;
}

/// One cubic piece of a smoothed line: two control points and where it ends.
class Cubic {
  /// Creates a cubic piece.
  const Cubic(this.control1, this.control2, this.end);

  /// The control point after the start.
  final Offset control1;

  /// The control point before the end.
  final Offset control2;

  /// Where the piece ends.
  final Offset end;
}

/// The cubic pieces joining [points] (x strictly increasing) for a smoothed [curve]; none for the others.
List<Cubic> curvePieces(List<Offset> points, LineCurve curve) {
  if (points.length < 2) return const [];
  return switch (curve) {
    LineCurve.smooth => _monotone(points),
    LineCurve.catmullRom => _catmullRom(points),
    _ => const [],
  };
}

List<Cubic> _catmullRom(List<Offset> points) => [
  for (var i = 0; i < points.length - 1; i++)
    () {
      final before = points[math.max(0, i - 1)];
      final from = points[i];
      final to = points[i + 1];
      final after = points[math.min(points.length - 1, i + 2)];
      return Cubic(from + (to - before) / 6, to - (after - from) / 6, to);
    }(),
];

// Fritsch-Carlson: tangents are limited so the curve between two points stays between their values.
List<Cubic> _monotone(List<Offset> points) {
  final count = points.length;
  final width = [
    for (var i = 0; i < count - 1; i++) points[i + 1].dx - points[i].dx,
  ];
  final secant = [
    for (var i = 0; i < count - 1; i++)
      width[i] == 0 ? 0.0 : (points[i + 1].dy - points[i].dy) / width[i],
  ];
  final slope = [
    for (var i = 0; i < count; i++)
      if (i == 0)
        secant[0]
      else if (i == count - 1)
        secant[count - 2]
      else if (secant[i - 1] * secant[i] <= 0)
        0.0
      else
        (secant[i - 1] + secant[i]) / 2,
  ];
  for (var i = 0; i < count - 1; i++) {
    if (secant[i] == 0) {
      slope[i] = 0;
      slope[i + 1] = 0;
      continue;
    }
    final a = slope[i] / secant[i];
    final b = slope[i + 1] / secant[i];
    final sum = a * a + b * b;
    if (sum > 9) {
      final scale = 3 / math.sqrt(sum);
      slope[i] = scale * a * secant[i];
      slope[i + 1] = scale * b * secant[i];
    }
  }
  return [
    for (var i = 0; i < count - 1; i++)
      () {
        final from = points[i];
        final to = points[i + 1];
        final third = width[i] / 3;
        return Cubic(
          Offset(from.dx + third, from.dy + slope[i] * third),
          Offset(to.dx - third, to.dy - slope[i + 1] * third),
          to,
        );
      }(),
  ];
}

/// The points of a step line through [points]: each step goes along first, then across.
List<Offset> stepPoints(List<Offset> points) {
  if (points.isEmpty) return points;
  return [
    points.first,
    for (var i = 1; i < points.length; i++) ...[
      Offset(points[i].dx, points[i - 1].dy),
      points[i],
    ],
  ];
}

/// Adds [points] shaped by [curve] to [path]: it continues from the current point when [connect], else moves.
void addCurve(
  Path path,
  List<Offset> points,
  LineCurve curve, {
  bool connect = false,
}) {
  if (points.isEmpty) return;
  final first = points.first;
  if (connect) {
    path.lineTo(first.dx, first.dy);
  } else {
    path.moveTo(first.dx, first.dy);
  }
  switch (curve) {
    case LineCurve.linear:
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
    case LineCurve.step:
      for (final p in stepPoints(points).skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
    case LineCurve.smooth || LineCurve.catmullRom:
      for (final c in curvePieces(points, curve)) {
        path.cubicTo(
          c.control1.dx,
          c.control1.dy,
          c.control2.dx,
          c.control2.dy,
          c.end.dx,
          c.end.dy,
        );
      }
  }
}
