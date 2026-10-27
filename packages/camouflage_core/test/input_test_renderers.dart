import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M5 inputs in the plain test skin: boxes and text, laid out from the style.

Widget _square(double size, Color? color) => SizedBox.square(
  dimension: size,
  child: ColoredBox(color: color ?? const Color(0xFF000000)),
);

Widget _labelRow(
  Widget control,
  List<CamoSpan>? label,
  String? description,
  String? error,
) => CamoLabelledControl(
  labelPosition: CamoLabelPosition.end,
  gap: 8,
  centerControl: true,
  firstLineHeight: 0,
  control: control,
  label: label == null
      ? null
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CamoText.rich(label),
            if (description != null) CamoText(description),
          ],
        ),
  below: error == null ? null : ExcludeSemantics(child: CamoText(error)),
);

class PlainCheckbox implements CamoCheckboxRenderer {
  const PlainCheckbox();

  @override
  CamoCheckboxStyle defaults(CamoTheme theme) => CamoCheckboxStyle(
    boxSize: 18,
    shape: BorderRadius.zero,
    borderWidth: 2,
    labelStyle: theme.typography.bodyLarge,
    labelPosition: CamoLabelPosition.end,
    labelGap: 12,
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
  ) => _labelRow(
    _square(style.boxSize, style.colors.checkedBox),
    state.label,
    state.description,
    state.error,
  );
}

class PlainSwitch implements CamoSwitchRenderer {
  const PlainSwitch();

  @override
  CamoSwitchStyle defaults(CamoTheme theme) => CamoSwitchStyle(
    showThumbIcons: false,
    thumbIcons: null,
    trackWidth: 52,
    trackHeight: 32,
    thumbSizeOff: 16,
    thumbSizeOn: 24,
    thumbSizePressed: 28,
    labelStyle: theme.typography.bodyLarge,
    labelPosition: CamoLabelPosition.start,
    labelGap: 16,
    descriptionStyle: theme.typography.bodySmall,
    colors: SwitchColors(
      trackOn: theme.colors.primary,
      trackOff: theme.colors.surface,
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
  ) => _labelRow(
    SizedBox(
      width: style.trackWidth,
      height: style.trackHeight,
      child: ColoredBox(color: style.colors.trackOff),
    ),
    state.label,
    state.description,
    state.error,
  );
}

class PlainRadio implements CamoRadioRenderer {
  const PlainRadio();

  @override
  CamoRadioStyle defaults(CamoTheme theme) => CamoRadioStyle(
    size: 20,
    dotSize: 10,
    borderWidth: 2,
    labelStyle: theme.typography.bodyLarge,
    descriptionStyle: theme.typography.bodyMedium,
    labelPosition: CamoLabelPosition.end,
    labelGap: 12,
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
  ) => _labelRow(
    _square(style.size, style.colors.unselected),
    state.label,
    state.description,
    null,
  );
}

class PlainSegmented implements CamoSegmentedControlRenderer {
  const PlainSegmented();

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
          container: const Color(0x00000000),
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
  ) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: style.height),
    child: Row(children: segments),
  );

  @override
  Widget renderSegment(
    BuildContext context,
    SegmentState state,
    SegmentSlots slots,
    CamoTheme theme,
    CamoSegmentedControlStyle style,
  ) => Center(
    child:
        slots.child ??
        (slots.label != null ? Text(slots.label!, maxLines: 1) : slots.icon!),
  );
}

class PlainSlider implements CamoSliderRenderer {
  const PlainSlider();

  @override
  CamoSliderStyle defaults(CamoTheme theme) => CamoSliderStyle(
    trackHeight: 4,
    thumbSize: const Size(20, 20),
    showStopMarks: false,
    showValueLabel: false,
    valueLabelStyle: theme.typography.labelLarge,
    colors: SliderColors(
      activeTrack: theme.colors.primary,
      inactiveTrack: theme.colors.outline,
      thumb: theme.colors.primary,
      stopMark: theme.colors.onPrimary,
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
  ) => SizedBox(
    width: double.infinity,
    height: style.thumbSize.height,
    child: ColoredBox(color: style.colors.inactiveTrack),
  );
}

class PlainStepper implements CamoStepperRenderer {
  const PlainStepper();

  @override
  CamoStepperStyle defaults(CamoTheme theme) => CamoStepperStyle(
    layout: StepperLayout.inline,
    buttonAppearance: Appearance.outline,
    height: 40,
    valueMinWidth: 40,
    valueStyle: theme.typography.titleMedium,
    decreaseIcon: const IconSource.builder(_square),
    increaseIcon: const IconSource.builder(_square),
    colors: StepperColors(
      button: theme.colors.outline,
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
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      state.decrease.wrap(_square(style.height, style.colors.button)),
      slots.input,
      state.increase.wrap(_square(style.height, style.colors.button)),
    ],
  );
}
