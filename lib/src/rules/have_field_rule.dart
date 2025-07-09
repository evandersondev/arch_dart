import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class HaveFieldRule extends ArchRule {
  final String package;
  final String fieldName;
  final String? fieldType;
  final bool? shouldBePrivate;
  final bool? shouldBeFinal;
  final bool? shouldBeStatic;

  HaveFieldRule(
    this.package,
    this.fieldName, {
    this.fieldType,
    this.shouldBePrivate,
    this.shouldBeFinal,
    this.shouldBeStatic,
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

          final field = _findField(declaration, fieldName);
          if (field == null) {
            violations.add(RuleMessages.fieldViolation(
                className, fieldName, 'must exist', path));
            continue;
          }

          _validateField(field, className, fieldName, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Have field', violations));
    }
  }

  FieldDeclaration? _findField(
      ClassDeclaration classDeclaration, String fieldName) {
    for (final member in classDeclaration.members) {
      if (member is FieldDeclaration) {
        for (final variable in member.fields.variables) {
          if (variable.name.lexeme == fieldName) {
            return member;
          }
        }
      }
    }
    return null;
  }

  void _validateField(FieldDeclaration field, String className,
      String fieldName, String path, List<String> violations) {
    if (fieldType != null) {
      final actualType = field.fields.type?.toString();
      if (actualType != fieldType) {
        violations.add(RuleMessages.fieldViolation(
            className, fieldName, 'must be of type $fieldType', path));
      }
    }

    if (shouldBePrivate != null) {
      final isPrivate = fieldName.startsWith('_');
      if (isPrivate != shouldBePrivate!) {
        final expected = shouldBePrivate! ? 'private' : 'public';
        violations.add(RuleMessages.fieldViolation(
            className, fieldName, 'must be $expected', path));
      }
    }

    if (shouldBeFinal != null) {
      final isFinal = field.fields.isFinal;
      if (isFinal != shouldBeFinal!) {
        final expected = shouldBeFinal! ? 'final' : 'non-final';
        violations.add(RuleMessages.fieldViolation(
            className, fieldName, 'must be $expected', path));
      }
    }

    if (shouldBeStatic != null) {
      final isStatic = field.isStatic;
      if (isStatic != shouldBeStatic!) {
        final expected = shouldBeStatic! ? 'static' : 'non-static';
        violations.add(RuleMessages.fieldViolation(
            className, fieldName, 'must be $expected', path));
      }
    }
  }
}
