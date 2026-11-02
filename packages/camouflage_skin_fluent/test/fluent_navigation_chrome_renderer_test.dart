import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M8 navigation chrome renderers against the contract: behavior on the whole item, theme fields honored.
void main() {
  const skin = fluentSkinDefault;
  final theme = fluentTheme();
  final items = [
    for (final l in ['A', 'B', 'C'])
      CamoNavItem<String>(
        value: l,
        label: l,
        icon: const SizedBox.square(dimension: 8),
      ),
  ];

  testWidgets('an item takes taps across its whole box', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: CamoNavigationBar<String>(
          items: items,
          selected: 'none',
          onChanged: (_) => taps++,
        ),
      ),
    );
    final box = tester.getRect(find.byType(CamoNavItemButton<String>).first);
    await tester.tapAt(box.topLeft + const Offset(1, 1));
    await tester.tapAt(box.bottomRight - const Offset(2, 2));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('a bar honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoNavigationBarTheme(height: 71),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(navigationBar: o),
        child: CamoNavigationBar<String>(
          items: items,
          selected: 'A',
          onChanged: (_) {},
        ),
      ),
      measure: (size) => size.height == 71,
    );
  });

  testWidgets('a rail honors its width', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoNavigationRailTheme(width: 77),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(navigationRail: o),
        child: SizedBox(
          height: 300,
          child: CamoNavigationRail<String>(
            items: items,
            selected: 'A',
            onChanged: (_) {},
          ),
        ),
      ),
      measure: (size) => size.width == 77,
    );
  });

  testWidgets('a drawer honors its width', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoNavigationDrawerTheme(width: 301),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(navigationDrawer: o),
        child: SizedBox(
          height: 300,
          child: CamoNavigationDrawer<String>(
            sections: [CamoNavSection(items: items)],
            selected: 'A',
            onChanged: (_) {},
          ),
        ),
      ),
      measure: (size) => size.width == 301,
    );
  });
}
