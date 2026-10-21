import 'package:flutter/foundation.dart';

/// Per-component overrides: one nullable `CamoXTheme` per component, `null` meaning the skin's default.
/// Each component adds its field here, with its `CamoXTheme` / `CamoXStyle` pair, in its own milestone (M3 to M8).
@immutable
class CamoComponentThemes {
  /// Creates component themes (none yet).
  const CamoComponentThemes();

  @override
  bool operator ==(Object other) => other is CamoComponentThemes;

  @override
  int get hashCode => 0;
}
