import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/positions.dart';
import '../theme/camo_theme.dart';

/// How a sheet shows on a wide window: still a bottom sheet (capped at `maxWidth`), or a centered card.
enum WidePresentation {
  /// Still a bottom sheet, capped at `maxWidth`.
  sheet,

  /// A centered card.
  centered,
}

/// A sheet opened over another overlay: with its own scrim (darker), or sharing the one below.
enum StackedScrim {
  /// Each overlay brings its own scrim, so layers get darker.
  each,

  /// One scrim, under the lowest overlay.
  topOnly,
}

/// Overrides for bottom sheets; `null` keeps the skin's default.
@immutable
class CamoBottomSheetTheme {
  /// Creates bottom sheet overrides.
  const CamoBottomSheetTheme({
    this.shape,
    this.maxWidth,
    this.contentPadding,
    this.showHandle,
    this.handleSize,
    this.handleColor,
    this.titleStyle,
    this.titleAlign,
    this.showCloseButton,
    this.closeIcon,
    this.containerColor,
    this.scrimAlpha,
    this.widePresentation,
    this.stackedScrim,
  });

  /// The corners (the top ones, for a bottom sheet).
  final BorderRadius? shape;

  /// The widest the sheet gets on tablets and desktop.
  final double? maxWidth;

  /// Inside the sheet, around the content.
  final EdgeInsetsDirectional? contentPadding;

  /// Whether the drag handle shows.
  final bool? showHandle;

  /// The drag handle's size.
  final Size? handleSize;

  /// The drag handle's color.
  final Color? handleColor;

  /// The title.
  final TextStyle? titleStyle;

  /// Where the title sits.
  final CamoTitleAlign? titleAlign;

  /// A ✕ in the header, shown only when the sheet is dismissible.
  final bool? showCloseButton;

  /// The ✕'s icon.
  final IconSource? closeIcon;

  /// The background.
  final Color? containerColor;

  /// The scrim's opacity over `colors.scrim`.
  final double? scrimAlpha;

  /// How the sheet shows on wide windows.
  final WidePresentation? widePresentation;

  /// Over another overlay: its own scrim or the shared one.
  final StackedScrim? stackedScrim;

  /// A copy with the given fields replaced.
  CamoBottomSheetTheme copyWith({
    BorderRadius? shape,
    double? maxWidth,
    EdgeInsetsDirectional? contentPadding,
    bool? showHandle,
    Size? handleSize,
    Color? handleColor,
    TextStyle? titleStyle,
    CamoTitleAlign? titleAlign,
    bool? showCloseButton,
    IconSource? closeIcon,
    Color? containerColor,
    double? scrimAlpha,
    WidePresentation? widePresentation,
    StackedScrim? stackedScrim,
  }) => CamoBottomSheetTheme(
    shape: shape ?? this.shape,
    maxWidth: maxWidth ?? this.maxWidth,
    contentPadding: contentPadding ?? this.contentPadding,
    showHandle: showHandle ?? this.showHandle,
    handleSize: handleSize ?? this.handleSize,
    handleColor: handleColor ?? this.handleColor,
    titleStyle: titleStyle ?? this.titleStyle,
    titleAlign: titleAlign ?? this.titleAlign,
    showCloseButton: showCloseButton ?? this.showCloseButton,
    closeIcon: closeIcon ?? this.closeIcon,
    containerColor: containerColor ?? this.containerColor,
    scrimAlpha: scrimAlpha ?? this.scrimAlpha,
    widePresentation: widePresentation ?? this.widePresentation,
    stackedScrim: stackedScrim ?? this.stackedScrim,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoBottomSheetTheme &&
      other.shape == shape &&
      other.maxWidth == maxWidth &&
      other.contentPadding == contentPadding &&
      other.showHandle == showHandle &&
      other.handleSize == handleSize &&
      other.handleColor == handleColor &&
      other.titleStyle == titleStyle &&
      other.titleAlign == titleAlign &&
      other.showCloseButton == showCloseButton &&
      other.closeIcon == closeIcon &&
      other.containerColor == containerColor &&
      other.scrimAlpha == scrimAlpha &&
      other.widePresentation == widePresentation &&
      other.stackedScrim == stackedScrim;

  @override
  int get hashCode => Object.hash(
    shape,
    maxWidth,
    contentPadding,
    showHandle,
    handleSize,
    handleColor,
    titleStyle,
    titleAlign,
    showCloseButton,
    closeIcon,
    containerColor,
    scrimAlpha,
    widePresentation,
    stackedScrim,
  );
}

/// The resolved bottom sheet style: every field set.
@immutable
class CamoBottomSheetStyle {
  /// Creates a bottom sheet style.
  const CamoBottomSheetStyle({
    required this.shape,
    required this.maxWidth,
    required this.contentPadding,
    required this.showHandle,
    required this.handleSize,
    required this.handleColor,
    required this.titleStyle,
    required this.titleAlign,
    required this.showCloseButton,
    required this.closeIcon,
    required this.containerColor,
    required this.scrimAlpha,
    required this.widePresentation,
    required this.stackedScrim,
  });

  /// The corners.
  final BorderRadius shape;

  /// The widest the sheet gets.
  final double maxWidth;

  /// Inside the sheet, around the content.
  final EdgeInsetsDirectional contentPadding;

  /// Whether the drag handle shows.
  final bool showHandle;

  /// The drag handle's size.
  final Size handleSize;

  /// The drag handle's color.
  final Color handleColor;

  /// The title.
  final TextStyle titleStyle;

  /// Where the title sits.
  final CamoTitleAlign titleAlign;

  /// A ✕ in the header when dismissible.
  final bool showCloseButton;

  /// The ✕'s icon.
  final IconSource closeIcon;

  /// The background.
  final Color containerColor;

  /// The scrim's opacity.
  final double scrimAlpha;

  /// How the sheet shows on wide windows.
  final WidePresentation widePresentation;

  /// Over another overlay: its own scrim or the shared one.
  final StackedScrim stackedScrim;

  /// This style with [o]'s non-null fields applied.
  CamoBottomSheetStyle merge(CamoBottomSheetTheme? o) => o == null
      ? this
      : CamoBottomSheetStyle(
          shape: o.shape ?? shape,
          maxWidth: o.maxWidth ?? maxWidth,
          contentPadding: o.contentPadding ?? contentPadding,
          showHandle: o.showHandle ?? showHandle,
          handleSize: o.handleSize ?? handleSize,
          handleColor: o.handleColor ?? handleColor,
          titleStyle: o.titleStyle ?? titleStyle,
          titleAlign: o.titleAlign ?? titleAlign,
          showCloseButton: o.showCloseButton ?? showCloseButton,
          closeIcon: o.closeIcon ?? closeIcon,
          containerColor: o.containerColor ?? containerColor,
          scrimAlpha: o.scrimAlpha ?? scrimAlpha,
          widePresentation: o.widePresentation ?? widePresentation,
          stackedScrim: o.stackedScrim ?? stackedScrim,
        );
}

/// What a bottom sheet renderer draws: the container, the header (handle, [title], a close button when
/// `showCloseButton` and [dismissible]) and the content. [dragProgress] runs from 0 (resting) to 1 (dragged
/// fully down). A close button calls [onDismissRequest], the same path as back and Esc.
@immutable
class BottomSheetState {
  /// Creates a bottom sheet state.
  const BottomSheetState({
    required this.title,
    required this.dragProgress,
    required this.dismissible,
    required this.onDismissRequest,
    required this.centered,
  });

  /// The title, if any.
  final String? title;

  /// 0 resting, 1 dragged fully down.
  final double dragProgress;

  /// Whether back, Esc, the scrim and a close button may close it.
  final bool dismissible;

  /// Asks to close it.
  final VoidCallback onDismissRequest;

  /// Shown as a centered card on a wide window.
  final bool centered;
}

/// The bottom sheet's content.
@immutable
class BottomSheetSlots {
  /// Creates the slots.
  const BottomSheetSlots({required this.content});

  /// The content, with the bottom system inset already applied. Give it the height that's left (a `Flexible`
  /// in a `Column`), so long content can scroll.
  final Widget content;
}

/// Draws bottom sheets. Core places, drags and dismisses them.
abstract interface class CamoBottomSheetRenderer {
  /// The complete bottom sheet style for [theme].
  CamoBottomSheetStyle defaults(CamoTheme theme);

  /// Draws [state] with [slots].
  Widget render(
    BuildContext context,
    BottomSheetState state,
    BottomSheetSlots slots,
    CamoTheme theme,
    CamoBottomSheetStyle style,
  );
}

class _SheetFrameScope extends InheritedWidget {
  const _SheetFrameScope({
    required this.dragProgress,
    required this.dismissible,
    required this.onDismissRequest,
    required this.centered,
    required super.child,
  });

  final double dragProgress;
  final bool dismissible;
  final VoidCallback onDismissRequest;
  final bool centered;

  @override
  bool updateShouldNotify(_SheetFrameScope old) =>
      old.dragProgress != dragProgress ||
      old.dismissible != dismissible ||
      old.centered != centered;
}

const _dismissFraction = 0.4;
const _dismissVelocity = 1200.0;
const _maxHeightFraction = 0.9;

/// The frame of a bottom sheet (base Overlays §3.1) inside its route: anchored to the bottom (centered and
/// capped at `maxWidth`, or a centered card on wide windows with `WidePresentation.centered`), drag to dismiss,
/// above the keyboard, Esc and the screen-reader dismiss action. All of them, like the route's scrim, call
/// [onDismissRequest]; with [dismissible] `false` they do nothing. Opening it as a route arrives with
/// `showCamoBottomSheet` in M6; in M5 the date and time fields use it.
class CamoSheetFrame extends StatefulWidget {
  /// Creates the frame around [child], usually a `CamoBottomSheet`.
  const CamoSheetFrame({
    super.key,
    required this.onDismissRequest,
    required this.child,
    this.dismissible = true,
    this.dragToDismiss = true,
  });

  /// Asks to close the sheet; the route pops when it agrees.
  final VoidCallback onDismissRequest;

  /// The sheet.
  final Widget child;

  /// `false` ignores every dismissal request.
  final bool dismissible;

  /// `false` turns off dragging down to close.
  final bool dragToDismiss;

  @override
  State<CamoSheetFrame> createState() => _CamoSheetFrameState();
}

class _CamoSheetFrameState extends State<CamoSheetFrame>
    with SingleTickerProviderStateMixin {
  final _sheetKey = GlobalKey();
  late final AnimationController _drag = AnimationController.unbounded(
    vsync: this,
  );

  double get _height => _sheetKey.currentContext?.size?.height ?? 1;

  void _dismiss() {
    if (widget.dismissible) widget.onDismissRequest();
  }

  void _dragEnd(DragEndDetails details) {
    final fast = (details.primaryVelocity ?? 0) > _dismissVelocity;
    if (fast || _drag.value > _height * _dismissFraction) {
      _dismiss();
      if (mounted) {
        _drag.animateTo(0, duration: const Duration(milliseconds: 200));
      }
    } else {
      _drag.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSheetFrame');
    final theme = Camouflage.themeOf(context, component: 'CamoSheetFrame');
    final style = skin.bottomSheet
        .defaults(theme)
        .merge(theme.components.bottomSheet);
    final media = MediaQuery.of(context);
    final centered =
        style.widePresentation == WidePresentation.centered &&
        media.size.width > style.maxWidth + theme.spacing.xxl * 2;
    final canDrag = widget.dragToDismiss && widget.dismissible && !centered;
    final sheet = AnimatedBuilder(
      animation: _drag,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, centered ? 0 : _drag.value),
        child: _SheetFrameScope(
          dragProgress: (_drag.value / _height).clamp(0.0, 1.0),
          dismissible: widget.dismissible,
          onDismissRequest: _dismiss,
          centered: centered,
          child: child!,
        ),
      ),
      child: KeyedSubtree(key: _sheetKey, child: widget.child),
    );
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _dismiss},
      child: FocusScope(
        autofocus: true,
        child: Padding(
          padding: EdgeInsets.only(
            top: media.padding.top,
            bottom: media.viewInsets.bottom,
          ),
          child: Align(
            alignment: centered ? Alignment.center : Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: style.maxWidth,
                maxHeight: media.size.height * _maxHeightFraction,
              ),
              child: GestureDetector(
                onVerticalDragUpdate: canDrag
                    ? (d) => _drag.value = (_drag.value + d.delta.dy).clamp(
                        0.0,
                        double.infinity,
                      )
                    : null,
                onVerticalDragEnd: canDrag ? _dragEnd : null,
                child: sheet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bottom sheet's content: the skin's container, handle, optional [title] and close button around [child].
/// Put it in a [CamoSheetFrame]; it scrolls nothing itself, so give long content its own scroll. Screen readers
/// hear it as a pane named [title], with a dismiss action when it's dismissible.
class CamoBottomSheet extends StatelessWidget {
  /// Creates a sheet around [child].
  const CamoBottomSheet({super.key, this.title, required this.child});

  /// The title, if any.
  final String? title;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoBottomSheet');
    final theme = Camouflage.themeOf(context, component: 'CamoBottomSheet');
    final style = skin.bottomSheet
        .defaults(theme)
        .merge(theme.components.bottomSheet);
    final frame = context
        .dependOnInheritedWidgetOfExactType<_SheetFrameScope>();
    final dismiss = frame?.onDismissRequest ?? () {};
    final dismissible = frame?.dismissible ?? false;
    return Semantics(
      scopesRoute: true,
      namesRoute: title != null,
      explicitChildNodes: true,
      label: title,
      onDismiss: dismissible ? dismiss : null,
      child: skin.bottomSheet.render(
        context,
        BottomSheetState(
          title: title,
          dragProgress: frame?.dragProgress ?? 0,
          dismissible: dismissible,
          onDismissRequest: dismiss,
          centered: frame?.centered ?? false,
        ),
        BottomSheetSlots(
          content: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: child,
          ),
        ),
        theme,
        style,
      ),
    );
  }
}
