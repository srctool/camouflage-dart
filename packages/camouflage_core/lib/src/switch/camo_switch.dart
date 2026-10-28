import 'package:flutter/widgets.dart';

import '../checkbox/camo_checkbox.dart' show toggleSemantics;
import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../text/camo_text.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_error_semantics.dart';
import '../util/camo_touch_target.dart';
import '../util/camo_row_toggle.dart';

/// Every color a switch uses. Disabled and error colors come from the theme.
@immutable
class SwitchColors {
  /// Creates switch colors.
  const SwitchColors({
    required this.trackOn,
    required this.trackOff,
    required this.thumbOn,
    required this.thumbOff,
    required this.trackOffBorder,
    required this.label,
  });

  /// The track when on.
  final Color trackOn;

  /// The track when off.
  final Color trackOff;

  /// The thumb when on.
  final Color thumbOn;

  /// The thumb when off.
  final Color thumbOff;

  /// The track's border when off.
  final Color trackOffBorder;

  /// The label text.
  final Color label;

  @override
  bool operator ==(Object other) =>
      other is SwitchColors &&
      other.trackOn == trackOn &&
      other.trackOff == trackOff &&
      other.thumbOn == thumbOn &&
      other.thumbOff == thumbOff &&
      other.trackOffBorder == trackOffBorder &&
      other.label == label;

  @override
  int get hashCode =>
      Object.hash(trackOn, trackOff, thumbOn, thumbOff, trackOffBorder, label);
}

/// The icons inside the thumb when `showThumbIcons` is on. A `null` [unchecked] leaves "off" plain.
@immutable
class ThumbIcons {
  /// Creates thumb icons.
  const ThumbIcons({required this.checked, this.unchecked});

  /// Shown when on.
  final IconSource checked;

  /// Shown when off, if any.
  final IconSource? unchecked;

  @override
  bool operator ==(Object other) =>
      other is ThumbIcons &&
      other.checked == checked &&
      other.unchecked == unchecked;

  @override
  int get hashCode => Object.hash(checked, unchecked);
}

/// Overrides for switches; `null` keeps the skin's default.
@immutable
class CamoSwitchTheme {
  /// Creates switch overrides.
  const CamoSwitchTheme({
    this.showThumbIcons,
    this.thumbIcons,
    this.trackWidth,
    this.trackHeight,
    this.thumbSizeOff,
    this.thumbSizeOn,
    this.thumbSizePressed,
    this.labelStyle,
    this.labelPosition,
    this.labelGap,
    this.descriptionStyle,
    this.colors,
  });

  /// Draws [thumbIcons] inside the thumb.
  final bool? showThumbIcons;

  /// The brand's thumb icons.
  final ThumbIcons? thumbIcons;

  /// The track's width.
  final double? trackWidth;

  /// The track's height.
  final double? trackHeight;

  /// The thumb when off.
  final double? thumbSizeOff;

  /// The thumb when on.
  final double? thumbSizeOn;

  /// The thumb while pressed or dragged.
  final double? thumbSizePressed;

  /// The label.
  final TextStyle? labelStyle;

  /// Which side the label sits on.
  final CamoLabelPosition? labelPosition;

  /// The space between the label and the switch.
  final double? labelGap;

  /// The description line, color included.
  final TextStyle? descriptionStyle;

  /// Every color the switch uses.
  final SwitchColors? colors;

  /// A copy with the given fields replaced.
  CamoSwitchTheme copyWith({
    bool? showThumbIcons,
    ThumbIcons? thumbIcons,
    double? trackWidth,
    double? trackHeight,
    double? thumbSizeOff,
    double? thumbSizeOn,
    double? thumbSizePressed,
    TextStyle? labelStyle,
    CamoLabelPosition? labelPosition,
    double? labelGap,
    TextStyle? descriptionStyle,
    SwitchColors? colors,
  }) => CamoSwitchTheme(
    showThumbIcons: showThumbIcons ?? this.showThumbIcons,
    thumbIcons: thumbIcons ?? this.thumbIcons,
    trackWidth: trackWidth ?? this.trackWidth,
    trackHeight: trackHeight ?? this.trackHeight,
    thumbSizeOff: thumbSizeOff ?? this.thumbSizeOff,
    thumbSizeOn: thumbSizeOn ?? this.thumbSizeOn,
    thumbSizePressed: thumbSizePressed ?? this.thumbSizePressed,
    labelStyle: labelStyle ?? this.labelStyle,
    labelPosition: labelPosition ?? this.labelPosition,
    labelGap: labelGap ?? this.labelGap,
    descriptionStyle: descriptionStyle ?? this.descriptionStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSwitchTheme &&
      other.showThumbIcons == showThumbIcons &&
      other.thumbIcons == thumbIcons &&
      other.trackWidth == trackWidth &&
      other.trackHeight == trackHeight &&
      other.thumbSizeOff == thumbSizeOff &&
      other.thumbSizeOn == thumbSizeOn &&
      other.thumbSizePressed == thumbSizePressed &&
      other.labelStyle == labelStyle &&
      other.labelPosition == labelPosition &&
      other.labelGap == labelGap &&
      other.descriptionStyle == descriptionStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    showThumbIcons,
    thumbIcons,
    trackWidth,
    trackHeight,
    thumbSizeOff,
    thumbSizeOn,
    thumbSizePressed,
    labelStyle,
    labelPosition,
    labelGap,
    descriptionStyle,
    colors,
  );
}

/// The resolved switch style: every field set except [thumbIcons], which a skin without icons leaves `null`.
@immutable
class CamoSwitchStyle {
  /// Creates a switch style.
  const CamoSwitchStyle({
    required this.showThumbIcons,
    required this.thumbIcons,
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbSizeOff,
    required this.thumbSizeOn,
    required this.thumbSizePressed,
    required this.labelStyle,
    required this.labelPosition,
    required this.labelGap,
    required this.descriptionStyle,
    required this.colors,
  });

  /// Draws [thumbIcons] inside the thumb.
  final bool showThumbIcons;

  /// The thumb icons, if the skin has any.
  final ThumbIcons? thumbIcons;

  /// The track's width.
  final double trackWidth;

  /// The track's height.
  final double trackHeight;

  /// The thumb when off.
  final double thumbSizeOff;

  /// The thumb when on.
  final double thumbSizeOn;

  /// The thumb while pressed or dragged.
  final double thumbSizePressed;

  /// The label.
  final TextStyle labelStyle;

  /// Which side the label sits on.
  final CamoLabelPosition labelPosition;

  /// The space between the label and the switch.
  final double labelGap;

  /// The description line, color included.
  final TextStyle descriptionStyle;

  /// Every color the switch uses.
  final SwitchColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoSwitchStyle merge(CamoSwitchTheme? o) => o == null
      ? this
      : CamoSwitchStyle(
          showThumbIcons: o.showThumbIcons ?? showThumbIcons,
          thumbIcons: o.thumbIcons ?? thumbIcons,
          trackWidth: o.trackWidth ?? trackWidth,
          trackHeight: o.trackHeight ?? trackHeight,
          thumbSizeOff: o.thumbSizeOff ?? thumbSizeOff,
          thumbSizeOn: o.thumbSizeOn ?? thumbSizeOn,
          thumbSizePressed: o.thumbSizePressed ?? thumbSizePressed,
          labelStyle: o.labelStyle ?? labelStyle,
          labelPosition: o.labelPosition ?? labelPosition,
          labelGap: o.labelGap ?? labelGap,
          descriptionStyle: o.descriptionStyle ?? descriptionStyle,
          colors: o.colors ?? colors,
        );
}

/// What a switch renderer draws: the track and thumb, with the label and [description] on the style's
/// `labelPosition` side and [error] below. While the user drags the thumb, [dragFraction] is its position from
/// the "off" side (0) to the "on" side (1), measured from the start in the reading direction; the renderer draws
/// it there without animating. Otherwise the thumb animates to [checked].
@immutable
class SwitchState {
  /// Creates a switch state.
  const SwitchState({
    required this.checked,
    required this.label,
    required this.description,
    required this.error,
    required this.enabled,
    required this.dragFraction,
    required this.interaction,
    required this.controller,
  });

  /// Whether it's on.
  final bool checked;

  /// The label as spans, or `null` for a bare switch.
  final List<CamoSpan>? label;

  /// A second line under the label.
  final String? description;

  /// The error shown below the row.
  final String? error;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The thumb's position while dragged, else `null`.
  final double? dragFraction;

  /// Pressed, focused, hovered, dragged.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws switches.
abstract interface class CamoSwitchRenderer {
  /// The complete switch style for [theme].
  CamoSwitchStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(
    BuildContext context,
    SwitchState state,
    CamoTheme theme,
    CamoSwitchStyle style,
  );
}

/// An on/off switch that applies immediately (Wi-Fi on), announced as "Wi-Fi, switch, on". With a [label] the
/// whole row is one target. The thumb can be dragged: released past the middle it toggles, otherwise it springs
/// back. `onChanged: null` makes it display-only.
class CamoSwitch extends StatefulWidget {
  /// Creates a switch.
  const CamoSwitch({
    super.key,
    required this.checked,
    required this.onChanged,
    this.label,
    this.labelSpans,
    this.description,
    this.error,
    this.enabled = true,
    this.focusNode,
  });

  /// Whether it's on.
  final bool checked;

  /// Called with the new value; `null` makes it display-only.
  final ValueChanged<bool>? onChanged;

  /// The label; the whole row becomes the target.
  final String? label;

  /// A rich label (links, bold), instead of [label].
  final List<CamoSpan>? labelSpans;

  /// A second line under the label ("Uses more battery").
  final String? description;

  /// Marks it invalid and shows below the row.
  final String? error;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoSwitch> createState() => _CamoSwitchState();
}

class _CamoSwitchState extends State<CamoSwitch> {
  final _interaction = CamoInteractionController();
  double? _drag;

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSwitch');
    final theme = Camouflage.themeOf(context, component: 'CamoSwitch');
    final style = skin.switchRenderer
        .defaults(theme)
        .merge(theme.components.switchTheme);
    final spans =
        widget.labelSpans ??
        (widget.label == null ? null : [CamoSpan(widget.label!)]);
    final onChanged = widget.onChanged;
    final enabled = widget.enabled && onChanged != null;
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.switchRenderer.render(
        context,
        SwitchState(
          checked: widget.checked,
          label: spans,
          description: widget.description,
          error: widget.error,
          enabled: widget.enabled,
          dragFraction: _drag,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        theme,
        style,
      ),
    );
    if (onChanged == null) {
      return reportRowToggle(context, toggled: widget.checked, child: visual);
    }
    // The thumb's center travels from trackHeight / 2 to trackWidth - trackHeight / 2.
    final travel = (style.trackWidth - style.trackHeight).clamp(
      1.0,
      double.infinity,
    );
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    return CamoErrorSemantics(
      message: widget.error,
      child: GestureDetector(
        onHorizontalDragStart: enabled
            ? (_) {
                _interaction.setDragged(true);
                setState(() => _drag = widget.checked ? 1 : 0);
              }
            : null,
        onHorizontalDragUpdate: enabled
            ? (d) => setState(
                () => _drag = ((_drag ?? 0) + direction * d.delta.dx / travel)
                    .clamp(0.0, 1.0),
              )
            : null,
        onHorizontalDragEnd: enabled
            ? (_) {
                final on = (_drag ?? 0) > 0.5;
                _interaction.setDragged(false);
                setState(() => _drag = null);
                if (on != widget.checked) onChanged(on);
              }
            : null,
        onHorizontalDragCancel: enabled
            ? () {
                _interaction.setDragged(false);
                setState(() => _drag = null);
              }
            : null,
        child: CamoBehavior(
          controller: _interaction,
          enabled: enabled,
          focusNode: widget.focusNode,
          onActivate: () => onChanged(!widget.checked),
          semantics: (child) => toggleSemantics(
            spans: spans,
            description: widget.description,
            enabled: enabled,
            checked: widget.checked,
            isSwitch: true,
            child: child,
          ),
          child: CamoTouchTarget(child: visual),
        ),
      ),
    );
  }
}
