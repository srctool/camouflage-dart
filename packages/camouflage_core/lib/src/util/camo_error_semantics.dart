import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Marks [child] invalid with [message], announced politely when it appears. `null` leaves [child] as it is.
/// Inputs wrap their behavior in it; the visible error text then excludes its own semantics.
class CamoErrorSemantics extends StatelessWidget {
  /// Creates the error semantics around [child].
  const CamoErrorSemantics({
    super.key,
    required this.message,
    required this.child,
  });

  /// The error, or `null` when valid.
  final String? message;

  /// The input.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return child;
    return Semantics(
      validationResult: SemanticsValidationResult.invalid,
      hint: message,
      liveRegion: true,
      child: child,
    );
  }
}
