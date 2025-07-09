import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class MultipleImportByFileRule extends ArchRule {
  final String importeePackage; // Ex: domain/entities
  final List<String> targetFiles; // Ex: [main.dart, app.dart]

  MultipleImportByFileRule(this.importeePackage, this.targetFiles);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final filePath = p.normalize(entry.key);
      final unit = entry.value;

      final isTargetFile =
          targetFiles.any((target) => filePath.endsWith(target));
      if (!isTargetFile) continue;

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
      throw Exception(
          RuleMessages.violationFound('MultipleImportByFile', violations));
    }
  }
}
