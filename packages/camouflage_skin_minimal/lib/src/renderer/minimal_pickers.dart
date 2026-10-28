import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// Minimal's overlays and pickers (base Minimal Skin §3.3): flat surfaces with a hairline, ink for the selection.

const double _disabled = 0.38;
const double _scrim = 0.4;
const double _outerLabels = 0.8;
const double _innerLabels = 0.45;

/// Minimal's popup panel: radius 8, `surface` with a hairline, no shadow.
class MinimalMenuRenderer implements CamoMenuRenderer {
  /// Creates the renderer.
  const MinimalMenuRenderer();

  @override
  CamoMenuStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoMenuStyle(
      shape: theme.shapes.medium,
      minWidth: 112,
      maxWidth: 280,
      itemHeight: 40,
      contentPadding: EdgeInsetsDirectional.symmetric(
        vertical: theme.spacing.xs,
      ),
      textStyle: theme.typography.bodyMedium,
      iconSize: 18,
      elevation: theme.elevation.level0,
      checkPosition: CheckPosition.trailing,
      colors: MenuColors(
        container: c.surface,
        text: c.onSurface,
        icon: c.onSurfaceVariant,
        trailingText: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget panel(
    BuildContext context,
    Widget child,
    CamoTheme theme,
    CamoMenuStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    return skin.surfaceTreatment.decorate(
      color: style.colors.container,
      shape: style.shape,
      elevation: style.elevation,
      theme: theme,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: style.shape,
          border: Border.all(color: theme.colors.outlineVariant),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: style.minWidth),
          child: Padding(
            padding: style.contentPadding,
            child: CamoContentStyle(
              color: style.colors.text,
              iconStyle: CamoIconStyle(
                size: style.iconSize,
                color: style.colors.icon,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal's bottom sheet: top radius 16, `surface` with a hairline, a 36 × 4 handle in `outlineVariant`.
class MinimalBottomSheetRenderer implements CamoBottomSheetRenderer {
  /// Creates the renderer.
  const MinimalBottomSheetRenderer();

  @override
  CamoBottomSheetStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoBottomSheetStyle(
      shape: const BorderRadius.vertical(top: Radius.circular(16)),
      maxWidth: 640,
      contentPadding: EdgeInsetsDirectional.only(
        start: theme.spacing.l,
        end: theme.spacing.l,
        bottom: theme.spacing.xl,
      ),
      showHandle: true,
      handleSize: const Size(36, 4),
      handleColor: c.outlineVariant,
      titleStyle: theme.typography.titleLarge,
      titleAlign: CamoTitleAlign.start,
      showCloseButton: false,
      closeIcon: const IconSource.builder(_closeIcon),
      containerColor: c.surface,
      scrimAlpha: _scrim,
      widePresentation: WidePresentation.sheet,
      stackedScrim: StackedScrim.each,
    );
  }

  @override
  Widget render(
    BuildContext context,
    BottomSheetState state,
    BottomSheetSlots slots,
    CamoTheme theme,
    CamoBottomSheetStyle style,
  ) {
    final shape = state.centered ? theme.shapes.large : style.shape;
    return Camouflage.skinOf(context).surfaceTreatment.decorate(
      color: style.containerColor,
      shape: shape,
      elevation: 0,
      theme: theme,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(color: theme.colors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._sheetHeader(state, style, theme),
            Flexible(
              child: Padding(
                padding: style.contentPadding,
                child: slots.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Handle, title and close button, in the combinations the sheet theme allows.
List<Widget> _sheetHeader(
  BottomSheetState state,
  CamoBottomSheetStyle style,
  CamoTheme theme,
) {
  final close = style.showCloseButton && state.dismissible;
  return [
    if (style.showHandle && !state.centered)
      Padding(
        padding: EdgeInsets.symmetric(vertical: theme.spacing.m),
        child: Center(
          child: Container(
            width: style.handleSize.width,
            height: style.handleSize.height,
            decoration: BoxDecoration(
              color: style.handleColor,
              borderRadius: theme.shapes.full,
            ),
          ),
        ),
      ),
    if (state.title != null || close)
      Padding(
        padding: EdgeInsetsDirectional.only(
          start: theme.spacing.l,
          end: theme.spacing.s,
          top: theme.spacing.s,
        ),
        child: Row(
          children: [
            Expanded(
              child: state.title == null
                  ? const SizedBox.shrink()
                  : CamoText(
                      state.title!,
                      style: style.titleStyle,
                      color: theme.colors.onSurface,
                      textAlign: style.titleAlign == CamoTitleAlign.center
                          ? TextAlign.center
                          : TextAlign.start,
                    ),
            ),
            if (close)
              CamoIconButton(
                icon: CamoIcon(style.closeIcon),
                semanticLabel: 'Close',
                onPressed: state.onDismissRequest,
              ),
          ],
        ),
      ),
  ];
}

/// Minimal's calendar: day cells 36, an ink circle for the selected day, a 1 px `outline` ring for today and a
/// `surfaceContainerHigh` range band.
class MinimalDatePickerRenderer implements CamoDatePickerRenderer {
  /// Creates the renderer.
  const MinimalDatePickerRenderer();

  @override
  CamoDatePickerStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoDatePickerStyle(
      form: DatePickerForm.calendar,
      firstDayOfWeek: null,
      displayFormat: null,
      confirmButton: true,
      allowTyping: AllowTyping.auto,
      showOutsideDays: false,
      daySize: 36,
      autoPopupMinWidth: 600,
      contentPadding: EdgeInsetsDirectional.all(theme.spacing.m),
      headerStyle: t.titleSmall,
      weekdayStyle: t.labelSmall,
      dayStyle: t.bodyMedium,
      wheelTextStyle: t.bodyLarge,
      wheelItemHeight: 40,
      calendarIcon: const IconSource.builder(_calendarIcon),
      previousIcon: const IconSource.builder(_chevronStart),
      nextIcon: const IconSource.builder(_chevronEnd),
      colors: DatePickerColors(
        selected: c.primary,
        onSelected: c.onPrimary,
        range: c.surfaceContainerHigh,
        onRange: c.onSurface,
        today: c.outline,
        day: c.onSurface,
        weekday: c.onSurfaceVariant,
        disabled: c.onSurface.withValues(alpha: _disabled),
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
  ) => _calendarLayout(state, slots, style);

  @override
  Widget cell(
    BuildContext context,
    CalendarCell cell,
    CamoTheme theme,
    CamoDatePickerStyle style,
  ) => _cell(
    context,
    cell,
    theme,
    style,
    const BorderRadius.all(Radius.circular(999)),
  );

  @override
  Widget wheels(
    BuildContext context,
    List<Widget> wheels,
    CamoTheme theme,
    CamoDatePickerStyle style,
  ) => _wheelBand(
    wheels,
    style.wheelItemHeight,
    theme.colors.surfaceContainerHigh,
    theme,
  );
}

/// The calendar's layout: the header row, then the weekday row and six weeks, or the year list.
Widget _calendarLayout(
  CalendarState state,
  CalendarSlots slots,
  CamoDatePickerStyle style,
) => SizedBox(
  width: style.daySize * 7,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: slots.header,
            ),
          ),
          slots.previous,
          slots.next,
        ],
      ),
      if (state.choosingYear)
        SizedBox(height: style.daySize * 7, child: slots.years)
      else ...[
        Row(
          children: [
            for (final label in state.weekdayLabels)
              SizedBox.square(
                dimension: style.daySize,
                child: Center(
                  child: CamoText(
                    label,
                    style: style.weekdayStyle,
                    color: style.colors.weekday,
                  ),
                ),
              ),
          ],
        ),
        for (var week = 0; week < 6; week++)
          Row(
            children: [
              for (final day in state.days.skip(week * 7).take(7))
                slots.day(day),
            ],
          ),
      ],
    ],
  ),
);

// A cell's label color: on the selection, dimmed when disabled, on the band, quieter for another month.
Color _cellText(CalendarCell cell, DatePickerColors c) {
  if (cell.selected) return c.onSelected;
  if (!cell.enabled) return c.disabled;
  if (cell.rangePosition == RangePosition.middle) return c.onRange;
  if (!cell.inMonth) return c.weekday;
  return c.day;
}

// A calendar cell: the range band behind (half of it on the range's ends), the selected fill or today's ring in
// [shape], and the label; blank for another month's day unless showOutsideDays.
Widget _cell(
  BuildContext context,
  CalendarCell cell,
  CamoTheme theme,
  CamoDatePickerStyle style,
  BorderRadius shape,
) {
  final c = style.colors;
  final year = cell.kind == CalendarCellKind.year;
  if (!cell.inMonth && !style.showOutsideDays) {
    return SizedBox.square(dimension: style.daySize);
  }
  final text = _cellText(cell, c);
  final markShape = year ? theme.shapes.full : shape;
  final mark = Camouflage.skinOf(context).feedback.wrap(
    controller: cell.controller,
    contentColor: text,
    shape: markShape,
    theme: theme,
    child: Container(
      width: year ? null : style.daySize,
      height: style.daySize,
      margin: year ? const EdgeInsets.symmetric(horizontal: 4) : null,
      decoration: BoxDecoration(
        color: cell.selected ? c.selected : null,
        borderRadius: markShape,
        border: cell.isToday && !cell.selected
            ? Border.all(color: c.today)
            : null,
      ),
      alignment: Alignment.center,
      child: CamoText(cell.label, style: style.dayStyle, color: text),
    ),
  );
  return cell.wrap(
    SizedBox(
      width: year ? null : style.daySize,
      height: style.daySize,
      child: CustomPaint(
        painter: _RangeBand(
          cell.rangePosition,
          c.range,
          Directionality.of(context),
        ),
        child: mark,
      ),
    ),
  );
}

// The range band behind a day: all of a middle day, the inner half of the range's ends (mirrored right to left).
class _RangeBand extends CustomPainter {
  _RangeBand(this.position, this.color, this.direction);

  final RangePosition position;
  final Color color;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    if (position == RangePosition.none || position == RangePosition.single) {
      return;
    }
    final rtl = direction == TextDirection.rtl;
    final half = size.width / 2;
    final (left, width) = switch (position) {
      RangePosition.middle => (0.0, size.width),
      RangePosition.start => (rtl ? 0.0 : half, half),
      _ => (rtl ? half : 0.0, half),
    };
    canvas.drawRect(
      Rect.fromLTWH(left, 0, width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RangeBand old) =>
      old.position != position ||
      old.color != color ||
      old.direction != direction;
}

// Wheels side by side over a [band] behind the middle row.
Widget _wheelBand(
  List<Widget> wheels,
  double itemHeight,
  Color band,
  CamoTheme theme,
) => SizedBox(
  height: itemHeight * 5,
  child: Stack(
    alignment: Alignment.center,
    children: [
      Container(
        height: itemHeight,
        decoration: BoxDecoration(
          color: band,
          borderRadius: theme.shapes.medium,
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing.s,
        children: [for (final w in wheels) SizedBox(width: 72, child: w)],
      ),
    ],
  ),
);

/// Minimal's time picker: two 56 × 56 boxes (`surfaceContainerHigh`, radius 8) with `displaySmall` digits, the
/// active one ringed in ink, and a segmented AM/PM.
class MinimalTimePickerRenderer implements CamoTimePickerRenderer {
  /// Creates the renderer.
  const MinimalTimePickerRenderer();

  @override
  CamoTimePickerStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoTimePickerStyle(
      form: TimePickerForm.fields,
      confirmButton: true,
      digitStyle: t.displaySmall,
      dialTextStyle: t.bodyMedium,
      wheelTextStyle: t.bodyLarge,
      wheelItemHeight: 40,
      fieldSize: 56,
      dialSize: 240,
      autoPopupMinWidth: 600,
      contentPadding: EdgeInsetsDirectional.all(theme.spacing.l),
      clockIcon: const IconSource.builder(_clockIcon),
      colors: TimePickerColors(
        active: c.primary,
        activeContainer: c.surfaceContainerHigh,
        face: c.surfaceContainerHigh,
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
    if (wheels != null) return this.wheels(context, wheels, theme, style);
    final c = style.colors;
    Widget part(TimePart which, Widget field) {
      final active = state.activePart == which;
      return Opacity(
        opacity: state.enabled ? 1 : _disabled,
        child: Container(
          width: style.fieldSize,
          height: style.fieldSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? c.activeContainer : c.face,
            borderRadius: theme.shapes.medium,
            border: active ? Border.all(color: c.active, width: 2) : null,
          ),
          child: field,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing.l,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing.s,
          children: [
            part(TimePart.hour, slots.hour),
            CamoText(':', style: style.digitStyle, color: c.digits),
            part(TimePart.minute, slots.minute),
            if (slots.period != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: theme.spacing.s),
                child: slots.period,
              ),
          ],
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
  ) => CustomPaint(
    size: Size.square(style.dialSize),
    painter: _DialPainter(
      state,
      style,
      theme.colors.onPrimary,
      Directionality.of(context),
    ),
  );

  @override
  Widget wheels(
    BuildContext context,
    List<Widget> wheels,
    CamoTheme theme,
    CamoTimePickerStyle style,
  ) => _wheelBand(
    wheels,
    style.wheelItemHeight,
    theme.colors.surfaceContainerHigh,
    theme,
  );
}

/// A clock face: the face circle, the hand with a dot under the selected label, and the labels on their rings.
class _DialPainter extends CustomPainter {
  /// Paints [state] in [style]'s colors, the selected label in [onActive].
  _DialPainter(this.state, this.style, this.onActive, this.direction);

  /// The dial.
  final DialState state;

  /// Its style.
  final CamoTimePickerStyle style;

  /// The selected label's color, on the hand's dot.
  final Color onActive;

  /// For the labels' text.
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final c = style.colors;
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, radius, Paint()..color = c.face);
    Offset at(double degrees, double r) {
      final a = degrees * math.pi / 180;
      return center + Offset(r * math.sin(a), -r * math.cos(a));
    }

    final tip = at(
      state.handAngle,
      radius * (state.selectedInner ? _innerLabels : _outerLabels),
    );
    final hand = Paint()
      ..color = c.active
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(center, tip, hand)
      ..drawCircle(center, 3, hand)
      ..drawCircle(tip, 18, hand);
    void ring(List<String> labels, double r, {required bool inner}) {
      for (var i = 0; i < labels.length; i++) {
        final selected =
            i == state.selectedIndex && inner == state.selectedInner;
        final painter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: style.dialTextStyle.copyWith(
              color: selected ? onActive : c.digits,
            ),
          ),
          textDirection: direction,
        )..layout();
        painter.paint(
          canvas,
          at(i * 30, r) - Offset(painter.width / 2, painter.height / 2),
        );
      }
    }

    ring(state.labels, radius * _outerLabels, inner: false);
    final inner = state.innerLabels;
    if (inner != null) ring(inner, radius * _innerLabels, inner: true);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.state != state ||
      old.style != style ||
      old.onActive != onActive ||
      old.direction != direction;
}

Widget _glyph(double size, Color? color, void Function(Path p) draw) =>
    CustomPaint(
      size: Size.square(size),
      painter: _StrokePainter(color ?? const Color(0xFF000000), draw),
    );

Widget _calendarIcon(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..addRect(const Rect.fromLTRB(5, 6, 19, 20))
    ..moveTo(5, 10)
    ..lineTo(19, 10)
    ..moveTo(9, 3.5)
    ..lineTo(9, 7)
    ..moveTo(15, 3.5)
    ..lineTo(15, 7);
});

Widget _clockIcon(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8))
    ..moveTo(12, 7.5)
    ..lineTo(12, 12)
    ..lineTo(15, 14);
});

Widget _chevronStart(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(15, 5)
    ..lineTo(8, 12)
    ..lineTo(15, 19);
});

Widget _chevronEnd(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(9, 5)
    ..lineTo(16, 12)
    ..lineTo(9, 19);
});

Widget _closeIcon(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(6, 6)
    ..lineTo(18, 18)
    ..moveTo(18, 6)
    ..lineTo(6, 18);
});

// A 24-unit glyph stroked in [color] at 2 units.
class _StrokePainter extends CustomPainter {
  _StrokePainter(this.color, this.draw);

  final Color color;
  final void Function(Path p) draw;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path();
    draw(path);
    canvas
      ..scale(s)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.color != color;
}

/// Minimal's dialog: radius 12, `surface` with a hairline, no shadow, actions at the end.
class MinimalDialogRenderer implements CamoDialogRenderer {
  /// Creates the renderer.
  const MinimalDialogRenderer();

  @override
  CamoDialogStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoDialogStyle(
      shape: theme.shapes.large,
      minWidth: 280,
      maxWidth: 560,
      padding: EdgeInsetsDirectional.all(theme.spacing.xl),
      titleStyle: theme.typography.titleLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
      messageStyle: theme.typography.bodyMedium,
      titleAlign: CamoTitleAlign.start,
      actionsLayout: DialogActionsLayout.end,
      actionGap: theme.spacing.s,
      sectionGap: theme.spacing.l,
      showCloseButton: false,
      closeIcon: const IconSource.builder(_closeIcon),
      elevation: ElevationLevel.level0,
      scrimAlpha: _scrim,
      stackedScrim: StackedScrim.each,
      colors: DialogColors(
        container: c.surface,
        title: c.onSurface,
        message: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    DialogState state,
    DialogSlots slots,
    CamoTheme theme,
    CamoDialogStyle style,
  ) => _paintDialog(
    context,
    state,
    slots,
    theme,
    style,
    theme.colors.outlineVariant,
  );
}

// A dialog: the container (with a hairline in [border] when set), the title row with the optional close button,
// the message and content scrolling between them, and the actions laid out by `actionsLayout`.
Widget _paintDialog(
  BuildContext context,
  DialogState state,
  DialogSlots slots,
  CamoTheme theme,
  CamoDialogStyle style,
  Color? border,
) {
  final skin = Camouflage.skinOf(context);
  final center = style.titleAlign == CamoTitleAlign.center;
  final align = center ? TextAlign.center : TextAlign.start;
  final close = style.showCloseButton && state.dismissible;
  Widget dialog = Padding(
    padding: style.padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: style.sectionGap,
      children: [
        if (state.title != null || close)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: state.title == null
                    ? const SizedBox.shrink()
                    : Text(
                        state.title!,
                        textAlign: align,
                        style: style.titleStyle.copyWith(
                          color: style.colors.title,
                        ),
                      ),
              ),
              if (close)
                CamoIconButton(
                  icon: CamoIcon(style.closeIcon),
                  semanticLabel: 'Close',
                  onPressed: state.onDismissRequest,
                ),
            ],
          ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: style.sectionGap,
              children: [
                Text(
                  state.message,
                  textAlign: align,
                  style: style.messageStyle.copyWith(
                    color: style.colors.message,
                  ),
                ),
                ?slots.content,
              ],
            ),
          ),
        ),
        _dialogActions(slots, style.actionsLayout, style.actionGap),
      ],
    ),
  );
  if (border != null) {
    dialog = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: style.shape,
        border: Border.all(color: border),
      ),
      child: dialog,
    );
  }
  return skin.surfaceTreatment.decorate(
    color: style.colors.container,
    shape: style.shape,
    elevation: theme.elevation.of(style.elevation),
    theme: theme,
    child: ClipRRect(borderRadius: style.shape, child: dialog),
  );
}

// `confirm` and `dismiss` arranged by [layout]: `dismiss` first in a row (confirm at the end), confirm on top
// when stacked.
Widget _dialogActions(
  DialogSlots slots,
  DialogActionsLayout layout,
  double gap,
) {
  final dismiss = slots.dismiss;
  return switch (layout) {
    DialogActionsLayout.end || DialogActionsLayout.center => Wrap(
      alignment: layout == DialogActionsLayout.end
          ? WrapAlignment.end
          : WrapAlignment.center,
      spacing: gap,
      runSpacing: gap,
      children: [?dismiss, slots.confirm],
    ),
    DialogActionsLayout.fullWidthRow => Row(
      spacing: gap,
      children: [
        if (dismiss != null) Expanded(child: dismiss),
        Expanded(child: slots.confirm),
      ],
    ),
    DialogActionsLayout.stacked => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [slots.confirm, ?dismiss],
    ),
  };
}
