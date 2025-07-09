import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class ContentRule extends ArchRule {
  final String package;
  final String content;
  final bool? shouldContain;
  final bool? onlyRecords;
  final bool isRegex;

  ContentRule(
    this.package,
    this.content, {
    this.shouldContain,
    this.onlyRecords,
    this.isRegex = false,
  });

  @override
  Future<void> check() async {
    final violations = <String>[];
    final directory = Directory('.');

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final path = p.normalize(entity.path);

        if (!path.contains(package)) continue;

        if (onlyRecords == true) {
          await _checkOnlyRecords(entity, path, violations);
        } else {
          await _checkContent(entity, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Content', violations));
    }
  }

  Future<void> _checkContent(
      File file, String path, List<String> violations) async {
    final fileContent = await file.readAsString();

    if (shouldContain == false) {
      final hasForbiddenContent = isRegex
          ? RegExp(content).hasMatch(fileContent)
          : fileContent.contains(content);

      if (hasForbiddenContent) {
        violations.add(
            'File "$path" must not contain: ${isRegex ? 'pattern' : 'text'} "$content"');
      }
    } else {
      final hasRequiredContent = isRegex
          ? RegExp(content).hasMatch(fileContent)
          : fileContent.contains(content);

      if (!hasRequiredContent) {
        violations.add(
            'File "$path" must contain: ${isRegex ? 'pattern' : 'text'} "$content"');
      }
    }
  }

  Future<void> _checkOnlyRecords(
      File file, String path, List<String> violations) async {
    final unitsWithPath = await parseDirectoryWithPaths(file.parent.path);
    final unit = unitsWithPath[path];

    if (unit == null) return;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        // In Dart, records are typically represented as classes with specific patterns
        // This is a simplified check - you might need to adjust based on your record definition
        final className = declaration.name.lexeme;
        final isRecord = _isRecordClass(declaration);

        if (!isRecord) {
          violations.add(
              'File "$path" should only contain records, but found class "$className"');
        }
      } else if (declaration is! ImportDirective &&
          declaration is! ExportDirective &&
          declaration is! PartDirective &&
          declaration is! PartOfDirective) {
        violations.add(
            'File "$path" should only contain records, but found other declarations');
      }
    }
  }

  bool _isRecordClass(ClassDeclaration declaration) {
    // Simple heuristic: records typically have only final fields and maybe a constructor
    final hasOnlyFinalFields = declaration.members
        .whereType<FieldDeclaration>()
        .every((field) => field.fields.isFinal);

    final hasOnlyConstructorsAndFields = declaration.members.every((member) =>
        member is FieldDeclaration || member is ConstructorDeclaration);

    return hasOnlyFinalFields && hasOnlyConstructorsAndFields;
  }
}
