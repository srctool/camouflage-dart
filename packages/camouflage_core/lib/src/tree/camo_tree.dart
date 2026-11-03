import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';
import '../icon/camo_icon.dart';

/// Every color a tree uses.
@immutable
class TreeColors {
  /// Creates TreeColors.
  const TreeColors({
    required this.selected,
    required this.hover,
    required this.line,
    required this.text,
    required this.chevron,
  });

  /// A selected node.
  final Color selected;

  /// A hovered node.
  final Color hover;

  /// Guide lines.
  final Color line;

  /// Labels.
  final Color text;

  /// The expand chevron.
  final Color chevron;

  @override
  bool operator ==(Object other) =>
      other is TreeColors &&
      other.selected == selected &&
      other.hover == hover &&
      other.line == line &&
      other.text == text &&
      other.chevron == chevron;

  @override
  int get hashCode => Object.hash(selected, hover, line, text, chevron);
}

/// Overrides for trees. `null` keeps the skin's default.
@immutable
class CamoTreeTheme {
  /// Creates overrides.
  const CamoTreeTheme({
    this.rowHeight,
    this.indent,
    this.showLines,
    this.chevron,
    this.iconSize,
    this.textStyle,
    this.colors,
  });

  /// A node row.
  final double? rowHeight;

  /// Per level.
  final double? indent;

  /// Guide lines at each level.
  final bool? showLines;

  /// Collapsed (points to the end); turns when expanded.
  final IconSource? chevron;

  /// Node icons and the chevron.
  final double? iconSize;

  /// Node labels.
  final TextStyle? textStyle;

  /// Every color it uses.
  final TreeColors? colors;

  /// A copy with the given fields replaced.
  CamoTreeTheme copyWith({
    double? rowHeight,
    double? indent,
    bool? showLines,
    IconSource? chevron,
    double? iconSize,
    TextStyle? textStyle,
    TreeColors? colors,
  }) => CamoTreeTheme(
    rowHeight: rowHeight ?? this.rowHeight,
    indent: indent ?? this.indent,
    showLines: showLines ?? this.showLines,
    chevron: chevron ?? this.chevron,
    iconSize: iconSize ?? this.iconSize,
    textStyle: textStyle ?? this.textStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoTreeTheme &&
      other.rowHeight == rowHeight &&
      other.indent == indent &&
      other.showLines == showLines &&
      other.chevron == chevron &&
      other.iconSize == iconSize &&
      other.textStyle == textStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    rowHeight,
    indent,
    showLines,
    chevron,
    iconSize,
    textStyle,
    colors,
  );
}

/// The resolved tree style: every field set.
@immutable
class CamoTreeStyle {
  /// Creates a style.
  const CamoTreeStyle({
    required this.rowHeight,
    required this.indent,
    required this.showLines,
    required this.chevron,
    required this.iconSize,
    required this.textStyle,
    required this.colors,
  });

  /// A node row.
  final double rowHeight;

  /// Per level.
  final double indent;

  /// Guide lines at each level.
  final bool showLines;

  /// Collapsed (points to the end); turns when expanded.
  final IconSource chevron;

  /// Node icons and the chevron.
  final double iconSize;

  /// Node labels.
  final TextStyle textStyle;

  /// Every color it uses.
  final TreeColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoTreeStyle merge(CamoTreeTheme? o) => o == null
      ? this
      : CamoTreeStyle(
          rowHeight: o.rowHeight ?? rowHeight,
          indent: o.indent ?? indent,
          showLines: o.showLines ?? showLines,
          chevron: o.chevron ?? chevron,
          iconSize: o.iconSize ?? iconSize,
          textStyle: o.textStyle ?? textStyle,
          colors: o.colors ?? colors,
        );
}

/// A node of a [CamoTree]. [children] is `null` for a leaf, a list for loaded children; [hasChildren] `true` with
/// null [children] means they are not loaded yet (the tree asks for them when the node expands).
@immutable
class CamoTreeNode<T> {
  /// Creates a node.
  const CamoTreeNode({
    required this.id,
    required this.value,
    this.children,
    bool? hasChildren,
  }) : hasChildren = hasChildren ?? children != null;

  /// Identifies the node.
  final Object id;

  /// What the node stands for.
  final T value;

  /// Loaded children, or `null`.
  final List<CamoTreeNode<T>>? children;

  /// Whether it can be expanded.
  final bool hasChildren;
}

/// What a node row draws: its [level] (0 for a root), and whether it is [expanded], [loading] its children or
/// [selected].
@immutable
class TreeNodeState {
  /// Creates the state.
  const TreeNodeState({
    required this.level,
    required this.expanded,
    required this.hasChildren,
    required this.loading,
    required this.selected,
    required this.interaction,
    required this.controller,
  });

  /// The depth, 0 for a root.
  final int level;

  /// Whether its children show.
  final bool expanded;

  /// Whether it can be expanded.
  final bool hasChildren;

  /// Whether its children are being loaded.
  final bool loading;

  /// Whether it is selected.
  final bool selected;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// A node's content: its [icon] and [label], and [wrapToggle] for the chevron's hit area.
@immutable
class TreeNodeSlots {
  /// Creates the slots.
  const TreeNodeSlots({
    this.icon,
    required this.label,
    required this.wrapToggle,
  });

  /// The node's icon.
  final Widget? icon;

  /// The label.
  final String label;

  /// Wraps the chevron so a press on it expands or collapses the node.
  final Widget Function(Widget chevron) wrapToggle;
}

/// Draws one node row.
abstract interface class CamoTreeRenderer {
  /// The complete tree style for [theme].
  CamoTreeStyle defaults(CamoTheme theme);

  /// Draws one node, indented by its level.
  Widget renderNode(
    BuildContext context,
    TreeNodeState state,
    TreeNodeSlots slots,
    CamoTheme theme,
    CamoTreeStyle style,
  );
}

class _Visible<T> {
  const _Visible(this.node, this.level, this.parent);

  final CamoTreeNode<T> node;
  final int level;
  final int parent;
}

List<_Visible<T>> _flatten<T>(
  List<CamoTreeNode<T>> roots,
  Set<Object> expanded,
) {
  final out = <_Visible<T>>[];
  void visit(List<CamoTreeNode<T>> nodes, int level, int parent) {
    for (final node in nodes) {
      final at = out.length;
      out.add(_Visible(node, level, parent));
      if (expanded.contains(node.id) && node.children != null) {
        visit(node.children!, level + 1, at);
      }
    }
  }

  visit(roots, 0, -1);
  return out;
}

/// Hierarchical data you can expand and collapse. The app owns [expanded] and [selected] (sets of node ids). A
/// press selects (with [multiSelect], toggles); the chevron expands. A node whose children aren't loaded asks for
/// them once through [onLoadChildren] when it expands. Up and Down move, Right expands or enters the first child,
/// Left collapses or goes to the parent, Home and End jump, Enter or Space selects. [semanticLabel] names the
/// tree. Give the tree a height: its rows are lazy.
class CamoTree<T> extends StatefulWidget {
  /// Creates a tree.
  const CamoTree({
    super.key,
    required this.roots,
    required this.expanded,
    required this.onExpandedChanged,
    required this.selected,
    required this.onSelectedChanged,
    required this.label,
    required this.semanticLabel,
    this.multiSelect = false,
    this.onLoadChildren,
    this.icon,
  });

  /// The top-level nodes.
  final List<CamoTreeNode<T>> roots;

  /// The ids of the expanded nodes.
  final Set<Object> expanded;

  /// Called with the new expanded set.
  final ValueChanged<Set<Object>> onExpandedChanged;

  /// The ids of the selected nodes.
  final Set<Object> selected;

  /// Called with the new selection.
  final ValueChanged<Set<Object>> onSelectedChanged;

  /// A node's text.
  final String Function(T value) label;

  /// Names the tree.
  final String semanticLabel;

  /// Whether several nodes can be selected.
  final bool multiSelect;

  /// Called once when a node with unloaded children expands.
  final ValueChanged<CamoTreeNode<T>>? onLoadChildren;

  /// A node's icon, given whether it is expanded.
  final Widget? Function(T value, bool expanded)? icon;

  @override
  State<CamoTree<T>> createState() => _CamoTreeState<T>();
}

class _CamoTreeState<T> extends State<CamoTree<T>> {
  final _asked = <Object>{};

  void _setExpanded(Object id, bool open) => widget.onExpandedChanged(
    open ? {...widget.expanded, id} : ({...widget.expanded}..remove(id)),
  );

  void _select(Object id) {
    final selected = widget.selected;
    widget.onSelectedChanged(
      widget.multiSelect
          ? (selected.contains(id)
                ? ({...selected}..remove(id))
                : {...selected, id})
          : {id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _flatten(widget.roots, widget.expanded);
    // Unloaded children are asked for once, after the frame in which their node expanded.
    for (final v in visible) {
      final node = v.node;
      if (node.hasChildren &&
          node.children == null &&
          widget.expanded.contains(node.id) &&
          _asked.add(node.id)) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onLoadChildren?.call(node),
        );
      }
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: CamoRovingFocus(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: visible.length,
          itemBuilder: (context, i) => _NodeRow<T>(
            key: ValueKey(visible[i].node.id),
            tree: widget,
            visible: visible,
            index: i,
            setExpanded: _setExpanded,
            select: _select,
          ),
        ),
      ),
    );
  }
}

class _NodeRow<T> extends StatefulWidget {
  const _NodeRow({
    super.key,
    required this.tree,
    required this.visible,
    required this.index,
    required this.setExpanded,
    required this.select,
  });

  final CamoTree<T> tree;
  final List<_Visible<T>> visible;
  final int index;
  final void Function(Object id, bool open) setExpanded;
  final void Function(Object id) select;

  @override
  State<_NodeRow<T>> createState() => _NodeRowState<T>();
}

class _NodeRowState<T> extends State<_NodeRow<T>> {
  final _interaction = CamoInteractionController();
  final _toggle = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    _toggle.dispose();
    super.dispose();
  }

  KeyEventResult _key(KeyEvent event, bool Function(int step) move) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final v = widget.visible[widget.index];
    final node = v.node;
    final open = widget.tree.expanded.contains(node.id);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final into = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final out = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == into) {
      if (node.hasChildren && !open) {
        widget.setExpanded(node.id, true);
      } else if (node.hasChildren) {
        move(1);
      }
    } else if (key == out) {
      if (node.hasChildren && open) {
        widget.setExpanded(node.id, false);
      } else if (v.parent >= 0) {
        move(v.parent - widget.index);
      }
    } else if (key == LogicalKeyboardKey.home) {
      move(-widget.index);
    } else if (key == LogicalKeyboardKey.end) {
      move(widget.visible.length - 1 - widget.index);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      widget.select(node.id);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTree');
    final theme = Camouflage.themeOf(context, component: 'CamoTree');
    final style = skin.tree.defaults(theme).merge(theme.components.tree);
    final tree = widget.tree;
    final v = widget.visible[widget.index];
    final node = v.node;
    final open = tree.expanded.contains(node.id);
    final loading = node.hasChildren && node.children == null && open;
    final isSelected = tree.selected.contains(node.id);
    final expandable = node.hasChildren;
    return CamoRovingFocusItem(
      index: widget.index,
      enabled: true,
      selected: isSelected,
      onSelect: () {},
      onKey: _key,
      builder: (context, node0) => CamoBehavior(
        controller: _interaction,
        enabled: true,
        focusNode: node0,
        onActivate: () => widget.select(node.id),
        semantics: (child) => Semantics(
          selected: isSelected,
          expanded: expandable ? open : null,
          label: tree.label(node.value),
          value: expandable ? (open ? 'Expanded' : 'Collapsed') : null,
          onExpand: expandable && !open
              ? () => widget.setExpanded(node.id, true)
              : null,
          onCollapse: expandable && open
              ? () => widget.setExpanded(node.id, false)
              : null,
          excludeSemantics: true,
          child: child,
        ),
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.tree.renderNode(
            context,
            TreeNodeState(
              level: v.level,
              expanded: open,
              hasChildren: expandable,
              loading: loading,
              selected: isSelected,
              interaction: _interaction.value,
              controller: _interaction,
            ),
            TreeNodeSlots(
              icon: tree.icon?.call(node.value, open),
              label: tree.label(node.value),
              wrapToggle: (chevron) => expandable
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.setExpanded(node.id, !open),
                      child: chevron,
                    )
                  : chevron,
            ),
            theme,
            style,
          ),
        ),
      ),
    );
  }
}
