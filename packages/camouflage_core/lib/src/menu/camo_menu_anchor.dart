import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../divider/camo_divider.dart';
import '../overlay/camo_overlay_routes.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import 'camo_menu.dart';

/// One entry in a menu: a [CamoMenuItem], a [CamoMenuDivider], a [CamoMenuGroup] or a [CamoMenuSubmenu].
sealed class CamoMenuEntry {
  const CamoMenuEntry();
}

/// A menu action. Selecting it closes the menu, then runs [onPressed] after the frame (so a dialog it opens
/// isn't stacked over a closing menu). [trailingText] is for a shortcut ("Ctrl+C"); [tone] `error` marks a
/// destructive item. A non-null [checked] makes it checkable: the app flips it in [onPressed].
class CamoMenuItem extends CamoMenuEntry {
  /// Creates an item.
  const CamoMenuItem({
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingText,
    this.tone = Tone.defaultTone,
    this.enabled = true,
    this.checked,
  });

  /// The item's text.
  final String text;

  /// Runs after the menu closes.
  final VoidCallback onPressed;

  /// An icon before the text.
  final Widget? leadingIcon;

  /// A shortcut at the end.
  final String? trailingText;

  /// `error` for destructive items.
  final Tone tone;

  /// `false` disables it.
  final bool enabled;

  /// `null` for a plain item; otherwise whether it's checked.
  final bool? checked;
}

/// A line between entries.
class CamoMenuDivider extends CamoMenuEntry {
  /// Creates a divider.
  const CamoMenuDivider();
}

/// Items that belong together; [exclusive] announces the checked one as a radio item ("Sort by: Newest").
class CamoMenuGroup extends CamoMenuEntry {
  /// Creates a group.
  const CamoMenuGroup({required this.items, this.exclusive = false});

  /// The items.
  final List<CamoMenuItem> items;

  /// Single choice.
  final bool exclusive;
}

/// A row that opens a nested menu of [items] beside it (Reset ▸ Soft, Mixed, Hard). Hovering opens it after a
/// short delay; a tap, Enter and the arrow toward the child (Right, or Left in right-to-left) open it at once.
/// The arrow back and Esc close only the submenu; picking a leaf closes every level. A submenu may hold submenus;
/// more than two levels is a design smell.
class CamoMenuSubmenu extends CamoMenuEntry {
  /// Creates a submenu row.
  const CamoMenuSubmenu({
    required this.text,
    required this.items,
    this.leadingIcon,
    this.enabled = true,
  });

  /// The row's text.
  final String text;

  /// The nested menu's entries.
  final List<CamoMenuEntry> items;

  /// An icon before the text.
  final Widget? leadingIcon;

  /// `false` disables it.
  final bool enabled;
}

/// Opens and closes a [CamoMenuAnchor] from outside it.
class CamoMenuController extends ChangeNotifier {
  _CamoMenuAnchorState? _anchor;

  /// Whether the menu is showing.
  bool get isOpen => _anchor?._popup != null;

  /// Shows the menu.
  void open() => _anchor?._open();

  /// Hides the menu.
  void close() => _anchor?._close();

  void _changed() => notifyListeners();
}

/// A menu attached to the widget [builder] returns (an overflow button, a split button's arrow): [builder] gets
/// `open` for its press. The menu shows [items], or [panel] (custom content in a [CamoMenuPanel], ADR-30),
/// below the anchor (above it near the bottom edge). Opened from the keyboard, the first item takes focus; Up
/// and Down move, Home and End jump, typing jumps to the next item starting with the typed letters, Enter
/// selects, and Esc or an outside tap closes it, returning focus to the anchor.
class CamoMenuAnchor extends StatefulWidget {
  /// Creates an anchor.
  const CamoMenuAnchor({
    super.key,
    this.items = const [],
    this.panel,
    this.controller,
    required this.builder,
  });

  /// The menu's entries.
  final List<CamoMenuEntry> items;

  /// Custom content instead of [items].
  final Widget? panel;

  /// Opens and closes it from outside.
  final CamoMenuController? controller;

  /// The anchor, given the function that opens the menu.
  final Widget Function(BuildContext context, VoidCallback open) builder;

  @override
  State<CamoMenuAnchor> createState() => _CamoMenuAnchorState();
}

class _CamoMenuAnchorState extends State<CamoMenuAnchor> {
  BuildContext? _popup;

  @override
  void initState() {
    super.initState();
    widget.controller?._anchor = this;
  }

  @override
  void didUpdateWidget(CamoMenuAnchor old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      if (old.controller?._anchor == this) old.controller?._anchor = null;
      widget.controller?._anchor = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._anchor == this) widget.controller?._anchor = null;
    super.dispose();
  }

  Future<void> _open() async {
    if (_popup != null) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.controller?._changed(),
    );
    final keyboard = openedByKeyboard(context);
    final picked = await showCamoAnchoredPopup<CamoMenuItem>(
      context,
      builder: (popup) {
        _popup = popup;
        return Semantics(
          role: SemanticsRole.menu,
          explicitChildNodes: true,
          child:
              widget.panel ??
              MenuEntries(
                entries: widget.items,
                focusFirst: keyboard,
                onSelected: (item) => Navigator.of(popup).pop(item),
              ),
        );
      },
    );
    _popup = null;
    widget.controller?._changed();
    runAfterFrame(picked);
  }

  void _close() {
    final popup = _popup;
    if (popup != null && popup.mounted) Navigator.of(popup).pop();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _open);
}

/// Whether the menu [anchor] opens was opened from the keyboard: focus is inside the anchor and focus rings
/// show. A mouse click doesn't focus the anchor, so it doesn't count.
bool openedByKeyboard(BuildContext anchor) {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null ||
      FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {
    return false;
  }
  if (focused == anchor) return true;
  var inside = false;
  focused.visitAncestorElements((e) {
    inside = e == anchor;
    return !inside;
  });
  return inside;
}

/// Runs [item]'s action after the frame in which its menu closed.
void runAfterFrame(CamoMenuItem? item) {
  if (item == null) return;
  SchedulerBinding.instance
    ..addPostFrameCallback((_) => item.onPressed())
    ..ensureVisualUpdate();
}

/// A menu on right-click (desktop, web) or long press (touch) anywhere in [child], opening at the pointer. A
/// long press that opens the menu doesn't also press [child]. Screen readers reach it as the long-press action.
/// On the web, the browser's own context menu is off while the pointer is over the area.
class CamoContextMenuArea extends StatelessWidget {
  /// Creates the area.
  const CamoContextMenuArea({
    super.key,
    required this.items,
    required this.child,
  });

  /// The menu's entries.
  final List<CamoMenuEntry> items;

  /// The content.
  final Widget child;

  Future<void> _open(BuildContext context, Offset global) async {
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final box = context.findRenderObject()! as RenderBox;
    // A screen reader's long press has no position: the area's own corner.
    final at = global == Offset.zero ? box.localToGlobal(Offset.zero) : global;
    final picked = await showCamoAnchoredPopupAt<CamoMenuItem>(
      context,
      overlay.globalToLocal(at) & Size.zero,
      builder: (popup) => Semantics(
        role: SemanticsRole.menu,
        explicitChildNodes: true,
        child: MenuEntries(
          entries: items,
          onSelected: (item) => Navigator.of(popup).pop(item),
        ),
      ),
    );
    runAfterFrame(picked);
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: kIsWeb ? (_) => BrowserContextMenu.disableContextMenu() : null,
    onExit: kIsWeb ? (_) => BrowserContextMenu.enableContextMenu() : null,
    child: GestureDetector(
      onSecondaryTapUp: (d) => _open(context, d.globalPosition),
      onLongPressStart: (d) => _open(context, d.globalPosition),
      child: child,
    ),
  );
}

/// A standard menu row for custom content in a [CamoMenuPanel] (an account switcher with a "Sign out" item):
/// [onSelected] runs on a tap, Enter or Space.
class CamoMenuItemRow extends StatelessWidget {
  /// Creates a row.
  const CamoMenuItemRow({
    super.key,
    required this.item,
    required this.onSelected,
  });

  /// The item.
  final CamoMenuItem item;

  /// Runs when it's picked.
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => _MenuRow(
    item: item,
    kind: item.checked == null ? _RowKind.plain : _RowKind.check,
    reserveCheck: item.checked != null,
    reserveIcon: item.leadingIcon != null,
    onSelected: onSelected,
  );
}

enum _RowKind { plain, check, radio, submenu }

class _Row {
  const _Row(this.item, this.kind, [this.submenu]);

  final CamoMenuItem item;
  final _RowKind kind;
  final CamoMenuSubmenu? submenu;
}

const _typeAheadMillis = 500;
const _submenuOpenDelay = Duration(milliseconds: 250);
const _submenuCloseGrace = Duration(milliseconds: 120);

/// A menu's entries as rows, dividers and groups, at least [minWidth] wide (a select's field width), with the
/// keys: Home and End jump, typed letters find the next item starting with them.
class MenuEntries extends StatefulWidget {
  /// Creates the entries.
  const MenuEntries({
    super.key,
    required this.entries,
    required this.onSelected,
    this.minWidth = 0,
    this.focusFirst = false,
    this.onBack,
  });

  /// The entries.
  final List<CamoMenuEntry> entries;

  /// The picked item; the caller closes the menu.
  final ValueChanged<CamoMenuItem> onSelected;

  /// The narrowest the menu may be.
  final double minWidth;

  /// Focus the first item: the menu was opened from the keyboard (a pointer opening shows no focus ring).
  final bool focusFirst;

  /// Set on a submenu: the arrow back and Esc call it, and the caller closes the submenu.
  final VoidCallback? onBack;

  @override
  State<MenuEntries> createState() => _MenuEntriesState();
}

class _MenuEntriesState extends State<MenuEntries> {
  late List<_Row> _rows;
  late List<FocusNode> _nodes;
  late List<GlobalKey> _rowKeys;
  late List<OverlayPortalController> _portals;
  String _prefix = '';
  DateTime _typed = DateTime.fromMillisecondsSinceEpoch(0);

  // The submenu showing (a row index, -1 for none), whether its first item takes focus, and the hover timing.
  int _open = -1;
  bool _focusChild = false;
  bool _childHovered = false;
  int _hovered = -1;
  Timer? _openTimer;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _rows = _flatten(widget.entries);
    _nodes = [for (final _ in _rows) FocusNode()];
    _rowKeys = [for (final _ in _rows) GlobalKey()];
    _portals = [for (final _ in _rows) OverlayPortalController()];
    if (widget.focusFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final first = _enabled.firstOrNull;
        if (mounted && first != null) _nodes[first].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<int> get _enabled => [
    for (var i = 0; i < _rows.length; i++)
      if (_rows[i].item.enabled) i,
  ];

  int get _focused => _nodes.indexWhere((n) => n.hasFocus);

  bool _canOpen(int at) =>
      at >= 0 &&
      at < _rows.length &&
      _rows[at].submenu != null &&
      _rows[at].item.enabled;

  void _openAt(int at, {required bool focusFirst}) {
    if (!_canOpen(at) || (_open == at && !focusFirst)) return;
    if (_open != -1 && _open != at) _portals[_open].hide();
    setState(() {
      _open = at;
      _focusChild = focusFirst;
    });
    _portals[at].show();
    // Keys (Esc, the arrow back) reach the menu: the row has focus until the child takes it.
    if (!focusFirst) _nodes[at].requestFocus();
  }

  void _closeChild() {
    final at = _open;
    if (at == -1) return;
    _portals[at].hide();
    setState(() => _open = -1);
    // Closed from the keyboard: focus returns to its row.
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      _nodes[at].requestFocus();
    }
  }

  // Hovering a submenu row opens it after a moment; hovering another row closes the open submenu after a short
  // grace, so the pointer can cross a neighbour on its way to the child; it stays while the pointer is over it.
  void _hover(int at, bool hovered) {
    if (!mounted) return;
    if (!hovered) {
      if (_hovered == at) _hovered = -1;
      _openTimer?.cancel();
      return;
    }
    _hovered = at;
    _closeTimer?.cancel();
    _openTimer?.cancel();
    if (_canOpen(at)) {
      if (_open != at) {
        _openTimer = Timer(_submenuOpenDelay, () {
          if (mounted && _hovered == at) _openAt(at, focusFirst: false);
        });
      }
    } else if (_open != -1 && !_childHovered) {
      _closeTimer = Timer(_submenuCloseGrace, () {
        if (mounted && !_childHovered && _hovered != _open) _closeChild();
      });
    }
  }

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final enabled = _enabled;
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final toward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final away = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == toward && _canOpen(_focused)) {
      _openAt(_focused, focusFirst: true);
      return KeyEventResult.handled;
    }
    if ((key == away || key == LogicalKeyboardKey.escape) &&
        widget.onBack != null) {
      widget.onBack!();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape && _open != -1) {
      _closeChild();
      return KeyEventResult.handled;
    }
    int? target;
    if (key == LogicalKeyboardKey.home) {
      target = enabled.firstOrNull;
    } else if (key == LogicalKeyboardKey.end) {
      target = enabled.lastOrNull;
    } else {
      final char = event.character;
      final modifiers = HardwareKeyboard.instance;
      if (char != null &&
          char.trim().isNotEmpty &&
          !modifiers.isControlPressed &&
          !modifiers.isMetaPressed &&
          !modifiers.isAltPressed) {
        final now = DateTime.now();
        _prefix = now.difference(_typed).inMilliseconds > _typeAheadMillis
            ? char
            : _prefix + char;
        _typed = now;
        // A repeated first letter steps through the items starting with it.
        final focused = _focused;
        final from = _prefix.length == 1 ? focused + 1 : math.max(focused, 0);
        final order = [
          ...enabled.where((i) => i >= from),
          ...enabled.where((i) => i < from),
        ];
        target = order
            .where(
              (i) => _rows[i].item.text.toLowerCase().startsWith(
                _prefix.toLowerCase(),
              ),
            )
            .firstOrNull;
      }
    }
    if (target == null) return KeyEventResult.ignored;
    _nodes[target].requestFocus();
    return KeyEventResult.handled;
  }

  // The nested menu, beside its row (end side, flipping to the start side, shifted up near the bottom edge).
  Widget _submenu(BuildContext overlay, int at) {
    final row = _rowKeys[at].currentContext?.findRenderObject();
    final box = Overlay.of(overlay).context.findRenderObject();
    if (row is! RenderBox || box is! RenderBox || !row.attached) {
      return const SizedBox.shrink();
    }
    final anchor = box.globalToLocal(row.localToGlobal(Offset.zero)) & row.size;
    final submenu = _rows[at].submenu!;
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _BesideDelegate(anchor, Directionality.of(overlay)),
        child: MouseRegion(
          onEnter: (_) => _childHovered = true,
          onExit: (_) => _childHovered = false,
          child: CamoMenuPanel(
            child: Semantics(
              role: SemanticsRole.menu,
              explicitChildNodes: true,
              child: MenuEntries(
                entries: submenu.items,
                focusFirst: _focusChild,
                onSelected: widget.onSelected,
                onBack: _closeChild,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoMenuAnchor');
    final theme = Camouflage.themeOf(context, component: 'CamoMenuAnchor');
    final style = skin.menu.defaults(theme).merge(theme.components.menu);
    final reserveCheck = _rows.any((r) => r.item.checked != null);
    final reserveIcon = _rows.any((r) => r.item.leadingIcon != null);
    var index = 0;
    Widget row(CamoMenuItem item) {
      final at = index++;
      final submenu = _rows[at].submenu;
      final line = _MenuRow(
        key: _rowKeys[at],
        item: item,
        kind: _rows[at].kind,
        reserveCheck: reserveCheck,
        reserveIcon: reserveIcon,
        focusNode: _nodes[at],
        onSelected: submenu == null
            ? () => widget.onSelected(item)
            : () => _openAt(at, focusFirst: false),
        onHover: (h) => _hover(at, h),
        submenuOpen: _open == at,
        onCollapse: _closeChild,
      );
      if (submenu == null) return line;
      return OverlayPortal(
        controller: _portals[at],
        overlayChildBuilder: (overlay) => _submenu(overlay, at),
        child: line,
      );
    }

    final divider = Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: const CamoDivider(),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: math.max(style.minWidth, widget.minWidth),
        maxWidth: math.max(style.maxWidth, widget.minWidth),
      ),
      child: IntrinsicWidth(
        child: Focus(
          onKeyEvent: _keys,
          skipTraversal: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in widget.entries)
                  switch (entry) {
                    CamoMenuItem() => row(entry),
                    CamoMenuSubmenu() => row(
                      CamoMenuItem(
                        text: entry.text,
                        onPressed: () {},
                        leadingIcon: entry.leadingIcon,
                        enabled: entry.enabled,
                      ),
                    ),
                    CamoMenuDivider() => divider,
                    CamoMenuGroup() => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [for (final item in entry.items) row(item)],
                    ),
                  },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Beside the anchor on its end side with its top at the anchor's top (a submenu next to its row); the start side
// when it doesn't fit; shifted up near the bottom edge and never past the overlay's edges.
class _BesideDelegate extends SingleChildLayoutDelegate {
  const _BesideDelegate(this.anchor, this.direction);

  final Rect anchor;
  final TextDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size child) {
    final rtl = direction == TextDirection.rtl;
    final atEnd = rtl ? anchor.left - child.width : anchor.right;
    final atStart = rtl ? anchor.right : anchor.left - child.width;
    final endFits = atEnd >= 0 && atEnd + child.width <= size.width;
    final startFits = atStart >= 0 && atStart + child.width <= size.width;
    final x = endFits
        ? atEnd
        : startFits
        ? atStart
        : atEnd.clamp(0, math.max(0, size.width - child.width)).toDouble();
    final y = anchor.top
        .clamp(0, math.max(0, size.height - child.height))
        .toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_BesideDelegate old) =>
      old.anchor != anchor || old.direction != direction;
}

List<_Row> _flatten(List<CamoMenuEntry> entries) => [
  for (final entry in entries)
    ...switch (entry) {
      CamoMenuItem() => [
        _Row(entry, entry.checked == null ? _RowKind.plain : _RowKind.check),
      ],
      CamoMenuSubmenu() => [
        _Row(
          CamoMenuItem(
            text: entry.text,
            onPressed: () {},
            leadingIcon: entry.leadingIcon,
            enabled: entry.enabled,
          ),
          _RowKind.submenu,
          entry,
        ),
      ],
      CamoMenuDivider() => const <_Row>[],
      CamoMenuGroup() => [
        for (final item in entry.items)
          _Row(
            item,
            item.checked == null
                ? _RowKind.plain
                : entry.exclusive
                ? _RowKind.radio
                : _RowKind.check,
          ),
      ],
    },
];

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    super.key,
    required this.item,
    required this.kind,
    required this.reserveCheck,
    required this.reserveIcon,
    required this.onSelected,
    this.focusNode,
    this.onHover,
    this.submenuOpen = false,
    this.onCollapse,
  });

  final CamoMenuItem item;
  final _RowKind kind;
  final bool reserveCheck;
  final bool reserveIcon;
  final VoidCallback onSelected;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onHover;
  final bool submenuOpen;
  final VoidCallback? onCollapse;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  final _interaction = CamoInteractionController();
  bool _wasHovered = false;

  @override
  void initState() {
    super.initState();
    _interaction.addListener(_hovered);
  }

  void _hovered() {
    final hovered = _interaction.value.hovered;
    if (hovered == _wasHovered) return;
    _wasHovered = hovered;
    widget.onHover?.call(hovered);
  }

  @override
  void dispose() {
    _interaction.removeListener(_hovered);
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final item = w.item;
    final skin = Camouflage.skinOf(context, component: 'CamoMenuItemRow');
    final theme = Camouflage.themeOf(context, component: 'CamoMenuItemRow');
    final style = skin.menu.defaults(theme).merge(theme.components.menu);
    final checkable = w.kind == _RowKind.check || w.kind == _RowKind.radio;
    final submenu = w.kind == _RowKind.submenu;
    // The merge sits outside the behavior, so the tap action joins the row node.
    return MergeSemantics(
      child: CamoBehavior(
        controller: _interaction,
        enabled: item.enabled,
        focusNode: w.focusNode,
        onActivate: w.onSelected,
        semantics: (child) => Semantics(
          role: switch (w.kind) {
            _RowKind.plain || _RowKind.submenu => SemanticsRole.menuItem,
            _RowKind.check => SemanticsRole.menuItemCheckbox,
            _RowKind.radio => SemanticsRole.menuItemRadio,
          },
          enabled: item.enabled,
          checked: checkable ? item.checked == true : null,
          inMutuallyExclusiveGroup: w.kind == _RowKind.radio ? true : null,
          expanded: submenu ? w.submenuOpen : null,
          onExpand: submenu && !w.submenuOpen ? w.onSelected : null,
          onCollapse: submenu && w.submenuOpen ? w.onCollapse : null,
          child: child,
        ),
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.menu.item(
            context,
            MenuItemState(
              text: item.text,
              trailingText: item.trailingText,
              tone: item.tone,
              enabled: item.enabled,
              checked: item.checked,
              reserveCheck: w.reserveCheck,
              reserveIcon: w.reserveIcon,
              interaction: _interaction.value,
              controller: _interaction,
              hasSubmenu: submenu,
              submenuOpen: w.submenuOpen,
            ),
            MenuItemSlots(leadingIcon: item.leadingIcon),
            theme,
            style,
          ),
        ),
      ),
    );
  }
}
