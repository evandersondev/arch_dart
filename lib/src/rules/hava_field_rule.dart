import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class HaveFieldRule extends ArchRule {
  final String package;
  final String fieldName;
  final String? fieldType;

  HaveFieldRule(this.package, this.fieldName, {this.fieldType});

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join('.', package))) continue;

      final pathSegments = path.split(p.separator);
      if (!pathSegments.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final hasField = declaration.members.any((member) {
            if (member is FieldDeclaration) {
              final variables = member.fields.variables;
              return variables.any((variable) {
                final hasCorrectName = variable.name.lexeme == fieldName;
                if (fieldType != null) {
                  return hasCorrectName &&
                      member.fields.type?.toSource() == fieldType;
                }
                return hasCorrectName;
              });
            }
            return false;
          });

          if (!hasField) {
            throw Exception(
              'Classe "${declaration.name}" deve ter o campo "$fieldName"'
              '${fieldType != null ? ' do tipo $fieldType' : ''} (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
