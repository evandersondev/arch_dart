import 'dart:io';

import 'package:path/path.dart' as p;

import '../utils/layer_validation_type.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class LayerRule extends ArchRule {
  final List<String> layers;
  final LayerValidationType validationType;
  final bool allowMissingLayers;

  LayerRule(
    this.layers, {
    this.validationType = LayerValidationType.both,
    this.allowMissingLayers = true,
  });

  @override
  Future<void> check() async {
    final violations = <String>[];

    switch (validationType) {
      case LayerValidationType.structure:
        await _checkStructure('lib', violations);
        break;
      case LayerValidationType.dependencies:
        await _checkDependencies('lib', violations);
        break;
      case LayerValidationType.both:
        await _checkStructure('lib', violations);
        await _checkDependencies('lib', violations);
        break;
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Layer', violations));
    }
  }

  Future<void> _checkStructure(String rootDir, List<String> violations) async {
    final rootDirectory = Directory(rootDir);
    if (!await rootDirectory.exists()) {
      // Se o diretório raiz (ex: 'lib') não existir, não há o que checar.
      return;
    }
    final directory = rootDirectory;
    final existingLayers = <String>[];

    // Find existing layers
    await for (final entity in directory.list()) {
      if (entity is Directory) {
        final dirName = p.basename(entity.path);
        if (layers.contains(dirName)) {
          existingLayers.add(dirName);
        } else if (!_isCommonDirectory(dirName)) {
          // Report any directory that is not in the allowed list and not a common ignored one.
          violations.add(
            'Unexpected directory "$dirName" found in "lib/". Only directories defined in the rule are allowed.',
          );
        }
      }
    }

    // Check for missing layers
    if (!allowMissingLayers) {
      for (final layer in layers) {
        if (!existingLayers.contains(layer)) {
          violations
              .add('Required layer "$layer" is missing in project structure');
        }
      }
    }
  }

  Future<void> _checkDependencies(
      String rootDir, List<String> violations) async {
    // Create a dependency hierarchy based on layer order
    final layerHierarchy = <String, int>{};
    for (int i = 0; i < layers.length; i++) {
      layerHierarchy[layers[i]] = i;
    }

    final rootDirectory = Directory(rootDir);
    if (!await rootDirectory.exists()) {
      // Se o diretório raiz (ex: 'lib') não existir, não há o que checar.
      return;
    }
    final directory = rootDirectory;

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final path = p.normalize(entity.path);
        final currentLayer = _getLayerFromPath(path);

        if (currentLayer == null) continue;

        final content = await entity.readAsString();
        final imports = _extractImports(content);

        for (final import in imports) {
          final importedLayer = _getLayerFromImport(import, rootDir);

          if (importedLayer != null && importedLayer != currentLayer) {
            final currentLayerIndex = layerHierarchy[currentLayer] ?? -1;
            final importedLayerIndex = layerHierarchy[importedLayer] ?? -1;

            // Check if the dependency violates the layer hierarchy
            // Higher layers (lower index) should not depend on lower layers (higher index)
            if (currentLayerIndex >= 0 &&
                importedLayerIndex >= 0 &&
                currentLayerIndex < importedLayerIndex) {
              violations.add(RuleMessages.dependencyViolation(
                  path,
                  'layer "$importedLayer"',
                  'Layer "$currentLayer" should not depend on layer "$importedLayer"'));
            }
          }
        }
      }
    }
  }

  String? _getLayerFromPath(String path) {
    for (final layer in layers) {
      if (path.contains('/$layer/') || path.contains('\\$layer\\')) {
        return layer;
      }
    }
    return null;
  }

  String? _getLayerFromImport(String import, String rootDir) {
    // Handle relative imports
    if (import.startsWith('./') || import.startsWith('../')) {
      return null; // Skip relative imports for now
    }

    // Handle package imports
    for (final layer in layers) {
      if (import.contains('/$layer/')) {
        return layer;
      }
    }

    return null;
  }

  List<String> _extractImports(String content) {
    final imports = <String>[];
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('import ')) {
        // Abordagem mais simples - extrair o que está entre aspas
        final singleQuoteMatch =
            RegExp(r"import\s+'([^']+)'").firstMatch(trimmed);
        final doubleQuoteMatch =
            RegExp(r'import\s+"([^"]+)"').firstMatch(trimmed);

        if (singleQuoteMatch != null) {
          imports.add(singleQuoteMatch.group(1)!);
        } else if (doubleQuoteMatch != null) {
          imports.add(doubleQuoteMatch.group(1)!);
        }
      }
    }

    return imports;
  }

  bool _isCommonDirectory(String dirName) {
    const commonDirs = {
      '.dart_tool',
      '.git',
      '.idea',
      '.vscode',
      'build',
      'node_modules',
      'test',
      'tests',
      'example',
      'examples',
      'doc',
      'docs',
      'assets',
      'web',
      'android',
      'ios',
      'linux',
      'macos',
      'windows',
    };

    // Ignora diretórios comuns e qualquer diretório que comece com '.'
    return commonDirs.contains(dirName) || dirName.startsWith('.');
  }
}
