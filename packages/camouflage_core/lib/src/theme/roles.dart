/// The corner-radius roles of `CamoShapes`.
enum ShapeRole {
  /// No rounding.
  none,

  /// 4 by default.
  extraSmall,

  /// 6 by default.
  small,

  /// 8 by default.
  medium,

  /// 12 by default.
  large,

  /// 16 by default.
  extraLarge,

  /// A pill or a circle.
  full,
}

/// The semantic depth levels of `CamoElevation`. How depth looks is the skin's surface treatment.
enum ElevationLevel {
  /// Flat.
  level0,

  /// A resting card.
  level1,

  /// A top bar when scrolled.
  level2,

  /// A raised card.
  level3,

  /// Hovered raised elements.
  level4,

  /// A dialog.
  level5,
}

/// The status a tone-aware component expresses. Each tone reads one color family (`CamoColors.family`).
enum Tone {
  /// The brand family (`default` is a Dart keyword).
  defaultTone,

  /// Errors and destructive actions.
  error,

  /// Confirmations.
  success,

  /// Cautions.
  warning,

  /// Neutral information.
  info,
}

/// How separated a surface is from the screen background, from `surface` to `surfaceContainerHighest`.
enum SurfaceLevel {
  /// The screen background.
  surface,

  /// `surfaceContainerLowest`.
  lowest,

  /// `surfaceContainerLow`.
  low,

  /// `surfaceContainer`.
  container,

  /// `surfaceContainerHigh`.
  high,

  /// `surfaceContainerHighest`.
  highest,
}
