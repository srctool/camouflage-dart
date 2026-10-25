import 'package:flutter/widgets.dart';

/// The size and color icons take by default inside a container.
@immutable
class CamoIconStyle {
  /// Creates an icon style.
  const CamoIconStyle({required this.size, required this.color});

  /// The icon's size in logical pixels.
  final double size;

  /// The icon's color.
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is CamoIconStyle && other.size == size && other.color == color;

  @override
  int get hashCode => Object.hash(size, color);

  @override
  String toString() => 'CamoIconStyle(size: $size, color: $color)';
}

/// Sets the content color and icon style for the slots a renderer draws, e.g. `onPrimary` inside a solid
/// button. It also sets Flutter's `IconTheme` and `DefaultTextStyle` color, so plain `Icon` and `Text`
/// widgets follow too.
class CamoContentStyle extends StatelessWidget {
  /// Creates a content style for [child].
  const CamoContentStyle({
    super.key,
    required this.color,
    required this.iconStyle,
    required this.child,
  });

  /// The content color.
  final Color color;

  /// The icon size and color.
  final CamoIconStyle iconStyle;

  /// The subtree that gets the style.
  final Widget child;

  /// The nearest content color, or `null` outside any provider or container.
  static Color? maybeColorOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ContentScope>()?.color;

  /// The nearest icon style, or `null` outside any provider or container.
  static CamoIconStyle? maybeIconStyleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ContentScope>()?.iconStyle;

  @override
  Widget build(BuildContext context) => _ContentScope(
    color: color,
    iconStyle: iconStyle,
    child: IconTheme.merge(
      data: IconThemeData(color: iconStyle.color, size: iconStyle.size),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        child: child,
      ),
    ),
  );
}

class _ContentScope extends InheritedWidget {
  const _ContentScope({
    required this.color,
    required this.iconStyle,
    required super.child,
  });

  final Color color;
  final CamoIconStyle iconStyle;

  @override
  bool updateShouldNotify(_ContentScope old) =>
      color != old.color || iconStyle != old.iconStyle;
}

/// [color] at [alpha] of its own opacity, for disabled containers and content.
Color disabled(Color color, double alpha) =>
    color.withValues(alpha: color.a * alpha);
