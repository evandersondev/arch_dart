import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ResideInRule extends ArchRule {
  final String package;
  final String expectedLocation;
  final List<String>? allowedPackages;
  final bool isFolder;
  final bool negate;

  ResideInRule(
    this.package,
    this.expectedLocation, {
    this.allowedPackages,
    this.isFolder = false,
    this.negate = false,
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      // Se package não está vazio, filtra por ele primeiro
      if (package.isNotEmpty && !path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          _checkClassLocation(declaration, path, violations);
        } else if (declaration is EnumDeclaration) {
          _checkEnumLocation(declaration, path, violations);
        } else if (declaration is FunctionDeclaration) {
          _checkFunctionLocation(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('ResideIn', violations));
    }
  }

  void _checkClassLocation(
      ClassDeclaration declaration, String path, List<String> violations) {
    final className = declaration.name.lexeme;

    // Se o package não está vazio, verifica se a classe corresponde ao filtro
    if (package.isNotEmpty) {
      // Verifica se a classe corresponde ao filtro do package (ex: classes terminadas com 'Controller')
      if (!_classMatchesPackageFilter(className)) return;
    }

    final isInCorrectLocation = _checkLocation(path);

    if (negate) {
      if (isInCorrectLocation) {
        violations.add(
            'Class "$className" should NOT be in ${_getLocationDescription()} (file: $path)');
      }
    } else {
      if (!isInCorrectLocation) {
        violations.add(
            'Class "$className" should be in ${_getLocationDescription()} (file: $path)');
      }
    }
  }

  void _checkEnumLocation(
      EnumDeclaration declaration, String path, List<String> violations) {
    final enumName = declaration.name.lexeme;

    if (package.isNotEmpty) {
      if (!_enumMatchesPackageFilter(enumName)) return;
    }

    final isInCorrectLocation = _checkLocation(path);

    if (negate) {
      if (isInCorrectLocation) {
        violations.add(
            'Enum "$enumName" should NOT be in ${_getLocationDescription()} (file: $path)');
      }
    } else {
      if (!isInCorrectLocation) {
        violations.add(
            'Enum "$enumName" should be in ${_getLocationDescription()} (file: $path)');
      }
    }
  }

  void _checkFunctionLocation(
      FunctionDeclaration declaration, String path, List<String> violations) {
    final functionName = declaration.name.lexeme;

    if (package.isNotEmpty) {
      if (!_functionMatchesPackageFilter(functionName)) return;
    }

    final isInCorrectLocation = _checkLocation(path);

    if (negate) {
      if (isInCorrectLocation) {
        violations.add(
            'Function "$functionName" should NOT be in ${_getLocationDescription()} (file: $path)');
      }
    } else {
      if (!isInCorrectLocation) {
        violations.add(
            'Function "$functionName" should be in ${_getLocationDescription()} (file: $path)');
      }
    }
  }

  bool _checkLocation(String filePath) {
    if (isFolder) {
      // Normaliza os caminhos para comparação
      final normalizedPath = p.normalize(filePath).replaceAll('\\', '/');
      final normalizedExpected =
          p.normalize(expectedLocation).replaceAll('\\', '/');

      // Verifica se o arquivo está na pasta especificada
      return normalizedPath.contains(normalizedExpected);
    } else if (allowedPackages != null) {
      // Verifica se está em qualquer um dos pacotes permitidos
      return allowedPackages!.any((pkg) => filePath.contains(pkg));
    } else {
      // Verifica se está no pacote específico
      return filePath.contains(expectedLocation);
    }
  }

  bool _classMatchesPackageFilter(String className) {
    // Esta lógica precisa ser expandida baseada no filtro aplicado
    // Por enquanto, retorna true para permitir todas as classes
    // Em uma implementação completa, isso seria baseado no filtro anterior
    return true;
  }

  bool _enumMatchesPackageFilter(String enumName) {
    return true;
  }

  bool _functionMatchesPackageFilter(String functionName) {
    return true;
  }

  String _getLocationDescription() {
    if (isFolder) {
      return 'folder "$expectedLocation"';
    } else if (allowedPackages != null) {
      return 'one of packages: ${allowedPackages!.join(', ')}';
    } else {
      return 'package "$expectedLocation"';
    }
  }
}
