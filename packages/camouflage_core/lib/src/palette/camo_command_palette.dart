import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../menu/camo_menu_anchor.dart';
import '../overlay/camo_overlay_routes.dart';
import '../provider/camouflage.dart';
import '../search/camo_search_field.dart';
import '../speed_search/camo_matcher.dart';
import 'camo_command_palette_model.dart';

/// Overrides for the command palette. `null` keeps the default.
@immutable
class CamoCommandPaletteTheme {
  /// Creates overrides.
  const CamoCommandPaletteTheme({
    this.placeholder,
    this.noResults,
    this.loading,
    this.maxWidth,
    this.maxHeight,
  });

  /// The field's placeholder.
  final String? placeholder;

  /// The row shown when nothing matches.
  final String? noResults;

  /// The row a slow source shows.
  final String? loading;

  /// The widest the palette gets.
  final double? maxWidth;

  /// The tallest the results get.
  final double? maxHeight;

  @override
  bool operator ==(Object other) =>
      other is CamoCommandPaletteTheme &&
      other.placeholder == placeholder &&
      other.noResults == noResults &&
      other.loading == loading &&
      other.maxWidth == maxWidth &&
      other.maxHeight == maxHeight;

  @override
  int get hashCode =>
      Object.hash(placeholder, noResults, loading, maxWidth, maxHeight);
}

const _defaultMaxWidth = 640.0;
const _defaultMaxHeight = 400.0;
const _edgeMargin = 16.0;
const _topFraction = 8;
const _headerHeight = 28.0;

/// "Find action" and "Search everywhere": a popup at the top of the window with one field and results grouped by
/// source. Put it once under your `Navigator`; show it with [CamoCommandPaletteState.show] from your own
/// shortcut.
///
/// Typing runs every source's search (the answer to an older query is dropped); each group appears as it answers
/// and a slow one shows a loading row. Titles are highlighted with the source's match kind. With nothing typed
/// each group lists what was run before first. Focus stays in the field: Up and Down move the active row through
/// every group, Tab and Shift+Tab jump between groups, Enter runs the active row, Esc clears the query and then
/// closes. The palette closes first, then the item's `onSelect` runs after the frame.
///
/// Built from the skin's popup panel, search field and menu rows: every skin draws it. Screen readers get the
/// field, a list with every row's group and "n of m", and hear the active row as it changes.
class CamoCommandPalette extends StatefulWidget {
  /// Creates the palette.
  const CamoCommandPalette({
    super.key,
    required this.state,
    required this.sources,
  });

  /// Whether it's open, and the query.
  final CamoCommandPaletteState state;

  /// The groups of results.
  final List<CamoCommandSource> sources;

  @override
  State<CamoCommandPalette> createState() => _CamoCommandPaletteState();
}

class _CamoCommandPaletteState extends State<CamoCommandPalette> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_sync);
    SchedulerBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(CamoCommandPalette old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      old.state.removeListener(_sync);
      widget.state.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final open = widget.state.open;
    if (open && !_showing) {
      _showing = true;
      // Never during a build: the state may change from any frame callback.
      SchedulerBinding.instance
        ..addPostFrameCallback((_) => _present())
        ..ensureVisualUpdate();
    } else if (!open && _showing) {
      _showing = false;
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _present() async {
    if (!mounted || !widget.state.open) {
      _showing = false;
      return;
    }
    final theme = Camouflage.themeOf(context, component: 'CamoCommandPalette');
    final o = theme.components.commandPalette;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final window = overlay.size;
    final width = math.min(
      o?.maxWidth ?? _defaultMaxWidth,
      window.width - _edgeMargin * 2,
    );
    final top = window.height / _topFraction;
    final state = widget.state;
    final sources = widget.sources;
    final run = <CamoCommandItem>[];
    await showCamoAnchoredPopupAt<void>(
      context,
      Rect.fromLTWH((window.width - width) / 2, top - theme.spacing.xs, 0, 0),
      builder: (popup) => SizedBox(
        width: width,
        child: _PaletteBody(
          state: state,
          sources: sources,
          onRun: (item) {
            run.add(item);
            state.remember(item.id);
            state.hide();
          },
        ),
      ),
    );
    _showing = false;
    state.hide();
    // After the palette is gone, so a dialog the item opens isn't stacked over it.
    if (run.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => run.first.onSelect(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// One source's latest answer; items are the previous query's while loading.
class _Result {
  const _Result(this.items, this.loading);

  final List<CamoCommandItem> items;
  final bool loading;
}

sealed class _Row {
  const _Row();
}

class _Header extends _Row {
  const _Header(this.title);

  final String title;
}

class _Entry extends _Row {
  const _Entry(
    this.item,
    this.group,
    this.kind,
    this.index,
    this.position,
    this.size,
  );

  final CamoCommandItem item;
  final String group;
  final MatchKind? kind;
  final int index;
  final int position;
  final int size;
}

class _Status extends _Row {
  const _Status(this.text);

  final String text;
}

class _PaletteBody extends StatefulWidget {
  const _PaletteBody({
    required this.state,
    required this.sources,
    required this.onRun,
  });

  final CamoCommandPaletteState state;
  final List<CamoCommandSource> sources;
  final ValueChanged<CamoCommandItem> onRun;

  @override
  State<_PaletteBody> createState() => _PaletteBodyState();
}

class _PaletteBodyState extends State<_PaletteBody> {
  late final List<_Result?> _results = List.filled(widget.sources.length, null);
  final _focus = FocusNode();
  final _scroll = ScrollController();
  int _generation = 0;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_queryChanged);
    _run();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.state.removeListener(_queryChanged);
    _generation++;
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _lastQuery = '';

  void _queryChanged() {
    if (!mounted || widget.state.query == _lastQuery) return;
    _lastQuery = widget.state.query;
    _active = 0;
    _run();
  }

  // Asks every source; a newer query makes the older answers stale.
  void _run() {
    final query = widget.state.query;
    final generation = ++_generation;
    setState(() {
      for (var i = 0; i < _results.length; i++) {
        _results[i] = _Result(_results[i]?.items ?? const [], true);
      }
    });
    for (var i = 0; i < widget.sources.length; i++) {
      final index = i;
      Future<List<CamoCommandItem>> answer;
      try {
        answer = widget.sources[i].search(query);
      } catch (_) {
        answer = Future.value(const []);
      }
      answer.catchError((Object _) => const <CamoCommandItem>[]).then((items) {
        if (!mounted || generation != _generation) return;
        setState(() => _results[index] = _Result(items, false));
      });
    }
  }

  ({List<_Row> rows, List<_Entry> entries}) _layout(
    String loading,
    String noResults,
  ) {
    final rows = <_Row>[];
    final entries = <_Entry>[];
    final query = widget.state.query;
    final recent = widget.state.recent;
    var anyLoading = false;
    for (var i = 0; i < widget.sources.length; i++) {
      final source = widget.sources[i];
      final result = _results[i] ?? const _Result([], true);
      var items = result.items;
      if (query.isEmpty) {
        int rank(CamoCommandItem it) {
          final r = recent.indexOf(it.id);
          return r < 0 ? 1 << 30 : r;
        }

        items = [...items]..sort((a, b) => rank(a).compareTo(rank(b)));
      }
      items = items.take(source.limit).toList();
      anyLoading = anyLoading || result.loading;
      if (items.isNotEmpty || result.loading) rows.add(_Header(source.title));
      for (var p = 0; p < items.length; p++) {
        final e = _Entry(
          items[p],
          source.title,
          source.matchKind,
          entries.length,
          p,
          items.length,
        );
        entries.add(e);
        rows.add(e);
      }
      if (items.isEmpty && result.loading) rows.add(_Status(loading));
    }
    if (entries.isEmpty && !anyLoading) rows.add(_Status(noResults));
    return (rows: rows, entries: entries);
  }

  void _move(int count, int step) {
    if (count == 0) return;
    setState(() => _active = (_active + step) % count);
  }

  void _jump(List<_Entry> entries, int step) {
    final starts = [
      for (final e in entries)
        if (e.position == 0) e.index,
    ];
    if (starts.isEmpty) return;
    var here = 0;
    for (var i = 0; i < starts.length; i++) {
      if (starts[i] <= _active) here = i;
    }
    setState(() => _active = starts[(here + step) % starts.length]);
  }

  void _reveal(List<_Row> rows, double itemHeight, double viewport) {
    var top = 0.0;
    for (final row in rows) {
      final height = row is _Header ? _headerHeight : itemHeight;
      if (row is _Entry && row.index == _active) {
        // The first entry of the list shows its heading too.
        final from = _active == 0 ? 0.0 : top;
        final to = top + height;
        final offset = _scroll.hasClients ? _scroll.offset : 0.0;
        if (from < offset) {
          _scroll.jumpTo(from);
        } else if (to > offset + viewport) {
          _scroll.jumpTo(to - viewport);
        }
        return;
      }
      top += height;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoCommandPalette');
    final theme = Camouflage.themeOf(context, component: 'CamoCommandPalette');
    final o = theme.components.commandPalette;
    final menu = skin.menu.defaults(theme).merge(theme.components.menu);
    final layout = _layout(
      o?.loading ?? 'Loading…',
      o?.noResults ?? 'No results',
    );
    final rows = layout.rows;
    final entries = layout.entries;
    final active = entries.isEmpty ? 0 : _active.clamp(0, entries.length - 1);
    if (active != _active) _active = active;
    final reserveIcon = entries.any((e) => e.item.icon != null);
    var total = 0.0;
    for (final r in rows) {
      total += r is _Header ? _headerHeight : menu.itemHeight;
    }
    final viewport = math.min(total, o?.maxHeight ?? _defaultMaxHeight);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reveal(rows, menu.itemHeight, viewport);
    });
    final colors = theme.colors;
    final current = entries.isEmpty ? null : entries[active];
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.tab): _JumpIntent(1),
        SingleActivator(LogicalKeyboardKey.tab, shift: true): _JumpIntent(-1),
      },
      child: Actions(
        actions: {
          _MoveIntent: CallbackAction<_MoveIntent>(
            onInvoke: (i) {
              _move(entries.length, i.step < 0 ? entries.length - 1 : 1);
              return null;
            },
          ),
          _JumpIntent: CallbackAction<_JumpIntent>(
            onInvoke: (i) {
              _jump(entries, i.step < 0 ? math.max(1, entries.length) - 1 : 1);
              return null;
            },
          ),
        },
        // After the field, which clears a typed query on its own Esc: the next one closes.
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent ||
                event.logicalKey != LogicalKeyboardKey.escape) {
              return KeyEventResult.ignored;
            }
            widget.state.hide();
            return KeyEventResult.handled;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(theme.spacing.xs),
                child: CamoSearchField(
                  query: widget.state.query,
                  onChanged: (q) => widget.state.query = q,
                  onSubmitted: (_) {
                    if (current != null) widget.onRun(current.item);
                  },
                  placeholder: o?.placeholder ?? 'Search actions and files',
                  focusNode: _focus,
                ),
              ),
              Semantics(
                liveRegion: true,
                label: current == null
                    ? ''
                    : '${current.item.title}, ${current.group}, '
                          '${current.index + 1} of ${entries.length}',
                child: const SizedBox.shrink(),
              ),
              SizedBox(
                height: viewport,
                child: ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.zero,
                  itemCount: rows.length,
                  itemBuilder: (context, i) => switch (rows[i]) {
                    _Header(:final title) => SizedBox(
                      height: _headerHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.m,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: theme.typography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Status(:final text) => SizedBox(
                      height: menu.itemHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.m,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            text,
                            style: theme.typography.bodyMedium.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    final _Entry e => SizedBox(
                      height: menu.itemHeight,
                      child: _entryRow(e, e.index == active, reserveIcon),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entryRow(_Entry e, bool active, bool reserveIcon) {
    final item = e.item;
    final query = widget.state.query;
    final kind = e.kind;
    final highlight = kind == null
        ? const <MatchRange>[]
        : CamoMatcher.match(query, item.title, kind: kind) ?? const [];
    final hint = [
      e.group,
      '${e.position + 1} of ${e.size}',
      ?item.subtitle,
    ].join(', ');
    return CamoMenuItemRow(
      key: ValueKey<Object>('${e.group}:${item.id}'),
      item: CamoMenuItem(
        text: item.title,
        onPressed: () {},
        leadingIcon: item.icon,
        trailingText: item.shortcut ?? item.subtitle,
      ),
      onSelected: () => widget.onRun(item),
      highlight: highlight,
      active: active,
      reserveIcon: reserveIcon,
      hint: hint,
      focusable: false,
      asOption: true,
    );
  }
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.step);

  final int step;
}

class _JumpIntent extends Intent {
  const _JumpIntent(this.step);

  final int step;
}
