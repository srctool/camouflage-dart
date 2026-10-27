import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M5 selection controls, slider and stepper against the contract: taps reach the whole control, and every
// component-theme field is honored.
void main() {
  const skin = fluentSkinDefault;
  final theme = fluentTheme();

  // A tap at the rendered box's corner and one at its center both fire.
  Future<void> cornerAndCenter(
    WidgetTester tester,
    Widget Function(VoidCallback onTap) build,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      camoTestApp(skin: skin, theme: theme, child: build(() => taps++)),
    );
    final box = tester.getRect(find.byKey(camoContentKey));
    await tester.tapAt(box.topLeft + const Offset(1, 1));
    await tester.tapAt(box.center);
    await tester.pump();
    expect(taps, 2);
  }

  testWidgets('checkbox takes taps across its row', (tester) async {
    await cornerAndCenter(
      tester,
      (onTap) => CamoCheckbox(
        checked: false,
        onChanged: (_) => onTap(),
        label: 'Remember',
      ),
    );
  });

  testWidgets('switch takes taps across its row', (tester) async {
    await cornerAndCenter(
      tester,
      (onTap) => SizedBox(
        width: 200,
        child: CamoSwitch(
          checked: false,
          onChanged: (_) => onTap(),
          label: 'Wi-Fi',
        ),
      ),
    );
  });

  testWidgets('radio takes taps across its row', (tester) async {
    await cornerAndCenter(
      tester,
      (onTap) => CamoRadio(selected: false, onChanged: onTap, label: 'Card'),
    );
  });

  testWidgets('a segment takes taps across its box', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: CamoSegmentedControl<int>(
          options: const [
            Segment(1, label: 'One'),
            Segment(2, label: 'Two'),
          ],
          selected: 1,
          onChanged: (_) => taps++,
        ),
      ),
    );
    final box = tester.getRect(find.byType(CamoSegmentButton<int>).last);
    await tester.tapAt(box.topLeft + const Offset(1, 1));
    await tester.tapAt(box.bottomRight - const Offset(2, 2));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('checkbox honors boxSize', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoCheckboxTheme(boxSize: 77),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(checkbox: o),
        child: CamoCheckbox(checked: true, onChanged: (_) {}),
      ),
      measure: (size) => size.width == 77,
    );
  });

  testWidgets('switch honors its track size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoSwitchTheme(trackWidth: 90, trackHeight: 60),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(switchTheme: o),
        child: CamoSwitch(checked: true, onChanged: (_) {}),
      ),
      measure: (size) => size == const Size(90, 60),
    );
  });

  testWidgets('radio honors its size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoRadioTheme(size: 70),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(radio: o),
        child: CamoRadio(selected: true, onChanged: () {}),
      ),
      measure: (size) => size.width == 70,
    );
  });

  testWidgets('segmented control honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoSegmentedControlTheme(height: 70),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(segmentedControl: o),
        child: CamoSegmentedControl<int>(
          options: const [
            Segment(1, label: 'One'),
            Segment(2, label: 'Two'),
          ],
          selected: 1,
          onChanged: (_) {},
        ),
      ),
      measure: (size) => size.height == 70,
    );
  });

  testWidgets('slider honors its thumb size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoSliderTheme(thumbSize: Size(60, 60)),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(slider: o),
        child: SizedBox(
          width: 200,
          child: CamoSlider(value: 0.5, onChanged: (_) {}),
        ),
      ),
      measure: (size) => size.height == 60,
    );
  });

  for (final layout in StepperLayout.values) {
    testWidgets('stepper honors its height (${layout.name})', (tester) async {
      await assertNoLiterals(
        tester,
        skin: skin,
        theme: theme,
        oddStyle: CamoStepperTheme(layout: layout, height: 70),
        build: (o) => ProvideComponentThemes(
          components: CamoComponentThemes(stepper: o),
          child: CamoStepper(value: 2, onChanged: (_) {}, semanticLabel: 'Qty'),
        ),
        measure: (size) => size.height == 70,
      );
    });
  }
}
