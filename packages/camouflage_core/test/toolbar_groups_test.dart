import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/toolbar/camo_toolbar.dart' as toolbar;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'action_test_renderers.dart';
import 'test_skins.dart';

// The M9 button group, split button and toolbar tests from their Flutter notes.

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

CamoToolbarAction _action(
  String label,
  List<String> log, {
  bool? selected,
  bool enabled = true,
}) => CamoToolbarAction(
  id: label,
  label: label,
  icon: Text(label.substring(0, 1)),
  onPressed: () => log.add(label),
  enabled: enabled,
  selected: selected,
);

bool _focused(WidgetTester tester, Finder finder) =>
    Focus.of(tester.element(finder)).hasFocus;

void main() {
  group('button group', () {
    testWidgets('its buttons run their commands', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          CamoButtonGroup(
            buttons: [
              for (final t in ['Cut', 'Copy', 'Paste'])
                CamoGroupButton(id: t, text: t, onPressed: () => log.add(t)),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Copy'));
      await tester.tap(find.text('Paste'));
      expect(log, ['Copy', 'Paste']);
    });

    testWidgets('a toggle keeps the app\'s selected state', (tester) async {
      var bold = false;
      late StateSetter set;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return CamoButtonGroup(
                buttons: [
                  CamoGroupButton(
                    id: 'b',
                    text: 'Bold',
                    selected: bold,
                    onPressed: () => set(() => bold = !bold),
                  ),
                  CamoGroupButton(
                    id: 'i',
                    text: 'Italic',
                    selected: false,
                    onPressed: () {},
                  ),
                ],
              );
            },
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Bold')),
        isSemantics(hasToggledState: true, isToggled: false),
      );
      await tester.tap(find.text('Bold'));
      await tester.pump();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Bold')),
        isSemantics(hasToggledState: true, isToggled: true),
      );
      expect(groupButtons[0]?.selected, isTrue);
    });

    testWidgets('each button knows its position in the group', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoButtonGroup(
            buttons: [
              for (final t in ['A', 'B', 'C'])
                CamoGroupButton(id: t, text: t, onPressed: () {}),
            ],
          ),
        ),
      );
      expect(
        [for (var i = 0; i < 3; i++) groupButtons[i]!.position.isFirst],
        [true, false, false],
      );
      expect(
        [for (var i = 0; i < 3; i++) groupButtons[i]!.position.isLast],
        [false, false, true],
      );
      expect(groupButtons[0]!.position.count, 3);
    });

    testWidgets('arrows move between the buttons without pressing them', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          CamoButtonGroup(
            buttons: [
              CamoGroupButton(
                id: 'a',
                text: 'A',
                onPressed: () => log.add('a'),
              ),
              CamoGroupButton(
                id: 'b',
                text: 'B',
                enabled: false,
                onPressed: () => log.add('b'),
              ),
              CamoGroupButton(
                id: 'c',
                text: 'C',
                onPressed: () => log.add('c'),
              ),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focused(tester, find.text('A')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focused(tester, find.text('C')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focused(tester, find.text('A')), isTrue);
      expect(log, isEmpty);
    });

    testWidgets('a disabled group presses nothing', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          CamoButtonGroup(
            enabled: false,
            buttons: [
              CamoGroupButton(id: 'a', text: 'A', onPressed: () => pressed++),
            ],
          ),
        ),
      );
      await tester.tap(find.text('A'));
      expect(pressed, 0);
      expect(groupButtons[0]!.enabled, isFalse);
    });

    testWidgets('an icon-only button needs a semantic label', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoButtonGroup(
            buttons: [
              CamoGroupButton(
                id: 'a',
                icon: const SizedBox.square(dimension: 8),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNotNull);
    });
  });

  group('split button', () {
    const menu = [
      CamoMenuItem(text: 'Save as', onPressed: _noop),
      CamoMenuItem(text: 'Save a copy', onPressed: _noop),
    ];

    testWidgets('the main part runs the action, the arrow opens the menu', (
      tester,
    ) async {
      var saved = 0;
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          CamoSplitButton(
            text: 'Save',
            onPressed: () => saved++,
            menu: [
              CamoMenuItem(text: 'Save as', onPressed: () => log.add('as')),
            ],
          ),
        ),
      );
      expect(find.text('Save as'), findsNothing);
      await tester.tap(find.text('Save'));
      expect(saved, 1);
      await tester.tap(find.bySemanticsLabel('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save as'));
      await tester.pumpAndSettle();
      expect(log, ['as']);
      expect(saved, 1);
    });

    testWidgets('a menu button opens its menu from the whole button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const CamoSplitButton(
            text: 'Sort',
            onPressed: null,
            menu: [CamoMenuItem(text: 'Newest', onPressed: _noop)],
          ),
        ),
      );
      expect(lastSplit!.hasAction, isFalse);
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      expect(find.text('Newest'), findsOneWidget);
    });

    testWidgets('the arrow announces whether the menu is open', (tester) async {
      await tester.pumpWidget(
        _app(CamoSplitButton(text: 'Save', onPressed: () {}, menu: menu)),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('More options')),
        isSemantics(hasExpandedState: true, isExpanded: false),
      );
      await tester.tap(find.bySemanticsLabel('More options'));
      await tester.pumpAndSettle();
      // The open menu's route hides the page behind it from screen readers, so the state is read from the skin.
      expect(lastSplit!.expanded, isTrue);
    });

    testWidgets('Down on the main part opens the menu', (tester) async {
      await tester.pumpWidget(
        _app(CamoSplitButton(text: 'Save', onPressed: () {}, menu: menu)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Save a copy'), findsOneWidget);
    });

    testWidgets('a disabled split button presses nothing', (tester) async {
      var saved = 0;
      await tester.pumpWidget(
        _app(
          CamoSplitButton(
            text: 'Save',
            enabled: false,
            onPressed: () => saved++,
            menu: menu,
          ),
        ),
      );
      await tester.tap(find.text('Save'));
      await tester.tap(find.bySemanticsLabel('More options'));
      await tester.pumpAndSettle();
      expect(saved, 0);
      expect(find.text('Save as'), findsNothing);
    });
  });

  group('toolbar', () {
    test(
      'fitting keeps all actions when they fit, else leaves room for more',
      () {
        expect(toolbar.fitActions(5, 5 * 48 + 4 * 4, 48, 4), 5);
        // One short of all five: four actions would leave no room for the overflow button, so three show.
        expect(toolbar.fitActions(5, 5 * 48 + 4 * 4 - 1, 48, 4), 3);
        expect(toolbar.fitActions(3, 10, 48, 4), 0);
        expect(toolbar.fitActions(0, 100, 48, 4), 0);
      },
    );

    testWidgets('actions that do not fit move into the overflow and back', (
      tester,
    ) async {
      final log = <String>[];
      var width = 400.0;
      late StateSetter set;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return SizedBox(
                width: width,
                child: CamoToolbar(
                  actions: [
                    for (final l in ['Bold', 'Italic', 'Link', 'Quote'])
                      _action(l, log),
                  ],
                ),
              );
            },
          ),
        ),
      );
      expect(find.bySemanticsLabel('Quote'), findsOneWidget);
      expect(find.bySemanticsLabel('More'), findsNothing);
      set(() => width = 130);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Bold'), findsOneWidget);
      expect(find.bySemanticsLabel('Quote'), findsNothing);
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quote'));
      await tester.pumpAndSettle();
      expect(log, ['Quote']);
      set(() => width = 400);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Quote'), findsOneWidget);
      expect(find.bySemanticsLabel('More'), findsNothing);
    });

    testWidgets('a toggle keeps its state in the toolbar and the overflow', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 60,
            child: CamoToolbar(
              actions: [
                _action('Bold', log, selected: true),
                _action('Italic', log, selected: false),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      expect(find.text('Bold'), findsOneWidget);
      expect(find.text('Italic'), findsOneWidget);
    });

    testWidgets('arrows move between the actions and skip a disabled one', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          CamoToolbar(
            actions: [
              _action('Bold', log),
              _action('Italic', log, enabled: false),
              _action('Link', log),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focused(tester, find.text('B')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focused(tester, find.text('L')), isTrue);
      expect(log, isEmpty);
    });

    testWidgets('leading and trailing content always show', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 150,
            child: CamoToolbar(
              actions: [
                for (final l in ['Bold', 'Italic', 'Link']) _action(l, []),
              ],
              leading: const Text('Menu'),
              trailing: const Text('Send'),
            ),
          ),
        ),
      );
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.bySemanticsLabel('More'), findsOneWidget);
    });

    testWidgets('a floating toolbar asks the skin for the floating placement', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          CamoToolbar(
            placement: ToolbarPlacement.floating,
            actions: [_action('Bold', [])],
          ),
        ),
      );
      expect(lastToolbar!.placement, ToolbarPlacement.floating);
      expect(lastToolbar!.count, 1);
    });

    testWidgets('the toolbar container holds custom content', (tester) async {
      await tester.pumpWidget(
        _app(
          const CamoToolbarContainer(
            semanticLabel: 'Formatting',
            child: Text('custom'),
          ),
        ),
      );
      expect(find.text('custom'), findsOneWidget);
      expect(find.bySemanticsLabel('Formatting'), findsOneWidget);
    });
  });
}

void _noop() {}
