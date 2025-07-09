import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';
import 'method_rule_type.dart';

class MethodRule extends ArchRule {
  final String package;
  final MethodRuleType ruleType;
  final String? expectedType;
  final String? expectedMethodName;
  final List<String>? expectedParameters;
  final String? requiredAnnotation;
  final bool? isPrivate;
  final bool checkAll;
  final bool isFunction;
  final bool negate;
  final bool isForEnum;

  MethodRule(
    this.package,
    this.ruleType, {
    this.expectedType,
    this.expectedMethodName,
    this.expectedParameters,
    this.requiredAnnotation,
    this.isPrivate,
    this.checkAll = false,
    this.isFunction = false,
    this.isForEnum = false,
    this.negate = false,
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (isForEnum && declaration is EnumDeclaration) {
          _checkEnumMethods(declaration, path, violations);
        } else if (isFunction && declaration is FunctionDeclaration) {
          _checkFunction(declaration, path, violations);
        } else if (!isForEnum && declaration is ClassDeclaration) {
          _checkClassMethods(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Method', violations));
    }
  }

  void _checkEnumMethods(
      EnumDeclaration declaration, String path, List<String> violations) {
    final enumName = declaration.name.lexeme;
    bool hasMatchingMethod = false;

    for (final member in declaration.members) {
      if (member is MethodDeclaration) {
        final meetsCondition = _checkMethodRule(member);
        if (negate ? !meetsCondition : meetsCondition) {
          hasMatchingMethod = true;
          if (!checkAll) break;
        }
      }
    }

    if (checkAll && (negate ? hasMatchingMethod : !hasMatchingMethod)) {
      violations.add(
          'Enum "$enumName" ${negate ? 'should NOT have' : 'does not have'} a method matching the criteria: ${_getRuleDescription()} (file: $path)');
    }
  }

  void _checkFunction(
      FunctionDeclaration function, String path, List<String> violations) {
    final functionName = function.name.lexeme;
    final hasExpectedBehavior = _checkFunctionRule(function);

    if (negate ? hasExpectedBehavior : !hasExpectedBehavior) {
      violations.add(
          'Function "$functionName" ${negate ? 'should NOT' : 'should'} ${_getRuleDescription()} (file: $path)');
    }
  }

  void _checkClassMethods(
      ClassDeclaration classDeclaration, String path, List<String> violations) {
    final className = classDeclaration.name.lexeme;
    final methods = classDeclaration.members.whereType<MethodDeclaration>();
    bool hasMatchingMethod = false;

    for (final method in methods) {
      final methodName = method.name.lexeme;
      final hasExpectedBehavior = _checkMethodRule(method);

      if (negate ? hasExpectedBehavior : !hasExpectedBehavior) {
        violations.add(
            'Method "$methodName" in class "$className" ${negate ? 'should NOT' : 'should'} ${_getRuleDescription()} (file: $path)');
      } else {
        hasMatchingMethod = true;
      }
    }

    if (checkAll && (negate ? hasMatchingMethod : !hasMatchingMethod)) {
      violations.add(
          'Class "$className" ${negate ? 'should NOT have' : 'does not have'} a method matching the criteria: ${_getRuleDescription()} (file: $path)');
    }
  }

  bool _checkMethodRule(MethodDeclaration method) {
    switch (ruleType) {
      case MethodRuleType.async:
        return method.body is BlockFunctionBody &&
            (method.body as BlockFunctionBody).keyword?.lexeme == 'async';
      case MethodRuleType.sync:
        return method.body is BlockFunctionBody &&
            (method.body as BlockFunctionBody).keyword?.lexeme != 'async';
      case MethodRuleType.returnType:
        return method.returnType?.toString() == expectedType;
      case MethodRuleType.parameters:
        final params = method.parameters?.parameters;
        return _checkMethodParameters(params);
      case MethodRuleType.name:
        return method.name.lexeme == expectedMethodName;
      case MethodRuleType.annotation:
        return _hasAnnotation(method.metadata);
      case MethodRuleType.visibility:
        final isPrivateMethod = method.name.lexeme.startsWith('_');
        return isPrivate == true ? isPrivateMethod : !isPrivateMethod;
    }
  }

  bool _checkFunctionRule(FunctionDeclaration function) {
    switch (ruleType) {
      case MethodRuleType.async:
        return function.functionExpression.body is BlockFunctionBody &&
            (function.functionExpression.body as BlockFunctionBody)
                    .keyword
                    ?.lexeme ==
                'async';
      case MethodRuleType.sync:
        return function.functionExpression.body is BlockFunctionBody &&
            (function.functionExpression.body as BlockFunctionBody)
                    .keyword
                    ?.lexeme !=
                'async';
      case MethodRuleType.returnType:
        return function.returnType?.toString() == expectedType;
      case MethodRuleType.parameters:
        final params = function.functionExpression.parameters?.parameters;
        return _checkFunctionParameters(params);
      case MethodRuleType.name:
        return function.name.lexeme == expectedMethodName;
      case MethodRuleType.annotation:
        return _hasAnnotation(function.metadata);
      case MethodRuleType.visibility:
        final isPrivateFunction = function.name.lexeme.startsWith('_');
        return isPrivate == true ? isPrivateFunction : !isPrivateFunction;
    }
  }

  bool _checkFunctionParameters(List<FormalParameter>? params) {
    if (expectedParameters == null) return true;

    final paramList = params ?? [];

    if (paramList.length != expectedParameters!.length) return false;

    for (int i = 0; i < paramList.length; i++) {
      final param = paramList[i];
      final expectedParam = expectedParameters![i];

      // Verificar tipo do parâmetro
      if (param is SimpleFormalParameter) {
        if (param.type?.toString() != expectedParam) return false;
      } else if (param is DefaultFormalParameter) {
        final innerParam = param.parameter;
        if (innerParam is SimpleFormalParameter) {
          if (innerParam.type?.toString() != expectedParam) return false;
        }
      }
    }

    return true;
  }

  bool _checkMethodParameters(List<FormalParameter>? params) {
    if (expectedParameters == null) return true;

    final paramList = params ?? [];

    if (paramList.length != expectedParameters!.length) return false;

    for (int i = 0; i < paramList.length; i++) {
      final param = paramList[i];
      final expectedParam = expectedParameters![i];

      // Verificar tipo do parâmetro
      if (param is SimpleFormalParameter) {
        if (param.type?.toString() != expectedParam) return false;
      } else if (param is DefaultFormalParameter) {
        final innerParam = param.parameter;
        if (innerParam is SimpleFormalParameter) {
          if (innerParam.type?.toString() != expectedParam) return false;
        }
      }
    }

    return true;
  }

  bool _hasAnnotation(List<Annotation> annotations) {
    if (requiredAnnotation == null) return true;

    return annotations
        .any((annotation) => annotation.name.toString() == requiredAnnotation);
  }

  String _getRuleDescription() {
    switch (ruleType) {
      case MethodRuleType.async:
        return 'be async';
      case MethodRuleType.sync:
        return 'be sync';
      case MethodRuleType.returnType:
        return 'return type $expectedType';
      case MethodRuleType.parameters:
        return 'have parameters: ${expectedParameters?.join(', ') ?? 'none'}';
      case MethodRuleType.name:
        return 'be named $expectedMethodName';
      case MethodRuleType.annotation:
        return 'have annotation @$requiredAnnotation';
      case MethodRuleType.visibility:
        return isPrivate == true ? 'be private' : 'be public';
    }
  }
}
