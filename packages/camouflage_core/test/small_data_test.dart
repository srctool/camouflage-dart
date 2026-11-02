import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/breadcrumb/camo_breadcrumb.dart' as crumbs;
import 'package:camouflage_core/src/pagination/camo_pagination.dart' as paging;
import 'package:camouflage_core/src/rating/camo_rating.dart' as stars;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'data_test_renderers.dart';
import 'test_skins.dart';

// The M10 image, rating, pagination, breadcrumb and progress steps tests from their Flutter notes.

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

bool _focused(WidgetTester tester, Finder finder) =>
    Focus.of(tester.element(finder)).hasFocus;

void main() {
  group('image', () {
    testWidgets('reports its phase', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 40,
            child: CamoImage(
              source: ImageSource.loading(),
              semanticLabel: 'Photo',
            ),
          ),
        ),
      );
      expect(lastImage!.phase, ImagePhase.loading);
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 40,
            child: CamoImage(
              source: ImageSource.loaded(ColoredBox(color: Color(0xFFFF0000))),
              semanticLabel: 'Photo',
            ),
          ),
        ),
      );
      expect(lastImage!.phase, ImagePhase.loaded);
    });

    testWidgets('a failed image keeps its description and says it failed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 40,
            child: CamoImage(
              source: ImageSource.failed(),
              semanticLabel: 'Photo',
            ),
          ),
        ),
      );
      expect(lastImage!.phase, ImagePhase.failed);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Photo')),
        isSemantics(isImage: true, value: 'Could not load'),
      );
    });

    testWidgets('a decorative image is hidden from screen readers', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 40,
            child: CamoImage(source: ImageSource.failed(), semanticLabel: null),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Photo'), findsNothing);
      expect(find.semantics.byFlag(SemanticsFlag.isImage), findsNothing);
    });
  });

  group('rating', () {
    test('maps a pointer position to a value', () {
      expect(stars.ratingValueAt(1, 100, 5, 1, rtl: false), 1);
      expect(stars.ratingValueAt(50, 100, 5, 1, rtl: false), 3);
      expect(stars.ratingValueAt(100, 100, 5, 1, rtl: false), 5);
      expect(stars.ratingValueAt(45, 100, 5, 0.5, rtl: false), 2.5);
      expect(stars.ratingValueAt(1, 100, 5, 1, rtl: true), 5);
      expect(stars.snapRating(2.2, 1, 5), 3);
      expect(stars.formatRating(3.5), '3.5');
      expect(stars.formatRating(4), '4');
    });

    testWidgets('a tap sets the value', (tester) async {
      var value = 2.0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => CamoRating(
              value: value,
              label: 'Quality',
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(CamoRating));
      await tester.tapAt(
        Offset(rect.right - rect.width * 0.05, rect.center.dy),
      );
      expect(value, 5);
    });

    testWidgets('a read-only rating announces its value and cannot change', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const CamoRating(value: 3.5, label: 'Quality')),
      );
      expect(lastRating!.interactive, isFalse);
      final node = tester.getSemantics(find.bySemanticsLabel('Quality'));
      expect(node.value, '3.5 of 5 stars');
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.increase),
        isFalse,
      );
    });

    testWidgets('arrows and the accessibility action change it by a step', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var value = 3.0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => CamoRating(
              value: value,
              label: 'Quality',
              step: RatingStep.half,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 3.5);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 5);
      // Screen readers get increase and decrease actions, which call the same handlers as the arrows.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Quality')),
        isSemantics(hasIncreaseAction: true, hasDecreaseAction: true),
      );
      handle.dispose();
    });

    testWidgets('a disabled rating is not interactive', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoRating(
            value: 3,
            label: 'Quality',
            onChanged: (_) {},
            enabled: false,
          ),
        ),
      );
      expect(lastRating!.interactive, isFalse);
      expect(lastRating!.enabled, isFalse);
    });
  });

  group('pagination', () {
    List<String> pages(int total, int page, [int siblings = 1]) => [
      for (final item in paging.pageItems(total, page, siblings))
        switch (item) {
          paging.PageItemPage(:final index) => '${index + 1}',
          paging.PageItemGap() => '…',
        },
    ];

    test('the numbered form keeps a fixed length and the ends', () {
      expect(pages(3, 0), ['1', '2', '3']);
      expect(pages(10, 0), ['1', '2', '3', '4', '5', '…', '10']);
      expect(pages(10, 4), ['1', '…', '4', '5', '6', '…', '10']);
      expect(pages(10, 9), ['1', '…', '6', '7', '8', '9', '10']);
      for (var page = 0; page < 30; page++) {
        final items = paging.pageItems(30, page, 1);
        expect(items, hasLength(7));
        expect(items, contains(const paging.PageItemPage(0)));
        expect(items, contains(const paging.PageItemPage(29)));
        expect(items, contains(paging.PageItemPage(page)));
      }
    });

    testWidgets('a page button changes the page and the arrows step', (
      tester,
    ) async {
      var page = 0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => CamoPagination(
              pageCount: 5,
              page: page,
              onPageChanged: (p) => setState(() => page = p),
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Page 3'));
      await tester.pump();
      expect(page, 2);
      await tester.tap(find.bySemanticsLabel('Next page'));
      await tester.pump();
      expect(page, 3);
    });

    testWidgets('the current page is selected and announced', (tester) async {
      await tester.pumpWidget(
        _app(CamoPagination(pageCount: 5, page: 1, onPageChanged: (_) {})),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Page 2')),
        isSemantics(isSelected: true, value: 'current page'),
      );
      expect(pageButtons[1]!.current, isTrue);
    });

    testWidgets('the compact and dots forms draw their parts', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoPagination(
            pageCount: 9,
            page: 2,
            variant: PaginationVariant.compact,
            onPageChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Page 3 of 9'), findsOneWidget);
      await tester.pumpWidget(
        _app(
          CamoPagination(
            pageCount: 4,
            page: 0,
            variant: PaginationVariant.dots,
            onPageChanged: (_) {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Page 4'), findsOneWidget);
    });

    testWidgets('one or fewer pages draw nothing', (tester) async {
      lastPagination = null;
      await tester.pumpWidget(
        _app(CamoPagination(pageCount: 1, page: 0, onPageChanged: (_) {})),
      );
      expect(lastPagination, isNull);
    });
  });

  group('breadcrumb', () {
    test('the plan keeps everything that fits and collapses the middle', () {
      const widths = [40.0, 60.0, 60.0, 60.0, 80.0];
      final all = crumbs.planBreadcrumb(widths, 10, 30, 1000, null);
      expect(all.head, 5);
      expect(all.tail, 0);
      final narrow = crumbs.planBreadcrumb(widths, 10, 30, 200, null);
      expect(narrow.head, 1);
      expect(narrow.tail, inInclusiveRange(1, 2));
      final capped = crumbs.planBreadcrumb(widths, 10, 30, 1000, 3);
      expect(capped.head, 1);
      expect(capped.tail, 2);
      expect(crumbs.planBreadcrumb([40, 60], 10, 30, 10, null).head, 2);
    });

    const trail = ['Home', 'Projects', 'Camouflage', 'Design', 'Notes'];

    testWidgets('shows every item when it fits, and links run', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 1000,
            child: CamoBreadcrumb(
              items: [
                for (final name in trail)
                  CamoBreadcrumbItem(
                    id: name,
                    label: name,
                    onPressed: () => log.add(name),
                  ),
              ],
            ),
          ),
        ),
      );
      for (final name in trail) {
        expect(find.text(name), findsOneWidget);
      }
      expect(lastBreadcrumb!.collapsed, 0);
      await tester.tap(find.text('Projects'));
      await tester.tap(find.text('Notes'));
      expect(log, ['Projects']);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Notes')),
        isSemantics(label: 'Notes', value: 'current page'),
      );
    });

    testWidgets('a narrow breadcrumb collapses the middle into a menu', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 330,
            child: CamoBreadcrumb(
              items: [
                for (final name in trail)
                  CamoBreadcrumbItem(
                    id: name,
                    label: name,
                    onPressed: () => log.add(name),
                  ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Projects'), findsNothing);
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(log, ['Projects']);
    });
  });

  group('progress steps', () {
    const wizard = ['Account', 'Shipping', 'Payment', 'Review'];

    testWidgets('derive their status from the current step', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 600,
            child: CamoProgressSteps(
              current: 1,
              steps: [for (final n in wizard) CamoStep(id: n, label: n)],
            ),
          ),
        ),
      );
      expect(
        [for (var i = 0; i < 4; i++) steps[i]!.status],
        [
          StepStatus.complete,
          StepStatus.current,
          StepStatus.upcoming,
          StepStatus.upcoming,
        ],
      );
      expect(steps[3]!.last, isTrue);
    });

    testWidgets('a step can be flagged with an error', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 600,
            child: CamoProgressSteps(
              current: 1,
              steps: [
                for (final (i, n) in wizard.indexed)
                  CamoStep(
                    id: n,
                    label: n,
                    status: i == 2 ? StepStatus.error : null,
                  ),
              ],
            ),
          ),
        ),
      );
      expect(steps[2]!.status, StepStatus.error);
    });

    testWidgets('a step announces its place and clickable ones run', (
      tester,
    ) async {
      var jumped = -1;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 600,
            child: CamoProgressSteps(
              current: 1,
              steps: [
                for (final (i, n) in wizard.indexed)
                  CamoStep(
                    id: n,
                    label: n,
                    onPressed: i < 2 ? () => jumped = i : null,
                  ),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Shipping')).value,
        'Step 2 of 4, current',
      );
      await tester.tap(find.text('Account'));
      expect(jumped, 0);
      expect(steps[0]!.clickable, isTrue);
      expect(steps[3]!.clickable, isFalse);
    });

    testWidgets('steps can run vertically', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoProgressSteps(
            current: 0,
            orientation: StepsOrientation.vertical,
            steps: [
              for (final n in wizard)
                CamoStep(id: n, label: n, description: '$n details'),
            ],
          ),
        ),
      );
      expect(steps[0]!.orientation, StepsOrientation.vertical);
      expect(find.text('Payment details'), findsOneWidget);
    });

    testWidgets('arrows move between clickable steps', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 600,
            child: CamoProgressSteps(
              current: 1,
              steps: [
                for (final (i, n) in wizard.indexed)
                  CamoStep(id: n, label: n, onPressed: i < 2 ? () {} : null),
              ],
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focused(tester, find.text('Shipping')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_focused(tester, find.text('Account')), isTrue);
    });
  });
}
