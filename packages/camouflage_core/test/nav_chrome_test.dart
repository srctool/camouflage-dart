import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'nav_chrome_test_renderers.dart';
import 'test_skins.dart';

// The M8 navigation chrome tests from their Flutter notes: bar, rail, drawer, modal drawer, adaptive layout.

const _caps = CamoCapabilities(
  backdropBlur: true,
  runtimeShaders: true,
  windowMaterial: false,
  reduceTransparency: false,
);

CamoEnvironment _env(WindowSizeClass size) => CamoEnvironment(
  windowSize: size,
  input: InputMode.touch,
  platform: CamoPlatform.android,
  capabilities: _caps,
);

Widget _app(Widget child, {WindowSizeClass size = WindowSizeClass.compact}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: CamouflageProvider(
        skin: skinA,
        theme: themeT,
        environment: _env(size),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

final _items = [
  for (final l in ['Home', 'Inbox', 'Search', 'Profile'])
    CamoNavItem<String>(
      value: l,
      label: l,
      icon: const SizedBox.square(dimension: 8),
    ),
];

void main() {
  testWidgets('a tap selects and items are tabs', (tester) async {
    final semantics = tester.ensureSemantics();
    var selected = 'Home';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 600,
            child: CamoNavigationBar<String>(
              items: _items,
              selected: selected,
              onChanged: (v) => setState(() => selected = v),
            ),
          ),
        ),
      ),
    );
    final home = tester.getSemantics(find.text('Home')).getSemanticsData();
    expect(home.flagsCollection.isSelected.name, 'isTrue');
    expect(home.role, SemanticsRole.tab);
    await tester.tap(find.text('Inbox'));
    await tester.pump();
    expect(selected, 'Inbox');
    semantics.dispose();
  });

  testWidgets('reselecting the current item calls back', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 600,
          child: CamoNavigationBar<String>(
            items: _items,
            selected: 'Home',
            onChanged: (_) => calls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Home'));
    expect(calls, 1);
  });

  testWidgets('a disabled item does not select', (tester) async {
    var selected = 'Home';
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 600,
          child: CamoNavigationBar<String>(
            items: [
              for (final i in _items)
                CamoNavItem<String>(
                  value: i.value,
                  label: i.label,
                  icon: i.icon,
                  enabled: i.value != 'Search',
                ),
            ],
            selected: selected,
            onChanged: (v) => selected = v,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Search'));
    expect(selected, 'Home');
  });

  testWidgets('the arrow keys move and select', (tester) async {
    var selected = 'Home';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 600,
            child: CamoNavigationBar<String>(
              items: _items,
              selected: selected,
              onChanged: (v) => setState(() => selected = v),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(selected, 'Inbox');
  });

  testWidgets('a hidden bar cannot be tapped, focused or read', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    Widget bar({required bool visible}) => _app(
      SizedBox(
        width: 600,
        child: CamoNavigationBar<String>(
          items: _items,
          selected: 'Home',
          onChanged: (_) => taps++,
          visible: visible,
        ),
      ),
    );
    await tester.pumpWidget(bar(visible: true));
    expect(find.semantics.byLabel('Inbox'), findsOneWidget);
    await tester.pumpWidget(bar(visible: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inbox'), warnIfMissed: false);
    expect(taps, 0);
    expect(find.semantics.byLabel('Inbox'), findsNothing);
    semantics.dispose();
  });

  testWidgets('a bar reads the system insets', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
        child: _app(
          SizedBox(
            width: 600,
            child: CamoNavigationBar<String>(
              items: _items,
              selected: 'Home',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(lastBarInsets?.bottom, 34);
  });

  testWidgets('the rail shows its header and selects', (tester) async {
    var selected = 'Home';
    await tester.pumpWidget(
      _app(
        SizedBox(
          height: 400,
          child: CamoNavigationRail<String>(
            items: _items,
            selected: selected,
            onChanged: (v) => selected = v,
            header: const Text('FAB'),
          ),
        ),
        size: WindowSizeClass.medium,
      ),
    );
    expect(find.text('FAB'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    expect(selected, 'Profile');
  });

  testWidgets('the drawer lists sections and selects', (tester) async {
    var selected = 'Home';
    await tester.pumpWidget(
      _app(
        SizedBox(
          height: 600,
          child: CamoNavigationDrawer<String>(
            sections: [
              CamoNavSection(title: 'Main', items: _items.take(2).toList()),
              CamoNavSection(title: 'More', items: _items.skip(2).toList()),
            ],
            selected: selected,
            onChanged: (v) => selected = v,
          ),
        ),
        size: WindowSizeClass.large,
      ),
    );
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
    await tester.tap(find.text('Search'));
    expect(selected, 'Search');
  });

  testWidgets('a modal drawer opens, and selecting closes it', (tester) async {
    var open = false;
    var selected = 'Home';
    late StateSetter set;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return CamoModalDrawer(
              open: open,
              onDismissRequest: () => setState(() => open = false),
              child: CamoNavigationDrawer<String>(
                sections: [CamoNavSection(items: _items)],
                selected: selected,
                onChanged: (v) => selected = v,
              ),
            );
          },
        ),
      ),
    );
    expect(find.text('Inbox'), findsNothing);
    set(() => open = true);
    await tester.pumpAndSettle();
    expect(find.text('Inbox'), findsOneWidget);
    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(selected, 'Inbox');
    expect(open, isFalse);
    expect(find.text('Inbox'), findsNothing);
  });

  testWidgets('Esc closes a modal drawer', (tester) async {
    var open = true;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => CamoModalDrawer(
            open: open,
            onDismissRequest: () => setState(() => open = false),
            child: CamoNavigationDrawer<String>(
              sections: [CamoNavSection(items: _items)],
              selected: 'Home',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Inbox'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(open, isFalse);
  });

  testWidgets('the adaptive layout switches and keeps the screen state', (
    tester,
  ) async {
    Widget layout(WindowSizeClass size) => _app(
      SizedBox(
        width: 1000,
        height: 600,
        child: CamoAdaptiveNavigation<String>(
          items: _items,
          selected: 'Home',
          onChanged: (_) {},
          header: const Text('HEADER'),
          child: const _Counter(),
        ),
      ),
      size: size,
    );
    await tester.pumpWidget(layout(WindowSizeClass.compact));
    expect(find.text('HEADER'), findsNothing);
    await tester.tap(find.text('count 0'));
    await tester.pump();
    expect(find.text('count 1'), findsOneWidget);
    await tester.pumpWidget(layout(WindowSizeClass.medium));
    expect(find.text('HEADER'), findsOneWidget);
    expect(find.text('count 1'), findsOneWidget);
    await tester.pumpWidget(layout(WindowSizeClass.large));
    expect(find.text('HEADER'), findsOneWidget);
    expect(find.text('count 1'), findsOneWidget);
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var _n = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _n++),
    child: Text('count $_n'),
  );
}
