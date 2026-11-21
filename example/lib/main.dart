import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_carbon/camouflage_skin_carbon.dart';
import 'package:camouflage_skin_cupertino/camouflage_skin_cupertino.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_material/camouflage_skin_material.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_icon.dart';
import 'brands.dart';
import 'checkout.dart';
import 'data_display.dart';
import 'dates_and_times.dart';
import 'documents.dart';
import 'forms.dart';
import 'inbox.dart';
import 'navigation.dart';
import 'navigation_shell.dart';
import 'admin.dart';
import 'charts.dart';
import 'editor.dart';
import 'lists.dart';
import 'panels.dart';
import 'dock_layout.dart';
import 'split_pane.dart';
import 'small_data.dart';
import 'selection.dart';
import 'overlays.dart';
import 'structure.dart';
import 'debug_skin.dart';

Future<void> main() async {
  // The date and time pickers' names and formats in every locale, not only en_US.
  await initializeDateFormatting();
  runApp(const CamouflageExampleApp());
}

const _debugSeed = Color(0xFF0B57D0);
const _promoSeed = Color(0xFFE8710A);
const _fakeRequest = Duration(seconds: 2);

/// The skins the example switches between, each with its own starter theme.
enum SampleSkin {
  /// Camouflage's own dialect.
  minimal('Minimal'),

  /// Fluent 2.
  fluent('Fluent'),

  /// Fluent 2 with Acrylic flyouts and dialogs.
  fluentAcrylic('Fluent Acrylic'),

  /// Material Design 3.
  material('Material'),

  /// Apple's HIG with Classic blur materials.
  cupertino('Cupertino'),

  /// Apple's HIG with Liquid Glass.
  cupertinoGlass('Cupertino Glass'),

  /// IBM Carbon: square, layered, flat.
  carbon('Carbon'),

  /// The reference renderers.
  debug('Debug');

  const SampleSkin(this.label);

  /// The switcher's label.
  final String label;

  /// The skin.
  CamoSkin get skin => switch (this) {
    SampleSkin.minimal => minimalSkin,
    SampleSkin.fluent => fluentSkinDefault,
    SampleSkin.fluentAcrylic => _acrylic,
    SampleSkin.material => materialSkin,
    SampleSkin.cupertino => cupertinoSkin,
    SampleSkin.cupertinoGlass => _glass,
    SampleSkin.carbon => carbonSkin,
    SampleSkin.debug => debugSkin,
  };

  /// Whether it's a Fluent skin (they take the brand color as Fluent's own).
  bool get isFluent =>
      this == SampleSkin.fluent || this == SampleSkin.fluentAcrylic;

  /// The skin's starter theme.
  CamoTheme theme(Brightness b) => switch (this) {
    SampleSkin.minimal => minimalTheme(brightness: b),
    SampleSkin.fluent || SampleSkin.fluentAcrylic => fluentTheme(brightness: b),
    SampleSkin.material => materialTheme(brightness: b),
    SampleSkin.cupertino ||
    SampleSkin.cupertinoGlass => cupertinoTheme(brightness: b),
    SampleSkin.carbon => carbonTheme(family: _carbonFamily(b)),
    SampleSkin.debug => CamoTheme(
      colors: CamoColors.fromSeed(primary: _debugSeed, brightness: b),
      typography: CamoTypography.system(),
    ),
  };
}

// Carbon's light theme is White, its dark one G100.
CarbonThemeFamily _carbonFamily(Brightness b) =>
    b == Brightness.dark ? CarbonThemeFamily.g100 : CarbonThemeFamily.white;

/// A brand on a skin's starter theme, light or dark: everything the example can switch. A skin with its own
/// token set takes the brand color too (Fluent derives its hover and pressed steps from it), so the brand reaches
/// every state, not only the roles.
CamoTheme sampleTheme(SampleSkin skin, Brand brand, Brightness brightness) {
  final seed = brand.tokens?.brand[600];
  final base = skin.isFluent && seed != null
      ? fluentTheme(brand: seed, brightness: brightness)
      : skin == SampleSkin.material && seed != null
      ? materialTheme(seed: seed, brightness: brightness)
      : (skin == SampleSkin.cupertino || skin == SampleSkin.cupertinoGlass) &&
            seed != null
      ? cupertinoTheme(accent: seed, brightness: brightness)
      : skin == SampleSkin.carbon && seed != null
      ? carbonTheme(family: _carbonFamily(brightness), accent: seed)
      : skin.theme(brightness);
  return brand.on(base, brightness);
}

/// The example app. Built on [WidgetsApp], not MaterialApp, to prove core works without Material.
/// M4: one screen, two brands, two skins and dark mode, switched live at the provider, like the Kotlin sample;
/// then the component gallery.
class CamouflageExampleApp extends StatefulWidget {
  /// Creates the example app.
  const CamouflageExampleApp({super.key});

  @override
  State<CamouflageExampleApp> createState() => _CamouflageExampleAppState();
}

/// A component page of the catalog: a title, one line about it and its demo.
class _Entry {
  const _Entry(this.title, this.description, this.build);

  final String title;
  final String description;
  final Widget Function() build;
}

final _entries = <_Entry>[
  _Entry(
    'Checkout',
    'A screen built from the components: a bar, rows, text, a button, a link.',
    () => const Checkout(),
  ),
  _Entry(
    'Buttons',
    'Six appearances in two tones, with icons, a disabled state and loading.',
    () => const _Buttons(),
  ),
  _Entry(
    'Icon buttons',
    'Icon-only buttons: plain, tonal, toggled, destructive, tooltips.',
    () => const _IconButtons(),
  ),
  _Entry(
    'Text',
    'The type scale, bold runs and links inside a sentence.',
    () => const _Texts(),
  ),
  _Entry('Surfaces', 'Surfaces, levels and dividers.', () => const _Surfaces()),
  _Entry(
    'Progress',
    'Linear and circular indicators, determinate and not.',
    () => const _Progress(),
  ),
  _Entry(
    'Selection controls',
    'Checkboxes, switches, radios, a segmented control, a slider and a stepper.',
    () => const SelectionControls(),
  ),
  _Entry(
    'Forms',
    'A sign-up form: text fields, validation and a submit button.',
    () => const SignUpForm(),
  ),
  _Entry(
    'Search',
    'A search field filtering a list of countries.',
    () => const CountrySearch(),
  ),
  _Entry(
    'Dates and times',
    'Date and time pickers, as fields and as wheels.',
    () => const DatesAndTimes(),
  ),
  _Entry(
    'Settings',
    'A settings screen with grouped rows and toggles.',
    () => const SettingsScreen(),
  ),
  _Entry(
    'Cards',
    'Cards in every appearance and tone, clickable and selectable.',
    () => const Cards(),
  ),
  _Entry(
    'Accordions',
    'Disclosure sections that open and close.',
    () => const Faq(),
  ),
  _Entry(
    'Loading placeholders',
    'Skeletons that stand in for content.',
    () => const LoadingProfile(),
  ),
  _Entry(
    'Paged list',
    'An endless list with pull to refresh, retry and empty states.',
    () => const Products(),
  ),
  _Entry(
    'Overlays',
    'Dialogs, sheets and the things that stack over the page.',
    () => const OverlayDemo(),
  ),
  _Entry(
    'Menus and dialogs',
    'Menus, selects, dialogs and sheets over documents.',
    () => const DocumentsScreen(),
  ),
  _Entry(
    'Chips, badges, avatars',
    'Small data display: tokens, counts and people.',
    () => const DataDisplayDemo(),
  ),
  _Entry(
    'Banners and snackbars',
    'Messages: progress, snackbars and banners in an inbox.',
    () => const InboxScreen(),
  ),
  _Entry(
    'Tabs and FAB',
    'Tabs and the floating action button.',
    () => const NavigationDemo(),
  ),
  _Entry(
    'Navigation',
    'A bar, a rail and a drawer, by window size.',
    () => const NavigationShellDemo(),
  ),
  _Entry(
    'Popover and side sheet',
    'Panels anchored to a control or to an edge.',
    () => const PanelsDemo(),
  ),
  _Entry(
    'Split panes',
    'Resizable panes with an accessible, draggable divider.',
    () => const SplitPaneDemo(),
  ),
  _Entry(
    'Dock layout',
    'Tool windows on side and bottom docks, opened from edge stripes.',
    () => const DockLayoutDemo(),
  ),
  _Entry(
    'Toolbars',
    'Toolbars, button groups and a split button in an editor.',
    () => const EditorDemo(),
  ),
  _Entry(
    'Rating and steps',
    'Stars, page controls, a path and progress steps.',
    () => const SmallDataDemo(),
  ),
  _Entry(
    'Table and tree',
    'A data table and an outline tree.',
    () => const ListsDemo(),
  ),
  _Entry(
    'File upload',
    'A folder, an uploader and a review.',
    () => const AdminDemo(),
  ),
  _Entry(
    'Charts',
    'A dashboard of line, bar and donut charts.',
    () => const ChartsDemo(),
  ),
];

const _cardHeight = 112.0;
const _cardIcon = 28.0;

class _CamouflageExampleAppState extends State<CamouflageExampleApp> {
  bool? _dark;
  SampleSkin _skin = SampleSkin.minimal;
  Brand _brand = Brand.defaultBrand;
  _Entry? _open;
  bool _themePage = false;

  @override
  Widget build(BuildContext context) => WidgetsApp(
    title: 'Camouflage',
    color: _debugSeed,
    builder: (context, _) {
      final dark =
          _dark ?? MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final brightness = dark ? Brightness.dark : Brightness.light;
      return CamoAnimatedTheme(
        theme: sampleTheme(_skin, _brand, brightness),
        builder: (context, theme) => CamouflageProvider(
          skin: _skin.skin,
          theme: theme,
          child: Navigator(
            onGenerateRoute: (_) => PageRouteBuilder<void>(
              pageBuilder: (context, _, _) => _page(context),
            ),
          ),
        ),
      );
    },
  );

  void _home() => setState(() {
    _open = null;
    _themePage = false;
  });

  // The page, laid out like a component catalog (as the Kotlin sample is): a home of component cards, a page per
  // component (a title, a line about it and its demo), and a theme page for the skin, the brand and the dark mode,
  // switched live at the provider. It reads the theme from the provider, so a switch rebuilds it inside the
  // Navigator (which the date and time pickers open their routes on).
  Widget _page(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final brightness = theme.colors.surface.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final dark = brightness == Brightness.dark;
    final inner = _themePage || _open != null;
    final title = _themePage
        ? 'Theme'
        : _open != null
        ? _open!.title
        : 'Camouflage';
    return PopScope(
      canPop: !inner,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _home();
      },
      child: CamoSurface(
        child: Column(
          children: [
            CamoTopBar(
              title: title,
              navigation: inner
                  ? CamoIconButton(
                      icon: const AppIcon.back(),
                      semanticLabel: 'Back',
                      onPressed: _home,
                    )
                  : null,
              actions: [
                if (!_themePage)
                  CamoIconButton(
                    icon: const AppIcon.palette(),
                    semanticLabel: 'Theme',
                    onPressed: () => setState(() {
                      _open = null;
                      _themePage = true;
                    }),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(theme.spacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: theme.spacing.l,
                  children: [
                    if (_themePage)
                      ..._themeControls(theme, dark)
                    else if (_open != null)
                      ..._componentPage(theme, _open!, brightness)
                    else
                      ..._homeCards(theme),
                    SizedBox(height: theme.spacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The home: the component cards, two to a row.
  List<Widget> _homeCards(CamoTheme theme) => [
    CamoText('Components', style: theme.typography.titleMedium),
    for (var i = 0; i < _entries.length; i += 2)
      Row(
        spacing: theme.spacing.m,
        children: [
          for (var j = i; j < i + 2; j++)
            Expanded(
              child: j < _entries.length
                  ? CamoCard(
                      onPressed: () => setState(() => _open = _entries[j]),
                      child: SizedBox(
                        height: _cardHeight,
                        child: Padding(
                          padding: EdgeInsets.all(theme.spacing.m),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppIcon.star(size: _cardIcon),
                              Flexible(
                                child: CamoText(
                                  _entries[j].title,
                                  style: theme.typography.labelLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
  ];

  // A component's page: what it is, then its demo (the promo nested provider is part of the checkout's page).
  List<Widget> _componentPage(
    CamoTheme theme,
    _Entry entry,
    Brightness brightness,
  ) => [
    CamoText('Description', style: theme.typography.titleMedium),
    CamoText(entry.description, color: theme.colors.onSurfaceVariant),
    CamoText('Examples', style: theme.typography.titleMedium),
    _Section(title: entry.title, child: entry.build()),
    if (entry.title == 'Checkout')
      CamouflageProvider(
        theme: sampleTheme(_skin, _brand, brightness).copyWith(
          colors: CamoColors.fromSeed(
            primary: _promoSeed,
            brightness: brightness,
          ),
        ),
        child: _Section(
          title: 'Nested provider: a promo theme',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CamoButton(
              text: 'Claim offer',
              onPressed: () {},
              suffixIcon: const AppIcon.chevronRight(),
            ),
          ),
        ),
      ),
  ];

  // The theme page: the skin, the brand and light or dark.
  List<Widget> _themeControls(CamoTheme theme, bool dark) => [
    CamoText('Skin', style: theme.typography.titleMedium),
    _Switcher(
      options: SampleSkin.values,
      chosen: _skin,
      label: (s) => s.label,
      onChoose: (s) => setState(() => _skin = s),
    ),
    CamoText('Brand', style: theme.typography.titleMedium),
    _Switcher(
      options: Brand.values,
      chosen: _brand,
      label: (b) => b.label,
      onChoose: (b) => setState(() => _brand = b),
    ),
    CamoText('Appearance', style: theme.typography.titleMedium),
    _Switcher(
      options: const [false, true],
      chosen: dark,
      label: (d) => d ? 'Dark' : 'Light',
      onChoose: (d) => setState(() => _dark = d),
    ),
  ];
}

// A row of buttons, one per option; the chosen one is solid.
class _Switcher<T> extends StatelessWidget {
  const _Switcher({
    required this.options,
    required this.chosen,
    required this.label,
    required this.onChoose,
  });

  final List<T> options;
  final T chosen;
  final String Function(T) label;
  final void Function(T) onChoose;

  @override
  Widget build(BuildContext context) {
    final s = Camouflage.spacingOf(context).s;
    return Wrap(
      spacing: s,
      runSpacing: s,
      children: [
        for (final o in options)
          CamoButton(
            text: label(o),
            onPressed: () => onChoose(o),
            appearance: o == chosen ? Appearance.solid : Appearance.outline,
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return CamoSurface(
      level: SurfaceLevel.low,
      shape: ShapeRole.large,
      border: true,
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing.m,
          children: [
            CamoText(title, style: theme.typography.titleMedium),
            child,
          ],
        ),
      ),
    );
  }
}

class _Buttons extends StatefulWidget {
  const _Buttons();

  @override
  State<_Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons> {
  bool _loading = false;
  Timer? _request;

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  void _submit() {
    setState(() => _loading = true);
    _request = Timer(_fakeRequest, () => setState(() => _loading = false));
  }

  @override
  Widget build(BuildContext context) {
    final s = Camouflage.spacingOf(context).s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: s,
      children: [
        for (final tone in [Tone.defaultTone, Tone.error])
          for (final enabled in [true, false])
            Wrap(
              spacing: s,
              runSpacing: s,
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
        Wrap(
          spacing: s,
          runSpacing: s,
          children: [
            CamoButton(
              text: 'Search',
              onPressed: () {},
              prefixIcon: const AppIcon.search(),
            ),
            CamoButton(
              text: 'Next',
              onPressed: () {},
              appearance: Appearance.outline,
              suffixIcon: const AppIcon.chevronRight(),
            ),
            CamoButton(
              text: 'Delete',
              onPressed: () {},
              appearance: Appearance.ghost,
              tone: Tone.error,
              prefixIcon: const AppIcon.delete(),
            ),
          ],
        ),
        CamoButton(text: 'Submit', onPressed: _submit, loading: _loading),
      ],
    );
  }
}

class _IconButtons extends StatefulWidget {
  const _IconButtons();

  @override
  State<_IconButtons> createState() => _IconButtonsState();
}

class _IconButtonsState extends State<_IconButtons> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Camouflage.spacingOf(context).s,
    children: [
      CamoIconButton(
        icon: const AppIcon.back(),
        semanticLabel: 'Back',
        onPressed: () {},
        tooltip: 'Back',
      ),
      CamoIconButton(
        icon: const AppIcon.search(),
        semanticLabel: 'Search',
        onPressed: () {},
        appearance: Appearance.soft,
        tooltip: 'Search the library',
      ),
      CamoIconButton(
        icon: _favorite ? const AppIcon.star() : const AppIcon.starOutline(),
        semanticLabel: 'Favorite',
        onPressed: () => setState(() => _favorite = !_favorite),
        checked: _favorite,
        tooltip: 'Add to favorites',
      ),
      CamoIconButton(
        icon: const AppIcon.delete(),
        semanticLabel: 'Delete',
        onPressed: () {},
        tone: Tone.error,
        tooltip: 'Delete',
      ),
      CamoIconButton(
        icon: const AppIcon.search(),
        semanticLabel: 'Search',
        onPressed: () {},
        appearance: Appearance.solid,
      ),
      const CamoIconButton(
        icon: AppIcon.search(),
        semanticLabel: 'Search',
        onPressed: null,
      ),
    ],
  );
}

class _Texts extends StatelessWidget {
  const _Texts();

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final t = theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style) in [
          ('Display small', t.displaySmall),
          ('Headline medium', t.headlineMedium),
          ('Title large', t.titleLarge),
          ('Title medium', t.titleMedium),
          ('Body large', t.bodyLarge),
          ('Body medium', t.bodyMedium),
          ('Body small', t.bodySmall),
          ('Label large', t.labelLarge),
          ('Label small', t.labelSmall),
        ])
          CamoText(name, style: style),
        CamoText(
          'Bold body',
          style: t.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        CamoText.rich([
          const CamoSpan('I agree to the '),
          CamoSpan('Terms', onTap: () {}),
          const CamoSpan(' and the '),
          CamoSpan('Privacy Policy', onTap: () {}),
          const CamoSpan('.'),
        ]),
        CamoText('Saved', color: theme.colors.success),
      ],
    );
  }
}

class _Surfaces extends StatelessWidget {
  const _Surfaces();

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.m,
      children: [
        Wrap(
          spacing: spacing.s,
          children: [
            for (final level in SurfaceLevel.values)
              CamoSurface(
                level: level,
                shape: ShapeRole.medium,
                border: true,
                child: const SizedBox.square(dimension: 48),
              ),
            const CamoSurface(
              shape: ShapeRole.medium,
              elevation: ElevationLevel.level3,
              child: SizedBox.square(dimension: 48),
            ),
          ],
        ),
        const CamoDivider(),
        const CamoDivider(inset: DividerInset.start),
        const CamoDivider(inset: DividerInset.middle),
        IntrinsicHeight(
          child: Row(
            children: [
              const CamoText('Left'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.m),
                child: const CamoDivider(orientation: Axis.vertical),
              ),
              const CamoText('Right'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Camouflage.spacingOf(context).l,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: const [
      CamoProgressCircle(size: ProgressSize.small, semanticLabel: 'Loading'),
      CamoProgressCircle(semanticLabel: 'Loading'),
      CamoProgressCircle(
        value: 0.6,
        size: ProgressSize.large,
        semanticLabel: 'Uploading',
      ),
      CamoProgressCircle(
        value: 0.3,
        tone: Tone.error,
        semanticLabel: 'Upload failed',
      ),
    ],
  );
}

final CamoSkin _acrylic = fluentSkin(surface: FluentSurface.acrylic);
final CamoSkin _glass = cupertinoSkinWith(
  surface: CupertinoSurface.liquidGlass,
);
