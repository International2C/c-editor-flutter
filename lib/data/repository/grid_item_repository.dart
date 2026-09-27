import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/lunar_mine_vein_type_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Grid item info. Ported from Z-Editor-master GridItemRepository.kt
/// For display use ResourceNames.lookup(context, 'griditem_$typeName').
enum GridItemFilterMode { all, restricted, renaiStatues }

enum GridItemTag { normal, special }

enum GridItemSource { defaultSource, custom }

class GridItemInfo {
  const GridItemInfo({
    required this.typeName,
    required this.category,
    this.gameTypeName,
    this.gridItemTypeAlias,
    this.exclusivePresetGroup,
    this.icon,
    this.tag = GridItemTag.normal,
    this.source = GridItemSource.defaultSource,
    this.gridItemType,
    this.companionObjects = const [],
  });

  final String typeName;
  final String? gameTypeName;
  final String? gridItemTypeAlias;
  final String? exclusivePresetGroup;
  final GridItemCategory category;

  String get actualTypeName => gameTypeName ?? typeName;

  /// Icon filename in assets/images/griditems/ (e.g. 'gravestone_egypt.webp').
  /// Null = use placeholder icon.
  final String? icon;
  final GridItemTag tag;
  final GridItemSource source;
  final PvzObject? gridItemType;
  final List<PvzObject> companionObjects;
}

enum GridItemCategory {
  all('All'),
  scene('Scene'),
  trap('Trap'),
  spawnableObjects('Spawnable Objects');

  const GridItemCategory(this.label);
  final String label;
}

/// Grid item repository. Icons from assets/images/griditems/.
/// Items without matching icon use placeholder.
/// For localized display use getLocalizedName(context, typeName) via ResourceNames.
class GridItemRepository {
  GridItemRepository._();

  static const String _resourcePath = 'assets/resources/GridItems.json';
  static const Map<String, String> _moduleGridItemIcons = {
    'ArmrackArmor': 'ArmrackArmor.webp',
    'ArmrackBlade': 'ArmrackBlade.webp',
    'ArmrackBomb': 'ArmrackBomb.webp',
    'ArmrackFlag': 'ArmrackFlag.webp',
    'ArmrackHammer': 'ArmrackHammer.webp',
    'ArmrackNunchaku': 'ArmrackNunchaku.webp',
    'ArmrackTorch': 'ArmrackTorch.webp',
    'energyGrid': 'energyGrid.webp',
    'radiation_meteor_ore': 'radiation_meteor_ore.webp',
    'SmokeManhole': 'SmokeManhole.webp',
    'steam_down': 'steam_down.webp',
    'steam_up': 'steam_up.webp',
  };
  static final List<GridItemInfo> staticItems = [];
  static bool _isLoaded = false;

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      await ReferenceRepository.init();
      final jsonString = await loadJsonString(_resourcePath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      staticItems
        ..clear()
        ..addAll(
          jsonList.map((raw) {
            final item = raw as Map<String, dynamic>;
            return GridItemInfo(
              typeName: item['typeName'] as String,
              gameTypeName: item['gameTypeName'] as String?,
              gridItemTypeAlias: item['gridItemTypeAlias'] as String?,
              exclusivePresetGroup: item['exclusivePresetGroup'] as String?,
              category: _parseCategory(item['category'] as String?),
              icon: item['icon'] as String?,
              tag: _parseTag(item['tag'] as String?),
              source: _parseSource(item['source'] as String?),
              gridItemType: _parseGridItemType(item['gridItemType']),
              companionObjects: _parseCompanionObjects(
                item['companionObjects'],
              ),
            );
          }),
        );
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading grid items: $e');
    }
  }

  static List<GridItemInfo> get allItems => staticItems;

  static List<GridItemInfo> getByCategory(GridItemCategory category) {
    if (category == GridItemCategory.all) return allItems;
    return allItems.where((i) => i.category == category).toList();
  }

  static List<GridItemInfo> getAll() => allItems;

  static GridItemInfo? getByTypeName(String typeName) {
    for (final item in allItems) {
      if (item.typeName == typeName) return item;
    }
    final alias = buildGridAliases(typeName);
    for (final item in allItems) {
      if (item.actualTypeName == typeName ||
          item.gridItemTypeAlias == typeName ||
          buildGridAliases(item.actualTypeName) == alias) {
        return item;
      }
    }
    return null;
  }

  /// Returns asset path for icon, or unknown placeholder if no icon.
  static String getIconPath(String aliases) {
    final vein = lunarMineVeinTypeInfo(aliases);
    if (vein != null) return vein.iconAsset;
    final moduleIcon = _moduleGridItemIcons[aliases];
    if (moduleIcon != null) {
      return 'assets/images/griditems/$moduleIcon';
    }
    if (aliases == 'gulliver_tunnel') {
      return 'assets/images/tunnels/GULLIVERTUNNEL_ORIENTATION_BIG_ON_LEFT.webp';
    }
    if (aliases.startsWith('tool_powertile_')) {
      return 'assets/images/tools/$aliases.png';
    }
    if (aliases == 'pumpkin_house') {
      return 'assets/images/griditems/pumpkin_house.webp';
    }
    final typeName = aliases == 'gravestone' ? 'gravestone_egypt' : aliases;
    final icon = getByTypeName(typeName)?.icon;
    return icon != null
        ? 'assets/images/griditems/$icon'
        : 'assets/images/others/unknown.webp';
  }

  /// True for any Renai statue type (half or non-half).
  static bool isRenaiStatue(String typeName) =>
      typeName.contains('renai_statue_') ||
      typeName == 'renai_zomboss_statue_zombie1_half';

  /// Renai statue types only (for statue picker in Renai module).
  static List<GridItemInfo> getRenaiStatueItems() =>
      allItems.where((i) => isRenaiStatue(i.typeName)).toList();

  static bool isValid(String typeName) {
    if (typeName == 'pumpkin_house') return true;
    if (allItems.any(
      (item) => item.typeName == typeName || item.actualTypeName == typeName,
    )) {
      return true;
    }
    return ReferenceRepository.instance.isValidGridItem(typeName);
  }

  static String buildGridAliases(String id) {
    if (id == 'gravestone_egypt') return 'gravestone';
    return id;
  }

  static String buildGridItemTypeRtid(String typeName, PvzLevelFile levelFile) {
    final item = getByTypeName(typeName);
    final alias =
        item?.gridItemTypeAlias ??
        buildGridAliases(item?.actualTypeName ?? typeName);
    if (item?.source == GridItemSource.custom) {
      ensureCustomGridItemInLevel(typeName, levelFile);
      if (item?.gridItemType != null) {
        ensureGridItemTypeInLevel(typeName, levelFile);
        return RtidParser.build(alias, 'CurrentLevel');
      }
    }
    return RtidParser.build(alias, 'GridItemTypes');
  }

  static PvzObject? ensureGridItemTypeInLevel(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final item = getByTypeName(typeName);
    if (item == null || item.source != GridItemSource.custom) return null;
    ensureCustomGridItemInLevel(typeName, levelFile);
    final template = item.gridItemType;
    if (template == null) return null;

    final alias =
        item.gridItemTypeAlias ?? buildGridAliases(item.actualTypeName);
    final templateAliases = template.aliases;
    final aliases = templateAliases != null && templateAliases.isNotEmpty
        ? templateAliases
        : <String>[alias];
    final templateTypeName = _gridItemTypeName(template) ?? item.actualTypeName;

    for (final object in levelFile.objects) {
      if (object.objClass != 'GridItemType') continue;
      final objectAliases = object.aliases ?? const <String>[];
      if (aliases.any(objectAliases.contains)) return object;
      if (_gridItemTypeName(object) == templateTypeName) return object;
    }

    final object = _clonePvzObject(template);
    if (object.aliases == null || object.aliases!.isEmpty) {
      object.aliases = List<String>.from(aliases);
    }
    levelFile.objects.add(object);
    return object;
  }

  static bool ensureCustomGridItemInLevel(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final item = getByTypeName(typeName);
    if (item == null || item.source != GridItemSource.custom) return true;

    for (final template in _customObjectTemplates(item)) {
      if (_findMatchingTemplateObject(levelFile, template) != null) continue;
      if (_findObjectWithTemplateAlias(levelFile, template) != null) continue;
      levelFile.objects.add(_clonePvzObject(template));
    }
    return isRecognizedCustomGridItem(typeName, levelFile);
  }

  static bool isRecognizedCustomGridItem(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    return _itemsMatchingTypeName(typeName)
        .where((item) => item.source == GridItemSource.custom)
        .any((item) => _isCustomItemRecognized(item, levelFile));
  }

  static bool isValidForLevel(String typeName, PvzLevelFile levelFile) {
    return displayTypeNameForLevel(typeName, levelFile) != null;
  }

  static String toGameTypeName(String typeName) {
    return getByTypeName(typeName)?.actualTypeName ?? typeName;
  }

  static String? displayTypeNameForLevel(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final matches = _itemsMatchingTypeName(typeName);
    if (matches.isEmpty) {
      return ReferenceRepository.instance.isValidGridItem(typeName)
          ? typeName
          : null;
    }
    for (final item in matches) {
      if (item.source != GridItemSource.custom ||
          _isCustomItemRecognized(item, levelFile)) {
        return item.actualTypeName;
      }
    }
    return null;
  }

  static bool hasConflictingExclusivePreset(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final item = _exactItem(typeName) ?? getByTypeName(typeName);
    final group = item?.exclusivePresetGroup;
    if (item == null || group == null || group.isEmpty) return false;
    if (_isCustomItemRecognized(item, levelFile)) return false;

    final groupedItems = allItems.where(
      (candidate) => candidate.exclusivePresetGroup == group,
    );
    final templateAliases = groupedItems
        .expand(_customObjectTemplates)
        .expand((template) => template.aliases ?? const <String>[])
        .toSet();
    final hasPresetObject = levelFile.objects.any(
      (object) =>
          (object.aliases ?? const <String>[]).any(templateAliases.contains),
    );
    return hasPresetObject ||
        _containsValue(
          levelFile.objects.map((object) => object.objData),
          item.actualTypeName,
        );
  }

  static bool replaceExclusivePreset(String typeName, PvzLevelFile levelFile) {
    final item = _exactItem(typeName) ?? getByTypeName(typeName);
    final group = item?.exclusivePresetGroup;
    if (item == null || group == null || group.isEmpty) return false;

    final groupedItems = allItems
        .where((candidate) => candidate.exclusivePresetGroup == group)
        .toList(growable: false);
    final aliases = groupedItems
        .expand(_customObjectTemplates)
        .expand((template) => template.aliases ?? const <String>[])
        .toSet();
    levelFile.objects.removeWhere(
      (object) => (object.aliases ?? const <String>[]).any(aliases.contains),
    );
    for (final template in _customObjectTemplates(item)) {
      levelFile.objects.add(_clonePvzObject(template));
    }
    return _isCustomItemRecognized(item, levelFile);
  }

  static int cleanupUnusedCustomGridItemTypes(PvzLevelFile levelFile) {
    var removed = 0;
    for (final item in allItems) {
      if (item.source != GridItemSource.custom) continue;
      if (_cleanupUnusedCustomGridItemType(item, levelFile)) {
        removed++;
      }
    }
    return removed;
  }

  static bool cleanupUnusedCustomGridItemType(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final item = getByTypeName(typeName);
    if (item == null || item.source != GridItemSource.custom) return false;
    return _cleanupUnusedCustomGridItemType(item, levelFile);
  }

  static List<GridItemInfo> search(String query) {
    if (query.trim().isEmpty) return allItems;
    final lower = query.toLowerCase();
    return allItems
        .where(
          (item) =>
              item.typeName.toLowerCase().contains(lower) ||
              item.actualTypeName.toLowerCase().contains(lower),
        )
        .toList();
  }

  static GridItemCategory _parseCategory(String? raw) {
    return GridItemCategory.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => GridItemCategory.scene,
    );
  }

  static GridItemTag _parseTag(String? raw) {
    return GridItemTag.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => GridItemTag.normal,
    );
  }

  static GridItemSource _parseSource(String? raw) {
    return raw == 'custom'
        ? GridItemSource.custom
        : GridItemSource.defaultSource;
  }

  static PvzObject? _parseGridItemType(dynamic raw) {
    if (raw is Map<String, dynamic>) return PvzObject.fromJson(raw);
    if (raw is Map) return PvzObject.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  static List<PvzObject> _parseCompanionObjects(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => PvzObject.fromJson(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }

  static List<PvzObject> _customObjectTemplates(GridItemInfo item) => [
    if (item.gridItemType != null) item.gridItemType!,
    ...item.companionObjects,
  ];

  static GridItemInfo? _exactItem(String typeName) =>
      allItems.firstWhereOrNull((item) => item.typeName == typeName);

  static List<GridItemInfo> _itemsMatchingTypeName(String typeName) {
    final exact = allItems.where((item) => item.typeName == typeName).toList();
    if (exact.isNotEmpty) return exact;
    final alias = buildGridAliases(typeName);
    return allItems
        .where(
          (item) =>
              item.actualTypeName == typeName ||
              item.gridItemTypeAlias == typeName ||
              buildGridAliases(item.actualTypeName) == alias,
        )
        .toList();
  }

  static bool _isCustomItemRecognized(
    GridItemInfo item,
    PvzLevelFile levelFile,
  ) {
    final templates = _customObjectTemplates(item);
    return templates.isNotEmpty &&
        templates.every(
          (template) =>
              _findMatchingTemplateObject(levelFile, template) != null ||
              _matchesBuiltInGridItemType(levelFile, template),
        );
  }

  static bool _matchesBuiltInGridItemType(
    PvzLevelFile levelFile,
    PvzObject template,
  ) {
    if (template.objClass != 'GridItemType') return false;
    final typeName = _gridItemTypeName(template);
    if (typeName == null) return false;
    // A conflicting local definition must not borrow the built-in preset art.
    if (_findObjectWithTemplateAlias(levelFile, template) != null ||
        levelFile.objects.any(
          (object) =>
              object.objClass == 'GridItemType' &&
              _gridItemTypeName(object) == typeName,
        )) {
      return false;
    }
    final builtIn = ReferenceRepository.instance.gridItemTypeForName(typeName);
    return builtIn != null &&
        const DeepCollectionEquality().equals(
          builtIn.objData,
          template.objData,
        );
  }

  static PvzObject? _findObjectWithTemplateAlias(
    PvzLevelFile levelFile,
    PvzObject template,
  ) {
    final aliases = template.aliases ?? const <String>[];
    return levelFile.objects.firstWhereOrNull(
      (object) =>
          aliases.any((alias) => object.aliases?.contains(alias) == true),
    );
  }

  static PvzObject? _findMatchingTemplateObject(
    PvzLevelFile levelFile,
    PvzObject template,
  ) {
    final object = _findObjectWithTemplateAlias(levelFile, template);
    if (object == null || object.objClass != template.objClass) return null;
    return const DeepCollectionEquality().equals(
          object.objData,
          template.objData,
        )
        ? object
        : null;
  }

  static bool _cleanupUnusedCustomGridItemType(
    GridItemInfo item,
    PvzLevelFile levelFile,
  ) {
    final aliases = _gridItemTypeAliases(item);
    final hasReference = aliases.any(
      (alias) => _containsValue(
        levelFile.objects.map((object) => object.toJson()),
        RtidParser.build(alias, 'CurrentLevel'),
      ),
    );
    if (hasReference) return false;

    var removed = false;
    levelFile.objects.removeWhere((object) {
      if (object.objClass != 'GridItemType') return false;
      final objectAliases = object.aliases ?? const <String>[];
      final shouldRemove = objectAliases.any(aliases.contains);
      removed = removed || shouldRemove;
      return shouldRemove;
    });
    return removed;
  }

  static Set<String> _gridItemTypeAliases(GridItemInfo item) {
    final aliases = <String>{
      item.gridItemTypeAlias ?? buildGridAliases(item.actualTypeName),
    };
    final templateAliases = item.gridItemType?.aliases;
    if (templateAliases != null) aliases.addAll(templateAliases);
    return aliases;
  }

  static bool _containsValue(dynamic value, String target) {
    if (value is String) return value == target;
    if (value is Iterable) {
      return value.any((entry) => _containsValue(entry, target));
    }
    if (value is Map) {
      return value.values.any((entry) => _containsValue(entry, target));
    }
    return false;
  }

  static String? _gridItemTypeName(PvzObject object) {
    final objData = object.objData;
    if (objData is Map) {
      final typeName = objData['TypeName'];
      if (typeName is String && typeName.isNotEmpty) return typeName;
    }
    return null;
  }

  static PvzObject _clonePvzObject(PvzObject object) {
    final aliases = object.aliases;
    return PvzObject(
      aliases: aliases == null ? null : List<String>.from(aliases),
      objClass: object.objClass,
      objData: jsonDecode(jsonEncode(object.objData)),
    );
  }
}
