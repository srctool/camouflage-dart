import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_error_semantics.dart';
import 'camo_formats.dart';

/// Where a field's label sits: [above] the field, or [floating] inside it and moving to the top edge.
enum LabelPlacement {
  /// A static label over the field.
  above,

  /// Inside the field, moving to the top edge on focus or when not empty.
  floating,
}

/// Every color a text field uses.
@immutable
class TextFieldColors {
  /// Creates text field colors.
  const TextFieldColors({
    required this.container,
    required this.border,
    required this.focusedBorder,
    required this.errorBorder,
    required this.text,
    required this.label,
    required this.placeholder,
    required this.icon,
  });

  /// The fill.
  final Color container;

  /// The resting border.
  final Color border;

  /// The border while focused.
  final Color focusedBorder;

  /// The border, error text and suffix icon in the error state.
  final Color errorBorder;

  /// The typed text.
  final Color text;

  /// The label.
  final Color label;

  /// The placeholder, prefix and suffix text.
  final Color placeholder;

  /// The icons.
  final Color icon;

  @override
  bool operator ==(Object other) =>
      other is TextFieldColors &&
      other.container == container &&
      other.border == border &&
      other.focusedBorder == focusedBorder &&
      other.errorBorder == errorBorder &&
      other.text == text &&
      other.label == label &&
      other.placeholder == placeholder &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(
    container,
    border,
    focusedBorder,
    errorBorder,
    text,
    label,
    placeholder,
    icon,
  );
}

/// Overrides for text fields (and the fields built on their frame); `null` keeps the skin's default.
@immutable
class CamoTextFieldTheme {
  /// Creates text field overrides.
  const CamoTextFieldTheme({
    this.labelPlacement,
    this.height,
    this.shape,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.floatingLabelStyle,
    this.supportingTextStyle,
    this.iconSize,
    this.borderWidth,
    this.focusedBorderWidth,
    this.colors,
  });

  /// Above or floating.
  final LabelPlacement? labelPlacement;

  /// The single-line height.
  final double? height;

  /// The corners.
  final BorderRadius? shape;

  /// Padding around the input.
  final EdgeInsetsDirectional? contentPadding;

  /// The typed text.
  final TextStyle? textStyle;

  /// The resting label.
  final TextStyle? labelStyle;

  /// The floated label, or the label above the field.
  final TextStyle? floatingLabelStyle;

  /// Supporting and error text.
  final TextStyle? supportingTextStyle;

  /// The icons' size.
  final double? iconSize;

  /// The resting border.
  final double? borderWidth;

  /// The focused border.
  final double? focusedBorderWidth;

  /// Every color it uses.
  final TextFieldColors? colors;

  /// A copy with the given fields replaced.
  CamoTextFieldTheme copyWith({
    LabelPlacement? labelPlacement,
    double? height,
    BorderRadius? shape,
    EdgeInsetsDirectional? contentPadding,
    TextStyle? textStyle,
    TextStyle? labelStyle,
    TextStyle? floatingLabelStyle,
    TextStyle? supportingTextStyle,
    double? iconSize,
    double? borderWidth,
    double? focusedBorderWidth,
    TextFieldColors? colors,
  }) => CamoTextFieldTheme(
    labelPlacement: labelPlacement ?? this.labelPlacement,
    height: height ?? this.height,
    shape: shape ?? this.shape,
    contentPadding: contentPadding ?? this.contentPadding,
    textStyle: textStyle ?? this.textStyle,
    labelStyle: labelStyle ?? this.labelStyle,
    floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
    supportingTextStyle: supportingTextStyle ?? this.supportingTextStyle,
    iconSize: iconSize ?? this.iconSize,
    borderWidth: borderWidth ?? this.borderWidth,
    focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoTextFieldTheme &&
      other.labelPlacement == labelPlacement &&
      other.height == height &&
      other.shape == shape &&
      other.contentPadding == contentPadding &&
      other.textStyle == textStyle &&
      other.labelStyle == labelStyle &&
      other.floatingLabelStyle == floatingLabelStyle &&
      other.supportingTextStyle == supportingTextStyle &&
      other.iconSize == iconSize &&
      other.borderWidth == borderWidth &&
      other.focusedBorderWidth == focusedBorderWidth &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    labelPlacement,
    height,
    shape,
    contentPadding,
    textStyle,
    labelStyle,
    floatingLabelStyle,
    supportingTextStyle,
    iconSize,
    borderWidth,
    focusedBorderWidth,
    colors,
  );
}

/// The resolved text field style: every field set.
@immutable
class CamoTextFieldStyle {
  /// Creates a text field style.
  const CamoTextFieldStyle({
    required this.labelPlacement,
    required this.height,
    required this.shape,
    required this.contentPadding,
    required this.textStyle,
    required this.labelStyle,
    required this.floatingLabelStyle,
    required this.supportingTextStyle,
    required this.iconSize,
    required this.borderWidth,
    required this.focusedBorderWidth,
    required this.colors,
  });

  /// Above or floating.
  final LabelPlacement labelPlacement;

  /// The single-line height.
  final double height;

  /// The corners.
  final BorderRadius shape;

  /// Padding around the input.
  final EdgeInsetsDirectional contentPadding;

  /// The typed text.
  final TextStyle textStyle;

  /// The resting label.
  final TextStyle labelStyle;

  /// The floated label, or the label above the field.
  final TextStyle floatingLabelStyle;

  /// Supporting and error text.
  final TextStyle supportingTextStyle;

  /// The icons' size.
  final double iconSize;

  /// The resting border.
  final double borderWidth;

  /// The focused border.
  final double focusedBorderWidth;

  /// Every color it uses.
  final TextFieldColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoTextFieldStyle merge(CamoTextFieldTheme? o) => o == null
      ? this
      : CamoTextFieldStyle(
          labelPlacement: o.labelPlacement ?? labelPlacement,
          height: o.height ?? height,
          shape: o.shape ?? shape,
          contentPadding: o.contentPadding ?? contentPadding,
          textStyle: o.textStyle ?? textStyle,
          labelStyle: o.labelStyle ?? labelStyle,
          floatingLabelStyle: o.floatingLabelStyle ?? floatingLabelStyle,
          supportingTextStyle: o.supportingTextStyle ?? supportingTextStyle,
          iconSize: o.iconSize ?? iconSize,
          borderWidth: o.borderWidth ?? borderWidth,
          focusedBorderWidth: o.focusedBorderWidth ?? focusedBorderWidth,
          colors: o.colors ?? colors,
        );
}

/// What a text field renderer draws around the input: the label (by `style.labelPlacement`), the placeholder
/// while [isEmpty], [prefixText] and [suffixText] while focused or not empty, the border for the focused and
/// error states, and [supportingText] or [error] below. Core names the input and marks the error on it, so the
/// label, placeholder and error texts exclude their own semantics.
@immutable
class TextFieldState {
  /// Creates a text field state.
  const TextFieldState({
    required this.value,
    required this.label,
    required this.placeholder,
    required this.supportingText,
    required this.error,
    required this.prefixText,
    required this.suffixText,
    required this.enabled,
    required this.focused,
    required this.singleLine,
    required this.secure,
    required this.isEmpty,
    required this.interaction,
    required this.controller,
  });

  /// The raw value.
  final String value;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error, shown instead of [supportingText].
  final String? error;

  /// Fixed text before the input ("+62").
  final String? prefixText;

  /// Fixed text after the input ("kg").
  final String? suffixText;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The input has focus.
  final bool focused;

  /// One line.
  final bool singleLine;

  /// Obscured text.
  final bool secure;

  /// No text yet.
  final bool isEmpty;

  /// Focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction].
  final CamoInteractionController controller;
}

/// The caller's icons and core's [input]: the editable widget, already filtered, formatted and styled. The
/// renderer places [input] and never recreates it, so a skin switch keeps focus, text and selection.
@immutable
class TextFieldSlots {
  /// Creates the slots.
  const TextFieldSlots({this.prefixIcon, this.suffixIcon, required this.input});

  /// A decorative icon at the start.
  final Widget? prefixIcon;

  /// An icon or a `CamoFieldAction` at the end.
  final Widget? suffixIcon;

  /// The editable widget.
  final Widget input;
}

/// Draws text fields and every field built on their frame, and supplies the text-editing visuals.
abstract interface class CamoTextFieldRenderer {
  /// The complete text field style for [theme].
  CamoTextFieldStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    TextFieldState state,
    TextFieldSlots slots,
    CamoTheme theme,
    CamoTextFieldStyle style,
  );

  /// The selection handles.
  TextSelectionControls selectionControls(BuildContext context);

  /// The copy and paste menu.
  Widget contextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  );
}

/// A controlled text field. [value] is raw text: [inputFilter] blocks or trims input before it reaches
/// [onChanged], and [displayFormat] shows formatting (dashes, thousand separators) without storing it, with the
/// cursor kept in place. If the app doesn't take a change, the field keeps showing [value]. [error] replaces
/// [supportingText] and marks it invalid. [prefixText] / [suffixText] ("+62", "kg") are never part of the
/// value. The editable widget lives here, not in the skin, so switching skins while typing keeps focus and
/// selection.
class CamoTextField extends StatefulWidget {
  /// Creates a text field.
  const CamoTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
    this.singleLine = true,
    this.secure = false,
    this.onFocusChanged,
    this.inputFilter,
    this.displayFormat,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.focusNode,
  }) : assert(
         !(secure && displayFormat != null),
         "CamoTextField: a secure field can't have a displayFormat.",
       );

  /// The raw value.
  final String value;

  /// Called with each accepted raw value.
  final ValueChanged<String>? onChanged;

  /// The label, which also names the field.
  final String? label;

  /// Shown while empty (not a label).
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// Marks it invalid and replaces [supportingText].
  final String? error;

  /// A decorative icon at the start.
  final Widget? prefixIcon;

  /// An icon or a `CamoFieldAction` at the end.
  final Widget? suffixIcon;

  /// Fixed text before the input.
  final String? prefixText;

  /// Fixed text after the input.
  final String? suffixText;

  /// `false` disables it.
  final bool enabled;

  /// One line.
  final bool singleLine;

  /// A password: obscured, no autocorrect, no copy.
  final bool secure;

  /// Reports focus changes (for `onUnfocus` validation).
  final ValueChanged<bool>? onFocusChanged;

  /// Which input is accepted.
  final CamoInputFilter? inputFilter;

  /// How the raw value is shown.
  final CamoDisplayFormat? displayFormat;

  /// The keyboard.
  final TextInputType? keyboardType;

  /// The keyboard's action button.
  final TextInputAction? textInputAction;

  /// Called by the keyboard's action.
  final ValueChanged<String>? onSubmitted;

  /// Autofill hints for password managers.
  final Iterable<String>? autofillHints;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoTextField> createState() => _CamoTextFieldState();
}

class _CamoTextFieldState extends State<CamoTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final _interaction = CamoInteractionController();
  late final _ControlledText _text = _ControlledText(
    this,
    () => widget.value,
    (v) => widget.onChanged?.call(v),
  );
  FocusNode? _ownFocus;
  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !widget.secure;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  CamoTextFormatter get _formatter => CamoTextFormatter(
    filter: widget.inputFilter,
    format: widget.displayFormat,
  );

  @override
  void initState() {
    super.initState();
    _text.init(_formatter);
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(CamoTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_focusChanged);
      _focus.addListener(_focusChanged);
    }
    _text.sync(_formatter);
  }

  void _focusChanged() {
    _interaction.setFocused(_focus.hasFocus);
    widget.onFocusChanged?.call(_focus.hasFocus);
    setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _ownFocus?.dispose();
    _text.dispose();
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoTextField');
    final theme = Camouflage.themeOf(context, component: 'CamoTextField');
    final style = skin.textField
        .defaults(theme)
        .merge(theme.components.textField);
    final enabled = widget.enabled && widget.onChanged != null;
    final textStyle = style.textStyle.copyWith(color: style.colors.text);
    final Widget input = CamoErrorSemantics(
      message: widget.error,
      child: Semantics(
        label: widget.label ?? widget.placeholder,
        child: _gestures.buildGestureDetector(
          behavior: HitTestBehavior.translucent,
          // Disabled takes no focus (a tap, Tab); read-only (no onChanged) still focuses for copying.
          child: ExcludeFocus(
            excluding: !widget.enabled,
            child: EditableText(
              key: editableTextKey,
              controller: _text.controller,
              focusNode: _focus,
              readOnly: !enabled,
              obscureText: widget.secure,
              autocorrect: !widget.secure,
              enableSuggestions: !widget.secure,
              style: textStyle,
              cursorColor: style.colors.text,
              backgroundCursorColor: style.colors.placeholder,
              selectionColor: style.colors.focusedBorder.withValues(alpha: 0.3),
              selectionControls: skin.textField.selectionControls(context),
              contextMenuBuilder: widget.secure
                  ? null
                  : (context, state) =>
                        skin.textField.contextMenuBuilder(context, state),
              rendererIgnoresPointer: true,
              maxLines: widget.singleLine ? 1 : null,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              autofillHints: widget.autofillHints,
              inputFormatters: [_formatter],
              onChanged: _text.changed,
            ),
          ),
        ),
      ),
    );
    final Widget field = ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.textField.render(
        context,
        TextFieldState(
          value: _text.raw,
          label: widget.label,
          placeholder: widget.placeholder,
          supportingText: widget.supportingText,
          error: widget.error,
          prefixText: widget.prefixText,
          suffixText: widget.suffixText,
          enabled: widget.enabled,
          focused: _focus.hasFocus,
          singleLine: widget.singleLine,
          secure: widget.secure,
          isEmpty: _text.raw.isEmpty,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        TextFieldSlots(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          input: input,
        ),
        theme,
        style,
      ),
    );
    // A tap anywhere on the field (the label, a prefix) focuses the input.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: enabled ? _focus.requestFocus : null,
      excludeFromSemantics: true,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.text : MouseCursor.defer,
        onEnter: (_) => _interaction.setHovered(true),
        onExit: (_) => _interaction.setHovered(false),
        child: field,
      ),
    );
  }
}

/// A text controller kept in step with the app's raw value: edits report the raw value; when the app changes
/// the value the text follows with the cursor at the end; when the app ignores an edit, the text returns to the
/// app's value after the frame.
class _ControlledText {
  _ControlledText(this._state, this._value, this._onChanged);

  final State _state;
  final String Function() _value;
  final ValueChanged<String> _onChanged;
  final controller = TextEditingController();
  CamoTextFormatter _formatter = CamoTextFormatter();
  String raw = '';

  void init(CamoTextFormatter formatter) {
    _formatter = formatter;
    _set(_value());
  }

  void sync(CamoTextFormatter formatter) {
    _formatter = formatter;
    if (raw != _value()) _set(_value());
  }

  void changed(String shown) {
    raw = _formatter.raw(shown);
    _onChanged(raw);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_state.mounted && raw != _value()) _set(_value());
    });
  }

  void _set(String value) {
    raw = value;
    final shown = _formatter.show(value);
    controller.value = TextEditingValue(
      text: shown,
      selection: TextSelection.collapsed(offset: shown.length),
    );
  }

  void dispose() => controller.dispose();
}

/// An icon action inside a field (clear, show password, open a picker). Unlike a `CamoIconButton` it has no
/// container of its own: it takes the field's icon size and color (the ambient icon style the field's renderer
/// sets for its icons) and a small square around the icon, so a field with an action is as tall as one
/// without. It's its own focusable button, after the input, named by [semanticLabel].
class CamoFieldAction extends StatefulWidget {
  /// Creates a field action.
  const CamoFieldAction({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  /// The icon, usually an app icon widget.
  final Widget icon;

  /// Names the action ("Show password").
  final String semanticLabel;

  /// Called on a tap or Enter / Space; `null` disables it.
  final VoidCallback? onPressed;

  @override
  State<CamoFieldAction> createState() => _CamoFieldActionState();
}

class _CamoFieldActionState extends State<CamoFieldAction> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoFieldAction');
    final theme = Camouflage.themeOf(context, component: 'CamoFieldAction');
    final icon = Camouflage.iconStyleOf(context);
    final enabled = widget.onPressed != null;
    final side = icon.size + theme.spacing.s;
    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onFocusChange: (f) => _interaction.setFocused(
        f,
        byKeyboard:
            f &&
            FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional,
      ),
      onShowHoverHighlight: _interaction.setHovered,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onPressed?.call(),
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled
            ? (d) => _interaction.pressDown(d.localPosition)
            : null,
        onTapUp: enabled ? (_) => _interaction.pressEnd() : null,
        onTapCancel: enabled ? _interaction.pressEnd : null,
        onTap: widget.onPressed,
        child: Semantics(
          button: true,
          enabled: enabled,
          label: widget.semanticLabel,
          excludeSemantics: true,
          child: skin.feedback.wrap(
            controller: _interaction,
            contentColor: icon.color,
            shape: BorderRadius.circular(side / 2),
            theme: theme,
            child: SizedBox.square(
              dimension: side,
              child: Center(
                child: Opacity(opacity: enabled ? 1 : 0.38, child: widget.icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The building block (ADR-30): the text field's frame (label, border and focus, icons, supporting and error
/// text) around any [child], such as OTP boxes or a country picker with a number field, so custom inputs match
/// the brand's fields. The frame can't see inside [child], so the caller passes [focused] and [isEmpty]. The
/// child keeps its own semantics; the frame names it with [label] and marks it with [error].
class CamoFieldFrame extends StatefulWidget {
  /// Creates a field frame.
  const CamoFieldFrame({
    super.key,
    required this.focused,
    required this.isEmpty,
    required this.child,
    this.label,
    this.supportingText,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  /// The content has focus.
  final bool focused;

  /// The content has no value.
  final bool isEmpty;

  /// The custom input.
  final Widget child;

  /// The label.
  final String? label;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// A decorative icon at the start.
  final Widget? prefixIcon;

  /// An icon or a `CamoFieldAction` at the end.
  final Widget? suffixIcon;

  /// `false` shows the disabled look.
  final bool enabled;

  @override
  State<CamoFieldFrame> createState() => _CamoFieldFrameState();
}

class _CamoFieldFrameState extends State<CamoFieldFrame> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final skin = Camouflage.skinOf(context, component: 'CamoFieldFrame');
    final theme = Camouflage.themeOf(context, component: 'CamoFieldFrame');
    final style = skin.textField
        .defaults(theme)
        .merge(theme.components.textField);
    return CamoErrorSemantics(
      message: widget.error,
      child: Semantics(
        label: widget.label,
        container: true,
        child: skin.textField.render(
          context,
          TextFieldState(
            value: '',
            label: widget.label,
            placeholder: null,
            supportingText: widget.supportingText,
            error: widget.error,
            prefixText: null,
            suffixText: null,
            enabled: widget.enabled,
            focused: widget.focused,
            singleLine: true,
            secure: false,
            isEmpty: widget.isEmpty,
            interaction: InteractionState(focused: widget.focused),
            controller: _interaction,
          ),
          TextFieldSlots(
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            input: widget.child,
          ),
          theme,
          style,
        ),
      ),
    );
  }
}
