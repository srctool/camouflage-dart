import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_touch_target.dart';

/// Every color a slider uses.
@immutable
class SliderColors {
  /// Creates slider colors.
  const SliderColors({
    required this.activeTrack,
    required this.inactiveTrack,
    required this.thumb,
    required this.stopMark,
    required this.valueLabel,
    required this.valueLabelText,
  });

  /// The track from the start to the value.
  final Color activeTrack;

  /// The rest of the track.
  final Color inactiveTrack;

  /// The thumb.
  final Color thumb;

  /// The dots at each step.
  final Color stopMark;

  /// The value label's bubble.
  final Color valueLabel;

  /// The value label's text.
  final Color valueLabelText;

  @override
  bool operator ==(Object other) =>
      other is SliderColors &&
      other.activeTrack == activeTrack &&
      other.inactiveTrack == inactiveTrack &&
      other.thumb == thumb &&
      other.stopMark == stopMark &&
      other.valueLabel == valueLabel &&
      other.valueLabelText == valueLabelText;

  @override
  int get hashCode => Object.hash(
    activeTrack,
    inactiveTrack,
    thumb,
    stopMark,
    valueLabel,
    valueLabelText,
  );
}

/// Overrides for sliders; `null` keeps the skin's default.
@immutable
class CamoSliderTheme {
  /// Creates slider overrides.
  const CamoSliderTheme({
    this.trackHeight,
    this.thumbSize,
    this.showStopMarks,
    this.showValueLabel,
    this.valueLabelStyle,
    this.colors,
  });

  /// The track's thickness.
  final double? trackHeight;

  /// The thumb (a circle when square, a bar otherwise).
  final Size? thumbSize;

  /// Dots at each step.
  final bool? showStopMarks;

  /// A label above the thumb while dragging.
  final bool? showValueLabel;

  /// The value label's text.
  final TextStyle? valueLabelStyle;

  /// Every color it uses.
  final SliderColors? colors;

  /// A copy with the given fields replaced.
  CamoSliderTheme copyWith({
    double? trackHeight,
    Size? thumbSize,
    bool? showStopMarks,
    bool? showValueLabel,
    TextStyle? valueLabelStyle,
    SliderColors? colors,
  }) => CamoSliderTheme(
    trackHeight: trackHeight ?? this.trackHeight,
    thumbSize: thumbSize ?? this.thumbSize,
    showStopMarks: showStopMarks ?? this.showStopMarks,
    showValueLabel: showValueLabel ?? this.showValueLabel,
    valueLabelStyle: valueLabelStyle ?? this.valueLabelStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSliderTheme &&
      other.trackHeight == trackHeight &&
      other.thumbSize == thumbSize &&
      other.showStopMarks == showStopMarks &&
      other.showValueLabel == showValueLabel &&
      other.valueLabelStyle == valueLabelStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    trackHeight,
    thumbSize,
    showStopMarks,
    showValueLabel,
    valueLabelStyle,
    colors,
  );
}

/// The resolved slider style: every field set.
@immutable
class CamoSliderStyle {
  /// Creates a slider style.
  const CamoSliderStyle({
    required this.trackHeight,
    required this.thumbSize,
    required this.showStopMarks,
    required this.showValueLabel,
    required this.valueLabelStyle,
    required this.colors,
  });

  /// The track's thickness.
  final double trackHeight;

  /// The thumb.
  final Size thumbSize;

  /// Dots at each step.
  final bool showStopMarks;

  /// A label above the thumb while dragging.
  final bool showValueLabel;

  /// The value label's text.
  final TextStyle valueLabelStyle;

  /// Every color it uses.
  final SliderColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoSliderStyle merge(CamoSliderTheme? o) => o == null
      ? this
      : CamoSliderStyle(
          trackHeight: o.trackHeight ?? trackHeight,
          thumbSize: o.thumbSize ?? thumbSize,
          showStopMarks: o.showStopMarks ?? showStopMarks,
          showValueLabel: o.showValueLabel ?? showValueLabel,
          valueLabelStyle: o.valueLabelStyle ?? valueLabelStyle,
          colors: o.colors ?? colors,
        );
}

/// What a slider renderer draws. [fraction] is the value's place in the range (0 to 1, from the start in the
/// reading direction); [divisions] - 1 stops lie between the ends. The renderer fills the width it's given, and
/// its track runs from half a thumb width in from each end, which is where core maps touches. [valueText] labels
/// the thumb while `interaction.dragged`.
@immutable
class SliderState {
  /// Creates a slider state.
  const SliderState({
    required this.fraction,
    required this.divisions,
    required this.enabled,
    required this.valueText,
    required this.interaction,
    required this.controller,
  });

  /// The value's place in the range.
  final double fraction;

  /// The number of steps, or `null` when continuous.
  final int? divisions;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The value's text, if the app gave a `valueLabel`.
  final String? valueText;

  /// Pressed, focused, hovered, dragged.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws sliders.
abstract interface class CamoSliderRenderer {
  /// The complete slider style for [theme].
  CamoSliderStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    SliderState state,
    CamoTheme theme,
    CamoSliderStyle style,
  );
}

/// Snaps a fraction to the nearest of `divisions + 1` stops (both ends included); continuous when `null`.
double camoSnap(double fraction, int? divisions) =>
    divisions == null || divisions <= 0
    ? fraction
    : (fraction * divisions).round() / divisions;

/// A value between [min] and [max]: volume, a price filter. A tap jumps to the touched value and a drag follows
/// the finger; [divisions] snaps it (`null` = continuous). [onChangeEnd] fires once per gesture or key press,
/// so an app can save once. [semanticLabel] names it ("Volume"), and [valueLabel] gives the value's text, shown
/// on the thumb while dragging. `onChanged: null` disables it. It fills the width it's given.
class CamoSlider extends StatefulWidget {
  /// Creates a slider.
  const CamoSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeEnd,
    this.valueLabel,
    this.semanticLabel,
    this.focusNode,
  });

  /// The current value.
  final double value;

  /// Called with each new value; `null` disables the slider.
  final ValueChanged<double>? onChanged;

  /// The smallest value.
  final double min;

  /// The largest value.
  final double max;

  /// The number of steps between [min] and [max], or `null` for continuous.
  final int? divisions;

  /// Called once when a drag, tap or key press ends.
  final ValueChanged<double>? onChangeEnd;

  /// The value's text, for the thumb label and screen readers.
  final String Function(double value)? valueLabel;

  /// Names the slider for screen readers.
  final String? semanticLabel;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoSlider> createState() => _CamoSliderState();
}

const double _continuousKeyStep = 0.01;
const double _pageStep = 0.1;

class _CamoSliderState extends State<CamoSlider> {
  final _interaction = CamoInteractionController();
  FocusNode? _ownNode;
  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());
  double? _latest;

  @override
  void dispose() {
    _interaction.dispose();
    _ownNode?.dispose();
    super.dispose();
  }

  double get _span => widget.max - widget.min > 0 ? widget.max - widget.min : 1;

  double get _fraction =>
      ((widget.value.clamp(widget.min, widget.max) - widget.min) / _span).clamp(
        0,
        1,
      );

  double _valueOf(double fraction) =>
      widget.min + camoSnap(fraction.clamp(0, 1), widget.divisions) * _span;

  double get _keyStep {
    final d = widget.divisions;
    return d != null && d > 0 ? 1 / d : _continuousKeyStep;
  }

  void _change(double fraction) {
    final value = _valueOf(fraction);
    _latest = value;
    widget.onChanged?.call(value);
  }

  void _end() => widget.onChangeEnd?.call(_latest ?? widget.value);

  // The fraction under x, on the track that runs from half a thumb in from each end of the slider's width.
  double _at(double x, double inset, bool rtl) {
    final width = (context.findRenderObject()! as RenderBox).size.width;
    final f = (x - inset) / (width - inset * 2).clamp(1, double.infinity);
    return rtl ? 1 - f : f;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event, bool rtl) {
    if (widget.onChanged == null || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final f = _fraction;
    final step = _keyStep;
    final page = step > _pageStep ? step : _pageStep;
    final key = event.logicalKey;
    final double? target = switch (key) {
      LogicalKeyboardKey.arrowRight => f + (rtl ? -step : step),
      LogicalKeyboardKey.arrowLeft => f - (rtl ? -step : step),
      LogicalKeyboardKey.arrowUp => f + step,
      LogicalKeyboardKey.arrowDown => f - step,
      LogicalKeyboardKey.pageUp => f + page,
      LogicalKeyboardKey.pageDown => f - page,
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => 1,
      _ => null,
    };
    if (target == null) return KeyEventResult.ignored;
    _change(target);
    _end();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSlider');
    final theme = Camouflage.themeOf(context, component: 'CamoSlider');
    final style = skin.slider.defaults(theme).merge(theme.components.slider);
    final enabled = widget.onChanged != null;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final valueLabel = widget.valueLabel;
    final inset = style.thumbSize.width / 2;
    final f = _fraction;
    String describe(double fraction) =>
        valueLabel?.call(_valueOf(fraction)) ??
        '${(camoSnap(fraction, widget.divisions) * 100).round()}%';
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.slider.render(
        context,
        SliderState(
          fraction: f,
          divisions: widget.divisions,
          enabled: enabled,
          valueText: valueLabel?.call(widget.value),
          interaction: _interaction.value,
          controller: _interaction,
        ),
        theme,
        style,
      ),
    );
    return Semantics(
      slider: true,
      enabled: enabled,
      label: widget.semanticLabel,
      value: describe(f),
      increasedValue: describe((f + _keyStep).clamp(0, 1)),
      decreasedValue: describe((f - _keyStep).clamp(0, 1)),
      onIncrease: enabled
          ? () {
              _change(f + _keyStep);
              _end();
            }
          : null,
      onDecrease: enabled
          ? () {
              _change(f - _keyStep);
              _end();
            }
          : null,
      excludeSemantics: true,
      child: Focus(
        focusNode: _node,
        canRequestFocus: enabled,
        onKeyEvent: (node, event) => _onKey(node, event, rtl),
        onFocusChange: (focused) => _interaction.setFocused(
          focused,
          byKeyboard:
              focused &&
              FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional,
        ),
        child: MouseRegion(
          onEnter: enabled ? (_) => _interaction.setHovered(true) : null,
          onExit: enabled ? (_) => _interaction.setHovered(false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (d) {
                    _interaction.pressDown(d.localPosition);
                    _change(_at(d.localPosition.dx, inset, rtl));
                  }
                : null,
            onTapUp: enabled
                ? (_) {
                    _interaction.pressEnd();
                    _end();
                  }
                : null,
            onTapCancel: enabled ? _interaction.pressEnd : null,
            onHorizontalDragStart: enabled
                ? (d) {
                    _interaction.setDragged(true);
                    _change(_at(d.localPosition.dx, inset, rtl));
                  }
                : null,
            onHorizontalDragUpdate: enabled
                ? (d) => _change(_at(d.localPosition.dx, inset, rtl))
                : null,
            onHorizontalDragEnd: enabled
                ? (_) {
                    _interaction
                      ..setDragged(false)
                      ..pressEnd();
                    _end();
                  }
                : null,
            child: CamoTouchTarget(
              minSize: const Size(0, kCamoMinTouchTarget),
              child: visual,
            ),
          ),
        ),
      ),
    );
  }
}
