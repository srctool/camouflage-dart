import 'dart:ui' show CheckedState, Tristate;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The batch-1 inputs' tests from their Flutter notes, under the plain test skin.

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: direction,
        // What WidgetsApp gives every app: the default shortcuts and actions (Tab, arrows, Enter) and a focus
        // scope, so keyboard tests can Tab into the content.
        child: Shortcuts(
          shortcuts: WidgetsApp.defaultShortcuts,
          child: Actions(
            actions: WidgetsApp.defaultActions,
            child: FocusScope(
              autofocus: true,
              child: Overlay(
                key: UniqueKey(),
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => CamouflageProvider(
                      skin: skinA,
                      theme: themeT,
                      child: Align(alignment: Alignment.topLeft, child: child),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

// Rebuilds with state, like an app holding the value.
class _Holder<T> extends StatefulWidget {
  const _Holder(this.initial, this.builder);

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Holder<T>> createState() => _HolderState<T>();
}

class _HolderState<T> extends State<_Holder<T>> {
  late T value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(value, (v) => setState(() => value = v));
}

void main() {
  group('CamoCheckbox', () {
    testWidgets('a labelled checkbox is one toggle the label flips', (
      tester,
    ) async {
      var checked = false;
      await tester.pumpWidget(
        _app(
          _Holder<bool>(
            false,
            (v, set) => CamoCheckbox(
              checked: v,
              onChanged: (c) {
                checked = c;
                set(c);
              },
              label: 'Remember me',
            ),
          ),
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Remember me'))
          .getSemanticsData();
      expect(data.flagsCollection.isChecked, CheckedState.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      await tester.tap(find.text('Remember me'));
      await tester.pump();
      expect(checked, isTrue);
    });

    testWidgets('display-only or disabled does not toggle', (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              const CamoCheckbox(
                checked: true,
                onChanged: null,
                label: 'Shown',
              ),
              CamoCheckbox(
                checked: false,
                onChanged: (_) => changes++,
                label: 'Off',
                enabled: false,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Off'));
      await tester.tap(find.text('Shown'));
      await tester.pump();
      expect(changes, 0);
    });

    testWidgets('a link in the label fires and does not toggle', (
      tester,
    ) async {
      var checked = false;
      var opened = 0;
      await tester.pumpWidget(
        _app(
          CamoCheckbox(
            checked: false,
            onChanged: (c) => checked = c,
            labelSpans: [
              const CamoSpan('I agree to the '),
              CamoSpan('Terms', onTap: () => opened++),
            ],
          ),
        ),
      );
      await tester.tapOnText(find.textRange.ofSubstring('Terms'));
      await tester.pump();
      expect(opened, 1);
      expect(checked, isFalse);
    });

    testWidgets('an error marks it invalid', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          CamoCheckbox(
            checked: false,
            onChanged: (_) {},
            label: 'Consent',
            error: 'Please accept the terms',
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(CamoErrorSemantics));
      expect(
        node.getSemanticsData().validationResult,
        SemanticsValidationResult.invalid,
      );
      handle.dispose();
    });
  });

  group('CamoSwitch', () {
    testWidgets('is announced as a switch and toggles', (tester) async {
      var on = false;
      await tester.pumpWidget(
        _app(
          _Holder<bool>(
            false,
            (v, set) => CamoSwitch(
              checked: v,
              onChanged: (c) {
                on = c;
                set(c);
              },
              label: 'Wi-Fi',
            ),
          ),
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Wi-Fi'))
          .getSemanticsData();
      expect(data.flagsCollection.isToggled, Tristate.isFalse);
      await tester.tap(find.text('Wi-Fi'));
      await tester.pump();
      expect(on, isTrue);
    });

    testWidgets('a drag past the middle toggles; a short one springs back', (
      tester,
    ) async {
      var on = false;
      await tester.pumpWidget(
        _app(
          _Holder<bool>(
            false,
            (v, set) => CamoSwitch(
              checked: v,
              onChanged: (c) {
                on = c;
                set(c);
              },
            ),
          ),
        ),
      );
      await tester.drag(find.byType(CamoSwitch), const Offset(25, 0));
      await tester.pump();
      expect(on, isFalse);
      await tester.drag(find.byType(CamoSwitch), const Offset(60, 0));
      await tester.pump();
      expect(on, isTrue);
    });

    testWidgets('in RTL dragging left turns it on', (tester) async {
      var on = false;
      await tester.pumpWidget(
        _app(
          CamoSwitch(checked: false, onChanged: (c) => on = c),
          direction: TextDirection.rtl,
        ),
      );
      await tester.drag(find.byType(CamoSwitch), const Offset(-60, 0));
      await tester.pump();
      expect(on, isTrue);
    });
  });

  group('CamoRadioGroup', () {
    const speeds = [
      RadioOption('standard', 'Standard'),
      RadioOption('express', 'Express', enabled: false),
      RadioOption('overnight', 'Overnight'),
    ];

    testWidgets('a tap selects the value', (tester) async {
      String? value;
      await tester.pumpWidget(
        _app(
          CamoRadioGroup<String>(
            value: null,
            onChanged: (v) => value = v,
            options: speeds,
            label: 'Shipping',
          ),
        ),
      );
      await tester.tap(find.text('Overnight'));
      expect(value, 'overnight');
      final data = tester
          .getSemantics(find.text('Overnight'))
          .getSemanticsData();
      expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    });

    testWidgets('arrows move, select and skip disabled options', (
      tester,
    ) async {
      String? value = 'standard';
      await tester.pumpWidget(
        _app(
          _Holder<String?>(
            'standard',
            (v, set) => CamoRadioGroup<String>(
              value: v,
              onChanged: (n) {
                value = n;
                set(n);
              },
              options: speeds,
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'overnight');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'standard');
    });

    testWidgets('Tab enters on the selected option and leaves after it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CamoRadioGroup<String>(
                value: 'overnight',
                onChanged: (_) {},
                options: speeds,
              ),
              CamoCheckbox(checked: false, onChanged: (_) {}, label: 'After'),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .getSemantics(find.text('Overnight'))
            .getSemanticsData()
            .flagsCollection
            .isFocused,
        Tristate.isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .getSemantics(find.text('After'))
            .getSemanticsData()
            .flagsCollection
            .isFocused,
        Tristate.isTrue,
      );
    });
  });

  group('CamoSegmentedControl', () {
    const periods = [
      Segment('d', label: 'Day'),
      Segment('w', label: 'Week'),
      Segment('m', label: 'A whole month'),
    ];

    testWidgets('segments share the width and a tap selects', (tester) async {
      String? value;
      await tester.pumpWidget(
        _app(
          CamoSegmentedControl<String>(
            options: periods,
            selected: 'd',
            onChanged: (v) => value = v,
          ),
        ),
      );
      final day = tester.getSize(find.byType(CamoSegmentButton<String>).first);
      final month = tester.getSize(find.byType(CamoSegmentButton<String>).last);
      expect(day.width, month.width);
      await tester.tap(find.text('Week'));
      expect(value, 'w');
    });

    testWidgets('arrows select the next segment', (tester) async {
      String? value;
      await tester.pumpWidget(
        _app(
          CamoSegmentedControl<String>(
            options: periods,
            selected: 'd',
            onChanged: (v) => value = v,
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 'w');
    });

    testWidgets('an icon-only segment without a label asserts', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoSegmentedControl<String>(
            options: const [
              Segment('g', icon: SizedBox.square(dimension: 8)),
              Segment('l', label: 'List'),
            ],
            selected: 'g',
            onChanged: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNotNull);
    });
  });

  group('CamoSlider', () {
    testWidgets('a tap jumps, snaps and ends once', (tester) async {
      double? value;
      var ends = 0;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: CamoSlider(
              value: 0,
              onChanged: (v) => value = v,
              divisions: 4,
              onChangeEnd: (_) => ends++,
              semanticLabel: 'Rating',
            ),
          ),
        ),
      );
      final box = tester.getRect(find.byType(CamoSlider));
      await tester.tapAt(Offset(box.left + box.width * 0.55, box.center.dy));
      await tester.pump();
      expect(value, 0.5);
      expect(ends, 1);
    });

    testWidgets('keys and semantics actions move the value', (tester) async {
      await tester.pumpWidget(
        _app(
          _Holder<double>(
            0.5,
            (v, set) => SizedBox(
              width: 200,
              child: CamoSlider(
                value: v,
                onChanged: set,
                divisions: 10,
                semanticLabel: 'Volume',
              ),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      var data = tester
          .getSemantics(find.byType(CamoSlider))
          .getSemanticsData();
      expect(data.value, '60%');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      data = tester.getSemantics(find.byType(CamoSlider)).getSemanticsData();
      expect(data.value, '0%');
      tester.semantics.performAction(
        find.semantics.byLabel('Volume'),
        SemanticsAction.increase,
      );
      await tester.pump();
      data = tester.getSemantics(find.byType(CamoSlider)).getSemanticsData();
      expect(data.value, '10%');
    });

    testWidgets('in RTL the minimum is on the right', (tester) async {
      double? value;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 200,
            child: CamoSlider(value: 0.5, onChanged: (v) => value = v),
          ),
          direction: TextDirection.rtl,
        ),
      );
      final box = tester.getRect(find.byType(CamoSlider));
      await tester.tapAt(Offset(box.left + box.width * 0.95, box.center.dy));
      expect(value, lessThan(0.1));
    });
  });

  group('CamoStepper', () {
    testWidgets('the buttons step and disable at the limits', (tester) async {
      var count = 1;
      await tester.pumpWidget(
        _app(
          _Holder<int>(
            1,
            (v, set) => CamoStepper(
              value: v,
              onChanged: (n) {
                count = n;
                set(n);
              },
              max: 2,
              semanticLabel: 'quantity',
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Increase quantity'));
      await tester.pump();
      expect(count, 2);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Increase quantity'))
            .getSemanticsData()
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
      await tester.tap(find.bySemanticsLabel('Decrease quantity'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Decrease quantity'));
      await tester.pump();
      expect(count, 0);
    });

    testWidgets('a typed value is clamped and snapped when focus leaves', (
      tester,
    ) async {
      var count = 2;
      final other = FocusNode();
      addTearDown(other.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              _Holder<int>(
                2,
                (v, set) => CamoStepper(
                  value: v,
                  onChanged: (n) {
                    count = n;
                    set(n);
                  },
                  max: 10,
                  step: 2,
                  semanticLabel: 'Guests',
                ),
              ),
              Focus(focusNode: other, child: const SizedBox(height: 10)),
            ],
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '7');
      other.requestFocus();
      await tester.pump();
      expect(count, 8);
      await tester.showKeyboard(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '99');
      other.requestFocus();
      await tester.pump();
      expect(count, 10);
    });

    testWidgets('decimal steps never drift', (tester) async {
      var dose = const CamoDecimal(0, 1);
      await tester.pumpWidget(
        _app(
          _Holder<CamoDecimal>(
            const CamoDecimal(0, 1),
            (v, set) => CamoStepper.decimal(
              value: v,
              onChanged: (n) {
                dose = n;
                set(n);
              },
              min: CamoDecimal.zero,
              max: const CamoDecimal(1, 0),
              step: CamoDecimal.parse('0.1'),
              decimals: 1,
              semanticLabel: 'dose',
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.bySemanticsLabel('Increase dose'));
        await tester.pump();
      }
      expect(dose.compareTo(CamoDecimal.parse('0.3')), 0);
    });
  });

  group('CamoDecimal', () {
    test('parses either separator and keeps the scale', () {
      expect(CamoDecimal.parse('12.50'), const CamoDecimal(1250, 2));
      expect(CamoDecimal.parse('0,25'), const CamoDecimal(25, 2));
      expect(CamoDecimal.parse('-3'), const CamoDecimal(-3, 0));
      expect(CamoDecimal.tryParse('1.2.3'), isNull);
      expect(CamoDecimal.tryParse('abc'), isNull);
      expect(CamoDecimal.tryParse(''), isNull);
    });

    test('steps never drift and format with the separator', () {
      final tenth = CamoDecimal.parse('0.1');
      expect((tenth + tenth + tenth).compareTo(CamoDecimal.parse('0.3')), 0);
      expect(CamoDecimal.parse('12.5').withScale(2).format(','), '12,50');
      expect(CamoDecimal.parse('-1.25').withScale(1).format(), '-1.3');
      expect(CamoDecimal.parse('0.05').format(), '0.05');
    });

    test('snaps to the nearest step from the start', () {
      expect(
        camoSnapToStep(
          CamoDecimal.parse('1.6'),
          CamoDecimal.parse('0.5'),
          CamoDecimal.parse('0.5'),
        ).format(),
        '1.5',
      );
      expect(camoSnap(0.45, 4), 0.5);
      expect(camoSnap(0.3, null), 0.3);
    });
  });
}
