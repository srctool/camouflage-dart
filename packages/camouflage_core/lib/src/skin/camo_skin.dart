import 'package:flutter/foundation.dart';

import 'contract.dart';

/// A design language: how each component is built, how it reacts to touch and what its surfaces are made of.
///
/// Every field is required, so a skin that misses one doesn't compile. Each component adds its renderer
/// field here in its own milestone (M3 to M8, ADR-39). `copyWith(feedback: …)` replaces part of a skin and
/// keeps the rest.
@immutable
class CamoSkin {
  /// Creates a skin.
  const CamoSkin({
    required this.name,
    required this.surfaceTreatment,
    required this.feedback,
  });

  /// For debugging and tests, e.g. `'minimal'`.
  final String name;

  /// What this skin's containers are made of.
  final SurfaceTreatment surfaceTreatment;

  /// How this skin responds to press, hover and focus.
  final InteractionFeedback feedback;

  /// A copy with the given fields replaced; the others stay `identical`.
  CamoSkin copyWith({
    String? name,
    SurfaceTreatment? surfaceTreatment,
    InteractionFeedback? feedback,
  }) => CamoSkin(
    name: name ?? this.name,
    surfaceTreatment: surfaceTreatment ?? this.surfaceTreatment,
    feedback: feedback ?? this.feedback,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSkin &&
      other.name == name &&
      other.surfaceTreatment == surfaceTreatment &&
      other.feedback == feedback;

  @override
  int get hashCode => Object.hash(name, surfaceTreatment, feedback);

  @override
  String toString() => 'CamoSkin($name)';
}
