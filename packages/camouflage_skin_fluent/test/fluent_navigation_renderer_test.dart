import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M8 tabs and FAB renderers against the contract: behavior on the whole node, theme fields honored.
void main() {
  const skin = fluentSkinDefault;
  final theme = fluentTheme();

  testWidgets('a tab takes taps across its box', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: CamoTabs<int>(
          selected: 1,
          onChanged: (_) => taps++,
          tabs: const [
            CamoTab(1, label: 'One'),
            CamoTab(2, label: 'Two'),
          ],
        ),
      ),
    );
    final box = tester.getRect(find.byType(CamoTabItem<int>).last);
    await tester.tapAt(box.topLeft + const Offset(1, 1));
    await tester.tapAt(box.bottomRight - const Offset(2, 2));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('a fab takes taps across its whole box', (tester) async {
    await assertRendererAppliesBehavior(
      tester,
      skin: skin,
      theme: theme,
      build: (onPressed) => CamoFab(
        icon: const SizedBox.square(dimension: 20),
        semanticLabel: 'Add',
        onPressed: onPressed,
      ),
    );
  });

  testWidgets('a tab bar honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoTabsTheme(height: 61),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(tabs: o),
        child: CamoTabs<String>(
          selected: 'a',
          onChanged: (_) {},
          tabs: const [CamoTab('a', label: 'One')],
        ),
      ),
      measure: (size) => size.height == 61,
    );
  });

  testWidgets('a fab honors its size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoFabTheme(sizeRegular: 57),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(fab: o),
        child: CamoFab(
          icon: const SizedBox.square(dimension: 20),
          semanticLabel: 'Add',
          onPressed: () {},
        ),
      ),
      measure: (size) => size.width == 57,
    );
  });
}
