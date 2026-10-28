import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../fluent_tokens.dart';
import 'fluent_pickers.dart' show menuCheckIcon;

// Fluent's data display components (base Fluent Skin §3): Tag / InteractionTag chips, CounterBadge badges and
// brand-tinted Avatars.

const _disabled = 0.38;
const _personIconScale = 0.6;

/// Fluent's chips (Tag): 32 tall, radius 4, filled by default; a selected filter is brand.
class FluentChipRenderer implements CamoChipRenderer {
  /// Creates the renderer.
  const FluentChipRenderer();

  @override
  CamoChipStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final s = theme.spacing;
    final stroke = theme.tokens<FluentTokens>()?.neutralStroke1 ?? c.outline;
    return CamoChipStyle(
      defaultAppearance: Appearance.soft,
      height: 32,
      shape: theme.shapes.small,
      padding: EdgeInsetsDirectional.symmetric(horizontal: s.s),
      iconPadding: EdgeInsetsDirectional.symmetric(horizontal: s.xs + s.xxs),
      iconGap: s.xs,
      textStyle: theme.typography.bodyMedium,
      iconSize: 20,
      borderWidth: 1,
      showCheckWhenSelected: false,
      outlineColors: ChipColors(
        container: c.surface,
        content: c.onSurface,
        border: stroke,
      ),
      softColors: ChipColors(
        container: c.surfaceContainer,
        content: c.onSurface,
      ),
      solidColors: ChipColors(container: c.primary, content: c.onPrimary),
      selectedColors: ChipColors(container: c.primary, content: c.onPrimary),
      groupSpacing: s.s,
      checkIcon: const IconSource.builder(menuCheckIcon),
      removeIcon: const IconSource.builder(_removeIcon),
    );
  }

  @override
  Widget render(
    BuildContext context,
    ChipState state,
    ChipSlots slots,
    CamoTheme theme,
    CamoChipStyle style,
  ) => paintChip(context, state, slots, theme, style);
}

/// A chip: the surface treatment and border, the check or leading icon, the label and the remove button.
Widget paintChip(
  BuildContext context,
  ChipState state,
  ChipSlots slots,
  CamoTheme theme,
  CamoChipStyle style,
) {
  final skin = Camouflage.skinOf(context);
  final colors = style.colorsFor(state, theme);
  final showCheck = state.selected == true && style.showCheckWhenSelected;
  final start = showCheck || slots.leading != null
      ? style.iconPadding
      : style.padding;
  final end = slots.remove != null ? style.iconPadding : style.padding;
  final remove = slots.remove;
  final leading = showCheck ? CamoIcon(style.checkIcon) : slots.leading;
  Widget chip = skin.surfaceTreatment.decorate(
    color: colors.container,
    shape: style.shape,
    elevation: 0,
    theme: theme,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.height),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: start.start, end: end.end),
        child: CamoContentStyle(
          color: colors.content,
          iconStyle: CamoIconStyle(size: style.iconSize, color: colors.content),
          child: _BoundedWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: style.iconGap,
              children: [
                ?leading,
                Flexible(
                  child: Text(
                    state.label,
                    style: style.textStyle.copyWith(color: colors.content),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?remove,
              ],
            ),
          ),
        ),
      ),
    ),
  );
  final border = colors.border;
  if (border != null) {
    chip = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: style.shape,
        border: Border.all(color: border, width: style.borderWidth),
      ),
      child: chip,
    );
  }
  if (state.kind != ChipKind.tag) {
    chip = skin.feedback.wrap(
      controller: state.controller,
      contentColor: colors.content,
      shape: style.shape,
      theme: theme,
      child: chip,
    );
  }
  return state.enabled ? chip : Opacity(opacity: _disabled, child: chip);
}

/// Fluent's badges (CounterBadge, small): a 6 dot or a 16 pill, danger by default.
class FluentBadgeRenderer implements CamoBadgeRenderer {
  /// Creates the renderer.
  const FluentBadgeRenderer();

  @override
  CamoBadgeStyle defaults(CamoTheme theme) => CamoBadgeStyle(
    defaultAppearance: Appearance.solid,
    defaultTone: Tone.error,
    dotSize: 6,
    height: 16,
    minWidth: 16,
    padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.xs),
    textStyle: theme.typography.labelSmall,
    offset: Offset(-theme.spacing.xs, theme.spacing.xs),
    borderWidth: 1,
  );

  @override
  Widget render(
    BuildContext context,
    BadgeState state,
    CamoTheme theme,
    CamoBadgeStyle style,
  ) => paintBadge(state, theme, style);
}

/// A badge: a dot, or a pill with the count; the outline appearance adds a border.
Widget paintBadge(BadgeState state, CamoTheme theme, CamoBadgeStyle style) {
  final colors = style.colorsFor(state.appearance, state.tone, theme);
  final border = colors.border;
  final decoration = BoxDecoration(
    color: colors.container,
    borderRadius: theme.shapes.full,
    border: border == null
        ? null
        : Border.all(color: border, width: style.borderWidth),
  );
  final text = state.text;
  if (text == null) {
    return SizedBox.square(
      dimension: style.dotSize,
      child: DecoratedBox(decoration: decoration),
    );
  }
  return ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: style.minWidth,
      minHeight: style.height,
    ),
    child: DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: style.padding,
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            text,
            style: style.textStyle.copyWith(color: colors.content),
            maxLines: 1,
          ),
        ),
      ),
    ),
  );
}

/// Fluent's avatars: brand-tinted initials in circles, 24 / 32 / 48.
class FluentAvatarRenderer implements CamoAvatarRenderer {
  /// Creates the renderer.
  const FluentAvatarRenderer();

  @override
  CamoAvatarStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final t = theme.typography;
    final neutral = AvatarColors(
      container: c.surfaceContainerHigh,
      content: c.onSurfaceVariant,
    );
    return CamoAvatarStyle(
      shape: AvatarShape.circle,
      roundedShape: theme.shapes.small,
      sizeSmall: 24,
      sizeMedium: 32,
      sizeLarge: 48,
      textStyleSmall: t.labelSmall,
      textStyleMedium: t.labelLarge,
      textStyleLarge: t.titleMedium,
      // Fluent's brand Avatar color: initials on the brand tint.
      initialsPalette: [
        AvatarColors(
          container: c.primaryContainer,
          content: c.onPrimaryContainer,
        ),
      ],
      neutralColors: neutral,
      presenceSize: 10,
      presenceColors: PresenceColors(
        online: c.success,
        away: c.warning,
        busy: c.error,
        offline: c.outline,
        ring: c.surface,
      ),
      ringWidth: 2,
      groupOverlap: 8,
      personIcon: const IconSource.builder(_personIcon),
    );
  }

  @override
  Widget render(
    BuildContext context,
    AvatarState state,
    AvatarSlots slots,
    CamoTheme theme,
    CamoAvatarStyle style,
  ) => paintAvatar(state, slots, theme, style);
}

/// An avatar: initials (or the person icon) under the app's image, clipped; the presence dot outside the clip.
Widget paintAvatar(
  AvatarState state,
  AvatarSlots slots,
  CamoTheme theme,
  CamoAvatarStyle style,
) {
  final colors = style.colorsFor(state);
  final diameter = style.sizeOf(state.size);
  final initials = state.initials;
  final image = slots.image;
  final presence = state.presence;
  return SizedBox.square(
    dimension: diameter,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: style.shapeOf(state.shape, theme),
            child: ColoredBox(
              color: colors.container,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: initials != null
                        ? Text(
                            initials,
                            style: style
                                .textStyleOf(state.size)
                                .copyWith(color: colors.content),
                            maxLines: 1,
                          )
                        : CamoIcon(
                            style.personIcon,
                            size: diameter * _personIconScale,
                            color: colors.content,
                          ),
                  ),
                  ?image,
                ],
              ),
            ),
          ),
        ),
        if (presence != null)
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: style.presenceSize,
              height: style.presenceSize,
              padding: EdgeInsets.all(style.ringWidth),
              decoration: BoxDecoration(
                color: style.presenceColors.ring,
                shape: BoxShape.circle,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.presenceColors.of(presence),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// In a horizontally scrolling row a chip gets an unbounded width, where its flexible label can't lay out: give it a
// finite one there (the label's ellipsis still works in bounded rows).
class _BoundedWidth extends SingleChildRenderObjectWidget {
  const _BoundedWidth({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBoundedWidth();
}

class _RenderBoundedWidth extends RenderProxyBox {
  static const _cap = 100000.0;

  BoxConstraints _bound(BoxConstraints c) =>
      c.hasBoundedWidth ? c : c.copyWith(maxWidth: _cap);

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(_bound(constraints), parentUsesSize: true);
    size = constraints.constrain(child.size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(child!.getDryLayout(_bound(constraints)));
}

Widget _glyph(double size, Color? color, void Function(Path p) draw) =>
    CustomPaint(
      size: Size.square(size),
      painter: _StrokePainter(color ?? const Color(0xFF000000), draw),
    );

Widget _removeIcon(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..moveTo(6, 6)
    ..lineTo(18, 18)
    ..moveTo(18, 6)
    ..lineTo(6, 18);
});

Widget _personIcon(double size, Color? color) => _glyph(size, color, (p) {
  p
    ..addOval(Rect.fromCircle(center: const Offset(12, 8), radius: 4))
    ..moveTo(4.5, 20.5)
    ..cubicTo(5.5, 16.5, 8.5, 14.5, 12, 14.5)
    ..cubicTo(15.5, 14.5, 18.5, 16.5, 19.5, 20.5);
});

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.color, this.draw);

  final Color color;
  final void Function(Path p) draw;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path();
    draw(path);
    canvas
      ..scale(s)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.color != color;
}
