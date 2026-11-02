import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Mica's fallback chain (ADR-42): the window material shows through the base layers, else the opaque surface.
void main() {
  const window = Color(0xFFFF00FF);
  const surface = Color(0xFF00AA00);

  CamoEnvironment env({
    required bool windowMaterial,
    bool reduceTransparency = false,
  }) => CamoEnvironment(
    windowSize: WindowSizeClass.expanded,
    input: InputMode.pointer,
    platform: CamoPlatform.windows,
    capabilities: CamoCapabilities(
      backdropBlur: true,
      runtimeShaders: true,
      windowMaterial: windowMaterial,
      reduceTransparency: reduceTransparency,
    ),
  );

  // A base layer (or a raised one) of `surface` over a window-colored background.
  Future<void> pump(
    WidgetTester tester,
    CamoEnvironment environment, {
    bool raised = false,
  }) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: CamouflageProvider(
        skin: fluentSkin(surface: FluentSurface.mica),
        theme: fluentTheme(),
        environment: environment,
        child: Builder(
          builder: (context) {
            final theme = Camouflage.themeOf(context);
            return ColoredBox(
              color: window,
              child: Camouflage.skinOf(context).surfaceTreatment.decorate(
                color: surface,
                shape: BorderRadius.zero,
                elevation: raised ? theme.elevation.level3 : 0,
                theme: theme,
                child: const SizedBox.square(dimension: 40),
              ),
            );
          },
        ),
      ),
    ),
  );

  Color? fill(WidgetTester tester) {
    final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    for (final box in boxes) {
      final d = box.decoration;
      if (d is BoxDecoration && d.color == surface) return d.color;
    }
    return null;
  }

  testWidgets('the window material shows through a base layer', (tester) async {
    await pump(tester, env(windowMaterial: true));
    expect(fill(tester), isNull);
  });

  testWidgets('without a window material the base layer is solid', (
    tester,
  ) async {
    await pump(tester, env(windowMaterial: false));
    expect(fill(tester), surface);
  });

  testWidgets('reduce transparency keeps the solid surface', (tester) async {
    await pump(tester, env(windowMaterial: true, reduceTransparency: true));
    expect(fill(tester), surface);
  });

  testWidgets('raised surfaces stay solid', (tester) async {
    await pump(tester, env(windowMaterial: true), raised: true);
    expect(fill(tester), surface);
  });
}
