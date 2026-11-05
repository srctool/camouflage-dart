import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the skin is named and uses press-fade feedback', () {
    expect(cupertinoSkin.name, 'cupertino');
    expect(cupertinoSkin.feedback, isA<OpacityFeedback>());
  });

  test('the surface option picks the treatment', () {
    expect(cupertinoSkinWith().surfaceTreatment, isA<Classic>());
    expect(
      cupertinoSkinWith(surface: CupertinoSurface.liquidGlass).surfaceTreatment,
      isA<LiquidGlass>(),
    );
  });
}
