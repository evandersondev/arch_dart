import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class OnlyDependencyRule extends ArchRule {
  final String sourcePackage;
  final List<String> allowedPackages;
  final bool allowExternalPackages;
  final List<String> allowedExternalPackages;

  OnlyDependencyRule(
    this.sourcePackage,
    this.allowedPackages, {
    this.allowExternalPackages = true,
    this.allowedExternalPackages = const [
      'flutter',
      'dart:',
    ],
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    // Detectar o nome do projeto
    final projectName = await _detectProjectName('.');

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(sourcePackage)) continue;

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';

          if (_isViolation(importPath, projectName)) {
            final violatingLayer = _getViolatingLayer(importPath);
            violations.add(
                'File "$path" violates dependency rule: cannot import from "$violatingLayer" layer. '
                'Package "$sourcePackage" should only depend on: ${allowedPackages.join(', ')} '
                '(import: $importPath)');
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('OnlyDependency', violations));
    }
  }

  Future<String?> _detectProjectName(String rootDir) async {
    try {
      // Procurar pubspec.yaml no diretório pai
      var currentDir = Directory(rootDir).parent;

      for (int i = 0; i < 3; i++) {
        // Procurar até 3 níveis acima
        final pubspecPath = p.join(currentDir.path, 'pubspec.yaml');
        final pubspecFile = File(pubspecPath);

        if (await pubspecFile.exists()) {
          final content = await pubspecFile.readAsString();
          final lines = content.split('\n');

          for (final line in lines) {
            if (line.trim().startsWith('name:')) {
              return line.split(':')[1].trim();
            }
          }
        }

        currentDir = currentDir.parent;
      }
    } catch (e) {
      // Ignorar erros
    }
    return null;
  }

  bool _isViolation(String importPath, String? projectName) {
    // Permitir imports relativos
    if (importPath.startsWith('./') || importPath.startsWith('../')) {
      return false;
    }

    // Verificar se é um import externo permitido
    if (allowExternalPackages) {
      for (final allowedExternal in allowedExternalPackages) {
        if (importPath.startsWith(allowedExternal)) {
          return false;
        }
      }
    }

    // Verificar imports do próprio projeto
    bool isInternalImport = false;

    if (projectName != null && importPath.startsWith('package:$projectName/')) {
      isInternalImport = true;
    } else if (importPath.startsWith('lib/')) {
      isInternalImport = true;
    }

    if (isInternalImport) {
      // Verificar se está nos pacotes permitidos
      for (final allowedPackage in allowedPackages) {
        if (importPath.contains('/$allowedPackage/') ||
            importPath.contains('$allowedPackage/')) {
          return false; // Não é violação
        }
      }
      return true; // É violação - import interno não permitido
    }

    // Para outros imports de packages externos
    if (importPath.startsWith('package:')) {
      return !allowExternalPackages;
    }

    return false;
  }

  String _getViolatingLayer(String importPath) {
    final commonLayers = ['presentation', 'domain', 'data', 'infra', 'core'];

    for (final layer in commonLayers) {
      if (importPath.contains('/$layer/') || importPath.contains('$layer/')) {
        return layer;
      }
    }

    return 'unknown';
  }
}
