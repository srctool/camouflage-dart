import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'chart_data.dart';

/// What every chart is wrapped in: a [title], the legend (each entry a toggle chip, see [onLegendToggle]), the
/// plot ([child]) and, when [table] is given, a switch to the same data as a table ([showTable],
/// [onShowTableChanged]).
///
/// The plot is one image node whose text is "[title]. [summary]"; the plot itself adds no semantics except the
/// announcement of a focused point. While [loading] a skeleton of [plotHeight]
/// stands in; with no data ([isEmpty]) the [empty] widget (or "No data") does.
class CamoChartFrame extends StatelessWidget {
  /// Creates a chart frame.
  const CamoChartFrame({
    super.key,
    required this.title,
    required this.summary,
    required this.child,
    this.legend = const [],
    this.onLegendToggle,
    this.loading = false,
    this.isEmpty = false,
    this.empty,
    this.plotHeight = 200,
    this.table,
    this.showTable = false,
    this.onShowTableChanged,
  });

  /// The chart's title.
  final String title;

  /// What the chart shows, for a screen reader ("Line chart, 2 series, 12 points").
  final String summary;

  /// The plot.
  final Widget child;

  /// The legend entries.
  final List<LegendItem> legend;

  /// Called with the index of the entry that was toggled; `null` makes the legend read-only.
  final ValueChanged<int>? onLegendToggle;

  /// Whether a skeleton stands in for the plot.
  final bool loading;

  /// Whether there is no data.
  final bool isEmpty;

  /// What shows with no data; "No data" by default.
  final Widget? empty;

  /// The height of the loading skeleton.
  final double plotHeight;

  /// The data as a table, shown instead of the plot while [showTable] is on.
  final Widget? table;

  /// Whether the table shows instead of the plot.
  final bool showTable;

  /// Called when the table switch is pressed.
  final ValueChanged<bool>? onShowTableChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoChartFrame');
    final spacing = theme.spacing;
    final plotShown = !loading && !isEmpty;
    final Widget body;
    if (loading) {
      body = CamoSkeleton(height: plotHeight);
    } else if (isEmpty) {
      body = empty ?? const CamoText('No data');
    } else if (showTable && table != null) {
      body = SizedBox(height: plotHeight, child: table);
    } else {
      body = Semantics(
        container: true,
        image: true,
        label: '$title. $summary',
        child: child,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.s,
      children: [
        CamoText(title, style: theme.typography.titleSmall),
        if (legend.isNotEmpty) _Legend(legend, onLegendToggle, spacing.xs),
        body,
        if (plotShown && table != null && onShowTableChanged != null)
          CamoChip(
            label: 'View as table',
            selected: showTable,
            onPressed: () => onShowTableChanged!(!showTable),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.items, this.onToggle, this.gap);

  final List<LegendItem> items;
  final ValueChanged<int>? onToggle;
  final double gap;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: gap,
    runSpacing: gap,
    children: [
      for (var i = 0; i < items.length; i++)
        CamoChip(
          label: items[i].label,
          selected: onToggle != null ? items[i].visible : null,
          onPressed: onToggle == null ? null : () => onToggle!(i),
          leading: DecoratedBox(
            decoration: BoxDecoration(
              color: items[i].color,
              shape: BoxShape.circle,
            ),
            child: const SizedBox.square(dimension: 8),
          ),
        ),
    ],
  );
}

/// The chart's data as a table: a row per category, a column per series.
class CamoChartDataTable extends StatelessWidget {
  /// Creates a data table for a chart.
  const CamoChartDataTable({
    super.key,
    required this.categories,
    required this.series,
    required this.caption,
    this.format = formatChartNumber,
  });

  /// The category labels, one per row.
  final List<String> categories;

  /// The series, one per column.
  final List<ChartSeries> series;

  /// Names the table for a screen reader.
  final String caption;

  /// How a value reads.
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) => CamoDataTable<int>(
    columns: [
      CamoColumn<int>(
        id: 'category',
        header: 'Category',
        cell: (context, row) => CamoText(categories[row]),
      ),
      for (var i = 0; i < series.length; i++)
        CamoColumn<int>(
          id: i,
          header: series[i].name,
          cell: (context, row) {
            final value = row < series[i].values.length
                ? series[i].values[row]
                : null;
            return CamoText(value == null ? '-' : format(value));
          },
        ),
    ],
    rows: [for (var i = 0; i < categories.length; i++) i],
    rowKey: (row) => row,
    semanticLabel: caption,
  );
}
