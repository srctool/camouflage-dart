/// One validation check, like a Flutter validator: `null` means valid, otherwise the message to show. Rules are
/// constants or classes, reusable across forms; a field's rules run in order and the first failure wins.
abstract interface class CamoRule<T> {
  /// A rule from a function.
  const factory CamoRule.from(String? Function(T? value) check) = _FnRule<T>;

  /// The message for [value], or `null` when it's valid.
  String? validate(T? value);
}

class _FnRule<T> implements CamoRule<T> {
  const _FnRule(this._check);

  final String? Function(T? value) _check;

  @override
  String? validate(T? value) => _check(value);
}

/// The built-in rules. Messages are always passed in, for localization.
abstract final class CamoRules {
  /// Not null, and not blank for text (`T` comes from the field's rule list).
  static CamoRule<T> required<T>(String message) => CamoRule<T>.from(
    (v) => switch (v) {
      null => message,
      final String s when s.trim().isEmpty => message,
      final Iterable<Object?> i when i.isEmpty => message,
      _ => null,
    },
  );

  /// A boolean that is true (a consent checkbox).
  static CamoRule<bool> requiredTrue(String message) =>
      CamoRule<bool>.from((v) => v == true ? null : message);

  /// At least [n] characters; empty text passes (pair with [required]).
  static CamoRule<String> minLength(int n, String message) => CamoRule.from(
    (v) => v != null && v.isNotEmpty && v.length < n ? message : null,
  );

  /// At most [n] characters.
  static CamoRule<String> maxLength(int n, String message) =>
      CamoRule.from((v) => (v?.length ?? 0) > n ? message : null);

  /// A number of at least [n]; text that isn't a number fails, empty text passes.
  static CamoRule<String> min(num n, String message) =>
      _number(message, (x) => x >= n);

  /// A number of at most [n]; text that isn't a number fails, empty text passes.
  static CamoRule<String> max(num n, String message) =>
      _number(message, (x) => x <= n);

  /// The whole text matches [regex]; empty text passes.
  static CamoRule<String> pattern(RegExp regex, String message) =>
      CamoRule.from((v) {
        if (v == null || v.isEmpty) return null;
        final m = regex.matchAsPrefix(v);
        return m != null && m.end == v.length ? null : message;
      });

  /// A practical email shape (not full RFC 5322); empty text passes.
  static CamoRule<String> email(String message) =>
      pattern(RegExp(r'[^\s@]+@[^\s@]+\.[^\s@]+'), message);

  /// Equals the field [fieldKey] in the same form (confirm password). Outside a form it passes.
  static CamoRule<String> matches(String fieldKey, String message) =>
      MatchesRule(fieldKey, message);

  static CamoRule<String> _number(String message, bool Function(num) ok) =>
      CamoRule.from((v) {
        if (v == null || v.trim().isEmpty) return null;
        final n = num.tryParse(v.trim().replaceAll(',', '.'));
        return n == null || !ok(n) ? message : null;
      });
}

/// Needs the form to read the other field; the form resolves it while validating.
class MatchesRule implements CamoRule<String> {
  /// Creates the rule.
  const MatchesRule(this.fieldKey, this.message);

  /// The other field.
  final String fieldKey;

  /// The message.
  final String message;

  @override
  String? validate(String? value) => null;

  /// The message when [value] differs from [other].
  String? check(Object? value, Object? other) =>
      value == other ? null : message;
}
