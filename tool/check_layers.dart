// Checks every workspace package's Camouflage dependencies against tool/layers.yaml (ADR-27):
// a package may depend only on lower layers. dev_dependencies count too, since pub allows cycles through them,
// but they may also point at the same layer: tests don't ship, and the skins test themselves with
// camouflage_skin_testing (ADR-27, amended 2026-10-25).
// Usage (from dart-lib/): dart run tool/check_layers.dart, or melos run layers
import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  final layers = (loadYaml(
    File('tool/layers.yaml').readAsStringSync(),
  ) as YamlMap).cast<String, int>();
  final root = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  final members = (root['workspace'] as YamlList).cast<String>();

  final problems = <String>[];
  for (final member in members) {
    final pubspec =
        loadYaml(File('$member/pubspec.yaml').readAsStringSync()) as YamlMap;
    final name = pubspec['name'] as String;
    final layer = layers[name];
    if (layer == null) {
      problems.add('$name ($member) has no layer in tool/layers.yaml');
      continue;
    }
    for (final section in ['dependencies', 'dev_dependencies']) {
      final deps =
          (pubspec[section] as YamlMap?)?.keys.cast<String>() ??
          const <String>[];
      for (final dep in deps.where(layers.containsKey)) {
        final depLayer = layers[dep]!;
        final allowed = section == 'dev_dependencies'
            ? depLayer <= layer
            : depLayer < layer;
        if (!allowed)
          problems.add(
            '$name -> $dep ($section): layer $layer may not depend on layer $depLayer',
          );
      }
      for (final dep in deps.where(
        (d) => d.startsWith('camouflage_') && !layers.containsKey(d),
      )) {
        problems.add(
          '$name -> $dep ($section): $dep has no layer in tool/layers.yaml',
        );
      }
    }
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Layer check failed:');
    for (final p in problems) {
      stderr.writeln('  $p');
    }
    exit(1);
  }
  stdout.writeln('Layers OK (${members.length} packages).');
}
