part of 'camo_tree.dart';

// The result of a speed search over a tree: the nodes to show, the ancestors to open, and what matched where.
class _TreeSearch<T> {
  const _TreeSearch(this.roots, this.open, this.hits);

  final List<CamoTreeNode<T>> roots;
  final Set<Object> open;
  final Map<Object, List<MatchRange>> hits;
}

// Searches [roots]' loaded nodes with [match] (null: no match). With [filter] the result keeps the nodes that
// match and the ancestors of those that do, and opens those ancestors; without it the tree is kept whole and only
// [_TreeSearch.hits] says what matched.
_TreeSearch<T> _searchTree<T>(
  List<CamoTreeNode<T>> roots,
  String Function(T value) label,
  List<MatchRange>? Function(String text) match, {
  required bool filter,
}) {
  final open = <Object>{};
  final hits = <Object, List<MatchRange>>{};
  CamoTreeNode<T>? visit(CamoTreeNode<T> node) {
    final own = match(label(node.value));
    if (own != null) hits[node.id] = own;
    final kept = [
      for (final child in node.children ?? <CamoTreeNode<T>>[]) ?visit(child),
    ];
    final below = kept.isNotEmpty;
    if (below) open.add(node.id);
    if (!filter) return node;
    if (below) {
      return CamoTreeNode<T>(
        id: node.id,
        value: node.value,
        children: kept,
        hasChildren: node.hasChildren,
      );
    }
    return own != null ? node : null;
  }

  return _TreeSearch(
    [for (final r in roots) ?visit(r)],
    filter ? open : const {},
    hits,
  );
}
