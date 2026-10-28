import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

const _filters = [
  'Open now',
  'Top rated',
  'Free delivery',
  'Vegetarian',
  r'Under $10',
];
const _sorts = ['Relevance', 'Distance', 'Rating', 'Price', 'Newest'];

typedef _Contact = ({String name, Presence? presence, Gradient? photo});

// A "photo": a gradient stands in for an image the app would load (`Image.network`, say).
const List<_Contact> _contacts = [
  (
    name: 'Ada Lovelace',
    presence: Presence.online,
    photo: LinearGradient(colors: [Color(0xFFE6A15C), Color(0xFF8E3B2E)]),
  ),
  (name: 'Grace Hopper', presence: Presence.busy, photo: null),
  (name: 'Alan Turing', presence: Presence.away, photo: null),
  (
    name: 'Barbara Liskov',
    presence: null,
    photo: LinearGradient(colors: [Color(0xFF5C8DE6), Color(0xFF2E3F8E)]),
  ),
  (name: 'Edsger Dijkstra', presence: Presence.offline, photo: null),
];

Widget? _photo(Gradient? gradient) => gradient == null
    ? null
    : DecoratedBox(decoration: BoxDecoration(gradient: gradient));

/// Chips, badges and avatars: filters, a sort row, recipients, suggestions, status tags, badges and contacts.
class DataDisplayDemo extends StatefulWidget {
  /// Creates the demo.
  const DataDisplayDemo({super.key});

  @override
  State<DataDisplayDemo> createState() => _DataDisplayDemoState();
}

class _DataDisplayDemoState extends State<DataDisplayDemo> {
  var _filtersOn = {'Open now'};
  var _sort = {'Relevance'};
  var _recipients = ['Ada Lovelace', 'Grace Hopper', 'Alan Turing'];
  var _unread = 3;

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context);
    final type = Camouflage.themeOf(context).typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.m,
      children: [
        CamoText('Filters (several)', style: type.labelLarge),
        CamoChipGroup<String>(
          options: [for (final f in _filters) ChipOption(f, f)],
          selected: _filtersOn,
          onChanged: (v) => setState(() => _filtersOn = v),
        ),
        CamoText('Sort by (one, scrolls)', style: type.labelLarge),
        CamoChipGroup<String>(
          options: [for (final s in _sorts) ChipOption(s, s)],
          selected: _sort,
          onChanged: (v) => setState(() => _sort = v),
          multiSelect: false,
          layout: ChipLayout.scroll,
          required: true,
        ),
        CamoText('To', style: type.labelLarge),
        Wrap(
          spacing: spacing.s,
          runSpacing: spacing.s,
          children: [
            for (final name in _recipients)
              CamoChip(
                label: name,
                onDeleted: () => setState(
                  () => _recipients = [..._recipients]..remove(name),
                ),
                leading: CamoAvatar(name: name, size: AvatarSize.small),
              ),
          ],
        ),
        Wrap(
          spacing: spacing.s,
          runSpacing: spacing.s,
          children: [
            CamoChip(
              label: 'Add to calendar',
              onPressed: () {},
              leading: const AppIcon.star(),
            ),
            CamoChip(
              label: 'Share',
              onPressed: () {},
              leading: const AppIcon.share(),
            ),
          ],
        ),
        Wrap(
          spacing: spacing.s,
          runSpacing: spacing.s,
          children: const [
            CamoChip(
              label: 'Paid',
              appearance: Appearance.soft,
              tone: Tone.success,
            ),
            CamoChip(
              label: 'Pending',
              appearance: Appearance.soft,
              tone: Tone.warning,
            ),
            CamoChip(
              label: 'Overdue',
              appearance: Appearance.soft,
              tone: Tone.error,
            ),
            CamoChip(label: 'Draft'),
          ],
        ),
        Wrap(
          spacing: spacing.l,
          runSpacing: spacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CamoBadgedBox(
              badge: CamoBadge(
                count: _unread,
                semanticLabel: '$_unread unread',
              ),
              child: CamoIconButton(
                icon: const AppIcon.star(),
                semanticLabel: 'Notifications',
                onPressed: () => setState(() => _unread = 0),
              ),
            ),
            CamoBadgedBox(
              badge: const CamoBadge(count: 128),
              child: CamoIconButton(
                icon: const AppIcon.share(),
                semanticLabel: 'Shared',
                onPressed: () {},
              ),
            ),
            const CamoBadgedBox(
              badge: CamoBadge(),
              child: CamoAvatar(name: 'Grace Hopper'),
            ),
            CamoAvatarGroup(
              avatars: [
                for (final c in _contacts)
                  CamoAvatar(name: c.name, image: _photo(c.photo)),
              ],
            ),
          ],
        ),
        CamoListSection(
          title: 'Contacts',
          children: [
            for (final c in _contacts)
              CamoListItem(
                headline: c.name,
                supporting: c.presence?.name ?? 'No status',
                // The row says the name; the avatar in its leading slot stays decorative.
                leading: CamoAvatar(
                  name: c.name,
                  image: _photo(c.photo),
                  presence: c.presence,
                ),
                onPressed: () {},
              ),
          ],
        ),
      ],
    );
  }
}
