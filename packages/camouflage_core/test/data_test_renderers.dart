import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M10 image, rating, pagination, breadcrumb and progress steps in the plain test skin: boxes, rows and text.

/// The last state each plain renderer drew, for tests.
ImageState? lastImage;
RatingState? lastRating;
PaginationState? lastPagination;
BreadcrumbState? lastBreadcrumb;

/// The state each plain page button and step last drew, by index, for tests.
final pageButtons = <int, PageButtonState>{};
final steps = <int, StepItemState>{};

Widget _dataIcon(double size, Color? color) => SizedBox.square(dimension: size);

class PlainImage implements CamoImageRenderer {
  const PlainImage();

  @override
  CamoImageStyle defaults(CamoTheme theme) => const CamoImageStyle(
    placeholderIcon: IconSource.builder(_dataIcon),
    errorIcon: IconSource.builder(_dataIcon),
    fade: Duration.zero,
    borderWidth: 0,
    colors: ImageColors(
      placeholder: Color(0xFFCCCCCC),
      icon: Color(0xFF888888),
      border: Color(0xFF888888),
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
    lastImage = state;
    return ColoredBox(
      color: style.colors.placeholder,
      child: Stack(children: [child, Text(state.phase.name)]),
    );
  }
}

class PlainRating implements CamoRatingRenderer {
  const PlainRating();

  @override
  CamoRatingStyle defaults(CamoTheme theme) => const CamoRatingStyle(
    icon: IconSource.builder(_dataIcon),
    smallSize: 16,
    mediumSize: 20,
    largeSize: 28,
    gap: 4,
    colors: RatingColors(
      filled: Color(0xFF000000),
      empty: Color(0xFF888888),
      hover: Color(0xFF444444),
      disabled: Color(0xFFCCCCCC),
    ),
  );

  @override
  Widget render(
    BuildContext context,
    RatingState state,
    CamoTheme theme,
    CamoRatingStyle style,
  ) {
    lastRating = state;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < state.max; i++)
            const SizedBox.square(dimension: 24),
        ],
      ),
    );
  }
}

class PlainPagination implements CamoPaginationRenderer {
  const PlainPagination();

  @override
  CamoPaginationStyle defaults(CamoTheme theme) => CamoPaginationStyle(
    buttonSize: 32,
    shape: BorderRadius.zero,
    dotSize: 8,
    gap: 4,
    textStyle: theme.typography.labelLarge,
    previousIcon: const IconSource.builder(_dataIcon),
    nextIcon: const IconSource.builder(_dataIcon),
    colors: const PaginationColors(
      currentContainer: Color(0xFFCCCCCC),
      currentContent: Color(0xFF000000),
      content: Color(0xFF000000),
      dot: Color(0xFF888888),
      activeDot: Color(0xFF000000),
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    PaginationState state,
    CamoTheme theme,
    CamoPaginationStyle style,
    List<Widget> children,
  ) {
    lastPagination = state;
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  @override
  Widget renderButton(
    BuildContext context,
    PageButtonState state,
    String label,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) {
    pageButtons[state.index] = state;
    return SizedBox.square(dimension: 32, child: Text(label));
  }

  @override
  Widget renderArrow(
    BuildContext context,
    PageArrowState state,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) => SizedBox.square(dimension: 32, child: Text(state.direction.name));

  @override
  Widget renderGap(
    BuildContext context,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) => const Text('…');

  @override
  Widget renderDot(
    BuildContext context,
    PageDotState state,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) => const SizedBox.square(dimension: 16);

  @override
  Widget renderSummary(
    BuildContext context,
    String text,
    CamoTheme theme,
    CamoPaginationStyle style,
  ) => Text(text);
}

class PlainBreadcrumb implements CamoBreadcrumbRenderer {
  const PlainBreadcrumb();

  @override
  CamoBreadcrumbStyle defaults(CamoTheme theme) => CamoBreadcrumbStyle(
    separator: const IconSource.builder(_dataIcon),
    itemPadding: 4,
    overflowIcon: const IconSource.builder(_dataIcon),
    iconSize: 16,
    textStyle: theme.typography.bodyMedium,
    colors: const BreadcrumbColors(
      link: Color(0xFF0000FF),
      current: Color(0xFF000000),
      separator: Color(0xFF888888),
      hover: Color(0xFF000000),
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    BreadcrumbState state,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
    List<Widget> children,
  ) {
    lastBreadcrumb = state;
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  @override
  Widget renderItem(
    BuildContext context,
    BreadcrumbItemState state,
    BreadcrumbSlots slots,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
  ) => Padding(
    padding: const EdgeInsets.all(4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [?slots.icon, Text(slots.label)],
    ),
  );

  @override
  Widget renderSeparator(
    BuildContext context,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
  ) => const Text('/');
}

class PlainProgressSteps implements CamoProgressStepsRenderer {
  const PlainProgressSteps();

  @override
  CamoStepsStyle defaults(CamoTheme theme) => CamoStepsStyle(
    markerSize: 20,
    connectorWidth: 2,
    showNumbers: true,
    checkIcon: const IconSource.builder(_dataIcon),
    errorIcon: const IconSource.builder(_dataIcon),
    labelStyle: theme.typography.labelLarge,
    descriptionStyle: theme.typography.bodySmall,
    colors: const StepsColors(
      complete: Color(0xFF00AA00),
      onComplete: Color(0xFFFFFFFF),
      current: Color(0xFF0000FF),
      onCurrent: Color(0xFFFFFFFF),
      upcoming: Color(0xFF888888),
      error: Color(0xFFFF0000),
      connector: Color(0xFF888888),
      text: Color(0xFF000000),
      mutedText: Color(0xFF444444),
    ),
  );

  @override
  Widget renderStep(
    BuildContext context,
    StepItemState state,
    StepSlots slots,
    CamoTheme theme,
    CamoStepsStyle style,
  ) {
    steps[state.index] = state;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(slots.label),
          if (slots.description != null) Text(slots.description!),
        ],
      ),
    );
  }
}
