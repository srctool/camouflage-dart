import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';
import '../icon/camo_icon.dart';

/// Every color progress steps use.
@immutable
class StepsColors {
  /// Creates StepsColors.
  const StepsColors({
    required this.complete,
    required this.onComplete,
    required this.current,
    required this.onCurrent,
    required this.upcoming,
    required this.error,
    required this.connector,
    required this.text,
    required this.mutedText,
  });

  /// A complete step's marker.
  final Color complete;

  /// Its check.
  final Color onComplete;

  /// The current step's marker.
  final Color current;

  /// Its number.
  final Color onCurrent;

  /// An upcoming step's outline.
  final Color upcoming;

  /// A step with an error.
  final Color error;

  /// The line to an incomplete step.
  final Color connector;

  /// Labels.
  final Color text;

  /// Descriptions and upcoming labels.
  final Color mutedText;

  @override
  bool operator ==(Object other) =>
      other is StepsColors &&
      other.complete == complete &&
      other.onComplete == onComplete &&
      other.current == current &&
      other.onCurrent == onCurrent &&
      other.upcoming == upcoming &&
      other.error == error &&
      other.connector == connector &&
      other.text == text &&
      other.mutedText == mutedText;

  @override
  int get hashCode => Object.hash(
    complete,
    onComplete,
    current,
    onCurrent,
    upcoming,
    error,
    connector,
    text,
    mutedText,
  );
}

/// Overrides for progress steps. `null` keeps the skin's default.
@immutable
class CamoStepsTheme {
  /// Creates overrides.
  const CamoStepsTheme({
    this.markerSize,
    this.connectorWidth,
    this.showNumbers,
    this.checkIcon,
    this.errorIcon,
    this.labelStyle,
    this.descriptionStyle,
    this.colors,
  });

  /// The step marker.
  final double? markerSize;

  /// The line between steps.
  final double? connectorWidth;

  /// Numbers in the markers (else dots).
  final bool? showNumbers;

  /// A complete step.
  final IconSource? checkIcon;

  /// A step with an error.
  final IconSource? errorIcon;

  /// Step labels.
  final TextStyle? labelStyle;

  /// Step descriptions.
  final TextStyle? descriptionStyle;

  /// Every color it uses.
  final StepsColors? colors;

  /// A copy with the given fields replaced.
  CamoStepsTheme copyWith({
    double? markerSize,
    double? connectorWidth,
    bool? showNumbers,
    IconSource? checkIcon,
    IconSource? errorIcon,
    TextStyle? labelStyle,
    TextStyle? descriptionStyle,
    StepsColors? colors,
  }) => CamoStepsTheme(
    markerSize: markerSize ?? this.markerSize,
    connectorWidth: connectorWidth ?? this.connectorWidth,
    showNumbers: showNumbers ?? this.showNumbers,
    checkIcon: checkIcon ?? this.checkIcon,
    errorIcon: errorIcon ?? this.errorIcon,
    labelStyle: labelStyle ?? this.labelStyle,
    descriptionStyle: descriptionStyle ?? this.descriptionStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoStepsTheme &&
      other.markerSize == markerSize &&
      other.connectorWidth == connectorWidth &&
      other.showNumbers == showNumbers &&
      other.checkIcon == checkIcon &&
      other.errorIcon == errorIcon &&
      other.labelStyle == labelStyle &&
      other.descriptionStyle == descriptionStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    markerSize,
    connectorWidth,
    showNumbers,
    checkIcon,
    errorIcon,
    labelStyle,
    descriptionStyle,
    colors,
  );
}

/// The resolved progress steps style: every field set.
@immutable
class CamoStepsStyle {
  /// Creates a style.
  const CamoStepsStyle({
    required this.markerSize,
    required this.connectorWidth,
    required this.showNumbers,
    required this.checkIcon,
    required this.errorIcon,
    required this.labelStyle,
    required this.descriptionStyle,
    required this.colors,
  });

  /// The step marker.
  final double markerSize;

  /// The line between steps.
  final double connectorWidth;

  /// Numbers in the markers (else dots).
  final bool showNumbers;

  /// A complete step.
  final IconSource checkIcon;

  /// A step with an error.
  final IconSource errorIcon;

  /// Step labels.
  final TextStyle labelStyle;

  /// Step descriptions.
  final TextStyle descriptionStyle;

  /// Every color it uses.
  final StepsColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoStepsStyle merge(CamoStepsTheme? o) => o == null
      ? this
      : CamoStepsStyle(
          markerSize: o.markerSize ?? markerSize,
          connectorWidth: o.connectorWidth ?? connectorWidth,
          showNumbers: o.showNumbers ?? showNumbers,
          checkIcon: o.checkIcon ?? checkIcon,
          errorIcon: o.errorIcon ?? errorIcon,
          labelStyle: o.labelStyle ?? labelStyle,
          descriptionStyle: o.descriptionStyle ?? descriptionStyle,
          colors: o.colors ?? colors,
        );
}

/// Where a step is in the process.
enum StepStatus {
  /// Done.
  complete,

  /// The one the process is at.
  current,

  /// Not reached yet.
  upcoming,

  /// Needs attention.
  error,
}

/// Which way the steps run.
enum StepsOrientation {
  /// Left to right (right to left in RTL).
  horizontal,

  /// Top to bottom.
  vertical,
}

/// One step. A null [status] is derived from the current step (earlier ones are complete); set `error` to flag a
/// step. A null [onPressed] makes it not clickable.
@immutable
class CamoStep {
  /// Creates a step.
  const CamoStep({
    required this.id,
    required this.label,
    this.description,
    this.status,
    this.onPressed,
  });

  /// Identifies the step across rebuilds.
  final Object id;

  /// The step's name.
  final String label;

  /// A line under the name.
  final String? description;

  /// Overrides the derived status.
  final StepStatus? status;

  /// Runs when it's pressed; `null` makes it not clickable.
  final VoidCallback? onPressed;
}

/// What a step renderer draws: the marker, the label and description, and (unless [last]) the connector to the next
/// step, drawn in the complete color when this step is complete. In a horizontal layout the step gets an equal share
/// of the width (the last one only its own); in a vertical one its own height.
@immutable
class StepItemState {
  /// Creates the state.
  const StepItemState({
    required this.index,
    required this.count,
    required this.status,
    required this.clickable,
    required this.orientation,
    required this.interaction,
    required this.controller,
  });

  /// The step, zero-based.
  final int index;

  /// How many steps.
  final int count;

  /// Where it is in the process.
  final StepStatus status;

  /// Whether it can be pressed.
  final bool clickable;

  /// The layout direction.
  final StepsOrientation orientation;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;

  /// Whether this is the last step.
  bool get last => index == count - 1;
}

/// A step's content.
@immutable
class StepSlots {
  /// Creates the slots.
  const StepSlots({required this.label, this.description});

  /// The name.
  final String label;

  /// The line under it.
  final String? description;
}

/// Draws progress steps.
abstract interface class CamoProgressStepsRenderer {
  /// The complete progress steps style for [theme].
  CamoStepsStyle defaults(CamoTheme theme);

  /// Draws one step.
  Widget renderStep(
    BuildContext context,
    StepItemState state,
    StepSlots slots,
    CamoTheme theme,
    CamoStepsStyle style,
  );
}

/// Shows where you are in a multi-step process; the app swaps the content and sets [current] (zero-based). A step
/// announces "Step 2 of 4, current"; steps with an [CamoStep.onPressed] are buttons and the arrow keys move between
/// them. [semanticLabel] names the list.
class CamoProgressSteps extends StatelessWidget {
  /// Creates progress steps.
  const CamoProgressSteps({
    super.key,
    required this.steps,
    required this.current,
    this.orientation = StepsOrientation.horizontal,
    this.semanticLabel = 'Progress',
  });

  /// The steps, in order.
  final List<CamoStep> steps;

  /// The current step, zero-based.
  final int current;

  /// Horizontal or vertical.
  final StepsOrientation orientation;

  /// Names the list.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final horizontal = orientation == StepsOrientation.horizontal;
    final children = [
      for (final (i, step) in steps.indexed)
        _StepView(
          key: ValueKey(step.id),
          step: step,
          index: i,
          count: steps.length,
          current: current,
          orientation: orientation,
        ),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: CamoRovingFocus(
        child: horizontal
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (i, child) in children.indexed)
                      if (i < children.length - 1)
                        Expanded(child: child)
                      else
                        child,
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
      ),
    );
  }
}

class _StepView extends StatefulWidget {
  const _StepView({
    super.key,
    required this.step,
    required this.index,
    required this.count,
    required this.current,
    required this.orientation,
  });

  final CamoStep step;
  final int index;
  final int count;
  final int current;
  final StepsOrientation orientation;

  @override
  State<_StepView> createState() => _StepViewState();
}

class _StepViewState extends State<_StepView> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  static String _word(StepStatus s) => switch (s) {
    StepStatus.complete => 'complete',
    StepStatus.current => 'current',
    StepStatus.upcoming => 'upcoming',
    StepStatus.error => 'error',
  };

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoProgressSteps');
    final theme = Camouflage.themeOf(context, component: 'CamoProgressSteps');
    final style = skin.progressSteps
        .defaults(theme)
        .merge(theme.components.progressSteps);
    final step = widget.step;
    final status =
        step.status ??
        (widget.index < widget.current
            ? StepStatus.complete
            : widget.index == widget.current
            ? StepStatus.current
            : StepStatus.upcoming);
    final clickable = step.onPressed != null;
    return CamoRovingFocusItem(
      index: widget.index,
      enabled: clickable,
      selected: widget.index == widget.current,
      onSelect: () {},
      builder: (context, node) => CamoBehavior(
        controller: _interaction,
        enabled: clickable,
        focusNode: node,
        onActivate: step.onPressed,
        semantics: (child) => Semantics(
          button: clickable,
          enabled: true,
          selected: widget.index == widget.current,
          label: step.label,
          value:
              'Step ${widget.index + 1} of ${widget.count}, ${_word(status)}',
          hint: step.description,
          excludeSemantics: true,
          child: child,
        ),
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.progressSteps.renderStep(
            context,
            StepItemState(
              index: widget.index,
              count: widget.count,
              status: status,
              clickable: clickable,
              orientation: widget.orientation,
              interaction: _interaction.value,
              controller: _interaction,
            ),
            StepSlots(label: step.label, description: step.description),
            theme,
            style,
          ),
        ),
      ),
    );
  }
}
