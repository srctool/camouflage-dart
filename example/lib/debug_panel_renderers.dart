import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M9 popover and side sheet in the debug skin: boxes, rows and plain text.

/// The debug skin's DebugPopover renderer.
class DebugPopover implements CamoPopoverRenderer {
  /// Creates the renderer.
  const DebugPopover();

  @override
  CamoPopoverStyle defaults(CamoTheme theme) => CamoPopoverStyle(
    shape: BorderRadius.zero,
    maxWidth: 320,
    padding: 16,
    showArrow: false,
    arrowSize: const Size(16, 8),
    elevation: ElevationLevel.level2,
    titleStyle: theme.typography.titleSmall,
    gap: 4,
    colors: PopoverColors(
      container: theme.colors.surface,
      title: theme.colors.onSurface,
      content: theme.colors.onSurfaceVariant,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    PopoverState state,
    PopoverSlots slots,
    CamoTheme theme,
    CamoPopoverStyle style,
  ) {
    return ColoredBox(
      color: style.colors.container,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (slots.title != null) Text(slots.title!),
          slots.child,
          ?slots.actions,
        ],
      ),
    );
  }
}

/// The debug skin's DebugSideSheet renderer.
class DebugSideSheet implements CamoSideSheetRenderer {
  /// Creates the renderer.
  const DebugSideSheet();

  @override
  CamoSideSheetStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoSideSheetStyle(
      width: 320,
      modalShape: BorderRadius.zero,
      padding: 16,
      titleStyle: theme.typography.titleLarge,
      showDivider: true,
      showCloseButton: true,
      closeIcon: const IconSource.builder(_icon),
      scrimAlpha: 0.32,
      colors: SideSheetColors(
        container: c.surface,
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
  ) {
    final body = ColoredBox(
      color: style.colors.container,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.title != null) Text(state.title!),
          if (state.onClose != null)
            GestureDetector(onTap: state.onClose, child: const Text('close')),
          Expanded(child: slots.child),
          ?slots.actions,
        ],
      ),
    );
    return state.modal ? body : SizedBox(width: style.width, child: body);
  }
}

Widget _icon(double size, Color? color) => SizedBox.square(dimension: size);
