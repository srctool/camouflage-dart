import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/datepicker/camo_dates.dart'
    show typedDigits;
import 'package:camouflage_core/src/overlay/camo_overlay_routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The batch-3 pickers' tests from their Flutter notes: the calendar, the date and time fields and the sheet.

Widget _app(Widget child, {CamoTheme? theme}) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: skinA,
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

const _october = CamoYearMonth(2026, 10);

void main() {
  group('CamoCalendar', () {
    testWidgets(
      'a tap selects a day and days outside the limits are disabled',
      (tester) async {
        CalendarSelection? picked;
        await tester.pumpWidget(
          _app(
            _Holder<CalendarSelection>(
              const SingleDate(null),
              (v, set) => CamoCalendar(
                selection: v,
                onSelectionChanged: (s) {
                  picked = s;
                  set(s);
                },
                visibleMonth: _october,
                onVisibleMonthChanged: (_) {},
                firstDate: DateTime(2026, 10, 5),
              ),
            ),
          ),
        );
        await tester.tap(find.text('14'));
        await tester.pump();
        expect(picked, SingleDate(DateTime(2026, 10, 14)));
        expect(find.text('[14]'), findsOneWidget);
        await tester.tap(find.text('4'));
        await tester.pump();
        expect(picked, SingleDate(DateTime(2026, 10, 14)));
      },
    );

    testWidgets('a range is picked start then end and the ends are announced', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      CalendarSelection? picked;
      await tester.pumpWidget(
        _app(
          _Holder<CalendarSelection>(
            const DateRangeSelection(null, null),
            (v, set) => CamoCalendar(
              selection: v,
              onSelectionChanged: (s) {
                picked = s;
                set(s);
              },
              visibleMonth: _october,
              onVisibleMonthChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.tap(find.text('14'));
      await tester.pump();
      expect(
        picked,
        DateRangeSelection(DateTime(2026, 10, 10), DateTime(2026, 10, 14)),
      );
      expect(tester.getSemantics(find.text('[10]')).value, 'start of range');
      expect(tester.getSemantics(find.text('12')).value, 'in range');
      semantics.dispose();
    });

    testWidgets('arrows move the focused day across months and Enter selects', (
      tester,
    ) async {
      var month = _october;
      CalendarSelection? picked;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => CamoCalendar(
              selection: SingleDate(DateTime(2026, 10, 30)),
              onSelectionChanged: (s) => picked = s,
              visibleMonth: month,
              onVisibleMonthChanged: (m) => setState(() => month = m),
              autofocus: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(month, const CamoYearMonth(2026, 11));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, SingleDate(DateTime(2026, 11, 7)));
    });
  });

  group('CamoDateField', () {
    testWidgets('a date field confirms with OK', (tester) async {
      DateTime? value = DateTime(2026, 10, 1);
      await tester.pumpWidget(
        _app(
          _Holder<DateTime?>(
            value,
            (v, set) => CamoDateField(
              value: v,
              onChanged: (d) {
                value = d;
                set(d);
              },
              label: 'Birth date',
              presentation: PickerPresentation.popup,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CamoDateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('14'));
      await tester.pump();
      expect(value, DateTime(2026, 10, 1));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(value, DateTime(2026, 10, 14));
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('cancel and Esc close the sheet without a change', (
      tester,
    ) async {
      DateTime? value;
      await tester.pumpWidget(
        _app(
          CamoDateField(
            value: null,
            onChanged: (d) => value = d,
            label: 'Delivery',
            presentation: PickerPresentation.sheet,
          ),
        ),
      );
      await tester.tap(find.byType(CamoDateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsNothing);
      await tester.tap(find.byType(CamoDateField));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsNothing);
      expect(value, isNull);
    });

    testWidgets(
      'typing a valid date sets it and an invalid one shows the error',
      (tester) async {
        DateTime? value;
        final typing = themeT.copyWith(
          components: const CamoComponentThemes(
            datePicker: CamoDatePickerTheme(allowTyping: AllowTyping.always),
          ),
        );
        await tester.pumpWidget(
          _app(
            _Holder<DateTime?>(
              null,
              (v, set) => CamoDateField(
                value: v,
                onChanged: (d) {
                  value = d;
                  set(d);
                },
                label: 'Due',
              ),
            ),
            theme: typing,
          ),
        );
        const pattern = 'MM/dd/yyyy'; // en_US, the test locale
        await tester.enterText(
          find.byType(EditableText),
          typedDigits(DateTime(2026, 10, 14), pattern),
        );
        await tester.pump();
        expect(value, DateTime(2026, 10, 14));
        await tester.enterText(find.byType(EditableText), '02312026');
        await tester.pump();
        expect(value, DateTime(2026, 10, 14));
        expect(find.text('Enter a valid date'), findsOneWidget);
      },
    );

    testWidgets('a required date form field fails until picked', (
      tester,
    ) async {
      final form = CamoFormController();
      await tester.pumpWidget(
        _app(
          CamoForm(
            controller: form,
            child: CamoDateFormField(
              fieldKey: 'start',
              label: 'Start',
              rules: [CamoRules.required('Pick a date')],
              presentation: PickerPresentation.popup,
            ),
          ),
        ),
      );
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick a date'), findsOneWidget);
    });
  });

  group('CamoTimeField', () {
    testWidgets('a time field takes typed parts and confirms', (tester) async {
      CamoTime? value;
      await tester.pumpWidget(
        _app(
          CamoTimeField(
            value: null,
            onChanged: (t) => value = t,
            label: 'Pickup',
            use24Hour: true,
            presentation: PickerPresentation.popup,
          ),
        ),
      );
      await tester.tap(find.byType(CamoTimeField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(0), '14');
      await tester.enterText(find.byType(EditableText).at(1), '30');
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(value, const CamoTime(hour: 14, minute: 30));
    });

    testWidgets('minutes snap to the step when left and arrows step', (
      tester,
    ) async {
      CamoTime? value = const CamoTime(hour: 10, minute: 0);
      await tester.pumpWidget(
        _app(
          _Holder<CamoTime?>(
            value,
            (v, set) => CamoTimeInput(
              value: v,
              onChanged: (t) {
                value = t;
                set(t);
              },
              minuteStep: 15,
              use24Hour: true,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).at(1), '08');
      await tester.pump();
      expect(value, const CamoTime(hour: 10, minute: 8));
      await tester.tap(find.byType(EditableText).at(0));
      await tester.pump();
      expect(value, const CamoTime(hour: 10, minute: 15));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(value, const CamoTime(hour: 11, minute: 15));
    });
  });

  group('the sheet', () {
    testWidgets('Esc and the scrim close a dismissible sheet only', (
      tester,
    ) async {
      late BuildContext opener;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) {
              opener = context;
              return const SizedBox.square(dimension: 10);
            },
          ),
        ),
      );
      Future<void> open({required bool dismissible}) async {
        showCamoSheet<void>(
          opener,
          dismissible: dismissible,
          builder: (_) => const CamoBottomSheet(
            title: 'Filters',
            child: SizedBox(height: 80),
          ),
        );
        await tester.pumpAndSettle();
      }

      await open(dismissible: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsNothing);
      await open(dismissible: true);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsNothing);
      await open(dismissible: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);
    });
  });
}
