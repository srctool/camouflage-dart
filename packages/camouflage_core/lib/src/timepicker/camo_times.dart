import 'package:flutter/foundation.dart';

/// A wall-clock time: hour and minute, with no date or time zone. (`TimeOfDay` lives in `material`.)
@immutable
class CamoTime implements Comparable<CamoTime> {
  /// Creates a time; [hour] is 0–23 and [minute] 0–59.
  const CamoTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  /// The time of [dateTime].
  CamoTime.fromDateTime(DateTime dateTime)
    : this(hour: dateTime.hour, minute: dateTime.minute);

  /// The hour, 0–23.
  final int hour;

  /// The minute, 0–59.
  final int minute;

  /// Minutes since midnight.
  int get inMinutes => hour * 60 + minute;

  /// This time moved by [hours] and [minutes], wrapping around the day.
  CamoTime shift({int hours = 0, int minutes = 0}) {
    const day = 24 * 60;
    final total = ((inMinutes + hours * 60 + minutes) % day + day) % day;
    return CamoTime(hour: total ~/ 60, minute: total % 60);
  }

  @override
  int compareTo(CamoTime other) => inMinutes - other.inMinutes;

  @override
  bool operator ==(Object other) =>
      other is CamoTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Before or after noon, in 12-hour times.
enum DayPeriod {
  /// Before noon.
  am,

  /// From noon.
  pm,
}

/// The part of a time being changed.
enum TimePart {
  /// The hour.
  hour,

  /// The minute.
  minute,
}

/// The picker's form: typed hour and minute fields, a clock dial, or hour · minute · period wheels.
enum TimePickerForm {
  /// Typed hour and minute fields.
  fields,

  /// Fields above a clock dial.
  dial,

  /// Hour, minute and period wheels.
  wheel,
}

/// The hour on a 12-hour clock: 0 → 12, 13 → 1.
int hour12(int hour) => hour % 12 == 0 ? 12 : hour % 12;

/// Before or after noon.
DayPeriod periodOf(int hour) => hour < 12 ? DayPeriod.am : DayPeriod.pm;

/// The 24-hour hour for [hour12] (1–12) in [period].
int hour24(int hour12, DayPeriod period) =>
    hour12 % 12 + (period == DayPeriod.pm ? 12 : 0);

/// [minute] on the nearest multiple of [step] that stays within the hour (58 with step 15 → 45).
int snapMinute(int minute, int step) {
  if (step <= 1) return minute;
  final nearest = (minute + step ~/ 2) ~/ step * step;
  return nearest >= 60 ? nearest - step : nearest;
}

/// Whether [time] is in the window; a window with [min] after [max] runs past midnight.
bool inTimeWindow(CamoTime time, CamoTime? min, CamoTime? max) {
  if (min == null && max == null) return true;
  if (min == null) return time.compareTo(max!) <= 0;
  if (max == null) return time.compareTo(min) >= 0;
  if (min.compareTo(max) <= 0) {
    return time.compareTo(min) >= 0 && time.compareTo(max) <= 0;
  }
  return time.compareTo(min) >= 0 || time.compareTo(max) <= 0;
}
