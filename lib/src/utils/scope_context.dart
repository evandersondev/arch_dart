enum ScopeType {
  package,
  folder,
  file,
  directory,
}

class ScopeContext {
  final ScopeType type;
  final String path;
  final List<String> includedPaths;
  final List<String> excludedPaths;
  final bool recursive;

  ScopeContext({
    required this.type,
    required this.path,
    this.includedPaths = const [],
    this.excludedPaths = const [],
    this.recursive = true,
  });

  ScopeContext.package(String packageName)
      : type = ScopeType.package,
        path = packageName,
        includedPaths = const [],
        excludedPaths = const [],
        recursive = true;

  ScopeContext.folder(String folderPath, {bool recursive = true})
      : type = ScopeType.folder,
        path = folderPath,
        includedPaths = const [],
        excludedPaths = const [],
        recursive = recursive;

  ScopeContext.file(String filePath)
      : type = ScopeType.file,
        path = filePath,
        includedPaths = const [],
        excludedPaths = const [],
        recursive = false;

  ScopeContext.directory(String directoryPath, {bool recursive = true})
      : type = ScopeType.directory,
        path = directoryPath,
        includedPaths = const [],
        excludedPaths = const [],
        recursive = recursive;

  bool matches(String filePath) {
    switch (type) {
      case ScopeType.package:
        return filePath.contains('/$path/') || filePath.contains('\\$path\\');
      case ScopeType.folder:
      case ScopeType.directory:
        if (recursive) {
          return filePath.contains('/$path/') || filePath.contains('\\$path\\');
        } else {
          final normalizedPath = filePath.replaceAll('\\', '/');
          final normalizedScope = path.replaceAll('\\', '/');
          return normalizedPath.contains('/$normalizedScope/');
        }
      case ScopeType.file:
        return filePath.endsWith(path);
    }
  }

  bool isExcluded(String filePath) {
    for (final excluded in excludedPaths) {
      if (filePath.contains(excluded)) {
        return true;
      }
    }
    return false;
  }

  bool isIncluded(String filePath) {
    if (includedPaths.isEmpty) return true;

    for (final included in includedPaths) {
      if (filePath.contains(included)) {
        return true;
      }
    }
    return false;
  }

  bool shouldProcess(String filePath) {
    return matches(filePath) && !isExcluded(filePath) && isIncluded(filePath);
  }

  ScopeContext copyWith({
    ScopeType? type,
    String? path,
    List<String>? includedPaths,
    List<String>? excludedPaths,
    bool? recursive,
  }) {
    return ScopeContext(
      type: type ?? this.type,
      path: path ?? this.path,
      includedPaths: includedPaths ?? this.includedPaths,
      excludedPaths: excludedPaths ?? this.excludedPaths,
      recursive: recursive ?? this.recursive,
    );
  }

  @override
  String toString() {
    return 'ScopeContext(type: $type, path: $path, recursive: $recursive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScopeContext &&
        other.type == type &&
        other.path == path &&
        other.recursive == recursive;
  }

  @override
  int get hashCode {
    return type.hashCode ^ path.hashCode ^ recursive.hashCode;
  }
}
