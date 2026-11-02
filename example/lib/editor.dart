import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

// The M9 milestone screen: an editor whose toolbars use a split button, command and toggle groups and an
// overflowing action bar, with a popover from the toolbar and a properties side sheet beside the document.

/// An editor with a command bar, an action bar, a popover and a properties side sheet.
class EditorDemo extends StatefulWidget {
  /// Creates the demo.
  const EditorDemo({super.key});

  @override
  State<EditorDemo> createState() => _EditorDemoState();
}

class _EditorDemoState extends State<EditorDemo> {
  var _bold = false;
  var _italic = false;
  var _underline = false;
  var _starred = false;
  var _properties = true;
  var _linkOpen = false;
  var _last = 'Nothing yet';

  String get _style => [
    if (_bold) 'bold',
    if (_italic) 'italic',
    if (_underline) 'underline',
  ].join(', ');

  void _did(String command) => setState(() => _last = command);

  Widget _commandBar() => CamoToolbarContainer(
    semanticLabel: 'Document commands',
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: Camouflage.spacingOf(context).m,
        children: [
          CamoSplitButton(
            text: 'Save',
            onPressed: () => _did('Save'),
            menu: [
              CamoMenuItem(text: 'Save as…', onPressed: () => _did('Save as')),
              CamoMenuItem(
                text: 'Save a copy',
                onPressed: () => _did('Save a copy'),
              ),
              const CamoMenuDivider(),
              CamoMenuItem(
                text: 'Export as PDF',
                onPressed: () => _did('Export'),
              ),
            ],
          ),
          CamoButtonGroup(
            semanticLabel: 'Clipboard',
            buttons: [
              for (final t in ['Cut', 'Copy', 'Paste'])
                CamoGroupButton(id: t, text: t, onPressed: () => _did(t)),
            ],
          ),
          CamoButtonGroup(
            semanticLabel: 'Text style',
            connected: false,
            buttons: [
              CamoGroupButton(
                id: 'b',
                text: 'B',
                semanticLabel: 'Bold',
                selected: _bold,
                onPressed: () => setState(() => _bold = !_bold),
              ),
              CamoGroupButton(
                id: 'i',
                text: 'I',
                semanticLabel: 'Italic',
                selected: _italic,
                onPressed: () => setState(() => _italic = !_italic),
              ),
              CamoGroupButton(
                id: 'u',
                text: 'U',
                semanticLabel: 'Underline',
                selected: _underline,
                onPressed: () => setState(() => _underline = !_underline),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _actionBar() => CamoToolbar(
    placement: ToolbarPlacement.floating,
    semanticLabel: 'Document actions',
    actions: [
      CamoToolbarAction(
        id: 'star',
        label: 'Star',
        icon: const AppIcon.star(),
        selected: _starred,
        onPressed: () => setState(() => _starred = !_starred),
      ),
      CamoToolbarAction(
        id: 'share',
        label: 'Share',
        icon: const AppIcon.share(),
        onPressed: () => _did('Share'),
      ),
      CamoToolbarAction(
        id: 'upload',
        label: 'Upload',
        icon: const AppIcon.upload(),
        onPressed: () => _did('Upload'),
      ),
      CamoToolbarAction(
        id: 'archive',
        label: 'Archive',
        icon: const AppIcon.archive(),
        onPressed: () => _did('Archive'),
      ),
      CamoToolbarAction(
        id: 'delete',
        label: 'Delete',
        icon: const AppIcon.delete(),
        onPressed: () => _did('Delete'),
      ),
    ],
    leading: CamoPopover(
      open: _linkOpen,
      onDismissRequest: () => setState(() => _linkOpen = false),
      anchor: CamoButton(
        text: 'Link',
        appearance: Appearance.ghost,
        onPressed: () => setState(() => _linkOpen = !_linkOpen),
      ),
      title: 'Insert link',
      actions: CamoButton(
        text: 'Insert',
        onPressed: () => setState(() {
          _linkOpen = false;
          _last = 'Insert link';
        }),
      ),
      child: const CamoText('Paste a URL to link the selected text.'),
    ),
    trailing: CamoIconButton(
      icon: const AppIcon.edit(),
      semanticLabel: 'Properties',
      checked: _properties,
      onPressed: () => setState(() => _properties = !_properties),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Camouflage.spacingOf(context).m,
    children: [
      _commandBar(),
      _actionBar(),
      // A docked sheet keeps its width on a wide window and gives way to the document on a narrow one.
      SizedBox(
        height: 240,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(Camouflage.spacingOf(context).m),
                  child: CamoText(
                    'Last command: $_last. '
                    'Text style: ${_style.isEmpty ? 'plain' : _style}.',
                  ),
                ),
              ),
              if (_properties)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.6,
                  ),
                  child: CamoSideSheet(
                    title: 'Properties',
                    onClose: () => setState(() => _properties = false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        CamoText('Starred: ${_starred ? 'yes' : 'no'}'),
                        const CamoText('Words: 214'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
