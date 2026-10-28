import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../list/camo_list_item.dart' show listDivider;
import '../provider/camouflage.dart';
import '../skeleton/camo_skeleton.dart';
import '../theme/camo_theme.dart';

/// Which load is running.
enum PagedLoad {
  /// None.
  none,

  /// The first page, or a new search.
  initial,

  /// A refresh.
  refresh,

  /// The next page.
  more,
}

/// Which page failed.
enum PagedErrorScope {
  /// The first page: nothing to show.
  firstPage,

  /// The next page: the items stay, with a retry row.
  nextPage,
}

/// A failed load: the [message] to show and which page failed.
@immutable
class PagedError {
  /// Creates PagedError.
  const PagedError({required this.message, required this.scope});

  /// What to show.
  final String message;

  /// Which page failed.
  final PagedErrorScope scope;

  @override
  bool operator ==(Object other) =>
      other is PagedError && other.message == message && other.scope == scope;

  @override
  int get hashCode => Object.hash(message, scope);
}

/// Everything a [CamoPagedList] shows. The app (or its data layer, through a small adapter) builds it; the list only reads it. [endReached] means there are no more pages.
@immutable
class CamoPagedListState<T> {
  /// Creates a list state.
  const CamoPagedListState({
    this.items = const [],
    this.loading = PagedLoad.none,
    this.endReached = false,
    this.error,
  });

  /// The loaded items.
  final List<T> items;

  /// Which load is running.
  final PagedLoad loading;

  /// No more pages.
  final bool endReached;

  /// The failed load, if any.
  final PagedError? error;

  @override
  bool operator ==(Object other) =>
      other is CamoPagedListState<T> &&
      identical(other.items, items) &&
      other.loading == loading &&
      other.endReached == endReached &&
      other.error == error;

  @override
  int get hashCode => Object.hash(items, loading, endReached, error);
}

/// The words a paged list shows and announces.
@immutable
class PagedListStrings {
  /// Creates PagedListStrings.
  const PagedListStrings({
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = '',
    this.errorTitle = 'Something went wrong',
    this.retry = 'Retry',
    this.nextPageFailed = "Couldn't load more",
    this.loading = 'Loading',
    this.loadingMore = 'Loading more',
  });

  /// The default empty state's title.
  final String emptyTitle;

  /// The default empty state's message.
  final String emptyMessage;

  /// The default first-page error's title.
  final String errorTitle;

  /// The retry button.
  final String retry;

  /// The retry row's default message.
  final String nextPageFailed;

  /// Announced while the first page loads.
  final String loading;

  /// Announced once while the next page loads.
  final String loadingMore;

  @override
  bool operator ==(Object other) =>
      other is PagedListStrings &&
      other.emptyTitle == emptyTitle &&
      other.emptyMessage == emptyMessage &&
      other.errorTitle == errorTitle &&
      other.retry == retry &&
      other.nextPageFailed == nextPageFailed &&
      other.loading == loading &&
      other.loadingMore == loadingMore;

  @override
  int get hashCode => Object.hash(
    emptyTitle,
    emptyMessage,
    errorTitle,
    retry,
    nextPageFailed,
    loading,
    loadingMore,
  );
}

/// Overrides for paged lists; `null` keeps the skin's default.
@immutable
class CamoPagedListTheme {
  /// Creates CamoPagedListTheme.
  const CamoPagedListTheme({
    this.initialSkeletonCount,
    this.moreSkeletonCount,
    this.prefetchExtent,
    this.refreshKeepsItems,
    this.refreshThreshold,
    this.itemFadeIn,
    this.strings,
  });

  /// Skeleton rows for a first load or a refresh.
  final int? initialSkeletonCount;

  /// Skeleton rows appended while the next page loads.
  final int? moreSkeletonCount;

  /// How close to the end (in pixels) `onLoadMore` fires.
  final double? prefetchExtent;

  /// `true`: a refresh keeps the items and shows only the indicator.
  final bool? refreshKeepsItems;

  /// How far the user pulls past the top before releasing refreshes.
  final double? refreshThreshold;

  /// Items fade in when they replace skeletons.
  final bool? itemFadeIn;

  /// The words it shows and announces.
  final PagedListStrings? strings;

  /// A copy with the given fields replaced.
  CamoPagedListTheme copyWith({
    int? initialSkeletonCount,
    int? moreSkeletonCount,
    double? prefetchExtent,
    bool? refreshKeepsItems,
    double? refreshThreshold,
    bool? itemFadeIn,
    PagedListStrings? strings,
  }) => CamoPagedListTheme(
    initialSkeletonCount: initialSkeletonCount ?? this.initialSkeletonCount,
    moreSkeletonCount: moreSkeletonCount ?? this.moreSkeletonCount,
    prefetchExtent: prefetchExtent ?? this.prefetchExtent,
    refreshKeepsItems: refreshKeepsItems ?? this.refreshKeepsItems,
    refreshThreshold: refreshThreshold ?? this.refreshThreshold,
    itemFadeIn: itemFadeIn ?? this.itemFadeIn,
    strings: strings ?? this.strings,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoPagedListTheme &&
      other.initialSkeletonCount == initialSkeletonCount &&
      other.moreSkeletonCount == moreSkeletonCount &&
      other.prefetchExtent == prefetchExtent &&
      other.refreshKeepsItems == refreshKeepsItems &&
      other.refreshThreshold == refreshThreshold &&
      other.itemFadeIn == itemFadeIn &&
      other.strings == strings;

  @override
  int get hashCode => Object.hash(
    initialSkeletonCount,
    moreSkeletonCount,
    prefetchExtent,
    refreshKeepsItems,
    refreshThreshold,
    itemFadeIn,
    strings,
  );
}

/// The resolved paged list style: every field set.
@immutable
class CamoPagedListStyle {
  /// Creates CamoPagedListStyle.
  const CamoPagedListStyle({
    required this.initialSkeletonCount,
    required this.moreSkeletonCount,
    required this.prefetchExtent,
    required this.refreshKeepsItems,
    required this.refreshThreshold,
    required this.itemFadeIn,
    required this.strings,
  });

  /// Skeleton rows for a first load or a refresh.
  final int initialSkeletonCount;

  /// Skeleton rows appended while the next page loads.
  final int moreSkeletonCount;

  /// How close to the end (in pixels) `onLoadMore` fires.
  final double prefetchExtent;

  /// `true`: a refresh keeps the items and shows only the indicator.
  final bool refreshKeepsItems;

  /// How far the user pulls past the top before releasing refreshes.
  final double refreshThreshold;

  /// Items fade in when they replace skeletons.
  final bool itemFadeIn;

  /// The words it shows and announces.
  final PagedListStrings strings;

  /// This style with [o]'s non-null fields applied.
  CamoPagedListStyle merge(CamoPagedListTheme? o) => o == null
      ? this
      : CamoPagedListStyle(
          initialSkeletonCount: o.initialSkeletonCount ?? initialSkeletonCount,
          moreSkeletonCount: o.moreSkeletonCount ?? moreSkeletonCount,
          prefetchExtent: o.prefetchExtent ?? prefetchExtent,
          refreshKeepsItems: o.refreshKeepsItems ?? refreshKeepsItems,
          refreshThreshold: o.refreshThreshold ?? refreshThreshold,
          itemFadeIn: o.itemFadeIn ?? itemFadeIn,
          strings: o.strings ?? strings,
        );
}

/// What a paged list renderer draws around the rows core lays out. [refreshing] is true from a pull past the
/// threshold until the refresh finishes; [pull] is how far the user has pulled (1 at the threshold, more past
/// it): listen to it while painting, so the pull doesn't rebuild.
@immutable
class PagedListState {
  /// Creates a paged list state.
  const PagedListState({
    required this.loading,
    required this.endReached,
    required this.errorScope,
    required this.isEmpty,
    required this.refreshing,
    required this.pull,
  });

  /// Which load is running.
  final PagedLoad loading;

  /// No more pages.
  final bool endReached;

  /// Which page failed, if any.
  final PagedErrorScope? errorScope;

  /// Loaded with no items.
  final bool isEmpty;

  /// A pull-started refresh is running.
  final bool refreshing;

  /// The pull, as a fraction of the threshold.
  final ValueListenable<double> pull;
}

/// Draws the parts of a paged list that aren't rows: the refresh indicator, the retry row, the empty and error
/// states.
abstract interface class CamoPagedListRenderer {
  /// The complete paged list style for [theme].
  CamoPagedListStyle defaults(CamoTheme theme);

  /// The refresh indicator, placed over the top of the list. Show it while [PagedListState.refreshing], while
  /// the user pulls, and for `PagedLoad.refresh`; draw nothing otherwise.
  Widget refreshIndicator(
    BuildContext context,
    PagedListState state,
    CamoTheme theme,
    CamoPagedListStyle style,
  );

  /// The row after the items when the next page failed: [message] and a retry action calling [onRetry].
  Widget retryRow(
    BuildContext context,
    String message,
    VoidCallback onRetry,
    CamoTheme theme,
    CamoPagedListStyle style,
  );

  /// The default empty state.
  Widget empty(BuildContext context, CamoTheme theme, CamoPagedListStyle style);

  /// The default first-page error: [message] and a retry button calling [onRetry], with [retryFocus] on the
  /// button (core focuses it when the error appears).
  Widget error(
    BuildContext context,
    String message,
    VoidCallback onRetry,
    FocusNode retryFocus,
    CamoTheme theme,
    CamoPagedListStyle style,
  );
}

const _pullResistance = 0.5;

/// A list screen that loads from an API: skeleton rows while a page loads, the next page when the user nears
/// the end, pull to refresh on touch devices, an empty state, and a retry when a page fails. It's controlled:
/// it renders [state] and never fetches. [onLoadMore] fires once per state when the end is within
/// `prefetchExtent`, and never while loading, after `endReached` or with a next-page error. [onRefresh]
/// enables the pull gesture (there's no gesture with a mouse: offer a refresh action too); the indicator stays
/// until its future completes and the state is idle again. [itemKey] must be unique and stable.
class CamoPagedList<T> extends StatefulWidget {
  /// Creates a paged list.
  const CamoPagedList({
    super.key,
    required this.state,
    required this.itemKey,
    required this.onLoadMore,
    required this.onRetry,
    required this.itemBuilder,
    this.controller,
    this.onRefresh,
    this.skeleton,
    this.empty,
    this.firstPageError,
    this.header,
    this.separatorBuilder,
    this.padding,
  });

  /// What to show.
  final CamoPagedListState<T> state;

  /// A stable, unique key per item.
  final Object Function(T item) itemKey;

  /// Load the next page.
  final VoidCallback onLoadMore;

  /// Retry the failed page.
  final VoidCallback onRetry;

  /// One item's row.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// The list's scroll controller.
  final ScrollController? controller;

  /// Enables pull to refresh.
  final Future<void> Function()? onRefresh;

  /// One skeleton row; `null` is `CamoSkeleton.listItem()`.
  final Widget? skeleton;

  /// The empty state; `null` is the skin's.
  final Widget? empty;

  /// The first-page error; `null` is the skin's, with a retry button.
  final Widget Function(BuildContext context, String message)? firstPageError;

  /// Scrolls with the list (a search field, a summary).
  final Widget? header;

  /// A one-off separator; `null` uses `CamoListItemTheme.dividers`.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Around the rows.
  final EdgeInsetsGeometry? padding;

  @override
  State<CamoPagedList<T>> createState() => _CamoPagedListState<T>();
}

class _CamoPagedListState<T> extends State<CamoPagedList<T>> {
  ScrollController? _own;
  ScrollController get _controller =>
      widget.controller ?? (_own ??= ScrollController());
  final _pull = ValueNotifier<double>(0);
  final _fraction = ValueNotifier<double>(0);
  final _retryFocus = FocusNode();
  bool _refreshing = false;
  bool _refreshDone = true;
  CamoPagedListState<T>? _triggeredBy;
  CamoPagedListState<T>? _loadedFor;
  // Keys new in this state (they replace skeletons): each fades in once, when first built.
  final _fresh = <Object>{};

  @override
  void initState() {
    super.initState();
    _focusRetryIfFailed(null);
  }

  @override
  void didUpdateWidget(CamoPagedList<T> old) {
    super.didUpdateWidget(old);
    final s = widget.state;
    if (!identical(s.items, old.state.items)) {
      final before = {for (final it in old.state.items) widget.itemKey(it)};
      _fresh
        ..clear()
        ..addAll(s.items.map(widget.itemKey).where((k) => !before.contains(k)));
    }
    if (s.loading == PagedLoad.more && old.state.loading != PagedLoad.more) {
      final style = _style(context);
      SemanticsService.sendAnnouncement(
        View.of(context),
        style.strings.loadingMore,
        Directionality.of(context),
      );
    }
    _focusRetryIfFailed(old.state);
    _maybeFinishRefresh();
  }

  @override
  void dispose() {
    _own?.dispose();
    _pull.dispose();
    _fraction.dispose();
    _retryFocus.dispose();
    super.dispose();
  }

  CamoPagedListStyle _style(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoPagedList');
    final theme = Camouflage.themeOf(context, component: 'CamoPagedList');
    return skin.pagedList.defaults(theme).merge(theme.components.pagedList);
  }

  bool _firstPageFailed(CamoPagedListState<T> s) =>
      s.error?.scope == PagedErrorScope.firstPage &&
      s.loading == PagedLoad.none;

  void _focusRetryIfFailed(CamoPagedListState<T>? old) {
    if (!_firstPageFailed(widget.state) ||
        (old != null && _firstPageFailed(old)) ||
        widget.firstPageError != null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _retryFocus.requestFocus();
    });
  }

  // Fires once per state that's near the end and can load.
  void _maybeLoadMore() {
    final s = widget.state;
    final canLoad =
        s.loading == PagedLoad.none &&
        !s.endReached &&
        s.error?.scope != PagedErrorScope.nextPage;
    if (!canLoad || identical(_loadedFor, s) || !_controller.hasClients) return;
    final style = _style(context);
    if (_controller.position.extentAfter >= style.prefetchExtent) return;
    _loadedFor = s;
    widget.onLoadMore();
  }

  void _setPull(double pixels) {
    _pull.value = pixels;
    final threshold = _style(context).refreshThreshold;
    _fraction.value = threshold > 0 ? pixels / threshold : 0;
  }

  void _release() {
    final onRefresh = widget.onRefresh;
    if (onRefresh != null &&
        !_refreshing &&
        _pull.value >= _style(context).refreshThreshold) {
      setState(() {
        _refreshing = true;
        _refreshDone = false;
        _triggeredBy = widget.state;
      });
      onRefresh().whenComplete(() {
        if (!mounted) return;
        _refreshDone = true;
        _maybeFinishRefresh();
      });
    }
    _setPull(0);
  }

  void _maybeFinishRefresh() {
    final s = widget.state;
    if (_refreshing &&
        _refreshDone &&
        !identical(s, _triggeredBy) &&
        s.loading == PagedLoad.none) {
      setState(() => _refreshing = false);
      if (_controller.hasClients) {
        final theme = Camouflage.themeOf(context, component: 'CamoPagedList');
        _controller.animateTo(
          0,
          duration: theme.motion.durationMedium,
          curve: theme.motion.easingStandard,
        );
      }
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    final touch = widget.onRefresh != null && !_refreshing;
    if (n is ScrollUpdateNotification) {
      // Bouncing physics (iOS) pull below the top directly.
      if (touch &&
          n.dragDetails != null &&
          n.metrics.pixels < n.metrics.minScrollExtent) {
        _setPull(n.metrics.minScrollExtent - n.metrics.pixels);
      } else if (_pull.value > 0 &&
          n.dragDetails != null &&
          (n.scrollDelta ?? 0) > 0) {
        _setPull((_pull.value - n.scrollDelta!).clamp(0, double.infinity));
      }
      _maybeLoadMore();
    } else if (n is OverscrollNotification) {
      // Clamping physics (Android) report the pull as overscroll at the top.
      if (touch && n.dragDetails != null && n.overscroll < 0) {
        _setPull(_pull.value - n.overscroll * _pullResistance);
      }
    } else if (n is ScrollEndNotification) {
      if (_pull.value > 0) _release();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoPagedList');
    final theme = Camouflage.themeOf(context, component: 'CamoPagedList');
    final style = _style(context);
    final list = skin.listItem.defaults(theme).merge(theme.components.listItem);
    final line = skin.divider.defaults(theme).merge(theme.components.divider);
    final s = widget.state;
    assert(_uniqueKeys(s.items, widget.itemKey));
    final loading = s.loading;
    final firstPageFailed = _firstPageFailed(s);
    final fullSkeleton =
        loading == PagedLoad.initial ||
        (loading == PagedLoad.refresh && !style.refreshKeepsItems);
    final showItems = !fullSkeleton && !firstPageFailed;
    final isEmpty =
        s.items.isEmpty && loading == PagedLoad.none && s.error == null;
    final skeleton = widget.skeleton ?? const CamoSkeleton.listItem();
    final hasHeader = widget.header != null;
    final retry =
        showItems &&
        s.error?.scope == PagedErrorScope.nextPage &&
        loading == PagedLoad.none;
    final more = showItems && loading == PagedLoad.more
        ? style.moreSkeletonCount
        : 0;
    final items = showItems ? s.items.length : 0;
    final head = hasHeader ? 1 : 0;
    final count =
        head +
        (fullSkeleton
            ? style.initialSkeletonCount
            : firstPageFailed || isEmpty
            ? 1
            : items + more + (retry ? 1 : 0));
    final announce = switch (loading) {
      PagedLoad.initial || PagedLoad.refresh => style.strings.loading,
      _ => null,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });

    Widget row(BuildContext context, int i, double viewport) {
      if (hasHeader && i == 0) return widget.header!;
      final j = i - head;
      if (fullSkeleton) return ExcludeSemantics(child: skeleton);
      if (firstPageFailed || isEmpty) {
        final Widget fill = firstPageFailed
            ? (widget.firstPageError?.call(context, s.error!.message) ??
                  skin.pagedList.error(
                    context,
                    s.error!.message,
                    widget.onRetry,
                    _retryFocus,
                    theme,
                    style,
                  ))
            : (widget.empty ?? skin.pagedList.empty(context, theme, style));
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewport),
          child: Center(child: fill),
        );
      }
      if (j < items) {
        final item = s.items[j];
        final key = widget.itemKey(item);
        final Widget built = widget.itemBuilder(context, item, j);
        final Widget faded = _FadeIn(
          animate: _fresh.remove(key) && style.itemFadeIn,
          duration: theme.motion.durationMedium,
          child: built,
        );
        return KeyedSubtree(
          key: ValueKey(key),
          child: j == 0
              ? faded
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.separatorBuilder?.call(context, j - 1) ??
                        listDivider(
                          list.dividers,
                          list.dividerInsetStart,
                          line,
                        ),
                    faded,
                  ],
                ),
        );
      }
      if (j < items + more) return ExcludeSemantics(child: skeleton);
      return skin.pagedList.retryRow(
        context,
        s.error!.message,
        widget.onRetry,
        theme,
        style,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        children: [
          CamoSkeletonGroup(
            active: fullSkeleton || more > 0,
            child: LayoutBuilder(
              builder: (context, constraints) => ListView.builder(
                controller: _controller,
                padding: widget.padding,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: count,
                findChildIndexCallback: (key) {
                  if (key is! ValueKey || !showItems) return null;
                  final index = s.items.indexWhere(
                    (it) => widget.itemKey(it) == key.value,
                  );
                  return index < 0 ? null : index + head;
                },
                itemBuilder: (context, i) =>
                    row(context, i, constraints.maxHeight),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            child: Center(
              child: skin.pagedList.refreshIndicator(
                context,
                PagedListState(
                  loading: loading,
                  endReached: s.endReached,
                  errorScope: s.error?.scope,
                  isEmpty: isEmpty,
                  refreshing: _refreshing,
                  pull: _fraction,
                ),
                theme,
                style,
              ),
            ),
          ),
          // One polite announcement per first load; the skeleton rows themselves are hidden.
          Semantics(
            liveRegion: true,
            label: announce,
            child: const SizedBox(width: 1, height: 1),
          ),
        ],
      ),
    );
  }
}

bool _uniqueKeys<T>(List<T> items, Object Function(T) key) {
  final seen = <Object>{};
  for (final it in items) {
    final k = key(it);
    if (!seen.add(k)) {
      throw FlutterError(
        'CamoPagedList: two items share the key $k. itemKey must be unique.',
      );
    }
  }
  return true;
}

class _FadeIn extends StatefulWidget {
  const _FadeIn({
    required this.animate,
    required this.duration,
    required this.child,
  });

  final bool animate;
  final Duration duration;
  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.animate ? 0 : 1,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _controller, child: widget.child);
}
