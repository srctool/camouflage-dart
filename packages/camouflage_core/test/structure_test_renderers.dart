import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M6 structure components in the plain test skin: boxes, rows and text markers, no decoration.

class PlainCard implements CamoCardRenderer {
  const PlainCard();

  @override
  CamoCardStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoCardStyle(
      defaultAppearance: Appearance.raised,
      shape: BorderRadius.zero,
      contentPadding: EdgeInsetsDirectional.zero,
      solidColors: CardColors(container: c.primary, content: c.onPrimary),
      softColors: CardColors(
        container: c.surfaceContainerHighest,
        content: c.onSurface,
      ),
      raisedColors: CardColors(
        container: c.surfaceContainerLow,
        content: c.onSurface,
      ),
      outlineColors: CardColors(
        container: c.surface,
        content: c.onSurface,
        border: c.outlineVariant,
      ),
      raisedElevation: ElevationLevel.level1,
      hoveredElevation: ElevationLevel.level2,
      borderWidth: 1,
      toneBorderWidth: 4,
      selectedBorderColor: c.primary,
      selectedBorderWidth: 2,
      showSelectedCheck: false,
    );
  }

  @override
  Widget render(
    BuildContext context,
    CardState state,
    CardSlots slots,
    CamoTheme theme,
    CamoCardStyle style,
  ) => ColoredBox(
    color: style.colorsFor(state.appearance, state.tone, theme).container,
    child: slots.child,
  );
}

class PlainListItem implements CamoListItemRenderer {
  const PlainListItem();

  @override
  CamoListItemStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoListItemStyle(
      minHeightOneLine: 56,
      minHeightTwoLines: 72,
      minHeightThreeLines: 88,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leadingGap: 16,
      trailingGap: 16,
      headlineStyle: t.bodyLarge,
      supportingStyle: t.bodyMedium,
      overlineStyle: t.labelSmall,
      iconSize: 24,
      sectionShape: BorderRadius.zero,
      sectionTitleStyle: t.titleSmall,
      sectionFooterStyle: t.bodySmall,
      dividers: ListDividers.inset,
      dividerInsetStart: 56,
      colors: ListItemColors(
        headline: c.onSurface,
        supporting: c.onSurfaceVariant,
        overline: c.onSurfaceVariant,
        icon: c.onSurfaceVariant,
        selectedContainer: c.secondaryContainer,
        sectionTitle: c.onSurfaceVariant,
        sectionFooter: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    ListItemState state,
    ListItemSlots slots,
    CamoTheme theme,
    CamoListItemStyle style,
  ) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: style.minHeight(state.lines)),
    child: Row(
      children: [
        ?slots.leading,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.overline != null) Text(state.overline!),
              Text(state.headline),
              if (state.supporting != null) Text(state.supporting!),
            ],
          ),
        ),
        ?slots.trailing,
      ],
    ),
  );

  @override
  Widget section(
    BuildContext context,
    ListSectionState state,
    Widget rows,
    CamoTheme theme,
    CamoListItemStyle style,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (state.title != null)
        Semantics(header: true, child: Text(state.title!)),
      rows,
      if (state.footer != null) Text(state.footer!),
    ],
  );
}

class PlainAccordion implements CamoAccordionRenderer {
  const PlainAccordion();

  @override
  CamoAccordionStyle defaults(CamoTheme theme) => CamoAccordionStyle(
    indicator: AccordionIndicator.chevron,
    indicatorPosition: IndicatorPosition.end,
    headerMinHeight: 56,
    headerPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
    contentPadding: const EdgeInsetsDirectional.all(16),
    titleStyle: theme.typography.bodyLarge,
    subtitleStyle: theme.typography.bodyMedium,
    iconSize: 24,
    colors: AccordionColors(
      title: theme.colors.onSurface,
      subtitle: theme.colors.onSurfaceVariant,
      indicator: theme.colors.onSurfaceVariant,
    ),
    strings: const AccordionStrings(),
  );

  @override
  Widget render(
    BuildContext context,
    AccordionState state,
    AccordionSlots slots,
    CamoTheme theme,
    CamoAccordionStyle style,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      slots.header(
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: style.headerMinHeight),
          child: Row(
            children: [
              ?slots.leading,
              Expanded(child: Text(state.title)),
              Text(state.expanded ? '-' : '+'),
            ],
          ),
        ),
      ),
      slots.content,
    ],
  );
}

class PlainSkeleton implements CamoSkeletonRenderer {
  const PlainSkeleton();

  @override
  CamoSkeletonStyle defaults(CamoTheme theme) => CamoSkeletonStyle(
    animation: SkeletonAnimation.shimmer,
    baseColor: theme.colors.surfaceContainerHighest,
    highlightColor: theme.colors.surfaceContainerLow,
    cycleDuration: const Duration(milliseconds: 1500),
    textLineGap: 8,
  );

  @override
  Widget render(
    BuildContext context,
    SkeletonState state,
    CamoTheme theme,
    CamoSkeletonStyle style,
  ) => CamoSkeletonPaint(state: state, style: style);
}

class PlainTopBar implements CamoTopBarRenderer {
  const PlainTopBar();

  @override
  CamoTopBarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoTopBarStyle(
      titleAlign: CamoTitleAlign.start,
      divider: TopBarDivider.whenScrolled,
      height: 64,
      titleStyle: theme.typography.titleLarge,
      iconSize: 24,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      actionGap: 4,
      dividerWidth: 1,
      colors: TopBarColors(
        container: c.surface,
        scrolledContainer: c.surfaceContainer,
        title: c.onSurface,
        navigation: c.onSurface,
        actions: c.onSurfaceVariant,
        divider: c.outlineVariant,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    TopBarState state,
    TopBarSlots slots,
    CamoTheme theme,
    CamoTopBarStyle style,
  ) => KeyedSubtree(
    key: ValueKey(state.scrolled ? 'bar-scrolled' : 'bar-resting'),
    child: Padding(
      padding: state.insets,
      child: CamoTopBarRow(
        titleAlign: style.titleAlign,
        minHeight: style.height,
        actionGap: style.actionGap,
        navigation: slots.navigation,
        title:
            slots.titleContent ??
            Semantics(header: true, child: Text(state.title)),
        actions: slots.actions,
      ),
    ),
  );

  @override
  Widget container(
    BuildContext context,
    TopBarState state,
    Widget child,
    CamoTheme theme,
    CamoTopBarStyle style,
  ) => Padding(padding: state.insets, child: child);
}

class PlainPagedList implements CamoPagedListRenderer {
  const PlainPagedList();

  @override
  CamoPagedListStyle defaults(CamoTheme theme) => const CamoPagedListStyle(
    initialSkeletonCount: 4,
    moreSkeletonCount: 2,
    prefetchExtent: 100,
    refreshKeepsItems: false,
    refreshThreshold: 64,
    itemFadeIn: false,
    strings: PagedListStrings(),
  );

  @override
  Widget refreshIndicator(
    BuildContext context,
    PagedListState state,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => state.refreshing ? const Text('refreshing') : const SizedBox.shrink();

  @override
  Widget retryRow(
    BuildContext context,
    String message,
    VoidCallback onRetry,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => Row(
    children: [
      Expanded(child: Text(message)),
      CamoButton(text: style.strings.retry, onPressed: onRetry),
    ],
  );

  @override
  Widget empty(
    BuildContext context,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => Text(style.strings.emptyTitle);

  @override
  Widget error(
    BuildContext context,
    String message,
    VoidCallback onRetry,
    FocusNode retryFocus,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(message),
      CamoButton(
        text: style.strings.retry,
        onPressed: onRetry,
        focusNode: retryFocus,
      ),
    ],
  );
}
