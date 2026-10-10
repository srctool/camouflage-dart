import 'package:flutter/foundation.dart';

/// The theme every component reads its tokens from. A placeholder until milestone M1 defines the real tokens.
@immutable
class CamoTheme {
  /// Creates a theme.
  const CamoTheme({required this.placeholder});

  /// A stand-in token until M1.
  final int placeholder;

  @override
  bool operator ==(Object other) =>
      other is CamoTheme && other.placeholder == placeholder;

  @override
  int get hashCode => placeholder.hashCode;
}
