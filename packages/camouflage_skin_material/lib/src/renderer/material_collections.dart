import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'material_indicators.dart'
    show
        chevronLeftGlyph,
        chevronRightGlyph,
        closeGlyph,
        retryGlyph,
        uploadGlyph;

// Material's carousel and file uploader: a hairline dashed zone, floating round buttons.

const double _disabledContent = 0.38;
const double _buttonAlpha = 0.92;
const double _dragFill = 0.08;
const double _zoneIcon = 28;
const double _buttonIcon = 24;

/// Material's carousel: masked items, floating round buttons.
class MaterialCarouselRenderer implements CamoCarouselRenderer {
  /// Creates the renderer.
  const MaterialCarouselRenderer();

  @override
  CamoCarouselStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoCarouselStyle(
      itemShape: theme.shapes.extraLarge,
      itemSpacing: 8,
      peek: 32,
      buttonSize: 40,
      previousIcon: const IconSource.builder(chevronLeftGlyph),
      nextIcon: const IconSource.builder(chevronRightGlyph),
      colors: CarouselColors(
        buttonContainer: c.surface.withValues(alpha: _buttonAlpha),
        buttonContent: c.onSurface,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    CarouselState state,
    CamoTheme theme,
    CamoCarouselStyle style,
    Widget child,
  ) => child;

  @override
  Widget renderItem(
    BuildContext context,
    CamoTheme theme,
    CamoCarouselStyle style,
    Widget child,
  ) => ClipRRect(
    borderRadius: style.itemShape,
    child: ColoredBox(color: theme.colors.surfaceContainerHigh, child: child),
  );

  @override
  Widget renderButton(
    BuildContext context,
    CarouselButtonState state,
    CamoTheme theme,
    CamoCarouselStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final content = state.enabled
        ? c.buttonContent
        : disabled(c.buttonContent, _disabledContent);
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: BorderRadius.circular(style.buttonSize),
      theme: theme,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.buttonContainer,
        ),
        child: SizedBox.square(
          dimension: style.buttonSize,
          child: Center(
            child: CamoIcon(
              state.direction == CarouselDirection.previous
                  ? style.previousIcon
                  : style.nextIcon,
              size: _buttonIcon,
              color: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Material's file uploader: a dashed drop zone and plain file rows.
class MaterialFileUploaderRenderer implements CamoFileUploaderRenderer {
  /// Creates the renderer.
  const MaterialFileUploaderRenderer();

  @override
  CamoUploaderStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoUploaderStyle(
      zoneShape: theme.shapes.medium,
      dashed: true,
      zoneHeight: 120,
      icon: const IconSource.builder(uploadGlyph),
      removeIcon: const IconSource.builder(closeGlyph),
      retryIcon: const IconSource.builder(retryGlyph),
      titleStyle: theme.typography.labelLarge,
      hintStyle: theme.typography.bodySmall,
      colors: UploaderColors(
        zone: c.surfaceContainerLow,
        border: c.outline,
        dragBorder: c.primary,
        error: c.error,
        text: c.onSurface,
        mutedText: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget renderZone(
    BuildContext context,
    UploaderZoneState state,
    UploaderZoneSlots slots,
    CamoTheme theme,
    CamoUploaderStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final c = style.colors;
    final content = state.enabled ? c.text : disabled(c.text, _disabledContent);
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: style.zoneShape,
      theme: theme,
      child: CustomPaint(
        foregroundPainter: _ZoneBorder(
          color: state.dragOver ? c.dragBorder : c.border,
          width: state.dragOver ? 2 : 1,
          radius: style.zoneShape.topLeft.x,
          dashed: style.dashed,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: style.zoneHeight),
          child: ClipRRect(
            borderRadius: style.zoneShape,
            child: ColoredBox(
              color: state.dragOver
                  ? c.dragBorder.withValues(alpha: _dragFill)
                  : c.zone,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    CamoIcon(style.icon, size: _zoneIcon, color: c.mutedText),
                    Text(
                      slots.title,
                      textAlign: TextAlign.center,
                      style: style.titleStyle.copyWith(color: content),
                    ),
                    if (slots.hint != null)
                      Text(
                        slots.hint!,
                        textAlign: TextAlign.center,
                        style: style.hintStyle.copyWith(color: c.mutedText),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget renderRow(
    BuildContext context,
    UploadRowState state,
    UploadRowSlots slots,
    CamoTheme theme,
    CamoUploaderStyle style,
  ) {
    final c = style.colors;
    final failed = state.status is UploadFailed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  slots.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.titleStyle.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  slots.detail,
                  style: style.hintStyle.copyWith(
                    color: failed ? c.error : c.mutedText,
                  ),
                ),
                if (state.status is UploadUploading)
                  CamoProgressBar(
                    value: state.progress,
                    semanticLabel: 'Uploading ${slots.name}',
                  ),
                if (failed) const CamoProgressBar(value: 1, tone: Tone.error),
              ],
            ),
          ),
          ?slots.retry,
          slots.remove,
        ],
      ),
    );
  }
}

// A rounded rectangle outline, dashed when asked.
class _ZoneBorder extends CustomPainter {
  const _ZoneBorder({
    required this.color,
    required this.width,
    required this.radius,
    required this.dashed,
  });

  final Color color;
  final double width;
  final double radius;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    if (!dashed) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        canvas.drawPath(metric.extractPath(at, at + 6), paint);
        at += 12;
      }
    }
  }

  @override
  bool shouldRepaint(_ZoneBorder old) =>
      old.color != color || old.width != width || old.dashed != dashed;
}
