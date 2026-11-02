import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/popover/camo_popover.dart' as popover;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'panel_test_renderers.dart';
import 'test_skins.dart';

// The M9 popover and side sheet tests from their Flutter notes.

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Directionality(
        textDirection: direction,
        child: CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

popover.PopoverLayout _place(
  Rect anchor,
  popover.PopoverPlacement requested, {
  bool ltr = true,
}) => popover.placePopover(
  anchor: anchor,
  size: const Size(200, 100),
  window: const Size(800, 600),
  requested: requested,
  gap: 8,
  ltr: ltr,
);

void main() {
  group('popover placement', () {
    test('opens below the anchor, centered on it', () {
      final layout = _place(
        const Rect.fromLTWH(300, 100, 40, 20),
        PopoverPlacement.auto,
      );
      expect(layout.placement, PopoverPlacement.bottom);
      expect(layout.offset, const Offset(220, 128));
      expect(layout.arrow, 100);
    });

    test('flips above when there is no room below', () {
      final layout = _place(
        const Rect.fromLTWH(300, 560, 40, 20),
        PopoverPlacement.auto,
      );
      expect(layout.placement, PopoverPlacement.top);
      expect(layout.offset.dy, 560 - 8 - 100);
    });

    test(
      'stays inside the window and the arrow still points at the anchor',
      () {
        final layout = _place(
          const Rect.fromLTWH(0, 100, 40, 20),
          PopoverPlacement.auto,
        );
        expect(layout.offset.dx, 0);
        expect(layout.arrow, 20);
      },
    );

    test('the side placements follow the reading direction', () {
      const anchor = Rect.fromLTWH(400, 200, 40, 20);
      expect(_place(anchor, PopoverPlacement.end).offset.dx, 448);
      final mirrored = _place(anchor, PopoverPlacement.end, ltr: false);
      expect(mirrored.placement, PopoverPlacement.end);
      expect(mirrored.offset.dx, 400 - 8 - 200);
    });

    test('a side placement flips when it does not fit', () {
      final layout = _place(
        const Rect.fromLTWH(700, 200, 40, 20),
        PopoverPlacement.end,
      );
      expect(layout.placement, PopoverPlacement.start);
    });
  });

  group('popover', () {
    testWidgets('shows while open and Esc asks to close', (tester) async {
      var open = false;
      var requests = 0;
      late StateSetter set;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return CamoPopover(
                open: open,
                onDismissRequest: () => requests++,
                anchor: const Text('anchor'),
                title: 'Details',
                child: const Text('body'),
              );
            },
          ),
        ),
      );
      expect(find.text('body'), findsNothing);
      set(() => open = true);
      await tester.pumpAndSettle();
      expect(find.text('body'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(lastPopover, isNotNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(requests, greaterThan(0));
      // The app closes it by setting open to false.
      set(() => open = false);
      await tester.pumpAndSettle();
      expect(find.text('body'), findsNothing);
    });

    testWidgets('an outside tap asks to close', (tester) async {
      var requests = 0;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            height: 300,
            child: CamoPopover(
              open: true,
              onDismissRequest: () => requests++,
              anchor: const Text('anchor'),
              child: const Text('body'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(700, 500));
      expect(requests, 1);
    });

    testWidgets('the anchor announces whether it is open', (tester) async {
      final semantics = tester.ensureSemantics();
      Widget app({required bool open}) => _app(
        CamoPopover(
          open: open,
          onDismissRequest: () {},
          anchor: const Text('anchor'),
          child: const Text('body'),
        ),
      );
      await tester.pumpWidget(app(open: false));
      expect(
        find.semantics.byFlag(SemanticsFlag.hasExpandedState),
        findsOneWidget,
      );
      expect(find.semantics.byFlag(SemanticsFlag.isExpanded), findsNothing);
      await tester.pumpWidget(app(open: true));
      await tester.pumpAndSettle();
      expect(find.semantics.byFlag(SemanticsFlag.isExpanded), findsOneWidget);
      semantics.dispose();
    });
  });

  group('side sheet', () {
    testWidgets(
      'standard mode sits in the layout and its close button closes',
      (tester) async {
        var closed = false;
        await tester.pumpWidget(
          _app(
            SizedBox(
              height: 400,
              child: CamoSideSheet(
                title: 'Properties',
                onClose: () => closed = true,
                actions: const Text('Apply'),
                child: const Text('size'),
              ),
            ),
          ),
        );
        expect(find.text('Properties'), findsOneWidget);
        expect(find.text('size'), findsOneWidget);
        expect(find.text('Apply'), findsOneWidget);
        await tester.tap(find.text('close'));
        expect(closed, isTrue);
      },
    );

    testWidgets('modal: a drag toward the end edge asks to close', (
      tester,
    ) async {
      var requests = 0;
      await tester.pumpWidget(
        _app(
          CamoModalSideSheet(
            open: true,
            onDismissRequest: () => requests++,
            child: const CamoSideSheet(child: Text('size')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.text('size'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(requests, 0);
      await tester.drag(find.text('size'), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(requests, greaterThan(0));
    });

    testWidgets('modal in RTL slides the other way', (tester) async {
      var requests = 0;
      await tester.pumpWidget(
        _app(
          CamoModalSideSheet(
            open: true,
            onDismissRequest: () => requests++,
            child: const CamoSideSheet(child: Text('size')),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.text('size'), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(requests, 0);
      await tester.drag(find.text('size'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(requests, greaterThan(0));
    });

    testWidgets('a modal drawer closes on a drag toward the start edge', (
      tester,
    ) async {
      var requests = 0;
      await tester.pumpWidget(
        _app(
          CamoModalDrawer(
            open: true,
            onDismissRequest: () => requests++,
            child: CamoNavigationDrawer<String>(
              sections: const [
                CamoNavSection(
                  items: [
                    CamoNavItem(
                      value: 'a',
                      label: 'Inbox',
                      icon: SizedBox.square(dimension: 8),
                    ),
                  ],
                ),
              ],
              selected: 'a',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.text('Inbox'), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(requests, 0);
      await tester.drag(find.text('Inbox'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(requests, greaterThan(0));
    });
  });
}
