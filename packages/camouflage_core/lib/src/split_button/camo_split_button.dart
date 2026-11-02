import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../menu/camo_menu_anchor.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import '../util/camo_touch_target.dart';

/// Overrides for split buttons. `null` keeps the skin's default.
@immutable
class CamoSplitButtonTheme {
  /// Creates overrides.
  const CamoSplitButtonTheme({
    this.defaultAppearance,
    this.height,
    this.shape,
    this.innerShape,
    this.arrowWidth,
    this.gap,
    this.iconSize,
    this.iconGap,
    this.padding,
    this.textStyle,
    this.arrowIcon,
  });

  /// The appearance when a call passes none.
  final Appearance? defaultAppearance;

  /// Button height.
  final double? height;

  /// The outer corners.
  final BorderRadius? shape;

  /// The corners between the parts.
  final BorderRadius? innerShape;

  /// The arrow part.
  final double? arrowWidth;

  /// The gap between the parts (0 draws a divider line instead).
  final double? gap;

  /// Icons.
  final double? iconSize;

  /// Icon to label.
  final double? iconGap;

  /// Start and end of the label part.
  final double? padding;

  /// The label.
  final TextStyle? textStyle;

  /// The arrow.
  final IconSource? arrowIcon;

  /// A copy with the given fields replaced.
  CamoSplitButtonTheme copyWith({
    Appearance? defaultAppearance,
    double? height,
    BorderRadius? shape,
    BorderRadius? innerShape,
    double? arrowWidth,
    double? gap,
    double? iconSize,
    double? iconGap,
    double? padding,
    TextStyle? textStyle,
    IconSource? arrowIcon,
  }) => CamoSplitButtonTheme(
    defaultAppearance: defaultAppearance ?? this.defaultAppearance,
    height: height ?? this.height,
    shape: shape ?? this.shape,
    innerShape: innerShape ?? this.innerShape,
    arrowWidth: arrowWidth ?? this.arrowWidth,
    gap: gap ?? this.gap,
    iconSize: iconSize ?? this.iconSize,
    iconGap: iconGap ?? this.iconGap,
    padding: padding ?? this.padding,
    textStyle: textStyle ?? this.textStyle,
    arrowIcon: arrowIcon ?? this.arrowIcon,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSplitButtonTheme &&
      other.defaultAppearance == defaultAppearance &&
      other.height == height &&
      other.shape == shape &&
      other.innerShape == innerShape &&
      other.arrowWidth == arrowWidth &&
      other.gap == gap &&
      other.iconSize == iconSize &&
      other.iconGap == iconGap &&
      other.padding == padding &&
      other.textStyle == textStyle &&
      other.arrowIcon == arrowIcon;

  @override
  int get hashCode => Object.hash(
    defaultAppearance,
    height,
    shape,
    innerShape,
    arrowWidth,
    gap,
    iconSize,
    iconGap,
    padding,
    textStyle,
    arrowIcon,
  );
}

/// The resolved split button style: every field set.
@immutable
class CamoSplitButtonStyle {
  /// Creates a style.
  const CamoSplitButtonStyle({
    required this.defaultAppearance,
    required this.height,
    required this.shape,
    required this.innerShape,
    required this.arrowWidth,
    required this.gap,
    required this.iconSize,
    required this.iconGap,
    required this.padding,
    required this.textStyle,
    required this.arrowIcon,
  });

  /// The appearance when a call passes none.
  final Appearance defaultAppearance;

  /// Button height.
  final double height;

  /// The outer corners.
  final BorderRadius shape;

  /// The corners between the parts.
  final BorderRadius innerShape;

  /// The arrow part.
  final double arrowWidth;

  /// The gap between the parts (0 draws a divider line instead).
  final double gap;

  /// Icons.
  final double iconSize;

  /// Icon to label.
  final double iconGap;

  /// Start and end of the label part.
  final double padding;

  /// The label.
  final TextStyle textStyle;

  /// The arrow.
  final IconSource arrowIcon;

  /// This style with [o]'s non-null fields applied.
  CamoSplitButtonStyle merge(CamoSplitButtonTheme? o) => o == null
      ? this
      : CamoSplitButtonStyle(
          defaultAppearance: o.defaultAppearance ?? defaultAppearance,
          height: o.height ?? height,
          shape: o.shape ?? shape,
          innerShape: o.innerShape ?? innerShape,
          arrowWidth: o.arrowWidth ?? arrowWidth,
          gap: o.gap ?? gap,
          iconSize: o.iconSize ?? iconSize,
          iconGap: o.iconGap ?? iconGap,
          padding: o.padding ?? padding,
          textStyle: o.textStyle ?? textStyle,
          arrowIcon: o.arrowIcon ?? arrowIcon,
        );
}

/// What a split button renderer draws. [hasAction] is `false` for a menu button: one part, the whole button opens
/// the menu, and the arrow is drawn inside it. Draw the chevron turned when [expanded]. The colors are the
/// button's: `skin.button`'s style, resolved with `colorsFor(appearance, tone, theme)`.
@immutable
class SplitButtonState {
  /// Creates a split button state.
  const SplitButtonState({
    required this.text,
    required this.hasAction,
    required this.expanded,
    required this.appearance,
    required this.tone,
    required this.enabled,
    required this.mainInteraction,
    required this.arrowInteraction,
    required this.mainController,
    required this.arrowController,
  });

  /// The label.
  final String text;

  /// `false` for a menu button.
  final bool hasAction;

  /// Whether the menu is open.
  final bool expanded;

  /// The visual weight.
  final Appearance appearance;

  /// The color family.
  final Tone tone;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The label part's pressed, focused and hovered state.
  final InteractionState mainInteraction;

  /// The arrow part's pressed, focused and hovered state.
  final InteractionState arrowInteraction;

  /// The source of [mainInteraction], for the skin's feedback.
  final CamoInteractionController mainController;

  /// The source of [arrowInteraction], for the skin's feedback.
  final CamoInteractionController arrowController;
}

/// The caller's icon before the text.
@immutable
class SplitButtonSlots {
  /// Creates the slots.
  const SplitButtonSlots({this.prefixIcon});

  /// The icon.
  final Widget? prefixIcon;
}

/// The behavior of the two parts: wrap the label part's visual in [main] and the arrow part's in [arrow]. For a
/// menu button wrap the whole visual in [main].
@immutable
class SplitButtonBehavior {
  /// Creates the behavior.
  const SplitButtonBehavior({required this.main, required this.arrow});

  /// Wraps the label part.
  final Widget Function(Widget child) main;

  /// Wraps the arrow part.
  final Widget Function(Widget child) arrow;
}

/// Draws split buttons.
abstract interface class CamoSplitButtonRenderer {
  /// The complete split button style for [theme].
  CamoSplitButtonStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots], wrapping the parts with [behavior].
  Widget render(
    BuildContext context,
    SplitButtonState state,
    SplitButtonSlots slots,
    SplitButtonBehavior behavior,
    CamoTheme theme,
    CamoSplitButtonStyle style,
  );
}

/// A main action with a menu of related ones ("Save", with "Save as…" behind the arrow). Tab reaches the main part,
/// then the arrow; Enter or Space presses the focused part; Down or Alt+Down on either opens the [menu] and
/// focuses its first item; Esc closes it and returns focus. An [onPressed] of `null` makes a menu button: one part
/// that opens the menu. [menuSemanticLabel] names the arrow. `enabled: false` disables both parts.
class CamoSplitButton extends StatefulWidget {
  /// Creates a split button.
  const CamoSplitButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.menu,
    this.appearance,
    this.tone = Tone.defaultTone,
    this.enabled = true,
    this.prefixIcon,
    this.menuSemanticLabel = 'More options',
  });

  /// The label.
  final String text;

  /// The main action; `null` makes a menu button.
  final VoidCallback? onPressed;

  /// The menu's entries.
  final List<CamoMenuEntry> menu;

  /// The visual weight; `null` uses the theme's default.
  final Appearance? appearance;

  /// The color family.
  final Tone tone;

  /// `false` disables both parts.
  final bool enabled;

  /// An icon before the text.
  final Widget? prefixIcon;

  /// Names the arrow part.
  final String menuSemanticLabel;

  @override
  State<CamoSplitButton> createState() => _CamoSplitButtonState();
}

class _CamoSplitButtonState extends State<CamoSplitButton> {
  final _main = CamoInteractionController();
  final _arrow = CamoInteractionController();
  final _menu = CamoMenuController();

  @override
  void dispose() {
    _main.dispose();
    _arrow.dispose();
    _menu.dispose();
    super.dispose();
  }

  Widget _part(
    CamoInteractionController controller,
    VoidCallback onActivate,
    String label,
    bool? expanded,
    Widget child,
  ) => CamoBehavior(
    controller: controller,
    enabled: widget.enabled,
    onActivate: onActivate,
    semantics: (child) => Semantics(
      button: true,
      enabled: widget.enabled,
      expanded: expanded,
      label: label,
      excludeSemantics: true,
      child: child,
    ),
    child: CamoTouchTarget(
      minSize: const Size(0, kCamoMinTouchTarget),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSplitButton');
    final theme = Camouflage.themeOf(context, component: 'CamoSplitButton');
    final style = skin.splitButton
        .defaults(theme)
        .merge(theme.components.splitButton);
    final action = widget.onPressed;
    return CamoMenuAnchor(
      controller: _menu,
      items: widget.menu,
      builder: (context, open) => ListenableBuilder(
        listenable: _menu,
        builder: (context, _) {
          final expanded = _menu.isOpen;
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): open,
              const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
                  open,
            },
            child: ListenableBuilder(
              listenable: Listenable.merge([_main, _arrow]),
              builder: (context, _) => skin.splitButton.render(
                context,
                SplitButtonState(
                  text: widget.text,
                  hasAction: action != null,
                  expanded: expanded,
                  appearance: widget.appearance ?? style.defaultAppearance,
                  tone: widget.tone,
                  enabled: widget.enabled,
                  mainInteraction: _main.value,
                  arrowInteraction: _arrow.value,
                  mainController: _main,
                  arrowController: _arrow,
                ),
                SplitButtonSlots(
                  prefixIcon: widget.prefixIcon == null
                      ? null
                      : ExcludeSemantics(child: widget.prefixIcon),
                ),
                SplitButtonBehavior(
                  main: (child) => _part(
                    _main,
                    action ?? open,
                    widget.text,
                    action == null ? expanded : null,
                    child,
                  ),
                  arrow: (child) => _part(
                    _arrow,
                    open,
                    widget.menuSemanticLabel,
                    expanded,
                    child,
                  ),
                ),
                theme,
                style,
              ),
            ),
          );
        },
      ),
    );
  }
}
