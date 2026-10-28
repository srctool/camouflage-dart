import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'fluent_pickers.dart' show dropdownChevronIcon;

import '../fluent_tokens.dart';

// Fluent's Input + Field and SearchBox (base Fluent Skin §3.2): 32 tall, radius 4, a stroke with a stronger
// bottom edge that turns brand (2 px) on focus, the label above.

const double _hairline = 1;
const double _disabled = 0.38;

/// Fluent's Input + Field: 32 tall, radius 4, a stroke with a stronger bottom edge; the label above.
class FluentTextFieldRenderer implements CamoTextFieldRenderer {
  /// Creates the renderer.
  const FluentTextFieldRenderer();

  @override
  CamoTextFieldStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    return CamoTextFieldStyle(
      labelPlacement: LabelPlacement.above,
      height: 32,
      shape: theme.shapes.small,
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing.m,
      ),
      textStyle: t.bodyMedium,
      labelStyle: t.bodyMedium,
      floatingLabelStyle: t.bodyMedium,
      supportingTextStyle: t.bodySmall,
      iconSize: 20,
      borderWidth: _hairline,
      focusedBorderWidth: 2,
      dropdownIcon: const IconSource.builder(dropdownChevronIcon),
      colors: TextFieldColors(
        container: c.surface,
        border:
            theme.tokens<FluentTokens>()?.neutralStroke1 ?? c.outlineVariant,
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
    // The bottom edge: the stronger neutral stroke, brand and thicker when focused, the error color in error.
    final accent = error
        ? c.errorBorder
        : (state.focused ? c.focusedBorder : theme.colors.outline);
    final accentWidth = state.focused
        ? style.focusedBorderWidth
        : style.borderWidth;
    final floating =
        style.labelPlacement == LabelPlacement.floating && state.label != null;
    final frame = Container(
      foregroundDecoration: _BottomAccent(accent, accentWidth, style.shape),
      decoration: BoxDecoration(
        color: c.container,
        borderRadius: style.shape,
        border: Border.all(
          color: error ? c.errorBorder : c.border,
          width: style.borderWidth,
        ),
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

/// Fluent's SearchBox: the input's look with a search icon and a dismiss action, 32 tall.
class FluentSearchFieldRenderer implements CamoSearchFieldRenderer {
  /// Creates the renderer.
  const FluentSearchFieldRenderer();

  @override
  CamoSearchFieldStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSearchFieldStyle(
      height: 32,
      shape: theme.shapes.small,
      textStyle: theme.typography.bodyMedium,
      placeholderStyle: theme.typography.bodyMedium,
      iconSize: 20,
      searchIcon: const IconSource.builder(_searchIcon),
      clearIcon: const IconSource.builder(_clearIcon),
      colors: SearchFieldColors(
        container: c.surface,
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
        padding: EdgeInsetsDirectional.only(start: theme.spacing.s),
        foregroundDecoration: _BottomAccent(
          state.focused ? theme.colors.primary : theme.colors.outline,
          state.focused ? 2 : _hairline,
          style.shape,
        ),
        decoration: BoxDecoration(
          color: c.container,
          borderRadius: style.shape,
          border: Border.all(
            color:
                theme.tokens<FluentTokens>()?.neutralStroke1 ??
                theme.colors.outlineVariant,
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

// Fluent's input bottom edge: a line [width] tall along the bottom, inside the rounded corners.
class _BottomAccent extends Decoration {
  const _BottomAccent(this.color, this.width, this.shape);

  final Color color;
  final double width;
  final BorderRadius shape;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _AccentPainter(this);
}

class _AccentPainter extends BoxPainter {
  _AccentPainter(this.decoration);

  final _BottomAccent decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final rect = offset & size;
    canvas
      ..save()
      ..clipRRect(decoration.shape.toRRect(rect))
      ..drawRect(
        Rect.fromLTWH(
          rect.left,
          rect.bottom - decoration.width,
          rect.width,
          decoration.width,
        ),
        Paint()..color = decoration.color,
      )
      ..restore();
  }
}
