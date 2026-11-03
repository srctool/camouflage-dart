import 'dart:ui';

import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ticks step by nice numbers', () {
    expect(niceTicks(3, 97, 5), [0, 20, 40, 60, 80, 100]);
    expect(niceTicks(0.1, 0.9, 3), [0, 0.5, 1]);
  });

  test('ticks cover the range', () {
    final ticks = niceTicks(-13, 41);
    expect(ticks.first <= -13 && ticks.last >= 41, isTrue);
  });

  test('a flat range widens around its value', () {
    final seven = niceTicks(7, 7);
    expect(seven.first < 7 && seven.last > 7, isTrue);
    final zero = niceTicks(0, 0);
    expect(zero.first < 0 && zero.last > 0, isTrue);
  });

  test('ticks have no floating point drift', () {
    expect(niceTicks(0, 0.5, 6).map((t) => (t * 10).round() / 10), [
      0,
      0.1,
      0.2,
      0.3,
      0.4,
      0.5,
    ]);
  });

  test('numbers read without trailing zeros', () {
    expect(formatChartNumber(3), '3');
    expect(formatChartNumber(3.46), '3.5');
    expect(formatChartNumber(-2.5), '-2.5');
    expect(formatChartNumber(-0.01), '0');
    expect(formatChartNumber(1234567), '1234567');
  });

  test('a scale maps and inverts', () {
    const y = LinearScale(0, 100, 200, 0);
    expect(y.map(0), 200);
    expect(y.map(100), 0);
    expect(y.invert(100), 50);
  });

  test('the summary names the trend', () {
    expect(sparklineSummary([3, 5, 9]), 'Trend from 3 to 9, up 200%');
    expect(
      sparklineSummary([10, null, 5], 'Signups'),
      'Signups: from 10 to 5, down 50%',
    );
    expect(sparklineSummary([4, 4]), 'Trend from 4 to 4, flat');
    expect(sparklineSummary([0, 6]), 'Trend from 0 to 6, up by 6');
    expect(sparklineSummary([null, 7]), 'Trend at 7');
    expect(sparklineSummary([null, null], 'Load'), 'Load: no data');
  });

  test('downsampling keeps the peaks', () {
    final values = List<double?>.generate(1000, (i) => i == 500 ? 99 : 1);
    final reduced = downsample(values, 50);
    expect(reduced.length <= 100, isTrue);
    expect(reduced, contains(99));
    expect(downsample(values.take(10).toList(), 50), values.take(10).toList());
  });

  test('points break at gaps', () {
    final points = sparklinePoints(
      [0, null, 2, 4],
      (0, 4),
      const Size(30, 10),
      0,
    );
    expect(sparklineSegments(points).map((r) => r.length), [1, 2]);
    expect(points[0], const Offset(0, 10));
    expect(points[3], const Offset(30, 0));
  });

  test('a flat series sits in the middle, a single point is centered', () {
    expect(sparklinePoints([5, 5], (5, 5), const Size(10, 10), 0)[0]!.dy, 5);
    expect(sparklinePoints([1], (0, 2), const Size(10, 10), 0)[0]!.dx, 5);
  });

  test('extremes are the top and bottom points', () {
    final found = sparklineExtremes([
      const Offset(0, 5),
      const Offset(1, 1),
      null,
      const Offset(2, 9),
    ]);
    expect(found, [const Offset(1, 1), const Offset(2, 9)]);
  });
}
