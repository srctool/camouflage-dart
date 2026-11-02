import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The M9 popover and side sheet: a popover from a button, a standard side sheet beside a document, and the same
// sheet as a modal one.

/// A popover, a docked side sheet and a modal one.
class PanelsDemo extends StatefulWidget {
  /// Creates the demo.
  const PanelsDemo({super.key});

  @override
  State<PanelsDemo> createState() => _PanelsDemoState();
}

class _PanelsDemoState extends State<PanelsDemo> {
  var _shared = false;
  var _details = true;
  var _modal = false;

  Widget _sheet({VoidCallback? onClose, Widget? actions}) => CamoSideSheet(
    title: 'Details',
    onClose: onClose,
    actions: actions,
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [CamoText('Size: 4.2 MB'), CamoText('Modified: today')],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).m,
    children: [
      Wrap(
        spacing: Camouflage.spacingOf(context).m,
        runSpacing: Camouflage.spacingOf(context).s,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CamoPopover(
            open: _shared,
            onDismissRequest: () => setState(() => _shared = false),
            anchor: CamoButton(
              text: 'Share',
              onPressed: () => setState(() => _shared = !_shared),
            ),
            title: 'Share this file',
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                CamoButton(
                  text: 'Cancel',
                  appearance: Appearance.ghost,
                  onPressed: () => setState(() => _shared = false),
                ),
                CamoButton(
                  text: 'Copy link',
                  onPressed: () => setState(() => _shared = false),
                ),
              ],
            ),
            child: const CamoText('Anyone with the link can view it.'),
          ),
          CamoButton(
            text: 'Details (docked)',
            appearance: Appearance.outline,
            onPressed: () => setState(() => _details = !_details),
          ),
          CamoButton(
            text: 'Details (modal)',
            appearance: Appearance.outline,
            onPressed: () => setState(() => _modal = true),
          ),
        ],
      ),
      SizedBox(
        height: 220,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Camouflage.spacingOf(context).m),
                child: const CamoText(
                  'The document: it stays usable beside the docked sheet.',
                ),
              ),
            ),
            if (_details)
              _sheet(onClose: () => setState(() => _details = false)),
          ],
        ),
      ),
      CamoModalSideSheet(
        open: _modal,
        onDismissRequest: () => setState(() => _modal = false),
        child: _sheet(
          onClose: () => setState(() => _modal = false),
          actions: CamoButton(
            text: 'Done',
            onPressed: () => setState(() => _modal = false),
          ),
        ),
      ),
    ],
  );
}
