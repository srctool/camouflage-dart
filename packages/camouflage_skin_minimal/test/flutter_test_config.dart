import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';

// CI goldens (text drawn as blocks, identical on every OS) always; platform goldens (real text, for local
// review) only off CI, and never committed (Testing §3).
Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    AlchemistConfig.runWithConfig(
      config: AlchemistConfig(
        platformGoldensConfig: PlatformGoldensConfig(
          enabled: !Platform.environment.containsKey('CI'),
        ),
      ),
      run: () async => testMain(),
    );
