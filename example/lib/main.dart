import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_skin_fluent/camouflage_skin_fluent.dart';
import 'package:camouflage_skin_minimal/camouflage_skin_minimal.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';
import 'debug_skin.dart';

void main() => runApp(const CamouflageExampleApp());

const _debugSeed = Color(0xFF0B57D0);
const _promoSeed = Color(0xFFE8710A);
const _fakeRequest = Duration(seconds: 2);

// The three skins the example switches between, each with its own starter theme.
enum _Skin {
  minimal('Minimal', minimalSkin),
  fluent('Fluent', fluentSkinDefault),
  debug('Debug', debugSkin);

  const _Skin(this.label, this.skin);

  final String label;
  final CamoSkin skin;

  CamoTheme theme(Brightness b) => switch (this) {
    _Skin.minimal => minimalTheme(brightness: b),
    _Skin.fluent => fluentTheme(brightness: b),
    _Skin.debug => CamoTheme(
      colors: CamoColors.fromSeed(primary: _debugSeed, brightness: b),
      typography: CamoTypography.system(),
    ),
  };
}

/// The example app. Built on [WidgetsApp], not MaterialApp, to prove core works without Material.
/// M3: the first components on DebugSkin, Minimal and Fluent, switched live, like the Kotlin sample.
class CamouflageExampleApp extends StatefulWidget {
  /// Creates the example app.
  const CamouflageExampleApp({super.key});

  @override
  State<CamouflageExampleApp> createState() => _CamouflageExampleAppState();
}

class _CamouflageExampleAppState extends State<CamouflageExampleApp> {
  bool? _dark;
  _Skin _skin = _Skin.minimal;

  @override
  Widget build(BuildContext context) => WidgetsApp(
    title: 'Camouflage',
    color: _debugSeed,
    builder: (context, _) {
      final dark =
          _dark ?? MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final brightness = dark ? Brightness.dark : Brightness.light;
      return CamoAnimatedTheme(
        theme: _skin.theme(brightness),
        builder: (context, theme) => CamouflageProvider(
          skin: _skin.skin,
          theme: theme,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => CamoSurface(
                  child: SizedBox.expand(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(theme.spacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: theme.spacing.l,
                        children: [
                          Wrap(
                            spacing: theme.spacing.s,
                            runSpacing: theme.spacing.s,
                            children: [
                              for (final s in _Skin.values)
                                CamoButton(
                                  text: s.label,
                                  onPressed: () => setState(() => _skin = s),
                                  appearance: s == _skin
                                      ? Appearance.solid
                                      : Appearance.outline,
                                ),
                              CamoButton(
                                text: dark ? 'Light' : 'Dark',
                                onPressed: () => setState(() => _dark = !dark),
                                appearance: Appearance.ghost,
                              ),
                            ],
                          ),
                          const _Section(title: 'Buttons', child: _Buttons()),
                          const _Section(
                            title: 'Icon buttons',
                            child: _IconButtons(),
                          ),
                          const _Section(title: 'Text', child: _Texts()),
                          const _Section(
                            title: 'Surfaces and dividers',
                            child: _Surfaces(),
                          ),
                          const _Section(title: 'Progress', child: _Progress()),
                          CamouflageProvider(
                            theme: _skin
                                .theme(brightness)
                                .copyWith(
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
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
