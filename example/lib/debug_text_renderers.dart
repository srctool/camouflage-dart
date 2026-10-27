import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// DebugSkin's text inputs: a bordered column (label, a row of prefix / input / suffix, then the message).

const _focus = Color(0xFFFF00FF);

Widget _square(double size, Color? color) => SizedBox.square(
  dimension: size,
  child: ColoredBox(color: color ?? const Color(0xFF000000)),
);

/// DebugSkin's text field.
class DebugTextFieldRenderer implements CamoTextFieldRenderer {
  /// Creates the renderer.
  const DebugTextFieldRenderer();

  @override
  CamoTextFieldStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoTextFieldStyle(
      labelPlacement: LabelPlacement.above,
      height: 48,
      shape: BorderRadius.zero,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing.m,
      ),
      textStyle: t.bodyLarge,
      labelStyle: t.bodyLarge,
      floatingLabelStyle: t.labelMedium,
      supportingTextStyle: t.bodySmall,
      iconSize: 20,
      borderWidth: 1,
      focusedBorderWidth: 2,
      colors: TextFieldColors(
        container: const Color(0x00000000),
        border: c.outline,
        focusedBorder: _focus,
        errorBorder: c.error,
        text: c.onSurface,
        label: c.onSurface,
        placeholder: c.onSurfaceVariant,
        icon: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    TextFieldState state,
    TextFieldSlots slots,
    CamoTheme theme,
    CamoTextFieldStyle style,
  ) {
    final c = style.colors;
    final border = state.error != null
        ? c.errorBorder
        : (state.focused ? c.focusedBorder : c.border);
    final message = state.error ?? state.supportingText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.label != null)
          ExcludeSemantics(
            child: Text(
              '[${style.labelPlacement.name}] ${state.label}',
              style: style.floatingLabelStyle.copyWith(color: c.label),
            ),
          ),
        Container(
          constraints: BoxConstraints(minHeight: style.height),
          padding: style.contentPadding,
          decoration: BoxDecoration(
            border: Border.all(color: border, width: state.focused ? 2 : 1),
          ),
          child: CamoContentStyle(
            color: c.icon,
            iconStyle: CamoIconStyle(size: style.iconSize, color: c.icon),
            child: Row(
              spacing: theme.spacing.s,
              children: [
                ?slots.prefixIcon,
                if (state.prefixText != null) Text(state.prefixText!),
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      if (state.isEmpty && state.placeholder != null)
                        ExcludeSemantics(
                          child: Text(
                            state.placeholder!,
                            style: style.textStyle.copyWith(
                              color: c.placeholder,
                            ),
                          ),
                        ),
                      slots.input,
                    ],
                  ),
                ),
                if (state.suffixText != null) Text(state.suffixText!),
                ?slots.suffixIcon,
              ],
            ),
          ),
        ),
        if (message != null)
          ExcludeSemantics(
            child: Text(
              message,
              style: style.supportingTextStyle.copyWith(
                color: state.error != null ? c.errorBorder : c.placeholder,
              ),
            ),
          ),
      ],
    );
  }

  @override
  TextSelectionControls selectionControls(BuildContext context) =>
      CamoTextSelectionControls(_focus);

  @override
  Widget contextMenuBuilder(BuildContext context, EditableTextState state) =>
      camoSystemContextMenu(context, state);
}

/// DebugSkin's search field.
class DebugSearchFieldRenderer implements CamoSearchFieldRenderer {
  /// Creates the renderer.
  const DebugSearchFieldRenderer();

  @override
  CamoSearchFieldStyle defaults(CamoTheme theme) => CamoSearchFieldStyle(
    height: 48,
    shape: BorderRadius.zero,
    textStyle: theme.typography.bodyLarge,
    placeholderStyle: theme.typography.bodyLarge,
    iconSize: 20,
    searchIcon: const IconSource.builder(_square),
    clearIcon: const IconSource.builder(_square),
    colors: SearchFieldColors(
      container: theme.colors.surfaceContainerHigh,
      text: theme.colors.onSurface,
      placeholder: theme.colors.onSurfaceVariant,
      icon: theme.colors.onSurfaceVariant,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    SearchFieldState state,
    SearchFieldSlots slots,
    CamoTheme theme,
    CamoSearchFieldStyle style,
  ) => Container(
    constraints: BoxConstraints(minHeight: style.height),
    padding: EdgeInsets.symmetric(horizontal: theme.spacing.s),
    decoration: BoxDecoration(
      color: style.colors.container,
      border: Border.all(
        color: state.focused ? _focus : theme.colors.outline,
        width: state.focused ? 2 : 1,
      ),
    ),
    child: CamoContentStyle(
      color: style.colors.icon,
      iconStyle: CamoIconStyle(size: style.iconSize, color: style.colors.icon),
      child: Row(
        spacing: theme.spacing.s,
        children: [
          slots.leading,
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                if (state.isEmpty)
                  ExcludeSemantics(child: Text(state.placeholder)),
                slots.input,
              ],
            ),
          ),
          ?slots.clear,
          ?slots.trailing,
        ],
      ),
    ),
  );
}
