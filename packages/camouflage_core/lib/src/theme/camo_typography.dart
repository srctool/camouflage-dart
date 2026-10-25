import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 15 text styles: five roles × three sizes. Each is complete, weight included, so a component reads one constant.
/// Sizes are logical pixels, scaled by the user's text scaler in `Text`.
@immutable
class CamoTypography {
  /// Creates typography with every style given.
  const CamoTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  /// Camouflage's default scale (base Theme §3.5) in [fontFamily], or the platform font when `null`.
  factory CamoTypography.system({String? fontFamily}) {
    TextStyle style(double size, double lineHeight, FontWeight weight) =>
        TextStyle(
          fontFamily: fontFamily,
          fontWeight: weight,
          fontSize: size,
          height: lineHeight / size,
          letterSpacing: 0,
        );
    const strong = FontWeight.w600;
    const label = FontWeight.w500;
    const body = FontWeight.w400;
    return CamoTypography(
      displayLarge: style(48, 56, strong),
      displayMedium: style(40, 48, strong),
      displaySmall: style(32, 40, strong),
      headlineLarge: style(28, 36, strong),
      headlineMedium: style(24, 32, strong),
      headlineSmall: style(20, 28, strong),
      titleLarge: style(18, 26, strong),
      titleMedium: style(16, 24, strong),
      titleSmall: style(14, 20, strong),
      bodyLarge: style(16, 24, body),
      bodyMedium: style(14, 20, body),
      bodySmall: style(12, 16, body),
      labelLarge: style(14, 20, label),
      labelMedium: style(12, 16, label),
      labelSmall: style(11, 16, label),
    );
  }

  /// Hero numbers, splash text.
  final TextStyle displayLarge;

  /// The medium display style.
  final TextStyle displayMedium;

  /// The small display style.
  final TextStyle displaySmall;

  /// Screen titles in content.
  final TextStyle headlineLarge;

  /// The medium headline style.
  final TextStyle headlineMedium;

  /// Dialog titles.
  final TextStyle headlineSmall;

  /// Top bar titles.
  final TextStyle titleLarge;

  /// Card titles.
  final TextStyle titleMedium;

  /// The small title style.
  final TextStyle titleSmall;

  /// Paragraphs.
  final TextStyle bodyLarge;

  /// Default text.
  final TextStyle bodyMedium;

  /// Captions.
  final TextStyle bodySmall;

  /// Button text.
  final TextStyle labelLarge;

  /// Chips.
  final TextStyle labelMedium;

  /// Small tags.
  final TextStyle labelSmall;

  List<TextStyle> get _all => [
    displayLarge,
    displayMedium,
    displaySmall,
    headlineLarge,
    headlineMedium,
    headlineSmall, //
    titleLarge,
    titleMedium,
    titleSmall,
    bodyLarge,
    bodyMedium,
    bodySmall,
    labelLarge,
    labelMedium,
    labelSmall,
  ];

  /// A copy with the given styles replaced.
  CamoTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return CamoTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  /// Blends every style from [a] to [b] at [t].
  static CamoTypography lerp(CamoTypography a, CamoTypography b, double t) {
    TextStyle l(TextStyle x, TextStyle y) => TextStyle.lerp(x, y, t)!;
    return CamoTypography(
      displayLarge: l(a.displayLarge, b.displayLarge),
      displayMedium: l(a.displayMedium, b.displayMedium),
      displaySmall: l(a.displaySmall, b.displaySmall),
      headlineLarge: l(a.headlineLarge, b.headlineLarge),
      headlineMedium: l(a.headlineMedium, b.headlineMedium),
      headlineSmall: l(a.headlineSmall, b.headlineSmall),
      titleLarge: l(a.titleLarge, b.titleLarge),
      titleMedium: l(a.titleMedium, b.titleMedium),
      titleSmall: l(a.titleSmall, b.titleSmall),
      bodyLarge: l(a.bodyLarge, b.bodyLarge),
      bodyMedium: l(a.bodyMedium, b.bodyMedium),
      bodySmall: l(a.bodySmall, b.bodySmall),
      labelLarge: l(a.labelLarge, b.labelLarge),
      labelMedium: l(a.labelMedium, b.labelMedium),
      labelSmall: l(a.labelSmall, b.labelSmall),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CamoTypography && listEquals(other._all, _all);

  @override
  int get hashCode => Object.hashAll(_all);
}
