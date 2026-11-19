import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// Fuzzy scoring and the command palette (base CamoCommandPalette, M16).

Widget _app(Widget child) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: Directionality(
    textDirection: TextDirection.ltr,
    child: CamouflageProvider(
      skin: skinA,
      theme: themeT,
      child: Align(alignment: Alignment.topLeft, child: child),
    ),
  ),
);

int? _score(String q, String t) => CamoMatcher.score(q, t)?.score;

void main() {
  group('CamoMatcher.score', () {
    test('a prefix beats a substring beats a hump beats a scattered match', () {
      final prefix = _score('open', 'Open File')!;
      final substring = _score('file', 'Open File')!;
      final hump = _score('of', 'Open File')!;
      final scattered = _score('ofl', 'Open File')!;
      expect(prefix, greaterThan(substring));
      expect(substring, greaterThan(hump));
      expect(hump, greaterThan(scattered));
    });

    test('consecutive letters and a shorter text score higher', () {
      expect(
        _score('fl', 'featureLogin')!,
        greaterThan(_score('fl', 'fooxxxlogin')!),
      );
      expect(
        _score('log', 'Login')!,
        greaterThan(_score('log', 'Login with a very long description')!),
      );
    });

    test('no match is null and an empty query scores zero', () {
      expect(CamoMatcher.score('xyz', 'Open File'), isNull);
      expect(CamoMatcher.score('', 'anything')!.score, 0);
    });

    test('the ranges are the highlight', () {
      expect(CamoMatcher.score('of', 'Open File')!.ranges, const [
        MatchRange(0, 1),
        MatchRange(5, 6),
      ]);
    });
  });

  group('sources and state', () {
    CamoCommandItem item(String t, [String? shortcut]) =>
        CamoCommandItem(id: t, title: t, onSelect: () {}, shortcut: shortcut);

    test(
      'a source keeps the best few, an empty query lists the first',
      () async {
        final source = CamoCommandSource.of(
          title: 'Actions',
          items: [
            for (final t in [
              'Open File',
              'Close File',
              'File: Save',
              'Profile',
              'Reopen Closed',
            ])
              item(t),
          ],
          limit: 3,
        );
        final found = [for (final i in await source.search('file')) i.title];
        expect(found.length, 3);
        expect(found.first, 'File: Save');
        expect(
          [for (final i in await source.search('')) i.title],
          ['Open File', 'Close File', 'File: Save'],
        );
      },
    );

    test('ten thousand items rank quickly', () async {
      final source = CamoCommandSource.of(
        title: 'Files',
        items: [
          for (var i = 0; i < 10000; i++)
            item('module$i/src/featureLogin$i.kt'),
        ],
      );
      await source.search('fLog9');
      final watch = Stopwatch()..start();
      final found = await source.search('fLog9');
      expect(found.length, 8);
      expect(watch.elapsedMilliseconds, lessThan(2000));
    });

    test('the state remembers the most recent first and round-trips', () {
      final state = CamoCommandPaletteState(maxRecent: 3);
      for (final id in ['a', 'b', 'c', 'b', 'd']) {
        state.remember(id);
      }
      expect(state.recent, ['d', 'b', 'c']);
      expect(
        CamoCommandPaletteState(recent: state.snapshot()).recent,
        state.recent,
      );
    });

    test('show resets the query and toggle flips', () {
      final state = CamoCommandPaletteState()..query = 'old';
      state.toggle();
      expect(state.open, isTrue);
      expect(state.query, '');
      state.toggle();
      expect(state.open, isFalse);
    });
  });

  group('CamoCommandPalette', () {
    final ran = <String>[];

    CamoCommandItem item(String t, [String? shortcut]) => CamoCommandItem(
      id: t,
      title: t,
      onSelect: () => ran.add(t),
      shortcut: shortcut,
    );

    final actions = CamoCommandSource.of(
      title: 'Actions',
      items: [
        item('Open File', 'Ctrl+O'),
        item('Close File'),
        item('Toggle Theme'),
      ],
    );
    final files = CamoCommandSource.of(
      title: 'Files',
      items: [item('README.md'), item('build.gradle.kts')],
    );

    setUp(ran.clear);

    testWidgets(
      'hidden until opened, then groups every source with shortcut hints',
      (tester) async {
        final state = CamoCommandPaletteState();
        await tester.pumpWidget(
          _app(CamoCommandPalette(state: state, sources: [actions, files])),
        );
        expect(find.text('Open File'), findsNothing);
        state.show();
        await tester.pumpAndSettle();
        for (final t in [
          'Actions',
          'Files',
          'Open File',
          'Ctrl+O',
          'README.md',
        ]) {
          expect(find.text(t), findsWidgets, reason: t);
        }
      },
    );

    testWidgets('typing filters and Enter runs the active row after closing', (
      tester,
    ) async {
      final state = CamoCommandPaletteState();
      await tester.pumpWidget(
        _app(CamoCommandPalette(state: state, sources: [actions, files])),
      );
      state.show();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'clo');
      await tester.pumpAndSettle();
      expect(find.text('Close File'), findsOneWidget);
      expect(find.text('Toggle Theme'), findsNothing);
      expect(find.text('README.md'), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(ran, ['Close File']);
      expect(state.open, isFalse);
      expect(state.recent, ['Close File']);
      expect(find.text('Close File'), findsNothing);
    });

    testWidgets('arrows move the active row and Tab jumps to the next group', (
      tester,
    ) async {
      final state = CamoCommandPaletteState();
      await tester.pumpWidget(
        _app(CamoCommandPalette(state: state, sources: [actions, files])),
      );
      state.show();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(ran, ['Close File']);
      state.show();
      await tester.pumpAndSettle();
      // Close File is a recent now: it leads its group.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(ran, ['Close File', 'README.md']);
    });

    testWidgets(
      'Esc closes and a slow source shows a loading row while the others answer',
      (tester) async {
        final state = CamoCommandPaletteState();
        final slow = CamoCommandSource(
          title: 'Symbols',
          search: (q) =>
              Future.delayed(const Duration(seconds: 60), () => [item('Late')]),
        );
        await tester.pumpWidget(
          _app(CamoCommandPalette(state: state, sources: [actions, slow])),
        );
        state.show();
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.text('Open File'), findsOneWidget);
        expect(find.text('Symbols'), findsOneWidget);
        expect(find.text('Loading…'), findsOneWidget);
        expect(find.text('Late'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle(const Duration(seconds: 61));
        expect(state.open, isFalse);
        expect(find.text('Open File'), findsNothing);
      },
    );

    testWidgets('no matches shows one row', (tester) async {
      final state = CamoCommandPaletteState();
      await tester.pumpWidget(
        _app(CamoCommandPalette(state: state, sources: [actions, files])),
      );
      state.show();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('No results'), findsOneWidget);
    });
  });
}
