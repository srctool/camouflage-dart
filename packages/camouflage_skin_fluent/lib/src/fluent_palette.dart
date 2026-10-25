import 'package:flutter/widgets.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

// Fluent 2's published color tokens (@fluentui/tokens 1.0.0-alpha.24: global/brandColors, global/colors).

/// Fluent's default brand color, `brandWeb[80]`.
const Color fluentBrandBlue = Color(0xFF0F6CBD);

// brandWeb, steps 10..160.
const _brandWeb = [
  Color(0xFF061724),
  Color(0xFF082338),
  Color(0xFF0A2E4A),
  Color(0xFF0C3B5E),
  Color(0xFF0E4775),
  Color(0xFF0F548C),
  Color(0xFF115EA3),
  Color(0xFF0F6CBD),
  Color(0xFF2886DE),
  Color(0xFF479EF5),
  Color(0xFF62ABF5),
  Color(0xFF77B7F7),
  Color(0xFF96C6FA),
  Color(0xFFB4D6FA),
  Color(0xFFCFE4FA),
  Color(0xFFEBF3FC),
];

/// A 16-step brand ramp, read by step (`ramp[80]` is the brand color). The default brand is Fluent's own
/// `brandWeb`; another brand keeps its hue and chroma at the tones of `brandWeb`'s steps, with step 80 being the
/// brand color itself.
class BrandRamp {
  BrandRamp._(this._steps);

  /// The ramp for [brand].
  factory BrandRamp.of(Color brand) {
    if (brand == fluentBrandBlue) return BrandRamp._(_brandWeb);
    final hct = Hct.fromInt(brand.toARGB32());
    final palette = TonalPalette.of(hct.hue, hct.chroma);
    return BrandRamp._([
      for (var i = 0; i < _brandWeb.length; i++)
        (i + 1) * 10 == 80
            ? brand
            : Color(
                palette.get(Hct.fromInt(_brandWeb[i].toARGB32()).tone.round()),
              ),
    ]);
  }

  final List<Color> _steps;

  /// The color at [step] (10..160).
  Color operator [](int step) => _steps[step ~/ 10 - 1];
}

/// Fluent's neutral `grey[n]`: n is the lightness percentage.
Color grey(int n) => _grey[n]!;

const _grey = {
  2: Color(0xFF050505),
  4: Color(0xFF0A0A0A),
  6: Color(0xFF0F0F0F),
  8: Color(0xFF141414),
  10: Color(0xFF1A1A1A),
  12: Color(0xFF1F1F1F),
  14: Color(0xFF242424),
  16: Color(0xFF292929),
  18: Color(0xFF2E2E2E),
  20: Color(0xFF333333),
  22: Color(0xFF383838),
  24: Color(0xFF3D3D3D),
  26: Color(0xFF424242),
  28: Color(0xFF474747),
  30: Color(0xFF4D4D4D),
  32: Color(0xFF525252),
  34: Color(0xFF575757),
  36: Color(0xFF5C5C5C),
  38: Color(0xFF616161),
  40: Color(0xFF666666),
  42: Color(0xFF6B6B6B),
  44: Color(0xFF707070),
  46: Color(0xFF757575),
  48: Color(0xFF7A7A7A),
  50: Color(0xFF808080),
  60: Color(0xFF999999),
  68: Color(0xFFADADAD),
  70: Color(0xFFB3B3B3),
  74: Color(0xFFBDBDBD),
  78: Color(0xFFC7C7C7),
  82: Color(0xFFD1D1D1),
  84: Color(0xFFD6D6D6),
  88: Color(0xFFE0E0E0),
  90: Color(0xFFE6E6E6),
  92: Color(0xFFEBEBEB),
  94: Color(0xFFF0F0F0),
  96: Color(0xFFF5F5F5),
  98: Color(0xFFFAFAFA),
};

/// The steps of a Fluent shared color that the status roles use; [foreground] is light mode's foreground1.
class Shared {
  /// Creates the steps.
  const Shared(
    this.shade40,
    this.foreground,
    this.primary,
    this.tint30,
    this.tint40,
    this.tint60,
  );

  /// The darkest step used (dark-mode containers).
  final Color shade40;

  /// Light mode's text on the tint.
  final Color foreground;

  /// The color itself.
  final Color primary;

  /// Dark mode's strong color.
  final Color tint30;

  /// Dark mode's text on containers.
  final Color tint40;

  /// Light mode's container.
  final Color tint60;
}

// The status mapping (statusColorMapping): danger = cranberry, success = green, warning = orange. Light mode's
// foreground1 is shade10, except warning's, which Fluent patches to shade20.
/// Fluent's danger palette.
const cranberry = Shared(
  Color(0xFF3B0509),
  Color(0xFFB10E1C),
  Color(0xFFC50F1F),
  Color(0xFFDC626D),
  Color(0xFFEEACB2),
  Color(0xFFFDF3F4),
);

/// Fluent's success palette.
const green = Shared(
  Color(0xFF052505),
  Color(0xFF0E700E),
  Color(0xFF107C10),
  Color(0xFF54B054),
  Color(0xFF9FD89F),
  Color(0xFFF1FAF1),
);

/// Fluent's warning palette.
const orange = Shared(
  Color(0xFF4A1E04),
  Color(0xFFBC4B09),
  Color(0xFFF7630C),
  Color(0xFFFAA06B),
  Color(0xFFFDCFB4),
  Color(0xFFFFF9F5),
);
