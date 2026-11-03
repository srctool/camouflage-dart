import 'package:flutter/widgets.dart';

/// How many ticks an axis aims for unless it says otherwise.
const int defaultTickCount = 5;

/// One data series: a [name] for the legend, one value per category (`null` is a gap) and an optional [color].
@immutable
class ChartSeries {
  /// Creates a series.
  const ChartSeries({required this.name, required this.values, this.color});

  /// The legend name.
  final String name;

  /// One value per category; `null` is a gap.
  final List<double?> values;

  /// The series color; `null` takes the next palette color.
  final Color? color;
}

/// An axis: an optional [title], a fixed [min] or [max] (`null` reads the data), [tickCount] and tick [format].
@immutable
class ChartAxis {
  /// Creates an axis.
  const ChartAxis({
    this.title,
    this.min,
    this.max,
    this.tickCount = defaultTickCount,
    this.format = formatChartNumber,
  });

  /// The axis title.
  final String? title;

  /// The lowest value shown; `null` reads the data.
  final double? min;

  /// The highest value shown; `null` reads the data.
  final double? max;

  /// How many ticks to aim for.
  final int tickCount;

  /// How a tick value reads.
  final String Function(double value) format;
}

/// One legend entry; the legend toggles [visible] through the frame's callback.
@immutable
class LegendItem {
  /// Creates a legend entry.
  const LegendItem({
    required this.label,
    required this.color,
    this.visible = true,
  });

  /// The series name.
  final String label;

  /// The series color.
  final Color color;

  /// Whether the series is shown.
  final bool visible;

  /// This entry with [visible] changed.
  LegendItem withVisible(bool visible) =>
      LegendItem(label: label, color: color, visible: visible);
}

/// A number as a person reads it: whole numbers without a decimal point, otherwise one decimal.
String formatChartNumber(double value) {
  if (value.isNaN || value.isInfinite) return '$value';
  if (value.abs() >= 1e15) return value.toInt().toString();
  final tenths = (value.abs() * 10).round();
  final sign = value < 0 && tenths != 0 ? '-' : '';
  final whole = tenths ~/ 10;
  final fraction = tenths % 10;
  return fraction == 0 ? '$sign$whole' : '$sign$whole.$fraction';
}
