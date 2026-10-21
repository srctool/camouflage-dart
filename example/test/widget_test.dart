import 'package:camouflage_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the example shows the color roles in light and dark', (
    tester,
  ) async {
    await tester.pumpWidget(const CamouflageExampleApp());
    expect(find.text('Light · seed #0B57D0'), findsOneWidget);
    expect(find.text('Dark · seed #0B57D0'), findsOneWidget);
    expect(find.text('primaryContainer'), findsNWidgets(2));
  });
}
