import '../rules/access_rule.dart';
import '../rules/annotation_rule.dart';
import '../rules/clean_architecture_rule.dart';
import '../rules/combine_rule.dart';
import '../rules/combined_naming_location_rule.dart';
import '../rules/constructor_params_rule.dart';
import '../rules/cyclic_dependency_rule.dart';
import '../rules/extend_rule.dart';
import '../rules/features_independence_rule.dart';
import '../rules/field_rule.dart';
import '../rules/implement_rule.dart';
import '../rules/import_by_file_rule.dart';
import '../rules/import_rule.dart';
import '../rules/line_count_rule.dart';
import '../rules/method_rule.dart';
import '../rules/method_rule_type.dart';
import '../rules/multiple_import_by_file_rule.dart';
import '../rules/multiple_no_dependency_rule.dart';
import '../rules/naming_rule.dart';
import '../rules/no_dependency_rule.dart';
import '../rules/only_dependency_rule.dart';
import '../rules/reside_in_rule.dart';
import '../rules/visibility_rule.dart';
import '../selectors/enum_selector.dart';
import '../utils/rule_base.dart';

enum VisibilityEnum { public, private }

class ClassSelector {
  final String package;
  final String? nameFilter;
  final bool? checkContains;
  final bool? checkPrefix;

  ClassSelector(
    this.package, {
    this.nameFilter,
    this.checkContains,
    this.checkPrefix,
  });

  ClassSelector inPackage(String packageName) => ClassSelector(
        packageName,
        nameFilter: nameFilter,
        checkContains: checkContains,
        checkPrefix: checkPrefix,
      );

  ClassSelector inFolder(String folder) => ClassSelector(
        folder,
        nameFilter: nameFilter,
        checkContains: checkContains,
        checkPrefix: checkPrefix,
      );

  ClassSelector inDirectory(String directory) => ClassSelector(
        directory,
        nameFilter: nameFilter,
        checkContains: checkContains,
        checkPrefix: checkPrefix,
      );

  ClassSelector inFile(String file) => ClassSelector(
        file,
        nameFilter: nameFilter,
        checkContains: checkContains,
        checkPrefix: checkPrefix,
      );

  NoDependencyRule shouldNotDependOn(String targetPackage) {
    return NoDependencyRule(package, targetPackage);
  }

  ImportByFileRule shouldNotBeImportedIn(String fileName) {
    return ImportByFileRule(package, fileName);
  }

  MultipleImportByFileRule shouldNotBeImportedInAny(List<String> files) {
    return MultipleImportByFileRule(package, files);
  }

  MultipleNoDependencyRule shouldNotDependOnAny(List<String> targetPackages) {
    return MultipleNoDependencyRule(package, targetPackages);
  }

  OnlyDependencyRule shouldOnlyDependOn(List<String> packages) {
    return OnlyDependencyRule(package, packages);
  }

  CleanArchitectureRule shouldFollowCleanArchitecture(
      {List<String>? allowedLayers}) {
    return CleanArchitectureRule(package, allowedLayers: allowedLayers);
  }

  VisibilityRule shouldBePublic() => VisibilityRule(package, Visibility.public);
  VisibilityRule shouldBePrivate() =>
      VisibilityRule(package, Visibility.private);
  VisibilityRule shouldBeFinal() =>
      VisibilityRule(package, Visibility.finalClass);
  VisibilityRule shouldBeAbstract() =>
      VisibilityRule(package, Visibility.abstract);
  VisibilityRule shouldBeSealed() => VisibilityRule(package, Visibility.sealed);
  VisibilityRule shouldBeBase() => VisibilityRule(package, Visibility.base);
  VisibilityRule shouldBeMixin() => VisibilityRule(package, Visibility.mixin);
  VisibilityRule shouldBeEnum() =>
      VisibilityRule(package, Visibility.enumClass);
  VisibilityRule shouldBeRecord() => VisibilityRule(package, Visibility.record);
  VisibilityRule shouldBeInterface() =>
      VisibilityRule(package, Visibility.interface);
  VisibilityRule shouldBeAbstractInterface() =>
      VisibilityRule(package, Visibility.abstractInterface);

  VisibilityRule shouldNotBe(Visibility visibility) =>
      VisibilityRule(package, visibility, negate: true);
  VisibilityRule shouldNotBeAbstract() =>
      VisibilityRule(package, Visibility.abstract, negate: true);
  VisibilityRule shouldNotBeFinal() =>
      VisibilityRule(package, Visibility.finalClass, negate: true);
  VisibilityRule shouldNotBeSealed() =>
      VisibilityRule(package, Visibility.sealed, negate: true);
  VisibilityRule shouldNotBeBase() =>
      VisibilityRule(package, Visibility.base, negate: true);

  NoDependencyRule shouldNotAccessPackage(String targetPackage) {
    return NoDependencyRule(package, targetPackage);
  }

  AnnotationRule shouldBeAnnotatedWith(String annotation) {
    return AnnotationRule(package, annotation);
  }

  FieldRule shouldHaveFieldsOfType(String type) {
    return FieldRule(package, expectedType: type);
  }

  FieldRule shouldHaveFieldsWithVisibility(Visibility visibility) {
    return FieldRule(package, visibility: visibility);
  }

  FieldRule shouldHaveNonFinalFields() {
    return FieldRule(package, shouldBeFinal: false);
  }

  FieldRule shouldHaveFinalFields() {
    return FieldRule(package, shouldBeFinal: true);
  }

  CyclicDependencyRule shouldHaveNoCyclicDependencies(List<String> packages) {
    return CyclicDependencyRule(packages);
  }

  CombinedRule shouldComplyWith(List<ArchRule> rules) {
    return CombinedRule(package, rules);
  }

  VisibilityRule shouldBe(Visibility visibility) {
    return VisibilityRule(package, visibility);
  }

  ImplementRule shouldImplement(String interfaceName) {
    return ImplementRule(package, interfaceName);
  }

  ImplementRule shouldImplementInterfaceThatEndsWith(String suffix) {
    return ImplementRule(package, '', interfaceNameSuffix: suffix);
  }

  ImplementRule shouldImplementOnly(List<String> interfaces) =>
      ImplementRule(package, interfaces.first, allowedInterfaces: interfaces);

  ExtendRule shouldExtend(String className) => ExtendRule(package, className);
  ExtendRule shouldExtendAnyOf(List<String> classNames) =>
      ExtendRule(package, classNames.first, allowedClasses: classNames);

  MethodRuleBuilder shouldHaveMethodThat() {
    return MethodRuleBuilder(package);
  }

  MethodRuleBuilder shouldHaveAllMethods() {
    return MethodRuleBuilder(package, checkAll: true);
  }

  NamingRule shouldHaveNameEndingWith(String suffix) {
    return NamingRule(package, suffix, checkClasses: true, checkMethods: false);
  }

  NamingRule shouldHaveMethodWithName(String name) {
    return NamingRule.forMethods(package, name);
  }

  ImportRule shouldNotHaveImports(List<String> imports) {
    return ImportRule(package, imports);
  }

  VisibilityRule shouldHaveOnlyPrivateConstructors() =>
      VisibilityRule(package, Visibility.private, isConstructor: true);

  VisibilityRule shouldHaveOnlyPublicConstructors() =>
      VisibilityRule(package, Visibility.public, isConstructor: true);

  ConstructorParamsRule shouldRequireAllParams() => ConstructorParamsRule(
      package, ConstructorParamsRuleType.requireAllParams);

  ConstructorParamsRule shouldHaveOnlyNamedRequiredParams() =>
      ConstructorParamsRule(
          package, ConstructorParamsRuleType.onlyNamedRequiredParams);

  ResideInRule shouldBeInPackage(String packageName) =>
      ResideInRule(package, packageName);

  ResideInRule shouldBeInAnyPackage(List<String> packages) =>
      ResideInRule(package, packages.first, allowedPackages: packages);

  AccessRule shouldOnlyBeAccessedBy(List<String> packages) =>
      AccessRule(package, packages);

  ClassSelector withNameEndingWith(String suffix) => ClassSelector(
        package,
        nameFilter: suffix,
        checkContains: false,
        checkPrefix: false,
      );

  ClassSelector withNameContaining(String substring) => ClassSelector(
        package,
        nameFilter: substring,
        checkContains: true,
        checkPrefix: false,
      );

  ClassSelector withNameStartingWith(String prefix) => ClassSelector(
        package,
        nameFilter: prefix,
        checkContains: false,
        checkPrefix: true,
      );

  AnnotationRule withAnnotation(String annotation) =>
      AnnotationRule(package, annotation);

  LineCountRule withLineCountGreaterThan(int count) =>
      LineCountRule(package, count);

  ArchRule shouldBeInFolder(String folder) {
    if (nameFilter == null) {
      return ResideInRule(package, folder, isFolder: true);
    }

    return CombinedNamingLocationRule(
      nameFilter!,
      folder,
      checkContains: checkContains ?? false,
      checkPrefix: checkPrefix ?? false,
    );
  }
}

class MethodSelector {
  final String package;

  MethodSelector(this.package);

  MethodSelector inPackage(String packageName) => MethodSelector(packageName);
  MethodSelector inFolder(String folder) => MethodSelector(folder);
  MethodSelector inDirectory(String directory) => MethodSelector(directory);
  MethodSelector inFile(String file) => MethodSelector(file);

  NamingRule shouldHaveNameEndingWith(String suffix) {
    return NamingRule.forMethods(package, suffix);
  }

  NamingRule shouldHaveNameContaining(String substring) {
    return NamingRule.forMethods(package, substring, checkContains: true);
  }

  MethodRule shouldBeAsync() {
    return MethodRule(package, MethodRuleType.async, checkAll: true);
  }

  MethodRule shouldBePrivate() {
    return MethodRule(package, MethodRuleType.visibility,
        isPrivate: true, checkAll: true);
  }

  MethodRule shouldReturnType(String type) {
    return MethodRule(package, MethodRuleType.returnType,
        expectedType: type, checkAll: true);
  }
}

class FunctionSelector {
  final String package;

  FunctionSelector(this.package);

  FunctionSelector inPackage(String packageName) =>
      FunctionSelector(packageName);
  FunctionSelector inFolder(String folder) => FunctionSelector(folder);
  FunctionSelector inDirectory(String directory) => FunctionSelector(directory);
  FunctionSelector inFile(String file) => FunctionSelector(file);

  NamingRule shouldHaveNameEndingWith(String suffix) {
    return NamingRule.forFunctions(package, suffix);
  }

  NamingRule shouldHaveNameContaining(String substring) {
    return NamingRule.forFunctions(package, substring, checkContains: true);
  }

  MethodRule shouldBeAsync() {
    return MethodRule(package, MethodRuleType.async, isFunction: true);
  }

  MethodRule shouldReturnType(String type) {
    return MethodRule(package, MethodRuleType.returnType,
        expectedType: type, isFunction: true);
  }
}

class FeaturesSelector {
  final String featuresPath;

  FeaturesSelector([this.featuresPath = 'features']);

  FeaturesIndependenceRule shouldBeIndependent() {
    return FeaturesIndependenceRule(featuresPath);
  }
}

ClassSelector classes() => ClassSelector('');
MethodSelector methods() => MethodSelector('');
FunctionSelector functions() => FunctionSelector('');
EnumSelector enums() => EnumSelector('');
FeaturesSelector features([String path = 'features']) => FeaturesSelector(path);

class MethodRuleBuilder {
  final String package;
  final bool checkAll;
  final bool isForEnum;

  MethodRuleBuilder(
    this.package, {
    this.checkAll = false,
    this.isForEnum = false,
  });

  MethodRule returnType(String type) {
    return MethodRule(
      package,
      MethodRuleType.returnType,
      expectedType: type,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  MethodRule shouldBeAsync() {
    return MethodRule(
      package,
      MethodRuleType.async,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  MethodRule shouldBePrivate() {
    return MethodRule(
      package,
      MethodRuleType.visibility,
      isPrivate: true,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  MethodRule shouldBePublic() {
    return MethodRule(
      package,
      MethodRuleType.visibility,
      isPrivate: false,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  MethodRule shouldHaveAnnotation(String annotation) {
    return MethodRule(
      package,
      MethodRuleType.annotation,
      requiredAnnotation: annotation,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  MethodRule hasMethodNamed(String methodName) {
    return MethodRule(
      package,
      MethodRuleType.name,
      expectedMethodName: methodName,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  MethodRule withParameters(List<String> parameters) {
    return MethodRule(
      package,
      MethodRuleType.parameters,
      expectedParameters: parameters,
      checkAll: checkAll,
      isForEnum: isForEnum,
    );
  }

  NamingRule withNameEndingWith(String suffix) {
    return NamingRule.forMethods(package, suffix);
  }

  NamingRule withNameContaining(String substring) {
    return NamingRule.forMethods(package, substring, checkContains: true);
  }
}
