import 'dart:convert';
import 'package:flutter/services.dart';
import '../pvz_models.dart';
import '../rtid_parser.dart';

class ZombiePropertiesRepository {
  ZombiePropertiesRepository._();
  static final ZombiePropertiesRepository instance =
      ZombiePropertiesRepository._();

  final Map<String, ZombieStats> _statsCache = {};
  final Map<String, String> _aliasToTypeCache = {};
  final Map<String, String> _aliasToZombieClassCache = {};
  final Map<String, PvzObject> _originalTypeJson = {};
  final Map<String, PvzObject> _originalPropsJson = {};
  bool _isInitialized = false;

  static Future<void> init() async {
    if (instance._isInitialized) return;
    try {
      final propsFileMap = await _loadReferenceFile(
        'assets/reference/PropertySheets.json',
      );
      final typesFileMap = await _loadReferenceFile(
        'assets/reference/ZombieTypes.json',
      );

      for (final entry in typesFileMap.entries) {
        final alias = entry.key;
        final obj = entry.value;
        try {
          if (obj.objData is! Map<String, dynamic>) continue;
          final typeData = ZombieTypeData.fromJson(
            obj.objData as Map<String, dynamic>,
          );
          final typeName = typeData.typeName;
          if (typeName.isEmpty) continue;
          final zombieClass =
              (obj.objData as Map<String, dynamic>)['ZombieClass']
                  ?.toString()
                  .trim() ??
              '';
          if (zombieClass.isNotEmpty) {
            for (final candidate in <String>{
              alias,
              typeName,
              ...?obj.aliases,
            }) {
              final normalized = candidate.trim();
              if (normalized.isNotEmpty) {
                instance._aliasToZombieClassCache.putIfAbsent(
                  normalized,
                  () => zombieClass,
                );
              }
            }
          }
          if (instance._aliasToTypeCache.containsKey(alias) ||
              instance._aliasToTypeCache.containsKey(typeName)) {
            continue;
          }

          instance._aliasToTypeCache[alias] = typeName;
          instance._aliasToTypeCache[typeName] = typeName;
          instance._originalTypeJson[typeName] = obj;

          final propsAlias = RtidParser.parse(typeData.properties)?.alias ?? '';
          final propsObj = propsFileMap[propsAlias];
          if (propsObj != null && propsObj.objData is Map<String, dynamic>) {
            instance._originalPropsJson[typeName] = propsObj;
            instance._statsCache[typeName] = ZombieStats.fromPropertySheet(
              typeName,
              propsObj.objData as Map<String, dynamic>,
            );
          }
        } catch (_) {}
      }
      instance._isInitialized = true;
    } catch (_) {}
  }

  static Future<Map<String, PvzObject>> _loadReferenceFile(String path) async {
    try {
      final jsonStr = await rootBundle.loadString(path);
      final Map<String, dynamic> root =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final objects = (root['objects'] as List<dynamic>? ?? [])
          .map((e) => PvzObject.fromJson(e as Map<String, dynamic>))
          .toList();
      final result = <String, PvzObject>{};
      for (final o in objects) {
        final alias = o.aliases?.isNotEmpty == true
            ? o.aliases!.first
            : 'unknown';
        if (!result.containsKey(alias)) result[alias] = o;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  static String getTypeNameByAlias(String alias) {
    return instance._aliasToTypeCache[alias] ?? alias;
  }

  /// Returns the exact ZombieClass declared by the matching ZombieType.
  ///
  /// The mapping comes from the same bundled ZombieTypes reference already
  /// used for zombie templates and follows that repository's source priority.
  static String? getZombieClassByAlias(String alias) {
    final normalized = alias.trim();
    if (normalized.isEmpty) return null;
    return instance._aliasToZombieClassCache[normalized] ??
        instance._aliasToZombieClassCache[getTypeNameByAlias(normalized)];
  }

  static ZombieStats getStats(String typeName) {
    return instance._statsCache[typeName] ??
        ZombieStats(
          id: typeName,
          hp: 0.0,
          cost: 0,
          weight: 0,
          speed: 0.0,
          eatDPS: 0.0,
          sizeType: 'unknown',
        );
  }

  static bool isValidAlias(String alias) {
    return instance._aliasToTypeCache.containsKey(alias);
  }

  static Map<String, PvzObject>? getTemplateJson(String typeName) {
    final t = instance._originalTypeJson[typeName];
    final p = instance._originalPropsJson[typeName];
    if (t == null || p == null) return null;
    return {'type': t, 'props': p};
  }

  static PvzObject? getOriginalTypeObject(String typeName) {
    return instance._originalTypeJson[typeName];
  }

  static PvzObject? getOriginalPropertyObject(String typeName) {
    return instance._originalPropsJson[typeName];
  }

  static Map<String, dynamic>? cloneOriginalTypeData(String typeName) {
    final data = instance._originalTypeJson[typeName]?.objData;
    if (data is! Map) return null;
    return _cloneMap(data);
  }

  static Map<String, dynamic>? cloneOriginalPropertyData(String typeName) {
    final data = instance._originalPropsJson[typeName]?.objData;
    if (data is! Map) return null;
    return _cloneMap(data);
  }

  static Map<String, dynamic> _cloneMap(Map data) {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(data)) as Map<String, dynamic>,
    );
  }

  /// Whether the base zombie's default property sheet defines a [Resilience]
  /// shield (distinct from [ZombieTypeData.resistences]).
  static bool supportsResilienceShield(String typeName) {
    final props = instance._originalPropsJson[typeName];
    if (props?.objData is! Map<String, dynamic>) return false;
    return (props!.objData as Map<String, dynamic>).containsKey('Resilience');
  }

  static bool get isInitialized => instance._isInitialized;
}
