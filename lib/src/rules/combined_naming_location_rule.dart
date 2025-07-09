import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class CombinedNamingLocationRule extends ArchRule {
  final String namePattern;
  final String expectedFolder;
  final bool checkContains;
  final bool checkPrefix;
  final bool negate;

  CombinedNamingLocationRule(
    this.namePattern,
    this.expectedFolder, {
    this.checkContains = false,
    this.checkPrefix = false,
    this.negate = false,
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];
    final matchingClasses = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;

          // Verifica se o nome da classe corresponde ao padrão
          if (_nameMatches(className)) {
            matchingClasses.add('$className at $path');

            // Verifica se está na pasta correta
            final isInCorrectFolder = _isInCorrectFolder(path);

            if (negate) {
              if (isInCorrectFolder) {
                violations.add(
                    'Class "$className" should NOT be in folder "$expectedFolder" (file: $path)');
              }
            } else {
              if (!isInCorrectFolder) {
                violations.add(
                    'Class "$className" with name ${_getPatternDescription()} should be in folder "$expectedFolder" (file: $path)');
              }
            }
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('CombinedNamingLocation', violations));
    }
  }

  bool _nameMatches(String name) {
    if (checkContains) {
      return name.contains(namePattern);
    } else if (checkPrefix) {
      return name.startsWith(namePattern);
    } else {
      // Por padrão, verifica se termina com o padrão
      return name.endsWith(namePattern);
    }
  }

  bool _isInCorrectFolder(String filePath) {
    // Converte para forward slashes para consistência
    final normalizedPath = filePath.replaceAll('\\', '/');
    final normalizedExpected = expectedFolder.replaceAll('\\', '/');

    // Verifica se o caminho contém a pasta esperada
    // Pode ser uma correspondência exata ou uma subpasta
    return normalizedPath.contains(normalizedExpected) ||
        normalizedPath.contains('/$normalizedExpected/') ||
        normalizedPath.endsWith('/$normalizedExpected') ||
        normalizedPath.contains('$normalizedExpected/');
  }

  String _getPatternDescription() {
    if (checkContains) {
      return 'containing "$namePattern"';
    } else if (checkPrefix) {
      return 'starting with "$namePattern"';
    } else {
      return 'ending with "$namePattern"';
    }
  }
}
