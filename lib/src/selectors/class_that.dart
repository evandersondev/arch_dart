import '../rules/extend_rule.dart';
import '../rules/hava_field_rule.dart';
import '../rules/implement_rule.dart';
import '../rules/reside_in_rule.dart';

class ClassThat {
  final String package;

  ClassThat(this.package);

  ResideInRule resideIn(String packageName) {
    return ResideInRule(package, packageName);
  }

  ImplementRule implement(String interfaceName) {
    return ImplementRule(package, interfaceName);
  }

  ExtendRule extend(String className) {
    return ExtendRule(package, className);
  }

  HaveFieldRule haveField(String fieldName) {
    return HaveFieldRule(package, fieldName);
  }
}
