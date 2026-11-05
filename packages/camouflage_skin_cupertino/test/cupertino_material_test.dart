import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The materials chain (ADR-42): a material blurs what is behind it only from level2 up, with a backdrop blur, and
// without Reduce Transparency; every other step is the opaque surface color. Flutter needs no backdrop widget:
// `BackdropFilter` blurs what is painted behind it, so "no `CupertinoBackdrop`" has no Flutter counterpart.
void main() {
  const caps = CamoCapabilities(
    backdropBlur: true,
    runtimeShaders: true,
    windowMaterial: false,
    reduceTransparency: false,
  );

  Future<void> pump(
    WidgetTester tester,
    CamoCapabilities? capabilities,
    ElevationLevel level, {
    bool glass = false,
  }) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: CamouflageProvider(
        skin: cupertinoSkinWith(
          surface: glass
              ? CupertinoSurface.liquidGlass
              : CupertinoSurface.classic,
        ),
        theme: cupertinoLight,
        environment: capabilities == null
            ? null
            : CamoEnvironment(
                windowSize: WindowSizeClass.compact,
                input: InputMode.touch,
                platform: CamoPlatform.ios,
                capabilities: capabilities,
              ),
        child: Builder(
          builder: (context) =>
              Camouflage.skinOf(context).surfaceTreatment.decorate(
                color: const Color(0xFFFFFFFF),
                shape: BorderRadius.circular(12),
                elevation: Camouflage.themeOf(context).elevation.of(level),
                theme: Camouflage.themeOf(context),
                child: const SizedBox(width: 100, height: 60),
              ),
        ),
      ),
    ),
  );

  for (final glass in [false, true]) {
    final name = glass ? 'glass' : 'classic';

    testWidgets('$name blurs from level2 with a blur and no reduction', (
      tester,
    ) async {
      await pump(tester, caps, ElevationLevel.level2, glass: glass);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('$name is opaque below level2', (tester) async {
      await pump(tester, caps, ElevationLevel.level1, glass: glass);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('$name is opaque without a backdrop blur', (tester) async {
      await pump(
        tester,
        caps.copyWith(backdropBlur: false),
        ElevationLevel.level3,
        glass: glass,
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('$name is opaque with Reduce Transparency', (tester) async {
      await pump(
        tester,
        caps.copyWith(reduceTransparency: true),
        ElevationLevel.level3,
        glass: glass,
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });
  }

  testWidgets('glass keeps its blur and specular edge without shaders', (
    tester,
  ) async {
    await pump(
      tester,
      caps.copyWith(runtimeShaders: false),
      ElevationLevel.level3,
      glass: true,
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
