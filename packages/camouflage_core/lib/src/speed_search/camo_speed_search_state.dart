import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'camo_matcher.dart';

/// What speed search does with the items that don't match.
enum SpeedSearchMode {
  /// Hide them (a tree keeps the ancestors of the matches).
  filter,

  /// Keep them all and only move focus to the next match.
  jump,
}

/// The state of a speed search: the typed [query], with no field. Hand it to a component
/// (`CamoTree(speedSearch: state)`) or use it with your own lists: [match] says whether and where an item's text
/// matches, for [CamoHighlightedText]. Typing in a focused collection appends, Backspace removes, Esc clears.
///
/// [mode] picks filtering or jumping; [kind] how the query matches (see [CamoMatcher]).
class CamoSpeedSearchState extends ChangeNotifier {
  /// Creates a state.
  CamoSpeedSearchState({
    this.mode = SpeedSearchMode.filter,
    this.kind = MatchKind.auto,
  });

  /// Filtering or jumping.
  final SpeedSearchMode mode;

  /// How the query matches.
  final MatchKind kind;

  String _query = '';

  /// How many items match, as the collection last counted them (for the overlay and the announcement).
  int matchCount = 0;

  /// What the user typed. Empty when no search is running.
  String get query => _query;

  /// Whether a search is running.
  bool get active => _query.isNotEmpty;

  /// Appends [text] to the query.
  void type(String text) {
    _query += text;
    notifyListeners();
  }

  /// Removes the last typed character.
  void backspace() {
    if (_query.isEmpty) return;
    _query = _query.substring(0, _query.length - 1);
    notifyListeners();
  }

  /// Ends the search.
  void clear() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  /// The ranges of [text] that match the query, `null` when it doesn't, an empty list while no search runs.
  List<MatchRange>? match(String text) =>
      CamoMatcher.match(_query, text, kind: kind);

  /// Whether [text] matches the query (always `true` while no search runs).
  bool matches(String text) => match(text) != null;

  /// Handles a key for a collection: Esc and Backspace only while a search runs; printable keys always.
  KeyEventResult handleKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && active) {
      clear();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace && active) {
      backspace();
      return KeyEventResult.handled;
    }
    final keys = HardwareKeyboard.instance;
    if (keys.isControlPressed || keys.isMetaPressed || keys.isAltPressed) {
      return KeyEventResult.ignored;
    }
    final char = event.character;
    // Space is a select key until a search has started.
    final printable =
        char != null &&
        char.isNotEmpty &&
        char.codeUnitAt(0) > (active ? 0x1F : 0x20) &&
        char.codeUnitAt(0) != 0x7F;
    if (!printable) return KeyEventResult.ignored;
    type(char);
    return KeyEventResult.handled;
  }
}

/// Typing in the focused collection below feeds [state]; Esc clears it first and only then goes on.
class CamoSpeedSearchKeys extends StatelessWidget {
  /// Creates the wrapper.
  const CamoSpeedSearchKeys({
    super.key,
    required this.state,
    required this.child,
  });

  /// The search, or `null` for none.
  final CamoSpeedSearchState? state;

  /// The collection.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    if (state == null) return child;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) => state.handleKey(event),
      child: child,
    );
  }
}
