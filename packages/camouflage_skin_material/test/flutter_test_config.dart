import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// CI goldens (text drawn as blocks) always; platform goldens (real text, for local review) only off CI, and
// never committed (Testing §3). Skia antialiases edges slightly differently on macOS and Linux, so a golden may
// differ by up to 0.5% of its pixels; a real change (a color, a size) moves far more.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (goldenFileComparator case final LocalFileComparator local) {
    goldenFileComparator = _Tolerant(
      local.basedir.resolve('flutter_test_config.dart'),
    );
  }
  await AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: !Platform.environment.containsKey('CI'),
      ),
    ),
    run: () async => testMain(),
  );
}

const double _tolerance = 0.005;

class _Tolerant extends LocalFileComparator {
  _Tolerant(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
