import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_example/lists.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M10 sample end to end: the table sorts and selects, and the tree loads its branch when opened.
Widget _app() => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: minimalSkin,
    theme: minimalLight,
    child: const SingleChildScrollView(child: ListsDemo()),
  ),
);

void main() {
  testWidgets('sorting reorders the rows and a press selects one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    final before = tester.getTopLeft(find.text('Ada Lovelace')).dy;
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Ada Lovelace')).dy,
      greaterThan(before),
    );
    await tester.tap(find.text('Grace Hopper'));
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);
  });

  testWidgets('opening the shared drive loads its files', (tester) async {
    tester.view.physicalSize = const Size(3000, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    expect(find.text('Backup.zip'), findsNothing);
    // The chevron sits in a 24 wide box just before the label.
    final label = tester.getCenter(find.text('Shared drive'));
    final left = tester.getTopLeft(find.text('Shared drive')).dx;
    await tester.tapAt(Offset(left - 16, label.dy));
    await tester.pump();
    await tester.pump();
    expect(find.text('Backup.zip'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
  });
}
