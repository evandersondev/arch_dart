<p align="center">
  <!-- <img src="./assets/logo.png" width="200px" align="center" alt="Darto logo" /> -->
  <h1 align="center">ArchDart</h1>
  <br>
  <p align="center">
  <!-- <a href="https://darto-docs.vercel.app/">🐶 Oficial Darto Documentation</a> -->
  <br/>
    Dart/Flutter Architectural Testing Framework inspired by ArchUnit for Java. 
  </p>
</p>

<br/>

### Support 💖

If you find ArchDart useful, please consider supporting its development 🌟[Buy Me a Coffee](https://buymeacoffee.com/evandersondev).🌟 Your support helps us improve the framework and make it even better!

<br>
<br>

**Note**: Some rules in ArchDart have not been thoroughly tested and may contain potential errors. Please report any issues or unexpected behavior to the project repository for further investigation and improvement.

ArchDart is a Dart and Flutter package inspired by Java's ArchUnit, designed to enforce architectural rules in your projects. It provides a fluent, expressive API to validate the structure, naming conventions, dependencies, and other architectural aspects of your Dart/Flutter codebase. ArchDart helps ensure that your project adheres to clean architecture principles, domain-driven design, or custom architectural patterns.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Selectors](#selectors)
- [Scopes](#scopes)
- [Filters](#filters)
- [Assertions](#assertions)
  - [Modifiers and Types](#modifiers-and-types)
  - [Inheritance and Implementation](#inheritance-and-implementation)
  - [Structure, Naming, and Constructors](#structure-naming-and-constructors)
  - [Dependencies and Layers](#dependencies-and-layers)
  - [File Content](#file-content)
- [Negations](#negations)
- [Utilities](#utilities)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add ArchDart to your project by including it in your `pubspec.yaml`:

```yaml
dev_dependencies:
  arch_dart: ^[latest-version]
```

Run `flutter pub get` to install the package.

## Usage

ArchDart provides a fluent API to define architectural rules and validate them against your Dart/Flutter codebase. Rules are defined using selectors, scopes, filters, and assertions, and are executed using the `check` method. The package integrates with `flutter_test` for writing test cases.

Here’s a basic example:

```dart
import 'package:arch_dart/arch_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Repositories should end with Repository', () async {
    await classes()
        .inFolder('infra/repositories')
        .shouldHaveNameEndingWith('Repository')
        .check();
  });
}
```

## Selectors

Selectors define the type of elements to validate:

| Selector      | Description                     |
| ------------- | ------------------------------- |
| `classes()`   | Selects all classes             |
| `enums()`     | Selects all enums               |
| `methods()`   | Selects all methods             |
| `functions()` | Selects all top-level functions |
| `features()`  | Selects feature directories     |

## Scopes

Scopes narrow down the elements to a specific location in the project:

| Method                | Description                                      |
| --------------------- | ------------------------------------------------ |
| `inPackage('name')`   | Logical package (e.g., `controller`, `service`)  |
| `inFolder('path')`    | Directory path in the project (e.g., `lib/core`) |
| `inDirectory('path')` | Alias for `inFolder`                             |
| `inFile('file.dart')` | Specific Dart file                               |

## Filters

Filters select a subset of elements based on specific criteria:

| Method                         | Description                              |
| ------------------------------ | ---------------------------------------- |
| `withNameEndingWith('suffix')` | Names ending with the specified suffix   |
| `withNameContaining('text')`   | Names containing the specified text      |
| `withAnnotation('name')`       | Elements with the specified annotation   |
| `withLineCountGreaterThan(n)`  | Classes with more than `n` lines of code |
| `withValueCountGreaterThan(n)` | Enums with more than `n` values          |

## Assertions

Assertions define the rules that elements must satisfy. They are prefixed with `should...`.

### Modifiers and Types

| Method                       | Description                   |
| ---------------------------- | ----------------------------- |
| `shouldBePublic()`           | Must be public                |
| `shouldBePrivate()`          | Must be private               |
| `shouldBeFinal()`            | Must be `final`               |
| `shouldBeAbstract()`         | Must be `abstract`            |
| `shouldBeSealed()`           | Must be `sealed`              |
| `shouldBeBase()`             | Must be `base`                |
| `shouldBeMixin()`            | Must be a `mixin`             |
| `shouldBeEnum()`             | Must be an `enum`             |
| `shouldBeRecord()`           | Must be a `record`            |
| `shouldBeAnnotatedWith('X')` | Must have the `@X` annotation |

### Inheritance and Implementation

| Method                         | Description                                  |
| ------------------------------ | -------------------------------------------- |
| `shouldExtend('SuperClass')`   | Must extend the specified class              |
| `shouldExtendAnyOf([...])`     | Must extend one of the specified classes     |
| `shouldImplement('Interface')` | Must implement the specified interface       |
| `shouldImplementOnly([...])`   | Must implement only the specified interfaces |

### Structure, Naming, and Constructors

| Method                                | Description                                                      |
| ------------------------------------- | ---------------------------------------------------------------- |
| `shouldHaveNameEndingWith('X')`       | Name must end with `X`                                           |
| `shouldHaveOnlyPrivateConstructors()` | All constructors must be private                                 |
| `shouldRequireAllParams()`            | Constructors must have all required parameters                   |
| `shouldHaveOnlyNamedRequiredParams()` | Constructors must have only named required parameters            |
| `shouldHaveMethodThat()`              | Methods must satisfy specific criteria (e.g., name, return type) |

### Dependencies and Layers

| Method                          | Description                                    |
| ------------------------------- | ---------------------------------------------- |
| `shouldOnlyDependOn([...])`     | Can only depend on the specified packages      |
| `shouldOnlyBeAccessedBy([...])` | Can only be accessed by the specified packages |
| `shouldBeInPackage('X')`        | Must reside in the specified package           |
| `shouldBeInAnyPackage([...])`   | Must reside in one of the specified packages   |
| `shouldBeInFolder('path')`      | Must reside in the specified folder            |
| `shouldNotHaveImports([...])`   | Must not import the specified packages         |
| `shouldNotBeImportedIn('file')` | Must not be imported in the specified file     |
| `shouldBeIndependent()`         | Features must not reference each other         |

### File Content

| Method                          | Description                                     |
| ------------------------------- | ----------------------------------------------- |
| `shouldContain('text')`         | File must contain the specified text            |
| `shouldNotBeExportedIn('file')` | File must not be exported in the specified file |

## Negations

Negations are assertions prefixed with `shouldNot...` to ensure elements do not meet certain criteria:

| Method                              | Description                                |
| ----------------------------------- | ------------------------------------------ |
| `shouldNotBe(type)`                 | Must not be of the specified type/modifier |
| `shouldNotDependOn('package')`      | Must not depend on the specified package   |
| `shouldNotAccessPackage('package')` | Must not access the specified package      |
| `shouldNotHaveImports([...])`       | Must not import the specified packages     |
| `shouldNotContain('text')`          | File must not contain the specified text   |
| `shouldNotBeExportedIn('file')`     | Must not be exported in the specified file |

## Utilities

Utilities help control rule execution and chaining:

| Method         | Description                                               |
| -------------- | --------------------------------------------------------- |
| `check()`      | Executes the rule validation                              |
| `andAlso()`    | Chains multiple rules with AND logic                      |
| `orElse()`     | Chains multiple rules with OR logic                       |
| `shouldFail()` | Marks the rule as expected to fail (for negative testing) |

## Examples

Below are example test cases demonstrating common use cases for ArchDart:

### Enforcing Naming Conventions

Ensure all enums in `lib/core/enums` have a `stringToEnum` method and end with `Enum`:

```dart
test('All enums should have stringToEnum method', () async {
  await enums()
      .inFolder('lib/core/enums')
      .shouldHaveMethodThat()
      .hasMethodNamed('stringToEnum')
      .andAlso()
      .shouldHaveNameEndingWith('Enum')
      .check();
});
```

### Enforcing Layer Dependencies

Ensure classes in the `presentation` package do not depend on `infra`:

```dart
test('Presentation should not access Infra', () async {
  await classes()
      .inPackage('presentation')
      .shouldNotDependOn('infra')
      .check();
});
```

### Enforcing Clean Architecture

Ensure use cases in `domain/usecases` have an `execute` method:

```dart
test('UseCases should have an execute method', () async {
  await classes()
      .inFolder('domain/usecases')
      .shouldHaveMethodThat()
      .hasMethodNamed('execute')
      .check();
});
```

### Enforcing Feature Isolation

Ensure features are independent of each other:

```dart
test('Features should not reference each other', () async {
  await features()
      .shouldBeIndependent()
      .check();
});
```

### Enforcing Constructor Rules

Ensure entities in `domain/entities` use only named required parameters:

```dart
test('Entities should have all required named parameters', () async {
  await classes()
      .inFolder('domain/entities')
      .shouldHaveOnlyNamedRequiredParams()
      .check();
});
```

### Enforcing Layer Structure

Ensure the project follows the expected layer structure:

```dart
test('Layers should follow the expected structure', () async {
  await layers(['presentation', 'domain', 'infra', 'core'])
      .onlyStructure()
      .allowMissingLayers()
      .check();
});
```

### Use `ArchRule` Type

Use the `ArchRule` type to define custom rules:

```dart
test('Custom rule example', () async {
  ArchRule rule = classes()
    .inPackage('presentation')
    .shouldNotDependOn('infra');

  await rule.check();
});
```

## Contributing

Contributions to ArchDart are welcome! Please submit issues or pull requests to the project repository. When contributing, ensure that:

- New rules are thoroughly tested.
- Documentation is updated to reflect new features.
- Code follows Dart best practices and includes appropriate comments.

## License

ArchDart is licensed under the [MIT License](LICENSE). See the LICENSE file for details.
