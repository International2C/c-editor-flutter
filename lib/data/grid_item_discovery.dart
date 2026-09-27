import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';

class DiscoveredGridItem {
  const DiscoveredGridItem({
    required this.id,
    this.isDedicatedModuleItem = false,
  });

  final String id;

  /// Whether this entry comes from a dedicated grid-item module. These entries
  /// are part of the module's normal configuration rather than custom grid-item
  /// placements, so the overview must not badge them with C.
  final bool isDedicatedModuleItem;
}

class GridItemDiscovery {
  static Set<String> discoverGridItems(PvzLevelFile levelFile) {
    return discoverGridItemEntries(levelFile).map((entry) => entry.id).toSet();
  }

  static List<DiscoveredGridItem> discoverGridItemEntries(
    PvzLevelFile levelFile,
  ) {
    final items = <String, DiscoveredGridItem>{};

    void addItem(String id, {bool isDedicatedModuleItem = false}) {
      if (id.isEmpty) return;
      final clean = _cleanId(id);
      final key = '$clean|$isDedicatedModuleItem';
      items.putIfAbsent(
        key,
        () => DiscoveredGridItem(
          id: clean,
          isDedicatedModuleItem: isDedicatedModuleItem,
        ),
      );
    }

    void scan(dynamic d) {
      if (d is Map) {
        final t =
            d['TypeName'] ??
            d['GridItemType'] ??
            d['GridItemTypeName'] ??
            d['ItemType'];
        if (t is String && t.isNotEmpty) {
          final clean = _cleanId(t);
          final displayTypeName = GridItemRepository.displayTypeNameForLevel(
            clean,
            levelFile,
          );
          if (clean != 'flowerpot' && displayTypeName != null) {
            addItem(displayTypeName);
          }
        }
        for (final v in d.values) {
          scan(v);
        }
      } else if (d is List) {
        for (final e in d) {
          scan(e);
        }
      }
    }

    final gridModules = {
      'InitialGridItemProperties',
      'SpawnGravestonesWaveActionProps',
    };

    for (final obj in levelFile.objects) {
      if (gridModules.contains(obj.objClass)) {
        scan(obj.objData);
      }
      if (obj.objClass == 'SpawnRocketLandingWaveActionProps' &&
          obj.objData is Map) {
        final rocketPool = (obj.objData as Map)['RocketPool'];
        if (rocketPool is List) {
          for (final entry in rocketPool.whereType<Map>()) {
            final type = entry['Type'];
            if (type is! String || type.isEmpty) continue;
            final clean = _cleanId(type);
            final displayTypeName = GridItemRepository.displayTypeNameForLevel(
              clean,
              levelFile,
            );
            if (displayTypeName != null) {
              addItem(displayTypeName);
            }
          }
        }
      }
    }

    final smokeData = readSmokePollutionData(levelFile);
    if (smokeData != null &&
        smokeData.smokeManholeList.isNotEmpty &&
        smokeData.gridItem.isNotEmpty) {
      addItem(smokeData.gridItem);
    }

    final pipeData = readManholePipelineData(levelFile);
    if (pipeData != null && pipeData.pipelineList.isNotEmpty) {
      addItem('steam_down');
      addItem('steam_up');
    }

    final armrackData = readArmrackModuleData(levelFile);
    if (armrackData != null) {
      for (final override in armrackData.overrides) {
        for (final item in override.itemList) {
          addItem(item.type, isDedicatedModuleItem: true);
        }
      }
    }

    final lunarMineData = readLunarMineVeinModuleData(levelFile);
    if (lunarMineData != null) {
      for (final placement in lunarMineData.placements) {
        addItem(placement.typeName);
      }
    }

    final radiationMeteorData = readRadiationMeteorModuleData(levelFile);
    if (radiationMeteorData != null &&
        radiationMeteorData.spawnSchedule.isNotEmpty) {
      addItem('radiation_meteor_ore');
    }

    final gulliverData = readGulliverTunnelData(levelFile);
    if (gulliverData != null && gulliverData.tunnelPlacements.isNotEmpty) {
      addItem('gulliver_tunnel');
    }

    final moldLayout = readMoldColonyLayoutData(levelFile);
    if (moldLayout != null &&
        moldLayout.values.any((row) => row.any((value) => value != 0))) {
      addItem('fake_mold');
    }

    final ptData = readPowerTileModuleData(levelFile);
    if (ptData != null) {
      for (final tile in ptData.linkedTiles) {
        addItem('tool_powertile_${tile.group}');
      }
    }

    final energyData = readEnergyGridModuleData(levelFile);
    if (energyData != null) {
      for (final over in energyData.overrides) {
        if (over.itemList.isNotEmpty) {
          addItem('energyGrid', isDedicatedModuleItem: true);
        }
      }
    }

    final renaiData = readRenaiModuleData(levelFile);
    if (renaiData != null) {
      for (final s in renaiData.statueInfos) {
        addItem(s.typeName);
      }
      for (final s in renaiData.statueNightInfos) {
        addItem(s.typeName);
      }
    }

    final potObj = findModuleObject(levelFile, 'ZombiePotionModuleProperties');
    if (potObj != null && potObj.objData is Map) {
      final potData = ZombiePotionModulePropertiesData.fromJson(
        Map<String, dynamic>.from(potObj.objData as Map),
      );
      for (final type in potData.potionTypes) {
        addItem(type);
      }
    }

    for (final obj in levelFile.objects) {
      if (obj.objClass.contains('Dino')) {
        scan(obj.objData);
      }
      if (obj.objClass == 'ZombiePotionActionProps') {
        scan(obj.objData);
      }
      if (obj.objClass == 'ZombieAtlantisShellActionProps') {
        addItem('atlantis_shell');
      }
      if (obj.objClass == 'SpawnEagleFlagsWaveActionProps' &&
          obj.objData is Map) {
        final flags = (obj.objData as Map)['Flags'];
        if (flags is List) {
          for (final entry in flags.whereType<Map>()) {
            final type = entry['Type'];
            if (type is String && type.isNotEmpty) {
              addItem(type);
            }
          }
        }
      }
      if (obj.objClass == 'PumpkinHouseActionProps') {
        addItem('pumpkin_house');
      }
      if (obj.objClass == 'WaveActionZombieTentProps' && obj.objData is Map) {
        final tents = (obj.objData as Map)['ZombieTents'];
        if (tents is List) {
          for (final entry in tents.whereType<Map>()) {
            final type = entry['TentType'];
            if (type is String && type.isNotEmpty) {
              addItem(type);
            }
          }
        }
      }
    }

    return items.values.toList(growable: false);
  }

  static String _cleanId(String id) {
    if (id.contains('(') && id.contains('@')) {
      return LevelParser.extractAlias(id);
    }
    return id;
  }
}
