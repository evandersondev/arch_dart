import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class AccessRule extends ArchRule {
  final String targetPackage;
  final List<String> allowedPackages;

  AccessRule(this.targetPackage, this.allowedPackages);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      // Skip files in target package or allowed packages
      if (path.contains(targetPackage) ||
          allowedPackages.any((allowed) => path.contains(allowed))) {
        continue;
      }

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';

          if (importPath.contains(targetPackage)) {
            violations.add(RuleMessages.accessViolation(
                'classes in $targetPackage', allowedPackages, path));
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Access', violations));
    }
  }

  // String? _getPackageFromPath(String path, String rootDir) {
  //   final relativePath = p.relative(path, from: rootDir);
  //   final parts = p.split(relativePath);
  //   if (parts.isEmpty) return null;
  //   return parts.first;
  // }

  // Future<String> _getProjectName(String rootDir) async {
  //   try {
  //     final pubspecFile = File(p.join(rootDir, '../pubspec.yaml'));
  //     if (!pubspecFile.existsSync()) return '';
  //     final content = await pubspecFile.readAsString();
  //     final yaml = loadYaml(content) as Map;
  //     return yaml['name'] as String? ?? '';
  //   } catch (e) {
  //     print('Erro ao ler pubspec.yaml: $e');
  //     return '';
  //   }
  // }
}
