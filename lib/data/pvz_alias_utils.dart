import 'package:collection/collection.dart';
import 'package:c_editor/data/level_rtid_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

enum PvzAliasCharacterIssue { whitespace, chineseCharacters }

/// Renames a [CurrentLevel] (or other source) object alias and updates RTIDs.
abstract final class PvzAliasUtils {
  /// Returns the first unsupported character category in a user-entered alias.
  ///
  /// Existing level files may contain other characters, so this check is kept
  /// deliberately narrow: editors reject whitespace and Han characters without
  /// imposing a stricter format on imported aliases.
  static PvzAliasCharacterIssue? unsupportedCharacterIssue(String alias) {
    if (RegExp(r'[\s\u0085]', unicode: true).hasMatch(alias)) {
      return PvzAliasCharacterIssue.whitespace;
    }
    if (_containsHanCharacters(alias)) {
      return PvzAliasCharacterIssue.chineseCharacters;
    }
    return null;
  }

  static bool _containsHanCharacters(String value) {
    return value.runes.any(
      (codePoint) =>
          (codePoint >= 0x3400 && codePoint <= 0x4DBF) ||
          (codePoint >= 0x4E00 && codePoint <= 0x9FFF) ||
          (codePoint >= 0xF900 && codePoint <= 0xFAFF) ||
          (codePoint >= 0x20000 && codePoint <= 0x2FA1F) ||
          (codePoint >= 0x30000 && codePoint <= 0x3347F),
    );
  }

  static bool isAliasAvailable(
    PvzLevelFile levelFile,
    String alias, {
    String? excludeAlias,
  }) {
    final trimmed = alias.trim();
    if (trimmed.isEmpty) return false;
    return !levelFile.objects.any((o) {
      final aliases = o.aliases;
      if (aliases == null || aliases.isEmpty) return false;
      if (excludeAlias != null && aliases.contains(excludeAlias)) return false;
      return aliases.contains(trimmed);
    });
  }

  static String uniqueAlias(
    PvzLevelFile levelFile,
    String baseAlias, {
    String numberSeparator = '_',
  }) {
    var candidate = baseAlias.trim();
    if (candidate.isEmpty) candidate = 'Object';
    if (isAliasAvailable(levelFile, candidate)) return candidate;
    var i = 1;
    while (!isAliasAvailable(levelFile, '$candidate$numberSeparator$i')) {
      i++;
    }
    return '$candidate$numberSeparator$i';
  }

  static void renameAlias({
    required PvzLevelFile levelFile,
    required String oldAlias,
    required String newAlias,
    String source = 'CurrentLevel',
  }) {
    final trimmed = newAlias.trim();
    if (trimmed.isEmpty || trimmed == oldAlias) return;
    final oldRtid = RtidParser.build(oldAlias, source);
    final newRtid = RtidParser.build(trimmed, source);

    final obj = levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(oldAlias) == true,
    );
    if (obj != null) {
      obj.aliases = [trimmed];
    }

    LevelRtidUtils.replaceReferences(levelFile, oldRtid, newRtid);
  }
}
