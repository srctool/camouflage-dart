import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/navigation.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M8 sample end to end: tabs drive the pager, the FAB collapses while the list scrolls and hides on the way down.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  builder: (context, _) => CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: NavigationDemo()),
  ),
);

void main() {
  testWidgets('a tap on a tab turns the page', (tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Overview: swipe or tap a tab'), findsOneWidget);
    await tester.tap(find.text('Specs'));
    await tester.pumpAndSettle();
    expect(find.text('Specs: swipe or tap a tab'), findsOneWidget);
  });

  testWidgets(
    'scrolling the list hides the FAB and scrolling up brings it back',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 4000);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app());
      expect(find.text('Compose'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Compose message'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(find.text('Compose'), findsOneWidget);
    },
  );
}
