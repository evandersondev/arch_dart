import '../utils/rule_base.dart';
import '../utils/scope_context.dart';

abstract class ScopedRule extends ArchRule {
  final ScopeContext scope;

  ScopedRule(this.scope);

  @override
  Future<void> check() async {
    await checkInScope('.', scope);
  }

  Future<void> checkInScope(String rootDir, ScopeContext scope);

  bool shouldProcessFile(String filePath) {
    return scope.shouldProcess(filePath);
  }
}

// Implementação base para regras que usam escopo
abstract class BaseScopedRule extends ScopedRule {
  final String package;

  BaseScopedRule(this.package, ScopeContext scope) : super(scope);

  @override
  Future<void> checkInScope(String rootDir, ScopeContext scope) async {
    // Implementação padrão que pode ser sobrescrita
    final violations = <String>[];
    await performCheck(rootDir, violations);

    if (violations.isNotEmpty) {
      throw Exception('ArchRule violations found:\n${violations.join('\n')}');
    }
  }

  Future<void> performCheck(String rootDir, List<String> violations);
}
