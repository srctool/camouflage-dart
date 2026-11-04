import 'dart:ui';

import 'package:camouflage_charts/src/bar_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

const _plot = Rect.fromLTRB(0, 0, 100, 100);

List<BarRect> _bars(
  List<List<double?>> series, {
  int? categories,
  BarMode mode = BarMode.grouped,
  BarOrientation orientation = BarOrientation.vertical,
  (double, double) domain = (0, 10),
  double barGap = 0,
  double groupGap = 0,
  bool rtl = false,
}) => barRects(
  plot: _plot,
  categories: categories ?? series.first.length,
  series: series,
  mode: mode,
  orientation: orientation,
  domain: domain,
  barGap: barGap,
  groupGap: groupGap,
  rtl: rtl,
);

void main() {
  test('vertical bars rise from the bottom, one band per category', () {
    final bars = _bars([
      [10, 5],
    ]);
    expect(bars[0].rect, const Rect.fromLTRB(0, 0, 50, 100));
    expect(bars[1].rect, const Rect.fromLTRB(50, 50, 100, 100));
    expect(bars[0].end, BarEdge.top);
  });

  test('grouped bars sit side by side with the gap', () {
    final bars = _bars([
      [10],
      [5],
    ], barGap: 4);
    expect(bars[0].rect.left, 0);
    expect(bars[0].rect.width, 48);
    expect(bars[1].rect.left, 52);
    expect(bars[1].rect.top, 50);
  });

  test('the group gap leaves space between groups', () {
    final bars = _bars([
      [10, 10],
    ], groupGap: 1);
    expect(bars[0].rect.left, 12.5);
    expect(bars[0].rect.width, 25);
    expect(bars[1].rect.left, 62.5);
  });

  test('stacked bars pile up and negatives go down separately', () {
    final bars = _bars(
      [
        [4],
        [-2],
        [3],
      ],
      mode: BarMode.stacked,
      domain: (-2, 8),
    );
    expect(bars[0].rect, const Rect.fromLTRB(0, 40, 100, 80));
    expect(bars[1].rect, const Rect.fromLTRB(0, 80, 100, 100));
    expect(bars[2].rect, const Rect.fromLTRB(0, 10, 100, 40));
    expect([for (final b in bars) b.end], [null, BarEdge.bottom, BarEdge.top]);
  });

  test('a negative bar hangs from zero', () {
    final bars = _bars(
      [
        [-5],
      ],
      domain: (-10, 10),
    );
    expect(bars[0].rect, const Rect.fromLTRB(0, 50, 100, 75));
    expect(bars[0].end, BarEdge.bottom);
  });

  test('a zero value is a zero-height bar at the baseline', () {
    final bars = _bars([
      [0, 10],
    ]);
    expect(bars[0].rect.height, 0);
    expect(bars[0].rect.top, 100);
  });

  test('gaps have no bar', () {
    final bars = _bars([
      [null, 10],
    ]);
    expect([for (final b in bars) b.category], [1]);
  });

  test('horizontal bars run right, one row per category', () {
    final bars = _bars([
      [10, 5],
    ], orientation: BarOrientation.horizontal);
    expect(bars[0].rect, const Rect.fromLTRB(0, 0, 100, 50));
    expect(bars[1].rect, const Rect.fromLTRB(0, 50, 50, 100));
    expect(bars[0].end, BarEdge.right);
  });

  test('right-to-left mirrors vertical and horizontal bars', () {
    final vertical = _bars([
      [10, 5],
    ], rtl: true);
    expect(vertical[0].rect, const Rect.fromLTRB(50, 0, 100, 100));
    expect(vertical[1].rect, const Rect.fromLTRB(0, 50, 50, 100));
    final horizontal = _bars(
      [
        [10, 5],
      ],
      orientation: BarOrientation.horizontal,
      rtl: true,
    );
    expect(horizontal[0].rect, const Rect.fromLTRB(0, 0, 100, 50));
    expect(horizontal[1].rect, const Rect.fromLTRB(50, 50, 100, 100));
    expect(horizontal[1].end, BarEdge.left);
  });

  test('no categories or series means no bars', () {
    expect(
      _bars([
        [1],
      ], categories: 0),
      isEmpty,
    );
    expect(_bars(const [], categories: 2), isEmpty);
  });

  test('the bar nearest the pointer is the one in its column', () {
    final bars = _bars([
      [10, 5],
    ]);
    expect(nearestBar(bars, const Offset(10, 90), vertical: true)!.category, 0);
    expect(nearestBar(bars, const Offset(80, 95), vertical: true)!.category, 1);
    expect(nearestBar(bars, const Offset(80, 5), vertical: true)!.category, 1);
    expect(nearestBar(const [], const Offset(1, 1), vertical: true), isNull);
    final rows = _bars([
      [10, 5],
    ], orientation: BarOrientation.horizontal);
    expect(
      nearestBar(rows, const Offset(95, 80), vertical: false)!.category,
      1,
    );
  });
}
