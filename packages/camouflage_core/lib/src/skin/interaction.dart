import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// What the user is doing to a component right now. Renderers branch on it.
///
/// `dragged` is for a slider handle or a switch thumb.
@immutable
class InteractionState {
  /// Creates a state; everything defaults to `false`.
  const InteractionState({
    this.pressed = false,
    this.focused = false,
    this.hovered = false,
    this.dragged = false,
  });

  /// Nothing is happening.
  static const InteractionState none = InteractionState();

  /// A pointer or key is pressing the component.
  final bool pressed;

  /// The component has input focus.
  final bool focused;

  /// A pointer is over the component.
  final bool hovered;

  /// A handle or thumb is being dragged.
  final bool dragged;

  /// A copy with the given fields replaced.
  InteractionState copyWith({
    bool? pressed,
    bool? focused,
    bool? hovered,
    bool? dragged,
  }) => InteractionState(
    pressed: pressed ?? this.pressed,
    focused: focused ?? this.focused,
    hovered: hovered ?? this.hovered,
    dragged: dragged ?? this.dragged,
  );

  @override
  bool operator ==(Object other) =>
      other is InteractionState &&
      other.pressed == pressed &&
      other.focused == focused &&
      other.hovered == hovered &&
      other.dragged == dragged;

  @override
  int get hashCode => Object.hash(pressed, focused, hovered, dragged);

  @override
  String toString() =>
      'InteractionState(pressed: $pressed, focused: $focused, hovered: $hovered, dragged: $dragged)';
}

/// Owned by a component's `State`: the component's behavior wrapper reports into it, and renderers
/// listen to it for feedback, including where a press started so a ripple can begin at the finger.
class CamoInteractionController extends ChangeNotifier
    implements ValueListenable<InteractionState> {
  InteractionState _value = InteractionState.none;
  bool _focusedByKeyboard = false;
  final StreamController<Offset> _pressDowns = StreamController.broadcast();
  final StreamController<void> _pressEnds = StreamController.broadcast();

  @override
  InteractionState get value => _value;

  /// The local position of each press, as it starts.
  Stream<Offset> get pressDowns => _pressDowns.stream;

  /// A press was released or cancelled.
  Stream<void> get pressEnds => _pressEnds.stream;

  /// Whether focus came from the keyboard, for focus rings (a tap focuses without a ring).
  bool get focusedByKeyboard => _focusedByKeyboard;

  /// Reports a press starting at [localPosition].
  void pressDown(Offset localPosition) {
    _pressDowns.add(localPosition);
    _set(_value.copyWith(pressed: true));
  }

  /// Reports the press ending, by release or cancel.
  void pressEnd() {
    _pressEnds.add(null);
    _set(_value.copyWith(pressed: false));
  }

  /// Reports a pointer entering or leaving.
  void setHovered(bool hovered) => _set(_value.copyWith(hovered: hovered));

  /// Reports focus; [byKeyboard] decides whether a focus ring shows.
  void setFocused(bool focused, {bool byKeyboard = false}) {
    _focusedByKeyboard = focused && byKeyboard;
    _set(_value.copyWith(focused: focused));
  }

  /// Reports a drag starting or ending.
  void setDragged(bool dragged) => _set(_value.copyWith(dragged: dragged));

  void _set(InteractionState next) {
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _pressDowns.close();
    _pressEnds.close();
    super.dispose();
  }
}
