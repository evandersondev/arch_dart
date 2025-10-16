import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class NoDependencyAnyRule extends ArchRule {
  final String sourcePackage;
  final List<String> forbiddenPackages;

  NoDependencyAnyRule(this.sourcePackage, this.forbiddenPackages);

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    print('🔍 Verificando dependências proibidas...');
    print('   Pacote origem: $sourcePackage');
    print('   Pacotes proibidos: ${forbiddenPackages.join(', ')}');

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      // Verifica se o arquivo está no pacote de origem
      if (!path.contains(sourcePackage)) continue;

      print('   📁 Verificando arquivo: $path');

      // Analisa os imports
      for (final directive in unit.directives) {
        if (directive is ImportDirective) {
          final importPath = directive.uri.stringValue ?? '';

          // Verifica se o import contém algum dos pacotes proibidos
          for (final forbidden in forbiddenPackages) {
            if (importPath.contains(forbidden)) {
              violations.add(RuleMessages.dependencyViolation(
                  path, forbidden, importPath));
              print('     ❌ Import proibido encontrado: $importPath');
            }
          }
        }
      }
    }

    // Relatório final
    print('📊 Resultado da verificação:');

    if (violations.isNotEmpty) {
      print('   ❌ Violações encontradas: ${violations.length}');
      throw Exception(
          RuleMessages.violationFound('No dependency any', violations));
    }

    print('   ✅ Nenhuma dependência proibida encontrada');
  }
}
