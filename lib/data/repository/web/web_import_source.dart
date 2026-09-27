/// Which web picker produced the entries an import is reading from.
///
/// Declared apart from the pickers themselves so platform-agnostic code (the
/// repository base) can name it without pulling `dart:js_interop` into a native
/// build.
enum WebImportSource {
  /// `<input webkitdirectory>` — keys are folder-relative paths.
  folder,

  /// `<input type="file">` — keys are leaf file names.
  files,
}
