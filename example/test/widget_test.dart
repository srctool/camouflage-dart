import 'package:camouflage_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the example app starts', (tester) async {
    await tester.pumpWidget(const CamouflageExampleApp());
    expect(find.text('Camouflage example (M0), theme 0'), findsOneWidget);
  });
}
