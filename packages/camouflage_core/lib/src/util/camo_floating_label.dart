import 'package:flutter/widgets.dart';

import '../theme/camo_theme.dart';

/// A field frame with a `floating` label, for text field renderers: [label] rests inside [field] at [startInset]
/// (centered on its height, in [restingStyle]) and moves to sit on the top edge in [floatedStyle] when
/// [floated] (focused or not empty), on a [cutout] background that hides the border behind it. The label
/// excludes its semantics (core names the input).
class CamoFloatingLabel extends StatelessWidget {
  /// Creates the frame.
  const CamoFloatingLabel({
    super.key,
    required this.label,
    required this.floated,
    required this.restingStyle,
    required this.floatedStyle,
    required this.color,
    required this.cutout,
    required this.startInset,
    required this.theme,
    required this.field,
  });

  /// The label text.
  final String label;

  /// On the top edge (focused or not empty).
  final bool floated;

  /// The label inside the field.
  final TextStyle restingStyle;

  /// The label on the top edge.
  final TextStyle floatedStyle;

  /// The label's color.
  final Color color;

  /// The background behind the floated label.
  final Color cutout;

  /// Where the label starts, from the field's start edge.
  final double startInset;

  /// For the motion.
  final CamoTheme theme;

  /// The framed row.
  final Widget field;

  static const double _cutoutPadding = 4;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: floated ? 1 : 0),
    duration: theme.motion.durationShort,
    curve: theme.motion.easingStandard,
    builder: (context, t, _) => Stack(
      clipBehavior: Clip.none,
      children: [
        field,
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: startInset - _cutoutPadding * t,
              ),
              child: Align(
                alignment: AlignmentDirectional(-1, -t),
                child: FractionalTranslation(
                  translation: Offset(0, -0.5 * t),
                  child: ExcludeSemantics(
                    child: Container(
                      color: Color.lerp(cutout.withValues(alpha: 0), cutout, t),
                      padding: EdgeInsets.symmetric(
                        horizontal: _cutoutPadding * t,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle.lerp(
                          restingStyle,
                          floatedStyle,
                          t,
                        )!.copyWith(color: color),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
