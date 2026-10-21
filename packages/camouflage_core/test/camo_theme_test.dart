import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class Brand extends CamoTokenSet<Brand> {
  const Brand(this.accent);

  final Color accent;

  @override
  Brand lerp(Brand other, double t) =>
      Brand(Color.lerp(accent, other.accent, t)!);

  @override
  bool operator ==(Object other) => other is Brand && other.accent == accent;

  @override
  int get hashCode => accent.hashCode;
}

void main() {
  const seed = Color(0xFF6750A4);
  final light = CamoTheme(
    colors: CamoColors.fromSeed(primary: seed),
    typography: CamoTypography.system(),
  );
  final dark = light.copyWith(
    colors: CamoColors.fromSeed(primary: seed, brightness: Brightness.dark),
  );

  test('black on white is 21', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      contrastRatio(const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)),
      closeTo(1, 0.0001),
    );
  });

  test(
    'fromSeed primary is tone 40 (light) and 80 (dark) of the seed palette',
    () {
      final hct = Hct.fromInt(seed.toARGB32());
      final palette = TonalPalette.of(hct.hue, hct.chroma);
      expect(light.colors.primary, Color(palette.get(40)));
      expect(dark.colors.primary, Color(palette.get(80)));
    },
  );

  test('default neutrals are true grays', () {
    final c = light.colors;
    for (final color in [
      c.surface,
      c.surfaceContainer,
      c.onSurface,
      c.outline,
    ]) {
      expect(color.r, closeTo(color.g, 0.002));
      expect(color.g, closeTo(color.b, 0.002));
    }
    expect(c.surface, const Color(0xFFFFFFFF));
  });

  test('seed themes validate in light, dark and with a tinted neutral', () {
    expect(light.validate(), isEmpty);
    expect(dark.validate(), isEmpty);
    expect(
      light
          .copyWith(
            colors: CamoColors.fromSeed(primary: seed, neutral: seed),
          )
          .validate(),
      isEmpty,
    );
  });

  test('a planted low-contrast pair is reported with its ratio', () {
    final bad = light.copyWith(
      colors: light.colors.copyWith(onWarning: light.colors.warning),
    );
    final issue = bad.validate().single as LowContrast;
    expect(issue.pair, 'onWarning/warning');
    expect(issue.ratio, closeTo(1, 0.0001));
    expect(issue.required, 4.5);
  });

  test('negative values are reported', () {
    final bad = light.copyWith(
      spacing: const CamoSpacing(m: -4),
      motion: const CamoMotion(durationLong: Duration(milliseconds: -1)),
      shapes: const CamoShapes(small: BorderRadius.all(Radius.circular(-2))),
    );
    expect(bad.validate().whereType<InvalidValue>().map((i) => i.token), [
      'spacing.m',
      'motion.durationLong',
      'shapes.small',
    ]);
  });

  test('duplicate token sets are reported', () {
    final bad = light.copyWith(
      tokenSets: const [Brand(Color(0xFFFF0000)), Brand(Color(0xFF0000FF))],
    );
    expect(bad.validate(), [const ShadowedRole('tokenSets.Brand')]);
  });

  test('copyWith keeps untouched groups', () {
    final changed = light.copyWith(colors: dark.colors);
    expect(identical(changed.typography, light.typography), isTrue);
    expect(changed.shapes, light.shapes);
  });

  test('an unknown token set is null', () {
    expect(light.tokens<Brand>(), isNull);
    expect(
      light
          .copyWith(tokenSets: const [Brand(Color(0xFFFF0000))])
          .tokens<Brand>(),
      const Brand(Color(0xFFFF0000)),
    );
  });

  test('tone families', () {
    final c = light.colors;
    expect(
      c.family(Tone.defaultTone),
      ToneColors(
        c.primary,
        c.onPrimary,
        c.secondaryContainer,
        c.onSecondaryContainer,
      ),
    );
    expect(c.family(Tone.warning).container, c.warningContainer);
  });

  test('lerp returns the endpoints at 0 and 1, and blends in between', () {
    expect(identical(CamoTheme.lerp(light, dark, 0), light), isTrue);
    expect(identical(CamoTheme.lerp(light, dark, 1), dark), isTrue);
    final mid = CamoTheme.lerp(light, dark, 0.5);
    expect(mid.colors.surface, isNot(light.colors.surface));
    expect(mid.colors.surface, isNot(dark.colors.surface));
  });

  test('lerp blends token sets of the same type', () {
    final a = light.copyWith(tokenSets: const [Brand(Color(0xFF000000))]);
    final b = light.copyWith(tokenSets: const [Brand(Color(0xFFFFFFFF))]);
    final mid = CamoTheme.lerp(a, b, 0.5).tokens<Brand>()!;
    expect(mid.accent.r, inExclusiveRange(0, 1));
  });

  testWidgets('CamoAnimatedTheme blends to a new theme', (tester) async {
    Widget app(CamoTheme theme) => Directionality(
      textDirection: TextDirection.ltr,
      child: CamoAnimatedTheme(
        theme: theme,
        duration: const Duration(milliseconds: 300),
        builder: (context, t) =>
            ColoredBox(color: t.colors.surface, child: const SizedBox.expand()),
      ),
    );
    Color surface() => tester.widget<ColoredBox>(find.byType(ColoredBox)).color;
    await tester.pumpWidget(app(light));
    expect(surface(), light.colors.surface);
    await tester.pumpWidget(app(dark));
    await tester.pump(const Duration(milliseconds: 150));
    expect(surface(), isNot(light.colors.surface));
    expect(surface(), isNot(dark.colors.surface));
    await tester.pumpAndSettle();
    expect(surface(), dark.colors.surface);
  });
}
