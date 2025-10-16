import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class CyclicDependencyRule extends ArchRule {
  final List<String> packages;

  CyclicDependencyRule(this.packages);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final dependencies = <String, Set<String>>{};

    // Build dependency graph
    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      final sourcePackage = _getPackageFromPath(path);
      if (sourcePackage == null || !packages.contains(sourcePackage)) continue;

      dependencies[sourcePackage] ??= <String>{};

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';
          final targetPackage = _getPackageFromImport(importPath);

          if (targetPackage != null &&
              packages.contains(targetPackage) &&
              targetPackage != sourcePackage) {
            dependencies[sourcePackage]!.add(targetPackage);
          }
        }
      }
    }

    // Check for cycles
    final violations = <String>[];
    for (final package in packages) {
      final cycle = _findCycle(package, dependencies, <String>{}, <String>[]);
      if (cycle != null) {
        violations.add(RuleMessages.cyclicDependencyViolation(cycle));
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('Cyclic dependency', violations));
    }
  }

  String? _getPackageFromPath(String path) {
    for (final package in packages) {
      if (path.contains(package)) {
        return package;
      }
    }
    return null;
  }

  String? _getPackageFromImport(String importPath) {
    for (final package in packages) {
      if (importPath.contains(package)) {
        return package;
      }
    }
    return null;
  }

  List<String>? _findCycle(
      String current,
      Map<String, Set<String>> dependencies,
      Set<String> visited,
      List<String> path) {
    if (path.contains(current)) {
      final cycleStart = path.indexOf(current);
      return path.sublist(cycleStart)..add(current);
    }

    if (visited.contains(current)) {
      return null;
    }

    visited.add(current);
    path.add(current);

    final deps = dependencies[current] ?? <String>{};
    for (final dep in deps) {
      final cycle = _findCycle(dep, dependencies, visited, List.from(path));
      if (cycle != null) {
        return cycle;
      }
    }

    path.remove(current);
    return null;
  }
}
