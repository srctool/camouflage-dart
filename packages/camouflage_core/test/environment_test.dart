import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The context layer (ADR-41): the environment, breakpoints and adaptive themes.

const _caps = CamoCapabilities(
  backdropBlur: true,
  runtimeShaders: true,
  windowMaterial: false,
  reduceTransparency: false,
);
const _pointer = CamoEnvironment(
  windowSize: WindowSizeClass.expanded,
  input: InputMode.pointer,
  platform: CamoPlatform.windows,
  capabilities: _caps,
);
final _touch = _pointer.copyWith(
  windowSize: WindowSizeClass.compact,
  input: InputMode.touch,
  platform: CamoPlatform.android,
);

// Spacing.s is 8 by default; the rule makes it 4 with a pointer.
final _dense = themeT.adapt(
  (t, env) => env.input == InputMode.pointer
      ? t.copyWith(spacing: const CamoSpacing(s: 4))
      : t,
);

Widget _app({required Size size, required Widget child}) => MediaQuery(
  data: MediaQueryData(size: size),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  test('breakpoints classify the width', () {
    const b = CamoBreakpoints();
    expect(b.classify(599), WindowSizeClass.compact);
    expect(b.classify(600), WindowSizeClass.medium);
    expect(b.classify(840), WindowSizeClass.expanded);
    expect(b.classify(1200), WindowSizeClass.large);
    expect(
      const CamoBreakpoints(medium: 500).classify(550),
      WindowSizeClass.medium,
    );
  });

  test('the default input follows the platform', () {
    expect(defaultInput(CamoPlatform.ios), InputMode.touch);
    expect(defaultInput(CamoPlatform.android), InputMode.touch);
    expect(defaultInput(CamoPlatform.web), InputMode.pointer);
    expect(defaultInput(CamoPlatform.macOs), InputMode.pointer);
  });

  testWidgets("the root follows the window width and the theme's breakpoints", (
    tester,
  ) async {
    WindowSizeClass? seen;
    Widget build(double width) => _app(
      size: Size(width, 800),
      child: CamouflageProvider(
        skin: skinA,
        theme: themeT.copyWith(breakpoints: const CamoBreakpoints(medium: 700)),
        child: Builder(
          builder: (context) {
            seen = Camouflage.environmentOf(context).windowSize;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(build(400));
    expect(seen, WindowSizeClass.compact);
    await tester.pumpWidget(build(650));
    expect(seen, WindowSizeClass.compact);
    await tester.pumpWidget(build(900));
    expect(seen, WindowSizeClass.expanded);
  });

  testWidgets('a rule runs for the environment and the theme carries it', (
    tester,
  ) async {
    CamoTheme? theme;
    Widget build(CamoEnvironment env) => _app(
      size: const Size(800, 600),
      child: CamouflageProvider(
        skin: skinA,
        theme: _dense,
        environment: env,
        child: Builder(
          builder: (context) {
            theme = Camouflage.themeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(build(_touch));
    expect(theme?.spacing.s, 8);
    expect(theme?.environment, _touch);
    await tester.pumpWidget(build(_pointer));
    expect(theme?.spacing.s, 4);
    expect(theme?.environment, _pointer);
  });

  testWidgets('a nested provider adapts the written theme once', (
    tester,
  ) async {
    // A rule that halves spacing each time would show a second run.
    final halving = themeT.adapt(
      (t, env) => t.copyWith(spacing: CamoSpacing(s: t.spacing.s / 2)),
    );
    CamoTheme? outer;
    CamoTheme? inner;
    CamoTheme? override;
    await tester.pumpWidget(
      _app(
        size: const Size(800, 600),
        child: CamouflageProvider(
          skin: skinA,
          theme: halving,
          environment: _pointer,
          child: Builder(
            builder: (context) {
              outer = Camouflage.themeOf(context);
              return Column(
                children: [
                  CamouflageProvider(
                    skin: skinA,
                    child: Builder(
                      builder: (context) {
                        inner = Camouflage.themeOf(context);
                        return const SizedBox();
                      },
                    ),
                  ),
                  CamouflageProvider(
                    environment: _touch,
                    child: Builder(
                      builder: (context) {
                        override = Camouflage.themeOf(context);
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    expect(outer?.spacing.s, 4);
    expect(inner?.spacing.s, 4);
    expect(override?.spacing.s, 4);
    expect(override?.environment, _touch);
  });

  testWidgets('a theme read from a provider and passed on is not adapted '
      'again', (tester) async {
    final halving = themeT.adapt(
      (t, env) => t.copyWith(spacing: CamoSpacing(s: t.spacing.s / 2)),
    );
    CamoTheme? inner;
    await tester.pumpWidget(
      _app(
        size: const Size(800, 600),
        child: CamouflageProvider(
          skin: skinA,
          theme: halving,
          environment: _pointer,
          child: Builder(
            builder: (context) => CamouflageProvider(
              theme: Camouflage.themeOf(context),
              child: Builder(
                builder: (context) {
                  inner = Camouflage.themeOf(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
    expect(inner?.spacing.s, 4);
  });

  test('rules compose in order', () {
    final theme = themeT
        .adapt((t, env) => t.copyWith(spacing: const CamoSpacing(s: 10)))
        .adapt(
          (t, env) => t.copyWith(spacing: CamoSpacing(s: t.spacing.s * 2)),
        );
    expect(theme.forEnvironment(_pointer).spacing.s, 20);
  });

  test('a theme you build has no environment and lerp keeps the rules', () {
    expect(themeT.environment, isNull);
    final other = _dense.copyWith(
      breakpoints: const CamoBreakpoints(medium: 500),
    );
    final mid = CamoTheme.lerp(themeT, other, 0.75);
    expect(mid.adaptation, same(other.adaptation));
    expect(mid.breakpoints, other.breakpoints);
  });

  testWidgets('reduced motion still applies after the rules', (tester) async {
    CamoTheme? theme;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: CamouflageProvider(
            skin: skinA,
            theme: _dense,
            environment: _pointer,
            child: Builder(
              builder: (context) {
                theme = Camouflage.themeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    expect(theme?.motion.durationMedium, Duration.zero);
    expect(theme?.spacing.s, 4);
  });
}
