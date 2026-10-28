import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

// The base Overlays samples: a sheet and dialogs in their own widgets, each with a `show` returning its result,
// the same content as the Kotlin sample.

const _countries = [
  'Indonesia',
  'Japan',
  'Netherlands',
  'New Zealand',
  'Singapore',
];

/// The country picker: a sheet in its own widget, returning the picked country.
class CountryPickerSheet extends StatelessWidget {
  /// Creates the sheet.
  const CountryPickerSheet({super.key});

  /// Opens it; `null` when dismissed.
  static Future<String?> show(BuildContext context) =>
      showCamoBottomSheet<String>(
        context: context,
        builder: (_) => const CountryPickerSheet(),
      );

  @override
  Widget build(BuildContext context) => CamoBottomSheet(
    title: 'Choose country',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in _countries)
          CamoListItem(headline: c, onPressed: () => Navigator.pop(context, c)),
      ],
    ),
  );
}

/// A destructive confirmation: `true` to delete.
class DeleteItemDialog extends StatelessWidget {
  /// Creates the dialog.
  const DeleteItemDialog({super.key});

  /// Opens it; `null` when dismissed.
  static Future<bool?> show(BuildContext context) => showCamoDialog<bool>(
    context: context,
    builder: (_) => const DeleteItemDialog(),
  );

  @override
  Widget build(BuildContext context) => CamoDialog(
    title: 'Delete item?',
    message: "This can't be undone.",
    confirm: CamoButton(
      text: 'Delete',
      tone: Tone.error,
      onPressed: () => Navigator.pop(context, true),
    ),
    dismiss: CamoButton(
      text: 'Cancel',
      appearance: Appearance.ghost,
      onPressed: () => Navigator.pop(context, false),
    ),
  );
}

/// A choice in custom content: the chosen order, or `null` when cancelled.
class SortOrderDialog extends StatefulWidget {
  /// Creates the dialog.
  const SortOrderDialog({super.key});

  /// Opens it.
  static Future<String?> show(BuildContext context) => showCamoDialog<String>(
    context: context,
    builder: (_) => const SortOrderDialog(),
  );

  @override
  State<SortOrderDialog> createState() => _SortOrderDialogState();
}

class _SortOrderDialogState extends State<SortOrderDialog> {
  String _selected = 'Newest';

  @override
  Widget build(BuildContext context) => CamoDialog(
    title: 'Sort by',
    message: 'Choose how items are ordered.',
    confirm: CamoButton(
      text: 'Apply',
      onPressed: () => Navigator.pop(context, _selected),
    ),
    dismiss: CamoButton(
      text: 'Cancel',
      appearance: Appearance.ghost,
      onPressed: () => Navigator.pop(context),
    ),
    content: CamoRadioGroup<String>(
      value: _selected,
      onChanged: (v) => setState(() => _selected = v),
      options: const [
        RadioOption('Newest', 'Newest'),
        RadioOption('Price', 'Price'),
        RadioOption('Rating', 'Rating'),
      ],
    ),
  );
}

/// Buttons that open the overlays and show what they returned.
class OverlayDemo extends StatefulWidget {
  /// Creates the demo.
  const OverlayDemo({super.key});

  @override
  State<OverlayDemo> createState() => _OverlayDemoState();
}

class _OverlayDemoState extends State<OverlayDemo> {
  String? _country;
  bool _deleted = false;
  String _order = 'Newest';

  @override
  Widget build(BuildContext context) {
    final theme = Camouflage.themeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.spacing.s,
      children: [
        CamoText(
          'Country: ${_country ?? 'none'} · Sort: $_order · '
          '${_deleted ? 'Item deleted' : 'Item kept'}',
        ),
        Wrap(
          spacing: theme.spacing.s,
          runSpacing: theme.spacing.s,
          children: [
            CamoButton(
              text: 'Choose country',
              onPressed: () async {
                final c = await CountryPickerSheet.show(context);
                if (c != null) setState(() => _country = c);
              },
            ),
            CamoButton(
              text: 'Delete item',
              appearance: Appearance.outline,
              tone: Tone.error,
              onPressed: () async {
                final yes = await DeleteItemDialog.show(context);
                if (yes != null) setState(() => _deleted = yes);
              },
            ),
            CamoButton(
              text: 'Sort by',
              appearance: Appearance.outline,
              onPressed: () async {
                final o = await SortOrderDialog.show(context);
                if (o != null) setState(() => _order = o);
              },
            ),
          ],
        ),
      ],
    );
  }
}
