import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';
import '../util/camo_touch_target.dart';

/// Every color pagination uses: the current page's [currentContainer] and [currentContent], the dots.
@immutable
class PaginationColors {
  /// Creates PaginationColors.
  const PaginationColors({
    required this.currentContainer,
    required this.currentContent,
    required this.content,
    required this.dot,
    required this.activeDot,
  });

  /// The current page's fill.
  final Color currentContainer;

  /// The current page's text.
  final Color currentContent;

  /// Other pages and arrows.
  final Color content;

  /// An inactive dot.
  final Color dot;

  /// The active dot.
  final Color activeDot;

  @override
  bool operator ==(Object other) =>
      other is PaginationColors &&
      other.currentContainer == currentContainer &&
      other.currentContent == currentContent &&
      other.content == content &&
      other.dot == dot &&
      other.activeDot == activeDot;

  @override
  int get hashCode =>
      Object.hash(currentContainer, currentContent, content, dot, activeDot);
}

/// Overrides for pagination. `null` keeps the skin's default.
@immutable
class CamoPaginationTheme {
  /// Creates overrides.
  const CamoPaginationTheme({
    this.buttonSize,
    this.shape,
    this.dotSize,
    this.gap,
    this.textStyle,
    this.previousIcon,
    this.nextIcon,
    this.colors,
  });

  /// Page button size.
  final double? buttonSize;

  /// Page button corners.
  final BorderRadius? shape;

  /// A dot of the page control.
  final double? dotSize;

  /// Between parts.
  final double? gap;

  /// Page numbers and the summary.
  final TextStyle? textStyle;

  /// The previous arrow.
  final IconSource? previousIcon;

  /// The next arrow.
  final IconSource? nextIcon;

  /// Every color it uses.
  final PaginationColors? colors;

  /// A copy with the given fields replaced.
  CamoPaginationTheme copyWith({
    double? buttonSize,
    BorderRadius? shape,
    double? dotSize,
    double? gap,
    TextStyle? textStyle,
    IconSource? previousIcon,
    IconSource? nextIcon,
    PaginationColors? colors,
  }) => CamoPaginationTheme(
    buttonSize: buttonSize ?? this.buttonSize,
    shape: shape ?? this.shape,
    dotSize: dotSize ?? this.dotSize,
    gap: gap ?? this.gap,
    textStyle: textStyle ?? this.textStyle,
    previousIcon: previousIcon ?? this.previousIcon,
    nextIcon: nextIcon ?? this.nextIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoPaginationTheme &&
      other.buttonSize == buttonSize &&
      other.shape == shape &&
      other.dotSize == dotSize &&
      other.gap == gap &&
      other.textStyle == textStyle &&
      other.previousIcon == previousIcon &&
      other.nextIcon == nextIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    buttonSize,
    shape,
    dotSize,
    gap,
    textStyle,
    previousIcon,
    nextIcon,
    colors,
  );
}

/// The resolved pagination style: every field set.
@immutable
class CamoPaginationStyle {
  /// Creates a style.
  const CamoPaginationStyle({
    required this.buttonSize,
    required this.shape,
    required this.dotSize,
    required this.gap,
    required this.textStyle,
    required this.previousIcon,
    required this.nextIcon,
    required this.colors,
  });

  /// Page button size.
  final double buttonSize;

  /// Page button corners.
  final BorderRadius shape;

  /// A dot of the page control.
  final double dotSize;

  /// Between parts.
  final double gap;

  /// Page numbers and the summary.
  final TextStyle textStyle;

  /// The previous arrow.
  final IconSource previousIcon;

  /// The next arrow.
  final IconSource nextIcon;

  /// Every color it uses.
  final PaginationColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoPaginationStyle merge(CamoPaginationTheme? o) => o == null
      ? this
      : CamoPaginationStyle(
          buttonSize: o.buttonSize ?? buttonSize,
          shape: o.shape ?? shape,
          dotSize: o.dotSize ?? dotSize,
          gap: o.gap ?? gap,
          textStyle: o.textStyle ?? textStyle,
          previousIcon: o.previousIcon ?? previousIcon,
          nextIcon: o.nextIcon ?? nextIcon,
          colors: o.colors ?? colors,
        );
}

/// The form of pagination: numbered pages, a compact "Page 3 of 9", or the dots of a page control.
enum PaginationVariant {
  /// Previous, 1 2 3 … 9, next.
  numbered,

  /// Previous, "Page 3 of 9", next.
  compact,

  /// The dots of a page control.
  dots,
}

/// Which way an arrow goes.
enum PageDirection {
  /// Towards the first page.
  previous,

  /// Towards the last page.
  next,
}

/// What the container renderer draws: the row around the parts.
@immutable
class PaginationState {
  /// Creates the state.
  const PaginationState({
    required this.pageCount,
    required this.page,
    required this.variant,
  });

  /// How many pages.
  final int pageCount;

  /// The current page, zero-based.
  final int page;

  /// The form.
  final PaginationVariant variant;
}

/// What a page button draws: page [index] (zero-based; show `index + 1`), the [current] one highlighted.
@immutable
class PageButtonState {
  /// Creates the state.
  const PageButtonState({
    required this.index,
    required this.current,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// The page, zero-based.
  final int index;

  /// Whether it is the current page.
  final bool current;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// What an arrow draws; [enabled] is `false` at the first or last page.
@immutable
class PageArrowState {
  /// Creates the state.
  const PageArrowState({
    required this.direction,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// Which way it goes.
  final PageDirection direction;

  /// `false` at the end of the range.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// What a dot of the page control draws.
@immutable
class PageDotState {
  /// Creates the state.
  const PageDotState({
    required this.active,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// Whether it is the current page.
  final bool active;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws pagination in parts.
abstract interface class CamoPaginationRenderer {
  /// The complete pagination style for [theme].
  CamoPaginationStyle defaults(CamoTheme theme);

  /// The row around [children].
  Widget renderContainer(
    BuildContext context,
    PaginationState state,
    CamoTheme theme,
    CamoPaginationStyle style,
    List<Widget> children,
  );

  /// A page button showing [label] (the page number).
  Widget renderButton(
    BuildContext context,
    PageButtonState state,
    String label,
    CamoTheme theme,
    CamoPaginationStyle style,
  );

  /// A previous or next arrow.
  Widget renderArrow(
    BuildContext context,
    PageArrowState state,
    CamoTheme theme,
    CamoPaginationStyle style,
  );

  /// The gap ("…") between non-adjacent pages.
  Widget renderGap(
    BuildContext context,
    CamoTheme theme,
    CamoPaginationStyle style,
  );

  /// A dot of the page control.
  Widget renderDot(
    BuildContext context,
    PageDotState state,
    CamoTheme theme,
    CamoPaginationStyle style,
  );

  /// The compact form's text ("Page 3 of 9").
  Widget renderSummary(
    BuildContext context,
    String text,
    CamoTheme theme,
    CamoPaginationStyle style,
  );
}

/// One item of the numbered form: a page (zero-based) or a gap.
@visibleForTesting
@immutable
sealed class PageItem {
  const PageItem();
}

/// A page.
@visibleForTesting
class PageItemPage extends PageItem {
  /// Creates the item.
  const PageItemPage(this.index);

  /// The page, zero-based.
  final int index;

  @override
  bool operator ==(Object other) =>
      other is PageItemPage && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// A gap.
@visibleForTesting
class PageItemGap extends PageItem {
  /// Creates the item.
  const PageItemGap();
}

// The numbered form's fixed slots (first, last, current and two gaps) and where its middle pages start (1-based).
const _fixedSlots = 5;
const _firstMiddle = 3;

/// The items of the numbered form: always the first and last page, [siblings] pages around [page], and a gap where
/// pages are left out (a gap that would hide a single page shows that page instead), so the length is fixed at
/// `2 * siblings + 5` once there are more pages than that.
@visibleForTesting
List<PageItem> pageItems(int pageCount, int page, int siblings) {
  if (pageCount <= siblings * 2 + _fixedSlots) {
    return [for (var i = 0; i < pageCount; i++) PageItemPage(i)];
  }
  final current = page + 1;
  final startSiblings = _max(
    _min(current - siblings, pageCount - siblings * 2 - 2),
    _firstMiddle,
  );
  final endSiblings = _min(
    _max(current + siblings, siblings * 2 + _firstMiddle),
    pageCount - 2,
  );
  return [
    const PageItemPage(0),
    if (startSiblings > _firstMiddle)
      const PageItemGap()
    else
      const PageItemPage(1),
    for (var n = startSiblings; n <= endSiblings; n++) PageItemPage(n - 1),
    if (endSiblings < pageCount - 2)
      const PageItemGap()
    else
      PageItemPage(pageCount - 2),
    PageItemPage(pageCount - 1),
  ];
}

int _min(int a, int b) => a < b ? a : b;
int _max(int a, int b) => a > b ? a : b;

/// Moves through pages. [page] is zero-based. One Tab stop: the arrow keys move between the parts and Space or
/// Enter picks one. [semanticLabel] names the navigation; a page announces "Page 3" and the current one "current
/// page". With one page or fewer it draws nothing.
class CamoPagination extends StatelessWidget {
  /// Creates pagination.
  const CamoPagination({
    super.key,
    required this.pageCount,
    required this.page,
    required this.onPageChanged,
    this.variant = PaginationVariant.numbered,
    this.siblings = 1,
    this.enabled = true,
    this.semanticLabel = 'Pagination',
  });

  /// How many pages.
  final int pageCount;

  /// The current page, zero-based.
  final int page;

  /// Called with the chosen page.
  final ValueChanged<int> onPageChanged;

  /// The form.
  final PaginationVariant variant;

  /// Pages shown beside the current one.
  final int siblings;

  /// `false` disables every part.
  final bool enabled;

  /// Names the navigation.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    final skin = Camouflage.skinOf(context, component: 'CamoPagination');
    final theme = Camouflage.themeOf(context, component: 'CamoPagination');
    final style = skin.pagination
        .defaults(theme)
        .merge(theme.components.pagination);
    final current = page.clamp(0, pageCount - 1);
    _Part part(
      int slot,
      Widget Function(BuildContext, CamoInteractionController, bool) build, {
      required bool selected,
      required bool partEnabled,
      required String label,
      required VoidCallback onPressed,
      String? value,
    }) => _Part(
      slot: slot,
      selected: selected,
      enabled: enabled && partEnabled,
      label: label,
      value: value,
      onPressed: onPressed,
      build: build,
    );
    final children = <Widget>[
      part(
        0,
        (context, controller, on) => skin.pagination.renderArrow(
          context,
          PageArrowState(
            direction: PageDirection.previous,
            enabled: on,
            interaction: controller.value,
            controller: controller,
          ),
          theme,
          style,
        ),
        selected: false,
        partEnabled: current > 0,
        label: 'Previous page',
        onPressed: () => onPageChanged(current - 1),
      ),
      ...switch (variant) {
        PaginationVariant.numbered => [
          for (final (i, item) in pageItems(
            pageCount,
            current,
            siblings,
          ).indexed)
            switch (item) {
              PageItemPage(:final index) => part(
                i + 1,
                (context, controller, on) => skin.pagination.renderButton(
                  context,
                  PageButtonState(
                    index: index,
                    current: index == current,
                    enabled: on,
                    interaction: controller.value,
                    controller: controller,
                  ),
                  '${index + 1}',
                  theme,
                  style,
                ),
                selected: index == current,
                partEnabled: true,
                label: 'Page ${index + 1}',
                value: index == current ? 'current page' : null,
                onPressed: () => onPageChanged(index),
              ),
              PageItemGap() => skin.pagination.renderGap(context, theme, style),
            },
        ],
        PaginationVariant.compact => [
          skin.pagination.renderSummary(
            context,
            'Page ${current + 1} of $pageCount',
            theme,
            style,
          ),
        ],
        PaginationVariant.dots => [
          for (var i = 0; i < pageCount; i++)
            part(
              i + 1,
              (context, controller, on) => skin.pagination.renderDot(
                context,
                PageDotState(
                  active: i == current,
                  enabled: on,
                  interaction: controller.value,
                  controller: controller,
                ),
                theme,
                style,
              ),
              selected: i == current,
              partEnabled: true,
              label: 'Page ${i + 1}',
              onPressed: () => onPageChanged(i),
            ),
        ],
      },
      part(
        pageCount + 2,
        (context, controller, on) => skin.pagination.renderArrow(
          context,
          PageArrowState(
            direction: PageDirection.next,
            enabled: on,
            interaction: controller.value,
            controller: controller,
          ),
          theme,
          style,
        ),
        selected: false,
        partEnabled: current < pageCount - 1,
        label: 'Next page',
        onPressed: () => onPageChanged(current + 1),
      ),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: CamoRovingFocus(
        child: skin.pagination.renderContainer(
          context,
          PaginationState(
            pageCount: pageCount,
            page: current,
            variant: variant,
          ),
          theme,
          style,
          children,
        ),
      ),
    );
  }
}

class _Part extends StatefulWidget {
  const _Part({
    required this.slot,
    required this.selected,
    required this.enabled,
    required this.label,
    required this.onPressed,
    required this.build,
    this.value,
  });

  final int slot;
  final bool selected;
  final bool enabled;
  final String label;
  final String? value;
  final VoidCallback onPressed;
  final Widget Function(BuildContext, CamoInteractionController, bool) build;

  @override
  State<_Part> createState() => _PartState();
}

class _PartState extends State<_Part> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CamoRovingFocusItem(
    index: widget.slot,
    enabled: widget.enabled,
    selected: widget.selected,
    onSelect: () {},
    builder: (context, node) => CamoBehavior(
      controller: _interaction,
      enabled: widget.enabled,
      focusNode: node,
      onActivate: widget.onPressed,
      semantics: (child) => Semantics(
        button: true,
        enabled: widget.enabled,
        selected: widget.selected,
        label: widget.label,
        value: widget.value,
        excludeSemantics: true,
        child: child,
      ),
      child: CamoTouchTarget(
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) =>
              widget.build(context, _interaction, widget.enabled),
        ),
      ),
    ),
  );
}
