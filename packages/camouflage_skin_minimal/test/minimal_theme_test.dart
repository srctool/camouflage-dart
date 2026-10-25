import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light, dark and accent themes validate', () {
    const accent = Color(0xFF0B57D0);
    for (final theme in [
      minimalLight,
      minimalDark,
      minimalTheme(accent: accent),
      minimalTheme(accent: accent, brightness: Brightness.dark),
    ]) {
      expect(theme.validate(), isEmpty);
    }
  });

  test('without an accent, primary is ink', () {
    expect(minimalLight.colors.primary, minimalLight.colors.onSurface);
    expect(minimalDark.colors.primary, minimalDark.colors.onSurface);
  });
}
