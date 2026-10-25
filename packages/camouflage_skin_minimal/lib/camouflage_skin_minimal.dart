/// The Minimal skin: Camouflage's own neutral dialect.
library;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

/// The Minimal skin's starter theme: monochrome ink on true grays. A placeholder until milestone M3 builds the skin.
final CamoTheme minimalTheme = CamoTheme(
  colors: CamoColors.fromSeed(primary: const Color(0xFF1F1F1F)),
  typography: CamoTypography.system(),
);
