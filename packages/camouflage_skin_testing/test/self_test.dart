import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The checks must catch the bugs they exist for (Testing §4, done when).

// Hard-codes its height instead of reading style.height.
class _FixedHeight implements CamoButtonRenderer {
  const _FixedHeight();

  @override
  CamoButtonStyle defaults(CamoTheme theme) =>
      const MinimalButtonRenderer().defaults(theme);

  @override
  Widget render(
    BuildContext context,
    ButtonState state,
    ButtonSlots slots,
    CamoTheme theme,
    CamoButtonStyle style,
  ) => SizedBox(width: style.minWidth, height: 40, child: Text(state.text));
}

// Swallows taps with its own detector, so the component never hears them.
class _SwallowsTaps implements CamoButtonRenderer {
  const _SwallowsTaps();

  @override
  CamoButtonStyle defaults(CamoTheme theme) =>
      const MinimalButtonRenderer().defaults(theme);

  @override
  Widget render(
    BuildContext context,
    ButtonState state,
    ButtonSlots slots,
    CamoTheme theme,
    CamoButtonStyle style,
  ) => GestureDetector(
    onTap: () {},
    child: SizedBox(width: 80, height: 40, child: Text(state.text)),
  );
}

void main() {
  testWidgets('a renderer that swallows taps fails', (tester) async {
    await expectLater(
      () => assertRendererAppliesBehavior(
        tester,
        skin: minimalSkin.copyWith(button: const _SwallowsTaps()),
        theme: minimalLight,
        build: (onPressed) => CamoButton(text: 'Save', onPressed: onPressed),
      ),
      throwsA(isA<TestFailure>()),
    );
  });

  testWidgets('a hard-coded height fails', (tester) async {
    await expectLater(
      () => assertNoLiterals(
        tester,
        skin: minimalSkin.copyWith(button: const _FixedHeight()),
        theme: minimalLight,
        oddStyle: const CamoButtonTheme(height: 77),
        build: (o) => ProvideComponentThemes(
          components: CamoComponentThemes(button: o),
          child: CamoButton(text: 'Go', onPressed: () {}),
        ),
        measure: (size) => size.height == 77,
      ),
      throwsA(isA<TestFailure>()),
    );
  });

  testWidgets('a correct renderer passes both', (tester) async {
    await assertRendererAppliesBehavior(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      build: (onPressed) => CamoButton(text: 'Save', onPressed: onPressed),
    );
    await assertNoLiterals(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      oddStyle: const CamoButtonTheme(height: 77),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(button: o),
        child: CamoButton(text: 'Go', onPressed: () {}),
      ),
      measure: (size) => size.height == 77,
    );
  });
}
