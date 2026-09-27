import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

/// A level-local custom zombie variant sharing the same base [TypeName].
class CustomZombieVariation {
  const CustomZombieVariation({required this.alias, required this.rtid});

  final String alias;
  final String rtid;
}

/// Helpers for level-local custom [ZombieType] objects and their references.
abstract final class CustomZombieLevelUtils {
  static const _currentLevel = 'CurrentLevel';
  static const _zombieReferenceKeys = {
    'Type',
    'TypeName',
    'ZombieTypeName',
    'DropperZombieType',
  };

  static bool isCustomZombieRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return false;
    final info = RtidParser.parse(rtid);
    return info?.source == _currentLevel;
  }

  /// Unknown built-in types or missing icons are not broken custom references.
  static bool isMissingCustomZombie(PvzLevelFile levelFile, String typeOrRtid) {
    final info = RtidParser.parse(typeOrRtid);
    if (info == null || (info.source != _currentLevel && info.source != '.')) {
      return false;
    }
    return !levelFile.objects.any(
      (object) =>
          object.objClass == 'ZombieType' &&
          object.aliases?.contains(info.alias) == true,
    );
  }

  static String defaultRtid(String baseType) {
    final aliases = ZombieRepository().buildZombieAliases(baseType);
    return RtidParser.build(aliases, 'ZombieTypes');
  }

  static String? aliasFromRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return null;
    return RtidParser.parse(rtid)?.alias;
  }

  static List<CustomZombieVariation> listVariations(
    PvzLevelFile levelFile,
    String baseType,
  ) {
    final items = <CustomZombieVariation>[];
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'ZombieType') continue;
      final aliases = obj.aliases;
      if (aliases == null || aliases.isEmpty) continue;
      final alias = aliases.first;
      final data = obj.objData;
      if (data is! Map<String, dynamic>) continue;
      if (data['TypeName'] != baseType) continue;
      items.add(
        CustomZombieVariation(
          alias: alias,
          rtid: RtidParser.build(alias, _currentLevel),
        ),
      );
    }
    items.sort((a, b) => a.alias.compareTo(b.alias));
    return items;
  }

  /// Resolves a custom zombie alias from an RTID or a bare level-local alias.
  static String? resolveCustomZombieAlias(
    PvzLevelFile levelFile,
    String typeOrRtid,
  ) {
    final info = RtidParser.parse(typeOrRtid);
    if (info?.source == _currentLevel) return info!.alias;
    final isLevelType = levelFile.objects.any(
      (o) =>
          o.objClass == 'ZombieType' && o.aliases?.contains(typeOrRtid) == true,
    );
    return isLevelType ? typeOrRtid : null;
  }

  /// Counts how many times [alias@CurrentLevel] appears in level object data.
  static int countZombieUses(PvzLevelFile levelFile, String alias) {
    final rtid = RtidParser.build(alias, _currentLevel);
    var count = 0;
    for (final obj in levelFile.objects) {
      count += _countZombieUseInValue(obj.objData, rtid, alias);
    }
    return count;
  }

  static int countReferences(PvzLevelFile levelFile, String alias) {
    return countZombieUses(levelFile, alias);
  }

  static int _countZombieUseInValue(dynamic value, String rtid, String alias) {
    if (value == rtid) return 1;
    if (value is List) {
      var sum = 0;
      for (final item in value) {
        sum += _countZombieUseInValue(item, rtid, alias);
      }
      return sum;
    }
    if (value is Map) {
      var sum = 0;
      for (final entry in value.entries) {
        if (_zombieReferenceKeys.contains(entry.key) &&
            _isZombieReference(entry.value, rtid)) {
          sum++;
        } else {
          sum += _countZombieUseInValue(entry.value, rtid, alias);
        }
      }
      return sum;
    }
    return 0;
  }

  static bool _isZombieReference(dynamic value, String rtid) {
    return value == rtid;
  }

  /// Removes [ZombieType] and its [CurrentLevel] property sheet, if present.
  static void removeTypeAndProperties(PvzLevelFile levelFile, String alias) {
    PvzObject? typeObj;
    for (final obj in levelFile.objects) {
      if (obj.objClass == 'ZombieType' &&
          obj.aliases?.contains(alias) == true) {
        typeObj = obj;
        break;
      }
    }
    if (typeObj == null) return;

    final data = typeObj.objData;
    if (data is Map<String, dynamic>) {
      final propsRtid = data['Properties'] as String?;
      final propsInfo = propsRtid != null ? RtidParser.parse(propsRtid) : null;
      if (propsInfo?.source == _currentLevel) {
        levelFile.objects.removeWhere(
          (o) => o.aliases?.contains(propsInfo!.alias) == true,
        );
      }
    }
    levelFile.objects.remove(typeObj);
  }

  /// Whether removing one zombie reference would leave [alias] unused.
  static bool willBeOrphanAfterRemove(PvzLevelFile levelFile, String alias) {
    return countZombieUses(levelFile, alias) == 1;
  }

  /// Prompts only when [alias] is used by exactly one current-level zombie.
  static Future<bool?> maybePromptDeleteOrphanBeforeRemove({
    required BuildContext context,
    required PvzLevelFile levelFile,
    required String alias,
  }) async {
    if (!willBeOrphanAfterRemove(levelFile, alias)) return false;
    return promptDeleteOrphanProperties(context, alias: alias);
  }

  /// Asks whether orphan type/property objects should be erased from the level.
  /// Returns `true` to erase, `false` to keep them in the level file.
  static Future<bool?> promptDeleteOrphanProperties(
    BuildContext context, {
    required String alias,
  }) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final okGreen = isDark ? pvzGreenLight : pvzGreenDark;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.customZombieOrphanDeleteTitle ??
              'Erase custom properties from level?',
        ),
        content: Text(
          l10n?.customZombieOrphanDeleteMessage(alias) ??
              'This is the last use of "$alias" in this level. '
                  'Remove its zombie type and property objects from the level file? '
                  'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n?.customZombieOrphanDeleteKeep ?? 'Keep in level'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: okGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n?.customZombieOrphanDeleteErase ?? 'Erase from level',
            ),
          ),
        ],
      ),
    );
  }

  /// Deletes a zombie from a modal bottom sheet: prompts for orphan cleanup,
  /// closes the sheet, then runs [onRemove].
  static Future<void> handleDeleteFromBottomSheet({
    required BuildContext sheetContext,
    required BuildContext parentContext,
    required PvzLevelFile levelFile,
    required String zombieTypeRtid,
    required Future<void> Function(bool eraseOrphanProperties) onRemove,
  }) async {
    final info = RtidParser.parse(zombieTypeRtid);
    var eraseOrphan = false;
    if (info?.source == _currentLevel) {
      final choice = await maybePromptDeleteOrphanBeforeRemove(
        context: parentContext,
        levelFile: levelFile,
        alias: info!.alias,
      );
      if (choice == null) return;
      eraseOrphan = choice;
    }
    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    await onRemove(eraseOrphan);
  }
}
