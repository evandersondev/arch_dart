import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class CleanArchitectureRule extends ArchRule {
  final String layer;
  final List<String> allowedLayers;

  static const Map<String, List<String>> _defaultLayerRules = {
    'domain': [], // Domain não deve depender de nenhuma outra camada
    'data': ['domain'], // Data pode depender apenas de Domain
    'presentation': ['domain'], // Presentation pode depender apenas de Domain
    'infra': ['domain', 'data'], // Infra pode depender de Domain e Data
  };

  CleanArchitectureRule(this.layer, {List<String>? allowedLayers})
      : allowedLayers = allowedLayers ?? _defaultLayerRules[layer] ?? [];

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(layer)) continue;

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';

          if (_isArchitectureViolation(importPath)) {
            violations.add(
                'Layer "$layer" should not depend on "${_getViolatingLayer(importPath)}" '
                '(file: $path, import: $importPath)');
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('CleanArchitecture', violations));
    }
  }

  bool _isArchitectureViolation(String importPath) {
    // Ignorar imports externos (Flutter, Dart, packages)
    if (importPath.startsWith('package:flutter') ||
        importPath.startsWith('package:dart') ||
        importPath.startsWith('dart:') ||
        importPath.startsWith('./') ||
        importPath.startsWith('../')) {
      return false;
    }

    // Verificar se é import interno do projeto
    if (importPath.startsWith('lib/') || importPath.contains('/lib/')) {
      final layers = ['domain', 'data', 'presentation', 'infra'];

      for (final forbiddenLayer in layers) {
        if (forbiddenLayer != layer &&
            !allowedLayers.contains(forbiddenLayer) &&
            importPath.contains(forbiddenLayer)) {
          return true;
        }
      }
    }

    return false;
  }

  String _getViolatingLayer(String importPath) {
    final layers = ['domain', 'data', 'presentation', 'infra'];

    for (final layerName in layers) {
      if (importPath.contains(layerName)) {
        return layerName;
      }
    }

    return 'unknown layer';
  }
}
