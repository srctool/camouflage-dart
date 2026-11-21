import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The dock layout: the state's rules, stripes, tool windows, maximize, moving, focus and right to left (M16).

Widget _app(Widget child, {TextDirection dir = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Directionality(
        textDirection: dir,
        child: CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

const _ids = ['files', 'search', 'details', 'log', 'terminal'];
const _edges = [
  DockEdge.left,
  DockEdge.left,
  DockEdge.right,
  DockEdge.bottom,
  DockEdge.bottom,
];

CamoDockState _state([Set<Object> open = const {}]) =>
    CamoDockState({for (var i = 0; i < 5; i++) _ids[i]: _edges[i]}, open: open);

String _title(String id) => id[0].toUpperCase() + id.substring(1);

final _windows = [
  for (var i = 0; i < 5; i++)
    CamoToolWindow(
      id: _ids[i],
      title: _title(_ids[i]),
      icon: const SizedBox.square(dimension: 12),
      defaultEdge: _edges[i],
      child: Focus(
        key: ValueKey('content-${_ids[i]}'),
        child: const SizedBox.expand(),
      ),
    ),
];

class _Center extends StatelessWidget {
  const _Center();

  @override
  Widget build(BuildContext context) =>
      const Focus(key: ValueKey('center'), child: SizedBox.expand());
}

Widget _dock(CamoDockState state, {double width = 1400}) => SizedBox(
  width: width,
  height: 600,
  child: CamoDockLayout(
    state: state,
    toolWindows: _windows,
    center: const _Center(),
  ),
);

Finder _content(String id) => find.byKey(ValueKey('content-$id'));
Finder _stripe(String id) => find.byKey(ValueKey('dock-stripe-$id'));

void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Key? _focusedKey() => FocusManager.instance.primaryFocus?.context?.widget.key;

void main() {
  group('CamoDockState', () {
    test('windows keep their stripe order per edge', () {
      final s = _state({'files', 'log'});
      expect(s.windowsOn(DockEdge.left), ['files', 'search']);
      expect(s.openOn(DockEdge.left), ['files']);
      expect(s.openOn(DockEdge.bottom), ['log']);
    });

    test('toggle opens and hides, several windows share an edge', () {
      final s = _state({'files'})..toggle('search');
      expect(s.openOn(DockEdge.left), ['files', 'search']);
      s.toggle('files');
      expect(s.openOn(DockEdge.left), ['search']);
      expect(s.windowsOn(DockEdge.left), ['files', 'search']);
    });

    test('moving joins the other edge at the end and stays open', () {
      final s = _state({'files'})..move('files', DockEdge.bottom);
      expect(s.windowsOn(DockEdge.left), ['search']);
      expect(s.windowsOn(DockEdge.bottom), ['log', 'terminal', 'files']);
      expect(s.isOpen('files'), isTrue);
    });

    test('maximize ends when another opens or the window hides', () {
      final s = _state()..maximize('details');
      expect(s.maximized, 'details');
      expect(s.isOpen('details'), isTrue);
      s.open('search');
      expect(s.maximized, isNull);
      s
        ..maximize('log')
        ..close('log');
      expect(s.maximized, isNull);
      s
        ..maximize('log')
        ..restore();
      expect(s.maximized, isNull);
      expect(s.isOpen('log'), isTrue);
    });

    test('an unknown id changes nothing', () {
      final s = _state()
        ..open('nope')
        ..move('nope', DockEdge.right)
        ..maximize('nope');
      expect(s.isOpen('nope'), isFalse);
      expect(s.maximized, isNull);
      expect(s.ids.length, 5);
    });

    test('a layout restores from its snapshot', () {
      final s = _state({'files', 'log'})
        ..move('log', DockEdge.right)
        ..toggle('details')
        ..setSize(DockEdge.left, 0.4)
        ..maximize('files');
      final saved = s.snapshot();
      final restored = _state()..apply(saved);
      expect(restored.snapshot(), saved);
      expect(restored.edgeOf('log'), DockEdge.right);
      expect(restored.sizeOf(DockEdge.left), 0.4);
      expect(restored.maximized, 'files');
    });

    test('a snapshot with unknown or missing windows is fitted', () {
      final other = _state()..move('log', DockEdge.left);
      final saved = other.snapshot();
      final s = _state()
        ..apply(
          CamoDockSnapshot(
            order: ['gone', 'log'],
            edges: {...saved.edges, 'gone': DockEdge.right},
            open: {'gone', 'log'},
            sizes: saved.sizes,
            maximized: 'gone',
          ),
        );
      expect(s.ids.toSet(), _ids.toSet());
      expect(s.ids.first, 'log');
      expect(s.openOn(DockEdge.left), ['log']);
      expect(s.maximized, isNull);
    });
  });

  group('CamoDockLayout', () {
    testWidgets('stripe buttons toggle their tool windows', (tester) async {
      final state = _state();
      await tester.pumpWidget(_app(_dock(state)));
      expect(_content('files'), findsNothing);
      await tester.tap(_stripe('files'));
      await tester.pumpAndSettle();
      expect(_content('files'), findsOneWidget);
      await tester.tap(_stripe('log'));
      await tester.pumpAndSettle();
      expect(_content('log'), findsOneWidget);
      await tester.tap(_stripe('files'));
      await tester.pumpAndSettle();
      expect(_content('files'), findsNothing);
      expect(state.isOpen('log'), isTrue);
    });

    testWidgets('three docks with five windows rearrange and restore', (
      tester,
    ) async {
      final state = _state(_ids.toSet());
      await tester.pumpWidget(_app(_dock(state)));
      await tester.pumpAndSettle();
      for (final id in _ids) {
        expect(_content(id), findsOneWidget, reason: id);
      }
      state.move('search', DockEdge.right);
      await tester.pumpAndSettle();
      expect(_content('search'), findsOneWidget);
      final saved = state.snapshot();
      state
        ..close('files')
        ..move('log', DockEdge.left);
      await tester.pumpAndSettle();
      state.apply(saved);
      await tester.pumpAndSettle();
      expect(_content('files'), findsOneWidget);
      expect(state.edgeOf('log'), DockEdge.bottom);
    });

    testWidgets('maximize hides the center and restore brings it back', (
      tester,
    ) async {
      _wide(tester);
      final handle = tester.ensureSemantics();
      final state = _state({'files'});
      await tester.pumpWidget(_app(_dock(state)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('center')), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Maximize'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('center')), findsNothing);
      expect(_content('files'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Restore'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('center')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a narrow dock folds maximize and hide into its menu', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final state = _state({'files'});
      await tester.pumpWidget(_app(_dock(state, width: 500)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Maximize'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Tool window options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maximize'));
      await tester.pumpAndSettle();
      expect(state.maximized, 'files');
      handle.dispose();
    });

    testWidgets('hide closes the window and keeps its stripe button', (
      tester,
    ) async {
      _wide(tester);
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(_dock(_state({'files'}))));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Hide'));
      await tester.pumpAndSettle();
      expect(_content('files'), findsNothing);
      expect(_stripe('files'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the header menu moves the window to another edge', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final state = _state({'files'});
      await tester.pumpWidget(_app(_dock(state)));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Tool window options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bottom'));
      await tester.pumpAndSettle();
      expect(state.edgeOf('files'), DockEdge.bottom);
      handle.dispose();
    });

    testWidgets('focus moves into a window and Esc returns to the center', (
      tester,
    ) async {
      final state = _state();
      await tester.pumpWidget(_app(_dock(state)));
      state.focus('details');
      await tester.pumpAndSettle();
      expect(_focusedKey(), const ValueKey('content-details'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(_focusedKey(), const ValueKey('center'));
    });

    testWidgets('the left dock sits at the end in right to left', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_dock(_state({'files'})), dir: TextDirection.rtl),
      );
      await tester.pumpAndSettle();
      final files = tester.getTopLeft(_content('files'));
      final center = tester.getTopLeft(find.byKey(const ValueKey('center')));
      expect(files.dx, greaterThan(center.dx));
    });
  });
}
