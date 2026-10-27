import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';
import '../util/camo_touch_target.dart';

/// Every color a segmented control uses. [container] is the track behind the segments.
@immutable
class SegmentedColors {
  /// Creates segmented colors.
  const SegmentedColors({
    required this.container,
    required this.border,
    required this.selectedContainer,
    required this.selectedContent,
    required this.content,
  });

  /// The track.
  final Color container;

  /// Outlines and dividers.
  final Color border;

  /// The selected segment's fill.
  final Color selectedContainer;

  /// The selected segment's label and icon.
  final Color selectedContent;

  /// The other segments' labels and icons.
  final Color content;

  @override
  bool operator ==(Object other) =>
      other is SegmentedColors &&
      other.container == container &&
      other.border == border &&
      other.selectedContainer == selectedContainer &&
      other.selectedContent == selectedContent &&
      other.content == content;

  @override
  int get hashCode => Object.hash(
    container,
    border,
    selectedContainer,
    selectedContent,
    content,
  );
}

/// Overrides for segmented controls; `null` keeps the skin's default.
@immutable
class CamoSegmentedControlTheme {
  /// Creates segmented control overrides.
  const CamoSegmentedControlTheme({
    this.height,
    this.shape,
    this.borderWidth,
    this.textStyle,
    this.iconSize,
    this.showCheckIcon,
    this.colors,
  });

  /// The control's height.
  final double? height;

  /// The outer corners.
  final BorderRadius? shape;

  /// Outlines and dividers.
  final double? borderWidth;

  /// Segment labels.
  final TextStyle? textStyle;

  /// Segment icons.
  final double? iconSize;

  /// A check mark on the selected segment.
  final bool? showCheckIcon;

  /// Every color it uses.
  final SegmentedColors? colors;

  /// A copy with the given fields replaced.
  CamoSegmentedControlTheme copyWith({
    double? height,
    BorderRadius? shape,
    double? borderWidth,
    TextStyle? textStyle,
    double? iconSize,
    bool? showCheckIcon,
    SegmentedColors? colors,
  }) => CamoSegmentedControlTheme(
    height: height ?? this.height,
    shape: shape ?? this.shape,
    borderWidth: borderWidth ?? this.borderWidth,
    textStyle: textStyle ?? this.textStyle,
    iconSize: iconSize ?? this.iconSize,
    showCheckIcon: showCheckIcon ?? this.showCheckIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSegmentedControlTheme &&
      other.height == height &&
      other.shape == shape &&
      other.borderWidth == borderWidth &&
      other.textStyle == textStyle &&
      other.iconSize == iconSize &&
      other.showCheckIcon == showCheckIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    height,
    shape,
    borderWidth,
    textStyle,
    iconSize,
    showCheckIcon,
    colors,
  );
}

/// The resolved segmented control style: every field set.
@immutable
class CamoSegmentedControlStyle {
  /// Creates a segmented control style.
  const CamoSegmentedControlStyle({
    required this.height,
    required this.shape,
    required this.borderWidth,
    required this.textStyle,
    required this.iconSize,
    required this.showCheckIcon,
    required this.colors,
  });

  /// The control's height.
  final double height;

  /// The outer corners.
  final BorderRadius shape;

  /// Outlines and dividers.
  final double borderWidth;

  /// Segment labels.
  final TextStyle textStyle;

  /// Segment icons.
  final double iconSize;

  /// A check mark on the selected segment.
  final bool showCheckIcon;

  /// Every color it uses.
  final SegmentedColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoSegmentedControlStyle merge(CamoSegmentedControlTheme? o) => o == null
      ? this
      : CamoSegmentedControlStyle(
          height: o.height ?? height,
          shape: o.shape ?? shape,
          borderWidth: o.borderWidth ?? borderWidth,
          textStyle: o.textStyle ?? textStyle,
          iconSize: o.iconSize ?? iconSize,
          showCheckIcon: o.showCheckIcon ?? showCheckIcon,
          colors: o.colors ?? colors,
        );
}

/// One option of a [CamoSegmentedControl]. It needs a [label] or an [icon]; an icon-only segment needs a
/// [semanticLabel].
@immutable
class Segment<T> {
  /// Creates a segment.
  const Segment(
    this.value, {
    this.label,
    this.icon,
    this.semanticLabel,
    this.enabled = true,
  });

  /// What choosing it selects.
  final T value;

  /// The segment's label.
  final String? label;

  /// The segment's icon.
  final Widget? icon;

  /// Names an icon-only segment.
  final String? semanticLabel;

  /// `false` disables this segment only.
  final bool enabled;
}

/// What the container renderer draws: the track and outer shape around the segments.
@immutable
class SegmentedContainerState {
  /// Creates the container state.
  const SegmentedContainerState({required this.enabled, required this.count});

  /// `false` shows the disabled look.
  final bool enabled;

  /// How many segments it holds.
  final int count;
}

/// What a segment renderer draws: one segment at [position], selected or not.
@immutable
class SegmentState {
  /// Creates a segment state.
  const SegmentState({
    required this.selected,
    required this.enabled,
    required this.position,
    required this.interaction,
    required this.controller,
  });

  /// Whether it's the chosen segment.
  final bool selected;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Its place in the row.
  final CamoItemPosition position;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// A segment's content: its [label] and [icon], or a building block's custom [child] instead of both.
@immutable
class SegmentSlots {
  /// Creates the slots.
  const SegmentSlots({this.label, this.icon, this.child});

  /// The label.
  final String? label;

  /// The icon.
  final Widget? icon;

  /// Custom content, replacing [label] and [icon].
  final Widget? child;
}

/// Draws segmented controls in two parts: the container (a `Row` holding the segments) and each segment. Core
/// sizes the segments to equal widths.
abstract interface class CamoSegmentedControlRenderer {
  /// The complete segmented control style for [theme].
  CamoSegmentedControlStyle defaults(CamoTheme theme);

  /// Draws the track around [segments], which must be the children of a `Row` (they're `Expanded`).
  Widget renderContainer(
    BuildContext context,
    SegmentedContainerState state,
    CamoTheme theme,
    CamoSegmentedControlStyle style,
    List<Widget> segments,
  );

  /// Draws one segment with [slots].
  Widget renderSegment(
    BuildContext context,
    SegmentState state,
    SegmentSlots slots,
    CamoTheme theme,
    CamoSegmentedControlStyle style,
  );
}

class _SegmentedScope extends InheritedWidget {
  const _SegmentedScope({required this.enabled, required super.child});

  final bool enabled;

  @override
  bool updateShouldNotify(_SegmentedScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// A compact choice between 2 to 5 related options ("Day / Week / Month"), each segment the same width. It's a
/// radio group: one Tab stop, the arrow keys move and select, and segments are announced "Week, 2 of 3". For
/// several selections, use filter chips. `onChanged: null` disables it.
class CamoSegmentedControl<T> extends StatelessWidget {
  /// Creates a segmented control.
  const CamoSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  /// The segments.
  final List<Segment<T>> options;

  /// The chosen value.
  final T selected;

  /// Called with the chosen value.
  final ValueChanged<T>? onChanged;

  /// `false` disables every segment.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return CamoSegmentedContainer(
      enabled: enabled && onChanged != null,
      children: [
        for (final (i, segment) in options.indexed)
          CamoSegmentButton<T>(
            segment: segment,
            selected: segment.value == selected,
            onPressed: () => onChanged?.call(segment.value),
            position: CamoItemPosition(i, options.length),
          ),
      ],
    );
  }
}

/// The building block (ADR-30) for custom segments: the skin's track and outer shape, radio-group semantics and
/// the arrow keys across the [CamoSegmentButton]s in [children].
class CamoSegmentedContainer extends StatelessWidget {
  /// Creates the container.
  const CamoSegmentedContainer({
    super.key,
    required this.children,
    this.enabled = true,
  });

  /// The segment buttons.
  final List<Widget> children;

  /// `false` disables every segment.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(
      context,
      component: 'CamoSegmentedContainer',
    );
    final theme = Camouflage.themeOf(
      context,
      component: 'CamoSegmentedContainer',
    );
    final style = skin.segmentedControl
        .defaults(theme)
        .merge(theme.components.segmentedControl);
    return Semantics(
      role: SemanticsRole.radioGroup,
      container: true,
      child: CamoTouchTarget(
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: _SegmentedScope(
              enabled: enabled,
              child: CamoRovingFocus(
                child: skin.segmentedControl.renderContainer(
                  context,
                  SegmentedContainerState(
                    enabled: enabled,
                    count: children.length,
                  ),
                  theme,
                  style,
                  children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One skin-styled segment inside a [CamoSegmentedContainer], with radio semantics. [child] replaces the
/// segment's label and icon (an icon with a count, two lines); the segment's label still names it.
class CamoSegmentButton<T> extends StatefulWidget {
  /// Creates a segment button.
  const CamoSegmentButton({
    super.key,
    required this.segment,
    required this.selected,
    required this.onPressed,
    required this.position,
    this.child,
  });

  /// The segment.
  final Segment<T> segment;

  /// Whether it's the chosen one.
  final bool selected;

  /// Called when chosen.
  final VoidCallback onPressed;

  /// Its place in the row.
  final CamoItemPosition position;

  /// Custom content.
  final Widget? child;

  @override
  State<CamoSegmentButton<T>> createState() => _CamoSegmentButtonState<T>();
}

class _CamoSegmentButtonState<T> extends State<CamoSegmentButton<T>> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segment = widget.segment;
    assert(
      segment.label != null || segment.icon != null || widget.child != null,
      'A Segment needs a label or an icon.',
    );
    assert(
      segment.label != null || segment.semanticLabel != null,
      'An icon-only Segment needs a semanticLabel.',
    );
    final skin = Camouflage.skinOf(context, component: 'CamoSegmentButton');
    final theme = Camouflage.themeOf(context, component: 'CamoSegmentButton');
    final scope = context.dependOnInheritedWidgetOfExactType<_SegmentedScope>();
    assert(
      scope != null,
      'CamoSegmentButton must be inside a CamoSegmentedContainer.',
    );
    final style = skin.segmentedControl
        .defaults(theme)
        .merge(theme.components.segmentedControl);
    final enabled = (scope?.enabled ?? true) && segment.enabled;
    return Expanded(
      child: CamoRovingFocusItem(
        index: widget.position.index,
        enabled: enabled,
        selected: widget.selected,
        onSelect: widget.onPressed,
        builder: (context, node) => CamoBehavior(
          controller: _interaction,
          enabled: enabled,
          focusNode: node,
          onActivate: widget.onPressed,
          semantics: (child) => Semantics(
            enabled: enabled,
            checked: widget.selected,
            inMutuallyExclusiveGroup: true,
            label: segment.semanticLabel ?? segment.label,
            excludeSemantics: true,
            child: child,
          ),
          child: ListenableBuilder(
            listenable: _interaction,
            builder: (context, _) => skin.segmentedControl.renderSegment(
              context,
              SegmentState(
                selected: widget.selected,
                enabled: enabled,
                position: widget.position,
                interaction: _interaction.value,
                controller: _interaction,
              ),
              SegmentSlots(
                label: segment.label,
                icon: segment.icon,
                child: widget.child,
              ),
              theme,
              style,
            ),
          ),
        ),
      ),
    );
  }
}
