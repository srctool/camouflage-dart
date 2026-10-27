import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// The base notes' date and time samples: a birth date, weekday delivery, a hotel stay, two times, two months.
class DatesAndTimes extends StatefulWidget {
  /// Creates the samples.
  const DatesAndTimes({super.key});

  @override
  State<DatesAndTimes> createState() => _DatesAndTimesState();
}

class _DatesAndTimesState extends State<DatesAndTimes> {
  final _today = dateOnly(DateTime.now());
  DateTime? _birth;
  DateTime? _delivery;
  CamoDateRange? _stay;
  CamoTime? _reminder;
  CamoTime? _pickup;
  CalendarSelection _twoMonths = const DateRangeSelection(null, null);
  late CamoYearMonth _first = CamoYearMonth.of(_today);

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.m,
      children: [
        CamoDateField(
          value: _birth,
          onChanged: (d) => setState(() => _birth = d),
          label: 'Birth date',
          lastDate: _today,
        ),
        CamoDateField(
          value: _delivery,
          onChanged: (d) => setState(() => _delivery = d),
          label: 'Delivery',
          supportingText: 'Weekdays only',
          firstDate: _today,
          selectableDayPredicate: (d) => d.weekday < DateTime.saturday,
        ),
        CamoDateRangeField(
          value: _stay,
          onChanged: (r) => setState(() => _stay = r),
          label: 'Hotel stay',
          supportingText: 'Up to 14 nights',
          firstDate: _today,
          maxLength: 14,
        ),
        CamoTimeField(
          value: _reminder,
          onChanged: (t) => setState(() => _reminder = t),
          label: 'Reminder',
        ),
        CamoTimeField(
          value: _pickup,
          onChanged: (t) => setState(() => _pickup = t),
          label: 'Pickup slot',
          supportingText: 'Every 15 minutes, 09:00–17:00',
          minuteStep: 15,
          minTime: const CamoTime(hour: 9, minute: 0),
          maxTime: const CamoTime(hour: 17, minute: 0),
        ),
        CamoText(
          'Two months',
          style: Camouflage.typographyOf(context).titleSmall,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.l,
            children: [
              for (final offset in [0, 1])
                CamoCalendar(
                  selection: _twoMonths,
                  onSelectionChanged: (s) => setState(() => _twoMonths = s),
                  visibleMonth: _first.plusMonths(offset),
                  onVisibleMonthChanged: (m) =>
                      setState(() => _first = m.plusMonths(-offset)),
                  firstDate: _today,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
