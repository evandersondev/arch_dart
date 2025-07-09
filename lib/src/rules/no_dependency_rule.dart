import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class NoDependencyRule extends ArchRule {
  final String sourcePackage;
  final String targetPackage;

  NoDependencyRule(this.sourcePackage, this.targetPackage);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(sourcePackage)) continue;

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';

          if (importPath.contains(targetPackage)) {
            violations.add(RuleMessages.dependencyViolation(
                path, targetPackage, importPath));
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Dependency', violations));
    }
  }
}
