import 'package:flutter/widgets.dart';

import '../list/camo_list_item.dart' show dividedColumn;
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';

/// The icon that shows whether a section is open.
enum AccordionIndicator {
  /// A chevron that turns.
  chevron,

  /// A plus that becomes a minus.
  plusMinus,
}

/// Which end of the header the indicator sits at, in reading order.
enum IndicatorPosition {
  /// Before the title.
  start,

  /// After the title.
  end,
}

/// The words an accordion header announces.
@immutable
class AccordionStrings {
  /// Creates AccordionStrings.
  const AccordionStrings({
    this.expanded = 'Expanded',
    this.collapsed = 'Collapsed',
    this.expand = 'Expand',
    this.collapse = 'Collapse',
  });

  /// An open section's state, where the platform has no expanded flag of its own.
  final String expanded;

  /// A closed section's state, likewise.
  final String collapsed;

  /// The action on a closed header.
  final String expand;

  /// The action on an open header.
  final String collapse;

  @override
  bool operator ==(Object other) =>
      other is AccordionStrings &&
      other.expanded == expanded &&
      other.collapsed == collapsed &&
      other.expand == expand &&
      other.collapse == collapse;

  @override
  int get hashCode => Object.hash(expanded, collapsed, expand, collapse);
}

/// Every color an accordion uses; [expandedContainer] fills an open section when set.
@immutable
class AccordionColors {
  /// Creates AccordionColors.
  const AccordionColors({
    required this.title,
    required this.subtitle,
    required this.indicator,
    this.expandedContainer,
  });

  /// The title.
  final Color title;

  /// The subtitle.
  final Color subtitle;

  /// The indicator and leading icon.
  final Color indicator;

  /// An open section's fill, if any.
  final Color? expandedContainer;

  @override
  bool operator ==(Object other) =>
      other is AccordionColors &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.indicator == indicator &&
      other.expandedContainer == expandedContainer;

  @override
  int get hashCode =>
      Object.hash(title, subtitle, indicator, expandedContainer);
}

/// Overrides for accordions; `null` keeps the skin's default.
@immutable
class CamoAccordionTheme {
  /// Creates CamoAccordionTheme.
  const CamoAccordionTheme({
    this.indicator,
    this.indicatorPosition,
    this.headerMinHeight,
    this.headerPadding,
    this.contentPadding,
    this.titleStyle,
    this.subtitleStyle,
    this.iconSize,
    this.colors,
    this.strings,
  });

  /// The open/closed icon.
  final AccordionIndicator? indicator;

  /// Where the icon sits.
  final IndicatorPosition? indicatorPosition;

  /// The header row's height.
  final double? headerMinHeight;

  /// The header row's padding.
  final EdgeInsetsDirectional? headerPadding;

  /// Around the content.
  final EdgeInsetsDirectional? contentPadding;

  /// The title.
  final TextStyle? titleStyle;

  /// The subtitle.
  final TextStyle? subtitleStyle;

  /// The indicator and leading icon.
  final double? iconSize;

  /// Every color it uses.
  final AccordionColors? colors;

  /// The words it announces.
  final AccordionStrings? strings;

  /// A copy with the given fields replaced.
  CamoAccordionTheme copyWith({
    AccordionIndicator? indicator,
    IndicatorPosition? indicatorPosition,
    double? headerMinHeight,
    EdgeInsetsDirectional? headerPadding,
    EdgeInsetsDirectional? contentPadding,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    double? iconSize,
    AccordionColors? colors,
    AccordionStrings? strings,
  }) => CamoAccordionTheme(
    indicator: indicator ?? this.indicator,
    indicatorPosition: indicatorPosition ?? this.indicatorPosition,
    headerMinHeight: headerMinHeight ?? this.headerMinHeight,
    headerPadding: headerPadding ?? this.headerPadding,
    contentPadding: contentPadding ?? this.contentPadding,
    titleStyle: titleStyle ?? this.titleStyle,
    subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    iconSize: iconSize ?? this.iconSize,
    colors: colors ?? this.colors,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoAccordionTheme &&
      other.indicator == indicator &&
      other.indicatorPosition == indicatorPosition &&
      other.headerMinHeight == headerMinHeight &&
      other.headerPadding == headerPadding &&
      other.contentPadding == contentPadding &&
      other.titleStyle == titleStyle &&
      other.subtitleStyle == subtitleStyle &&
      other.iconSize == iconSize &&
      other.colors == colors &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    indicator,
    indicatorPosition,
    headerMinHeight,
    headerPadding,
    contentPadding,
    titleStyle,
    subtitleStyle,
    iconSize,
    colors,
    strings,
  );
}

/// The resolved accordion style: every field set.
@immutable
class CamoAccordionStyle {
  /// Creates CamoAccordionStyle.
  const CamoAccordionStyle({
    required this.indicator,
    required this.indicatorPosition,
    required this.headerMinHeight,
    required this.headerPadding,
    required this.contentPadding,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.iconSize,
    required this.colors,
    required this.strings,
  });

  /// The open/closed icon.
  final AccordionIndicator indicator;

  /// Where the icon sits.
  final IndicatorPosition indicatorPosition;

  /// The header row's height.
  final double headerMinHeight;

  /// The header row's padding.
  final EdgeInsetsDirectional headerPadding;

  /// Around the content.
  final EdgeInsetsDirectional contentPadding;

  /// The title.
  final TextStyle titleStyle;

  /// The subtitle.
  final TextStyle subtitleStyle;

  /// The indicator and leading icon.
  final double iconSize;

  /// Every color it uses.
  final AccordionColors colors;

  /// The words it announces.
  final AccordionStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoAccordionStyle merge(CamoAccordionTheme? o) => o == null
      ? this
      : CamoAccordionStyle(
          indicator: o.indicator ?? indicator,
          indicatorPosition: o.indicatorPosition ?? indicatorPosition,
          headerMinHeight: o.headerMinHeight ?? headerMinHeight,
          headerPadding: o.headerPadding ?? headerPadding,
          contentPadding: o.contentPadding ?? contentPadding,
          titleStyle: o.titleStyle ?? titleStyle,
          subtitleStyle: o.subtitleStyle ?? subtitleStyle,
          iconSize: o.iconSize ?? iconSize,
          colors: o.colors ?? colors,
          strings: o.strings ?? strings,
        );
}

/// What an accordion renderer draws: a header with [title], [subtitle] and the indicator, and the content
/// below. [openFraction] runs from 0 (closed) to 1 (open) with the expand animation: turn or morph the
/// indicator with it.
@immutable
class AccordionState {
  /// Creates an accordion state.
  const AccordionState({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.openFraction,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// The header's title.
  final String title;

  /// The line under it, if any.
  final String? subtitle;

  /// Whether the section is open.
  final bool expanded;

  /// The animation, 0 closed to 1 open.
  final double openFraction;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The header's press, hover and focus.
  final InteractionState interaction;

  /// For the skin's feedback on the header.
  final CamoInteractionController controller;
}

/// The parts an accordion renderer places: the caller's [leading] icon, the [header] behavior to wrap the
/// header row in, and [content], which core already pads, clips and animates to its open height.
@immutable
class AccordionSlots {
  /// Creates the slots.
  const AccordionSlots({
    required this.leading,
    required this.header,
    required this.content,
  });

  /// An icon before the title.
  final Widget? leading;

  /// Wraps the drawn header row in its behavior and semantics.
  final Widget Function(Widget headerRow) header;

  /// The content, below the header, full width.
  final Widget content;
}

/// Draws accordions.
abstract interface class CamoAccordionRenderer {
  /// The complete accordion style for [theme].
  CamoAccordionStyle defaults(CamoTheme theme);

  /// Draws the header (through `slots.header`) and places the content below it.
  Widget render(
    BuildContext context,
    AccordionState state,
    AccordionSlots slots,
    CamoTheme theme,
    CamoAccordionStyle style,
  );
}

/// An expandable section (an FAQ answer, a "Shipping" panel). It's controlled: the app owns [expanded]. The
/// header is a button and a heading with an expanded state. Collapsed content stays mounted, keeping its state
/// (a half-filled form), but takes no space and is neither focusable nor announced.
class CamoAccordion extends StatefulWidget {
  /// Creates an accordion.
  const CamoAccordion({
    super.key,
    required this.title,
    required this.expanded,
    required this.onExpansionChanged,
    this.subtitle,
    this.leading,
    this.enabled = true,
    this.focusNode,
    required this.child,
  });

  /// The header's title.
  final String title;

  /// Whether it's open.
  final bool expanded;

  /// Called with the new state.
  final ValueChanged<bool> onExpansionChanged;

  /// A line under the title.
  final String? subtitle;

  /// An icon before the title.
  final Widget? leading;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node for the header.
  final FocusNode? focusNode;

  /// The content.
  final Widget child;

  @override
  State<CamoAccordion> createState() => _CamoAccordionState();
}

class _CamoAccordionState extends State<CamoAccordion>
    with SingleTickerProviderStateMixin {
  final _interaction = CamoInteractionController();
  late final _open = AnimationController(
    vsync: this,
    value: widget.expanded ? 1 : 0,
  );

  @override
  void didUpdateWidget(CamoAccordion old) {
    super.didUpdateWidget(old);
    if (old.expanded != widget.expanded) {
      final theme = Camouflage.themeOf(context, component: 'CamoAccordion');
      _open.animateTo(
        widget.expanded ? 1 : 0,
        duration: theme.motion.durationMedium,
        curve: theme.motion.easingStandard,
      );
    }
  }

  @override
  void dispose() {
    _interaction.dispose();
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoAccordion');
    final theme = Camouflage.themeOf(context, component: 'CamoAccordion');
    final style = skin.accordion
        .defaults(theme)
        .merge(theme.components.accordion);
    final expanded = widget.expanded;
    void toggle() => widget.onExpansionChanged(!expanded);
    Widget header(Widget row) => MergeSemantics(
      child: CamoBehavior(
        controller: _interaction,
        enabled: widget.enabled,
        focusNode: widget.focusNode,
        onActivate: toggle,
        semantics: (child) => Semantics(
          button: true,
          header: true,
          expanded: expanded,
          enabled: widget.enabled,
          onTapHint: expanded ? style.strings.collapse : style.strings.expand,
          child: child,
        ),
        child: row,
      ),
    );
    final content = AnimatedBuilder(
      animation: _open,
      builder: (context, child) => ClipRect(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          heightFactor: _open.value,
          child: Visibility(
            visible: _open.value > 0,
            maintainState: true,
            maintainAnimation: true,
            child: child!,
          ),
        ),
      ),
      child: ExcludeFocus(
        excluding: !expanded,
        child: ExcludeSemantics(
          excluding: !expanded,
          child: Padding(padding: style.contentPadding, child: widget.child),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_open, _interaction]),
      builder: (context, _) => skin.accordion.render(
        context,
        AccordionState(
          title: widget.title,
          subtitle: widget.subtitle,
          expanded: expanded,
          openFraction: _open.value,
          enabled: widget.enabled,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        AccordionSlots(
          leading: widget.leading,
          header: header,
          content: content,
        ),
        theme,
        style,
      ),
    );
  }
}

/// One section of a [CamoAccordionGroup], identified by [key].
@immutable
class CamoAccordionItem<K> {
  /// Creates an item.
  const CamoAccordionItem({
    required this.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.enabled = true,
    required this.child,
  });

  /// Identifies the section in the open set.
  final K key;

  /// The header's title.
  final String title;

  /// A line under the title.
  final String? subtitle;

  /// An icon before the title.
  final Widget? leading;

  /// `false` disables it.
  final bool enabled;

  /// The content.
  final Widget child;
}

/// Accordion sections with the list dividers (`CamoListItemTheme.dividers`) between them. [expanded] is the
/// set of open keys (controlled). With [singleExpand], opening one section closes the others (an FAQ).
class CamoAccordionGroup<K> extends StatelessWidget {
  /// Creates a group.
  const CamoAccordionGroup({
    super.key,
    required this.expanded,
    required this.onExpandedChanged,
    required this.items,
    this.singleExpand = false,
  });

  /// The open sections' keys.
  final Set<K> expanded;

  /// Called with the new open set.
  final ValueChanged<Set<K>> onExpandedChanged;

  /// The sections.
  final List<CamoAccordionItem<K>> items;

  /// Opening one closes the others.
  final bool singleExpand;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoAccordionGroup');
    final theme = Camouflage.themeOf(context, component: 'CamoAccordionGroup');
    final list = skin.listItem.defaults(theme).merge(theme.components.listItem);
    final style = skin.accordion
        .defaults(theme)
        .merge(theme.components.accordion);
    // An `inset` divider starts where the header's text does (headers have no leading slot to clear).
    return dividedColumn(
      context,
      [
        for (final item in items)
          CamoAccordion(
            key: ValueKey(item.key),
            title: item.title,
            subtitle: item.subtitle,
            leading: item.leading,
            enabled: item.enabled,
            expanded: expanded.contains(item.key),
            onExpansionChanged: (open) => onExpandedChanged(
              !open
                  ? ({...expanded}..remove(item.key))
                  : singleExpand
                  ? {item.key}
                  : {...expanded, item.key},
            ),
            child: item.child,
          ),
      ],
      list.dividers,
      style.headerPadding.start,
    );
  }
}
