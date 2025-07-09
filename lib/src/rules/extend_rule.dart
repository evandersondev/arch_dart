import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ExtendRule extends ArchRule {
  final String package;
  final String parentClass;
  final List<String>? allowedClasses;

  ExtendRule(
    this.package,
    this.parentClass, {
    this.allowedClasses,
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
          final extendsClause = declaration.extendsClause;

          if (extendsClause == null) {
            violations.add(
                RuleMessages.extendViolation(className, parentClass, path));
            continue;
          }

          final visitor = _TypeNameVisitor();
          extendsClause.superclass.accept(visitor);
          final extendedClass = visitor.typeName;

          if (allowedClasses != null) {
            if (extendedClass == null ||
                !allowedClasses!.contains(extendedClass)) {
              violations.add(RuleMessages.extendViolation(
                  className, 'one of: ${allowedClasses!.join(", ")}', path));
            }
          } else {
            if (extendedClass != parentClass) {
              violations.add(
                  RuleMessages.extendViolation(className, parentClass, path));
            }
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Inheritance', violations));
    }
  }
}

class _TypeNameVisitor extends GeneralizingAstVisitor<void> {
  String? typeName;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    typeName ??= node.name;
    super.visitSimpleIdentifier(node);
  }
}
