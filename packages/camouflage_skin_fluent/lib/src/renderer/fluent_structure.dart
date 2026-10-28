import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../fluent_tokens.dart';

// Fluent's structure components (base Fluent Skin §3): shadow4 cards, quiet lists, the chevron at the start.

const double _disabled = 0.38;
const double _iconSize = 20;
const double _progressSpot = 20;
const double _headerGap = 8;

TextStyle _semibold(TextStyle s) => s.copyWith(fontWeight: FontWeight.w600);

/// Fluent's cards: radius 8, shadow4 (shadow8 on hover), brand Solid, a brand border when selected.
class FluentCardRenderer implements CamoCardRenderer {
  /// Creates the renderer.
  const FluentCardRenderer();

  @override
  CamoCardStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.tokens<FluentTokens>();
    return CamoCardStyle(
      defaultAppearance: Appearance.raised,
      shape: theme.shapes.medium,
      contentPadding: EdgeInsetsDirectional.zero,
      solidColors: CardColors(container: c.primary, content: c.onPrimary),
      softColors: CardColors(
        container: c.surfaceContainerLow,
        content: c.onSurface,
      ),
      raisedColors: CardColors(container: c.surface, content: c.onSurface),
      outlineColors: CardColors(
        container: c.surface,
        content: c.onSurface,
        border: t?.neutralStroke1 ?? c.outline,
      ),
      // shadow4 at rest, shadow8 while hovered.
      raisedElevation: ElevationLevel.level2,
      hoveredElevation: ElevationLevel.level3,
      borderWidth: 1,
      toneBorderWidth: 3,
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

/// Fluent's list rows: 40 / 56 / 72, no dividers, a subtle selected fill.
class FluentListItemRenderer implements CamoListItemRenderer {
  /// Creates the renderer.
  const FluentListItemRenderer();

  @override
  CamoListItemStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    final pad = theme.spacing.m;
    return CamoListItemStyle(
      minHeightOneLine: 40,
      minHeightTwoLines: 56,
      minHeightThreeLines: 72,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: pad,
        vertical: theme.spacing.xs + theme.spacing.xxs,
      ),
      leadingGap: pad,
      trailingGap: pad,
      headlineStyle: t.bodyMedium,
      supportingStyle: t.bodySmall,
      overlineStyle: t.labelSmall,
      iconSize: _iconSize,
      sectionShape: theme.shapes.none,
      sectionTitleStyle: _semibold(t.titleSmall),
      sectionFooterStyle: t.bodySmall,
      dividers: ListDividers.none,
      dividerInsetStart: pad + _iconSize + pad,
      colors: ListItemColors(
        headline: c.onSurface,
        supporting: c.onSurfaceVariant,
        overline: c.onSurfaceVariant,
        icon: c.onSurfaceVariant,
        selectedContainer:
            theme.tokens<FluentTokens>()?.subtleBackgroundPressed ??
            c.surfaceContainerHigh,
        sectionTitle: c.onSurface,
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
  ) => paintListItem(context, state, slots, theme, style, theme.shapes.small);

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
  return Column(
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
          color: theme.colors.surfaceOf(state.level),
          child: rows,
        ),
      ),
      if (state.footer != null)
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(pad, theme.spacing.s, pad, 0),
          child: Text(
            state.footer!,
            style: style.sectionFooterStyle.copyWith(
              color: style.colors.sectionFooter,
            ),
          ),
        ),
    ],
  );
}

/// Fluent's accordion: the chevron at the start, turning down as it opens; a 44 header.
class FluentAccordionRenderer implements CamoAccordionRenderer {
  /// Creates the renderer.
  const FluentAccordionRenderer();

  @override
  CamoAccordionStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final pad = theme.spacing.m;
    return CamoAccordionStyle(
      indicator: AccordionIndicator.chevron,
      indicatorPosition: IndicatorPosition.start,
      headerMinHeight: 44,
      headerPadding: EdgeInsetsDirectional.symmetric(horizontal: pad),
      contentPadding: EdgeInsetsDirectional.fromSTEB(pad, 0, pad, pad),
      titleStyle: theme.typography.bodyMedium,
      subtitleStyle: theme.typography.bodySmall,
      iconSize: _iconSize,
      colors: AccordionColors(
        title: c.onSurface,
        subtitle: c.onSurfaceVariant,
        indicator: c.onSurfaceVariant,
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
    theme.shapes.small,
    _fluentIndicator,
  );
}

Widget _fluentIndicator(
  BuildContext context,
  AccordionState state,
  CamoAccordionStyle style,
) => switch (style.indicator) {
  // The chevron points along the reading direction while closed and turns down as the section opens.
  AccordionIndicator.chevron => Transform.rotate(
    angle:
        state.openFraction *
        math.pi /
        2 *
        (Directionality.of(context) == TextDirection.rtl ? -1 : 1),
    child: const CamoIcon(IconSource.builder(_chevronEnd, autoMirror: true)),
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

/// Fluent's skeletons: a shimmer sweeping across `surfaceContainerHigh`.
class FluentSkeletonRenderer implements CamoSkeletonRenderer {
  /// Creates the renderer.
  const FluentSkeletonRenderer();

  @override
  CamoSkeletonStyle defaults(CamoTheme theme) => CamoSkeletonStyle(
    animation: SkeletonAnimation.shimmer,
    baseColor: theme.colors.surfaceContainerHigh,
    highlightColor: theme.colors.surfaceContainerLowest,
    cycleDuration: const Duration(milliseconds: 2000),
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

/// Fluent's app header: 48 tall, the title at the start in `titleMedium` semibold, a stroke once scrolled.
class FluentTopBarRenderer implements CamoTopBarRenderer {
  /// Creates the renderer.
  const FluentTopBarRenderer();

  @override
  CamoTopBarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoTopBarStyle(
      titleAlign: CamoTitleAlign.start,
      divider: TopBarDivider.whenScrolled,
      height: 48,
      titleStyle: _semibold(theme.typography.titleMedium),
      iconSize: _iconSize,
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.xs),
      actionGap: theme.spacing.xs,
      dividerWidth: 1,
      colors: TopBarColors(
        container: c.surface,
        scrolledContainer: c.surface,
        title: c.onSurface,
        navigation: c.onSurface,
        actions: c.onSurface,
        divider:
            theme.tokens<FluentTokens>()?.neutralStroke2 ?? c.outlineVariant,
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
  ) => paintTopBar(state, slots, theme, style);

  @override
  Widget container(
    BuildContext context,
    TopBarState state,
    Widget child,
    CamoTheme theme,
    CamoTopBarStyle style,
  ) => paintTopBarContainer(state, child, theme, style);
}

/// The bar's surface (tinted when scrolled), the content padded by the insets, and the divider.
Widget paintTopBarContainer(
  TopBarState state,
  Widget child,
  CamoTheme theme,
  CamoTopBarStyle style,
) => TweenAnimationBuilder<Color?>(
  tween: ColorTween(
    end: state.scrolled
        ? style.colors.scrolledContainer
        : style.colors.container,
  ),
  duration: theme.motion.durationShort,
  builder: (context, color, _) => ColoredBox(
    color: color ?? style.colors.container,
    child: Column(
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
    ),
  ),
);

/// A top bar: navigation, the title placed by `titleAlign` (a header), and the actions, on the bar's surface.
Widget paintTopBar(
  TopBarState state,
  TopBarSlots slots,
  CamoTheme theme,
  CamoTopBarStyle style,
) {
  final c = style.colors;
  final navigation = slots.navigation;
  // Without navigation, a start-aligned title keeps the bar's text inset.
  final inset = navigation == null && style.titleAlign == CamoTitleAlign.start
      ? EdgeInsetsDirectional.only(start: theme.spacing.l - theme.spacing.xs)
      : EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.s);
  return paintTopBarContainer(
    state,
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
        title: Padding(
          padding: inset,
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
        actions: [
          for (final a in slots.actions)
            CamoContentStyle(
              color: c.actions,
              iconStyle: CamoIconStyle(size: style.iconSize, color: c.actions),
              child: a,
            ),
        ],
      ),
    ),
    theme,
    style,
  );
}

/// Fluent's paged list: a brand spinner on a disc, a Ghost retry, centered empty and error states.
class FluentPagedListRenderer implements CamoPagedListRenderer {
  /// Creates the renderer.
  const FluentPagedListRenderer();

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
  ) => paintRefreshIndicator(
    state,
    theme,
    style,
    theme.colors.primary,
    theme.colors.surface,
  );

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

Widget _chevronEnd(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(10, 6)
    ..lineTo(16, 12)
    ..lineTo(10, 18);
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

// A 24-unit glyph stroked in [color] at 1.5 units (Fluent's regular weight).
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
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.color != color;
}
