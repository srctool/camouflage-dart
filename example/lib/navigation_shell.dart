import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

// The M8 milestone screen: one set of destinations as a bar on a phone, a rail on a tablet and a drawer on a
// desktop window, with the same selection and the same screen state. The window sizes are simulated by the
// segmented control (a window can't resize inside this page); a real app just reads the window.

enum _Destination {
  home('Home'),
  inbox('Inbox'),
  search('Search'),
  profile('Profile');

  const _Destination(this.label);

  final String label;
}

const _sizes = {
  WindowSizeClass.compact: 360.0,
  WindowSizeClass.medium: 640.0,
  WindowSizeClass.large: 960.0,
};
const _shellHeight = 360.0;

List<CamoNavItem<_Destination>> _destinations() => [
  for (final d in _Destination.values)
    CamoNavItem<_Destination>(
      value: d,
      label: d.label,
      icon: const AppIcon.star(),
      badge: d == _Destination.inbox
          ? const CamoBadge(count: 3, semanticLabel: '3 unread')
          : null,
    ),
];

/// A navigation shell whose layout follows a simulated window size.
class NavigationShellDemo extends StatefulWidget {
  /// Creates the demo.
  const NavigationShellDemo({super.key});

  @override
  State<NavigationShellDemo> createState() => _NavigationShellDemoState();
}

class _NavigationShellDemoState extends State<NavigationShellDemo> {
  var _size = WindowSizeClass.compact;
  var _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final base = Camouflage.environmentOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Camouflage.spacingOf(context).m,
      children: [
        CamoSegmentedControl<WindowSizeClass>(
          options: [for (final s in _sizes.keys) Segment(s, label: s.name)],
          selected: _size,
          onChanged: (s) => setState(() => _size = s),
        ),
        // The simulated window: its own environment, so the chrome picks the layout for the chosen size.
        CamouflageProvider(
          environment: base.copyWith(windowSize: _size),
          child: SizedBox(
            width: _sizes[_size],
            height: _shellHeight,
            child: ClipRect(
              child: Stack(
                children: [
                  _Shell(
                    size: _size,
                    onMenu: () => setState(() => _menuOpen = true),
                  ),
                  if (_size == WindowSizeClass.compact)
                    CamoModalDrawer(
                      open: _menuOpen,
                      onDismissRequest: () => setState(() => _menuOpen = false),
                      child: CamoNavigationDrawer<_Destination>(
                        sections: [CamoNavSection(items: _destinations())],
                        selected: _Destination.home,
                        onChanged: (_) {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({required this.size, required this.onMenu});

  final WindowSizeClass size;
  final VoidCallback onMenu;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  var _selected = _Destination.home;

  @override
  Widget build(BuildContext context) => CamoAdaptiveNavigation<_Destination>(
    items: _destinations(),
    selected: _selected,
    onChanged: (d) => setState(() => _selected = d),
    header: CamoFab(
      icon: const AppIcon.edit(),
      semanticLabel: 'Compose',
      onPressed: () {},
    ),
    child: _Screen(
      destination: _selected,
      size: widget.size,
      onMenu: widget.onMenu,
    ),
  );
}

// The screen keeps its taps when the layout changes: its state moves with it.
class _Screen extends StatefulWidget {
  const _Screen({
    required this.destination,
    required this.size,
    required this.onMenu,
  });

  final _Destination destination;
  final WindowSizeClass size;
  final VoidCallback onMenu;

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(Camouflage.spacingOf(context).l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Camouflage.spacingOf(context).m,
      children: [
        CamoText(
          '${widget.destination.label} (${widget.size.name} window)',
          style: Camouflage.typographyOf(context).titleMedium,
        ),
        CamoText(
          'The screen keeps its state when the layout changes: $_taps taps.',
        ),
        CamoButton(text: 'Tap', onPressed: () => setState(() => _taps++)),
        if (widget.size == WindowSizeClass.compact)
          CamoButton(text: 'Menu (modal drawer)', onPressed: widget.onMenu),
      ],
    ),
  );
}
