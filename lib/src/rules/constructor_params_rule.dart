import 'package:analyzer/dart/ast/ast.dart';

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

enum ConstructorParamsRuleType {
  requireAllParams,
  onlyNamedRequiredParams,
}

class ConstructorParamsRule extends ArchRule {
  final String package;
  final ConstructorParamsRuleType ruleType;

  ConstructorParamsRule(this.package, this.ruleType);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = entry.key;
      final unit = entry.value;

      if (package.isNotEmpty && !path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          _checkClassConstructors(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('ConstructorParams', violations));
    }
  }

  void _checkClassConstructors(
      ClassDeclaration classDecl, String path, List<String> violations) {
    final className = classDecl.name.lexeme;

    for (final member in classDecl.members) {
      if (member is ConstructorDeclaration) {
        _checkConstructor(member, className, path, violations);
      }
    }
  }

  void _checkConstructor(ConstructorDeclaration constructor, String className,
      String path, List<String> violations) {
    final constructorName = constructor.name?.lexeme ?? 'default';
    final parameters = constructor.parameters;

    switch (ruleType) {
      case ConstructorParamsRuleType.requireAllParams:
        _checkRequireAllParams(
            parameters, className, constructorName, path, violations);
        break;
      case ConstructorParamsRuleType.onlyNamedRequiredParams:
        _checkOnlyNamedRequiredParams(
            parameters, className, constructorName, path, violations);
        break;
    }
  }

  void _checkRequireAllParams(FormalParameterList parameters, String className,
      String constructorName, String path, List<String> violations) {
    final hasOptionalParams = parameters.parameters.any((param) {
      return param is DefaultFormalParameter || param.isOptional;
    });

    if (hasOptionalParams) {
      violations.add(
          'Constructor "$constructorName" in class "$className" should require all parameters (file: $path)');
    }
  }

  void _checkOnlyNamedRequiredParams(
      FormalParameterList parameters,
      String className,
      String constructorName,
      String path,
      List<String> violations) {
    // Verifica se todos os parâmetros são nomeados e obrigatórios
    for (final param in parameters.parameters) {
      if (param is! DefaultFormalParameter) {
        // Parâmetro posicional obrigatório - OK se não há parâmetros nomeados
        continue;
      }

      final defaultParam = param;

      // Se é um parâmetro nomeado
      if (defaultParam.isNamed) {
        // Verifica se é obrigatório (required)
        if (!defaultParam.isRequired && defaultParam.defaultValue == null) {
          violations.add(
              'Constructor "$constructorName" in class "$className" has optional named parameter "${_getParameterName(defaultParam)}" - all named parameters should be required (file: $path)');
        }
      } else if (defaultParam.isOptional) {
        // Parâmetro posicional opcional
        violations.add(
            'Constructor "$constructorName" in class "$className" has optional positional parameter "${_getParameterName(defaultParam)}" - use named required parameters instead (file: $path)');
      }
    }

    // Verifica se há mistura de parâmetros posicionais e nomeados
    final hasPositional = parameters.parameters.any((param) =>
        param is! DefaultFormalParameter ||
        (!param.isNamed && !param.isOptional));

    final hasNamed = parameters.parameters
        .any((param) => param is DefaultFormalParameter && param.isNamed);

    if (hasPositional && hasNamed) {
      violations.add(
          'Constructor "$constructorName" in class "$className" mixes positional and named parameters - use only named required parameters (file: $path)');
    }

    // Se há apenas parâmetros nomeados, verifica se todos são obrigatórios
    if (hasNamed && !hasPositional) {
      final namedParams = parameters.parameters
          .whereType<DefaultFormalParameter>()
          .where((param) => param.isNamed);

      for (final param in namedParams) {
        if (!param.isRequired) {
          violations.add(
              'Constructor "$constructorName" in class "$className" has optional named parameter "${_getParameterName(param)}" - all named parameters should be required (file: $path)');
        }
      }
    }
  }

  String _getParameterName(DefaultFormalParameter param) {
    if (param.parameter is SimpleFormalParameter) {
      return (param.parameter as SimpleFormalParameter).name?.lexeme ??
          'unknown';
    }
    return 'unknown';
  }
}
