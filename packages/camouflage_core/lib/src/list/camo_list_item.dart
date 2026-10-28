import 'package:flutter/widgets.dart';

import '../avatar/camo_avatar.dart' show avatarInRow;
import '../divider/camo_divider.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_row_toggle.dart';

/// The lines a list section draws between its rows.
enum ListDividers {
  /// No lines.
  none,

  /// Edge to edge.
  full,

  /// Starting after the leading slot.
  inset,
}

/// Every color a list row and section use.
@immutable
class ListItemColors {
  /// Creates ListItemColors.
  const ListItemColors({
    required this.headline,
    required this.supporting,
    required this.overline,
    required this.icon,
    required this.selectedContainer,
    required this.sectionTitle,
    required this.sectionFooter,
  });

  /// The headline.
  final Color headline;

  /// The supporting text.
  final Color supporting;

  /// The overline.
  final Color overline;

  /// Leading and trailing icons.
  final Color icon;

  /// A selected row's fill.
  final Color selectedContainer;

  /// A section's title.
  final Color sectionTitle;

  /// A section's footer.
  final Color sectionFooter;

  @override
  bool operator ==(Object other) =>
      other is ListItemColors &&
      other.headline == headline &&
      other.supporting == supporting &&
      other.overline == overline &&
      other.icon == icon &&
      other.selectedContainer == selectedContainer &&
      other.sectionTitle == sectionTitle &&
      other.sectionFooter == sectionFooter;

  @override
  int get hashCode => Object.hash(
    headline,
    supporting,
    overline,
    icon,
    selectedContainer,
    sectionTitle,
    sectionFooter,
  );
}

/// Overrides for list rows and sections; `null` keeps the skin's default.
@immutable
class CamoListItemTheme {
  /// Creates CamoListItemTheme.
  const CamoListItemTheme({
    this.minHeightOneLine,
    this.minHeightTwoLines,
    this.minHeightThreeLines,
    this.contentPadding,
    this.leadingGap,
    this.trailingGap,
    this.headlineStyle,
    this.supportingStyle,
    this.overlineStyle,
    this.iconSize,
    this.sectionShape,
    this.sectionTitleStyle,
    this.sectionFooterStyle,
    this.dividers,
    this.dividerInsetStart,
    this.colors,
  });

  /// A one-line row's height.
  final double? minHeightOneLine;

  /// A two-line row's height.
  final double? minHeightTwoLines;

  /// A three-line row's height.
  final double? minHeightThreeLines;

  /// A row's padding.
  final EdgeInsetsDirectional? contentPadding;

  /// Between the leading slot and the text.
  final double? leadingGap;

  /// Between the text and the trailing slot.
  final double? trailingGap;

  /// The headline.
  final TextStyle? headlineStyle;

  /// The supporting text.
  final TextStyle? supportingStyle;

  /// The overline.
  final TextStyle? overlineStyle;

  /// The ambient icon size for leading and trailing icons.
  final double? iconSize;

  /// A section's corners (inset grouped sections).
  final BorderRadius? sectionShape;

  /// A section's title.
  final TextStyle? sectionTitleStyle;

  /// A section's footer.
  final TextStyle? sectionFooterStyle;

  /// The lines a section draws between its rows.
  final ListDividers? dividers;

  /// Where an `inset` divider starts: after the padding, a leading icon and the gap.
  final double? dividerInsetStart;

  /// Every color it uses.
  final ListItemColors? colors;

  /// A copy with the given fields replaced.
  CamoListItemTheme copyWith({
    double? minHeightOneLine,
    double? minHeightTwoLines,
    double? minHeightThreeLines,
    EdgeInsetsDirectional? contentPadding,
    double? leadingGap,
    double? trailingGap,
    TextStyle? headlineStyle,
    TextStyle? supportingStyle,
    TextStyle? overlineStyle,
    double? iconSize,
    BorderRadius? sectionShape,
    TextStyle? sectionTitleStyle,
    TextStyle? sectionFooterStyle,
    ListDividers? dividers,
    double? dividerInsetStart,
    ListItemColors? colors,
  }) => CamoListItemTheme(
    minHeightOneLine: minHeightOneLine ?? this.minHeightOneLine,
    minHeightTwoLines: minHeightTwoLines ?? this.minHeightTwoLines,
    minHeightThreeLines: minHeightThreeLines ?? this.minHeightThreeLines,
    contentPadding: contentPadding ?? this.contentPadding,
    leadingGap: leadingGap ?? this.leadingGap,
    trailingGap: trailingGap ?? this.trailingGap,
    headlineStyle: headlineStyle ?? this.headlineStyle,
    supportingStyle: supportingStyle ?? this.supportingStyle,
    overlineStyle: overlineStyle ?? this.overlineStyle,
    iconSize: iconSize ?? this.iconSize,
    sectionShape: sectionShape ?? this.sectionShape,
    sectionTitleStyle: sectionTitleStyle ?? this.sectionTitleStyle,
    sectionFooterStyle: sectionFooterStyle ?? this.sectionFooterStyle,
    dividers: dividers ?? this.dividers,
    dividerInsetStart: dividerInsetStart ?? this.dividerInsetStart,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoListItemTheme &&
      other.minHeightOneLine == minHeightOneLine &&
      other.minHeightTwoLines == minHeightTwoLines &&
      other.minHeightThreeLines == minHeightThreeLines &&
      other.contentPadding == contentPadding &&
      other.leadingGap == leadingGap &&
      other.trailingGap == trailingGap &&
      other.headlineStyle == headlineStyle &&
      other.supportingStyle == supportingStyle &&
      other.overlineStyle == overlineStyle &&
      other.iconSize == iconSize &&
      other.sectionShape == sectionShape &&
      other.sectionTitleStyle == sectionTitleStyle &&
      other.sectionFooterStyle == sectionFooterStyle &&
      other.dividers == dividers &&
      other.dividerInsetStart == dividerInsetStart &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    minHeightOneLine,
    minHeightTwoLines,
    minHeightThreeLines,
    contentPadding,
    leadingGap,
    trailingGap,
    headlineStyle,
    supportingStyle,
    overlineStyle,
    iconSize,
    sectionShape,
    sectionTitleStyle,
    sectionFooterStyle,
    dividers,
    dividerInsetStart,
    colors,
  );
}

/// The resolved list style: every field set.
@immutable
class CamoListItemStyle {
  /// Creates CamoListItemStyle.
  const CamoListItemStyle({
    required this.minHeightOneLine,
    required this.minHeightTwoLines,
    required this.minHeightThreeLines,
    required this.contentPadding,
    required this.leadingGap,
    required this.trailingGap,
    required this.headlineStyle,
    required this.supportingStyle,
    required this.overlineStyle,
    required this.iconSize,
    required this.sectionShape,
    required this.sectionTitleStyle,
    required this.sectionFooterStyle,
    required this.dividers,
    required this.dividerInsetStart,
    required this.colors,
  });

  /// A one-line row's height.
  final double minHeightOneLine;

  /// A two-line row's height.
  final double minHeightTwoLines;

  /// A three-line row's height.
  final double minHeightThreeLines;

  /// A row's padding.
  final EdgeInsetsDirectional contentPadding;

  /// Between the leading slot and the text.
  final double leadingGap;

  /// Between the text and the trailing slot.
  final double trailingGap;

  /// The headline.
  final TextStyle headlineStyle;

  /// The supporting text.
  final TextStyle supportingStyle;

  /// The overline.
  final TextStyle overlineStyle;

  /// The ambient icon size for leading and trailing icons.
  final double iconSize;

  /// A section's corners (inset grouped sections).
  final BorderRadius sectionShape;

  /// A section's title.
  final TextStyle sectionTitleStyle;

  /// A section's footer.
  final TextStyle sectionFooterStyle;

  /// The lines a section draws between its rows.
  final ListDividers dividers;

  /// Where an `inset` divider starts: after the padding, a leading icon and the gap.
  final double dividerInsetStart;

  /// Every color it uses.
  final ListItemColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoListItemStyle merge(CamoListItemTheme? o) => o == null
      ? this
      : CamoListItemStyle(
          minHeightOneLine: o.minHeightOneLine ?? minHeightOneLine,
          minHeightTwoLines: o.minHeightTwoLines ?? minHeightTwoLines,
          minHeightThreeLines: o.minHeightThreeLines ?? minHeightThreeLines,
          contentPadding: o.contentPadding ?? contentPadding,
          leadingGap: o.leadingGap ?? leadingGap,
          trailingGap: o.trailingGap ?? trailingGap,
          headlineStyle: o.headlineStyle ?? headlineStyle,
          supportingStyle: o.supportingStyle ?? supportingStyle,
          overlineStyle: o.overlineStyle ?? overlineStyle,
          iconSize: o.iconSize ?? iconSize,
          sectionShape: o.sectionShape ?? sectionShape,
          sectionTitleStyle: o.sectionTitleStyle ?? sectionTitleStyle,
          sectionFooterStyle: o.sectionFooterStyle ?? sectionFooterStyle,
          dividers: o.dividers ?? dividers,
          dividerInsetStart: o.dividerInsetStart ?? dividerInsetStart,
          colors: o.colors ?? colors,
        );

  /// The minimum height of a row with [lines] lines of text.
  double minHeight(int lines) => lines <= 1
      ? minHeightOneLine
      : lines == 2
      ? minHeightTwoLines
      : minHeightThreeLines;
}

/// What a list row renderer draws: [headline] with [overline] above and [supporting] below, in a row at least
/// `style.minHeight(lines)` tall. Center the slots for one or two lines; for three, align them to the top.
@immutable
class ListItemState {
  /// Creates a row state.
  const ListItemState({
    required this.headline,
    required this.supporting,
    required this.overline,
    required this.lines,
    required this.clickable,
    required this.selected,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// The main line.
  final String headline;

  /// The line below, if any.
  final String? supporting;

  /// The small line above, if any.
  final String? overline;

  /// How many lines of text.
  final int lines;

  /// Whether the row has an `onPressed`.
  final bool clickable;

  /// Highlighted (navigation lists, pickers).
  final bool selected;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Press, hover and focus.
  final InteractionState interaction;

  /// For the skin's feedback.
  final CamoInteractionController controller;
}

/// The caller's leading and trailing content (an icon, an avatar, a display-only control, a chevron).
@immutable
class ListItemSlots {
  /// Creates the slots.
  const ListItemSlots({this.leading, this.trailing});

  /// Before the text.
  final Widget? leading;

  /// After the text.
  final Widget? trailing;
}

/// What a list section renderer draws: an optional [title] (a heading) above the rows and [footer] below.
@immutable
class ListSectionState {
  /// Creates a section state.
  const ListSectionState({
    required this.title,
    required this.footer,
    required this.level,
  });

  /// The heading, if any.
  final String? title;

  /// The note below, if any.
  final String? footer;

  /// The section's fill.
  final SurfaceLevel level;
}

/// Draws list rows and sections.
abstract interface class CamoListItemRenderer {
  /// The complete list style for [theme].
  CamoListItemStyle defaults(CamoTheme theme);

  /// Draws one row. Keep the texts you draw in the semantics tree: a tappable row merges them into one
  /// announcement.
  Widget render(
    BuildContext context,
    ListItemState state,
    ListItemSlots slots,
    CamoTheme theme,
    CamoListItemStyle style,
  );

  /// Draws a section around [rows] (laid out by core, with the dividers). Mark the drawn title with
  /// `Semantics(header: true)`.
  Widget section(
    BuildContext context,
    ListSectionState state,
    Widget rows,
    CamoTheme theme,
    CamoListItemStyle style,
  );
}

/// One list row: up to three lines of text with a leading and a trailing slot. With [onPressed] the whole row
/// is one target, announced as one element; without it the row is plain content. For a settings row with a
/// switch, pass the switch display-only (`onChanged: null`) as [trailing] and toggle in [onPressed]: the row
/// is then announced as the switch ("Wi-Fi, switch, on").
class CamoListItem extends StatefulWidget {
  /// Creates a row.
  const CamoListItem({
    super.key,
    required this.headline,
    this.supporting,
    this.overline,
    this.leading,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
    this.focusNode,
  });

  /// The main line.
  final String headline;

  /// The line below.
  final String? supporting;

  /// The small line above.
  final String? overline;

  /// Before the text.
  final Widget? leading;

  /// After the text.
  final Widget? trailing;

  /// Makes the row one target; `null` keeps it plain content.
  final VoidCallback? onPressed;

  /// Highlights the row.
  final bool selected;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoListItem> createState() => _CamoListItemState();
}

class _CamoListItemState extends State<CamoListItem> {
  final _interaction = CamoInteractionController();
  bool _hasToggle = false;

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  // A display-only control came or went: it decides the row's role, after this frame.
  void _onToggle(bool has) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hasToggle != has) setState(() => _hasToggle = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoListItem');
    final theme = Camouflage.themeOf(context, component: 'CamoListItem');
    final style = skin.listItem
        .defaults(theme)
        .merge(theme.components.listItem);
    final onPressed = widget.onPressed;
    final lines =
        1 +
        (widget.supporting != null ? 1 : 0) +
        (widget.overline != null ? 1 : 0);
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.listItem.render(
        context,
        ListItemState(
          headline: widget.headline,
          supporting: widget.supporting,
          overline: widget.overline,
          lines: lines,
          clickable: onPressed != null,
          selected: widget.selected,
          enabled: widget.enabled,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        // The row says the name, so an avatar in the leading slot is decorative.
        ListItemSlots(
          leading: widget.leading == null ? null : avatarInRow(widget.leading!),
          trailing: widget.trailing,
        ),
        theme,
        style,
      ),
    );
    if (onPressed == null) {
      return widget.selected
          ? Semantics(selected: true, child: visual)
          : visual;
    }
    // The merge sits outside the behavior, so the tap action joins the row node.
    return MergeSemantics(
      child: CamoBehavior(
        controller: _interaction,
        enabled: widget.enabled,
        focusNode: widget.focusNode,
        onActivate: onPressed,
        semantics: (child) => Semantics(
          button: !_hasToggle,
          enabled: widget.enabled,
          selected: widget.selected ? true : null,
          child: child,
        ),
        child: RowToggleScope(onToggle: _onToggle, child: visual),
      ),
    );
  }
}

/// Rows grouped under an optional [title] (a heading) with an optional [footer]. The section draws the
/// dividers between its [children] from `CamoListItemTheme.dividers`, never after the last one. [level] is the
/// section's fill; whether it's inset or edge to edge is the skin's choice.
class CamoListSection extends StatelessWidget {
  /// Creates a section.
  const CamoListSection({
    super.key,
    this.title,
    this.footer,
    this.level = SurfaceLevel.surface,
    required this.children,
  });

  /// The heading.
  final String? title;

  /// The note below the rows.
  final String? footer;

  /// The section's fill.
  final SurfaceLevel level;

  /// The rows, usually `CamoListItem`s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoListSection');
    final theme = Camouflage.themeOf(context, component: 'CamoListSection');
    final style = skin.listItem
        .defaults(theme)
        .merge(theme.components.listItem);
    return skin.listItem.section(
      context,
      ListSectionState(title: title, footer: footer, level: level),
      dividedColumn(context, children, style.dividers, style.dividerInsetStart),
      theme,
      style,
    );
  }
}

/// [children] in a column with the skin's divider line between consecutive ones, never after the last: edge to
/// edge for `full`, from [insetStart] for `inset`, none for `none`. Shared by list sections and accordion groups.
Widget dividedColumn(
  BuildContext context,
  List<Widget> children,
  ListDividers dividers,
  double insetStart,
) {
  final skin = Camouflage.skinOf(context, component: 'CamoListSection');
  final theme = Camouflage.themeOf(context, component: 'CamoListSection');
  final line = skin.divider.defaults(theme).merge(theme.components.divider);
  final rows = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    if (i > 0) rows.add(listDivider(dividers, insetStart, line));
    rows.add(children[i]);
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: rows,
  );
}

/// One divider line between rows, per [dividers]; an empty box for `none`.
Widget listDivider(
  ListDividers dividers,
  double insetStart,
  CamoDividerStyle line,
) {
  if (dividers == ListDividers.none) return const SizedBox.shrink();
  return ExcludeSemantics(
    child: Padding(
      padding: EdgeInsetsDirectional.only(
        start: dividers == ListDividers.inset ? insetStart : 0,
      ),
      child: SizedBox(
        height: line.thickness,
        child: ColoredBox(color: line.color),
      ),
    ),
  );
}
