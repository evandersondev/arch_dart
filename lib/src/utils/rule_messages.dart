class RuleMessages {
  // Padrão para mensagens de erro
  static String violationFound(String ruleType, List<String> violations) {
    return '$ruleType rule violation${violations.length > 1 ? 's' : ''} found:\n'
        '${violations.map((v) => '  • $v').join('\n')}';
  }

  // lineRuleViolation
  static String lineRuleViolation(
      String className, String lineNumber, String filePath, String message) {
    return 'Line rule violation in class "$className" at line $lineNumber (file: $filePath): $message';
  }

  // Mensagens específicas por tipo de regra
  static String namingViolation(String elementType, String elementName,
      String pattern, bool isContains, String filePath) {
    final condition = isContains ? 'contain' : 'end with';
    return '$elementType "$elementName" must $condition "$pattern" (file: $filePath)';
  }

  static String annotationViolation(String elementType, String elementName,
      String annotation, String filePath) {
    return '$elementType "$elementName" must be annotated with @$annotation (file: $filePath)';
  }

  static String implementationViolation(
      String className, String interfaceName, String filePath) {
    return 'Class "$className" must implement $interfaceName (file: $filePath)';
  }

  static String dependencyViolation(
      String sourceFile, String targetPackage, String importPath) {
    return 'File "$sourceFile" must not depend on "$targetPackage" (import: $importPath)';
  }

  static String visibilityViolation(
      String className, String expectedVisibility, String filePath) {
    return 'Class "$className" must be $expectedVisibility (file: $filePath)';
  }

  static String extendViolation(
      String className, String expectedParent, String filePath) {
    return 'Class "$className" must extend $expectedParent (file: $filePath)';
  }

  static String fieldViolation(
      String className, String fieldName, String requirement, String filePath) {
    return 'Class "$className" field "$fieldName" $requirement (file: $filePath)';
  }

  static String importViolation(String filePath, String forbiddenImport) {
    return 'File "$filePath" must not import "$forbiddenImport"';
  }

  static String lineCountViolation(
      String filePath, int actualCount, int maxCount) {
    return 'File "$filePath" has $actualCount lines but must not exceed $maxCount lines';
  }

  static String methodViolation(String className, String methodName,
      String requirement, String filePath) {
    return 'Class "$className" method "$methodName" $requirement (file: $filePath)';
  }

  static String cyclicDependencyViolation(List<String> cycle) {
    return 'Cyclic dependency detected: ${cycle.join(' -> ')} -> ${cycle.first}';
  }

  static String featureIndependenceViolation(String sourceFeature,
      String targetFeature, String filePath, String importPath) {
    return 'Feature "$sourceFeature" must not depend on feature "$targetFeature" (file: $filePath, import: $importPath)';
  }

  static String enumValueCountViolation(
      String enumName, int actualCount, int minCount, String filePath) {
    return 'Enum "$enumName" has $actualCount values but must have more than $minCount values (file: $filePath)';
  }

  static String interfaceEndingViolation(
      String className, String suffix, String filePath) {
    return 'Class "$className" must implement an interface ending with "$suffix" (file: $filePath)';
  }

  static String accessViolation(
      String className, List<String> allowedPackages, String accessingFile) {
    return 'Class "$className" can only be accessed by packages: ${allowedPackages.join(', ')} (accessed from: $accessingFile)';
  }

  static String residenceViolation(
      String className, String expectedLocation, String actualLocation) {
    return 'Class "$className" must reside in "$expectedLocation" but found in "$actualLocation"';
  }
}
