import '../rules/constructor_parameter_rule.dart';
import '../rules/visibility_rule.dart';
import '../utils/rule_base.dart';

class ConstructorSelector {
  final String package;

  ConstructorSelector(this.package);

  // Affirmatives
  VisibilityRule shouldBePrivate() =>
      VisibilityRule(package, Visibility.private, isConstructor: true);
  ConstructorParameterRule shouldRequireAllParams() =>
      ConstructorParameterRule(package, allRequired: true);
  ConstructorParameterRule shouldHaveOnlyNamedRequiredParams() =>
      ConstructorParameterRule(package, onlyNamedRequired: true);
}
