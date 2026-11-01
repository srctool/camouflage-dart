import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

// The M8 tabs and FAB: a product page with fixed tabs over a page view, a scrollable category bar, and a list
// with an extended FAB that collapses while it scrolls (and hides when scrolling down).

const _productTabs = [
  CamoTab('overview', label: 'Overview'),
  CamoTab('reviews', label: 'Reviews', badge: CamoBadge(count: 12)),
  CamoTab('specs', label: 'Specs'),
];
const _categories = [
  'Phones',
  'Laptops',
  'Audio',
  'Cameras',
  'Wearables',
  'Gaming',
  'Home',
  'Accessories',
];
const _listHeight = 280.0;
const _rows = 24;

/// Tabs over a pager, a scrollable bar and a list with a FAB.
class NavigationDemo extends StatelessWidget {
  /// Creates the demo.
  const NavigationDemo({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).l,
    children: const [_ProductPage(), _CategoryBar(), _MessageList()],
  );
}

class _ProductPage extends StatefulWidget {
  const _ProductPage();

  @override
  State<_ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<_ProductPage> {
  final _controller = PageController();
  late final _sync = CamoTabsPageSync<String>(
    pageController: _controller,
    tabs: _productTabs,
  );

  @override
  void dispose() {
    _sync.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListenableBuilder(
        listenable: _sync,
        builder: (context, _) => CamoTabs<String>(
          selected: _sync.selected,
          onChanged: _sync.select,
          tabs: _productTabs,
          position: _sync,
        ),
      ),
      SizedBox(
        height: 96,
        child: PageView(
          controller: _controller,
          children: [
            for (final tab in _productTabs)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsets.all(Camouflage.spacingOf(context).m),
                  child: CamoText('${tab.label}: swipe or tap a tab'),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _CategoryBar extends StatefulWidget {
  const _CategoryBar();

  @override
  State<_CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<_CategoryBar> {
  var _selected = _categories.first;

  @override
  Widget build(BuildContext context) => CamoTabs<String>(
    selected: _selected,
    onChanged: (v) => setState(() => _selected = v),
    scrollable: true,
    tabs: [for (final c in _categories) CamoTab(c, label: c)],
  );
}

class _MessageList extends StatefulWidget {
  const _MessageList();

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final _controller = ScrollController();
  late final _hide = CamoHideOnScroll(_controller);
  var _scrolling = false;

  @override
  void dispose() {
    _hide.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _listHeight,
    child: Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            final scrolling = switch (n) {
              ScrollStartNotification() || ScrollUpdateNotification() => true,
              ScrollEndNotification() => false,
              _ => _scrolling,
            };
            if (scrolling != _scrolling) setState(() => _scrolling = scrolling);
            return false;
          },
          child: ListView.builder(
            controller: _controller,
            itemCount: _rows,
            itemBuilder: (context, i) => CamoListItem(
              headline: 'Message ${i + 1}',
              supporting: 'Scroll to move the buttons',
            ),
          ),
        ),
        Positioned(
          right: Camouflage.spacingOf(context).m,
          bottom: Camouflage.spacingOf(context).m,
          child: ValueListenableBuilder<bool>(
            valueListenable: _hide,
            builder: (context, visible, _) => CamoFab(
              icon: const AppIcon.edit(),
              semanticLabel: 'Compose message',
              onPressed: () {},
              text: 'Compose',
              expanded: !_scrolling,
              visible: visible,
            ),
          ),
        ),
      ],
    ),
  );
}
