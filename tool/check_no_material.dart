// Library packages are Material-free: fails if one imports Material or Cupertino (see docs: Project Setup).
// The one exception is camouflage_skin_material, which may import material_ui for the ink ripple.
// Usage (from dart-lib/): dart run tool/check_no_material.dart, or melos run no-material
import 'dart:io';

// The package that may use material_ui, and only that.
const _materialSkin = 'camouflage_skin_material';

const _forbidden = [
  'package:flutter/material.dart',
  'package:flutter/cupertino.dart',
  'package:material_ui/',
  'package:cupertino_ui/',
];

void main() {
  final problems = <String>[];
  for (final package in Directory(
    'packages',
  ).listSync().whereType<Directory>()) {
    final lib = Directory('${package.path}/lib');
    if (!lib.existsSync()) continue;
    final allowed = package.path.endsWith(_materialSkin)
        ? const ['package:material_ui/']
        : const <String>[];
    for (final file
        in lib
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (_forbidden.any((f) => lines[i].contains(f) && !allowed.contains(f)))
          problems.add('${file.path}:${i + 1}: ${lines[i].trim()}');
      }
    }
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Material or Cupertino imported in a library package:');
    for (final p in problems) {
      stderr.writeln('  $p');
    }
    exit(1);
  }
  stdout.writeln('No Material or Cupertino imports.');
}
