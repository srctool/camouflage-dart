import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// CamoSplitPane (base Split Pane, M16): sizes from fractions, drag, keys, collapse, screen reader, RTL, snapshots.

// The direction wraps the Navigator, so any route has it too.
Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      builder: (context, app) =>
          Directionality(textDirection: direction, child: app!),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: CamouflageProvider(
        skin: skinA,
        theme: themeT,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

CamoPane _pane(String key, {double min = 50, bool collapsible = false}) =>
    CamoPane(
      minSize: min,
      collapsible: collapsible,
      child: SizedBox.expand(key: ValueKey(key)),
    );

Widget _three(
  CamoSplitState state, {
  double length = 800,
  Axis axis = Axis.horizontal,
}) => SizedBox(
  width: axis == Axis.horizontal ? length : 200,
  height: axis == Axis.horizontal ? 200 : length,
  child: CamoSplitPane(
    axis: axis,
    state: state,
    panes: [_pane('a'), _pane('b'), _pane('c', collapsible: true)],
  ),
);

double _width(WidgetTester tester, String key) =>
    tester.getSize(find.byKey(ValueKey(key))).width;

double _height(WidgetTester tester, String key) =>
    tester.getSize(find.byKey(ValueKey(key))).height;

Finder get _dividers =>
    find.byWidgetPredicate((w) => w.runtimeType.toString() == '_SplitDivider');

Future<void> _focus(WidgetTester tester, int index) async {
  final inner = find.descendant(
    of: _dividers.at(index),
    matching: find.byType(MouseRegion),
  );
  Focus.of(tester.element(inner.first)).requestFocus();
  await tester.pump();
}

void main() {
  testWidgets('panes get their fractions of the container less the dividers', (
    tester,
  ) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state)));
    expect(_width(tester, 'a'), closeTo(199, 1));
    expect(_width(tester, 'b'), closeTo(199, 1));
    expect(_width(tester, 'c'), closeTo(398, 1));
  });

  testWidgets('a vertical split stacks the panes', (tester) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(
      _app(_three(state, length: 400, axis: Axis.vertical)),
    );
    expect(_height(tester, 'a'), closeTo(99, 1));
    expect(_height(tester, 'c'), closeTo(198, 1));
  });

  testWidgets('dragging a divider moves space between its neighbours only', (
    tester,
  ) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state)));
    await tester.drag(_dividers.at(0), const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(state.fractions[0], greaterThan(0.3));
    expect(state.fractions[0] + state.fractions[1], closeTo(0.5, 0.001));
    expect(state.fractions[2], closeTo(0.5, 0.001));
  });

  testWidgets('arrow keys resize by the key step and Shift by the large step', (
    tester,
  ) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state)));
    await _focus(tester, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_width(tester, 'a'), closeTo(215, 1));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(_width(tester, 'a'), closeTo(151, 1));
  });

  testWidgets('Home and End go to the limits and never collapse', (
    tester,
  ) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state)));
    await _focus(tester, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_width(tester, 'c'), closeTo(50, 1));
    expect(state.collapsed, isEmpty);
  });

  testWidgets(
    'Enter collapses a collapsible pane and Enter again restores it',
    (tester) async {
      final state = CamoSplitState([1, 1, 2]);
      await tester.pumpWidget(_app(_three(state)));
      await _focus(tester, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(state.collapsed, {2});
      expect(find.byKey(const ValueKey('c')), findsNothing);
      await _focus(tester, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.byKey(const ValueKey('c')), findsOneWidget);
      expect(state.collapsed, isEmpty);
    },
  );

  testWidgets('a screen reader adjusts the divider like a slider', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state)));
    final divider = find.bySemanticsLabel('Resize panel').at(0);
    var data = tester.getSemantics(divider).getSemanticsData();
    expect(data.value, '25 percent');
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    tester.semantics.performAction(
      find.semantics.byLabel('Resize panel').first,
      SemanticsAction.increase,
    );
    await tester.pump();
    data = tester.getSemantics(divider).getSemanticsData();
    expect(state.fractions[0], greaterThan(0.25));
    expect(data.value, isNot('25 percent'));
    handle.dispose();
  });

  testWidgets('a double tap resets the two neighbours', (tester) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state)));
    state.resize(0, 100);
    await tester.pump();
    expect(_width(tester, 'a'), closeTo(299, 1));
    final at = tester.getCenter(_dividers.at(0));
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 500));
    expect(_width(tester, 'a'), closeTo(199, 1));
  });

  testWidgets('a restored snapshot keeps its fractions on a different width', (
    tester,
  ) async {
    final state = CamoSplitState([1, 1, 1])
      ..apply(const CamoSplitSnapshot(fractions: [1, 2, 1], collapsed: {}));
    await tester.pumpWidget(_app(_three(state, length: 400)));
    expect(_width(tester, 'a'), closeTo(99, 1));
    expect(_width(tester, 'b'), closeTo(198, 1));
  });

  testWidgets('right to left puts the first pane on the right', (tester) async {
    final state = CamoSplitState([1, 1, 2]);
    await tester.pumpWidget(_app(_three(state), direction: TextDirection.rtl));
    final a = tester.getTopLeft(find.byKey(const ValueKey('a'))).dx;
    final c = tester.getTopLeft(find.byKey(const ValueKey('c'))).dx;
    expect(a, greaterThan(c));
    await _focus(tester, 0);
    // Right moves the divider right, which shrinks the first pane (it is on the right).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_width(tester, 'a'), closeTo(183, 1));
  });

  testWidgets('a split may be nested', (tester) async {
    final outer = CamoSplitState([1, 1]);
    final inner = CamoSplitState([1, 1]);
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 600,
          height: 400,
          child: CamoSplitPane(
            axis: Axis.horizontal,
            state: outer,
            panes: [
              _pane('left'),
              CamoPane(
                child: CamoSplitPane(
                  axis: Axis.vertical,
                  state: inner,
                  panes: [_pane('top'), _pane('bottom')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(_width(tester, 'left'), closeTo(299, 1));
    expect(_height(tester, 'top'), closeTo(199, 1));
  });

  test(
    'a state needs two positive panes and a wrong sized snapshot is ignored',
    () {
      expect(() => CamoSplitState([1]), throwsArgumentError);
      expect(() => CamoSplitState([1, 0]), throwsArgumentError);
      final state = CamoSplitState([1, 1, 2]);
      state.collapse(2);
      state.collapse(1);
      state.collapse(0);
      expect(state.collapsed, {2, 1});
      state.apply(const CamoSplitSnapshot(fractions: [1, 1], collapsed: {}));
      expect(state.fractions.length, 3);
    },
  );
}
