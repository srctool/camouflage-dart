import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The key of the box [camoTestApp] wraps the content in.
const Key camoContentKey = ValueKey('camo-content');

/// [child] under a provider with [skin] and [theme], with what `WidgetsApp` gives every app (an overlay, the
/// default shortcuts), at [textScale] and in [textDirection]. The content sits in a box keyed [camoContentKey]
/// that sizes to it.
Widget camoTestApp({
  required CamoSkin skin,
  required CamoTheme theme,
  required Widget child,
  double textScale = 1,
  TextDirection textDirection = TextDirection.ltr,
}) => MediaQuery(
  data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
  child: Directionality(
    textDirection: textDirection,
    child: Shortcuts(
      shortcuts: WidgetsApp.defaultShortcuts,
      child: Overlay(
        key: UniqueKey(),
        initialEntries: [
          OverlayEntry(
            builder: (_) => CamouflageProvider(
              skin: skin,
              theme: theme,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: KeyedSubtree(key: camoContentKey, child: child),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

/// [child] under the current theme with its component themes replaced by [components].
class ProvideComponentThemes extends StatelessWidget {
  /// Creates the override.
  const ProvideComponentThemes({
    super.key,
    required this.components,
    required this.child,
  });

  /// The component themes to use.
  final CamoComponentThemes components;

  /// The subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) => CamouflageProvider(
    theme: Camouflage.themeOf(context).copyWith(components: components),
    child: child,
  );
}

/// Checks that a pressable component keeps its behavior under [skin]: a tap at the rendered box's corner and one
/// at its center both fire, and it's exposed as one button. In Flutter the component wraps what the renderer
/// returns, so this mostly guards renderers that add their own gesture handling or swallow taps.
Future<void> assertRendererAppliesBehavior(
  WidgetTester tester, {
  required CamoSkin skin,
  required CamoTheme theme,
  required Widget Function(VoidCallback onPressed) build,
}) async {
  var taps = 0;
  final handle = tester.ensureSemantics();
  try {
    await tester.pumpWidget(
      camoTestApp(skin: skin, theme: theme, child: build(() => taps++)),
    );
    final box = tester.getRect(find.byKey(camoContentKey));
    await tester.tapAt(box.topLeft + const Offset(1, 1));
    await tester.tapAt(box.center);
    await tester.pump();
    expect(
      taps,
      2,
      reason: 'a tap at the corner and one at the center of the rendered box must both fire',
    );
    final buttons = find.semantics.byFlag(SemanticsFlag.isButton);
    expect(
      buttons,
      findsOneWidget,
      reason: 'the component must expose one button',
    );
  } finally {
    handle.dispose();
  }
}

/// The "no literals" check: renders with [oddStyle], a style holding values no skin would pick, and asserts
/// [measure] on the content's size, so a renderer that ignores a component-theme field fails.
Future<void> assertNoLiterals<S>(
  WidgetTester tester, {
  required CamoSkin skin,
  required CamoTheme theme,
  required S oddStyle,
  required Widget Function(S style) build,
  required bool Function(Size size) measure,
}) async {
  await tester.pumpWidget(
    camoTestApp(skin: skin, theme: theme, child: build(oddStyle)),
  );
  final size = tester.getSize(find.byKey(camoContentKey));
  expect(
    measure(size),
    isTrue,
    reason: 'the renderer ignored a field of $oddStyle (size $size)',
  );
}
