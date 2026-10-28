import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_icon.dart';
import 'brands.dart';
import 'checkout.dart';
import 'dates_and_times.dart';
import 'documents.dart';
import 'forms.dart';
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
    SampleSkin.debug => debugSkin,
  };

  /// Whether it's a Fluent skin (they take the brand color as Fluent's own).
  bool get isFluent =>
      this == SampleSkin.fluent || this == SampleSkin.fluentAcrylic;

  /// The skin's starter theme.
  CamoTheme theme(Brightness b) => switch (this) {
    SampleSkin.minimal => minimalTheme(brightness: b),
    SampleSkin.fluent || SampleSkin.fluentAcrylic => fluentTheme(brightness: b),
    SampleSkin.debug => CamoTheme(
      colors: CamoColors.fromSeed(primary: _debugSeed, brightness: b),
      typography: CamoTypography.system(),
    ),
  };
}

/// A brand on a skin's starter theme, light or dark: everything the example can switch. A skin with its own
/// token set takes the brand color too (Fluent derives its hover and pressed steps from it), so the brand reaches
/// every state, not only the roles.
CamoTheme sampleTheme(SampleSkin skin, Brand brand, Brightness brightness) {
  final seed = brand.tokens?.brand[600];
  final base = skin.isFluent && seed != null
      ? fluentTheme(brand: seed, brightness: brightness)
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

class _CamouflageExampleAppState extends State<CamouflageExampleApp> {
  bool? _dark;
  SampleSkin _skin = SampleSkin.minimal;
  Brand _brand = Brand.defaultBrand;

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

  // The gallery page. It reads the theme from the provider, so a skin, brand or dark switch rebuilds it
  // inside the Navigator (which the date and time pickers open their routes on).
  Widget _page(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final brightness = theme.colors.surface.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final dark = brightness == Brightness.dark;
    return CamoSurface(
      child: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.spacing.l,
            children: [
              _Switcher(
                options: SampleSkin.values,
                chosen: _skin,
                label: (s) => s.label,
                onChoose: (s) => setState(() => _skin = s),
              ),
              _Switcher(
                options: Brand.values,
                chosen: _brand,
                label: (b) => b.label,
                onChoose: (b) => setState(() => _brand = b),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CamoButton(
                  text: dark ? 'Light' : 'Dark',
                  onPressed: () => setState(() => _dark = !dark),
                  appearance: Appearance.ghost,
                ),
              ),
              const Checkout(),
              const _Section(title: 'Buttons', child: _Buttons()),
              const _Section(title: 'Icon buttons', child: _IconButtons()),
              const _Section(title: 'Text', child: _Texts()),
              const _Section(
                title: 'Surfaces and dividers',
                child: _Surfaces(),
              ),
              const _Section(title: 'Progress', child: _Progress()),
              const _Section(
                title: 'Selection controls',
                child: SelectionControls(),
              ),
              const _Section(title: 'Sign-up form', child: SignUpForm()),
              const _Section(title: 'Search', child: CountrySearch()),
              const _Section(title: 'Dates and times', child: DatesAndTimes()),
              const _Section(title: 'Settings screen', child: SettingsScreen()),
              const _Section(title: 'Cards', child: Cards()),
              const _Section(title: 'Accordions', child: Faq()),
              const _Section(
                title: 'Loading placeholders',
                child: LoadingProfile(),
              ),
              const _Section(title: 'Paged list', child: Products()),
              const _Section(title: 'Overlays', child: OverlayDemo()),
              const _Section(
                title: 'Documents: menus, selects, dialogs and sheets',
                child: DocumentsScreen(),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
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
