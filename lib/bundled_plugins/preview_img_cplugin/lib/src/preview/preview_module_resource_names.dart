import 'package:flutter/widgets.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';

enum PreviewModuleResourceKind {
  plant,
  zombie,
  gridItem,
  tool,
  collectable,
  creature,
  zombieCondition,
  plantCondition,
}

typedef PreviewModuleResourceName =
    String Function(PreviewModuleResourceKind kind, String id);

/// Cached initialization shared by module text and icon-grid insertions.
Future<void> loadPreviewModuleResourceNames() async {
  await Future.wait([
    ResourceNames.ensureLoaded(),
    PlantRepository().init(),
    ZombieRepository().init(),
    GridItemRepository.init(),
    ZombiePropertiesRepository.init(),
    FishTypeRepository().init(),
    ZombossMechRepository.init(),
    ZombossBattleRepository.init(),
  ]);
}

/// Resolves display-only names without changing the identifiers used by icons
/// or module data. The caller must initialize the resource repositories first.
String previewModuleResourceName(
  BuildContext context,
  PvzLevelFile levelFile,
  PreviewModuleResourceKind kind,
  String raw,
) {
  final parsed = RtidParser.parse(raw.trim());
  final alias = parsed?.alias ?? raw.trim();
  if (alias.isEmpty) return raw;

  final prefix = switch (kind) {
    PreviewModuleResourceKind.plant => 'plant_',
    PreviewModuleResourceKind.zombie => 'zombie_',
    PreviewModuleResourceKind.gridItem => 'griditem_',
    PreviewModuleResourceKind.tool => 'tool_',
    PreviewModuleResourceKind.creature => 'creature_',
    PreviewModuleResourceKind.zombieCondition => 'zombieCondition_',
    PreviewModuleResourceKind.plantCondition => 'plantCondition_',
    PreviewModuleResourceKind.collectable => '',
  };
  final localClass = switch (kind) {
    PreviewModuleResourceKind.plant => 'PlantType',
    PreviewModuleResourceKind.zombie => 'ZombieType',
    PreviewModuleResourceKind.gridItem => 'GridItemType',
    PreviewModuleResourceKind.creature => 'CreatureType',
    _ => null,
  };
  String normalize(String value) {
    // Some genuine IDs start with the localization prefix too, for example
    // zombie_towerdefend_wolf_imp. Prefer an exact catalogue/local alias before
    // treating that prefix as a display-key wrapper.
    final isCatalogId = switch (kind) {
      PreviewModuleResourceKind.plant =>
        PlantRepository().getPlantInfoById(value) != null,
      PreviewModuleResourceKind.zombie =>
        ZombieRepository().getZombieById(value) != null,
      PreviewModuleResourceKind.gridItem =>
        GridItemRepository.getByTypeName(value) != null,
      _ => false,
    };
    final isLocalAlias =
        localClass != null &&
        levelFile.objects.any(
          (object) =>
              object.objClass == localClass &&
              object.aliases?.contains(value) == true,
        );
    return isCatalogId || isLocalAlias ? value : _withoutPrefix(value, prefix);
  }

  var id = normalize(alias);
  String? customAlias;
  // A source-qualified reference must not accidentally resolve to an unrelated
  // level-local object with the same alias. Bare aliases remain supported.
  if (localClass != null &&
      (parsed == null || parsed.source == 'CurrentLevel')) {
    final visited = <String>{};
    while (visited.add(id)) {
      String? nextType;
      for (final object in levelFile.objects) {
        if (object.objClass != localClass ||
            object.aliases?.contains(id) != true) {
          continue;
        }
        final data = object.objData;
        if (data is Map && data['TypeName'] is String) {
          nextType = data['TypeName'] as String;
        }
        break;
      }
      if (nextType == null || nextType.trim().isEmpty) break;
      if (kind == PreviewModuleResourceKind.zombie) customAlias ??= alias;
      final nextAlias = RtidParser.parse(nextType)?.alias ?? nextType.trim();
      id = normalize(nextAlias);
    }
  }

  String? translated(Iterable<String> keys) {
    for (final key in keys.toSet()) {
      final name = ResourceNames.lookup(context, key);
      if (name.isNotEmpty && name != key) return name;
    }
    return null;
  }

  String? toolName(String value) {
    final toolId = value.startsWith('tool_') ? value : 'tool_$value';
    final localized = translated([toolId]);
    if (localized != null) return localized;
    final tool = ToolRepository.get(toolId);
    return tool == null ? null : ToolRepository.localizedName(context, tool.id);
  }

  String? name;
  switch (kind) {
    case PreviewModuleResourceKind.zombieCondition:
      name = translated(['zombieCondition_$id']);
      break;
    case PreviewModuleResourceKind.plantCondition:
      name = translated(['plantCondition_$id', 'zombieCondition_$id']);
      break;
    case PreviewModuleResourceKind.plant:
      // Conveyor belts and seed rain may store tool packets as PlantType.
      name = id.startsWith('tool_')
          ? toolName(id)
          : translated([PlantRepository().getName(id), 'plant_$id']);
      break;
    case PreviewModuleResourceKind.zombie:
      final repo = ZombieRepository();
      final type = ZombiePropertiesRepository.getTypeNameByAlias(id);
      final keys = <String>[repo.getName(id), repo.getName(type)];
      // The catalogue exposes some game aliases under their editor IDs.
      for (final zombie in repo.allZombies) {
        if (repo.buildZombieAliases(zombie.id) == id ||
            repo.buildZombieAliases(zombie.id) == type) {
          keys.add(zombie.name);
        }
      }
      final mech =
          ZombossMechRepository.getBase(id) ??
          ZombossMechRepository.findBaseForVariation(id) ??
          ZombossMechRepository.findBaseForVariation(type);
      final boss =
          ZombossBattleRepository.getBase(id) ??
          ZombossBattleRepository.findBaseForVariation(id) ??
          ZombossBattleRepository.findBaseForVariation(type);
      if (mech != null) keys.add(mech.id);
      if (boss != null) keys.add(boss.id);
      name = translated(keys);
      if (name != null && customAlias != null && name != customAlias) {
        name = '$name ($customAlias)';
      }
      break;
    case PreviewModuleResourceKind.gridItem:
      final item = GridItemRepository.getByTypeName(id);
      // Never use plant_$id here: cosmoss is also the Moss Tile grid item.
      name = translated([
        if (item != null) 'griditem_${item.typeName}',
        if (item != null) 'griditem_${item.actualTypeName}',
        'griditem_$id',
        if (id.startsWith('Armrack')) 'armrack_$id',
      ]);
      if (name == null && id.startsWith('tool_')) name = toolName(id);
      break;
    case PreviewModuleResourceKind.tool:
      name = toolName(id);
      break;
    case PreviewModuleResourceKind.collectable:
      final key = switch (id.toLowerCase()) {
        'plantfood' || 'tool_plantfood' => 'tool_plantfood',
        'sun' || 'sun_large' => 'sun_large',
        _ => id,
      };
      name = translated([key]);
      if (name == null && id.toLowerCase() == 'goldcoin') {
        name = AppLocalizations.of(context)?.pickupCollectableLootGoldCoin;
      }
      break;
    case PreviewModuleResourceKind.creature:
      final fishRepo = FishTypeRepository();
      final fish =
          fishRepo.getFishByAlias(id) ?? fishRepo.getFishByTypeName(id);
      final fishAlias = FishInfo.normalizeFishAlias(fish?.alias ?? id);
      name = translated([
        'creature_$fishAlias',
        'dinoType_${_withoutPrefix(id, 'dinoType_')}',
      ]);
      break;
  }
  // Match the existing module display fallback: unwrap unknown RTIDs, but do
  // not expose a fabricated key such as plant_my_custom_plant.
  return name ?? (parsed == null ? raw : alias);
}

String _withoutPrefix(String value, String prefix) =>
    prefix.isNotEmpty && value.startsWith(prefix)
    ? value.substring(prefix.length)
    : value;
