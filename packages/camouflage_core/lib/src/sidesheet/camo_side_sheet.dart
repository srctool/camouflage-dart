import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../overlay/camo_side_frame.dart';
import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// Every color a side sheet uses; [modalContainer] is the container while it slides over the content.
@immutable
class SideSheetColors {
  /// Creates SideSheetColors.
  const SideSheetColors({
    required this.container,
    required this.modalContainer,
    required this.title,
    required this.divider,
  });

  /// The standard fill.
  final Color container;

  /// The modal fill.
  final Color modalContainer;

  /// The title.
  final Color title;

  /// The edge line and the line under the title.
  final Color divider;

  @override
  bool operator ==(Object other) =>
      other is SideSheetColors &&
      other.container == container &&
      other.modalContainer == modalContainer &&
      other.title == title &&
      other.divider == divider;

  @override
  int get hashCode => Object.hash(container, modalContainer, title, divider);
}

/// Overrides for side sheets; `null` keeps the skin's default.
@immutable
class CamoSideSheetTheme {
  /// Creates overrides.
  const CamoSideSheetTheme({
    this.width,
    this.modalShape,
    this.padding,
    this.titleStyle,
    this.showDivider,
    this.showCloseButton,
    this.closeIcon,
    this.scrimAlpha,
    this.colors,
  });

  /// The sheet width (at most 80% of a phone window).
  final double? width;

  /// The modal container corners.
  final BorderRadius? modalShape;

  /// Around the content.
  final double? padding;

  /// The title.
  final TextStyle? titleStyle;

  /// The edge line in standard mode and the line under the title.
  final bool? showDivider;

  /// A close button when onClose is set.
  final bool? showCloseButton;

  /// The close button icon.
  final IconSource? closeIcon;

  /// The modal scrim.
  final double? scrimAlpha;

  /// Every color it uses.
  final SideSheetColors? colors;

  /// A copy with the given fields replaced.
  CamoSideSheetTheme copyWith({
    double? width,
    BorderRadius? modalShape,
    double? padding,
    TextStyle? titleStyle,
    bool? showDivider,
    bool? showCloseButton,
    IconSource? closeIcon,
    double? scrimAlpha,
    SideSheetColors? colors,
  }) => CamoSideSheetTheme(
    width: width ?? this.width,
    modalShape: modalShape ?? this.modalShape,
    padding: padding ?? this.padding,
    titleStyle: titleStyle ?? this.titleStyle,
    showDivider: showDivider ?? this.showDivider,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    closeIcon: closeIcon ?? this.closeIcon,
    scrimAlpha: scrimAlpha ?? this.scrimAlpha,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoSideSheetTheme &&
      other.width == width &&
      other.modalShape == modalShape &&
      other.padding == padding &&
      other.titleStyle == titleStyle &&
      other.showDivider == showDivider &&
      other.showCloseButton == showCloseButton &&
      other.closeIcon == closeIcon &&
      other.scrimAlpha == scrimAlpha &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    width,
    modalShape,
    padding,
    titleStyle,
    showDivider,
    showCloseButton,
    closeIcon,
    scrimAlpha,
    colors,
  );
}

/// The resolved side sheet style: every field set.
@immutable
class CamoSideSheetStyle {
  /// Creates a style.
  const CamoSideSheetStyle({
    required this.width,
    required this.modalShape,
    required this.padding,
    required this.titleStyle,
    required this.showDivider,
    required this.showCloseButton,
    required this.closeIcon,
    required this.scrimAlpha,
    required this.colors,
  });

  /// The sheet width (at most 80% of a phone window).
  final double width;

  /// The modal container corners.
  final BorderRadius modalShape;

  /// Around the content.
  final double padding;

  /// The title.
  final TextStyle titleStyle;

  /// The edge line in standard mode and the line under the title.
  final bool showDivider;

  /// A close button when onClose is set.
  final bool showCloseButton;

  /// The close button icon.
  final IconSource closeIcon;

  /// The modal scrim.
  final double scrimAlpha;

  /// Every color it uses.
  final SideSheetColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoSideSheetStyle merge(CamoSideSheetTheme? o) => o == null
      ? this
      : CamoSideSheetStyle(
          width: o.width ?? width,
          modalShape: o.modalShape ?? modalShape,
          padding: o.padding ?? padding,
          titleStyle: o.titleStyle ?? titleStyle,
          showDivider: o.showDivider ?? showDivider,
          showCloseButton: o.showCloseButton ?? showCloseButton,
          closeIcon: o.closeIcon ?? closeIcon,
          scrimAlpha: o.scrimAlpha ?? scrimAlpha,
          colors: o.colors ?? colors,
        );
}

/// What the side sheet renderer draws: [modal] while it slides over the content, standard (docked) in the layout.
/// Draw the [title] and, when [onClose] is set and the style asks for it, a close button that calls it.
@immutable
class SideSheetState {
  /// Creates the state.
  const SideSheetState({
    required this.modal,
    required this.title,
    required this.onClose,
  });

  /// Whether it is the modal mode.
  final bool modal;

  /// The title.
  final String? title;

  /// Called by the close button.
  final VoidCallback? onClose;
}

/// A side sheet's content: the scrolling [child] and the [actions] pinned at the bottom.
@immutable
class SideSheetSlots {
  /// Creates the slots.
  const SideSheetSlots({required this.child, this.actions});

  /// The content, scrolling.
  final Widget child;

  /// The actions at the bottom end.
  final Widget? actions;
}

/// Draws side sheets.
abstract interface class CamoSideSheetRenderer {
  /// The complete side sheet style for [theme].
  CamoSideSheetStyle defaults(CamoTheme theme);

  /// Draws the sheet: the container, the title row, the scrolling content and the actions.
  Widget render(
    BuildContext context,
    SideSheetState state,
    SideSheetSlots slots,
    CamoTheme theme,
    CamoSideSheetStyle style,
  );
}

class _ModalScope extends InheritedWidget {
  const _ModalScope({required super.child});

  @override
  bool updateShouldNotify(_ModalScope old) => false;
}

/// A panel on the end edge for secondary content next to the main screen: properties, filters, details. Placed
/// in a layout it is the **standard** (docked) mode, and the main content stays usable; inside a
/// [CamoModalSideSheet] it is the **modal** one. [title] names it for screen readers; [onClose] adds a close
/// button (and is what dismissing the modal one asks for). The [child] scrolls; the [actions] stay at the bottom.
class CamoSideSheet extends StatelessWidget {
  /// Creates a side sheet.
  const CamoSideSheet({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    this.actions,
  });

  /// The content.
  final Widget child;

  /// The title; it also names the panel for screen readers.
  final String? title;

  /// Adds a close button that calls it.
  final VoidCallback? onClose;

  /// Buttons pinned at the bottom end.
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSideSheet');
    final theme = Camouflage.themeOf(context, component: 'CamoSideSheet');
    final style = skin.sideSheet
        .defaults(theme)
        .merge(theme.components.sideSheet);
    final modal =
        context.dependOnInheritedWidgetOfExactType<_ModalScope>() != null;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: title,
      child: skin.sideSheet.render(
        context,
        SideSheetState(modal: modal, title: title, onClose: onClose),
        SideSheetSlots(child: child, actions: actions),
        theme,
        style,
      ),
    );
  }
}

/// The modal mode: a [CamoSideSheet] sliding in from the end edge over the content, with a scrim. Its visibility
/// is state ([open]), like the modal drawer's. A scrim tap, back, Esc and a drag toward the end edge all call
/// [onDismissRequest]; focus moves in and stays in while it is open. Place it where an `Overlay` is above it
/// (inside a route).
class CamoModalSideSheet extends StatelessWidget {
  /// Creates a modal side sheet.
  const CamoModalSideSheet({
    super.key,
    required this.open,
    required this.onDismissRequest,
    required this.child,
  });

  /// Whether the sheet is shown.
  final bool open;

  /// Called by a scrim tap, back, Esc or a drag toward the end edge.
  final VoidCallback onDismissRequest;

  /// A [CamoSideSheet].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoModalSideSheet');
    final theme = Camouflage.themeOf(context, component: 'CamoModalSideSheet');
    final style = skin.sideSheet
        .defaults(theme)
        .merge(theme.components.sideSheet);
    return CamoSideFrame(
      edge: SideEdge.end,
      open: open,
      onDismissRequest: onDismissRequest,
      width: style.width,
      scrimAlpha: style.scrimAlpha,
      child: _ModalScope(child: child),
    );
  }
}
