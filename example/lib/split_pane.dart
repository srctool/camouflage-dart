import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M16 split pane: a list and a detail side by side, and a log below them that collapses. Drag a divider, focus it
// and press the arrow keys (Shift for a larger step, Home and End, Enter to collapse the log), or double-tap to
// reset. The layout is app state: "Save layout" keeps a snapshot, "Restore" brings it back.

/// The split pane sample.
class SplitPaneDemo extends StatefulWidget {
  /// Creates the sample.
  const SplitPaneDemo({super.key});

  @override
  State<SplitPaneDemo> createState() => _SplitPaneDemoState();
}

class _SplitPaneDemoState extends State<SplitPaneDemo> {
  final _outer = CamoSplitState([3, 1]);
  final _inner = CamoSplitState([1, 2]);
  (CamoSplitSnapshot, CamoSplitSnapshot)? _saved;

  @override
  void dispose() {
    _outer.dispose();
    _inner.dispose();
    super.dispose();
  }

  // A pane may be squeezed to its minimum: the content scrolls.
  Widget _panel(String title, String text) => CamoSurface(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [CamoText(title), CamoText(text)],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        children: [
          CamoButton(
            text: 'Save layout',
            appearance: Appearance.outline,
            onPressed: () => _saved = (_outer.snapshot(), _inner.snapshot()),
          ),
          CamoButton(
            text: 'Restore',
            appearance: Appearance.outline,
            onPressed: () {
              final saved = _saved;
              if (saved == null) return;
              _outer.apply(saved.$1);
              _inner.apply(saved.$2);
            },
          ),
          CamoButton(
            text: 'Reset',
            appearance: Appearance.ghost,
            onPressed: () {
              _outer.reset();
              _inner.reset();
            },
          ),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 320,
        child: CamoSplitPane(
          axis: Axis.vertical,
          state: _outer,
          panes: [
            CamoPane(
              minSize: 120,
              child: CamoSplitPane(
                axis: Axis.horizontal,
                state: _inner,
                panes: [
                  CamoPane(
                    minSize: 100,
                    child: _panel('List', 'Documents, in a column.'),
                  ),
                  CamoPane(
                    minSize: 120,
                    child: _panel('Detail', 'The selected document.'),
                  ),
                ],
              ),
            ),
            CamoPane(
              minSize: 60,
              collapsible: true,
              child: _panel(
                'Log',
                'Collapses; Enter on its divider restores it.',
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
