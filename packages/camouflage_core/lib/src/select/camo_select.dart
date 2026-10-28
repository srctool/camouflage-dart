import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../bottom_sheet/camo_bottom_sheet.dart';
import '../datepicker/camo_date_field.dart';
import '../form/camo_form.dart';
import '../form/camo_rule.dart';
import '../icon/camo_icon.dart';
import '../list/camo_list_item.dart';
import '../menu/camo_menu_anchor.dart';
import '../overlay/camo_overlay_routes.dart';
import '../paged_list/camo_paged_list.dart';
import '../provider/camouflage.dart';
import '../search/camo_search_field.dart';
import '../text/camo_text.dart';

/// How a select shows its options: a menu under the field, a bottom sheet, or `auto` (see [CamoSelectTheme]).
enum SelectPresentation {
  /// The menu on wide windows with few options, the sheet otherwise.
  auto,

  /// Always a menu.
  menu,

  /// Always a sheet.
  sheet,
}

/// One choice in a select. [supporting] shows under the label in the sheet.
@immutable
class SelectOption<T> {
  /// Creates an option.
  const SelectOption(
    this.value,
    this.label, {
    this.supporting,
    this.leading,
    this.enabled = true,
  });

  /// What picking it sets.
  final T value;

  /// What it shows.
  final String label;

  /// A second line in the sheet.
  final String? supporting;

  /// An icon or avatar before the label.
  final Widget? leading;

  /// `false` disables it.
  final bool enabled;
}

/// The words a select shows.
@immutable
class SelectStrings {
  /// Creates the strings.
  const SelectStrings({this.search = 'Search', this.noResults = 'No results'});

  /// The sheet's search placeholder.
  final String search;

  /// Shown when the search matches nothing.
  final String noResults;

  @override
  bool operator ==(Object other) =>
      other is SelectStrings &&
      other.search == search &&
      other.noResults == noResults;

  @override
  int get hashCode => Object.hash(search, noResults);
}

/// Overrides for selects. A select has no renderer of its own (the field, menu, sheet and rows are the text
/// field's, menu's, bottom sheet's and list item's), so these are presentation rules with core defaults.
@immutable
class CamoSelectTheme {
  /// Creates select overrides.
  const CamoSelectTheme({
    this.autoMenuMaxOptions,
    this.autoMenuMinWidth,
    this.showCheckOnSelected,
    this.searchDebounce,
    this.strings,
  });

  /// The most options `auto` shows as a menu.
  final int? autoMenuMaxOptions;

  /// The window width from which `auto` may use a menu.
  final double? autoMenuMinWidth;

  /// A checkmark on the current option in the sheet.
  final bool? showCheckOnSelected;

  /// How long the async select waits after typing before `onQueryChanged`.
  final Duration? searchDebounce;

  /// The words it shows.
  final SelectStrings? strings;

  /// A copy with the given fields replaced.
  CamoSelectTheme copyWith({
    int? autoMenuMaxOptions,
    double? autoMenuMinWidth,
    bool? showCheckOnSelected,
    Duration? searchDebounce,
    SelectStrings? strings,
  }) => CamoSelectTheme(
    autoMenuMaxOptions: autoMenuMaxOptions ?? this.autoMenuMaxOptions,
    autoMenuMinWidth: autoMenuMinWidth ?? this.autoMenuMinWidth,
    showCheckOnSelected: showCheckOnSelected ?? this.showCheckOnSelected,
    searchDebounce: searchDebounce ?? this.searchDebounce,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSelectTheme &&
      other.autoMenuMaxOptions == autoMenuMaxOptions &&
      other.autoMenuMinWidth == autoMenuMinWidth &&
      other.showCheckOnSelected == showCheckOnSelected &&
      other.searchDebounce == searchDebounce &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    autoMenuMaxOptions,
    autoMenuMinWidth,
    showCheckOnSelected,
    searchDebounce,
    strings,
  );
}

/// The resolved select style: every field set.
@immutable
class CamoSelectStyle {
  /// Creates a select style; the defaults are core's.
  const CamoSelectStyle({
    this.autoMenuMaxOptions = 7,
    this.autoMenuMinWidth = 600,
    this.showCheckOnSelected = true,
    this.searchDebounce = const Duration(milliseconds: 500),
    this.strings = const SelectStrings(),
  });

  /// The most options `auto` shows as a menu.
  final int autoMenuMaxOptions;

  /// The window width from which `auto` may use a menu.
  final double autoMenuMinWidth;

  /// A checkmark on the current option in the sheet.
  final bool showCheckOnSelected;

  /// How long the async select waits after typing.
  final Duration searchDebounce;

  /// The words it shows.
  final SelectStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoSelectStyle merge(CamoSelectTheme? o) => o == null
      ? this
      : CamoSelectStyle(
          autoMenuMaxOptions: o.autoMenuMaxOptions ?? autoMenuMaxOptions,
          autoMenuMinWidth: o.autoMenuMinWidth ?? autoMenuMinWidth,
          showCheckOnSelected: o.showCheckOnSelected ?? showCheckOnSelected,
          searchDebounce: o.searchDebounce ?? searchDebounce,
          strings: o.strings ?? strings,
        );
}

CamoSelectStyle _styleOf(BuildContext context) => const CamoSelectStyle().merge(
  Camouflage.themeOf(context, component: 'CamoSelect').components.select,
);

IconSource _dropdownIcon(BuildContext context) {
  final skin = Camouflage.skinOf(context, component: 'CamoSelect');
  final theme = Camouflage.themeOf(context, component: 'CamoSelect');
  return skin.textField
      .defaults(theme)
      .merge(theme.components.textField)
      .dropdownIcon;
}

/// Picks one of [options]: a read-only field (the text field's frame with the skin's dropdown chevron) that
/// opens the options in a menu under it or in a bottom sheet ([presentation]). `auto` uses the menu for up to
/// `CamoSelectTheme.autoMenuMaxOptions` options on a window at least `autoMenuMinWidth` wide, and the sheet
/// otherwise, and always when [searchable] (the sheet then has a search field filtering by label, ignoring
/// case and accents). Picking an option calls [onChanged] and closes; Esc, back or an outside tap closes
/// without a change. A [value] that isn't among the options shows as `value.toString()`.
class CamoSelect<T> extends StatefulWidget {
  /// Creates a select.
  const CamoSelect({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.presentation = SelectPresentation.auto,
    this.searchable = false,
    this.prefixIcon,
    this.enabled = true,
    this.focusNode,
  });

  /// The current value, or `null`.
  final T? value;

  /// Called with the picked value.
  final ValueChanged<T> onChanged;

  /// The choices.
  final List<SelectOption<T>> options;

  /// The label (the sheet's title too).
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// Menu, sheet or auto.
  final SelectPresentation presentation;

  /// A search field in the sheet.
  final bool searchable;

  /// An icon at the start of the field.
  final Widget? prefixIcon;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoSelect<T>> createState() => _CamoSelectState<T>();
}

class _CamoSelectState<T> extends State<CamoSelect<T>> {
  bool _open = false;

  Future<void> _show(BuildContext anchor) async {
    final w = widget;
    final style = _styleOf(context);
    final menu = switch (w.presentation) {
      SelectPresentation.menu => true,
      SelectPresentation.sheet => false,
      SelectPresentation.auto =>
        !w.searchable &&
            w.options.length <= style.autoMenuMaxOptions &&
            MediaQuery.sizeOf(context).width >= style.autoMenuMinWidth,
    };
    setState(() => _open = true);
    final T? picked;
    if (menu) {
      final keyboard = openedByKeyboard(anchor);
      final width = (anchor.findRenderObject()! as RenderBox).size.width;
      final items = [
        for (final option in w.options)
          CamoMenuItem(
            text: option.label,
            onPressed: () {},
            leadingIcon: option.leading,
            enabled: option.enabled,
            checked: option.value == w.value,
          ),
      ];
      final item = await showCamoAnchoredPopup<CamoMenuItem>(
        anchor,
        builder: (popup) => Semantics(
          role: SemanticsRole.menu,
          explicitChildNodes: true,
          child: MenuEntries(
            entries: [CamoMenuGroup(exclusive: true, items: items)],
            minWidth: width,
            focusFirst: keyboard,
            onSelected: (item) => Navigator.of(popup).pop(item),
          ),
        ),
      );
      picked = item == null ? null : w.options[items.indexOf(item)].value;
    } else {
      picked = await showCamoBottomSheet<T>(
        context: context,
        builder: (sheet) => CamoBottomSheet(
          title: w.label,
          child: _OptionList<T>(
            options: w.options,
            value: w.value,
            searchable: w.searchable,
            style: style,
            onPicked: (value) => Navigator.of(sheet).pop(value),
          ),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _open = false);
    if (picked != null) widget.onChanged(picked as T);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final text =
        w.options.where((o) => o.value == w.value).firstOrNull?.label ??
        w.value?.toString();
    return _SelectField(
      text: text,
      icon: _dropdownIcon(context),
      open: _open,
      label: w.label,
      placeholder: w.placeholder,
      supportingText: w.supportingText,
      error: w.error,
      prefixIcon: w.prefixIcon,
      enabled: w.enabled,
      focusNode: w.focusNode,
      onOpen: _show,
    );
  }
}

// The picker field, opening on Down too.
class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.text,
    required this.icon,
    required this.open,
    required this.label,
    required this.placeholder,
    required this.supportingText,
    required this.error,
    required this.prefixIcon,
    required this.enabled,
    required this.focusNode,
    required this.onOpen,
  });

  final String? text;
  final IconSource icon;
  final bool open;
  final String? label;
  final String? placeholder;
  final String? supportingText;
  final String? error;
  final Widget? prefixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(BuildContext anchor) onOpen;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (anchor) => CallbackShortcuts(
      bindings: {
        if (enabled)
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              onOpen(anchor),
      },
      child: CamoPickerField(
        text: text,
        icon: icon,
        open: open,
        label: label,
        placeholder: placeholder,
        supportingText: supportingText,
        error: error,
        prefixIcon: prefixIcon,
        enabled: enabled,
        focusNode: focusNode,
        onOpen: onOpen,
      ),
    ),
  );
}

class _OptionList<T> extends StatefulWidget {
  const _OptionList({
    required this.options,
    required this.value,
    required this.searchable,
    required this.style,
    required this.onPicked,
  });

  final List<SelectOption<T>> options;
  final T? value;
  final bool searchable;
  final CamoSelectStyle style;
  final ValueChanged<T> onPicked;

  @override
  State<_OptionList<T>> createState() => _OptionListState<T>();
}

class _OptionListState<T> extends State<_OptionList<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final folded = fold(_query.trim());
    final shown = [
      for (final option in w.options)
        if (fold(option.label).contains(folded)) option,
    ];
    final spacing = Camouflage.themeOf(
      context,
      component: 'CamoSelect',
    ).spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (w.searchable)
          _SearchRow(
            query: _query,
            placeholder: w.style.strings.search,
            onChanged: (q) => setState(() => _query = q),
          ),
        if (shown.isEmpty)
          Padding(
            padding: EdgeInsets.all(spacing.l),
            child: CamoText(w.style.strings.noResults),
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in shown)
                  _OptionRow<T>(
                    option: option,
                    selected: option.value == w.value,
                    style: w.style,
                    onPressed: () => w.onPicked(option.value),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.query,
    required this.placeholder,
    required this.onChanged,
  });

  final String query;
  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.themeOf(
      context,
      component: 'CamoSelect',
    ).spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.l, vertical: spacing.s),
      child: CamoSearchField(
        query: query,
        onChanged: onChanged,
        onSubmitted: (_) {},
        placeholder: placeholder,
      ),
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.style,
    required this.onPressed,
  });

  final SelectOption<T> option;
  final bool selected;
  final CamoSelectStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSelect');
    final theme = Camouflage.themeOf(context, component: 'CamoSelect');
    final check = skin.menu
        .defaults(theme)
        .merge(theme.components.menu)
        .checkIcon;
    return CamoListItem(
      headline: option.label,
      supporting: option.supporting,
      leading: option.leading,
      trailing: selected && style.showCheckOnSelected ? CamoIcon(check) : null,
      onPressed: onPressed,
      selected: selected,
      enabled: option.enabled,
    );
  }
}

/// A select whose options come from an API, controlled like `CamoPagedList` (ADR-29): it always opens a sheet
/// with a search field and a paged list over [options]. It calls [onOpen] once each time the sheet opens (load
/// the first page), and [onQueryChanged] `CamoSelectTheme.searchDebounce` after the user stops typing; it never
/// fetches. [selectedLabel] is the current value's label, since its option may not be loaded.
class CamoAsyncSelect<T> extends StatefulWidget {
  /// Creates an async select.
  const CamoAsyncSelect({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    required this.onOpen,
    required this.onQueryChanged,
    required this.onLoadMore,
    required this.onRetry,
    required this.selectedLabel,
    this.onRefresh,
    this.label,
    this.placeholder,
    this.supportingText,
    this.error,
    this.prefixIcon,
    this.enabled = true,
    this.focusNode,
  });

  /// The current value, or `null`.
  final T? value;

  /// Called with the picked value.
  final ValueChanged<T> onChanged;

  /// The loaded options, as the app's paging state.
  final CamoPagedListState<SelectOption<T>> options;

  /// The sheet opened: load the first page.
  final VoidCallback onOpen;

  /// The search changed (debounced).
  final ValueChanged<String> onQueryChanged;

  /// Load the next page.
  final VoidCallback onLoadMore;

  /// Retry the failed load.
  final VoidCallback onRetry;

  /// The current value's label.
  final String? selectedLabel;

  /// Pull to refresh, if any.
  final Future<void> Function()? onRefresh;

  /// The label (the sheet's title too).
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// The error.
  final String? error;

  /// An icon at the start of the field.
  final Widget? prefixIcon;

  /// `false` disables it.
  final bool enabled;

  /// An optional focus node the app controls.
  final FocusNode? focusNode;

  @override
  State<CamoAsyncSelect<T>> createState() => _CamoAsyncSelectState<T>();
}

class _CamoAsyncSelectState<T> extends State<CamoAsyncSelect<T>> {
  bool _open = false;
  // The sheet is a route: it hears new options through this, not through rebuilds.
  late final _options = ValueNotifier(widget.options);

  @override
  void didUpdateWidget(CamoAsyncSelect<T> old) {
    super.didUpdateWidget(old);
    // This runs while the page builds, and the sheet's route isn't below it: it hears after the frame.
    final options = widget.options;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _options.value = options;
    });
  }

  @override
  void dispose() {
    _options.dispose();
    super.dispose();
  }

  Future<void> _show(BuildContext anchor) async {
    final style = _styleOf(context);
    setState(() => _open = true);
    final picked = await showCamoBottomSheet<T>(
      context: context,
      builder: (sheet) => CamoBottomSheet(
        title: widget.label,
        child: _AsyncOptions<T>(
          options: _options,
          value: widget.value,
          style: style,
          select: widget,
          onPicked: (value) => Navigator.of(sheet).pop(value),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (picked != null) widget.onChanged(picked as T);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return _SelectField(
      text: w.selectedLabel ?? w.value?.toString(),
      icon: _dropdownIcon(context),
      open: _open,
      label: w.label,
      placeholder: w.placeholder,
      supportingText: w.supportingText,
      error: w.error,
      prefixIcon: w.prefixIcon,
      enabled: w.enabled,
      focusNode: w.focusNode,
      onOpen: _show,
    );
  }
}

class _AsyncOptions<T> extends StatefulWidget {
  const _AsyncOptions({
    required this.options,
    required this.value,
    required this.style,
    required this.select,
    required this.onPicked,
  });

  final ValueListenable<CamoPagedListState<SelectOption<T>>> options;
  final T? value;
  final CamoSelectStyle style;
  final CamoAsyncSelect<T> select;
  final ValueChanged<T> onPicked;

  @override
  State<_AsyncOptions<T>> createState() => _AsyncOptionsState<T>();
}

class _AsyncOptionsState<T> extends State<_AsyncOptions<T>> {
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Once per opening, after the frame that built the sheet.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.select.onOpen());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String query) {
    setState(() => _query = query);
    _debounce?.cancel();
    _debounce = Timer(
      widget.style.searchDebounce,
      () => widget.select.onQueryChanged(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchRow(
          query: _query,
          placeholder: w.style.strings.search,
          onChanged: _changed,
        ),
        Flexible(
          child: ValueListenableBuilder(
            valueListenable: w.options,
            builder: (context, options, _) => CamoPagedList<SelectOption<T>>(
              state: options,
              itemKey: (o) => o.value.toString(),
              onLoadMore: w.select.onLoadMore,
              onRetry: w.select.onRetry,
              onRefresh: w.select.onRefresh,
              itemBuilder: (context, option, _) => _OptionRow<T>(
                option: option,
                selected: option.value == w.value,
                style: w.style,
                onPressed: () => w.onPicked(option.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A [CamoSelect] in a `CamoForm`, e.g. with `CamoRules.required` for "pick one".
class CamoSelectFormField<T> extends StatelessWidget {
  /// Creates a select form field.
  const CamoSelectFormField({
    super.key,
    this.fieldKey,
    required this.options,
    this.initialValue,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.forceError,
    this.visible = true,
    this.label,
    this.placeholder,
    this.supportingText,
    this.presentation = SelectPresentation.auto,
    this.searchable = false,
    this.prefixIcon,
    this.enabled = true,
  });

  /// The entry's key in the form.
  final String? fieldKey;

  /// The choices.
  final List<SelectOption<T>> options;

  /// The first value.
  final T? initialValue;

  /// The checks, in order.
  final List<CamoRule<T>> rules;

  /// Called by `save()`.
  final void Function(T? value)? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// `false` keeps the value but hides the field and skips it.
  final bool visible;

  /// The label.
  final String? label;

  /// Shown while empty.
  final String? placeholder;

  /// Helper text below.
  final String? supportingText;

  /// Menu, sheet or auto.
  final SelectPresentation presentation;

  /// A search field in the sheet.
  final bool searchable;

  /// An icon at the start of the field.
  final Widget? prefixIcon;

  /// `false` disables it.
  final bool enabled;

  @override
  Widget build(BuildContext context) => CamoFormField<T>(
    fieldKey: fieldKey,
    initialValue: initialValue,
    rules: rules,
    onSaved: onSaved,
    validateMode: validateMode,
    enabled: enabled,
    visible: visible,
    forceError: forceError,
    builder: (context, field) => !visible
        ? const SizedBox.shrink()
        : Focus(
            skipTraversal: true,
            onFocusChange: field.onFocusChanged,
            child: CamoSelect<T>(
              value: field.value,
              onChanged: field.didChange,
              options: options,
              label: label,
              placeholder: placeholder,
              supportingText: supportingText,
              error: field.error,
              presentation: presentation,
              searchable: searchable,
              prefixIcon: prefixIcon,
              enabled: enabled,
            ),
          ),
  );
}

const _accents = {
  'aàáâãäåā': 'a',
  'cçćč': 'c',
  'eèéêëēė': 'e',
  'iìíîïī': 'i',
  'nñń': 'n',
  'oòóôõöøō': 'o',
  'sśš': 's',
  'uùúûüū': 'u',
  'yýÿ': 'y',
  'zźżž': 'z',
};

final _fold = {
  for (final MapEntry(key: chars, value: base) in _accents.entries)
    for (final char in chars.split('')) char: base,
};

/// Lowercase, with the common Latin accents removed ("Zürich" matches "zur").
@visibleForTesting
String fold(String text) =>
    text.toLowerCase().split('').map((c) => _fold[c] ?? c).join();
