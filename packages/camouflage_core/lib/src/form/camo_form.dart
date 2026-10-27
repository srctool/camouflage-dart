import 'package:flutter/widgets.dart';

import 'camo_rule.dart';

/// When a form field validates (Flutter's `AutovalidateMode`).
enum ValidateMode {
  /// Only when the controller's `validate()` is called, usually on submit.
  disabled,

  /// On every change and from the start, before any edit.
  always,

  /// On every change, after the user's first edit of that field.
  onUserInteraction,

  /// When the field loses focus.
  onUnfocus,
}

// One field's state, kept by the controller under its key whether or not the field is on screen.
class _Entry extends ChangeNotifier {
  _Entry(this.key, this.initialValue, this.order) : _value = initialValue;

  final String key;
  final Object? initialValue;
  final int order;
  Object? _value;
  String? _error;
  String? _serverError;
  bool hasInteracted = false;
  List<CamoRule<Object?>> rules = const [];
  ValidateMode? mode;
  bool enabled = true;
  bool visible = true;
  void Function(Object?)? onSaved;
  FocusNode? focusNode;
  BuildContext? context;

  Object? get value => _value;
  set value(Object? v) {
    _value = v;
    notifyListeners();
  }

  String? get error => _serverError ?? _error;

  void setError(String? rules, {String? server, bool clearServer = false}) {
    _error = rules;
    if (clearServer) _serverError = null;
    if (server != null) _serverError = server;
    notifyListeners();
  }
}

/// The handle an app keeps for a [CamoForm], like Flutter's `FormState` from a key. It's app state: create it in
/// a `State` (and dispose it) or hold it in the page's notifier. The controller owns every field's value by key,
/// so a field scrolled out of a lazy list keeps its value and is still validated and saved.
class CamoFormController extends ChangeNotifier {
  final Map<String, _Entry> _entries = {};
  var _nextOrder = 0;
  Map<String, Object?> _restored = {};
  ValidateMode _mode = ValidateMode.disabled;
  VoidCallback? _onChanged;
  Future<void> Function(String key)? _reveal;
  String? _pendingFocus;
  bool _isValid = true;

  /// `true` after the last `validate()` found no error.
  bool get isValid => _isValid;

  /// Any field's value differs from its initial value.
  bool get isDirty => _entries.values.any((e) => e.value != e.initialValue);

  /// Field [key]'s value differs from its initial value.
  bool isFieldDirty(String key) {
    final e = _entries[key];
    return e != null && e.value != e.initialValue;
  }

  /// Field [key]'s current value, or `null` when there's no such field.
  T? value<T>(String key) => _entries[key]?.value as T?;

  /// Creates field [key]'s entry before its field is ever shown, so a lazy form validates rows the user hasn't
  /// scrolled to. A field attaching later takes this entry.
  void declare<T>(
    String key, {
    T? initialValue,
    List<CamoRule<T>> rules = const [],
  }) => _entry(key, initialValue).rules = rules;

  /// Drops field [key]'s entry for good (a removed row).
  void remove(String key) => _entries.remove(key)?.dispose();

  /// Validates every visible, enabled field, on screen or not, in the order they first appeared. The first
  /// invalid one is scrolled into view and focused (revealed first through `revealField` when it's off screen).
  bool validate() {
    _Entry? first;
    for (final e in _ordered()) {
      if (!e.visible || !e.enabled) continue;
      if (!_check(e) && first == null) first = e;
    }
    _isValid = first == null;
    if (first != null) _focus(first);
    notifyListeners();
    return _isValid;
  }

  /// Calls every visible, enabled field's `onSaved` with its current value.
  void save() {
    for (final e in _ordered()) {
      if (e.visible && e.enabled) e.onSaved?.call(e.value);
    }
  }

  /// Every field back to its initial value, with errors and interaction cleared.
  void reset() {
    for (final e in _entries.values) {
      e
        ..hasInteracted = false
        ..value = e.initialValue
        ..setError(null, clearServer: true);
    }
    _isValid = true;
    notifyListeners();
  }

  /// Shows [errors] (from a server) on the fields by key, until each field's next change.
  void setErrors(Map<String, String> errors) {
    for (final MapEntry(:key, value: message) in errors.entries) {
      final e = _entries[key];
      e?.setError(e._error, server: message);
    }
    if (errors.isEmpty) return;
    _isValid = false;
    final first = _ordered()
        .where((e) => errors.containsKey(e.key))
        .firstOrNull;
    if (first != null) _focus(first);
    notifyListeners();
  }

  /// Every field's value, error and interaction, for `RestorationMixin` or a saved draft. Values should be
  /// primitives (text, numbers, booleans).
  Map<String, Object?> toMap() => {
    for (final e in _entries.values)
      e.key: {'value': e.value, 'error': e.error, 'touched': e.hasInteracted},
  };

  /// Restores what [toMap] saved; fields take it when they attach.
  void restore(Map<String, Object?> data) {
    _restored = Map.of(data);
    for (final e in _entries.values) {
      _apply(e);
    }
  }

  _Entry _entry(String key, Object? initialValue) => _entries.putIfAbsent(
    key,
    () => _apply(_Entry(key, initialValue, _nextOrder++)),
  );

  _Entry _apply(_Entry e) {
    final saved = _restored.remove(e.key);
    if (saved is Map) {
      e
        ..value = saved['value']
        ..hasInteracted = saved['touched'] == true
        ..setError(saved['error'] as String?);
    }
    return e;
  }

  // Runs [e]'s rules and stores the result; true when valid.
  bool _check(_Entry e) {
    if (!e.enabled) {
      e.setError(null);
      return true;
    }
    String? message;
    for (final rule in e.rules) {
      message = rule is MatchesRule
          ? rule.check(e.value, _entries[rule.fieldKey]?.value)
          : rule.validate(e.value);
      if (message != null) break;
    }
    e.setError(message);
    return e.error == null;
  }

  List<_Entry> _ordered() =>
      _entries.values.toList()..sort((a, b) => a.order.compareTo(b.order));

  void _focus(_Entry e) {
    final context = e.context;
    if (context != null && context.mounted) {
      Scrollable.ensureVisible(context, alignment: 0.5);
      e.focusNode?.requestFocus();
      return;
    }
    _pendingFocus = e.key;
    final reveal = _reveal;
    if (reveal == null) return;
    reveal(e.key).then((_) {
      // The row may have attached mid-scroll; once it has, focus it here too.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final c = e.context;
        if (_pendingFocus == e.key && c != null && c.mounted) {
          _pendingFocus = null;
          Scrollable.ensureVisible(c, alignment: 0.5);
          e.focusNode?.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final e in _entries.values) {
      e.dispose();
    }
    super.dispose();
  }
}

class _FormScope extends InheritedWidget {
  const _FormScope(this.controller, {required super.child});

  final CamoFormController controller;

  @override
  bool updateShouldNotify(_FormScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Flutter's `Form`, keyed by field name: the scope [CamoFormField]s attach to. [validateMode] is the default for
/// fields that don't set their own; [onChanged] fires when any field changes. In a lazy list, [revealField]
/// scrolls the row for a key into the tree so `validate()` can focus an off-screen field. The fields are one
/// `AutofillGroup`, so password managers see them together.
class CamoForm extends StatelessWidget {
  /// Creates a form.
  const CamoForm({
    super.key,
    required this.controller,
    this.validateMode = ValidateMode.disabled,
    this.onChanged,
    this.revealField,
    required this.child,
  });

  /// A form in a list of rows [itemExtent] tall: `validate()` scrolls [scrollController] to the row
  /// [indexOfKey] gives.
  factory CamoForm.list({
    Key? key,
    required CamoFormController controller,
    required ScrollController scrollController,
    required int Function(String key) indexOfKey,
    required double itemExtent,
    ValidateMode validateMode = ValidateMode.disabled,
    VoidCallback? onChanged,
    required Widget child,
  }) => CamoForm(
    key: key,
    controller: controller,
    validateMode: validateMode,
    onChanged: onChanged,
    revealField: (k) async {
      final i = indexOfKey(k);
      if (i < 0 || !scrollController.hasClients) return;
      await scrollController.animateTo(
        (i * itemExtent).clamp(0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    },
    child: child,
  );

  /// The handle the app calls.
  final CamoFormController controller;

  /// The default for fields that don't set their own.
  final ValidateMode validateMode;

  /// Called when any field changes.
  final VoidCallback? onChanged;

  /// Scrolls the row for a key into the tree.
  final Future<void> Function(String key)? revealField;

  /// The fields, anywhere below.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    controller
      .._mode = validateMode
      .._onChanged = onChanged
      .._reveal = revealField;
    return _FormScope(controller, child: AutofillGroup(child: child));
  }
}

/// A form field's view of its entry: what its builder reads and calls.
class CamoFormFieldState<T> {
  CamoFormFieldState._(this._entry, this._form, this._mode, this._forced);

  final _Entry _entry;
  final CamoFormController? _form;
  final ValidateMode Function() _mode;
  final String? Function() _forced;

  /// The current value.
  T? get value => _entry.value as T?;

  /// The error to show: the forced error, a server error, or the rules' result.
  String? get error => _forced() ?? _entry.error;

  /// The user has changed this field.
  bool get hasInteracted => _entry.hasInteracted;

  /// The value differs from the initial value.
  bool get isDirty => _entry.value != _entry.initialValue;

  /// Give it to the input, so `validate()` can focus it.
  FocusNode get focusNode => _entry.focusNode!;

  /// Wire to the input's change callback.
  void didChange(T? value) {
    _entry
      ..hasInteracted = true
      ..value = value
      ..setError(_entry._error, clearServer: true);
    final mode = _mode();
    if (mode == ValidateMode.onUserInteraction || mode == ValidateMode.always) {
      validate();
    }
    _form?._onChanged?.call();
  }

  /// Wire to the input's focus callback (for `onUnfocus`).
  void onFocusChanged(bool focused) {
    if (!focused && _mode() == ValidateMode.onUnfocus && _entry.hasInteracted) {
      validate();
    }
  }

  /// Runs the rules now; true when valid.
  bool validate() => (_form ?? CamoFormController())._check(_entry);
}

/// Flutter's `FormField`: puts any input into a [CamoForm]. Inside a form [fieldKey] is required: it names the
/// entry that holds the value (so it survives scrolling in a lazy list), and it's the key for `setErrors`,
/// `matches` and `value(key)`. Outside a form the field validates on its own. `visible: false` keeps the value but
/// skips validation and saving; a disabled field isn't validated. [forceError] shows instead of the rules'
/// result. Give the builder's `field.focusNode` to the input.
class CamoFormField<T> extends StatefulWidget {
  /// Creates a form field.
  const CamoFormField({
    super.key,
    this.fieldKey,
    this.initialValue,
    this.rules = const [],
    this.onSaved,
    this.validateMode,
    this.enabled = true,
    this.visible = true,
    this.forceError,
    required this.builder,
  });

  /// The entry's key in the form (`key` is taken by `Widget`).
  final String? fieldKey;

  /// The first value.
  final T? initialValue;

  /// The checks, in order.
  final List<CamoRule<T>> rules;

  /// Called by `save()` with the current value.
  final void Function(T? value)? onSaved;

  /// Overrides the form's mode.
  final ValidateMode? validateMode;

  /// A disabled field isn't validated.
  final bool enabled;

  /// `false` keeps the value but skips validation and saving.
  final bool visible;

  /// Shown instead of the rules' result.
  final String? forceError;

  /// Builds the input from the field.
  final Widget Function(BuildContext context, CamoFormFieldState<T> field)
  builder;

  @override
  State<CamoFormField<T>> createState() => _CamoFormFieldState<T>();
}

class _CamoFormFieldState<T> extends State<CamoFormField<T>> {
  final _focus = FocusNode();
  CamoFormController? _form;
  _Entry? _entry;
  CamoFormFieldState<T>? _view;
  bool _checked = false;
  Object? _checkedValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = context
        .dependOnInheritedWidgetOfExactType<_FormScope>()
        ?.controller;
    assert(
      form == null || widget.fieldKey != null,
      'A CamoFormField inside a CamoForm needs a fieldKey.',
    );
    if (form != _form || _entry == null) _attach(form);
  }

  @override
  void didUpdateWidget(CamoFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldKey != widget.fieldKey) _attach(_form);
    _update();
  }

  void _attach(CamoFormController? form) {
    _detach();
    _form = form;
    final key = widget.fieldKey;
    final entry = form != null && key != null
        ? form._entry(key, widget.initialValue)
        : _Entry(key ?? '', widget.initialValue, 0);
    assert(
      entry.context == null || !entry.context!.mounted,
      'Two CamoFormFields share the key "${entry.key}". Keys must be unique in a form.',
    );
    _entry = entry
      ..focusNode = _focus
      ..context = context
      ..addListener(_changed);
    _view = CamoFormFieldState<T>._(
      entry,
      form,
      () => widget.validateMode ?? _form?._mode ?? ValidateMode.disabled,
      () => widget.forceError,
    );
    _update();
    if (form != null && form._pendingFocus == entry.key) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        form._pendingFocus = null;
        Scrollable.ensureVisible(context, alignment: 0.5);
        _focus.requestFocus();
      });
    }
  }

  void _update() {
    final e = _entry!;
    e
      ..rules = widget.rules
      ..mode = widget.validateMode
      ..enabled = widget.enabled
      ..visible = widget.visible
      ..onSaved = widget.onSaved == null
          ? null
          : (v) => widget.onSaved!(v as T?);
    if (!widget.enabled && e._error != null) e._error = null;
  }

  void _detach() {
    final e = _entry;
    if (e == null) return;
    e.removeListener(_changed);
    if (e.context == context) {
      e
        ..context = null
        ..focusNode = null;
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detach();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.validateMode ?? _form?._mode ?? ValidateMode.disabled;
    final e = _entry!;
    if (mode == ValidateMode.always &&
        widget.enabled &&
        widget.visible &&
        (!_checked || e.value != _checkedValue)) {
      _checked = true;
      _checkedValue = e.value;
      // After the frame: validating stores the error, which rebuilds this field.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _view!.validate();
      });
    }
    return widget.builder(context, _view!);
  }
}
