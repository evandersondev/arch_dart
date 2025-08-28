import 'package:arch_dart/arch_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Top level functions',
    () {
      test(
        'All function in factory folder should be start with "make"',
        () async {
          ArchRule rule = functions()
              .inFolder('core/factories')
              .shouldHaveNameContaining('make');

          await rule.check();
        },
      );
    },
  );

  test('All enums should be stringToEnum method', () async {
    await enums()
        .inFolder('lib/core/enums')
        .shouldHaveMethodThat()
        .hasMethodNamed('stringToEnum')
        .andAlso()
        .shouldHaveNameEndingWith('Enum')
        .check();
  });

  group('Naming and Visibility Rules', () {
    test('Repositories should end with Repository', () async {
      ArchRule rule = classes()
          .inFolder('infra/repositories')
          .shouldHaveNameEndingWith('RepositoryImpl');

      await rule.check();
    });

    test('Services should end with Service and be public', () async {
      await classes()
          .inFolder('infra/services')
          .shouldBe(Visibility.public)
          .andAlso()
          .shouldHaveNameEndingWith('Service')
          .check();
    });

    test('Classes with too many lines should be avoided', () async {
      await classes()
          .inFolder('lib/domain/entities')
          .withLineCountGreaterThan(100)
          .shouldFail()
          .check();
    });

    test('Entities should not be imported directly in main', () async {
      await classes()
          .inFolder('domain/entities')
          .shouldNotBeImportedIn('main.dart')
          .check();
    });
  });

  group('Layers and Dependencies', () {
    test('Presentation should not access Infra', () async {
      await classes()
          .inPackage('presentation')
          .shouldNotDependOn('infra')
          .check();
    });

    test('Domain should not depend on Presentation or Infra', () async {
      await classes()
          .inPackage('domain')
          .shouldNotDependOnAny(['presentation', 'infra']).check();
    });

    test('Infra should only depend on Domain and Core', () async {
      await classes()
          .inPackage('infra')
          .shouldOnlyDependOn(['domain', 'core']).check();
    });

    test('Presentation should only depend on Domain and Core', () async {
      await classes()
          .inPackage('presentation')
          .shouldOnlyDependOn(['domain', 'core']).check();
    });

    test('Repositories in domain must be abstract', () async {
      await classes()
          .inFolder('domain/repositories')
          .shouldBeAbstract()
          .andAlso()
          .shouldHaveNameEndingWith('Repository')
          .check();
    });
  });

  group('Domain Purity', () {
    test('Domain should not import Flutter or IO packages', () async {
      await classes().inPackage('domain').shouldNotHaveImports([
        'package:flutter',
        'package:flutter/material.dart',
        'dart:io',
      ]).check();
    });

    test('Entities should be final', () async {
      await classes().inFolder('domain/entities').shouldBeFinal().check();
    });

    test('Classes ending with Controller should be in the correct folder',
        () async {
      await classes()
          .withNameEndingWith('Controller')
          .shouldBeInFolder('presentation/controllers')
          .check();
    });

    test('Entities should have all required named parameters', () async {
      await classes()
          .inFolder('domain/entities')
          .shouldHaveOnlyNamedRequiredParams()
          .check();
    });
  });

  group('Clean Architecture Rules', () {
    test('UseCases should have an execute method', () async {
      await classes()
          .inFolder('domain/usecases')
          .shouldHaveMethodThat()
          .hasMethodNamed('execute')
          .check();
    });

    test('Entities should not have external dependencies', () async {
      await classes().inFolder('domain/entities').shouldNotHaveImports([
        'package:http',
        'package:dio',
        'package:flutter',
      ]).check();
    });
  });

  group('Feature Isolation', () {
    test('Features should not reference each other', () async {
      await features().shouldBeIndependent().check();
    });
  });

  group('State Rules in Presentation', () {
    test('Controllers should be annotated with @immutable', () async {
      await classes()
          .inFolder('presentation/controllers')
          .shouldBeAnnotatedWith('immutable')
          .check();
    });

    test('States should end with State and use Freezed', () async {
      await classes()
          .inFolder('presentation/states')
          .shouldHaveNameEndingWith('State')
          .check();

      await classes()
          .inFolder('presentation/states')
          .shouldBeAnnotatedWith('freezed')
          .check();
    });
  });

  group('Layer Organization', () {
    // test('Main layers should exist', () async {
    //   await layers(['presentation', 'domain', 'infra', 'core'])
    //       .onlyStructure()
    //       .requireAllLayers()
    //       .check();
    // });

    test('Layers should follow the expected structure', () async {
      await layers(['presentation', 'domain', 'infra', 'core'])
          .onlyStructure()
          .allowMissingLayers()
          .check();
    });
  });

  group('Interfaces', () {
    test('Repositories should implement their interfaces', () async {
      await classes()
          .inFolder('infra/repositories')
          .shouldImplement('IUserRepository')
          .check();
    });

    // test('Services should implement their interfaces', () async {
    //   await classes()
    //       .inFolder('infra/services')
    //       .shouldImplementInterfaceThatEndsWith('Service')
    //       .check();
    // });
  });
}
