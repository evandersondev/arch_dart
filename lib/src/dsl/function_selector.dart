import '../rules/method_rule.dart';
import '../rules/method_rule_type.dart';
import '../rules/naming_rule.dart';
import '../rules/visibility_rule.dart';
import '../utils/rule_base.dart';

class FunctionSelector {
  final String package;

  FunctionSelector(this.package);

  // Métodos de escopo
  FunctionSelector inPackage(String packageName) =>
      FunctionSelector(packageName);
  FunctionSelector inFolder(String folder) => FunctionSelector(folder);
  FunctionSelector inDirectory(String directory) => FunctionSelector(directory);
  FunctionSelector inFile(String file) => FunctionSelector(file);

  // Métodos de visibilidade
  VisibilityRule shouldBePrivate() =>
      VisibilityRule(package, Visibility.private, isFunction: true);

  VisibilityRule shouldBePublic() =>
      VisibilityRule(package, Visibility.public, isFunction: true);

  VisibilityRule shouldNotBePrivate() =>
      VisibilityRule(package, Visibility.private,
          isFunction: true, negate: true);

  VisibilityRule shouldNotBePublic() =>
      VisibilityRule(package, Visibility.public,
          isFunction: true, negate: true);

  // Métodos de tipo de retorno e comportamento
  MethodRule shouldReturnType(String type) =>
      MethodRule(package, MethodRuleType.returnType,
          expectedType: type, isFunction: true);

  MethodRule shouldBeAsync() =>
      MethodRule(package, MethodRuleType.async, isFunction: true);

  MethodRule shouldBeSync() =>
      MethodRule(package, MethodRuleType.sync, isFunction: true);

  MethodRule shouldNotBeAsync() =>
      MethodRule(package, MethodRuleType.async, isFunction: true, negate: true);

  MethodRule shouldNotBeSync() =>
      MethodRule(package, MethodRuleType.sync, isFunction: true, negate: true);

  // Métodos de nomenclatura
  NamingRule shouldHaveNameEndingWith(String suffix) {
    return NamingRule.forFunctions(package, suffix);
  }

  NamingRule shouldHaveNameContaining(String substring) {
    return NamingRule.forFunctions(package, substring, checkContains: true);
  }

  NamingRule shouldHaveNameStartingWith(String prefix) {
    return NamingRule.forFunctions(package, prefix, checkPrefix: true);
  }

  // Métodos de filtro
  NamingRule withNameEndingWith(String suffix) {
    return NamingRule.forFunctions(package, suffix);
  }

  NamingRule withNameContaining(String substring) {
    return NamingRule.forFunctions(package, substring, checkContains: true);
  }

  NamingRule withNameStartingWith(String prefix) {
    return NamingRule.forFunctions(package, prefix, checkPrefix: true);
  }

  // Métodos de parâmetros
  MethodRule shouldHaveParameters(List<String> parameters) =>
      MethodRule(package, MethodRuleType.parameters,
          expectedParameters: parameters, isFunction: true);

  MethodRule shouldHaveNoParameters() =>
      MethodRule(package, MethodRuleType.parameters,
          expectedParameters: [], isFunction: true);
}
