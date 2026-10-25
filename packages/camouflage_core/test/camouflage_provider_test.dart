import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

Widget _app(Widget child, {bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  // Base Provider and Scoping §3.1: what the outer and inner providers set, read inside the inner one.
  Future<(CamoSkin?, CamoTheme?)> inside(
    WidgetTester tester,
    (CamoSkin?, CamoTheme?)? outer,
    (CamoSkin?, CamoTheme?) inner,
  ) async {
    CamoSkin? skin;
    CamoTheme? theme;
    final read = Builder(
      builder: (context) {
        skin = Camouflage.maybeSkinOf(context);
        theme = Camouflage.maybeThemeOf(context);
        return const SizedBox();
      },
    );
    final innerProvider = CamouflageProvider(
      skin: inner.$1,
      theme: inner.$2,
      child: read,
    );
    await tester.pumpWidget(
      _app(
        outer == null
            ? innerProvider
            : CamouflageProvider(
                skin: outer.$1,
                theme: outer.$2,
                child: innerProvider,
              ),
      ),
    );
    return (skin, theme);
  }

  group('inheritance', () {
    testWidgets('an inner provider with nothing inherits both', (t) async {
      expect(await inside(t, (skinA, themeT), (null, null)), (skinA, themeT));
    });
    testWidgets('an inner theme overrides only the theme', (t) async {
      expect(await inside(t, (skinA, themeT), (null, themeU)), (skinA, themeU));
    });
    testWidgets('an inner skin overrides only the skin', (t) async {
      expect(await inside(t, (skinA, themeT), (skinB, null)), (skinB, themeT));
    });
    testWidgets('an inner skin and theme override both', (t) async {
      expect(await inside(t, (skinA, themeT), (skinB, themeU)), (
        skinB,
        themeU,
      ));
    });
    testWidgets('a lone skin has no theme', (t) async {
      expect(await inside(t, null, (skinB, null)), (skinB, null));
    });
    testWidgets('a lone theme has no skin', (t) async {
      expect(await inside(t, null, (null, themeU)), (null, themeU));
    });
    testWidgets('a lone provider with both works', (t) async {
      expect(await inside(t, null, (skinB, themeU)), (skinB, themeU));
    });
  });

  group('fail fast', () {
    Future<String> errorOf(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(_app(child));
      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      return (error as FlutterError).message;
    }

    testWidgets('no provider names the component and the skin', (t) async {
      final message = await errorOf(
        t,
        Builder(
          builder: (context) {
            Camouflage.skinOf(context, component: 'CamoButton');
            return const SizedBox();
          },
        ),
      );
      expect(
        message,
        startsWith(
          'No CamouflageProvider found above CamoButton: missing skin.\n'
          'Wrap your app in CamouflageProvider(skin: …, theme: …)',
        ),
      );
    });

    testWidgets('a theme-only provider fails on the skin', (t) async {
      final message = await errorOf(
        t,
        CamouflageProvider(
          theme: themeU,
          child: Builder(
            builder: (context) {
              Camouflage.skinOf(context, component: 'CamoButton');
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        message,
        startsWith(
          'No CamouflageProvider found above CamoButton: missing skin.',
        ),
      );
    });

    testWidgets('a missing token set is named', (t) async {
      final message = await errorOf(
        t,
        CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Builder(
            builder: (context) {
              Camouflage.tokensOf<Brand>(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(message, contains('missing token set Brand in the theme.'));
    });
  });

  testWidgets('a skin switch rebuilds dependents', (tester) async {
    final names = <String>[];
    Widget app(CamoSkin skin) => _app(
      CamouflageProvider(
        skin: skin,
        theme: themeT,
        child: Builder(
          builder: (context) {
            names.add(Camouflage.skinOf(context).name);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(app(skinA));
    await tester.pumpWidget(app(skinB));
    expect(names, ['a', 'b']);
  });

  testWidgets('disableAnimations zeroes the durations', (tester) async {
    late CamoMotion motion;
    await tester.pumpWidget(
      _app(
        disableAnimations: true,
        CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Builder(
            builder: (context) {
              motion = Camouflage.motionOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect([
      motion.durationShort,
      motion.durationMedium,
      motion.durationLong,
    ], everyElement(Duration.zero));
  });

  testWidgets('a provider resets the content style; containers set it', (
    tester,
  ) async {
    late Color reset;
    late CamoIconStyle resetIcon;
    late Color inner;
    late IconThemeData iconTheme;
    await tester.pumpWidget(
      _app(
        CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: CamoContentStyle(
            color: const Color(0xFFFF0000),
            iconStyle: const CamoIconStyle(size: 18, color: Color(0xFF0000FF)),
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    inner = Camouflage.contentColorOf(context);
                    iconTheme = IconTheme.of(context);
                    return const SizedBox();
                  },
                ),
                CamouflageProvider(
                  theme: themeU,
                  child: Builder(
                    builder: (context) {
                      reset = Camouflage.contentColorOf(context);
                      resetIcon = Camouflage.iconStyleOf(context);
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(inner, const Color(0xFFFF0000));
    expect(iconTheme.color, const Color(0xFF0000FF));
    expect(iconTheme.size, 18);
    expect(reset, themeU.colors.onSurface);
    expect(resetIcon, CamoIconStyle(size: 24, color: themeU.colors.onSurface));
  });

  testWidgets('a route pushed from a nested provider sees the nested theme', (
    tester,
  ) async {
    CamoTheme? inRoute;
    await tester.pumpWidget(
      CamouflageProvider(
        skin: skinA,
        theme: themeT,
        child: WidgetsApp(
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) =>
              PageRouteBuilder<T>(pageBuilder: (c, _, _) => builder(c)),
          home: CamouflageProvider(
            theme: themeU,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => pushCamoRoute<void>(
                  context,
                  route: (builder) =>
                      PageRouteBuilder(pageBuilder: (c, _, _) => builder(c)),
                  builder: (routeContext) {
                    inRoute = Camouflage.themeOf(routeContext);
                    return const SizedBox();
                  },
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(inRoute, same(themeU));
  });

  test('copyWith keeps the other fields identical', () {
    const feedback = NoFeedback();
    final copy = skinA.copyWith(feedback: feedback);
    expect(identical(copy.surfaceTreatment, skinA.surfaceTreatment), isTrue);
    expect(identical(copy.name, skinA.name), isTrue);
    expect(identical(copy.feedback, feedback), isTrue);
    // A skin that leaves out a field doesn't compile: CamoSkin has no defaults (Skin Contract §3.3).
  });

  test('the controller reports interactions and press positions', () async {
    final controller = CamoInteractionController();
    final downs = <Offset>[];
    final sub = controller.pressDowns.listen(downs.add);
    var notified = 0;
    controller.addListener(() => notified++);

    controller.pressDown(const Offset(3, 4));
    controller.setFocused(true, byKeyboard: true);
    controller.setHovered(true);
    controller.setHovered(true); // no change, no notification
    await Future<void>.delayed(Duration.zero);

    expect(
      controller.value,
      const InteractionState(pressed: true, focused: true, hovered: true),
    );
    expect(controller.focusedByKeyboard, isTrue);
    expect(downs, [const Offset(3, 4)]);
    expect(notified, 3);

    controller.pressEnd();
    controller.setFocused(true);
    expect(controller.value.pressed, isFalse);
    expect(controller.focusedByKeyboard, isFalse);
    await sub.cancel();
    controller.dispose();
  });

  test('disabled scales the alpha', () {
    expect(disabled(const Color(0xFF000000), 0.38).a, closeTo(0.38, 0.01));
    expect(disabled(const Color(0x80000000), 0.38).a, closeTo(0.19, 0.01));
  });
}
