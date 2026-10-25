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

/// Overrides for progress indicators; `null` keeps the skin's default. The bar's fields join with
/// `CamoProgressBar` (M7, ADR-39).
@immutable
class CamoProgressTheme {
  /// Creates progress overrides.
  const CamoProgressTheme({
    this.circleStroke,
    this.circleSizeSmall,
    this.circleSizeMedium,
    this.circleSizeLarge,
    this.colors,
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

  @override
  bool operator ==(Object other) =>
      other is CamoProgressTheme &&
      other.circleStroke == circleStroke &&
      other.circleSizeSmall == circleSizeSmall &&
      other.circleSizeMedium == circleSizeMedium &&
      other.circleSizeLarge == circleSizeLarge &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    circleStroke,
    circleSizeSmall,
    circleSizeMedium,
    circleSizeLarge,
    colors,
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

  /// This style with [o]'s non-null fields applied.
  CamoProgressStyle merge(CamoProgressTheme? o) => o == null
      ? this
      : CamoProgressStyle(
          circleStroke: o.circleStroke ?? circleStroke,
          circleSizeSmall: o.circleSizeSmall ?? circleSizeSmall,
          circleSizeMedium: o.circleSizeMedium ?? circleSizeMedium,
          circleSizeLarge: o.circleSizeLarge ?? circleSizeLarge,
          colors: o.colors ?? colors,
        );

  /// The diameter for [size].
  double circleSizeOf(ProgressSize size) => switch (size) {
    ProgressSize.small => circleSizeSmall,
    ProgressSize.medium => circleSizeMedium,
    ProgressSize.large => circleSizeLarge,
  };
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
