import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_material/camouflage_skin_material.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter_test/flutter_test.dart';

// The M10 rating and pagination renderers against the contract: theme fields honored.
void main() {
  const skin = materialSkin;
  final theme = materialBaselineLight;

  testWidgets('a rating honors its icon size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoRatingTheme(mediumSize: 33),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(rating: o),
        child: const CamoRating(value: 3, label: 'Quality'),
      ),
      measure: (size) => size.height == 33,
    );
  });

  testWidgets('pagination honors its button size', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoPaginationTheme(buttonSize: 61),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(pagination: o),
        child: CamoPagination(pageCount: 5, page: 1, onPageChanged: (_) {}),
      ),
      measure: (size) => size.height == 61,
    );
  });
}
