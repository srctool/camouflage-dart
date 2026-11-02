import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/small_data.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M10 sample end to end: the rating changes, a page turns, the path steps up and the wizard moves.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: SmallDataDemo()),
  ),
);

void main() {
  testWidgets('a tap on a star, a page and a path item change the screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Quality: 3.5 of 5'), findsOneWidget);
    final rect = tester.getRect(find.bySemanticsLabel('Quality'));
    await tester.tapAt(Offset(rect.right - 2, rect.center.dy));
    await tester.pump();
    expect(find.text('Quality: 5.0 of 5'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pump();
    expect(find.text('Page 2 of 12'), findsWidgets);
    await tester.tap(find.text('Projects'));
    await tester.pump();
    expect(find.text('Notes'), findsNothing);
  });

  testWidgets('Next and Back move the wizard', (tester) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Payment')).value,
      'Step 3 of 4, current',
    );
    await tester.tap(find.text('Back'));
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Shipping')).value,
      'Step 2 of 4, current',
    );
  });
}
