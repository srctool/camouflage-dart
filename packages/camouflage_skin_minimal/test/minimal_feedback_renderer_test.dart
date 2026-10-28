import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M7 feedback renderers against the contract: theme fields honored.
void main() {
  const skin = minimalSkin;
  final theme = minimalLight;

  testWidgets('a bar honors its height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoProgressTheme(barHeight: 9),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(progress: o),
        child: const SizedBox(width: 100, child: CamoProgressBar(value: 0.5)),
      ),
      measure: (size) => size.height == 9,
    );
  });

  testWidgets('a banner honors its padding', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoBannerTheme(padding: EdgeInsetsDirectional.all(37)),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(banner: o),
        child: const SizedBox(
          width: 300,
          child: CamoBanner(message: 'Message', icon: SizedBox.shrink()),
        ),
      ),
      measure: (size) => size.height > 74,
    );
  });

  testWidgets('a snackbar honors its min height', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoSnackbarTheme(minHeight: 83),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(snackbar: o),
        child: Builder(
          builder: (context) {
            final t = Camouflage.themeOf(context);
            final style = skin.snackbar
                .defaults(t)
                .merge(t.components.snackbar);
            return SizedBox(
              width: 300,
              child: skin.snackbar.render(
                context,
                SnackbarState(
                  message: 'Saved',
                  action: null,
                  tone: Tone.defaultTone,
                  withDismiss: false,
                  showToneIcon: false,
                  position: style.position,
                  interaction: InteractionState.none,
                ),
                const SnackbarSlots(),
                t,
                style,
              ),
            );
          },
        ),
      ),
      measure: (size) => size.height == 83,
    );
  });
}
