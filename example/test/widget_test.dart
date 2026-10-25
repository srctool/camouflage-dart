import 'package:camouflage_example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the example switches skin through the root provider', (
    tester,
  ) async {
    await tester.pumpWidget(const CamouflageExampleApp());
    expect(
      find.text('[debug] Inherits the root skin and theme'),
      findsOneWidget,
    );
    expect(
      find.text('[debug-outline] Uses the other skin, inherits the root theme'),
      findsOneWidget,
    );

    await tester.tap(find.text('[debug] Skin: debug'));
    await tester.pumpAndSettle();
    expect(
      find.text('[debug-outline] Inherits the root skin and theme'),
      findsOneWidget,
    );
    expect(
      find.text('[debug] Uses the other skin, inherits the root theme'),
      findsOneWidget,
    );
  });

  testWidgets('the example starts in dark mode when the platform is dark', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(const CamouflageExampleApp());
    await tester.pumpAndSettle();
    expect(find.text('[debug] Dark'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
