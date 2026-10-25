import 'package:flutter/foundation.dart';

import '../button/camo_button.dart';
import '../divider/camo_divider.dart';
import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../progress/camo_progress.dart';
import '../surface/camo_surface.dart';
import '../text/camo_text.dart';
import '../tooltip/camo_tooltip.dart';
import 'contract.dart';

/// A design language: how each component is built, how it reacts to touch and what its surfaces are made of.
///
/// Every field is required, so a skin that misses one doesn't compile. Each component adds its renderer
/// field here in its own milestone (ADR-39). `copyWith(button: …)` replaces part of a skin and keeps the rest.
/// Renderers read `Camouflage.skinOf(context).surfaceTreatment` and `.feedback`, so a borrowed renderer takes
/// the host skin's.
@immutable
class CamoSkin {
  /// Creates a skin.
  const CamoSkin({
    required this.name,
    required this.surfaceTreatment,
    required this.feedback,
    required this.text,
    required this.icon,
    required this.surface,
    required this.divider,
    required this.button,
    required this.iconButton,
    required this.progressCircle,
    required this.tooltip,
  });

  /// For debugging and tests, e.g. `'minimal'`.
  final String name;

  /// What this skin's containers are made of.
  final SurfaceTreatment surfaceTreatment;

  /// How this skin responds to press, hover and focus.
  final InteractionFeedback feedback;

  /// Draws `CamoText`.
  final CamoTextRenderer text;

  /// Draws `CamoIcon`.
  final CamoIconRenderer icon;

  /// Draws `CamoSurface`.
  final CamoSurfaceRenderer surface;

  /// Draws `CamoDivider`.
  final CamoDividerRenderer divider;

  /// Draws `CamoButton`.
  final CamoButtonRenderer button;

  /// Draws `CamoIconButton`.
  final CamoIconButtonRenderer iconButton;

  /// Draws `CamoProgressCircle`.
  final CamoProgressCircleRenderer progressCircle;

  /// Draws `CamoTooltip`'s bubble.
  final CamoTooltipRenderer tooltip;

  /// A copy with the given fields replaced; the others stay `identical`.
  CamoSkin copyWith({
    String? name,
    SurfaceTreatment? surfaceTreatment,
    InteractionFeedback? feedback,
    CamoTextRenderer? text,
    CamoIconRenderer? icon,
    CamoSurfaceRenderer? surface,
    CamoDividerRenderer? divider,
    CamoButtonRenderer? button,
    CamoIconButtonRenderer? iconButton,
    CamoProgressCircleRenderer? progressCircle,
    CamoTooltipRenderer? tooltip,
  }) => CamoSkin(
    name: name ?? this.name,
    surfaceTreatment: surfaceTreatment ?? this.surfaceTreatment,
    feedback: feedback ?? this.feedback,
    text: text ?? this.text,
    icon: icon ?? this.icon,
    surface: surface ?? this.surface,
    divider: divider ?? this.divider,
    button: button ?? this.button,
    iconButton: iconButton ?? this.iconButton,
    progressCircle: progressCircle ?? this.progressCircle,
    tooltip: tooltip ?? this.tooltip,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSkin &&
      other.name == name &&
      other.surfaceTreatment == surfaceTreatment &&
      other.feedback == feedback &&
      other.text == text &&
      other.icon == icon &&
      other.surface == surface &&
      other.divider == divider &&
      other.button == button &&
      other.iconButton == iconButton &&
      other.progressCircle == progressCircle &&
      other.tooltip == tooltip;

  @override
  int get hashCode => Object.hash(
    name,
    surfaceTreatment,
    feedback,
    text,
    icon,
    surface,
    divider,
    button,
    iconButton,
    progressCircle,
    tooltip,
  );

  @override
  String toString() => 'CamoSkin($name)';
}
