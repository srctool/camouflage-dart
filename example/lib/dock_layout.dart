import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

// The M16 dock layout: five tool windows on three edges. Tap a stripe button to toggle a window, drag a divider,
// use a window's menu to move it, maximize or hide it. "Show Log" moves keyboard focus into a window; Esc returns it
// to the editor. The layout is app state: "Save layout" keeps a snapshot, "Restore" brings it back.

// A stripe button's icon takes the skin's tint, so an open window shows in every skin (Material colors the icon).
const _windows = <(String, String, DockEdge, Widget)>[
  ('files', 'Files', DockEdge.left, AppIcon.archive()),
  ('search', 'Search', DockEdge.left, AppIcon.search()),
  ('details', 'Details', DockEdge.right, AppIcon.edit()),
  ('log', 'Log', DockEdge.bottom, AppIcon.sort()),
  ('terminal', 'Terminal', DockEdge.bottom, AppIcon.chevronRight()),
];

/// The dock layout sample.
class DockLayoutDemo extends StatefulWidget {
  /// Creates the sample.
  const DockLayoutDemo({super.key});

  @override
  State<DockLayoutDemo> createState() => _DockLayoutDemoState();
}

class _DockLayoutDemoState extends State<DockLayoutDemo> {
  final _state = CamoDockState(
    {for (final (id, _, edge, _) in _windows) id: edge},
    open: {'files', 'log'},
  );
  CamoDockSnapshot? _saved;
  int _opened = 0;

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      Wrap(
        spacing: 8,
        children: [
          CamoButton(
            text: 'Save layout',
            appearance: Appearance.outline,
            onPressed: () => _saved = _state.snapshot(),
          ),
          CamoButton(
            text: 'Restore',
            appearance: Appearance.outline,
            onPressed: () {
              final saved = _saved;
              if (saved != null) _state.apply(saved);
            },
          ),
          CamoButton(
            text: 'Show Log',
            appearance: Appearance.outline,
            onPressed: () => _state.focus('log'),
          ),
        ],
      ),
      SizedBox(
        height: 480,
        child: CamoDockLayout(
          state: _state,
          toolWindows: [
            for (final (id, title, edge, icon) in _windows)
              CamoToolWindow(
                id: id,
                title: title,
                icon: icon,
                defaultEdge: edge,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      CamoText('$title tool window'),
                      // Something to focus: `focus(id)` lands here, Esc leaves.
                      CamoButton(
                        text: 'Refresh',
                        appearance: Appearance.outline,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
          ],
          center: CamoSurface(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const CamoText(
                    'Editor: the center. Esc inside a tool window comes back here.',
                  ),
                  CamoButton(
                    text: 'Open file',
                    appearance: Appearance.outline,
                    onPressed: () => setState(() => _opened++),
                  ),
                  CamoText('Files opened: $_opened'),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
