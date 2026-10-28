import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The M7 feedback components' tests from their Flutter notes: progress bar, messenger and snackbar, banner.

late CamoMessenger _messenger;

Widget _app(
  Widget child, {
  CamoTheme? theme,
  bool accessibleNavigation = false,
}) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  builder: (context, _) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(accessibleNavigation: accessibleNavigation),
    child: CamouflageProvider(
      skin: skinA,
      theme: theme ?? themeT,
      child: Builder(
        builder: (context) {
          _messenger = CamoMessenger.of(context);
          return Align(alignment: Alignment.topLeft, child: child);
        },
      ),
    ),
  ),
);

void main() {
  group('progress bars', () {
    testWidgets('a bar announces its value or that it is working', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 200,
            child: Column(
              children: [
                CamoProgressBar(value: 1.4, semanticLabel: 'Uploading photo'),
                CamoProgressBar(semanticLabel: 'Loading'),
              ],
            ),
          ),
        ),
      );
      final upload = tester
          .getSemantics(find.bySemanticsLabel('Uploading photo'))
          .getSemanticsData();
      expect(upload.value, '100%');
      final loading = tester
          .getSemantics(find.bySemanticsLabel('Loading'))
          .getSemanticsData();
      expect(loading.value, '');
      semantics.dispose();
    });
  });

  group('messenger and snackbars', () {
    testWidgets('show completes with actionPerformed when the action is '
        'tapped', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SizedBox()));
      final result = _messenger.show('Message archived', action: 'Undo');
      await tester.pumpAndSettle();
      expect(find.text('Message archived'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Undo')),
        matchesSemantics(
          label: 'Undo',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(await result, SnackbarResult.actionPerformed);
      expect(find.text('Message archived'), findsNothing);
      semantics.dispose();
    });

    testWidgets('a snackbar times out as dismissed', (tester) async {
      await tester.pumpWidget(_app(const SizedBox()));
      SnackbarResult? result;
      _messenger
          .show('Saved', duration: SnackbarDuration.short)
          .then((r) => result = r);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(result, isNull);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(result, SnackbarResult.dismissed);
    });

    testWidgets('messages queue in order', (tester) async {
      await tester.pumpWidget(_app(const SizedBox()));
      final results = <String>[];
      _messenger
          .show('First', duration: SnackbarDuration.indefinite)
          .then((r) => results.add('First ${r.name}'));
      _messenger.show('Second', duration: SnackbarDuration.indefinite);
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsNothing);
      _messenger.dismissCurrent();
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
      expect(results, ['First dismissed']);
    });

    testWidgets('withDismiss follows the theme and the dismiss button '
        'dismisses', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(),
          theme: themeT.copyWith(
            components: const CamoComponentThemes(
              snackbar: CamoSnackbarTheme(showDismiss: true),
            ),
          ),
        ),
      );
      final result = _messenger.show(
        'Copied',
        duration: SnackbarDuration.indefinite,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Dismiss'));
      await tester.pumpAndSettle();
      expect(await result, SnackbarResult.dismissed);
      _messenger.show(
        'No close',
        duration: SnackbarDuration.indefinite,
        withDismiss: false,
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Dismiss'), findsNothing);
      semantics.dispose();
    });

    testWidgets('a screen reader keeps a snackbar with an action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const SizedBox(), accessibleNavigation: true),
      );
      SnackbarResult? result;
      _messenger.show('Archived', action: 'Undo').then((r) => result = r);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 60));
      expect(result, isNull);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('insets lift a bottom snackbar above the screen chrome', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const CamoMessengerInsets(bottom: 80, child: SizedBox())),
      );
      _messenger.show('Lifted', duration: SnackbarDuration.indefinite);
      await tester.pumpAndSettle();
      final screen = tester.getSize(find.byType(WidgetsApp));
      final bar = tester.getRect(
        find.ancestor(of: find.text('Lifted'), matching: find.byType(Row)),
      );
      // The plain skin's margin is 16, plus the screen's 80.
      expect(bar.bottom, screen.height - 16 - 80);
    });

    testWidgets('a snackbar is a live region', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const SizedBox()));
      _messenger.show(
        "Couldn't send",
        tone: Tone.error,
        duration: SnackbarDuration.indefinite,
      );
      await tester.pumpAndSettle();
      final data = tester
          .getSemantics(find.text("Couldn't send"))
          .getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);
      semantics.dispose();
    });
  });

  group('banners', () {
    testWidgets('a banner dismisses and announces warnings and errors', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var dismissed = 0;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: Column(
              children: [
                CamoBanner(
                  message: "Couldn't sync",
                  tone: Tone.error,
                  onDismiss: () => dismissed++,
                ),
                const CamoBanner(message: 'Trial ends in 3 days'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Dismiss'));
      expect(dismissed, 1);
      expect(
        tester
            .getSemantics(find.text("Couldn't sync"))
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      expect(
        tester
            .getSemantics(find.text('Trial ends in 3 days'))
            .flagsCollection
            .isLiveRegion,
        isFalse,
      );
      semantics.dispose();
    });

    testWidgets('a banner reads its texts as one node', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 300,
            child: CamoBanner(
              title: 'Trial',
              message: 'Your trial ends in 3 days',
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Trial')).getSemanticsData().label,
        'Trial\nYour trial ends in 3 days',
      );
      semantics.dispose();
    });

    testWidgets("ghost actions take the banner's accent", (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: CamoBanner(
              message: 'Storage is full',
              tone: Tone.error,
              appearance: Appearance.solid,
              actions: [
                CamoButton(
                  text: 'Retry',
                  onPressed: () {},
                  appearance: Appearance.ghost,
                ),
              ],
            ),
          ),
        ),
      );
      final text = tester.widget<RichText>(
        find.descendant(
          of: find.text('Retry'),
          matching: find.byType(RichText),
        ),
      );
      expect(text.text.style?.color, themeT.colors.onError);
    });
  });
}
