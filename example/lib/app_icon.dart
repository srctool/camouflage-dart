import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The app's icons (CamoIcon §3, the `AppIcon` pattern): one constructor per asset, with no size or color unless
/// given, so each takes the style of the component it's placed in. Decorative by default.
class AppIcon extends StatelessWidget {
  /// A back arrow; it mirrors in RTL.
  const AppIcon.back({super.key, this.size, this.color})
    : _asset = 'back',
      _mirror = true;

  /// A magnifier.
  const AppIcon.search({super.key, this.size, this.color})
    : _asset = 'search',
      _mirror = false;

  /// A filled star.
  const AppIcon.star({super.key, this.size, this.color})
    : _asset = 'star',
      _mirror = false;

  /// An outlined star.
  const AppIcon.starOutline({super.key, this.size, this.color})
    : _asset = 'star_outline',
      _mirror = false;

  /// A trash can.
  const AppIcon.delete({super.key, this.size, this.color})
    : _asset = 'delete',
      _mirror = false;

  /// A chevron; it mirrors in RTL.
  const AppIcon.chevronRight({super.key, this.size, this.color})
    : _asset = 'chevron',
      _mirror = true;

  /// Three dots: more options.
  const AppIcon.more({super.key, this.size, this.color})
    : _asset = 'more',
      _mirror = false;

  /// Sort lines.
  const AppIcon.sort({super.key, this.size, this.color})
    : _asset = 'sort',
      _mirror = false;

  /// Share.
  const AppIcon.share({super.key, this.size, this.color})
    : _asset = 'share',
      _mirror = false;

  /// A pencil.
  const AppIcon.edit({super.key, this.size, this.color})
    : _asset = 'edit',
      _mirror = false;

  final String _asset;
  final bool _mirror;

  /// The size; `null` follows the surrounding component.
  final double? size;

  /// The color; `null` follows the surrounding component.
  final Color? color;

  @override
  Widget build(BuildContext context) => CamoIcon(
    IconSource.builder(
      (s, c) => SvgPicture.asset(
        'assets/icons/$_asset.svg',
        width: s,
        height: s,
        colorFilter: c == null ? null : ColorFilter.mode(c, BlendMode.srcIn),
      ),
      autoMirror: _mirror,
    ),
    size: size,
    color: color,
  );
}
