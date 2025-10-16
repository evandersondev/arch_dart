import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class FeaturesIndependenceRule extends ArchRule {
  final String featuresPath;

  FeaturesIndependenceRule([this.featuresPath = 'features']);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    // Map to store feature dependencies
    final featureDependencies = <String, Set<String>>{};

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(featuresPath)) continue;

      final feature = _extractFeatureName(path);
      if (feature == null) continue;

      featureDependencies[feature] ??= <String>{};

      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';
          final importedFeature = _extractFeatureFromImport(importPath);

          if (importedFeature != null && importedFeature != feature) {
            featureDependencies[feature]!.add(importedFeature);
            violations.add(RuleMessages.dependencyViolation(
                path, 'feature "$importedFeature"', importPath));
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('Features independence', violations));
    }
  }

  String? _extractFeatureName(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    final featuresIndex = parts.indexOf(featuresPath);

    if (featuresIndex >= 0 && featuresIndex + 1 < parts.length) {
      return parts[featuresIndex + 1];
    }

    return null;
  }

  String? _extractFeatureFromImport(String importPath) {
    if (importPath.contains('/$featuresPath/')) {
      final parts = importPath.split('/$featuresPath/');
      if (parts.length > 1) {
        final featurePart = parts[1].split('/').first;
        return featurePart;
      }
    }

    return null;
  }
}
