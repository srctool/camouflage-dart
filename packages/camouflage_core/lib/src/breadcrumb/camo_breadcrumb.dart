import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../menu/camo_menu_anchor.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';

/// Every color a breadcrumb uses: [link] for items you can go to, [current] for the last one.
@immutable
class BreadcrumbColors {
  /// Creates BreadcrumbColors.
  const BreadcrumbColors({
    required this.link,
    required this.current,
    required this.separator,
    required this.hover,
  });

  /// Items you can go to.
  final Color link;

  /// The last item.
  final Color current;

  /// Between items.
  final Color separator;

  /// A hovered link.
  final Color hover;

  @override
  bool operator ==(Object other) =>
      other is BreadcrumbColors &&
      other.link == link &&
      other.current == current &&
      other.separator == separator &&
      other.hover == hover;

  @override
  int get hashCode => Object.hash(link, current, separator, hover);
}

/// Overrides for breadcrumbs. `null` keeps the skin's default.
@immutable
class CamoBreadcrumbTheme {
  /// Creates overrides.
  const CamoBreadcrumbTheme({
    this.separator,
    this.itemPadding,
    this.overflowIcon,
    this.iconSize,
    this.textStyle,
    this.colors,
  });

  /// Between items; mirrors in right-to-left layouts.
  final IconSource? separator;

  /// Around an item.
  final double? itemPadding;

  /// The overflow button.
  final IconSource? overflowIcon;

  /// Item and separator icons.
  final double? iconSize;

  /// Item labels.
  final TextStyle? textStyle;

  /// Every color it uses.
  final BreadcrumbColors? colors;

  /// A copy with the given fields replaced.
  CamoBreadcrumbTheme copyWith({
    IconSource? separator,
    double? itemPadding,
    IconSource? overflowIcon,
    double? iconSize,
    TextStyle? textStyle,
    BreadcrumbColors? colors,
  }) => CamoBreadcrumbTheme(
    separator: separator ?? this.separator,
    itemPadding: itemPadding ?? this.itemPadding,
    overflowIcon: overflowIcon ?? this.overflowIcon,
    iconSize: iconSize ?? this.iconSize,
    textStyle: textStyle ?? this.textStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoBreadcrumbTheme &&
      other.separator == separator &&
      other.itemPadding == itemPadding &&
      other.overflowIcon == overflowIcon &&
      other.iconSize == iconSize &&
      other.textStyle == textStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    separator,
    itemPadding,
    overflowIcon,
    iconSize,
    textStyle,
    colors,
  );
}

/// The resolved breadcrumb style: every field set.
@immutable
class CamoBreadcrumbStyle {
  /// Creates a style.
  const CamoBreadcrumbStyle({
    required this.separator,
    required this.itemPadding,
    required this.overflowIcon,
    required this.iconSize,
    required this.textStyle,
    required this.colors,
  });

  /// Between items; mirrors in right-to-left layouts.
  final IconSource separator;

  /// Around an item.
  final double itemPadding;

  /// The overflow button.
  final IconSource overflowIcon;

  /// Item and separator icons.
  final double iconSize;

  /// Item labels.
  final TextStyle textStyle;

  /// Every color it uses.
  final BreadcrumbColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoBreadcrumbStyle merge(CamoBreadcrumbTheme? o) => o == null
      ? this
      : CamoBreadcrumbStyle(
          separator: o.separator ?? separator,
          itemPadding: o.itemPadding ?? itemPadding,
          overflowIcon: o.overflowIcon ?? overflowIcon,
          iconSize: o.iconSize ?? iconSize,
          textStyle: o.textStyle ?? textStyle,
          colors: o.colors ?? colors,
        );
}

/// One step of the trail. A null [onPressed] makes it plain text.
@immutable
class CamoBreadcrumbItem {
  /// Creates an item.
  const CamoBreadcrumbItem({
    required this.id,
    required this.label,
    this.icon,
    this.onPressed,
  });

  /// Identifies the item across rebuilds.
  final Object id;

  /// The text.
  final String label;

  /// An icon before the text.
  final Widget? icon;

  /// Runs when it's pressed; `null` for plain text.
  final VoidCallback? onPressed;
}

/// What the container renderer draws: the row around the items. [collapsed] is how many items moved into the menu.
@immutable
class BreadcrumbState {
  /// Creates the state.
  const BreadcrumbState({required this.count, required this.collapsed});

  /// How many items the trail has.
  final int count;

  /// How many moved into the overflow menu.
  final int collapsed;
}

/// What an item draws: the [current] (last) one is not a link; [link] items show hover and focus.
@immutable
class BreadcrumbItemState {
  /// Creates the state.
  const BreadcrumbItemState({
    required this.current,
    required this.link,
    required this.interaction,
    required this.controller,
  });

  /// Whether it is the last item.
  final bool current;

  /// Whether it can be pressed.
  final bool link;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// An item's content.
@immutable
class BreadcrumbSlots {
  /// Creates the slots.
  const BreadcrumbSlots({required this.label, this.icon});

  /// The text.
  final String label;

  /// The icon.
  final Widget? icon;
}

/// Draws breadcrumbs in parts: the container, each item and the separator between them.
abstract interface class CamoBreadcrumbRenderer {
  /// The complete breadcrumb style for [theme].
  CamoBreadcrumbStyle defaults(CamoTheme theme);

  /// The row around [children].
  Widget renderContainer(
    BuildContext context,
    BreadcrumbState state,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
    List<Widget> children,
  );

  /// One item.
  Widget renderItem(
    BuildContext context,
    BreadcrumbItemState state,
    BreadcrumbSlots slots,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
  );

  /// The separator between two items.
  Widget renderSeparator(
    BuildContext context,
    CamoTheme theme,
    CamoBreadcrumbStyle style,
  );
}

/// Which items show: the first [head], then (when some are hidden) the overflow, then the last [tail].
@visibleForTesting
class CollapsePlan {
  /// Creates a plan.
  const CollapsePlan(this.head, this.tail);

  /// Items shown from the start.
  final int head;

  /// Items shown from the end.
  final int tail;
}

/// Chooses what shows in [available]. Everything shows when it fits (and within [maxVisible]); otherwise the first
/// item stays, the middle collapses behind an overflow button, and as many of the last items as fit stay.
@visibleForTesting
CollapsePlan planBreadcrumb(
  List<double> widths,
  double separator,
  double overflow,
  double available,
  int? maxVisible,
) {
  final n = widths.length;
  final all =
      widths.fold<double>(0, (a, b) => a + b) + separator * (n - 1).clamp(0, n);
  final fitsAll = all <= available && (maxVisible == null || n <= maxVisible);
  if (n <= 2 || fitsAll) return CollapsePlan(n, 0);
  bool fits(int tail) =>
      widths[0] +
              overflow +
              widths.skip(n - tail).fold<double>(0, (a, b) => a + b) +
              separator * (tail + 1) <=
          available &&
      (maxVisible == null || 1 + tail <= maxVisible);
  var tail = n - 2;
  while (tail > 1 && !fits(tail)) {
    tail--;
  }
  return CollapsePlan(1, tail);
}

/// A trail of where you are: the last item is the current location, earlier ones link up the hierarchy. When it
/// doesn't fit (or has more than [maxVisible] items) the middle items collapse into a "…" menu. One Tab stop: the
/// arrow keys move along the trail. [semanticLabel] names the navigation; the current item announces "current
/// page". It measures its room as it lays out, so it has no intrinsic size: give it a width.
class CamoBreadcrumb extends StatelessWidget {
  /// Creates a breadcrumb.
  const CamoBreadcrumb({
    super.key,
    required this.items,
    this.maxVisible,
    this.semanticLabel = 'Breadcrumb',
  });

  /// The trail, root first.
  final List<CamoBreadcrumbItem> items;

  /// At most this many items show (the rest collapse); `null` collapses only when it doesn't fit.
  final int? maxVisible;

  /// Names the navigation.
  final String semanticLabel;

  // An item's width as its renderer lays it out: the label, the icon and the padding around them.
  double _widthOf(
    BuildContext context,
    CamoBreadcrumbItem item,
    CamoBreadcrumbStyle style, {
    required bool current,
  }) {
    // Measured in the style the item is drawn in: the ambient text style under the skin's.
    final base = DefaultTextStyle.of(context).style.merge(style.textStyle);
    final painter = TextPainter(
      // The current item is drawn semibold by the stock skins, which is wider.
      text: TextSpan(
        text: item.label,
        style: current ? base.copyWith(fontWeight: FontWeight.w600) : base,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final icon = item.icon == null ? 0 : style.iconSize + style.itemPadding;
    return painter.width + icon + style.itemPadding * 2;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final skin = Camouflage.skinOf(context, component: 'CamoBreadcrumb');
    final theme = Camouflage.themeOf(context, component: 'CamoBreadcrumb');
    final style = skin.breadcrumb
        .defaults(theme)
        .merge(theme.components.breadcrumb);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final plan = planBreadcrumb(
            [
              for (final (i, item) in items.indexed)
                _widthOf(context, item, style, current: i == items.length - 1),
            ],
            style.iconSize,
            kCamoMinTouchTargetWidth,
            // The widths are measured text, so a little room is kept for what a skin adds.
            constraints.hasBoundedWidth
                ? constraints.maxWidth - _slack
                : double.infinity,
            maxVisible,
          );
          final tail = plan.tail;
          final head = tail == 0 ? items.length : plan.head;
          final hidden = tail == 0
              ? const <CamoBreadcrumbItem>[]
              : items.sublist(head, items.length - tail);
          Widget item(int i) => _ItemView(
            key: ValueKey(items[i].id),
            item: items[i],
            index: i,
            current: i == items.length - 1,
          );
          Widget separator() =>
              skin.breadcrumb.renderSeparator(context, theme, style);
          // Clipped, not squeezed: below the shortest form (first item, menu, last item) the end is cut off.
          return UnconstrainedBox(
            alignment: AlignmentDirectional.centerStart,
            constrainedAxis: Axis.vertical,
            clipBehavior: Clip.hardEdge,
            child: CamoRovingFocus(
              child: skin.breadcrumb.renderContainer(
                context,
                BreadcrumbState(count: items.length, collapsed: hidden.length),
                theme,
                style,
                [
                  for (var i = 0; i < head; i++) ...[
                    if (i > 0) separator(),
                    item(i),
                  ],
                  if (tail > 0) ...[
                    separator(),
                    _Overflow(
                      items: hidden,
                      index: head,
                      icon: style.overflowIcon,
                    ),
                    for (
                      var i = items.length - tail;
                      i < items.length;
                      i++
                    ) ...[separator(), item(i)],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

const double _slack = 8;

/// The width the overflow button takes (a touch target).
const double kCamoMinTouchTargetWidth = 48;

class _ItemView extends StatefulWidget {
  const _ItemView({
    super.key,
    required this.item,
    required this.index,
    required this.current,
  });

  final CamoBreadcrumbItem item;
  final int index;
  final bool current;

  @override
  State<_ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<_ItemView> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoBreadcrumb');
    final theme = Camouflage.themeOf(context, component: 'CamoBreadcrumb');
    final style = skin.breadcrumb
        .defaults(theme)
        .merge(theme.components.breadcrumb);
    final item = widget.item;
    final link = item.onPressed != null && !widget.current;
    return CamoRovingFocusItem(
      index: widget.index,
      enabled: link,
      selected: false,
      onSelect: () {},
      builder: (context, node) => CamoBehavior(
        controller: _interaction,
        enabled: link,
        focusNode: node,
        onActivate: item.onPressed,
        semantics: (child) => Semantics(
          button: link,
          enabled: link,
          label: item.label,
          value: widget.current ? 'current page' : null,
          excludeSemantics: true,
          child: child,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            widthFactor: 1,
            child: ListenableBuilder(
              listenable: _interaction,
              builder: (context, _) => skin.breadcrumb.renderItem(
                context,
                BreadcrumbItemState(
                  current: widget.current,
                  link: link,
                  interaction: _interaction.value,
                  controller: _interaction,
                ),
                BreadcrumbSlots(
                  label: item.label,
                  icon: item.icon == null
                      ? null
                      : ExcludeSemantics(child: item.icon),
                ),
                theme,
                style,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Overflow extends StatelessWidget {
  const _Overflow({
    required this.items,
    required this.index,
    required this.icon,
  });

  final List<CamoBreadcrumbItem> items;
  final int index;
  final IconSource icon;

  @override
  Widget build(BuildContext context) => CamoMenuAnchor(
    items: [
      for (final item in items)
        CamoMenuItem(
          text: item.label,
          onPressed: item.onPressed ?? () {},
          leadingIcon: item.icon,
          enabled: item.onPressed != null,
        ),
    ],
    builder: (context, open) => CamoRovingFocusItem(
      index: index,
      enabled: true,
      selected: false,
      onSelect: () {},
      builder: (context, node) => CamoIconButton(
        icon: CamoIcon(icon),
        semanticLabel: 'More',
        onPressed: open,
        appearance: Appearance.ghost,
        focusNode: node,
      ),
    ),
  );
}
