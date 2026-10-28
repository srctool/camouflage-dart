import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M5 overlays and pickers in the plain test skin: boxes and rows, no decoration.

Widget _square(double size, Color? color) => SizedBox.square(dimension: size);

class PlainMenu implements CamoMenuRenderer {
  const PlainMenu();

  @override
  CamoMenuStyle defaults(CamoTheme theme) => CamoMenuStyle(
    shape: BorderRadius.zero,
    minWidth: 112,
    maxWidth: 280,
    itemHeight: 48,
    contentPadding: const EdgeInsetsDirectional.all(8),
    textStyle: theme.typography.labelLarge,
    iconSize: 24,
    elevation: 0,
    checkPosition: CheckPosition.trailing,
    checkIcon: const IconSource.builder(_square),
    colors: MenuColors(
      container: theme.colors.surface,
      text: theme.colors.onSurface,
      icon: theme.colors.onSurfaceVariant,
      trailingText: theme.colors.onSurfaceVariant,
    ),
  );

  @override
  Widget panel(
    BuildContext context,
    Widget child,
    CamoTheme theme,
    CamoMenuStyle style,
  ) => ColoredBox(
    color: style.colors.container,
    child: ConstrainedBox(
      constraints: BoxConstraints(minWidth: style.minWidth),
      child: child,
    ),
  );

  @override
  Widget item(
    BuildContext context,
    MenuItemState state,
    MenuItemSlots slots,
    CamoTheme theme,
    CamoMenuStyle style,
  ) => SizedBox(
    height: style.itemHeight,
    child: Row(
      children: [
        ?slots.leadingIcon,
        Text(state.text),
        if (state.trailingText case final shortcut?) Text(shortcut),
      ],
    ),
  );
}

class PlainBottomSheet implements CamoBottomSheetRenderer {
  const PlainBottomSheet();

  @override
  CamoBottomSheetStyle defaults(CamoTheme theme) => CamoBottomSheetStyle(
    shape: BorderRadius.zero,
    maxWidth: 640,
    contentPadding: const EdgeInsetsDirectional.all(16),
    showHandle: true,
    handleSize: const Size(32, 4),
    handleColor: theme.colors.outline,
    titleStyle: theme.typography.titleLarge,
    titleAlign: CamoTitleAlign.start,
    showCloseButton: false,
    closeIcon: const IconSource.builder(_square),
    containerColor: theme.colors.surface,
    scrimAlpha: 0.32,
    widePresentation: WidePresentation.sheet,
    stackedScrim: StackedScrim.each,
  );

  @override
  Widget render(
    BuildContext context,
    BottomSheetState state,
    BottomSheetSlots slots,
    CamoTheme theme,
    CamoBottomSheetStyle style,
  ) => ColoredBox(
    color: style.containerColor,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.title != null) Text(state.title!, style: style.titleStyle),
        Flexible(child: slots.content),
      ],
    ),
  );
}

class PlainDatePicker implements CamoDatePickerRenderer {
  const PlainDatePicker();

  @override
  CamoDatePickerStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoDatePickerStyle(
      form: DatePickerForm.calendar,
      firstDayOfWeek: null,
      displayFormat: null,
      confirmButton: true,
      allowTyping: AllowTyping.never,
      showOutsideDays: false,
      daySize: 60,
      autoPopupMinWidth: 600,
      contentPadding: const EdgeInsetsDirectional.all(8),
      headerStyle: t.titleMedium,
      weekdayStyle: t.labelMedium,
      dayStyle: t.bodyMedium,
      wheelTextStyle: t.bodyLarge,
      wheelItemHeight: 40,
      calendarIcon: const IconSource.builder(_square),
      previousIcon: const IconSource.builder(_square),
      nextIcon: const IconSource.builder(_square),
      colors: DatePickerColors(
        selected: c.primary,
        onSelected: c.onPrimary,
        range: c.primaryContainer,
        onRange: c.onPrimaryContainer,
        today: c.outline,
        day: c.onSurface,
        weekday: c.onSurfaceVariant,
        disabled: c.outline,
      ),
      strings: const DatePickerStrings(),
    );
  }

  @override
  Widget calendar(
    BuildContext context,
    CalendarState state,
    CalendarSlots slots,
    CamoTheme theme,
    CamoDatePickerStyle style,
  ) => SizedBox(
    width: style.daySize * 7,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            slots.previous,
            Expanded(child: slots.header),
            slots.next,
          ],
        ),
        if (state.choosingYear)
          SizedBox(height: 280, child: slots.years)
        else ...[
          Row(
            children: [
              for (final w in state.weekdayLabels)
                SizedBox.square(dimension: style.daySize, child: Text(w)),
            ],
          ),
          for (var week = 0; week < 6; week++)
            Row(
              children: [
                for (final d in state.days.skip(week * 7).take(7)) slots.day(d),
              ],
            ),
        ],
      ],
    ),
  );

  @override
  Widget cell(
    BuildContext context,
    CalendarCell cell,
    CamoTheme theme,
    CamoDatePickerStyle style,
  ) {
    final box = SizedBox(
      width: cell.kind == CalendarCellKind.year ? null : style.daySize,
      height: style.daySize,
      child: Center(
        child: Text(cell.selected ? '[${cell.label}]' : cell.label),
      ),
    );
    return cell.inMonth || style.showOutsideDays
        ? cell.wrap(box)
        : SizedBox.square(dimension: style.daySize);
  }

  @override
  Widget wheels(
    BuildContext context,
    List<Widget> wheels,
    CamoTheme theme,
    CamoDatePickerStyle style,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [for (final w in wheels) SizedBox(width: 64, child: w)],
  );
}

class PlainTimePicker implements CamoTimePickerRenderer {
  const PlainTimePicker();

  @override
  CamoTimePickerStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoTimePickerStyle(
      form: TimePickerForm.fields,
      confirmButton: true,
      digitStyle: t.headlineSmall,
      dialTextStyle: t.bodyMedium,
      wheelTextStyle: t.bodyLarge,
      wheelItemHeight: 40,
      fieldSize: 64,
      dialSize: 240,
      autoPopupMinWidth: 600,
      contentPadding: const EdgeInsetsDirectional.all(8),
      clockIcon: const IconSource.builder(_square),
      colors: TimePickerColors(
        active: c.primary,
        activeContainer: c.primaryContainer,
        face: c.surfaceContainerHighest,
        digits: c.onSurface,
        period: c.onSurfaceVariant,
      ),
      strings: const TimePickerStrings(),
    );
  }

  @override
  Widget render(
    BuildContext context,
    TimePickerState state,
    TimePickerSlots slots,
    CamoTheme theme,
    CamoTimePickerStyle style,
  ) {
    final wheels = slots.wheels;
    if (wheels != null) {
      return Row(mainAxisSize: MainAxisSize.min, children: wheels);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [slots.hour, const Text(':'), slots.minute, ?slots.period],
        ),
        ?slots.dial,
      ],
    );
  }

  @override
  Widget dial(
    BuildContext context,
    DialState state,
    CamoTheme theme,
    CamoTimePickerStyle style,
  ) => ColoredBox(color: style.colors.face);

  @override
  Widget wheels(
    BuildContext context,
    List<Widget> wheels,
    CamoTheme theme,
    CamoTimePickerStyle style,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [for (final w in wheels) SizedBox(width: 64, child: w)],
  );
}
