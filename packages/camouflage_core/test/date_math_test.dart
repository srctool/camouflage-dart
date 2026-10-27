import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/datepicker/camo_dates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('date math', () {
    test(
      'the grid starts on the first day of the week and holds six weeks',
      () {
        // 1 October 2026 is a Thursday.
        final sunday = monthGrid(
          const CamoYearMonth(2026, 10),
          DateTime.sunday,
        );
        expect(sunday, hasLength(42));
        expect(sunday.first, DateTime(2026, 9, 27));
        expect(
          monthGrid(const CamoYearMonth(2026, 10), DateTime.monday).first,
          DateTime(2026, 9, 28),
        );
        expect(
          monthGrid(const CamoYearMonth(2026, 6), DateTime.monday).first,
          DateTime(2026, 6, 1),
        );
      },
    );

    test('leap years and clamped days', () {
      expect(const CamoYearMonth(2028, 2).numberOfDays, 29);
      expect(const CamoYearMonth(2100, 2).numberOfDays, 28);
      expect(
        const CamoYearMonth(2028, 2).dayLike(DateTime(2028, 1, 31)),
        DateTime(2028, 2, 29),
      );
      expect(
        const CamoYearMonth(2026, 12).plusMonths(1),
        const CamoYearMonth(2027, 1),
      );
    });

    test('limits and max length disable days', () {
      final min = DateTime(2026, 10, 5), max = DateTime(2026, 10, 25);
      expect(dateSelectable(DateTime(2026, 10, 4), min, max, null), isFalse);
      expect(dateSelectable(DateTime(2026, 10, 5), min, max, null), isTrue);
      expect(dateSelectable(DateTime(2026, 10, 26), min, max, null), isFalse);
      bool weekdays(DateTime d) => d.weekday < DateTime.saturday;
      expect(
        dateSelectable(DateTime(2026, 10, 10), null, null, weekdays),
        isFalse,
      );
      final start = DateTime(2026, 10, 1);
      expect(
        dateSelectable(
          DateTime(2026, 10, 14),
          null,
          null,
          null,
          rangeStart: start,
          maxLength: 14,
        ),
        isTrue,
      );
      expect(
        dateSelectable(
          DateTime(2026, 10, 15),
          null,
          null,
          null,
          rangeStart: start,
          maxLength: 14,
        ),
        isFalse,
      );
    });

    test('a range is picked start then end', () {
      final a = DateTime(2026, 10, 10), b = DateTime(2026, 10, 14);
      final start = const DateRangeSelection(null, null).tap(a);
      expect(start, DateRangeSelection(a, null));
      expect(start.tap(b), DateRangeSelection(a, b));
      expect(
        start.tap(DateTime(2026, 10, 1)),
        DateRangeSelection(DateTime(2026, 10, 1), null),
      );
      expect(rangePosition(a, a, b), RangePosition.start);
      expect(rangePosition(DateTime(2026, 10, 12), a, b), RangePosition.middle);
      expect(rangePosition(b, a, b), RangePosition.end);
      expect(rangePosition(a, a, null), RangePosition.single);
    });

    test('typing patterns keep the locale order and parse only real dates', () {
      expect(typingPattern('M/d/y'), 'MM/dd/yyyy');
      expect(typingPattern('dd/MM/y'), 'dd/MM/yyyy');
      expect(typingPattern('dd.MM.yy'), 'dd.MM.yyyy');
      expect(typingMask('dd/MM/yyyy'), '##/##/####');
      expect(parseTyped('14102026', 'dd/MM/yyyy'), DateTime(2026, 10, 14));
      expect(parseTyped('10142026', 'MM/dd/yyyy'), DateTime(2026, 10, 14));
      expect(parseTyped('31022026', 'dd/MM/yyyy'), isNull);
      expect(typedDigits(DateTime(2026, 10, 14), 'dd/MM/yyyy'), '14102026');
    });

    test('times: 12 and 24 hours, steps and windows past midnight', () {
      expect(hour12(0), 12);
      expect(hour24(12, DayPeriod.am), 0);
      expect(hour24(2, DayPeriod.pm), 14);
      expect(snapMinute(58, 15), 45);
      expect(snapMinute(14, 15), 15);
      const night = CamoTime(hour: 22, minute: 0),
          six = CamoTime(hour: 6, minute: 0);
      expect(
        inTimeWindow(const CamoTime(hour: 2, minute: 0), night, six),
        isTrue,
      );
      expect(
        inTimeWindow(const CamoTime(hour: 12, minute: 0), night, six),
        isFalse,
      );
      expect(
        const CamoTime(hour: 23, minute: 50).shift(minutes: 20),
        const CamoTime(hour: 0, minute: 10),
      );
    });
  });

  group('locale data', () {
    setUpAll(initializeDateFormatting);

    test('locales know their first day, names and patterns', () {
      expect(CamoDateLocale('en_US').firstDayOfWeek, DateTime.sunday);
      expect(CamoDateLocale('de_DE').firstDayOfWeek, DateTime.monday);
      expect(CamoDateLocale('id_ID').monthNames()[9], 'Oktober');
      expect(
        typingPattern(CamoDateLocale('en_US').shortDatePattern),
        'MM/dd/yyyy',
      );
      expect(
        typingPattern(CamoDateLocale('id_ID').shortDatePattern),
        'dd/MM/yyyy',
      );
      expect(
        CamoDateLocale('en_US').monthYear(const CamoYearMonth(2026, 10)),
        'October 2026',
      );
      expect(CamoDateLocale('en_US').time(14, 30, use24Hour: false), '2:30 PM');
    });

    test('an uninitialized locale falls back to en_US', () {
      expect(CamoDateLocale('xx_YY').locale, 'en_US');
    });
  });
}
