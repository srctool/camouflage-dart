import 'package:flutter/foundation.dart';

import 'camo_colors.dart';
import 'camo_component_themes.dart';
import 'camo_scales.dart';
import 'camo_token_set.dart';
import 'camo_typography.dart';
import 'theme_validator.dart';

/// Everything a skin draws with: colors, typography, component overrides, shapes, spacing, elevation, motion
/// and the brand's own token sets. Light and dark are two instances; there's no `isDark` flag.
@immutable
class CamoTheme {
  /// Creates a theme. Only [colors] and [typography] have no defaults.
  const CamoTheme({
    required this.colors,
    required this.typography,
    this.components = const CamoComponentThemes(),
    this.shapes = const CamoShapes(),
    this.spacing = const CamoSpacing(),
    this.elevation = const CamoElevation(),
    this.motion = const CamoMotion(),
    this.tokenSets = const [],
  });

  /// The 42 color roles.
  final CamoColors colors;

  /// The 15 text styles.
  final CamoTypography typography;

  /// Per-component overrides.
  final CamoComponentThemes components;

  /// Corner radii.
  final CamoShapes shapes;

  /// Spacing roles.
  final CamoSpacing spacing;

  /// Depth levels.
  final CamoElevation elevation;

  /// Durations and easings.
  final CamoMotion motion;

  /// The brand's own typed token sets (ADR-32).
  final List<CamoTokenSet> tokenSets;

  /// The token set of type [T], or `null` if this theme doesn't include it.
  T? tokens<T extends CamoTokenSet<T>>() =>
      tokenSets.whereType<T>().firstOrNull;

  /// Reports contrast and value problems. It never throws and never corrects a brand's colors.
  List<ThemeIssue> validate() => ThemeValidator.validate(this);

  /// A copy with the given groups replaced.
  CamoTheme copyWith({
    CamoColors? colors,
    CamoTypography? typography,
    CamoComponentThemes? components,
    CamoShapes? shapes,
    CamoSpacing? spacing,
    CamoElevation? elevation,
    CamoMotion? motion,
    List<CamoTokenSet>? tokenSets,
  }) {
    return CamoTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      components: components ?? this.components,
      shapes: shapes ?? this.shapes,
      spacing: spacing ?? this.spacing,
      elevation: elevation ?? this.elevation,
      motion: motion ?? this.motion,
      tokenSets: tokenSets ?? this.tokenSets,
    );
  }

  /// The theme between [a] and [b] at [t]: colors, text styles, radii and sizes blend, easings and component
  /// overrides switch at the midpoint, and token sets blend by type.
  static CamoTheme lerp(CamoTheme a, CamoTheme b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    return CamoTheme(
      colors: CamoColors.lerp(a.colors, b.colors, t),
      typography: CamoTypography.lerp(a.typography, b.typography, t),
      components: t < 0.5 ? a.components : b.components,
      shapes: CamoShapes.lerp(a.shapes, b.shapes, t),
      spacing: CamoSpacing.lerp(a.spacing, b.spacing, t),
      elevation: CamoElevation.lerp(a.elevation, b.elevation, t),
      motion: CamoMotion.lerp(a.motion, b.motion, t),
      tokenSets: _lerpTokenSets(a.tokenSets, b.tokenSets, t),
    );
  }

  // Sets of the same type blend; a set only one theme has switches at the midpoint.
  static List<CamoTokenSet> _lerpTokenSets(
    List<CamoTokenSet> a,
    List<CamoTokenSet> b,
    double t,
  ) {
    final blended = <CamoTokenSet>[
      for (final to in b)
        if (a.where((from) => from.runtimeType == to.runtimeType).firstOrNull
            case final from?)
          (from as dynamic).lerp(to, t) as CamoTokenSet
        else if (t >= 0.5)
          to,
    ];
    final onlyInA = t < 0.5
        ? a.where((from) => b.every((to) => to.runtimeType != from.runtimeType))
        : const <CamoTokenSet>[];
    return [...blended, ...onlyInA];
  }

  @override
  bool operator ==(Object other) =>
      other is CamoTheme &&
      other.colors == colors &&
      other.typography == typography &&
      other.components == components &&
      other.shapes == shapes &&
      other.spacing == spacing &&
      other.elevation == elevation &&
      other.motion == motion &&
      listEquals(other.tokenSets, tokenSets);

  @override
  int get hashCode => Object.hash(
    colors,
    typography,
    components,
    shapes,
    spacing,
    elevation,
    motion,
    Object.hashAll(tokenSets),
  );
}
