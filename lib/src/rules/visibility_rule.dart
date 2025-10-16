import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class VisibilityRule extends ArchRule {
  final String package;
  final Visibility visibility;
  final bool negate;
  final bool isConstructor;
  final bool isFunction;

  VisibilityRule(
    this.package,
    this.visibility, {
    this.negate = false,
    this.isConstructor = false,
    this.isFunction = false,
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('lib');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (isFunction && declaration is FunctionDeclaration) {
          final functionName = declaration.name.lexeme;
          _checkFunctionModifiers(declaration, functionName, path, violations);
        } else if (declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;

          if (isConstructor) {
            _checkConstructors(declaration, className, path, violations);
          } else {
            _checkClassModifiers(declaration, className, path, violations);
          }
        } else if (declaration is EnumDeclaration &&
            visibility == Visibility.enumClass) {
          final enumName = declaration.name.lexeme;
          _checkEnumDeclaration(declaration, enumName, path, violations);
        } else if (declaration is MixinDeclaration &&
            visibility == Visibility.mixin) {
          final mixinName = declaration.name.lexeme;
          _checkMixinDeclaration(declaration, mixinName, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Visibility', violations));
    }
  }

  void _checkFunctionModifiers(FunctionDeclaration declaration,
      String functionName, String path, List<String> violations) {
    final hasExpectedModifier = _hasFunctionModifier(declaration);

    if (negate) {
      if (hasExpectedModifier) {
        violations.add(
            'Function "$functionName" should NOT be ${_getModifierName()} (file: $path)');
      }
    } else {
      if (!hasExpectedModifier) {
        violations.add(
            'Function "$functionName" should be ${_getModifierName()} (file: $path)');
      }
    }
  }

  void _checkClassModifiers(ClassDeclaration declaration, String className,
      String path, List<String> violations) {
    final hasExpectedModifier = _hasModifier(declaration);

    if (negate) {
      if (hasExpectedModifier) {
        violations.add(
            'Class "$className" should NOT be ${_getModifierName()} (file: $path)');
      }
    } else {
      if (!hasExpectedModifier) {
        violations.add(
            'Class "$className" should be ${_getModifierName()} (file: $path)');
      }
    }
  }

  void _checkConstructors(ClassDeclaration declaration, String className,
      String path, List<String> violations) {
    final constructors =
        declaration.members.whereType<ConstructorDeclaration>();

    for (final constructor in constructors) {
      final isPrivate = constructor.name?.lexeme.startsWith('_') ?? false;

      if (visibility == Visibility.private && !isPrivate) {
        violations.add(
            'Class "$className" should have only private constructors (file: $path)');
      } else if (visibility == Visibility.public && isPrivate) {
        violations.add(
            'Class "$className" should have public constructors (file: $path)');
      }
    }
  }

  void _checkEnumDeclaration(EnumDeclaration declaration, String enumName,
      String path, List<String> violations) {
    if (negate) {
      violations
          .add('Declaration "$enumName" should NOT be an enum (file: $path)');
    }
    // Se não é negativo, então está correto (é um enum)
  }

  void _checkMixinDeclaration(MixinDeclaration declaration, String mixinName,
      String path, List<String> violations) {
    if (negate) {
      violations
          .add('Declaration "$mixinName" should NOT be a mixin (file: $path)');
    }
    // Se não é negativo, então está correto (é um mixin)
  }

  bool _hasFunctionModifier(FunctionDeclaration declaration) {
    switch (visibility) {
      case Visibility.private:
        return declaration.name.lexeme.startsWith('_');
      case Visibility.public:
        return !declaration.name.lexeme.startsWith('_');
      default:
        // Outros modificadores não se aplicam a funções
        return false;
    }
  }

  bool _hasModifier(ClassDeclaration declaration) {
    switch (visibility) {
      case Visibility.abstract:
        return declaration.abstractKeyword != null;
      case Visibility.finalClass:
        return declaration.finalKeyword != null;
      case Visibility.sealed:
        return declaration.sealedKeyword != null;
      case Visibility.base:
        return declaration.baseKeyword != null;
      case Visibility.interface:
        return declaration.interfaceKeyword != null;
      case Visibility.abstractInterface:
        return declaration.abstractKeyword != null &&
            declaration.interfaceKeyword != null;
      case Visibility.private:
        return declaration.name.lexeme.startsWith('_');
      case Visibility.public:
        return !declaration.name.lexeme.startsWith('_');
      case Visibility.mixin:
        // Para classes que são mixins, verificamos se é uma MixinDeclaration
        return false; // Será tratado separadamente
      case Visibility.enumClass:
        // Para classes que são enums, verificamos se é uma EnumDeclaration
        return false; // Será tratado separadamente
      case Visibility.record:
        // Records são um tipo especial no Dart
        return _isRecord(declaration);
    }
  }

  bool _isRecord(ClassDeclaration declaration) {
    // Verificar se a classe segue o padrão de record
    // Isso pode ser customizado baseado nas suas convenções
    return declaration.name.lexeme.endsWith('Record') ||
        declaration.extendsClause?.superclass.name2.lexeme == 'Record';
  }

  String _getModifierName() {
    switch (visibility) {
      case Visibility.abstract:
        return 'abstract';
      case Visibility.finalClass:
        return 'final';
      case Visibility.sealed:
        return 'sealed';
      case Visibility.base:
        return 'base';
      case Visibility.interface:
        return 'interface';
      case Visibility.abstractInterface:
        return 'abstract interface';
      case Visibility.private:
        return 'private';
      case Visibility.public:
        return 'public';
      case Visibility.mixin:
        return 'mixin';
      case Visibility.enumClass:
        return 'enum';
      case Visibility.record:
        return 'record';
    }
  }
}
