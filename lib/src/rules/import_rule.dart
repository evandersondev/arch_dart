import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ImportRule extends ArchRule {
  final String package;
  final List<String> forbiddenImports;

  ImportRule(this.package, this.forbiddenImports);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';

          for (final forbidden in forbiddenImports) {
            if (importPath.contains(forbidden)) {
              violations.add(RuleMessages.importViolation(path, importPath));
            }
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Import', violations));
    }
  }
}
