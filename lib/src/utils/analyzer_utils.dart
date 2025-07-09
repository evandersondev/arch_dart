import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

Future<Map<String, CompilationUnit>> parseDirectoryWithPaths(
    String path) async {
  final dartFiles = Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  final result = <String, CompilationUnit>{};

  for (var file in dartFiles) {
    final content = await file.readAsString();
    final parsed = parseString(content: content, path: file.path);
    result[file.path] = parsed.unit;
  }

  return result;
}
