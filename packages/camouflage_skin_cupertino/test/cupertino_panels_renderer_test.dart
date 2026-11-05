import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M9 popover and side sheet renderers against the contract: theme fields honored.
void main() {
  const skin = cupertinoSkin;
  final theme = cupertinoLight;

  testWidgets('a popover honors its max width', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoPopoverTheme(maxWidth: 211),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(popover: o),
        child: Builder(
          builder: (context) {
            final t = Camouflage.themeOf(context);
            final style = skin.popover.defaults(t).merge(t.components.popover);
            return skin.popover.render(
              context,
              const PopoverState(
                placement: PopoverPlacement.bottom,
                arrowOffset: 0,
              ),
              const PopoverSlots(
                title: 'Title',
                child: SizedBox(width: 600, height: 20),
              ),
              t,
              style,
            );
          },
        ),
      ),
      measure: (size) => size.width == 211,
    );
  });

  testWidgets('a side sheet honors its width', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoSideSheetTheme(width: 277),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(sideSheet: o),
        child: const SizedBox(
          height: 300,
          child: CamoSideSheet(title: 'Details', child: Text('x')),
        ),
      ),
      measure: (size) => size.width == 277,
    );
  });
}
