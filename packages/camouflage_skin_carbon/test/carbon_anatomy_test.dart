import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:flutter_test/flutter_test.dart';

// What makes Carbon Carbon, read from the renderers' defaults (base Carbon Skin §3.2).
void main() {
  final themes = [
    for (final f in CarbonThemeFamily.values) carbonTheme(family: f),
  ];

  test('buttons are 48 tall and square', () {
    for (final theme in themes) {
      final style = carbonSkin.button.defaults(theme);
      expect(style.height, 48);
      expect(style.shape, theme.shapes.none);
      expect(style.defaultAppearance, Appearance.solid);
    }
  });

  test('the dialog actions fill the row and the dialog is square', () {
    for (final theme in themes) {
      final style = carbonSkin.dialog.defaults(theme);
      expect(style.actionsLayout, DialogActionsLayout.fullWidthRow);
      expect(style.shape, theme.shapes.none);
      expect(style.showCloseButton, isTrue);
    }
  });

  test('the header is gray 100 in every family', () {
    for (final theme in themes) {
      final colors = carbonSkin.topBar.defaults(theme).colors;
      expect(colors.container, carbonGray100);
      expect(colors.title, carbonGray10);
    }
  });

  test('text fields are 40 tall on the field fill', () {
    for (final theme in themes) {
      final style = carbonSkin.textField.defaults(theme);
      expect(style.height, 40);
      expect(style.colors.container, theme.colors.surfaceContainerLow);
    }
  });

  test('tags are pills, avatars are square, the toggle is green when on', () {
    for (final theme in themes) {
      expect(carbonSkin.chip.defaults(theme).shape, theme.shapes.full);
      expect(carbonSkin.avatar.defaults(theme).shape, AvatarShape.square);
      final toggle = carbonSkin.switchRenderer.defaults(theme);
      expect(toggle.trackWidth, 48);
      expect(toggle.colors.trackOn, theme.colors.success);
    }
  });
}
