import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// Every color a rating uses: [hover] is the preview under the pointer.
@immutable
class RatingColors {
  /// Creates RatingColors.
  const RatingColors({
    required this.filled,
    required this.empty,
    required this.hover,
    required this.disabled,
  });

  /// Filled icons.
  final Color filled;

  /// Empty icons.
  final Color empty;

  /// The hover preview.
  final Color hover;

  /// Filled icons when disabled.
  final Color disabled;

  @override
  bool operator ==(Object other) =>
      other is RatingColors &&
      other.filled == filled &&
      other.empty == empty &&
      other.hover == hover &&
      other.disabled == disabled;

  @override
  int get hashCode => Object.hash(filled, empty, hover, disabled);
}

/// Overrides for ratings. `null` keeps the skin's default.
@immutable
class CamoRatingTheme {
  /// Creates overrides.
  const CamoRatingTheme({
    this.icon,
    this.smallSize,
    this.mediumSize,
    this.largeSize,
    this.gap,
    this.colors,
  });

  /// The filled icon; empty ones are the same icon in the empty color.
  final IconSource? icon;

  /// Small icon size.
  final double? smallSize;

  /// Medium icon size.
  final double? mediumSize;

  /// Large icon size.
  final double? largeSize;

  /// Between icons.
  final double? gap;

  /// Every color it uses.
  final RatingColors? colors;

  /// A copy with the given fields replaced.
  CamoRatingTheme copyWith({
    IconSource? icon,
    double? smallSize,
    double? mediumSize,
    double? largeSize,
    double? gap,
    RatingColors? colors,
  }) => CamoRatingTheme(
    icon: icon ?? this.icon,
    smallSize: smallSize ?? this.smallSize,
    mediumSize: mediumSize ?? this.mediumSize,
    largeSize: largeSize ?? this.largeSize,
    gap: gap ?? this.gap,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoRatingTheme &&
      other.icon == icon &&
      other.smallSize == smallSize &&
      other.mediumSize == mediumSize &&
      other.largeSize == largeSize &&
      other.gap == gap &&
      other.colors == colors;

  @override
  int get hashCode =>
      Object.hash(icon, smallSize, mediumSize, largeSize, gap, colors);
}

/// The resolved rating style: every field set.
@immutable
class CamoRatingStyle {
  /// Creates a style.
  const CamoRatingStyle({
    required this.icon,
    required this.smallSize,
    required this.mediumSize,
    required this.largeSize,
    required this.gap,
    required this.colors,
  });

  /// The filled icon; empty ones are the same icon in the empty color.
  final IconSource icon;

  /// Small icon size.
  final double smallSize;

  /// Medium icon size.
  final double mediumSize;

  /// Large icon size.
  final double largeSize;

  /// Between icons.
  final double gap;

  /// Every color it uses.
  final RatingColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoRatingStyle merge(CamoRatingTheme? o) => o == null
      ? this
      : CamoRatingStyle(
          icon: o.icon ?? icon,
          smallSize: o.smallSize ?? smallSize,
          mediumSize: o.mediumSize ?? mediumSize,
          largeSize: o.largeSize ?? largeSize,
          gap: o.gap ?? gap,
          colors: o.colors ?? colors,
        );

  /// The icon size for [size].
  double sizeOf(RatingSize size) => switch (size) {
    RatingSize.small => smallSize,
    RatingSize.medium => mediumSize,
    RatingSize.large => largeSize,
  };
}

/// How finely a rating can be set.
enum RatingStep {
  /// Whole icons.
  whole,

  /// Half icons.
  half,
}

/// The size of a rating's icons.
enum RatingSize {
  /// Small.
  small,

  /// Medium.
  medium,

  /// Large.
  large,
}

/// What the rating renderer draws: [max] icons, each filled up to [value]; while the pointer is over an interactive
/// rating, draw [hoverValue] in the hover color instead. The icons must share the width evenly (each icon plus its
/// gap), because core maps the pointer position to a value from the rating's width.
@immutable
class RatingState {
  /// Creates the state.
  const RatingState({
    required this.value,
    required this.hoverValue,
    required this.max,
    required this.size,
    required this.interactive,
    required this.enabled,
    required this.focused,
  });

  /// The rating.
  final double value;

  /// The preview under the pointer.
  final double? hoverValue;

  /// How many icons.
  final int max;

  /// The icon size role.
  final RatingSize size;

  /// Whether it can be changed.
  final bool interactive;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Whether it has keyboard focus (draw a ring).
  final bool focused;
}

/// Draws ratings.
abstract interface class CamoRatingRenderer {
  /// The complete rating style for [theme].
  CamoRatingStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    RatingState state,
    CamoTheme theme,
    CamoRatingStyle style,
  );
}

/// A rating of [value] out of [max], read-only when [onChanged] is `null`. [label] names it ("Quality").
class CamoRating extends StatefulWidget {
  /// Creates a rating.
  const CamoRating({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.max = 5,
    this.step = RatingStep.whole,
    this.size = RatingSize.medium,
    this.enabled = true,
  });

  /// The rating, 0 to [max].
  final double value;

  /// Names the rating.
  final String label;

  /// Called with the new value; `null` makes it read-only.
  final ValueChanged<double>? onChanged;

  /// How many icons.
  final int max;

  /// Whole or half steps.
  final RatingStep step;

  /// The icon size role.
  final RatingSize size;

  /// `false` disables it.
  final bool enabled;

  @override
  State<CamoRating> createState() => _CamoRatingState();
}

class _CamoRatingState extends State<CamoRating> {
  double? _hover;
  var _focused = false;

  bool get _interactive => widget.onChanged != null && widget.enabled;
  double get _unit => widget.step == RatingStep.half ? 0.5 : 1;

  void _set(double value) =>
      widget.onChanged?.call(value.clamp(0, widget.max.toDouble()));

  double _at(Offset local) {
    final box = context.findRenderObject() as RenderBox?;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ratingValueAt(
      local.dx,
      box?.size.width ?? 0,
      widget.max,
      _unit,
      rtl: rtl,
    );
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final backward = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final double? target = key == forward || key == LogicalKeyboardKey.arrowUp
        ? widget.value + _unit
        : key == backward || key == LogicalKeyboardKey.arrowDown
        ? widget.value - _unit
        : key == LogicalKeyboardKey.home
        ? 0
        : key == LogicalKeyboardKey.end
        ? widget.max.toDouble()
        : null;
    if (target == null) return KeyEventResult.ignored;
    _set(target);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoRating');
    final theme = Camouflage.themeOf(context, component: 'CamoRating');
    final style = skin.rating.defaults(theme).merge(theme.components.rating);
    Widget rating = skin.rating.render(
      context,
      RatingState(
        value: widget.value,
        hoverValue: _hover,
        max: widget.max,
        size: widget.size,
        interactive: _interactive,
        enabled: widget.enabled,
        focused: _focused,
      ),
      theme,
      style,
    );
    if (_interactive) {
      rating = Focus(
        onKeyEvent: _key,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: MouseRegion(
          onHover: (e) => setState(() => _hover = _at(e.localPosition)),
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _set(_at(d.localPosition)),
            onHorizontalDragStart: (d) => _set(_at(d.localPosition)),
            onHorizontalDragUpdate: (d) => _set(_at(d.localPosition)),
            child: rating,
          ),
        ),
      );
    }
    final value = formatRating(widget.value);
    return Semantics(
      slider: _interactive,
      enabled: widget.enabled,
      label: widget.label,
      value: '$value of ${widget.max} stars',
      increasedValue: _interactive
          ? formatRating(math.min(widget.value + _unit, widget.max.toDouble()))
          : null,
      decreasedValue: _interactive
          ? formatRating(math.max(widget.value - _unit, 0))
          : null,
      onIncrease: _interactive ? () => _set(widget.value + _unit) : null,
      onDecrease: _interactive ? () => _set(widget.value - _unit) : null,
      excludeSemantics: true,
      child: rating,
    );
  }
}

/// The step the pointer position at [x] of [width] lands on: the icon it is in, or its half.
@visibleForTesting
double ratingValueAt(
  double x,
  double width,
  int max,
  double unit, {
  required bool rtl,
}) {
  if (width <= 0) return 0;
  final fraction = (x / width).clamp(0.0, 1.0);
  return snapRating((rtl ? 1 - fraction : fraction) * max, unit, max);
}

/// [value] rounded up to a step of [unit], at least one step and at most [max].
@visibleForTesting
double snapRating(double value, double unit, int max) =>
    ((value / unit).ceil() * unit).clamp(unit, max.toDouble());

/// A rating's text: whole numbers without a decimal, else one decimal.
@visibleForTesting
String formatRating(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : ((value * 10).round() / 10).toString();
