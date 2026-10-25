import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The M3 components' tests from their Flutter notes, under the plain test skin.

const _dot = IconSource.builder(_square);
Widget _square(double size, Color? color) => SizedBox.square(
  dimension: size,
  child: ColoredBox(color: color ?? const Color(0xFF000000)),
);

Widget _app(Widget child, {CamoTheme? theme, double textScale = 1}) =>
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        // What WidgetsApp gives every app: the default shortcuts (Enter, Space) and an overlay.
        child: Shortcuts(
          shortcuts: WidgetsApp.defaultShortcuts,
          child: Overlay(
            key: UniqueKey(), // initialEntries are read once: a fresh overlay per pump
            initialEntries: [
              OverlayEntry(
                builder: (_) => CamouflageProvider(
                  skin: skinA,
                  theme: theme ?? themeT,
                  child: Align(alignment: Alignment.topLeft, child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  group('CamoText', () {
    testWidgets('takes the content color', (tester) async {
      await tester.pumpWidget(_app(const CamoText('Hello')));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.color, themeT.colors.onSurface);
    });

    testWidgets('each link is its own link', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        _app(
          CamoText.rich([
            const CamoSpan('I agree to the '),
            CamoSpan('Terms', onTap: () => tapped.add('terms')),
            const CamoSpan(' and '),
            CamoSpan('Privacy', onTap: () => tapped.add('privacy')),
          ]),
        ),
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byType(RichText),
      );
      final start = 'I agree to the Terms and '.length;
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + 3),
      );
      await tester.tapAt(
        tester.getTopLeft(find.byType(RichText)) + boxes.first.toRect().center,
      );
      expect(tapped, ['privacy']);
    });

    testWidgets('a span without overrides inherits the base style', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          CamoText.rich(const [
            CamoSpan('plain'),
          ], style: themeT.typography.titleLarge),
        ),
      );
      final rich = tester.widget<RichText>(find.byType(RichText));
      expect(rich.text.style?.fontSize, themeT.typography.titleLarge.fontSize);
    });
  });

  group('CamoIcon', () {
    testWidgets('follows the ambient style; parameters override it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const CamoContentStyle(
            color: Color(0xFFFF0000),
            iconStyle: CamoIconStyle(size: 32, color: Color(0xFFFF0000)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CamoIcon(_dot, key: ValueKey('a')),
                CamoIcon(_dot, key: ValueKey('b'), size: 12),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('a'))),
        const Size.square(32),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('b'))),
        const Size.square(12),
      );
    });

    testWidgets('a decorative icon has no semantics; a labelled one does', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              CamoIcon(_dot),
              CamoIcon(_dot, semanticLabel: 'Search'),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('autoMirror flips only in RTL', (tester) async {
      Widget icon(TextDirection d) => Directionality(
        textDirection: d,
        child: const CamoIcon(IconSource.builder(_square, autoMirror: true)),
      );
      await tester.pumpWidget(_app(icon(TextDirection.ltr)));
      expect(find.byType(Transform), findsNothing);
      await tester.pumpWidget(_app(icon(TextDirection.rtl)));
      expect(find.byType(Transform), findsOneWidget);
    });
  });

  group('CamoSurface and CamoDivider', () {
    testWidgets('surface content is onSurface', (tester) async {
      late Color color;
      await tester.pumpWidget(
        _app(
          CamoSurface(
            level: SurfaceLevel.high,
            child: Builder(
              builder: (context) {
                color = Camouflage.contentColorOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(color, themeT.colors.onSurface);
    });

    testWidgets('a divider is hidden and takes its thickness', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const SizedBox(width: 100, child: CamoDivider())),
      );
      expect(tester.getSize(find.byType(CamoDivider)).height, 1);
      expect(find.byType(ExcludeSemantics), findsWidgets);
      handle.dispose();
    });
  });

  group('CamoButton', () {
    testWidgets('fires once per tap, not when disabled or loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CamoButton(text: 'Save', onPressed: () => taps++),
              const CamoButton(text: 'Off', onPressed: null),
              CamoButton(
                text: 'Busy',
                onPressed: () => taps += 100,
                loading: true,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.tap(find.text('Off'), warnIfMissed: false);
      await tester.tap(find.text('Busy'));
      expect(taps, 2);
    });

    testWidgets('is a button named by its text, busy while loading', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(CamoButton(text: 'Busy', onPressed: () {}, loading: true)),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Busy')),
        matchesSemantics(
          label: 'Busy',
          value: 'Busy',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('keyboard Enter activates it', (tester) async {
      var taps = 0;
      final focus = FocusNode();
      await tester.pumpWidget(
        _app(CamoButton(text: 'Go', onPressed: () => taps++, focusNode: focus)),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
      focus.dispose();
    });

    testWidgets('a small button still has a 48 target', (tester) async {
      var taps = 0;
      final small = themeT.copyWith(
        components: const CamoComponentThemes(
          button: CamoButtonTheme(height: 32),
        ),
      );
      await tester.pumpWidget(
        _app(
          CamoButton(text: 'OK', onPressed: () => taps++),
          theme: small,
        ),
      );
      final box = tester.getRect(find.byType(CamoTouchTarget));
      expect(box.height, greaterThanOrEqualTo(48));
      await tester.tapAt(box.topLeft + const Offset(1, 1));
      expect(taps, 1);
    });

    testWidgets('the touch target counts in intrinsic sizes', (tester) async {
      await tester.pumpWidget(
        _app(
          IntrinsicWidth(
            child: CamoIconButton(
              icon: const CamoIcon(_dot),
              semanticLabel: 'Back',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(IntrinsicWidth)).width, 48);
    });

    testWidgets('a prefix icon takes the button icon size', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoButton(
            text: 'Save',
            onPressed: () {},
            prefixIcon: const CamoIcon(_dot, key: ValueKey('i')),
          ),
        ),
      );
      final size = skinA.button.defaults(themeT).iconSize;
      expect(
        tester.getSize(find.byKey(const ValueKey('i'))),
        Size.square(size),
      );
    });

    testWidgets('grows with text scale', (tester) async {
      await tester.pumpWidget(
        _app(CamoButton(text: 'Large text', onPressed: () {}), textScale: 3),
      );
      final height = skinA.button.defaults(themeT).height;
      expect(
        tester.getSize(find.byType(ConstrainedBox).first).height,
        greaterThan(height),
      );
    });

    test('style merges, and status tones take their family', () {
      final style = skinA.button.defaults(themeT);
      expect(style.merge(const CamoButtonTheme(height: 56)).height, 56);
      expect(
        style.merge(const CamoButtonTheme(height: 56)).minWidth,
        style.minWidth,
      );
      expect(
        style.colorsFor(Appearance.outline, Tone.error, themeT).border,
        themeT.colors.error,
      );
    });
  });

  group('CamoIconButton', () {
    testWidgets('one labelled button with a 48 target, the icon hidden', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          CamoIconButton(
            icon: const CamoIcon(_dot, semanticLabel: 'inner'),
            semanticLabel: 'Back',
            onPressed: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('inner'), findsNothing);
      expect(
        tester.getSize(find.byType(CamoTouchTarget)),
        const Size.square(48),
      );
      handle.dispose();
    });

    testWidgets('checked makes it a toggle', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          CamoIconButton(
            icon: const CamoIcon(_dot),
            semanticLabel: 'Favorite',
            onPressed: () {},
            checked: true,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Favorite')),
        matchesSemantics(
          label: 'Favorite',
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('CamoProgressCircle', () {
    testWidgets('clamps and exposes the value', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const CamoProgressCircle(value: 1.7, semanticLabel: 'Upload')),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Upload')),
        matchesSemantics(label: 'Upload', value: '100%'),
      );
      handle.dispose();
    });
  });

  group('CamoTooltip', () {
    testWidgets('shows after the hover delay and hides on exit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const CamoTooltip(
            message: 'Close the panel',
            child: SizedBox.square(dimension: 40),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(SizedBox).last));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Close the panel'), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Close the panel'), findsOneWidget);
      await mouse.moveTo(const Offset(300, 300));
      await tester.pump();
      expect(find.text('Close the panel'), findsNothing);
    });

    testWidgets('a long press shows it without firing the tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          CamoIconButton(
            icon: const CamoIcon(_dot),
            semanticLabel: 'Close',
            onPressed: () => taps++,
            tooltip: 'Close',
          ),
        ),
      );
      await tester.longPress(find.byType(CamoIconButton));
      await tester.pump();
      expect(find.text('Close'), findsOneWidget);
      expect(taps, 0);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
