import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'debug_skin.dart';
import 'debug_placeholder.dart';

void main() => runApp(const CamouflageExampleApp());

enum _Brand {
  blue('blue', Color(0xFF0B57D0)),
  green('green', Color(0xFF146C2E));

  const _Brand(this.label, this.seed);

  final String label;
  final Color seed;
}

const _promoSeed = Color(0xFFE8710A);

CamoTheme _theme(Color seed, Brightness brightness) => CamoTheme(
  colors: CamoColors.fromSeed(primary: seed, brightness: brightness),
  typography: CamoTypography.system(),
);

/// The example app. Built on [WidgetsApp], not MaterialApp, to prove core works without Material.
/// M2: placeholders drawn through DebugSkin, with nested providers and live switching, like the Kotlin sample.
class CamouflageExampleApp extends StatefulWidget {
  /// Creates the example app.
  const CamouflageExampleApp({super.key});

  @override
  State<CamouflageExampleApp> createState() => _CamouflageExampleAppState();
}

class _CamouflageExampleAppState extends State<CamouflageExampleApp> {
  bool? _dark;
  _Brand _brand = _Brand.blue;
  CamoSkin _skin = debugSkin;

  @override
  Widget build(BuildContext context) {
    final otherSkin = _skin == debugSkin ? debugOutlineSkin : debugSkin;
    return WidgetsApp(
      title: 'Camouflage',
      color: _brand.seed,
      builder: (context, _) {
        final dark =
            _dark ??
            MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final brightness = dark ? Brightness.dark : Brightness.light;
        return CamoAnimatedTheme(
          theme: _theme(_brand.seed, brightness),
          builder: (context, theme) => CamouflageProvider(
            skin: _skin,
            theme: theme,
            child: ColoredBox(
              color: theme.colors.surface,
              child: SizedBox.expand(
                child: SingleChildScrollView(
                  child: _Section(
                    title: 'Root provider',
                    children: [
                      Wrap(
                        spacing: theme.spacing.s,
                        runSpacing: theme.spacing.s,
                        children: [
                          DebugPlaceholder(
                            'Skin: ${_skin.name}',
                            onPressed: () => setState(() => _skin = otherSkin),
                          ),
                          DebugPlaceholder(
                            'Brand: ${_brand.label}',
                            onPressed: () => setState(
                              () => _brand =
                                  _Brand.values[(_brand.index + 1) %
                                      _Brand.values.length],
                            ),
                          ),
                          DebugPlaceholder(
                            dark ? 'Dark' : 'Light',
                            onPressed: () => setState(() => _dark = !dark),
                          ),
                        ],
                      ),
                      const DebugPlaceholder(
                        'Inherits the root skin and theme',
                      ),
                      CamoAnimatedTheme(
                        theme: _theme(_promoSeed, brightness),
                        builder: (context, promo) => CamouflageProvider(
                          theme: promo,
                          child: const _Section(
                            title: 'Nested provider: theme only',
                            children: [
                              DebugPlaceholder(
                                'Inherits the root skin, uses the promo theme',
                              ),
                            ],
                          ),
                        ),
                      ),
                      CamouflageProvider(
                        skin: otherSkin,
                        child: const _Section(
                          title: 'Nested provider: skin only',
                          children: [
                            DebugPlaceholder(
                              'Uses the other skin, inherits the root theme',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// A region on the theme's surface, drawn with the current skin's surface treatment.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return Camouflage.skinOf(context).surfaceTreatment.decorate(
      color: theme.colors.surface,
      shape: theme.shapes.large,
      elevation: 0,
      theme: theme,
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing.m,
          children: [
            Text(
              title,
              style: theme.typography.titleMedium.copyWith(
                color: Camouflage.contentColorOf(context),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
