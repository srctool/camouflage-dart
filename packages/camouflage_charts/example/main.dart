import 'package:camouflage_charts/camouflage_charts.dart';
import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const MyApp());

/// A line chart under the Minimal skin; swap the skin and theme and the chart follows.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => WidgetsApp(
    color: const Color(0xFF0B57D0),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    builder: (context, child) => CamouflageProvider(
      skin: minimalSkin,
      theme: minimalTheme(),
      child: child!,
    ),
    home: const Dashboard(),
  );
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) => const CamoSurface(
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CamoLineChart(
          title: 'Revenue by quarter',
          categories: ['Q1', 'Q2', 'Q3', 'Q4'],
          series: [
            ChartSeries(name: 'Subscriptions', values: [12, 15, 19, 27]),
            ChartSeries(name: 'Services', values: [6, 7, null, 9]),
          ],
        ),
      ),
    ),
  );
}
