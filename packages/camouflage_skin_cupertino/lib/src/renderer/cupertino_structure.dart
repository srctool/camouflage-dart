import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Cupertino's structure components (base Cupertino Skin §3.2): inset grouped list sections (rounded, on the
// grouped background), cards without shadows, a disclosure triangle, a navigation bar whose large title collapses
// as the content scrolls under it.

const double _disabled = 0.38;
const double _iconSize = 20;
const double _progressSpot = 20;
const double _groupInset = 16;
const double _largeTitleHeight = 52;
const double _headerGap = 12;

TextStyle _semibold(TextStyle s) => s.copyWith(fontWeight: FontWeight.w600);

/// Cupertino's cards: a Raised card on the grouped background (a secondary grouped fill), radius 12, no shadow.
class CupertinoCardRenderer implements CamoCardRenderer {
  /// Creates the renderer.
  const CupertinoCardRenderer();

  @override
  CamoCardStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoCardStyle(
      defaultAppearance: Appearance.raised,
      shape: theme.shapes.medium,
      contentPadding: EdgeInsetsDirectional.zero,
      solidColors: CardColors(container: c.primary, content: c.onPrimary),
      softColors: CardColors(
        container: c.surfaceContainerHigh,
        content: c.onSurface,
      ),
      raisedColors: CardColors(
        container: c.surfaceContainerLow,
        content: c.onSurface,
      ),
      outlineColors: CardColors(
        container: c.surfaceContainerLow,
        content: c.onSurface,
        border: c.outline,
      ),
      raisedElevation: ElevationLevel.level0,
      hoveredElevation: ElevationLevel.level0,
      borderWidth: 0.5,
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
  ) => paintCard(context, state, slots, theme, style);
}

/// A card: the surface treatment, its border (or the selected border), a tone strip on a toned Raised card.
Widget paintCard(
  BuildContext context,
  CardState state,
  CardSlots slots,
  CamoTheme theme,
  CamoCardStyle style,
) {
  final skin = Camouflage.skinOf(context);
  final colors = style.colorsFor(state.appearance, state.tone, theme);
  final raised = state.appearance == Appearance.raised;
  final toned = raised && state.tone != Tone.defaultTone;
  final depth = !raised
      ? ElevationLevel.level0
      : state.clickable && state.interaction.hovered
      ? style.hoveredElevation
      : style.raisedElevation;
  final (Color, double)? border = state.selected == true
      ? (style.selectedBorderColor, style.selectedBorderWidth)
      : toned
      ? (style.raisedColors.border == null
            ? null
            : (style.raisedColors.border!, style.borderWidth))
      : (colors.border == null ? null : (colors.border!, style.borderWidth));
  final content = state.enabled || !state.clickable
      ? colors.content
      : colors.content.withValues(alpha: colors.content.a * _disabled);
  final icons = skin.icon.defaults(theme).merge(theme.components.icon);
  Widget body = CamoContentStyle(
    color: content,
    iconStyle: CamoIconStyle(size: icons.size, color: content),
    child: Padding(padding: style.contentPadding, child: slots.child),
  );
  if (toned && state.selected != true) {
    final strip = colors.border ?? colors.content;
    body = Stack(
      children: [
        body,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: style.toneBorderWidth,
          child: ColoredBox(color: strip),
        ),
      ],
    );
  }
  Widget card = skin.surfaceTreatment.decorate(
    color: colors.container,
    shape: style.shape,
    elevation: theme.elevation.of(depth),
    theme: theme,
    child: ClipRRect(borderRadius: style.shape, child: body),
  );
  if (border != null) {
    card = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: style.shape,
        border: Border.all(color: border.$1, width: border.$2),
      ),
      child: card,
    );
  }
  if (!state.clickable) return card;
  return skin.feedback.wrap(
    controller: state.controller,
    contentColor: content,
    shape: style.shape,
    theme: theme,
    child: card,
  );
}

/// Cupertino's list rows: 44 / 60 / 76, inset hairline dividers, inset grouped sections (rounded, on the grouped
/// background).
class CupertinoListItemRenderer implements CamoListItemRenderer {
  /// Creates the renderer.
  const CupertinoListItemRenderer();

  @override
  CamoListItemStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    final pad = theme.spacing.l;
    return CamoListItemStyle(
      minHeightOneLine: 44,
      minHeightTwoLines: 60,
      minHeightThreeLines: 76,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: pad,
        vertical: theme.spacing.s,
      ),
      leadingGap: pad,
      trailingGap: pad,
      headlineStyle: t.bodyLarge,
      supportingStyle: t.bodyMedium,
      overlineStyle: t.labelSmall,
      iconSize: _iconSize,
      sectionShape: theme.shapes.medium,
      sectionTitleStyle: t.bodySmall,
      sectionFooterStyle: t.bodySmall,
      dividers: ListDividers.inset,
      dividerInsetStart: pad + _iconSize + pad,
      colors: ListItemColors(
        headline: c.onSurface,
        supporting: c.onSurfaceVariant,
        overline: c.onSurfaceVariant,
        icon: c.primary,
        selectedContainer: c.surfaceContainerHigh,
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
  ) => paintListItem(context, state, slots, theme, style, BorderRadius.zero);

  @override
  Widget section(
    BuildContext context,
    ListSectionState state,
    Widget rows,
    CamoTheme theme,
    CamoListItemStyle style,
  ) => paintListSection(state, rows, theme, style);
}

/// A list row: leading, the text column and trailing, with the selected fill and the press feedback.
Widget paintListItem(
  BuildContext context,
  ListItemState state,
  ListItemSlots slots,
  CamoTheme theme,
  CamoListItemStyle style,
  BorderRadius shape,
) {
  final c = style.colors;
  final alpha = state.enabled ? 1.0 : _disabled;
  final icon = c.icon.withValues(alpha: c.icon.a * alpha);
  final leading = slots.leading;
  final trailing = slots.trailing;
  Widget row = ConstrainedBox(
    constraints: BoxConstraints(minHeight: style.minHeight(state.lines)),
    child: Padding(
      padding: style.contentPadding,
      child: CamoContentStyle(
        color: icon,
        iconStyle: CamoIconStyle(size: style.iconSize, color: icon),
        child: Row(
          crossAxisAlignment: state.lines >= 3
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (leading != null)
              Padding(
                padding: EdgeInsetsDirectional.only(end: style.leadingGap),
                child: leading,
              ),
            Expanded(
              child: Opacity(
                opacity: alpha,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.overline != null)
                      Text(
                        state.overline!,
                        style: style.overlineStyle.copyWith(color: c.overline),
                      ),
                    Text(
                      state.headline,
                      style: style.headlineStyle.copyWith(color: c.headline),
                    ),
                    if (state.supporting != null)
                      Text(
                        state.supporting!,
                        style: style.supportingStyle.copyWith(
                          color: c.supporting,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: style.trailingGap),
                child: trailing,
              ),
          ],
        ),
      ),
    ),
  );
  if (state.selected) {
    row = DecoratedBox(
      decoration: BoxDecoration(
        color: c.selectedContainer,
        borderRadius: shape,
      ),
      child: row,
    );
  }
  if (!state.clickable) return row;
  return Camouflage.skinOf(context).feedback.wrap(
    controller: state.controller,
    contentColor: c.headline,
    shape: shape,
    theme: theme,
    child: row,
  );
}

/// A list section: the title (a header), the rows on the section's fill, and the footer.
Widget paintListSection(
  ListSectionState state,
  Widget rows,
  CamoTheme theme,
  CamoListItemStyle style,
) {
  final pad = theme.spacing.l;
  // Inset grouped: the rows in a rounded group on the grouped background, 16 in from the edges; the title above it
  // and the footer below, both inset 16 more to line up with the rows' text.
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: _groupInset),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.title != null)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              pad,
              pad,
              pad,
              theme.spacing.s,
            ),
            child: Semantics(
              header: true,
              child: Text(
                state.title!,
                style: style.sectionTitleStyle.copyWith(
                  color: style.colors.sectionTitle,
                ),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: style.sectionShape,
          child: ColoredBox(
            color: theme.colors.surfaceContainerLow,
            child: rows,
          ),
        ),
        if (state.footer != null)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              pad,
              theme.spacing.s,
              pad,
              0,
            ),
            child: Text(
              state.footer!,
              style: style.sectionFooterStyle.copyWith(
                color: style.colors.sectionFooter,
              ),
            ),
          ),
      ],
    ),
  );
}

/// Cupertino's accordion: a disclosure triangle at the start (right when closed, down when open), a 44 header, `bodyLarge`.
class CupertinoAccordionRenderer implements CamoAccordionRenderer {
  /// Creates the renderer.
  const CupertinoAccordionRenderer();

  @override
  CamoAccordionStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final pad = theme.spacing.l;
    return CamoAccordionStyle(
      indicator: AccordionIndicator.chevron,
      indicatorPosition: IndicatorPosition.start,
      headerMinHeight: 44,
      headerPadding: EdgeInsetsDirectional.symmetric(horizontal: pad),
      contentPadding: EdgeInsetsDirectional.fromSTEB(pad, 0, pad, pad),
      titleStyle: theme.typography.bodyLarge,
      subtitleStyle: theme.typography.bodySmall,
      iconSize: _iconSize,
      colors: AccordionColors(
        title: c.onSurface,
        subtitle: c.onSurfaceVariant,
        indicator: c.primary,
      ),
      strings: const AccordionStrings(),
    );
  }

  @override
  Widget render(
    BuildContext context,
    AccordionState state,
    AccordionSlots slots,
    CamoTheme theme,
    CamoAccordionStyle style,
  ) => paintAccordion(
    context,
    state,
    slots,
    theme,
    style,
    BorderRadius.zero,
    _cupertinoIndicator,
  );
}

Widget _cupertinoIndicator(
  BuildContext context,
  AccordionState state,
  CamoAccordionStyle style,
) => switch (style.indicator) {
  AccordionIndicator.chevron => Transform.rotate(
    angle: -(1 - state.openFraction) * math.pi / 2,
    child: const CamoIcon(IconSource.builder(_chevronDown)),
  ),
  AccordionIndicator.plusMinus => CamoIcon(
    IconSource.builder(state.expanded ? _minus : _plus),
  ),
};

/// An accordion: the header row (leading, texts, the indicator on its side) and the core-animated content.
Widget paintAccordion(
  BuildContext context,
  AccordionState state,
  AccordionSlots slots,
  CamoTheme theme,
  CamoAccordionStyle style,
  BorderRadius shape,
  Widget Function(BuildContext, AccordionState, CamoAccordionStyle) indicator,
) {
  final c = style.colors;
  final alpha = state.enabled ? 1.0 : _disabled;
  final leading = slots.leading;
  final start = style.indicatorPosition == IndicatorPosition.start;
  final header = Camouflage.skinOf(context).feedback.wrap(
    controller: state.controller,
    contentColor: c.title,
    shape: shape,
    theme: theme,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.headerMinHeight),
      child: Padding(
        padding: style.headerPadding,
        child: Opacity(
          opacity: alpha,
          child: CamoContentStyle(
            color: c.indicator,
            iconStyle: CamoIconStyle(size: style.iconSize, color: c.indicator),
            child: Row(
              spacing: _headerGap,
              children: [
                if (start) indicator(context, state, style),
                ?leading,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.title,
                        style: style.titleStyle.copyWith(color: c.title),
                      ),
                      if (state.subtitle != null)
                        Text(
                          state.subtitle!,
                          style: style.subtitleStyle.copyWith(
                            color: c.subtitle,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!start) indicator(context, state, style),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  final open = c.expandedContainer;
  final Widget column = Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [slots.header(header), slots.content],
  );
  return state.expanded && open != null
      ? DecoratedBox(
          decoration: BoxDecoration(color: open, borderRadius: shape),
          child: column,
        )
      : column;
}

/// Cupertino's skeletons: a calm pulse in `surfaceContainerHigh`.
class CupertinoSkeletonRenderer implements CamoSkeletonRenderer {
  /// Creates the renderer.
  const CupertinoSkeletonRenderer();

  @override
  CamoSkeletonStyle defaults(CamoTheme theme) => CamoSkeletonStyle(
    animation: SkeletonAnimation.pulse,
    baseColor: theme.colors.secondaryContainer,
    highlightColor: theme.colors.surfaceContainerHigh,
    cycleDuration: const Duration(milliseconds: 1500),
    textLineGap: 6,
  );

  @override
  Widget render(
    BuildContext context,
    SkeletonState state,
    CamoTheme theme,
    CamoSkeletonStyle style,
  ) => CamoSkeletonPaint(state: state, style: style);
}

/// Cupertino's top bar: a 44 row with the inline title centered (fading in as content scrolls under the bar) and a
/// large title below it that collapses over 52 of scroll; a blur material and a hairline once scrolled.
class CupertinoTopBarRenderer implements CamoTopBarRenderer {
  /// Creates the renderer.
  const CupertinoTopBarRenderer();

  @override
  CamoTopBarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoTopBarStyle(
      titleAlign: CamoTitleAlign.center,
      divider: TopBarDivider.whenScrolled,
      height: 44,
      titleStyle: theme.typography.titleMedium,
      iconSize: 22,
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.xs),
      actionGap: theme.spacing.xs,
      dividerWidth: 0.5,
      colors: TopBarColors(
        container: c.surface,
        scrolledContainer: c.surfaceContainerLow,
        title: c.onSurface,
        navigation: c.primary,
        actions: c.primary,
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
  ) => paintTopBar(context, state, slots, theme, style);

  @override
  Widget container(
    BuildContext context,
    TopBarState state,
    Widget child,
    CamoTheme theme,
    CamoTopBarStyle style,
  ) => paintTopBarContainer(context, state, child, theme, style);
}

/// The bar's surface (the grouped background at rest, a blur material once content is under it), the content padded
/// by the insets, and the hairline.
Widget paintTopBarContainer(
  BuildContext context,
  TopBarState state,
  Widget child,
  CamoTheme theme,
  CamoTopBarStyle style,
) {
  final content = Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(padding: state.insets, child: child),
      if (style.showsDivider(state.scrollOffset))
        SizedBox(
          height: style.dividerWidth,
          child: ColoredBox(color: style.colors.divider),
        ),
    ],
  );
  if (state.scrolled) {
    return Camouflage.skinOf(context).surfaceTreatment.decorate(
      color: style.colors.scrolledContainer,
      shape: BorderRadius.zero,
      elevation: theme.elevation.of(ElevationLevel.level2),
      theme: theme,
      child: content,
    );
  }
  return ColoredBox(color: style.colors.container, child: content);
}

/// A top bar: navigation, the inline title (centered, a header) fading in as the content scrolls under the bar, the
/// actions, and below the row the large title, which collapses over 52 of scroll.
Widget paintTopBar(
  BuildContext context,
  TopBarState state,
  TopBarSlots slots,
  CamoTheme theme,
  CamoTopBarStyle style,
) {
  final c = style.colors;
  final navigation = slots.navigation;
  final large = slots.titleContent == null;
  final collapse = large
      ? (state.scrollOffset / _largeTitleHeight).clamp(0.0, 1.0)
      : 1.0;
  return paintTopBarContainer(
    context,
    state,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: style.padding,
          child: CamoTopBarRow(
            titleAlign: style.titleAlign,
            minHeight: style.height,
            actionGap: style.actionGap,
            navigation: navigation == null
                ? null
                : CamoContentStyle(
                    color: c.navigation,
                    iconStyle: CamoIconStyle(
                      size: style.iconSize,
                      color: c.navigation,
                    ),
                    child: navigation,
                  ),
            // Invisible at rest but still the bar's heading for assistive technology.
            title: Opacity(
              opacity: collapse,
              alwaysIncludeSemantics: true,
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: theme.spacing.s,
                ),
                child:
                    slots.titleContent ??
                    Semantics(
                      header: true,
                      child: Text(
                        state.title,
                        style: style.titleStyle.copyWith(color: c.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ),
            ),
            actions: [
              for (final a in slots.actions)
                CamoContentStyle(
                  color: c.actions,
                  iconStyle: CamoIconStyle(
                    size: style.iconSize,
                    color: c.actions,
                  ),
                  child: a,
                ),
            ],
          ),
        ),
        if (large && collapse < 1)
          ClipRect(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              heightFactor: 1 - collapse,
              child: Opacity(
                opacity: 1 - collapse,
                child: SizedBox(
                  height: _largeTitleHeight,
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: theme.spacing.l,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ExcludeSemantics(
                        child: Text(
                          state.title,
                          style: theme.typography.displaySmall.copyWith(
                            color: c.title,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
    theme,
    style,
  );
}

/// Cupertino's paged list: a 20 ink progress circle, a Ghost retry, centered quiet empty and error states.
class CupertinoPagedListRenderer implements CamoPagedListRenderer {
  /// Creates the renderer.
  const CupertinoPagedListRenderer();

  @override
  CamoPagedListStyle defaults(CamoTheme theme) => const CamoPagedListStyle(
    initialSkeletonCount: 10,
    moreSkeletonCount: 3,
    prefetchExtent: 400,
    refreshKeepsItems: false,
    refreshThreshold: 72,
    itemFadeIn: true,
    strings: PagedListStrings(),
  );

  @override
  Widget refreshIndicator(
    BuildContext context,
    PagedListState state,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => paintRefreshIndicator(state, theme, style, theme.colors.primary, null);

  @override
  Widget retryRow(
    BuildContext context,
    String message,
    VoidCallback onRetry,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => paintRetryRow(message, onRetry, theme, style);

  @override
  Widget empty(
    BuildContext context,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => paintPagedMessage(
    style.strings.emptyTitle,
    style.strings.emptyMessage,
    null,
    null,
    theme,
    style,
  );

  @override
  Widget error(
    BuildContext context,
    String message,
    VoidCallback onRetry,
    FocusNode retryFocus,
    CamoTheme theme,
    CamoPagedListStyle style,
  ) => paintPagedMessage(
    style.strings.errorTitle,
    message,
    onRetry,
    retryFocus,
    theme,
    style,
  );
}

/// The refresh spot: an arc that fills as the user pulls (following the finger down), then a spinning circle
/// while refreshing. [disc] draws a filled circle behind it when set.
Widget paintRefreshIndicator(
  PagedListState state,
  CamoTheme theme,
  CamoPagedListStyle style,
  Color color,
  Color? disc,
) {
  final active = state.refreshing || state.loading == PagedLoad.refresh;
  Widget spot = SizedBox.square(
    dimension: _progressSpot,
    child: active
        ? const CamoProgressCircle(size: ProgressSize.small)
        : CustomPaint(painter: _PullArc(state.pull, color)),
  );
  if (disc != null) {
    spot = DecoratedBox(
      decoration: BoxDecoration(color: disc, shape: BoxShape.circle),
      child: Padding(padding: EdgeInsets.all(theme.spacing.s), child: spot),
    );
  }
  return ValueListenableBuilder<double>(
    valueListenable: state.pull,
    builder: (context, pull, child) => Padding(
      padding: EdgeInsets.only(
        top:
            theme.spacing.l +
            (active ? 0 : math.min(pull, 1) * style.refreshThreshold),
      ),
      child: Opacity(opacity: active || pull > 0 ? 1 : 0, child: child),
    ),
    child: spot,
  );
}

class _PullArc extends CustomPainter {
  _PullArc(this.pull, this.color) : super(repaint: pull);

  final ValueListenable<double> pull;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final f = math.min(pull.value, 1.0);
    if (f <= 0) return;
    const stroke = 2.0;
    canvas.drawArc(
      (Offset.zero & size).deflate(stroke / 2),
      -math.pi / 2,
      2 * math.pi * f,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PullArc old) => old.color != color || old.pull != pull;
}

/// The next-page retry row: the message and a Ghost retry button.
Widget paintRetryRow(
  String message,
  VoidCallback onRetry,
  CamoTheme theme,
  CamoPagedListStyle style,
) => Padding(
  padding: EdgeInsetsDirectional.symmetric(
    horizontal: theme.spacing.l,
    vertical: theme.spacing.s,
  ),
  child: Row(
    children: [
      Expanded(
        child: Text(
          message,
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.onSurfaceVariant,
          ),
        ),
      ),
      CamoButton(
        text: style.strings.retry,
        onPressed: onRetry,
        appearance: Appearance.ghost,
      ),
    ],
  ),
);

/// A centered empty or error message; with [onRetry], a retry button under it.
Widget paintPagedMessage(
  String title,
  String message,
  VoidCallback? onRetry,
  FocusNode? retryFocus,
  CamoTheme theme,
  CamoPagedListStyle style,
) => Padding(
  padding: EdgeInsets.all(theme.spacing.xl),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing.s,
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: _semibold(theme.typography.titleMedium)
            .copyWith(color: theme.colors.onSurface),
      ),
      if (message.isNotEmpty)
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.onSurfaceVariant,
          ),
        ),
      if (onRetry != null)
        Padding(
          padding: EdgeInsets.only(top: theme.spacing.s),
          child: CamoButton(
            text: style.strings.retry,
            onPressed: onRetry,
            focusNode: retryFocus,
          ),
        ),
    ],
  ),
);

Widget _chevronDown(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(6, 9)
    ..lineTo(12, 15)
    ..lineTo(18, 9);
});

Widget _plus(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(5, 12)
    ..lineTo(19, 12)
    ..moveTo(12, 5)
    ..lineTo(12, 19);
});

Widget _minus(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(5, 12)
    ..lineTo(19, 12);
});

Widget _glyph(double size, Color? color, void Function(Path p) draw) =>
    SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StrokePainter(color ?? const Color(0xFF000000), draw),
      ),
    );

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
