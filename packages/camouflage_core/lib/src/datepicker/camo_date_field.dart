import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../button/camo_button.dart';
import '../icon/camo_icon.dart';
import '../overlay/camo_overlay_routes.dart';
import '../bottom_sheet/camo_bottom_sheet.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../textfield/camo_formats.dart';
import '../textfield/camo_text_field.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_wheel.dart';
import 'camo_calendar.dart';
import 'camo_dates.dart';

/// The resolved date picker style for [context].
CamoDatePickerStyle datePickerStyleOf(BuildContext context, String component) {
  final skin = Camouflage.skinOf(context, component: component);
  final theme = Camouflage.themeOf(context, component: component);
  return skin.datePicker.defaults(theme).merge(theme.components.datePicker);
}

/// Opens a field's picker: anchored under [anchor] in the skin's popup panel, or in a bottom sheet titled
/// [title]. `auto` picks the popup from [autoPopupMinWidth] of window width.
Future<T?> openFieldPicker<T>(
  BuildContext anchor, {
  required PickerPresentation presentation,
  required double autoPopupMinWidth,
  required String? title,
  required WidgetBuilder builder,
}) {
  final popup = switch (presentation) {
    PickerPresentation.popup => true,
    PickerPresentation.sheet => false,
    PickerPresentation.auto =>
      MediaQuery.sizeOf(anchor).width >= autoPopupMinWidth,
  };
  if (popup) return showCamoAnchoredPopup<T>(anchor, builder: builder);
  return showCamoBottomSheet<T>(
    context: anchor,
    builder: (context) => CamoBottomSheet(
      title: title,
      child: SingleChildScrollView(child: Center(child: builder(context))),
    ),
  );
}

/// Whether the platform has a hardware keyboard and a pointer by default (desktop and web), so typing beats
/// picking.
bool get prefersTyping =>
    kIsWeb ||
    const {
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);

/// A read-only field that opens a picker: the text-field frame (focused while open) with [text] or the
/// [placeholder], the picker's [icon] at the end, and the whole field one button announced as a pop-up.
class CamoPickerField extends StatefulWidget {
  /// Creates a picker field.
  const CamoPickerField({
    super.key,
    required this.text,
    required this.icon,
    required this.onOpen,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.enabled = true,
    this.open = false,
    this.focusNode,
    this.onFocusChanged,
    this.prefixIcon,
  });

  /// The value's text, or `null` when empty.
  final String? text;

  /// The picker's icon.
  final IconSource icon;

  /// Opens the picker; called with this field's context, which anchors a popup.
  final void Function(BuildContext anchor) onOpen;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// `false` disables it.
  final bool enabled;

  /// The picker is open, so the field looks focused.
  final bool open;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  /// Reports focus changes.
  final ValueChanged<bool>? onFocusChanged;

  /// An icon at the start of the field.
  final Widget? prefixIcon;

  @override
  State<CamoPickerField> createState() => _CamoPickerFieldState();
}

class _CamoPickerFieldState extends State<CamoPickerField> {
  final _controller = CamoInteractionController();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  void _changed() {
    final focused = _controller.value.focused;
    if (focused != _focused) {
      _focused = focused;
      widget.onFocusChanged?.call(focused);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final skin = Camouflage.skinOf(context, component: 'CamoPickerField');
    final theme = Camouflage.themeOf(context, component: 'CamoPickerField');
    final field = skin.textField
        .defaults(theme)
        .merge(theme.components.textField);
    final focused = _focused || w.open;
    // A floating label rests where the placeholder would be, so the placeholder waits for focus there.
    final resting =
        field.labelPlacement == LabelPlacement.floating &&
        w.label != null &&
        !focused;
    final shown = w.text ?? (resting ? '' : w.placeholder ?? '');
    return CamoBehavior(
      controller: _controller,
      enabled: w.enabled,
      focusNode: w.focusNode,
      onActivate: () => w.onOpen(context),
      semantics: (child) => Semantics(
        button: true,
        expanded: w.open,
        value: w.text,
        child: child,
      ),
      child: CamoFieldFrame(
        focused: focused,
        isEmpty: w.text == null,
        label: w.label,
        supportingText: w.supportingText,
        error: w.error,
        prefixIcon: w.prefixIcon,
        suffixIcon: CamoIcon(w.icon),
        enabled: w.enabled,
        child: ExcludeSemantics(
          child: Text(
            shown,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: field.textStyle.copyWith(
              color: w.text == null
                  ? field.colors.placeholder
                  : field.colors.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// A date field: the text-field frame showing [value] in `CamoDatePickerTheme.displayFormat` (or the locale's
/// medium date), opening a calendar (or wheels, per `CamoDatePickerTheme.form`) in a popup on wide windows and a
/// bottom sheet otherwise ([presentation]). Single dates confirm with Cancel/OK unless `confirmButton` is off,
/// when a tap picks and closes.
///
/// On desktop and web (`allowTyping: auto`) the field also takes typing in the locale's short date pattern; a
/// complete, valid date in range calls [onChanged], anything else shows "Enter a valid date" and leaves [value]
/// alone. Values are date-only `DateTime`s.
class CamoDateField extends StatefulWidget {
  /// Creates a date field.
  const CamoDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.presentation = PickerPresentation.auto,
    this.enabled = true,
    this.onFocusChanged,
    this.focusNode,
  });

  /// The date, or `null`.
  final DateTime? value;

  /// Called with each picked or typed date.
  final ValueChanged<DateTime> onChanged;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// The earliest date.
  final DateTime? firstDate;

  /// The latest date.
  final DateTime? lastDate;

  /// `false` disables a day.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Popup, sheet, or by window width.
  final PickerPresentation presentation;

  /// `false` disables it.
  final bool enabled;

  /// Reports focus changes.
  final ValueChanged<bool>? onFocusChanged;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoDateField> createState() => _CamoDateFieldState();
}

class _CamoDateFieldState extends State<CamoDateField> {
  bool _open = false;
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext anchor) async {
    final w = widget;
    final style = datePickerStyleOf(context, 'CamoDateField');
    setState(() => _open = true);
    final result = await openFieldPicker<CalendarSelection>(
      anchor,
      presentation: w.presentation,
      autoPopupMinWidth: style.autoPopupMinWidth,
      title: w.label,
      builder: (context) => _DatePanel(
        initial: SingleDate(w.value == null ? null : dateOnly(w.value!)),
        firstDate: w.firstDate,
        lastDate: w.lastDate,
        selectableDayPredicate: w.selectableDayPredicate,
        maxRangeLength: null,
      ),
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (result case SingleDate(:final date?)) w.onChanged(date);
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final style = datePickerStyleOf(context, 'CamoDateField');
    final typing =
        w.enabled &&
        switch (style.allowTyping) {
          AllowTyping.auto => prefersTyping,
          AllowTyping.always => true,
          AllowTyping.never => false,
        };
    final locale = CamoDateLocale.of(context);
    if (typing) {
      return _TypedDateField(
        value: w.value,
        onChanged: w.onChanged,
        label: w.label,
        placeholder: w.placeholder,
        supportingText: w.supportingText,
        error: w.error,
        firstDate: w.firstDate,
        lastDate: w.lastDate,
        selectableDayPredicate: w.selectableDayPredicate,
        style: style,
        locale: locale,
        focusNode: _focus,
        onFocusChanged: w.onFocusChanged,
        onOpen: _pick,
      );
    }
    return CamoPickerField(
      text: w.value == null
          ? null
          : locale.mediumDate(w.value!, pattern: style.displayFormat),
      icon: style.calendarIcon,
      onOpen: _pick,
      label: w.label,
      placeholder: w.placeholder,
      supportingText: w.supportingText,
      error: w.error,
      enabled: w.enabled,
      open: _open,
      focusNode: _focus,
      onFocusChanged: w.onFocusChanged,
    );
  }
}

/// A date range field: like [CamoDateField] (without typing), showing "start – end" and opening a calendar
/// where the first tap sets the start and the second the end; Done confirms and Clear starts over. With
/// [maxLength], days more than [maxLength] days after a picked start are disabled.
class CamoDateRangeField extends StatefulWidget {
  /// Creates a date range field.
  const CamoDateRangeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.maxLength,
    this.presentation = PickerPresentation.auto,
    this.enabled = true,
    this.onFocusChanged,
    this.focusNode,
  });

  /// The range, or `null`.
  final CamoDateRange? value;

  /// Called with each confirmed range.
  final ValueChanged<CamoDateRange> onChanged;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// The earliest date.
  final DateTime? firstDate;

  /// The latest date.
  final DateTime? lastDate;

  /// `false` disables a day.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The longest range in days.
  final int? maxLength;

  /// Popup, sheet, or by window width.
  final PickerPresentation presentation;

  /// `false` disables it.
  final bool enabled;

  /// Reports focus changes.
  final ValueChanged<bool>? onFocusChanged;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoDateRangeField> createState() => _CamoDateRangeFieldState();
}

class _CamoDateRangeFieldState extends State<CamoDateRangeField> {
  bool _open = false;
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext anchor) async {
    final w = widget;
    final style = datePickerStyleOf(context, 'CamoDateRangeField');
    setState(() => _open = true);
    final result = await openFieldPicker<CalendarSelection>(
      anchor,
      presentation: w.presentation,
      autoPopupMinWidth: style.autoPopupMinWidth,
      title: w.label,
      builder: (context) => _DatePanel(
        initial: DateRangeSelection(w.value?.start, w.value?.end),
        firstDate: w.firstDate,
        lastDate: w.lastDate,
        selectableDayPredicate: w.selectableDayPredicate,
        maxRangeLength: w.maxLength,
      ),
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (result case DateRangeSelection(:final start?, :final end?)) {
      w.onChanged(CamoDateRange(start, end));
    }
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final style = datePickerStyleOf(context, 'CamoDateRangeField');
    final locale = CamoDateLocale.of(context);
    final range = w.value;
    final text = range == null
        ? null
        : '${locale.mediumDate(range.start, pattern: style.displayFormat)} – '
              '${locale.mediumDate(range.end, pattern: style.displayFormat)}';
    return CamoPickerField(
      text: text,
      icon: style.calendarIcon,
      onOpen: _pick,
      label: w.label,
      placeholder: w.placeholder,
      supportingText: w.supportingText,
      error: w.error,
      enabled: w.enabled,
      open: _open,
      focusNode: _focus,
      onFocusChanged: w.onFocusChanged,
    );
  }
}

// The typed form of the date field: the locale's short pattern as a mask, the calendar behind the icon.
class _TypedDateField extends StatefulWidget {
  const _TypedDateField({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.placeholder,
    required this.supportingText,
    required this.error,
    required this.firstDate,
    required this.lastDate,
    required this.selectableDayPredicate,
    required this.style,
    required this.locale,
    required this.focusNode,
    required this.onFocusChanged,
    required this.onOpen,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String? placeholder;
  final String? supportingText;
  final String? error;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime day)? selectableDayPredicate;
  final CamoDatePickerStyle style;
  final CamoDateLocale locale;
  final FocusNode focusNode;
  final ValueChanged<bool>? onFocusChanged;
  final void Function(BuildContext anchor) onOpen;

  @override
  State<_TypedDateField> createState() => _TypedDateFieldState();
}

class _TypedDateFieldState extends State<_TypedDateField> {
  late final String _pattern = typingPattern(widget.locale.shortDatePattern);
  late String _digits = _digitsOf(widget.value);
  bool _left = false;

  String _digitsOf(DateTime? date) =>
      date == null ? '' : typedDigits(date, _pattern);

  int get _length => _pattern.replaceAll(RegExp('[^A-Za-z]'), '').length;

  bool _allowed(DateTime d) => dateSelectable(
    d,
    widget.firstDate,
    widget.lastDate,
    widget.selectableDayPredicate,
  );

  @override
  void didUpdateWidget(_TypedDateField old) {
    super.didUpdateWidget(old);
    final shown = parseTyped(_digits, _pattern);
    if (!sameDayOrBothNull(shown, widget.value)) {
      _digits = _digitsOf(widget.value);
    }
  }

  String? get _typedError {
    final strings = widget.style.strings;
    final parsed = parseTyped(_digits, _pattern);
    if (_digits.isEmpty) return null;
    if (_digits.length < _length) return _left ? strings.invalidDate : null;
    if (parsed == null) return strings.invalidDate;
    return _allowed(parsed) ? null : strings.outOfRange;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return CamoTextField(
      value: _digits,
      onChanged: (typed) {
        setState(() => _digits = typed);
        final date = parseTyped(typed, _pattern);
        if (date != null && _allowed(date)) w.onChanged(date);
      },
      label: w.label,
      placeholder: w.placeholder ?? _pattern.toLowerCase(),
      supportingText: w.supportingText,
      error: w.error ?? _typedError,
      suffixIcon: Builder(
        builder: (anchor) => CamoFieldAction(
          icon: CamoIcon(w.style.calendarIcon),
          semanticLabel: w.style.strings.chooseDate,
          onPressed: () => w.onOpen(anchor),
        ),
      ),
      onFocusChanged: (focused) {
        if (!focused && _digits.isNotEmpty) setState(() => _left = true);
        w.onFocusChanged?.call(focused);
      },
      inputFilter: CamoInputFilter.digitsOnly(maxLength: _length),
      displayFormat: CamoDisplayFormat.pattern(typingMask(_pattern)),
      keyboardType: TextInputType.number,
      focusNode: w.focusNode,
    );
  }
}

// What the popup or sheet holds: the calendar (or wheels for a single date in the wheel form) on a draft of the
// selection, then Cancel/OK (single, with confirmButton) or Clear/Done (range). Confirming pops the draft.
class _DatePanel extends StatefulWidget {
  const _DatePanel({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
    required this.selectableDayPredicate,
    required this.maxRangeLength,
  });

  final CalendarSelection initial;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime day)? selectableDayPredicate;
  final int? maxRangeLength;

  @override
  State<_DatePanel> createState() => _DatePanelState();
}

class _DatePanelState extends State<_DatePanel> {
  late CalendarSelection _draft = widget.initial;
  late CamoYearMonth _month = CamoYearMonth.of(_selectedOrToday());

  DateTime _selectedOrToday() {
    final selected = switch (widget.initial) {
      SingleDate(:final date) => date,
      DateRangeSelection(:final start) => start,
    };
    return selected ?? _clamp(dateOnly(DateTime.now()));
  }

  DateTime _clamp(DateTime d) {
    final first = widget.firstDate, last = widget.lastDate;
    if (first != null && d.isBefore(first)) return dateOnly(first);
    if (last != null && d.isAfter(last)) return dateOnly(last);
    return d;
  }

  void _commit(CalendarSelection selection) =>
      Navigator.pop(context, selection);

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context, component: 'CamoDateField');
    final style = datePickerStyleOf(context, 'CamoDateField');
    final strings = style.strings;
    final single = widget.initial is SingleDate;
    final wheel = single && style.form == DatePickerForm.wheel;
    return Padding(
      padding: style.contentPadding,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing.s,
          children: [
            if (wheel)
              _DateWheels(
                date: (_draft as SingleDate).date ?? _selectedOrToday(),
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                style: style,
                theme: theme,
                onChanged: (d) => setState(() => _draft = SingleDate(d)),
              )
            else
              CamoCalendar(
                selection: _draft,
                onSelectionChanged: (s) {
                  setState(() => _draft = s);
                  if (single && !style.confirmButton) _commit(s);
                },
                visibleMonth: _month,
                onVisibleMonthChanged: (m) => setState(() => _month = m),
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectableDayPredicate: widget.selectableDayPredicate,
                maxRangeLength: widget.maxRangeLength,
                autofocus: true,
              ),
            if (!single || style.confirmButton || wheel)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: theme.spacing.s,
                children: switch (_draft) {
                  SingleDate(:final date) => [
                    CamoButton(
                      text: strings.cancel,
                      onPressed: () => Navigator.pop(context),
                      appearance: Appearance.ghost,
                    ),
                    CamoButton(
                      text: strings.ok,
                      onPressed: wheel || date != null
                          ? () =>
                                _commit(SingleDate(date ?? _selectedOrToday()))
                          : null,
                      appearance: Appearance.ghost,
                    ),
                  ],
                  DateRangeSelection(:final start, :final end) => [
                    CamoButton(
                      text: strings.clear,
                      onPressed: start == null
                          ? null
                          : () => setState(
                              () =>
                                  _draft = const DateRangeSelection(null, null),
                            ),
                      appearance: Appearance.ghost,
                    ),
                    CamoButton(
                      text: strings.done,
                      onPressed: end == null ? null : () => _commit(_draft),
                      appearance: Appearance.ghost,
                    ),
                  ],
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Day, month and year wheels in the locale's order; a change keeps the date real (31 → 30) and within limits.
class _DateWheels extends StatelessWidget {
  const _DateWheels({
    required this.date,
    required this.firstDate,
    required this.lastDate,
    required this.style,
    required this.theme,
    required this.onChanged,
  });

  final DateTime date;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final CamoDatePickerStyle style;
  final CamoTheme theme;
  final ValueChanged<DateTime> onChanged;

  void _emit(int year, int month, int day) {
    final ym = CamoYearMonth(year, month);
    var d = DateTime(year, month, day.clamp(1, ym.numberOfDays));
    if (firstDate != null && d.isBefore(firstDate!)) d = dateOnly(firstDate!);
    if (lastDate != null && d.isAfter(lastDate!)) d = dateOnly(lastDate!);
    onChanged(d);
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDateField');
    final locale = CamoDateLocale.of(context);
    final order = typingPattern(locale.shortDatePattern)
        .replaceAll(RegExp('[^A-Za-z]'), '')
        .split('')
        .toSet();
    final months = locale.monthNames(short: true);
    final firstYear = firstDate?.year ?? date.year - 120;
    final lastYear = lastDate?.year ?? date.year + 50;
    final c = style.colors;
    final s = style.strings;
    Widget wheel(
      int count,
      int selected,
      ValueChanged<int> onSelect,
      String Function(int) label,
      String name,
    ) => CamoWheelColumn(
      count: count,
      selected: selected,
      onSelect: onSelect,
      label: label,
      name: name,
      itemHeight: style.wheelItemHeight,
      textStyle: style.wheelTextStyle,
      selectedColor: c.day,
      color: c.weekday,
    );
    final wheels = [
      for (final part in order)
        switch (part) {
          'd' => wheel(
            CamoYearMonth(date.year, date.month).numberOfDays,
            date.day - 1,
            (i) => _emit(date.year, date.month, i + 1),
            (i) => '${i + 1}',
            s.day,
          ),
          'M' => wheel(
            12,
            date.month - 1,
            (i) => _emit(date.year, i + 1, date.day),
            (i) => months[i],
            s.month,
          ),
          _ => wheel(
            lastYear - firstYear + 1,
            date.year - firstYear,
            (i) => _emit(firstYear + i, date.month, date.day),
            (i) => '${firstYear + i}',
            s.year,
          ),
        },
    ];
    return skin.datePicker.wheels(context, wheels, theme, style);
  }
}
