import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

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
    this.checkIcon,
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

  /// The checkmark of a checked item (and of the current option in a select's sheet).
  final IconSource? checkIcon;

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
    IconSource? checkIcon,
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
    checkIcon: checkIcon ?? this.checkIcon,
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
      other.checkIcon == checkIcon &&
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
    checkIcon,
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
    required this.checkIcon,
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

  /// The checkmark of a checked item (and of the current option in a select's sheet).
  final IconSource checkIcon;

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
          checkIcon: o.checkIcon ?? checkIcon,
          colors: o.colors ?? colors,
        );
}

/// What a menu row renderer draws: [text] with [trailingText] (a shortcut) at the end, in [tone] (`error` for
/// destructive items) and dimmed when not [enabled]. [checked] is `null` for a plain item; otherwise draw the
/// check when `true`, at `style.checkPosition`. Keep the text aligned across the menu: leave the check column
/// when [reserveCheck] (some item is checkable) and the icon column when [reserveIcon] (some item has an icon).
/// Show the highlight from [interaction] (hovered, focused, pressed).
@immutable
class MenuItemState {
  /// Creates a row state.
  const MenuItemState({
    required this.text,
    required this.trailingText,
    required this.tone,
    required this.enabled,
    required this.checked,
    required this.reserveCheck,
    required this.reserveIcon,
    required this.interaction,
    required this.controller,
  });

  /// The item's text.
  final String text;

  /// A shortcut at the end, if any.
  final String? trailingText;

  /// `error` for destructive items.
  final Tone tone;

  /// `false` shows the disabled look.
  final bool enabled;

  /// `null` for a plain item; otherwise whether it's checked.
  final bool? checked;

  /// Some item in the menu is checkable: keep the check column.
  final bool reserveCheck;

  /// Some item in the menu has an icon: keep the icon column.
  final bool reserveIcon;

  /// Press, hover and focus.
  final InteractionState interaction;

  /// For the skin's feedback.
  final CamoInteractionController controller;
}

/// The item's leading icon, if any.
@immutable
class MenuItemSlots {
  /// Creates the slots.
  const MenuItemSlots({this.leadingIcon});

  /// Before the text.
  final Widget? leadingIcon;
}

/// Draws menus: the popup panel, the surface every anchored popup sits on (a menu, a date picker's calendar),
/// and the menu's rows.
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

  /// Draws one row, `style.itemHeight` tall and filling the panel's width. Keep the text in the semantics tree.
  Widget item(
    BuildContext context,
    MenuItemState state,
    MenuItemSlots slots,
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
