import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class FieldRule extends ArchRule {
  final String package;
  final String? expectedType;
  final Visibility? visibility;
  final bool? shouldBeFinal;

  FieldRule(
    this.package, {
    this.expectedType,
    this.visibility,
    this.shouldBeFinal,
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

          for (final member in declaration.members) {
            if (member is FieldDeclaration) {
              for (final variable in member.fields.variables) {
                final fieldName = variable.name.lexeme;

                _checkFieldType(member, className, fieldName, path, violations);
                _checkFieldVisibility(
                    member, className, fieldName, path, violations);
                _checkFieldFinality(
                    member, className, fieldName, path, violations);
              }
            }
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Field', violations));
    }
  }

  void _checkFieldType(FieldDeclaration field, String className,
      String fieldName, String path, List<String> violations) {
    if (expectedType == null) return;

    final fieldType = field.fields.type?.toString();
    if (fieldType != expectedType) {
      violations.add(RuleMessages.fieldViolation(
          className, fieldName, 'must be of type $expectedType', path));
    }
  }

  void _checkFieldVisibility(FieldDeclaration field, String className,
      String fieldName, String path, List<String> violations) {
    if (visibility == null) return;

    final isPrivate = fieldName.startsWith('_');
    final expectedPrivate = visibility == Visibility.private;

    if (isPrivate != expectedPrivate) {
      final expected = expectedPrivate ? 'private' : 'public';
      violations.add(RuleMessages.fieldViolation(
          className, fieldName, 'must be $expected', path));
    }
  }

  void _checkFieldFinality(FieldDeclaration field, String className,
      String fieldName, String path, List<String> violations) {
    if (shouldBeFinal == null) return;

    final isFinal = field.fields.isFinal;

    if (isFinal != shouldBeFinal!) {
      final expected = shouldBeFinal! ? 'final' : 'non-final';
      violations.add(RuleMessages.fieldViolation(
          className, fieldName, 'must be $expected', path));
    }
  }
}
