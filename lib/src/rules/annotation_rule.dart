import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class AnnotationRule extends ArchRule {
  final String package;
  final String annotation;
  final bool isEnum;
  final bool isClass;
  final bool isMethod;
  final bool isFunction;
  final bool negate;

  AnnotationRule(
    this.package,
    this.annotation, {
    this.isEnum = false,
    this.isClass = true,
    this.isMethod = false,
    this.isFunction = false,
    this.negate = false,
  });

  // Construtores específicos
  AnnotationRule.forClasses(this.package, this.annotation,
      {this.negate = false})
      : isEnum = false,
        isClass = true,
        isMethod = false,
        isFunction = false;

  AnnotationRule.forEnums(this.package, this.annotation, {this.negate = false})
      : isEnum = true,
        isClass = false,
        isMethod = false,
        isFunction = false;

  AnnotationRule.forMethods(this.package, this.annotation,
      {this.negate = false})
      : isEnum = false,
        isClass = false,
        isMethod = true,
        isFunction = false;

  AnnotationRule.forFunctions(this.package, this.annotation,
      {this.negate = false})
      : isEnum = false,
        isClass = false,
        isMethod = false,
        isFunction = true;

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (isClass && declaration is ClassDeclaration) {
          _checkClassAnnotation(declaration, path, violations);
        } else if (isEnum && declaration is EnumDeclaration) {
          _checkEnumAnnotation(declaration, path, violations);
        } else if (isFunction && declaration is FunctionDeclaration) {
          _checkFunctionAnnotation(declaration, path, violations);
        } else if (isMethod && declaration is ClassDeclaration) {
          _checkMethodAnnotations(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Annotation', violations));
    }
  }

  void _checkClassAnnotation(
      ClassDeclaration declaration, String path, List<String> violations) {
    final className = declaration.name.lexeme;
    final hasAnnotation = _hasRequiredAnnotation(declaration.metadata);

    if (negate) {
      if (hasAnnotation) {
        violations.add(
            'Class "$className" should NOT be annotated with @$annotation (file: $path)');
      }
    } else {
      if (!hasAnnotation) {
        violations.add(
            'Class "$className" should be annotated with @$annotation (file: $path)');
      }
    }
  }

  void _checkEnumAnnotation(
      EnumDeclaration declaration, String path, List<String> violations) {
    final enumName = declaration.name.lexeme;
    final hasAnnotation = _hasRequiredAnnotation(declaration.metadata);

    if (negate) {
      if (hasAnnotation) {
        violations.add(
            'Enum "$enumName" should NOT be annotated with @$annotation (file: $path)');
      }
    } else {
      if (!hasAnnotation) {
        violations.add(
            'Enum "$enumName" should be annotated with @$annotation (file: $path)');
      }
    }
  }

  void _checkFunctionAnnotation(
      FunctionDeclaration declaration, String path, List<String> violations) {
    final functionName = declaration.name.lexeme;
    final hasAnnotation = _hasRequiredAnnotation(declaration.metadata);

    if (negate) {
      if (hasAnnotation) {
        violations.add(
            'Function "$functionName" should NOT be annotated with @$annotation (file: $path)');
      }
    } else {
      if (!hasAnnotation) {
        violations.add(
            'Function "$functionName" should be annotated with @$annotation (file: $path)');
      }
    }
  }

  void _checkMethodAnnotations(
      ClassDeclaration classDeclaration, String path, List<String> violations) {
    final className = classDeclaration.name.lexeme;
    final methods = classDeclaration.members.whereType<MethodDeclaration>();

    for (final method in methods) {
      final methodName = method.name.lexeme;
      final hasAnnotation = _hasRequiredAnnotation(method.metadata);

      if (negate) {
        if (hasAnnotation) {
          violations.add(
              'Method "$methodName" in class "$className" should NOT be annotated with @$annotation (file: $path)');
        }
      } else {
        if (!hasAnnotation) {
          violations.add(
              'Method "$methodName" in class "$className" should be annotated with @$annotation (file: $path)');
        }
      }
    }
  }

  bool _hasRequiredAnnotation(List<Annotation> annotations) {
    return annotations.any((ann) => ann.name.toString() == annotation);
  }
}
