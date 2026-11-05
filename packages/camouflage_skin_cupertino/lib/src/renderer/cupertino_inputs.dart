import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_primitives.dart' show thumbColor;

// Cupertino's selection controls, slider and stepper (base Cupertino Skin §3.2): accent when on (the switch too,
// decided 2026-09-27), a round check, a 51 x 31 switch, a checkmark radio, a segmented track with a white thumb,
// a 28 thumb with a shadow, a gray -/+ pill.

const double _hairline = 0.5;
const double _controlBorder = 1.5;
const double _stepWidth = 47;
const double _disabled = 0.38;
const _clear = Color(0x00000000);

/// Cupertino's checkbox: a 22 round box with a 1.5 outline; the accent with a white check when checked.
class CupertinoCheckboxRenderer implements CamoCheckboxRenderer {
  /// Creates the renderer.
  const CupertinoCheckboxRenderer();

  @override
  CamoCheckboxStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoCheckboxStyle(
      boxSize: 22,
      shape: theme.shapes.full,
      borderWidth: _controlBorder,
      labelStyle: theme.typography.bodyLarge,
      labelPosition: CamoLabelPosition.end,
      labelGap: theme.spacing.m,
      descriptionStyle: theme.typography.bodySmall.copyWith(
        color: c.onSurfaceVariant,
      ),
      colors: CheckboxColors(
        checkedBox: c.primary,
        checkmark: c.onPrimary,
        uncheckedBorder: c.outline,
        label: c.onSurface,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    CheckboxState state,
    CamoTheme theme,
    CamoCheckboxStyle style,
  ) {
    final colors = style.colors;
    final border = state.error != null
        ? theme.colors.error
        : (state.checked ? colors.checkedBox : colors.uncheckedBorder);
    final box = Camouflage.skinOf(context).feedback.wrap(
      controller: state.controller,
      contentColor: colors.checkedBox,
      shape: style.shape,
      theme: theme,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: state.checked ? 1 : 0),
        duration: theme.motion.durationShort,
        builder: (context, on, _) => CustomPaint(
          size: Size.square(style.boxSize),
          painter: _BoxPainter(
            fill: colors.checkedBox.withValues(alpha: colors.checkedBox.a * on),
            border: border,
            borderWidth: style.borderWidth,
            shape: style.shape,
            check: colors.checkmark.withValues(alpha: colors.checkmark.a * on),
          ),
        ),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: CamoLabelledControl(
        labelPosition: style.labelPosition,
        gap: style.labelGap,
        centerControl: false,
        firstLineHeight: _lineHeight(context, style.labelStyle),
        control: box,
        label: _label(
          state.label,
          state.description,
          style.labelStyle,
          colors.label,
          style.descriptionStyle,
        ),
        below: _error(state.error, theme),
      ),
    );
  }
}

/// Cupertino's switch: a 51 × 31 track, a 27 white thumb with a shadow; the accent when on, gray when off.
class CupertinoSwitchRenderer implements CamoSwitchRenderer {
  /// Creates the renderer.
  const CupertinoSwitchRenderer();

  @override
  CamoSwitchStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSwitchStyle(
      showThumbIcons: false,
      thumbIcons: null,
      trackWidth: 51,
      trackHeight: 31,
      thumbSizeOff: 27,
      thumbSizeOn: 27,
      thumbSizePressed: 27,
      labelStyle: theme.typography.bodyLarge,
      labelPosition: CamoLabelPosition.start,
      labelGap: theme.spacing.l,
      descriptionStyle: theme.typography.bodySmall.copyWith(
        color: c.onSurfaceVariant,
      ),
      colors: SwitchColors(
        trackOn: c.primary,
        trackOff: c.surfaceContainerHigh,
        thumbOn: const Color(0xFFFFFFFF),
        thumbOff: const Color(0xFFFFFFFF),
        trackOffBorder: _clear,
        label: c.onSurface,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    SwitchState state,
    CamoTheme theme,
    CamoSwitchStyle style,
  ) {
    final colors = style.colors;
    final interaction = state.interaction;
    final thumb = interaction.pressed || interaction.dragged
        ? style.thumbSizePressed
        : (state.checked ? style.thumbSizeOn : style.thumbSizeOff);
    final track = Camouflage.skinOf(context).feedback.wrap(
      controller: state.controller,
      contentColor: colors.trackOn,
      shape: BorderRadius.circular(style.trackHeight / 2),
      theme: theme,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: state.dragFraction ?? (state.checked ? 1 : 0)),
        duration: state.dragFraction != null
            ? Duration.zero
            : theme.motion.durationShort,
        curve: theme.motion.easingStandard,
        builder: (context, on, _) => _SwitchTrack(
          style: style,
          on: on,
          thumb: thumb,
          checked: state.checked,
          thumbBorder: colors.trackOffBorder,
        ),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: CamoLabelledControl(
        labelPosition: style.labelPosition,
        gap: style.labelGap,
        centerControl: true,
        firstLineHeight: 0,
        control: track,
        label: _label(
          state.label,
          state.description,
          style.labelStyle,
          colors.label,
          style.descriptionStyle,
        ),
        below: _error(state.error, theme),
      ),
    );
  }
}

/// Cupertino's radio: the iOS list style, a check mark in the accent on the selected row. An unselected option keeps a
/// faint ring, so a horizontal group (core doesn't tell the renderer) still reads as options.
class CupertinoRadioRenderer implements CamoRadioRenderer {
  /// Creates the renderer.
  const CupertinoRadioRenderer();

  @override
  CamoRadioStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoRadioStyle(
      size: 22,
      dotSize: 8,
      borderWidth: _hairline,
      labelStyle: theme.typography.bodyLarge,
      descriptionStyle: theme.typography.bodySmall.copyWith(
        color: c.onSurfaceVariant,
      ),
      labelPosition: CamoLabelPosition.start,
      labelGap: theme.spacing.m,
      colors: RadioColors(
        selected: c.primary,
        unselected: c.outline,
        error: c.error,
        label: c.onSurface,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    RadioState state,
    CamoTheme theme,
    CamoRadioStyle style,
  ) {
    final colors = style.colors;
    final ring = state.error
        ? colors.error
        : (state.selected ? colors.selected : colors.unselected);
    final circle = Camouflage.skinOf(context).feedback.wrap(
      controller: state.controller,
      contentColor: colors.selected,
      shape: BorderRadius.circular(style.size / 2),
      theme: theme,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: state.selected ? 1 : 0),
        duration: theme.motion.durationShort,
        builder: (context, on, _) => CustomPaint(
          size: Size.square(style.size),
          painter: _RadioPainter(
            ring: ring.withValues(alpha: ring.a * (1 - on)),
            width: style.borderWidth,
            check: colors.selected.withValues(alpha: on),
          ),
        ),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: CamoLabelledControl(
        labelPosition: style.labelPosition,
        gap: style.labelGap,
        centerControl: false,
        firstLineHeight: _lineHeight(context, style.labelStyle),
        control: circle,
        label: _label(
          state.label,
          state.description,
          style.labelStyle,
          colors.label,
          style.descriptionStyle,
        ),
      ),
    );
  }
}

/// Cupertino's segmented control: a 32 gray track, radius 8; the selected segment is a white thumb with a shadow, with
/// no check icon.
class CupertinoSegmentedControlRenderer
    implements CamoSegmentedControlRenderer {
  /// Creates the renderer.
  const CupertinoSegmentedControlRenderer();

  @override
  CamoSegmentedControlStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSegmentedControlStyle(
      height: 32,
      shape: theme.shapes.small,
      borderWidth: 0,
      textStyle: theme.typography.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
      ),
      iconSize: 16,
      showCheckIcon: false,
      colors: SegmentedColors(
        container: c.secondaryContainer,
        border: _clear,
        selectedContainer: thumbColor(theme),
        selectedContent: c.onSurface,
        content: c.onSurface,
      ),
    );
  }

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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.colors.container,
          borderRadius: style.shape,
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.xxs),
          child: Row(spacing: theme.spacing.xxs, children: segments),
        ),
      ),
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
    final colors = style.colors;
    final shape = theme.shapes.extraSmall;
    final content = state.selected ? colors.selectedContent : colors.content;
    return Camouflage.skinOf(context).feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: shape,
      theme: theme,
      child: AnimatedContainer(
        duration: theme.motion.durationShort,
        decoration: BoxDecoration(
          color: state.selected ? colors.selectedContainer : _clear,
          borderRadius: shape,
          boxShadow: state.selected
              ? const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: theme.spacing.m),
        alignment: Alignment.center,
        child: Opacity(
          opacity: state.enabled ? 1 : _disabled,
          child: _segmentContent(
            slots,
            state.selected && style.showCheckIcon,
            content,
            style,
          ),
        ),
      ),
    );
  }
}

/// Cupertino's slider: a 4 track (gray, accent active), a 28 round white thumb with a shadow,
/// and the value label only while dragging.
class CupertinoSliderRenderer implements CamoSliderRenderer {
  /// Creates the renderer.
  const CupertinoSliderRenderer();

  @override
  CamoSliderStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSliderStyle(
      trackHeight: 4,
      thumbSize: const Size(28, 28),
      showStopMarks: false,
      showValueLabel: true,
      valueLabelStyle: theme.typography.labelMedium,
      colors: SliderColors(
        activeTrack: c.primary,
        inactiveTrack: c.secondaryContainer,
        thumb: const Color(0xFFFFFFFF),
        stopMark: c.onSurfaceVariant,
        valueLabel: c.inverseSurface,
        valueLabelText: c.inverseOnSurface,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    SliderState state,
    CamoTheme theme,
    CamoSliderStyle style,
  ) {
    final size = style.thumbSize;
    final shape = BorderRadius.circular(size.shortestSide / 2);
    final thumb = Camouflage.skinOf(context).feedback.wrap(
      controller: state.controller,
      contentColor: theme.colors.onSurface,
      shape: shape,
      theme: theme,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: style.colors.thumb,
          borderRadius: shape,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: _sliderLayout(state, theme, style, thumb),
    );
  }
}

/// Cupertino's stepper: the value beside a gray -/+ pill (UIStepper), halves of 47 x 32 with a hairline between.
class CupertinoStepperRenderer implements CamoStepperRenderer {
  /// Creates the renderer.
  const CupertinoStepperRenderer();

  @override
  CamoStepperStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoStepperStyle(
      layout: StepperLayout.inline,
      buttonAppearance: Appearance.soft,
      height: 32,
      valueMinWidth: 40,
      valueStyle: theme.typography.titleMedium,
      decreaseIcon: const IconSource.builder(_minusIcon),
      increaseIcon: const IconSource.builder(_plusIcon),
      colors: StepperColors(
        button: c.onSurface,
        value: c.onSurface,
        field: c.secondaryContainer,
        error: c.error,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    StepperState state,
    StepperSlots slots,
    CamoTheme theme,
    CamoStepperStyle style,
  ) {
    final border = state.error ? style.colors.error : style.colors.field;
    final shape = theme.shapes.small;
    final Widget content = switch (style.layout) {
      StepperLayout.inline => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing.m,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: style.valueMinWidth),
            child: Center(widthFactor: 1, heightFactor: 1, child: slots.input),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: style.colors.field,
              borderRadius: shape,
              border: state.error
                  ? Border.all(color: border, width: _hairline)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepButton(
                  context,
                  state.decrease,
                  style.decreaseIcon,
                  style,
                  theme,
                ),
                SizedBox(
                  width: _hairline,
                  height: style.height / 2,
                  child: ColoredBox(color: theme.colors.outline),
                ),
                _stepButton(
                  context,
                  state.increase,
                  style.increaseIcon,
                  style,
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
      StepperLayout.split => Container(
        constraints: BoxConstraints(minHeight: style.height),
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(
            color: state.focused ? theme.colors.primary : border,
            width: state.focused ? _controlBorder : _hairline,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing.m),
                child: Center(child: slots.input),
              ),
              Column(
                children: [
                  Expanded(
                    child: _splitButton(
                      context,
                      state.increase,
                      style.increaseIcon,
                      style,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _splitButton(
                      context,
                      state.decrease,
                      style.decreaseIcon,
                      style,
                      theme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    };
    return Opacity(opacity: state.enabled ? 1 : _disabled, child: content);
  }

  Widget _stepButton(
    BuildContext context,
    StepperButton button,
    IconSource icon,
    CamoStepperStyle style,
    CamoTheme theme,
  ) {
    final shape = theme.shapes.small;
    final content = style.colors.button;
    return button.wrap(
      CamoTouchTarget(
        child: Camouflage.skinOf(context).feedback.wrap(
          controller: button.controller,
          contentColor: content,
          shape: shape,
          theme: theme,
          child: Opacity(
            opacity: button.enabled ? 1 : _disabled,
            child: SizedBox(
              width: _stepWidth,
              height: style.height,
              child: Center(child: CamoIcon(icon, size: 16, color: content)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _splitButton(
    BuildContext context,
    StepperButton button,
    IconSource icon,
    CamoStepperStyle style,
    CamoTheme theme,
  ) => button.wrap(
    Camouflage.skinOf(context).feedback.wrap(
      controller: button.controller,
      contentColor: style.colors.button,
      shape: BorderRadius.zero,
      theme: theme,
      child: Opacity(
        opacity: button.enabled ? 1 : _disabled,
        child: SizedBox(
          width: style.height * 3 / 4,
          child: Center(
            child: CamoIcon(icon, size: 12, color: style.colors.button),
          ),
        ),
      ),
    ),
  );
}

// The label and its description line, or `null` for a bare control.
Widget? _label(
  List<CamoSpan>? label,
  String? description,
  TextStyle labelStyle,
  Color labelColor,
  TextStyle descriptionStyle,
) => label == null
    ? null
    : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CamoText.rich(label, style: labelStyle, color: labelColor),
          if (description != null)
            CamoText(
              description,
              style: descriptionStyle,
              color: descriptionStyle.color,
            ),
        ],
      );

// The message under a control. Core announces it, so the text excludes its own semantics.
Widget? _error(String? message, CamoTheme theme) => message == null
    ? null
    : Padding(
        padding: EdgeInsets.only(top: theme.spacing.xs),
        child: ExcludeSemantics(
          child: CamoText(
            message,
            style: theme.typography.bodySmall,
            color: theme.colors.error,
          ),
        ),
      );

/// The height of one line of [style] at the current text scale.
double _lineHeight(BuildContext context, TextStyle style) {
  final size = MediaQuery.textScalerOf(context).scale(style.fontSize ?? 14);
  return size * (style.height ?? 1.4);
}

Widget _segmentContent(
  SegmentSlots slots,
  bool check,
  Color color,
  CamoSegmentedControlStyle style,
) => CamoContentStyle(
  color: color,
  iconStyle: CamoIconStyle(size: style.iconSize, color: color),
  child:
      slots.child ??
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (check)
            CustomPaint(
              size: Size.square(style.iconSize),
              painter: _CheckPainter(color),
            ),
          ?slots.icon,
          if (slots.label != null)
            Flexible(
              child: Text(
                slots.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.textStyle.copyWith(color: color),
              ),
            ),
        ],
      ),
);

/// The track across the width (inset by half a thumb at each end, where core maps touches), the stops, [thumb]
/// at the value and, while dragging, the value label above it.
Widget _sliderLayout(
  SliderState state,
  CamoTheme theme,
  CamoSliderStyle style,
  Widget thumb,
) {
  final size = style.thumbSize;
  final height = size.height > style.trackHeight
      ? size.height
      : style.trackHeight;
  final valueText = state.valueText;
  return SizedBox(
    height: height,
    width: double.infinity,
    child: Builder(
      builder: (context) {
        final direction = Directionality.of(context);
        return Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.centerStart,
          children: [
            SizedBox(
              width: double.infinity,
              height: style.trackHeight,
              child: CustomPaint(
                painter: _TrackPainter(
                  fraction: state.fraction,
                  inset: size.width / 2,
                  active: style.colors.activeTrack,
                  inactive: style.colors.inactiveTrack,
                  stop: style.colors.stopMark,
                  stops: style.showStopMarks ? state.divisions : null,
                  rtl: direction == TextDirection.rtl,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: _AtFraction(state.fraction, direction, size.width, 0),
                child: thumb,
              ),
            ),
            if (style.showValueLabel &&
                state.interaction.dragged &&
                valueText != null)
              Positioned.fill(
                child: CustomSingleChildLayout(
                  delegate: _AtFraction(
                    state.fraction,
                    direction,
                    size.width,
                    height + theme.spacing.s,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.s,
                      vertical: theme.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: style.colors.valueLabel,
                      borderRadius: theme.shapes.small,
                    ),
                    child: Text(
                      valueText,
                      style: style.valueLabelStyle.copyWith(
                        color: style.colors.valueLabelText,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

// Centers the child on the thumb's center at [fraction] (from the start), [above] pixels above the thumb's middle
// (0 = vertically centered on it).
class _AtFraction extends SingleChildLayoutDelegate {
  _AtFraction(this.fraction, this.direction, this.thumbWidth, this.above);

  final double fraction;
  final TextDirection direction;
  final double thumbWidth;
  final double above;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final fromStart =
        (size.width - thumbWidth) * fraction +
        thumbWidth / 2 -
        childSize.width / 2;
    final x = direction == TextDirection.rtl
        ? size.width - fromStart - childSize.width
        : fromStart;
    final y = above == 0
        ? (size.height - childSize.height) / 2
        : size.height / 2 - above - childSize.height / 2;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_AtFraction old) =>
      old.fraction != fraction ||
      old.direction != direction ||
      old.thumbWidth != thumbWidth ||
      old.above != above;
}

class _SwitchTrack extends StatelessWidget {
  const _SwitchTrack({
    required this.style,
    required this.on,
    required this.thumb,
    required this.checked,
    required this.thumbBorder,
  });

  final CamoSwitchStyle style;
  final double on;
  final double thumb;
  final bool checked;
  final Color thumbBorder;

  @override
  Widget build(BuildContext context) {
    final colors = style.colors;
    final off = 1 - on;
    final center =
        style.trackHeight / 2 + (style.trackWidth - style.trackHeight) * on;
    final border = thumbBorder.withValues(alpha: thumbBorder.a * off);
    final icons = style.thumbIcons;
    final icon = checked ? icons?.checked : icons?.unchecked;
    return Container(
      width: style.trackWidth,
      height: style.trackHeight,
      decoration: BoxDecoration(
        color: Color.lerp(colors.trackOff, colors.trackOn, on),
        borderRadius: BorderRadius.circular(style.trackHeight / 2),
        border: Border.all(color: border, width: _hairline),
      ),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          PositionedDirectional(
            start: center - thumb / 2,
            child: Container(
              width: thumb,
              height: thumb,
              decoration: BoxDecoration(
                color: Color.lerp(colors.thumbOff, colors.thumbOn, on),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: style.showThumbIcons && icon != null
                  ? CamoIcon(
                      icon,
                      size: thumb * 2 / 3,
                      color: checked ? colors.trackOn : colors.trackOff,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxPainter extends CustomPainter {
  _BoxPainter({
    required this.fill,
    required this.border,
    required this.borderWidth,
    required this.shape,
    required this.check,
  });

  final Color fill;
  final Color border;
  final double borderWidth;
  final BorderRadius shape;
  final Color check;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = shape.toRRect(rect);
    canvas.drawRRect(r, Paint()..color = fill);
    canvas.drawRRect(
      r.deflate(borderWidth / 2),
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
    _CheckPainter(check).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_BoxPainter old) =>
      old.fill != fill ||
      old.border != border ||
      old.borderWidth != borderWidth ||
      old.shape != shape ||
      old.check != check;
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.24, s * 0.52)
      ..lineTo(s * 0.42, s * 0.70)
      ..lineTo(s * 0.77, s * 0.32);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = s / 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({required this.ring, required this.width, required this.check});

  final Color ring;
  final double width;
  final Color check;

  @override
  void paint(Canvas canvas, Size size) {
    if (ring.a > 0) {
      canvas.drawCircle(
        size.center(Offset.zero),
        (size.shortestSide - width) / 2,
        Paint()
          ..color = ring
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }
    _CheckPainter(check).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_RadioPainter old) =>
      old.ring != ring || old.width != width || old.check != check;
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.fraction,
    required this.inset,
    required this.active,
    required this.inactive,
    required this.stop,
    required this.stops,
    required this.rtl,
  });

  final double fraction;
  final double inset;
  final Color active;
  final Color inactive;
  final Color stop;
  final int? stops;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final travel = size.width - inset * 2;
    double x(double f) =>
        rtl ? size.width - inset - f * travel : inset + f * travel;
    final y = size.height / 2;
    final line = Paint()
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x(0), y), Offset(x(1), y), line..color = inactive);
    canvas.drawLine(
      Offset(x(0), y),
      Offset(x(fraction), y),
      line..color = active,
    );
    final n = stops;
    if (n != null && n > 0) {
      for (var i = 0; i <= n; i++) {
        canvas.drawCircle(
          Offset(x(i / n), y),
          size.height / 4,
          Paint()..color = stop,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.fraction != fraction ||
      old.inset != inset ||
      old.active != active ||
      old.inactive != inactive ||
      old.stop != stop ||
      old.stops != stops ||
      old.rtl != rtl;
}

/// A − drawn in [color], [size] square.
Widget _minusIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _StrokePainter(color ?? const Color(0xFF000000), plus: false),
);

/// A + drawn in [color], [size] square.
Widget _plusIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _StrokePainter(color ?? const Color(0xFF000000), plus: true),
);

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.color, {required this.plus});

  final Color color;
  final bool plus;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..color = color
      ..strokeWidth = s / 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.21, s / 2), Offset(s * 0.79, s / 2), paint);
    if (plus) {
      canvas.drawLine(Offset(s / 2, s * 0.21), Offset(s / 2, s * 0.79), paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.color != color || old.plus != plus;
}
