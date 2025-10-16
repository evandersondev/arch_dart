import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ImplementRule extends ArchRule {
  final String package;
  final String interfaceName;
  final List<String>? allowedInterfaces;
  final String? interfaceNameSuffix;

  ImplementRule(
    this.package,
    this.interfaceName, {
    this.allowedInterfaces,
    this.interfaceNameSuffix,
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

          if (interfaceNameSuffix != null) {
            _checkInterfaceSuffix(declaration, className, path, violations);
          } else if (allowedInterfaces != null) {
            _checkAllowedInterfaces(declaration, className, path, violations);
          } else {
            _checkSpecificInterface(declaration, className, path, violations);
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          RuleMessages.violationFound('Implementation', violations));
    }
  }

  void _checkInterfaceSuffix(ClassDeclaration declaration, String className,
      String path, List<String> violations) {
    final implementsClause = declaration.implementsClause;

    if (implementsClause == null || implementsClause.interfaces.isEmpty) {
      violations.add(
          'Class "$className" must implement an interface ending with "$interfaceNameSuffix" (file: $path)');
      return;
    }

    bool hasMatchingInterface = false;
    for (final interface in implementsClause.interfaces) {
      final interfaceName = interface.name2.lexeme;
      if (interfaceName.endsWith(interfaceNameSuffix!)) {
        hasMatchingInterface = true;
        break;
      }
    }

    if (!hasMatchingInterface) {
      violations.add(
          'Class "$className" must implement an interface ending with "$interfaceNameSuffix" (file: $path)');
    }
  }

  void _checkAllowedInterfaces(ClassDeclaration declaration, String className,
      String path, List<String> violations) {
    final implementsClause = declaration.implementsClause;

    if (implementsClause == null || implementsClause.interfaces.isEmpty) {
      violations.add(
          'Class "$className" must implement one of: ${allowedInterfaces!.join(', ')} (file: $path)');
      return;
    }

    bool hasAllowedInterface = false;
    for (final interface in implementsClause.interfaces) {
      final interfaceName = interface.name2.lexeme;
      if (allowedInterfaces!.contains(interfaceName)) {
        hasAllowedInterface = true;
        break;
      }
    }

    if (!hasAllowedInterface) {
      violations.add(
          'Class "$className" must implement one of: ${allowedInterfaces!.join(', ')} (file: $path)');
    }
  }

  void _checkSpecificInterface(ClassDeclaration declaration, String className,
      String path, List<String> violations) {
    final implementsClause = declaration.implementsClause;

    if (implementsClause == null || implementsClause.interfaces.isEmpty) {
      violations.add(
          'Class "$className" must implement "$interfaceName" (file: $path)');
      return;
    }

    bool implementsRequired = false;
    for (final interface in implementsClause.interfaces) {
      if (interface.name2.lexeme == interfaceName) {
        implementsRequired = true;
        break;
      }
    }

    if (!implementsRequired) {
      violations.add(
          'Class "$className" must implement "$interfaceName" (file: $path)');
    }
  }
}

// class _TypeNameVisitor extends GeneralizingAstVisitor<void> {
//   String? typeName;

//   @override
//   void visitSimpleIdentifier(SimpleIdentifier node) {
//     typeName ??= node.name;
//     super.visitSimpleIdentifier(node);
//   }
// }
