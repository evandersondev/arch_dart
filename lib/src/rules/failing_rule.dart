import '../utils/rule_base.dart';

class FailingRule extends ArchRule {
  final ArchRule rule;

  FailingRule(this.rule);

  @override
  Future<void> check() async {
    try {
      await rule.check();
    } catch (e) {
      final error = e.toString();
      throw Exception(
        error,
      );
    }
  }
}
