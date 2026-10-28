import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'data_display_test_renderers.dart';
import 'input_test_renderers.dart';
import 'overlay_test_renderers.dart';
import 'structure_test_renderers.dart';
import 'text_test_renderers.dart';

// A plain skin for core's own tests: every renderer draws from its style and theme, nothing more.

class Fill implements SurfaceTreatment {
  const Fill();

  @override
  Widget decorate({
    required Widget child,
    required Color color,
    required BorderRadius shape,
    required double elevation,
    required CamoTheme theme,
  }) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: shape),
    child: child,
  );
}

class NoFeedback implements InteractionFeedback {
  const NoFeedback();

  @override
  Widget wrap({
    required Widget child,
    required CamoInteractionController controller,
    required Color contentColor,
    required BorderRadius shape,
    required CamoTheme theme,
  }) => child;
}

class PlainText implements CamoTextRenderer {
  const PlainText();

  @override
  TextStyle linkStyle(CamoTheme theme) =>
      TextStyle(color: theme.colors.primary);

  @override
  Widget render(BuildContext context, TextState s, CamoTheme theme) =>
      Text.rich(
        s.content,
        style: s.style.copyWith(color: s.color),
        maxLines: s.maxLines,
        overflow: s.overflow,
        textAlign: s.textAlign,
      );
}

class PlainIcon implements CamoIconRenderer {
  const PlainIcon();

  @override
  CamoIconStyle defaults(CamoTheme theme) =>
      CamoIconStyle(size: 24, color: theme.colors.onSurface);

  @override
  Widget render(BuildContext context, IconState state, CamoTheme theme) =>
      IconImage(state);
}

class PlainSurface implements CamoSurfaceRenderer {
  const PlainSurface();

  @override
  CamoSurfaceStyle defaults(CamoTheme theme) => CamoSurfaceStyle(
    borderWidth: 1,
    borderColor: theme.colors.outlineVariant,
  );

  @override
  Widget render(
    BuildContext context,
    SurfaceState s,
    SurfaceSlots slots,
    CamoTheme theme,
    CamoSurfaceStyle style,
  ) => ColoredBox(
    color: theme.colors.surfaceOf(s.level),
    child: CamoContentStyle(
      color: theme.colors.onSurface,
      iconStyle: CamoIconStyle(size: 24, color: theme.colors.onSurface),
      child: slots.child,
    ),
  );
}

class PlainDivider implements CamoDividerRenderer {
  const PlainDivider();

  @override
  CamoDividerStyle defaults(CamoTheme theme) => CamoDividerStyle(
    thickness: 1,
    color: theme.colors.outlineVariant,
    startInset: 16,
    endInset: 16,
  );

  @override
  Widget render(
    BuildContext context,
    DividerState s,
    CamoTheme theme,
    CamoDividerStyle style,
  ) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: s.inset == DividerInset.none ? 0 : style.startInset,
      end: s.inset == DividerInset.middle ? style.endInset : 0,
    ),
    child: s.orientation == Axis.horizontal
        ? SizedBox(
            height: style.thickness,
            width: double.infinity,
            child: ColoredBox(color: style.color),
          )
        : SizedBox(
            width: style.thickness,
            height: double.infinity,
            child: ColoredBox(color: style.color),
          ),
  );
}

class PlainButton implements CamoButtonRenderer {
  const PlainButton();

  @override
  CamoButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final solid = ButtonColors(container: c.primary, content: c.onPrimary);
    return CamoButtonStyle(
      defaultAppearance: Appearance.solid,
      height: 40,
      minWidth: 64,
      shape: BorderRadius.zero,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      paddingWithIcon: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      textStyle: theme.typography.labelLarge,
      iconSize: 18,
      iconGap: 8,
      borderWidth: 1,
      raisedElevation: ElevationLevel.level1,
      solidColors: solid,
      softColors: solid,
      raisedColors: solid,
      outlineColors: ButtonColors(
        container: const Color(0x00000000),
        content: c.primary,
        border: c.outline,
      ),
      ghostColors: solid,
      linkColors: solid,
      disabledContainerAlpha: 0.12,
      disabledContentAlpha: 0.38,
    );
  }

  @override
  Widget render(
    BuildContext context,
    ButtonState s,
    ButtonSlots slots,
    CamoTheme theme,
    CamoButtonStyle style,
  ) {
    final colors = style.colorsFor(s.appearance, s.tone, theme);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: style.height,
        minWidth: style.minWidth,
      ),
      child: ColoredBox(
        color: colors.container,
        child: Padding(
          padding: style.padding,
          child: CamoContentStyle(
            color: colors.content,
            iconStyle: CamoIconStyle(
              size: style.iconSize,
              color: colors.content,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?slots.prefixIcon,
                Text(
                  s.text,
                  style: style.textStyle.copyWith(color: colors.content),
                  maxLines: 2,
                ),
                ?slots.suffixIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlainIconButton implements CamoIconButtonRenderer {
  const PlainIconButton();

  @override
  CamoIconButtonStyle defaults(CamoTheme theme) {
    final c = theme.colors;
    final ghost = IconButtonColors(
      container: const Color(0x00000000),
      content: c.onSurfaceVariant,
    );
    final solid = IconButtonColors(container: c.primary, content: c.onPrimary);
    return CamoIconButtonStyle(
      defaultAppearance: Appearance.ghost,
      containerSize: 40,
      shape: BorderRadius.zero,
      iconSize: 24,
      borderWidth: 1,
      solidColors: solid,
      softColors: ghost,
      outlineColors: ghost,
      ghostColors: ghost,
      checkedColors: solid,
      disabledContainerAlpha: 0.12,
      disabledContentAlpha: 0.38,
    );
  }

  @override
  Widget render(
    BuildContext context,
    IconButtonState s,
    IconButtonSlots slots,
    CamoTheme theme,
    CamoIconButtonStyle style,
  ) {
    final colors = style.colorsFor(
      s.appearance,
      s.tone,
      theme,
      checked: s.checked ?? false,
    );
    return SizedBox.square(
      dimension: style.containerSize,
      child: ColoredBox(
        color: colors.container,
        child: Center(
          child: CamoContentStyle(
            color: colors.content,
            iconStyle: CamoIconStyle(
              size: style.iconSize,
              color: colors.content,
            ),
            child: slots.icon,
          ),
        ),
      ),
    );
  }
}

class PlainProgressCircle implements CamoProgressCircleRenderer {
  const PlainProgressCircle();

  @override
  CamoProgressStyle defaults(CamoTheme theme) => CamoProgressStyle(
    circleStroke: 4,
    circleSizeSmall: 24,
    circleSizeMedium: 48,
    circleSizeLarge: 64,
    colors: ProgressColors(
      active: theme.colors.primary,
      track: theme.colors.outlineVariant,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    ProgressState s,
    CamoTheme theme,
    CamoProgressStyle style,
  ) => SizedBox.square(
    dimension: style.circleSizeOf(s.size),
    child: ColoredBox(color: style.colors.active),
  );
}

class PlainTooltip implements CamoTooltipRenderer {
  const PlainTooltip();

  @override
  CamoTooltipStyle defaults(CamoTheme theme) => CamoTooltipStyle(
    shape: BorderRadius.zero,
    padding: const EdgeInsets.all(4),
    offset: 8,
    textStyle: theme.typography.bodySmall,
    showDelay: const Duration(milliseconds: 500),
    hideDelay: const Duration(milliseconds: 1500),
    maxWidth: 200,
    colors: TooltipColors(
      container: theme.colors.inverseSurface,
      text: theme.colors.inverseOnSurface,
    ),
  );

  @override
  Widget render(
    BuildContext context,
    TooltipState s,
    CamoTheme theme,
    CamoTooltipStyle style,
  ) => ColoredBox(
    color: style.colors.container,
    child: Text(
      s.text,
      style: style.textStyle.copyWith(color: style.colors.text),
    ),
  );
}

class Brand extends CamoTokenSet<Brand> {
  const Brand();

  @override
  Brand lerp(Brand to, double t) => this;
}

const skinA = CamoSkin(
  name: 'a',
  surfaceTreatment: Fill(),
  feedback: NoFeedback(),
  text: PlainText(),
  icon: PlainIcon(),
  surface: PlainSurface(),
  divider: PlainDivider(),
  button: PlainButton(),
  iconButton: PlainIconButton(),
  progressCircle: PlainProgressCircle(),
  tooltip: PlainTooltip(),
  checkbox: PlainCheckbox(),
  switchRenderer: PlainSwitch(),
  radio: PlainRadio(),
  segmentedControl: PlainSegmented(),
  slider: PlainSlider(),
  stepper: PlainStepper(),
  textField: PlainTextField(),
  searchField: PlainSearchField(),
  menu: PlainMenu(),
  bottomSheet: PlainBottomSheet(),
  datePicker: PlainDatePicker(),
  timePicker: PlainTimePicker(),
  card: PlainCard(),
  listItem: PlainListItem(),
  accordion: PlainAccordion(),
  skeleton: PlainSkeleton(),
  topBar: PlainTopBar(),
  pagedList: PlainPagedList(),
  dialog: PlainDialog(),
  chip: PlainChip(),
  badge: PlainBadge(),
  avatar: PlainAvatar(),
);
final skinB = skinA.copyWith(name: 'b');
final themeT = CamoTheme(
  colors: CamoColors.fromSeed(primary: const Color(0xFF0B57D0)),
  typography: CamoTypography.system(),
);
final themeU = themeT.copyWith(
  colors: CamoColors.fromSeed(primary: const Color(0xFFB3261E)),
);
