import 'package:flutter/widgets.dart';

import 'roles.dart';
import 'seed_scheme.dart';

/// The 42 color roles in 7 groups. `onX` is the color of content drawn on `x`.
///
/// Build them explicitly (every role), or from a few seeds with [CamoColors.fromSeed].
@immutable
class CamoColors {
  /// Creates colors with every role given.
  const CamoColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.scrim,
  });

  /// All 42 roles from a few seeds, with the tonal-palette algorithm (HCT) and Camouflage's tone table.
  ///
  /// - [secondary] / [tertiary]: `null` derives them from [primary]'s hue.
  /// - Status seeds: `null` uses Camouflage's default seeds.
  /// - [neutral]: `null` gives true grays (ADR-24). Pass [primary] for brand-tinted surfaces (Material style).
  factory CamoColors.fromSeed({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? neutral,
    Brightness brightness = Brightness.light,
  }) => SeedScheme.build(
    primary: primary,
    secondary: secondary,
    tertiary: tertiary,
    error: error,
    success: success,
    warning: warning,
    info: info,
    neutral: neutral,
    dark: brightness == Brightness.dark,
  );

  /// Main actions and selected areas.
  final Color primary;

  /// Content on primary.
  final Color onPrimary;

  /// Highlighted areas in the primary family.
  final Color primaryContainer;

  /// Content on primaryContainer.
  final Color onPrimaryContainer;

  /// Supporting actions.
  final Color secondary;

  /// Content on secondary.
  final Color onSecondary;

  /// Soft fills, filter chips, toggled icon backgrounds.
  final Color secondaryContainer;

  /// Content on secondaryContainer.
  final Color onSecondaryContainer;

  /// A third accent (a highlight badge, a chart series).
  final Color tertiary;

  /// Content on tertiary.
  final Color onTertiary;

  /// The tertiary container.
  final Color tertiaryContainer;

  /// Content on tertiaryContainer.
  final Color onTertiaryContainer;

  /// The default background of screens.
  final Color surface;

  /// The least separated container level.
  final Color surfaceContainerLowest;

  /// A low container level.
  final Color surfaceContainerLow;

  /// The middle container level.
  final Color surfaceContainer;

  /// A high container level.
  final Color surfaceContainerHigh;

  /// The most separated container level.
  final Color surfaceContainerHighest;

  /// Primary text and icons on any surface.
  final Color onSurface;

  /// Secondary text, placeholders, unselected icons.
  final Color onSurfaceVariant;

  /// Borders that must be seen.
  final Color outline;

  /// Decorative dividers and subtle borders.
  final Color outlineVariant;

  /// Errors and destructive actions.
  final Color error;

  /// Content on error.
  final Color onError;

  /// The error container.
  final Color errorContainer;

  /// Content on errorContainer.
  final Color onErrorContainer;

  /// Confirmations.
  final Color success;

  /// Content on success.
  final Color onSuccess;

  /// The success container.
  final Color successContainer;

  /// Content on successContainer.
  final Color onSuccessContainer;

  /// Cautions.
  final Color warning;

  /// Content on warning.
  final Color onWarning;

  /// The warning container.
  final Color warningContainer;

  /// Content on warningContainer.
  final Color onWarningContainer;

  /// Neutral information.
  final Color info;

  /// Content on info.
  final Color onInfo;

  /// The info container.
  final Color infoContainer;

  /// Content on infoContainer.
  final Color onInfoContainer;

  /// Elements on the opposite scheme (snackbars, tooltips).
  final Color inverseSurface;

  /// Content on inverseSurface.
  final Color inverseOnSurface;

  /// The action color on inverseSurface.
  final Color inversePrimary;

  /// The dim layer behind dialogs and sheets.
  final Color scrim;

  /// A copy with the given roles replaced.
  CamoColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? surface,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? inversePrimary,
    Color? scrim,
  }) {
    return CamoColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      surface: surface ?? this.surface,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      scrim: scrim ?? this.scrim,
    );
  }

  /// Blends every role from [a] to [b] at [t].
  static CamoColors lerp(CamoColors a, CamoColors b, double t) {
    return CamoColors(
      primary: Color.lerp(a.primary, b.primary, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      primaryContainer: Color.lerp(a.primaryContainer, b.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(
        a.onPrimaryContainer,
        b.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      onSecondary: Color.lerp(a.onSecondary, b.onSecondary, t)!,
      secondaryContainer: Color.lerp(
        a.secondaryContainer,
        b.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        a.onSecondaryContainer,
        b.onSecondaryContainer,
        t,
      )!,
      tertiary: Color.lerp(a.tertiary, b.tertiary, t)!,
      onTertiary: Color.lerp(a.onTertiary, b.onTertiary, t)!,
      tertiaryContainer: Color.lerp(
        a.tertiaryContainer,
        b.tertiaryContainer,
        t,
      )!,
      onTertiaryContainer: Color.lerp(
        a.onTertiaryContainer,
        b.onTertiaryContainer,
        t,
      )!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceContainerLowest: Color.lerp(
        a.surfaceContainerLowest,
        b.surfaceContainerLowest,
        t,
      )!,
      surfaceContainerLow: Color.lerp(
        a.surfaceContainerLow,
        b.surfaceContainerLow,
        t,
      )!,
      surfaceContainer: Color.lerp(a.surfaceContainer, b.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(
        a.surfaceContainerHigh,
        b.surfaceContainerHigh,
        t,
      )!,
      surfaceContainerHighest: Color.lerp(
        a.surfaceContainerHighest,
        b.surfaceContainerHighest,
        t,
      )!,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
      onSurfaceVariant: Color.lerp(a.onSurfaceVariant, b.onSurfaceVariant, t)!,
      outline: Color.lerp(a.outline, b.outline, t)!,
      outlineVariant: Color.lerp(a.outlineVariant, b.outlineVariant, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      onError: Color.lerp(a.onError, b.onError, t)!,
      errorContainer: Color.lerp(a.errorContainer, b.errorContainer, t)!,
      onErrorContainer: Color.lerp(a.onErrorContainer, b.onErrorContainer, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      onSuccess: Color.lerp(a.onSuccess, b.onSuccess, t)!,
      successContainer: Color.lerp(a.successContainer, b.successContainer, t)!,
      onSuccessContainer: Color.lerp(
        a.onSuccessContainer,
        b.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      onWarning: Color.lerp(a.onWarning, b.onWarning, t)!,
      warningContainer: Color.lerp(a.warningContainer, b.warningContainer, t)!,
      onWarningContainer: Color.lerp(
        a.onWarningContainer,
        b.onWarningContainer,
        t,
      )!,
      info: Color.lerp(a.info, b.info, t)!,
      onInfo: Color.lerp(a.onInfo, b.onInfo, t)!,
      infoContainer: Color.lerp(a.infoContainer, b.infoContainer, t)!,
      onInfoContainer: Color.lerp(a.onInfoContainer, b.onInfoContainer, t)!,
      inverseSurface: Color.lerp(a.inverseSurface, b.inverseSurface, t)!,
      inverseOnSurface: Color.lerp(a.inverseOnSurface, b.inverseOnSurface, t)!,
      inversePrimary: Color.lerp(a.inversePrimary, b.inversePrimary, t)!,
      scrim: Color.lerp(a.scrim, b.scrim, t)!,
    );
  }

  /// The family a [Tone] reads. `Tone.defaultTone` pairs [primary] with [secondaryContainer].
  ToneColors family(Tone tone) => switch (tone) {
    Tone.defaultTone => ToneColors(
      primary,
      onPrimary,
      secondaryContainer,
      onSecondaryContainer,
    ),
    Tone.error => ToneColors(error, onError, errorContainer, onErrorContainer),
    Tone.success => ToneColors(
      success,
      onSuccess,
      successContainer,
      onSuccessContainer,
    ),
    Tone.warning => ToneColors(
      warning,
      onWarning,
      warningContainer,
      onWarningContainer,
    ),
    Tone.info => ToneColors(info, onInfo, infoContainer, onInfoContainer),
  };

  @override
  bool operator ==(Object other) =>
      other is CamoColors &&
      other.primary == primary &&
      other.onPrimary == onPrimary &&
      other.primaryContainer == primaryContainer &&
      other.onPrimaryContainer == onPrimaryContainer &&
      other.secondary == secondary &&
      other.onSecondary == onSecondary &&
      other.secondaryContainer == secondaryContainer &&
      other.onSecondaryContainer == onSecondaryContainer &&
      other.tertiary == tertiary &&
      other.onTertiary == onTertiary &&
      other.tertiaryContainer == tertiaryContainer &&
      other.onTertiaryContainer == onTertiaryContainer &&
      other.surface == surface &&
      other.surfaceContainerLowest == surfaceContainerLowest &&
      other.surfaceContainerLow == surfaceContainerLow &&
      other.surfaceContainer == surfaceContainer &&
      other.surfaceContainerHigh == surfaceContainerHigh &&
      other.surfaceContainerHighest == surfaceContainerHighest &&
      other.onSurface == onSurface &&
      other.onSurfaceVariant == onSurfaceVariant &&
      other.outline == outline &&
      other.outlineVariant == outlineVariant &&
      other.error == error &&
      other.onError == onError &&
      other.errorContainer == errorContainer &&
      other.onErrorContainer == onErrorContainer &&
      other.success == success &&
      other.onSuccess == onSuccess &&
      other.successContainer == successContainer &&
      other.onSuccessContainer == onSuccessContainer &&
      other.warning == warning &&
      other.onWarning == onWarning &&
      other.warningContainer == warningContainer &&
      other.onWarningContainer == onWarningContainer &&
      other.info == info &&
      other.onInfo == onInfo &&
      other.infoContainer == infoContainer &&
      other.onInfoContainer == onInfoContainer &&
      other.inverseSurface == inverseSurface &&
      other.inverseOnSurface == inverseOnSurface &&
      other.inversePrimary == inversePrimary &&
      other.scrim == scrim;

  @override
  int get hashCode => Object.hashAll([
    primary,
    onPrimary,
    primaryContainer,
    onPrimaryContainer,
    secondary,
    onSecondary,
    secondaryContainer,
    onSecondaryContainer,
    tertiary,
    onTertiary,
    tertiaryContainer,
    onTertiaryContainer,
    surface,
    surfaceContainerLowest,
    surfaceContainerLow,
    surfaceContainer,
    surfaceContainerHigh,
    surfaceContainerHighest,
    onSurface,
    onSurfaceVariant,
    outline,
    outlineVariant,
    error,
    onError,
    errorContainer,
    onErrorContainer,
    success,
    onSuccess,
    successContainer,
    onSuccessContainer,
    warning,
    onWarning,
    warningContainer,
    onWarningContainer,
    info,
    onInfo,
    infoContainer,
    onInfoContainer,
    inverseSurface,
    inverseOnSurface,
    inversePrimary,
    scrim,
  ]);
}

/// One color family: the strong color, the content on it, the container, and the content on the container.
@immutable
class ToneColors {
  /// Creates a family.
  const ToneColors(
    this.strong,
    this.onStrong,
    this.container,
    this.onContainer,
  );

  /// The strong color (a Solid button's fill).
  final Color strong;

  /// Content on [strong].
  final Color onStrong;

  /// The container color (a Soft fill, a banner).
  final Color container;

  /// Content on [container].
  final Color onContainer;

  @override
  bool operator ==(Object other) =>
      other is ToneColors &&
      other.strong == strong &&
      other.onStrong == onStrong &&
      other.container == container &&
      other.onContainer == onContainer;

  @override
  int get hashCode => Object.hash(strong, onStrong, container, onContainer);
}
