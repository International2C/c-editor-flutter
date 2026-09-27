import 'dart:convert';

import 'package:flutter/services.dart';

import '../pvz_models.dart';

/// Loads reference LevelModules from assets and provides alias -> objClass lookup.
/// Ported from Z-Editor-master ReferenceRepository.kt
class ReferenceRepository {
  ReferenceRepository._();
  static final ReferenceRepository instance = ReferenceRepository._();

  Map<String, PvzObject>? _moduleCache;
  final Set<String> _validGridItemAliases = {};
  final Map<String, PvzObject> _gridItemTypesByName = {};

  /// Load LevelModules.json and GridItemTypes.json from assets. Call once (e.g. when entering editor).
  static Future<void> init() async {
    if (instance._moduleCache != null) return;
    try {
      final modulesJson = await rootBundle.loadString(
        'assets/reference/LevelModules.json',
      );
      final modulesMap = jsonDecode(modulesJson) as Map<String, dynamic>;
      final list = modulesMap['objects'] as List<dynamic>? ?? [];
      final cache = <String, PvzObject>{};
      for (final e in list) {
        final obj = PvzObject.fromJson(e as Map<String, dynamic>);
        final alias = obj.aliases?.isNotEmpty == true
            ? obj.aliases!.first
            : 'unknown';
        if (!cache.containsKey(alias)) cache[alias] = obj;
      }
      instance._moduleCache = cache;

      final gridJson = await rootBundle.loadString(
        'assets/reference/GridItemTypes.json',
      );
      final gridMap = jsonDecode(gridJson) as Map<String, dynamic>;
      final gridList = gridMap['objects'] as List<dynamic>? ?? [];
      for (final e in gridList) {
        final obj = e as Map<String, dynamic>;
        final object = PvzObject.fromJson(obj);
        final data = object.objData;
        if (object.objClass == 'GridItemType' && data is Map) {
          final typeName = data['TypeName'];
          if (typeName is String && typeName.isNotEmpty) {
            instance._gridItemTypesByName[typeName] = object;
          }
        }
        final aliases = obj['aliases'] as List<dynamic>? ?? [];
        for (final a in aliases) {
          instance._validGridItemAliases.add(a.toString());
        }
      }
    } catch (_) {
      instance._moduleCache = {};
    }
  }

  String? getObjClass(String alias) {
    return _moduleCache?[alias]?.objClass;
  }

  PvzObject? objectForAlias(String alias) => _moduleCache?[alias];

  /// Some built-in types (such as armrack) have a TypeName but no RTID alias.
  PvzObject? gridItemTypeForName(String typeName) =>
      _gridItemTypesByName[typeName];

  /// Returns true if alias is in GridItemTypes.json. If not loaded, returns true (permissive).
  bool isValidGridItem(String alias) {
    if (_validGridItemAliases.isEmpty) return true;
    return _validGridItemAliases.contains(alias);
  }

  /// Positive resource evidence; unlike picker validation, unavailable catalogs
  /// must not classify every unknown name as a grid item.
  bool isKnownGridItem(String alias) => _validGridItemAliases.contains(alias);

  bool get isLoaded => _moduleCache != null;
}
