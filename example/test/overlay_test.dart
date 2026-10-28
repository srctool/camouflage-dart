import 'package:camouflage_example/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a mouse click opens the delete dialog and it stays open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 12000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CamouflageExampleApp());
    await tester.pump();
    final button = find.text('Delete item');
    await tester.ensureVisible(button);
    await tester.pump(const Duration(seconds: 1));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(button));
    await gesture.moveTo(tester.getCenter(button));
    await tester.pump();
    await gesture.down(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 60));
    await gesture.up();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Delete item?'), findsOneWidget);
    await gesture.removePointer();
    // Let the paged list's fake requests finish before the tree goes.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  });
}
