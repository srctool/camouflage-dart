import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A date with no time: `DateTime(y, m, d)` at local midnight. Times and zones are dropped.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// [d] moved by [days] calendar days (DST can't shift it, the day is rebuilt from its parts).
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// Whether [a] and [b] are the same calendar day.
bool sameDay(DateTime? a, DateTime? b) =>
    a != null &&
    b != null &&
    a.year == b.year &&
    a.month == b.month &&
    a.day == b.day;

/// A month of a year, e.g. the month a calendar shows.
@immutable
class CamoYearMonth implements Comparable<CamoYearMonth> {
  /// Creates a month; [month] is 1–12.
  const CamoYearMonth(this.year, this.month);

  /// The month [date] is in.
  CamoYearMonth.of(DateTime date) : this(date.year, date.month);

  /// The year.
  final int year;

  /// The month, 1–12.
  final int month;

  /// The month's first day.
  DateTime get firstDay => DateTime(year, month);

  /// How many days it has.
  int get numberOfDays => DateTime(year, month + 1, 0).day;

  /// This month moved by [months].
  CamoYearMonth plusMonths(int months) {
    final d = DateTime(year, month + months);
    return CamoYearMonth(d.year, d.month);
  }

  /// [date]'s day in this month, clamped to its length (31 Jan → 28/29 Feb).
  DateTime dayLike(DateTime date) =>
      DateTime(year, month, date.day.clamp(1, numberOfDays));

  @override
  int compareTo(CamoYearMonth other) =>
      (year - other.year) * 12 + month - other.month;

  /// Before [other].
  bool operator <(CamoYearMonth other) => compareTo(other) < 0;

  /// After [other].
  bool operator >(CamoYearMonth other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is CamoYearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}

/// A range of dates, both ends included. (Flutter's `DateTimeRange` lives in `material`.)
@immutable
class CamoDateRange {
  /// Creates a range; [start] must not be after [end].
  CamoDateRange(DateTime start, DateTime end)
    : assert(!dateOnly(start).isAfter(dateOnly(end))),
      start = dateOnly(start),
      end = dateOnly(end);

  /// The first day.
  final DateTime start;

  /// The last day.
  final DateTime end;

  /// Whether [date] is in the range.
  bool contains(DateTime date) {
    final d = dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  bool operator ==(Object other) =>
      other is CamoDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start..$end';
}

/// What a calendar has selected: one date, or a range being picked.
@immutable
sealed class CalendarSelection {
  const CalendarSelection();
}

/// One date, or none yet.
final class SingleDate extends CalendarSelection {
  /// Creates a single-date selection.
  const SingleDate(this.date);

  /// The date, date-only.
  final DateTime? date;

  @override
  bool operator ==(Object other) =>
      other is SingleDate && sameDayOrBothNull(other.date, date);

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() => 'SingleDate($date)';
}

/// A range: no ends yet, a start only, or both.
final class DateRangeSelection extends CalendarSelection {
  /// Creates a range selection.
  const DateRangeSelection(this.start, this.end);

  /// The first day, once picked.
  final DateTime? start;

  /// The last day, once picked.
  final DateTime? end;

  /// The next range after tapping [date]: a start, then an end; a tap before the start, or after a full range,
  /// starts again.
  DateRangeSelection tap(DateTime date) {
    final s = start;
    if (s == null || end != null || date.isBefore(s)) {
      return DateRangeSelection(date, null);
    }
    return DateRangeSelection(s, date);
  }

  @override
  bool operator ==(Object other) =>
      other is DateRangeSelection &&
      sameDayOrBothNull(other.start, start) &&
      sameDayOrBothNull(other.end, end);

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRangeSelection($start, $end)';
}

/// Whether [a] and [b] are both null or the same day.
bool sameDayOrBothNull(DateTime? a, DateTime? b) =>
    (a == null && b == null) || sameDay(a, b);

/// How a date or time field shows its picker.
enum PickerPresentation {
  /// A popup on a wide window (`autoPopupMinWidth`), a bottom sheet otherwise.
  auto,

  /// Anchored under the field.
  popup,

  /// A bottom sheet.
  sheet,
}

/// Where a day sits in a selected range.
enum RangePosition {
  /// Outside the range.
  none,

  /// The range's first day.
  start,

  /// Between the ends.
  middle,

  /// The range's last day.
  end,

  /// A start without an end yet, or a one-day range.
  single,
}

/// The picker's form: a month grid, or day · month · year wheels (single dates only).
enum DatePickerForm {
  /// A month grid.
  calendar,

  /// Day, month and year wheels.
  wheel,
}

/// Whether a date field accepts typing: on desktop and web (`auto`), everywhere, or nowhere.
enum AllowTyping {
  /// On desktop and web.
  auto,

  /// On every platform.
  always,

  /// Only the picker.
  never,
}

const _daysInWeek = 7;
const _gridDays = 42;

/// The 42 days a month grid shows: from the week holding the 1st, starting on [firstDayOfWeek]
/// (`DateTime.monday` … `DateTime.sunday`).
List<DateTime> monthGrid(CamoYearMonth month, int firstDayOfWeek) {
  final first = month.firstDay;
  final lead = (first.weekday - firstDayOfWeek + _daysInWeek) % _daysInWeek;
  return List.generate(_gridDays, (i) => addDays(first, i - lead));
}

/// The weekday names (Monday first) in grid order, starting on [firstDayOfWeek].
List<String> weekdayOrder(List<String> mondayFirst, int firstDayOfWeek) {
  final shift = firstDayOfWeek - 1;
  return [...mondayFirst.skip(shift), ...mondayFirst.take(shift)];
}

/// Whether [date] is within [min]…[max].
bool inDateRange(DateTime date, DateTime? min, DateTime? max) =>
    (min == null || !date.isBefore(dateOnly(min))) &&
    (max == null || !date.isAfter(dateOnly(max)));

/// Whether [date] can be picked with the limits and, for a range with a start, [maxLength] days.
bool dateSelectable(
  DateTime date,
  DateTime? min,
  DateTime? max,
  bool Function(DateTime)? isSelectable, {
  DateTime? rangeStart,
  int? maxLength,
}) {
  final allowed =
      inDateRange(date, min, max) && (isSelectable?.call(date) ?? true);
  final withinLength =
      rangeStart == null ||
      maxLength == null ||
      date.isBefore(rangeStart) ||
      DateTime.utc(date.year, date.month, date.day)
              .difference(
                DateTime.utc(rangeStart.year, rangeStart.month, rangeStart.day),
              )
              .inDays <
          maxLength;
  return allowed && withinLength;
}

/// [date]'s place in the range [start]…[end].
RangePosition rangePosition(DateTime date, DateTime? start, DateTime? end) {
  if (start == null) return RangePosition.none;
  if (end == null || sameDay(start, end)) {
    return sameDay(date, start) ? RangePosition.single : RangePosition.none;
  }
  if (sameDay(date, start)) return RangePosition.start;
  if (sameDay(date, end)) return RangePosition.end;
  if (date.isAfter(start) && date.isBefore(end)) return RangePosition.middle;
  return RangePosition.none;
}

/// A typing pattern from the locale's short date pattern, with two-digit day and month and a four-digit year in
/// the locale's order and separator: "M/d/y" → "MM/dd/yyyy", "dd/MM/y" → "dd/MM/yyyy".
String typingPattern(String shortPattern) {
  final order = <String>[];
  for (final c in shortPattern.split('')) {
    if ((c == 'd' || c == 'M' || c == 'y') && !order.contains(c)) order.add(c);
  }
  final separator = shortPattern
      .split('')
      .firstWhere(
        (c) => !RegExp(r"[A-Za-z\s']").hasMatch(c),
        orElse: () => '/',
      );
  final fields = (order.isEmpty ? ['M', 'd', 'y'] : order).map(
    (c) => switch (c) {
      'd' => 'dd',
      'M' => 'MM',
      _ => 'yyyy',
    },
  );
  return fields.join(separator);
}

/// A typing pattern's mask for `CamoDisplayFormat.pattern`: "dd/MM/yyyy" → "##/##/####".
String typingMask(String pattern) =>
    pattern.replaceAll(RegExp('[A-Za-z]'), '#');

/// The date in [digits] (exactly the pattern's eight), or `null` when they aren't a real date.
DateTime? parseTyped(String digits, String pattern) {
  final letters = pattern.replaceAll(RegExp('[^A-Za-z]'), '');
  if (digits.length != letters.length || !RegExp(r'^\d+$').hasMatch(digits)) {
    return null;
  }
  int field(String c) {
    final b = StringBuffer();
    for (var i = 0; i < letters.length; i++) {
      if (letters[i] == c) b.write(digits[i]);
    }
    return int.parse(b.toString());
  }

  final y = field('y'), m = field('M'), d = field('d');
  final date = DateTime(y, m, d);
  return date.year == y && date.month == m && date.day == d ? date : null;
}

/// [date] as the digits a typing [pattern] holds: 2026-10-14 with "dd/MM/yyyy" → "14102026".
String typedDigits(DateTime date, String pattern) {
  final letters = pattern.replaceAll(RegExp('[^A-Za-z]'), '');
  final out = StringBuffer();
  var i = 0;
  while (i < letters.length) {
    final c = letters[i];
    var n = 1;
    while (i + n < letters.length && letters[i + n] == c) {
      n++;
    }
    final value = switch (c) {
      'd' => date.day,
      'M' => date.month,
      _ => date.year,
    };
    final text = value.toString().padLeft(n, '0');
    out.write(text.substring(text.length - n));
    i += n;
  }
  return out.toString();
}

/// Locale facts for the pickers, from `intl`. A locale whose data the app hasn't initialized
/// (`initializeDateFormatting`) falls back to `en_US`, logged once in debug builds.
@immutable
class CamoDateLocale {
  /// The facts for [locale] (an `intl` name like "id_ID").
  CamoDateLocale(String locale) : locale = _available(locale);

  /// The [Localizations] locale of [context].
  factory CamoDateLocale.of(BuildContext context) => CamoDateLocale(
    (Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))
        .toString(),
  );

  /// The `intl` locale used.
  final String locale;

  static final _warned = <String>{};

  static String _available(String locale) {
    final canonical = Intl.canonicalizedLocale(locale);
    for (final candidate in [canonical, Intl.shortLocale(canonical)]) {
      if (DateFormat.localeExists(candidate)) return candidate;
    }
    if (kDebugMode && _warned.add(locale)) {
      debugPrint(
        'Camouflage: no intl date data for "$locale"; call initializeDateFormatting(). Using en_US.',
      );
    }
    return 'en_US';
  }

  DateFormat get _symbols => DateFormat('', locale);

  /// The first day of the week, `DateTime.monday` … `DateTime.sunday`.
  int get firstDayOfWeek => _symbols.dateSymbols.FIRSTDAYOFWEEK + 1;

  /// The twelve standalone month names, January first.
  List<String> monthNames({bool short = false}) => short
      ? _symbols.dateSymbols.STANDALONESHORTMONTHS
      : _symbols.dateSymbols.STANDALONEMONTHS;

  /// The seven narrow weekday names, Monday first.
  List<String> get narrowWeekdays {
    final sundayFirst = _symbols.dateSymbols.STANDALONENARROWWEEKDAYS;
    return [...sundayFirst.skip(1), sundayFirst.first];
  }

  /// The AM and PM markers.
  List<String> get amPm => _symbols.dateSymbols.AMPMS;

  /// The locale's short numeric date pattern ("M/d/y", "dd/MM/y").
  String get shortDatePattern => DateFormat.yMd(locale).pattern ?? 'M/d/y';

  /// "October 2026".
  String monthYear(CamoYearMonth month) =>
      DateFormat.yMMMM(locale).format(month.firstDay);

  /// "14 Oct 2026", or [pattern] when given.
  String mediumDate(DateTime date, {String? pattern}) =>
      (pattern != null ? DateFormat(pattern, locale) : DateFormat.yMMMd(locale))
          .format(date);

  /// "Wednesday, 14 October 2026": a day's full name for screen readers.
  String fullDate(DateTime date) => DateFormat.yMMMMEEEEd(locale).format(date);

  /// "14:30" or "2:30 PM".
  String time(int hour, int minute, {required bool use24Hour}) =>
      (use24Hour ? DateFormat.Hm(locale) : DateFormat('h:mm a', locale)).format(
        DateTime(2000, 1, 1, hour, minute),
      );
}
