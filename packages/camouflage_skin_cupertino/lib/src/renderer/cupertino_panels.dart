import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_feedback.dart' show feedbackCloseIcon;

// Cupertino's popover and side sheet (base Cupertino Skin §3.2): a blur-material panel, the popover with an arrow.

const double _hairline = 0.5;
const double _arrowInset = 12;

/// Cupertino's popover: a blur-material panel with an arrow, radius 14, the title, the content and the actions.
class CupertinoPopoverRenderer implements CamoPopoverRenderer {
  /// Creates the renderer.
  const CupertinoPopoverRenderer();

  @override
  CamoPopoverStyle defaults(CamoTheme theme) => CamoPopoverStyle(
    shape: theme.shapes.large,
    maxWidth: 360,
    padding: theme.spacing.l,
    showArrow: true,
    arrowSize: const Size(20, 10),
    elevation: ElevationLevel.level3,
    titleStyle: theme.typography.titleMedium,
    gap: theme.spacing.xs,
    colors: PopoverColors(
      container: theme.colors.surfaceContainerHigh,
      title: theme.colors.onSurface,
      content: theme.colors.onSurfaceVariant,
      border: null,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    PopoverState state,
    PopoverSlots slots,
    CamoTheme theme,
    CamoPopoverStyle style,
  ) => paintPopover(context, state, slots, theme, style);
}

/// A popover: the arrow (when the style asks) and the panel with the title, the content and the actions.
Widget paintPopover(
  BuildContext context,
  PopoverState state,
  PopoverSlots slots,
  CamoTheme theme,
  CamoPopoverStyle style,
) {
  final skin = Camouflage.skinOf(context);
  final arrow = style.showArrow ? style.arrowSize.height : 0.0;
  final edges = switch (state.placement) {
    PopoverPlacement.top => EdgeInsets.only(bottom: arrow),
    PopoverPlacement.end => EdgeInsetsDirectional.only(
      start: arrow,
    ).resolve(Directionality.of(context)),
    PopoverPlacement.start => EdgeInsetsDirectional.only(
      end: arrow,
    ).resolve(Directionality.of(context)),
    _ => EdgeInsets.only(top: arrow),
  };
  final c = style.colors;
  final border = c.border;
  final panel = ConstrainedBox(
    constraints: BoxConstraints(maxWidth: style.maxWidth),
    child: skin.surfaceTreatment.decorate(
      color: c.container,
      shape: style.shape,
      elevation: theme.elevation.of(style.elevation),
      theme: theme,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: style.shape,
          border: border == null
              ? null
              : Border.all(color: border, width: _hairline),
        ),
        child: Padding(
          padding: EdgeInsets.all(style.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing.s,
            children: [
              if (slots.title != null)
                Text(
                  slots.title!,
                  style: style.titleStyle.copyWith(color: c.title),
                ),
              slots.child,
              if (slots.actions != null)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: slots.actions,
                ),
            ],
          ),
        ),
      ),
    ),
  );
  if (!style.showArrow) return Padding(padding: edges, child: panel);
  return CustomPaint(
    painter: _ArrowPainter(
      state: state,
      style: style,
      rtl: Directionality.of(context) == TextDirection.rtl,
    ),
    child: Padding(padding: edges, child: panel),
  );
}

// The arrow on the panel's edge that faces the anchor, centered on `arrowOffset` and kept off the corners.
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.state, required this.style, required this.rtl});

  final PopoverState state;
  final CamoPopoverStyle style;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final base = style.arrowSize.width;
    final height = style.arrowSize.height;
    final inset = _arrowInset + base / 2;
    final at = state.arrowOffset;
    final path = Path();
    double clampTo(double v, double max) =>
        max <= 2 * inset ? max / 2 : v.clamp(inset, max - inset);
    switch (state.placement) {
      case PopoverPlacement.top:
        final x = clampTo(at, size.width);
        path
          ..moveTo(x - base / 2, size.height - height)
          ..lineTo(x, size.height)
          ..lineTo(x + base / 2, size.height - height);
      case PopoverPlacement.start || PopoverPlacement.end:
        final y = clampTo(at, size.height);
        final onLeft = (state.placement == PopoverPlacement.end) != rtl;
        final edge = onLeft ? height : size.width - height;
        final tip = onLeft ? 0.0 : size.width;
        path
          ..moveTo(edge, y - base / 2)
          ..lineTo(tip, y)
          ..lineTo(edge, y + base / 2);
      default:
        final x = clampTo(at, size.width);
        path
          ..moveTo(x - base / 2, height)
          ..lineTo(x, 0)
          ..lineTo(x + base / 2, height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = style.colors.container);
    final border = style.colors.border;
    if (border != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = _hairline,
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.state != state || old.style != style || old.rtl != rtl;
}

/// Cupertino's side sheet: a blur-material panel on the end edge with a hairline, rounded start corners when modal.
class CupertinoSideSheetRenderer implements CamoSideSheetRenderer {
  /// Creates the renderer.
  const CupertinoSideSheetRenderer();

  @override
  CamoSideSheetStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSideSheetStyle(
      width: 320,
      // Physical corners: the style's shape type has no directional form (as in the Material skin).
      modalShape: const BorderRadius.horizontal(left: Radius.circular(20)),
      padding: theme.spacing.l,
      titleStyle: theme.typography.titleMedium,
      showDivider: true,
      showCloseButton: true,
      closeIcon: const IconSource.builder(feedbackCloseIcon),
      scrimAlpha: 0.4,
      colors: SideSheetColors(
        container: c.surfaceContainerLow,
        modalContainer: c.surfaceContainerLow,
        title: c.onSurface,
        divider: c.outlineVariant,
      ),
    );
  }

  @override
  Widget render(
    BuildContext context,
    SideSheetState state,
    SideSheetSlots slots,
    CamoTheme theme,
    CamoSideSheetStyle style,
  ) => paintSideSheet(context, state, slots, theme, style);
}

/// A side sheet: the container with its start-edge line, the title row with the close button, content, actions.
Widget paintSideSheet(
  BuildContext context,
  SideSheetState state,
  SideSheetSlots slots,
  CamoTheme theme,
  CamoSideSheetStyle style,
) {
  final skin = Camouflage.skinOf(context);
  final c = style.colors;
  final close = style.showCloseButton && state.onClose != null;
  final shape = state.modal ? style.modalShape : BorderRadius.zero;
  final body = Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (state.title != null || close)
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: style.padding,
            top: style.padding / 2,
            end: style.padding / 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.title ?? '',
                  style: style.titleStyle.copyWith(color: c.title),
                ),
              ),
              if (close)
                CamoIconButton(
                  icon: CamoIcon(style.closeIcon),
                  semanticLabel: 'Close',
                  onPressed: state.onClose,
                ),
            ],
          ),
        ),
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(style.padding),
          child: slots.child,
        ),
      ),
      if (slots.actions != null)
        Padding(
          padding: EdgeInsets.all(style.padding),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: slots.actions,
          ),
        ),
    ],
  );
  final sheet = skin.surfaceTreatment.decorate(
    color: state.modal ? c.modalContainer : c.container,
    shape: shape,
    elevation: theme.elevation.of(ElevationLevel.level2),
    theme: theme,
    child: DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: style.showDivider
            ? BorderDirectional(
                start: BorderSide(color: c.divider, width: _hairline),
              )
            : null,
      ),
      child: ClipRRect(borderRadius: shape, child: body),
    ),
  );
  return state.modal ? sheet : SizedBox(width: style.width, child: sheet);
}
