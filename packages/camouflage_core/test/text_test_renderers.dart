import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M5 text inputs in the plain test skin: a bordered column with the label, the input and the messages.

Widget _dot(double size, Color? color) => SizedBox.square(dimension: size);

class PlainTextField implements CamoTextFieldRenderer {
  const PlainTextField();

  @override
  CamoTextFieldStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoTextFieldStyle(
      labelPlacement: LabelPlacement.above,
      height: 48,
      shape: BorderRadius.zero,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      textStyle: t.bodyLarge,
      labelStyle: t.bodyLarge,
      floatingLabelStyle: t.bodySmall,
      supportingTextStyle: t.bodySmall,
      iconSize: 24,
      borderWidth: 1,
      focusedBorderWidth: 2,
      colors: TextFieldColors(
        container: const Color(0x00000000),
        border: c.outline,
        focusedBorder: c.primary,
        errorBorder: c.error,
        text: c.onSurface,
        label: c.onSurfaceVariant,
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
    final message = state.error ?? state.supportingText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.label != null) ExcludeSemantics(child: Text(state.label!)),
        Container(
          constraints: BoxConstraints(minHeight: style.height),
          padding: style.contentPadding,
          decoration: BoxDecoration(
            border: Border.all(
              color: style.colors.border,
              width: style.borderWidth,
            ),
          ),
          child: Row(
            children: [
              ?slots.prefixIcon,
              if (state.prefixText != null) Text(state.prefixText!),
              Expanded(
                child: Stack(
                  children: [
                    if (state.isEmpty && state.placeholder != null)
                      ExcludeSemantics(child: Text(state.placeholder!)),
                    slots.input,
                  ],
                ),
              ),
              ?slots.suffixIcon,
            ],
          ),
        ),
        if (message != null) ExcludeSemantics(child: Text(message)),
      ],
    );
  }

  @override
  TextSelectionControls selectionControls(BuildContext context) =>
      EmptyTextSelectionControls();

  @override
  Widget contextMenuBuilder(BuildContext context, EditableTextState state) =>
      camoSystemContextMenu(context, state);
}

class PlainSearchField implements CamoSearchFieldRenderer {
  const PlainSearchField();

  @override
  CamoSearchFieldStyle defaults(CamoTheme theme) => CamoSearchFieldStyle(
    height: 48,
    shape: BorderRadius.zero,
    textStyle: theme.typography.bodyLarge,
    placeholderStyle: theme.typography.bodyLarge,
    iconSize: 24,
    searchIcon: const IconSource.builder(_dot),
    clearIcon: const IconSource.builder(_dot),
    colors: SearchFieldColors(
      container: const Color(0x00000000),
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
  ) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: style.height),
    child: Row(
      children: [
        slots.leading,
        Expanded(child: slots.input),
        ?slots.clear,
        ?slots.trailing,
      ],
    ),
  );
}
