import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// Where a divider leaves space: nowhere, at the start (after a leading icon), or on both sides.
enum DividerInset {
  /// Full width.
  none,

  /// Inset at the start.
  start,

  /// Inset on both sides.
  middle,
}

/// Overrides for dividers; `null` keeps the skin's default. `thickness: 0` hides every divider.
@immutable
class CamoDividerTheme {
  /// Creates divider overrides.
  const CamoDividerTheme({
    this.thickness,
    this.color,
    this.startInset,
    this.endInset,
  });

  /// The line's thickness.
  final double? thickness;

  /// The line's color.
  final Color? color;

  /// The space used by `start` and `middle` insets.
  final double? startInset;

  /// The end space used by `middle` insets.
  final double? endInset;

  /// A copy with the given fields replaced.
  CamoDividerTheme copyWith({
    double? thickness,
    Color? color,
    double? startInset,
    double? endInset,
  }) => CamoDividerTheme(
    thickness: thickness ?? this.thickness,
    color: color ?? this.color,
    startInset: startInset ?? this.startInset,
    endInset: endInset ?? this.endInset,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoDividerTheme &&
      other.thickness == thickness &&
      other.color == color &&
      other.startInset == startInset &&
      other.endInset == endInset;

  @override
  int get hashCode => Object.hash(thickness, color, startInset, endInset);
}

/// The resolved divider style: every field set.
@immutable
class CamoDividerStyle {
  /// Creates a divider style.
  const CamoDividerStyle({
    required this.thickness,
    required this.color,
    required this.startInset,
    required this.endInset,
  });

  /// The line's thickness.
  final double thickness;

  /// The line's color.
  final Color color;

  /// The start inset.
  final double startInset;

  /// The end inset.
  final double endInset;

  /// This style with [o]'s non-null fields applied.
  CamoDividerStyle merge(CamoDividerTheme? o) => o == null
      ? this
      : CamoDividerStyle(
          thickness: o.thickness ?? thickness,
          color: o.color ?? color,
          startInset: o.startInset ?? startInset,
          endInset: o.endInset ?? endInset,
        );
}

/// What a divider renderer draws.
@immutable
class DividerState {
  /// Creates a divider state.
  const DividerState({required this.orientation, required this.inset});

  /// Horizontal or vertical.
  final Axis orientation;

  /// The inset.
  final DividerInset inset;
}

/// Draws dividers.
abstract interface class CamoDividerRenderer {
  /// The complete divider style for [theme].
  CamoDividerStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    DividerState state,
    CamoTheme theme,
    CamoDividerStyle style,
  );
}

/// A line between groups of content. Decorative: hidden from screen readers. A vertical divider needs a bounded
/// height (an `IntrinsicHeight` around a `Row`).
class CamoDivider extends StatelessWidget {
  /// Creates a divider.
  const CamoDivider({
    super.key,
    this.orientation = Axis.horizontal,
    this.inset = DividerInset.none,
  });

  /// Horizontal or vertical.
  final Axis orientation;

  /// The inset.
  final DividerInset inset;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoDivider');
    final theme = Camouflage.themeOf(context, component: 'CamoDivider');
    final style = skin.divider.defaults(theme).merge(theme.components.divider);
    return ExcludeSemantics(
      child: skin.divider.render(
        context,
        DividerState(orientation: orientation, inset: inset),
        theme,
        style,
      ),
    );
  }
}
