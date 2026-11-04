import 'dart:ui';

/// Which way bars run.
enum BarOrientation {
  /// Bars rise from the bottom.
  vertical,

  /// Bars run from the start edge (the left, or the right in a right-to-left layout).
  horizontal,
}

/// How the series of a category sit.
enum BarMode {
  /// Side by side.
  grouped,

  /// On top of each other.
  stacked,
}

/// The side of a bar that is its free end (the one that gets the radius).
enum BarEdge {
  /// The top.
  top,

  /// The bottom.
  bottom,

  /// The left.
  left,

  /// The right.
  right,
}

/// One bar: the `series`' `value` in `category`, its `rect`, and the free `end` edge (`null` inside a stack).
class BarRect {
  /// Creates a bar.
  const BarRect(this.category, this.series, this.value, this.rect, this.end);

  /// The category index.
  final int category;

  /// The index among the visible series.
  final int series;

  /// The value.
  final double value;

  /// Where the bar is.
  final Rect rect;

  /// The free end, or `null` for the inside of a stack.
  final BarEdge? end;
}

// Where bars go along the category axis and the value axis, for one chart.
class _BarLayout {
  _BarLayout(
    this.plot,
    this.vertical,
    this.categories,
    this.groupGap,
    (double, double) domain,
  ) : _start = domain.$1,
      _extent = domain.$2 - domain.$1 {
    bandLength = (vertical ? plot.width : plot.height) / categories;
    groupLength = bandLength / (1 + groupGap);
    _valueLength = vertical ? plot.height : plot.width;
    zero = position(0.clamp(domain.$1, domain.$2).toDouble());
  }

  final Rect plot;
  final bool vertical;
  final int categories;
  final double groupGap;
  final double _start;
  final double _extent;
  late final double bandLength;
  late final double groupLength;
  late final double _valueLength;
  late final double zero;

  // A value's distance from the start of the value axis (the bottom for vertical bars).
  double position(double value) =>
      (_extent == 0 ? 0.0 : (value - _start) / _extent) * _valueLength;

  // Where a group starts along the category axis.
  double groupStart(int category) =>
      category * bandLength + (bandLength - groupLength) / 2;

  // A bar covering `low..high` on the value axis and `width` from `start` on the category axis.
  BarRect bar(
    int category,
    int series,
    double value,
    (double, double) along,
    double start,
    double width, {
    required bool free,
  }) {
    final end = _endOf(vertical, value >= 0, free);
    final (low, high) = along;
    final rect = vertical
        ? Rect.fromLTRB(
            plot.left + start,
            plot.bottom - high,
            plot.left + start + width,
            plot.bottom - low,
          )
        : Rect.fromLTRB(
            plot.left + low,
            plot.top + start,
            plot.left + high,
            plot.top + start + width,
          );
    return BarRect(category, series, value, rect, end);
  }
}

BarEdge? _endOf(bool vertical, bool positive, bool free) {
  if (!free) return null;
  if (vertical) return positive ? BarEdge.top : BarEdge.bottom;
  return positive ? BarEdge.right : BarEdge.left;
}

/// The bars of a bar chart: [series] holds one list of values per visible series, one value per category, drawn in
/// [plot] against [domain] (low, high).
///
/// Grouped bars sit side by side, each [barGap] apart; stacked bars pile positives up and negatives down,
/// separately. [groupGap] is the space between groups as a share of a group. Bars grow from the zero baseline (or
/// the nearest edge when zero is outside [domain]). With [rtl] the bars mirror: vertical bars run from the right,
/// horizontal bars start at the right edge.
List<BarRect> barRects({
  required Rect plot,
  required int categories,
  required List<List<double?>> series,
  required BarMode mode,
  required BarOrientation orientation,
  required (double, double) domain,
  required double barGap,
  required double groupGap,
  required bool rtl,
}) {
  if (categories == 0 || series.isEmpty) return const [];
  final layout = _BarLayout(
    plot,
    orientation == BarOrientation.vertical,
    categories,
    groupGap,
    domain,
  );
  final bars = [
    for (var c = 0; c < categories; c++)
      ...mode == BarMode.grouped
          ? _grouped(layout, c, series, barGap)
          : _stacked(layout, c, series),
  ];
  return rtl ? [for (final bar in bars) _mirrored(bar, plot)] : bars;
}

List<BarRect> _grouped(
  _BarLayout layout,
  int category,
  List<List<double?>> series,
  double barGap,
) {
  final width =
      ((layout.groupLength - (series.length - 1) * barGap) / series.length)
          .clamp(1.0, double.infinity)
          .toDouble();
  final bars = <BarRect>[];
  for (var i = 0; i < series.length; i++) {
    final value = category < series[i].length ? series[i][category] : null;
    if (value == null) continue;
    final start = layout.groupStart(category) + i * (width + barGap);
    final tip = layout.position(value);
    final along = tip < layout.zero ? (tip, layout.zero) : (layout.zero, tip);
    bars.add(layout.bar(category, i, value, along, start, width, free: true));
  }
  return bars;
}

List<BarRect> _stacked(
  _BarLayout layout,
  int category,
  List<List<double?>> series,
) {
  final present = <(int, double)>[
    for (var i = 0; i < series.length; i++)
      if (category < series[i].length && series[i][category] != null)
        (i, series[i][category]!),
  ];
  int? lastUp;
  int? lastDown;
  for (final (index, value) in present) {
    if (value >= 0) {
      lastUp = index;
    } else {
      lastDown = index;
    }
  }
  var up = layout.zero;
  var down = layout.zero;
  final bars = <BarRect>[];
  for (final (index, value) in present) {
    final size = layout.position(value) - layout.zero;
    final from = value >= 0 ? up : down;
    final to = from + size;
    if (value >= 0) {
      up = to;
    } else {
      down = to;
    }
    final free = index == (value >= 0 ? lastUp : lastDown);
    final along = from < to ? (from, to) : (to, from);
    bars.add(
      layout.bar(
        category,
        index,
        value,
        along,
        layout.groupStart(category),
        layout.groupLength,
        free: free,
      ),
    );
  }
  return bars;
}

BarRect _mirrored(BarRect bar, Rect plot) {
  final r = bar.rect;
  final flipped = Rect.fromLTRB(
    plot.left + plot.right - r.right,
    r.top,
    plot.left + plot.right - r.left,
    r.bottom,
  );
  final end = switch (bar.end) {
    BarEdge.left => BarEdge.right,
    BarEdge.right => BarEdge.left,
    final other => other,
  };
  return BarRect(bar.category, bar.series, bar.value, flipped, end);
}

/// The bar the pointer is at: the one whose column (row, for horizontal bars) is nearest to [point] across the
/// category axis, and among those the nearest along the value axis. `null` when there are no bars.
BarRect? nearestBar(
  List<BarRect> bars,
  Offset point, {
  required bool vertical,
}) {
  BarRect? best;
  var bestAcross = 0.0;
  var bestAlong = 0.0;
  for (final bar in bars) {
    final across = vertical
        ? _gap(bar.rect.left, bar.rect.right, point.dx)
        : _gap(bar.rect.top, bar.rect.bottom, point.dy);
    final along = vertical
        ? _gap(bar.rect.top, bar.rect.bottom, point.dy)
        : _gap(bar.rect.left, bar.rect.right, point.dx);
    if (best == null ||
        across < bestAcross ||
        (across == bestAcross && along < bestAlong)) {
      best = bar;
      bestAcross = across;
      bestAlong = along;
    }
  }
  return best;
}

double _gap(double low, double high, double at) {
  if (at < low) return low - at;
  if (at > high) return at - high;
  return 0;
}
