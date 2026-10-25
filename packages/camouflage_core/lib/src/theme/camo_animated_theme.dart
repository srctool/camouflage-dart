import 'package:flutter/widgets.dart';

import 'camo_theme.dart';

/// Animates to [theme]: a theme change blends over [duration] with `CamoTheme.lerp`, restarting from wherever it is,
/// like `AnimatedTheme`. [builder] receives the theme to draw with.
class CamoAnimatedTheme extends ImplicitlyAnimatedWidget {
  /// Creates the animated theme.
  const CamoAnimatedTheme({
    super.key,
    required this.theme,
    required this.builder,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.linear,
    super.onEnd,
  });

  /// The theme to animate to.
  final CamoTheme theme;

  /// Builds the subtree with the current (blended) theme.
  final Widget Function(BuildContext context, CamoTheme theme) builder;

  @override
  AnimatedWidgetBaseState<CamoAnimatedTheme> createState() =>
      _CamoAnimatedThemeState();
}

class _CamoThemeTween extends Tween<CamoTheme> {
  _CamoThemeTween({super.begin});

  @override
  CamoTheme lerp(double t) => CamoTheme.lerp(begin!, end!, t);
}

class _CamoAnimatedThemeState
    extends AnimatedWidgetBaseState<CamoAnimatedTheme> {
  _CamoThemeTween? _theme;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _theme = visitor(
      _theme,
      widget.theme,
      (value) => _CamoThemeTween(begin: value as CamoTheme),
    ) as _CamoThemeTween?;
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _theme!.evaluate(animation));
}
