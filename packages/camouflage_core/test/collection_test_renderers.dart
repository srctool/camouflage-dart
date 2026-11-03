import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M10 carousel and file uploader in the plain test skin: boxes, rows and text.

/// The last state each plain renderer drew, for tests.
CarouselState? lastCarousel;
UploaderZoneState? lastZone;

/// The state of each plain carousel button (by direction) and file row (by name) last drawn, for tests.
final carouselButtons = <String, CarouselButtonState>{};
final uploadRows = <String, UploadRowState>{};

Widget _collectionIcon(double size, Color? color) =>
    SizedBox.square(dimension: size);

class PlainCarousel implements CamoCarouselRenderer {
  const PlainCarousel();

  @override
  CamoCarouselStyle defaults(CamoTheme theme) => const CamoCarouselStyle(
    itemShape: BorderRadius.zero,
    itemSpacing: 8,
    peek: 16,
    buttonSize: 32,
    previousIcon: IconSource.builder(_collectionIcon),
    nextIcon: IconSource.builder(_collectionIcon),
    colors: CarouselColors(
      buttonContainer: Color(0xFFFFFFFF),
      buttonContent: Color(0xFF000000),
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    CarouselState state,
    CamoTheme theme,
    CamoCarouselStyle style,
    Widget child,
  ) {
    lastCarousel = state;
    return child;
  }

  @override
  Widget renderItem(
    BuildContext context,
    CamoTheme theme,
    CamoCarouselStyle style,
    Widget child,
  ) => ColoredBox(color: const Color(0xFFCCCCCC), child: child);

  @override
  Widget renderButton(
    BuildContext context,
    CarouselButtonState state,
    CamoTheme theme,
    CamoCarouselStyle style,
  ) {
    carouselButtons[state.direction.name] = state;
    return SizedBox.square(dimension: 32, child: Text(state.direction.name));
  }
}

class PlainFileUploader implements CamoFileUploaderRenderer {
  const PlainFileUploader();

  @override
  CamoUploaderStyle defaults(CamoTheme theme) => CamoUploaderStyle(
    zoneShape: BorderRadius.zero,
    dashed: false,
    zoneHeight: 80,
    icon: const IconSource.builder(_collectionIcon),
    removeIcon: const IconSource.builder(_collectionIcon),
    retryIcon: const IconSource.builder(_collectionIcon),
    titleStyle: theme.typography.labelLarge,
    hintStyle: theme.typography.bodySmall,
    colors: const UploaderColors(
      zone: Color(0xFFFFFFFF),
      border: Color(0xFF888888),
      dragBorder: Color(0xFF0000FF),
      error: Color(0xFFFF0000),
      text: Color(0xFF000000),
      mutedText: Color(0xFF444444),
    ),
  );

  @override
  Widget renderZone(
    BuildContext context,
    UploaderZoneState state,
    UploaderZoneSlots slots,
    CamoTheme theme,
    CamoUploaderStyle style,
  ) {
    lastZone = state;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(slots.title),
          if (slots.hint != null) Text(slots.hint!),
        ],
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
    uploadRows[slots.name] = state;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(slots.name), Text(slots.detail)],
          ),
        ),
        ?slots.retry,
        slots.remove,
      ],
    );
  }
}
