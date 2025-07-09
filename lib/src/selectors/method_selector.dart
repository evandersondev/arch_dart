import '../rules/method_rule.dart';
import '../rules/method_rule_type.dart';

class MethodSelector {
  final String package;

  MethodSelector(this.package);

  MethodRule shouldBeAsync() {
    return MethodRule(package, MethodRuleType.async);
  }

  MethodRule shouldReturnType(String type) {
    return MethodRule(package, MethodRuleType.returnType, expectedType: type);
  }
}
