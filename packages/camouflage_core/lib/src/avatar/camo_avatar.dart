import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import 'initials.dart';

/// The three avatar sizes; the theme sets each one's diameter.
enum AvatarSize {
  /// The small diameter.
  small,

  /// The medium diameter.
  medium,

  /// The large diameter.
  large,
}

/// An avatar's outline: a circle, a rounded square (`roundedShape`) or a square.
enum AvatarShape {
  /// A circle.
  circle,

  /// A rounded square.
  rounded,

  /// A square.
  square,
}

/// A person's status, shown as a small dot on the avatar and said after the name.
enum Presence {
  /// Online.
  online,

  /// Away.
  away,

  /// Busy.
  busy,

  /// Offline.
  offline,
}

/// An avatar's background and initials color.
@immutable
class AvatarColors {
  /// Creates AvatarColors.
  const AvatarColors({required this.container, required this.content});

  /// The background.
  final Color container;

  /// The initials or icon.
  final Color content;

  @override
  bool operator ==(Object other) =>
      other is AvatarColors &&
      other.container == container &&
      other.content == content;

  @override
  int get hashCode => Object.hash(container, content);
}

/// The presence dot's color per [Presence], and the [ring] around the dot and around avatars in a group.
@immutable
class PresenceColors {
  /// Creates PresenceColors.
  const PresenceColors({
    required this.online,
    required this.away,
    required this.busy,
    required this.offline,
    required this.ring,
  });

  /// Online.
  final Color online;

  /// Away.
  final Color away;

  /// Busy.
  final Color busy;

  /// Offline.
  final Color offline;

  /// The ring.
  final Color ring;

  /// The dot color for [presence].
  Color of(Presence presence) => switch (presence) {
    Presence.online => online,
    Presence.away => away,
    Presence.busy => busy,
    Presence.offline => offline,
  };

  @override
  bool operator ==(Object other) =>
      other is PresenceColors &&
      other.online == online &&
      other.away == away &&
      other.busy == busy &&
      other.offline == offline &&
      other.ring == ring;

  @override
  int get hashCode => Object.hash(online, away, busy, offline, ring);
}

/// The words avatars say: each [Presence], and [more] for the "+N" avatar of a group.
@immutable
class AvatarStrings {
  /// Creates AvatarStrings.
  const AvatarStrings({
    this.online = 'online',
    this.away = 'away',
    this.busy = 'busy',
    this.offline = 'offline',
    this.more = _more,
  });

  /// Online.
  final String online;

  /// Away.
  final String away;

  /// Busy.
  final String busy;

  /// Offline.
  final String offline;

  /// "2 more".
  final String Function(int count) more;

  /// The word for [presence].
  String of(Presence presence) => switch (presence) {
    Presence.online => online,
    Presence.away => away,
    Presence.busy => busy,
    Presence.offline => offline,
  };

  @override
  bool operator ==(Object other) =>
      other is AvatarStrings &&
      other.online == online &&
      other.away == away &&
      other.busy == busy &&
      other.offline == offline &&
      other.more == more;

  @override
  int get hashCode => Object.hash(online, away, busy, offline, more);
}

String _more(int count) => '$count more';

/// Overrides for avatars; `null` keeps the skin's default.
@immutable
class CamoAvatarTheme {
  /// Creates CamoAvatarTheme.
  const CamoAvatarTheme({
    this.shape,
    this.roundedShape,
    this.sizeSmall,
    this.sizeMedium,
    this.sizeLarge,
    this.textStyleSmall,
    this.textStyleMedium,
    this.textStyleLarge,
    this.initialsPalette,
    this.neutralColors,
    this.presenceSize,
    this.presenceColors,
    this.ringWidth,
    this.groupOverlap,
    this.personIcon,
    this.strings,
  });

  /// The shape for the whole brand when an avatar passes none.
  final AvatarShape? shape;

  /// The corners of `rounded` avatars.
  final BorderRadius? roundedShape;

  /// A small avatar.
  final double? sizeSmall;

  /// A medium avatar.
  final double? sizeMedium;

  /// A large avatar.
  final double? sizeLarge;

  /// A small avatar's initials.
  final TextStyle? textStyleSmall;

  /// A medium avatar's initials.
  final TextStyle? textStyleMedium;

  /// A large avatar's initials.
  final TextStyle? textStyleLarge;

  /// Initials backgrounds, picked by a stable hash of the name.
  final List<AvatarColors>? initialsPalette;

  /// An avatar with no name (the person icon) and the "+N" of a group.
  final AvatarColors? neutralColors;

  /// The presence dot.
  final double? presenceSize;

  /// The presence dot per status, and the ring.
  final PresenceColors? presenceColors;

  /// The ring around the presence dot and around each avatar in a group.
  final double? ringWidth;

  /// How far avatars in a group overlap.
  final double? groupOverlap;

  /// The icon of an avatar with no name and no image.
  final IconSource? personIcon;

  /// The words avatars say.
  final AvatarStrings? strings;

  /// A copy with the given fields replaced.
  CamoAvatarTheme copyWith({
    AvatarShape? shape,
    BorderRadius? roundedShape,
    double? sizeSmall,
    double? sizeMedium,
    double? sizeLarge,
    TextStyle? textStyleSmall,
    TextStyle? textStyleMedium,
    TextStyle? textStyleLarge,
    List<AvatarColors>? initialsPalette,
    AvatarColors? neutralColors,
    double? presenceSize,
    PresenceColors? presenceColors,
    double? ringWidth,
    double? groupOverlap,
    IconSource? personIcon,
    AvatarStrings? strings,
  }) => CamoAvatarTheme(
    shape: shape ?? this.shape,
    roundedShape: roundedShape ?? this.roundedShape,
    sizeSmall: sizeSmall ?? this.sizeSmall,
    sizeMedium: sizeMedium ?? this.sizeMedium,
    sizeLarge: sizeLarge ?? this.sizeLarge,
    textStyleSmall: textStyleSmall ?? this.textStyleSmall,
    textStyleMedium: textStyleMedium ?? this.textStyleMedium,
    textStyleLarge: textStyleLarge ?? this.textStyleLarge,
    initialsPalette: initialsPalette ?? this.initialsPalette,
    neutralColors: neutralColors ?? this.neutralColors,
    presenceSize: presenceSize ?? this.presenceSize,
    presenceColors: presenceColors ?? this.presenceColors,
    ringWidth: ringWidth ?? this.ringWidth,
    groupOverlap: groupOverlap ?? this.groupOverlap,
    personIcon: personIcon ?? this.personIcon,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoAvatarTheme &&
      other.shape == shape &&
      other.roundedShape == roundedShape &&
      other.sizeSmall == sizeSmall &&
      other.sizeMedium == sizeMedium &&
      other.sizeLarge == sizeLarge &&
      other.textStyleSmall == textStyleSmall &&
      other.textStyleMedium == textStyleMedium &&
      other.textStyleLarge == textStyleLarge &&
      listEquals(other.initialsPalette, initialsPalette) &&
      other.neutralColors == neutralColors &&
      other.presenceSize == presenceSize &&
      other.presenceColors == presenceColors &&
      other.ringWidth == ringWidth &&
      other.groupOverlap == groupOverlap &&
      other.personIcon == personIcon &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    shape,
    roundedShape,
    sizeSmall,
    sizeMedium,
    sizeLarge,
    textStyleSmall,
    textStyleMedium,
    textStyleLarge,
    Object.hashAll(initialsPalette ?? const []),
    neutralColors,
    presenceSize,
    presenceColors,
    ringWidth,
    groupOverlap,
    personIcon,
    strings,
  );
}

/// The resolved avatar style: every field set.
@immutable
class CamoAvatarStyle {
  /// Creates CamoAvatarStyle.
  const CamoAvatarStyle({
    required this.shape,
    required this.roundedShape,
    required this.sizeSmall,
    required this.sizeMedium,
    required this.sizeLarge,
    required this.textStyleSmall,
    required this.textStyleMedium,
    required this.textStyleLarge,
    required this.initialsPalette,
    required this.neutralColors,
    required this.presenceSize,
    required this.presenceColors,
    required this.ringWidth,
    required this.groupOverlap,
    required this.personIcon,
    this.strings = const AvatarStrings(),
  });

  /// The shape for the whole brand when an avatar passes none.
  final AvatarShape shape;

  /// The corners of `rounded` avatars.
  final BorderRadius roundedShape;

  /// A small avatar.
  final double sizeSmall;

  /// A medium avatar.
  final double sizeMedium;

  /// A large avatar.
  final double sizeLarge;

  /// A small avatar's initials.
  final TextStyle textStyleSmall;

  /// A medium avatar's initials.
  final TextStyle textStyleMedium;

  /// A large avatar's initials.
  final TextStyle textStyleLarge;

  /// Initials backgrounds, picked by a stable hash of the name.
  final List<AvatarColors> initialsPalette;

  /// An avatar with no name (the person icon) and the "+N" of a group.
  final AvatarColors neutralColors;

  /// The presence dot.
  final double presenceSize;

  /// The presence dot per status, and the ring.
  final PresenceColors presenceColors;

  /// The ring around the presence dot and around each avatar in a group.
  final double ringWidth;

  /// How far avatars in a group overlap.
  final double groupOverlap;

  /// The icon of an avatar with no name and no image.
  final IconSource personIcon;

  /// The words avatars say.
  final AvatarStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoAvatarStyle merge(CamoAvatarTheme? o) => o == null
      ? this
      : CamoAvatarStyle(
          shape: o.shape ?? shape,
          roundedShape: o.roundedShape ?? roundedShape,
          sizeSmall: o.sizeSmall ?? sizeSmall,
          sizeMedium: o.sizeMedium ?? sizeMedium,
          sizeLarge: o.sizeLarge ?? sizeLarge,
          textStyleSmall: o.textStyleSmall ?? textStyleSmall,
          textStyleMedium: o.textStyleMedium ?? textStyleMedium,
          textStyleLarge: o.textStyleLarge ?? textStyleLarge,
          initialsPalette: (o.initialsPalette?.isNotEmpty ?? false)
              ? o.initialsPalette!
              : initialsPalette,
          neutralColors: o.neutralColors ?? neutralColors,
          presenceSize: o.presenceSize ?? presenceSize,
          presenceColors: o.presenceColors ?? presenceColors,
          ringWidth: o.ringWidth ?? ringWidth,
          groupOverlap: o.groupOverlap ?? groupOverlap,
          personIcon: o.personIcon ?? personIcon,
          strings: o.strings ?? strings,
        );

  /// The diameter for [size].
  double sizeOf(AvatarSize size) => switch (size) {
    AvatarSize.small => sizeSmall,
    AvatarSize.medium => sizeMedium,
    AvatarSize.large => sizeLarge,
  };

  /// The initials style for [size].
  TextStyle textStyleOf(AvatarSize size) => switch (size) {
    AvatarSize.small => textStyleSmall,
    AvatarSize.medium => textStyleMedium,
    AvatarSize.large => textStyleLarge,
  };

  /// The outline for [shape].
  BorderRadius shapeOf(AvatarShape shape, CamoTheme theme) => switch (shape) {
    AvatarShape.circle => theme.shapes.full,
    AvatarShape.rounded => roundedShape,
    AvatarShape.square => BorderRadius.zero,
  };

  /// The colors for [state]: the palette entry its seed picks, or the neutral colors without a seed.
  AvatarColors colorsFor(AvatarState state) {
    final seed = state.colorSeed;
    return seed == null
        ? neutralColors
        : initialsPalette[seed % initialsPalette.length];
  }
}

/// What an avatar renderer draws. With [initials] it shows them (under the image, if any); without, the `personIcon`. [colorSeed] picks the palette entry (`null`: the neutral colors). [shape] is resolved.
@immutable
class AvatarState {
  /// Creates AvatarState.
  const AvatarState({
    required this.initials,
    required this.colorSeed,
    required this.size,
    required this.shape,
    required this.presence,
  });

  /// The initials, or `null` for the person icon.
  final String? initials;

  /// The FNV-1a hash of the name, or `null`.
  final int? colorSeed;

  /// The size.
  final AvatarSize size;

  /// The resolved shape.
  final AvatarShape shape;

  /// The status dot, if any.
  final Presence? presence;

  @override
  bool operator ==(Object other) =>
      other is AvatarState &&
      other.initials == initials &&
      other.colorSeed == colorSeed &&
      other.size == size &&
      other.shape == shape &&
      other.presence == presence;

  @override
  int get hashCode => Object.hash(initials, colorSeed, size, shape, presence);
}

/// The app's [image] (its own image widget). The renderer draws it on top of the initials, clipped to the
/// shape, so a missing, loading or failed image leaves the initials showing.
@immutable
class AvatarSlots {
  /// Creates the slots.
  const AvatarSlots({this.image});

  /// For example `Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())`.
  final Widget? image;
}

/// Draws avatars. Draw the presence dot outside the clip.
abstract interface class CamoAvatarRenderer {
  /// The complete avatar style for [theme].
  CamoAvatarStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    AvatarState state,
    AvatarSlots slots,
    CamoTheme theme,
    CamoAvatarStyle style,
  );
}

/// Marks [child] as a list row's leading slot: the row says the name, so an avatar there is decorative.
Widget avatarInRow(Widget child) => _AvatarInRow(child: child);

class _AvatarInRow extends InheritedWidget {
  const _AvatarInRow({required super.child});

  @override
  bool updateShouldNotify(_AvatarInRow oldWidget) => false;
}

/// A person or entity: the app's [image] (`Image.network` with an `errorBuilder`, say; core loads no images), on
/// top of initials from [name] in a color picked from the name, or a person icon with no name. It's announced as
/// [name] plus the [presence] ("Dwiki Riyadi, online"); with no name it's decorative, and so it is in a
/// `CamoListItem`'s leading slot, where the row already says the name.
class CamoAvatar extends StatelessWidget {
  /// Creates an avatar.
  const CamoAvatar({
    super.key,
    this.name,
    this.image,
    this.size = AvatarSize.medium,
    this.shape,
    this.presence,
  });

  /// Gives the initials, their color and the accessible name.
  final String? name;

  /// The app's image widget, drawn over the initials.
  final Widget? image;

  /// Small, medium or large.
  final AvatarSize size;

  /// `null` uses `CamoAvatarTheme.shape`.
  final AvatarShape? shape;

  /// A status dot.
  final Presence? presence;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoAvatar');
    final theme = Camouflage.themeOf(context, component: 'CamoAvatar');
    final style = skin.avatar.defaults(theme).merge(theme.components.avatar);
    final name = this.name;
    final initials = avatarInitials(name);
    final inRow = context.getInheritedWidgetOfExactType<_AvatarInRow>() != null;
    final presence = this.presence;
    final String? label = name == null || name.trim().isEmpty || inRow
        ? null
        : presence == null
        ? name
        : '$name, ${style.strings.of(presence)}';
    final image = this.image;
    final visual = skin.avatar.render(
      context,
      AvatarState(
        initials: initials,
        colorSeed: initials == null ? null : avatarColorSeed(name ?? ''),
        size: size,
        shape: shape ?? style.shape,
        presence: presence,
      ),
      AvatarSlots(image: image == null ? null : ExcludeSemantics(child: image)),
      theme,
      style,
    );
    return label == null
        ? ExcludeSemantics(child: visual)
        : Semantics(
            image: true,
            label: label,
            excludeSemantics: true,
            child: visual,
          );
  }
}

/// Avatars that overlap by `groupOverlap`, each in a ring, showing at most [max] and then a "+N" avatar
/// ("2 more") for the rest. [size] sizes the "+N".
class CamoAvatarGroup extends StatelessWidget {
  /// Creates an avatar group.
  const CamoAvatarGroup({
    super.key,
    required this.avatars,
    this.max = 3,
    this.size = AvatarSize.medium,
  });

  /// The avatars, usually [CamoAvatar]s.
  final List<Widget> avatars;

  /// How many show before the "+N".
  final int max;

  /// The "+N" avatar's size.
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoAvatarGroup');
    final theme = Camouflage.themeOf(context, component: 'CamoAvatarGroup');
    final style = skin.avatar.defaults(theme).merge(theme.components.avatar);
    final shape = style.shapeOf(style.shape, theme);
    final rest = avatars.length - max;
    Widget ring(Widget child) => DecoratedBox(
      decoration: BoxDecoration(
        color: style.presenceColors.ring,
        borderRadius: shape,
      ),
      child: Padding(padding: EdgeInsets.all(style.ringWidth), child: child),
    );
    final rings = [
      for (final avatar in avatars.take(max)) ring(avatar),
      if (rest > 0)
        ring(
          Semantics(
            label: style.strings.more(rest),
            excludeSemantics: true,
            child: skin.avatar.render(
              context,
              AvatarState(
                initials: '+$rest',
                colorSeed: null,
                size: size,
                shape: style.shape,
                presence: null,
              ),
              const AvatarSlots(),
              theme,
              style,
            ),
          ),
        ),
    ];
    // Each avatar after the first takes less room than it draws, so it overlaps the one before it.
    final diameter = style.sizeOf(size) + 2 * style.ringWidth;
    final overlap = (diameter - style.groupOverlap) / diameter;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, r) in rings.indexed)
          i == 0
              ? r
              : Align(
                  alignment: AlignmentDirectional.centerEnd,
                  widthFactor: overlap,
                  child: r,
                ),
      ],
    );
  }
}
