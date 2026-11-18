import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../surface/camo_surface.dart';
import '../text/camo_text.dart';
import '../theme/roles.dart';
import 'camo_matcher.dart';
import 'camo_speed_search_state.dart';

/// Overrides for speed search. `null` keeps the default.
@immutable
class CamoSpeedSearchTheme {
  /// Creates overrides.
  const CamoSpeedSearchTheme({
    this.highlightColor,
    this.highlightTextColor,
    this.matchCount,
    this.noMatches,
  });

  /// The fill behind matched characters.
  final Color? highlightColor;

  /// The color of matched characters.
  final Color? highlightTextColor;

  /// The words for a match count ("3 matches").
  final String Function(int count)? matchCount;

  /// The words for no match.
  final String? noMatches;

  /// A copy with the given fields replaced.
  CamoSpeedSearchTheme copyWith({
    Color? highlightColor,
    Color? highlightTextColor,
    String Function(int count)? matchCount,
    String? noMatches,
  }) => CamoSpeedSearchTheme(
    highlightColor: highlightColor ?? this.highlightColor,
    highlightTextColor: highlightTextColor ?? this.highlightTextColor,
    matchCount: matchCount ?? this.matchCount,
    noMatches: noMatches ?? this.noMatches,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSpeedSearchTheme &&
      other.highlightColor == highlightColor &&
      other.highlightTextColor == highlightTextColor &&
      other.matchCount == matchCount &&
      other.noMatches == noMatches;

  @override
  int get hashCode =>
      Object.hash(highlightColor, highlightTextColor, matchCount, noMatches);
}

/// [text] with the characters in [ranges] (from [CamoSpeedSearchState.match]) drawn in the theme's speed search
/// colors. Use it with `match` in your own lists; the tree and menus do it themselves.
class CamoHighlightedText extends StatelessWidget {
  /// Creates the text.
  const CamoHighlightedText(
    this.text,
    this.ranges, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  /// The text.
  final String text;

  /// The matched ranges.
  final List<MatchRange> ranges;

  /// The text style, the theme's body style by default.
  final TextStyle? style;

  /// The most lines.
  final int? maxLines;

  /// What happens to what doesn't fit.
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }
    final theme = Camouflage.themeOf(context, component: 'CamoHighlightedText');
    final o = theme.components.speedSearch;
    final base = style ?? DefaultTextStyle.of(context).style;
    final mark = base.copyWith(
      backgroundColor: o?.highlightColor ?? theme.colors.tertiaryContainer,
      color: o?.highlightTextColor ?? theme.colors.onTertiaryContainer,
    );
    final spans = <TextSpan>[];
    var at = 0;
    for (final r in ranges) {
      final start = r.start.clamp(at, text.length);
      final end = r.end.clamp(start, text.length);
      if (start > at) spans.add(TextSpan(text: text.substring(at, start)));
      if (end > start) {
        spans.add(TextSpan(text: text.substring(start, end), style: mark));
      }
      at = end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// The typed query and the match count, in a small surface a collection puts at its start edge while a search
/// runs. A polite live region: a screen reader hears "3 matches" or "No matches" as the query changes.
class CamoSpeedSearchOverlay extends StatelessWidget {
  /// Creates the overlay.
  const CamoSpeedSearchOverlay({super.key, required this.state});

  /// The search.
  final CamoSpeedSearchState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      if (!state.active) return const SizedBox.shrink();
      final theme = Camouflage.themeOf(
        context,
        component: 'CamoSpeedSearchOverlay',
      );
      final o = theme.components.speedSearch;
      final count = state.matchCount;
      final summary = count == 0
          ? o?.noMatches ?? 'No matches'
          : o?.matchCount?.call(count) ?? '$count matches';
      final spacing = Camouflage.spacingOf(context);
      return Semantics(
        liveRegion: true,
        label: '${state.query}, $summary',
        excludeSemantics: true,
        child: CamoSurface(
          level: SurfaceLevel.high,
          shape: ShapeRole.small,
          border: true,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s,
              vertical: spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: spacing.s,
              children: [
                CamoText(state.query),
                CamoText(
                  summary,
                  style: Camouflage.typographyOf(context).labelSmall,
                  color: theme.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
