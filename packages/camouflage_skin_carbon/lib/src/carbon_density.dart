import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// Carbon's control sizes (base Carbon Skin §3.5): [xs] 24, [sm] 32, [md] 40 and [lg] 48 logical pixels. Desktop
/// apps live at [sm] and [md]; [lg] is Carbon's large size and the touch default. `xs` is a Camouflage extension
/// (Carbon's own buttons start at `sm`). The sizes are minimums: larger text still grows a control, and a touch
/// target stays 48.
enum CarbonDensity {
  /// 24, with 12 point text.
  xs(24),

  /// 32.
  sm(32),

  /// 40, the pointer default.
  md(40),

  /// 48, the touch default and what Carbon drew before density.
  lg(48);

  const CarbonDensity(this.size);

  /// The control height.
  final double size;
}

/// The theme's [density], read by the renderers (`theme.tokens<CarbonDensityTokens>()`). One value for every
/// control, so a size is decided in one place; a component theme override still wins for one component.
@immutable
class CarbonDensityTokens extends CamoTokenSet<CarbonDensityTokens> {
  /// Creates the tokens.
  const CarbonDensityTokens(this.density);

  /// The density every control follows.
  final CarbonDensity density;

  @override
  CarbonDensityTokens lerp(CarbonDensityTokens other, double t) =>
      t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is CarbonDensityTokens && other.density == density;

  @override
  int get hashCode => density.hashCode;
}

/// The theme's density: [CarbonDensity.lg] (what Carbon drew before) without the tokens.
extension CarbonThemeDensity on CamoTheme {
  /// The density the skin draws at.
  CarbonDensity get carbonDensity =>
      tokens<CarbonDensityTokens>()?.density ?? CarbonDensity.lg;
}

/// Carbon's body-compact-01 is 14; [CarbonDensity.xs] draws 12.
extension CarbonDensityText on TextStyle {
  /// This style at [density]'s text size.
  TextStyle forDensity(CarbonDensity density) =>
      density == CarbonDensity.xs ? copyWith(fontSize: 12) : this;
}
