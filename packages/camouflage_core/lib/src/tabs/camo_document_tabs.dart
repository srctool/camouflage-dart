import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../menu/camo_menu_anchor.dart';
import '../provider/camouflage.dart';
import '../skin/positions.dart';
import '../tooltip/camo_tooltip.dart';
import '../theme/roles.dart';
import 'camo_document_tabs_model.dart';
import 'camo_tabs.dart';

const _titleMaxWidth = 180.0;
const _trailingSize = 18.0;
const _dotSize = 8.0;
const _closeIconSize = 12.0;

/// Editor-style tabs for open documents: a close button on hover and on the selected tab (a dot while the
/// document is modified), middle-click to close, drag to reorder with a mouse or Alt+Left and Alt+Right on a
/// focused tab, pinned tabs at the start, and a row that scrolls with a "show all tabs" menu (searchable by
/// typing) when the tabs don't fit.
///
/// [documents] and [selected] (a document id) are the app's; so is closing: [onClose] says the user asked, and
/// the app removes the document and picks the next selection. The order and pins live in [state].
/// [onContextMenu] returns the entries of a tab's right-click menu ("Close others", "Pin"). Ctrl+W is the app's
/// key. Screen readers get the tab-list semantics of `CamoTabs` plus Close, Move earlier, Move later and Pin
/// actions on each tab, and hear "modified" and "pinned" in its value.
///
/// Built from the skin's tab bar (every skin draws it), so it needs no renderer of its own. A touch drag scrolls
/// the row; reorder on touch is through the screen reader actions or the keyboard.
class CamoDocumentTabs extends StatefulWidget {
  /// Creates the tabs.
  const CamoDocumentTabs({
    super.key,
    required this.documents,
    required this.selected,
    required this.onSelect,
    required this.onClose,
    required this.state,
    this.onContextMenu,
    this.appearance,
  });

  /// The open documents, in any order: [state] orders them.
  final List<CamoDocument> documents;

  /// The selected document's id.
  final Object selected;

  /// Called with the id of the tab the user chose.
  final ValueChanged<Object> onSelect;

  /// Called with the id of the tab the user asked to close; the app removes it.
  final ValueChanged<Object> onClose;

  /// The order and the pinned tabs.
  final CamoDocumentTabsState state;

  /// The entries of a tab's right-click menu.
  final List<CamoMenuEntry> Function(CamoDocument document)? onContextMenu;

  /// `null` uses the skin's default tab appearance.
  final Appearance? appearance;

  @override
  State<CamoDocumentTabs> createState() => _CamoDocumentTabsState();
}

class _CamoDocumentTabsState extends State<CamoDocumentTabs> {
  final _keys = <Object, GlobalKey>{};
  Object? _dragId;
  double _dx = 0;
  var _overflow = false;

  List<Object> get _ids => [for (final d in widget.documents) d.id];

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_changed);
    _syncAfterFrame();
  }

  @override
  void didUpdateWidget(CamoDocumentTabs old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      old.state.removeListener(_changed);
      widget.state.addListener(_changed);
    }
    _syncAfterFrame();
  }

  @override
  void dispose() {
    widget.state.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _syncAfterFrame() {
    final ids = _ids;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.state.sync(ids);
    });
  }

  GlobalKey _key(Object id) => _keys.putIfAbsent(id, GlobalKey.new);

  // Swaps the dragged tab with the neighbor it has passed the middle of.
  void _drag(Object id, double delta, bool rtl) {
    _dx += delta;
    final order = widget.state.order;
    final at = order.indexOf(id);
    final right = rtl ? -1 : 1;
    final moveRight = _dx > 0;
    final step = moveRight ? right : -right;
    final own = _box(id);
    final neighborId = at + step >= 0 && at + step < order.length
        ? order[at + step]
        : null;
    final neighbor = neighborId == null ? null : _box(neighborId);
    if (own != null && neighbor != null) {
      final center = own.center.dx + _dx;
      final middle = neighbor.center.dx;
      if (moveRight ? center > middle : center < middle) {
        widget.state.move(id, at + step);
        if (widget.state.order.indexOf(id) != at) {
          _dx -= (moveRight ? 1 : -1) * neighbor.width;
        }
      }
    }
    setState(() {});
  }

  Rect? _box(Object id) {
    final box = _keys[id]?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final byId = {for (final d in widget.documents) d.id: d};
    final ordered = [for (final id in widget.state.sorted(_ids)) ?byId[id]];
    final selectedIndex = ordered.indexWhere((d) => d.id == widget.selected);
    _keys.removeWhere((id, _) => !byId.containsKey(id));
    return Row(
      children: [
        Expanded(
          child: CamoTabsContainer(
            selectedIndex: selectedIndex,
            scrollable: true,
            appearance: widget.appearance,
            onOverflowChanged: (value) {
              if (value != _overflow) setState(() => _overflow = value);
            },
            children: [
              for (var i = 0; i < ordered.length; i++)
                _tab(ordered[i], i, ordered.length, rtl),
            ],
          ),
        ),
        if (_overflow) _AllTabsMenu(ordered, widget.selected, widget.onSelect),
      ],
    );
  }

  Widget _tab(CamoDocument doc, int index, int count, bool rtl) {
    final state = widget.state;
    final pinned = state.isPinned(doc.id);
    final order = state.order;
    final at = order.indexOf(doc.id);
    final firstOfGroup = pinned ? 0 : state.pinned.length;
    final lastOfGroup = pinned ? state.pinned.length - 1 : order.length - 1;
    final dragging = _dragId == doc.id;
    final value = [
      if (doc.modified) 'modified',
      if (pinned) 'pinned',
    ].join(', ');
    Widget tab = CamoTabItem<Object>(
      tab: CamoTab(doc.id, label: doc.title),
      selected: doc.id == widget.selected,
      onPressed: () => widget.onSelect(doc.id),
      position: CamoItemPosition(index, count),
      semanticsValue: value.isEmpty ? null : value,
      customSemanticsActions: {
        if (doc.closable)
          const CustomSemanticsAction(label: 'Close'): () =>
              widget.onClose(doc.id),
        if (at > firstOfGroup)
          const CustomSemanticsAction(label: 'Move earlier'): () =>
              state.moveBy(doc.id, -1),
        if (at >= firstOfGroup && at < lastOfGroup)
          const CustomSemanticsAction(label: 'Move later'): () =>
              state.moveBy(doc.id, 1),
        if (pinned)
          const CustomSemanticsAction(label: 'Unpin'): () => state.unpin(doc.id)
        else
          const CustomSemanticsAction(label: 'Pin'): () => state.pin(doc.id),
      },
      child: _TabContent(
        doc: doc,
        pinned: pinned,
        selected: doc.id == widget.selected,
        onClose: () => widget.onClose(doc.id),
      ),
    );
    tab = Focus(
      includeSemantics: false,
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        final alt = HardwareKeyboard.instance.isAltPressed;
        final left = event.logicalKey == LogicalKeyboardKey.arrowLeft;
        final moves =
            event is! KeyUpEvent &&
            alt &&
            (left || event.logicalKey == LogicalKeyboardKey.arrowRight);
        if (!moves) return KeyEventResult.ignored;
        state.moveBy(doc.id, left != rtl ? -1 : 1);
        return KeyEventResult.handled;
      },
      child: tab,
    );
    tab = Listener(
      onPointerDown: (event) {
        if (doc.closable && event.buttons == kMiddleMouseButton) {
          widget.onClose(doc.id);
        }
      },
      child: GestureDetector(
        excludeFromSemantics: true,
        supportedDevices: const {
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
        },
        onHorizontalDragStart: (_) => setState(() {
          _dragId = doc.id;
          _dx = 0;
        }),
        onHorizontalDragUpdate: (d) => _drag(doc.id, d.delta.dx, rtl),
        onHorizontalDragEnd: (_) => setState(() {
          _dragId = null;
          _dx = 0;
        }),
        onHorizontalDragCancel: () => setState(() {
          _dragId = null;
          _dx = 0;
        }),
        child: tab,
      ),
    );
    // Always wrapped, so starting a drag doesn't rebuild the tab under the pointer.
    tab = Transform.translate(
      offset: Offset(dragging ? _dx : 0, 0),
      child: tab,
    );
    final menu = widget.onContextMenu;
    final Widget framed = menu == null
        ? tab
        : CamoContextMenuArea(items: menu(doc), child: tab);
    return KeyedSubtree(key: _key(doc.id), child: framed);
  }
}

class _TabContent extends StatefulWidget {
  const _TabContent({
    required this.doc,
    required this.pinned,
    required this.selected,
    required this.onClose,
  });

  final CamoDocument doc;
  final bool pinned;
  final bool selected;
  final VoidCallback onClose;

  @override
  State<_TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<_TabContent> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final style = DefaultTextStyle.of(context).style;
    final color = style.color ?? const Color(0xFF000000);
    final showClose =
        doc.closable &&
        !widget.pinned &&
        (_hovered || (widget.selected && !doc.modified));
    final Widget trailing;
    if (showClose) {
      trailing = _CloseButton(onPressed: widget.onClose);
    } else if (doc.modified) {
      trailing = _Mark(
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );
    } else if (widget.pinned) {
      trailing = _Mark(
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      trailing = const SizedBox.square(dimension: _trailingSize);
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CamoTooltip(
        message: doc.title,
        anchorLabel: doc.title,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            ?doc.icon,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _titleMaxWidth),
              child: Text(
                doc.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: _trailingSize,
      child: Center(
        child: SizedBox.square(dimension: _dotSize, child: child),
      ),
    ),
  );
}

// The small close button: reached through the tab's "Close" action, never a Tab stop of its own.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDocumentTabs');
    final theme = Camouflage.themeOf(context, component: 'CamoDocumentTabs');
    final icon = skin.chip
        .defaults(theme)
        .merge(theme.components.chip)
        .removeIcon;
    return ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: _trailingSize,
          child: Center(child: CamoIcon(icon, size: _closeIconSize)),
        ),
      ),
    );
  }
}

class _AllTabsMenu extends StatelessWidget {
  const _AllTabsMenu(this.ordered, this.selected, this.onSelect);

  final List<CamoDocument> ordered;
  final Object selected;
  final ValueChanged<Object> onSelect;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDocumentTabs');
    final theme = Camouflage.themeOf(context, component: 'CamoDocumentTabs');
    final chevron = skin.splitButton
        .defaults(theme)
        .merge(theme.components.splitButton)
        .arrowIcon;
    // The selected document first, as a list of what is open.
    final items = [
      ...ordered.where((d) => d.id == selected),
      ...ordered.where((d) => d.id != selected),
    ];
    return CamoMenuAnchor(
      speedSearch: true,
      items: [
        for (final doc in items)
          CamoMenuItem(
            text: doc.title,
            onPressed: () => onSelect(doc.id),
            trailingText: doc.modified ? 'modified' : null,
          ),
      ],
      builder: (context, open) => CamoIconButton(
        icon: CamoIcon(chevron),
        semanticLabel: 'Show all tabs',
        onPressed: open,
        appearance: Appearance.ghost,
        tooltip: 'All tabs',
      ),
    );
  }
}
