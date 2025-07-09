import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class NamingRule extends ArchRule {
  final String package;
  final String pattern;
  final bool checkContains;
  final bool checkPrefix;
  final bool checkClasses;
  final bool checkMethods;
  final bool checkFunctions;
  final bool checkEnums;
  final bool negate;

  NamingRule(
    this.package,
    this.pattern, {
    this.checkContains = false,
    this.checkPrefix = false,
    this.checkClasses = true,
    this.checkMethods = false,
    this.checkFunctions = false,
    this.checkEnums = false,
    this.negate = false,
  });

  // Constructor específico para métodos
  NamingRule.forMethods(
    this.package,
    this.pattern, {
    this.checkContains = false,
    this.checkPrefix = false,
    this.negate = false,
  })  : checkClasses = false,
        checkMethods = true,
        checkFunctions = false,
        checkEnums = false;

  // Constructor específico para funções
  NamingRule.forFunctions(
    this.package,
    this.pattern, {
    this.checkContains = false,
    this.checkPrefix = false,
    this.negate = false,
  })  : checkClasses = false,
        checkMethods = false,
        checkFunctions = true,
        checkEnums = false;

  // Constructor específico para enums
  NamingRule.forEnums(
    this.package,
    this.pattern, {
    this.checkContains = false,
    this.checkPrefix = false,
    this.negate = false,
  })  : checkClasses = false,
        checkMethods = false,
        checkFunctions = false,
        checkEnums = true;

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (checkClasses && declaration is ClassDeclaration) {
          _checkClassName(declaration, path, violations);
        } else if (checkEnums && declaration is EnumDeclaration) {
          _checkEnumName(declaration, path, violations);
        } else if (checkFunctions && declaration is FunctionDeclaration) {
          _checkFunctionName(declaration, path, violations);
        } else if (checkMethods && declaration is ClassDeclaration) {
          _checkMethodNames(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Naming', violations));
    }
  }

  void _checkClassName(
      ClassDeclaration declaration, String path, List<String> violations) {
    final className = declaration.name.lexeme;
    final matches = _nameMatches(className);

    if (negate) {
      if (matches) {
        violations.add(
            'Class "$className" should NOT ${_getPatternDescription()} (file: $path)');
      }
    } else {
      if (!matches) {
        violations.add(
            'Class "$className" should ${_getPatternDescription()} (file: $path)');
      }
    }
  }

  void _checkEnumName(
      EnumDeclaration declaration, String path, List<String> violations) {
    final enumName = declaration.name.lexeme;
    final matches = _nameMatches(enumName);

    if (negate) {
      if (matches) {
        violations.add(
            'Enum "$enumName" should NOT ${_getPatternDescription()} (file: $path)');
      }
    } else {
      if (!matches) {
        violations.add(
            'Enum "$enumName" should ${_getPatternDescription()} (file: $path)');
      }
    }
  }

  void _checkFunctionName(
      FunctionDeclaration declaration, String path, List<String> violations) {
    final functionName = declaration.name.lexeme;
    final matches = _nameMatches(functionName);

    if (negate) {
      if (matches) {
        violations.add(
            'Function "$functionName" should NOT ${_getPatternDescription()} (file: $path)');
      }
    } else {
      if (!matches) {
        violations.add(
            'Function "$functionName" should ${_getPatternDescription()} (file: $path)');
      }
    }
  }

  void _checkMethodNames(
      ClassDeclaration classDeclaration, String path, List<String> violations) {
    final className = classDeclaration.name.lexeme;
    final methods = classDeclaration.members.whereType<MethodDeclaration>();

    for (final method in methods) {
      final methodName = method.name.lexeme;
      final matches = _nameMatches(methodName);

      if (negate) {
        if (matches) {
          violations.add(
              'Method "$methodName" in class "$className" should NOT ${_getPatternDescription()} (file: $path)');
        }
      } else {
        if (!matches) {
          violations.add(
              'Method "$methodName" in class "$className" should ${_getPatternDescription()} (file: $path)');
        }
      }
    }
  }

  bool _nameMatches(String name) {
    if (checkContains) {
      return name.contains(pattern);
    } else if (checkPrefix) {
      return name.startsWith(pattern);
    } else {
      // Por padrão, verifica se termina com o padrão
      return name.endsWith(pattern);
    }
  }

  String _getPatternDescription() {
    if (checkContains) {
      return 'contain "$pattern"';
    } else if (checkPrefix) {
      return 'start with "$pattern"';
    } else {
      return 'end with "$pattern"';
    }
  }
}
