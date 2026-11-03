import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'minimal_groups.dart' show moreIcon;

// Minimal's image, rating, pagination, breadcrumb and progress steps: hairlines, ink fills, slashes and small markers.

const double _hairline = 1;
const double _disabledContent = 0.38;
const double _hoverAlpha = 0.6;
const double _focusWidth = 2;
const double _iconSize = 24;
const double _iconShare = 0.7;

/// Minimal's image: a placeholder block with an icon, a fade to the picture.
class MinimalImageRenderer implements CamoImageRenderer {
  /// Creates the renderer.
  const MinimalImageRenderer();

  @override
  CamoImageStyle defaults(CamoTheme theme) => CamoImageStyle(
    placeholderIcon: const IconSource.builder(imageGlyph),
    errorIcon: const IconSource.builder(brokenImageGlyph),
    fade: const Duration(milliseconds: 150),
    borderWidth: 0,
    colors: ImageColors(
      placeholder: theme.colors.surfaceContainerHigh,
      icon: theme.colors.onSurfaceVariant,
      border: theme.colors.outlineVariant,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    ImageState state,
    CamoTheme theme,
    CamoImageStyle style,
    Widget child,
  ) {
    final c = style.colors;
    return ClipRRect(
      borderRadius: state.shape,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.placeholder,
          borderRadius: state.shape,
          border: style.borderWidth > 0
              ? Border.all(color: c.border, width: style.borderWidth)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            child,
            if (state.phase != ImagePhase.loaded)
              Center(
                child: CamoIcon(
                  state.phase == ImagePhase.failed
                      ? style.errorIcon
                      : style.placeholderIcon,
                  size: _iconSize,
                  color: c.icon,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Minimal's rating: 20 dp stars.
class MinimalRatingRenderer implements CamoRatingRenderer {
  /// Creates the renderer.
  const MinimalRatingRenderer();

  @override
  CamoRatingStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final filled = c.primary;
    return CamoRatingStyle(
      icon: const IconSource.builder(starGlyph),
      smallSize: 16,
      mediumSize: 20,
      largeSize: 28,
      gap: 4,
      colors: RatingColors(
        filled: filled,
        empty: c.outlineVariant,
        hover: filled.withValues(alpha: _hoverAlpha),
        disabled: disabled(c.onSurface, _disabledContent),
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    RatingState state,
    CamoTheme theme,
    CamoRatingStyle style,
  ) {
    final size = style.sizeOf(state.size);
    final shown = state.hoverValue ?? state.value;
    final filled = !state.enabled
        ? style.colors.disabled
        : state.hoverValue != null
        ? style.colors.hover
        : style.colors.filled;
    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < state.max; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: style.gap / 2),
            child: SizedBox.square(
              dimension: size,
              child: Stack(
                children: [
                  CamoIcon(style.icon, size: size, color: style.colors.empty),
                  ClipRect(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: (shown - i).clamp(0.0, 1.0),
                      child: CamoIcon(style.icon, size: size, color: filled),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    if (state.focused) {
      row = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: style.colors.filled, width: _focusWidth),
        ),
        child: row,
      );
    }
    return row;
  }
}

/// Minimal's pagination: 32 buttons, the current page a soft fill, chevron arrows.
class MinimalPaginationRenderer implements CamoPaginationRenderer {
  /// Creates the renderer.
  const MinimalPaginationRenderer();

  @override
  CamoPaginationStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoPaginationStyle(
      buttonSize: 32,
      shape: theme.shapes.medium,
      dotSize: 8,
      gap: 4,
      textStyle: theme.typography.labelLarge,
      previousIcon: const IconSource.builder(chevronLeftGlyph),
      nextIcon: const IconSource.builder(chevronRightGlyph),
      colors: PaginationColors(
        currentContainer: c.surfaceContainerHigh,
        currentContent: c.onSurface,
        content: c.onSurface,
        dot: c.outlineVariant,
        activeDot: c.primary,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    PaginationState state,
    CamoTheme theme,
    CamoPaginationStyle style,
    List<Widget> children,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: style.gap,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );

  @override
  Widget renderButton(
    BuildContext context,
    PageButtonState state,
    String label,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final content = !state.enabled
        ? disabled(c.content, _disabledContent)
        : state.current
        ? c.currentContent
        : c.content;
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: style.shape,
      theme: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: state.current ? c.currentContainer : null,
          borderRadius: style.shape,
        ),
        child: SizedBox.square(
          dimension: style.buttonSize,
          child: Center(
            child: Text(
              label,
              style: style.textStyle.copyWith(
                color: content,
                fontWeight: state.current ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget renderArrow(
    BuildContext context,
    PageArrowState state,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final previous = state.direction == PageDirection.previous;
    final content = state.enabled
        ? style.colors.content
        : disabled(style.colors.content, _disabledContent);
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: style.shape,
      theme: theme,
      child: SizedBox.square(
        dimension: style.buttonSize,
        child: Center(
          child: CamoIcon(
            previous != rtl ? style.previousIcon : style.nextIcon,
            size: _iconSize,
            color: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget renderGap(
    BuildContext context,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) => SizedBox.square(
    dimension: style.buttonSize,
    child: Center(
      child: Text(
        '…',
        style: style.textStyle.copyWith(color: style.colors.content),
      ),
    ),
  );

  @override
  Widget renderDot(
    BuildContext context,
    PageDotState state,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) {
    final color = state.active ? style.colors.activeDot : style.colors.dot;
    return SizedBox.square(
      dimension: style.buttonSize,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.enabled ? color : disabled(color, _disabledContent),
          ),
          child: SizedBox.square(dimension: style.dotSize),
        ),
      ),
    );
  }

  @override
  Widget renderSummary(
    BuildContext context,
    String text,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) => Padding(
    padding: EdgeInsets.symmetric(horizontal: style.gap),
    child: Text(
      text,
      style: style.textStyle.copyWith(color: style.colors.content),
    ),
  );
}

/// Minimal's breadcrumb: slash separators, links in the muted text color.
class MinimalBreadcrumbRenderer implements CamoBreadcrumbRenderer {
  /// Creates the renderer.
  const MinimalBreadcrumbRenderer();

  @override
  CamoBreadcrumbStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoBreadcrumbStyle(
      separator: const IconSource.builder(slashGlyph),
      itemPadding: 4,
      overflowIcon: const IconSource.builder(moreIcon),
      iconSize: 16,
      textStyle: theme.typography.bodyMedium,
      colors: BreadcrumbColors(
        link: c.onSurfaceVariant,
        current: c.onSurface,
        separator: c.outline,
        hover: c.onSurface,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    BreadcrumbState state,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
    List<Widget> children,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );

  @override
  Widget renderItem(
    BuildContext context,
    BreadcrumbItemState state,
    BreadcrumbSlots slots,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final color = state.current
        ? c.current
        : state.interaction.hovered
        ? c.hover
        : c.link;
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: color,
      shape: theme.shapes.small,
      theme: theme,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: style.itemPadding),
        child: CamoContentStyle(
          color: color,
          iconStyle: CamoIconStyle(size: style.iconSize, color: color),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: style.itemPadding,
            children: [
              ?slots.icon,
              Text(
                slots.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.textStyle.copyWith(
                  color: color,
                  fontWeight: state.current ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget renderSeparator(
    BuildContext context,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
  ) => Transform.flip(
    flipX: Directionality.of(context) == TextDirection.rtl,
    child: CamoIcon(
      style.separator,
      size: style.iconSize,
      color: style.colors.separator,
    ),
  );
}

/// Minimal's progress steps: 20 markers on a hairline connector.
class MinimalProgressStepsRenderer implements CamoProgressStepsRenderer {
  /// Creates the renderer.
  const MinimalProgressStepsRenderer();

  @override
  CamoStepsStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final accent = c.primary;
    final onAccent = c.onPrimary;
    return CamoStepsStyle(
      markerSize: 20,
      connectorWidth: 1,
      showNumbers: true,
      checkIcon: const IconSource.builder(checkGlyph),
      errorIcon: const IconSource.builder(alertGlyph),
      labelStyle: theme.typography.labelLarge,
      descriptionStyle: theme.typography.bodySmall,
      colors: StepsColors(
        complete: accent,
        onComplete: onAccent,
        current: accent,
        onCurrent: onAccent,
        upcoming: c.outlineVariant,
        error: c.error,
        connector: c.outlineVariant,
        text: c.onSurface,
        mutedText: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget renderStep(
    BuildContext context,
    StepItemState state,
    StepSlots slots,
    CamoTheme theme,
    CamoStepsStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final connector = state.status == StepStatus.complete
        ? c.complete
        : c.connector;
    final textColor = state.status == StepStatus.upcoming
        ? c.mutedText
        : c.text;
    final labels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        Text(
          slots.label,
          style: style.labelStyle.copyWith(
            color: textColor,
            fontWeight: state.status == StepStatus.current
                ? FontWeight.w600
                : null,
          ),
        ),
        if (slots.description != null)
          Text(
            slots.description!,
            style: style.descriptionStyle.copyWith(color: c.mutedText),
          ),
      ],
    );
    final marker = _Marker(state: state, style: style);
    final Widget body = state.orientation == StepsOrientation.horizontal
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Row(
                mainAxisSize: state.last ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  marker,
                  if (!state.last)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: SizedBox(
                          height: style.connectorWidth,
                          child: ColoredBox(color: connector),
                        ),
                      ),
                    ),
                ],
              ),
              labels,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  marker,
                  if (!state.last)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SizedBox(
                        width: style.connectorWidth,
                        height: 24,
                        child: ColoredBox(color: connector),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: labels,
              ),
            ],
          );
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: textColor,
      shape: theme.shapes.small,
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: body,
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.state, required this.style});

  final StepItemState state;
  final CamoStepsStyle style;

  @override
  Widget build(BuildContext context) {
    final c = style.colors;
    final (fill, content, border) = switch (state.status) {
      StepStatus.complete => (c.complete, c.onComplete, null),
      StepStatus.current => (c.current, c.onCurrent, null),
      StepStatus.error => (c.error, const Color(0xFFFFFFFF), null),
      StepStatus.upcoming => (const Color(0x00000000), c.mutedText, c.upcoming),
    };
    final Widget inner = switch (state.status) {
      StepStatus.complete => CamoIcon(
        style.checkIcon,
        size: style.markerSize * _iconShare,
        color: content,
      ),
      StepStatus.error => CamoIcon(
        style.errorIcon,
        size: style.markerSize * _iconShare,
        color: content,
      ),
      _ =>
        style.showNumbers
            ? Text(
                '${state.index + 1}',
                style: style.labelStyle.copyWith(color: content),
              )
            : const SizedBox.shrink(),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: border == null
            ? null
            : Border.all(color: border, width: _hairline),
      ),
      child: SizedBox.square(
        dimension: style.markerSize,
        child: Center(child: inner),
      ),
    );
  }
}

// --- glyphs: a 24 by 24 grid, drawn as strokes or a fill in the icon's color ---

Widget _glyph(
  double size,
  Color? color,
  void Function(Canvas canvas, Paint paint) draw, {
  bool fill = false,
  double stroke = 2,
}) => CustomPaint(
  size: Size.square(size),
  painter: _GlyphPainter(color ?? const Color(0xFF000000), draw, fill, stroke),
);

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.color, this.draw, this.fill, this.stroke);

  final Color color;
  final void Function(Canvas canvas, Paint paint) draw;
  final bool fill;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);
    draw(
      canvas,
      Paint()
        ..color = color
        ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}

Path _poly(List<List<double>> points, {bool close = false}) {
  final path = Path()..moveTo(points.first[0], points.first[1]);
  for (final p in points.skip(1)) {
    path.lineTo(p[0], p[1]);
  }
  if (close) path.close();
  return path;
}

/// An image placeholder: a frame with a hill.
Widget imageGlyph(double size, Color? color) =>
    _glyph(size, color, (canvas, paint) {
      canvas.drawPath(
        _poly([
          [4, 5],
          [20, 5],
          [20, 19],
          [4, 19],
        ], close: true),
        paint,
      );
      canvas.drawPath(
        _poly([
          [4, 16],
          [9, 11],
          [14, 16],
          [16, 14],
          [20, 18],
        ]),
        paint,
      );
    });

/// A failed image: the frame with a slash.
Widget brokenImageGlyph(double size, Color? color) =>
    _glyph(size, color, (canvas, paint) {
      canvas.drawPath(
        _poly([
          [4, 5],
          [20, 5],
          [20, 19],
          [4, 19],
        ], close: true),
        paint,
      );
      canvas.drawPath(
        _poly([
          [4, 4],
          [20, 20],
        ]),
        paint,
      );
    });

/// A filled star.
Widget starGlyph(double size, Color? color) => _glyph(
  size,
  color,
  (canvas, paint) => canvas.drawPath(
    _poly([
      [12, 2],
      [15.09, 8.26],
      [22, 9.27],
      [17, 14.14],
      [18.18, 21.02],
      [12, 17.77],
      [5.82, 21.02],
      [7, 14.14],
      [2, 9.27],
      [8.91, 8.26],
    ], close: true),
    paint,
  ),
  fill: true,
);

/// A chevron pointing left.
Widget chevronLeftGlyph(double size, Color? color) => _glyph(
  size,
  color,
  (canvas, paint) => canvas.drawPath(
    _poly([
      [15, 6],
      [9, 12],
      [15, 18],
    ]),
    paint,
  ),
);

/// A chevron pointing right.
Widget chevronRightGlyph(double size, Color? color) => _glyph(
  size,
  color,
  (canvas, paint) => canvas.drawPath(
    _poly([
      [9, 6],
      [15, 12],
      [9, 18],
    ]),
    paint,
  ),
);

/// A slash.
Widget slashGlyph(double size, Color? color) => _glyph(
  size,
  color,
  (canvas, paint) => canvas.drawPath(
    _poly([
      [16, 5],
      [8, 19],
    ]),
    paint,
  ),
);

/// A check mark.
Widget checkGlyph(double size, Color? color) => _glyph(
  size,
  color,
  (canvas, paint) => canvas.drawPath(
    _poly([
      [5, 12.5],
      [10, 17.5],
      [19, 7],
    ]),
    paint,
  ),
  stroke: 2.5,
);

/// An exclamation mark.
Widget alertGlyph(double size, Color? color) =>
    _glyph(size, color, (canvas, paint) {
      canvas.drawPath(
        _poly([
          [12, 5],
          [12, 14],
        ]),
        paint,
      );
      canvas.drawPath(
        _poly([
          [12, 19],
          [12, 19.01],
        ]),
        paint,
      );
    }, stroke: 2.5);

/// An arrow pointing up.
Widget arrowUpGlyph(double size, Color? color) =>
    _glyph(size, color, (canvas, paint) {
      canvas.drawPath(
        _poly([
          [12, 19],
          [12, 5],
        ]),
        paint,
      );
      canvas.drawPath(
        _poly([
          [6, 11],
          [12, 5],
          [18, 11],
        ]),
        paint,
      );
    }, stroke: 2.5);
