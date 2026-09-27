import 'dart:typed_data';

import 'package:c_editor/data/repository/web/web_file_picker.dart';
import 'package:c_editor/data/repository/web/web_folder_picker.dart';
import 'package:c_editor/data/repository/web/web_import_source.dart';

export 'package:c_editor/data/repository/web/web_import_source.dart';

/// Web import facade (Dart-only; no File System Access API).
class WebFileSystemAccess {
  WebFileSystemAccess._();

  static final WebFileSystemAccess instance = WebFileSystemAccess._();

  final WebFolderPicker _folderPicker = WebFolderPicker.instance;
  final WebFilePicker _filePicker = WebFilePicker.instance;

  bool get isSupported => _folderPicker.isSupported;

  Future<({String name, List<String> paths})?> pickFolderForImport() =>
      _folderPicker.pickFolderForImport();

  Future<List<String>?> pickFilesForImport(List<String> extensions) =>
      _filePicker.pickFilesForImport(extensions);

  Future<Uint8List?> readImportEntry(WebImportSource source, String path) =>
      switch (source) {
        WebImportSource.folder => _folderPicker.readFolderImportEntry(path),
        WebImportSource.files => _filePicker.readFileImportEntry(path),
      };

  void releaseImport(WebImportSource source) => switch (source) {
    WebImportSource.folder => _folderPicker.releaseFolderImport(),
    WebImportSource.files => _filePicker.releaseFileImport(),
  };
}
