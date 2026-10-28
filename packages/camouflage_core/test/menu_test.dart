import 'dart:ui' show CheckedState;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// CamoMenu and CamoSelect's tests from their Flutter notes.

Widget _app(Widget child, {Alignment alignment = Alignment.topLeft}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: CamouflageProvider(
        skin: skinA,
        theme: themeT,
        child: Align(alignment: alignment, child: child),
      ),
    );

List<CamoMenuEntry> _overflow(List<String> log) => [
  CamoMenuItem(text: 'Share', onPressed: () => log.add('share')),
  CamoMenuItem(
    text: 'Edit',
    onPressed: () => log.add('edit'),
    trailingText: 'Ctrl+E',
  ),
  CamoMenuItem(
    text: 'Archive',
    onPressed: () => log.add('archive'),
    enabled: false,
  ),
  const CamoMenuDivider(),
  CamoMenuItem(text: 'Delete', onPressed: () => log.add('delete')),
];

Widget _more(List<CamoMenuEntry> items) => CamoMenuAnchor(
  items: items,
  builder: (context, open) => CamoButton(text: 'More', onPressed: open),
);

SemanticsData _semantics(WidgetTester tester, String text) =>
    tester.getSemantics(find.text(text)).getSemanticsData();

bool _hasFocus(String text) {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  return find
      .descendant(
        of: find.byElementPredicate((e) => e == focused),
        matching: find.text(text),
      )
      .evaluate()
      .isNotEmpty;
}

final _sorts = [
  const SelectOption('new', 'Newest'),
  const SelectOption('old', 'Oldest'),
  const SelectOption('az', 'Name'),
];

void main() {
  testWidgets('selecting an item closes the menu, then runs its action', (
    tester,
  ) async {
    final log = <String>[];
    await tester.pumpWidget(_app(_more(_overflow(log))));
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(_semantics(tester, 'Edit').role, SemanticsRole.menuItem);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(log, ['edit']);
    expect(find.text('Share'), findsNothing);
  });

  testWidgets(
    'checkable items are checkboxes and an exclusive group has radios',
    (tester) async {
      await tester.pumpWidget(
        _app(
          _more([
            CamoMenuItem(
              text: 'Show hidden files',
              onPressed: () {},
              checked: true,
            ),
            const CamoMenuDivider(),
            CamoMenuGroup(
              exclusive: true,
              items: [
                CamoMenuItem(text: 'Newest', onPressed: () {}, checked: true),
                CamoMenuItem(text: 'Oldest', onPressed: () {}, checked: false),
              ],
            ),
          ]),
        ),
      );
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      final hidden = _semantics(tester, 'Show hidden files');
      expect(hidden.role, SemanticsRole.menuItemCheckbox);
      expect(hidden.flagsCollection.isChecked, CheckedState.isTrue);
      final newest = _semantics(tester, 'Newest');
      expect(newest.role, SemanticsRole.menuItemRadio);
      expect(newest.flagsCollection.isChecked, CheckedState.isTrue);
      expect(newest.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(
        _semantics(tester, 'Oldest').flagsCollection.isChecked,
        CheckedState.isFalse,
      );
    },
  );

  testWidgets(
    'keys move focus, jump and type ahead, and Esc returns to the anchor',
    (tester) async {
      await tester.pumpWidget(_app(_more(_overflow([]))));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_hasFocus('More'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_hasFocus('Share'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(_hasFocus('Delete'), isTrue);
      // The disabled item is skipped; "e" finds Edit.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.pump();
      expect(_hasFocus('Edit'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_hasFocus('Delete'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsNothing);
      expect(_hasFocus('More'), isTrue);
    },
  );

  testWidgets('the menu opens below its anchor, above it near the bottom', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_more(_overflow([]))));
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Share')).dy,
      greaterThan(tester.getTopLeft(find.text('More')).dy),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _app(_more(_overflow([])), alignment: Alignment.bottomLeft),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Share')).dy,
      lessThan(tester.getTopLeft(find.text('More')).dy),
    );
  });

  testWidgets(
    'a context menu opens on right-click and on long press, without pressing the content',
    (tester) async {
      final log = <String>[];
      var presses = 0;
      await tester.pumpWidget(
        _app(
          CamoContextMenuArea(
            items: _overflow(log),
            child: GestureDetector(
              onTap: () => presses++,
              child: const SizedBox(width: 200, height: 60, child: Text('Row')),
            ),
          ),
        ),
      );
      await tester.tap(
        find.text('Row'),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Row'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(log, ['share', 'delete']);
      expect(presses, 0);
    },
  );

  testWidgets('a short select on a wide window is a menu, picking sets it', (
    tester,
  ) async {
    String? value = 'new';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 300,
            child: CamoSelect<String>(
              value: value,
              onChanged: (v) => setState(() => value = v),
              options: _sorts,
              label: 'Sort by',
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Newest'));
    await tester.pumpAndSettle();
    expect(_semantics(tester, 'Oldest').role, SemanticsRole.menuItemRadio);
    await tester.tap(find.text('Oldest'));
    await tester.pumpAndSettle();
    expect(value, 'old');
    expect(find.text('Name'), findsNothing);
  });

  testWidgets('a narrow window opens a sheet, and Esc keeps the value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? value = 'new';
    await tester.pumpWidget(
      _app(
        CamoSelect<String>(
          value: value,
          onChanged: (v) => value = v,
          options: _sorts,
          label: 'Sort by',
        ),
      ),
    );
    await tester.tap(find.text('Newest'));
    await tester.pumpAndSettle();
    expect(find.text('Name'), findsOneWidget);
    expect(
      _semantics(tester, 'Name').role,
      isNot(SemanticsRole.menuItemRadio),
      reason: 'a sheet of list rows, not a menu',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(value, 'new');
    expect(find.text('Name'), findsNothing);
  });

  testWidgets('a searchable select filters ignoring case and accents', (
    tester,
  ) async {
    final cities = [
      for (final c in ['Zürich', 'Bern', 'Genève', 'Basel']) SelectOption(c, c),
    ];
    String? value;
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 300,
          child: CamoSelect<String>(
            value: value,
            onChanged: (v) => value = v,
            options: cities,
            label: 'City',
            placeholder: 'Pick a city',
            searchable: true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pick a city'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'zur');
    await tester.pumpAndSettle();
    expect(find.text('Bern'), findsNothing);
    await tester.tap(find.text('Zürich'));
    await tester.pumpAndSettle();
    expect(value, 'Zürich');
  });

  testWidgets(
    'an async select calls onOpen once per opening and debounces the query',
    (tester) async {
      var opens = 0;
      final queries = <String>[];
      int? value;
      final page = CamoPagedListState(
        items: [for (var i = 1; i <= 3; i++) SelectOption(i, 'City $i')],
        endReached: true,
      );
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 300,
              child: CamoAsyncSelect<int>(
                value: value,
                onChanged: (v) => setState(() => value = v),
                options: page,
                onOpen: () => opens++,
                onQueryChanged: queries.add,
                onLoadMore: () {},
                onRetry: () {},
                selectedLabel: value == null ? null : 'City $value',
                placeholder: 'Pick a city',
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick a city'));
      await tester.pumpAndSettle();
      expect(opens, 1);
      await tester.enterText(find.byType(EditableText), 'Ba');
      await tester.pump(const Duration(milliseconds: 200));
      expect(queries, isEmpty);
      await tester.pump(const Duration(milliseconds: 400));
      expect(queries, ['Ba']);
      await tester.tap(find.text('City 2'));
      await tester.pumpAndSettle();
      expect(value, 2);
      await tester.tap(find.text('City 2'));
      await tester.pumpAndSettle();
      expect(opens, 2);
    },
  );

  testWidgets('an async select shows options that arrive after it opens', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SizedBox(width: 300, child: _Loader())));
    await tester.tap(find.text('Pick a city'));
    await tester.pumpAndSettle();
    expect(find.text('City 1'), findsOneWidget);
  });
}

// An app that loads its options when the sheet opens, the way a repository does.
class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  var _state = const CamoPagedListState<SelectOption<int>>();

  Future<void> _load() async {
    setState(
      () => _state = const CamoPagedListState(loading: PagedLoad.initial),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    setState(
      () => _state = const CamoPagedListState(
        items: [SelectOption(1, 'City 1')],
        endReached: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CamoAsyncSelect<int>(
    value: null,
    onChanged: (_) {},
    options: _state,
    onOpen: _load,
    onQueryChanged: (_) {},
    onLoadMore: () {},
    onRetry: () {},
    selectedLabel: null,
    placeholder: 'Pick a city',
  );
}
