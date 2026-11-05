import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// What a chart looks like, fully resolved: every field set. Charts and [ChartRenderer]s read this.
@immutable
class ResolvedChartStyle {
  /// Creates a resolved style.
  const ResolvedChartStyle({
    required this.gridLines,
    required this.gridDashed,
    required this.lineWidth,
    required this.markerSize,
    required this.areaOpacity,
    required this.barRadius,
    required this.barGap,
    required this.groupGap,
    required this.donutThickness,
    required this.sliceGap,
    required this.selectedOffset,
    required this.labelThreshold,
    required this.animate,
    required this.palette,
  });

  /// Whether the plot has grid lines.
  final bool gridLines;

  /// Whether grid lines are dashed.
  final bool gridDashed;

  /// The stroke width of lines.
  final double lineWidth;

  /// The diameter of markers and highlights.
  final double markerSize;

  /// How opaque filled areas are.
  final double areaOpacity;

  /// The corner radius of bars.
  final double barRadius;

  /// The gap between bars.
  final double barGap;

  /// The space between groups of bars, as a share of a group.
  final double groupGap;

  /// A donut ring's width as a share of the radius.
  final double donutThickness;

  /// The gap between pie slices.
  final double sliceGap;

  /// How far a selected slice moves out.
  final double selectedOffset;

  /// The smallest share of a pie that gets a label.
  final double labelThreshold;

  /// Whether charts draw in with an animation.
  final bool animate;

  /// The series colors, in order.
  final List<Color> palette;

  /// This style with [overrides]' non-null fields applied.
  ResolvedChartStyle merge(ChartStyle? overrides) {
    if (overrides == null) return this;
    final colors = overrides.palette;
    return ResolvedChartStyle(
      gridLines: overrides.gridLines ?? gridLines,
      gridDashed: overrides.gridDashed ?? gridDashed,
      lineWidth: overrides.lineWidth ?? lineWidth,
      markerSize: overrides.markerSize ?? markerSize,
      areaOpacity: overrides.areaOpacity ?? areaOpacity,
      barRadius: overrides.barRadius ?? barRadius,
      barGap: overrides.barGap ?? barGap,
      groupGap: overrides.groupGap ?? groupGap,
      donutThickness: overrides.donutThickness ?? donutThickness,
      sliceGap: overrides.sliceGap ?? sliceGap,
      selectedOffset: overrides.selectedOffset ?? selectedOffset,
      labelThreshold: overrides.labelThreshold ?? labelThreshold,
      animate: overrides.animate ?? animate,
      palette: colors != null && colors.isNotEmpty ? colors : palette,
    );
  }

  /// The color of series [index], cycling when there are more series than colors.
  Color seriesColor(int index) => palette[index % palette.length];
}

/// Chart style changes: a field that is `null` keeps the layer below (the theme's defaults, then the skin's
/// preset, then [ChartTokens], then the chart's own `style`).
@immutable
class ChartStyle {
  /// Creates a style change.
  const ChartStyle({
    this.gridLines,
    this.gridDashed,
    this.lineWidth,
    this.markerSize,
    this.areaOpacity,
    this.barRadius,
    this.barGap,
    this.groupGap,
    this.donutThickness,
    this.sliceGap,
    this.selectedOffset,
    this.labelThreshold,
    this.animate,
    this.palette,
  });

  /// See [ResolvedChartStyle.gridLines].
  final bool? gridLines;

  /// See [ResolvedChartStyle.gridDashed].
  final bool? gridDashed;

  /// See [ResolvedChartStyle.lineWidth].
  final double? lineWidth;

  /// See [ResolvedChartStyle.markerSize].
  final double? markerSize;

  /// See [ResolvedChartStyle.areaOpacity].
  final double? areaOpacity;

  /// See [ResolvedChartStyle.barRadius].
  final double? barRadius;

  /// See [ResolvedChartStyle.barGap].
  final double? barGap;

  /// See [ResolvedChartStyle.groupGap].
  final double? groupGap;

  /// See [ResolvedChartStyle.donutThickness].
  final double? donutThickness;

  /// See [ResolvedChartStyle.sliceGap].
  final double? sliceGap;

  /// See [ResolvedChartStyle.selectedOffset].
  final double? selectedOffset;

  /// See [ResolvedChartStyle.labelThreshold].
  final double? labelThreshold;

  /// See [ResolvedChartStyle.animate].
  final bool? animate;

  /// See [ResolvedChartStyle.palette].
  final List<Color>? palette;

  @override
  bool operator ==(Object other) =>
      other is ChartStyle &&
      other.gridLines == gridLines &&
      other.gridDashed == gridDashed &&
      other.lineWidth == lineWidth &&
      other.markerSize == markerSize &&
      other.areaOpacity == areaOpacity &&
      other.barRadius == barRadius &&
      other.barGap == barGap &&
      other.groupGap == groupGap &&
      other.donutThickness == donutThickness &&
      other.sliceGap == sliceGap &&
      other.selectedOffset == selectedOffset &&
      other.labelThreshold == labelThreshold &&
      other.animate == animate &&
      listEquals(other.palette, palette);

  @override
  int get hashCode => Object.hash(
    gridLines,
    gridDashed,
    lineWidth,
    markerSize,
    areaOpacity,
    barRadius,
    barGap,
    groupGap,
    donutThickness,
    sliceGap,
    selectedOffset,
    labelThreshold,
    animate,
    Object.hashAll(palette ?? const []),
  );
}

/// A brand's chart tokens (ADR-32): a [style] that applies on top of the skin's preset, whichever skin is active.
@immutable
class ChartTokens extends CamoTokenSet<ChartTokens> {
  /// Creates chart tokens.
  const ChartTokens(this.style);

  /// The style changes.
  final ChartStyle style;

  @override
  ChartTokens lerp(ChartTokens other, double t) => t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is ChartTokens && other.style == style;

  @override
  int get hashCode => style.hashCode;
}

double _contrast(Color a, Color b) {
  final high = a.computeLuminance() > b.computeLuminance() ? a : b;
  final low = identical(high, a) ? b : a;
  return (high.computeLuminance() + 0.05) / (low.computeLuminance() + 0.05);
}

/// The color families in order; a color too close to the surface (a pale yellow on white) is left out.
@visibleForTesting
List<Color> paletteFor(CamoColors colors) {
  final all = <Color>{
    colors.primary,
    colors.info,
    colors.success,
    colors.warning,
    colors.error,
    colors.secondary,
    colors.tertiary,
  }.toList();
  final readable = all.where((c) => _contrast(c, colors.surface) >= 3).toList();
  return readable.length >= 3 ? readable : all;
}

ResolvedChartStyle _themeStyle(CamoColors colors) => ResolvedChartStyle(
  gridLines: true,
  gridDashed: false,
  lineWidth: 2,
  markerSize: 6,
  areaOpacity: 0.18,
  barRadius: 4,
  barGap: 4,
  groupGap: 0.3,
  donutThickness: 0.35,
  sliceGap: 2,
  selectedOffset: 6,
  labelThreshold: 0.05,
  animate: true,
  palette: paletteFor(colors),
);

/// Chart presets per skin name, and the way to add one for a skin of your own.
abstract final class CamoCharts {
  static final Map<String, ChartStyle> _presets = {
    'minimal': const ChartStyle(
      lineWidth: 1.5,
      areaOpacity: 0.12,
      barRadius: 2,
      markerSize: 5,
    ),
    'fluent': const ChartStyle(
      lineWidth: 2,
      areaOpacity: 0.2,
      barRadius: 4,
      gridDashed: true,
      sliceGap: 3,
    ),
    'material': const ChartStyle(
      lineWidth: 3,
      markerSize: 8,
      areaOpacity: 0.16,
      barRadius: 8,
      barGap: 2,
      donutThickness: 0.3,
      sliceGap: 4,
    ),
  };

  /// Sets the preset charts use while the skin named [skinName] is active.
  static void registerPreset(String skinName, ChartStyle style) {
    _presets[skinName] = style;
  }

  /// The style a chart under [context] draws with: the theme's defaults, then the preset for the skin's name,
  /// then the theme's [ChartTokens] if it has them, then [overrides].
  static ResolvedChartStyle styleOf(
    BuildContext context, {
    ChartStyle? overrides,
  }) {
    final skin = Camouflage.skinOf(context, component: 'chart');
    final theme = Camouflage.themeOf(context, component: 'chart');
    return _themeStyle(theme.colors)
        .merge(_presets[skin.name])
        .merge(theme.tokens<ChartTokens>()?.style)
        .merge(overrides);
  }
}
