import 'dart:async';

import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/widgets.dart';

import 'app_icon.dart';

// The M7 milestone screen: status everywhere. Tags, badges, progress, snackbars with Undo and banners by tone.

typedef _Mail = ({
  String from,
  String subject,
  String? tag,
  Tone tone,
  bool unread,
});

const List<_Mail> _initialMail = [
  (
    from: 'Ada Lovelace',
    subject: 'Notes on the analytical engine',
    tag: null,
    tone: Tone.defaultTone,
    unread: true,
  ),
  (
    from: 'Billing',
    subject: 'Invoice #1042',
    tag: 'Overdue',
    tone: Tone.error,
    unread: true,
  ),
  (
    from: 'Grace Hopper',
    subject: 'Compiler review on Friday',
    tag: 'Meeting',
    tone: Tone.info,
    unread: false,
  ),
  (
    from: 'Billing',
    subject: 'Invoice #1039',
    tag: 'Paid',
    tone: Tone.success,
    unread: false,
  ),
  (
    from: 'Alan Turing',
    subject: 'Re: the imitation game',
    tag: null,
    tone: Tone.defaultTone,
    unread: true,
  ),
];

const _presences = {
  'Ada Lovelace': Presence.online,
  'Grace Hopper': Presence.busy,
};

enum _Sync { failed, syncing, done }

const _syncTime = Duration(milliseconds: 1500);
const _uploadStep = Duration(milliseconds: 120);
const _step = 0.04;
const _failsAt = 0.6;

/// An inbox: a badged top bar, sync and trial banners, filters, mail with tags, Archive with Undo, uploads.
class InboxScreen extends StatefulWidget {
  /// Creates the screen.
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _mail = [..._initialMail];
  var _sync = _Sync.failed;
  var _trial = true;
  var _filter = {'All'};

  CamoMessenger get _messenger => CamoMessenger.of(context);

  Future<void> _archive(_Mail item) async {
    final index = _mail.indexOf(item);
    setState(() => _mail.remove(item));
    final result = await _messenger.show('Message archived', action: 'Undo');
    if (result == SnackbarResult.actionPerformed && mounted) {
      setState(() => _mail.insert(index.clamp(0, _mail.length), item));
    }
  }

  Future<void> _retrySync() async {
    setState(() => _sync = _Sync.syncing);
    await Future<void>.delayed(_syncTime);
    if (!mounted) return;
    setState(() => _sync = _Sync.done);
    unawaited(_messenger.show('Inbox synced', tone: Tone.success));
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context);
    final unread = _mail.where((m) => m.unread).length;
    final shown = _filter.contains('Unread')
        ? _mail.where((m) => m.unread)
        : _filter.contains('Tagged')
        ? _mail.where((m) => m.tag != null)
        : _mail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.m,
      children: [
        CamoTopBar(
          title: 'Inbox',
          insets: EdgeInsets.zero,
          actions: [
            CamoBadgedBox(
              badge: CamoBadge(count: unread, semanticLabel: '$unread unread'),
              child: CamoIconButton(
                icon: const AppIcon.notifications(),
                semanticLabel: 'Notifications',
                onPressed: () => setState(() {
                  for (var i = 0; i < _mail.length; i++) {
                    final m = _mail[i];
                    _mail[i] = (
                      from: m.from,
                      subject: m.subject,
                      tag: m.tag,
                      tone: m.tone,
                      unread: false,
                    );
                  }
                }),
              ),
            ),
          ],
        ),
        if (_sync == _Sync.syncing)
          const CamoProgressBar(semanticLabel: 'Syncing'),
        if (_sync == _Sync.failed)
          CamoBanner(
            title: "Couldn't sync",
            message: "2 messages couldn't be downloaded.",
            tone: Tone.warning,
            actions: [
              CamoButton(
                text: 'Retry',
                onPressed: _retrySync,
                appearance: Appearance.ghost,
              ),
            ],
          ),
        if (_trial)
          CamoBanner(
            message: 'Your trial ends in 3 days.',
            actions: [
              CamoButton(
                text: 'Upgrade',
                onPressed: () {},
                appearance: Appearance.ghost,
              ),
            ],
            onDismiss: () => setState(() => _trial = false),
          ),
        CamoChipGroup<String>(
          options: [
            for (final f in ['All', 'Unread', 'Tagged']) ChipOption(f, f),
          ],
          selected: _filter,
          onChanged: (v) => setState(() => _filter = v),
          multiSelect: false,
          layout: ChipLayout.scroll,
          required: true,
        ),
        CamoListSection(
          title: 'Messages',
          children: [
            for (final item in shown)
              CamoListItem(
                headline: item.from,
                supporting: item.subject,
                leading: CamoAvatar(
                  name: item.from,
                  presence: _presences[item.from],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.tag != null)
                      CamoChip(
                        label: item.tag!,
                        appearance: Appearance.soft,
                        tone: item.tone,
                      ),
                    CamoIconButton(
                      icon: const AppIcon.archive(),
                      semanticLabel: 'Archive',
                      onPressed: () => _archive(item),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
          ],
        ),
        const _Uploads(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: CamoButton(
            text: 'Send 3 notifications',
            appearance: Appearance.outline,
            onPressed: () {
              for (final text in [
                'Ada replied',
                'Grace mentioned you',
                'Alan shared a file',
              ]) {
                _messenger.show(text);
              }
            },
          ),
        ),
      ],
    );
  }
}

// Two attachments uploading; the second fails part way, with a Retry snackbar.
class _Uploads extends StatefulWidget {
  const _Uploads();

  @override
  State<_Uploads> createState() => _UploadsState();
}

class _UploadsState extends State<_Uploads> {
  var _photo = 0.0;
  var _report = 0.0;
  var _failed = false;
  var _attempt = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // The first attempt stops part way and fails; a retry finishes.
  void _start() {
    final stop = _attempt == 0 ? _failsAt : 1.0;
    setState(() {
      _failed = false;
      _report = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(_uploadStep, (timer) {
      if (_photo >= 1 && _report >= stop) {
        timer.cancel();
        if (_attempt == 0) _fail();
        return;
      }
      setState(() {
        _photo = (_photo + _step).clamp(0, 1);
        _report = (_report + _step).clamp(0, stop);
      });
    });
  }

  Future<void> _fail() async {
    setState(() => _failed = true);
    final result = await CamoMessenger.of(context)
        .show("Couldn't upload report.pdf", action: 'Retry', tone: Tone.error);
    if (result == SnackbarResult.actionPerformed && mounted) {
      _attempt++;
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Camouflage.spacingOf(context);
    Widget upload(String name, double value, Tone tone) => Row(
      spacing: spacing.s,
      children: [
        const AppIcon.upload(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.xs,
            children: [
              CamoText(name),
              CamoProgressBar(value: value, tone: tone, semanticLabel: name),
            ],
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.s,
      children: [
        CamoText(
          'Uploads',
          style: Camouflage.themeOf(context).typography.titleSmall,
        ),
        upload('photo.jpg', _photo, Tone.defaultTone),
        upload(
          _failed ? 'report.pdf · failed' : 'report.pdf',
          _report,
          _failed ? Tone.error : Tone.defaultTone,
        ),
      ],
    );
  }
}
