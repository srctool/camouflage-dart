import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../text/camo_text.dart';

/// How many rows a wheel shows: the selected one in the middle, two above and two below.
const wheelRows = 5;

/// One wheel of a picker: [count] rows that snap, the row under the middle reported to [onSelect]. Screen
/// readers get an adjustable control named [name] whose value is the selected row's label; Up and Down move it
/// by one when it has focus. The picker's renderer draws the band behind the middle row.
class CamoWheelColumn extends StatefulWidget {
  /// Creates a wheel.
  const CamoWheelColumn({
    super.key,
    required this.count,
    required this.selected,
    required this.onSelect,
    required this.label,
    required this.name,
    required this.itemHeight,
    required this.textStyle,
    required this.selectedColor,
    required this.color,
  });

  /// How many rows.
  final int count;

  /// The selected row.
  final int selected;

  /// Called with the row that settles in the middle.
  final ValueChanged<int> onSelect;

  /// A row's text.
  final String Function(int index) label;

  /// The wheel's accessible name ("Hour").
  final String name;

  /// A row's height.
  final double itemHeight;

  /// The rows' text.
  final TextStyle textStyle;

  /// The selected row's color.
  final Color selectedColor;

  /// The other rows' color.
  final Color color;

  @override
  State<CamoWheelColumn> createState() => _CamoWheelColumnState();
}

class _CamoWheelColumnState extends State<CamoWheelColumn> {
  late final _controller = FixedExtentScrollController(
    initialItem: widget.selected,
  );

  @override
  void didUpdateWidget(CamoWheelColumn old) {
    super.didUpdateWidget(old);
    final c = _controller;
    if (c.hasClients &&
        c.selectedItem != widget.selected &&
        !c.position.isScrollingNotifier.value) {
      c.jumpToItem(widget.selected);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int by) {
    final target = widget.selected + by;
    if (target >= 0 && target < widget.count) widget.onSelect(target);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Semantics(
      label: w.name,
      value: w.label(w.selected),
      increasedValue: w.selected + 1 < w.count ? w.label(w.selected + 1) : null,
      decreasedValue: w.selected > 0 ? w.label(w.selected - 1) : null,
      onIncrease: w.selected + 1 < w.count ? () => _step(1) : null,
      onDecrease: w.selected > 0 ? () => _step(-1) : null,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => _step(-1),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => _step(1),
        },
        child: Focus(
          child: SizedBox(
            height: w.itemHeight * wheelRows,
            child: ExcludeSemantics(
              child: ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: w.itemHeight,
                physics: const FixedExtentScrollPhysics(),
                diameterRatio: 3,
                onSelectedItemChanged: (i) {
                  if (i != w.selected) w.onSelect(i);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: w.count,
                  builder: (context, i) => Center(
                    child: CamoText(
                      w.label(i),
                      style: w.textStyle,
                      color: i == w.selected ? w.selectedColor : w.color,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
