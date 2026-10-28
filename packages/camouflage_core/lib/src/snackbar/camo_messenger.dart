import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../textfield/camo_text_field.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';
import 'camo_snackbar.dart';

// One snackbar waiting, shown or leaving, and the caller's future.
class _SnackbarRequest {
  _SnackbarRequest(
    this.message,
    this.action,
    this.tone,
    this.duration,
    this.withDismiss,
  );

  final String message;
  final String? action;
  final Tone tone;
  final SnackbarDuration duration;
  final bool? withDismiss;
  final completer = Completer<SnackbarResult>();

  bool get done => completer.isCompleted;
}

/// Shows snackbars from anywhere below the root `CamouflageProvider`, which installs one messenger for the app:
/// one snackbar at a time, the rest queued in order. Get it with [CamoMessenger.of]. Put the root provider above
/// your `Navigator` (in `WidgetsApp.builder`), so snackbars sit above dialogs and sheets.
class CamoMessenger {
  CamoMessenger._();

  final _queue = Queue<_SnackbarRequest>();
  final _changes = _Signal();
  final _insets = ValueNotifier<List<(double, double)>>(const []);
  _SnackbarRequest? _current;

  /// The messenger of the root provider above [context].
  static CamoMessenger of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_MessengerScope>();
    assert(
      scope != null,
      'CamoMessenger.of needs a CamouflageProvider above it.',
    );
    return scope!.messenger;
  }

  /// Shows [message] (with an optional [action], "Undo") after the snackbars queued before it, and completes with
  /// how it left. [withDismiss] adds a ✕; `null` follows `CamoSnackbarTheme.showDismiss`. With a screen reader on
  /// (`MediaQuery.accessibleNavigation`), a snackbar with an action stays until it's acted on or dismissed.
  Future<SnackbarResult> show(
    String message, {
    String? action,
    Tone tone = Tone.defaultTone,
    SnackbarDuration duration = SnackbarDuration.auto,
    bool? withDismiss,
  }) {
    final request = _SnackbarRequest(
      message,
      action,
      tone,
      duration,
      withDismiss,
    );
    _queue.add(request);
    _next();
    return request.completer.future;
  }

  /// Dismisses the snackbar on screen, if any (an outdated message); the next one in the queue shows.
  void dismissCurrent() => _complete(SnackbarResult.dismissed);

  void _complete(SnackbarResult result) {
    final current = _current;
    if (current == null || current.done) return;
    current.completer.complete(result);
    // The layer plays the exit, then calls _finished.
    _changes.ping();
  }

  // The current snackbar finished leaving: show the next one.
  void _finished() {
    _current = null;
    _next();
  }

  void _next() {
    if (_current == null && _queue.isNotEmpty) {
      _current = _queue.removeFirst();
      _changes.ping();
    }
  }

  void _dispose() {
    _changes.dispose();
    _insets.dispose();
  }
}

class _Signal extends ChangeNotifier {
  void ping() => notifyListeners();
}

class _MessengerScope extends InheritedWidget {
  const _MessengerScope({required this.messenger, required super.child});

  final CamoMessenger messenger;

  @override
  bool updateShouldNotify(_MessengerScope oldWidget) =>
      messenger != oldWidget.messenger;
}

/// Installs the app's messenger at the root provider; nested providers use it. [child] is laid out as if
/// nothing wrapped it; the snackbars draw in a layer above it.
Widget installMessenger(BuildContext context, Widget child) =>
    context.getInheritedWidgetOfExactType<_MessengerScope>() == null
    ? _MessengerHost(child: child)
    : child;

class _MessengerHost extends StatefulWidget {
  const _MessengerHost({required this.child});

  final Widget child;

  @override
  State<_MessengerHost> createState() => _MessengerHostState();
}

class _MessengerHostState extends State<_MessengerHost> {
  final _messenger = CamoMessenger._();

  @override
  void dispose() {
    _messenger._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _MessengerScope(
    messenger: _messenger,
    child: Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        Positioned.fill(child: _MessengerLayer(_messenger)),
      ],
    ),
  );
}

/// Keeps snackbars clear of this screen's chrome while [child] is shown: [bottom] above a navigation bar or a
/// FAB (for bottom snackbars), [top] below a top bar (for top ones). The innermost (latest) one wins.
class CamoMessengerInsets extends StatefulWidget {
  /// Creates insets for [child].
  const CamoMessengerInsets({
    super.key,
    this.bottom = 0,
    this.top = 0,
    required this.child,
  });

  /// Space above the bottom edge.
  final double bottom;

  /// Space below the top edge.
  final double top;

  /// The screen.
  final Widget child;

  @override
  State<CamoMessengerInsets> createState() => _CamoMessengerInsetsState();
}

class _CamoMessengerInsetsState extends State<CamoMessengerInsets> {
  CamoMessenger? _messenger;
  (double, double)? _entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(CamoMessengerInsets oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bottom != widget.bottom || oldWidget.top != widget.top) {
      _register();
    }
  }

  void _register() {
    _unregister();
    final messenger = context
        .getInheritedWidgetOfExactType<_MessengerScope>()
        ?.messenger;
    if (messenger == null) return;
    final entry = (widget.bottom, widget.top);
    _messenger = messenger;
    _entry = entry;
    messenger._insets.value = [...messenger._insets.value, entry];
  }

  void _unregister() {
    final messenger = _messenger;
    final entry = _entry;
    if (messenger == null || entry == null) return;
    final list = [...messenger._insets.value];
    final at = list.lastIndexWhere((e) => identical(e, entry));
    if (at >= 0) list.removeAt(at);
    messenger._insets.value = list;
    _messenger = null;
    _entry = null;
  }

  @override
  void dispose() {
    _unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// The layer above the app: the current snackbar, sliding in and out at its edge.
class _MessengerLayer extends StatefulWidget {
  const _MessengerLayer(this.messenger);

  final CamoMessenger messenger;

  @override
  State<_MessengerLayer> createState() => _MessengerLayerState();
}

class _MessengerLayerState extends State<_MessengerLayer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);
  _SnackbarRequest? _shown;

  CamoMessenger get _messenger => widget.messenger;

  @override
  void initState() {
    super.initState();
    _messenger._changes.addListener(_changed);
    _messenger._insets.addListener(_rebuild);
    WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
  }

  @override
  void dispose() {
    _messenger._changes.removeListener(_changed);
    _messenger._insets.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _changed() {
    if (!mounted) return;
    final current = _messenger._current;
    final theme = Camouflage.maybeThemeOf(context);
    _controller.duration = theme?.motion.durationMedium ?? Duration.zero;
    if (current != null && !current.done && current != _shown) {
      setState(() => _shown = current);
      _controller.forward(from: 0);
    } else if (current != null && current.done) {
      _controller.reverse().whenCompleteOrCancel(() {
        if (!mounted) return;
        setState(() => _shown = null);
        _messenger._finished();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    // Idle: nothing to lay out, paint or hit.
    if (shown == null) return const Offstage();
    final skin = Camouflage.skinOf(context, component: 'CamoMessenger');
    final theme = Camouflage.themeOf(context, component: 'CamoMessenger');
    final style = skin.snackbar
        .defaults(theme)
        .merge(theme.components.snackbar);
    final top = style.position == SnackbarPosition.top;
    final insets = _messenger._insets.value.lastOrNull ?? (0.0, 0.0);
    final x = switch (style.alignment) {
      SnackbarAlignment.start => -1.0,
      SnackbarAlignment.center => 0.0,
      SnackbarAlignment.end => 1.0,
    };
    final safe = MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return Padding(
      padding: EdgeInsets.only(
        left: safe.left + style.margin,
        right: safe.right + style.margin,
        top: top ? safe.top + style.margin + insets.$2 : 0,
        bottom: top ? 0 : safe.bottom + style.margin + insets.$1,
      ),
      child: Align(
        alignment: AlignmentDirectional(x, top ? -1 : 1),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: style.maxWidth),
          child: FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween(
                begin: Offset(0, top ? -1 : 1),
                end: Offset.zero,
              ).animate(curve),
              child: SizedBox(
                width: double.infinity,
                child: _Snackbar(
                  key: ObjectKey(shown),
                  request: shown,
                  style: style,
                  onResult: _messenger._complete,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _swipeFraction = 0.35;
const _tick = Duration(milliseconds: 100);

// One snackbar: its timer (paused while hovered, focused or dragged), swipe to dismiss, and announcement.
class _Snackbar extends StatefulWidget {
  const _Snackbar({
    super.key,
    required this.request,
    required this.style,
    required this.onResult,
  });

  final _SnackbarRequest request;
  final CamoSnackbarStyle style;
  final void Function(SnackbarResult result) onResult;

  @override
  State<_Snackbar> createState() => _SnackbarState();
}

class _SnackbarState extends State<_Snackbar> {
  Timer? _timer;
  Duration? _remaining;
  var _hovered = false;
  var _focused = false;
  var _dragging = false;
  var _drag = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _remaining ??= _duration();
    _timer ??= Timer.periodic(_tick, (_) => _tickDown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // The time it stays: the duration, or until acted on when a screen reader is on and there's an action.
  Duration? _duration() {
    final r = widget.request;
    final style = widget.style;
    if (r.duration == SnackbarDuration.indefinite) return null;
    final accessible = MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
    if (accessible && r.action != null) return null;
    return switch (r.duration) {
      SnackbarDuration.short => style.durationShort,
      SnackbarDuration.long => style.durationLong,
      _ => r.action != null ? style.durationLong : style.durationShort,
    };
  }

  void _tickDown() {
    final remaining = _remaining;
    if (remaining == null || _hovered || _focused || _dragging) return;
    final left = remaining - _tick;
    _remaining = left;
    if (left <= Duration.zero) {
      _timer?.cancel();
      widget.onResult(SnackbarResult.dismissed);
    }
  }

  void _endDrag(bool top) {
    final size = context.size ?? Size.zero;
    final away =
        _drag.dx.abs() > size.width * _swipeFraction ||
        (top && -_drag.dy > size.height * _swipeFraction);
    setState(() {
      _dragging = false;
      if (!away) _drag = Offset.zero;
    });
    if (away) widget.onResult(SnackbarResult.dismissed);
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSnackbar');
    final theme = Camouflage.themeOf(context, component: 'CamoSnackbar');
    final style = widget.style;
    final r = widget.request;
    final top = style.position == SnackbarPosition.top;
    final withDismiss = r.withDismiss ?? style.showDismiss;
    final toneIcon = style.showToneIcon
        ? skin.banner
              .defaults(theme)
              .merge(theme.components.banner)
              .toneIcons
              .ofTone(r.tone)
        : null;
    // The buttons are their own nodes, so they aren't merged into the snackbar's.
    final slots = SnackbarSlots(
      icon: toneIcon == null ? null : CamoIcon(toneIcon),
      action: r.action == null
          ? null
          : _SnackbarAction(
              text: r.action!,
              style: style.actionStyle,
              onPressed: () => widget.onResult(SnackbarResult.actionPerformed),
            ),
      dismiss: withDismiss
          ? Semantics(
              container: true,
              child: CamoFieldAction(
                icon: CamoIcon(style.dismissIcon),
                semanticLabel: style.strings.dismiss,
                onPressed: () => widget.onResult(SnackbarResult.dismissed),
              ),
            )
          : null,
    );
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 1;
    return Semantics(
      container: true,
      liveRegion: true,
      onDismiss: () => widget.onResult(SnackbarResult.dismissed),
      child: MouseRegion(
        onEnter: (_) => _hovered = true,
        onExit: (_) => _hovered = false,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) => _focused = focused,
          child: GestureDetector(
            onPanStart: (_) => setState(() => _dragging = true),
            onPanUpdate: (d) => setState(
              () => _drag = Offset(
                _drag.dx + d.delta.dx,
                top
                    ? (_drag.dy + d.delta.dy).clamp(double.negativeInfinity, 0)
                    : 0,
              ),
            ),
            onPanEnd: (_) => _endDrag(top),
            onPanCancel: () => _endDrag(top),
            child: Transform.translate(
              offset: _drag,
              child: Opacity(
                opacity: (1 - _drag.dx.abs() / width).clamp(0.0, 1.0),
                child: skin.snackbar.render(
                  context,
                  SnackbarState(
                    message: r.message,
                    action: r.action,
                    tone: r.tone,
                    withDismiss: withDismiss,
                    showToneIcon: toneIcon != null,
                    position: style.position,
                    interaction: InteractionState(
                      hovered: _hovered,
                      focused: _focused,
                      dragged: _dragging,
                    ),
                  ),
                  slots,
                  theme,
                  style,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// The snackbar's action: text in the content color the renderer provides (its action color), its own button.
class _SnackbarAction extends StatefulWidget {
  const _SnackbarAction({
    required this.text,
    required this.style,
    required this.onPressed,
  });

  final String text;
  final TextStyle style;
  final VoidCallback onPressed;

  @override
  State<_SnackbarAction> createState() => _SnackbarActionState();
}

class _SnackbarActionState extends State<_SnackbarAction> {
  final _interaction = CamoInteractionController();

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoSnackbar');
    final theme = Camouflage.themeOf(context, component: 'CamoSnackbar');
    final color = Camouflage.contentColorOf(context);
    final spacing = theme.spacing;
    // Its own node above the behavior, so the tap action joins it.
    return Semantics(
      container: true,
      child: CamoBehavior(
        controller: _interaction,
        enabled: true,
        onActivate: widget.onPressed,
        semantics: (child) => Semantics(
          button: true,
          label: widget.text,
          excludeSemantics: true,
          child: child,
        ),
        child: skin.feedback.wrap(
          controller: _interaction,
          contentColor: color,
          shape: theme.shapes.small,
          theme: theme,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s,
              vertical: spacing.xs,
            ),
            child: Text(
              widget.text,
              style: widget.style.copyWith(color: color),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
