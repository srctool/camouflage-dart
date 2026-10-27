import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../button/camo_button.dart';
import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import 'camo_dates.dart';

/// Every color a date picker uses.
@immutable
class DatePickerColors {
  /// Creates date picker colors.
  const DatePickerColors({
    required this.selected,
    required this.onSelected,
    required this.range,
    required this.onRange,
    required this.today,
    required this.day,
    required this.weekday,
    required this.disabled,
  });

  /// The selected day's fill.
  final Color selected;

  /// Text on [selected].
  final Color onSelected;

  /// The range band.
  final Color range;

  /// Text on [range].
  final Color onRange;

  /// Today's mark.
  final Color today;

  /// A day's text.
  final Color day;

  /// The weekday row, and other months' days.
  final Color weekday;

  /// Unavailable days.
  final Color disabled;

  @override
  bool operator ==(Object other) =>
      other is DatePickerColors &&
      other.selected == selected &&
      other.onSelected == onSelected &&
      other.range == range &&
      other.onRange == onRange &&
      other.today == today &&
      other.day == day &&
      other.weekday == weekday &&
      other.disabled == disabled;

  @override
  int get hashCode => Object.hash(
    selected,
    onSelected,
    range,
    onRange,
    today,
    day,
    weekday,
    disabled,
  );
}

/// The date picker's words, for the app to translate through its theme.
@immutable
class DatePickerStrings {
  /// Creates the strings; every one has an English default.
  const DatePickerStrings({
    this.chooseDate = 'Choose date',
    this.cancel = 'Cancel',
    this.ok = 'OK',
    this.done = 'Done',
    this.clear = 'Clear',
    this.previousMonth = 'Previous month',
    this.nextMonth = 'Next month',
    this.chooseYear = 'Choose year',
    this.today = 'today',
    this.unavailable = 'unavailable',
    this.rangeStart = 'start of range',
    this.rangeEnd = 'end of range',
    this.inRange = 'in range',
    this.day = 'Day',
    this.month = 'Month',
    this.year = 'Year',
    this.invalidDate = 'Enter a valid date',
    this.outOfRange = 'Enter a date within the allowed range',
  });

  /// The field's picker button.
  final String chooseDate;

  /// Closes without a change.
  final String cancel;

  /// Confirms a single date.
  final String ok;

  /// Confirms a range.
  final String done;

  /// Clears a range.
  final String clear;

  /// The header's previous button.
  final String previousMonth;

  /// The header's next button.
  final String nextMonth;

  /// The month header's action.
  final String chooseYear;

  /// A day's "today" state.
  final String today;

  /// A disabled day's state.
  final String unavailable;

  /// A range's first day.
  final String rangeStart;

  /// A range's last day.
  final String rangeEnd;

  /// A day inside a range.
  final String inRange;

  /// The day wheel.
  final String day;

  /// The month wheel.
  final String month;

  /// The year wheel.
  final String year;

  /// A typed date that isn't one.
  final String invalidDate;

  /// A typed date outside the limits.
  final String outOfRange;
}

/// Overrides for date pickers and date fields; `null` keeps the skin's default.
@immutable
class CamoDatePickerTheme {
  /// Creates date picker overrides.
  const CamoDatePickerTheme({
    this.form,
    this.firstDayOfWeek,
    this.displayFormat,
    this.confirmButton,
    this.allowTyping,
    this.showOutsideDays,
    this.daySize,
    this.autoPopupMinWidth,
    this.contentPadding,
    this.headerStyle,
    this.weekdayStyle,
    this.dayStyle,
    this.wheelTextStyle,
    this.wheelItemHeight,
    this.calendarIcon,
    this.previousIcon,
    this.nextIcon,
    this.colors,
    this.strings,
  });

  /// Calendar or wheels.
  final DatePickerForm? form;

  /// `DateTime.monday` … `DateTime.sunday`; `null` follows the locale.
  final int? firstDayOfWeek;

  /// The field's date pattern ("d MMM yyyy"); `null` uses the locale's medium date.
  final String? displayFormat;

  /// Cancel/OK for single dates.
  final bool? confirmButton;

  /// Typing in the date field.
  final AllowTyping? allowTyping;

  /// Other months' days in the grid.
  final bool? showOutsideDays;

  /// A day cell's size.
  final double? daySize;

  /// From this window width, `auto` uses a popup.
  final double? autoPopupMinWidth;

  /// Around the picker in its popup or sheet.
  final EdgeInsetsDirectional? contentPadding;

  /// The month header.
  final TextStyle? headerStyle;

  /// The weekday row.
  final TextStyle? weekdayStyle;

  /// The days.
  final TextStyle? dayStyle;

  /// The wheels' rows.
  final TextStyle? wheelTextStyle;

  /// A wheel row's height.
  final double? wheelItemHeight;

  /// The field's icon.
  final IconSource? calendarIcon;

  /// The header's previous icon (drawn for left to right; core swaps them in right to left).
  final IconSource? previousIcon;

  /// The header's next icon.
  final IconSource? nextIcon;

  /// Every color it uses.
  final DatePickerColors? colors;

  /// Its words.
  final DatePickerStrings? strings;

  /// A copy with the given fields replaced.
  CamoDatePickerTheme copyWith({
    DatePickerForm? form,
    int? firstDayOfWeek,
    String? displayFormat,
    bool? confirmButton,
    AllowTyping? allowTyping,
    bool? showOutsideDays,
    double? daySize,
    double? autoPopupMinWidth,
    EdgeInsetsDirectional? contentPadding,
    TextStyle? headerStyle,
    TextStyle? weekdayStyle,
    TextStyle? dayStyle,
    TextStyle? wheelTextStyle,
    double? wheelItemHeight,
    IconSource? calendarIcon,
    IconSource? previousIcon,
    IconSource? nextIcon,
    DatePickerColors? colors,
    DatePickerStrings? strings,
  }) => CamoDatePickerTheme(
    form: form ?? this.form,
    firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    displayFormat: displayFormat ?? this.displayFormat,
    confirmButton: confirmButton ?? this.confirmButton,
    allowTyping: allowTyping ?? this.allowTyping,
    showOutsideDays: showOutsideDays ?? this.showOutsideDays,
    daySize: daySize ?? this.daySize,
    autoPopupMinWidth: autoPopupMinWidth ?? this.autoPopupMinWidth,
    contentPadding: contentPadding ?? this.contentPadding,
    headerStyle: headerStyle ?? this.headerStyle,
    weekdayStyle: weekdayStyle ?? this.weekdayStyle,
    dayStyle: dayStyle ?? this.dayStyle,
    wheelTextStyle: wheelTextStyle ?? this.wheelTextStyle,
    wheelItemHeight: wheelItemHeight ?? this.wheelItemHeight,
    calendarIcon: calendarIcon ?? this.calendarIcon,
    previousIcon: previousIcon ?? this.previousIcon,
    nextIcon: nextIcon ?? this.nextIcon,
    colors: colors ?? this.colors,
    strings: strings ?? this.strings,
  );
}

/// The resolved date picker style. [firstDayOfWeek] and [displayFormat] stay `null` to follow the locale.
@immutable
class CamoDatePickerStyle {
  /// Creates a date picker style.
  const CamoDatePickerStyle({
    required this.form,
    required this.firstDayOfWeek,
    required this.displayFormat,
    required this.confirmButton,
    required this.allowTyping,
    required this.showOutsideDays,
    required this.daySize,
    required this.autoPopupMinWidth,
    required this.contentPadding,
    required this.headerStyle,
    required this.weekdayStyle,
    required this.dayStyle,
    required this.wheelTextStyle,
    required this.wheelItemHeight,
    required this.calendarIcon,
    required this.previousIcon,
    required this.nextIcon,
    required this.colors,
    required this.strings,
  });

  /// Calendar or wheels.
  final DatePickerForm form;

  /// `null` follows the locale.
  final int? firstDayOfWeek;

  /// `null` uses the locale's medium date.
  final String? displayFormat;

  /// Cancel/OK for single dates.
  final bool confirmButton;

  /// Typing in the date field.
  final AllowTyping allowTyping;

  /// Other months' days in the grid.
  final bool showOutsideDays;

  /// A day cell's size.
  final double daySize;

  /// From this window width, `auto` uses a popup.
  final double autoPopupMinWidth;

  /// Around the picker in its popup or sheet.
  final EdgeInsetsDirectional contentPadding;

  /// The month header.
  final TextStyle headerStyle;

  /// The weekday row.
  final TextStyle weekdayStyle;

  /// The days.
  final TextStyle dayStyle;

  /// The wheels' rows.
  final TextStyle wheelTextStyle;

  /// A wheel row's height.
  final double wheelItemHeight;

  /// The field's icon.
  final IconSource calendarIcon;

  /// The header's previous icon.
  final IconSource previousIcon;

  /// The header's next icon.
  final IconSource nextIcon;

  /// Every color it uses.
  final DatePickerColors colors;

  /// Its words.
  final DatePickerStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoDatePickerStyle merge(CamoDatePickerTheme? o) => o == null
      ? this
      : CamoDatePickerStyle(
          form: o.form ?? form,
          firstDayOfWeek: o.firstDayOfWeek ?? firstDayOfWeek,
          displayFormat: o.displayFormat ?? displayFormat,
          confirmButton: o.confirmButton ?? confirmButton,
          allowTyping: o.allowTyping ?? allowTyping,
          showOutsideDays: o.showOutsideDays ?? showOutsideDays,
          daySize: o.daySize ?? daySize,
          autoPopupMinWidth: o.autoPopupMinWidth ?? autoPopupMinWidth,
          contentPadding: o.contentPadding ?? contentPadding,
          headerStyle: o.headerStyle ?? headerStyle,
          weekdayStyle: o.weekdayStyle ?? weekdayStyle,
          dayStyle: o.dayStyle ?? dayStyle,
          wheelTextStyle: o.wheelTextStyle ?? wheelTextStyle,
          wheelItemHeight: o.wheelItemHeight ?? wheelItemHeight,
          calendarIcon: o.calendarIcon ?? calendarIcon,
          previousIcon: o.previousIcon ?? previousIcon,
          nextIcon: o.nextIcon ?? nextIcon,
          colors: o.colors ?? colors,
          strings: o.strings ?? strings,
        );
}

/// A day in the month grid. Days of the next or previous month are `inMonth: false`.
@immutable
class CalendarDay {
  /// Creates a day.
  const CalendarDay({
    required this.date,
    required this.inMonth,
    required this.enabled,
    required this.selected,
    required this.rangePosition,
    required this.isToday,
  });

  /// The date.
  final DateTime date;

  /// In the visible month.
  final bool inMonth;

  /// Can be picked.
  final bool enabled;

  /// The selected date, or a range end.
  final bool selected;

  /// Its place in the selected range.
  final RangePosition rangePosition;

  /// Today.
  final bool isToday;
}

/// What a calendar cell is: a day of the grid, or a year of the year list.
enum CalendarCellKind {
  /// A day of the month grid.
  day,

  /// A year of the year list.
  year,
}

/// One cell, drawn by the renderer: its [label] ("14", "2026"), its state, and [wrap], core's behavior (the tap,
/// focus and the full-date announcement) for the renderer to wrap its visual in.
@immutable
class CalendarCell {
  /// Creates a cell.
  const CalendarCell({
    required this.label,
    required this.kind,
    required this.inMonth,
    required this.enabled,
    required this.selected,
    required this.rangePosition,
    required this.isToday,
    required this.interaction,
    required this.controller,
    required this.wrap,
  });

  /// "14" or "2026".
  final String label;

  /// A day or a year.
  final CalendarCellKind kind;

  /// In the visible month.
  final bool inMonth;

  /// Can be picked.
  final bool enabled;

  /// Selected.
  final bool selected;

  /// Its place in the selected range.
  final RangePosition rangePosition;

  /// Today, or this year.
  final bool isToday;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;

  /// Wraps the cell's visual in its behavior.
  final Widget Function(Widget visual) wrap;
}

/// What a calendar renderer draws: the header ([monthLabel] in core's [CalendarSlots.header] button, previous and
/// next), then either the weekday row and the six weeks of [days] (seven each, in order), or, while
/// [choosingYear], the year list.
@immutable
class CalendarState {
  /// Creates a calendar state.
  const CalendarState({
    required this.visibleMonth,
    required this.monthLabel,
    required this.weekdayLabels,
    required this.days,
    required this.showOutsideDays,
    required this.choosingYear,
  });

  /// The month shown.
  final CamoYearMonth visibleMonth;

  /// "October 2026".
  final String monthLabel;

  /// Narrow weekday names in grid order.
  final List<String> weekdayLabels;

  /// The 42 days of the grid.
  final List<CalendarDay> days;

  /// Other months' days are drawn.
  final bool showOutsideDays;

  /// The year list is open.
  final bool choosingYear;
}

/// The calendar's parts, built by core: the header buttons, one day cell, and the year list.
@immutable
class CalendarSlots {
  /// Creates the slots.
  const CalendarSlots({
    required this.header,
    required this.previous,
    required this.next,
    required this.day,
    required this.years,
  });

  /// The month label, a button opening the year list.
  final Widget header;

  /// The previous month.
  final Widget previous;

  /// The next month.
  final Widget next;

  /// Builds a day's cell.
  final Widget Function(CalendarDay day) day;

  /// The year list.
  final Widget years;
}

/// Draws date pickers: the calendar, its cells and the wheels.
abstract interface class CamoDatePickerRenderer {
  /// The complete date picker style for [theme].
  CamoDatePickerStyle defaults(CamoTheme theme);

  /// The month: header, weekday row and grid (or the year list), from [slots].
  Widget calendar(
    BuildContext context,
    CalendarState state,
    CalendarSlots slots,
    CamoTheme theme,
    CamoDatePickerStyle style,
  );

  /// One day or year cell; an `inMonth: false` day is blank unless `style.showOutsideDays`. Wrap the visual
  /// in [CalendarCell.wrap].
  Widget cell(
    BuildContext context,
    CalendarCell cell,
    CamoTheme theme,
    CamoDatePickerStyle style,
  );

  /// The wheels side by side, with the band behind the middle row (`wheelRows` rows of `wheelItemHeight`).
  Widget wheels(
    BuildContext context,
    List<Widget> wheels,
    CamoTheme theme,
    CamoDatePickerStyle style,
  );
}

const _yearsBack = 120;
const _yearsAhead = 50;
const _yearColumns = 3;
const _daysInWeek = 7;

/// A month calendar (ADR-30): for booking screens and custom pickers, and inside the date fields. Everything is
/// controlled: [selection] and [visibleMonth] come from the caller, which a booking screen can use to show two
/// months side by side. Days outside [firstDate]…[lastDate], refused by [selectableDayPredicate] or, for a range
/// with a start, more than [maxRangeLength] days on, are shown but disabled. A single date's tap selects it; a
/// range's first tap sets the start and the second the end.
///
/// Keyboard: arrows move by day and week (mirrored right to left), PageUp/PageDown by month, with Shift by year,
/// Home/End to the week's ends, Enter or Space selects. The header opens a year list. With [autofocus] the focus
/// day takes focus when the calendar appears.
class CamoCalendar extends StatefulWidget {
  /// Creates a calendar.
  const CamoCalendar({
    super.key,
    required this.selection,
    required this.onSelectionChanged,
    required this.visibleMonth,
    required this.onVisibleMonthChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.maxRangeLength,
    this.autofocus = false,
  });

  /// One date or a range.
  final CalendarSelection selection;

  /// Called with each pick.
  final ValueChanged<CalendarSelection> onSelectionChanged;

  /// The month shown.
  final CamoYearMonth visibleMonth;

  /// Called by the header buttons, the year list and keyboard moves across months.
  final ValueChanged<CamoYearMonth> onVisibleMonthChanged;

  /// The earliest day.
  final DateTime? firstDate;

  /// The latest day.
  final DateTime? lastDate;

  /// `false` disables a day (weekends, holidays).
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The longest range, once a start is picked.
  final int? maxRangeLength;

  /// The focus day takes focus when it appears.
  final bool autofocus;

  @override
  State<CamoCalendar> createState() => _CamoCalendarState();
}

class _CamoCalendarState extends State<CamoCalendar> {
  final _controllers = List.generate(42, (_) => CamoInteractionController());
  final _nodes = List.generate(42, (i) => FocusNode(debugLabel: 'day $i'));
  late DateTime _focusDate = _initialFocus();
  late final DateTime _today = dateOnly(DateTime.now());
  bool _choosingYear = false;

  DateTime _initialFocus() {
    final selected = switch (widget.selection) {
      SingleDate(:final date) => date,
      DateRangeSelection(:final start) => start,
    };
    final month = widget.visibleMonth;
    if (selected != null && CamoYearMonth.of(selected) == month) {
      return dateOnly(selected);
    }
    final today = dateOnly(DateTime.now());
    return CamoYearMonth.of(today) == month ? today : month.firstDay;
  }

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) _focusSoon();
  }

  @override
  void didUpdateWidget(CamoCalendar old) {
    super.didUpdateWidget(old);
    if (CamoYearMonth.of(_focusDate) != widget.visibleMonth) {
      _focusDate = widget.visibleMonth.dayLike(_focusDate);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  // Focuses the focus day's cell once the grid shows it.
  void _focusSoon() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final firstDay = _firstDay();
    final index = monthGrid(
      widget.visibleMonth,
      firstDay,
    ).indexWhere((d) => sameDay(d, _focusDate));
    if (index >= 0) _nodes[index].requestFocus();
  });

  int _firstDay() =>
      _style().firstDayOfWeek ?? CamoDateLocale.of(context).firstDayOfWeek;

  CamoDatePickerStyle _style() {
    final skin = Camouflage.skinOf(context, component: 'CamoCalendar');
    final theme = Camouflage.themeOf(context, component: 'CamoCalendar');
    return skin.datePicker.defaults(theme).merge(theme.components.datePicker);
  }

  DateTime? get _rangeStart => switch (widget.selection) {
    DateRangeSelection(:final start, :final end) when end == null => start,
    _ => null,
  };

  bool _enabled(DateTime d) => dateSelectable(
    d,
    widget.firstDate,
    widget.lastDate,
    widget.selectableDayPredicate,
    rangeStart: _rangeStart,
    maxLength: widget.maxRangeLength,
  );

  void _select(DateTime date) {
    if (!_enabled(date)) return;
    setState(() => _focusDate = date);
    widget.onSelectionChanged(switch (widget.selection) {
      SingleDate() => SingleDate(date),
      final DateRangeSelection range => range.tap(date),
    });
  }

  void _moveTo(DateTime date) {
    setState(() => _focusDate = date);
    final month = CamoYearMonth.of(date);
    if (month != widget.visibleMonth) widget.onVisibleMonthChanged(month);
    _focusSoon();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _choosingYear) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final forward = rtl ? -1 : 1;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final from = _focusDate;
    final inWeek = (from.weekday - _firstDay() + _daysInWeek) % _daysInWeek;
    final target = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => addDays(from, -forward),
      LogicalKeyboardKey.arrowRight => addDays(from, forward),
      LogicalKeyboardKey.arrowUp => addDays(from, -_daysInWeek),
      LogicalKeyboardKey.arrowDown => addDays(from, _daysInWeek),
      LogicalKeyboardKey.pageUp => _shiftMonths(from, shift ? -12 : -1),
      LogicalKeyboardKey.pageDown => _shiftMonths(from, shift ? 12 : 1),
      LogicalKeyboardKey.home => addDays(from, -inWeek),
      LogicalKeyboardKey.end => addDays(from, _daysInWeek - 1 - inWeek),
      _ => null,
    };
    if (target == null) return KeyEventResult.ignored;
    _moveTo(target);
    return KeyEventResult.handled;
  }

  DateTime _shiftMonths(DateTime from, int months) =>
      CamoYearMonth.of(from).plusMonths(months).dayLike(from);

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoCalendar');
    final theme = Camouflage.themeOf(context, component: 'CamoCalendar');
    final style = skin.datePicker
        .defaults(theme)
        .merge(theme.components.datePicker);
    final locale = CamoDateLocale.of(context);
    final firstDay = style.firstDayOfWeek ?? locale.firstDayOfWeek;
    final month = widget.visibleMonth;
    final grid = monthGrid(month, firstDay);
    final days = [for (final date in grid) _day(date, month)];
    final strings = style.strings;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final canGoBack =
        widget.firstDate == null || month > CamoYearMonth.of(widget.firstDate!);
    final canGoOn =
        widget.lastDate == null || month < CamoYearMonth.of(widget.lastDate!);
    final monthLabel = locale.monthYear(month);
    final slots = CalendarSlots(
      header: Semantics(
        liveRegion: true,
        hint: strings.chooseYear,
        child: CamoButton(
          text: monthLabel,
          onPressed: () => setState(() => _choosingYear = !_choosingYear),
          appearance: Appearance.ghost,
        ),
      ),
      previous: CamoIconButton(
        icon: CamoIcon(rtl ? style.nextIcon : style.previousIcon),
        semanticLabel: strings.previousMonth,
        onPressed: canGoBack && !_choosingYear
            ? () => widget.onVisibleMonthChanged(month.plusMonths(-1))
            : null,
        appearance: Appearance.ghost,
      ),
      next: CamoIconButton(
        icon: CamoIcon(rtl ? style.previousIcon : style.nextIcon),
        semanticLabel: strings.nextMonth,
        onPressed: canGoOn && !_choosingYear
            ? () => widget.onVisibleMonthChanged(month.plusMonths(1))
            : null,
        appearance: Appearance.ghost,
      ),
      day: (day) => _dayCell(
        day,
        grid.indexWhere((d) => sameDay(d, day.date)),
        locale,
        style,
        theme,
      ),
      years: _YearList(
        month: month,
        today: _today,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        style: style,
        theme: theme,
        onPick: (year) {
          widget.onVisibleMonthChanged(CamoYearMonth(year, month.month));
          setState(() => _choosingYear = false);
        },
      ),
    );
    return Focus(
      onKeyEvent: _onKey,
      canRequestFocus: false,
      skipTraversal: true,
      child: skin.datePicker.calendar(
        context,
        CalendarState(
          visibleMonth: month,
          monthLabel: monthLabel,
          weekdayLabels: weekdayOrder(locale.narrowWeekdays, firstDay),
          days: days,
          showOutsideDays: style.showOutsideDays,
          choosingYear: _choosingYear,
        ),
        slots,
        theme,
        style,
      ),
    );
  }

  CalendarDay _day(DateTime date, CamoYearMonth month) {
    final RangePosition position;
    final bool selected;
    switch (widget.selection) {
      case SingleDate(date: final picked):
        position = RangePosition.none;
        selected = sameDay(date, picked);
      case DateRangeSelection(:final start, :final end):
        position = rangePosition(date, start, end);
        selected =
            position != RangePosition.none && position != RangePosition.middle;
    }
    return CalendarDay(
      date: date,
      inMonth: CamoYearMonth.of(date) == month,
      enabled: _enabled(date),
      selected: selected,
      rangePosition: position,
      isToday: sameDay(date, _today),
    );
  }

  Widget _dayCell(
    CalendarDay day,
    int index,
    CamoDateLocale locale,
    CamoDatePickerStyle style,
    CamoTheme theme,
  ) {
    final skin = Camouflage.skinOf(context);
    final controller = _controllers[index];
    final shown = day.inMonth || style.showOutsideDays;
    final strings = style.strings;
    final states = [
      if (day.isToday) strings.today,
      if (day.rangePosition == RangePosition.start) strings.rangeStart,
      if (day.rangePosition == RangePosition.end) strings.rangeEnd,
      if (day.rangePosition == RangePosition.middle) strings.inRange,
      if (!day.enabled) strings.unavailable,
    ];
    final focusTarget = sameDay(day.date, _focusDate);
    Widget wrap(Widget visual) {
      if (!shown) return ExcludeSemantics(child: visual);
      return ExcludeFocus(
        excluding: !focusTarget,
        child: CamoBehavior(
          controller: controller,
          enabled: day.enabled,
          focusNode: _nodes[index],
          onActivate: () => _select(day.date),
          semantics: (child) => Semantics(
            button: true,
            selected: day.selected,
            enabled: day.enabled,
            label: locale.fullDate(day.date),
            value: states.isEmpty ? null : states.join(', '),
            excludeSemantics: true,
            child: child,
          ),
          child: visual,
        ),
      );
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => skin.datePicker.cell(
        context,
        CalendarCell(
          label: '${day.date.day}',
          kind: CalendarCellKind.day,
          inMonth: day.inMonth,
          enabled: day.enabled,
          selected: day.selected,
          rangePosition: day.rangePosition,
          isToday: day.isToday,
          interaction: controller.value,
          controller: controller,
          wrap: wrap,
        ),
        theme,
        style,
      ),
    );
  }
}

// The years to choose from, the visible year near the top; years outside the limits aren't listed.
class _YearList extends StatefulWidget {
  const _YearList({
    required this.month,
    required this.today,
    required this.firstDate,
    required this.lastDate,
    required this.style,
    required this.theme,
    required this.onPick,
  });

  final CamoYearMonth month;
  final DateTime today;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final CamoDatePickerStyle style;
  final CamoTheme theme;
  final ValueChanged<int> onPick;

  @override
  State<_YearList> createState() => _YearListState();
}

class _YearListState extends State<_YearList> {
  late final int _first =
      widget.firstDate?.year ?? widget.month.year - _yearsBack;
  late final int _last =
      widget.lastDate?.year ?? widget.month.year + _yearsAhead;
  late final _scroll = ScrollController(
    initialScrollOffset:
        ((widget.month.year - _first) ~/ _yearColumns - 1).clamp(0, 1 << 20) *
        widget.style.daySize,
  );
  final _controllers = <int, CamoInteractionController>{};

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context);
    return GridView.builder(
      controller: _scroll,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _yearColumns,
        mainAxisExtent: widget.style.daySize,
      ),
      itemCount: _last - _first + 1,
      itemBuilder: (context, i) {
        final year = _first + i;
        final controller = _controllers.putIfAbsent(
          year,
          CamoInteractionController.new,
        );
        final selected = year == widget.month.year;
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) => skin.datePicker.cell(
            context,
            CalendarCell(
              label: '$year',
              kind: CalendarCellKind.year,
              inMonth: true,
              enabled: true,
              selected: selected,
              rangePosition: RangePosition.none,
              isToday: year == widget.today.year,
              interaction: controller.value,
              controller: controller,
              wrap: (visual) => CamoBehavior(
                controller: controller,
                enabled: true,
                onActivate: () => widget.onPick(year),
                semantics: (child) =>
                    Semantics(button: true, selected: selected, child: child),
                child: visual,
              ),
            ),
            widget.theme,
            widget.style,
          ),
        );
      },
    );
  }
}
