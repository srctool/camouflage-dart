import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const CamouflageExampleApp());

/// The example app. Built on [WidgetsApp], not MaterialApp, to prove core works without Material.
/// Until milestone M3 it shows a placeholder; then it grows a screen per milestone, like the Kotlin sample.
class CamouflageExampleApp extends StatelessWidget {
  /// Creates the example app.
  const CamouflageExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Camouflage',
      color: const Color(0xFF000000),
      // WidgetsApp paints no background (native surfaces start black), so the placeholder paints its own.
      builder: (context, _) => ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: Center(
          child: Text(
            'Camouflage example (M0), theme ${minimalTheme.placeholder}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Color(0xFF000000), fontSize: 16),
          ),
        ),
      ),
    );
  }
}
