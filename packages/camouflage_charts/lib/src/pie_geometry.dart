import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';

/// A slice of a pie: its [label], [value] and optional [color]. A negative value counts as zero.
class PieSlice {
  /// Creates a slice.
  const PieSlice({required this.label, required this.value, this.color});

  /// The slice's name.
  final String label;

  /// The slice's value.
  final double value;

  /// The slice's color; `null` takes the next palette color.
  final Color? color;
}

/// The angle of 12 o'clock: slices start there by default.
const double pieTop = -90;

/// The (start, sweep) angle in degrees of each value, clockwise from [startAngle] (0 is 3 o'clock, so -90 is the
/// top).
///
/// Negative values count as zero; with a total of zero every sweep is zero; one value gets the full turn.
List<(double, double)> sliceAngles(List<double> values, double startAngle) {
  final total = values.fold(0.0, (sum, v) => sum + math.max(0, v));
  var start = startAngle;
  return [
    for (final value in values)
      () {
        final sweep = total <= 0 ? 0.0 : math.max(0, value) / total * 360;
        final at = (start, sweep);
        start += sweep;
        return at;
      }(),
  ];
}

/// The index of the slice at [point], between [inner] and [outer] radius around [center]; `null` when none.
int? sliceAt(
  Offset point,
  Offset center,
  double outer,
  double inner,
  List<(double, double)> angles,
) {
  final dx = point.dx - center.dx;
  final dy = point.dy - center.dy;
  final radius = math.sqrt(dx * dx + dy * dy);
  if (radius < inner || radius > outer) return null;
  final angle = math.atan2(dy, dx) * 180 / math.pi;
  for (var i = 0; i < angles.length; i++) {
    final (start, sweep) = angles[i];
    final relative = ((angle - start) % 360 + 360) % 360;
    if (sweep > 0 && relative < sweep) return i;
  }
  return null;
}

/// The point at [radius] from [center] in direction [angle] degrees.
Offset polar(Offset center, double radius, double angle) {
  final radians = angle * math.pi / 180;
  return Offset(
    center.dx + math.cos(radians) * radius,
    center.dy + math.sin(radians) * radius,
  );
}

/// A share as a person reads it: "45%", or "<1%" for a sliver.
String shareText(double share) {
  final percent = share * 100;
  return percent > 0 && percent < 1 ? '<1%' : '${percent.round()}%';
}

/// The screen reader text of a pie: "Pie chart, 4 slices, largest: Search 45%".
String pieSummary(String kind, List<PieSlice> slices) {
  final head =
      '$kind, ${slices.length} ${slices.length == 1 ? 'slice' : 'slices'}';
  final total = slices.fold(0.0, (sum, s) => sum + math.max(0, s.value));
  if (slices.isEmpty || total <= 0) return head;
  var largest = slices.first;
  for (final s in slices) {
    if (s.value > largest.value) largest = s;
  }
  return '$head, largest: ${largest.label} ${shareText(math.max(0, largest.value) / total)}';
}
