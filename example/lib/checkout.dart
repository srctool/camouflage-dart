import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';
import 'brands.dart';

const _payment = Duration(seconds: 2);
const _brandSteps = [100, 300, 500, 700, 900];

/// The M4 demo screen: a checkout card built only from Camouflage components. Nothing here names a brand or a
/// skin; switching either at the provider restyles it (Provider and Scoping §3.3).
class Checkout extends StatefulWidget {
  /// Creates the screen.
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool _favorite = false;
  bool _paying = false;
  Timer? _request;

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  void _pay() {
    setState(() => _paying = true);
    _request = Timer(_payment, () => setState(() => _paying = false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final type = theme.typography;
    final spacing = theme.spacing;
    return CamoSurface(
      level: SurfaceLevel.lowest,
      shape: ShapeRole.large,
      elevation: ElevationLevel.level2,
      border: true,
      child: Padding(
        padding: EdgeInsets.all(spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.m,
          children: [
            Row(
              children: [
                CamoIconButton(
                  icon: const AppIcon.back(),
                  semanticLabel: 'Back',
                  onPressed: () {},
                  tooltip: 'Back to the cart',
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.s),
                    child: CamoText('Checkout', style: type.titleLarge),
                  ),
                ),
                CamoIconButton(
                  icon: _favorite
                      ? const AppIcon.star()
                      : const AppIcon.starOutline(),
                  semanticLabel: 'Favorite',
                  onPressed: () => setState(() => _favorite = !_favorite),
                  checked: _favorite,
                  tooltip: 'Save this order',
                ),
              ],
            ),
            const CamoDivider(),
            const _Line('Desk lamp', '€ 49.00'),
            const _Line('Linen shade', '€ 23.00'),
            const CamoDivider(inset: DividerInset.start),
            Row(
              children: [
                Expanded(child: CamoText('Total', style: type.titleMedium)),
                CamoText('€ 72.00', style: type.titleMedium),
              ],
            ),
            const _BrandStrip(),
            CamoText.rich(
              [
                const CamoSpan('By paying you agree to the '),
                CamoSpan('Terms', onTap: () {}),
                const CamoSpan('.'),
              ],
              style: type.bodySmall,
              color: theme.colors.onSurfaceVariant,
            ),
            CamoButton(
              text: 'Pay € 72.00',
              onPressed: _pay,
              loading: _paying,
              prefixIcon: const AppIcon.star(),
            ),
            CamoButton(
              text: 'Save for later',
              onPressed: () {},
              appearance: Appearance.ghost,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.price);

  final String label;
  final String price;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: CamoText(label)),
      CamoText(price, color: Camouflage.colorsOf(context).onSurfaceVariant),
    ],
  );
}

// The brand's own tokens, read like any theme value; nothing shows under a theme without them.
class _BrandStrip extends StatelessWidget {
  const _BrandStrip();

  @override
  Widget build(BuildContext context) {
    final tokens = Camouflage.maybeThemeOf(context)?.tokens<BrandTokens>();
    if (tokens == null) return const SizedBox.shrink();
    return Row(
      spacing: Camouflage.spacingOf(context).xs,
      children: [
        for (final step in _brandSteps)
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.brand[step],
              borderRadius: BorderRadius.circular(tokens.controlRadius),
            ),
            child: const SizedBox.square(dimension: 24),
          ),
      ],
    );
  }
}
