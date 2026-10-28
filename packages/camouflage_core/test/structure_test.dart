import 'package:camouflage_core/camouflage_core.dart';

import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The M6 structure components' tests from their Flutter notes: card, list item, accordion, skeleton, top bar,
// paged list.

Widget _app(Widget child, {CamoSkin? skin, CamoTheme? theme}) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: skin ?? skinA,
    theme: theme ?? themeT,
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

class _Holder<T> extends StatefulWidget {
  const _Holder(this.initial, this.builder);

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Holder<T>> createState() => _HolderState<T>();
}

class _HolderState<T> extends State<_Holder<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(_value, (v) => setState(() => _value = v));
}

final _page = [for (var i = 1; i <= 30; i++) 'Item $i'];

Widget _paged(
  CamoPagedListState<String> state, {
  VoidCallback? onLoadMore,
  VoidCallback? onRetry,
}) => SizedBox(
  width: 300,
  height: 400,
  child: CamoPagedList<String>(
    state: state,
    itemKey: (it) => it,
    onLoadMore: onLoadMore ?? () {},
    onRetry: onRetry ?? () {},
    itemBuilder: (context, value, _) =>
        SizedBox(height: 48, child: Text(value)),
  ),
);

void main() {
  group('CamoCard', () {
    testWidgets('a card without onPressed has no button semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const CamoCard(child: Text('Plain'))));
      expect(
        tester.getSemantics(find.text('Plain')),
        isNot(matchesSemantics(isButton: true)),
      );
      semantics.dispose();
    });

    testWidgets('a clickable card is one button and fires once per tap', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          CamoCard(
            onPressed: () => taps++,
            child: const Column(children: [Text('Pro'), Text('12 a month')]),
          ),
        ),
      );
      await tester.tap(find.text('Pro'));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.text('Pro')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Pro\n12 a month',
        ),
      );
      semantics.dispose();
    });

    testWidgets('a disabled card ignores taps; a selected card says so', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CamoCard(
                onPressed: () => taps++,
                enabled: false,
                child: const Text('Off'),
              ),
              CamoCard(
                onPressed: () {},
                selected: true,
                child: const Text('Chosen'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Off'));
      expect(taps, 0);
      expect(
        tester.getSemantics(find.text('Chosen')).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      semantics.dispose();
    });
  });

  group('CamoListItem', () {
    testWidgets('row heights follow the line count', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 300,
            child: Column(
              children: [
                CamoListItem(key: Key('one'), headline: 'One'),
                CamoListItem(
                  key: Key('two'),
                  headline: 'Two',
                  supporting: 'Detail',
                ),
                CamoListItem(
                  key: Key('three'),
                  headline: 'Three',
                  supporting: 'Detail',
                  overline: 'Over',
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('one'))).height, 56);
      expect(tester.getSize(find.byKey(const Key('two'))).height, 72);
      expect(tester.getSize(find.byKey(const Key('three'))).height, 88);
    });

    testWidgets('a switch row is announced as the switch and toggles', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          _Holder<bool>(
            false,
            (on, set) => SizedBox(
              width: 300,
              child: Column(
                children: [
                  const CamoListItem(headline: 'Plain row'),
                  CamoListItem(
                    headline: 'Wi-Fi',
                    trailing: CamoSwitch(checked: on, onChanged: null),
                    onPressed: () => set(!on),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final plain = tester.getSemantics(find.text('Plain row'));
      expect(plain.flagsCollection.isButton, isFalse);
      expect(plain.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      var row = tester.getSemantics(find.text('Wi-Fi'));
      expect(row.flagsCollection.isButton, isFalse);
      expect(row.flagsCollection.isToggled, Tristate.isFalse);
      await tester.tap(find.text('Wi-Fi'));
      await tester.pump();
      row = tester.getSemantics(find.text('Wi-Fi'));
      expect(row.flagsCollection.isToggled, Tristate.isTrue);
      semantics.dispose();
    });

    testWidgets('a plain row is a button and the section title a header', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: CamoListSection(
              title: 'Network',
              children: [
                CamoListItem(headline: 'Proxy', onPressed: () {}),
                CamoListItem(headline: 'DNS', onPressed: () {}, selected: true),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Network')).flagsCollection.isHeader,
        isTrue,
      );
      expect(
        tester.getSemantics(find.text('Proxy')).flagsCollection.isButton,
        isTrue,
      );
      expect(
        tester.getSemantics(find.text('DNS')).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      semantics.dispose();
    });
  });

  group('CamoAccordion', () {
    testWidgets('the header toggles and is a header with its state', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          _Holder<bool>(
            false,
            (open, set) => SizedBox(
              width: 300,
              child: CamoAccordion(
                title: 'Shipping',
                expanded: open,
                onExpansionChanged: set,
                child: const Text('Ships in 2 days'),
              ),
            ),
          ),
        ),
      );
      var header = tester.getSemantics(find.text('Shipping'));
      expect(header.flagsCollection.isHeader, isTrue);
      expect(header.flagsCollection.isButton, isTrue);
      expect(header.flagsCollection.isExpanded, Tristate.isFalse);
      expect(find.text('Ships in 2 days'), findsNothing);
      await tester.tap(find.text('Shipping'));
      await tester.pumpAndSettle();
      header = tester.getSemantics(find.text('Shipping'));
      expect(header.flagsCollection.isExpanded, Tristate.isTrue);
      expect(find.text('Ships in 2 days'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('collapsed content keeps its state', (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      late ValueChanged<bool> setOpen;
      await tester.pumpWidget(
        _app(
          _Holder<bool>(true, (open, set) {
            setOpen = set;
            return SizedBox(
              width: 300,
              child: CamoAccordion(
                title: 'Details',
                expanded: open,
                onExpansionChanged: set,
                child: _Field(controller, focus),
              ),
            );
          }),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'kept');
      setOpen(false);
      await tester.pumpAndSettle();
      expect(find.text('kept'), findsNothing);
      setOpen(true);
      await tester.pumpAndSettle();
      expect(find.text('kept'), findsOneWidget);
    });

    testWidgets('singleExpand closes the others', (tester) async {
      var open = {'a'};
      await tester.pumpWidget(
        _app(
          _Holder<Set<String>>(
            open,
            (value, set) => SizedBox(
              width: 300,
              child: CamoAccordionGroup<String>(
                expanded: value,
                onExpandedChanged: (v) {
                  open = v;
                  set(v);
                },
                singleExpand: true,
                items: const [
                  CamoAccordionItem(key: 'a', title: 'First', child: Text('A')),
                  CamoAccordionItem(
                    key: 'b',
                    title: 'Second',
                    child: Text('B'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(open, {'b'});
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(open, <String>{});
    });
  });

  group('CamoSkeleton', () {
    testWidgets('skeletons have no semantics and reduced motion is static', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 300,
            child: Column(
              children: [CamoSkeleton(height: 24), CamoSkeleton.text(lines: 3)],
            ),
          ),
          theme: themeT.copyWith(motion: themeT.motion.reduced()),
        ),
      );
      final paints = tester.widgetList<CamoSkeletonPaint>(
        find.byType(CamoSkeletonPaint),
      );
      expect(paints.length, 4);
      expect(
        paints.every((p) => p.state.animation == SkeletonAnimation.none),
        isTrue,
      );
      expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
      semantics.dispose();
    });
  });

  group('CamoTopBar', () {
    testWidgets('the title is a header and the scroll offset arrives', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      Widget bar(double offset) => _app(
        SizedBox(
          width: 360,
          child: CamoTopBar(title: 'Settings', scrollOffset: offset),
        ),
      );
      await tester.pumpWidget(bar(0));
      expect(
        tester.getSemantics(find.text('Settings')).flagsCollection.isHeader,
        isTrue,
      );
      expect(find.byKey(const ValueKey('bar-resting')), findsOneWidget);
      await tester.pumpWidget(bar(8));
      expect(find.byKey(const ValueKey('bar-scrolled')), findsOneWidget);
      await tester.pumpWidget(bar(double.infinity));
      expect(find.byKey(const ValueKey('bar-scrolled')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a custom title keeps the title as the header', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 360,
            child: CamoTopBar(title: 'Search', titleContent: Text('logo')),
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Search'))
            .flagsCollection
            .isHeader,
        isTrue,
      );
      expect(find.text('logo'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('CamoPagedList', () {
    testWidgets('each loading state draws its rows', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(_paged(const CamoPagedListState(loading: PagedLoad.initial))),
      );
      expect(find.text('Item 1'), findsNothing);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      await tester.pumpWidget(
        _app(_paged(CamoPagedListState(items: _page.take(3).toList()))),
      );
      expect(find.text('Item 1'), findsOneWidget);
      await tester.pumpWidget(
        _app(_paged(const CamoPagedListState(endReached: true))),
      );
      expect(find.text('Nothing here yet'), findsOneWidget);
      await tester.pumpWidget(
        _app(
          _paged(
            CamoPagedListState(
              items: _page.take(3).toList(),
              loading: PagedLoad.more,
            ),
          ),
        ),
      );
      expect(find.text('Item 3'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets(
      'a first-page error focuses retry; a next-page error shows a row',
      (tester) async {
        var retries = 0;
        await tester.pumpWidget(
          _app(
            _paged(
              const CamoPagedListState(
                error: PagedError(
                  message: 'Offline',
                  scope: PagedErrorScope.firstPage,
                ),
              ),
              onRetry: () => retries++,
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Offline'), findsOneWidget);
        final focused = FocusManager.instance.primaryFocus;
        expect(
          focused?.context?.findAncestorWidgetOfExactType<CamoButton>()?.text,
          'Retry',
        );
        await tester.tap(find.text('Retry'));
        expect(retries, 1);
        await tester.pumpWidget(
          _app(
            _paged(
              CamoPagedListState(
                items: _page.take(2).toList(),
                error: const PagedError(
                  message: "Couldn't load more",
                  scope: PagedErrorScope.nextPage,
                ),
              ),
              onRetry: () => retries++,
            ),
          ),
        );
        expect(find.text('Item 2'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        expect(retries, 2);
      },
    );

    testWidgets(
      'load more fires once near the end, never while loading or at the end',
      (tester) async {
        var calls = 0;
        Future<void> show(CamoPagedListState<String> s) async {
          await tester.pumpWidget(_app(_paged(s, onLoadMore: () => calls++)));
          await tester.pump();
        }

        var state = CamoPagedListState(items: _page);
        await show(state);
        expect(calls, 0);
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        expect(calls, 1);
        await show(CamoPagedListState(items: _page, loading: PagedLoad.more));
        expect(calls, 1);
        state = CamoPagedListState(items: _page, endReached: true);
        await show(state);
        expect(calls, 1);
      },
    );

    testWidgets('a short first page loads more right away', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _app(
          _paged(
            CamoPagedListState(items: _page.take(2).toList()),
            onLoadMore: () => calls++,
          ),
        ),
      );
      await tester.pump();
      expect(calls, 1);
    });
  });
}

class _Field extends StatelessWidget {
  const _Field(this.controller, this.focus);

  final TextEditingController controller;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) => EditableText(
    controller: controller,
    focusNode: focus,
    style: const TextStyle(fontSize: 14),
    cursorColor: const Color(0xFF000000),
    backgroundCursorColor: const Color(0xFF888888),
  );
}
