import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_error_semantics.dart';
import 'camo_decimal.dart';

/// How a stepper is laid out: − value + in a row, or a value field with ▲ ▼ at the end.
enum StepperLayout {
  /// − value +.
  inline,

  /// A value field with ▲ ▼ at the end.
  split,
}

/// Every color a stepper uses.
@immutable
class StepperColors {
  /// Creates stepper colors.
  const StepperColors({
    required this.button,
    required this.value,
    required this.field,
    required this.error,
  });

  /// The buttons' icons.
  final Color button;

  /// The value text.
  final Color value;

  /// The field's and buttons' outlines.
  final Color field;

  /// The outline in the error state.
  final Color error;

  @override
  bool operator ==(Object other) =>
      other is StepperColors &&
      other.button == button &&
      other.value == value &&
      other.field == field &&
      other.error == error;

  @override
  int get hashCode => Object.hash(button, value, field, error);
}

/// Overrides for steppers; `null` keeps the skin's default.
@immutable
class CamoStepperTheme {
  /// Creates stepper overrides.
  const CamoStepperTheme({
    this.layout,
    this.buttonAppearance,
    this.height,
    this.valueMinWidth,
    this.valueStyle,
    this.decreaseIcon,
    this.increaseIcon,
    this.colors,
  });

  /// Inline or split.
  final StepperLayout? layout;

  /// The − and + buttons' look.
  final Appearance? buttonAppearance;

  /// The control's height.
  final double? height;

  /// Keeps the layout from jumping between 9 and 10.
  final double? valueMinWidth;

  /// The value text.
  final TextStyle? valueStyle;

  /// The brand's − icon.
  final IconSource? decreaseIcon;

  /// The brand's + icon.
  final IconSource? increaseIcon;

  /// Every color it uses.
  final StepperColors? colors;

  /// A copy with the given fields replaced.
  CamoStepperTheme copyWith({
    StepperLayout? layout,
    Appearance? buttonAppearance,
    double? height,
    double? valueMinWidth,
    TextStyle? valueStyle,
    IconSource? decreaseIcon,
    IconSource? increaseIcon,
    StepperColors? colors,
  }) => CamoStepperTheme(
    layout: layout ?? this.layout,
    buttonAppearance: buttonAppearance ?? this.buttonAppearance,
    height: height ?? this.height,
    valueMinWidth: valueMinWidth ?? this.valueMinWidth,
    valueStyle: valueStyle ?? this.valueStyle,
    decreaseIcon: decreaseIcon ?? this.decreaseIcon,
    increaseIcon: increaseIcon ?? this.increaseIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoStepperTheme &&
      other.layout == layout &&
      other.buttonAppearance == buttonAppearance &&
      other.height == height &&
      other.valueMinWidth == valueMinWidth &&
      other.valueStyle == valueStyle &&
      other.decreaseIcon == decreaseIcon &&
      other.increaseIcon == increaseIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    layout,
    buttonAppearance,
    height,
    valueMinWidth,
    valueStyle,
    decreaseIcon,
    increaseIcon,
    colors,
  );
}

/// The resolved stepper style: every field set.
@immutable
class CamoStepperStyle {
  /// Creates a stepper style.
  const CamoStepperStyle({
    required this.layout,
    required this.buttonAppearance,
    required this.height,
    required this.valueMinWidth,
    required this.valueStyle,
    required this.decreaseIcon,
    required this.increaseIcon,
    required this.colors,
  });

  /// Inline or split.
  final StepperLayout layout;

  /// The − and + buttons' look.
  final Appearance buttonAppearance;

  /// The control's height.
  final double height;

  /// The value's minimum width.
  final double valueMinWidth;

  /// The value text.
  final TextStyle valueStyle;

  /// The − icon.
  final IconSource decreaseIcon;

  /// The + icon.
  final IconSource increaseIcon;

  /// Every color it uses.
  final StepperColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoStepperStyle merge(CamoStepperTheme? o) => o == null
      ? this
      : CamoStepperStyle(
          layout: o.layout ?? layout,
          buttonAppearance: o.buttonAppearance ?? buttonAppearance,
          height: o.height ?? height,
          valueMinWidth: o.valueMinWidth ?? valueMinWidth,
          valueStyle: o.valueStyle ?? valueStyle,
          decreaseIcon: o.decreaseIcon ?? decreaseIcon,
          increaseIcon: o.increaseIcon ?? increaseIcon,
          colors: o.colors ?? colors,
        );
}

/// One of a stepper's buttons. The renderer draws its visual and passes it through [wrap], which adds the tap,
/// hold-to-repeat, focus and label. The renderer sizes the button: an inline one inside a `CamoTouchTarget`,
/// a split layout's ▲ ▼ at half the field's height, for pointers.
@immutable
class StepperButton {
  /// Creates a stepper button.
  const StepperButton({
    required this.enabled,
    required this.interaction,
    required this.controller,
    required this.wrap,
  });

  /// `false` at the end of the range, or when the stepper is disabled.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;

  /// Wraps the button's visual in its behavior.
  final Widget Function(Widget visual) wrap;
}

/// What a stepper renderer draws: the value field and the two buttons, laid out by `style.layout`.
@immutable
class StepperState {
  /// Creates a stepper state.
  const StepperState({
    required this.valueText,
    required this.enabled,
    required this.error,
    required this.focused,
    required this.decrease,
    required this.increase,
  });

  /// The shown value.
  final String valueText;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The stepper has an error.
  final bool error;

  /// The value field has focus.
  final bool focused;

  /// The − button.
  final StepperButton decrease;

  /// The + button.
  final StepperButton increase;
}

/// The value: core's editable field (or plain text without typing), already styled from `style.valueStyle`.
@immutable
class StepperSlots {
  /// Creates the slots.
  const StepperSlots({required this.input});

  /// The value field.
  final Widget input;
}

/// Draws steppers.
abstract interface class CamoStepperRenderer {
  /// The complete stepper style for [theme].
  CamoStepperStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    StepperState state,
    StepperSlots slots,
    CamoTheme theme,
    CamoStepperStyle style,
  );
}

/// A quantity with − and + buttons: cart lines, guests. The buttons disable at [min] and [max], and holding one
/// repeats, faster over time. With [allowTyping] the value is a number field, clamped and snapped to [step] when
/// focus leaves. Screen readers get three stops: "Decrease [semanticLabel]", the value, and "Increase
/// [semanticLabel]"; each change is announced. [valueText] formats the value ("3 nights"). `onChanged: null`
/// disables it.
class CamoStepper extends StatefulWidget {
  /// A whole-number stepper.
  CamoStepper({
    super.key,
    required int value,
    required ValueChanged<int>? onChanged,
    int min = 0,
    int? max,
    int step = 1,
    this.semanticLabel,
    this.allowTyping = true,
    String Function(int value)? valueText,
    this.error,
  }) : value = CamoDecimal.of(value),
       onChanged = onChanged == null ? null : ((d) => onChanged(d.unscaled)),
       min = CamoDecimal.of(min),
       max = max == null ? null : CamoDecimal.of(max),
       step = CamoDecimal.of(step),
       decimals = 0,
       valueText = valueText == null ? null : ((d) => valueText(d.unscaled));

  /// A decimal stepper (weights, doses), exact in fixed point. [decimals] digits are shown and typed, with the
  /// locale's separator; typing accepts both `.` and `,`.
  const CamoStepper.decimal({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    this.max,
    required this.step,
    required this.decimals,
    this.semanticLabel,
    this.allowTyping = true,
    this.valueText,
    this.error,
  });

  /// The current value.
  final CamoDecimal value;

  /// Called with each new value; `null` disables the stepper.
  final ValueChanged<CamoDecimal>? onChanged;

  /// The smallest value.
  final CamoDecimal min;

  /// The largest value, or `null` for none.
  final CamoDecimal? max;

  /// How much a button press changes the value.
  final CamoDecimal step;

  /// Digits shown after the separator.
  final int decimals;

  /// Names the value ("Quantity").
  final String? semanticLabel;

  /// The value is an editable number field.
  final bool allowTyping;

  /// Formats the shown value.
  final String Function(CamoDecimal value)? valueText;

  /// Marks it invalid.
  final String? error;

  @override
  State<CamoStepper> createState() => _CamoStepperState();
}

const Duration _repeatAfter = Duration(milliseconds: 400);
const int _repeatStartMs = 250;
const int _repeatFastestMs = 100;
const int _pageSteps = 10;

class _CamoStepperState extends State<CamoStepper> {
  final _decrease = CamoInteractionController();
  final _increase = CamoInteractionController();
  final _focus = FocusNode(debugLabel: 'CamoStepper value');
  final _text = TextEditingController();
  Timer? _repeat;
  bool _repeated = false;
  bool _editing = false;

  String get _separator {
    final locale =
        Localizations.maybeLocaleOf(context) ??
        PlatformDispatcher.instance.locale;
    try {
      return NumberFormat.decimalPattern(locale.toLanguageTag())
          .symbols
          .DECIMAL_SEP;
    } on Object {
      return '.';
    }
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_editing) _syncText();
  }

  @override
  void didUpdateWidget(CamoStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing || oldWidget.value != widget.value) _syncText();
  }

  // The field shows the value while it isn't being typed in (and after a key changed it while typing).
  void _syncText() {
    final text = widget.value.withScale(widget.decimals).format(_separator);
    if (_text.text != text) _text.text = text;
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _decrease.dispose();
    _increase.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;
  bool get _canDecrease => _enabled && widget.value > widget.min;
  bool get _canIncrease =>
      _enabled && (widget.max == null || widget.value < widget.max!);

  CamoDecimal _clamp(CamoDecimal v) {
    final max = widget.max;
    final low = v < widget.min ? widget.min : v;
    return max != null && low > max ? max : low;
  }

  bool _stepBy(int steps) {
    final next = _clamp(widget.value + widget.step * steps);
    if (next.compareTo(widget.value) == 0) return false;
    widget.onChanged?.call(next.withScale(widget.decimals));
    return true;
  }

  void _focusChanged() {
    if (_focus.hasFocus) {
      setState(() => _editing = true);
      return;
    }
    if (_editing) _commit(_text.text);
    setState(() {
      _editing = false;
      _syncText();
    });
  }

  // A typed value, clamped and snapped; an empty or unreadable entry restores the last valid value.
  void _commit(String text) {
    final typed = CamoDecimal.tryParse(text);
    if (typed == null) return;
    final snapped = _clamp(
      camoSnapToStep(_clamp(typed), widget.min, widget.step),
    ).withScale(widget.decimals);
    if (snapped.compareTo(widget.value) != 0) widget.onChanged?.call(snapped);
  }

  void _startRepeat(int direction) {
    _repeat?.cancel();
    _repeated = false;
    var pause = _repeatStartMs;
    void tick() {
      if (!mounted || !_stepBy(direction)) return;
      _repeated = true;
      pause = (pause * 3 ~/ 4).clamp(_repeatFastestMs, _repeatStartMs);
      _repeat = Timer(Duration(milliseconds: pause), tick);
    }

    _repeat = Timer(_repeatAfter, tick);
  }

  void _stopRepeat() => _repeat?.cancel();

  StepperButton _button(
    CamoInteractionController controller,
    bool enabled,
    String label,
    int direction,
  ) => StepperButton(
    enabled: enabled,
    interaction: controller.value,
    controller: controller,
    wrap: (visual) => Listener(
      onPointerDown: enabled ? (_) => _startRepeat(direction) : null,
      onPointerUp: (_) => _stopRepeat(),
      onPointerCancel: (_) => _stopRepeat(),
      child: CamoBehavior(
        controller: controller,
        enabled: enabled,
        onActivate: () {
          if (_repeated) {
            _repeated = false;
          } else {
            _stepBy(direction);
          }
        },
        semantics: (child) => Semantics(
          button: true,
          enabled: enabled,
          label: label,
          excludeSemantics: true,
          child: child,
        ),
        child: visual,
      ),
    ),
  );

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.home) {
      widget.onChanged?.call(widget.min);
    } else if (key == LogicalKeyboardKey.end && widget.max != null) {
      widget.onChanged?.call(widget.max!);
    } else {
      final steps = switch (key) {
        LogicalKeyboardKey.arrowUp => 1,
        LogicalKeyboardKey.arrowDown => -1,
        LogicalKeyboardKey.pageUp => _pageSteps,
        LogicalKeyboardKey.pageDown => -_pageSteps,
        _ => 0,
      };
      if (steps == 0) return KeyEventResult.ignored;
      _stepBy(steps);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoStepper');
    final theme = Camouflage.themeOf(context, component: 'CamoStepper');
    final style = skin.stepper.defaults(theme).merge(theme.components.stepper);
    final separator = _separator;
    final shown =
        widget.valueText?.call(widget.value) ??
        widget.value.withScale(widget.decimals).format(separator);
    final textStyle = style.valueStyle.copyWith(color: style.colors.value);
    final align = style.layout == StepperLayout.inline
        ? TextAlign.center
        : TextAlign.start;
    final label = widget.semanticLabel;
    final Widget input = Semantics(
      label: label,
      value: shown,
      liveRegion: true,
      textField: widget.allowTyping,
      child: Focus(
        onKeyEvent: _onKey,
        skipTraversal: true,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (context, typed, child) => SizedBox(
            width: _measure(
              widget.allowTyping ? typed.text : shown,
              textStyle,
              style.valueMinWidth,
            ),
            child: child,
          ),
          child: widget.allowTyping
              ? EditableText(
                  controller: _text,
                  focusNode: _focus,
                  readOnly: !_enabled,
                  style: textStyle,
                  textAlign: align,
                  cursorColor: style.colors.value,
                  backgroundCursorColor: style.colors.field,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.decimals > 0,
                    signed: widget.min < CamoDecimal.zero,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,-]')),
                  ],
                  onSubmitted: (_) => _focus.unfocus(),
                )
              : Focus(
                  focusNode: _focus,
                  child: ExcludeSemantics(
                    child: Text(shown, style: textStyle, textAlign: align),
                  ),
                ),
        ),
      ),
    );
    final decreaseLabel = label == null ? 'Decrease' : 'Decrease $label';
    final increaseLabel = label == null ? 'Increase' : 'Increase $label';
    return CamoErrorSemantics(
      message: widget.error,
      child: ListenableBuilder(
        listenable: Listenable.merge([_decrease, _increase, _focus]),
        builder: (context, _) => skin.stepper.render(
          context,
          StepperState(
            valueText: shown,
            enabled: _enabled,
            error: widget.error != null,
            focused: _focus.hasFocus,
            decrease: _button(_decrease, _canDecrease, decreaseLabel, -1),
            increase: _button(_increase, _canIncrease, increaseLabel, 1),
          ),
          StepperSlots(input: input),
          theme,
          style,
        ),
      ),
    );
  }
}

// The value is as wide as its text plus room for the cursor, at least [min].
double _measure(String text, TextStyle style, double min) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final width = painter.width + 2;
  painter.dispose();
  return width < min ? min : width;
}
