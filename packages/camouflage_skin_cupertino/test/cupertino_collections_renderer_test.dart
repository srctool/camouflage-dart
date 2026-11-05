import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter_test/flutter_test.dart';

// The M10 file uploader renderer against the contract: theme fields honored.
void main() {
  const skin = cupertinoSkin;
  final theme = cupertinoLight;

  testWidgets('the zone honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoUploaderTheme(zoneHeight: 147),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(fileUploader: o),
        child: CamoFileUploader(
          files: const [],
          onPick: () {},
          onRemove: (_) {},
          semanticLabel: 'Upload files',
        ),
      ),
      measure: (size) => size.height == 147,
    );
  });
}
