import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../textfield/camo_text_field.dart';
import '../theme/camo_theme.dart';

/// Every color a search field uses.
@immutable
class SearchFieldColors {
  /// Creates search field colors.
  const SearchFieldColors({
    required this.container,
    required this.text,
    required this.placeholder,
    required this.icon,
  });

  /// The fill.
  final Color container;

  /// The typed text.
  final Color text;

  /// The placeholder.
  final Color placeholder;

  /// The icons.
  final Color icon;

  @override
  bool operator ==(Object other) =>
      other is SearchFieldColors &&
      other.container == container &&
      other.text == text &&
      other.placeholder == placeholder &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(container, text, placeholder, icon);
}

/// Overrides for search fields; `null` keeps the skin's default.
@immutable
class CamoSearchFieldTheme {
  /// Creates search field overrides.
  const CamoSearchFieldTheme({
    this.height,
    this.shape,
    this.textStyle,
    this.placeholderStyle,
    this.iconSize,
    this.searchIcon,
    this.clearIcon,
    this.colors,
  });

  /// The field's height.
  final double? height;

  /// The corners.
  final BorderRadius? shape;

  /// The typed text.
  final TextStyle? textStyle;

  /// The placeholder.
  final TextStyle? placeholderStyle;

  /// The icons' size.
  final double? iconSize;

  /// The leading search icon.
  final IconSource? searchIcon;

  /// The clear action's icon.
  final IconSource? clearIcon;

  /// Every color it uses.
  final SearchFieldColors? colors;

  /// A copy with the given fields replaced.
  CamoSearchFieldTheme copyWith({
    double? height,
    BorderRadius? shape,
    TextStyle? textStyle,
    TextStyle? placeholderStyle,
    double? iconSize,
    IconSource? searchIcon,
    IconSource? clearIcon,
    SearchFieldColors? colors,
  }) => CamoSearchFieldTheme(
    height: height ?? this.height,
    shape: shape ?? this.shape,
    textStyle: textStyle ?? this.textStyle,
    placeholderStyle: placeholderStyle ?? this.placeholderStyle,
    iconSize: iconSize ?? this.iconSize,
    searchIcon: searchIcon ?? this.searchIcon,
    clearIcon: clearIcon ?? this.clearIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSearchFieldTheme &&
      other.height == height &&
      other.shape == shape &&
      other.textStyle == textStyle &&
      other.placeholderStyle == placeholderStyle &&
      other.iconSize == iconSize &&
      other.searchIcon == searchIcon &&
      other.clearIcon == clearIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    height,
    shape,
    textStyle,
    placeholderStyle,
    iconSize,
    searchIcon,
    clearIcon,
    colors,
  );
}

/// The resolved search field style: every field set.
@immutable
class CamoSearchFieldStyle {
  /// Creates a search field style.
  const CamoSearchFieldStyle({
    required this.height,
    required this.shape,
    required this.textStyle,
    required this.placeholderStyle,
    required this.iconSize,
    required this.searchIcon,
    required this.clearIcon,
    required this.colors,
  });

  /// The field's height.
  final double height;

  /// The corners.
  final BorderRadius shape;

  /// The typed text.
  final TextStyle textStyle;

  /// The placeholder.
  final TextStyle placeholderStyle;

  /// The icons' size.
  final double iconSize;

  /// The leading search icon.
  final IconSource searchIcon;

  /// The clear action's icon.
  final IconSource clearIcon;

  /// Every color it uses.
  final SearchFieldColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoSearchFieldStyle merge(CamoSearchFieldTheme? o) => o == null
      ? this
      : CamoSearchFieldStyle(
          height: o.height ?? height,
          shape: o.shape ?? shape,
          textStyle: o.textStyle ?? textStyle,
          placeholderStyle: o.placeholderStyle ?? placeholderStyle,
          iconSize: o.iconSize ?? iconSize,
          searchIcon: o.searchIcon ?? searchIcon,
          clearIcon: o.clearIcon ?? clearIcon,
          colors: o.colors ?? colors,
        );
}

/// What a search field renderer draws: the container, the placeholder while [isEmpty], and the slots.
@immutable
class SearchFieldState {
  /// Creates a search field state.
  const SearchFieldState({
    required this.query,
    required this.placeholder,
    required this.enabled,
    required this.focused,
    required this.isEmpty,
    required this.interaction,
    required this.controller,
  });

  /// The current query.
  final String query;

  /// Shown while empty; it also names the field.
  final String placeholder;

  /// `false` shows the disabled look.
  final bool enabled;

  /// The input has focus.
  final bool focused;

  /// No text yet.
  final bool isEmpty;

  /// Focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction].
  final CamoInteractionController controller;
}

/// The search field's parts in order: [leading] (the caller's, or core's search icon), core's [input], the
/// [clear] action (present only while there's text) and the caller's [trailing].
@immutable
class SearchFieldSlots {
  /// Creates the slots.
  const SearchFieldSlots({
    required this.leading,
    required this.input,
    this.clear,
    this.trailing,
  });

  /// The search icon or the caller's widget.
  final Widget leading;

  /// The editable widget.
  final Widget input;

  /// The clear action.
  final Widget? clear;

  /// The caller's trailing widget.
  final Widget? trailing;
}

/// Draws search fields.
abstract interface class CamoSearchFieldRenderer {
  /// The complete search field style for [theme].
  CamoSearchFieldStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    SearchFieldState state,
    SearchFieldSlots slots,
    CamoTheme theme,
    CamoSearchFieldStyle style,
  );
}

/// A search field: the search icon, the keyboard's Search action (Enter on desktop and web) calling
/// [onSubmitted], and a "Clear search" action while there's text, which clears and keeps focus. Esc clears too.
/// [leading] replaces the search icon (a back button when a search is open); [trailing] adds e.g. a mic.
/// Debouncing is the app's: the field reports every change.
class CamoSearchField extends StatefulWidget {
  /// Creates a search field.
  const CamoSearchField({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    this.placeholder = 'Search',
    this.leading,
    this.trailing,
    this.enabled = true,
    this.onFocusChanged,
    this.focusNode,
  });

  /// The current query.
  final String query;

  /// Called with each change.
  final ValueChanged<String> onChanged;

  /// Called by the keyboard's Search action and Enter.
  final ValueChanged<String> onSubmitted;

  /// Shown while empty; it also names the field.
  final String placeholder;

  /// Replaces the search icon.
  final Widget? leading;

  /// After the clear action, e.g. a mic.
  final Widget? trailing;

  /// `false` disables it.
  final bool enabled;

  /// Reports focus changes.
  final ValueChanged<bool>? onFocusChanged;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoSearchField> createState() => _CamoSearchFieldState();
}

class _CamoSearchFieldState extends State<CamoSearchField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  final _interaction = CamoInteractionController();
  final _controller = TextEditingController();
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _set(widget.query);
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(CamoSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.query) _set(widget.query);
  }

  void _set(String text) => _controller.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  void _focusChanged() {
    _interaction.setFocused(_focus.hasFocus);
    widget.onFocusChanged?.call(_focus.hasFocus);
    setState(() {});
  }

  void _clear() {
    _set('');
    widget.onChanged('');
    _focus.requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _ownFocus?.dispose();
    _controller.dispose();
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSearchField');
    final theme = Camouflage.themeOf(context, component: 'CamoSearchField');
    final style = skin.searchField
        .defaults(theme)
        .merge(theme.components.searchField);
    final empty = _controller.text.isEmpty;
    final Widget input = Semantics(
      label: widget.placeholder,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (_controller.text.isNotEmpty) _clear();
          },
        },
        child: _gestures.buildGestureDetector(
          behavior: HitTestBehavior.translucent,
          child: ExcludeFocus(
            excluding: !widget.enabled,
            child: EditableText(
              key: editableTextKey,
              rendererIgnoresPointer: true,
              controller: _controller,
              focusNode: _focus,
              readOnly: !widget.enabled,
              autocorrect: false,
              style: style.textStyle.copyWith(color: style.colors.text),
              cursorColor: style.colors.text,
              backgroundCursorColor: style.colors.placeholder,
              selectionControls: skin.textField.selectionControls(context),
              contextMenuBuilder: skin.textField.contextMenuBuilder,
              maxLines: 1,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              onChanged: (text) {
                widget.onChanged(text);
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
    return ListenableBuilder(
      listenable: _interaction,
      builder: (context, _) => skin.searchField.render(
        context,
        SearchFieldState(
          query: _controller.text,
          placeholder: widget.placeholder,
          enabled: widget.enabled,
          focused: _focus.hasFocus,
          isEmpty: empty,
          interaction: _interaction.value,
          controller: _interaction,
        ),
        SearchFieldSlots(
          leading: widget.leading ?? CamoIcon(style.searchIcon),
          input: input,
          clear: empty
              ? null
              : CamoFieldAction(
                  icon: CamoIcon(style.clearIcon),
                  semanticLabel: 'Clear search',
                  onPressed: widget.enabled ? _clear : null,
                ),
          trailing: widget.trailing,
        ),
        theme,
        style,
      ),
    );
  }
}
