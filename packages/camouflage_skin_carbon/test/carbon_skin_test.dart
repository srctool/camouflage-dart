import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the skin is named and uses layered surfaces and Carbon states', () {
    expect(carbonSkin.name, 'carbon');
    expect(carbonSkin.surfaceTreatment, isA<Layered>());
    expect(carbonSkin.feedback, isA<CarbonStates>());
  });
}
