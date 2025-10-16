import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ConstructorParameterRule extends ArchRule {
  final String package;
  final String? expectedType;
  final String? parameterName;
  final bool? isRequired;
  final bool? isNamed;
  final bool? allRequired;
  final bool? onlyNamedRequired;

  ConstructorParameterRule(
    this.package, {
    this.expectedType,
    this.parameterName,
    this.isRequired,
    this.isNamed,
    this.allRequired,
    this.onlyNamedRequired,
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;

          final constructors =
              declaration.members.whereType<ConstructorDeclaration>().toList();

          for (final constructor in constructors) {
            final constructorName = constructor.name?.lexeme ?? 'default';
            _checkConstructorParameters(
                constructor, className, constructorName, path, violations);
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('Constructor parameter', violations));
    }
  }

  void _checkConstructorParameters(
      ConstructorDeclaration constructor,
      String className,
      String constructorName,
      String path,
      List<String> violations) {
    final parameters = constructor.parameters.parameters;

    if (allRequired == true) {
      final hasOptionalParams = parameters.any((param) => !param.isRequired);
      if (hasOptionalParams) {
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName',
            'must have all parameters required',
            path));
      }
    }

    if (onlyNamedRequired == true) {
      final hasPositionalParams = parameters.any((param) => !param.isNamed);
      if (hasPositionalParams) {
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName',
            'must have only named required parameters',
            path));
      }

      final hasOptionalNamedParams =
          parameters.any((param) => param.isNamed && !param.isRequired);
      if (hasOptionalNamedParams) {
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName',
            'must have only required named parameters',
            path));
      }
    }

    if (parameterName != null) {
      final hasParameter = parameters.any((param) {
        final name = param.name?.lexeme ?? '';
        return name == parameterName;
      });

      if (!hasParameter) {
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName',
            'must have parameter "$parameterName"',
            path));
        return;
      }

      final parameter =
          parameters.firstWhere((param) => param.name?.lexeme == parameterName);
      _validateParameter(
          parameter, className, constructorName, path, violations);
    } else if (allRequired != true && onlyNamedRequired != true) {
      for (final parameter in parameters) {
        _validateParameter(
            parameter, className, constructorName, path, violations);
      }
    }
  }

  void _validateParameter(FormalParameter parameter, String className,
      String constructorName, String path, List<String> violations) {
    final paramName = parameter.name?.lexeme ?? '';

    if (expectedType != null) {
      final paramType = _getParameterType(parameter);
      if (paramType != expectedType) {
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName parameter "$paramName"',
            'must be of type $expectedType',
            path));
      }
    }

    if (isRequired != null) {
      final paramIsRequired = parameter.isRequired;
      if (paramIsRequired != isRequired!) {
        final expected = isRequired! ? 'required' : 'optional';
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName parameter "$paramName"',
            'must be $expected',
            path));
      }
    }

    if (isNamed != null) {
      final paramIsNamed = parameter.isNamed;
      if (paramIsNamed != isNamed!) {
        final expected = isNamed! ? 'named' : 'positional';
        violations.add(RuleMessages.methodViolation(
            className,
            'constructor $constructorName parameter "$paramName"',
            'must be $expected',
            path));
      }
    }
  }

  String? _getParameterType(FormalParameter parameter) {
    if (parameter is SimpleFormalParameter) {
      return parameter.type?.toString();
    } else if (parameter is DefaultFormalParameter) {
      return _getParameterType(parameter.parameter);
    }
    return null;
  }
}
