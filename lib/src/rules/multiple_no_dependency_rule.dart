import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class MultipleNoDependencyRule extends ArchRule {
  final String package;
  final List<String> forbiddenPackages;

  MultipleNoDependencyRule(this.package, this.forbiddenPackages);

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

          for (final forbiddenPackage in forbiddenPackages) {
            if (importPath.contains(forbiddenPackage)) {
              violations.add(
                  'Package "$package" should not depend on "$forbiddenPackage" '
                  'but imports "$importPath" (file: $path)');
            }
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('MultipleNoDependency', violations));
    }
  }
}
