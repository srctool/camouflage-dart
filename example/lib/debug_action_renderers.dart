import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M9 button group, split button and toolbar in the debug skin: boxes, rows and text, no decoration.

/// A placeholder icon.
Widget _actionIcon(double size, Color? color) =>
    SizedBox.square(dimension: size);

/// The debug skin's button group renderer.
class DebugButtonGroup implements CamoButtonGroupRenderer {
  /// Creates the renderer.
  const DebugButtonGroup();

  @override
  CamoButtonGroupStyle defaults(CamoTheme theme) => CamoButtonGroupStyle(
    defaultAppearance: Appearance.outline,
    height: 36,
    shape: BorderRadius.zero,
    innerShape: BorderRadius.zero,
    spacing: 4,
    borderWidth: 1,
    iconSize: 16,
    iconGap: 8,
    textStyle: theme.typography.labelLarge,
    colors: GroupColors(
      content: theme.colors.onSurface,
      border: theme.colors.outline,
      selectedContainer: theme.colors.primary,
      selectedContent: theme.colors.onPrimary,
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    ButtonGroupState state,
    CamoTheme theme,
    CamoButtonGroupStyle style,
    List<Widget> buttons,
  ) => Row(mainAxisSize: MainAxisSize.min, children: buttons);

  @override
  Widget renderButton(
    BuildContext context,
    GroupButtonState state,
    GroupButtonSlots slots,
    CamoTheme theme,
    CamoButtonGroupStyle style,
  ) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [?slots.icon, if (slots.text != null) Text(slots.text!)],
      ),
    );
  }
}

/// The debug skin's split button renderer.
class DebugSplitButton implements CamoSplitButtonRenderer {
  /// Creates the renderer.
  const DebugSplitButton();

  @override
  CamoSplitButtonStyle defaults(CamoTheme theme) => CamoSplitButtonStyle(
    defaultAppearance: Appearance.solid,
    height: 40,
    shape: BorderRadius.zero,
    innerShape: BorderRadius.zero,
    arrowWidth: 40,
    gap: 2,
    iconSize: 16,
    iconGap: 8,
    padding: 12,
    textStyle: theme.typography.labelLarge,
    arrowIcon: const IconSource.builder(_actionIcon),
  );

  @override
  Widget render(
    BuildContext context,
    SplitButtonState state,
    SplitButtonSlots slots,
    SplitButtonBehavior behavior,
    CamoTheme theme,
    CamoSplitButtonStyle style,
  ) {
    if (!state.hasAction) {
      return behavior.main(
        Padding(padding: const EdgeInsets.all(4), child: Text(state.text)),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        behavior.main(
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [?slots.prefixIcon, Text(state.text)],
            ),
          ),
        ),
        behavior.arrow(const SizedBox.square(dimension: 40)),
      ],
    );
  }
}

/// The debug skin's toolbar renderer.
class DebugToolbar implements CamoToolbarRenderer {
  /// Creates the renderer.
  const DebugToolbar();

  @override
  CamoToolbarStyle defaults(CamoTheme theme) => CamoToolbarStyle(
    placement: ToolbarPlacement.docked,
    height: 56,
    actionSize: 48,
    floatingMargin: 8,
    floatingShape: BorderRadius.zero,
    floatingElevation: ElevationLevel.level2,
    actionSpacing: 4,
    padding: 8,
    showDivider: false,
    overflowIcon: const IconSource.builder(_actionIcon),
    colors: ToolbarColors(
      container: theme.colors.surface,
      divider: theme.colors.outlineVariant,
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    ToolbarState state,
    CamoTheme theme,
    CamoToolbarStyle style,
    Widget child,
  ) {
    return ColoredBox(
      color: style.colors.container,
      child: SizedBox(height: style.height, child: child),
    );
  }
}
