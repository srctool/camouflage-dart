import 'dart:ui' show CheckedState;

import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/avatar/initials.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// The M7 data display components' tests from their Flutter notes: chip, chip group, badge, avatar.

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    WidgetsApp(
      color: const Color(0xFFFFFFFF),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Directionality(
        textDirection: direction,
        child: CamouflageProvider(
          skin: skinA,
          theme: themeT,
          child: Align(alignment: AlignmentDirectional.topStart, child: child),
        ),
      ),
    );

class _Holder<T> extends StatefulWidget {
  const _Holder(this.initial, this.builder);

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Holder<T>> createState() => _HolderState<T>();
}

class _HolderState<T> extends State<_Holder<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(_value, (v) => setState(() => _value = v));
}

Widget _icon(double size, Color? color) => SizedBox.square(dimension: size);

SemanticsData _data(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).getSemanticsData();

void main() {
  group('chips', () {
    test('the callbacks decide the kind', () {
      expect(
        chipKind(onPressed: () {}, selected: false, onDeleted: () {}),
        ChipKind.filter,
      );
      expect(chipKind(onDeleted: () {}), ChipKind.input);
      expect(chipKind(onPressed: () {}), ChipKind.action);
      expect(chipKind(), ChipKind.tag);
    });

    testWidgets('a filter chip is a toggle that announces its state', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          _Holder<bool>(
            false,
            (on, set) => CamoChip(
              label: 'Open now',
              selected: on,
              onPressed: () => set(!on),
            ),
          ),
        ),
      );
      expect(
        _data(tester, find.text('Open now')).flagsCollection.isChecked,
        CheckedState.isFalse,
      );
      await tester.tap(find.text('Open now'));
      await tester.pump();
      expect(
        _data(tester, find.text('Open now')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      semantics.dispose();
    });

    testWidgets('an action chip is a button and a tag is text', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CamoChip(label: 'Add to calendar', onPressed: () => taps++),
              const CamoChip(label: 'Paid'),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Add to calendar')),
        matchesSemantics(
          label: 'Add to calendar',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await tester.tap(find.text('Add to calendar'));
      expect(taps, 1);
      final tag = _data(tester, find.text('Paid'));
      expect(tag.flagsCollection.isButton, isFalse);
      expect(tag.hasAction(SemanticsAction.tap), isFalse);
      semantics.dispose();
    });

    testWidgets('an input chip is removed by its button and the Delete key', (
      tester,
    ) async {
      final removed = <String>[];
      final grace = FocusNode();
      addTearDown(grace.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              CamoChip(label: 'Ada', onDeleted: () => removed.add('Ada')),
              CamoChip(
                label: 'Grace',
                onDeleted: () => removed.add('Grace'),
                focusNode: grace,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Remove Ada'));
      grace.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      expect(removed, ['Ada', 'Grace']);
    });

    testWidgets('an interactive chip has a full touch target', (tester) async {
      await tester.pumpWidget(
        _app(CamoChip(label: 'Filter', onPressed: () {})),
      );
      expect(tester.getSize(find.byType(CamoChip)).height, 48);
    });

    test('group selection follows the mode', () {
      expect(chipGroupSelection({1}, 2, multiSelect: true, required: false), {
        1,
        2,
      });
      expect(
        chipGroupSelection({1}, 1, multiSelect: true, required: false),
        <int>{},
      );
      expect(chipGroupSelection({1}, 2, multiSelect: false, required: false), {
        2,
      });
      expect(
        chipGroupSelection({1}, 1, multiSelect: false, required: false),
        <int>{},
      );
      expect(chipGroupSelection({1}, 1, multiSelect: false, required: true), {
        1,
      });
    });

    testWidgets('a single-choice group is a radio group that keeps a required '
        'choice', (tester) async {
      final semantics = tester.ensureSemantics();
      var picked = {'Newest'};
      await tester.pumpWidget(
        _app(
          _Holder<Set<String>>(
            {'Newest'},
            (selected, set) => CamoChipGroup<String>(
              options: const [
                ChipOption('Newest', 'Newest'),
                ChipOption('Oldest', 'Oldest'),
              ],
              selected: selected,
              onChanged: (v) {
                picked = v;
                set(v);
              },
              multiSelect: false,
              required: true,
            ),
          ),
        ),
      );
      final newest = _data(tester, find.text('Newest'));
      expect(newest.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(newest.flagsCollection.isChecked, CheckedState.isTrue);
      await tester.tap(find.text('Newest'));
      await tester.pump();
      expect(picked, {'Newest'});
      await tester.tap(find.text('Oldest'));
      await tester.pump();
      expect(picked, {'Oldest'});
      semantics.dispose();
    });

    testWidgets('a multi-select group toggles each chip', (tester) async {
      var picked = <int>{};
      await tester.pumpWidget(
        _app(
          _Holder<Set<int>>(
            {},
            (selected, set) => CamoChipGroup<int>(
              options: [
                for (var i = 1; i <= 3; i++) ChipOption(i, 'Option $i'),
              ],
              selected: selected,
              onChanged: (v) {
                picked = v;
                set(v);
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Option 1'));
      await tester.pump();
      await tester.tap(find.text('Option 3'));
      await tester.pump();
      expect(picked, {1, 3});
      await tester.tap(find.text('Option 1'));
      await tester.pump();
      expect(picked, {3});
    });

    testWidgets('the arrow keys bring a focused chip into view in a scrolling '
        'group', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 200,
            child: CamoChipGroup<int>(
              options: [for (var i = 1; i <= 12; i++) ChipOption(i, 'Chip $i')],
              selected: const {},
              onChanged: (_) {},
              layout: ChipLayout.scroll,
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // Left from the first chip wraps to the last one, far off screen.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      final last = tester.getRect(find.text('Chip 12'));
      expect(last.right, lessThanOrEqualTo(200));
      expect(last.left, greaterThanOrEqualTo(0));
    });
  });

  group('badges', () {
    test('the badge text caps at max', () {
      expect(badgeText(null, 99), isNull);
      expect(badgeText(3, 99), '3');
      expect(badgeText(100, 99), '99+');
      expect(badgeText(10, 9), '9+');
    });

    testWidgets('an icon button announces its badge', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          CamoBadgedBox(
            badge: const CamoBadge(count: 3),
            child: CamoIconButton(
              icon: const CamoIcon(IconSource.builder(_icon)),
              semanticLabel: 'Notifications',
              onPressed: () {},
            ),
          ),
        ),
      );
      final data = _data(tester, find.byType(CamoBadgedBox));
      expect(data.label, 'Notifications');
      expect(data.value, '3 new');
      expect(data.flagsCollection.isButton, isTrue);
      semantics.dispose();
    });

    testWidgets('zero hides the badge and its description', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const CamoBadgedBox(
            badge: CamoBadge(count: 0),
            child: CamoIcon(IconSource.builder(_icon), semanticLabel: 'Inbox'),
          ),
        ),
      );
      expect(_data(tester, find.byType(CamoBadgedBox)).value, '');
      expect(find.text('0'), findsNothing);
      semantics.dispose();
    });

    testWidgets('the badge sits on the top-end corner in both directions', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _app(
            const CamoBadgedBox(
              badge: CamoBadge(),
              child: SizedBox.square(dimension: 24),
            ),
            direction: direction,
          ),
        );
        await tester.pumpAndSettle();
        final anchor = tester.getRect(find.byType(SizedBox).first);
        final badge = tester.getRect(
          find.descendant(
            of: find.byType(CamoBadge),
            matching: find.byType(Container),
          ),
        );
        // The test badge's dot is 6 wide, its center 4 in from the end edge and 4 down from the top.
        final expected = direction == TextDirection.rtl ? 1.0 : 17.0;
        expect(badge.left - anchor.left, expected, reason: '$direction');
        expect(badge.top - anchor.top, 1.0, reason: '$direction');
      }
    });
  });

  group('avatars', () {
    test('initials come from the first and last words', () {
      expect(avatarInitials('Dwiki Riyadi'), 'DR');
      expect(avatarInitials('dwiki'), 'D');
      expect(avatarInitials('  Ada  Lovelace King '), 'AK');
      expect(avatarInitials('李小龙'), '李');
      expect(avatarInitials('émile Zola'), 'ÉZ');
      expect(avatarInitials('\u{1F600} Smile'), isNull);
      expect(avatarInitials(''), isNull);
      expect(avatarInitials(null), isNull);
    });

    test('graphemes keep emoji and marks whole', () {
      const indonesia = '\u{1F1EE}\u{1F1E9}';
      const japan = '\u{1F1EF}\u{1F1F5}';
      expect(graphemes(indonesia + japan), [indonesia, japan]);
      expect(graphemes('\u{1F44D}\u{1F3FD}x'), ['\u{1F44D}\u{1F3FD}', 'x']);
      expect(graphemes('\u{1F468}‍\u{1F469}‍\u{1F467}').length, 1);
      expect(graphemes('éa'), ['é', 'a']);
    });

    test('the color seed is FNV-1a of the UTF-8 bytes', () {
      // The same vectors as the Kotlin library's test, so a person gets the same color on both.
      expect(avatarColorSeed('Dwiki Riyadi'), 0xCDC853E9);
      expect(avatarColorSeed('Ada Lovelace'), 0xFE5E7CFE);
      expect(avatarColorSeed('李小龙'), 0x785BAF5E);
      expect(avatarColorSeed(''), 0x811C9DC5);
    });

    testWidgets('an avatar shows initials under the image and says name and '
        'presence', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              CamoAvatar(name: 'Dwiki Riyadi', presence: Presence.online),
              CamoAvatar(name: 'Ada Lovelace', image: Text('photo')),
              CamoAvatar(),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Dwiki Riyadi, online'), findsOneWidget);
      expect(find.text('DR'), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
      expect(find.text('photo'), findsOneWidget);
      expect(
        _data(
          tester,
          find.bySemanticsLabel('Dwiki Riyadi, online'),
        ).flagsCollection.isImage,
        isTrue,
      );
      semantics.dispose();
    });

    testWidgets('an avatar in a list row leaves the name to the row', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: CamoListItem(
              headline: 'Ada Lovelace',
              leading: const CamoAvatar(name: 'Ada Lovelace'),
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(_data(tester, find.text('Ada Lovelace')).label, 'Ada Lovelace');
      expect(find.text('AL'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a group shows max avatars and the rest as a count', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const CamoAvatarGroup(
            avatars: [
              CamoAvatar(name: 'A B'),
              CamoAvatar(name: 'C D'),
              CamoAvatar(name: 'E F'),
              CamoAvatar(name: 'G H'),
              CamoAvatar(name: 'I J'),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('E F'), findsOneWidget);
      expect(find.bySemanticsLabel('2 more'), findsOneWidget);
      expect(find.bySemanticsLabel('G H'), findsNothing);
      semantics.dispose();
    });
  });
}
