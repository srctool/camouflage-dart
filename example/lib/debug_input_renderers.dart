import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// DebugSkin's M5 inputs: squares and text, no animation, a magenta border for focus. They prove the contract,
// not a look.

const _focus = Color(0xFFFF00FF);
const _clear = Color(0x00000000);
const double _disabled = 0.38;

Widget _box(
  double w,
  double h,
  Color fill, {
  Color? border,
  bool focused = false,
}) => Container(
  width: w,
  height: h,
  decoration: BoxDecoration(
    color: fill,
    border: Border.all(
      color: focused ? _focus : (border ?? _clear),
      width: focused ? 2 : 1,
    ),
  ),
);

Widget? _label(List<CamoSpan>? label, String? description) => label == null
    ? null
    : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CamoText.rich(label),
          if (description != null) CamoText(description),
        ],
      );

Widget? _error(String? error, CamoTheme theme) => error == null
    ? null
    : ExcludeSemantics(child: CamoText(error, color: theme.colors.error));

/// DebugSkin's checkbox: a square, filled when checked.
class DebugCheckboxRenderer implements CamoCheckboxRenderer {
  /// Creates the renderer.
  const DebugCheckboxRenderer();

  @override
  CamoCheckboxStyle defaults(CamoTheme theme) => CamoCheckboxStyle(
    boxSize: 18,
    shape: BorderRadius.zero,
    borderWidth: 2,
    labelStyle: theme.typography.bodyLarge,
    labelPosition: CamoLabelPosition.end,
    labelGap: theme.spacing.m,
    descriptionStyle: theme.typography.bodySmall,
    colors: CheckboxColors(
      checkedBox: theme.colors.primary,
      checkmark: theme.colors.onPrimary,
      uncheckedBorder: theme.colors.outline,
      label: theme.colors.onSurface,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    CheckboxState state,
    CamoTheme theme,
    CamoCheckboxStyle style,
  ) => Opacity(
    opacity: state.enabled ? 1 : _disabled,
    child: CamoLabelledControl(
      labelPosition: style.labelPosition,
      gap: style.labelGap,
      centerControl: true,
      firstLineHeight: 0,
      control: _box(
        style.boxSize,
        style.boxSize,
        state.checked ? style.colors.checkedBox : _clear,
        border: state.error != null
            ? theme.colors.error
            : style.colors.uncheckedBorder,
        focused: state.interaction.focused,
      ),
      label: _label(state.label, state.description),
      below: _error(state.error, theme),
    ),
  );
}

/// DebugSkin's switch: a rectangle with a square at the start or the end.
class DebugSwitchRenderer implements CamoSwitchRenderer {
  /// Creates the renderer.
  const DebugSwitchRenderer();

  @override
  CamoSwitchStyle defaults(CamoTheme theme) => CamoSwitchStyle(
    showThumbIcons: false,
    thumbIcons: null,
    trackWidth: 44,
    trackHeight: 24,
    thumbSizeOff: 20,
    thumbSizeOn: 20,
    thumbSizePressed: 20,
    labelStyle: theme.typography.bodyLarge,
    labelPosition: CamoLabelPosition.start,
    labelGap: theme.spacing.l,
    descriptionStyle: theme.typography.bodySmall,
    colors: SwitchColors(
      trackOn: theme.colors.primary,
      trackOff: theme.colors.surfaceContainerHighest,
      thumbOn: theme.colors.onPrimary,
      thumbOff: theme.colors.outline,
      trackOffBorder: theme.colors.outline,
      label: theme.colors.onSurface,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    SwitchState state,
    CamoTheme theme,
    CamoSwitchStyle style,
  ) {
    final c = style.colors;
    final on = state.dragFraction == null
        ? state.checked
        : state.dragFraction! > 0.5;
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: CamoLabelledControl(
        labelPosition: style.labelPosition,
        gap: style.labelGap,
        centerControl: true,
        firstLineHeight: 0,
        control: Container(
          width: style.trackWidth,
          height: style.trackHeight,
          padding: const EdgeInsets.all(2),
          alignment: on
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: on ? c.trackOn : c.trackOff,
            border: Border.all(
              color: state.interaction.focused ? _focus : c.trackOffBorder,
            ),
          ),
          child: _box(
            style.thumbSizeOn,
            style.thumbSizeOn,
            on ? c.thumbOn : c.thumbOff,
          ),
        ),
        label: _label(state.label, state.description),
        below: _error(state.error, theme),
      ),
    );
  }
}

/// DebugSkin's radio: a square with a smaller square when selected.
class DebugRadioRenderer implements CamoRadioRenderer {
  /// Creates the renderer.
  const DebugRadioRenderer();

  @override
  CamoRadioStyle defaults(CamoTheme theme) => CamoRadioStyle(
    size: 18,
    dotSize: 8,
    borderWidth: 2,
    labelStyle: theme.typography.bodyLarge,
    descriptionStyle: theme.typography.bodySmall,
    labelPosition: CamoLabelPosition.end,
    labelGap: theme.spacing.m,
    colors: RadioColors(
      selected: theme.colors.primary,
      unselected: theme.colors.outline,
      error: theme.colors.error,
      label: theme.colors.onSurface,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    RadioState state,
    CamoTheme theme,
    CamoRadioStyle style,
  ) => Opacity(
    opacity: state.enabled ? 1 : _disabled,
    child: CamoLabelledControl(
      labelPosition: style.labelPosition,
      gap: style.labelGap,
      centerControl: true,
      firstLineHeight: 0,
      control: Container(
        width: style.size,
        height: style.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: state.interaction.focused
                ? _focus
                : (state.error ? style.colors.error : style.colors.unselected),
            width: style.borderWidth,
          ),
        ),
        child: state.selected
            ? _box(style.dotSize, style.dotSize, style.colors.selected)
            : null,
      ),
      label: _label(state.label, state.description),
    ),
  );
}

/// DebugSkin's segmented control: bordered boxes, the selected one filled.
class DebugSegmentedControlRenderer implements CamoSegmentedControlRenderer {
  /// Creates the renderer.
  const DebugSegmentedControlRenderer();

  @override
  CamoSegmentedControlStyle defaults(CamoTheme theme) =>
      CamoSegmentedControlStyle(
        height: 40,
        shape: BorderRadius.zero,
        borderWidth: 1,
        textStyle: theme.typography.labelLarge,
        iconSize: 18,
        showCheckIcon: false,
        colors: SegmentedColors(
          container: _clear,
          border: theme.colors.outline,
          selectedContainer: theme.colors.primary,
          selectedContent: theme.colors.onPrimary,
          content: theme.colors.onSurface,
        ),
      );

  @override
  Widget renderContainer(
    BuildContext context,
    SegmentedContainerState state,
    CamoTheme theme,
    CamoSegmentedControlStyle style,
    List<Widget> segments,
  ) => Opacity(
    opacity: state.enabled ? 1 : _disabled,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.height),
      child: Row(children: segments),
    ),
  );

  @override
  Widget renderSegment(
    BuildContext context,
    SegmentState state,
    SegmentSlots slots,
    CamoTheme theme,
    CamoSegmentedControlStyle style,
  ) {
    final c = style.colors;
    final content = state.selected ? c.selectedContent : c.content;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.s),
      decoration: BoxDecoration(
        color: state.selected ? c.selectedContainer : c.container,
        border: Border.all(
          color: state.interaction.focused ? _focus : c.border,
          width: state.interaction.focused ? 2 : style.borderWidth,
        ),
      ),
      child:
          slots.child ??
          (slots.label != null
              ? Text(
                  slots.label!,
                  maxLines: 1,
                  style: style.textStyle.copyWith(color: content),
                )
              : slots.icon!),
    );
  }
}

/// DebugSkin's slider: a line and a square thumb.
class DebugSliderRenderer implements CamoSliderRenderer {
  /// Creates the renderer.
  const DebugSliderRenderer();

  @override
  CamoSliderStyle defaults(CamoTheme theme) => CamoSliderStyle(
    trackHeight: 2,
    thumbSize: const Size(16, 16),
    showStopMarks: true,
    showValueLabel: true,
    valueLabelStyle: theme.typography.labelMedium,
    colors: SliderColors(
      activeTrack: theme.colors.primary,
      inactiveTrack: theme.colors.outline,
      thumb: theme.colors.primary,
      stopMark: theme.colors.onSurface,
      valueLabel: theme.colors.inverseSurface,
      valueLabelText: theme.colors.inverseOnSurface,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    SliderState state,
    CamoTheme theme,
    CamoSliderStyle style,
  ) => Opacity(
    opacity: state.enabled ? 1 : _disabled,
    child: SizedBox(
      height: style.thumbSize.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: style.trackHeight,
            child: ColoredBox(color: style.colors.inactiveTrack),
          ),
          Align(
            alignment: AlignmentDirectional(state.fraction * 2 - 1, 0),
            child: _box(
              style.thumbSize.width,
              style.thumbSize.height,
              style.colors.thumb,
              focused: state.interaction.focused,
            ),
          ),
        ],
      ),
    ),
  );
}

/// DebugSkin's stepper: − and + boxes around the value.
class DebugStepperRenderer implements CamoStepperRenderer {
  /// Creates the renderer.
  const DebugStepperRenderer();

  @override
  CamoStepperStyle defaults(CamoTheme theme) => CamoStepperStyle(
    layout: StepperLayout.inline,
    buttonAppearance: Appearance.outline,
    height: 40,
    valueMinWidth: 48,
    valueStyle: theme.typography.titleMedium,
    decreaseIcon: const IconSource.builder(_glyph),
    increaseIcon: const IconSource.builder(_glyph),
    colors: StepperColors(
      button: theme.colors.primary,
      value: theme.colors.onSurface,
      field: theme.colors.outline,
      error: theme.colors.error,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    StepperState state,
    StepperSlots slots,
    CamoTheme theme,
    CamoStepperStyle style,
  ) {
    final border = state.error ? style.colors.error : style.colors.field;
    Widget button(StepperButton b, String glyph) => b.wrap(
      CamoTouchTarget(
        child: Opacity(
          opacity: b.enabled ? 1 : _disabled,
          child: Container(
            width: style.height,
            height: style.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: b.interaction.focused ? _focus : border,
              ),
            ),
            child: Text(
              glyph,
              style: style.valueStyle.copyWith(color: style.colors.button),
            ),
          ),
        ),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          button(state.decrease, '−'),
          slots.input,
          button(state.increase, '+'),
        ],
      ),
    );
  }
}

Widget _glyph(double size, Color? color) => SizedBox.square(dimension: size);
