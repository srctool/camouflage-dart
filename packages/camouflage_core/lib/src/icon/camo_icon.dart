import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../skin/content_style.dart';
import '../theme/camo_theme.dart';

/// An icon asset, plus whether it mirrors in RTL and whether it keeps its own colors.
@immutable
sealed class IconSource {
  const IconSource({this.autoMirror = false, this.original = false});

  /// A glyph from an icon font.
  const factory IconSource.icon(
    IconData data, {
    bool autoMirror,
    bool original,
  }) = GlyphIconSource;

  /// An image (PNG, a network image, …).
  const factory IconSource.image(
    ImageProvider provider, {
    bool autoMirror,
    bool original,
  }) = ImageIconSource;

  /// Anything else, such as an SVG, drawn at a size and color; `color` is `null` for `original` sources.
  const factory IconSource.builder(
    Widget Function(double size, Color? color) build, {
    bool autoMirror,
    bool original,
  }) = BuilderIconSource;

  /// Flip horizontally in right-to-left layouts (back arrows, chevrons).
  final bool autoMirror;

  /// A multicolor asset: never tinted.
  final bool original;
}

/// An [IconSource] from an icon font.
final class GlyphIconSource extends IconSource {
  /// Creates the source.
  const GlyphIconSource(this.data, {super.autoMirror, super.original});

  /// The glyph.
  final IconData data;
}

/// An [IconSource] from an image.
final class ImageIconSource extends IconSource {
  /// Creates the source.
  const ImageIconSource(this.provider, {super.autoMirror, super.original});

  /// The image.
  final ImageProvider provider;
}

/// An [IconSource] drawn by a builder.
final class BuilderIconSource extends IconSource {
  /// Creates the source.
  const BuilderIconSource(this.build, {super.autoMirror, super.original});

  /// Draws the icon at a size and color.
  final Widget Function(double size, Color? color) build;
}

/// The icon component theme: overrides for the root icon style outside any component.
@immutable
class CamoIconTheme {
  /// Creates icon overrides; `null` keeps the skin's.
  const CamoIconTheme({this.size, this.color});

  /// The icon size.
  final double? size;

  /// The icon color.
  final Color? color;

  @override
  bool operator ==(Object other) =>
      other is CamoIconTheme && other.size == size && other.color == color;

  @override
  int get hashCode => Object.hash(size, color);
}

/// What an icon renderer draws: the asset at a resolved size and tint.
@immutable
class IconState {
  /// Creates an icon state.
  const IconState({
    required this.source,
    required this.size,
    required this.color,
    required this.semanticLabel,
  });

  /// The asset.
  final IconSource source;

  /// The resolved size.
  final double size;

  /// The resolved tint.
  final Color color;

  /// The label, or `null` for a decorative icon.
  final String? semanticLabel;
}

/// Draws icons, and sets the root icon style the provider resets to.
abstract interface class CamoIconRenderer {
  /// The icon style outside any component.
  CamoIconStyle defaults(CamoTheme theme);

  /// Draws [state].
  Widget render(BuildContext context, IconState state, CamoTheme theme);
}

/// An icon that takes its size and color from the surrounding component unless [size] or [color] is set.
/// A `null` [semanticLabel] makes it decorative: the right choice for icons passed into components, which carry
/// the label themselves.
class CamoIcon extends StatelessWidget {
  /// Creates an icon.
  const CamoIcon(
    this.source, {
    super.key,
    this.semanticLabel,
    this.size,
    this.color,
  });

  /// The asset.
  final IconSource source;

  /// The label, or `null` for a decorative icon.
  final String? semanticLabel;

  /// The size; `null` follows the ambient icon style.
  final double? size;

  /// The tint; `null` follows the ambient icon style.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoIcon');
    final theme = Camouflage.themeOf(context, component: 'CamoIcon');
    final ambient = Camouflage.iconStyleOf(context);
    final icon = skin.icon.render(
      context,
      IconState(
        source: source,
        size: size ?? ambient.size,
        color: color ?? ambient.color,
        semanticLabel: semanticLabel,
      ),
      theme,
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: icon)
        : Semantics(
            label: semanticLabel,
            image: true,
            excludeSemantics: true,
            child: icon,
          );
  }
}

/// Draws [state]'s asset at its size and tint, mirrored in right-to-left layouts when the source asks, and
/// untinted when it's `original`. What most icon renderers do; a skin may draw icons its own way instead.
class IconImage extends StatelessWidget {
  /// Draws [state].
  const IconImage(this.state, {super.key});

  /// What to draw.
  final IconState state;

  @override
  Widget build(BuildContext context) {
    final source = state.source;
    final tint = source.original ? null : state.color;
    final Widget drawn = switch (source) {
      GlyphIconSource(:final data) => Text.rich(
        TextSpan(
          text: String.fromCharCode(data.codePoint),
          style: TextStyle(
            inherit: false,
            fontFamily: data.fontFamily,
            package: data.fontPackage,
            fontSize: state.size,
            height: 1,
            color: tint,
          ),
        ),
        textScaler: TextScaler.noScaling,
      ),
      ImageIconSource(:final provider) => Image(
        image: provider,
        width: state.size,
        height: state.size,
        color: tint,
        colorBlendMode: BlendMode.srcIn,
      ),
      BuilderIconSource(:final build) => build(state.size, tint),
    };
    final mirror =
        source.autoMirror && Directionality.of(context) == TextDirection.rtl;
    return SizedBox.square(
      dimension: state.size,
      child: Center(
        child: mirror ? Transform.flip(flipX: true, child: drawn) : drawn,
      ),
    );
  }
}
