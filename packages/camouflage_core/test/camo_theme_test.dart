import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('themes with the same values are equal', () {
    expect(const CamoTheme(placeholder: 1), const CamoTheme(placeholder: 1));
  });
}
