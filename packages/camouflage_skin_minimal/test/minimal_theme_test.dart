import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the minimal theme validates', () {
    expect(minimalTheme.validate(), isEmpty);
  });
}
