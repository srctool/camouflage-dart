import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import '../fluent_tokens.dart';

// Fluent's Checkbox, Switch, Radio, toggle-button group, Slider and SpinButton (base Fluent Skin §3.2). Hover and
// press swap to FluentTokens' steps; Subtle draws the focus.

const double _hairline = 1;
const double _disabled = 0.38;
const _clear = Color(0x00000000);

/// Fluent's Checkbox: a 16 box, radius 2, a 1 px stroke; the brand fill with a white check when checked.
class FluentCheckboxRenderer implements CamoCheckboxRenderer {
  /// Creates the renderer.
  const FluentCheckboxRenderer();

  @override
  CamoCheckboxStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    return CamoCheckboxStyle(
      boxSize: 16,
      shape: theme.shapes.extraSmall,
      borderWidth: _hairline,
      labelStyle: theme.typography.bodyMedium,
      labelPosition: CamoLabelPosition.end,
      labelGap: theme.spacing.s,
      descriptionStyle: theme.typography.bodySmall.copyWith(
        color: c.onSurfaceVariant,
      ),
      colors: CheckboxColors(
        checkedBox: t?.brandBackground ?? c.primary,
        checkmark: t?.neutralForegroundOnBrand ?? c.onPrimary,
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
    final i = state.interaction;
    final fill = _brandStep(colors.checkedBox, i, theme.tokens<FluentTokens>());
    final border = state.error != null
        ? theme.colors.error
        : state.checked
        ? fill
        : (i.hovered || i.pressed
              ? theme.colors.onSurface
              : colors.uncheckedBorder);
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
            fill: fill.withValues(alpha: fill.a * on),
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

/// Fluent's Switch: a 40 × 20 track and a 14 thumb; the brand fill when on, a stroked track when off.
class FluentSwitchRenderer implements CamoSwitchRenderer {
  /// Creates the renderer.
  const FluentSwitchRenderer();

  @override
  CamoSwitchStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    return CamoSwitchStyle(
      showThumbIcons: false,
      thumbIcons: null,
      trackWidth: 40,
      trackHeight: 20,
      thumbSizeOff: 14,
      thumbSizeOn: 14,
      thumbSizePressed: 14,
      labelStyle: theme.typography.bodyMedium,
      labelPosition: CamoLabelPosition.end,
      labelGap: theme.spacing.s,
      descriptionStyle: theme.typography.bodySmall.copyWith(
        color: c.onSurfaceVariant,
      ),
      colors: SwitchColors(
        trackOn: t?.brandBackground ?? c.primary,
        trackOff: _clear,
        thumbOn: t?.neutralForegroundOnBrand ?? c.onPrimary,
        thumbOff: c.outline,
        trackOffBorder: c.outline,
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
          trackOn: _brandStep(
            colors.trackOn,
            interaction,
            theme.tokens<FluentTokens>(),
          ),
          offColor: interaction.hovered || interaction.pressed
              ? theme.colors.onSurface
              : null,
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

/// Fluent's Radio: a 16 circle with a 1 px stroke; a brand ring and a 10 dot when selected.
class FluentRadioRenderer implements CamoRadioRenderer {
  /// Creates the renderer.
  const FluentRadioRenderer();

  @override
  CamoRadioStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoRadioStyle(
      size: 16,
      dotSize: 10,
      borderWidth: _hairline,
      labelStyle: theme.typography.bodyMedium,
      descriptionStyle: theme.typography.bodySmall.copyWith(
        color: c.onSurfaceVariant,
      ),
      labelPosition: CamoLabelPosition.end,
      labelGap: theme.spacing.s,
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
    final active = state.interaction.hovered || state.interaction.pressed;
    final ring = state.error
        ? colors.error
        : state.selected
        ? colors.selected
        : (active ? theme.colors.onSurface : colors.unselected);
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
            ring: ring,
            width: style.borderWidth,
            dot: colors.selected,
            dotRadius: style.dotSize / 2 * on,
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

/// Fluent's toggle-button group: 32 tall, radius 4, one stroke around and between the segments; the selected
/// segment takes the selected neutral fill.
class FluentSegmentedControlRenderer implements CamoSegmentedControlRenderer {
  /// Creates the renderer.
  const FluentSegmentedControlRenderer();

  @override
  CamoSegmentedControlStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    return CamoSegmentedControlStyle(
      height: 32,
      shape: theme.shapes.small,
      borderWidth: _hairline,
      textStyle: theme.typography.bodyMedium,
      iconSize: 20,
      showCheckIcon: false,
      colors: SegmentedColors(
        container: c.surface,
        border: t?.neutralStroke1 ?? c.outlineVariant,
        selectedContainer: c.surfaceContainerHighest,
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
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: style.shape,
          border: Border.all(
            color: style.colors.border,
            width: style.borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: style.shape,
          child: ColoredBox(
            color: style.colors.container,
            child: Row(children: segments),
          ),
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
    final t = theme.tokens<FluentTokens>();
    final i = state.interaction;
    final content = state.selected ? colors.selectedContent : colors.content;
    final fill = state.selected
        ? colors.selectedContainer
        : i.pressed
        ? (t?.subtleBackgroundPressed ?? _clear)
        : i.hovered
        ? (t?.subtleBackgroundHover ?? _clear)
        : _clear;
    final divider = BorderSide(color: colors.border, width: style.borderWidth);
    return Camouflage.skinOf(context).feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: BorderRadius.zero,
      theme: theme,
      child: AnimatedContainer(
        duration: theme.motion.durationShort,
        decoration: BoxDecoration(
          color: fill,
          border: BorderDirectional(
            start: state.position.isFirst ? BorderSide.none : divider,
          ),
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

/// Fluent's Slider: a 4 rail and a 20 thumb, a neutral ring around a brand dot; no value label.
class FluentSliderRenderer implements CamoSliderRenderer {
  /// Creates the renderer.
  const FluentSliderRenderer();

  @override
  CamoSliderStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    return CamoSliderStyle(
      trackHeight: 4,
      thumbSize: const Size(20, 20),
      showStopMarks: false,
      showValueLabel: false,
      valueLabelStyle: theme.typography.bodySmall,
      colors: SliderColors(
        activeTrack: t?.brandBackground ?? c.primary,
        inactiveTrack: c.outline,
        thumb: t?.brandBackground ?? c.primary,
        stopMark: c.surface,
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
      child: CustomPaint(
        size: size,
        painter: _ThumbPainter(
          face: theme.colors.surface,
          ring:
              theme.tokens<FluentTokens>()?.neutralStroke1 ??
              theme.colors.outlineVariant,
          dot: _brandStep(
            style.colors.thumb,
            state.interaction,
            theme.tokens<FluentTokens>(),
          ),
        ),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: _sliderLayout(state, theme, style, thumb),
    );
  }
}

/// Fluent's SpinButton: a split field, 32 tall, a stroke with a stronger bottom edge and ▲ ▼ at the end.
class FluentStepperRenderer implements CamoStepperRenderer {
  /// Creates the renderer.
  const FluentStepperRenderer();

  @override
  CamoStepperStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    return CamoStepperStyle(
      layout: StepperLayout.split,
      buttonAppearance: Appearance.ghost,
      height: 32,
      valueMinWidth: 64,
      valueStyle: theme.typography.bodyMedium,
      decreaseIcon: const IconSource.builder(_chevronDownIcon),
      increaseIcon: const IconSource.builder(_chevronUpIcon),
      colors: StepperColors(
        button: c.onSurfaceVariant,
        value: c.onSurface,
        field: t?.neutralStroke1 ?? c.outlineVariant,
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
        spacing: theme.spacing.s,
        children: [
          _stepButton(
            context,
            state.decrease,
            style.decreaseIcon,
            style,
            theme,
            border,
          ),
          slots.input,
          _stepButton(
            context,
            state.increase,
            style.increaseIcon,
            style,
            theme,
            border,
          ),
        ],
      ),
      // Fluent's input: a stroke all around, a stronger bottom edge that turns brand (2 px) on focus.
      StepperLayout.split => Container(
        constraints: BoxConstraints(minHeight: style.height),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: state.error
                  ? style.colors.error
                  : (state.focused
                        ? theme.colors.primary
                        : theme.colors.outline),
              width: state.focused ? 2 : _hairline,
            ),
          ),
        ),
        decoration: BoxDecoration(
          color: theme.colors.surface,
          borderRadius: shape,
          border: Border.all(color: border, width: _hairline),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing.s),
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
    Color border,
  ) {
    final shape = theme.shapes.medium;
    final solid = style.buttonAppearance == Appearance.solid;
    final fill = switch (style.buttonAppearance) {
      Appearance.solid => theme.colors.primary,
      Appearance.soft || Appearance.raised => theme.colors.surfaceContainerHigh,
      _ => _clear,
    };
    final content = solid ? theme.colors.onPrimary : style.colors.button;
    return button.wrap(
      CamoTouchTarget(
        child: Camouflage.skinOf(context).feedback.wrap(
          controller: button.controller,
          contentColor: content,
          shape: shape,
          theme: theme,
          child: Opacity(
            opacity: button.enabled ? 1 : _disabled,
            child: Container(
              width: style.height,
              height: style.height,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: shape,
                border: style.buttonAppearance == Appearance.outline
                    ? Border.all(color: border, width: _hairline)
                    : null,
              ),
              alignment: Alignment.center,
              child: CamoIcon(icon, size: 16, color: content),
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
    required this.trackOn,
    required this.offColor,
  });

  final CamoSwitchStyle style;
  final double on;
  final double thumb;
  final bool checked;
  final Color trackOn;
  // The off stroke and thumb while hovered or pressed.
  final Color? offColor;

  @override
  Widget build(BuildContext context) {
    final colors = style.colors;
    final off = 1 - on;
    final stroke = offColor ?? colors.trackOffBorder;
    final inset = (style.trackHeight - thumb) / 2;
    final x = inset + (style.trackWidth - thumb - inset * 2) * on;
    final icons = style.thumbIcons;
    final icon = checked ? icons?.checked : icons?.unchecked;
    return Container(
      width: style.trackWidth,
      height: style.trackHeight,
      decoration: BoxDecoration(
        color: Color.lerp(colors.trackOff, trackOn, on),
        borderRadius: BorderRadius.circular(style.trackHeight / 2),
        border: Border.all(
          color: stroke.withValues(alpha: stroke.a * off),
          width: _hairline,
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          PositionedDirectional(
            start: x - _hairline,
            child: Container(
              width: thumb,
              height: thumb,
              decoration: BoxDecoration(
                color: Color.lerp(
                  offColor ?? colors.thumbOff,
                  colors.thumbOn,
                  on,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: style.showThumbIcons && icon != null
                  ? CamoIcon(
                      icon,
                      size: thumb * 2 / 3,
                      color: checked ? trackOn : colors.trackOff,
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
  _RadioPainter({
    required this.ring,
    required this.width,
    required this.dot,
    required this.dotRadius,
  });

  final Color ring;
  final double width;
  final Color dot;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      (size.shortestSide - width) / 2,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
    if (dotRadius > 0) {
      canvas.drawCircle(center, dotRadius, Paint()..color = dot);
    }
  }

  @override
  bool shouldRepaint(_RadioPainter old) =>
      old.ring != ring ||
      old.width != width ||
      old.dot != dot ||
      old.dotRadius != dotRadius;
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

/// A ▲ chevron drawn in [color], [size] square.
Widget _chevronUpIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _ChevronPainter(color ?? const Color(0xFF000000), up: true),
);

/// A ▼ chevron drawn in [color], [size] square.
Widget _chevronDownIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _ChevronPainter(color ?? const Color(0xFF000000), up: false),
);

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color, {required this.up});

  final Color color;
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final (edge, tip) = up ? (0.62, 0.38) : (0.38, 0.62);
    final path = Path()
      ..moveTo(s * 0.25, s * edge)
      ..lineTo(s * 0.5, s * tip)
      ..lineTo(s * 0.75, s * edge);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = s / 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color || old.up != up;
}

// Fluent's slider thumb: a neutral face and ring around a brand dot.
class _ThumbPainter extends CustomPainter {
  _ThumbPainter({required this.face, required this.ring, required this.dot});

  final Color face;
  final Color ring;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(center, r, Paint()..color = face);
    canvas.drawCircle(
      center,
      r - _hairline / 2,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = _hairline,
    );
    canvas.drawCircle(center, r * 0.6, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_ThumbPainter old) =>
      old.face != face || old.ring != ring || old.dot != dot;
}

// The brand fill's hover and pressed steps from FluentTokens; the fill itself under another theme.
Color _brandStep(Color rest, InteractionState i, FluentTokens? t) {
  if (t == null || rest != t.brandBackground) return rest;
  if (i.pressed) return t.brandBackgroundPressed;
  if (i.hovered) return t.brandBackgroundHover;
  return rest;
}
