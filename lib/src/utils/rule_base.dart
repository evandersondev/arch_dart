import '../rules/annotation_rule.dart';
import '../rules/extend_rule.dart';
import '../rules/failing_rule.dart';
import '../rules/field_rule.dart';
import '../rules/implement_interface_ending_rule.dart';
import '../rules/implement_rule.dart';
import '../rules/import_rule.dart';
import '../rules/method_rule.dart';
import '../rules/naming_rule.dart';
import '../rules/no_dependency_any_rule.dart';
import '../rules/no_dependency_rule.dart';
import '../rules/only_dependency_rule.dart';
import '../rules/visibility_rule.dart';

enum Visibility {
  public,
  private,
  abstract,
  finalClass,
  sealed,
  base,
  mixin,
  enumClass,
  record,
  interface,
  abstractInterface,
}

abstract class ArchRule {
  List<String> excludedFiles = [];
  List<String> excludedClasses = [];

  Future<void> check();

  void excludeFiles(List<String> files) {
    excludedFiles.addAll(files);
  }

  void excludeClasses(List<String> classes) {
    excludedClasses.addAll(classes);
  }

  bool isExcluded(String path, String? className) {
    if (excludedFiles.any((f) => path.contains(f))) return true;
    if (className != null && excludedClasses.contains(className)) return true;
    return false;
  }

  ChainedRule andAlso() {
    return ChainedRule([this]);
  }

  ChainedRule orElse() {
    return ChainedRule([this], useOr: true);
  }
}

class ChainedRule extends ArchRule {
  final List<ArchRule> rules;
  final bool useOr;

  ChainedRule(this.rules, {this.useOr = false});

  ChainedRule _addRule(ArchRule rule) {
    return ChainedRule([...rules, rule], useOr: useOr);
  }

  RuleBuilder shouldBe(Visibility visibility) {
    return RuleBuilder(this, 'shouldBe', [visibility]);
  }

  RuleBuilder shouldHaveNameEndingWith(String suffix) {
    return RuleBuilder(this, 'shouldHaveNameEndingWith', [suffix]);
  }

  RuleBuilder shouldBeAnnotatedWith(String annotation) {
    return RuleBuilder(this, 'shouldBeAnnotatedWith', [annotation]);
  }

  RuleBuilder shouldImplement(String interfaceName) {
    return RuleBuilder(this, 'shouldImplement', [interfaceName]);
  }

  RuleBuilder shouldImplementInterfaceThatEndsWith(String suffix) {
    return RuleBuilder(this, 'shouldImplementInterfaceThatEndsWith', [suffix]);
  }

  RuleBuilder shouldNotDependOnAny(List<String> packages) {
    return RuleBuilder(this, 'shouldNotDependOnAny', [packages]);
  }

  RuleBuilder shouldExtend(String className) {
    return RuleBuilder(this, 'shouldExtend', [className]);
  }

  RuleBuilder shouldNotDependOn(String targetPackage) {
    return RuleBuilder(this, 'shouldNotDependOn', [targetPackage]);
  }

  RuleBuilder shouldOnlyDependOn(List<String> packages) {
    return RuleBuilder(this, 'shouldOnlyDependOn', [packages]);
  }

  RuleBuilder shouldHaveFinalFields() {
    return RuleBuilder(this, 'shouldHaveFinalFields', []);
  }

  RuleBuilder shouldHaveNonFinalFields() {
    return RuleBuilder(this, 'shouldHaveNonFinalFields', []);
  }

  RuleBuilder shouldNotHaveImports(List<String> imports) {
    return RuleBuilder(this, 'shouldNotHaveImports', [imports]);
  }

  @override
  Future<void> check() async {
    if (useOr) {
      final errors = <String>[];
      for (final rule in rules) {
        try {
          await rule.check();
          return;
        } catch (e) {
          errors.add(e.toString());
        }
      }
      throw Exception(
          'Nenhuma das regras alternativas foi atendida:\n${errors.join('\n---\n')}');
    } else {
      for (final rule in rules) {
        await rule.check();
      }
    }
  }
}

class RuleBuilder {
  final ChainedRule _chainedRule;
  final String _methodName;
  final List<dynamic> _parameters;
  final String? _package;

  RuleBuilder(this._chainedRule, this._methodName, this._parameters,
      [this._package]);

  ChainedRule _buildCurrentRule() {
    final package = _package ?? _extractPackageFromChain();
    final rule = _createRuleFromMethod(package, _methodName, _parameters);
    return _chainedRule._addRule(rule);
  }

  String _extractPackageFromChain() {
    for (final rule in _chainedRule.rules) {
      if (rule is NamingRule) return rule.package;
      if (rule is VisibilityRule) return rule.package;
      if (rule is AnnotationRule) return rule.package;
      if (rule is ImplementRule) return rule.package;
      if (rule is ImplementInterfaceEndingRule) return rule.package;
      if (rule is ExtendRule) return rule.package;
      if (rule is NoDependencyRule) return rule.sourcePackage;
      if (rule is NoDependencyAnyRule) return rule.sourcePackage;
      if (rule is OnlyDependencyRule) return rule.sourcePackage;
      if (rule is FieldRule) return rule.package;
      if (rule is ImportRule) return rule.package;
      if (rule is MethodRule) return rule.package;
    }
    throw Exception('Should not reach here: no package found in chain');
  }

  ArchRule _createRuleFromMethod(
      String package, String methodName, List<dynamic> parameters) {
    switch (methodName) {
      case 'shouldBe':
        return VisibilityRule(package, parameters[0] as Visibility);
      case 'shouldHaveNameEndingWith':
        return NamingRule(package, parameters[0] as String);
      case 'shouldBeAnnotatedWith':
        return AnnotationRule(package, parameters[0] as String);
      case 'shouldImplement':
        return ImplementRule(package, parameters[0] as String);
      case 'shouldImplementInterfaceThatEndsWith':
        return ImplementInterfaceEndingRule(package, parameters[0] as String);
      case 'shouldNotDependOnAny':
        return NoDependencyAnyRule(package, parameters[0] as List<String>);
      case 'shouldImplementOnly':
        return ImplementRule(
          package,
          (parameters[0] as List<String>).first,
          allowedInterfaces: parameters[0] as List<String>,
        );
      case 'shouldExtend':
        return ExtendRule(package, parameters[0] as String);
      case 'shouldNotDependOn':
        return NoDependencyRule(package, parameters[0] as String);
      case 'shouldOnlyDependOn':
        return OnlyDependencyRule(package, parameters[0] as List<String>);
      case 'shouldHaveFinalFields':
        return FieldRule(package, shouldBeFinal: true);
      case 'shouldHaveNonFinalFields':
        return FieldRule(package, shouldBeFinal: false);
      case 'shouldNotHaveImports':
        return ImportRule(package, parameters[0] as List<String>);
      default:
        throw Exception('Método não suportado: $methodName');
    }
  }

  ChainedRule andAlso() {
    return _buildCurrentRule();
  }

  ChainedRule orElse() {
    final currentChain = _buildCurrentRule();
    return ChainedRule(currentChain.rules, useOr: true);
  }

  RuleBuilder shouldBe(Visibility visibility) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldBe', [visibility]);
  }

  RuleBuilder shouldFail() {
    final finalChain = _buildCurrentRule();
    return _FailingRuleBuilder(FailingRule(finalChain));
  }

  RuleBuilder shouldHaveNameEndingWith(String suffix) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldHaveNameEndingWith', [suffix]);
  }

  RuleBuilder shouldBeAnnotatedWith(String annotation) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldBeAnnotatedWith', [annotation]);
  }

  RuleBuilder shouldImplement(String interfaceName) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldImplement', [interfaceName]);
  }

  RuleBuilder shouldExtend(String className) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldExtend', [className]);
  }

  RuleBuilder shouldNotDependOn(String targetPackage) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldNotDependOn', [targetPackage]);
  }

  RuleBuilder shouldOnlyDependOn(List<String> packages) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldOnlyDependOn', [packages]);
  }

  RuleBuilder shouldHaveFinalFields() {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldHaveFinalFields', []);
  }

  RuleBuilder shouldHaveNonFinalFields() {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldHaveNonFinalFields', []);
  }

  RuleBuilder shouldNotHaveImports(List<String> imports) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldNotHaveImports', [imports]);
  }

  Future<void> check() async {
    final finalChain = _buildCurrentRule();
    await finalChain.check();
  }
}

extension ArchRuleFailureExtension on ArchRule {
  ArchRule shouldFail() {
    return FailingRule(this);
  }
}

class _FailingRuleBuilder extends RuleBuilder {
  final ArchRule _failingRule;

  _FailingRuleBuilder(this._failingRule) : super(ChainedRule([]), '', [], '');

  @override
  Future<void> check() async {
    await _failingRule.check();
  }

  @override
  RuleBuilder shouldFail() {
    throw Exception('You cannot chain shouldFail after shouldFail.');
  }

  @override
  ChainedRule andAlso() {
    throw Exception('You cannot chain rules after shouldFail.');
  }

  @override
  ChainedRule orElse() {
    throw Exception('You cannot chain rules after shouldFail.');
  }
}
