// ignore_for_file: avoid_print
//
// Cetak & simpan struktur folder `lib/` — selalu up-to-date.
//
// Usage (dari root proyek travelindo):
//   dart scripts/print_tree.dart
//   dart scripts/print_tree.dart --depth=4
//   dart scripts/print_tree.dart --out=docs/lib_structure.txt

import 'dart:io';

void main(List<String> args) {
  final options = _parseArgs(args);
  final projectRoot = _findProjectRoot();
  final libDir = Directory('${projectRoot.path}${Platform.pathSeparator}lib');

  if (!libDir.existsSync()) {
    stderr.writeln('ERROR: lib/ tidak ditemukan di ${projectRoot.path}');
    exit(1);
  }

  final buffer = StringBuffer()
    ..writeln('# Travelindo — lib/ structure')
    ..writeln('# Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('# Run: dart scripts/print_tree.dart')
    ..writeln();

  _printTree(
    dir: libDir,
    buffer: buffer,
    prefix: '',
    isLast: true,
    depth: 0,
    maxDepth: options.maxDepth,
  );

  final output = buffer.toString();
  stdout.writeln(output);

  final outFile = File('${projectRoot.path}${Platform.pathSeparator}${options.outPath}');
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(output);
  stdout.writeln('---');
  stdout.writeln('Saved → ${outFile.path}');
}

class _Options {
  const _Options({required this.maxDepth, required this.outPath});
  final int maxDepth;
  final String outPath;
}

_Options _parseArgs(List<String> args) {
  var maxDepth = 99;
  var outPath = 'docs${Platform.pathSeparator}lib_structure.txt';

  for (final arg in args) {
    if (arg.startsWith('--depth=')) {
      maxDepth = int.tryParse(arg.split('=').last) ?? maxDepth;
    } else if (arg.startsWith('--out=')) {
      outPath = arg.split('=').last;
    } else if (arg == '--help' || arg == '-h') {
      stdout.writeln('Usage: dart scripts/print_tree.dart [--depth=N] [--out=path]');
      exit(0);
    }
  }

  return _Options(maxDepth: maxDepth, outPath: outPath);
}

Directory _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      stderr.writeln('ERROR: pubspec.yaml tidak ditemukan — jalankan dari folder travelindo');
      exit(1);
    }
    dir = parent;
  }
}

void _printTree({
  required Directory dir,
  required StringBuffer buffer,
  required String prefix,
  required bool isLast,
  required int depth,
  required int maxDepth,
}) {
  final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? dir.path;
  final connector = isLast ? '└── ' : '├── ';
  buffer.writeln('$prefix$connector$name/');

  if (depth >= maxDepth) return;

  final childPrefix = prefix + (isLast ? '    ' : '│   ');

  final entries = dir
      .listSync()
      .where((e) {
        final base = e.uri.pathSegments.last;
        if (base.startsWith('.')) return false;
        if (e is File && !base.endsWith('.dart')) return false;
        return true;
      })
      .toList()
    ..sort((a, b) {
      final aIsDir = a is Directory;
      final bIsDir = b is Directory;
      if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });

  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    final last = i == entries.length - 1;

    if (entry is Directory) {
      _printTree(
        dir: entry,
        buffer: buffer,
        prefix: childPrefix,
        isLast: last,
        depth: depth + 1,
        maxDepth: maxDepth,
      );
    } else if (entry is File) {
      final fileName = entry.uri.pathSegments.last;
      final fileConnector = last ? '└── ' : '├── ';
      buffer.writeln('$childPrefix$fileConnector$fileName');
    }
  }
}
