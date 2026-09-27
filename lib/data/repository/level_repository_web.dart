import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../level_library_startup_cache.dart';
import '../pvz_models.dart';
import 'level_repository_base.dart';
import 'web/web_file_system_access.dart';
import 'web/web_level_opfs_store.dart';
import 'web/web_transfer_progress.dart';
import 'web/web_zip_builder.dart';
import 'package:c_editor/plugins/plugin_constants.dart';

/// Virtual path prefix for web - files opened via picker have no real path.
const String _webPathPrefix = 'web://';

String _normalizeWebDirPath(String path) {
  if (path.isEmpty || path == _webPathPrefix) return _webPathPrefix;
  var value = path;
  if (!value.startsWith(_webPathPrefix)) {
    value = '$_webPathPrefix$value';
  }
  while (value.endsWith('/') && value.length > _webPathPrefix.length) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

String _webJoin(String dirPath, String name) {
  final dir = _normalizeWebDirPath(dirPath);
  // Names must be relative leaf/subpaths — never trust a scheme-prefixed value
  // from path.basename on Flutter web.
  final cleanName = _storageKey(name.replaceAll('\\', '/').trim());
  if (cleanName.isEmpty) return dir;
  if (dir == _webPathPrefix) {
    return '$_webPathPrefix$cleanName';
  }
  return '$dir/$cleanName';
}

String _parentWebDir(String path) {
  final normalized = _normalizeWebDirPath(path);
  if (normalized == _webPathPrefix) return _webPathPrefix;
  final idx = normalized.lastIndexOf('/');
  if (idx < _webPathPrefix.length) return _webPathPrefix;
  return normalized.substring(0, idx);
}

String _relativeFromWebPath(String path) {
  final normalized = _normalizeWebDirPath(path);
  if (normalized == _webPathPrefix) return '';
  return normalized.substring(_webPathPrefix.length);
}

/// Strips a leading `web://` (or accidental `web:/`) so OPFS keys stay
/// library-relative. Using `package:path` on `web://…` paths is unsafe on
/// Flutter web — `basename` can return the whole scheme-prefixed string.
String _storageKey(String key) {
  var k = key.replaceAll('\\', '/').trim();
  if (k.startsWith(_webPathPrefix)) {
    k = k.substring(_webPathPrefix.length);
  } else if (k.startsWith('web:/')) {
    k = k.substring('web:/'.length);
  }
  while (k.startsWith('/')) {
    k = k.substring(1);
  }
  return k;
}

String _leafNameFromWebPath(String path) {
  final rel = path.startsWith(_webPathPrefix)
      ? _relativeFromWebPath(path)
      : path;
  final clean = rel.replaceAll('\\', '/');
  final idx = clean.lastIndexOf('/');
  return idx >= 0 ? clean.substring(idx + 1) : clean;
}

String _extensionFromName(String name) {
  final leaf = _leafNameFromWebPath(name);
  final idx = leaf.lastIndexOf('.');
  if (idx <= 0 || idx == leaf.length - 1) return '';
  return leaf.substring(idx + 1).toLowerCase();
}

String _fileNameFromPath(String filePath) {
  if (filePath.startsWith(_webPathPrefix)) {
    return filePath.substring(_webPathPrefix.length);
  }
  return p.basename(filePath);
}

LevelRepositoryBase createLevelRepository() => LevelRepositoryWebImpl();

class LevelRepositoryWebImpl extends LevelRepositoryBase {
  static const _prefsFolderKey = 'folder_path';
  static const _prefsLastLevelDirKey = 'last_level_directory';
  static const _defaultLibraryLabel = 'My Workspace';

  @override
  Future<List<LibraryItem>> getLibraries() async {
    await _ensureReady();
    return [
      LibraryItem(
        path: _webPathPrefix,
        displayName: _defaultLibraryLabel,
      )
    ];
  }

  @override
  Future<void> setLibraries(List<LibraryItem> libraries) async {
    // Web currently only supports the internal virtual storage
  }

  /// Metadata-only index of stored files: relative key -> byte size. File bytes
  /// live in OPFS and are read lazily, so the whole library is never in RAM.
  final Map<String, int> _index = {};
  final Set<String> _directories = {_webPathPrefix};

  /// Immediate children of each directory (web path → relative file keys).
  /// Keeps [getDirectoryContents] O(children) instead of O(library).
  final Map<String, Set<String>> _childFilesByParent = {};

  /// Immediate child directories of each directory (web path → child web paths).
  final Map<String, Set<String>> _childDirsByParent = {};

  final WebLevelOpfsStore _opfs = WebLevelOpfsStore.instance;
  final WebFileSystemAccess _fsa = WebFileSystemAccess.instance;

  Future<void>? _readyFuture;

  Future<void> _ensureReady() => _readyFuture ??= _initialize();

  Future<void> _initialize() async {
    await _opfs.ensureReady();

    final index = await _opfs.indexFilesWithSizes();
    _index
      ..clear()
      ..addAll(index);

    final dirs = await _opfs.listDirectories();
    _directories
      ..clear()
      ..add(_webPathPrefix);
    for (final rel in dirs) {
      _directories.add(_normalizeWebDirPath('$_webPathPrefix$rel'));
    }
    for (final key in _index.keys) {
      _registerParentDirectories(key);
    }
    _rebuildChildrenIndex();
  }

  @override
  Future<void> ensureWebStorageReady() => _ensureReady();

  @override
  bool isSupportedLevelFileName(String name) {
    // .rsb.smf archives are now supported on web (used as RSB export sources).
    return super.isSupportedLevelFileName(name);
  }

  @override
  void releaseWebImport(WebImportSource source) {
    _fsa.releaseImport(source);
  }

  @override
  Future<String?> getWebLibraryDisplayName() async {
    await _ensureReady();
    return _defaultLibraryLabel;
  }

  @override
  bool get isWebFolderImportSupported => _fsa.isSupported;

  @override
  Future<WebFolderImport?> pickWebFolderForImport() async {
    if (!_fsa.isSupported) {
      return null;
    }

    // Pick while the user-gesture is still active; bytes load during import.
    final picked = await _fsa.pickFolderForImport();
    if (picked == null) {
      _fsa.releaseImport(WebImportSource.folder);
      return null;
    }

    await _ensureReady();
    return WebFolderImport(name: picked.name, paths: picked.paths);
  }

  @override
  Future<List<String>?> pickWebFilesForImport(List<String> extensions) {
    // Deliberately *not* the `file_picker` package: its web implementation
    // detaches the <input type="file"> in the same task as `click()` and infers
    // cancellation from window focus, which loses the selection outright on
    // Android Chrome (the picker runs as a separate activity there).
    return _fsa.pickFilesForImport(extensions);
  }

  @override
  Future<int> importWebPickedBatched(
    List<({String storageKey, String relativePath})> entries, {
    WebImportSource source = WebImportSource.folder,
    WebTransferProgress? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (entries.isEmpty) {
      return 0;
    }
    await _ensureReady();
    const batchSize = 4;
    var imported = 0;
    try {
      for (var i = 0; i < entries.length; i++) {
        if (isCancelled?.call() == true) {
          break;
        }
        final entry = entries[i];
        final bytes = await _fsa.readImportEntry(source, entry.relativePath);
        if (bytes != null) {
          await _putFile(entry.storageKey, bytes);
          imported++;
        }
        onProgress?.call(i + 1, entries.length, null);
        if (i % batchSize == batchSize - 1) {
          await yieldToUi();
        }
      }
    } finally {
      _fsa.releaseImport(source);
    }
    return imported;
  }

  Future<void> _putFile(String key, Uint8List bytes) async {
    await _ensureReady();
    final storageKey = _storageKey(key);
    if (storageKey.isEmpty) {
      throw ArgumentError('Cannot write to empty web storage key.');
    }
    await _opfs.write(storageKey, bytes);
    _indexFile(storageKey, bytes.length);
  }

  Future<void> _removeFileKey(String key) async {
    await _ensureReady();
    await _opfs.delete(key);
    _unindexFile(key);
  }

  Future<void> _renameFileKey(String oldKey, String newKey) async {
    await _ensureReady();
    final size = _index[oldKey];
    if (size == null) {
      return;
    }
    await _opfs.renameFile(oldKey, newKey);
    _unindexFile(oldKey);
    _indexFile(newKey, size);
  }

  /// Indexes [key] at [size] and updates the parent→children maps.
  void _indexFile(String key, int size) {
    final had = _index.containsKey(key);
    _index[key] = size;
    if (!had) {
      final parent = _parentWebDir('$_webPathPrefix$key');
      (_childFilesByParent[parent] ??= <String>{}).add(key);
    }
    _registerParentDirectories(key);
  }

  /// Removes [key] from the size index and parent→children maps.
  void _unindexFile(String key) {
    if (_index.remove(key) == null) return;
    final parent = _parentWebDir('$_webPathPrefix$key');
    final kids = _childFilesByParent[parent];
    if (kids == null) return;
    kids.remove(key);
    if (kids.isEmpty) {
      _childFilesByParent.remove(parent);
    }
  }

  void _registerDirectory(String dir) {
    if (!_directories.add(dir) || dir == _webPathPrefix) return;
    final parent = _parentWebDir(dir);
    (_childDirsByParent[parent] ??= <String>{}).add(dir);
    _registerDirectory(parent);
  }

  void _registerParentDirectories(String key) {
    _registerDirectory(_parentWebDir('$_webPathPrefix$key'));
  }

  /// Rebuilds child maps from [_index] / [_directories] after bulk mutations.
  void _rebuildChildrenIndex() {
    _childFilesByParent.clear();
    _childDirsByParent.clear();
    for (final dir in _directories) {
      if (dir == _webPathPrefix) continue;
      final parent = _parentWebDir(dir);
      (_childDirsByParent[parent] ??= <String>{}).add(dir);
    }
    for (final key in _index.keys) {
      final parent = _parentWebDir('$_webPathPrefix$key');
      (_childFilesByParent[parent] ??= <String>{}).add(key);
    }
  }

  @override
  Future<bool> ensureFolderAccess() async {
    await _ensureReady();
    return true;
  }

  @override
  Future<LevelLibraryStartupCache> preloadLibrarySettings(
    SharedPreferences prefs,
  ) async {
    await _ensureReady();
    return LevelLibraryStartupCache(
      savedFolderPath: _webPathPrefix,
      webLibraryDisplayName: _defaultLibraryLabel,
      webReady: true,
    );
  }

  @override
  Future<String?> getSavedFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsFolderKey);
  }

  @override
  Future<void> setSavedFolderPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsFolderKey, path);
  }

  @override
  Future<List<FileItem>> getFavorites(
    String rootPath, {
    LevelSortMode sortMode = LevelSortMode.name,
  }) async {
    await _ensureReady();
    final favoritePaths = await readFavoriteLevelPaths();
    final items = <FileItem>[];

    for (final entry in _index.entries) {
      final fullPath = entry.key.startsWith(_webPathPrefix)
          ? entry.key
          : '$_webPathPrefix${entry.key}';

      if (favoritePaths.contains(fullPath)) {
        final name = _leafNameFromWebPath(fullPath);
        items.add(
          FileItem(
            name: name,
            path: fullPath,
            isDirectory: false,
            lastModified: 0,
            size: entry.value,
            isFavorite: true,
          ),
        );
      }
    }

    _sortItems(items, sortMode);
    return items;
  }

  @override
  Future<String> ensureIosLibraryPath() async => _webPathPrefix;

  @override
  Future<void> setLastOpenedLevelDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLastLevelDirKey, path);
  }

  @override
  Future<String?> getLastOpenedLevelDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsLastLevelDirKey);
  }

  @override
  Future<String> getCacheDir() async => _webPathPrefix;

  @override
  Future<bool> fileExistsInDirectory(String dirPath, String fileName) async {
    await _ensureReady();
    final filePath = _webJoin(dirPath, fileName);
    final key = _relativeFromWebPath(filePath);
    return _index.containsKey(key);
  }

  @override
  Future<List<FileItem>> getDirectoryContents(
    String dirPath, {
    LevelSortMode sortMode = LevelSortMode.name,
  }) async {
    await _ensureReady();
    if (!dirPath.startsWith(_webPathPrefix)) return [];
    final normalized = _normalizeWebDirPath(dirPath);
    _directories.add(_webPathPrefix);

    final favoritePaths = await readFavoriteLevelPaths();
    final items = <FileItem>[];

    final childDirs = _childDirsByParent[normalized];
    if (childDirs != null) {
      for (final dir in childDirs) {
        final leaf = _leafNameFromWebPath(dir);
        if (isReservedLibraryFolderName(leaf)) continue;
        items.add(
          FileItem(
            name: leaf,
            path: dir,
            isDirectory: true,
            lastModified: 0,
            size: 0,
          ),
        );
      }
    }

    final childFiles = _childFilesByParent[normalized];
    if (childFiles != null) {
      for (final key in childFiles) {
        final fullPath = '$_webPathPrefix$key';
        final name = _leafNameFromWebPath(fullPath);
        if (!isSupportedLibraryFileName(name)) continue;
        items.add(
          FileItem(
            name: name,
            path: fullPath,
            isDirectory: false,
            lastModified: 0,
            size: _index[key] ?? 0,
            isFavorite: favoritePaths.contains(fullPath),
          ),
        );
      }
    }

    items.sort((a, b) {
      // 1. Folders always on top, sorted by name
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      if (a.isDirectory) return naturalCompare(a.name, b.name);

      // 2. Favorites always on top of other files
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;

      // 3. File sorting based on mode
      return _compareFiles(a, b, sortMode);
    });
    return items;
  }

  void _sortItems(List<FileItem> list, LevelSortMode mode) {
    list.sort((a, b) => _compareFiles(a, b, mode));
  }

  int _compareFiles(FileItem a, FileItem b, LevelSortMode mode) {
    switch (mode) {
      case LevelSortMode.name:
        return naturalCompare(a.name, b.name);
      case LevelSortMode.modified:
        return b.lastModified.compareTo(a.lastModified);
      case LevelSortMode.created:
        return (b.creationTime ?? 0).compareTo(a.creationTime ?? 0);
      case LevelSortMode.size:
        return b.size.compareTo(a.size);
      case LevelSortMode.type:
        final rankCompare = a.extensionRank.compareTo(b.extensionRank);
        if (rankCompare != 0) return rankCompare;
        return naturalCompare(a.name, b.name);
    }
  }

  @override
  Future<bool> createDirectory(String parentPath, String name) async {
    await _ensureReady();
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.contains('/') || trimmed.contains('\\')) {
      return false;
    }
    if (isReservedLibraryFolderName(trimmed)) return false;
    final parent = _normalizeWebDirPath(parentPath);
    if (!_directories.contains(parent)) return false;
    final newDir = _webJoin(parent, trimmed);
    if (_directories.contains(newDir)) return false;
    final newKey = _relativeFromWebPath(newDir);
    if (_index.containsKey(newKey)) return false;
    await _opfs.createDirectory(newKey);
    _registerDirectory(newDir);
    return true;
  }

  @override
  Future<bool> renameItem(
    String currentDirPath,
    String oldName,
    String newName,
    bool isDirectory,
  ) async {
    await _ensureReady();
    final currentDir = _normalizeWebDirPath(currentDirPath);
    final oldPath = _webJoin(currentDir, oldName);
    final newPath = _webJoin(currentDir, newName);
    if (newName.trim().isEmpty ||
        newName.contains('/') ||
        newName.contains('\\')) {
      return false;
    }
    if (isDirectory &&
        (isReservedLibraryFolderName(newName) ||
            isReservedLibraryFolderName(oldName))) {
      return false;
    }
    if (isDirectory) {
      if (!_directories.contains(oldPath) || _directories.contains(newPath)) {
        return false;
      }
      final newKey = _relativeFromWebPath(newPath);
      if (_index.containsKey(newKey)) return false;

      final oldRel = _relativeFromWebPath(oldPath);
      final newRel = _relativeFromWebPath(newPath);
      await _opfs.renameDirectory(oldRel, newRel);

      final oldPrefix = '$oldPath/';
      final dirsToRename = _directories
          .where((d) => d == oldPath || d.startsWith(oldPrefix))
          .toList();
      for (final d in dirsToRename) {
        _directories.remove(d);
      }
      for (final d in dirsToRename) {
        final renamed = d == oldPath
            ? newPath
            : '$newPath/${d.substring(oldPrefix.length)}';
        _directories.add(renamed);
      }

      final oldRelPrefix = oldRel.isEmpty ? '' : '$oldRel/';
      final entriesToRename = _index.entries
          .where((e) => e.key == oldRel || e.key.startsWith(oldRelPrefix))
          .toList();
      for (final e in entriesToRename) {
        _index.remove(e.key);
        final renamedKey = e.key == oldRel
            ? newRel
            : '$newRel/${e.key.substring(oldRelPrefix.length)}';
        _index[renamedKey] = e.value;
      }
      _rebuildChildrenIndex();

      await moveFavoriteLevelPathPrefix(oldPath, newPath);
      return true;
    }

    final oldKey = _relativeFromWebPath(oldPath);
    final newKey = _relativeFromWebPath(newPath);
    if (!_index.containsKey(oldKey)) return false;
    if (_index.containsKey(newKey) || _directories.contains(newPath)) {
      return false;
    }
    await _renameFileKey(oldKey, newKey);
    await moveFavoriteLevelPath(oldPath, newPath);
    return true;
  }

  @override
  Future<void> deleteItem(
    String currentDirPath,
    String fileName,
    bool isDirectory,
  ) async {
    await _ensureReady();
    final currentDir = _normalizeWebDirPath(currentDirPath);
    final targetPath = _webJoin(currentDir, fileName);
    if (isDirectory) {
      final prefix = '$targetPath/';
      final targetRel = _relativeFromWebPath(targetPath);
      await _opfs.deleteDirectory(targetRel);
      _index.removeWhere((k, _) {
        final full = '$_webPathPrefix$k';
        return full == targetPath || full.startsWith(prefix);
      });
      _directories.removeWhere((d) => d == targetPath || d.startsWith(prefix));
      _directories.add(_webPathPrefix);
      _rebuildChildrenIndex();
      await removeFavoriteLevelPathPrefix(targetPath);
      return;
    }
    await _removeFileKey(_relativeFromWebPath(targetPath));
    await removeFavoriteLevelPath(targetPath);
  }

  @override
  Future<bool> copyLevelToTarget(
    String srcPath,
    String targetDirPath,
    String targetFileName,
  ) async {
    await _ensureReady();
    final srcName = _fileNameFromPath(srcPath);
    final targetPath = _webJoin(targetDirPath, targetFileName);
    final targetKey = _relativeFromWebPath(targetPath);
    if (_index.containsKey(targetKey)) return false;
    final bytes = await _opfs.read(srcName);
    if (bytes == null) return false;
    await _putFile(targetKey, bytes);
    await removeFavoriteLevelPath(targetPath);
    return true;
  }

  @override
  Future<bool> moveFile(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) async {
    await _ensureReady();
    if (srcDirPath == destDirPath) return false;
    final srcKey = _relativeFromWebPath(_webJoin(srcDirPath, fileName));
    final dstKey = _relativeFromWebPath(_webJoin(destDirPath, fileName));
    if (!_index.containsKey(srcKey) || _index.containsKey(dstKey)) {
      return false;
    }
    await _renameFileKey(srcKey, dstKey);
    await moveFavoriteLevelPath(
      _webJoin(srcDirPath, fileName),
      _webJoin(destDirPath, fileName),
    );
    return true;
  }

  @override
  Future<bool> moveFileOverwriting(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) async {
    await _ensureReady();
    if (srcDirPath == destDirPath) return false;
    final srcPath = _webJoin(srcDirPath, fileName);
    final destPath = _webJoin(destDirPath, fileName);
    final srcKey = _relativeFromWebPath(srcPath);
    final dstKey = _relativeFromWebPath(destPath);
    if (!_index.containsKey(srcKey)) return false;
    await _removeFileKey(dstKey);
    await _renameFileKey(srcKey, dstKey);
    await moveFavoriteLevelPath(srcPath, destPath, clearDestination: true);
    return true;
  }

  @override
  Future<String?> moveFileWithName(
    String srcDirPath,
    String fileName,
    String destDirPath,
    String newFileName,
  ) async {
    await _ensureReady();
    if (srcDirPath == destDirPath) return null;
    final srcPath = _webJoin(srcDirPath, fileName);
    final destPath = _webJoin(destDirPath, newFileName);
    final srcKey = _relativeFromWebPath(srcPath);
    final dstKey = _relativeFromWebPath(destPath);
    if (!_index.containsKey(srcKey)) return null;
    if (_index.containsKey(dstKey)) return null;
    await _renameFileKey(srcKey, dstKey);
    await moveFavoriteLevelPath(srcPath, destPath);
    return newFileName;
  }

  @override
  Future<int> clearAllInternalCache() async {
    await _ensureReady();
    final count = _index.length;
    _index.clear();
    _directories
      ..clear()
      ..add(_webPathPrefix);
    _childFilesByParent.clear();
    _childDirsByParent.clear();
    await _opfs.clear();
    return count;
  }

  @override
  Future<bool> prepareInternalCache(String sourcePath, String fileName) async {
    await _ensureReady();
    final sourceKey = _fileNameFromPath(sourcePath);
    if (_index.containsKey(sourceKey)) return true;
    if (_index.containsKey(fileName)) return true;
    return false;
  }

  @override
  Future<bool> prepareInternalCacheFromString(
    String fileName,
    String content,
  ) async {
    await _putFile(fileName, Uint8List.fromList(utf8.encode(content)));
    return true;
  }

  @override
  Future<Uint8List?> readLibraryFileBytes(String filePath) async {
    await _ensureReady();
    final key = _relativeFromWebPath(filePath);
    return _opfs.read(key);
  }

  @override
  Future<bool> prepareInternalCacheFromBytes(
    String fileName,
    List<int> bytes,
  ) async {
    // Avoid an extra full-buffer copy for already-typed data (large .rsb.smf
    // imports pass a Uint8List straight through).
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    await _putFile(fileName, data);
    return true;
  }

  @override
  Future<PvzLevelFile?> loadLevel(String fileName) async {
    await _ensureReady();
    final content = await _opfs.read(fileName);
    if (content == null) return null;
    return decodeLevelBytes(fileName, content);
  }

  @override
  Future<PvzLevelFile?> loadLevelFromPath(String filePath) async {
    final fileName = _fileNameFromPath(filePath);
    return loadLevel(fileName);
  }

  @override
  Future<void> saveAndExport(String filePath, PvzLevelFile levelData) async {
    final fileName = _fileNameFromPath(filePath);
    await _putFile(fileName, encodeLevelBytes(fileName, levelData));
  }

  @override
  Future<void> downloadLevel(String fileName) async {
    await _ensureReady();
    String? key;
    if (_index.containsKey(fileName)) {
      key = fileName;
    } else if (fileName.startsWith(_webPathPrefix)) {
      final rel = _relativeFromWebPath(fileName);
      if (_index.containsKey(rel)) key = rel;
    }
    if (key == null) {
      final targetLeaf = _leafNameFromWebPath(fileName);
      final matches = _index.keys
          .where((k) => _leafNameFromWebPath(k) == targetLeaf)
          .toList();
      if (matches.length == 1) {
        key = matches.first;
      }
    }
    if (key == null) return;
    final content = await _opfs.read(key);
    if (content == null) return;
    final downloadName = _leafNameFromWebPath(key);
    final ext = _extensionFromName(downloadName);
    await FilePicker.saveFile(
      dialogTitle: 'Save level',
      fileName: downloadName,
      type: FileType.custom,
      allowedExtensions: [ext.isEmpty ? 'json' : ext],
      bytes: content,
    );
  }

  @override
  Future<void> downloadAllLevelsAsZip({WebTransferProgress? onProgress}) async {
    await _ensureReady();
    if (_index.isEmpty) {
      return;
    }
    final keys = _index.keys.toList()..sort();
    final files = <({String path, Uint8List bytes})>[];
    for (final key in keys) {
      final bytes = await _opfs.read(key);
      if (bytes == null) continue;
      files.add((path: key, bytes: bytes));
    }
    final zipBytes = await buildZipBytes(files, onProgress: onProgress);
    if (zipBytes.isEmpty) {
      return;
    }
    await _triggerDownloadBytes('levels.zip', zipBytes);
  }

  @override
  Future<void> downloadFolderAsZip(
    String folderVirtualPath, {
    WebTransferProgress? onProgress,
  }) async {
    await _ensureReady();
    final normalized = _normalizeWebDirPath(folderVirtualPath);
    final prefix = _relativeFromWebPath(normalized);
    final folderName = _leafNameFromWebPath(normalized);

    final targets = <({String key, String zipPath})>[];
    for (final key in _index.keys) {
      final String relInFolder;
      if (prefix.isEmpty) {
        relInFolder = key;
      } else if (key.startsWith('$prefix/')) {
        relInFolder = key.substring(prefix.length + 1);
      } else {
        continue;
      }
      if (relInFolder.isEmpty) {
        continue;
      }
      targets.add((key: key, zipPath: '$folderName/$relInFolder'));
    }

    if (targets.isEmpty) {
      return;
    }
    targets.sort((a, b) => a.zipPath.compareTo(b.zipPath));

    final files = <({String path, Uint8List bytes})>[];
    for (final target in targets) {
      final bytes = await _opfs.read(target.key);
      if (bytes == null) continue;
      files.add((path: target.zipPath, bytes: bytes));
    }

    final zipBytes = await buildZipBytes(files, onProgress: onProgress);
    if (zipBytes.isEmpty) {
      return;
    }
    await _triggerDownloadBytes('$folderName.zip', zipBytes);
  }

  Future<void> _triggerDownloadBytes(String fileName, Uint8List bytes) async {
    await FilePicker.saveFile(
      dialogTitle: 'Save file',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      bytes: bytes,
    );
  }

  @override
  Future<bool> createLevelFromTemplate(
    String currentDirPath,
    String newFileName,
    String assetContent,
  ) async {
    await _ensureReady();
    final filePath = _webJoin(currentDirPath, newFileName);
    final key = _relativeFromWebPath(filePath);
    if (_index.containsKey(key)) return false;
    await _putFile(key, Uint8List.fromList(utf8.encode(assetContent)));
    await removeFavoriteLevelPath(filePath);
    return true;
  }

  @override
  Future<String?> convertLevelFile({
    required String sourcePath,
    required String sourceName,
    required String targetExtension,
    String? targetName,
  }) async {
    await _ensureReady();
    final srcName = _fileNameFromPath(sourcePath);
    final bytes = await _opfs.read(srcName);
    if (bytes == null) return null;
    PvzLevelFile? level;
    try {
      level = decodeLevelBytes(sourceName, bytes);
    } catch (_) {
      return null;
    }
    if (level == null) return null;
    final sourceDir = _parentWebDir('$_webPathPrefix$srcName');
    final targetNameOnly =
        targetName ??
        '${baseNameWithoutLevelExtension(sourceName)}$targetExtension';
    final targetPath = _webJoin(sourceDir, targetNameOnly);
    final target = _relativeFromWebPath(targetPath);
    if (_index.containsKey(target)) return null;
    await _putFile(target, encodeLevelBytes(target, level));
    await removeFavoriteLevelPath(targetPath);
    return target;
  }
}
