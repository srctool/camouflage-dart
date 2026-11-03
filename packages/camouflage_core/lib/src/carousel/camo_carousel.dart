import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../environment/camo_environment.dart';
import '../pagination/camo_pagination.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../util/camo_behavior.dart';
import '../util/camo_touch_target.dart';

/// Every color a carousel uses: the previous and next buttons float over the items.
@immutable
class CarouselColors {
  /// Creates CarouselColors.
  const CarouselColors({
    required this.buttonContainer,
    required this.buttonContent,
  });

  /// The buttons' fill.
  final Color buttonContainer;

  /// Their arrows.
  final Color buttonContent;

  @override
  bool operator ==(Object other) =>
      other is CarouselColors &&
      other.buttonContainer == buttonContainer &&
      other.buttonContent == buttonContent;

  @override
  int get hashCode => Object.hash(buttonContainer, buttonContent);
}

/// Overrides for carousels. `null` keeps the skin's default.
@immutable
class CamoCarouselTheme {
  /// Creates overrides.
  const CamoCarouselTheme({
    this.itemShape,
    this.itemSpacing,
    this.peek,
    this.buttonSize,
    this.previousIcon,
    this.nextIcon,
    this.colors,
  });

  /// The mask of each item.
  final BorderRadius? itemShape;

  /// Between items.
  final double? itemSpacing;

  /// The next item showing at the edge in the peek layout.
  final double? peek;

  /// The previous and next buttons.
  final double? buttonSize;

  /// The previous button.
  final IconSource? previousIcon;

  /// The next button.
  final IconSource? nextIcon;

  /// Every color it uses.
  final CarouselColors? colors;

  /// A copy with the given fields replaced.
  CamoCarouselTheme copyWith({
    BorderRadius? itemShape,
    double? itemSpacing,
    double? peek,
    double? buttonSize,
    IconSource? previousIcon,
    IconSource? nextIcon,
    CarouselColors? colors,
  }) => CamoCarouselTheme(
    itemShape: itemShape ?? this.itemShape,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    peek: peek ?? this.peek,
    buttonSize: buttonSize ?? this.buttonSize,
    previousIcon: previousIcon ?? this.previousIcon,
    nextIcon: nextIcon ?? this.nextIcon,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoCarouselTheme &&
      other.itemShape == itemShape &&
      other.itemSpacing == itemSpacing &&
      other.peek == peek &&
      other.buttonSize == buttonSize &&
      other.previousIcon == previousIcon &&
      other.nextIcon == nextIcon &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    itemShape,
    itemSpacing,
    peek,
    buttonSize,
    previousIcon,
    nextIcon,
    colors,
  );
}

/// The resolved carousel style: every field set.
@immutable
class CamoCarouselStyle {
  /// Creates a style.
  const CamoCarouselStyle({
    required this.itemShape,
    required this.itemSpacing,
    required this.peek,
    required this.buttonSize,
    required this.previousIcon,
    required this.nextIcon,
    required this.colors,
  });

  /// The mask of each item.
  final BorderRadius itemShape;

  /// Between items.
  final double itemSpacing;

  /// The next item showing at the edge in the peek layout.
  final double peek;

  /// The previous and next buttons.
  final double buttonSize;

  /// The previous button.
  final IconSource previousIcon;

  /// The next button.
  final IconSource nextIcon;

  /// Every color it uses.
  final CarouselColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoCarouselStyle merge(CamoCarouselTheme? o) => o == null
      ? this
      : CamoCarouselStyle(
          itemShape: o.itemShape ?? itemShape,
          itemSpacing: o.itemSpacing ?? itemSpacing,
          peek: o.peek ?? peek,
          buttonSize: o.buttonSize ?? buttonSize,
          previousIcon: o.previousIcon ?? previousIcon,
          nextIcon: o.nextIcon ?? nextIcon,
          colors: o.colors ?? colors,
        );
}

/// How the items sit: one at a time, or with the next one showing at the edge.
enum CarouselLayout {
  /// One item at a time.
  paged,

  /// The next item shows at the edge.
  peek,
}

/// Which way a navigation button goes.
enum CarouselDirection {
  /// Towards the first item.
  previous,

  /// Towards the last item.
  next,
}

/// What the container renderer draws: the frame around the items and the buttons.
@immutable
class CarouselState {
  /// Creates the state.
  const CarouselState({
    required this.page,
    required this.pageCount,
    required this.layout,
  });

  /// The current item.
  final int page;

  /// How many items.
  final int pageCount;

  /// The layout.
  final CarouselLayout layout;
}

/// What a navigation button draws; [enabled] is `false` at the first or last item.
@immutable
class CarouselButtonState {
  /// Creates the state.
  const CarouselButtonState({
    required this.direction,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// Which way it goes (already mirrored for right-to-left layouts).
  final CarouselDirection direction;

  /// `false` at the end of the range.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// Draws carousels in parts: the container, each item's frame and the previous and next buttons.
abstract interface class CamoCarouselRenderer {
  /// The complete carousel style for [theme].
  CamoCarouselStyle defaults(CamoTheme theme);

  /// The frame around [child], the pager of items.
  Widget renderContainer(
    BuildContext context,
    CarouselState state,
    CamoTheme theme,
    CamoCarouselStyle style,
    Widget child,
  );

  /// One item's frame (its mask) around the app's [child].
  Widget renderItem(
    BuildContext context,
    CamoTheme theme,
    CamoCarouselStyle style,
    Widget child,
  );

  /// A previous or next button.
  Widget renderButton(
    BuildContext context,
    CarouselButtonState state,
    CamoTheme theme,
    CamoCarouselStyle style,
  );
}

/// A strip of items you swipe or step through. [layout] `peek` lets the next item show at the edge (it uses a
/// `PageController` with a viewport fraction; a [controller] you pass must match). Previous and next buttons show on
/// pointer devices by default ([showButtons]); Left and Right (reading direction), Home and End step and jump; the
/// page dots are [CamoPagination]'s. Give the carousel a height: the items fill it. Each item announces "item 2 of 5"; [semanticLabel] names the carousel. There is
/// no auto-play.
class CamoCarousel<T> extends StatefulWidget {
  /// Creates a carousel.
  const CamoCarousel({
    super.key,
    required this.items,
    required this.itemKey,
    required this.semanticLabel,
    required this.itemBuilder,
    this.controller,
    this.layout = CarouselLayout.paged,
    this.showButtons,
    this.showIndicator = true,
  });

  /// The items.
  final List<T> items;

  /// An item's stable key.
  final Object Function(T item) itemKey;

  /// Names the carousel.
  final String semanticLabel;

  /// Draws an item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Moves the carousel from outside; created when `null`.
  final PageController? controller;

  /// One at a time, or peeking.
  final CarouselLayout layout;

  /// Whether the buttons show; `null` shows them on pointer devices.
  final bool? showButtons;

  /// Whether the page dots show.
  final bool showIndicator;

  @override
  State<CamoCarousel<T>> createState() => _CamoCarouselState<T>();
}

const _peekFraction = 0.9;

class _CamoCarouselState<T> extends State<CamoCarousel<T>> {
  PageController? _own;
  var _page = 0;

  PageController get _controller =>
      widget.controller ??
      (_own ??= PageController(
        viewportFraction: widget.layout == CarouselLayout.peek
            ? _peekFraction
            : 1,
      ));

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(CamoCarousel<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_changed);
      _controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _own?.dispose();
    super.dispose();
  }

  void _changed() {
    final page = (_controller.page ?? 0).round();
    if (page != _page) setState(() => _page = page);
  }

  void _go(int page) => _controller.animateToPage(
    page.clamp(0, widget.items.length - 1),
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final backward = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == forward) {
      _go(_page + 1);
    } else if (key == backward) {
      _go(_page - 1);
    } else if (key == LogicalKeyboardKey.home) {
      _go(0);
    } else if (key == LogicalKeyboardKey.end) {
      _go(widget.items.length - 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final skin = Camouflage.skinOf(context, component: 'CamoCarousel');
    final theme = Camouflage.themeOf(context, component: 'CamoCarousel');
    final style = skin.carousel
        .defaults(theme)
        .merge(theme.components.carousel);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final buttons =
        (widget.showButtons ??
            Camouflage.environmentOf(context).input == InputMode.pointer) &&
        items.length > 1;
    final last = items.length - 1;
    Widget button(CarouselDirection direction, bool enabled) => _NavButton(
      direction: direction,
      shown: rtl
          ? (direction == CarouselDirection.previous
                ? CarouselDirection.next
                : CarouselDirection.previous)
          : direction,
      enabled: enabled,
      onPressed: () =>
          _go(_page + (direction == CarouselDirection.previous ? -1 : 1)),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Focus(
        onKeyEvent: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The pager fills the height it is given (a PageView needs one); the dots sit below it.
            Flexible(
              child: skin.carousel.renderContainer(
                context,
                CarouselState(
                  page: _page,
                  pageCount: items.length,
                  layout: widget.layout,
                ),
                theme,
                style,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: _controller,
                      itemCount: items.length,
                      padEnds: widget.layout == CarouselLayout.paged,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: style.itemSpacing / 2,
                        ),
                        child: Semantics(
                          label: 'item ${i + 1} of ${items.length}',
                          container: true,
                          child: skin.carousel.renderItem(
                            context,
                            theme,
                            style,
                            widget.itemBuilder(context, items[i]),
                          ),
                        ),
                      ),
                    ),
                    if (buttons) ...[
                      PositionedDirectional(
                        start: 0,
                        child: button(CarouselDirection.previous, _page > 0),
                      ),
                      PositionedDirectional(
                        end: 0,
                        child: button(CarouselDirection.next, _page < last),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.showIndicator && items.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: CamoPagination(
                    pageCount: items.length,
                    page: _page,
                    variant: PaginationVariant.dots,
                    onPageChanged: _go,
                    semanticLabel: '${widget.semanticLabel} pages',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.direction,
    required this.shown,
    required this.enabled,
    required this.onPressed,
  });

  final CarouselDirection direction;
  final CarouselDirection shown;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoCarousel');
    final theme = Camouflage.themeOf(context, component: 'CamoCarousel');
    final style = skin.carousel
        .defaults(theme)
        .merge(theme.components.carousel);
    return CamoBehavior(
      controller: _interaction,
      enabled: widget.enabled,
      onActivate: widget.onPressed,
      semantics: (child) => Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.direction == CarouselDirection.previous
            ? 'Previous item'
            : 'Next item',
        excludeSemantics: true,
        child: child,
      ),
      child: CamoTouchTarget(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListenableBuilder(
            listenable: _interaction,
            builder: (context, _) => skin.carousel.renderButton(
              context,
              CarouselButtonState(
                direction: widget.shown,
                enabled: widget.enabled,
                interaction: _interaction.value,
                controller: _interaction,
              ),
              theme,
              style,
            ),
          ),
        ),
      ),
    );
  }
}
