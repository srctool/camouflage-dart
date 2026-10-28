import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'minimal_pickers.dart' show dropdownChevronIcon;

// Minimal's text field and search field (base Minimal Skin §3.4): a 44 field with a hairline, a 2 px primary
// ring when focused, the label above by default.

const double _hairline = 1;
const double _disabled = 0.38;
const _clear = Color(0x00000000);

/// Minimal's text field: 44 tall, radius 8, a hairline; the label above (or floating, by the theme).
class MinimalTextFieldRenderer implements CamoTextFieldRenderer {
  /// Creates the renderer with the default [labelPlacement].
  const MinimalTextFieldRenderer({this.labelPlacement = LabelPlacement.above});

  /// The label placement when the theme doesn't set one.
  final LabelPlacement labelPlacement;

  @override
  CamoTextFieldStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoTextFieldStyle(
      labelPlacement: labelPlacement,
      height: 44,
      shape: theme.shapes.medium,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing.m,
      ),
      textStyle: t.bodyLarge,
      labelStyle: t.bodyLarge,
      floatingLabelStyle: t.labelMedium,
      supportingTextStyle: t.bodySmall,
      iconSize: 18,
      borderWidth: _hairline,
      focusedBorderWidth: 2,
      dropdownIcon: const IconSource.builder(dropdownChevronIcon),
      colors: TextFieldColors(
        container: _clear,
        border: c.outline,
        focusedBorder: c.primary,
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
    final error = state.error != null;
    final border = error
        ? c.errorBorder
        : (state.focused ? c.focusedBorder : c.border);
    final width = state.focused ? style.focusedBorderWidth : style.borderWidth;
    final floating =
        style.labelPlacement == LabelPlacement.floating && state.label != null;
    final frame = Container(
      decoration: BoxDecoration(
        color: c.container,
        borderRadius: style.shape,
        border: Border.all(color: border, width: width),
      ),
      child: _row(
        state,
        slots,
        style,
        theme,
        showPlaceholder: state.isEmpty && (!floating || state.focused),
      ),
    );
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._labelled(state, slots, style, theme, floating, frame),
          ?_message(state, style, theme),
        ],
      ),
    );
  }

  @override
  TextSelectionControls selectionControls(BuildContext context) =>
      CamoTextSelectionControls(Camouflage.colorsOf(context).primary);

  @override
  Widget contextMenuBuilder(BuildContext context, EditableTextState state) =>
      camoSystemContextMenu(context, state);
}

/// Minimal's search field: 40 tall, radius 8, a `surfaceContainer` fill with no border, icons 18.
class MinimalSearchFieldRenderer implements CamoSearchFieldRenderer {
  /// Creates the renderer.
  const MinimalSearchFieldRenderer();

  @override
  CamoSearchFieldStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSearchFieldStyle(
      height: 40,
      shape: theme.shapes.medium,
      textStyle: theme.typography.bodyLarge,
      placeholderStyle: theme.typography.bodyLarge,
      iconSize: 18,
      searchIcon: const IconSource.builder(_searchIcon),
      clearIcon: const IconSource.builder(_clearIcon),
      colors: SearchFieldColors(
        container: c.surfaceContainer,
        text: c.onSurface,
        placeholder: c.onSurfaceVariant,
        icon: c.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    SearchFieldState state,
    SearchFieldSlots slots,
    CamoTheme theme,
    CamoSearchFieldStyle style,
  ) {
    final c = style.colors;
    return Opacity(
      opacity: state.enabled ? 1 : _disabled,
      child: Container(
        constraints: BoxConstraints(minHeight: style.height),
        padding: EdgeInsetsDirectional.only(start: theme.spacing.m),
        decoration: BoxDecoration(
          color: c.container,
          borderRadius: style.shape,
          border: Border.all(
            color: state.focused ? theme.colors.primary : _clear,
            width: 2,
          ),
        ),
        child: CamoContentStyle(
          color: c.icon,
          iconStyle: CamoIconStyle(size: style.iconSize, color: c.icon),
          child: Row(
            spacing: theme.spacing.s,
            children: [
              slots.leading,
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    if (state.isEmpty)
                      ExcludeSemantics(
                        child: Text(
                          state.placeholder,
                          maxLines: 1,
                          style: style.placeholderStyle.copyWith(
                            color: c.placeholder,
                          ),
                        ),
                      ),
                    slots.input,
                  ],
                ),
              ),
              ?slots.clear,
              ?slots.trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// The field with its label: above it, floating in it, or none.
List<Widget> _labelled(
  TextFieldState state,
  TextFieldSlots slots,
  CamoTextFieldStyle style,
  CamoTheme theme,
  bool floating,
  Widget frame,
) {
  final c = style.colors;
  final label = state.label;
  if (label == null) return [frame];
  if (floating) {
    final error = state.error != null;
    return [
      CamoFloatingLabel(
        label: label,
        floated: state.focused || !state.isEmpty,
        restingStyle: style.labelStyle,
        floatedStyle: style.floatingLabelStyle,
        color: error
            ? c.errorBorder
            : (state.focused ? c.focusedBorder : c.placeholder),
        cutout: theme.colors.surface,
        startInset:
            style.contentPadding.start +
            (slots.prefixIcon != null ? style.iconSize + theme.spacing.s : 0),
        theme: theme,
        field: frame,
      ),
    ];
  }
  return [
    Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.xs),
      child: ExcludeSemantics(
        child: CamoText(label, style: style.floatingLabelStyle, color: c.label),
      ),
    ),
    frame,
  ];
}

// The framed row: prefix icon and text, the input with its placeholder, suffix text and icon.
Widget _row(
  TextFieldState state,
  TextFieldSlots slots,
  CamoTextFieldStyle style,
  CamoTheme theme, {
  required bool showPlaceholder,
}) {
  final c = style.colors;
  final suffixColor = state.error != null ? c.errorBorder : c.icon;
  final affix = state.focused || !state.isEmpty;
  final affixStyle = style.textStyle.copyWith(color: c.placeholder);
  return Container(
    constraints: BoxConstraints(minHeight: style.height),
    padding: style.contentPadding,
    child: Row(
      spacing: theme.spacing.s,
      children: [
        if (slots.prefixIcon != null)
          CamoContentStyle(
            color: c.icon,
            iconStyle: CamoIconStyle(size: style.iconSize, color: c.icon),
            child: slots.prefixIcon!,
          ),
        if (affix && state.prefixText != null)
          Text(state.prefixText!, style: affixStyle),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacing.s),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                if (showPlaceholder && state.placeholder != null)
                  ExcludeSemantics(
                    child: Text(
                      state.placeholder!,
                      maxLines: 1,
                      style: style.textStyle.copyWith(color: c.placeholder),
                    ),
                  ),
                slots.input,
              ],
            ),
          ),
        ),
        if (affix && state.suffixText != null)
          Text(state.suffixText!, style: affixStyle),
        if (slots.suffixIcon != null)
          CamoContentStyle(
            color: suffixColor,
            iconStyle: CamoIconStyle(size: style.iconSize, color: suffixColor),
            child: slots.suffixIcon!,
          ),
      ],
    ),
  );
}

// The supporting text, or the error in its place. Core marks the error on the input, so the text hides.
Widget? _message(
  TextFieldState state,
  CamoTextFieldStyle style,
  CamoTheme theme,
) {
  final error = state.error;
  final text = error ?? state.supportingText;
  if (text == null) return null;
  final message = CamoText(
    text,
    style: style.supportingTextStyle,
    color: error != null ? style.colors.errorBorder : style.colors.placeholder,
  );
  return Padding(
    padding: EdgeInsets.only(top: theme.spacing.xs),
    child: error != null ? ExcludeSemantics(child: message) : message,
  );
}

Widget _searchIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _GlyphPainter(color ?? const Color(0xFF000000), search: true),
);

Widget _clearIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _GlyphPainter(color ?? const Color(0xFF000000), search: false),
);

// A magnifier or an ×, stroked in [color].
class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.color, {required this.search});

  final Color color;
  final bool search;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    if (search) {
      canvas
        ..drawCircle(Offset(10.5 * s, 10.5 * s), 6.5 * s, paint)
        ..drawLine(Offset(15.5 * s, 15.5 * s), Offset(20 * s, 20 * s), paint);
    } else {
      canvas
        ..drawLine(Offset(6 * s, 6 * s), Offset(18 * s, 18 * s), paint)
        ..drawLine(Offset(18 * s, 6 * s), Offset(6 * s, 18 * s), paint);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.color != color || old.search != search;
}
