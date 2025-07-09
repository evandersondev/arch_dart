import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../dsl/arch_classes.dart';
import '../rules/annotation_rule.dart';
import '../rules/enum_value_rule.dart';
import '../rules/naming_rule.dart';
import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class EnumSelector {
  final String package;

  EnumSelector(this.package);

  EnumSelector inPackage(String packageName) => EnumSelector(packageName);
  EnumSelector inFolder(String folder) => EnumSelector(folder);
  EnumSelector inDirectory(String directory) => EnumSelector(directory);
  EnumSelector inFile(String file) => EnumSelector(file);

  NamingRule withNameEndingWith(String suffix) =>
      NamingRule.forEnums(package, suffix);

  NamingRule withNameContaining(String substring) =>
      NamingRule.forEnums(package, substring, checkContains: true);

  NamingRule withNameStartingWith(String prefix) =>
      NamingRule.forEnums(package, prefix, checkPrefix: true);

  AnnotationRule withAnnotation(String annotation) =>
      AnnotationRule.forEnums(package, annotation);

  EnumValueRule withValueCountGreaterThan(int count) =>
      EnumValueRule(package, count);

  EnumValueRule withValueCountLessThan(int count) =>
      EnumValueRule(package, count, isLessThan: true);

  EnumValueRule withValueCountEqualTo(int count) =>
      EnumValueRule(package, count, isEqual: true);

  AnnotationRule shouldBeAnnotatedWith(String annotation) =>
      AnnotationRule.forEnums(package, annotation);

  NamingRule shouldHaveNameEndingWith(String suffix) =>
      NamingRule.forEnums(package, suffix);

  NamingRule shouldHaveNameContaining(String substring) =>
      NamingRule.forEnums(package, substring, checkContains: true);

  NamingRule shouldHaveNameStartingWith(String prefix) =>
      NamingRule.forEnums(package, prefix, checkPrefix: true);

  EnumValueRule shouldHaveValueCountGreaterThan(int count) =>
      EnumValueRule(package, count);

  EnumValueRule shouldHaveValueCountLessThan(int count) =>
      EnumValueRule(package, count, isLessThan: true);

  EnumValueRule shouldHaveValueCountEqualTo(int count) =>
      EnumValueRule(package, count, isEqual: true);

  EnumValueRule shouldHaveAtLeastValues(int count) =>
      EnumValueRule(package, count);

  EnumValueRule shouldHaveAtMostValues(int count) =>
      EnumValueRule(package, count, isLessThan: true);

  EnumValueRule shouldHaveExactlyValues(int count) =>
      EnumValueRule(package, count, isEqual: true);

  AnnotationRule shouldNotBeAnnotatedWith(String annotation) =>
      AnnotationRule.forEnums(package, annotation, negate: true);

  NamingRule shouldNotHaveNameEndingWith(String suffix) =>
      NamingRule.forEnums(package, suffix, negate: true);

  NamingRule shouldNotHaveNameContaining(String substring) =>
      NamingRule.forEnums(package, substring,
          checkContains: true, negate: true);

  NamingRule shouldNotHaveNameStartingWith(String prefix) =>
      NamingRule.forEnums(package, prefix, checkPrefix: true, negate: true);

  EnumValueRangeRule shouldHaveValueCountBetween(int min, int max) =>
      EnumValueRangeRule(package, min, max);

  MethodRuleBuilder shouldHaveMethodThat() {
    return MethodRuleBuilder(package,
        checkAll: true, isForEnum: true); // Add isForEnum flag
  }
}

class EnumValueRangeRule extends ArchRule {
  final String package;
  final int minCount;
  final int maxCount;

  EnumValueRangeRule(this.package, this.minCount, this.maxCount);

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
          final enumName = declaration.name.lexeme;
          final valueCount = declaration.constants.length;

          if (valueCount < minCount || valueCount > maxCount) {
            violations.add(
                'Enum "$enumName" must have between $minCount and $maxCount values, but has $valueCount (file: $path)');
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(
          'EnumValueRange rule violations found:\n${violations.join('\n')}');
    }
  }
}
