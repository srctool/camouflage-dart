import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// A badge's colors; [border] is drawn only when set (the outline appearance).
@immutable
class BadgeColors {
  /// Creates BadgeColors.
  const BadgeColors({
    required this.container,
    required this.content,
    this.border,
  });

  /// The fill.
  final Color container;

  /// The count.
  final Color content;

  /// The outline, if any.
  final Color? border;

  @override
  bool operator ==(Object other) =>
      other is BadgeColors &&
      other.container == container &&
      other.content == content &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, content, border);
}

/// The words a badge says when the app passes no label: [count] for a number, [dot] for a dot.
@immutable
class BadgeStrings {
  /// Creates BadgeStrings.
  const BadgeStrings({this.count = _count, this.dot = 'New'});

  /// "3 new".
  final String Function(String count) count;

  /// A dot's description.
  final String dot;

  @override
  bool operator ==(Object other) =>
      other is BadgeStrings && other.count == count && other.dot == dot;

  @override
  int get hashCode => Object.hash(count, dot);
}

String _count(String count) => '$count new';

/// Overrides for badges; `null` keeps the skin's default.
@immutable
class CamoBadgeTheme {
  /// Creates CamoBadgeTheme.
  const CamoBadgeTheme({
    this.defaultAppearance,
    this.defaultTone,
    this.dotSize,
    this.height,
    this.minWidth,
    this.padding,
    this.textStyle,
    this.offset,
    this.borderWidth,
    this.strings,
  });

  /// The appearance when a badge passes none.
  final Appearance? defaultAppearance;

  /// The tone when a badge passes none (a brand whose badges are, say, info sets it once).
  final Tone? defaultTone;

  /// A dot badge.
  final double? dotSize;

  /// A count badge (it grows with the font scale).
  final double? height;

  /// A count badge.
  final double? minWidth;

  /// Around the count.
  final EdgeInsetsDirectional? padding;

  /// The count.
  final TextStyle? textStyle;

  /// Where the badge's center sits from the anchor's top-end corner (x toward the end, y down).
  final Offset? offset;

  /// The outline appearance.
  final double? borderWidth;

  /// The words badges say.
  final BadgeStrings? strings;

  /// A copy with the given fields replaced.
  CamoBadgeTheme copyWith({
    Appearance? defaultAppearance,
    Tone? defaultTone,
    double? dotSize,
    double? height,
    double? minWidth,
    EdgeInsetsDirectional? padding,
    TextStyle? textStyle,
    Offset? offset,
    double? borderWidth,
    BadgeStrings? strings,
  }) => CamoBadgeTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    defaultTone: defaultTone ?? this.defaultTone,
    dotSize: dotSize ?? this.dotSize,
    height: height ?? this.height,
    minWidth: minWidth ?? this.minWidth,
    padding: padding ?? this.padding,
    textStyle: textStyle ?? this.textStyle,
    offset: offset ?? this.offset,
    borderWidth: borderWidth ?? this.borderWidth,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoBadgeTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.defaultTone == defaultTone &&
      other.dotSize == dotSize &&
      other.height == height &&
      other.minWidth == minWidth &&
      other.padding == padding &&
      other.textStyle == textStyle &&
      other.offset == offset &&
      other.borderWidth == borderWidth &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    defaultTone,
    dotSize,
    height,
    minWidth,
    padding,
    textStyle,
    offset,
    borderWidth,
    strings,
  );
}

/// The resolved badge style: every field set.
@immutable
class CamoBadgeStyle {
  /// Creates CamoBadgeStyle.
  const CamoBadgeStyle({
    required this.defaultAppearance,
    required this.defaultTone,
    required this.dotSize,
    required this.height,
    required this.minWidth,
    required this.padding,
    required this.textStyle,
    required this.offset,
    required this.borderWidth,
    this.strings = const BadgeStrings(),
  });

  /// The appearance when a badge passes none.
  final Appearance defaultAppearance;

  /// The tone when a badge passes none (a brand whose badges are, say, info sets it once).
  final Tone defaultTone;

  /// A dot badge.
  final double dotSize;

  /// A count badge (it grows with the font scale).
  final double height;

  /// A count badge.
  final double minWidth;

  /// Around the count.
  final EdgeInsetsDirectional padding;

  /// The count.
  final TextStyle textStyle;

  /// Where the badge's center sits from the anchor's top-end corner (x toward the end, y down).
  final Offset offset;

  /// The outline appearance.
  final double borderWidth;

  /// The words badges say.
  final BadgeStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoBadgeStyle merge(CamoBadgeTheme? o) => o == null
      ? this
      : CamoBadgeStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          defaultTone: o.defaultTone ?? defaultTone,
          dotSize: o.dotSize ?? dotSize,
          height: o.height ?? height,
          minWidth: o.minWidth ?? minWidth,
          padding: o.padding ?? padding,
          textStyle: o.textStyle ?? textStyle,
          offset: o.offset ?? offset,
          borderWidth: o.borderWidth ?? borderWidth,
          strings: o.strings ?? strings,
        );

  /// The colors for [appearance] in [tone] (the default tone is the brand's primary family): solid a strong fill,
  /// soft a container fill, outline the strong color for the border and text on `surface`.
  BadgeColors colorsFor(Appearance appearance, Tone tone, CamoTheme theme) {
    final f = theme.colors.family(tone);
    return switch (appearance) {
      Appearance.solid => BadgeColors(container: f.strong, content: f.onStrong),
      Appearance.soft => BadgeColors(
        container: f.container,
        content: f.onContainer,
      ),
      _ => BadgeColors(
        container: theme.colors.surface,
        content: f.strong,
        border: f.strong,
      ),
    };
  }
}

/// What a badge renderer draws: a dot when [text] is `null`, a pill with [text] ("3", "99+") otherwise.
@immutable
class BadgeState {
  /// Creates BadgeState.
  const BadgeState({
    required this.text,
    required this.tone,
    required this.appearance,
  });

  /// The count text, or `null` for a dot.
  final String? text;

  /// The resolved tone.
  final Tone tone;

  /// The resolved appearance.
  final Appearance appearance;

  /// A dot, no number.
  bool get isDot => text == null;

  @override
  bool operator ==(Object other) =>
      other is BadgeState &&
      other.text == text &&
      other.tone == tone &&
      other.appearance == appearance;

  @override
  int get hashCode => Object.hash(text, tone, appearance);
}

/// The appearance a badge draws for [a]: solid, soft or outline (the others fall back to solid).
Appearance badgeAppearance(Appearance a) => switch (a) {
  Appearance.soft || Appearance.outline => a,
  _ => Appearance.solid,
};

/// The text a badge shows for [count]: `null` for no count (a dot), `'$max+'` above [max].
String? badgeText(int? count, int max) {
  if (count == null) return null;
  if (count > max) return '$max+';
  return (count < 0 ? 0 : count).toString();
}

/// Draws badges.
abstract interface class CamoBadgeRenderer {
  /// The complete badge style for [theme].
  CamoBadgeStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    BadgeState state,
    CamoTheme theme,
    CamoBadgeStyle style,
  );
}

/// A count ("3") or, with no [count], a dot, usually in a [CamoBadgedBox] on an icon or avatar. Above [max] it
/// shows "99+"; a count of 0 (or less) shows nothing. A badge is never focusable: its [semanticLabel] (default
/// "3 new" / "New") joins its anchor's announcement. Count changes aren't announced; apps announce the ones
/// that matter.
class CamoBadge extends StatelessWidget {
  /// Creates a badge.
  const CamoBadge({
    super.key,
    this.count,
    this.max = 99,
    this.tone,
    this.appearance,
    this.semanticLabel,
  });

  /// The count; `null` makes a dot.
  final int? count;

  /// Above it the badge shows "$max+".
  final int max;

  /// `null` uses `CamoBadgeTheme.defaultTone`.
  final Tone? tone;

  /// `null` uses `CamoBadgeTheme.defaultAppearance`.
  final Appearance? appearance;

  /// What the anchor says about the badge ("3 unread messages").
  final String? semanticLabel;

  bool get _hidden => count != null && count! <= 0;

  /// What the badge adds to its anchor's announcement, or `null` when it shows nothing.
  String? describe(BuildContext context) {
    if (_hidden) return null;
    final skin = Camouflage.skinOf(context, component: 'CamoBadge');
    final theme = Camouflage.themeOf(context, component: 'CamoBadge');
    final strings = skin.badge
        .defaults(theme)
        .merge(theme.components.badge)
        .strings;
    final text = badgeText(count, max);
    return semanticLabel ?? (text == null ? strings.dot : strings.count(text));
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoBadge');
    final theme = Camouflage.themeOf(context, component: 'CamoBadge');
    final style = skin.badge.defaults(theme).merge(theme.components.badge);
    final Widget shown = _hidden
        ? const SizedBox.shrink(key: ValueKey('hidden'))
        : KeyedSubtree(
            key: ValueKey(badgeText(count, max)),
            child: skin.badge.render(
              context,
              BadgeState(
                text: badgeText(count, max),
                tone: tone ?? style.defaultTone,
                appearance: badgeAppearance(
                  appearance ?? style.defaultAppearance,
                ),
              ),
              theme,
              style,
            ),
          );
    return ExcludeSemantics(
      child: AnimatedSwitcher(
        duration: theme.motion.durationShort,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: shown,
      ),
    );
  }
}

/// Anchors [badge] (a [CamoBadge]) on [child] (an icon, an icon button, an avatar): its center sits at the
/// child's top-end corner plus `CamoBadgeStyle.offset`, mirrored in right-to-left layouts. The badge doesn't
/// change the child's size and isn't clipped. Its description joins the child's announcement.
class CamoBadgedBox extends StatelessWidget {
  /// Creates a badged box.
  const CamoBadgedBox({super.key, required this.badge, required this.child});

  /// Usually a [CamoBadge].
  final Widget badge;

  /// The anchor.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoBadgedBox');
    final theme = Camouflage.themeOf(context, component: 'CamoBadgedBox');
    final style = skin.badge.defaults(theme).merge(theme.components.badge);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final badge = this.badge;
    final description = badge is CamoBadge ? badge.describe(context) : null;
    // The badge's end edge sits at the corner plus the offset; half its size moves its center there.
    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: style.offset.dy,
          end: -style.offset.dx,
          child: FractionalTranslation(
            translation: Offset(rtl ? -0.5 : 0.5, -0.5),
            child: badge,
          ),
        ),
      ],
    );
    return MergeSemantics(
      child: Semantics(value: description, child: stack),
    );
  }
}
