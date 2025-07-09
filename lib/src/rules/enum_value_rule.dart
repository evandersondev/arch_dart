import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class EnumValueRule extends ArchRule {
  final String package;
  final int expectedCount;
  final bool isLessThan;
  final bool isEqual;
  final bool negate;

  EnumValueRule(
    this.package,
    this.expectedCount, {
    this.isLessThan = false,
    this.isEqual = false,
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
        if (declaration is EnumDeclaration) {
          _checkEnumValueCount(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('EnumValue', violations));
    }
  }

  void _checkEnumValueCount(
      EnumDeclaration declaration, String path, List<String> violations) {
    final enumName = declaration.name.lexeme;
    final valueCount = declaration.constants.length;
    final meetsCondition = _checkCondition(valueCount);

    if (negate) {
      if (meetsCondition) {
        violations.add(
            'Enum "$enumName" should NOT ${_getConditionDescription()} (actual: $valueCount) (file: $path)');
      }
    } else {
      if (!meetsCondition) {
        violations.add(
            'Enum "$enumName" should ${_getConditionDescription()} (actual: $valueCount) (file: $path)');
      }
    }
  }

  bool _checkCondition(int actualCount) {
    if (isEqual) {
      return actualCount == expectedCount;
    } else if (isLessThan) {
      return actualCount < expectedCount;
    } else {
      // Por padrão, verifica se é maior que
      return actualCount > expectedCount;
    }
  }

  String _getConditionDescription() {
    if (isEqual) {
      return 'have exactly $expectedCount values';
    } else if (isLessThan) {
      return 'have less than $expectedCount values';
    } else {
      return 'have more than $expectedCount values';
    }
  }
}
