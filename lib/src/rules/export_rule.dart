import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ExportRule extends ArchRule {
  final String package;
  final String? targetFile;
  final List<String>? forbiddenExports;
  final List<String>? requiredExports;

  // Constructor for shouldNotBeExportedIn usage
  ExportRule(this.package, this.targetFile)
      : forbiddenExports = null,
        requiredExports = null;

  // Named constructor for more complex export rules
  ExportRule.withRules(
    this.package, {
    this.forbiddenExports,
    this.requiredExports,
  }) : targetFile = null;

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    if (targetFile != null) {
      // Check if package is exported in specific file
      _checkNotExportedInFile(unitsWithPath, violations);
    } else {
      // Check forbidden/required exports
      _checkExportRules(unitsWithPath, violations);
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Export', violations));
    }
  }

  void _checkNotExportedInFile(
      Map<String, CompilationUnit> unitsWithPath, List<String> violations) {
    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(targetFile!)) continue;

      for (final directive in unit.directives) {
        if (directive is ExportDirective) {
          final exportPath = directive.uri.stringValue ?? '';

          if (exportPath.contains(package)) {
            violations.add(
                'File "$path" must not export anything from package "$package"');
          }
        }
      }
    }
  }

  void _checkExportRules(
      Map<String, CompilationUnit> unitsWithPath, List<String> violations) {
    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      final exports = <String>[];

      for (final directive in unit.directives) {
        if (directive is ExportDirective) {
          final exportPath = directive.uri.stringValue ?? '';
          exports.add(exportPath);

          // Check forbidden exports
          if (forbiddenExports != null) {
            for (final forbidden in forbiddenExports!) {
              if (exportPath.contains(forbidden)) {
                violations.add('File "$path" must not export "$exportPath"');
              }
            }
          }
        }
      }

      // Check required exports
      if (requiredExports != null) {
        for (final required in requiredExports!) {
          final hasRequiredExport =
              exports.any((export) => export.contains(required));
          if (!hasRequiredExport) {
            violations.add(
                'File "$path" must export something containing "$required"');
          }
        }
      }
    }
  }
}
