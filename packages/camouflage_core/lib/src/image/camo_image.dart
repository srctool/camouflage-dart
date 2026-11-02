import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';

/// Every color an image frame uses.
@immutable
class ImageColors {
  /// Creates ImageColors.
  const ImageColors({
    required this.placeholder,
    required this.icon,
    required this.border,
  });

  /// Behind the image.
  final Color placeholder;

  /// The placeholder and error icons.
  final Color icon;

  /// A hairline frame.
  final Color border;

  @override
  bool operator ==(Object other) =>
      other is ImageColors &&
      other.placeholder == placeholder &&
      other.icon == icon &&
      other.border == border;

  @override
  int get hashCode => Object.hash(placeholder, icon, border);
}

/// Overrides for images. `null` keeps the skin's default.
@immutable
class CamoImageTheme {
  /// Creates overrides.
  const CamoImageTheme({
    this.placeholderIcon,
    this.errorIcon,
    this.fade,
    this.borderWidth,
    this.colors,
  });

  /// Shown while loading.
  final IconSource? placeholderIcon;

  /// Shown on failure.
  final IconSource? errorIcon;

  /// The crossfade to the loaded image.
  final Duration? fade;

  /// A hairline frame (0 for none).
  final double? borderWidth;

  /// Every color it uses.
  final ImageColors? colors;

  /// A copy with the given fields replaced.
  CamoImageTheme copyWith({
    IconSource? placeholderIcon,
    IconSource? errorIcon,
    Duration? fade,
    double? borderWidth,
    ImageColors? colors,
  }) => CamoImageTheme(
    placeholderIcon: placeholderIcon ?? this.placeholderIcon,
    errorIcon: errorIcon ?? this.errorIcon,
    fade: fade ?? this.fade,
    borderWidth: borderWidth ?? this.borderWidth,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoImageTheme &&
      other.placeholderIcon == placeholderIcon &&
      other.errorIcon == errorIcon &&
      other.fade == fade &&
      other.borderWidth == borderWidth &&
      other.colors == colors;

  @override
  int get hashCode =>
      Object.hash(placeholderIcon, errorIcon, fade, borderWidth, colors);
}

/// The resolved image style: every field set.
@immutable
class CamoImageStyle {
  /// Creates a style.
  const CamoImageStyle({
    required this.placeholderIcon,
    required this.errorIcon,
    required this.fade,
    required this.borderWidth,
    required this.colors,
  });

  /// Shown while loading.
  final IconSource placeholderIcon;

  /// Shown on failure.
  final IconSource errorIcon;

  /// The crossfade to the loaded image.
  final Duration fade;

  /// A hairline frame (0 for none).
  final double borderWidth;

  /// Every color it uses.
  final ImageColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoImageStyle merge(CamoImageTheme? o) => o == null
      ? this
      : CamoImageStyle(
          placeholderIcon: o.placeholderIcon ?? placeholderIcon,
          errorIcon: o.errorIcon ?? errorIcon,
          fade: o.fade ?? fade,
          borderWidth: o.borderWidth ?? borderWidth,
          colors: o.colors ?? colors,
        );
}

/// Where an image is: loading, shown, or failed.
enum ImagePhase {
  /// Still loading: the skin's placeholder shows.
  loading,

  /// The picture shows.
  loaded,

  /// Loading failed.
  failed,
}

/// What [CamoImage] shows. Core loads nothing (ADR-27): the app maps its image loader's state to one of these.
@immutable
sealed class ImageSource {
  const ImageSource();

  /// The loaded picture, usually an `Image`; the app sets its fit.
  const factory ImageSource.loaded(Widget image) = ImageLoaded;

  /// Still loading.
  const factory ImageSource.loading() = ImageLoading;

  /// Loading failed with [error].
  const factory ImageSource.failed([Object? error]) = ImageFailed;
}

/// The loaded picture.
class ImageLoaded extends ImageSource {
  /// Creates the source.
  const ImageLoaded(this.image);

  /// The picture.
  final Widget image;
}

/// Still loading.
class ImageLoading extends ImageSource {
  /// Creates the source.
  const ImageLoading();
}

/// Loading failed.
class ImageFailed extends ImageSource {
  /// Creates the source.
  const ImageFailed([this.error]);

  /// What went wrong, if known.
  final Object? error;
}

/// What the image renderer draws: the frame in [shape], and the placeholder or error look unless [phase] is loaded.
@immutable
class ImageState {
  /// Creates the state.
  const ImageState({required this.phase, required this.shape});

  /// Loading, loaded or failed.
  final ImagePhase phase;

  /// The frame's corners.
  final BorderRadius shape;
}

/// Draws the frame (shape, placeholder, error, border) around the image that core passes as `child`.
abstract interface class CamoImageRenderer {
  /// The complete image style for [theme].
  CamoImageStyle defaults(CamoTheme theme);

  /// Draws the frame; [child] is the loaded image, which core fades in (empty while loading or failed).
  Widget render(
    BuildContext context,
    ImageState state,
    CamoTheme theme,
    CamoImageStyle style,
    Widget child,
  );
}

/// A picture with a shape, a placeholder while it loads and an error look when it fails. [semanticLabel]
/// describes it, or is `null` to hide a decorative image from screen readers; a failed image adds "could not
/// load". [aspectRatio] fixes the frame's proportions; give the image a size otherwise.
class CamoImage extends StatelessWidget {
  /// Creates an image.
  const CamoImage({
    super.key,
    required this.source,
    required this.semanticLabel,
    this.shape = ShapeRole.medium,
    this.aspectRatio,
  });

  /// What to show.
  final ImageSource source;

  /// Describes the image, or `null` for a decorative one.
  final String? semanticLabel;

  /// The corner role.
  final ShapeRole shape;

  /// Fixes the frame's width to height.
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoImage');
    final theme = Camouflage.themeOf(context, component: 'CamoImage');
    final style = skin.image.defaults(theme).merge(theme.components.image);
    final source = this.source;
    final phase = switch (source) {
      ImageLoaded() => ImagePhase.loaded,
      ImageLoading() => ImagePhase.loading,
      ImageFailed() => ImagePhase.failed,
    };
    Widget frame = skin.image.render(
      context,
      ImageState(phase: phase, shape: theme.shapes.of(shape)),
      theme,
      style,
      source is ImageLoaded
          ? AnimatedOpacity(
              opacity: 1,
              duration: style.fade,
              child: source.image,
            )
          : const SizedBox.shrink(),
    );
    final ratio = aspectRatio;
    if (ratio != null) frame = AspectRatio(aspectRatio: ratio, child: frame);
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: frame)
        : Semantics(
            image: true,
            label: label,
            value: phase == ImagePhase.failed ? 'Could not load' : null,
            child: ExcludeSemantics(child: frame),
          );
  }
}
