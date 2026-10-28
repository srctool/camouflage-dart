import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The components in their states, for screenshot goldens of any skin. Static: no animation, no input.

/// A small star-shaped test icon.
const IconSource galleryIcon = IconSource.builder(_star);

Widget _star(double size, Color? color) => CustomPaint(
  size: Size.square(size),
  painter: _StarPainter(color ?? const Color(0xFF000000)),
);

class _StarPainter extends CustomPainter {
  _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final points = [
      (12, 2),
      (15, 9),
      (22, 9),
      (16.5, 14),
      (18.5, 21),
      (12, 17),
      (5.5, 21),
      (7.5, 14),
      (2, 9),
      (9, 9),
    ];
    final path = Path()..moveTo(points.first.$1 * s, points.first.$2 * s);
    for (final p in points.skip(1)) {
      path.lineTo(p.$1 * s, p.$2 * s);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

/// Every button appearance, enabled and disabled, in the default and the error tone, plus icons and loading.
class ButtonGallery extends StatelessWidget {
  /// Creates the gallery.
  const ButtonGallery({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (final tone in [Tone.defaultTone, Tone.error])
          for (final enabled in [true, false])
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                for (final a in Appearance.values)
                  CamoButton(
                    text: a.name,
                    onPressed: enabled ? () {} : null,
                    appearance: a,
                    tone: tone,
                  ),
              ],
            ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            CamoButton(
              text: 'Save',
              onPressed: () {},
              prefixIcon: const CamoIcon(galleryIcon),
            ),
            CamoButton(
              text: 'Next',
              onPressed: () {},
              appearance: Appearance.outline,
              suffixIcon: const CamoIcon(galleryIcon),
            ),
            CamoButton(
              text: 'Done',
              onPressed: () {},
              tone: Tone.success,
              appearance: Appearance.soft,
            ),
          ],
        ),
      ],
    ),
  );
}

/// Every icon button appearance, a checked toggle, a disabled one and a tone.
class IconButtonGallery extends StatelessWidget {
  /// Creates the gallery.
  const IconButtonGallery({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        for (final a in [
          Appearance.solid,
          Appearance.soft,
          Appearance.outline,
          Appearance.ghost,
        ])
          CamoIconButton(
            icon: const CamoIcon(galleryIcon),
            semanticLabel: a.name,
            onPressed: () {},
            appearance: a,
          ),
        CamoIconButton(
          icon: const CamoIcon(galleryIcon),
          semanticLabel: 'Checked',
          onPressed: () {},
          checked: true,
        ),
        const CamoIconButton(
          icon: CamoIcon(galleryIcon),
          semanticLabel: 'Disabled',
          onPressed: null,
        ),
        CamoIconButton(
          icon: const CamoIcon(galleryIcon),
          semanticLabel: 'Delete',
          onPressed: () {},
          tone: Tone.error,
        ),
      ],
    ),
  );
}

/// Text styles and links, the surface levels, dividers, progress circles and a tooltip bubble.
class PrimitiveGallery extends StatelessWidget {
  /// Creates the gallery.
  const PrimitiveGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final type = theme.typography;
    final tooltip = Camouflage.skinOf(context).tooltip;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 388,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            CamoText('Headline', style: type.headlineSmall),
            CamoText('Title', style: type.titleMedium),
            CamoText.rich([
              const CamoSpan('Body with a '),
              CamoSpan('link', onTap: () {}),
              const CamoSpan('.'),
            ]),
            CamoText('Success', color: theme.colors.success),
            Row(
              spacing: 8,
              children: [
                for (final level in SurfaceLevel.values)
                  CamoSurface(
                    level: level,
                    shape: ShapeRole.medium,
                    border: true,
                    child: const SizedBox.square(dimension: 40),
                  ),
                const CamoSurface(
                  shape: ShapeRole.medium,
                  elevation: ElevationLevel.level3,
                  child: SizedBox.square(dimension: 40),
                ),
              ],
            ),
            const CamoDivider(),
            const CamoDivider(inset: DividerInset.middle),
            const IntrinsicHeight(
              child: Row(
                spacing: 8,
                children: [
                  CamoIcon(galleryIcon),
                  CamoDivider(orientation: Axis.vertical),
                  CamoProgressCircle(value: 0.3, size: ProgressSize.small),
                  CamoProgressCircle(value: 0.6),
                  CamoProgressCircle(
                    value: 0.9,
                    tone: Tone.error,
                    size: ProgressSize.large,
                  ),
                ],
              ),
            ),
            tooltip.render(
              context,
              const TooltipState(text: 'Tooltip', visible: true),
              theme,
              tooltip.defaults(theme).merge(theme.components.tooltip),
            ),
          ],
        ),
      ),
    );
  }
}

/// The M5 selection controls, slider and stepper in their states: checked, unchecked, disabled, with a
/// description and with an error.
class InputGallery extends StatelessWidget {
  /// Creates the gallery.
  const InputGallery({super.key});

  @override
  Widget build(BuildContext context) {
    void ignore(Object? _) {}
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              CamoCheckbox(checked: false, onChanged: ignore),
              CamoCheckbox(checked: true, onChanged: ignore),
              CamoCheckbox(checked: true, onChanged: ignore, enabled: false),
              CamoCheckbox(
                checked: true,
                onChanged: ignore,
                label: 'Remember me',
              ),
            ],
          ),
          CamoCheckbox(
            checked: false,
            onChanged: ignore,
            label: 'I agree',
            description: 'Required to continue',
            error: 'Please accept',
          ),
          SizedBox(
            width: 280,
            child: CamoSwitch(
              checked: true,
              onChanged: ignore,
              label: 'Wi-Fi',
              description: 'Uses more battery',
            ),
          ),
          SizedBox(
            width: 280,
            child: CamoSwitch(
              checked: false,
              onChanged: ignore,
              label: 'Bluetooth',
            ),
          ),
          SizedBox(
            width: 280,
            child: CamoSwitch(
              checked: true,
              onChanged: ignore,
              label: 'Airplane mode',
              enabled: false,
            ),
          ),
          CamoRadioGroup<String>(
            value: 'standard',
            onChanged: ignore,
            label: 'Shipping',
            options: const [
              RadioOption('standard', 'Standard', description: '3 to 5 days'),
              RadioOption('express', 'Express'),
              RadioOption('pickup', 'Pick up', enabled: false),
            ],
          ),
          CamoSegmentedControl<String>(
            options: const [
              Segment('d', label: 'Day'),
              Segment('w', label: 'Week'),
              Segment('m', label: 'Month'),
            ],
            selected: 'w',
            onChanged: ignore,
          ),
          SizedBox(
            width: 280,
            child: CamoSlider(
              value: 0.3,
              onChanged: ignore,
              semanticLabel: 'Volume',
            ),
          ),
          SizedBox(
            width: 280,
            child: CamoSlider(
              value: 0.5,
              onChanged: ignore,
              divisions: 4,
              semanticLabel: 'Rating',
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              CamoStepper(
                value: 2,
                onChanged: ignore,
                max: 9,
                semanticLabel: 'Quantity',
              ),
              CamoStepper(
                value: 0,
                onChanged: ignore,
                max: 9,
                semanticLabel: 'Guests',
                error: 'Add a guest',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The M5 text inputs in their states: empty with a placeholder, filled with an icon and prefix text, with an
/// action, an error, disabled, a floating label, a custom input in [CamoFieldFrame], and search fields.
class TextInputGallery extends StatelessWidget {
  /// Creates the gallery.
  const TextInputGallery({super.key});

  @override
  Widget build(BuildContext context) {
    void ignore(Object? _) {}
    final theme = Camouflage.themeOf(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            CamoTextField(
              value: '',
              onChanged: ignore,
              label: 'Email',
              placeholder: 'you@example.com',
              supportingText: 'We never share it',
            ),
            CamoTextField(
              value: '0812345',
              onChanged: ignore,
              label: 'Phone',
              prefixIcon: const CamoIcon(galleryIcon),
              prefixText: '+62',
            ),
            CamoTextField(
              value: 'ab',
              onChanged: ignore,
              label: 'Password',
              secure: true,
              error: 'Use at least 8 characters',
              suffixIcon: CamoFieldAction(
                icon: const CamoIcon(galleryIcon),
                semanticLabel: 'Show password',
                onPressed: () {},
              ),
            ),
            CamoTextField(
              value: 'Locked',
              onChanged: ignore,
              label: 'Company',
              enabled: false,
            ),
            CamouflageProvider(
              theme: theme.copyWith(
                components: theme.components.copyWith(
                  textField: const CamoTextFieldTheme(
                    labelPlacement: LabelPlacement.floating,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  CamoTextField(
                    value: '',
                    onChanged: ignore,
                    label: 'Floating, resting',
                  ),
                  CamoTextField(
                    value: 'Ann',
                    onChanged: ignore,
                    label: 'Floating, floated',
                    suffixText: 'kg',
                  ),
                ],
              ),
            ),
            const CamoFieldFrame(
              focused: false,
              isEmpty: false,
              label: 'Code',
              child: Row(
                spacing: 8,
                children: [
                  CamoText('•'),
                  CamoText('•'),
                  CamoText('•'),
                  CamoText('•'),
                ],
              ),
            ),
            CamoSearchField(query: '', onChanged: ignore, onSubmitted: ignore),
            CamoSearchField(
              query: 'tea',
              onChanged: ignore,
              onSubmitted: ignore,
              placeholder: 'Search drinks',
            ),
          ],
        ),
      ),
    );
  }
}

/// The M5 pickers and overlay looks, inline: a calendar with a selected day and one with a range, the time input in
/// its three forms, closed date and time fields, a bottom sheet's content and a popup panel. The month is fixed in
/// the past, so today never shows and the goldens stay put.
class PickerGallery extends StatelessWidget {
  /// Creates the gallery.
  const PickerGallery({super.key});

  @override
  Widget build(BuildContext context) {
    void ignore(Object? _) {}
    final theme = Camouflage.themeOf(context);
    final month = const CamoYearMonth(2024, 3);
    Widget withTime(TimePickerForm form, Widget child) => CamouflageProvider(
      theme: theme.copyWith(
        components: theme.components.copyWith(
          timePicker: CamoTimePickerTheme(form: form),
        ),
      ),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            CamoCalendar(
              selection: SingleDate(DateTime(2024, 3, 14)),
              onSelectionChanged: ignore,
              visibleMonth: month,
              onVisibleMonthChanged: ignore,
              firstDate: DateTime(2024, 3, 4),
            ),
            CamoCalendar(
              selection: DateRangeSelection(
                DateTime(2024, 3, 11),
                DateTime(2024, 3, 15),
              ),
              onSelectionChanged: ignore,
              visibleMonth: month,
              onVisibleMonthChanged: ignore,
            ),
            CamoTimeInput(
              value: const CamoTime(hour: 14, minute: 30),
              onChanged: ignore,
              use24Hour: true,
            ),
            CamoTimeInput(
              value: const CamoTime(hour: 9, minute: 5),
              onChanged: ignore,
              use24Hour: false,
            ),
            withTime(
              TimePickerForm.dial,
              CamoTimeInput(
                value: const CamoTime(hour: 14, minute: 30),
                onChanged: ignore,
                use24Hour: true,
              ),
            ),
            withTime(
              TimePickerForm.wheel,
              CamoTimeInput(
                value: const CamoTime(hour: 9, minute: 15),
                onChanged: ignore,
                minuteStep: 15,
                use24Hour: false,
              ),
            ),
            SizedBox(
              width: 360,
              child: CamoDateField(
                value: DateTime(2024, 3, 14),
                onChanged: ignore,
                label: 'Birth date',
              ),
            ),
            SizedBox(
              width: 360,
              child: CamoTimeField(
                value: null,
                onChanged: ignore,
                label: 'Pickup',
                placeholder: 'Choose a time',
              ),
            ),
            const SizedBox(
              width: 360,
              child: CamoBottomSheet(
                title: 'Filters',
                child: CamoText('Sheet content'),
              ),
            ),
            const CamoMenuPanel(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CamoText('Popup content'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The M6 structure components: a resting and a scrolled top bar, cards in every appearance (a status panel and
/// a selected card too), a list section, an accordion group with one section open, skeletons, and a paged list's
/// empty state and next-page retry row. Skeletons are captured at the start of their cycle.
class StructureGallery extends StatelessWidget {
  /// Creates the gallery.
  const StructureGallery({super.key});

  @override
  Widget build(BuildContext context) {
    void ignore(Object? _) {}
    const icon = CamoIcon(galleryIcon);
    Widget card(String text, {Appearance? a, Tone tone = Tone.defaultTone}) =>
        Expanded(
          child: CamoCard(
            appearance: a,
            tone: tone,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CamoText(text),
            ),
          ),
        );
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          CamoTopBar(
            title: 'Settings',
            insets: EdgeInsets.zero,
            navigation: CamoIconButton(
              icon: icon,
              semanticLabel: 'Back',
              onPressed: () {},
            ),
            actions: [
              CamoIconButton(
                icon: icon,
                semanticLabel: 'Search',
                onPressed: () {},
              ),
            ],
          ),
          const CamoTopBar(
            title: 'Inbox',
            scrollOffset: 8,
            insets: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 12,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    for (final a in [
                      Appearance.solid,
                      Appearance.soft,
                      Appearance.raised,
                      Appearance.outline,
                    ])
                      card(a.name, a: a),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    card('Low stock', a: Appearance.soft, tone: Tone.warning),
                    card('Payment failed', tone: Tone.error),
                    Expanded(
                      child: CamoCard(
                        onPressed: () {},
                        selected: true,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: CamoText('Pro plan'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CamoListSection(
            title: 'Network',
            footer: 'Changes apply right away.',
            children: [
              CamoListItem(
                headline: 'Wi-Fi',
                leading: icon,
                trailing: const CamoSwitch(checked: true, onChanged: null),
                onPressed: () {},
              ),
              CamoListItem(
                headline: 'Bluetooth',
                supporting: '2 devices',
                leading: icon,
                onPressed: () {},
              ),
              CamoListItem(
                headline: 'VPN',
                overline: 'Work',
                supporting: 'Connected since 09:00',
                leading: icon,
                selected: true,
                onPressed: () {},
              ),
            ],
          ),
          CamoAccordionGroup<String>(
            expanded: const {'ship'},
            onExpandedChanged: ignore,
            items: const [
              CamoAccordionItem(
                key: 'ship',
                title: 'Shipping',
                subtitle: '2 to 4 days',
                child: CamoText('Free over 50.'),
              ),
              CamoAccordionItem(
                key: 'returns',
                title: 'Returns',
                child: CamoText('30 days.'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    CamoSkeleton.circle(size: 40),
                    Expanded(child: CamoSkeleton.text(lines: 2)),
                  ],
                ),
                CamoSkeleton(height: 80),
              ],
            ),
          ),
          const CamoSkeleton.listItem(),
          SizedBox(
            height: 140,
            child: CamoPagedList<String>(
              state: const CamoPagedListState(),
              itemKey: (it) => it,
              onLoadMore: () {},
              onRetry: () {},
              itemBuilder: (context, value, _) => CamoListItem(headline: value),
            ),
          ),
          SizedBox(
            height: 200,
            child: CamoPagedList<String>(
              state: const CamoPagedListState(
                items: ['Order 1041', 'Order 1042'],
                error: PagedError(
                  message: "Couldn't load more",
                  scope: PagedErrorScope.nextPage,
                ),
              ),
              itemKey: (it) => it,
              onLoadMore: () {},
              onRetry: () {},
              itemBuilder: (context, value, _) => CamoListItem(headline: value),
            ),
          ),
        ],
      ),
    );
  }
}

/// The M6 dialog content, inline (no route): a confirmation with a title, a message-only notice, actions
/// stacked and in a full-width row, and a centered title with custom content.
class DialogGallery extends StatelessWidget {
  /// Creates the gallery.
  const DialogGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    Widget themed(CamoDialogTheme dialog, Widget child) => CamouflageProvider(
      theme: theme.copyWith(
        components: theme.components.copyWith(dialog: dialog),
      ),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            CamoDialog(
              title: 'Delete item?',
              message: "This can't be undone.",
              confirm: CamoButton(
                text: 'Delete',
                onPressed: () {},
                tone: Tone.error,
              ),
              dismiss: CamoButton(
                text: 'Cancel',
                onPressed: () {},
                appearance: Appearance.ghost,
              ),
            ),
            CamoDialog(
              message: 'Your changes were saved.',
              confirm: CamoButton(text: 'OK', onPressed: () {}),
            ),
            themed(
              const CamoDialogTheme(actionsLayout: DialogActionsLayout.stacked),
              CamoDialog(
                title: 'Stay updated',
                message: 'Turn on notifications to hear about your orders.',
                confirm: CamoButton(text: 'Allow', onPressed: () {}),
                dismiss: CamoButton(
                  text: 'Not now',
                  onPressed: () {},
                  appearance: Appearance.ghost,
                ),
              ),
            ),
            themed(
              const CamoDialogTheme(
                titleAlign: CamoTitleAlign.center,
                actionsLayout: DialogActionsLayout.fullWidthRow,
              ),
              CamoDialog(
                title: 'Sort by',
                message: 'Choose how items are ordered.',
                confirm: CamoButton(text: 'Apply', onPressed: () {}),
                dismiss: CamoButton(
                  text: 'Cancel',
                  onPressed: () {},
                  appearance: Appearance.outline,
                ),
                content: CamoRadioGroup<String>(
                  value: 'newest',
                  onChanged: (_) {},
                  options: const [
                    RadioOption('newest', 'Newest'),
                    RadioOption('price', 'Price'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The M6 menu, open: icons, a shortcut, a disabled item, a checkable item, a destructive item and dividers;
/// above it, a closed select showing its value and the dropdown chevron. The menu is a route, so the gallery
/// brings its own navigator and opens it after the first frame.
class MenuGallery extends StatelessWidget {
  /// Creates the gallery.
  const MenuGallery({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 352,
    height: 440,
    child: Navigator(
      onGenerateRoute: (_) =>
          PageRouteBuilder<void>(pageBuilder: (_, _, _) => const _MenuScene()),
    ),
  );
}

class _MenuScene extends StatefulWidget {
  const _MenuScene();

  @override
  State<_MenuScene> createState() => _MenuSceneState();
}

class _MenuSceneState extends State<_MenuScene> {
  final _menu = CamoMenuController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _menu.open());
  }

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        CamoSelect<String>(
          value: 'newest',
          onChanged: (_) {},
          options: const [
            SelectOption('newest', 'Newest'),
            SelectOption('price', 'Price'),
          ],
          label: 'Sort by',
        ),
        CamoMenuAnchor(
          controller: _menu,
          items: [
            CamoMenuItem(
              text: 'Share',
              onPressed: () {},
              leadingIcon: const CamoIcon(galleryIcon),
            ),
            CamoMenuItem(
              text: 'Edit',
              onPressed: () {},
              leadingIcon: const CamoIcon(galleryIcon),
              trailingText: 'Ctrl+E',
            ),
            CamoMenuItem(text: 'Archive', onPressed: () {}, enabled: false),
            const CamoMenuDivider(),
            CamoMenuItem(
              text: 'Show hidden files',
              onPressed: () {},
              checked: true,
            ),
            const CamoMenuDivider(),
            CamoMenuItem(text: 'Delete', onPressed: () {}, tone: Tone.error),
          ],
          builder: (context, open) => CamoButton(
            text: 'More',
            onPressed: open,
            appearance: Appearance.outline,
          ),
        ),
      ],
    ),
  );
}

/// The M7 data display components: tags in each appearance and tone, filter, input and action chips, a
/// single-choice group, badges (dot, count, "99+", tones) on icons, and avatars in each size, shape and
/// presence, plus a group.
class DataDisplayGallery extends StatelessWidget {
  /// Creates the gallery.
  const DataDisplayGallery({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> children, {double spacing = 8}) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: children,
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          row(const [
            CamoChip(label: 'Outline', appearance: Appearance.outline),
            CamoChip(label: 'Soft', appearance: Appearance.soft),
            CamoChip(label: 'Solid', appearance: Appearance.solid),
            CamoChip(
              label: 'Paid',
              appearance: Appearance.soft,
              tone: Tone.success,
            ),
            CamoChip(
              label: 'Overdue',
              appearance: Appearance.outline,
              tone: Tone.error,
            ),
          ]),
          row([
            CamoChip(label: 'Open', onPressed: () {}, selected: false),
            CamoChip(label: 'Open now', onPressed: () {}, selected: true),
            CamoChip(
              label: 'Starred',
              onPressed: () {},
              selected: false,
              leading: const CamoIcon(galleryIcon),
            ),
            CamoChip(
              label: 'Off',
              onPressed: () {},
              selected: false,
              enabled: false,
            ),
          ]),
          row([
            CamoChip(
              label: 'Ada',
              onDeleted: () {},
              leading: const CamoAvatar(
                name: 'Ada Lovelace',
                size: AvatarSize.small,
              ),
            ),
            CamoChip(label: 'Grace', onDeleted: () {}),
            CamoChip(
              label: 'Add to calendar',
              onPressed: () {},
              leading: const CamoIcon(galleryIcon),
            ),
          ]),
          CamoChipGroup<String>(
            options: const [
              ChipOption('Newest', 'Newest'),
              ChipOption('Oldest', 'Oldest'),
              ChipOption('Popular', 'Popular'),
            ],
            selected: const {'Oldest'},
            onChanged: (_) {},
            multiSelect: false,
          ),
          row(spacing: 24, const [
            CamoBadgedBox(badge: CamoBadge(), child: CamoIcon(galleryIcon)),
            CamoBadgedBox(
              badge: CamoBadge(count: 3),
              child: CamoIcon(galleryIcon),
            ),
            CamoBadgedBox(
              badge: CamoBadge(count: 120),
              child: CamoIcon(galleryIcon),
            ),
            CamoBadgedBox(
              badge: CamoBadge(
                count: 7,
                tone: Tone.info,
                appearance: Appearance.soft,
              ),
              child: CamoIcon(galleryIcon),
            ),
            CamoBadgedBox(
              badge: CamoBadge(count: 12, appearance: Appearance.outline),
              child: CamoIcon(galleryIcon),
            ),
            CamoBadgedBox(
              badge: CamoBadge(count: 2),
              child: CamoAvatar(name: 'Grace Hopper'),
            ),
          ]),
          row(const [
            CamoAvatar(name: 'Dwiki Riyadi', size: AvatarSize.small),
            CamoAvatar(name: 'Dwiki Riyadi', presence: Presence.online),
            CamoAvatar(
              name: 'Ada Lovelace',
              size: AvatarSize.large,
              presence: Presence.busy,
            ),
            CamoAvatar(
              name: 'Grace Hopper',
              shape: AvatarShape.rounded,
              presence: Presence.away,
            ),
            CamoAvatar(
              name: 'Alan Turing',
              shape: AvatarShape.square,
              presence: Presence.offline,
            ),
            CamoAvatar(),
          ]),
          const CamoAvatarGroup(
            avatars: [
              CamoAvatar(name: 'Ada Lovelace'),
              CamoAvatar(name: 'Grace Hopper'),
              CamoAvatar(name: 'Alan Turing'),
              CamoAvatar(name: 'Edsger Dijkstra'),
              CamoAvatar(name: 'Barbara Liskov'),
            ],
          ),
        ],
      ),
    );
  }
}
