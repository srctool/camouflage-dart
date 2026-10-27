import 'package:flutter/foundation.dart';

/// Which side of a control its label sits on, in reading order: [start] before it, [end] after it.
enum CamoLabelPosition {
  /// The label comes first; the control sits at the end of the row.
  start,

  /// The control comes first, then the label.
  end,
}

/// An item's place in a row of [count] items (a segment, a tab), for its shape and its "2 of 3" announcement.
@immutable
class CamoItemPosition {
  /// Creates a position.
  const CamoItemPosition(this.index, this.count);

  /// Zero-based.
  final int index;

  /// How many items the row has.
  final int count;

  /// The first item.
  bool get isFirst => index == 0;

  /// The last item.
  bool get isLast => index == count - 1;

  @override
  bool operator ==(Object other) =>
      other is CamoItemPosition && other.index == index && other.count == count;

  @override
  int get hashCode => Object.hash(index, count);
}

/// Where a header's title sits: at the start, or centered.
enum CamoTitleAlign {
  /// At the start, in reading order.
  start,

  /// Centered.
  center,
}
