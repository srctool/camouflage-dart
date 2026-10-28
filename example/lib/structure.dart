import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

const _pageSize = 10;
const _pages = 5;
const _fakePage = Duration(seconds: 1);

/// A settings screen: a top bar that separates when the list scrolls under it, sections with switches.
class SettingsScreen extends StatefulWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scroll = ScrollController();
  late final _offset = CamoTopBarScrollOffset(_scroll);
  bool _wifi = true;
  bool _bluetooth = false;
  bool _backup = true;

  @override
  void dispose() {
    _offset.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 420,
    child: Column(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: _offset,
          builder: (context, offset, _) => CamoTopBar(
            title: 'Settings',
            insets: EdgeInsets.zero,
            scrollOffset: offset,
            navigation: CamoIconButton(
              icon: const AppIcon.back(),
              semanticLabel: 'Back',
              onPressed: () {},
            ),
            actions: [
              CamoIconButton(
                icon: const AppIcon.search(),
                semanticLabel: 'Search settings',
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CamoListSection(
                  title: 'Network',
                  children: [
                    CamoListItem(
                      headline: 'Wi-Fi',
                      leading: const AppIcon.star(),
                      trailing: CamoSwitch(checked: _wifi, onChanged: null),
                      onPressed: () => setState(() => _wifi = !_wifi),
                    ),
                    CamoListItem(
                      headline: 'Bluetooth',
                      supporting: _bluetooth ? 'On' : 'Off',
                      leading: const AppIcon.star(),
                      trailing: CamoSwitch(
                        checked: _bluetooth,
                        onChanged: null,
                      ),
                      onPressed: () => setState(() => _bluetooth = !_bluetooth),
                    ),
                    CamoListItem(
                      headline: 'VPN',
                      supporting: 'Not connected',
                      leading: const AppIcon.star(),
                      trailing: const AppIcon.chevronRight(),
                      onPressed: () {},
                    ),
                  ],
                ),
                CamoListSection(
                  title: 'Account',
                  footer: 'Backups run at night on Wi-Fi.',
                  children: [
                    CamoListItem(
                      headline: 'Back up photos',
                      trailing: CamoCheckbox(checked: _backup, onChanged: null),
                      onPressed: () => setState(() => _backup = !_backup),
                    ),
                    CamoListItem(
                      headline: 'Storage',
                      overline: 'Plan',
                      supporting: '12 GB of 15 GB used',
                      onPressed: () {},
                    ),
                    CamoListItem(headline: 'Sign out', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

enum _Plan {
  free('Free', '0'),
  pro('Pro', '9'),
  team('Team', '29');

  const _Plan(this.label, this.price);

  final String label;
  final String price;
}

/// Cards: the four appearances, a status panel, pick-one plan cards, and a clickable card.
class Cards extends StatefulWidget {
  /// Creates the cards.
  const Cards({super.key});

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  _Plan _plan = _Plan.pro;
  int _opened = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    final pad = EdgeInsets.all(theme.spacing.m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing.s,
      children: [
        Row(
          spacing: theme.spacing.s,
          children: [
            for (final a in [
              Appearance.solid,
              Appearance.soft,
              Appearance.raised,
              Appearance.outline,
            ])
              Expanded(
                child: CamoCard(
                  appearance: a,
                  child: Padding(
                    padding: pad,
                    // Capitalized: the names alone are the buttons' labels.
                    child: CamoText(
                      '${a.name[0].toUpperCase()}${a.name.substring(1)}',
                    ),
                  ),
                ),
              ),
          ],
        ),
        CamoCard(
          appearance: Appearance.soft,
          tone: Tone.warning,
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.l),
            child: const CamoText('Only 3 left in stock.'),
          ),
        ),
        Semantics(
          explicitChildNodes: true,
          child: Row(
            spacing: theme.spacing.s,
            children: [
              for (final p in _Plan.values)
                Expanded(
                  child: Semantics(
                    inMutuallyExclusiveGroup: true,
                    child: CamoCard(
                      onPressed: () => setState(() => _plan = p),
                      selected: _plan == p,
                      child: Padding(
                        padding: pad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CamoText(
                              p.label,
                              style: theme.typography.titleSmall,
                            ),
                            CamoText(
                              '\$${p.price} a month',
                              style: theme.typography.bodySmall,
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
        CamoCard(
          onPressed: () => setState(() => _opened++),
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CamoText(
                  'Getting started',
                  style: theme.typography.titleMedium,
                ),
                CamoText(
                  _opened == 0
                      ? 'Tap to open the guide.'
                      : 'Opened $_opened times.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// An FAQ that opens one answer at a time, and product panels, one with a form that keeps its input.
class Faq extends StatefulWidget {
  /// Creates the FAQ.
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  Set<String> _open = {};
  bool _details = true;
  bool _note = false;
  String _message = '';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CamoAccordionGroup<String>(
        expanded: _open,
        onExpandedChanged: (v) => setState(() => _open = v),
        singleExpand: true,
        items: const [
          CamoAccordionItem(
            key: 'ship',
            title: 'How long does shipping take?',
            child: CamoText('Two to four working days.'),
          ),
          CamoAccordionItem(
            key: 'returns',
            title: 'Can I return an item?',
            child: CamoText('Within 30 days, unused.'),
          ),
          CamoAccordionItem(
            key: 'pay',
            title: 'Which payment methods work?',
            child: CamoText('Cards, bank transfer and wallets.'),
          ),
        ],
      ),
      CamoAccordion(
        title: 'Details',
        subtitle: 'Size, material',
        expanded: _details,
        onExpansionChanged: (v) => setState(() => _details = v),
        child: const CamoText('Cotton, regular fit.'),
      ),
      CamoAccordion(
        title: 'Gift note',
        subtitle: 'Kept when closed',
        expanded: _note,
        onExpansionChanged: (v) => setState(() => _note = v),
        child: CamoTextField(
          value: _message,
          onChanged: (v) => setState(() => _message = v),
          label: 'Message',
        ),
      ),
    ],
  );
}

/// A profile header while it loads: skeletons sharing one shimmer.
class LoadingProfile extends StatelessWidget {
  /// Creates the placeholder.
  const LoadingProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return CamoSkeletonGroup(
      child: Row(
        spacing: theme.spacing.m,
        children: [
          const CamoSkeleton.circle(size: 48),
          Expanded(
            child: CamoSkeleton.text(
              lines: 2,
              style: theme.typography.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A fake paged API: [_pages] pages of products, one second each, filtered by a query; page 3 can fail.
class _FakeProducts {
  bool failPage3 = false;

  Future<List<String>> page(String query, int page) async {
    await Future<void>.delayed(_fakePage);
    if (failPage3 && page == 2) throw StateError("Couldn't load page 3");
    final all = [for (var i = 1; i <= _pages * _pageSize; i++) 'Product $i']
        .where((p) => p.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return all.skip(page * _pageSize).take(_pageSize).toList();
  }
}

/// A product list on the fake API: paging, a failing page 3 with retry, refresh, and a search in the header.
class Products extends StatefulWidget {
  /// Creates the list.
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final _api = _FakeProducts();
  String _query = '';
  var _state = const CamoPagedListState<String>(loading: PagedLoad.initial);
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load(PagedLoad.initial);
  }

  // The newest request wins: a response for an older query is dropped.
  Future<void> _load(PagedLoad kind) async {
    final keep = kind == PagedLoad.more ? _state.items : const <String>[];
    final request = ++_request;
    setState(() => _state = CamoPagedListState(items: keep, loading: kind));
    try {
      final items = await _api.page(_query, keep.length ~/ _pageSize);
      if (!mounted || request != _request) return;
      setState(
        () => _state = CamoPagedListState(
          items: [...keep, ...items],
          endReached: items.length < _pageSize,
        ),
      );
    } on StateError catch (e) {
      if (!mounted || request != _request) return;
      setState(
        () => _state = CamoPagedListState(
          items: keep,
          error: PagedError(
            message: e.message,
            scope: keep.isEmpty
                ? PagedErrorScope.firstPage
                : PagedErrorScope.nextPage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing.s,
      children: [
        Wrap(
          spacing: theme.spacing.s,
          runSpacing: theme.spacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CamoCheckbox(
              checked: _api.failPage3,
              onChanged: (v) => setState(() => _api.failPage3 = v),
              label: 'Fail page 3',
            ),
            CamoButton(
              text: 'Refresh',
              onPressed: () => _load(PagedLoad.refresh),
              appearance: Appearance.outline,
            ),
          ],
        ),
        SizedBox(
          height: 420,
          child: CamoPagedList<String>(
            state: _state,
            itemKey: (p) => p,
            onLoadMore: () => _load(PagedLoad.more),
            onRetry: () => _load(
              _state.items.isEmpty ? PagedLoad.initial : PagedLoad.more,
            ),
            onRefresh: () => _load(PagedLoad.refresh),
            itemBuilder: (context, product, _) => CamoListItem(
              headline: product,
              supporting: 'In stock',
              onPressed: () {},
            ),
            header: Padding(
              padding: EdgeInsets.only(bottom: theme.spacing.s),
              child: CamoSearchField(
                query: _query,
                onChanged: (q) {
                  _query = q;
                  _load(PagedLoad.initial);
                },
                onSubmitted: (_) {},
                placeholder: 'Search products',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
