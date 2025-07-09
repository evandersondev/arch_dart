import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class MethodAnnotationRule extends ArchRule {
  final String package;
  final String annotation;
  final String? methodName;
  final bool checkAll;

  MethodAnnotationRule(
    this.package,
    this.annotation, {
    this.methodName,
    this.checkAll = false,
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
        if (declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;

          final methods =
              declaration.members.whereType<MethodDeclaration>().toList();

          if (checkAll) {
            _checkAllMethods(methods, className, path, violations);
          } else if (methodName != null) {
            _checkSpecificMethod(methods, className, path, violations);
          } else {
            _checkAllMethods(methods, className, path, violations);
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('Method annotation', violations));
    }
  }

  void _checkAllMethods(List<MethodDeclaration> methods, String className,
      String path, List<String> violations) {
    for (final method in methods) {
      final methodName = method.name.lexeme;
      _checkMethodAnnotation(method, className, methodName, path, violations);
    }
  }

  void _checkSpecificMethod(List<MethodDeclaration> methods, String className,
      String path, List<String> violations) {
    final method =
        methods.where((m) => m.name.lexeme == methodName).firstOrNull;
    if (method == null) {
      violations.add(RuleMessages.methodViolation(
          className, methodName!, 'must exist', path));
      return;
    }
    _checkMethodAnnotation(method, className, methodName!, path, violations);
  }

  void _checkMethodAnnotation(MethodDeclaration method, String className,
      String methodName, String path, List<String> violations) {
    final hasAnnotation = method.metadata.any((annotation) {
      final visitor = _AnnotationNameVisitor();
      annotation.accept(visitor);
      return visitor.annotationName == this.annotation;
    });

    if (!hasAnnotation) {
      violations.add(RuleMessages.methodViolation(
          className, methodName, 'must be annotated with @$annotation', path));
    }
  }
}

class _AnnotationNameVisitor extends GeneralizingAstVisitor<void> {
  String? annotationName;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    annotationName ??= node.name;
    super.visitSimpleIdentifier(node);
  }
}
