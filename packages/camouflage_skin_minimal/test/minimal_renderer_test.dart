import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal's renderers against the contract: behavior kept, and every component-theme field honored.
void main() {
  testWidgets('button keeps its behavior', (tester) async {
    await assertRendererAppliesBehavior(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      build: (onPressed) => CamoButton(text: 'Save', onPressed: onPressed),
    );
  });

  testWidgets('icon button keeps its behavior', (tester) async {
    await assertRendererAppliesBehavior(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      build: (onPressed) => CamoIconButton(
        icon: const CamoIcon(galleryIcon),
        semanticLabel: 'Close',
        onPressed: onPressed,
      ),
    );
  });

  testWidgets('button honors height and minWidth', (tester) async {
    await assertNoLiterals(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      oddStyle: const CamoButtonTheme(height: 77, minWidth: 222),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(button: o),
        child: CamoButton(text: 'Go', onPressed: () {}),
      ),
      measure: (size) => size == const Size(222, 77),
    );
  });

  testWidgets('icon button honors containerSize', (tester) async {
    await assertNoLiterals(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      oddStyle: const CamoIconButtonTheme(containerSize: 66),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(iconButton: o),
        child: CamoIconButton(
          icon: const CamoIcon(galleryIcon),
          semanticLabel: 'Close',
          onPressed: () {},
        ),
      ),
      measure: (size) => size.width == 66,
    );
  });

  testWidgets('divider honors thickness', (tester) async {
    await assertNoLiterals(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      oddStyle: const CamoDividerTheme(thickness: 7),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(divider: o),
        child: const SizedBox(width: 100, child: CamoDivider()),
      ),
      measure: (size) => size.height == 7,
    );
  });

  testWidgets('progress circle honors its size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: minimalSkin,
      theme: minimalLight,
      oddStyle: const CamoProgressTheme(circleSizeLarge: 70),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(progress: o),
        child: const CamoProgressCircle(value: 0.5, size: ProgressSize.large),
      ),
      measure: (size) => size.width == 70,
    );
  });
}
