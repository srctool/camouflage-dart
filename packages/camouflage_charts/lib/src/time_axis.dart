// A time axis over epoch milliseconds: ticks fall on calendar steps (minutes, hours, days, weeks, months, years)
// in the zone given as a UTC offset. No time package: core and charts stay free of one, and the app passes the
// offset.
const int _minute = 60000;
const int _hour = 60 * _minute;
const int _day = 24 * _hour;
const int _weekdayShift =
    4; // 1970-01-01 was a Thursday, so Monday is day 4 (mod 7)

/// A calendar step between two ticks.
enum TimeStep {
  /// One minute.
  minute(_minute),

  /// Five minutes.
  fiveMinutes(5 * _minute),

  /// Fifteen minutes.
  fifteenMinutes(15 * _minute),

  /// Thirty minutes.
  thirtyMinutes(30 * _minute),

  /// One hour.
  hour(_hour),

  /// Three hours.
  threeHours(3 * _hour),

  /// Six hours.
  sixHours(6 * _hour),

  /// Twelve hours.
  twelveHours(12 * _hour),

  /// One day.
  day(_day),

  /// Two days.
  twoDays(2 * _day),

  /// One week, starting Monday.
  week(7 * _day),

  /// One month.
  month(0, 1),

  /// Three months.
  quarter(0, 3),

  /// Six months.
  halfYear(0, 6),

  /// One year.
  year(0, 12),

  /// Two years.
  twoYears(0, 24),

  /// Five years.
  fiveYears(0, 60),

  /// Ten years.
  tenYears(0, 120);

  const TimeStep(this.millis, [this.months = 0]);

  /// The length in milliseconds for the fixed steps, `0` for the month-based ones.
  final int millis;

  /// The length in months for the calendar steps, `0` for the fixed ones.
  final int months;
}

/// The ticks of a time axis and the step between them.
class TimeTicks {
  /// Creates time ticks.
  const TimeTicks(this.ticks, this.step);

  /// The tick times, epoch milliseconds.
  final List<int> ticks;

  /// The step between ticks.
  final TimeStep step;
}

int _floorDiv(int a, int b) {
  final q = a ~/ b;
  return (a % b != 0 && (a < 0) != (b < 0)) ? q - 1 : q;
}

/// The days since 1970-01-01 of a civil date (proleptic Gregorian; Howard Hinnant's algorithm).
int daysFromCivil(int year, int month, int day) {
  final y = month <= 2 ? year - 1 : year;
  final era = _floorDiv(y, 400);
  final yearOfEra = y - era * 400;
  final shifted = month > 2 ? month - 3 : month + 9;
  final dayOfYear = (153 * shifted + 2) ~/ 5 + day - 1;
  final dayOfEra =
      yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
  return era * 146097 + dayOfEra - 719468;
}

/// The civil date (year, month 1..12, day 1..31) of [days] since 1970-01-01.
(int, int, int) civilFromDays(int days) {
  final z = days + 719468;
  final era = _floorDiv(z, 146097);
  final dayOfEra = z - era * 146097;
  final yearOfEra =
      (dayOfEra - dayOfEra ~/ 1460 + dayOfEra ~/ 36524 - dayOfEra ~/ 146096) ~/
      365;
  final dayOfYear =
      dayOfEra - (365 * yearOfEra + yearOfEra ~/ 4 - yearOfEra ~/ 100);
  final shifted = (5 * dayOfYear + 2) ~/ 153;
  final day = dayOfYear - (153 * shifted + 2) ~/ 5 + 1;
  final month = shifted < 10 ? shifted + 3 : shifted - 9;
  final year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0);
  return (year, month, day);
}

int _epochMillisOfMonth(int year, int month) =>
    daysFromCivil(year, month, 1) * _day;

/// Ticks for [start]..[end] (epoch milliseconds) at the finest calendar step that gives no more than [maxTicks],
/// as local times at [offsetMinutes] from UTC; the values are still epoch milliseconds.
TimeTicks timeTicks(int start, int end, int maxTicks, {int offsetMinutes = 0}) {
  if (maxTicks < 2) {
    throw ArgumentError.value(maxTicks, 'maxTicks', 'at least 2');
  }
  final offset = offsetMinutes * _minute;
  final low = (start < end ? start : end) + offset;
  final high = (start < end ? end : start) + offset;
  var chosen = TimeStep.tenYears;
  var ticks = const <int>[];
  for (final step in TimeStep.values) {
    final candidate = _ticksAt(low, high, step);
    chosen = step;
    ticks = candidate;
    if (candidate.length <= maxTicks) break;
  }
  return TimeTicks([for (final t in ticks) t - offset], chosen);
}

List<int> _ticksAt(int low, int high, TimeStep step) {
  if (step.months == 0) {
    final anchor = step == TimeStep.week ? _weekdayShift * _day : 0;
    final first =
        _floorDiv(low - anchor + step.millis - 1, step.millis) * step.millis +
        anchor;
    return [for (var t = first; t <= high; t += step.millis) t];
  }
  final (year, month, _) = civilFromDays(_floorDiv(low, _day));
  var monthIndex = year * 12 + (month - 1);
  // Quarters, years and multiples of them start on a multiple of the step: Jan Apr Jul Oct, then 2020 2025 2030.
  if (step.months > 1) {
    monthIndex = _floorDiv(monthIndex, step.months) * step.months;
  }
  final ticks = <int>[];
  while (true) {
    final time = _epochMillisOfMonth(
      _floorDiv(monthIndex, 12),
      monthIndex % 12 + 1,
    );
    if (time > high) break;
    if (time >= low) ticks.add(time);
    monthIndex += step.months;
  }
  return ticks;
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A tick's label for [step]: a time of day, a short date, a month (with the year in January) or a year.
String formatChartTime(
  int epochMillis,
  TimeStep step, {
  int offsetMinutes = 0,
}) {
  final local = epochMillis + offsetMinutes * _minute;
  final (year, month, day) = civilFromDays(_floorDiv(local, _day));
  final minuteOfDay = (local % _day) ~/ _minute;
  if (step.millis > 0 && step.millis < _day) {
    return '${_two(minuteOfDay ~/ 60)}:${_two(minuteOfDay % 60)}';
  }
  if (step.millis >= _day) return '${_monthNames[month - 1]} $day';
  if (step.months >= 12 || month == 1) return '$year';
  return _monthNames[month - 1];
}

String _two(int value) => value < 10 ? '0$value' : '$value';
