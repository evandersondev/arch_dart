import '../rules/method_rule.dart';
import '../rules/method_rule_type.dart';
import '../rules/visibility_rule.dart';
import '../utils/rule_base.dart';

class FunctionSelector {
  final String package;

  FunctionSelector(this.package);

  VisibilityRule shouldBePrivate() =>
      VisibilityRule(package, Visibility.private, isFunction: true);
  VisibilityRule shouldBePublic() =>
      VisibilityRule(package, Visibility.public, isFunction: true);
  MethodRule shouldReturnType(String type) =>
      MethodRule(package, MethodRuleType.returnType,
          expectedType: type, isFunction: true);
}
