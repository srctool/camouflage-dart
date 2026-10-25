import 'package:camouflage_example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the example switches skins through the root provider', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CamouflageExampleApp());
    await tester.pump();
    expect(find.text('solid'), findsNWidgets(4));
    await tester.tap(find.text('Debug'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('[solid] solid'), findsNWidgets(4));
    await tester.tap(find.text('[outline] Fluent'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('solid'), findsNWidgets(4));
  });

  testWidgets('the example starts in dark mode when the platform is dark', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.view.physicalSize = const Size(1200, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CamouflageExampleApp());
    await tester.pump();
    expect(find.text('Light'), findsOneWidget);
  });
}
