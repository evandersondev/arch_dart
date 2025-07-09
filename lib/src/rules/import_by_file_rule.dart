// lib/rules/import_by_file_rule.dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ImportByFileRule extends ArchRule {
  final String importeePackage; // Ex: domain/entities
  final String targetFileName; // Ex: main.dart

  ImportByFileRule(this.importeePackage, this.targetFileName);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final filePath = p.normalize(entry.key);
      final unit = entry.value;

      if (!filePath.endsWith(targetFileName)) continue;

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';
          if (importPath.contains(importeePackage)) {
            violations.add(
              'The file "$filePath" not be imported in "$importPath" of package "$importeePackage".',
            );
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('ImportByFile', violations));
    }
  }
}
