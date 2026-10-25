import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'roles.dart';

/// Corner radii by role. The kind of corner (round or continuous) is the skin's decision.
@immutable
class CamoShapes {
  /// Creates shapes; the defaults are Camouflage's (ADR-24).
  const CamoShapes({
    this.none = BorderRadius.zero,
    this.extraSmall = const BorderRadius.all(Radius.circular(4)),
    this.small = const BorderRadius.all(Radius.circular(6)),
    this.medium = const BorderRadius.all(Radius.circular(8)),
    this.large = const BorderRadius.all(Radius.circular(12)),
    this.extraLarge = const BorderRadius.all(Radius.circular(16)),
    this.full = const BorderRadius.all(Radius.circular(1000)),
  });

  /// Full-bleed surfaces.
  final BorderRadius none;

  /// Checkboxes, small tags.
  final BorderRadius extraSmall;

  /// Chips, snackbars, menus.
  final BorderRadius small;

  /// Buttons, text fields, cards.
  final BorderRadius medium;

  /// Large cards, dialogs.
  final BorderRadius large;

  /// Sheets.
  final BorderRadius extraLarge;

  /// A pill or a circle: a large radius, clamped by the box.
  final BorderRadius full;

  List<BorderRadius> get _all => [
    none,
    extraSmall,
    small,
    medium,
    large,
    extraLarge,
    full,
  ];

  /// The radius for a [ShapeRole].
  BorderRadius of(ShapeRole role) => switch (role) {
    ShapeRole.none => none,
    ShapeRole.extraSmall => extraSmall,
    ShapeRole.small => small,
    ShapeRole.medium => medium,
    ShapeRole.large => large,
    ShapeRole.extraLarge => extraLarge,
    ShapeRole.full => full,
  };

  /// Blends every radius from [a] to [b] at [t].
  static CamoShapes lerp(CamoShapes a, CamoShapes b, double t) {
    BorderRadius l(BorderRadius x, BorderRadius y) =>
        BorderRadius.lerp(x, y, t)!;
    return CamoShapes(
      none: l(a.none, b.none),
      extraSmall: l(a.extraSmall, b.extraSmall),
      small: l(a.small, b.small),
      medium: l(a.medium, b.medium),
      large: l(a.large, b.large),
      extraLarge: l(a.extraLarge, b.extraLarge),
      full: l(a.full, b.full),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CamoShapes && listEquals(other._all, _all);

  @override
  int get hashCode => Object.hashAll(_all);
}

/// Spacing roles on a 4-point grid, in logical pixels. Renderers use these, never raw numbers.
@immutable
class CamoSpacing {
  /// Creates spacing; the defaults are Camouflage's.
  const CamoSpacing({
    this.none = 0,
    this.xxs = 2,
    this.xs = 4,
    this.s = 8,
    this.m = 12,
    this.l = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  /// A named zero.
  final double none;

  /// 2 by default.
  final double xxs;

  /// 4 by default.
  final double xs;

  /// 8 by default.
  final double s;

  /// 12 by default.
  final double m;

  /// 16 by default.
  final double l;

  /// 24 by default.
  final double xl;

  /// 32 by default.
  final double xxl;

  /// Every role by name, for validation.
  Map<String, double> get named => {
    'none': none,
    'xxs': xxs,
    'xs': xs,
    's': s,
    'm': m,
    'l': l,
    'xl': xl,
    'xxl': xxl,
  };

  /// Blends every role from [a] to [b] at [t].
  static CamoSpacing lerp(CamoSpacing a, CamoSpacing b, double t) {
    double v(double x, double y) => lerpDouble(x, y, t)!;
    return CamoSpacing(
      none: v(a.none, b.none),
      xxs: v(a.xxs, b.xxs),
      xs: v(a.xs, b.xs),
      s: v(a.s, b.s),
      m: v(a.m, b.m),
      l: v(a.l, b.l),
      xl: v(a.xl, b.xl),
      xxl: v(a.xxl, b.xxl),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CamoSpacing && mapEquals(other.named, named);

  @override
  int get hashCode => Object.hashAll(named.values);
}

/// Semantic depth, not a shadow: each skin's surface treatment decides how depth looks.
@immutable
class CamoElevation {
  /// Creates elevation levels; the defaults are Camouflage's.
  const CamoElevation({
    this.level0 = 0,
    this.level1 = 1,
    this.level2 = 3,
    this.level3 = 6,
    this.level4 = 8,
    this.level5 = 12,
  });

  /// Flat.
  final double level0;

  /// A resting card.
  final double level1;

  /// A top bar when scrolled.
  final double level2;

  /// A raised card.
  final double level3;

  /// Hovered raised elements.
  final double level4;

  /// A dialog.
  final double level5;

  /// Every level by name, for validation.
  Map<String, double> get named => {
    'level0': level0, 'level1': level1, 'level2': level2, //
    'level3': level3, 'level4': level4, 'level5': level5,
  };

  /// The highest level whose depth is at most [elevation], for surface treatments that draw by level.
  ElevationLevel levelOf(double elevation) => ElevationLevel.values.lastWhere(
    (l) => of(l) <= elevation,
    orElse: () => ElevationLevel.level0,
  );

  /// The depth for an [ElevationLevel].
  double of(ElevationLevel level) => switch (level) {
    ElevationLevel.level0 => level0,
    ElevationLevel.level1 => level1,
    ElevationLevel.level2 => level2,
    ElevationLevel.level3 => level3,
    ElevationLevel.level4 => level4,
    ElevationLevel.level5 => level5,
  };

  /// Blends every level from [a] to [b] at [t].
  static CamoElevation lerp(CamoElevation a, CamoElevation b, double t) {
    double v(double x, double y) => lerpDouble(x, y, t)!;
    return CamoElevation(
      level0: v(a.level0, b.level0),
      level1: v(a.level1, b.level1),
      level2: v(a.level2, b.level2),
      level3: v(a.level3, b.level3),
      level4: v(a.level4, b.level4),
      level5: v(a.level5, b.level5),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CamoElevation && mapEquals(other.named, named);

  @override
  int get hashCode => Object.hashAll(named.values);
}

/// Durations and the two easings.
@immutable
class CamoMotion {
  /// Creates motion; the defaults are Camouflage's.
  const CamoMotion({
    this.durationShort = const Duration(milliseconds: 120),
    this.durationMedium = const Duration(milliseconds: 200),
    this.durationLong = const Duration(milliseconds: 300),
    this.easingStandard = const Cubic(0.2, 0, 0, 1),
    this.easingEmphasized = const Cubic(0.05, 0.7, 0.1, 1),
  });

  /// Small state changes.
  final Duration durationShort;

  /// Most transitions.
  final Duration durationMedium;

  /// Large movements (sheets, dialogs).
  final Duration durationLong;

  /// The default easing.
  final Curve easingStandard;

  /// The easing for prominent movements.
  final Curve easingEmphasized;

  /// A copy with the given values replaced.
  CamoMotion copyWith({
    Duration? durationShort,
    Duration? durationMedium,
    Duration? durationLong,
    Curve? easingStandard,
    Curve? easingEmphasized,
  }) {
    return CamoMotion(
      durationShort: durationShort ?? this.durationShort,
      durationMedium: durationMedium ?? this.durationMedium,
      durationLong: durationLong ?? this.durationLong,
      easingStandard: easingStandard ?? this.easingStandard,
      easingEmphasized: easingEmphasized ?? this.easingEmphasized,
    );
  }

  /// The motion for "reduce motion": every duration is zero.
  CamoMotion reduced() => copyWith(
    durationShort: Duration.zero,
    durationMedium: Duration.zero,
    durationLong: Duration.zero,
  );

  /// Durations interpolate; easings switch at the midpoint.
  static CamoMotion lerp(CamoMotion a, CamoMotion b, double t) {
    Duration d(Duration x, Duration y) => Duration(
      microseconds: lerpDouble(x.inMicroseconds, y.inMicroseconds, t)!.round(),
    );
    return CamoMotion(
      durationShort: d(a.durationShort, b.durationShort),
      durationMedium: d(a.durationMedium, b.durationMedium),
      durationLong: d(a.durationLong, b.durationLong),
      easingStandard: t < 0.5 ? a.easingStandard : b.easingStandard,
      easingEmphasized: t < 0.5 ? a.easingEmphasized : b.easingEmphasized,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CamoMotion &&
      other.durationShort == durationShort &&
      other.durationMedium == durationMedium &&
      other.durationLong == durationLong &&
      other.easingStandard == easingStandard &&
      other.easingEmphasized == easingEmphasized;

  @override
  int get hashCode => Object.hash(
    durationShort,
    durationMedium,
    durationLong,
    easingStandard,
    easingEmphasized,
  );
}
