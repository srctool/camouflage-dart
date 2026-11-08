# Example

```dart
import 'package:camouflage_skin_testing/camouflage_skin_testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('my skin keeps the buttons accessible', (tester) async {
    await expectAccessibleScreen(
      tester,
      skin: mySkin,
      theme: myTheme,
      child: const ButtonGallery(),
      textScale: 2,
    );
  });
}
```

Every Camouflage skin package runs these checks in its own tests: see the `*_accessibility_test.dart` files in the [repository](https://github.com/srctool/camouflage-dart/tree/main/packages).
