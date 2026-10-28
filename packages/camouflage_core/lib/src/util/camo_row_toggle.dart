import 'package:flutter/widgets.dart';

/// Lets a tappable row know that a display-only switch, checkbox or radio sits inside it, so the row is
/// announced as that control ("Wi-Fi, switch, on") instead of a button. The control's state reaches the row
/// through semantics merging.
class RowToggleScope extends InheritedWidget {
  /// Creates the scope; [onToggle] is told when a control appears (`true`) or goes (`false`).
  const RowToggleScope({
    super.key,
    required this.onToggle,
    required super.child,
  });

  /// Called when a display-only control appears or goes.
  final ValueChanged<bool> onToggle;

  @override
  bool updateShouldNotify(RowToggleScope oldWidget) => false;
}

/// A display-only control's [child] with its state in semantics ([toggled] for a switch, [checked] for a
/// checkbox or radio), reported to the tappable row around it. Outside a row it's [child] unchanged.
Widget reportRowToggle(
  BuildContext context, {
  bool? toggled,
  bool? checked,
  bool radio = false,
  required Widget child,
}) {
  final scope = context.getInheritedWidgetOfExactType<RowToggleScope>();
  if (scope == null) return child;
  return _Reporter(
    scope: scope,
    child: Semantics(
      toggled: toggled,
      checked: checked,
      inMutuallyExclusiveGroup: radio ? true : null,
      child: child,
    ),
  );
}

class _Reporter extends StatefulWidget {
  const _Reporter({required this.scope, required this.child});

  final RowToggleScope scope;
  final Widget child;

  @override
  State<_Reporter> createState() => _ReporterState();
}

class _ReporterState extends State<_Reporter> {
  @override
  void initState() {
    super.initState();
    widget.scope.onToggle(true);
  }

  @override
  void dispose() {
    widget.scope.onToggle(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
