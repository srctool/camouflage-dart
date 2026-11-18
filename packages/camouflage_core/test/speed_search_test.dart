import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// Speed search (base CamoSpeedSearch, M16).

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

List<MatchRange>? _m(String q, String t, [MatchKind k = MatchKind.auto]) =>
    CamoMatcher.match(q, t, kind: k);

final _tree = [
  const CamoTreeNode<String>(
    id: 'docs',
    value: 'Documents',
    children: [
      CamoTreeNode<String>(id: 'cv', value: 'CV'),
      CamoTreeNode<String>(
        id: 'notes',
        value: 'Notes',
        children: [CamoTreeNode<String>(id: 'n1', value: 'Note 1')],
      ),
    ],
  ),
  const CamoTreeNode<String>(
    id: 'pics',
    value: 'Pictures',
    children: [CamoTreeNode<String>(id: 'p1', value: 'Photo')],
  ),
  const CamoTreeNode<String>(id: 'readme', value: 'Readme'),
];

Widget _treeWidget(CamoSpeedSearchState state) => SizedBox(
  width: 400,
  height: 300,
  child: CamoTree<String>(
    roots: _tree,
    expanded: const {},
    onExpandedChanged: (_) {},
    selected: const {},
    onSelectedChanged: (_) {},
    label: (v) => v,
    semanticLabel: 'Files',
    speedSearch: state,
  ),
);

void main() {
  group('CamoMatcher', () {
    test('an empty query matches everything with no ranges', () {
      expect(_m('', 'x'), isEmpty);
    });

    test('prefix, then substring, then camel humps', () {
      expect(_m('fea', 'featureLogin'), [const MatchRange(0, 3)]);
      expect(_m('login', 'featureLogin'), [const MatchRange(7, 12)]);
      expect(_m('fLog', 'featureLogin'), [
        const MatchRange(0, 1),
        const MatchRange(7, 10),
      ]);
      expect(_m('fLx', 'featureLogin'), isNull);
    });

    test('case and accents are ignored', () {
      expect(_m('zur', 'Zürich'), [const MatchRange(0, 3)]);
      expect(_m('ZÜR', 'zurich'), [const MatchRange(0, 3)]);
    });

    test('fuzzy finds the letters in order; the kinds are strict', () {
      expect(_m('fln', 'featureLogin', MatchKind.fuzzy), [
        const MatchRange(0, 1),
        const MatchRange(7, 8),
        const MatchRange(11, 12),
      ]);
      expect(_m('nlf', 'featureLogin', MatchKind.fuzzy), isNull);
      expect(_m('login', 'featureLogin', MatchKind.prefix), isNull);
      expect(_m('fLog', 'featureLogin', MatchKind.substring), isNull);
    });

    test('five thousand texts match in well under a frame', () {
      final texts = [
        for (var i = 0; i < 5000; i++) 'module$i/src/featureLogin$i.dart',
      ];
      texts.where((t) => _m('fLog9', t) != null).length;
      final watch = Stopwatch()..start();
      texts.where((t) => _m('fLog9', t) != null).length;
      expect(watch.elapsedMilliseconds, lessThan(150));
    });
  });

  group('CamoSpeedSearchState', () {
    test('types, backs up, clears and matches by its kind', () {
      final s = CamoSpeedSearchState(kind: MatchKind.substring);
      expect(s.matches('anything'), isTrue);
      s
        ..type('og')
        ..type('i');
      expect(s.query, 'ogi');
      expect(s.match('featureLogin'), [const MatchRange(8, 11)]);
      s.backspace();
      expect(s.query, 'og');
      s.clear();
      expect(s.active, isFalse);
    });
  });

  group('CamoTree speed search', () {
    testWidgets('filters, keeps and opens the ancestors, then clears', (
      tester,
    ) async {
      final state = CamoSpeedSearchState();
      await tester.pumpWidget(_app(_treeWidget(state)));
      state.type('note');
      await tester.pump();
      await tester.pump();
      for (final t in ['Documents', 'Notes', 'Note 1']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      for (final t in ['Pictures', 'Readme', 'CV']) {
        expect(find.text(t), findsNothing, reason: t);
      }
      expect(state.matchCount, 2);
      state.clear();
      await tester.pump();
      expect(find.text('Readme'), findsOneWidget);
      expect(find.text('Pictures'), findsOneWidget);
    });

    testWidgets('jump mode keeps every node', (tester) async {
      final state = CamoSpeedSearchState(mode: SpeedSearchMode.jump);
      await tester.pumpWidget(_app(_treeWidget(state)));
      state.type('re');
      await tester.pump();
      expect(find.text('Pictures'), findsOneWidget);
      expect(find.text('Readme'), findsOneWidget);
      expect(state.matchCount, 2);
    });

    testWidgets('the keyboard types, backs up, and Esc clears', (tester) async {
      final state = CamoSpeedSearchState();
      await tester.pumpWidget(_app(_treeWidget(state)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR, character: 'r');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyE, character: 'e');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyE);
      await tester.pump();
      expect(state.query, 're');
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(state.query, 'r');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(state.query, '');
    });
  });

  group('CamoDataTable speed search', () {
    testWidgets('filters rows by the columns that give their text', (
      tester,
    ) async {
      final state = CamoSpeedSearchState();
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 400,
            height: 300,
            child: CamoDataTable<String>(
              columns: [
                CamoColumn(
                  id: 'name',
                  header: 'Name',
                  text: (p) => p,
                  cell: (context, p) => Text(p),
                ),
              ],
              rows: const ['Ada', 'Grace', 'Linus'],
              rowKey: (p) => p,
              semanticLabel: 'People',
              speedSearch: state,
            ),
          ),
        ),
      );
      state.type('gr');
      await tester.pump();
      expect(find.text('Grace'), findsOneWidget);
      expect(find.text('Ada'), findsNothing);
      expect(state.matchCount, 1);
      state.clear();
      await tester.pump();
      expect(find.text('Ada'), findsOneWidget);
    });
  });

  group('CamoMenuAnchor speed search', () {
    testWidgets('typing filters the items and Esc clears before closing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          CamoMenuAnchor(
            speedSearch: true,
            items: [
              CamoMenuItem(text: 'Copy', onPressed: () {}),
              CamoMenuItem(text: 'Cut', onPressed: () {}),
              CamoMenuItem(text: 'Paste', onPressed: () {}),
            ],
            builder: (context, open) =>
                GestureDetector(onTap: open, child: const Text('Edit')),
          ),
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      for (final k in ['p', 'a']) {
        final key = k == 'p'
            ? LogicalKeyboardKey.keyP
            : LogicalKeyboardKey.keyA;
        await tester.sendKeyDownEvent(key, character: k);
        await tester.sendKeyUpEvent(key);
      }
      await tester.pump();
      await tester.pump();
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Copy'), findsNothing);
      expect(find.text('Cut'), findsNothing);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      // Esc cleared the search; the menu stays open.
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Cut'), findsOneWidget);
    });
  });
}
