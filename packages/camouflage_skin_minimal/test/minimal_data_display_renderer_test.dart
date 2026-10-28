import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M7 data display renderers against the contract: behavior on the whole chip, theme fields honored.
void main() {
  const skin = minimalSkin;
  final theme = minimalLight;

  testWidgets('a chip takes taps across its whole box', (tester) async {
    await assertRendererAppliesBehavior(
      tester,
      skin: skin,
      theme: theme,
      build: (onPressed) => CamoChip(label: 'Chip', onPressed: onPressed),
    );
  });

  testWidgets('a chip honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoChipTheme(height: 53),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(chip: o),
        child: const CamoChip(label: 'Tag'),
      ),
      measure: (size) => size.height == 53,
    );
  });

  testWidgets('a chip in a scrolling row keeps its label', (tester) async {
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [CamoChip(label: 'Relevance')]),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CamoChip)).width, greaterThan(60));
  });

  testWidgets('a dot honors its size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoBadgeTheme(dotSize: 13),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(badge: o),
        child: const CamoBadge(),
      ),
      measure: (size) => size.width == 13,
    );
  });

  testWidgets('a count honors its min width', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoBadgeTheme(minWidth: 31),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(badge: o),
        child: const CamoBadge(count: 1),
      ),
      measure: (size) => size.width == 31,
    );
  });

  testWidgets('an avatar honors its size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoAvatarTheme(sizeMedium: 57),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(avatar: o),
        child: const CamoAvatar(name: 'Ada Lovelace'),
      ),
      measure: (size) => size.width == 57,
    );
  });
}
