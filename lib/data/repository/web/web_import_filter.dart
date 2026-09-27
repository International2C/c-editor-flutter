/// Extension filtering for the web import pickers.
///
/// Deliberately free of `dart:js_interop` so it stays unit-testable on the VM
/// and importable from platform-agnostic code.
///
/// Callers must apply these helpers themselves *as well as* passing the list to
/// the browser as an `accept` hint: Android's file chooser treats `accept` as a
/// suggestion and will hand back files the filter was meant to hide, which is
/// how a pick used to end up importing nothing at all.
library;

/// Case-insensitive extension allow-list, or `null` to accept every file.
///
/// Entries are normalised (trimmed, leading dots stripped, lower-cased) so a
/// caller may pass `'json'`, `'.json'` or `'JSON'`. An empty list yields
/// `null`, i.e. no filtering.
Set<String>? webPickExtensionFilter(Iterable<String> extensions) {
  final normalized = <String>{
    for (final extension in extensions)
      if (_normalizeExtension(extension).isNotEmpty)
        _normalizeExtension(extension),
  };
  return normalized.isEmpty ? null : normalized;
}

/// Lower-cased extension of [fileName] without the dot, or `''` when the name
/// carries no usable extension (leading dot, trailing dot, or none at all).
String webPickExtensionOf(String fileName) {
  final slash = fileName.lastIndexOf('/');
  final leaf = slash >= 0 ? fileName.substring(slash + 1) : fileName;
  final dot = leaf.lastIndexOf('.');
  if (dot <= 0 || dot == leaf.length - 1) return '';
  return leaf.substring(dot + 1).toLowerCase();
}

/// True when [fileName] passes [filter]; a `null` filter accepts everything.
bool webPickMatchesFilter(String fileName, Set<String>? filter) {
  if (filter == null) return true;
  return filter.contains(webPickExtensionOf(fileName));
}

String _normalizeExtension(String extension) =>
    extension.trim().replaceFirst(RegExp(r'^\.+'), '').toLowerCase();
