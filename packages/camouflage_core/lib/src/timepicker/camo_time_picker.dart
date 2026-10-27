import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../button/camo_button.dart';
import '../datepicker/camo_date_field.dart';
import '../datepicker/camo_dates.dart';
import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../segmented/camo_segmented_control.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_wheel.dart';
import 'camo_times.dart';

/// Every color a time picker uses.
@immutable
class TimePickerColors {
  /// Creates time picker colors.
  const TimePickerColors({
    required this.active,
    required this.activeContainer,
    required this.face,
    required this.digits,
    required this.period,
  });

  /// The active part's mark and the dial's hand.
  final Color active;

  /// The active part's box.
  final Color activeContainer;

  /// The dial's face and the inactive boxes.
  final Color face;

  /// The digits.
  final Color digits;

  /// The other wheel rows.
  final Color period;

  @override
  bool operator ==(Object other) =>
      other is TimePickerColors &&
      other.active == active &&
      other.activeContainer == activeContainer &&
      other.face == face &&
      other.digits == digits &&
      other.period == period;

  @override
  int get hashCode =>
      Object.hash(active, activeContainer, face, digits, period);
}

/// The time picker's words, for the app to translate through its theme.
@immutable
class TimePickerStrings {
  /// Creates the strings; every one has an English default.
  const TimePickerStrings({
    this.chooseTime = 'Choose time',
    this.hour = 'Hour',
    this.minute = 'Minute',
    this.period = 'AM or PM',
    this.cancel = 'Cancel',
    this.ok = 'OK',
  });

  /// The field's picker.
  final String chooseTime;

  /// The hour field and wheel.
  final String hour;

  /// The minute field and wheel.
  final String minute;

  /// The AM/PM control.
  final String period;

  /// Closes without a change.
  final String cancel;

  /// Confirms.
  final String ok;
}

/// Overrides for time pickers and time fields; `null` keeps the skin's default.
@immutable
class CamoTimePickerTheme {
  /// Creates time picker overrides.
  const CamoTimePickerTheme({
    this.form,
    this.confirmButton,
    this.digitStyle,
    this.dialTextStyle,
    this.wheelTextStyle,
    this.wheelItemHeight,
    this.fieldSize,
    this.dialSize,
    this.autoPopupMinWidth,
    this.contentPadding,
    this.clockIcon,
    this.colors,
    this.strings,
  });

  /// Fields, a dial or wheels.
  final TimePickerForm? form;

  /// Cancel/OK.
  final bool? confirmButton;

  /// The hour and minute digits.
  final TextStyle? digitStyle;

  /// The dial's numbers.
  final TextStyle? dialTextStyle;

  /// The wheels' rows.
  final TextStyle? wheelTextStyle;

  /// A wheel row's height.
  final double? wheelItemHeight;

  /// The hour and minute boxes.
  final double? fieldSize;

  /// The dial.
  final double? dialSize;

  /// From this window width, `auto` uses a popup.
  final double? autoPopupMinWidth;

  /// Around the picker in its popup or sheet.
  final EdgeInsetsDirectional? contentPadding;

  /// The field's icon.
  final IconSource? clockIcon;

  /// Every color it uses.
  final TimePickerColors? colors;

  /// Its words.
  final TimePickerStrings? strings;

  /// A copy with the given fields replaced.
  CamoTimePickerTheme copyWith({
    TimePickerForm? form,
    bool? confirmButton,
    TextStyle? digitStyle,
    TextStyle? dialTextStyle,
    TextStyle? wheelTextStyle,
    double? wheelItemHeight,
    double? fieldSize,
    double? dialSize,
    double? autoPopupMinWidth,
    EdgeInsetsDirectional? contentPadding,
    IconSource? clockIcon,
    TimePickerColors? colors,
    TimePickerStrings? strings,
  }) => CamoTimePickerTheme(
    form: form ?? this.form,
    confirmButton: confirmButton ?? this.confirmButton,
    digitStyle: digitStyle ?? this.digitStyle,
    dialTextStyle: dialTextStyle ?? this.dialTextStyle,
    wheelTextStyle: wheelTextStyle ?? this.wheelTextStyle,
    wheelItemHeight: wheelItemHeight ?? this.wheelItemHeight,
    fieldSize: fieldSize ?? this.fieldSize,
    dialSize: dialSize ?? this.dialSize,
    autoPopupMinWidth: autoPopupMinWidth ?? this.autoPopupMinWidth,
    contentPadding: contentPadding ?? this.contentPadding,
    clockIcon: clockIcon ?? this.clockIcon,
    colors: colors ?? this.colors,
    strings: strings ?? this.strings,
  );
}

/// The resolved time picker style: every field set.
@immutable
class CamoTimePickerStyle {
  /// Creates a time picker style.
  const CamoTimePickerStyle({
    required this.form,
    required this.confirmButton,
    required this.digitStyle,
    required this.dialTextStyle,
    required this.wheelTextStyle,
    required this.wheelItemHeight,
    required this.fieldSize,
    required this.dialSize,
    required this.autoPopupMinWidth,
    required this.contentPadding,
    required this.clockIcon,
    required this.colors,
    required this.strings,
  });

  /// Fields, a dial or wheels.
  final TimePickerForm form;

  /// Cancel/OK.
  final bool confirmButton;

  /// The hour and minute digits.
  final TextStyle digitStyle;

  /// The dial's numbers.
  final TextStyle dialTextStyle;

  /// The wheels' rows.
  final TextStyle wheelTextStyle;

  /// A wheel row's height.
  final double wheelItemHeight;

  /// The hour and minute boxes.
  final double fieldSize;

  /// The dial.
  final double dialSize;

  /// From this window width, `auto` uses a popup.
  final double autoPopupMinWidth;

  /// Around the picker in its popup or sheet.
  final EdgeInsetsDirectional contentPadding;

  /// The field's icon.
  final IconSource clockIcon;

  /// Every color it uses.
  final TimePickerColors colors;

  /// Its words.
  final TimePickerStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoTimePickerStyle merge(CamoTimePickerTheme? o) => o == null
      ? this
      : CamoTimePickerStyle(
          form: o.form ?? form,
          confirmButton: o.confirmButton ?? confirmButton,
          digitStyle: o.digitStyle ?? digitStyle,
          dialTextStyle: o.dialTextStyle ?? dialTextStyle,
          wheelTextStyle: o.wheelTextStyle ?? wheelTextStyle,
          wheelItemHeight: o.wheelItemHeight ?? wheelItemHeight,
          fieldSize: o.fieldSize ?? fieldSize,
          dialSize: o.dialSize ?? dialSize,
          autoPopupMinWidth: o.autoPopupMinWidth ?? autoPopupMinWidth,
          contentPadding: o.contentPadding ?? contentPadding,
          clockIcon: o.clockIcon ?? clockIcon,
          colors: o.colors ?? colors,
          strings: o.strings ?? strings,
        );
}

/// What a time picker renderer draws, for `style.form`: the hour and minute boxes, the period, a dial or wheels.
@immutable
class TimePickerState {
  /// Creates a time picker state.
  const TimePickerState({
    required this.hour,
    required this.minute,
    required this.is24Hour,
    required this.period,
    required this.activePart,
    required this.minuteStep,
    required this.enabled,
  });

  /// The hour, 0–23, or `null` when empty.
  final int? hour;

  /// The minute, or `null` when empty.
  final int? minute;

  /// 24-hour digits.
  final bool is24Hour;

  /// AM or PM.
  final DayPeriod period;

  /// The part being changed.
  final TimePart activePart;

  /// The minute step.
  final int minuteStep;

  /// `false` shows the disabled look.
  final bool enabled;
}

/// The time picker's parts, built by core: the editable [hour] and [minute] (draw a box around each, active when
/// `activePart` matches), the AM/PM [period] control (12-hour only), and the [dial] or [wheels] for those forms.
@immutable
class TimePickerSlots {
  /// Creates the slots.
  const TimePickerSlots({
    required this.hour,
    required this.minute,
    this.period,
    this.dial,
    this.wheels,
  });

  /// The hour field.
  final Widget hour;

  /// The minute field.
  final Widget minute;

  /// AM/PM, in 12-hour times.
  final Widget? period;

  /// The dial, in the dial form.
  final Widget? dial;

  /// The wheels, in the wheel form.
  final List<Widget>? wheels;
}

/// The dial's face: [labels] around the outer ring (12 at the top), [innerLabels] on an inner ring for 24-hour
/// hours, the hand at [handAngle] degrees clockwise from the top, and the label at [selectedIndex] (on the inner
/// ring when [selectedInner]) highlighted; -1 when the hand sits between labels (minute 7).
@immutable
class DialState {
  /// Creates a dial state.
  const DialState({
    required this.labels,
    required this.innerLabels,
    required this.selectedIndex,
    required this.selectedInner,
    required this.handAngle,
    required this.part,
  });

  /// The outer ring's labels, from the top, clockwise.
  final List<String> labels;

  /// The inner ring's, for 24-hour hours.
  final List<String>? innerLabels;

  /// The highlighted label, or -1.
  final int selectedIndex;

  /// The highlighted label is on the inner ring.
  final bool selectedInner;

  /// The hand, in degrees clockwise from the top.
  final double handAngle;

  /// Hours or minutes.
  final TimePart part;
}

/// Draws time pickers: the layout, the dial face and the wheels.
abstract interface class CamoTimePickerRenderer {
  /// The complete time picker style for [theme].
  CamoTimePickerStyle defaults(CamoTheme theme);

  /// Lays out [slots] for `style.form`.
  Widget render(
    BuildContext context,
    TimePickerState state,
    TimePickerSlots slots,
    CamoTheme theme,
    CamoTimePickerStyle style,
  );

  /// The dial face, filling `style.dialSize`; core turns touches into values (inner ring below [dialInnerRing] of
  /// the radius).
  Widget dial(
    BuildContext context,
    DialState state,
    CamoTheme theme,
    CamoTimePickerStyle style,
  );

  /// The wheels side by side, with the band behind the middle row.
  Widget wheels(
    BuildContext context,
    List<Widget> wheels,
    CamoTheme theme,
    CamoTimePickerStyle style,
  );
}

/// On a 24-hour dial, a touch nearer the middle than this share of the radius picks the inner ring (12–23).
const dialInnerRing = 0.62;

/// The resolved time picker style for [context].
CamoTimePickerStyle timePickerStyleOf(BuildContext context, String component) {
  final skin = Camouflage.skinOf(context, component: component);
  final theme = Camouflage.themeOf(context, component: component);
  return skin.timePicker.defaults(theme).merge(theme.components.timePicker);
}

/// The inline time input (ADR-30) in `CamoTimePickerTheme.form`: two digit fields with AM/PM (fields), the same
/// above a clock dial (dial), or wheels (wheel). [use24Hour] `null` follows the device
/// (`MediaQuery.alwaysUse24HourFormatOf`). Minutes move by [minuteStep] and snap to it when the minute field is
/// left. Screen readers get the hour and minute as adjustable fields in every form; Up and Down change them.
class CamoTimeInput extends StatefulWidget {
  /// Creates a time input.
  const CamoTimeInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.minuteStep = 1,
    this.use24Hour,
    this.enabled = true,
  });

  /// The time, or `null`.
  final CamoTime? value;

  /// Called with each change.
  final ValueChanged<CamoTime> onChanged;

  /// The minute step: 5, 15, 30 for slots.
  final int minuteStep;

  /// 24-hour digits; `null` follows the device.
  final bool? use24Hour;

  /// `false` disables it.
  final bool enabled;

  @override
  State<CamoTimeInput> createState() => _CamoTimeInputState();
}

class _CamoTimeInputState extends State<CamoTimeInput> {
  TimePart _active = TimePart.hour;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final skin = Camouflage.skinOf(context, component: 'CamoTimeInput');
    final theme = Camouflage.themeOf(context, component: 'CamoTimeInput');
    final style = skin.timePicker
        .defaults(theme)
        .merge(theme.components.timePicker);
    final is24 = w.use24Hour ?? MediaQuery.alwaysUse24HourFormatOf(context);
    final time = w.value ?? const CamoTime(hour: 0, minute: 0);
    final period = periodOf(time.hour);
    final strings = style.strings;
    final amPm = CamoDateLocale.of(context).amPm;
    final hour = _DigitField(
      value: w.value == null
          ? null
          : (is24 ? w.value!.hour : hour12(w.value!.hour)),
      first: is24 ? 0 : 1,
      last: is24 ? 23 : 12,
      step: 1,
      name: strings.hour,
      enabled: w.enabled,
      style: style,
      onFocus: () => setState(() => _active = TimePart.hour),
      onChanged: (h) => w.onChanged(
        CamoTime(hour: is24 ? h : hour24(h, period), minute: time.minute),
      ),
    );
    final minute = _DigitField(
      value: w.value?.minute,
      first: 0,
      last: 59,
      step: w.minuteStep,
      name: strings.minute,
      enabled: w.enabled,
      style: style,
      onFocus: () => setState(() => _active = TimePart.minute),
      onChanged: (m) => w.onChanged(CamoTime(hour: time.hour, minute: m)),
    );
    final periodControl = is24
        ? null
        : Semantics(
            label: strings.period,
            child: CamoSegmentedControl<DayPeriod>(
              options: [
                Segment(DayPeriod.am, label: amPm[0]),
                Segment(DayPeriod.pm, label: amPm[1]),
              ],
              selected: period,
              onChanged: (p) => w.onChanged(
                CamoTime(
                  hour: hour24(hour12(time.hour), p),
                  minute: time.minute,
                ),
              ),
              enabled: w.enabled,
            ),
          );
    final dial = style.form == TimePickerForm.dial
        ? _TimeDial(
            time: time,
            part: _active,
            is24: is24,
            minuteStep: w.minuteStep,
            style: style,
            theme: theme,
            enabled: w.enabled,
            onPart: (p) => setState(() => _active = p),
            onChanged: w.onChanged,
          )
        : null;
    final wheels = style.form == TimePickerForm.wheel
        ? _timeWheels(time, is24, w.minuteStep, amPm, style)
        : null;
    return skin.timePicker.render(
      context,
      TimePickerState(
        hour: w.value?.hour,
        minute: w.value?.minute,
        is24Hour: is24,
        period: period,
        activePart: _active,
        minuteStep: w.minuteStep,
        enabled: w.enabled,
      ),
      TimePickerSlots(
        hour: hour,
        minute: minute,
        period: periodControl,
        dial: dial,
        wheels: wheels,
      ),
      theme,
      style,
    );
  }

  List<Widget> _timeWheels(
    CamoTime time,
    bool is24,
    int minuteStep,
    List<String> amPm,
    CamoTimePickerStyle style,
  ) {
    final step = math.max(1, minuteStep);
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
      selectedColor: c.digits,
      color: c.period,
    );
    final onChanged = widget.onChanged;
    return [
      if (is24)
        wheel(
          24,
          time.hour,
          (h) => onChanged(CamoTime(hour: h, minute: time.minute)),
          _two,
          s.hour,
        )
      else
        wheel(
          12,
          hour12(time.hour) - 1,
          (i) => onChanged(
            CamoTime(
              hour: hour24(i + 1, periodOf(time.hour)),
              minute: time.minute,
            ),
          ),
          (i) => '${i + 1}',
          s.hour,
        ),
      wheel(
        60 ~/ step,
        snapMinute(time.minute, step) ~/ step,
        (i) => onChanged(CamoTime(hour: time.hour, minute: i * step)),
        (i) => _two(i * step),
        s.minute,
      ),
      if (!is24)
        wheel(
          2,
          periodOf(time.hour).index,
          (i) => onChanged(
            CamoTime(
              hour: hour24(hour12(time.hour), DayPeriod.values[i]),
              minute: time.minute,
            ),
          ),
          (i) => amPm[i],
          s.period,
        ),
    ];
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

// A two-digit field for the hour or the minute: typing a whole number in first…last reports it; Up and Down step
// it (wrapping); leaving it snaps to [step] and shows two digits again. Adjustable for screen readers.
class _DigitField extends StatefulWidget {
  const _DigitField({
    required this.value,
    required this.first,
    required this.last,
    required this.step,
    required this.name,
    required this.enabled,
    required this.style,
    required this.onFocus,
    required this.onChanged,
  });

  final int? value;
  final int first;
  final int last;
  final int step;
  final String name;
  final bool enabled;
  final CamoTimePickerStyle style;
  final VoidCallback onFocus;
  final ValueChanged<int> onChanged;

  @override
  State<_DigitField> createState() => _DigitFieldState();
}

class _DigitFieldState extends State<_DigitField> {
  late final _controller = TextEditingController(text: _shown(widget.value));
  final _focus = FocusNode();

  String _shown(int? v) => v == null ? '' : _two(v);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  void _focusChanged() {
    final w = widget;
    if (_focus.hasFocus) {
      w.onFocus();
    } else {
      final v = w.value;
      if (v != null && w.step > 1 && snapMinute(v, w.step) != v) {
        w.onChanged(snapMinute(v, w.step));
      }
      _controller.text = _shown(widget.value);
    }
  }

  @override
  void didUpdateWidget(_DigitField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != _shown(widget.value)) {
      _controller.text = _shown(widget.value);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _stepBy(int direction) {
    final w = widget;
    final size = w.last - w.first + 1;
    final from = w.value ?? w.first;
    w.onChanged(
      ((from - w.first + direction * w.step) % size + size) % size + w.first,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.text = _shown(widget.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final v = w.value;
    return Semantics(
      label: w.name,
      value: v == null ? null : '$v',
      increasedValue:
          '${v == null ? w.first : (v + w.step > w.last ? w.first : v + w.step)}',
      decreasedValue:
          '${v == null ? w.last : (v - w.step < w.first ? w.last : v - w.step)}',
      onIncrease: w.enabled ? () => _stepBy(1) : null,
      onDecrease: w.enabled ? () => _stepBy(-1) : null,
      textField: true,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => _stepBy(1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              _stepBy(-1),
        },
        child: SizedBox(
          width: w.style.fieldSize,
          child: EditableText(
            controller: _controller,
            focusNode: _focus,
            readOnly: !w.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: w.style.digitStyle.copyWith(color: w.style.colors.digits),
            cursorColor: w.style.colors.active,
            backgroundCursorColor: w.style.colors.face,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (typed) {
              final n = int.tryParse(typed);
              if (n != null && n >= w.first && n <= w.last) w.onChanged(n);
            },
          ),
        ),
      ),
    );
  }
}

// The time at a dial point: the hour (inner ring 12–23 on a 24-hour dial) or the minute, snapped to the step.
CamoTime _dialTime(
  Offset at,
  double size,
  CamoTime now,
  TimePart part,
  bool is24,
  int minuteStep,
) {
  final center = size / 2;
  final dx = at.dx - center;
  final dy = at.dy - center;
  final angle = (math.atan2(dx, -dy) * 180 / math.pi + 360) % 360;
  if (part == TimePart.minute) {
    return CamoTime(
      hour: now.hour,
      minute: snapMinute((angle / 6).round() % 60, minuteStep),
    );
  }
  final index = (angle / 30).round() % 12;
  final hour = !is24
      ? hour24(index == 0 ? 12 : index, periodOf(now.hour))
      : math.sqrt(dx * dx + dy * dy) < center * dialInnerRing
      ? index + 12
      : index;
  return CamoTime(hour: hour, minute: now.minute);
}

// The clock dial: a tap or drag picks the hour (then moves on to the minute) or the minute. Screen readers use the
// digit fields instead, so the dial is hidden from them.
class _TimeDial extends StatelessWidget {
  const _TimeDial({
    required this.time,
    required this.part,
    required this.is24,
    required this.minuteStep,
    required this.style,
    required this.theme,
    required this.enabled,
    required this.onPart,
    required this.onChanged,
  });

  final CamoTime time;
  final TimePart part;
  final bool is24;
  final int minuteStep;
  final CamoTimePickerStyle style;
  final CamoTheme theme;
  final bool enabled;
  final ValueChanged<TimePart> onPart;
  final ValueChanged<CamoTime> onChanged;

  void _pick(Offset at, {required bool release}) {
    onChanged(_dialTime(at, style.dialSize, time, part, is24, minuteStep));
    if (release && part == TimePart.hour) onPart(TimePart.minute);
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTimeInput');
    final DialState state;
    if (part == TimePart.hour) {
      final index = time.hour % 12;
      state = DialState(
        labels: List.generate(12, (i) => i != 0 ? '$i' : (is24 ? '00' : '12')),
        innerLabels: is24 ? List.generate(12, (i) => '${i + 12}') : null,
        selectedIndex: index,
        selectedInner: is24 && time.hour >= 12,
        handAngle: index * 30.0,
        part: TimePart.hour,
      );
    } else {
      state = DialState(
        labels: List.generate(12, (i) => _two(i * 5)),
        innerLabels: null,
        selectedIndex: time.minute % 5 == 0 ? time.minute ~/ 5 : -1,
        selectedInner: false,
        handAngle: time.minute * 6.0,
        part: TimePart.minute,
      );
    }
    Offset? last;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: style.dialSize,
        child: GestureDetector(
          onTapUp: enabled
              ? (d) => _pick(d.localPosition, release: true)
              : null,
          onPanStart: enabled
              ? (d) => _pick(last = d.localPosition, release: false)
              : null,
          onPanUpdate: enabled
              ? (d) => _pick(last = d.localPosition, release: false)
              : null,
          onPanEnd: enabled
              ? (_) => _pick(last ?? Offset.zero, release: true)
              : null,
          child: skin.timePicker.dial(context, state, theme, style),
        ),
      ),
    );
  }
}

/// A time field: the text-field frame showing [value] in the locale's short time (24 or 12 hours per
/// [use24Hour], `null` following the device), opening a [CamoTimeInput] in a popup on wide windows and a bottom
/// sheet otherwise. Cancel/OK confirm by default (`CamoTimePickerTheme.confirmButton`); OK is disabled outside
/// [minTime]…[maxTime], a window that may run past midnight.
class CamoTimeField extends StatefulWidget {
  /// Creates a time field.
  const CamoTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.minuteStep = 1,
    this.use24Hour,
    this.minTime,
    this.maxTime,
    this.presentation = PickerPresentation.auto,
    this.enabled = true,
    this.onFocusChanged,
    this.focusNode,
  });

  /// The time, or `null`.
  final CamoTime? value;

  /// Called with each confirmed time.
  final ValueChanged<CamoTime> onChanged;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// The minute step.
  final int minuteStep;

  /// 24-hour digits; `null` follows the device.
  final bool? use24Hour;

  /// The earliest time.
  final CamoTime? minTime;

  /// The latest time; before [minTime] runs past midnight.
  final CamoTime? maxTime;

  /// Popup, sheet, or by window width.
  final PickerPresentation presentation;

  /// `false` disables it.
  final bool enabled;

  /// Reports focus changes.
  final ValueChanged<bool>? onFocusChanged;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoTimeField> createState() => _CamoTimeFieldState();
}

class _CamoTimeFieldState extends State<CamoTimeField> {
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
    final style = timePickerStyleOf(context, 'CamoTimeField');
    final is24 = w.use24Hour ?? MediaQuery.alwaysUse24HourFormatOf(context);
    setState(() => _open = true);
    final result = await openFieldPicker<CamoTime>(
      anchor,
      presentation: w.presentation,
      autoPopupMinWidth: style.autoPopupMinWidth,
      title: w.label,
      builder: (context) => _TimePanel(
        initial:
            w.value ??
            w.minTime ??
            CamoTime(hour: 12, minute: snapMinute(0, w.minuteStep)),
        minuteStep: w.minuteStep,
        is24: is24,
        minTime: w.minTime,
        maxTime: w.maxTime,
        onLiveChange: w.onChanged,
      ),
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (result != null) w.onChanged(result);
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      _focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final style = timePickerStyleOf(context, 'CamoTimeField');
    final is24 = w.use24Hour ?? MediaQuery.alwaysUse24HourFormatOf(context);
    final value = w.value;
    return CamoPickerField(
      text: value == null
          ? null
          : CamoDateLocale.of(context)
                .time(value.hour, value.minute, use24Hour: is24),
      icon: style.clockIcon,
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

// What the popup or sheet holds: the time input on a draft, then Cancel/OK unless confirmButton is off, when each
// change in the window is reported at once.
class _TimePanel extends StatefulWidget {
  const _TimePanel({
    required this.initial,
    required this.minuteStep,
    required this.is24,
    required this.minTime,
    required this.maxTime,
    required this.onLiveChange,
  });

  final CamoTime initial;
  final int minuteStep;
  final bool is24;
  final CamoTime? minTime;
  final CamoTime? maxTime;
  final ValueChanged<CamoTime> onLiveChange;

  @override
  State<_TimePanel> createState() => _TimePanelState();
}

class _TimePanelState extends State<_TimePanel> {
  late CamoTime _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final theme = Camouflage.themeOf(context, component: 'CamoTimeField');
    final style = timePickerStyleOf(context, 'CamoTimeField');
    final inWindow = inTimeWindow(_draft, w.minTime, w.maxTime);
    return Padding(
      padding: style.contentPadding,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing.m,
          children: [
            CamoTimeInput(
              value: _draft,
              onChanged: (t) {
                setState(() => _draft = t);
                if (!style.confirmButton &&
                    inTimeWindow(t, w.minTime, w.maxTime)) {
                  w.onLiveChange(t);
                }
              },
              minuteStep: w.minuteStep,
              use24Hour: w.is24,
            ),
            if (style.confirmButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: theme.spacing.s,
                children: [
                  CamoButton(
                    text: style.strings.cancel,
                    onPressed: () => Navigator.pop(context),
                    appearance: Appearance.ghost,
                  ),
                  CamoButton(
                    text: style.strings.ok,
                    onPressed: inWindow
                        ? () => Navigator.pop(context, _draft)
                        : null,
                    appearance: Appearance.ghost,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
