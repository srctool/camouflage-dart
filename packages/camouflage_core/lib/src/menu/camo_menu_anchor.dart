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

/// One entry in a menu: a [CamoMenuItem], a [CamoMenuDivider] or a [CamoMenuGroup].
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

enum _RowKind { plain, check, radio }

class _Row {
  const _Row(this.item, this.kind);

  final CamoMenuItem item;
  final _RowKind kind;
}

const _typeAheadMillis = 500;

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
  });

  /// The entries.
  final List<CamoMenuEntry> entries;

  /// The picked item; the caller closes the menu.
  final ValueChanged<CamoMenuItem> onSelected;

  /// The narrowest the menu may be.
  final double minWidth;

  /// Focus the first item: the menu was opened from the keyboard (a pointer opening shows no focus ring).
  final bool focusFirst;

  @override
  State<MenuEntries> createState() => _MenuEntriesState();
}

class _MenuEntriesState extends State<MenuEntries> {
  late List<_Row> _rows;
  late List<FocusNode> _nodes;
  String _prefix = '';
  DateTime _typed = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _rows = _flatten(widget.entries);
    _nodes = [for (final _ in _rows) FocusNode()];
    if (widget.focusFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final first = _enabled.firstOrNull;
        if (mounted && first != null) _nodes[first].requestFocus();
      });
    }
  }

  @override
  void dispose() {
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

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final enabled = _enabled;
    final key = event.logicalKey;
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
      return _MenuRow(
        item: item,
        kind: _rows[at].kind,
        reserveCheck: reserveCheck,
        reserveIcon: reserveIcon,
        focusNode: _nodes[at],
        onSelected: () => widget.onSelected(item),
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

List<_Row> _flatten(List<CamoMenuEntry> entries) => [
  for (final entry in entries)
    ...switch (entry) {
      CamoMenuItem() => [
        _Row(entry, entry.checked == null ? _RowKind.plain : _RowKind.check),
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
    required this.item,
    required this.kind,
    required this.reserveCheck,
    required this.reserveIcon,
    required this.onSelected,
    this.focusNode,
  });

  final CamoMenuItem item;
  final _RowKind kind;
  final bool reserveCheck;
  final bool reserveIcon;
  final VoidCallback onSelected;
  final FocusNode? focusNode;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
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
    final checkable = w.kind != _RowKind.plain;
    // The merge sits outside the behavior, so the tap action joins the row node.
    return MergeSemantics(
      child: CamoBehavior(
        controller: _interaction,
        enabled: item.enabled,
        focusNode: w.focusNode,
        onActivate: w.onSelected,
        semantics: (child) => Semantics(
          role: switch (w.kind) {
            _RowKind.plain => SemanticsRole.menuItem,
            _RowKind.check => SemanticsRole.menuItemCheckbox,
            _RowKind.radio => SemanticsRole.menuItemRadio,
          },
          enabled: item.enabled,
          checked: checkable ? item.checked == true : null,
          inMutuallyExclusiveGroup: w.kind == _RowKind.radio ? true : null,
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
