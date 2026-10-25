import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../provider/camouflage.dart';
import '../theme/camo_theme.dart';

/// One run of rich text. Each span inherits the base style and color and overrides only what it sets.
/// A span with [onTap] is its own accessible link, styled by the skin.
@immutable
class CamoSpan {
  /// Creates a span.
  const CamoSpan(
    this.text, {
    this.style,
    this.fontWeight,
    this.italic,
    this.color,
    this.underline,
    this.onTap,
  });

  /// The text.
  final String text;

  /// Replaces the base style for this span: one of the 15 roles, optionally adjusted with `copyWith`.
  final TextStyle? style;

  /// Overrides the weight.
  final FontWeight? fontWeight;

  /// Overrides italics.
  final bool? italic;

  /// Overrides the color.
  final Color? color;

  /// Overrides the underline.
  final bool? underline;

  /// Makes the span a link.
  final VoidCallback? onTap;
}

/// What a text renderer draws: always a [TextSpan], so renderers handle one type.
@immutable
class TextState {
  /// Creates a text state.
  const TextState({
    required this.content,
    required this.style,
    required this.color,
    required this.maxLines,
    required this.overflow,
    required this.textAlign,
  });

  /// The text, plain or rich.
  final TextSpan content;

  /// The base style.
  final TextStyle style;

  /// The resolved color.
  final Color color;

  /// The line limit, or `null` for none.
  final int? maxLines;

  /// How overflowing text ends.
  final TextOverflow overflow;

  /// Alignment within the text's own box.
  final TextAlign textAlign;
}

/// Draws text. It has no component theme: styles come from the call, colors from the content color.
abstract interface class CamoTextRenderer {
  /// How link spans look in this skin.
  TextStyle linkStyle(CamoTheme theme);

  /// Draws [state].
  Widget render(BuildContext context, TextState state, CamoTheme theme);
}

/// Text in one of the theme's styles, in the surrounding container's content color unless [color] is set.
class CamoText extends StatefulWidget {
  /// Plain text.
  const CamoText(
    String this.text, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
  }) : spans = null;

  /// Rich text: [spans] with their own weights, colors and links.
  const CamoText.rich(
    List<CamoSpan> this.spans, {
    super.key,
    this.style,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
  }) : text = null;

  /// The plain text, or `null` for rich text.
  final String? text;

  /// The spans, or `null` for plain text.
  final List<CamoSpan>? spans;

  /// The style; `null` is the theme's `bodyMedium`.
  final TextStyle? style;

  /// The color; `null` is the content color.
  final Color? color;

  /// The line limit.
  final int? maxLines;

  /// How overflowing text ends.
  final TextOverflow overflow;

  /// Alignment within the text's own box.
  final TextAlign textAlign;

  @override
  State<CamoText> createState() => _CamoTextState();
}

class _CamoTextState extends State<CamoText> {
  // Link recognizers hold resources: created once per span list, disposed with it.
  List<TapGestureRecognizer?> _recognizers = const [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  @override
  void didUpdateWidget(CamoText old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.spans, widget.spans)) {
      _dispose();
      _build();
    }
  }

  void _build() {
    _recognizers = [
      for (final span in widget.spans ?? const <CamoSpan>[])
        span.onTap == null
            ? null
            : (TapGestureRecognizer()..onTap = span.onTap),
    ];
  }

  void _dispose() {
    for (final r in _recognizers) {
      r?.dispose();
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoText');
    final theme = Camouflage.themeOf(context, component: 'CamoText');
    final spans = widget.spans;
    final TextSpan content;
    if (spans == null) {
      content = TextSpan(text: widget.text);
    } else {
      final link = skin.text.linkStyle(theme);
      content = TextSpan(
        children: [
          for (var i = 0; i < spans.length; i++)
            _span(spans[i], _recognizers[i], link),
        ],
      );
    }
    return skin.text.render(
      context,
      TextState(
        content: content,
        style: widget.style ?? theme.typography.bodyMedium,
        color: widget.color ?? Camouflage.contentColorOf(context),
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      ),
      theme,
    );
  }

  TextSpan _span(CamoSpan s, TapGestureRecognizer? recognizer, TextStyle link) {
    final overrides = TextStyle(
      fontWeight: s.fontWeight,
      fontStyle: s.italic == null
          ? null
          : (s.italic! ? FontStyle.italic : FontStyle.normal),
      color: s.color,
      decoration: s.underline == null
          ? null
          : (s.underline! ? TextDecoration.underline : TextDecoration.none),
    );
    final base = recognizer == null
        ? s.style
        : (s.style ?? const TextStyle()).merge(link);
    return TextSpan(
      text: s.text,
      style: (base ?? const TextStyle()).merge(overrides),
      recognizer: recognizer,
      semanticsLabel: s.text,
    );
  }
}
