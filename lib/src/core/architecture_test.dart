import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ArchitectureTest {
  final List<ArchRule> rules = [];
  Function(String)? errorHandler;

  void setErrorHandler(Function(String) handler) {
    errorHandler = handler;
  }

  void addRule(ArchRule rule) {
    rules.add(rule);
  }

  Future<void> check() async {
    int filesChecked = 0;
    int violationsFound = 0;
    final unitsWithPath = await parseDirectoryWithPaths('.');
    filesChecked = unitsWithPath.length;

    for (final rule in rules) {
      try {
        await rule.check();
      } catch (e) {
        violationsFound++;
        if (errorHandler != null) {
          errorHandler!(e.toString());
        } else {
          rethrow;
        }
      }
    }

    print(
        'Resumo: $filesChecked arquivos verificados, $violationsFound violações encontradas');
  }

  ArchitectureTest andAlso() => this;
}
