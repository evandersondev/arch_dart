import 'constructor_selector.dart';
import 'enum_selector.dart';
import 'file_selector.dart';
import 'function_selector.dart';
import 'method_selector.dart';

class ElementSelector {
  final String package;

  ElementSelector(this.package);

  // Scoping methods
  ElementSelector inPackage(String package) => ElementSelector(package);
  ElementSelector inFolder(String folder) => ElementSelector(folder);
  ElementSelector inDirectory(String directory) => ElementSelector(directory);
  ElementSelector inFile(String file) => ElementSelector(file);

  // New entry points
  EnumSelector asEnums() => EnumSelector(package);
  MethodSelector asMethods() => MethodSelector(package);
  ConstructorSelector asConstructors() => ConstructorSelector(package);
  FileSelector asFiles() => FileSelector(package);
  FunctionSelector asFunctions() => FunctionSelector(package);
}

// Entry point functions
ElementSelector classes() => ElementSelector('');
ElementSelector enums() => ElementSelector('');
ElementSelector methods() => ElementSelector('');
ElementSelector constructors() => ElementSelector('');
ElementSelector files() => ElementSelector('');
ElementSelector functions() => ElementSelector('');

extension ElementSelectorExtension on Object {
  ElementSelector inPackage(String package) => ElementSelector(package);
  ElementSelector inFolder(String folder) => ElementSelector(folder);
  ElementSelector inDirectory(String directory) => ElementSelector(directory);
  ElementSelector inFile(String file) => ElementSelector(file);
}
