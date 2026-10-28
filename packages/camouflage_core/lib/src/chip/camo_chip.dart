import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../textfield/camo_text_field.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';
import '../util/camo_touch_target.dart';

/// A chip's colors for one appearance or for the selected state; [border] is drawn only when set.
@immutable
class ChipColors {
  /// Creates ChipColors.
  const ChipColors({
    required this.container,
    required this.content,
    this.border,
  });

  /// The fill.
  final Color container;

  /// Text and icons.
  final Color content;

  /// The outline, if any.
  final Color? border;

  @override
  bool operator ==(Object other) =>
      other is ChipColors &&
      other.container == container &&
      other.content == content &&
      other.border == border;

  @override
  int get hashCode => Object.hash(container, content, border);
}

/// The words chips say themselves: [remove] names an input chip's remove button from the chip's label.
@immutable
class ChipStrings {
  /// Creates ChipStrings.
  const ChipStrings({this.remove = _remove});

  /// "Remove Ada".
  final String Function(String label) remove;

  @override
  bool operator ==(Object other) =>
      other is ChipStrings && other.remove == remove;

  @override
  int get hashCode => remove.hashCode;
}

String _remove(String label) => 'Remove $label';

/// Overrides for chips; `null` keeps the skin's default.
@immutable
class CamoChipTheme {
  /// Creates CamoChipTheme.
  const CamoChipTheme({
    this.defaultAppearance,
    this.height,
    this.shape,
    this.padding,
    this.iconPadding,
    this.iconGap,
    this.textStyle,
    this.iconSize,
    this.borderWidth,
    this.showCheckWhenSelected,
    this.outlineColors,
    this.softColors,
    this.solidColors,
    this.selectedColors,
    this.groupSpacing,
    this.checkIcon,
    this.removeIcon,
    this.strings,
  });

  /// The appearance when a chip passes none.
  final Appearance? defaultAppearance;

  /// The chip height (interactive chips keep a 48 touch target).
  final double? height;

  /// The corners.
  final BorderRadius? shape;

  /// Inside the chip.
  final EdgeInsetsDirectional? padding;

  /// Inside the chip on a side with an icon, a check or the remove button.
  final EdgeInsetsDirectional? iconPadding;

  /// Between the icon, the label and the remove button.
  final double? iconGap;

  /// The label.
  final TextStyle? textStyle;

  /// Leading, check and remove icons.
  final double? iconSize;

  /// The outline width.
  final double? borderWidth;

  /// A leading check on selected filter chips.
  final bool? showCheckWhenSelected;

  /// Outline, in the default tone.
  final ChipColors? outlineColors;

  /// Soft, in the default tone.
  final ChipColors? softColors;

  /// Solid, in the default tone.
  final ChipColors? solidColors;

  /// A selected filter chip.
  final ChipColors? selectedColors;

  /// Between chips in a `CamoChipGroup`, across and between rows.
  final double? groupSpacing;

  /// The check of a selected filter chip.
  final IconSource? checkIcon;

  /// An input chip's remove button.
  final IconSource? removeIcon;

  /// The words chips say.
  final ChipStrings? strings;

  /// A copy with the given fields replaced.
  CamoChipTheme copyWith({
    Appearance? defaultAppearance,
    double? height,
    BorderRadius? shape,
    EdgeInsetsDirectional? padding,
    EdgeInsetsDirectional? iconPadding,
    double? iconGap,
    TextStyle? textStyle,
    double? iconSize,
    double? borderWidth,
    bool? showCheckWhenSelected,
    ChipColors? outlineColors,
    ChipColors? softColors,
    ChipColors? solidColors,
    ChipColors? selectedColors,
    double? groupSpacing,
    IconSource? checkIcon,
    IconSource? removeIcon,
    ChipStrings? strings,
  }) => CamoChipTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    height: height ?? this.height,
    shape: shape ?? this.shape,
    padding: padding ?? this.padding,
    iconPadding: iconPadding ?? this.iconPadding,
    iconGap: iconGap ?? this.iconGap,
    textStyle: textStyle ?? this.textStyle,
    iconSize: iconSize ?? this.iconSize,
    borderWidth: borderWidth ?? this.borderWidth,
    showCheckWhenSelected: showCheckWhenSelected ?? this.showCheckWhenSelected,
    outlineColors: outlineColors ?? this.outlineColors,
    softColors: softColors ?? this.softColors,
    solidColors: solidColors ?? this.solidColors,
    selectedColors: selectedColors ?? this.selectedColors,
    groupSpacing: groupSpacing ?? this.groupSpacing,
    checkIcon: checkIcon ?? this.checkIcon,
    removeIcon: removeIcon ?? this.removeIcon,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoChipTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.height == height &&
      other.shape == shape &&
      other.padding == padding &&
      other.iconPadding == iconPadding &&
      other.iconGap == iconGap &&
      other.textStyle == textStyle &&
      other.iconSize == iconSize &&
      other.borderWidth == borderWidth &&
      other.showCheckWhenSelected == showCheckWhenSelected &&
      other.outlineColors == outlineColors &&
      other.softColors == softColors &&
      other.solidColors == solidColors &&
      other.selectedColors == selectedColors &&
      other.groupSpacing == groupSpacing &&
      other.checkIcon == checkIcon &&
      other.removeIcon == removeIcon &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    height,
    shape,
    padding,
    iconPadding,
    iconGap,
    textStyle,
    iconSize,
    borderWidth,
    showCheckWhenSelected,
    outlineColors,
    softColors,
    solidColors,
    selectedColors,
    groupSpacing,
    checkIcon,
    removeIcon,
    strings,
  );
}

/// The resolved chip style: every field set. The per-appearance colors are for `Tone.defaultTone`.
@immutable
class CamoChipStyle {
  /// Creates CamoChipStyle.
  const CamoChipStyle({
    required this.defaultAppearance,
    required this.height,
    required this.shape,
    required this.padding,
    required this.iconPadding,
    required this.iconGap,
    required this.textStyle,
    required this.iconSize,
    required this.borderWidth,
    required this.showCheckWhenSelected,
    required this.outlineColors,
    required this.softColors,
    required this.solidColors,
    required this.selectedColors,
    required this.groupSpacing,
    required this.checkIcon,
    required this.removeIcon,
    this.strings = const ChipStrings(),
  });

  /// The appearance when a chip passes none.
  final Appearance defaultAppearance;

  /// The chip height (interactive chips keep a 48 touch target).
  final double height;

  /// The corners.
  final BorderRadius shape;

  /// Inside the chip.
  final EdgeInsetsDirectional padding;

  /// Inside the chip on a side with an icon, a check or the remove button.
  final EdgeInsetsDirectional iconPadding;

  /// Between the icon, the label and the remove button.
  final double iconGap;

  /// The label.
  final TextStyle textStyle;

  /// Leading, check and remove icons.
  final double iconSize;

  /// The outline width.
  final double borderWidth;

  /// A leading check on selected filter chips.
  final bool showCheckWhenSelected;

  /// Outline, in the default tone.
  final ChipColors outlineColors;

  /// Soft, in the default tone.
  final ChipColors softColors;

  /// Solid, in the default tone.
  final ChipColors solidColors;

  /// A selected filter chip.
  final ChipColors selectedColors;

  /// Between chips in a `CamoChipGroup`, across and between rows.
  final double groupSpacing;

  /// The check of a selected filter chip.
  final IconSource checkIcon;

  /// An input chip's remove button.
  final IconSource removeIcon;

  /// The words chips say.
  final ChipStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoChipStyle merge(CamoChipTheme? o) => o == null
      ? this
      : CamoChipStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          height: o.height ?? height,
          shape: o.shape ?? shape,
          padding: o.padding ?? padding,
          iconPadding: o.iconPadding ?? iconPadding,
          iconGap: o.iconGap ?? iconGap,
          textStyle: o.textStyle ?? textStyle,
          iconSize: o.iconSize ?? iconSize,
          borderWidth: o.borderWidth ?? borderWidth,
          showCheckWhenSelected:
              o.showCheckWhenSelected ?? showCheckWhenSelected,
          outlineColors: o.outlineColors ?? outlineColors,
          softColors: o.softColors ?? softColors,
          solidColors: o.solidColors ?? solidColors,
          selectedColors: o.selectedColors ?? selectedColors,
          groupSpacing: o.groupSpacing ?? groupSpacing,
          checkIcon: o.checkIcon ?? checkIcon,
          removeIcon: o.removeIcon ?? removeIcon,
          strings: o.strings ?? strings,
        );

  /// The colors for [state]: the selected colors for a selected filter chip, this style's colors for the default
  /// tone, and the tone's family otherwise (Solid a strong fill, Soft a container fill, Outline the tone's strong
  /// color for the border and text).
  ChipColors colorsFor(ChipState state, CamoTheme theme) {
    final f = theme.colors.family(state.tone);
    if (state.selected == true) return selectedColors;
    if (state.tone == Tone.defaultTone) {
      return switch (state.appearance) {
        Appearance.solid => solidColors,
        Appearance.soft => softColors,
        _ => outlineColors,
      };
    }
    return switch (state.appearance) {
      Appearance.solid => ChipColors(container: f.strong, content: f.onStrong),
      Appearance.soft => ChipColors(
        container: f.container,
        content: f.onContainer,
      ),
      _ => ChipColors(
        container: outlineColors.container,
        content: f.strong,
        border: f.strong,
      ),
    };
  }
}

/// The appearance a chip draws for [a]: outline, soft or solid (the others fall back to outline).
Appearance chipAppearance(Appearance a) => switch (a) {
  Appearance.solid || Appearance.soft => a,
  _ => Appearance.outline,
};

/// Which chip a [CamoChip] is, decided by the callbacks it passes.
enum ChipKind {
  /// `onPressed` only: an action or suggestion, a button.
  action,

  /// `selected` set: a filter that toggles.
  filter,

  /// `onDeleted` set (without `selected`): an entered value with a remove button.
  input,

  /// No callbacks: a static tag, text only.
  tag,
}

/// The kind a chip with these callbacks is.
ChipKind chipKind({
  VoidCallback? onPressed,
  bool? selected,
  VoidCallback? onDeleted,
}) {
  if (selected != null) return ChipKind.filter;
  if (onDeleted != null) return ChipKind.input;
  if (onPressed != null) return ChipKind.action;
  return ChipKind.tag;
}

/// What a chip renderer draws. [appearance] is already resolved (outline, soft or solid). [selected] is `null`
/// for chips that aren't filters. Draw press feedback for every kind but [ChipKind.tag].
@immutable
class ChipState {
  /// Creates a chip state.
  const ChipState({
    required this.label,
    required this.kind,
    required this.selected,
    required this.appearance,
    required this.tone,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// The label, one line.
  final String label;

  /// The kind.
  final ChipKind kind;

  /// A filter's selection; `null` for the other kinds.
  final bool? selected;

  /// The resolved appearance.
  final Appearance appearance;

  /// The status tone.
  final Tone tone;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Press, hover and focus.
  final InteractionState interaction;

  /// For the skin's feedback.
  final CamoInteractionController controller;
}

/// A chip's parts besides its label: the app's [leading] icon or avatar, and the [remove] button core builds for
/// input chips (its own focusable button; the renderer only places it, after the label).
@immutable
class ChipSlots {
  /// Creates the slots.
  const ChipSlots({this.leading, this.remove});

  /// An icon or a small avatar.
  final Widget? leading;

  /// The remove button.
  final Widget? remove;
}

/// Draws chips.
abstract interface class CamoChipRenderer {
  /// The complete chip style for [theme].
  CamoChipStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots]. A selected filter shows [CamoChipStyle.checkIcon] when the style asks.
  Widget render(
    BuildContext context,
    ChipState state,
    ChipSlots slots,
    CamoTheme theme,
    CamoChipStyle style,
  );
}

/// A compact element whose callbacks decide its kind: a filter when [selected] is set (it toggles through
/// [onPressed]), an input chip with a remove button when [onDeleted] is set, an action chip with [onPressed]
/// only, and a static tag with none (a status word in a [tone]: `soft` + `success` "Paid"). A focused input chip
/// is also removed with Backspace or Delete. Counts and dots are `CamoBadge`s, not chips.
class CamoChip extends StatefulWidget {
  /// Creates a chip.
  const CamoChip({
    super.key,
    required this.label,
    this.onPressed,
    this.selected,
    this.onDeleted,
    this.leading,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.enabled = true,
    this.focusNode,
  }) : _radio = false;

  // One radio of a single-choice CamoChipGroup.
  const CamoChip._radio({
    required this.label,
    required this.onPressed,
    required bool this.selected,
    required this.leading,
    required this.enabled,
    required this.focusNode,
  }) : onDeleted = null,
       appearance = null,
       tone = Tone.defaultTone,
       _radio = true;

  /// The label, one line with an ellipsis (the full label in semantics).
  final String label;

  /// Activates an action chip, or toggles a filter chip.
  final VoidCallback? onPressed;

  /// Non-null makes a filter chip.
  final bool? selected;

  /// Non-null adds a remove button (an input chip).
  final VoidCallback? onDeleted;

  /// An icon or a small `CamoAvatar`.
  final Widget? leading;

  /// `null` uses `CamoChipTheme.defaultAppearance`.
  final Appearance? appearance;

  /// A status tone, for tags.
  final Tone tone;

  /// `false` disables the chip.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  final bool _radio;

  @override
  State<CamoChip> createState() => _CamoChipState();
}

class _CamoChipState extends State<CamoChip> {
  final _interaction = CamoInteractionController();
  bool _wasFocused = false;

  @override
  void initState() {
    super.initState();
    _interaction.addListener(_bringIntoViewOnFocus);
  }

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  // A chip that takes focus in a scrolling row (the arrow keys in a CamoChipGroup) scrolls into view.
  void _bringIntoViewOnFocus() {
    final focused = _interaction.value.focused;
    if (focused && !_wasFocused && Scrollable.maybeOf(context) != null) {
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
    _wasFocused = focused;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoChip');
    final theme = Camouflage.themeOf(context, component: 'CamoChip');
    final style = skin.chip.defaults(theme).merge(theme.components.chip);
    final onPressed = widget.onPressed;
    final onDeleted = widget.onDeleted;
    final selected = widget.selected;
    final enabled = widget.enabled;
    final kind = chipKind(
      onPressed: onPressed,
      selected: selected,
      onDeleted: onDeleted,
    );
    // Its own node, so it isn't merged into the chip's.
    final remove = onDeleted == null
        ? null
        : Semantics(
            container: true,
            child: CamoFieldAction(
              icon: CamoIcon(style.removeIcon),
              semanticLabel: style.strings.remove(widget.label),
              onPressed: enabled ? onDeleted : null,
            ),
          );
    final Widget visual = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.chip.render(
        context,
        ChipState(
          label: widget.label,
          kind: kind,
          selected: selected,
          appearance: chipAppearance(
            widget.appearance ?? style.defaultAppearance,
          ),
          tone: widget.tone,
          enabled: enabled,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        ChipSlots(leading: widget.leading, remove: remove),
        theme,
        style,
      ),
    );
    if (kind == ChipKind.tag) {
      return Semantics(container: true, child: visual);
    }
    // The node sits above the behavior, so the tap and focus actions join it; the remove button stays its own.
    Widget chip = Semantics(
      container: true,
      child: CamoBehavior(
        controller: _interaction,
        enabled: enabled,
        focusNode: widget.focusNode,
        onActivate: onPressed,
        semantics: (child) => Semantics(
          enabled: enabled,
          button: onPressed != null && selected == null,
          checked: selected,
          inMutuallyExclusiveGroup: widget._radio ? true : null,
          child: child,
        ),
        child: CamoTouchTarget(child: visual),
      ),
    );
    if (onDeleted != null && enabled) {
      chip = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.delete): onDeleted,
          const SingleActivator(LogicalKeyboardKey.backspace): onDeleted,
        },
        child: chip,
      );
    }
    return chip;
  }
}

/// One option of a [CamoChipGroup].
@immutable
class ChipOption<T> {
  /// Creates an option.
  const ChipOption(this.value, this.label, {this.leading, this.enabled = true});

  /// The value it selects.
  final T value;

  /// The chip's label.
  final String label;

  /// An icon or a small avatar.
  final Widget? leading;

  /// `false` disables this chip.
  final bool enabled;
}

/// How a [CamoChipGroup] lays out its chips.
enum ChipLayout {
  /// Rows that wrap onto the next line.
  wrap,

  /// One horizontally scrolling row (under a search bar, say).
  scroll,
}

/// The selection a tap on [value] makes: multi-select toggles membership; single choice replaces the set, and
/// deselects [value] only when the group isn't [required].
Set<T> chipGroupSelection<T>(
  Set<T> selected,
  T value, {
  required bool multiSelect,
  required bool required,
}) {
  if (multiSelect) {
    return selected.contains(value)
        ? ({...selected}..remove(value))
        : {...selected, value};
  }
  if (selected.contains(value)) return required ? selected : <T>{};
  return {value};
}

/// Filter chips for [options], `groupSpacing` apart: several choices with [multiSelect] (a group of toggles, the
/// multi-select replacement for a segmented control), or one (a radio group, "Open now, 2 of 5"). A [required]
/// single choice keeps its last chip selected. The group is one Tab stop; the arrow keys move between chips, and
/// select in a single-choice group. In [ChipLayout.scroll], a focused chip scrolls into view. Name the group with
/// a heading above it.
class CamoChipGroup<T> extends StatelessWidget {
  /// Creates a chip group.
  const CamoChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiSelect = true,
    this.layout = ChipLayout.wrap,
    this.required = false,
  });

  /// The chips.
  final List<ChipOption<T>> options;

  /// The selected values.
  final Set<T> selected;

  /// Called with the new selection.
  final ValueChanged<Set<T>> onChanged;

  /// `false` makes a single choice.
  final bool multiSelect;

  /// Wrapping rows or one scrolling row.
  final ChipLayout layout;

  /// A single choice keeps its last chip selected.
  final bool required;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoChipGroup');
    final theme = Camouflage.themeOf(context, component: 'CamoChipGroup');
    final style = skin.chip.defaults(theme).merge(theme.components.chip);
    final chips = [
      for (final (index, option) in options.indexed)
        _groupChip(index, option, selected.contains(option.value)),
    ];
    final spacing = style.groupSpacing;
    final Widget laidOut = switch (layout) {
      ChipLayout.wrap => Wrap(
        spacing: spacing,
        runSpacing: spacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: chips,
      ),
      // A scrolling Row, not a lazy list, so the arrow keys reach every chip.
      ChipLayout.scroll => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: chips,
        ),
      ),
    };
    final group = CamoRovingFocus(child: laidOut);
    return multiSelect
        ? Semantics(container: true, child: group)
        : Semantics(
            role: SemanticsRole.radioGroup,
            container: true,
            child: group,
          );
  }

  Widget _groupChip(int index, ChipOption<T> option, bool isSelected) {
    void toggle() => onChanged(
      chipGroupSelection(
        selected,
        option.value,
        multiSelect: multiSelect,
        required: required,
      ),
    );
    return CamoRovingFocusItem(
      index: index,
      enabled: option.enabled,
      selected: isSelected,
      // Arrow keys select in a single-choice group, and only move focus in a multi-select one.
      onSelect: () {
        if (!multiSelect && !isSelected) toggle();
      },
      builder: (context, node) => multiSelect
          ? CamoChip(
              label: option.label,
              onPressed: toggle,
              selected: isSelected,
              leading: option.leading,
              enabled: option.enabled,
              focusNode: node,
            )
          : CamoChip._radio(
              label: option.label,
              onPressed: toggle,
              selected: isSelected,
              leading: option.leading,
              enabled: option.enabled,
              focusNode: node,
            ),
    );
  }
}
