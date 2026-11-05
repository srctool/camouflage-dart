import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M9 button group, split button and toolbar renderers against the contract: theme fields honored.
void main() {
  const skin = cupertinoSkin;
  final theme = cupertinoLight;

  testWidgets('a button group honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoButtonGroupTheme(height: 61),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(buttonGroup: o),
        child: CamoButtonGroup(
          buttons: [
            CamoGroupButton(id: 'a', text: 'A', onPressed: () {}),
            CamoGroupButton(id: 'b', text: 'B', onPressed: () {}),
          ],
        ),
      ),
      measure: (size) => size.height == 61,
    );
  });

  testWidgets('a split button honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoSplitButtonTheme(height: 57),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(splitButton: o),
        child: CamoSplitButton(text: 'Save', onPressed: () {}, menu: const []),
      ),
      measure: (size) => size.height == 57,
    );
  });

  testWidgets('a toolbar honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoToolbarTheme(height: 71),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(toolbar: o),
        child: SizedBox(
          width: 300,
          child: CamoToolbar(
            actions: [
              CamoToolbarAction(
                id: 'a',
                label: 'A',
                icon: const Text('A'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      measure: (size) => size.height == 71,
    );
  });
}
