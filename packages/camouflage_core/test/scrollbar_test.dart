import 'package:camouflage_core/camouflage_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_skins.dart';

// CamoScrollArea (base Scrollbar, M16): thumb geometry, drag, track click, touch, no size change.

const _caps = CamoCapabilities(
  backdropBlur: false,
  runtimeShaders: false,
  windowMaterial: false,
  reduceTransparency: false,
);
const _desktop = CamoEnvironment(
  windowSize: WindowSizeClass.expanded,
  input: InputMode.pointer,
  platform: CamoPlatform.windows,
  capabilities: _caps,
);
final _phone = _desktop.copyWith(
  windowSize: WindowSizeClass.compact,
  input: InputMode.touch,
  platform: CamoPlatform.android,
);

Widget _app(
  Widget child, {
  CamoEnvironment environment = _desktop,
  TextDirection direction = TextDirection.ltr,
}) => WidgetsApp(
  color: const Color(0xFFFFFFFF),
  builder: (context, app) =>
      Directionality(textDirection: direction, child: app!),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: CamouflageProvider(
    skin: skinA,
    theme: themeT,
    environment: environment,
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

// 100 of viewport over [content] of content, with the bar at the end edge.
Widget _scrolling(ScrollController controller, {double content = 200}) =>
    SizedBox(
      width: 200,
      height: 100,
      child: CamoScrollArea(
        child: SingleChildScrollView(
          controller: controller,
          child: SizedBox(height: content, width: 200),
        ),
      ),
    );

final _bar = find.byKey(const ValueKey('scrollbar'));

void main() {
  testWidgets('the thumb is proportional and follows the scroll', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(_scrolling(controller)));
    await tester.pumpAndSettle();
    expect(tester.getSize(_bar).height, closeTo(50, 1));
    expect(tester.getTopLeft(_bar).dy, closeTo(0, 1));
    controller.jumpTo(50);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(_bar).dy, closeTo(25, 2));
  });

  testWidgets('nothing is drawn when the content fits', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(_scrolling(controller, content: 80)));
    await tester.pumpAndSettle();
    expect(_bar, findsNothing);
  });

  testWidgets('touch input draws nothing', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(_scrolling(controller), environment: _phone));
    await tester.pumpAndSettle();
    expect(_bar, findsNothing);
  });

  testWidgets('dragging the thumb scrolls the content', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(_scrolling(controller)));
    await tester.pumpAndSettle();
    // A mouse: that is the input the bar is for (a touch drag would also try to scroll the content).
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(tester.getCenter(_bar));
    await tester.pump();
    // Past the drag slop, then 20 further.
    await mouse.moveBy(const Offset(0, 20));
    for (var i = 0; i < 4; i++) {
      await mouse.moveBy(const Offset(0, 5));
    }
    await mouse.up();
    await tester.pumpAndSettle();
    // 20 of thumb over 50 of room is 40% of the 100 that can scroll.
    expect(controller.offset, greaterThan(10));
    expect(controller.offset, closeTo(40, 12));
  });

  testWidgets('a click on the track pages a viewport', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(_scrolling(controller)));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(197, 90));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(controller.offset, closeTo(100, 1));
  });

  testWidgets('the bar does not change its containers size', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(_scrolling(controller)));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CamoScrollArea)), const Size(200, 100));
  });

  testWidgets('right to left puts the vertical bar on the left', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(_scrolling(controller), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();
    expect(tester.getCenter(_bar).dx, lessThan(100));
  });
}
