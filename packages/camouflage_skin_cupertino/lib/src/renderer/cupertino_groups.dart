import 'dart:math' as math;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_pickers.dart' show dropdownChevronIcon;

// Cupertino's button groups, split buttons and toolbars (base Cupertino Skin §3.2): a rounded group with hairline
// dividers and the accent tint for toggles, a pull-down split button, a bar of accent actions on a blur material (a
// floating one is a capsule).

const double _hairline = 0.5;
const double _disabledContainer = 0.12;
const double _disabledContent = 0.38;
const double _dividerAlpha = 0.4;
const _clear = Color(0x00000000);

/// Cupertino's button group: 36 tall, a rounded group with hairline dividers, the accent tint for toggles.
class CupertinoButtonGroupRenderer implements CamoButtonGroupRenderer {
  /// Creates the renderer.
  const CupertinoButtonGroupRenderer();

  @override
  CamoButtonGroupStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    return CamoButtonGroupStyle(
      defaultAppearance: Appearance.soft,
      height: 36,
      shape: theme.shapes.medium,
      innerShape: theme.shapes.none,
      spacing: theme.spacing.xs,
      borderWidth: _hairline,
      iconSize: 16,
      iconGap: theme.spacing.s,
      textStyle: theme.typography.labelLarge,
      colors: GroupColors(
        content: c.onSurface,
        border: c.outlineVariant,
        selectedContainer: c.primary,
        selectedContent: c.onPrimary,
      ),
    );
  }

  @override
  Widget renderContainer(
    BuildContext context,
    ButtonGroupState state,
    CamoTheme theme,
    CamoButtonGroupStyle style,
    List<Widget> buttons,
  ) {
    final border = state.enabled
        ? style.colorsFor(state.tone, theme).border
        : disabled(theme.colors.onSurface, _disabledContainer);
    // Connected outlined buttons share one outline with a line between them.
    final outlined = state.connected && state.appearance == Appearance.outline;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: state.connected ? 0 : style.spacing,
      children: [
        for (final (i, button) in buttons.indexed) ...[
          if (outlined && i > 0)
            SizedBox(
              width: style.borderWidth,
              child: ColoredBox(color: border),
            ),
          button,
        ],
      ],
    );
    if (!outlined) return row;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: style.shape,
        border: Border.all(color: border, width: style.borderWidth),
      ),
      child: ClipRRect(borderRadius: style.shape, child: row),
    );
  }

  @override
  Widget renderButton(
    BuildContext context,
    GroupButtonState state,
    GroupButtonSlots slots,
    CamoTheme theme,
    CamoButtonGroupStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final colors = style.colorsFor(state.tone, theme);
    final onSurface = theme.colors.onSurface;
    final pressed = state.selected ?? false;
    final rest = pressed
        ? colors.selectedContainer
        : switch (state.appearance) {
            Appearance.outline || Appearance.ghost || Appearance.link => _clear,
            _ => theme.colors.surfaceContainerHigh,
          };
    final container = state.enabled || rest.a == 0
        ? rest
        : disabled(onSurface, _disabledContainer);
    final tint = pressed ? colors.selectedContent : colors.content;
    final content = state.enabled
        ? tint
        : disabled(onSurface, _disabledContent);
    final outline =
        !state.connected &&
        !pressed &&
        (state.appearance == Appearance.outline ||
            state.appearance == Appearance.raised);
    final edge = state.enabled
        ? colors.border
        : disabled(onSurface, _disabledContainer);
    final shape = _shape(
      style,
      state.position,
      state.connected,
      Directionality.of(context) == TextDirection.rtl,
    );
    return skin.feedback.wrap(
      controller: state.controller,
      contentColor: content,
      shape: shape,
      theme: theme,
      child: _bordered(
        outline ? edge : null,
        style.borderWidth,
        shape,
        skin.surfaceTreatment.decorate(
          color: container,
          shape: shape,
          elevation: 0,
          theme: theme,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: style.height),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.m),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: CamoContentStyle(
                  color: content,
                  iconStyle: CamoIconStyle(
                    size: style.iconSize,
                    color: content,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: style.iconGap,
                    children: [
                      ?slots.icon,
                      if (slots.text != null)
                        Flexible(
                          child: Text(
                            slots.text!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style.textStyle.copyWith(color: content),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A connected group rounds only its outer corners: the first button's start side, the last button's end side.
BorderRadius _shape(
  CamoButtonGroupStyle style,
  CamoItemPosition position,
  bool connected,
  bool rtl,
) {
  if (!connected || position.count == 1) return style.shape;
  final outer = style.shape;
  final inner = style.innerShape;
  final left = rtl ? position.isLast : position.isFirst;
  final right = rtl ? position.isFirst : position.isLast;
  return BorderRadius.only(
    topLeft: left ? outer.topLeft : inner.topLeft,
    bottomLeft: left ? outer.bottomLeft : inner.bottomLeft,
    topRight: right ? outer.topRight : inner.topRight,
    bottomRight: right ? outer.bottomRight : inner.bottomRight,
  );
}

/// Cupertino's split button: a pull-down, 44 tall, a divider line between the parts.
class CupertinoSplitButtonRenderer implements CamoSplitButtonRenderer {
  /// Creates the renderer.
  const CupertinoSplitButtonRenderer();

  @override
  CamoSplitButtonStyle defaults(CamoTheme theme) => CamoSplitButtonStyle(
    defaultAppearance: Appearance.soft,
    height: 44,
    shape: theme.shapes.medium,
    innerShape: theme.shapes.none,
    arrowWidth: 36,
    gap: 0,
    iconSize: 20,
    iconGap: theme.spacing.s,
    padding: 20,
    textStyle: theme.typography.labelLarge,
    arrowIcon: const IconSource.builder(dropdownChevronIcon),
  );

  @override
  Widget render(
    BuildContext context,
    SplitButtonState state,
    SplitButtonSlots slots,
    SplitButtonBehavior behavior,
    CamoTheme theme,
    CamoSplitButtonStyle style,
  ) {
    final skin = Camouflage.skinOf(context);
    final rest = skin.button
        .defaults(theme)
        .merge(theme.components.button)
        .colorsFor(state.appearance, state.tone, theme);
    final onSurface = theme.colors.onSurface;
    final container = rest.container.a == 0
        ? _clear
        : state.enabled
        ? rest.container
        : disabled(onSurface, _disabledContainer);
    final content = state.enabled
        ? rest.content
        : disabled(onSurface, _disabledContent);
    final border = rest.border == null
        ? null
        : state.enabled
        ? rest.border
        : disabled(onSurface, _disabledContainer);

    Widget part(
      CamoInteractionController controller,
      BorderRadius shape,
      Widget child,
    ) => skin.feedback.wrap(
      controller: controller,
      contentColor: content,
      shape: shape,
      theme: theme,
      child: _bordered(
        border,
        _hairline,
        shape,
        skin.surfaceTreatment.decorate(
          color: container,
          shape: shape,
          elevation: 0,
          theme: theme,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: style.height),
            child: Center(widthFactor: 1, heightFactor: 1, child: child),
          ),
        ),
      ),
    );

    Widget chevron() => Transform.rotate(
      angle: state.expanded ? math.pi : 0,
      child: CamoIcon(style.arrowIcon),
    );

    Widget label({required bool withArrow}) => Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: style.padding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: style.iconGap,
        children: [
          ?slots.prefixIcon,
          Flexible(
            child: Text(
              state.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.textStyle.copyWith(color: content),
            ),
          ),
          if (withArrow) chevron(),
        ],
      ),
    );

    return CamoContentStyle(
      color: content,
      iconStyle: CamoIconStyle(size: style.iconSize, color: content),
      child: state.hasAction
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: style.gap,
              children: [
                behavior.main(
                  part(
                    state.mainController,
                    _half(style, main: true),
                    label(withArrow: false),
                  ),
                ),
                if (style.gap == 0 && border == null)
                  SizedBox(
                    width: _hairline,
                    height: style.height,
                    child: ColoredBox(
                      color: content.withValues(alpha: _dividerAlpha),
                    ),
                  ),
                behavior.arrow(
                  part(
                    state.arrowController,
                    _half(style, main: false),
                    SizedBox(
                      width: style.arrowWidth,
                      child: Center(heightFactor: 1, child: chevron()),
                    ),
                  ),
                ),
              ],
            )
          : behavior.main(
              part(state.mainController, style.shape, label(withArrow: true)),
            ),
    );
  }
}

// The two parts round their outer corners; where they meet they use the inner corners (a plain edge when joined).
BorderRadius _half(CamoSplitButtonStyle style, {required bool main}) {
  final outer = style.shape;
  final inner = style.innerShape;
  return main
      ? BorderRadius.only(
          topLeft: outer.topLeft,
          bottomLeft: outer.bottomLeft,
          topRight: inner.topRight,
          bottomRight: inner.bottomRight,
        )
      : BorderRadius.only(
          topLeft: inner.topLeft,
          bottomLeft: inner.bottomLeft,
          topRight: outer.topRight,
          bottomRight: outer.bottomRight,
        );
}

/// Cupertino's toolbar: a 44 bar of accent actions on a blur material with a hairline, or a floating capsule.
class CupertinoToolbarRenderer implements CamoToolbarRenderer {
  /// Creates the renderer.
  const CupertinoToolbarRenderer();

  @override
  CamoToolbarStyle defaults(CamoTheme theme) => CamoToolbarStyle(
    placement: ToolbarPlacement.docked,
    height: 44,
    actionSize: 44,
    floatingMargin: theme.spacing.l,
    floatingShape: theme.shapes.full,
    floatingElevation: ElevationLevel.level3,
    actionSpacing: theme.spacing.xxs,
    padding: theme.spacing.s,
    showDivider: true,
    overflowIcon: const IconSource.builder(moreIcon),
    colors: ToolbarColors(
      container: theme.colors.surfaceContainerLow,
      divider: theme.colors.outlineVariant,
    ),
  );

  @override
  Widget renderContainer(
    BuildContext context,
    ToolbarState state,
    CamoTheme theme,
    CamoToolbarStyle style,
    Widget child,
  ) {
    final skin = Camouflage.skinOf(context);
    final floating = state.placement == ToolbarPlacement.floating;
    final shape = floating ? style.floatingShape : BorderRadius.zero;
    Widget bar = ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.height),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: style.padding),
        child: Center(heightFactor: 1, child: child),
      ),
    );
    bar = skin.surfaceTreatment.decorate(
      color: style.colors.container,
      shape: shape,
      elevation: theme.elevation.of(
        floating ? style.floatingElevation : ElevationLevel.level2,
      ),
      theme: theme,
      child: bar,
    );
    if (!floating && style.showDivider) {
      bar = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: style.colors.divider, width: _hairline),
          ),
        ),
        child: bar,
      );
    }
    return floating
        ? Padding(padding: EdgeInsets.all(style.floatingMargin), child: bar)
        : bar;
  }
}

/// The overflow icon: three dots, one above the other.
Widget moreIcon(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _DotsPainter(color ?? const Color(0xFF000000)),
);

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = size.width * 0.09;
    for (final y in const [0.22, 0.5, 0.78]) {
      canvas.drawCircle(Offset(size.width / 2, size.height * y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

Widget _bordered(
  Color? border,
  double width,
  BorderRadius shape,
  Widget child,
) => border == null
    ? child
    : DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(color: border, width: width),
        ),
        child: child,
      );
