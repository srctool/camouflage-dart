import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_charts/src/cartesian_plot.dart';
import 'package:camouflage_charts/src/chart_model.dart';
import 'package:camouflage_charts/src/line_geometry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stacking adds series up and leaves gaps and negatives out', () {
    final bands = stack([
      [1, 2, null],
      [3, -4, 5],
    ]);
    expect(bands[0], [(0.0, 1.0), (0.0, 2.0), null]);
    expect(bands[1], [(1.0, 4.0), (2.0, 2.0), (0.0, 5.0)]);
  });

  test('the nearest index is the position closest to x', () {
    const positions = [0.0, 10.0, 20.0];
    expect(nearestIndex(positions, 14), 1);
    expect(nearestIndex(positions, 16), 2);
    expect(nearestIndex(const [], 5), isNull);
  });

  test('gaps split a line into runs', () {
    const p = Offset.zero;
    expect(gapRuns(const [p, null, p, p, null]), [(0, 1), (2, 4)]);
    expect(gapRuns(const [null, null]), isEmpty);
  });

  test('a step goes across then up', () {
    expect(stepPoints(const [Offset(0, 5), Offset(10, 8)]), const [
      Offset(0, 5),
      Offset(10, 5),
      Offset(10, 8),
    ]);
  });

  test('monotone smoothing never overshoots', () {
    const points = [
      Offset(0, 10),
      Offset(10, 0),
      Offset(20, 0),
      Offset(30, 10),
      Offset(40, 9),
    ];
    final pieces = curvePieces(points, LineCurve.smooth);
    expect(pieces, hasLength(4));
    for (var i = 0; i < pieces.length; i++) {
      final low = points[i].dy < points[i + 1].dy
          ? points[i].dy
          : points[i + 1].dy;
      final high = points[i].dy < points[i + 1].dy
          ? points[i + 1].dy
          : points[i].dy;
      expect(
        pieces[i].control1.dy,
        inInclusiveRange(low, high),
        reason: 'piece $i',
      );
      expect(
        pieces[i].control2.dy,
        inInclusiveRange(low, high),
        reason: 'piece $i',
      );
    }
  });

  test('Catmull-Rom passes through the data but can overshoot', () {
    const points = [Offset(0, 0), Offset(10, 0), Offset(20, 0), Offset(30, 10)];
    final pieces = curvePieces(points, LineCurve.catmullRom);
    expect([for (final p in pieces) p.end], points.skip(1));
    expect(pieces[1].control2.dy, lessThan(0));
    expect(curvePieces(points, LineCurve.smooth)[1].control2.dy, 0);
  });

  test('linear and step have no cubic pieces', () {
    const points = [Offset(0, 0), Offset(10, 5)];
    expect(curvePieces(points, LineCurve.linear), isEmpty);
    expect(curvePieces(points, LineCurve.step), isEmpty);
    expect(curvePieces(points.take(1).toList(), LineCurve.smooth), isEmpty);
  });

  test('categories spread evenly or follow time', () {
    const plot = Rect.fromLTRB(0, 0, 100, 10);
    expect(categoryPositions(plot, 3, null), [0, 50, 100]);
    expect(categoryPositions(plot, 1, null), [50]);
    expect(categoryPositions(plot, 3, const [0, 10, 40]), [0, 25, 100]);
    expect(categoryPositions(plot, 3, const [0, 10, 5]), [0, 50, 100]);
    expect(categoryPositions(plot, 0, null), isEmpty);
  });

  test('the value axis includes zero for areas and honors fixed bounds', () {
    const values = <List<double?>>[
      [12, 18],
    ];
    expect(
      lineDomain(LineKind.line, values, null, const ChartAxis()).low,
      greaterThan(0),
    );
    expect(lineDomain(LineKind.area, values, null, const ChartAxis()).low, 0);
    final fixed = lineDomain(
      LineKind.line,
      values,
      null,
      const ChartAxis(min: 0, max: 50),
    );
    expect(fixed.range, (0.0, 50.0));
    final both = [...values, ...values];
    final stacked = lineDomain(
      LineKind.stackedArea,
      both,
      stack(both),
      const ChartAxis(),
    );
    expect(stacked.high, greaterThanOrEqualTo(36));
  });

  test('the model puts areas on the baseline or the stack below', () {
    const plot = Rect.fromLTRB(0, 0, 100, 100);
    const values = <List<double?>>[
      [10, 10],
      [10, null],
    ];
    final bands = stack(values);
    final domain = lineDomain(
      LineKind.stackedArea,
      values,
      bands,
      const ChartAxis(min: 0, max: 20),
    );
    const colors = [Color(0xFFFF0000), Color(0xFF0000FF)];
    final stacked = lineModel(
      kind: LineKind.stackedArea,
      plot: plot,
      values: values,
      bands: bands,
      colors: colors,
      domain: domain,
      xs: const [0, 100],
    );
    expect(stacked.specs[0].upper[0], const Offset(0, 50));
    expect(stacked.specs[0].lower![0], const Offset(0, 100));
    expect(stacked.specs[1].upper[0], const Offset(0, 0));
    expect(stacked.specs[1].lower![0], const Offset(0, 50));
    expect(stacked.specs[1].upper[1], isNull);
    final line = lineModel(
      kind: LineKind.line,
      plot: plot,
      values: values,
      bands: null,
      colors: colors,
      domain: domain,
      xs: const [0, 100],
    );
    expect(line.specs[0].lower, isNull);
  });

  test('keys walk categories and series within bounds', () {
    expect(walkTarget(LogicalKeyboardKey.arrowRight, (0, 0), 3, 2), (1, 0));
    expect(walkTarget(LogicalKeyboardKey.arrowRight, (2, 0), 3, 2), (2, 0));
    expect(walkTarget(LogicalKeyboardKey.arrowLeft, (0, 0), 3, 2), (0, 0));
    expect(walkTarget(LogicalKeyboardKey.arrowDown, (1, 0), 3, 2), (1, 1));
    expect(walkTarget(LogicalKeyboardKey.arrowUp, (1, 1), 3, 2), (1, 0));
    expect(walkTarget(LogicalKeyboardKey.end, (0, 1), 3, 2), (2, 1));
    expect(walkTarget(LogicalKeyboardKey.home, (2, 1), 3, 2), (0, 1));
    expect(walkTarget(LogicalKeyboardKey.keyA, (0, 0), 3, 2), isNull);
    expect(walkTarget(LogicalKeyboardKey.arrowRight, (0, 0), 0, 0), isNull);
  });

  test('the summary names each series trend', () {
    expect(
      chartSummary(
        'Line chart',
        const ['Jan', 'Feb'],
        const [
          ChartSeries(name: 'Sales', values: [3, 9]),
        ],
      ),
      'Line chart, 1 series, 2 categories. Sales: from 3 to 9, up 200%',
    );
    expect(
      chartSummary('Bar chart', const ['Q1'], const []),
      'Bar chart, 0 series, 1 category',
    );
  });

  test('no data means no categories or only gaps', () {
    expect(
      noChartData(const [], const [
        ChartSeries(name: 'a', values: [1]),
      ]),
      isTrue,
    );
    expect(
      noChartData(
        const ['x'],
        const [
          ChartSeries(name: 'a', values: [null]),
        ],
      ),
      isTrue,
    );
    expect(
      noChartData(
        const ['x'],
        const [
          ChartSeries(name: 'a', values: [1]),
        ],
      ),
      isFalse,
    );
  });

  test('a stacked domain reaches the sums', () {
    const values = <List<double?>>[
      [4],
      [-2],
      [3],
    ];
    final stacked = barDomain(values, BarMode.stacked, const ChartAxis());
    expect((stacked.low, stacked.high), (-2.0, 8.0));
    final grouped = barDomain(values, BarMode.grouped, const ChartAxis());
    expect((grouped.low, grouped.high), (-2.0, 4.0));
    expect(
      barDomain(
        const [
          [4],
        ],
        BarMode.grouped,
        const ChartAxis(),
      ).low,
      0,
    );
  });
}
