import 'package:flutter/foundation.dart';

/// In-memory state shared by repeated visits to a searchable chooser.
///
/// Callers compose the key from the current level and chooser purpose so the
/// state remains local to the editing context without being written to JSON.
class SelectionViewMemory {
  String query = '';
  double scrollOffset = 0;
  double tagScrollOffset = 0;
  final Map<String, Object?> filters = <String, Object?>{};
  final Map<String, double> scrollOffsets = <String, double>{};
}

abstract final class SelectionViewMemoryStore {
  static final Map<String, SelectionViewMemory> _states = {};

  static SelectionViewMemory forKey(String key) =>
      _states.putIfAbsent(key, SelectionViewMemory.new);

  @visibleForTesting
  static void clear() => _states.clear();
}
