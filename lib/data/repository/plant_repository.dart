import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/tag_assets.dart';
import 'package:c_editor/l10n/app_localizations.dart';

const String _kToBeContinuedIconPath =
    'assets/images/others/to_be_continued.webp';

enum PlantCategory { quality, role, attribute, world, other, collection }

extension PlantCategoryExtension on PlantCategory {
  String getLabel(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    switch (this) {
      case PlantCategory.quality:
        return s.plantCategoryQuality;
      case PlantCategory.role:
        return s.plantCategoryRole;
      case PlantCategory.attribute:
        return s.plantCategoryAttribute;
      case PlantCategory.world:
        return s.plantCategoryWorld;
      case PlantCategory.other:
        return s.plantCategoryOther;
      case PlantCategory.collection:
        return s.plantCategoryCollection;
    }
  }
}

enum PlantTag {
  all,
  white,
  green,
  blue,
  purple,
  orange,
  red,
  support,
  ranger,
  sun_producer,
  defence,
  vanguard,
  trapper,
  fire,
  ice,
  magic,
  poison,
  electric,
  physical,
  worldTutorial,
  worldEgypt,
  worldPirate,
  worldWildWest,
  worldKongfu,
  worldFuture,
  worldDarkAges,
  worldBeach,
  worldIceage,
  worldSkycity,
  worldLostCity,
  worldEighties,
  worldDino,
  worldModern,
  worldSteam,
  worldRenai,
  worldHeian,
  worldAtlantis,
  worldMoon,
  worldFairytale,
  worldZcorp,
  worldMausoleum,
  original,
  parallel,
  special,
  hidden,
  tier4,
  chinese,
  international,
}

extension PlantTagExtension on PlantTag {
  String getLabel(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    switch (this) {
      case PlantTag.all:
        return s.plantTagAll;
      case PlantTag.white:
        return s.plantTagWhite;
      case PlantTag.green:
        return s.plantTagGreen;
      case PlantTag.blue:
        return s.plantTagBlue;
      case PlantTag.purple:
        return s.plantTagPurple;
      case PlantTag.orange:
        return s.plantTagOrange;
      case PlantTag.red:
        return s.plantTagRed;
      case PlantTag.support:
        return s.plantTagSupport;
      case PlantTag.ranger:
        return s.plantTagRanger;
      case PlantTag.sun_producer:
        return s.plantTagSunProducer;
      case PlantTag.defence:
        return s.plantTagDefence;
      case PlantTag.vanguard:
        return s.plantTagVanguard;
      case PlantTag.trapper:
        return s.plantTagTrapper;
      case PlantTag.fire:
        return s.plantTagFire;
      case PlantTag.ice:
        return s.plantTagIce;
      case PlantTag.magic:
        return s.plantTagMagic;
      case PlantTag.poison:
        return s.plantTagPoison;
      case PlantTag.electric:
        return s.plantTagElectric;
      case PlantTag.physical:
        return s.plantTagPhysical;
      case PlantTag.worldTutorial:
        return s.plantTagWorldTutorial;
      case PlantTag.worldEgypt:
        return s.plantTagWorldEgypt;
      case PlantTag.worldPirate:
        return s.plantTagWorldPirate;
      case PlantTag.worldWildWest:
        return s.plantTagWorldWildWest;
      case PlantTag.worldKongfu:
        return s.plantTagWorldKongfu;
      case PlantTag.worldFuture:
        return s.plantTagWorldFuture;
      case PlantTag.worldDarkAges:
        return s.plantTagWorldDarkAges;
      case PlantTag.worldBeach:
        return s.plantTagWorldBeach;
      case PlantTag.worldIceage:
        return s.plantTagWorldIceage;
      case PlantTag.worldSkycity:
        return s.plantTagWorldSkycity;
      case PlantTag.worldLostCity:
        return s.plantTagWorldLostCity;
      case PlantTag.worldEighties:
        return s.plantTagWorldEighties;
      case PlantTag.worldDino:
        return s.plantTagWorldDino;
      case PlantTag.worldModern:
        return s.plantTagWorldModern;
      case PlantTag.worldSteam:
        return s.plantTagWorldSteam;
      case PlantTag.worldRenai:
        return s.plantTagWorldRenai;
      case PlantTag.worldHeian:
        return s.plantTagWorldHeian;
      case PlantTag.worldAtlantis:
        return s.plantTagWorldAtlantis;
      case PlantTag.worldMoon:
        return s.plantTagWorldMoon;
      case PlantTag.worldFairytale:
        return s.plantTagWorldFairytale;
      case PlantTag.worldZcorp:
        return s.plantTagWorldZcorp;
      case PlantTag.worldMausoleum:
        return s.plantTagWorldMausoleum;
      case PlantTag.original:
        return s.plantTagOriginal;
      case PlantTag.parallel:
        return s.plantTagParallel;
      case PlantTag.special:
        return s.plantTagSpecial;
      case PlantTag.hidden:
        return s.plantTagHidden;
      case PlantTag.tier4:
        return s.plantTagTier4;
      case PlantTag.international:
        return s.plantTagInternational;
      case PlantTag.chinese:
        return s.plantTagChinese;
    }
  }

  String? get iconAssetPath {
    final fileName = _iconFileName;
    if (fileName == null) return null;
    switch (category) {
      case PlantCategory.quality:
        return TagAssets.plantRarity(fileName);
      case PlantCategory.role:
        return TagAssets.plantRole(fileName);
      case PlantCategory.attribute:
        return TagAssets.attribute(fileName);
      default:
        return null;
    }
  }

  String? get _iconFileName {
    switch (this) {
      case PlantTag.white:
        return 'Plant_White.webp';
      case PlantTag.green:
        return 'Plant_Green.webp';
      case PlantTag.blue:
        return 'Plant_Blue.webp';
      case PlantTag.purple:
        return 'Plant_Purple.webp';
      case PlantTag.orange:
        return 'Plant_Orange.webp';
      case PlantTag.red:
        return 'Plant_Red.png';
      case PlantTag.support:
        return 'Plant_Assist.webp';
      case PlantTag.ranger:
        return 'Plant_Remote.webp';
      case PlantTag.sun_producer:
        return 'Plant_Productor.webp';
      case PlantTag.defence:
        return 'Plant_Defence.webp';
      case PlantTag.vanguard:
        return 'Plant_Vanguard.webp';
      case PlantTag.trapper:
        return 'Plant_Trapper.webp';
      case PlantTag.fire:
        return 'Fire.webp';
      case PlantTag.ice:
        return 'Ice.webp';
      case PlantTag.magic:
        return 'Magic.webp';
      case PlantTag.poison:
        return 'Poison.webp';
      case PlantTag.electric:
        return 'Electric.webp';
      case PlantTag.physical:
        return 'Physics.webp';
      default:
        return null;
    }
  }

  PlantCategory get category {
    switch (this) {
      case PlantTag.all:
      case PlantTag.white:
      case PlantTag.green:
      case PlantTag.blue:
      case PlantTag.purple:
      case PlantTag.orange:
      case PlantTag.red:
        return PlantCategory.quality;
      case PlantTag.support:
      case PlantTag.ranger:
      case PlantTag.sun_producer:
      case PlantTag.defence:
      case PlantTag.vanguard:
      case PlantTag.trapper:
        return PlantCategory.role;
      case PlantTag.fire:
      case PlantTag.ice:
      case PlantTag.magic:
      case PlantTag.poison:
      case PlantTag.electric:
      case PlantTag.physical:
        return PlantCategory.attribute;
      case PlantTag.worldTutorial:
      case PlantTag.worldEgypt:
      case PlantTag.worldPirate:
      case PlantTag.worldWildWest:
      case PlantTag.worldKongfu:
      case PlantTag.worldFuture:
      case PlantTag.worldDarkAges:
      case PlantTag.worldBeach:
      case PlantTag.worldIceage:
      case PlantTag.worldSkycity:
      case PlantTag.worldLostCity:
      case PlantTag.worldEighties:
      case PlantTag.worldDino:
      case PlantTag.worldModern:
      case PlantTag.worldSteam:
      case PlantTag.worldRenai:
      case PlantTag.worldHeian:
      case PlantTag.worldAtlantis:
      case PlantTag.worldMoon:
      case PlantTag.worldFairytale:
      case PlantTag.worldZcorp:
      case PlantTag.worldMausoleum:
        return PlantCategory.world;
      case PlantTag.original:
      case PlantTag.parallel:
      case PlantTag.special:
      case PlantTag.hidden:
      case PlantTag.tier4:
      case PlantTag.international:
      case PlantTag.chinese:
        return PlantCategory.other;
    }
  }
}

class PlantInfo {
  final String id;
  final String name;
  final List<PlantTag> tags;
  final String? icon;

  /// Gameplay tags from `PlantTypes.json` (`objdata.Attribute.Tags`).
  /// These are intentionally separate from the editor's display/filter tags.
  final Set<String> attributeTags;

  /// Internal tags (e.g. _internal_no42, _internal_mausoleum) used for module gating.
  final List<String> internalTags;

  PlantInfo({
    required this.id,
    required this.name,
    required this.tags,
    this.icon,
    this.internalTags = const [],
    Set<String> attributeTags = const <String>{},
  }) : attributeTags = Set<String>.unmodifiable(attributeTags);

  bool hasInternalTag(String tag) => internalTags.contains(tag);

  bool hasAttributeTag(String tag) => attributeTags.contains(tag.toLowerCase());

  String? get iconAssetPath {
    if (id == 'coming_soon') return _kToBeContinuedIconPath;
    if (icon == null) return null;
    final path = icon!;
    return 'assets/images/plants/$path';
  }
}

class PlantRepository {
  static final PlantRepository _instance = PlantRepository._internal();
  factory PlantRepository() => _instance;
  PlantRepository._internal();

  List<PlantInfo> _allPlants = [];
  final List<String> _favoriteIds = [];
  bool _isLoaded = false;
  final Set<String> _uiConfiguredAliases = {};
  final Map<PlantTag, List<String>> _worldPlantOrder = {};
  final Map<String, Set<String>> _attributeTagsByAlias = {};

  List<PlantInfo> get allPlants => _allPlants;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoaded => _isLoaded;

  static PlantTag? _parseTagString(String tagStr) {
    if (tagStr.startsWith('_internal_')) return null;
    final normalizedTag = tagStr.replaceAll('_', '').toLowerCase();
    for (final tag in PlantTag.values) {
      if (tag == PlantTag.all) continue;
      if (tag.name.replaceAll('_', '').toLowerCase() == normalizedTag) {
        return tag;
      }
    }
    return null;
  }

  Future<Map<String, List<PlantTag>>> _loadWorldAssignments() async {
    final byPlantId = <String, List<PlantTag>>{};
    _worldPlantOrder.clear();
    try {
      final jsonString = await loadJsonString(
        'assets/resources/PlantWorldAssignments.json',
      );
      final map = json.decode(jsonString) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final worldTag = _parseTagString(entry.key);
        if (worldTag == null) continue;
        final orderedIds = <String>[];
        for (final rawId in (entry.value as List<dynamic>)) {
          final id = rawId as String;
          orderedIds.add(id);
          byPlantId.putIfAbsent(id, () => []).add(worldTag);
        }
        _worldPlantOrder[worldTag] = orderedIds;
      }
    } catch (e) {
      debugPrint('Error loading plant world assignments: $e');
    }
    return byPlantId;
  }

  Future<void> _loadAttributeTags() async {
    _attributeTagsByAlias.clear();
    try {
      final jsonString = await loadJsonString(
        'assets/reference/PlantTypes.json',
      );
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final objects = decoded['objects'] as List<dynamic>? ?? const [];
      for (final rawObject in objects) {
        if (rawObject is! Map) continue;
        final objData = rawObject['objdata'];
        if (objData is! Map) continue;
        final attribute = objData['Attribute'];
        if (attribute is! Map) continue;
        final rawTags = attribute['Tags'];
        if (rawTags is! List) continue;
        final tags = rawTags
            .whereType<String>()
            .map((tag) => tag.toLowerCase())
            .toSet();
        if (tags.isEmpty) continue;

        final aliases = <String>{};
        final typeName = objData['TypeName'];
        if (typeName is String && typeName.isNotEmpty) aliases.add(typeName);
        final rawAliases = rawObject['aliases'];
        if (rawAliases is List) {
          aliases.addAll(
            rawAliases.whereType<String>().where((alias) => alias.isNotEmpty),
          );
        }
        for (final alias in aliases) {
          for (final key in {alias, alias.toLowerCase()}) {
            _attributeTagsByAlias
                .putIfAbsent(key, () => <String>{})
                .addAll(tags);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading plant attribute tags: $e');
    }
  }

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFavorites();
    try {
      final worldAssignments = await _loadWorldAssignments();
      await _loadAttributeTags();
      final jsonString = await loadJsonString('assets/resources/Plants.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final seenIds = <String>{};
      _allPlants = [];
      for (final jsonItem in jsonList) {
        final id = jsonItem['id'] as String;
        if (seenIds.contains(id)) continue;
        seenIds.add(id);

        final name = jsonItem['name'] as String;
        final icon = jsonItem['icon'] as String?;
        final tagsList = (jsonItem['tags'] as List<dynamic>?)?.cast<String>();

        _uiConfiguredAliases.add(id);

        final internalTags = <String>[];
        final tagSet = <PlantTag>{};
        for (final tagStr in tagsList ?? const <String>[]) {
          if (tagStr.startsWith('_internal_')) {
            internalTags.add(tagStr);
            continue;
          }
          final tag = _parseTagString(tagStr);
          if (tag != null) tagSet.add(tag);
        }
        for (final tag in worldAssignments[id] ?? const <PlantTag>[]) {
          tagSet.add(tag);
        }

        final tags = tagSet.toList();
        _allPlants.add(
          PlantInfo(
            id: id,
            name: name,
            icon: icon,
            tags: tags.isEmpty ? [PlantTag.all] : tags,
            internalTags: internalTags,
            attributeTags:
                _attributeTagsByAlias[id] ??
                _attributeTagsByAlias[id.toLowerCase()] ??
                const <String>{},
          ),
        );
      }

      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading plants: $e');
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_plants');
    if (favorites != null) {
      _favoriteIds.clear();
      _favoriteIds.addAll(favorites);
    }
  }

  /// Returns the name key for localization (e.g. "plant_sunflower").
  /// Use ResourceNames.lookup(context, getName(id)) for display.
  String getName(String id) {
    for (final p in _allPlants) {
      if (p.id == id) return p.name;
    }
    return 'plant_$id';
  }

  PlantInfo? getPlantInfoById(String id) {
    try {
      return _allPlants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Checks the authoritative gameplay attributes, accepting either a plant's
  /// TypeName or any alias declared by `PlantTypes.json`.
  bool hasPlantAttributeTag(String id, String tag) {
    final tags =
        _attributeTagsByAlias[id] ?? _attributeTagsByAlias[id.toLowerCase()];
    return tags?.contains(tag.toLowerCase()) ?? false;
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  bool _hasWorldTag(PlantInfo plant) =>
      plant.tags.any((tag) => tag.category == PlantCategory.world);

  void _sortByWorldTag(List<PlantInfo> plants, PlantTag worldTag) {
    final order = _worldPlantOrder[worldTag];
    if (order == null || order.isEmpty) return;

    final rank = <String, int>{
      for (var i = 0; i < order.length; i++) order[i]: i,
    };
    plants.sort((a, b) {
      final ai = rank[a.id] ?? 1 << 30;
      final bi = rank[b.id] ?? 1 << 30;
      if (ai != bi) return ai.compareTo(bi);
      return a.id.compareTo(b.id);
    });
  }

  List<PlantInfo> _finalizePlantList(
    List<PlantInfo> plants,
    PlantTag? tag,
    String query,
  ) {
    if (tag != null &&
        tag != PlantTag.all &&
        tag.category == PlantCategory.world) {
      _sortByWorldTag(plants, tag);
    }

    if (query.trim().isEmpty) return plants;
    final lower = query.toLowerCase();
    return plants
        .where(
          (p) =>
              p.id.toLowerCase().contains(lower) ||
              p.name.toLowerCase().contains(lower),
        )
        .toList();
  }

  List<PlantInfo> search(String query, PlantTag? tag, PlantCategory category) {
    if (!_isLoaded) return [];
    final List<PlantInfo> baseList;
    if (category == PlantCategory.collection) {
      baseList = _allPlants.where((p) => _favoriteIds.contains(p.id)).toList();
    } else if (tag != null && tag != PlantTag.all) {
      baseList = _allPlants.where((p) => p.tags.contains(tag)).toList();
    } else if (category == PlantCategory.world) {
      baseList = _allPlants.where(_hasWorldTag).toList();
    } else {
      baseList = _allPlants;
    }

    return _finalizePlantList(baseList, tag, query);
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_plants', _favoriteIds);
  }
}
