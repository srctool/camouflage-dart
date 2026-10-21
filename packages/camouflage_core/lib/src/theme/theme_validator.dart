import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'camo_theme.dart';

/// A problem `CamoTheme.validate` found.
@immutable
sealed class ThemeIssue {
  const ThemeIssue();
}

/// A content color below the required contrast on its background.
/// [pair] is `"onX/x"`; WCAG 2.2 AA asks for 4.5:1 for text and 3:1 for non-text.
final class LowContrast extends ThemeIssue {
  /// Creates the issue.
  const LowContrast(this.pair, this.ratio, this.required);

  /// The two roles, content first.
  final String pair;

  /// The measured ratio.
  final double ratio;

  /// The ratio the pair needs.
  final double required;

  @override
  bool operator ==(Object other) =>
      other is LowContrast &&
      other.pair == pair &&
      other.ratio == ratio &&
      other.required == required;

  @override
  int get hashCode => Object.hash(pair, ratio, required);

  @override
  String toString() =>
      'LowContrast($pair, ${ratio.toStringAsFixed(2)} < $required)';
}

/// A negative radius, spacing, elevation or duration.
final class InvalidValue extends ThemeIssue {
  /// Creates the issue.
  const InvalidValue(this.token, this.value);

  /// The token's path, e.g. `spacing.m`.
  final String token;

  /// The invalid value.
  final Object value;

  @override
  bool operator ==(Object other) =>
      other is InvalidValue && other.token == token && other.value == value;

  @override
  int get hashCode => Object.hash(token, value);

  @override
  String toString() => 'InvalidValue($token, $value)';
}

/// Two token sets of the same type: the first one found shadows the other.
final class ShadowedRole extends ThemeIssue {
  /// Creates the issue.
  const ShadowedRole(this.key);

  /// The shadowed key, e.g. `tokenSets.BrandTokens`.
  final String key;

  @override
  bool operator ==(Object other) => other is ShadowedRole && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'ShadowedRole($key)';
}

/// A component size below the 48 touch target where the component needs one (checked from M3).
final class SmallTarget extends ThemeIssue {
  /// Creates the issue.
  const SmallTarget(this.component, this.size);

  /// The component theme's path, e.g. `components.iconButton`.
  final String component;

  /// The size it sets.
  final double size;

  @override
  bool operator ==(Object other) =>
      other is SmallTarget &&
      other.component == component &&
      other.size == size;

  @override
  int get hashCode => Object.hash(component, size);

  @override
  String toString() => 'SmallTarget($component, $size)';
}

/// The WCAG contrast ratio of two colors, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance() + 0.05;
  final l2 = b.computeLuminance() + 0.05;
  return math.max(l1, l2) / math.min(l1, l2);
}

/// The checks behind `CamoTheme.validate` (base Theme §3.13).
abstract final class ThemeValidator {
  static const double _text = 4.5;
  static const double _nonText = 3;

  /// Every issue in [theme]; empty when it's clean.
  static List<ThemeIssue> validate(CamoTheme theme) {
    final issues = <ThemeIssue>[];
    final c = theme.colors;
    void check(String pair, Color content, Color background, double required) {
      final ratio = contrastRatio(content, background);
      if (ratio < required) issues.add(LowContrast(pair, ratio, required));
    }

    // Every onX on its x.
    final pairs = <(String, Color, Color)>[
      ('onPrimary/primary', c.onPrimary, c.primary),
      (
        'onPrimaryContainer/primaryContainer',
        c.onPrimaryContainer,
        c.primaryContainer,
      ),
      ('onSecondary/secondary', c.onSecondary, c.secondary),
      (
        'onSecondaryContainer/secondaryContainer',
        c.onSecondaryContainer,
        c.secondaryContainer,
      ),
      ('onTertiary/tertiary', c.onTertiary, c.tertiary),
      (
        'onTertiaryContainer/tertiaryContainer',
        c.onTertiaryContainer,
        c.tertiaryContainer,
      ),
      ('onError/error', c.onError, c.error),
      ('onErrorContainer/errorContainer', c.onErrorContainer, c.errorContainer),
      ('onSuccess/success', c.onSuccess, c.success),
      (
        'onSuccessContainer/successContainer',
        c.onSuccessContainer,
        c.successContainer,
      ),
      ('onWarning/warning', c.onWarning, c.warning),
      (
        'onWarningContainer/warningContainer',
        c.onWarningContainer,
        c.warningContainer,
      ),
      ('onInfo/info', c.onInfo, c.info),
      ('onInfoContainer/infoContainer', c.onInfoContainer, c.infoContainer),
      ('inverseOnSurface/inverseSurface', c.inverseOnSurface, c.inverseSurface),
    ];
    for (final (pair, content, background) in pairs) {
      check(pair, content, background, _text);
    }

    // Text on every surface level.
    final surfaces = <String, Color>{
      'surface': c.surface,
      'surfaceContainerLowest': c.surfaceContainerLowest,
      'surfaceContainerLow': c.surfaceContainerLow,
      'surfaceContainer': c.surfaceContainer,
      'surfaceContainerHigh': c.surfaceContainerHigh,
      'surfaceContainerHighest': c.surfaceContainerHighest,
    };
    surfaces.forEach((name, background) {
      check('onSurface/$name', c.onSurface, background, _text);
      check('onSurfaceVariant/$name', c.onSurfaceVariant, background, _text);
    });
    check('outline/surface', c.outline, c.surface, _nonText);

    // Values that can't be negative.
    theme.spacing.named.forEach((k, v) {
      if (v < 0) issues.add(InvalidValue('spacing.$k', v));
    });
    theme.elevation.named.forEach((k, v) {
      if (v < 0) issues.add(InvalidValue('elevation.$k', v));
    });
    final m = theme.motion;
    <String, Duration>{
      'durationShort': m.durationShort,
      'durationMedium': m.durationMedium,
      'durationLong': m.durationLong,
    }.forEach((k, v) {
      if (v.isNegative) issues.add(InvalidValue('motion.$k', v));
    });
    final sh = theme.shapes;
    <String, BorderRadius>{
      'none': sh.none,
      'extraSmall': sh.extraSmall,
      'small': sh.small,
      'medium': sh.medium,
      'large': sh.large,
      'extraLarge': sh.extraLarge,
      'full': sh.full,
    }.forEach((k, v) {
      final corners = [v.topLeft, v.topRight, v.bottomLeft, v.bottomRight];
      final negative = corners.where((r) => r.x < 0 || r.y < 0).firstOrNull;
      if (negative != null) {
        issues.add(
          InvalidValue('shapes.$k', negative.x < 0 ? negative.x : negative.y),
        );
      }
    });

    // Token sets: one per type.
    final seen = <Type>{};
    for (final set in theme.tokenSets) {
      if (!seen.add(set.runtimeType)) {
        issues.add(ShadowedRole('tokenSets.${set.runtimeType}'));
      }
    }
    return issues;
  }
}
