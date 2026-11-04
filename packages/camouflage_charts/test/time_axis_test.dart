import 'package:camouflage_charts/src/time_axis.dart';
import 'package:flutter_test/flutter_test.dart';

const _hour = 3600000;
const _day = 24 * _hour;

int _utc(int year, int month, int day, [int hours = 0]) =>
    daysFromCivil(year, month, day) * _day + hours * _hour;

void main() {
  test('civil dates round trip through days', () {
    expect(daysFromCivil(1970, 1, 1), 0);
    expect(daysFromCivil(2000, 3, 1), 11017);
    expect(civilFromDays(11017), (2000, 3, 1));
    expect(civilFromDays(daysFromCivil(2024, 2, 29)), (2024, 2, 29));
    expect(civilFromDays(-1), (1969, 12, 31));
    for (var days = -800; days <= 800; days += 7) {
      final (y, m, d) = civilFromDays(days * 40);
      expect(daysFromCivil(y, m, d), days * 40);
    }
  });

  test('three days get daily ticks', () {
    final ticks = timeTicks(_utc(2026, 3, 1), _utc(2026, 3, 4), 5);
    expect(ticks.step, TimeStep.day);
    expect(ticks.ticks, [
      _utc(2026, 3, 1),
      _utc(2026, 3, 2),
      _utc(2026, 3, 3),
      _utc(2026, 3, 4),
    ]);
  });

  test("a day's ticks fall on hours", () {
    final ticks = timeTicks(_utc(2026, 3, 1), _utc(2026, 3, 2), 9);
    expect(ticks.step, TimeStep.threeHours);
    expect(ticks.ticks, hasLength(9));
  });

  test('a year gets quarters aligned to January', () {
    final ticks = timeTicks(_utc(2026, 1, 1), _utc(2026, 12, 31), 6);
    expect(ticks.step, TimeStep.quarter);
    expect(ticks.ticks, [
      _utc(2026, 1, 1),
      _utc(2026, 4, 1),
      _utc(2026, 7, 1),
      _utc(2026, 10, 1),
    ]);
    final mid = timeTicks(_utc(2026, 2, 10), _utc(2026, 12, 31), 6);
    expect(mid.ticks.first, _utc(2026, 4, 1));
  });

  test('years step on round years', () {
    final ticks = timeTicks(_utc(2019, 6, 1), _utc(2031, 6, 1), 4);
    expect(ticks.step, TimeStep.fiveYears);
    expect(ticks.ticks, [_utc(2020, 1, 1), _utc(2025, 1, 1), _utc(2030, 1, 1)]);
  });

  test('ticks follow the local day of the zone', () {
    final ticks = timeTicks(
      _utc(2026, 3, 1),
      _utc(2026, 3, 4),
      5,
      offsetMinutes: 60,
    );
    expect(ticks.ticks.first, _utc(2026, 3, 1, 23));
  });

  test('weeks start on Monday', () {
    final ticks = timeTicks(_utc(2026, 3, 1), _utc(2026, 3, 29), 5);
    expect(ticks.step, TimeStep.week);
    expect(ticks.ticks.first, _utc(2026, 3, 2));
  });

  test('labels read as times, dates, months and years', () {
    expect(
      formatChartTime(14 * _hour + _hour ~/ 2, TimeStep.fifteenMinutes),
      '14:30',
    );
    expect(formatChartTime(_utc(2026, 3, 5), TimeStep.day), 'Mar 5');
    expect(formatChartTime(_utc(2026, 3, 1), TimeStep.quarter), 'Mar');
    expect(formatChartTime(_utc(2026, 1, 1), TimeStep.month), '2026');
    expect(formatChartTime(_utc(2030, 1, 1), TimeStep.fiveYears), '2030');
    expect(formatChartTime(0, TimeStep.hour, offsetMinutes: 60), '01:00');
  });
}
