import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class CombinedRule extends ArchRule {
  final String package;
  final List<ArchRule> rules;

  CombinedRule(this.package, this.rules);

  @override
  Future<void> check() async {
    final violations = <String>[];

    for (final rule in rules) {
      try {
        await rule.check();
      } catch (e) {
        violations.add(e.toString());
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Combined', violations));
    }
  }
}
