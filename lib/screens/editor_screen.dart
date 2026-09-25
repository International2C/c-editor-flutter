import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/autosave_settings_dialog.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/data/level_module_order_utils.dart';
import 'package:c_editor/data/cowboy_minigame_utils.dart';
import 'package:c_editor/data/zomboss_eighties_speaker_presets.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/module_instance_display_name.dart';
import 'package:c_editor/data/module_instance_utils.dart';
import 'package:c_editor/data/mold_colony_module_utils.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/models/custom_stage_preset.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_ui_host.dart';
import 'package:c_editor/screens/level_overview/level_overview.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/fish_properties_repository.dart';
import 'package:c_editor/screens/editor/basic_info_screen.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:c_editor/screens/editor/others/custom_zombie_properties_screen.dart';
import 'package:c_editor/screens/editor/others/custom_fish_properties_screen.dart';
import 'package:c_editor/screens/editor/others/unknown_module_screen.dart';
import 'package:c_editor/screens/editor/modules/star_challenge_screen.dart';
import 'package:c_editor/screens/editor/modules/max_sun_module_screen.dart';
import 'package:c_editor/screens/editor/modules/moon_expert_module_screen.dart';
import 'package:c_editor/screens/editor/modules/statue_maze_module_screen.dart';
import 'package:c_editor/screens/editor/modules/camel_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/oak_train_screen.dart';
import 'package:c_editor/screens/editor/modules/rift_theme_module_screen.dart';
import 'package:c_editor/screens/editor/modules/bowling_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/death_hole_module_screen.dart';
import 'package:c_editor/screens/editor/modules/increased_cost_module_screen.dart';
import 'package:c_editor/screens/editor/modules/pirate_plank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/railcart_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/mechanism_plank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_rain_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/conveyor_seedbank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/sun_dropper_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/moon_life_support_system_screen.dart';
import 'package:c_editor/screens/editor/modules/lunar_terminal_module_screen.dart';
import 'package:c_editor/screens/editor/modules/level_powerup_module_screen.dart';
import 'package:c_editor/screens/editor/modules/lunar_mine_vein_module_screen.dart';
import 'package:c_editor/screens/editor/modules/radiation_meteor_module_screen.dart';
import 'package:c_editor/screens/editor/modules/gladiator_row_module_screen.dart';
import 'package:c_editor/screens/editor/modules/witch_module_properties_screen.dart';
import 'package:c_editor/data/final_stage_time_limited_module_utils.dart';
import 'package:c_editor/screens/editor/modules/starting_plantfood_module_screen.dart';
import 'package:c_editor/screens/editor/modules/tide_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/zombie_move_fast_module_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_settings_screen.dart';
import 'package:c_editor/screens/editor/modules/last_stand_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/cowboy_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/intro_single_handed_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/initial_plant_entry_screen.dart';
import 'package:c_editor/screens/editor/modules/initial_plant_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/initial_zombie_entry_screen.dart';
import 'package:c_editor/screens/editor/modules/initial_grid_item_entry_screen.dart';
import 'package:c_editor/screens/editor/modules/pickup_collectable_tutorial_screen.dart';
import 'package:c_editor/screens/editor/modules/zombie_sun_drop_module_screen.dart';
import 'package:c_editor/screens/editor/modules/power_tile_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/protect_grid_item_challenge_screen.dart';
import 'package:c_editor/screens/editor/modules/mold_colony_challenge_screen.dart';
import 'package:c_editor/screens/editor/modules/protect_plant_challenge_screen.dart';
import 'package:c_editor/screens/editor/modules/roof_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/rain_dark_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/bomb_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/bronze_module_screen.dart';
import 'package:c_editor/screens/editor/modules/armrack_module_screen.dart';
import 'package:c_editor/screens/editor/modules/energy_grid_module_screen.dart';
import 'package:c_editor/screens/editor/modules/sun_bomb_challenge_screen.dart';
import 'package:c_editor/screens/editor/modules/war_mist_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/zombie_potion_module_screen.dart';
import 'package:c_editor/screens/editor/modules/air_drop_ship_module_screen.dart';
import 'package:c_editor/screens/editor/modules/sperm_whale_module_screen.dart';
import 'package:c_editor/screens/editor/modules/glacier_module_screen.dart';
import 'package:c_editor/screens/editor/modules/heian_wind_module_screen.dart';
import 'package:c_editor/screens/editor/modules/renai_module_screen.dart';
import 'package:c_editor/screens/editor/modules/smoke_pollution_module_screen.dart';
import 'package:c_editor/screens/editor/modules/penny_classroom_module_screen.dart';
import 'package:c_editor/screens/editor/modules/manhole_pipeline_module_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_module_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_module_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_wave_screen.dart';
import 'package:c_editor/screens/editor/modules/lawn_mower_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/tunnel_defend_module_screen.dart';
import 'package:c_editor/screens/editor/modules/gulliver_tunnel_module_screen.dart';
import 'package:c_editor/screens/editor/modules/zombie_rush_module_screen.dart';
import 'package:c_editor/screens/editor/modules/pvz1_copycats_module_screen.dart';
import 'package:c_editor/screens/editor/modules/pvz1_seeing_stars_module_screen.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/screens/editor/modules/pvz1_passage_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/izombie_tab.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:c_editor/screens/editor/tabs/single_handed_tab.dart';
import 'package:c_editor/screens/editor/tabs/vase_breaker_tab.dart';
import 'package:c_editor/screens/editor/tabs/zomboss_battle_tab.dart';
import 'package:c_editor/screens/editor/tabs/zomboss_mech_battle_tab.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/screens/editor/tabs/wave_generator_tab.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/screens/editor/events/invalid_event_screen.dart';
import 'package:c_editor/screens/editor/events/beach_stage_event_screen.dart';
import 'package:c_editor/screens/editor/events/black_hole_event_screen.dart';
import 'package:c_editor/screens/editor/events/dino_event_screen.dart';
import 'package:c_editor/screens/editor/events/dino_run_event_screen.dart';
import 'package:c_editor/screens/editor/events/dino_tread_event_screen.dart';
import 'package:c_editor/screens/editor/events/fairy_tale_fog_event_screen.dart';
import 'package:c_editor/screens/editor/events/fairy_tale_wind_event_screen.dart';
import 'package:c_editor/screens/editor/events/frost_wind_event_screen.dart';
import 'package:c_editor/screens/editor/events/grid_item_spawn_event_screen.dart';
import 'package:c_editor/screens/editor/events/magic_mirror_event_screen.dart';
import 'package:c_editor/screens/editor/events/modify_conveyor_event_screen.dart';
import 'package:c_editor/screens/editor/events/modern_portals_event_screen.dart';
import 'package:c_editor/screens/editor/events/parachute_rain_event_screen.dart';
import 'package:c_editor/screens/editor/events/raiding_party_event_screen.dart';
import 'package:c_editor/screens/editor/events/barrel_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/school_bus_event_screen.dart';
import 'package:c_editor/screens/editor/events/hamster_zombie_event_screen.dart';
import 'package:c_editor/screens/editor/events/bungee_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/thunder_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/tide_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/zombie_fish_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/spawn_grave_stones_event_screen.dart';
import 'package:c_editor/screens/editor/events/storm_event_screen.dart';
import 'package:c_editor/screens/editor/events/tidal_change_event_screen.dart';
import 'package:c_editor/screens/editor/events/zombie_potion_event_screen.dart';
import 'package:c_editor/screens/editor/events/shell_event_screen.dart';
import 'package:c_editor/screens/editor/events/pumpkin_house_event_screen.dart';
import 'package:c_editor/screens/editor/events/eagle_standard_event_screen.dart';
import 'package:c_editor/screens/editor/events/zombie_tent_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/rocket_landing_event_screen.dart';
import 'package:c_editor/screens/editor/events/gravity_generator_event_screen.dart';
import 'package:c_editor/screens/editor/events/jittered_event_screen.dart';
import 'package:c_editor/screens/editor/events/ground_spawn_event_screen.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/screens/select/tool_selection_screen.dart';
import 'package:c_editor/screens/select/stage_selection_screen.dart';
import 'package:c_editor/screens/select/stage_base_selection_screen.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/models/stage_catalog.dart';
import 'package:c_editor/screens/editor/others/custom_stage_properties_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/utils/3rdParty/pyvz2/pyvz2_rton_codec.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';

typedef _EditorTopTabEntry = ({
  EditorTabType type,
  String? moduleRtid,
  int instanceIndex,
  int instanceCount,
});

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.onBack,
    required this.onRegisterBackHandler,
    required this.onLanguageTap,
  });

  final VoidCallback onBack;
  final void Function(Future<bool> Function()? handler) onRegisterBackHandler;
  final void Function(BuildContext context) onLanguageTap;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  TabController? _tabController;

  EditorCubit get _ec => context.read<EditorCubit>();

  String get _selectionStateBucketId {
    final filePath = _ec.filePath;
    if (filePath.isNotEmpty) return 'level:$filePath';
    return 'level:${_ec.fileName}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onRegisterBackHandler(_onEditorBackRequested);
    });
  }

  @override
  void dispose() {
    widget.onRegisterBackHandler(null);
    super.dispose();
  }

  /// Shared by AppBar back and the app PopScope / Escape leave path.
  /// Closes Overview / other modals before leaving the editor.
  Future<bool> _onEditorBackRequested() async {
    if (EscapeOverride.tryHandle?.call() == true) return false;
    if (ModalGate.tryAbsorb()) return false;
    if (popRouteAbove(context)) return false;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      return false;
    }
    if (context.read<EditorCubit>().state.hasChanges) {
      if (context.read<SettingsCubit>().state.autosave) {
        await _save();
        return true;
      }
      return await _confirmLeave();
    }
    return true;
  }

  Future<void> _leaveEditorIfAllowed() async {
    final leave = await _onEditorBackRequested();
    if (leave && mounted) widget.onBack();
  }

  static const _internalTagToModule = <String, String>{
    '_internal_copycats': 'PVZ1CopycatsModuleProperties',
  };

  Set<String> _levelModuleObjClasses() {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return {};
    final levelDef = _ec.state.parsedData!.levelDef;
    if (levelDef == null) return {};
    final objectMap = _ec.state.parsedData!.objectMap;
    final set = <String>{};
    for (final rtid in levelDef.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      if (info.source == 'CurrentLevel') {
        final obj = objectMap[info.alias];
        if (obj != null) set.add(obj.objClass);
      } else if (info.source == 'LevelModules') {
        set.add(info.alias);
      }
    }
    return set;
  }

  void _collectPlantIdsFromDynamic(dynamic data, Set<String> out) {
    if (data is Map) {
      for (final entry in data.entries) {
        final k = entry.key as String;
        final v = entry.value;
        if (k == 'PresetPlantList' ||
            k == 'PlantWhiteList' ||
            k == 'PlantBlackList') {
          if (v is List) {
            for (final e in v) {
              if (e is String && e.isNotEmpty) out.add(e);
            }
          }
        } else if (k == 'PlantMap' && v is Map) {
          for (final key in v.keys) {
            if (key is String && key.isNotEmpty) out.add(key);
          }
        } else if (k == 'InitialPlantList' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final pt = e['PlantType'];
              if (pt is String && pt.isNotEmpty) out.add(pt);
            }
          }
        } else if ((k == 'InitialPlantPlacements' || k == 'Placements') &&
            v is List) {
          for (final e in v) {
            if (e is Map) {
              final tn = e['TypeName'];
              if (tn is String && tn.isNotEmpty) out.add(tn);
            }
          }
        } else if (k == 'Plants' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final pt = e['PlantType'];
              if (pt is String && pt.isNotEmpty) out.add(pt);
              final pts = e['PlantTypes'];
              if (pts is List) {
                for (final p in pts) {
                  if (p is String && p.isNotEmpty) out.add(p);
                }
              }
            }
          }
        } else if (k == 'Vases' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final ptn = e['PlantTypeName'];
              if (ptn is String && ptn.isNotEmpty) out.add(ptn);
            }
          }
        } else if (k == 'SeedRains' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final ptn = e['PlantTypeName'];
              if (ptn is String && ptn.isNotEmpty) out.add(ptn);
            }
          }
        } else if (k == 'SpawnPlantName') {
          if (v is List) {
            for (final p in v) {
              if (p is String && p.isNotEmpty) out.add(p);
            }
          } else if (v is String && v.isNotEmpty) {
            out.add(v);
          }
        } else if ((k == 'PlantTypeName' || k == 'MatchTypeName') &&
            v is String &&
            v.isNotEmpty) {
          out.add(v);
        }
        _collectPlantIdsFromDynamic(v, out);
      }
    } else if (data is List) {
      for (final e in data) {
        _collectPlantIdsFromDynamic(e, out);
      }
    }
  }

  Set<String> _collectPlantIdsInLevel() {
    if (_ec.state.levelFile == null) return {};
    final out = <String>{};
    for (final obj in _ec.state.levelFile!.objects) {
      final data = obj.objData;
      if (data is Map<String, dynamic>) {
        _collectPlantIdsFromDynamic(data, out);
      }
    }
    return out;
  }

  /// Returns map: module objClass -> list of plant IDs that need this module but it's missing.
  Map<String, List<String>> _getMissingModuleWarnings() {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return {};
    final levelModules = _levelModuleObjClasses();
    final plantIds = _collectPlantIdsInLevel();
    final repo = PlantRepository();
    final warnings = <String, Set<String>>{};
    for (final plantId in plantIds) {
      final info = repo.getPlantInfoById(plantId);
      if (info == null) continue;
      for (final entry in _internalTagToModule.entries) {
        if (!info.hasInternalTag(entry.key)) continue;
        final moduleClass = entry.value;
        if (levelModules.contains(moduleClass)) continue;
        warnings.putIfAbsent(moduleClass, () => {}).add(plantId);
      }
    }
    return warnings.map((k, v) => MapEntry(k, v.toList()..sort()));
  }

  List<ModuleMetadata> _calculateMissingModules() {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) {
      return const [];
    }
    final existingClasses = <String>{
      ..._ec.state.levelFile!.objects.map((o) => o.objClass),
      ...?_ec.state.parsedData!.levelDef?.modules.map((rtid) {
        final info = RtidParser.parse(rtid);
        if (info == null) return '';
        if (info.source == 'CurrentLevel') {
          return _ec.state.parsedData!.objectMap[info.alias]?.objClass ?? '';
        }
        return ReferenceRepository.instance.getObjClass(info.alias) ?? '';
      }),
    }.where((e) => e.isNotEmpty).toSet();

    final isVaseBreaker =
        existingClasses.contains('VaseBreakerPresetProperties') ||
        existingClasses.contains('VaseBreakerArcadeModuleProperties') ||
        existingClasses.contains('VaseBreakerFlowModuleProperties');
    final isZombossMechBattle =
        existingClasses.contains('ZombossBattleModuleProperties') ||
        existingClasses.contains('ZombossBattleIntroProperties');
    final isZombossBattle = existingClasses.contains(
      'ZombossLastStandMinigameProperties',
    );
    final isLastStand = existingClasses.contains('LastStandMinigameProperties');
    final isCowboyMinigame = existingClasses.contains(
      'CowboyMinigameProperties',
    );
    final isSingleHanded = existingClasses.contains('SingleHandedProperties');
    final isSingleHandedTutorial = existingClasses.contains(
      'IntroSingleHandedProperties',
    );
    final isEvilDave = existingClasses.contains('EvilDaveProperties');

    final missingList = <String>[];
    if (!existingClasses.contains('CustomLevelModuleProperties')) {
      missingList.add('CustomLevelModuleProperties');
    }
    if (!existingClasses.contains('ZombiesAteYourBrainsProperties')) {
      if (!isEvilDave) missingList.add('ZombiesAteYourBrainsProperties');
    }
    if (!existingClasses.contains('ZombiesDeadWinConProperties') &&
        !existingClasses.contains('BronzeDeadWinConProperties')) {
      if (!isEvilDave &&
          !isZombossMechBattle &&
          !isZombossBattle &&
          !existingClasses.contains('PVZ1SeeingStarsModuleProperties')) {
        missingList.add('ZombiesDeadWinConProperties');
      }
    }
    if (!existingClasses.contains('StandardLevelIntroProperties')) {
      if (!isVaseBreaker &&
          !isLastStand &&
          !isCowboyMinigame &&
          !isSingleHanded &&
          !isSingleHandedTutorial &&
          !isZombossMechBattle &&
          !isZombossBattle &&
          !existingClasses.contains('CamelMinigameProperties')) {
        missingList.add('StandardLevelIntroProperties');
      }
    }
    if (isVaseBreaker) {
      if (!existingClasses.contains('VaseBreakerPresetProperties')) {
        missingList.add('VaseBreakerPresetProperties');
      }
      if (!existingClasses.contains('VaseBreakerArcadeModuleProperties')) {
        missingList.add('VaseBreakerArcadeModuleProperties');
      }
      if (!existingClasses.contains('VaseBreakerFlowModuleProperties')) {
        missingList.add('VaseBreakerFlowModuleProperties');
      }
    }
    if (isEvilDave) {
      if (!existingClasses.contains('InitialPlantEntryProperties')) {
        missingList.add('InitialPlantEntryProperties');
      }
      if (!existingClasses.contains('SeedBankProperties')) {
        missingList.add('SeedBankProperties');
      }
    }
    if (isZombossMechBattle) {
      if (!existingClasses.contains('ZombossBattleModuleProperties')) {
        missingList.add('ZombossBattleModuleProperties');
      }
      if (!existingClasses.contains('ZombossBattleIntroProperties')) {
        missingList.add('ZombossBattleIntroProperties');
      }
    }
    if (isZombossBattle) {
      if (!existingClasses.contains('ZombossLastStandMinigameProperties')) {
        missingList.add('ZombossLastStandMinigameProperties');
      }
    }
    if (isLastStand) {
      if (!existingClasses.contains('SeedBankProperties')) {
        missingList.add('SeedBankProperties');
      }
    }
    final metas = missingList
        .map((cls) => ModuleRegistry.getMetadata(cls))
        .where((m) {
          return m.titleKey != ModuleRegistry.defaultMetadataKey;
        })
        .toList();
    return metas;
  }

  void _openGlacierModuleSettings() {
    final levelFile = _ec.state.levelFile;
    final parsed = _ec.state.parsedData;
    if (levelFile == null || parsed?.levelDef == null) return;

    const objClass = 'GlacierModuleProperties';

    String? findGlacierRtid() {
      final def = parsed!.levelDef!;
      for (final moduleRtid in def.modules) {
        final info = RtidParser.parse(moduleRtid);
        if (info == null) continue;
        final obj = info.source == 'CurrentLevel'
            ? levelFile.objects.firstWhereOrNull(
                (o) => o.aliases?.contains(info.alias) == true,
              )
            : parsed.objectMap[info.alias];
        if (obj?.objClass == objClass) return moduleRtid;
      }
      return null;
    }

    var rtid = findGlacierRtid();
    if (rtid == null) {
      _addModule(ModuleRegistry.getMetadata(objClass));
      _ec.recalculateTabs();
      rtid = findGlacierRtid();
    }
    if (rtid == null || !mounted) return;
    final glacierRtid = rtid;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlacierModuleScreen(
          rtid: glacierRtid,
          levelFile: levelFile,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
          onRequestZombieSelection: (onSelected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ZombieSelectionScreen(
                  stateBucketId: _selectionStateBucketId,
                  editorCubit: _ec,
                  levelFile: _ec.state.levelFile,
                  onAddModule: (objClass) {
                    _addModule(ModuleRegistry.getMetadata(objClass));
                  },
                  multiSelect: false,
                  onZombieSelected: (id) {
                    Navigator.pop(context);
                    onSelected(id);
                  },
                  onMultiZombieSelected: (_) {},
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSingleHandedTutorialSettings() {
    final levelFile = _ec.state.levelFile;
    final parsed = _ec.state.parsedData;
    if (levelFile == null || parsed?.levelDef == null) return;

    const objClass = 'IntroSingleHandedProperties';

    String? findTutorialRtid() {
      for (final moduleRtid in parsed!.levelDef!.modules) {
        final info = RtidParser.parse(moduleRtid);
        if (info == null || info.source != 'CurrentLevel') continue;
        final object = levelFile.objects.firstWhereOrNull(
          (candidate) => candidate.aliases?.contains(info.alias) == true,
        );
        if (object?.objClass == objClass) return moduleRtid;
      }
      return null;
    }

    var rtid = findTutorialRtid();
    if (rtid == null) {
      _addModule(ModuleRegistry.getMetadata(objClass));
      _ec.recalculateTabs();
      rtid = findTutorialRtid();
    }
    if (rtid == null || !mounted) return;
    _pushSingleHandedTutorialScreen(rtid);
  }

  void _pushSingleHandedTutorialScreen(String rtid) {
    final levelFile = _ec.state.levelFile;
    if (levelFile == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntroSingleHandedPropertiesScreen(
          rtid: rtid,
          levelFile: levelFile,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _openInitialGridItemSettings() {
    final levelFile = _ec.state.levelFile;
    if (levelFile == null) return;

    final existing = ZombossEightiesSpeakerPresets.findModule(levelFile);
    final module = ZombossEightiesSpeakerPresets.ensureModule(levelFile);
    if (existing == null) {
      _markDirty();
      _ec.recalculateTabs();
    }
    if (!mounted) return;
    final rtid = ZombossEightiesSpeakerPresets.moduleRtid(module);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InitialGridItemEntryScreen(
          rtid: rtid,
          levelFile: levelFile,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
          onAddModule: (objClass) =>
              _addModule(ModuleRegistry.getMetadata(objClass)),
          onOpenCustomStageSelection: _openCustomStageSelectionFromGridItem,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_ec.state.levelFile == null) return;
    final hadChanges = _ec.state.hasChanges;
    await _ec.save();
    if (!mounted) return;
    if (hadChanges) {
      final l10n = AppLocalizations.of(context);
      AppMessage.show(
        context,
        l10n?.saved ?? 'Saved',
        icon: Icons.check_circle,
      );
    }
  }

  void _markDirty() {
    _ec.markDirty();
  }

  Future<bool> _confirmLeave() async {
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.unsavedChanges ?? 'Unsaved changes'),
        content: Text(l10n?.saveBeforeLeaving ?? 'Save before leaving?'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.discard ?? 'Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.stayInEditor ?? 'Stay'),
          ),
          FilledButton(
            onPressed: () async {
              await _save();
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: Text(l10n?.confirm ?? 'Save'),
          ),
        ],
      ),
    );
    return leave == true;
  }

  // --- Actions ---

  void _handleEditBasicInfo() {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BasicInfoScreen(
          levelFile: _ec.state.levelFile!,
          levelDef: _ec.state.parsedData!.levelDef!,
          onBack: () => Navigator.pop(context),
          onStageTap: (levelDef, onStagePicked) => _openStageSelection(
            levelDef: levelDef,
            onStagePicked: onStagePicked,
          ),
          onChanged: _markDirty,
        ),
      ),
    );
  }

  Future<void> _handleEditCustomStage(String alias) async {
    if (_ec.state.levelFile == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomStagePropertiesScreen(
          alias: alias,
          levelFile: _ec.state.levelFile!,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  String _suggestCustomStageAlias(StageBaseOption option) {
    return option.alias.isEmpty ? 'CustomStage' : '${option.alias}Custom';
  }

  Future<String?> _promptCustomStageAlias(String suggested) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _CustomStageAliasPromptDialog(initialAlias: suggested),
    );
  }

  Future<bool> _handleDeleteCustomStage({
    required LevelDefinitionData levelDef,
    required String alias,
  }) async {
    if (_ec.state.levelFile == null) return false;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.customStageDeleteTitle ?? 'Delete custom lawn?'),
        content: Text(
          l10n?.customStageDeleteMessage ??
              'This permanently removes the custom stage data from this level. If it is the active lawn, the level will switch to the default built-in lawn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    final currentAlias = RtidParser.parse(levelDef.stageModule)?.alias;
    final wasActive =
        CustomStageLevelUtils.isCustomStageRtid(levelDef.stageModule) &&
        currentAlias == alias;

    CustomStageLevelUtils.removeCustomStageFromLevel(
      _ec.state.levelFile!,
      alias,
    );
    _ec.state.parsedData?.objectMap.remove(alias);

    if (wasActive) {
      levelDef.stageModule = CustomStageLevelUtils.defaultBuiltinStageRtid;
      LevelParser.syncAndWriteLevelDefinition(levelDef, _ec.state.levelFile!);
    }
    _markDirty();
    return true;
  }

  Future<void> _createCustomStage({
    required LevelDefinitionData levelDef,
    VoidCallback? onStagePicked,
  }) async {
    if (_ec.state.levelFile == null) return;
    if (CustomStageLevelUtils.customStageObjectsInLevel(
      _ec.state.levelFile!,
    ).isNotEmpty) {
      if (mounted) {
        AppMessage.show(
          context,
          AppLocalizations.of(context)?.customStageOnePerLevelLimit ??
              'This level already has a custom lawn. Delete it before adding another.',
          icon: Icons.info_outline,
        );
      }
      return;
    }
    StageBaseOption? baseOption;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => StageBaseSelectionScreen(
          stateBucketId: '$_selectionStateBucketId:stage-base',
          onStageBaseSelected: (option) {
            baseOption = option;
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
    if (baseOption == null || !mounted) return;

    var suggested = _suggestCustomStageAlias(baseOption!);
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains(suggested) == true,
    )) {
      suggested = '${suggested}_1';
    }

    final alias = await _promptCustomStageAlias(suggested);
    if (alias == null || alias.isEmpty || !mounted) return;
    if (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains(alias) == true,
    )) {
      if (!mounted) return;
      AppMessage.show(
        context,
        AppLocalizations.of(context)?.customStageAliasTaken ??
            'That alias is already used in this level.',
        icon: Icons.info_outline,
      );
      return;
    }

    final rtid = CustomStageLevelUtils.createCustomStage(
      levelFile: _ec.state.levelFile!,
      alias: alias,
      baseOption: baseOption!,
    );
    levelDef.stageModule = rtid;
    LevelParser.syncAndWriteLevelDefinition(levelDef, _ec.state.levelFile!);
    _markDirty();
    onStagePicked?.call();
    await _handleEditCustomStage(alias);
    onStagePicked?.call();
  }

  Future<String?> _createCustomStageFromPreset({
    required LevelDefinitionData levelDef,
    required CustomStagePreset preset,
    VoidCallback? onStagePicked,
  }) {
    if (_ec.state.levelFile == null) return Future<String?>.value();
    final levelFile = _ec.state.levelFile!;
    if (CustomStageLevelUtils.customStageObjectsInLevel(levelFile).isNotEmpty) {
      if (mounted) {
        AppMessage.show(
          context,
          AppLocalizations.of(context)?.customStageOnePerLevelLimit ??
              'This level already has a custom lawn. Delete it before adding another.',
          icon: Icons.info_outline,
        );
      }
      return Future.value(null);
    }
    final alias = preset.alias;
    final rtid = CustomStageLevelUtils.createCustomStageFromTemplate(
      levelFile: levelFile,
      alias: alias,
      objclass: preset.objclass,
      objdata: preset.objdata,
      aliases: CustomStagePresetRepository.aliasesForPresetInstance(
        primaryAlias: alias,
        preset: preset,
      ),
      prepend: true,
    );
    levelDef.stageModule = rtid;
    LevelParser.syncAndWriteLevelDefinition(levelDef, levelFile);

    final stageObj = CustomStageLevelUtils.findStageObject(levelFile, alias);
    if (stageObj != null) {
      _ec.state.parsedData?.objectMap[alias] = stageObj;
    }
    _markDirty();
    onStagePicked?.call();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(() async {
        await _handleEditCustomStage(alias);
        onStagePicked?.call();
      }());
    });
    return Future.value(alias);
  }

  Future<void> _openStageSelection({
    required LevelDefinitionData levelDef,
    VoidCallback? onStagePicked,
    bool openCustomSection = false,
  }) async {
    if (_ec.state.levelFile == null) return;
    final current = levelDef.stageModule;
    final wasDeepSea = LevelParser.isDeepSeaLawn(levelDef);
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (stageRouteContext) => StageSelectionScreen(
          currentStageRtid: current,
          levelFile: _ec.state.levelFile!,
          openCustomSection: openCustomSection,
          onCreateCustomStage: () {
            Navigator.pop(stageRouteContext);
            _createCustomStage(
              levelDef: levelDef,
              onStagePicked: onStagePicked,
            );
          },
          onCreateCustomStageFromPreset: (preset) =>
              _createCustomStageFromPreset(
                levelDef: levelDef,
                preset: preset,
                onStagePicked: onStagePicked,
              ),
          onOpenCustomStageEditor: (alias) async {
            final rtid = RtidParser.build(
              alias,
              CustomStageLevelUtils.currentLevel,
            );
            if (levelDef.stageModule != rtid) {
              levelDef.stageModule = rtid;
              LevelParser.syncAndWriteLevelDefinition(
                levelDef,
                _ec.state.levelFile!,
              );
              _markDirty();
              onStagePicked?.call();
            }
            Navigator.pop(stageRouteContext);
            await _handleEditCustomStage(alias);
            onStagePicked?.call();
          },
          onDeleteCustomStage: (alias) async {
            final deleted = await _handleDeleteCustomStage(
              levelDef: levelDef,
              alias: alias,
            );
            if (deleted) onStagePicked?.call();
            return deleted;
          },
          onSwitchFromCustomToBuiltin: (alias) async {
            final l10n = AppLocalizations.of(context);
            final confirmed = await showDialog<bool>(
              context: stageRouteContext,
              builder: (ctx) => AlertDialog(
                title: Text(
                  l10n?.customStageSwitchToBuiltinTitle ??
                      'Switch to built-in lawn?',
                ),
                content: Text(
                  l10n?.customStageSwitchToBuiltinMessage ??
                      'This permanently removes the custom stage data from this level. This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l10n?.confirm ?? 'Confirm'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              CustomStageLevelUtils.removeCustomStageFromLevel(
                _ec.state.levelFile!,
                alias,
              );
              _ec.state.parsedData?.objectMap.remove(alias);
              _markDirty();
            }
            return confirmed ?? false;
          },
          onStageSelected: (newRtid) async {
            final willBeDeepSea = LevelParser.willBeDeepSeaStageRtid(
              newRtid,
              _ec.state.levelFile!,
            );
            if (wasDeepSea && !willBeDeepSea) {
              final has6RowData = LevelParser.has6RowDataInLevel(
                _ec.state.levelFile!,
              );
              if (has6RowData && mounted) {
                final l10n = AppLocalizations.of(context);
                final confirmed = await showDialog<bool>(
                  context: stageRouteContext,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n?.confirm ?? 'Confirm'),
                    content: Text(
                      l10n?.warningStageSwitchedTo5Rows ??
                          'Stage uses 5 rows but some data references row 6. These objects may not display correctly in-game. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n?.cancel ?? 'Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n?.confirm ?? 'Confirm'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
              }
            }
            levelDef.stageModule = newRtid;
            LevelParser.syncAndWriteLevelDefinition(
              levelDef,
              _ec.state.levelFile!,
            );
            _markDirty();
            onStagePicked?.call();
            if (!stageRouteContext.mounted) return;
            Navigator.pop(stageRouteContext);
          },
          onBack: () {
            if (!stageRouteContext.mounted) return;
            Navigator.pop(stageRouteContext);
          },
        ),
      ),
    );
  }

  Future<void> _openCustomStageSelectionFromGridItem() async {
    final levelDef = _ec.state.parsedData?.levelDef;
    if (levelDef == null) return;
    await _openStageSelection(levelDef: levelDef, openCustomSection: true);
  }

  void _handleNavigateToAddModule() async {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return;

    final existingObjClasses = <String>{};
    for (var rtid in _ec.state.parsedData!.levelDef!.modules) {
      final info = RtidParser.parse(rtid);
      if (info != null) {
        if (info.source == 'CurrentLevel') {
          final obj = _ec.state.parsedData!.objectMap[info.alias];
          if (obj != null) {
            existingObjClasses.add(
              ModuleRegistry.getMetadataForAlias(
                info.alias,
                obj.objClass,
              ).selectionKey,
            );
          }
        } else {
          final cls = ReferenceRepository.instance.getObjClass(info.alias);
          if (cls != null) {
            existingObjClasses.add(
              ModuleRegistry.getMetadataForAlias(info.alias, cls).selectionKey,
            );
          }
        }
      }
    }

    final selection = await Navigator.push<ModuleSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleSelectionScreen(
          existingObjClasses: existingObjClasses,
          stateBucketId: '$_selectionStateBucketId:module-selection',
        ),
      ),
    );

    if (selection != null) {
      if (!mounted) return;
      final meta = selection.metadata;
      final l10n = AppLocalizations.of(context)!;
      String? chosenAlias;
      if (meta.defaultSource == 'CurrentLevel') {
        var suggestedAlias = PvzAliasUtils.uniqueAlias(
          _ec.state.levelFile!,
          meta.effectiveAlias,
          numberSeparator: meta.duplicateAliasNumberSeparator,
        );
        chosenAlias = await showPvzAliasInputDialog(
          context,
          defaultAlias: suggestedAlias,
          title: l10n.addModuleAliasTitle,
          objClass: meta.objClass,
          levelFile: _ec.state.levelFile!,
        );
        if (chosenAlias == null || !mounted) return;
      }
      final requiredModuleObjClass = selection.requiredModuleObjClass;
      if (requiredModuleObjClass != null) {
        _addModule(ModuleRegistry.getMetadata(requiredModuleObjClass));
      }
      _addModule(meta, aliasOverride: chosenAlias);
    }
  }

  void _addModule(ModuleMetadata meta, {String? aliasOverride}) {
    final def = _ec.state.parsedData!.levelDef;
    if (def == null) return;

    var alias = aliasOverride ?? meta.effectiveAlias;
    final source = meta.defaultSource;

    if (source == 'CurrentLevel') {
      if (aliasOverride == null) {
        var count = 0;
        while (_ec.state.levelFile!.objects.any(
          (o) => o.aliases?.contains(alias) == true,
        )) {
          count++;
          alias =
              '${meta.effectiveAlias}${meta.duplicateAliasNumberSeparator}$count';
        }
      }

      final rtid = RtidParser.build(alias, source);
      def.modules.add(rtid);

      final objData = Map<String, dynamic>.from(meta.initialData ?? {});
      if (meta.defaultAlias == 'SouDaCheTunnelDefendDefault') {
        objData['BrickMapIndex'] = 3;
        objData['reportError'] = false;
        objData['Roads'] = objData['Roads'] ?? [];
        objData.remove('TunnelSequenceInterval');
      } else if (meta.objClass == 'TunnelDefendModuleProperties') {
        final stageAlias = RtidParser.parse(def.stageModule)?.alias ?? '';
        objData['BrickMapIndex'] = stageAlias == 'UnchartedMausoleum2Stage'
            ? 2
            : 1;
        objData['reportError'] = objData['reportError'] ?? true;
      }
      final moduleObject = PvzObject(
        aliases: [alias],
        objClass: meta.objClass,
        objData: objData,
      );
      _ec.state.levelFile!.objects.add(moduleObject);
      if (meta.objClass == CowboyMinigameUtils.moduleObjClass) {
        CowboyMinigameUtils.enableManualPacketSpawning(_ec.state.levelFile!);
      }
      if (meta.objClass == MoldColonyModuleUtils.moduleObjClass) {
        MoldColonyModuleUtils.ensureCurrentLevelLayout(
          levelFile: _ec.state.levelFile!,
          moduleObject: moduleObject,
        );
      }
    } else {
      final rtid = RtidParser.build(alias, source);
      def.modules.add(rtid);
    }

    _markDirty();
    _ec.recalculateTabs();
  }

  void _handleRemoveModule(String rtid) {
    final def = _ec.state.parsedData?.levelDef;
    if (def == null) return;

    final info = RtidParser.parse(rtid);
    String? moldLocations;
    if (info != null && info.source == 'CurrentLevel') {
      final moduleObject = _ec.state.levelFile!.objects.firstWhereOrNull(
        (object) => object.aliases?.contains(info.alias) == true,
      );
      if (moduleObject?.objClass == MoldColonyModuleUtils.moduleObjClass &&
          moduleObject?.objData is Map) {
        moldLocations = MoldColonyChallengePropsData.fromJson(
          Map<String, dynamic>.from(moduleObject!.objData as Map),
        ).locations;
      }
    }

    final removedModule = ModuleInstanceUtils.removeModule(
      levelFile: _ec.state.levelFile!,
      levelDef: def,
      rtid: rtid,
    );
    if (removedModule?.objClass == CowboyMinigameUtils.moduleObjClass) {
      CowboyMinigameUtils.removeManualPacketSpawning(_ec.state.levelFile!);
    }
    if (moldLocations != null) {
      MoldColonyModuleUtils.removeUnreferencedLayout(
        levelFile: _ec.state.levelFile!,
        locations: moldLocations,
      );
    }
    if (info?.alias == FinalStageTimeLimitedModuleUtils.alias) {
      _ec.state.levelFile!.objects.removeWhere(
        (o) => o.objClass == FinalStageTimeLimitedModuleUtils.objClass,
      );
    }

    _markDirty();
    _ec.recalculateTabs();
  }

  void _handleReorderModules({
    required bool isCoreSection,
    required int oldIndex,
    required int newIndex,
  }) {
    final def = _ec.state.parsedData?.levelDef;
    final file = _ec.state.levelFile;
    final objectMap = _ec.state.parsedData?.objectMap;
    if (def == null || file == null || objectMap == null) return;

    LevelModuleOrderUtils.reorderModuleSection(
      levelDef: def,
      levelFile: file,
      objectMap: objectMap,
      isCoreSection: isCoreSection,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    _markDirty();
    setState(() {});
  }

  Future<void> _handleEditEvent(String rtid, int waveIndex) async {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return;
    final l10n = AppLocalizations.of(context);
    final alias = LevelParser.extractAlias(rtid);
    final obj = _ec.state.parsedData!.objectMap[alias];

    if (obj == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvalidEventScreen(
            rtid: rtid,
            waveIndex: waveIndex,
            onDeleteReference: _handleDeleteEventReference,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    final objClass = obj.objClass;
    if (objClass == 'BarrelWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BarrelWaveEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'SchoolBusWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolBusEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'HamsterZombieSpawnerProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HamsterZombieEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onEditCustomZombie: _handleEditCustomZombie,
            onInjectCustomZombie: _injectCustomZombie,
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'BungeeWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BungeeWaveEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'ThunderWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThunderWaveEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnGravestonesWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpawnGraveStonesEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestGridItemSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GridItemSelectionScreen(
                    onGridItemSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onBack: () => Navigator.pop(context),
                    filterMode: GridItemFilterMode.all,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) =>
                        _addModule(ModuleRegistry.getMetadata(objClass)),
                    onOpenCustomStageSelection:
                        _openCustomStageSelectionFromGridItem,
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'ParachuteRainZombieSpawnerProps' ||
        objClass == 'BassRainZombieSpawnerProps' ||
        objClass == 'SpiderRainZombieSpawnerProps') {
      final subtitle = objClass == 'BassRainZombieSpawnerProps'
          ? 'Event: Bass/Jetpack rain'
          : objClass == 'SpiderRainZombieSpawnerProps'
          ? 'Event: Spider rain'
          : 'Event: Parachute rain';
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParachuteRainEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            eventSubtitle: subtitle,
            eventObjClass: objClass,
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'TidalChangeWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TidalChangeEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'TideWaveWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TideWaveEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnZombiesFishWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombieFishWaveEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onEditCustomZombie: _handleEditCustomZombie,
            onInjectCustomZombie: _injectCustomZombie,
            onEditCustomFish: _handleEditCustomFish,
            onInjectCustomFish: _injectCustomFish,
            onRequestPlantSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    isMultiSelect: false,
                    onPlantSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiPlantSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                  ),
                ),
              );
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnZombiesJitteredWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JitteredEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onEditCustomZombie: _handleEditCustomZombie,
            onInjectCustomZombie: _injectCustomZombie,
            onRequestPlantSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    isMultiSelect: false,
                    onPlantSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiPlantSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                  ),
                ),
              );
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnZombiesFromGroundSpawnerProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroundSpawnEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onEditCustomZombie: _handleEditCustomZombie,
            onInjectCustomZombie: _injectCustomZombie,
            onRequestPlantSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    isMultiSelect: false,
                    onPlantSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiPlantSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                  ),
                ),
              );
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'ModifyConveyorWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModifyConveyorEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            onRequestPlantSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    isMultiSelect: false,
                    onPlantSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiPlantSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                  ),
                ),
              );
            },
            onRequestToolSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ToolSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    onToolSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'BeachStageEventZombieSpawnerProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeachStageEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'StormZombieSpawnerProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StormEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onEditCustomZombie: _handleEditCustomZombie,
            onInjectCustomZombie: _injectCustomZombie,
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'RaidingPartyZombieSpawnerProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RaidingPartyEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'BlackHoleWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlackHoleEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'FrostWindWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FrostWindEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'DinoWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DinoEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'DinoTreadActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DinoTreadEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'DinoRunActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DinoRunEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnZombiesFromGridItemSpawnerProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GridItemSpawnEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () {
              _setActiveTab(EditorTabType.timeline);
              Navigator.pop(context);
            },
            onEditCustomZombie: _handleEditCustomZombie,
            onInjectCustomZombie: _injectCustomZombie,
            onRequestGridItemSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GridItemSelectionScreen(
                    onGridItemSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onBack: () => Navigator.pop(context),
                    filterMode: GridItemFilterMode.all,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) =>
                        _addModule(ModuleRegistry.getMetadata(objClass)),
                    onOpenCustomStageSelection:
                        _openCustomStageSelectionFromGridItem,
                  ),
                ),
              );
            },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'ZombiePotionActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombiePotionEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestGridItemSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GridItemSelectionScreen(
                    onGridItemSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onBack: () => Navigator.pop(context),
                    filterMode: GridItemFilterMode.all,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) =>
                        _addModule(ModuleRegistry.getMetadata(objClass)),
                    onOpenCustomStageSelection:
                        _openCustomStageSelectionFromGridItem,
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'ZombieAtlantisShellActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShellEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnEagleFlagsWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EagleStandardEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'PumpkinHouseActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PumpkinHouseEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'WaveActionZombieTentProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombieTentWaveEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    if (objClass == 'MagicMirrorWaveActionProps' ||
        objClass == 'WaveActionMagicMirrorTeleportationArrayProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MagicMirrorEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'FairyTaleFogWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FairyTaleFogEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'FairyTaleWindWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FairyTaleWindEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnModernPortalsWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModernPortalsEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'GravityGeneratorWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GravityGeneratorEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (objClass == 'SpawnRocketLandingWaveActionProps') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RocketLandingEventScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    AppMessage.show(
      context,
      l10n?.eventEditorInDevelopment ?? 'Event editor in development',
      icon: Icons.info_outline,
    );
  }

  void _handleAddEvent(int waveIndex) async {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return;
    final wm = _ec.state.parsedData!.waveManager;
    if (wm is! WaveManagerData) return;
    if (waveIndex < 1 || waveIndex > wm.waves.length) return;

    final meta = await Navigator.push<EventMetadata>(
      context,
      MaterialPageRoute(
        builder: (context) => EventSelectionScreen(
          waveIndex: waveIndex,
          levelFile: _ec.state.levelFile!,
          onEventSelected: (m) => Navigator.pop(context, m),
          onBack: () => Navigator.pop(context),
        ),
      ),
    );

    if (meta == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final waveEvents = wm.waves[waveIndex - 1];
    var prefix = 'Wave$waveIndex${meta.defaultAlias}';
    var count = 0;
    var suggestedAlias = '$prefix$count';
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains(suggestedAlias) == true,
    )) {
      count++;
      suggestedAlias = '$prefix$count';
    }

    final newAlias = await showPvzAliasInputDialog(
      context,
      defaultAlias: suggestedAlias,
      title: l10n.addEventAliasTitle,
      objClass: meta.defaultObjClass,
      levelFile: _ec.state.levelFile!,
    );
    if (newAlias == null || !mounted) return;

    final newRtid = RtidParser.build(newAlias, 'CurrentLevel');
    final data = meta.initialDataFactory();
    final objData = (data as dynamic).toJson() as Map<String, dynamic>;
    _ec.state.levelFile!.objects.add(
      PvzObject(
        aliases: [newAlias],
        objClass: meta.defaultObjClass,
        objData: objData,
      ),
    );
    waveEvents.add(newRtid);

    final wmObj = _ec.state.levelFile!.objects.firstWhereOrNull(
      (o) => o.objClass == 'WaveManagerProperties',
    );
    if (wmObj != null) {
      wmObj.objData = wm.toJson();
    }

    _markDirty();
  }

  void _handleDeleteEventReference(String rtid) {
    if (_ec.state.parsedData?.waveManager is WaveManagerData) {
      final wm = _ec.state.parsedData!.waveManager as WaveManagerData;
      for (final wave in wm.waves) {
        wave.remove(rtid);
      }
      final wmObj = _ec.state.levelFile?.objects.firstWhereOrNull(
        (o) => o.objClass == 'WaveManagerProperties',
      );
      if (wmObj != null) {
        wmObj.objData = wm.toJson();
      }
      _markDirty();
    }
  }

  void _handleEditWaveManagerSettings() {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return;
    final hasConveyor =
        _ec.state.parsedData!.levelDef?.modules.any((rtid) {
          final info = RtidParser.parse(rtid);
          if (info == null) return false;
          if (info.source == 'CurrentLevel') {
            final obj = _ec.state.parsedData!.objectMap[info.alias];
            return obj?.objClass == 'ConveyorSeedBankProperties';
          }
          return ReferenceRepository.instance.getObjClass(info.alias) ==
              'ConveyorSeedBankProperties';
        }) ??
        false;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaveManagerSettingsScreen(
          levelFile: _ec.state.levelFile!,
          hasConveyor: hasConveyor,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _openZombieSelection(void Function(String) onSelected) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZombieSelectionScreen(
          stateBucketId: _selectionStateBucketId,
          editorCubit: _ec,
          levelFile: _ec.state.levelFile,
          onAddModule: (objClass) {
            _addModule(ModuleRegistry.getMetadata(objClass));
          },
          multiSelect: false,
          onZombieSelected: (id) {
            Navigator.pop(context);
            onSelected(id);
          },
          onMultiZombieSelected: (_) {},
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleEditWaveGeneratorSettings() {
    if (_ec.state.levelFile == null || _ec.state.parsedData == null) return;
    final rtid = WaveGeneratorLevelUtils.moduleRtid(
      _ec.state.levelFile!,
      _ec.state.parsedData!,
    );
    if (rtid == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaveGeneratorModuleScreen(
          rtid: rtid,
          levelFile: _ec.state.levelFile!,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
          onRequestZombieSelection: _openZombieSelection,
        ),
      ),
    ).then((_) => _setActiveTab(EditorTabType.waveGenerator));
  }

  void _handleEditWaveGeneratorWave(int waveIndex) {
    if (_ec.state.levelFile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaveGeneratorWaveScreen(
          waveIndex: waveIndex,
          levelFile: _ec.state.levelFile!,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
          onRequestZombieSelection: _openZombieSelection,
        ),
      ),
    ).then((_) => _setActiveTab(EditorTabType.waveGenerator));
  }

  void _handleCreateWaveContainer() {
    if (_ec.state.levelFile == null) return;
    var alias = 'WaveManagerProps';
    var count = 0;
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains(alias) == true,
    )) {
      count++;
      alias = 'WaveManagerProps_$count';
    }
    final wm = WaveManagerData(waveCount: 0, waves: []);
    _ec.state.levelFile!.objects.add(
      PvzObject(
        aliases: [alias],
        objClass: 'WaveManagerProperties',
        objData: wm.toJson(),
      ),
    );
    final wmmObj = _ec.state.levelFile!.objects.firstWhereOrNull(
      (o) => o.objClass == 'WaveManagerModuleProperties',
    );
    if (wmmObj != null && wmmObj.objData is Map<String, dynamic>) {
      final data = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(wmmObj.objData as Map),
      );
      data.waveManagerProps = RtidParser.build(alias, 'CurrentLevel');
      wmmObj.objData = data.toJson();
    }
    _markDirty();
  }

  Future<void> _handleDeleteWaveContainer() async {
    if (_ec.state.levelFile == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteWaveContainerTitle ?? 'Delete wave container?'),
        content: Text(
          l10n?.deleteWaveContainerConfirm ??
              'Are you sure you want to delete the empty wave container? You can create a new one later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _ec.state.levelFile!.objects.removeWhere(
        (o) => o.objClass == 'WaveManagerProperties',
      );
      _markDirty();
    }
  }

  void _handleEditCustomZombie(String rtid) {
    if (_ec.state.levelFile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomZombiePropertiesScreen(
          rtid: rtid,
          levelFile: _ec.state.levelFile!,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
        ),
      ),
    ).then((_) => _setActiveTab(EditorTabType.timeline));
  }

  void _handleEditCustomFish(String rtid) {
    if (_ec.state.levelFile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomFishPropertiesScreen(
          rtid: rtid,
          levelFile: _ec.state.levelFile!,
          onChanged: _markDirty,
          onBack: () => Navigator.pop(context),
        ),
      ),
    ).then((_) => _setActiveTab(EditorTabType.timeline));
  }

  String? _injectCustomFish(String baseFishAlias) {
    if (_ec.state.levelFile == null) return null;
    final template = FishPropertiesRepository.getFishTemplate(baseFishAlias);
    if (template == null) return null;

    final typeTemplate = template['type'];
    final propsTemplate = template['props'];
    if (typeTemplate is! PvzObject || propsTemplate is! PvzObject) {
      return null;
    }

    final baseName = FishPropertiesRepository.getTypeName(baseFishAlias);
    var index = 1;
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains('${baseName}_$index') == true,
    )) {
      index++;
    }
    final newTypeAlias = '${baseName}_$index';

    var propsIndex = index;
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains('${baseName}_props_$propsIndex') == true,
    )) {
      propsIndex++;
    }
    final newPropsAlias = '${baseName}_props_$propsIndex';

    final newPropsData = _cloneJson(propsTemplate.objData);
    final newTypeData = _cloneJson(typeTemplate.objData);
    if (newTypeData is Map<String, dynamic>) {
      newTypeData['Properties'] = RtidParser.build(
        newPropsAlias,
        'CurrentLevel',
      );
    }

    final newPropsObj = PvzObject(
      aliases: [newPropsAlias],
      objClass: propsTemplate.objClass,
      objData: newPropsData,
    );
    final newTypeObj = PvzObject(
      aliases: [newTypeAlias],
      objClass: typeTemplate.objClass,
      objData: newTypeData,
    );

    _ec.state.levelFile!.objects.addAll([newPropsObj, newTypeObj]);
    _markDirty();

    return RtidParser.build(newTypeAlias, 'CurrentLevel');
  }

  void _showUiScaleDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var tempScale = context.read<SettingsCubit>().state.uiScale;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(ctx).width < 480 ? 12 : 40,
            vertical: 24,
          ),
          title: Text(l10n.adjustUiSize),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.currentScale((tempScale * 100).toInt().toString())),
              Slider(
                value: tempScale,
                min: 0.75,
                max: 1.5,
                onChanged: (v) => setDialogState(() => tempScale = v),
              ),
              EditorUiScalePresetLabels(
                currentScale: tempScale,
                onPresetSelected: (scale) =>
                    setDialogState(() => tempScale = scale),
                smallLabel: l10n.small,
                standardLabel: l10n.standard,
                largeLabel: l10n.large,
                ultraLabel: l10n.ultra,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().setUiScale(1.0);
                Navigator.pop(ctx);
              },
              child: Text(l10n.reset),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().setUiScale(tempScale);
                Navigator.pop(ctx);
              },
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }

  void _setActiveTab(EditorTabType type) {
    final index = _ec.state.availableTabs.indexOf(type);
    if (index >= 0) {
      _tabController?.animateTo(index);
    }
  }

  List<String> _moduleRtidsForEditorTab(EditorTabType type) {
    final objClass = switch (type) {
      EditorTabType.zombossMech => 'ZombossBattleModuleProperties',
      EditorTabType.zombossBattle => 'ZombossLastStandMinigameProperties',
      _ => null,
    };
    final def = _ec.state.parsedData?.levelDef;
    final objectMap = _ec.state.parsedData?.objectMap;
    if (objClass == null || def == null || objectMap == null) return const [];

    return def.modules
        .where((rtid) {
          final info = RtidParser.parse(rtid);
          if (info == null) return false;
          final resolvedObjClass = info.source == 'CurrentLevel'
              ? objectMap[info.alias]?.objClass
              : ReferenceRepository.instance.getObjClass(info.alias);
          return resolvedObjClass == objClass;
        })
        .toList(growable: false);
  }

  List<_EditorTopTabEntry> _editorTopTabEntries() {
    final rtidsByType = <EditorTabType, List<String>>{
      EditorTabType.zombossMech: _moduleRtidsForEditorTab(
        EditorTabType.zombossMech,
      ),
      EditorTabType.zombossBattle: _moduleRtidsForEditorTab(
        EditorTabType.zombossBattle,
      ),
    };
    final occurrences = <EditorTabType, int>{};
    return _ec.state.availableTabs
        .map((type) {
          final index = occurrences.update(
            type,
            (value) => value + 1,
            ifAbsent: () => 0,
          );
          final rtids = rtidsByType[type] ?? const <String>[];
          return (
            type: type,
            moduleRtid: index < rtids.length ? rtids[index] : null,
            instanceIndex: index,
            instanceCount: rtids.isEmpty ? 1 : rtids.length,
          );
        })
        .toList(growable: false);
  }

  void _setActiveModuleTab(EditorTabType type, String rtid) {
    final entries = _editorTopTabEntries();
    final index = entries.indexWhere(
      (entry) => entry.type == type && entry.moduleRtid == rtid,
    );
    if (index >= 0) _tabController?.animateTo(index);
  }

  dynamic _cloneJson(dynamic data) {
    return jsonDecode(jsonEncode(data));
  }

  String? _injectCustomZombie(String originalAlias) {
    if (_ec.state.levelFile == null) return null;
    final typeName = ZombiePropertiesRepository.getTypeNameByAlias(
      originalAlias,
    );
    final template = ZombiePropertiesRepository.getTemplateJson(typeName);
    if (template == null) {
      return null;
    }

    final typeTemplate = template['type'];
    final propsTemplate = template['props'];
    if (typeTemplate is! PvzObject || propsTemplate is! PvzObject) {
      return null;
    }

    final baseName = typeName;
    var index = 1;
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains('${baseName}_$index') == true,
    )) {
      index++;
    }
    final newTypeAlias = '${baseName}_$index';

    var propsIndex = index;
    while (_ec.state.levelFile!.objects.any(
      (o) => o.aliases?.contains('${baseName}_props_$propsIndex') == true,
    )) {
      propsIndex++;
    }
    final newPropsAlias = '${baseName}_props_$propsIndex';

    final newPropsData = _cloneJson(propsTemplate.objData);
    final newTypeData = _cloneJson(typeTemplate.objData);
    if (newTypeData is Map<String, dynamic>) {
      newTypeData['Properties'] = RtidParser.build(
        newPropsAlias,
        'CurrentLevel',
      );
    }

    final newPropsObj = PvzObject(
      aliases: [newPropsAlias],
      objClass: propsTemplate.objClass,
      objData: newPropsData,
    );
    final newTypeObj = PvzObject(
      aliases: [newTypeAlias],
      objClass: typeTemplate.objClass,
      objData: newTypeData,
    );

    _ec.state.levelFile!.objects.addAll([newPropsObj, newTypeObj]);
    _markDirty();

    return RtidParser.build(newTypeAlias, 'CurrentLevel');
  }

  void _handleEditModule(String rtid, {ModuleOpenHint? hint}) {
    final info = RtidParser.parse(rtid);
    if (info == null) return;

    PvzObject? obj;
    String objClass = 'Unknown';

    if (info.source == 'CurrentLevel') {
      obj = _ec.state.parsedData!.objectMap[info.alias];
      objClass = obj?.objClass ?? 'Unknown';
    } else {
      objClass =
          ReferenceRepository.instance.getObjClass(info.alias) ?? 'Unknown';
    }

    // Check if we have a specific screen for this module
    if (objClass == 'StatueMazeModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatueMazeModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (objClass == 'CamelMinigameProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CamelMinigameScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (objClass == 'OakTrainProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OakTrainScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (objClass == 'StarChallengeModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StarChallengeModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            onOpenCustomStageSelection: _openCustomStageSelectionFromGridItem,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LevelMutatorMaxSunProps') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaxSunModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'MoonExpertProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoonExpertModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LevelMutatorStartingPlantfoodProps') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartingPlantfoodModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'RiftThemeDemoModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RiftThemeModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LevelMutatorRiftTimedSunProps') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombieSunDropModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: true,
                    onZombieSelected: (_) {},
                    onMultiZombieSelected: (ids) {
                      Navigator.pop(context);
                      onSelected(ids);
                    },
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'PickupCollectableTutorialProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickupCollectableTutorialScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'RailcartProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RailcartPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'MechanismPlankProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MechanismPlankPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'IncreasedCostModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IncreasedCostModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'DeathHoleModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeathHoleModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'PVZ1PassageModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PVZ1PassageModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'PVZ1CopycatsModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PVZ1CopycatsModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            editorCubit: _ec,
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
          ),
        ),
      );
      return;
    }
    if (objClass == 'PVZ1SeeingStarsModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PVZ1SeeingStarsModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ZombieMoveFastModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombieMoveFastModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'TideProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TidePropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'BowlingMinigameProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BowlingMinigameScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (objClass == 'SunDropperProperties' &&
        _ec.state.parsedData?.levelDef != null) {
      void openSunDropper(String rt) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SunDropperPropertiesScreen(
              rtid: rt,
              levelFile: _ec.state.levelFile!,
              levelDef: _ec.state.parsedData!.levelDef!,
              onChanged: _markDirty,
              onBack: () => Navigator.pop(context),
              onModeToggled: (newRtid) {
                _markDirty();
                Navigator.pop(context);
                openSunDropper(newRtid);
              },
            ),
          ),
        );
      }

      openSunDropper(rtid);
      return;
    }

    if (objClass == 'MoonLifeSupportSystemProperties' &&
        _ec.state.parsedData?.levelDef != null) {
      void openLifeSupport(String rt) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoonLifeSupportSystemScreen(
              rtid: rt,
              levelFile: _ec.state.levelFile!,
              levelDef: _ec.state.parsedData!.levelDef!,
              onChanged: _markDirty,
              onBack: () => Navigator.pop(context),
              onRequestPlantSelection: (initialIds, onSelected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlantSelectionScreen(
                      stateBucketId: _selectionStateBucketId,
                      isMultiSelect: true,
                      initialSelectedIds: initialIds,
                      onPlantSelected: (_) {},
                      onMultiPlantSelected: (ids) {
                        Navigator.pop(context);
                        onSelected(ids);
                      },
                      onBack: () => Navigator.pop(context),
                      levelFile: _ec.state.levelFile,
                      onAddModule: (objClass) {
                        _addModule(ModuleRegistry.getMetadata(objClass));
                      },
                    ),
                  ),
                );
              },
              onModeToggled: (newRtid) {
                _markDirty();
                Navigator.pop(context);
                openLifeSupport(newRtid);
              },
            ),
          ),
        );
      }

      openLifeSupport(rtid);
      return;
    }
    if (objClass == 'WitchModuleProperties' &&
        _ec.state.parsedData?.levelDef != null) {
      void openWitchModule(String rt) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WitchModulePropertiesScreen(
              rtid: rt,
              levelFile: _ec.state.levelFile!,
              levelDef: _ec.state.parsedData!.levelDef!,
              onChanged: _markDirty,
              onBack: () => Navigator.pop(context),
              onModeToggled: (newRtid) {
                _markDirty();
                Navigator.pop(context);
                openWitchModule(newRtid);
              },
            ),
          ),
        );
      }

      openWitchModule(rtid);
      return;
    }
    // FinalStageTimeLimitedChallenge: unwired — see
    // FinalStageTimeLimitedChallengePropertiesScreen (kept for future use).
    if (info.source == 'CurrentLevel' && objClass == 'PiratePlankProperties') {
      if (_ec.state.parsedData!.levelDef != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PiratePlankPropertiesScreen(
              rtid: rtid,
              levelFile: _ec.state.levelFile!,
              levelDef: _ec.state.parsedData!.levelDef!,
              onChanged: _markDirty,
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      }
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == MoldColonyModuleUtils.moduleObjClass) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoldColonyChallengeScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'SeedRainProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeedRainPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            editorCubit: _ec,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ConveyorSeedBankProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConveyorSeedBankPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            onRequestPlantSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    isMultiSelect: false,
                    onPlantSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onBack: () => Navigator.pop(context),
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                  ),
                ),
              );
            },
            onRequestToolSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ToolSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    onToolSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LastStandMinigameProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LastStandMinigameScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == CowboyMinigameUtils.moduleObjClass) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CowboyMinigameScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'IntroSingleHandedProperties') {
      _pushSingleHandedTutorialScreen(rtid);
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'SingleHandedProperties') {
      _setActiveTab(EditorTabType.singleHanded);
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'SeedBankProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeedBankPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestPlantSelection:
                (
                  onSelected, {
                  excludeIds,
                  initialSelectedIds,
                  blockRealmExclusiveInChooser = false,
                  blockHiddenPlantsInChooser = false,
                  allowDuplicateSelection = false,
                }) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantSelectionScreen(
                        stateBucketId: _selectionStateBucketId,
                        isMultiSelect: true,
                        excludeIds: excludeIds ?? const [],
                        initialSelectedIds: initialSelectedIds ?? const [],
                        blockRealmExclusiveInChooser:
                            blockRealmExclusiveInChooser,
                        blockHiddenPlantsInChooser: blockHiddenPlantsInChooser,
                        allowDuplicateSelection: allowDuplicateSelection,
                        onPlantSelected: (_) {},
                        onMultiPlantSelected: (ids) {
                          Navigator.pop(context);
                          onSelected(ids);
                        },
                        onBack: () => Navigator.pop(context),
                        levelFile: _ec.state.levelFile,
                        onAddModule: (objClass) {
                          _addModule(ModuleRegistry.getMetadata(objClass));
                        },
                      ),
                    ),
                  );
                },
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: true,
                    onZombieSelected: (_) {},
                    onMultiZombieSelected: (ids) {
                      Navigator.pop(context);
                      onSelected(ids);
                    },
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'InitialPlantProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InitialPlantPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'InitialPlantEntryProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InitialPlantEntryScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'InitialZombieProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InitialZombieEntryScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            editorCubit: _ec,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'InitialGridItemProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InitialGridItemEntryScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            onOpenCustomStageSelection: _openCustomStageSelectionFromGridItem,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ProtectThePlantChallengeProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProtectPlantChallengeScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ProtectTheGridItemChallengeProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProtectGridItemChallengeScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            onOpenCustomStageSelection: _openCustomStageSelectionFromGridItem,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'BombProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BombPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'SunBombChallengeProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SunBombChallengeScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ZombiePotionModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombiePotionModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
            onOpenCustomStageSelection: _openCustomStageSelectionFromGridItem,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'DropShipProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AirDropShipModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            initialDropShipWave: hint?.dropShipWave,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'SpermWhaleModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpermWhaleModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'GlacierModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GlacierModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: (onSelected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZombieSelectionScreen(
                    stateBucketId: _selectionStateBucketId,
                    editorCubit: _ec,
                    levelFile: _ec.state.levelFile,
                    onAddModule: (objClass) {
                      _addModule(ModuleRegistry.getMetadata(objClass));
                    },
                    multiSelect: false,
                    onZombieSelected: (id) {
                      Navigator.pop(context);
                      onSelected(id);
                    },
                    onMultiZombieSelected: (_) {},
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'HeianWindModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HeianWindModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            initialWaveNumber: hint?.heianWindWaveNumber,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'RenaiModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RenaiModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'SmokePollutionModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmokePollutionModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'BronzeProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BronzeModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'ArmrackProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArmrackModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            initialModuleWave: hint?.gridOverrideModuleWave,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'EnergyGridProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnergyGridModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            initialModuleWave: hint?.gridOverrideModuleWave,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LunarTerminalModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LunarTerminalModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LevelPowerupModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LevelPowerupModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'LunarMineVeinModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LunarMineVeinModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'GladiatorRowModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GladiatorRowModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            initialWave: hint?.gladiatorWave,
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'RadiationMeteorModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RadiationMeteorModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ZombossBattleModuleProperties') {
      _setActiveModuleTab(EditorTabType.zombossMech, rtid);
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ZombossBattleIntroProperties') {
      _setActiveTab(EditorTabType.zombossMech);
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ZombossLastStandMinigameProperties') {
      _setActiveModuleTab(EditorTabType.zombossBattle, rtid);
      return;
    }
    if (const {
      'VaseBreakerPresetProperties',
      'VaseBreakerArcadeModuleProperties',
      'VaseBreakerFlowModuleProperties',
    }.contains(objClass)) {
      _setActiveTab(EditorTabType.vaseBreaker);
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'PennyClassroomModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PennyClassroomModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onAddModule: (objClass) =>
                _addModule(ModuleRegistry.getMetadata(objClass)),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ManholePipelineModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManholePipelineModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'PowerTileProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PowerTilePropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'RoofProperties') {
      if (_ec.state.parsedData!.levelDef != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoofPropertiesScreen(
              rtid: rtid,
              levelFile: _ec.state.levelFile!,
              levelDef: _ec.state.parsedData!.levelDef!,
              onChanged: _markDirty,
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      }
      return;
    }
    if (info.source == 'CurrentLevel' && objClass == 'WarMistProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WarMistPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (objClass == 'RainDarkProperties') {
      if (_ec.state.parsedData!.levelDef != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RainDarkPropertiesScreen(
              currentRtid: rtid,
              levelDef: _ec.state.parsedData!.levelDef!,
              onChanged: _markDirty,
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      }
      return;
    }
    if (objClass == 'LawnMowerProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LawnMowerPropertiesScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'TunnelDefendModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TunnelDefendModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'InitialGridItemGulliverTunnelProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GulliverTunnelModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'ZombieRushModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZombieRushModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'WaveManagerModuleProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaveManagerModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: _openZombieSelection,
            onOpenWaveTimeline: () {
              Navigator.pop(context);
              _setActiveTab(EditorTabType.timeline);
            },
          ),
        ),
      );
      return;
    }
    if (info.source == 'CurrentLevel' &&
        objClass == 'WaveGeneratorProperties') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaveGeneratorModuleScreen(
            rtid: rtid,
            levelFile: _ec.state.levelFile!,
            onChanged: _markDirty,
            onBack: () => Navigator.pop(context),
            onRequestZombieSelection: _openZombieSelection,
          ),
        ),
      );
      return;
    }

    // Fallback: Use UnknownModuleScreen for local objects without editor, or show message for references
    if (info.source == 'CurrentLevel' && obj != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UnknownModuleScreen(onBack: () => Navigator.pop(context)),
        ),
      );
    } else {
      final l10n = AppLocalizations.of(context);
      AppMessage.show(
        context,
        l10n?.moduleEditorInProgress ?? 'Module editor in development',
        icon: Icons.info_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool useCompactActions = screenWidth < 500;

    return BlocListener<EditorCubit, EditorState>(
      listenWhen: (previous, current) =>
          current.loadErrorKind != null &&
          previous.loadErrorKind != current.loadErrorKind,
      listener: (context, state) {
        final kind = state.loadErrorKind;
        if (kind == null) return;
        final l10n = AppLocalizations.of(context);
        AppMessage.show(
          context,
          _rtonErrorMessage(l10n, kind),
          icon: Icons.error_outline,
        );
      },
      child: BlocBuilder<EditorCubit, EditorState>(
        builder: (context, editorState) {
          final l10n = AppLocalizations.of(context);
          final editorTopTabs = _editorTopTabEntries();
          Widget body = Scaffold(
            appBar: AppBar(
              title: Text(_ec.fileName, overflow: TextOverflow.ellipsis),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _leaveEditorIfAllowed,
              ),
              actions: [
                if (!useCompactActions) ...[
                  IconButton(
                    icon: const Icon(Icons.code),
                    tooltip: l10n?.tooltipJsonViewer ?? 'View/edit JSON',
                    onPressed: _ec.state.levelFile != null
                        ? () async {
                            final hadChanges = _ec.state.hasChanges;
                            await _save();
                            if (!mounted) return;
                            if (hadChanges) {
                              // Let the banner start its fade-in before the route covers the frame.
                              await Future<void>.delayed(
                                const Duration(milliseconds: 32),
                              );
                              if (!mounted) return;
                            }
                            WidgetsBinding.instance.addPostFrameCallback((
                              _,
                            ) async {
                              if (!context.mounted) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JsonViewerScreen(
                                    fileName: _ec.fileName,
                                    filePath: _ec.filePath,
                                    levelFile: _ec.state.levelFile!,
                                    onBack: () => Navigator.pop(context),
                                    onSaved: () => _ec.onJsonViewerSaved(),
                                  ),
                                ),
                              );
                            });
                          }
                        : null,
                  ),
                ],
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: l10n?.tooltipSave ?? 'Save',
                      onPressed: _ec.state.hasChanges ? _save : null,
                    );
                  },
                ),
                ...pluginEditorAppBarActions(context),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    if (useCompactActions) ...[
                      PopupMenuItem(
                        value: 'json',
                        enabled: _ec.state.levelFile != null,
                        child: EditorPopupMenuTile(
                          enabled: _ec.state.levelFile != null,
                          leading: const Icon(Icons.code),
                          title: Text(
                            l10n?.tooltipJsonViewer ?? 'View/edit JSON',
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                    ],
                    PopupMenuItem(
                      value: 'lang',
                      child: EditorPopupMenuTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n?.language ?? 'Language'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'ui',
                      child: EditorPopupMenuTile(
                        leading: const Icon(Icons.aspect_ratio),
                        title: Text(l10n?.uiSize ?? 'UI size'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'theme',
                      child: EditorPopupMenuTile(
                        leading: Icon(
                          settings.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        title: Text(l10n?.toggleTheme ?? 'Toggle theme'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'autosave',
                      child: EditorPopupMenuTile(
                        leading: const Icon(Icons.save_outlined),
                        title: Text(
                          settings.autosave
                              ? (l10n?.autosaveOn ?? 'Autosave: on')
                              : (l10n?.autosaveOff ?? 'Autosave: off'),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'level_overview',
                      enabled: _ec.state.levelFile != null,
                      child: EditorPopupMenuTile(
                        enabled: _ec.state.levelFile != null,
                        leading: const Icon(Icons.visibility),
                        title: Text(l10n?.levelOverview ?? 'Level Overview'),
                      ),
                    ),
                    ...pluginOverflowMenuItems(
                      context: context,
                      slot: CPluginUiSlots.editorOverflow,
                      valuePrefix: 'plugin:',
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'json') {
                      final hadChanges = _ec.state.hasChanges;
                      await _save();
                      if (!mounted) return;
                      if (hadChanges) {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 32),
                        );
                        if (!mounted) return;
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JsonViewerScreen(
                              fileName: _ec.fileName,
                              filePath: _ec.filePath,
                              levelFile: _ec.state.levelFile!,
                              onBack: () => Navigator.pop(context),
                              onSaved: () => _ec.onJsonViewerSaved(),
                            ),
                          ),
                        );
                      });
                    } else if (value == 'lang') {
                      widget.onLanguageTap(context);
                    } else if (value == 'ui') {
                      _showUiScaleDialog(context);
                    } else if (value == 'theme') {
                      context.read<SettingsCubit>().cycleTheme();
                    } else if (value == 'autosave') {
                      showAutosaveSettingsDialog(context);
                    } else if (value == 'level_overview') {
                      await openLevelOverviewFromOpenSession(context);
                    } else {
                      handlePluginOverflowSelection(
                        context,
                        value: value,
                        valuePrefix: 'plugin:',
                        slot: CPluginUiSlots.editorOverflow,
                      );
                    }
                  },
                ),
              ],
            ),
            body: _ec.state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ec.state.levelFile == null || _ec.state.parsedData == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Text(
                          l10n?.failedToLoadLevel ?? 'Failed to load level',
                          key: const ValueKey('level-load-failure-message'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : DefaultTabController(
                    length: editorTopTabs.length,
                    child: Builder(
                      builder: (context) {
                        _tabController = DefaultTabController.of(context);
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final topTabLabels = <String>[];
                            final topTabWidgets = editorTopTabs.map((entry) {
                              final t = entry.type;
                              IconData icon;
                              String label;
                              switch (t) {
                                case EditorTabType.settings:
                                  icon = Icons.settings;
                                  label = l10n?.settings ?? 'Settings';
                                  break;
                                case EditorTabType.timeline:
                                  icon = Icons.timeline;
                                  label = l10n?.timeline ?? 'Timeline';
                                  break;
                                case EditorTabType.waveGenerator:
                                  icon = Icons.waves;
                                  label =
                                      l10n?.waveGeneratorTabLabel ?? 'Waves';
                                  break;
                                case EditorTabType.iZombie:
                                  icon = Icons.groups;
                                  label = l10n?.iZombie ?? 'I, Zombie';
                                  break;
                                case EditorTabType.vaseBreaker:
                                  icon = Icons.inventory_2;
                                  label = l10n?.vaseBreaker ?? 'Vase breaker';
                                  break;
                                case EditorTabType.singleHanded:
                                  icon = Icons.sledding;
                                  label =
                                      l10n?.singleHandedTabLabel ??
                                      'All by Oneself';
                                  break;
                                case EditorTabType.zombossMech:
                                  icon = Icons.smart_toy_outlined;
                                  label = moduleInstanceDisplayName(
                                    baseName:
                                        l10n?.zombossMech ??
                                        'ZombossMech Battle',
                                    objClass: 'ZombossBattleModuleProperties',
                                    instanceCount: entry.instanceCount,
                                    instanceIndex: entry.instanceIndex,
                                  );
                                  break;
                                case EditorTabType.zombossBattle:
                                  icon = Icons.castle;
                                  label = moduleInstanceDisplayName(
                                    baseName:
                                        l10n?.zombossBattle ?? 'Zomboss Battle',
                                    objClass:
                                        'ZombossLastStandMinigameProperties',
                                    instanceCount: entry.instanceCount,
                                    instanceIndex: entry.instanceIndex,
                                  );
                                  break;
                              }
                              topTabLabels.add(label);
                              return Tab(text: label, icon: Icon(icon));
                            }).toList();
                            final tabLabelStyle =
                                Theme.of(context).tabBarTheme.labelStyle ??
                                Theme.of(context).textTheme.titleSmall ??
                                const TextStyle(fontSize: 14);
                            final textScaler = MediaQuery.textScalerOf(context);
                            final requiredTabWidth = topTabLabels.fold<double>(
                              0,
                              (width, label) {
                                final painter = TextPainter(
                                  text: TextSpan(
                                    text: label,
                                    style: tabLabelStyle,
                                  ),
                                  textDirection: Directionality.of(context),
                                  textScaler: textScaler,
                                  maxLines: 1,
                                )..layout();
                                return width + painter.width + 48;
                              },
                            );
                            final shouldScroll =
                                constraints.maxWidth < 600 ||
                                requiredTabWidth > constraints.maxWidth;
                            return Column(
                              children: [
                                if (shouldScroll)
                                  PersistentScrollableTabBar(
                                    controller: _tabController!,
                                    tabs: topTabWidgets,
                                  )
                                else
                                  TabBar(
                                    isScrollable: false,
                                    tabAlignment: TabAlignment.fill,
                                    dividerHeight: 0,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    tabs: topTabWidgets,
                                  ),
                                Expanded(
                                  child: TabBarView(
                                    children: editorTopTabs.map<Widget>((
                                      entry,
                                    ) {
                                      final t = entry.type;
                                      switch (t) {
                                        case EditorTabType.settings:
                                          return LevelSettingsTab(
                                            levelDef:
                                                _ec.state.parsedData!.levelDef,
                                            objectMap:
                                                _ec.state.parsedData!.objectMap,
                                            issues: LevelIssueRegistry.forLevel(
                                              context,
                                              _ec.state.levelFile!,
                                              parsed: _ec.state.parsedData,
                                              editorOnly: true,
                                            ),
                                            onEditBasicInfo:
                                                _handleEditBasicInfo,
                                            onEditModule: _handleEditModule,
                                            onRemoveModule: _handleRemoveModule,
                                            onReorderModules:
                                                _handleReorderModules,
                                            onNavigateToAddModule:
                                                _handleNavigateToAddModule,
                                          );
                                        case EditorTabType.timeline:
                                          return WaveTimelineTab(
                                            levelFile: _ec.state.levelFile!,
                                            parsed: _ec.state.parsedData!,
                                            onChanged: _markDirty,
                                            onEditEvent: _handleEditEvent,
                                            onAddEvent: _handleAddEvent,
                                            onEditWaveManagerSettings:
                                                _handleEditWaveManagerSettings,
                                            onEditCustomZombie:
                                                _handleEditCustomZombie,
                                            onEditCustomFish:
                                                _handleEditCustomFish,
                                            onOpenModule: _handleEditModule,
                                            openWaveSheetNotifier:
                                                _ec.openWaveSheetNotifier,
                                            onCreateContainer: () =>
                                                _handleCreateWaveContainer(),
                                            onDeleteContainer: () =>
                                                _handleDeleteWaveContainer(),
                                          );
                                        case EditorTabType.waveGenerator:
                                          return WaveGeneratorTab(
                                            levelFile: _ec.state.levelFile!,
                                            parsed: _ec.state.parsedData!,
                                            onChanged: _markDirty,
                                            onOpenModule: _handleEditModule,
                                            onEditWaveGeneratorSettings:
                                                _handleEditWaveGeneratorSettings,
                                            onEditWave:
                                                _handleEditWaveGeneratorWave,
                                          );
                                        case EditorTabType.iZombie:
                                          return IZombieTab(
                                            levelFile: _ec.state.levelFile!,
                                            onChanged: _markDirty,
                                          );
                                        case EditorTabType.vaseBreaker:
                                          return VaseBreakerTab(
                                            levelFile: _ec.state.levelFile!,
                                            onChanged: _markDirty,
                                            editorCubit: _ec,
                                            onAddModule: (objClass) {
                                              _addModule(
                                                ModuleRegistry.getMetadata(
                                                  objClass,
                                                ),
                                              );
                                            },
                                          );
                                        case EditorTabType.singleHanded:
                                          return SingleHandedTab(
                                            levelFile: _ec.state.levelFile!,
                                            onChanged: _markDirty,
                                            onAddModule: (objClass) {
                                              _addModule(
                                                ModuleRegistry.getMetadata(
                                                  objClass,
                                                ),
                                              );
                                            },
                                            onOpenTutorialModule:
                                                _openSingleHandedTutorialSettings,
                                          );
                                        case EditorTabType.zombossMech:
                                          return ZombossMechBattleTab(
                                            key: ValueKey(entry.moduleRtid),
                                            levelFile: _ec.state.levelFile!,
                                            onChanged: _markDirty,
                                            moduleRtid: entry.moduleRtid,
                                            onOpenGlacierModule:
                                                _openGlacierModuleSettings,
                                            onOpenInitialGridItems:
                                                _openInitialGridItemSettings,
                                          );
                                        case EditorTabType.zombossBattle:
                                          return ZombossBattleTab(
                                            key: ValueKey(entry.moduleRtid),
                                            levelFile: _ec.state.levelFile!,
                                            onChanged: _markDirty,
                                            onAutoModulesEnsured:
                                                _ec.refreshParsedData,
                                            moduleRtid: entry.moduleRtid,
                                          );
                                      }
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
          );
          // Desktop Escape is handled globally by _DesktopEscapeHandler in
          // app.dart. A local Shortcuts binding here used to also fire and
          // leave the editor in the same keypress after Overview closed.
          return body;
        },
      ),
    );
  }

  String _rtonErrorMessage(AppLocalizations? l10n, RtonErrorKind kind) {
    if (l10n == null) return RtonFormatException(kind).message;
    switch (kind) {
      case RtonErrorKind.invalidMagic:
        return l10n.invalidRtonMagic;
      case RtonErrorKind.invalidVersion:
        return l10n.invalidRtonVersion;
      case RtonErrorKind.invalidEnd:
        return l10n.invalidRtonEnd;
      case RtonErrorKind.invalidArrayEnd:
        return l10n.invalidRtonArrayEnd;
      case RtonErrorKind.invalidRtid:
        return l10n.invalidRtid;
      case RtonErrorKind.invalidValueType:
        return l10n.invalidValueType;
    }
  }
}

class EditorUiScalePresetLabels extends StatelessWidget {
  const EditorUiScalePresetLabels({
    super.key,
    required this.currentScale,
    required this.onPresetSelected,
    required this.smallLabel,
    required this.standardLabel,
    required this.largeLabel,
    required this.ultraLabel,
  });

  static const double smallScale = 0.75;
  static const double standardScale = 1.0;
  static const double largeScale = 1.25;
  static const double ultraScale = 1.5;
  static const double _presetTolerance = 0.0001;

  final double currentScale;
  final ValueChanged<double> onPresetSelected;
  final String smallLabel;
  final String standardLabel;
  final String largeLabel;
  final String ultraLabel;

  bool _isSelected(double scale) {
    return (currentScale - scale).abs() <= _presetTolerance;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _UiScalePresetLabel(
          label: smallLabel,
          scale: smallScale,
          alignment: Alignment.centerLeft,
          isSelected: _isSelected(smallScale),
          onSelected: onPresetSelected,
        ),
        _UiScalePresetLabel(
          label: standardLabel,
          scale: standardScale,
          alignment: Alignment.center,
          isSelected: _isSelected(standardScale),
          onSelected: onPresetSelected,
        ),
        _UiScalePresetLabel(
          label: largeLabel,
          scale: largeScale,
          alignment: Alignment.center,
          isSelected: _isSelected(largeScale),
          onSelected: onPresetSelected,
        ),
        _UiScalePresetLabel(
          label: ultraLabel,
          scale: ultraScale,
          alignment: Alignment.centerRight,
          isSelected: _isSelected(ultraScale),
          onSelected: onPresetSelected,
        ),
      ],
    );
  }
}

/// Owns its [TextEditingController] so dispose cannot race dialog route teardown.
/// Uses [Dialog] (not [AlertDialog]) to avoid IntrinsicWidth + LayoutBuilder crashes.
class _CustomStageAliasPromptDialog extends StatefulWidget {
  const _CustomStageAliasPromptDialog({required this.initialAlias});

  final String initialAlias;

  @override
  State<_CustomStageAliasPromptDialog> createState() =>
      _CustomStageAliasPromptDialogState();
}

class _CustomStageAliasPromptDialogState
    extends State<_CustomStageAliasPromptDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAlias);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = MediaQuery.sizeOf(context).width - 48;
    final dialogW = available < 420 ? (available < 1 ? 1.0 : available) : 420.0;

    return EscapeClosesModal(
      child: Dialog(
        child: SizedBox(
          width: dialogW,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.customStageAliasPromptTitle ?? 'Custom stage alias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n?.customStageAlias ?? 'Stage alias',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => safeNavPop(context),
                        child: Text(l10n?.cancel ?? 'Cancel'),
                      ),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(l10n?.confirm ?? 'Confirm'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UiScalePresetLabel extends StatelessWidget {
  const _UiScalePresetLabel({
    required this.label,
    required this.scale,
    required this.alignment,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final double scale;
  final AlignmentGeometry alignment;
  final bool isSelected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: isSelected ? theme.colorScheme.primary : null,
      fontWeight: isSelected ? FontWeight.bold : null,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => onSelected(scale),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: alignment,
            widthFactor: 1,
            heightFactor: 1,
            child: Text(label, style: style),
          ),
        ),
      ),
    );
  }
}
