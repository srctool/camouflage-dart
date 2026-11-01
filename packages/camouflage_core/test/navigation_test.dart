import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'navigation_test_renderers.dart';
import 'test_skins.dart';

// The M8 tabs and FAB tests from their Flutter notes.

Widget _app(Widget child, {CamoTheme? theme}) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  builder: (context, _) => CamouflageProvider(
    skin: skinA,
    theme: theme ?? themeT,
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

const _tabs = [
  CamoTab('a', label: 'Overview'),
  CamoTab('b', label: 'Reviews'),
  CamoTab('c', label: 'Specs'),
];

void main() {
  group('tabs', () {
    testWidgets('a tap selects and the indicator moves', (tester) async {
      var selected = 'a';
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 600,
              child: CamoTabs<String>(
                selected: selected,
                onChanged: (v) => setState(() => selected = v),
                tabs: _tabs,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final first = lastIndicator;
      expect(first, isNotNull);
      await tester.tap(find.text('Reviews'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
      expect(lastIndicator!.start, greaterThan(first!.start));
    });

    testWidgets('tabs have tab semantics and the selected one says so', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 600,
            child: CamoTabs<String>(
              selected: 'b',
              onChanged: (_) {},
              tabs: _tabs,
            ),
          ),
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Reviews'))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected.name, 'isTrue');
      expect(data.role, SemanticsRole.tab);
      semantics.dispose();
    });

    testWidgets('onChanged: null disables the bar', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 600,
            child: CamoTabs<String>(
              selected: 'a',
              onChanged: null,
              tabs: _tabs,
            ),
          ),
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Reviews'))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled.name, 'isFalse');
      semantics.dispose();
    });

    testWidgets('a disabled tab does not select', (tester) async {
      var selected = 'a';
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 600,
              child: CamoTabs<String>(
                selected: selected,
                onChanged: (v) => setState(() => selected = v),
                tabs: const [
                  CamoTab('a', label: 'One'),
                  CamoTab('b', label: 'Two', enabled: false),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Two'));
      expect(selected, 'a');
    });

    testWidgets('a selection not in the tabs draws no indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 600,
            child: CamoTabs<String>(
              selected: 'zzz',
              onChanged: (_) {},
              tabs: _tabs,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(lastIndicator, isNull);
    });

    testWidgets('a scrollable bar keeps the selected tab visible', (
      tester,
    ) async {
      final tabs = [for (var i = 0; i < 12; i++) CamoTab(i, label: 'Tab $i')];
      var selected = 0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 200,
              child: CamoTabs<int>(
                selected: selected,
                onChanged: (v) => setState(() => selected = v),
                tabs: tabs,
                scrollable: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Tab 11')).dx, greaterThan(200));
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 200,
            child: CamoTabs<int>(
              selected: 11,
              onChanged: (_) {},
              tabs: tabs,
              scrollable: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Tab 11')).dx, lessThan(200));
    });

    testWidgets('a page view and the tabs stay in sync', (tester) async {
      final controller = PageController();
      late CamoTabsPageSync<String> sync;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              sync = CamoTabsPageSync<String>(
                pageController: controller,
                tabs: _tabs,
              );
              return SizedBox(
                width: 600,
                height: 200,
                child: Column(
                  children: [
                    ListenableBuilder(
                      listenable: sync,
                      builder: (context, _) => CamoTabs<String>(
                        selected: sync.selected,
                        onChanged: sync.select,
                        tabs: _tabs,
                        position: sync,
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: controller,
                        children: [
                          for (final t in _tabs) Text('page ${t.label}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(sync.selected, 'a');
      await tester.tap(find.text('Specs'));
      await tester.pumpAndSettle();
      expect(controller.page, 2);
      expect(sync.selected, 'c');
      await tester.drag(find.byType(PageView), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(sync.selected, 'b');
      sync.dispose();
      controller.dispose();
    });
  });

  group('fab', () {
    testWidgets('it names itself from its text or its label', (tester) async {
      final semantics = tester.ensureSemantics();
      Widget fab({required bool expanded}) => _app(
        CamoFab(
          icon: const SizedBox.square(dimension: 24),
          semanticLabel: 'Compose message',
          onPressed: () {},
          text: 'Compose',
          expanded: expanded,
        ),
      );
      await tester.pumpWidget(fab(expanded: true));
      expect(find.bySemanticsLabel('Compose'), findsOneWidget);
      await tester.pumpWidget(fab(expanded: false));
      expect(find.bySemanticsLabel('Compose'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a hidden fab cannot be tapped, focused or read', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      Widget fab({required bool visible}) => _app(
        CamoFab(
          icon: const SizedBox.square(dimension: 24),
          semanticLabel: 'Add',
          onPressed: () => taps++,
          visible: visible,
        ),
      );
      await tester.pumpWidget(fab(visible: true));
      await tester.tap(find.byType(CamoFab));
      expect(taps, 1);
      await tester.pumpWidget(fab(visible: false));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CamoFab), warnIfMissed: false);
      expect(taps, 1);
      expect(find.bySemanticsLabel('Add'), findsNothing);
      semantics.dispose();
    });

    testWidgets('onPressed: null disables it', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const CamoFab(
            icon: SizedBox.square(dimension: 24),
            semanticLabel: 'Add',
            onPressed: null,
          ),
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Add'))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled.name, 'isFalse');
      semantics.dispose();
    });

    testWidgets('the small fab keeps a 48 target', (tester) async {
      final theme = themeT.copyWith(
        components: const CamoComponentThemes(
          fab: CamoFabTheme(size: FabSize.small),
        ),
      );
      await tester.pumpWidget(
        _app(
          CamoFab(
            icon: const SizedBox.square(dimension: 24),
            semanticLabel: 'Add',
            onPressed: () {},
          ),
          theme: theme,
        ),
      );
      final size = tester.getSize(find.byType(CamoTouchTarget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
