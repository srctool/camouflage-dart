# camouflage_charts

[![pub package](https://img.shields.io/pub/v/camouflage_charts.svg)](https://pub.dev/packages/camouflage_charts)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-camouflage.srctool.com-blue.svg)](https://camouflage.srctool.com)

**Charts without a chart library, that follow the active Camouflage skin.** Line, area, bar, pie, donut and sparkline charts, drawn with the skin's colors, type and shapes, so a chart in a Cupertino app looks like Cupertino and in a Carbon app like Carbon.

## Features

- `CamoLineChart` (line, area and stacked area; linear, monotone, Catmull-Rom and step curves; a time axis), `CamoBarChart` (vertical and horizontal, grouped and stacked), `CamoPieChart` (pie and donut with a center slot) and `CamoSparkline`.
- A legend that toggles series, a tooltip and crosshair at the pointer, and a loading and an empty state.
- **Accessible:** every chart is an image with a generated summary, keyboard traversal of the points with a live announcement, and a data table as an alternative.
- **Styled by the skin:** each Camouflage skin ships a chart preset; override with `ChartTokens`, a `ChartStyle`, or your own `ChartRenderer`.
- No dependency on a chart package, and no Material.

## Getting started

```sh
flutter pub add camouflage_core camouflage_charts camouflage_skin_minimal
```

Charts read the skin and theme from the `CamouflageProvider` (see [`camouflage_core`](https://pub.dev/packages/camouflage_core)).

## Usage

```dart
import 'package:camouflage_charts/camouflage_charts.dart';

CamoLineChart(
  title: 'Revenue by quarter',
  categories: const ['Q1', 'Q2', 'Q3', 'Q4'],
  series: const [
    ChartSeries(name: 'Subscriptions', values: [12, 15, 19, 27]),
    ChartSeries(name: 'Services', values: [6, 7, null, 9]), // null is a gap
  ],
)
```

`CamoBarChart` and `CamoPieChart` take the same kind of data. A sparkline is a line without axes, for a dashboard card.

## Styling

```dart
// Per chart, or for the whole subtree through ChartTokens on the theme.
CamoCharts.registerPreset('my-skin', const ChartStyle(lineWidth: 2, barRadius: 4));
```

The style layers apply in this order: the theme's defaults, the skin's preset, the theme's `ChartTokens`, then the chart's own parameters.

## Learn more

- A dashboard that uses all five chart types is in the [example app](https://github.com/srctool/camouflage-dart/tree/main/example).
- Documentation: https://camouflage.srctool.com
- Source and issues: https://github.com/srctool/camouflage-dart

## License

Apache License 2.0, see [LICENSE](LICENSE).
