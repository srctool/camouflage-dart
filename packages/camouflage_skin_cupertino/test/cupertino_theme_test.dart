import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Apple's published system colors don't all reach WCAG AA (white on systemBlue is 4.0, secondaryLabel on the grouped
// background 3.1): the skin keeps them as published (base Cupertino Skin §3), so these pairs are the known
// exceptions. The text roles on the page (`onSurface`) must pass, and a new pair failing is a regression.
const _appleKnown = {
  'onPrimary/primary',
  'onPrimaryContainer/primaryContainer',
  'onSecondary/secondary',
  'onTertiaryContainer/tertiaryContainer',
  'onError/error',
  'onErrorContainer/errorContainer',
  'onSuccess/success',
  'onSuccessContainer/successContainer',
  'onWarning/warning',
  'onInfo/info',
  'onInfoContainer/infoContainer',
  'onSurfaceVariant/surface',
  'onSurfaceVariant/surfaceContainerLowest',
  'onSurfaceVariant/surfaceContainerLow',
  'onSurfaceVariant/surfaceContainer',
  'onSurfaceVariant/surfaceContainerHigh',
  'onSurfaceVariant/surfaceContainerHighest',
  'outline/surface',
  'onWarningContainer/warningContainer',
  'onTertiary/tertiary',
  'primary/surface',
  'onSecondaryContainer/secondaryContainer',
};

void main() {
  const accent = Color(0xFF0B57D0);
  final themes = [
    cupertinoLight,
    cupertinoDark,
    cupertinoTheme(accent: accent),
    cupertinoTheme(accent: accent, brightness: Brightness.dark),
  ];

  test('only Apple\'s own color pairs are below contrast', () {
    for (final theme in themes) {
      final failing = theme
          .validate()
          .whereType<LowContrast>()
          .map((i) => i.pair)
          .toList();
      expect(failing.where((p) => !_appleKnown.contains(p)), isEmpty);
      expect(failing, isNot(contains('onSurface/surface')));
    }
  });

  // The system colors of the HIG tables, pinned: a change here is a decision, not a side effect.
  test('the system colors are pinned', () {
    final light = cupertinoLight.colors;
    final dark = cupertinoDark.colors;
    expect(light.primary, const Color(0xFF007AFF));
    expect(dark.primary, const Color(0xFF0A84FF));
    expect(light.error, const Color(0xFFFF3B30));
    expect(dark.error, const Color(0xFFFF453A));
    expect(light.success, const Color(0xFF34C759));
    expect(dark.success, const Color(0xFF30D158));
    expect(light.warning, const Color(0xFFFF9500));
    expect(dark.warning, const Color(0xFFFF9F0A));
    expect(light.info, const Color(0xFF30B0C7));
    expect(dark.info, const Color(0xFF40CBE0));
    expect(light.surface, const Color(0xFFF2F2F7)); // systemGroupedBackground
    expect(light.surfaceContainerLow, const Color(0xFFFFFFFF));
    expect(dark.surface, const Color(0xFF000000));
    expect(dark.surfaceContainerLow, const Color(0xFF1C1C1E));
  });

  test('an accent replaces the system blue in both appearances', () {
    expect(cupertinoTheme(accent: accent).colors.primary, accent);
    expect(
      cupertinoTheme(
        accent: accent,
        brightness: Brightness.dark,
      ).colors.primary,
      accent,
    );
  });
}
