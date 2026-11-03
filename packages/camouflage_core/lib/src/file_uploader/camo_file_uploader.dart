import 'package:flutter/widgets.dart';

import '../icon/camo_icon.dart';
import '../icon_button/camo_icon_button.dart';
import '../provider/camouflage.dart';
import '../skin/interaction.dart';
import '../theme/camo_theme.dart';
import '../theme/roles.dart';
import '../util/camo_behavior.dart';

/// Every color a file uploader uses: the zone and its border, the border while dragging over, errors, text.
@immutable
class UploaderColors {
  /// Creates UploaderColors.
  const UploaderColors({
    required this.zone,
    required this.border,
    required this.dragBorder,
    required this.error,
    required this.text,
    required this.mutedText,
  });

  /// The zone's fill.
  final Color zone;

  /// The zone's border.
  final Color border;

  /// The border while files hover over it.
  final Color dragBorder;

  /// A failed file.
  final Color error;

  /// Names.
  final Color text;

  /// Hints and details.
  final Color mutedText;

  @override
  bool operator ==(Object other) =>
      other is UploaderColors &&
      other.zone == zone &&
      other.border == border &&
      other.dragBorder == dragBorder &&
      other.error == error &&
      other.text == text &&
      other.mutedText == mutedText;

  @override
  int get hashCode =>
      Object.hash(zone, border, dragBorder, error, text, mutedText);
}

/// Overrides for file uploaders. `null` keeps the skin's default.
@immutable
class CamoUploaderTheme {
  /// Creates overrides.
  const CamoUploaderTheme({
    this.zoneShape,
    this.dashed,
    this.zoneHeight,
    this.icon,
    this.removeIcon,
    this.retryIcon,
    this.titleStyle,
    this.hintStyle,
    this.colors,
  });

  /// The drop zone corners.
  final BorderRadius? zoneShape;

  /// A dashed zone border.
  final bool? dashed;

  /// The drop zone height.
  final double? zoneHeight;

  /// The zone icon.
  final IconSource? icon;

  /// A file row's remove button.
  final IconSource? removeIcon;

  /// A failed file row's retry button.
  final IconSource? retryIcon;

  /// The zone title and file names.
  final TextStyle? titleStyle;

  /// The zone hint and file details.
  final TextStyle? hintStyle;

  /// Every color it uses.
  final UploaderColors? colors;

  /// A copy with the given fields replaced.
  CamoUploaderTheme copyWith({
    BorderRadius? zoneShape,
    bool? dashed,
    double? zoneHeight,
    IconSource? icon,
    IconSource? removeIcon,
    IconSource? retryIcon,
    TextStyle? titleStyle,
    TextStyle? hintStyle,
    UploaderColors? colors,
  }) => CamoUploaderTheme(
    zoneShape: zoneShape ?? this.zoneShape,
    dashed: dashed ?? this.dashed,
    zoneHeight: zoneHeight ?? this.zoneHeight,
    icon: icon ?? this.icon,
    removeIcon: removeIcon ?? this.removeIcon,
    retryIcon: retryIcon ?? this.retryIcon,
    titleStyle: titleStyle ?? this.titleStyle,
    hintStyle: hintStyle ?? this.hintStyle,
    colors: colors ?? this.colors,
  );

  @override
  bool operator ==(Object other) =>
      other is CamoUploaderTheme &&
      other.zoneShape == zoneShape &&
      other.dashed == dashed &&
      other.zoneHeight == zoneHeight &&
      other.icon == icon &&
      other.removeIcon == removeIcon &&
      other.retryIcon == retryIcon &&
      other.titleStyle == titleStyle &&
      other.hintStyle == hintStyle &&
      other.colors == colors;

  @override
  int get hashCode => Object.hash(
    zoneShape,
    dashed,
    zoneHeight,
    icon,
    removeIcon,
    retryIcon,
    titleStyle,
    hintStyle,
    colors,
  );
}

/// The resolved file uploader style: every field set.
@immutable
class CamoUploaderStyle {
  /// Creates a style.
  const CamoUploaderStyle({
    required this.zoneShape,
    required this.dashed,
    required this.zoneHeight,
    required this.icon,
    required this.removeIcon,
    required this.retryIcon,
    required this.titleStyle,
    required this.hintStyle,
    required this.colors,
  });

  /// The drop zone corners.
  final BorderRadius zoneShape;

  /// A dashed zone border.
  final bool dashed;

  /// The drop zone height.
  final double zoneHeight;

  /// The zone icon.
  final IconSource icon;

  /// A file row's remove button.
  final IconSource removeIcon;

  /// A failed file row's retry button.
  final IconSource retryIcon;

  /// The zone title and file names.
  final TextStyle titleStyle;

  /// The zone hint and file details.
  final TextStyle hintStyle;

  /// Every color it uses.
  final UploaderColors colors;

  /// This style with [o]'s non-null fields applied.
  CamoUploaderStyle merge(CamoUploaderTheme? o) => o == null
      ? this
      : CamoUploaderStyle(
          zoneShape: o.zoneShape ?? zoneShape,
          dashed: o.dashed ?? dashed,
          zoneHeight: o.zoneHeight ?? zoneHeight,
          icon: o.icon ?? icon,
          removeIcon: o.removeIcon ?? removeIcon,
          retryIcon: o.retryIcon ?? retryIcon,
          titleStyle: o.titleStyle ?? titleStyle,
          hintStyle: o.hintStyle ?? hintStyle,
          colors: o.colors ?? colors,
        );
}

/// Where a file's upload is.
@immutable
sealed class UploadStatus {
  const UploadStatus();

  /// Waiting or in progress.
  const factory UploadStatus.uploading() = UploadUploading;

  /// Finished.
  const factory UploadStatus.done() = UploadDone;

  /// Failed with [message] (the app validates types and sizes).
  const factory UploadStatus.failed(String message) = UploadFailed;
}

/// Waiting or in progress.
class UploadUploading extends UploadStatus {
  /// Creates the status.
  const UploadUploading();
}

/// Finished.
class UploadDone extends UploadStatus {
  /// Creates the status.
  const UploadDone();
}

/// Failed.
class UploadFailed extends UploadStatus {
  /// Creates the status.
  const UploadFailed(this.message);

  /// Why it failed.
  final String message;
}

/// A file row: [progress] is `0..1` while uploading, or `null` while it waits. The app runs the upload.
@immutable
class UploadFile {
  /// Creates a file row.
  const UploadFile({
    required this.id,
    required this.name,
    this.sizeBytes,
    this.progress,
    this.status = const UploadStatus.uploading(),
  });

  /// Identifies the file.
  final Object id;

  /// The file's name.
  final String name;

  /// Its size in bytes.
  final int? sizeBytes;

  /// `0..1`, or `null` while waiting.
  final double? progress;

  /// Where the upload is.
  final UploadStatus status;
}

/// A file dropped on the zone: its name and size; the app reads it however its platform allows.
@immutable
class DroppedFile {
  /// Creates a dropped file.
  const DroppedFile({required this.name, this.sizeBytes, this.handle});

  /// The name.
  final String name;

  /// The size, if known.
  final int? sizeBytes;

  /// The platform's own reference to it.
  final Object? handle;
}

/// What a platform drop target needs to report: [setDragOver] while files hover over the zone and [onDropped] with
/// what was dropped. Core uses no windowing or filesystem plugin, so the app wraps the zone with its own drop API.
@immutable
class DropTargetCallbacks {
  /// Creates the callbacks.
  const DropTargetCallbacks({
    required this.setDragOver,
    required this.onDropped,
  });

  /// Called with `true` while files hover over the zone.
  final ValueChanged<bool> setDragOver;

  /// Called with the dropped files.
  final ValueChanged<List<DroppedFile>> onDropped;
}

/// What the zone draws: [dragOver] while files hover over it.
@immutable
class UploaderZoneState {
  /// Creates the state.
  const UploaderZoneState({
    required this.dragOver,
    required this.enabled,
    required this.interaction,
    required this.controller,
  });

  /// Whether files hover over the zone.
  final bool dragOver;

  /// `false` shows the disabled look.
  final bool enabled;

  /// Pressed, focused, hovered.
  final InteractionState interaction;

  /// The source of [interaction], for the skin's feedback.
  final CamoInteractionController controller;
}

/// The zone's content.
@immutable
class UploaderZoneSlots {
  /// Creates the slots.
  const UploaderZoneSlots({required this.title, this.hint});

  /// The title.
  final String title;

  /// The hint under it.
  final String? hint;
}

/// What a file row draws.
@immutable
class UploadRowState {
  /// Creates the state.
  const UploadRowState({required this.status, required this.progress});

  /// Where the upload is.
  final UploadStatus status;

  /// `0..1`, or `null`.
  final double? progress;
}

/// A file row's content: its [name], a [detail] line ("2.4 MB, 45%") and the remove and retry buttons core builds.
@immutable
class UploadRowSlots {
  /// Creates the slots.
  const UploadRowSlots({
    required this.name,
    required this.detail,
    required this.remove,
    this.retry,
  });

  /// The name.
  final String name;

  /// The detail line.
  final String detail;

  /// The remove button.
  final Widget remove;

  /// The retry button of a failed file.
  final Widget? retry;
}

/// Draws file uploaders in parts: the drop zone and each file row.
abstract interface class CamoFileUploaderRenderer {
  /// The complete file uploader style for [theme].
  CamoUploaderStyle defaults(CamoTheme theme);

  /// The zone.
  Widget renderZone(
    BuildContext context,
    UploaderZoneState state,
    UploaderZoneSlots slots,
    CamoTheme theme,
    CamoUploaderStyle style,
  );

  /// One file row: the name and detail, the progress (a `CamoProgressBar`) while uploading, and the buttons.
  Widget renderRow(
    BuildContext context,
    UploadRowState state,
    UploadRowSlots slots,
    CamoTheme theme,
    CamoUploaderStyle style,
  );
}

/// A drop zone and button for choosing files, with a list of each file's progress. Core opens no picker and reads no
/// file (ADR-27): a press, Enter or Space on the zone calls [onPick], where the app opens its picker;
/// [dropTargetBuilder] lets the app wrap the zone with its platform's drop API. The app runs the uploads and reports
/// them in [files]. The zone announces as one button with its [hint]; a row announces its name and state, and a
/// failure is announced once. [semanticLabel] names the zone.
class CamoFileUploader extends StatefulWidget {
  /// Creates a file uploader.
  const CamoFileUploader({
    super.key,
    required this.files,
    required this.onPick,
    required this.onRemove,
    required this.semanticLabel,
    this.dropTargetBuilder,
    this.onFilesDropped,
    this.onRetry,
    this.hint,
    this.enabled = true,
  });

  /// The files and their progress.
  final List<UploadFile> files;

  /// Opens the app's picker.
  final VoidCallback onPick;

  /// Removes a file.
  final ValueChanged<UploadFile> onRemove;

  /// Names the zone.
  final String semanticLabel;

  /// Wraps the zone with the app's drop API.
  final Widget Function(
    BuildContext context,
    Widget zone,
    DropTargetCallbacks callbacks,
  )?
  dropTargetBuilder;

  /// Called with the files dropped on the zone.
  final ValueChanged<List<DroppedFile>>? onFilesDropped;

  /// Retries a failed file; without it a failed row has no retry button.
  final ValueChanged<UploadFile>? onRetry;

  /// A line under the zone's title ("PNG or JPG, up to 5 MB").
  final String? hint;

  /// `false` disables the zone.
  final bool enabled;

  @override
  State<CamoFileUploader> createState() => _CamoFileUploaderState();
}

class _CamoFileUploaderState extends State<CamoFileUploader> {
  final _interaction = CamoInteractionController();
  var _dragOver = false;

  @override
  void dispose() {
    _interaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoFileUploader');
    final theme = Camouflage.themeOf(context, component: 'CamoFileUploader');
    final style = skin.fileUploader
        .defaults(theme)
        .merge(theme.components.fileUploader);
    Widget zone = CamoBehavior(
      controller: _interaction,
      enabled: widget.enabled,
      onActivate: widget.onPick,
      semantics: (child) => Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.semanticLabel,
        hint: widget.hint,
        excludeSemantics: true,
        child: child,
      ),
      child: ListenableBuilder(
        listenable: _interaction,
        builder: (context, _) => skin.fileUploader.renderZone(
          context,
          UploaderZoneState(
            dragOver: _dragOver,
            enabled: widget.enabled,
            interaction: _interaction.value,
            controller: _interaction,
          ),
          UploaderZoneSlots(title: widget.semanticLabel, hint: widget.hint),
          theme,
          style,
        ),
      ),
    );
    final wrap = widget.dropTargetBuilder;
    if (wrap != null) {
      zone = wrap(
        context,
        zone,
        DropTargetCallbacks(
          setDragOver: (over) => setState(() => _dragOver = over),
          onDropped: (dropped) {
            setState(() => _dragOver = false);
            widget.onFilesDropped?.call(dropped);
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        zone,
        for (final file in widget.files)
          _FileRow(
            key: ValueKey(file.id),
            file: file,
            onRemove: widget.onRemove,
            onRetry: widget.onRetry,
          ),
      ],
    );
  }
}

const _kilo = 1024;

/// A size as a person reads it: bytes, KB or MB with one decimal.
@visibleForTesting
String formatSize(int bytes) => bytes < _kilo
    ? '$bytes B'
    : bytes < _kilo * _kilo
    ? '${(bytes / _kilo).toStringAsFixed(1)} KB'
    : '${(bytes / (_kilo * _kilo)).toStringAsFixed(1)} MB';

class _FileRow extends StatelessWidget {
  const _FileRow({
    super.key,
    required this.file,
    required this.onRemove,
    required this.onRetry,
  });

  final UploadFile file;
  final ValueChanged<UploadFile> onRemove;
  final ValueChanged<UploadFile>? onRetry;

  @override
  Widget build(BuildContext context) {
    final skin = Camouflage.skinOf(context, component: 'CamoFileUploader');
    final theme = Camouflage.themeOf(context, component: 'CamoFileUploader');
    final style = skin.fileUploader
        .defaults(theme)
        .merge(theme.components.fileUploader);
    final status = file.status;
    final failed = status is UploadFailed;
    final state = switch (status) {
      UploadFailed(:final message) => message,
      UploadDone() => 'Done',
      UploadUploading() =>
        file.progress == null
            ? 'Waiting'
            : '${(file.progress! * 100).round()}%',
    };
    final detail = [
      if (file.sizeBytes != null) formatSize(file.sizeBytes!),
      state,
    ].join(', ');
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: file.name,
      value: detail,
      liveRegion: failed,
      child: skin.fileUploader.renderRow(
        context,
        UploadRowState(status: status, progress: file.progress),
        UploadRowSlots(
          name: file.name,
          detail: detail,
          retry: failed && onRetry != null
              ? CamoIconButton(
                  icon: CamoIcon(style.retryIcon),
                  semanticLabel: 'Retry ${file.name}',
                  appearance: Appearance.ghost,
                  onPressed: () => onRetry!(file),
                )
              : null,
          remove: CamoIconButton(
            icon: CamoIcon(style.removeIcon),
            semanticLabel: 'Remove ${file.name}',
            appearance: Appearance.ghost,
            onPressed: () => onRemove(file),
          ),
        ),
        theme,
        style,
      ),
    );
  }
}
