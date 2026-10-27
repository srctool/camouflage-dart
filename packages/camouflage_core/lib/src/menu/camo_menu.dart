import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// Where a checked menu item's checkmark sits.
enum CheckPosition {
  /// Before the text, in a reserved column.
  leading,

  /// After the text.
  trailing,
}

/// Every color a menu uses.
@immutable
class MenuColors {
  /// Creates menu colors.
  const MenuColors({
    required this.container,
    required this.text,
    required this.icon,
    required this.trailingText,
  });

  /// The panel.
  final Color container;

  /// Item text.
  final Color text;

  /// Leading icons.
  final Color icon;

  /// Trailing text, e.g. a shortcut.
  final Color trailingText;

  @override
  bool operator ==(Object other) =>
      other is MenuColors &&
      other.container == container &&
      other.text == text &&
      other.icon == icon &&
      other.trailingText == trailingText;

  @override
  int get hashCode => Object.hash(container, text, icon, trailingText);
}

/// Overrides for menus and popup panels; `null` keeps the skin's default.
@immutable
class CamoMenuTheme {
  /// Creates menu overrides.
  const CamoMenuTheme({
    this.shape,
    this.minWidth,
    this.maxWidth,
    this.itemHeight,
    this.contentPadding,
    this.textStyle,
    this.iconSize,
    this.elevation,
    this.checkPosition,
    this.colors,
  });

  /// The corners.
  final BorderRadius? shape;

  /// The narrowest panel.
  final double? minWidth;

  /// The widest menu (items; custom panels may ask for more).
  final double? maxWidth;

  /// A row's height (M6).
  final double? itemHeight;

  /// Inside the panel.
  final EdgeInsetsDirectional? contentPadding;

  /// Item text (M6).
  final TextStyle? textStyle;

  /// Leading icons (M6).
  final double? iconSize;

  /// Depth.
  final double? elevation;

  /// Where a checkmark sits (M6).
  final CheckPosition? checkPosition;

  /// Every color it uses.
  final MenuColors? colors;

  /// A copy with the given fields replaced.
  CamoMenuTheme copyWith({
    BorderRadius? shape,
    double? minWidth,
    double? maxWidth,
    double? itemHeight,
    EdgeInsetsDirectional? contentPadding,
    TextStyle? textStyle,
    double? iconSize,
    double? elevation,
    CheckPosition? checkPosition,
    MenuColors? colors,
  }) => CamoMenuTheme(
    shape: shape ?? this.shape,
    minWidth: minWidth ?? this.minWidth,
    maxWidth: maxWidth ?? this.maxWidth,
    itemHeight: itemHeight ?? this.itemHeight,
    contentPadding: contentPadding ?? this.contentPadding,
    textStyle: textStyle ?? this.textStyle,
    iconSize: iconSize ?? this.iconSize,
    elevation: elevation ?? this.elevation,
    checkPosition: checkPosition ?? this.checkPosition,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoMenuTheme &&
      other.shape == shape &&
      other.minWidth == minWidth &&
      other.maxWidth == maxWidth &&
      other.itemHeight == itemHeight &&
      other.contentPadding == contentPadding &&
      other.textStyle == textStyle &&
      other.iconSize == iconSize &&
      other.elevation == elevation &&
      other.checkPosition == checkPosition &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    shape,
    minWidth,
    maxWidth,
    itemHeight,
    contentPadding,
    textStyle,
    iconSize,
    elevation,
    checkPosition,
    colors,
  );
}

/// The resolved menu style: every field set.
@immutable
class CamoMenuStyle {
  /// Creates a menu style.
  const CamoMenuStyle({
    required this.shape,
    required this.minWidth,
    required this.maxWidth,
    required this.itemHeight,
    required this.contentPadding,
    required this.textStyle,
    required this.iconSize,
    required this.elevation,
    required this.checkPosition,
    required this.colors,
  });

  /// The corners.
  final BorderRadius shape;

  /// The narrowest panel.
  final double minWidth;

  /// The widest menu.
  final double maxWidth;

  /// A row's height.
  final double itemHeight;

  /// Inside the panel.
  final EdgeInsetsDirectional contentPadding;

  /// Item text.
  final TextStyle textStyle;

  /// Leading icons.
  final double iconSize;

  /// Depth.
  final double elevation;

  /// Where a checkmark sits.
  final CheckPosition checkPosition;

  /// Every color it uses.
  final MenuColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoMenuStyle merge(CamoMenuTheme? o) => o == null
      ? this
      : CamoMenuStyle(
          shape: o.shape ?? shape,
          minWidth: o.minWidth ?? minWidth,
          maxWidth: o.maxWidth ?? maxWidth,
          itemHeight: o.itemHeight ?? itemHeight,
          contentPadding: o.contentPadding ?? contentPadding,
          textStyle: o.textStyle ?? textStyle,
          iconSize: o.iconSize ?? iconSize,
          elevation: o.elevation ?? elevation,
          checkPosition: o.checkPosition ?? checkPosition,
          colors: o.colors ?? colors,
        );
}

/// Draws menus. In M5 it draws the popup panel, the surface every anchored popup sits on (a date picker's
/// calendar, a custom menu); the menu's rows arrive with `CamoMenu` in M6.
abstract interface class CamoMenuRenderer {
  /// The complete menu style for [theme].
  CamoMenuStyle defaults(CamoTheme theme);

  /// The popup's container around [child], at least `minWidth` wide.
  Widget panel(
    BuildContext context,
    Widget child,
    CamoTheme theme,
    CamoMenuStyle style,
  );
}

/// The skin's popup surface (ADR-30) for custom popup content: Up and Down move focus between its focusable
/// children when they don't use the keys themselves.
class CamoMenuPanel extends StatelessWidget {
  /// Creates a panel around [child].
  const CamoMenuPanel({super.key, required this.child});

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoMenuPanel');
    final theme = Camouflage.themeOf(context, component: 'CamoMenuPanel');
    final style = skin.menu.defaults(theme).merge(theme.components.menu);
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
      },
      child: FocusTraversalGroup(
        child: skin.menu.panel(context, child, theme, style),
      ),
    );
  }
}
