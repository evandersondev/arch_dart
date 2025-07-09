import '../rules/content_rule.dart';
import '../rules/export_rule.dart';

class FileSelector {
  final String package;

  FileSelector(this.package);

  ContentRule shouldContain(String text) => ContentRule(package, text);
  ContentRule shouldNotContain(String text) =>
      ContentRule(package, text, shouldContain: false);
  ExportRule shouldNotBeExportedIn(String file) => ExportRule(package, file);
  ContentRule shouldOnlyContainRecords() =>
      ContentRule(package, '', onlyRecords: true);
}
