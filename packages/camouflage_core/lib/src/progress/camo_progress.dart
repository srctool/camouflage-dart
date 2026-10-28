import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// A progress circle's size.
enum ProgressSize {
  /// The smallest (a loading button).
  small,

  /// The default.
  medium,

  /// The largest.
  large,
}

/// The active part and the track of an indicator.
@immutable
class ProgressColors {
  /// Creates progress colors.
  const ProgressColors({required this.active, required this.track});

  /// The active part.
  final Color active;

  /// The track.
  final Color track;

  @override
  bool operator ==(Object other) =>
      other is ProgressColors && other.active == active && other.track == track;

  @override
  int get hashCode => Object.hash(active, track);
}

/// Overrides for progress indicators, circles and bars; `null` keeps the skin's default.
@immutable
class CamoProgressTheme {
  /// Creates progress overrides.
  const CamoProgressTheme({
    this.circleStroke,
    this.circleSizeSmall,
    this.circleSizeMedium,
    this.circleSizeLarge,
    this.colors,
    this.barHeight,
    this.trackGap,
    this.showStopIndicator,
  });

  /// The circle's stroke.
  final double? circleStroke;

  /// The small diameter.
  final double? circleSizeSmall;

  /// The medium diameter.
  final double? circleSizeMedium;

  /// The large diameter.
  final double? circleSizeLarge;

  /// The colors for the default tone.
  final ProgressColors? colors;

  /// A bar's thickness.
  final double? barHeight;

  /// The gap between a bar's active part and its track (0: they touch).
  final double? trackGap;

  /// An end dot on determinate bars.
  final bool? showStopIndicator;

  /// A copy with the given fields replaced.
  CamoProgressTheme copyWith({
    double? circleStroke,
    double? circleSizeSmall,
    double? circleSizeMedium,
    double? circleSizeLarge,
    ProgressColors? colors,
    double? barHeight,
    double? trackGap,
    bool? showStopIndicator,
  }) => CamoProgressTheme(
    circleStroke: circleStroke ?? this.circleStroke,
    circleSizeSmall: circleSizeSmall ?? this.circleSizeSmall,
    circleSizeMedium: circleSizeMedium ?? this.circleSizeMedium,
    circleSizeLarge: circleSizeLarge ?? this.circleSizeLarge,
    colors: colors ?? this.colors,
    barHeight: barHeight ?? this.barHeight,
    trackGap: trackGap ?? this.trackGap,
    showStopIndicator: showStopIndicator ?? this.showStopIndicator,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoProgressTheme &&
      other.circleStroke == circleStroke &&
      other.circleSizeSmall == circleSizeSmall &&
      other.circleSizeMedium == circleSizeMedium &&
      other.circleSizeLarge == circleSizeLarge &&
      other.colors == colors &&
      other.barHeight == barHeight &&
      other.trackGap == trackGap &&
      other.showStopIndicator == showStopIndicator;

  @override
  int get hashCode => Object.hash(
    circleStroke,
    circleSizeSmall,
    circleSizeMedium,
    circleSizeLarge,
    colors,
    barHeight,
    trackGap,
    showStopIndicator,
  );
}

/// The resolved progress style: every field set. [colors] is for the default tone; status tones use their family.
@immutable
class CamoProgressStyle {
  /// Creates a progress style.
  const CamoProgressStyle({
    required this.circleStroke,
    required this.circleSizeSmall,
    required this.circleSizeMedium,
    required this.circleSizeLarge,
    required this.colors,
    required this.barHeight,
    required this.trackGap,
    required this.showStopIndicator,
  });

  /// The circle's stroke.
  final double circleStroke;

  /// The small diameter.
  final double circleSizeSmall;

  /// The medium diameter.
  final double circleSizeMedium;

  /// The large diameter.
  final double circleSizeLarge;

  /// The colors for the default tone.
  final ProgressColors colors;

  /// A bar's thickness.
  final double barHeight;

  /// The gap between a bar's active part and its track (0: they touch).
  final double trackGap;

  /// An end dot on determinate bars.
  final bool showStopIndicator;

  /// This style with [o]'s non-null fields applied.
  CamoProgressStyle merge(CamoProgressTheme? o) => o == null
      ? this
      : CamoProgressStyle(
          circleStroke: o.circleStroke ?? circleStroke,
          circleSizeSmall: o.circleSizeSmall ?? circleSizeSmall,
          circleSizeMedium: o.circleSizeMedium ?? circleSizeMedium,
          circleSizeLarge: o.circleSizeLarge ?? circleSizeLarge,
          colors: o.colors ?? colors,
          barHeight: o.barHeight ?? barHeight,
          trackGap: o.trackGap ?? trackGap,
          showStopIndicator: o.showStopIndicator ?? showStopIndicator,
        );

  /// The diameter for [size].
  double circleSizeOf(ProgressSize size) => switch (size) {
    ProgressSize.small => circleSizeSmall,
    ProgressSize.medium => circleSizeMedium,
    ProgressSize.large => circleSizeLarge,
  };

  /// The active and track colors for [tone]: this style's for the default tone, the tone's strong color otherwise.
  ProgressColors colorsFor(Tone tone, CamoTheme theme) =>
      tone == Tone.defaultTone
      ? colors
      : ProgressColors(
          active: theme.colors.family(tone).strong,
          track: colors.track,
        );
}

/// What a progress renderer draws. `value == null` is indeterminate; otherwise it's in `0..1`.
@immutable
class ProgressState {
  /// Creates a progress state.
  const ProgressState({
    required this.value,
    required this.tone,
    required this.size,
  });

  /// The fraction done, or `null`.
  final double? value;

  /// The color family.
  final Tone tone;

  /// The circle's size.
  final ProgressSize size;
}

/// Draws progress circles. Indeterminate circles animate with `theme.motion`; when its durations are zero
/// (reduced motion), they pulse slowly instead of moving.
abstract interface class CamoProgressCircleRenderer {
  /// The complete progress style for [theme].
  CamoProgressStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  );
}

/// A circular progress indicator. `value == null` spins; a value is clamped to `0..1`.
class CamoProgressCircle extends StatelessWidget {
  /// Creates a progress circle.
  const CamoProgressCircle({
    super.key,
    this.value,
    this.tone = Tone.defaultTone,
    this.size = ProgressSize.medium,
    this.semanticLabel,
  });

  /// The fraction done, or `null` for indeterminate.
  final double? value;

  /// The color family.
  final Tone tone;

  /// The size.
  final ProgressSize size;

  /// The accessible name ("Uploading photo").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoProgressCircle');
    final theme = Camouflage.themeOf(context, component: 'CamoProgressCircle');
    final style = skin.progressCircle
        .defaults(theme)
        .merge(theme.components.progress);
    final clamped = value?.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: clamped == null ? null : '${(clamped * 100).round()}%',
      child: skin.progressCircle.render(
        context,
        ProgressState(value: clamped, tone: tone, size: size),
        theme,
        style,
      ),
    );
  }
}

/// Draws progress bars, across the width they're given at the style's bar height, filling from the start (the
/// right in right-to-left layouts). Indeterminate bars animate with `theme.motion`; when its durations are zero
/// (reduced motion), they pulse slowly instead of moving. A change of value animates over `durationMedium`.
abstract interface class CamoProgressBarRenderer {
  /// The complete progress style for [theme] (the same style as the circle's).
  CamoProgressStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    ProgressState state,
    CamoTheme theme,
    CamoProgressStyle style,
  );
}

/// A linear progress indicator, as wide as its parent allows. `value == null` is indeterminate (loading); a
/// value is clamped to `0..1` (an upload at 40%). [tone] colors a failing upload; [semanticLabel] names it ("Uploading
/// photo"). Value changes aren't announced as they happen: announce the milestones ("Upload complete").
class CamoProgressBar extends StatelessWidget {
  /// Creates a progress bar.
  const CamoProgressBar({
    super.key,
    this.value,
    this.tone = Tone.defaultTone,
    this.semanticLabel,
  });

  /// The fraction done, or  for indeterminate.
  final double? value;

  /// The color family.
  final Tone tone;

  /// The accessible name ("Uploading photo").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoProgressBar');
    final theme = Camouflage.themeOf(context, component: 'CamoProgressBar');
    final style = skin.progressBar
        .defaults(theme)
        .merge(theme.components.progress);
    final clamped = value?.clamp(0.0, 1.0);
    return Semantics(
      container: true,
      label: semanticLabel,
      value: clamped == null ? null : '${(clamped * 100).round()}%',
      child: skin.progressBar.render(
        context,
        ProgressState(value: clamped, tone: tone, size: ProgressSize.medium),
        theme,
        style,
      ),
    );
  }
}
