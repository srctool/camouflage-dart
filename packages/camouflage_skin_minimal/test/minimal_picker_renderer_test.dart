import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// The M5 pickers and popup panel against the contract: a day's behavior on its whole cell, theme fields honored.
void main() {
  const skin = minimalSkin;
  final theme = minimalLight;
  const month = CamoYearMonth(2024, 3);

  testWidgets('a day cell takes taps across its box', (tester) async {
    var picks = 0;
    await tester.pumpWidget(
      camoTestApp(
        skin: skin,
        theme: theme,
        child: CamoCalendar(
          selection: const SingleDate(null),
          onSelectionChanged: (_) => picks++,
          visibleMonth: month,
          onVisibleMonthChanged: (_) {},
        ),
      ),
    );
    final day = tester.getRect(find.text('14'));
    final size = skin.datePicker.defaults(theme).daySize;
    final cell = Rect.fromCenter(center: day.center, width: size, height: size);
    await tester.tapAt(cell.topLeft + const Offset(1, 1));
    await tester.tapAt(cell.center);
    await tester.pump();
    expect(picks, 2);
  });

  testWidgets('the calendar honors daySize', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoDatePickerTheme(daySize: 50),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(datePicker: o),
        child: CamoCalendar(
          selection: const SingleDate(null),
          onSelectionChanged: (_) {},
          visibleMonth: month,
          onVisibleMonthChanged: (_) {},
        ),
      ),
      measure: (size) => size.width == 350,
    );
  });

  testWidgets('the time boxes honor fieldSize', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoTimePickerTheme(fieldSize: 77),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(timePicker: o),
        child: CamoTimeInput(
          value: const CamoTime(hour: 9, minute: 0),
          onChanged: (_) {},
          use24Hour: true,
        ),
      ),
      measure: (size) => size.height == 77,
    );
  });

  testWidgets('the popup panel honors minWidth', (tester) async {
    await assertNoLiterals(
      tester,
      skin: skin,
      theme: theme,
      oddStyle: const CamoMenuTheme(minWidth: 333),
      build: (o) => ProvideComponentThemes(
        components: CamoComponentThemes(menu: o),
        child: const CamoMenuPanel(child: CamoText('Hi')),
      ),
      measure: (size) => size.width == 333,
    );
  });
}
