import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_roving_focus.dart';
import '../util/camo_touch_target.dart';

/// Every color a button group uses, for the default tone. [selectedContainer] fills a pressed toggle.
@immutable
class GroupColors {
  /// Creates GroupColors.
  const GroupColors({
    required this.content,
    required this.border,
    required this.selectedContainer,
    required this.selectedContent,
  });

  /// Label and icon.
  final Color content;

  /// Outlines and dividers.
  final Color border;

  /// A pressed toggle.
  final Color selectedContainer;

  /// Its label and icon.
  final Color selectedContent;

  @override
  bool operator ==(Object other) =>
      other is GroupColors &&
      other.content == content &&
      other.border == border &&
      other.selectedContainer == selectedContainer &&
      other.selectedContent == selectedContent;

  @override
  int get hashCode =>
      Object.hash(content, border, selectedContainer, selectedContent);
}

/// Overrides for button groups. `null` keeps the skin's default.
@immutable
class CamoButtonGroupTheme {
  /// Creates overrides.
  const CamoButtonGroupTheme({
    this.defaultAppearance,
    this.height,
    this.shape,
    this.innerShape,
    this.spacing,
    this.borderWidth,
    this.iconSize,
    this.iconGap,
    this.textStyle,
    this.colors,
  });

  /// The appearance when a call passes none.
  final Appearance? defaultAppearance;

  /// Button height.
  final double? height;

  /// The outer corners.
  final BorderRadius? shape;

  /// The corners between connected buttons.
  final BorderRadius? innerShape;

  /// The gap in a spaced group.
  final double? spacing;

  /// Outlines and dividers.
  final double? borderWidth;

  /// Icon size.
  final double? iconSize;

  /// Icon to label.
  final double? iconGap;

  /// Labels.
  final TextStyle? textStyle;

  /// Every color it uses.
  final GroupColors? colors;

  /// A copy with the given fields replaced.
  CamoButtonGroupTheme copyWith({
    Appearance? defaultAppearance,
    double? height,
    BorderRadius? shape,
    BorderRadius? innerShape,
    double? spacing,
    double? borderWidth,
    double? iconSize,
    double? iconGap,
    TextStyle? textStyle,
    GroupColors? colors,
  }) => CamoButtonGroupTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    height: height ?? this.height,
    shape: shape ?? this.shape,
    innerShape: innerShape ?? this.innerShape,
    spacing: spacing ?? this.spacing,
    borderWidth: borderWidth ?? this.borderWidth,
    iconSize: iconSize ?? this.iconSize,
    iconGap: iconGap ?? this.iconGap,
    textStyle: textStyle ?? this.textStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoButtonGroupTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.height == height &&
      other.shape == shape &&
      other.innerShape == innerShape &&
      other.spacing == spacing &&
      other.borderWidth == borderWidth &&
      other.iconSize == iconSize &&
      other.iconGap == iconGap &&
      other.textStyle == textStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    height,
    shape,
    innerShape,
    spacing,
    borderWidth,
    iconSize,
    iconGap,
    textStyle,
    colors,
  );
}

/// The resolved button group style: every field set.
@immutable
class CamoButtonGroupStyle {
  /// Creates a style.
  const CamoButtonGroupStyle({
    required this.defaultAppearance,
    required this.height,
    required this.shape,
    required this.innerShape,
    required this.spacing,
    required this.borderWidth,
    required this.iconSize,
    required this.iconGap,
    required this.textStyle,
    required this.colors,
  });

  /// The appearance when a call passes none.
  final Appearance defaultAppearance;

  /// Button height.
  final double height;

  /// The outer corners.
  final BorderRadius shape;

  /// The corners between connected buttons.
  final BorderRadius innerShape;

  /// The gap in a spaced group.
  final double spacing;

  /// Outlines and dividers.
  final double borderWidth;

  /// Icon size.
  final double iconSize;

  /// Icon to label.
  final double iconGap;

  /// Labels.
  final TextStyle textStyle;

  /// Every color it uses.
  final GroupColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoButtonGroupStyle merge(CamoButtonGroupTheme? o) => o == null
      ? this
      : CamoButtonGroupStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          height: o.height ?? height,
          shape: o.shape ?? shape,
          innerShape: o.innerShape ?? innerShape,
          spacing: o.spacing ?? spacing,
          borderWidth: o.borderWidth ?? borderWidth,
          iconSize: o.iconSize ?? iconSize,
          iconGap: o.iconGap ?? iconGap,
          textStyle: o.textStyle ?? textStyle,
          colors: o.colors ?? colors,
        );

  /// The colors in [tone]: this style's for the default tone, the tone's family otherwise.
  GroupColors colorsFor(Tone tone, CamoTheme theme) {
    if (tone == Tone.defaultTone) return colors;
    final f = theme.colors.family(tone);
    return GroupColors(
      content: f.strong,
      border: f.strong,
      selectedContainer: f.strong,
      selectedContent: f.onStrong,
    );
  }
}

/// One button of a [CamoButtonGroup]. It needs a [text] or an [icon]; an icon-only button needs a
/// [semanticLabel]. A non-null [selected] makes it a toggle (Bold, Italic): the app owns the state and flips it in
/// [onPressed].
@immutable
class CamoGroupButton {
  /// Creates a group button.
  const CamoGroupButton({
    required this.id,
    required this.onPressed,
    this.text,
    this.icon,
    this.semanticLabel,
    this.selected,
    this.enabled = true,
  });

  /// Identifies the button across rebuilds.
  final Object id;

  /// Runs when it's pressed.
  final VoidCallback onPressed;

  /// The label.
  final String? text;

  /// The icon.
  final Widget? icon;

  /// Names an icon-only button.
  final String? semanticLabel;

  /// `null` for a command; otherwise whether the toggle is pressed.
  final bool? selected;

  /// `false` disables this button only.
  final bool enabled;
}

/// What the container renderer draws: the row around the buttons.
@immutable
class ButtonGroupState {
  /// Creates the container state.
  const ButtonGroupState({
    required this.count,
    required this.connected,
    required this.appearance,
    required this.tone,
    required this.enabled,
  });

  /// How many buttons it holds.
  final int count;

  /// Whether the buttons share borders and corners.
  final bool connected;

  /// The visual weight.
  final Appearance appearance;

  /// The color family.
  final Tone tone;

  /// `false` shows the disabled look.
  final bool enabled;
}

/// What a button renderer draws. [selected] is `null` for a command button; draw the pressed look when `true`.
/// [position] is for the outer corners of a connected group.
@immutable
class GroupButtonState {
  /// Creates a button state.
  const GroupButtonState({
    required this.selected,
    required this.enabled,
    required this.position,
    required this.connected,
    required this.appearance,
    required this.tone,
    required this.interaction,
    required this.controller,
  });

  /// `null` for a command; otherwise pressed or not.
  final bool? selected;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Its place in the row.
  final CamoItemPosition position;

  /// Whether the group is connected.
  final bool connected;

  /// The visual weight.
  final Appearance appearance;

  /// The color family.
  final Tone tone;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// A button's content.
@immutable
class GroupButtonSlots {
  /// Creates the slots.
  const GroupButtonSlots({this.text, this.icon});

  /// The label.
  final String? text;

  /// The icon.
  final Widget? icon;
}

/// Draws button groups in two parts: the container (a row, spaced or connected) and each button.
abstract interface class CamoButtonGroupRenderer {
  /// The complete button group style for [theme].
  CamoButtonGroupStyle defaults(CamoTheme theme);

  /// Draws the row around [buttons], which core sizes to their content.
  Widget renderContainer(
    BuildContext context,
    ButtonGroupState state,
    CamoTheme theme,
    CamoButtonGroupStyle style,
    List<Widget> buttons,
  );

  /// Draws one button with [slots].
  Widget renderButton(
    BuildContext context,
    GroupButtonState state,
    GroupButtonSlots slots,
    CamoTheme theme,
    CamoButtonGroupStyle style,
  );
}

/// Related buttons as one control: commands (Cut, Copy, Paste) or independent toggles (Bold, Italic). It is not a
/// segmented control, which chooses one value. [connected] buttons share borders and corners; otherwise they keep
/// a gap. One Tab stop: the arrow keys move between the enabled buttons, wrapping, and Space or Enter presses.
/// [semanticLabel] names the group. A group never wraps: too many buttons belong in a toolbar.
class CamoButtonGroup extends StatelessWidget {
  /// Creates a button group.
  const CamoButtonGroup({
    super.key,
    required this.buttons,
    this.connected = true,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The buttons, in order.
  final List<CamoGroupButton> buttons;

  /// Shared borders and corners, or a gap between buttons.
  final bool connected;

  /// The visual weight; `null` uses the theme's default.
  final Appearance? appearance;

  /// The color family.
  final Tone tone;

  /// `false` disables every button.
  final bool enabled;

  /// Names the group.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoButtonGroup');
    final theme = Camouflage.themeOf(context, component: 'CamoButtonGroup');
    final style = skin.buttonGroup
        .defaults(theme)
        .merge(theme.components.buttonGroup);
    final resolved = appearance ?? style.defaultAppearance;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: CamoTouchTarget(
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: CamoRovingFocus(
              child: skin.buttonGroup.renderContainer(
                context,
                ButtonGroupState(
                  count: buttons.length,
                  connected: connected,
                  appearance: resolved,
                  tone: tone,
                  enabled: enabled,
                ),
                theme,
                style,
                [
                  for (final (i, button) in buttons.indexed)
                    _GroupButtonWidget(
                      key: ValueKey(button.id),
                      button: button,
                      position: CamoItemPosition(i, buttons.length),
                      connected: connected,
                      appearance: resolved,
                      tone: tone,
                      groupEnabled: enabled,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupButtonWidget extends StatefulWidget {
  const _GroupButtonWidget({
    super.key,
    required this.button,
    required this.position,
    required this.connected,
    required this.appearance,
    required this.tone,
    required this.groupEnabled,
  });

  final CamoGroupButton button;
  final CamoItemPosition position;
  final bool connected;
  final Appearance appearance;
  final Tone tone;
  final bool groupEnabled;

  @override
  State<_GroupButtonWidget> createState() => _GroupButtonWidgetState();
}

class _GroupButtonWidgetState extends State<_GroupButtonWidget> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.button;
    assert(
      button.text != null || button.icon != null,
      'A CamoGroupButton needs a text or an icon.',
    );
    assert(
      button.text != null || button.semanticLabel != null,
      'An icon-only CamoGroupButton needs a semanticLabel.',
    );
    final skin = Camouflage.skinOf(context, component: 'CamoButtonGroup');
    final theme = Camouflage.themeOf(context, component: 'CamoButtonGroup');
    final style = skin.buttonGroup
        .defaults(theme)
        .merge(theme.components.buttonGroup);
    final enabled = widget.groupEnabled && button.enabled;
    return CamoRovingFocusItem(
      index: widget.position.index,
      enabled: enabled,
      selected: false,
      onSelect: () {},
      builder: (context, node) => CamoBehavior(
        touchSemantics: true,
        controller: _interaction,
        enabled: enabled,
        focusNode: node,
        onActivate: button.onPressed,
        semantics: (child) => Semantics(
          button: true,
          enabled: enabled,
          toggled: button.selected,
          label: button.semanticLabel ?? button.text,
          excludeSemantics: true,
          child: child,
        ),
        child: ListenableBuilder(
          listenable: _interaction,
          builder: (context, _) => skin.buttonGroup.renderButton(
            context,
            GroupButtonState(
              selected: button.selected,
              enabled: enabled,
              position: widget.position,
              connected: widget.connected,
              appearance: widget.appearance,
              tone: widget.tone,
              interaction: _interaction.value,
              controller: _interaction,
            ),
            GroupButtonSlots(
              text: button.text,
              icon: button.icon == null
                  ? null
                  : ExcludeSemantics(child: button.icon),
            ),
            theme,
            style,
          ),
        ),
      ),
    );
  }
}
