import 'package:camouflage_core/camouflage_core.dart';
import 'package:camouflage_core/src/file_uploader/camo_file_uploader.dart'
    as uploader;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'collection_test_renderers.dart';
import 'test_skins.dart';

// The M10 carousel and file uploader tests from their Flutter notes.

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
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

const _slides = ['One', 'Two', 'Three'];

Widget _carousel([List<String> items = _slides]) => SizedBox(
  width: 400,
  height: 200,
  child: CamoCarousel<String>(
    items: items,
    itemKey: (s) => s,
    semanticLabel: 'Gallery',
    showButtons: true,
    itemBuilder: (context, s) => Center(child: Text('slide $s')),
  ),
);

const _files = [
  UploadFile(id: 'a', name: 'a.png', sizeBytes: 1048576, progress: 0.45),
  UploadFile(
    id: 'b',
    name: 'b.pdf',
    sizeBytes: 2048,
    status: UploadStatus.failed('Too large'),
  ),
  UploadFile(
    id: 'c',
    name: 'c.txt',
    sizeBytes: 12,
    status: UploadStatus.done(),
  ),
];

void main() {
  group('carousel', () {
    testWidgets('the buttons step through the items and stop at the ends', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_carousel()));
      expect(lastCarousel!.page, 0);
      expect(lastCarousel!.pageCount, 3);
      expect(carouselButtons['previous']!.enabled, isFalse);
      await tester.tap(find.bySemanticsLabel('Next item'));
      await tester.pumpAndSettle();
      expect(lastCarousel!.page, 1);
      await tester.tap(find.bySemanticsLabel('Next item'));
      await tester.pumpAndSettle();
      expect(carouselButtons['next']!.enabled, isFalse);
    });

    testWidgets('arrows, Home and End move and jump', (tester) async {
      await tester.pumpWidget(_app(_carousel()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(lastCarousel!.page, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(lastCarousel!.page, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(lastCarousel!.page, 0);
    });

    testWidgets('an item announces its place and the page dots are there', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_carousel()));
      expect(find.bySemanticsLabel(RegExp('item 1 of 3')), findsOneWidget);
      expect(find.bySemanticsLabel('Page 2'), findsOneWidget);
    });

    testWidgets('a single item has no buttons or dots', (tester) async {
      await tester.pumpWidget(_app(_carousel(['Only'])));
      expect(find.bySemanticsLabel('Next item'), findsNothing);
      expect(find.bySemanticsLabel('Page 1'), findsNothing);
    });
  });

  group('file uploader', () {
    test('sizes read as a person would say them', () {
      expect(uploader.formatSize(12), '12 B');
      expect(uploader.formatSize(2048), '2.0 KB');
      expect(uploader.formatSize(1048576), '1.0 MB');
    });

    testWidgets('the zone is one button that opens the picker', (tester) async {
      var picked = 0;
      await tester.pumpWidget(
        _app(
          CamoFileUploader(
            files: const [],
            onPick: () => picked++,
            onRemove: (_) {},
            semanticLabel: 'Upload files',
            hint: 'PNG up to 5 MB',
          ),
        ),
      );
      await tester.tap(find.text('Upload files'));
      expect(picked, 1);
    });

    testWidgets('a disabled zone does nothing', (tester) async {
      var picked = 0;
      await tester.pumpWidget(
        _app(
          CamoFileUploader(
            files: const [],
            onPick: () => picked++,
            onRemove: (_) {},
            semanticLabel: 'Upload files',
            enabled: false,
          ),
        ),
      );
      await tester.tap(find.text('Upload files'));
      expect(picked, 0);
      expect(lastZone!.enabled, isFalse);
    });

    testWidgets('rows show their progress and remove and retry are buttons', (
      tester,
    ) async {
      final removed = <String>[];
      final retried = <String>[];
      await tester.pumpWidget(
        _app(
          CamoFileUploader(
            files: _files,
            onPick: () {},
            onRemove: (f) => removed.add(f.name),
            onRetry: (f) => retried.add(f.name),
            semanticLabel: 'Upload files',
          ),
        ),
      );
      expect(uploadRows['a.png']!.status, isA<UploadUploading>());
      expect(uploadRows['a.png']!.progress, 0.45);
      await tester.tap(find.bySemanticsLabel('Remove a.png'));
      await tester.tap(find.bySemanticsLabel('Retry b.pdf'));
      expect(removed, ['a.png']);
      expect(retried, ['b.pdf']);
      expect(find.bySemanticsLabel('Retry a.png'), findsNothing);
    });

    testWidgets('a row announces its state', (tester) async {
      await tester.pumpWidget(
        _app(
          CamoFileUploader(
            files: _files,
            onPick: () {},
            onRemove: (_) {},
            semanticLabel: 'Upload files',
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('a.png').first).value,
        '1.0 MB, 45%',
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('b.pdf').first).value,
        '2.0 KB, Too large',
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('c.txt').first).value,
        '12 B, Done',
      );
    });

    testWidgets("the app's drop target drives the zone", (tester) async {
      DropTargetCallbacks? callbacks;
      var dropped = <DroppedFile>[];
      await tester.pumpWidget(
        _app(
          CamoFileUploader(
            files: const [],
            onPick: () {},
            onRemove: (_) {},
            semanticLabel: 'Upload files',
            dropTargetBuilder: (context, zone, cb) {
              callbacks = cb;
              return zone;
            },
            onFilesDropped: (d) => dropped = d,
          ),
        ),
      );
      callbacks!.setDragOver(true);
      await tester.pump();
      expect(lastZone!.dragOver, isTrue);
      callbacks!.onDropped(const [DroppedFile(name: 'x.txt', sizeBytes: 10)]);
      await tester.pump();
      expect(lastZone!.dragOver, isFalse);
      expect(dropped.map((f) => f.name), ['x.txt']);
    });
  });
}
