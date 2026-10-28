import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The M6 overlay routes' tests from their Flutter notes: results, dismissal, the veto, the captured theme.

Widget _app(Widget child) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
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

Widget _opener(void Function(BuildContext) onOpen) =>
    Builder(builder: (context) => _Tap(onTap: () => onOpen(context)));

class _Tap extends StatelessWidget {
  const _Tap({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: const SizedBox(width: 120, height: 40, child: Text('Open')),
  );
}

Widget _deleteDialog(BuildContext context) => CamoDialog(
  title: 'Delete item?',
  message: "This can't be undone.",
  confirm: CamoButton(
    text: 'Delete',
    onPressed: () => Navigator.pop(context, true),
  ),
  dismiss: CamoButton(
    text: 'Cancel',
    onPressed: () => Navigator.pop(context, false),
  ),
);

void main() {
  testWidgets('a dialog returns the value it is popped with', (tester) async {
    Future<bool?>? result;
    await tester.pumpWidget(
      _app(
        _opener(
          (c) =>
              result = showCamoDialog<bool>(context: c, builder: _deleteDialog),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget, reason: 'the page below stays');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
    expect(find.text('Delete item?'), findsNothing);
  });

  testWidgets('the scrim, Esc and back close with null', (tester) async {
    final results = <bool?>[];
    await tester.pumpWidget(
      _app(
        _opener(
          (c) => showCamoDialog<bool>(
            context: c,
            builder: _deleteDialog,
          ).then(results.add),
        ),
      ),
    );
    Future<void> open() async {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    await open();
    await tester.tapAt(const Offset(780, 580));
    await tester.pumpAndSettle();
    await open();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await open();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(results, [null, null, null]);
  });

  testWidgets('PopScope and dismissible: false keep it open', (tester) async {
    await tester.pumpWidget(
      _app(
        _opener(
          (c) => showCamoBottomSheet<void>(
            context: c,
            builder: (_) => const PopScope(
              canPop: false,
              child: CamoBottomSheet(title: 'Saving', child: Text('Busy')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.tapAt(const Offset(780, 10));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Busy'), findsOneWidget);
  });

  testWidgets('a non-dismissible dialog ignores back but closes by pop', (
    tester,
  ) async {
    Future<bool?>? result;
    await tester.pumpWidget(
      _app(
        _opener(
          (c) => result = showCamoDialog<bool>(
            context: c,
            dismissible: false,
            builder: _deleteDialog,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Delete item?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('the dialog sees the theme where it was opened', (tester) async {
    late CamoTheme seen;
    await tester.pumpWidget(
      _app(
        CamouflageProvider(
          theme: themeU,
          child: _opener(
            (c) => showCamoDialog<void>(
              context: c,
              builder: (context) {
                seen = Camouflage.themeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(seen.colors.primary, themeU.colors.primary);
  });

  testWidgets('a sheet page shows over the page below and pops a value', (
    tester,
  ) async {
    final pages = <Page<Object?>>[
      const _PlainPage(key: ValueKey('home'), child: Text('Home')),
      const CamoSheetPage<String>(
        key: ValueKey('picker'),
        child: CamoBottomSheet(
          title: 'Choose country',
          child: Text('Indonesia'),
        ),
      ),
    ];
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFFFFFFFF),
        builder: (context, _) => CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Navigator(pages: pages, onDidRemovePage: pages.remove),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.text('Indonesia'))),
      isA<CamoSheetRoute<String>>(),
    );
  });
}

class _PlainPage extends Page<void> {
  const _PlainPage({super.key, required this.child});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder<void>(
    settings: this,
    pageBuilder: (context, _, _) => child,
  );
}
