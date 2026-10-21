import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const CamouflageExampleApp());

const _seed = Color(0xFF0B57D0);

/// The example app. Built on [WidgetsApp], not MaterialApp, to prove core works without Material.
/// M1: every color role of a seed theme, in light and dark, like the Kotlin sample.
class CamouflageExampleApp extends StatelessWidget {
  /// Creates the example app.
  const CamouflageExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final light = CamoTheme(
      colors: CamoColors.fromSeed(primary: _seed),
      typography: CamoTypography.system(),
    );
    final dark = light.copyWith(
      colors: CamoColors.fromSeed(primary: _seed, brightness: Brightness.dark),
    );
    return WidgetsApp(
      title: 'Camouflage',
      color: _seed,
      builder: (context, _) => SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Swatches(title: 'Light', theme: light),
            ),
            Expanded(
              child: _Swatches(title: 'Dark', theme: dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.title, required this.theme});

  final String title;
  final CamoTheme theme;

  @override
  Widget build(BuildContext context) {
    final c = theme.colors;
    return ColoredBox(
      color: c.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$title · seed #0B57D0',
              style: theme.typography.titleMedium.copyWith(color: c.onSurface),
            ),
            for (final (name, color, content) in _roles(c))
              Container(
                height: 36,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: c.outlineVariant),
                ),
                child: Text(
                  name,
                  style: theme.typography.labelMedium.copyWith(color: content),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Each role with the content color drawn on it.
List<(String, Color, Color)> _roles(CamoColors c) => [
  ('primary', c.primary, c.onPrimary),
  ('primaryContainer', c.primaryContainer, c.onPrimaryContainer),
  ('secondary', c.secondary, c.onSecondary),
  ('secondaryContainer', c.secondaryContainer, c.onSecondaryContainer),
  ('tertiary', c.tertiary, c.onTertiary),
  ('tertiaryContainer', c.tertiaryContainer, c.onTertiaryContainer),
  ('surface', c.surface, c.onSurface),
  ('surfaceContainerLowest', c.surfaceContainerLowest, c.onSurface),
  ('surfaceContainerLow', c.surfaceContainerLow, c.onSurface),
  ('surfaceContainer', c.surfaceContainer, c.onSurface),
  ('surfaceContainerHigh', c.surfaceContainerHigh, c.onSurface),
  ('surfaceContainerHighest', c.surfaceContainerHighest, c.onSurfaceVariant),
  ('outline', c.outline, c.surface),
  ('outlineVariant', c.outlineVariant, c.onSurface),
  ('error', c.error, c.onError),
  ('errorContainer', c.errorContainer, c.onErrorContainer),
  ('success', c.success, c.onSuccess),
  ('successContainer', c.successContainer, c.onSuccessContainer),
  ('warning', c.warning, c.onWarning),
  ('warningContainer', c.warningContainer, c.onWarningContainer),
  ('info', c.info, c.onInfo),
  ('infoContainer', c.infoContainer, c.onInfoContainer),
  ('inverseSurface', c.inverseSurface, c.inverseOnSurface),
  ('inversePrimary', c.inversePrimary, c.inverseSurface),
  ('scrim', c.scrim, const Color(0xFFFFFFFF)), // the scrim has no content role
];
