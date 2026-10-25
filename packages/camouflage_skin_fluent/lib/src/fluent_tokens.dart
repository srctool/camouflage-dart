import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Fluent's explicit state steps, which core's roles don't cover: Fluent shows hover and press by swapping to the
/// next token, not with an overlay. `fluentTheme` adds them to its theme; renderers read them with
/// `theme.tokens<FluentTokens>()`.
@immutable
class FluentTokens extends CamoTokenSet<FluentTokens> {
  /// Creates the tokens.
  const FluentTokens({
    required this.brandBackground,
    required this.brandBackgroundHover,
    required this.brandBackgroundPressed,
    required this.neutralForegroundOnBrand,
    required this.neutralBackground1Hover,
    required this.neutralBackground1Pressed,
    required this.subtleBackgroundHover,
    required this.subtleBackgroundPressed,
    required this.neutralForeground2Hover,
    required this.neutralStroke1,
    required this.neutralStroke1Hover,
    required this.neutralStroke1Pressed,
    required this.neutralStroke2,
    required this.brandForegroundLinkHover,
    required this.brandForegroundLinkPressed,
    required this.strokeFocus1,
    required this.strokeFocus2,
    required this.shadowAmbient,
    required this.shadowKey,
  });

  /// The filled brand background (primary buttons).
  final Color brandBackground;

  /// [brandBackground] hovered.
  final Color brandBackgroundHover;

  /// [brandBackground] pressed.
  final Color brandBackgroundPressed;

  /// Text and icons on [brandBackground] (white in both modes).
  final Color neutralForegroundOnBrand;

  /// The default background hovered.
  final Color neutralBackground1Hover;

  /// The default background pressed.
  final Color neutralBackground1Pressed;

  /// A subtle (transparent) control hovered.
  final Color subtleBackgroundHover;

  /// A subtle (transparent) control pressed.
  final Color subtleBackgroundPressed;

  /// Secondary text on hover.
  final Color neutralForeground2Hover;

  /// The default control border.
  final Color neutralStroke1;

  /// [neutralStroke1] hovered.
  final Color neutralStroke1Hover;

  /// [neutralStroke1] pressed.
  final Color neutralStroke1Pressed;

  /// Dividers.
  final Color neutralStroke2;

  /// Links hovered.
  final Color brandForegroundLinkHover;

  /// Links pressed.
  final Color brandForegroundLinkPressed;

  /// The focus indicator's inner stroke (1 px, light in light mode).
  final Color strokeFocus1;

  /// The focus indicator's outer stroke (2 px, dark in light mode).
  final Color strokeFocus2;

  /// The ambient shadow's color.
  final Color shadowAmbient;

  /// The key shadow's color.
  final Color shadowKey;

  @override
  FluentTokens lerp(FluentTokens other, double t) => FluentTokens(
    brandBackground: Color.lerp(brandBackground, other.brandBackground, t)!,
    brandBackgroundHover: Color.lerp(
      brandBackgroundHover,
      other.brandBackgroundHover,
      t,
    )!,
    brandBackgroundPressed: Color.lerp(
      brandBackgroundPressed,
      other.brandBackgroundPressed,
      t,
    )!,
    neutralForegroundOnBrand: Color.lerp(
      neutralForegroundOnBrand,
      other.neutralForegroundOnBrand,
      t,
    )!,
    neutralBackground1Hover: Color.lerp(
      neutralBackground1Hover,
      other.neutralBackground1Hover,
      t,
    )!,
    neutralBackground1Pressed: Color.lerp(
      neutralBackground1Pressed,
      other.neutralBackground1Pressed,
      t,
    )!,
    subtleBackgroundHover: Color.lerp(
      subtleBackgroundHover,
      other.subtleBackgroundHover,
      t,
    )!,
    subtleBackgroundPressed: Color.lerp(
      subtleBackgroundPressed,
      other.subtleBackgroundPressed,
      t,
    )!,
    neutralForeground2Hover: Color.lerp(
      neutralForeground2Hover,
      other.neutralForeground2Hover,
      t,
    )!,
    neutralStroke1: Color.lerp(neutralStroke1, other.neutralStroke1, t)!,
    neutralStroke1Hover: Color.lerp(
      neutralStroke1Hover,
      other.neutralStroke1Hover,
      t,
    )!,
    neutralStroke1Pressed: Color.lerp(
      neutralStroke1Pressed,
      other.neutralStroke1Pressed,
      t,
    )!,
    neutralStroke2: Color.lerp(neutralStroke2, other.neutralStroke2, t)!,
    brandForegroundLinkHover: Color.lerp(
      brandForegroundLinkHover,
      other.brandForegroundLinkHover,
      t,
    )!,
    brandForegroundLinkPressed: Color.lerp(
      brandForegroundLinkPressed,
      other.brandForegroundLinkPressed,
      t,
    )!,
    strokeFocus1: Color.lerp(strokeFocus1, other.strokeFocus1, t)!,
    strokeFocus2: Color.lerp(strokeFocus2, other.strokeFocus2, t)!,
    shadowAmbient: Color.lerp(shadowAmbient, other.shadowAmbient, t)!,
    shadowKey: Color.lerp(shadowKey, other.shadowKey, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is FluentTokens &&
      other.brandBackground == brandBackground &&
      other.brandBackgroundHover == brandBackgroundHover &&
      other.brandBackgroundPressed == brandBackgroundPressed &&
      other.neutralForegroundOnBrand == neutralForegroundOnBrand &&
      other.neutralBackground1Hover == neutralBackground1Hover &&
      other.neutralBackground1Pressed == neutralBackground1Pressed &&
      other.subtleBackgroundHover == subtleBackgroundHover &&
      other.subtleBackgroundPressed == subtleBackgroundPressed &&
      other.neutralForeground2Hover == neutralForeground2Hover &&
      other.neutralStroke1 == neutralStroke1 &&
      other.neutralStroke1Hover == neutralStroke1Hover &&
      other.neutralStroke1Pressed == neutralStroke1Pressed &&
      other.neutralStroke2 == neutralStroke2 &&
      other.brandForegroundLinkHover == brandForegroundLinkHover &&
      other.brandForegroundLinkPressed == brandForegroundLinkPressed &&
      other.strokeFocus1 == strokeFocus1 &&
      other.strokeFocus2 == strokeFocus2 &&
      other.shadowAmbient == shadowAmbient &&
      other.shadowKey == shadowKey;

  @override
  int get hashCode => Object.hashAll([
    brandBackground,
    brandBackgroundHover,
    brandBackgroundPressed,
    neutralForegroundOnBrand,
    neutralBackground1Hover,
    neutralBackground1Pressed,
    subtleBackgroundHover,
    subtleBackgroundPressed,
    neutralForeground2Hover,
    neutralStroke1,
    neutralStroke1Hover,
    neutralStroke1Pressed,
    neutralStroke2,
    brandForegroundLinkHover,
    brandForegroundLinkPressed,
    strokeFocus1,
    strokeFocus2,
    shadowAmbient,
    shadowKey,
  ]);
}
