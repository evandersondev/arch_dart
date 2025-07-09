import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ImplementInterfaceEndingRule extends ArchRule {
  final String package;
  final String suffix;

  ImplementInterfaceEndingRule(this.package, this.suffix);

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
          final implements = declaration.implementsClause?.interfaces ?? [];

          final hasInterfaceWithSuffix = implements.any((interface) {
            final visitor = _TypeNameVisitor();
            interface.accept(visitor);
            return visitor.typeName?.endsWith(suffix) ?? false;
          });

          if (!hasInterfaceWithSuffix) {
            violations.add(
                RuleMessages.interfaceEndingViolation(className, suffix, path));
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('Interface ending', violations));
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
