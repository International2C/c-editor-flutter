import 'package:c_editor/data/statue_maze_validation.dart';
import 'package:c_editor/data/oak_train_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/glacier_module_presets.dart';
import 'package:c_editor/data/camel_minigame_utils.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';

/// How serious a level issue is. Errors use red conflict styling; warnings use
/// the yellow [EditorWarningBanner] styling.
enum LevelIssueSeverity { warning, error }

/// One entry of `LevelDefinition.Modules`, resolved to its object class.
class LevelModuleRef {
  const LevelModuleRef({
    required this.rtid,
    required this.alias,
    required this.objClass,
    required this.objData,
    required this.isCurrentLevel,
  });

  final String rtid;
  final String alias;
  final String objClass;
  final dynamic objData;
  final bool isCurrentLevel;

  bool get isExpeditionTiles => isExpeditionTilesModule(
    alias: alias,
    objClass: objClass,
    objData: objData,
  );
}

bool isExpeditionTilesModule({
  required String alias,
  required String? objClass,
  required dynamic objData,
}) {
  if (objClass != 'TunnelDefendModuleProperties') return false;
  if (alias == 'SouDaCheTunnelDefendDefault' ||
      alias.startsWith('SoudacheTunnelDefendStage')) {
    return true;
  }
  if (objData is Map) {
    return (objData['BrickMapIndex'] as num?)?.toInt() == 3;
  }
  return false;
}

/// Everything a [LevelIssueRule] may inspect. Built once per evaluation.
class LevelIssueContext {
  LevelIssueContext._({
    required this.levelFile,
    required this.parsed,
    required this.modules,
  }) : moduleObjClasses = modules.map((m) => m.objClass).toSet(),
       objectObjClasses = levelFile.objects.map((o) => o.objClass).toSet();

  factory LevelIssueContext.fromLevel(
    PvzLevelFile levelFile, {
    ParsedLevelData? parsed,
  }) {
    final data = parsed ?? LevelParser.parseLevel(levelFile);
    final modules = <LevelModuleRef>[];
    for (final rtid in data.levelDef?.modules ?? const <String>[]) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      if (info.source == 'CurrentLevel') {
        final obj =
            data.objectMap[info.alias] ??
            levelFile.objects.firstWhereOrNull(
              (o) => o.aliases?.contains(info.alias) == true,
            );
        if (obj == null) continue;
        modules.add(
          LevelModuleRef(
            rtid: rtid,
            alias: info.alias,
            objClass: obj.objClass,
            objData: obj.objData,
            isCurrentLevel: true,
          ),
        );
      } else if (info.source == 'LevelModules') {
        final ref = ReferenceRepository.instance.objectForAlias(info.alias);
        final objClass = ref?.objClass ?? _objClassForStockAlias(info.alias);
        if (objClass == null) continue;
        modules.add(
          LevelModuleRef(
            rtid: rtid,
            alias: info.alias,
            objClass: objClass,
            objData: ref?.objData,
            isCurrentLevel: false,
          ),
        );
      }
    }
    return LevelIssueContext._(
      levelFile: levelFile,
      parsed: data,
      modules: modules,
    );
  }

  static String? _objClassForStockAlias(String alias) {
    for (final entry in ModuleRegistry.registry.entries) {
      if (entry.value.defaultAlias == alias) return entry.key;
    }
    return null;
  }

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final List<LevelModuleRef> modules;
  final Set<String> moduleObjClasses;
  final Set<String> objectObjClasses;

  Set<String>? _plantIds;
  Map<String, List<String>>? _plantsNeedingMissingModules;

  LevelDefinitionData? get levelDef => parsed.levelDef;

  bool hasModule(String objClass) => moduleObjClasses.contains(objClass);

  bool hasModuleOrObject(String objClass) =>
      moduleObjClasses.contains(objClass) ||
      objectObjClasses.contains(objClass);

  bool get hasTunnelDefend => modules.any(
    (m) => m.objClass == 'TunnelDefendModuleProperties' && !m.isExpeditionTiles,
  );

  bool get hasExpeditionTiles => modules.any((m) => m.isExpeditionTiles);

  PvzObject? firstObject(String objClass) =>
      levelFile.objects.firstWhereOrNull((o) => o.objClass == objClass) ??
      parsed.objectMap.values.firstWhereOrNull((o) => o.objClass == objClass);

  String get stageAlias =>
      RtidParser.parse(levelDef?.stageModule ?? '')?.alias ?? '';

  Set<String> get plantIds => _plantIds ??= _collectPlantIds();

  /// Missing companion modules required by plants in the level
  /// (module objClass → plant ids).
  Map<String, List<String>> get plantsNeedingMissingModules =>
      _plantsNeedingMissingModules ??= _computePlantsNeedingMissingModules();

  Set<String> _collectPlantIds() {
    final out = <String>{};
    for (final obj in levelFile.objects) {
      _collectPlantIdsFromDynamic(obj.objData, out);
    }
    return out;
  }

  Map<String, List<String>> _computePlantsNeedingMissingModules() {
    final repo = PlantRepository();
    final warnings = <String, Set<String>>{};
    for (final plantId in plantIds) {
      final info = repo.getPlantInfoById(plantId);
      if (info == null) continue;
      for (final entry in LevelIssueRegistry.plantInternalTagToModule.entries) {
        if (!info.hasInternalTag(entry.key)) continue;
        final moduleClass = entry.value;
        if (moduleObjClasses.contains(moduleClass)) continue;
        warnings.putIfAbsent(moduleClass, () => {}).add(plantId);
      }
    }
    return warnings.map((k, v) => MapEntry(k, v.toList()..sort()));
  }

  static void _collectPlantIdsFromDynamic(dynamic data, Set<String> out) {
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
}

typedef LevelIssuePredicate = bool Function(LevelIssueContext ctx);
typedef LevelIssueText =
    String Function(BuildContext context, AppLocalizations l10n);
typedef LevelIssueBullets =
    List<String> Function(
      BuildContext context,
      AppLocalizations l10n,
      LevelIssueContext ctx,
    );

/// Emits zero or more issues (for plant-gated missing modules, etc.).
typedef LevelIssueEmitter =
    List<LevelIssue> Function(
      BuildContext context,
      AppLocalizations l10n,
      LevelIssueContext ctx,
    );

/// Declarative level issue: conflicts, missing modules, advisories.
class LevelIssueRule {
  const LevelIssueRule({
    required this.id,
    this.severity = LevelIssueSeverity.warning,
    this.showInEditor = true,
    this.isActive,
    this.title,
    this.message,
    this.bulletPoints,
    this.emit,
  }) : assert(
         emit != null || (isActive != null && title != null && message != null),
         'Provide either emit, or isActive + title + message',
       );

  final String id;
  final LevelIssueSeverity severity;
  final bool showInEditor;
  final LevelIssuePredicate? isActive;
  final LevelIssueText? title;
  final LevelIssueText? message;
  final LevelIssueBullets? bulletPoints;
  final LevelIssueEmitter? emit;
}

/// A resolved, localized issue ready for display or export validation.
class LevelIssue {
  const LevelIssue({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
    this.bulletPoints = const [],
  });

  final String id;
  final LevelIssueSeverity severity;
  final String title;
  final String message;
  final List<String> bulletPoints;

  bool get isError => severity == LevelIssueSeverity.error;
}

/// Pairwise module conflict definition (all listed classes present → error).
class ModuleConflictRule {
  const ModuleConflictRule({
    required this.conflictingClasses,
    this.descriptionKey,
  });

  final Set<String> conflictingClasses;
  final String? descriptionKey;
}

/// Single registry for level conflicts (errors), missing-module advisories,
/// plant-gated requirements, and other warnings.
class LevelIssueRegistry {
  static const glacierModule = 'GlacierModuleProperties';
  static const zombossBattleModule = 'ZombossBattleModuleProperties';
  static const seeingStarsModule = 'PVZ1SeeingStarsModuleProperties';
  static const statueMazeModule = 'StatueMazeModuleProperties';
  static const zombiesDeadWinCon = 'ZombiesDeadWinConProperties';
  static const bronzeDeadWinCon = 'BronzeDeadWinConProperties';

  static const plantInternalTagToModule = {
    'parallel': 'UnchartedModeNo42UniverseModule',
    'mausoleum': 'PVZ2MausoleumModuleUnchartedMode',
    '_internal_copycats': 'PVZ1CopycatsModuleProperties',
  };

  static const List<ModuleConflictRule> conflictModuleRules = [
    ModuleConflictRule(
      conflictingClasses: {'SeedBankProperties', 'ConveyorSeedBankProperties'},
      descriptionKey: 'conflictDesc_SeedBankConveyor',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'VaseBreakerPresetProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_VaseBreakerIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'LastStandMinigameProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_LastStandIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CowboyMinigameProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_CowboyIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'SingleHandedProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_SingleHandedIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'IntroSingleHandedProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_SingleHandedTutorialIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CamelMinigameProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_CamelMinigameIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {'EvilDaveProperties', 'ZombiesDeadWinConProperties'},
      descriptionKey: 'conflictDesc_EvilDaveZombieDrop',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'EvilDaveProperties',
        'ZombiesAteYourBrainsProperties',
      },
      descriptionKey: 'conflictDesc_EvilDaveVictory',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'ZombossBattleModuleProperties',
        'ZombiesDeadWinConProperties',
      },
      descriptionKey: 'conflictDesc_ZombossDeathDrop',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'ZombossBattleIntroProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_ZombossTwoIntros',
    ),
    ModuleConflictRule(
      conflictingClasses: {'InitialPlantEntryProperties', 'RoofProperties'},
      descriptionKey: 'conflictDesc_InitialPlantEntryRoof',
    ),
    ModuleConflictRule(
      conflictingClasses: {'InitialPlantProperties', 'RoofProperties'},
      descriptionKey: 'conflictDesc_InitialPlantRoof',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'ProtectThePlantChallengeProperties',
        'RoofProperties',
      },
      descriptionKey: 'conflictDesc_ProtectPlantRoof',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CustomLevelModuleProperties',
        'LawnMowerProperties',
      },
      descriptionKey: 'conflictDesc_LawnMowerYard',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CustomLevelModuleProperties',
        'MoonExpertProperties',
      },
      descriptionKey: 'conflictDesc_MoonExpertYard',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'WaveGeneratorProperties',
        'WaveManagerModuleProperties',
      },
      descriptionKey: 'conflictDesc_WaveGeneratorWaveManagerModule',
    ),
    ModuleConflictRule(
      conflictingClasses: {'WaveGeneratorProperties', 'WaveManagerProperties'},
      descriptionKey: 'conflictDesc_WaveGeneratorWaveManager',
    ),
  ];

  static final List<LevelIssueRule> rules = [
    // --- Conflicts (errors) ---
    ...conflictModuleRules.map(_conflictRule),
    LevelIssueRule(
      id: 'statueMazeMissingRotations',
      severity: LevelIssueSeverity.error,
      emit: (context, l10n, ctx) => [
        for (final module in ctx.modules.where(
          (m) => m.objClass == statueMazeModule,
        ))
          if (statueMazeRoundsWithoutRotations(module.objData).isNotEmpty)
            LevelIssue(
              id: 'statueMazeMissingRotations_${module.rtid}',
              severity: LevelIssueSeverity.error,
              title: l10n.conflictTitle_ModuleLogic,
              message: l10n.statueMazeMissingRotationsWarning(
                statueMazeRoundsWithoutRotations(module.objData).join(', '),
              ),
            ),
      ],
    ),
    LevelIssueRule(
      id: 'conflict_winConditionExclusive',
      severity: LevelIssueSeverity.error,
      isActive: (ctx) =>
          ctx.moduleObjClasses
              .where((c) => c.endsWith('WinConProperties'))
              .length >
          1,
      title: (_, l10n) => l10n.conflictTitle_ModuleLogic,
      message: (_, l10n) => l10n.conflictDesc_WinConditionExclusive,
    ),

    // --- Plant-gated missing modules (errors) ---
    LevelIssueRule(
      id: 'missingPlantModules',
      severity: LevelIssueSeverity.error,
      emit: (context, l10n, ctx) {
        final repo = PlantRepository();
        return [
          for (final entry in ctx.plantsNeedingMissingModules.entries)
            LevelIssue(
              id: 'missingPlantModule_${entry.key}',
              severity: LevelIssueSeverity.error,
              title: l10n.missingPlantModuleWarningTitle,
              message: l10n.missingModuleForPlantsWarning(
                ModuleRegistry.getMetadata(entry.key).getTitle(context),
                entry.value
                    .map((id) => _plantDisplayName(context, repo, id))
                    .join(', '),
              ),
            ),
        ];
      },
    ),

    // --- Missing essentials (warning with bullets) ---
    LevelIssueRule(
      id: 'missingEssentials',
      isActive: (ctx) => _missingEssentialClasses(ctx).isNotEmpty,
      title: (_, l10n) => l10n.missingModules,
      message: (_, l10n) => l10n.missingModulesRecommended,
      bulletPoints: (context, _, ctx) => _missingEssentialClasses(ctx)
          .map((cls) => ModuleRegistry.getMetadata(cls).getTitle(context))
          .where((title) => title.isNotEmpty)
          .toList(),
    ),

    // --- Advisories ---
    LevelIssueRule(
      id: 'camelMinigameChooserConflict',
      severity: LevelIssueSeverity.error,
      isActive: (ctx) =>
          ctx.hasModule(CamelMinigameUtils.moduleClass) &&
          ctx.modules.any(
            (module) =>
                module.objClass == 'SeedBankProperties' &&
                module.objData is Map &&
                ((module.objData as Map)['SelectionMethod'] ?? 'chooser') ==
                    'chooser',
          ),
      title: (_, l10n) => l10n.conflictTitle_ModuleLogic,
      message: (_, l10n) => l10n.conflictDesc_CamelMinigameChooser,
    ),
    LevelIssueRule(
      id: 'camelMinigameNonTouchZombies',
      emit: (context, l10n, ctx) {
        if (!ctx.hasModule(CamelMinigameUtils.moduleClass)) return [];
        final zombies = CamelMinigameUtils.incompatibleZombies(ctx.levelFile);
        if (zombies.isEmpty) return [];
        return [
          LevelIssue(
            id: 'camelMinigameNonTouchZombies',
            severity: LevelIssueSeverity.error,
            title: l10n.conflictTitle_ModuleLogic,
            message: l10n.conflictDesc_CamelMinigameNonTouchZombies(
              zombies
                  .map(
                    (id) => ZombieDisplayUtils.localizedName(
                      context,
                      typeOrRtid: id,
                      levelFile: ctx.levelFile,
                    ),
                  )
                  .join(', '),
            ),
          ),
        ];
      },
    ),
    LevelIssueRule(
      id: 'oakTrainTutorialIntroWarning',
      isActive: (ctx) =>
          ctx.hasModule('OakTrainIntroProperties') &&
          ctx.hasModule('StandardLevelIntroProperties'),
      title: (_, l10n) => l10n.oakTrainTutorialIntroWarningTitle,
      message: (_, l10n) => l10n.oakTrainTutorialIntroWarning,
    ),
    LevelIssueRule(
      id: 'oakTrainUnderwaterWarning',
      isActive: (ctx) =>
          ctx.hasModule('OakTrainProperties') &&
          OakTrainUtils.needsOxygenSupport(ctx.levelFile),
      title: (_, l10n) => l10n.oakTrainUnderwaterWarningTitle,
      message: (_, l10n) => l10n.oakTrainUnderwaterWarning,
    ),
    LevelIssueRule(
      id: 'targetZombieInWaveManagerWarning',
      isActive: (ctx) =>
          ctx.hasModule('WaveManagerModuleProperties') &&
          OakTrainUtils.hasIncompatibleWaveSpawns(ctx.levelFile),
      title: (_, l10n) => l10n.targetZombieInWaveManagerWarningTitle,
      message: (_, l10n) => l10n.targetZombieInWaveManagerWarning,
    ),
    LevelIssueRule(
      id: 'goldRoadNonLostCityLawnWarning',
      isActive: (ctx) =>
          ctx.hasModule('GoldRoadProperties') &&
          LevelParser.resolveStageObjdata(ctx.levelDef, ctx.levelFile) !=
              null &&
          !LevelParser.usesLostCityBackground(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.goldRoadNonLostCityLawnWarningTitle,
      message: (_, l10n) => l10n.goldRoadNonLostCityLawnWarning,
    ),
    LevelIssueRule(
      id: 'goldRoadDeepseaLawnWarning',
      isActive: (ctx) =>
          ctx.hasModule('GoldRoadProperties') &&
          LevelParser.usesDeepSeaBackground(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.goldRoadDeepseaLawnWarningTitle,
      message: (_, l10n) => l10n.goldRoadDeepseaLawnWarning,
    ),
    LevelIssueRule(
      id: 'cowboyMinigameConveyorWarning',
      isActive: (ctx) =>
          ctx.hasModule('CowboyMinigameProperties') &&
          !ctx.hasModule('ConveyorSeedBankProperties'),
      title: (_, l10n) => l10n.cowboyMinigameDependencyWarningTitle,
      message: (_, l10n) => l10n.cowboyMinigameConveyorWarning,
    ),
    LevelIssueRule(
      id: 'seeingStarsWinConWarning',
      isActive: (ctx) =>
          ctx.hasModule(seeingStarsModule) &&
          (ctx.hasModule(zombiesDeadWinCon) ||
              ctx.hasModule(bronzeDeadWinCon) ||
              ctx.hasModule('ZombieRushModuleProperties') ||
              ctx.hasModule(statueMazeModule)),
      title: (_, l10n) => l10n.seeingStarsWinConWarningTitle,
      message: (_, l10n) => l10n.seeingStarsWinConWarning,
    ),
    LevelIssueRule(
      id: 'seeingStarsCompatibilityWarning',
      isActive: (ctx) =>
          ctx.hasModule(seeingStarsModule) &&
          ctx.hasModule('WaveGeneratorProperties'),
      title: (_, l10n) => l10n.seeingStarsCompatibilityWarningTitle,
      message: (_, l10n) => l10n.seeingStarsCompatibilityWarning,
    ),
    LevelIssueRule(
      id: 'glacierModuleCompatibilityWarning',
      isActive: (ctx) =>
          ctx.hasModule(glacierModule) &&
          !ctx.modules.any(
            (module) =>
                module.objClass == zombossBattleModule &&
                module.objData is Map &&
                ZombossMechRepository.isIceAgeMechVariation(
                  (module.objData as Map)['ZombossMechType'] as String?,
                ),
          ),
      title: (_, l10n) => l10n.glacierModuleCompatibilityWarningTitle,
      message: (_, l10n) => l10n.glacierModuleCompatibilityWarning,
    ),
    LevelIssueRule(
      id: 'glacierModuleUnderwaterWarning',
      isActive: (ctx) =>
          ctx.hasModule(glacierModule) &&
          LevelParser.isDeepSeaLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.glacierModuleUnderwaterWarningTitle,
      message: (_, l10n) => l10n.glacierModuleUnderwaterWarning,
    ),
    LevelIssueRule(
      id: 'iceAgePlantPuzzleWarning',
      isActive: (ctx) =>
          ctx.hasModule(glacierModule) &&
          ctx.modules.any(
            (module) =>
                module.objClass == zombossBattleModule &&
                module.objData is Map &&
                GlacierModulePresets.isPlantPuzzleVariation(
                  (module.objData as Map)['ZombossMechType'] as String?,
                ),
          ),
      title: (_, l10n) => l10n.iceAgePlantPuzzleVariationWarningTitle,
      message: (_, l10n) => l10n.iceAgePlantPuzzleVariationWarning,
    ),
    LevelIssueRule(
      id: 'recommendedTunnelDefend',
      isActive: (ctx) {
        final alias = ctx.stageAlias;
        if (alias != 'UnchartedMausoleumStage' &&
            alias != 'UnchartedMausoleum2Stage') {
          return false;
        }
        return !ctx.hasTunnelDefend && !ctx.hasExpeditionTiles;
      },
      title: (_, l10n) => l10n.recommendedTunnelDefendTitle,
      message: (_, l10n) => l10n.recommendedTunnelDefendBody,
    ),
    LevelIssueRule(
      id: 'recommendedExpeditionTiles',
      isActive: (ctx) =>
          !ctx.hasExpeditionTiles &&
          !ctx.hasTunnelDefend &&
          !LevelParser.isUnderwaterWorldSixRowLawn(
            ctx.levelDef,
            ctx.levelFile,
          ) &&
          LevelParser.isSouDaCheLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.recommendedExpeditionTilesTitle,
      message: (_, l10n) => l10n.recommendedExpeditionTilesBody,
    ),
    LevelIssueRule(
      id: 'tunnelExpeditionCompatibilityWarning',
      isActive: (ctx) => ctx.hasTunnelDefend && ctx.hasExpeditionTiles,
      title: (_, l10n) => l10n.tunnelExpeditionCompatibilityWarningTitle,
      message: (_, l10n) => l10n.tunnelExpeditionCompatibilityWarningBody,
    ),
    LevelIssueRule(
      id: 'expeditionTilesUnderwaterMismatch',
      severity: LevelIssueSeverity.error,
      isActive: (ctx) =>
          ctx.hasExpeditionTiles &&
          LevelParser.isUnderwaterWorldSixRowLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.stageMismatch,
      message: (_, l10n) => l10n.expeditionTilesUnderwaterMismatchWarning,
    ),
    LevelIssueRule(
      id: 'gladiatorWaveGeneratorCompatibilityWarning',
      isActive: (ctx) =>
          ctx.hasModule('GladiatorRowModuleProperties') &&
          ctx.hasModule('WaveGeneratorProperties'),
      title: (_, l10n) => l10n.gladiatorCompatibilityWarningTitle,
      message: (_, l10n) => l10n.gladiatorWaveGeneratorCompatibilityWarning,
    ),
    LevelIssueRule(
      id: 'gladiatorRowUnderwaterMismatch',
      isActive: (ctx) =>
          ctx.hasModule('GladiatorRowModuleProperties') &&
          LevelParser.isUnderwaterWorldSixRowLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.stageMismatch,
      message: (_, l10n) => l10n.gladiatorUnderwaterMismatchWarning,
    ),
    LevelIssueRule(
      id: 'sixRowDataInFiveRowStage',
      showInEditor: false,
      isActive: (ctx) {
        final (rows, _) = LevelParser.getGridDimensions(
          ctx.levelDef,
          ctx.levelFile,
        );
        if (rows >= 6) return false;
        return LevelParser.has6RowDataInLevel(ctx.levelFile);
      },
      title: (_, l10n) => l10n.warning,
      message: (_, l10n) => l10n.warningStageSwitchedTo5Rows,
    ),
  ];

  static LevelIssueRule _conflictRule(ModuleConflictRule rule) {
    final key = rule.descriptionKey ?? rule.conflictingClasses.join('_');
    return LevelIssueRule(
      id: 'conflict_$key',
      severity: LevelIssueSeverity.error,
      isActive: (ctx) =>
          rule.conflictingClasses.every(ctx.moduleObjClasses.contains),
      title: (_, l10n) => l10n.conflictTitle_ModuleLogic,
      message: (context, l10n) => rule.descriptionKey != null
          ? _conflictDescription(l10n, rule.descriptionKey!)
          : _defaultConflictDescription(context, l10n, rule),
    );
  }

  /// Evaluates conflicts against a bare class set (used by tests / legacy API).
  static List<LevelIssue> conflictsForClasses(
    BuildContext context,
    Set<String> existingObjClasses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.conflictTitle_ModuleLogic;
    final result = <LevelIssue>[];
    for (final rule in conflictModuleRules) {
      if (!rule.conflictingClasses.every(existingObjClasses.contains)) {
        continue;
      }
      final key = rule.descriptionKey ?? rule.conflictingClasses.join('_');
      result.add(
        LevelIssue(
          id: 'conflict_$key',
          severity: LevelIssueSeverity.error,
          title: title,
          message: rule.descriptionKey != null
              ? _conflictDescription(l10n, rule.descriptionKey!)
              : _defaultConflictDescription(context, l10n, rule),
        ),
      );
    }
    final winConCount = existingObjClasses
        .where((c) => c.endsWith('WinConProperties'))
        .length;
    if (winConCount > 1) {
      result.add(
        LevelIssue(
          id: 'conflict_winConditionExclusive',
          severity: LevelIssueSeverity.error,
          title: title,
          message: l10n.conflictDesc_WinConditionExclusive,
        ),
      );
    }
    return result;
  }

  static List<LevelIssue> getActiveIssues(
    BuildContext context,
    LevelIssueContext ctx, {
    bool editorOnly = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final out = <LevelIssue>[];
    for (final rule in rules) {
      if (editorOnly && !rule.showInEditor) continue;
      final emit = rule.emit;
      if (emit != null) {
        out.addAll(emit(context, l10n, ctx));
        continue;
      }
      if (!(rule.isActive!(ctx))) continue;
      out.add(
        LevelIssue(
          id: rule.id,
          severity: rule.severity,
          title: rule.title!(context, l10n),
          message: rule.message!(context, l10n),
          bulletPoints: rule.bulletPoints?.call(context, l10n, ctx) ?? const [],
        ),
      );
    }
    return out;
  }

  static List<LevelIssue> forLevel(
    BuildContext context,
    PvzLevelFile levelFile, {
    ParsedLevelData? parsed,
    bool editorOnly = false,
  }) {
    return getActiveIssues(
      context,
      LevelIssueContext.fromLevel(levelFile, parsed: parsed),
      editorOnly: editorOnly,
    );
  }

  static List<String> _missingEssentialClasses(LevelIssueContext ctx) {
    // Only wired modules take effect. Leftover objects must neither satisfy a
    // requirement nor suppress a recommendation for the current configuration.
    final existing = ctx.moduleObjClasses;
    final isVaseBreaker =
        existing.contains('VaseBreakerPresetProperties') ||
        existing.contains('VaseBreakerArcadeModuleProperties') ||
        existing.contains('VaseBreakerFlowModuleProperties');
    final isZombossMechBattle =
        existing.contains('ZombossBattleModuleProperties') ||
        existing.contains('ZombossBattleIntroProperties');
    final isZombossBattle = existing.contains(
      'ZombossLastStandMinigameProperties',
    );
    final isLastStand = existing.contains('LastStandMinigameProperties');
    final isCowboyMinigame = existing.contains('CowboyMinigameProperties');
    final isSingleHanded = existing.contains('SingleHandedProperties');
    final isSingleHandedTutorial = existing.contains(
      'IntroSingleHandedProperties',
    );
    final isEvilDave = existing.contains('EvilDaveProperties');
    final isSeeingStars = existing.contains(seeingStarsModule);

    final missing = <String>[];
    if (!existing.contains('CustomLevelModuleProperties')) {
      missing.add('CustomLevelModuleProperties');
    }
    if (!existing.contains('ZombiesAteYourBrainsProperties') && !isEvilDave) {
      missing.add('ZombiesAteYourBrainsProperties');
    }
    if (!existing.any((cls) => cls.endsWith('WinConProperties')) &&
        !isEvilDave &&
        !isZombossMechBattle &&
        !isZombossBattle &&
        !isSeeingStars) {
      missing.add(zombiesDeadWinCon);
    }
    if (!existing.contains('StandardLevelIntroProperties') &&
        !isVaseBreaker &&
        !isLastStand &&
        !isCowboyMinigame &&
        !isSingleHanded &&
        !isSingleHandedTutorial &&
        !ctx.hasModule('OakTrainIntroProperties') &&
        !isZombossMechBattle &&
        !isZombossBattle &&
        !existing.contains(CamelMinigameUtils.moduleClass)) {
      missing.add('StandardLevelIntroProperties');
    }
    if (isVaseBreaker) {
      if (!existing.contains('VaseBreakerPresetProperties')) {
        missing.add('VaseBreakerPresetProperties');
      }
      if (!existing.contains('VaseBreakerArcadeModuleProperties')) {
        missing.add('VaseBreakerArcadeModuleProperties');
      }
      if (!existing.contains('VaseBreakerFlowModuleProperties')) {
        missing.add('VaseBreakerFlowModuleProperties');
      }
    }
    if (isEvilDave) {
      if (!existing.contains('InitialPlantEntryProperties')) {
        missing.add('InitialPlantEntryProperties');
      }
      if (!existing.contains('SeedBankProperties')) {
        missing.add('SeedBankProperties');
      }
    }
    if (isZombossMechBattle) {
      if (!existing.contains('ZombossBattleModuleProperties')) {
        missing.add('ZombossBattleModuleProperties');
      }
      if (!existing.contains('ZombossBattleIntroProperties')) {
        missing.add('ZombossBattleIntroProperties');
      }
    }
    if (ctx.hasModule('OakTrainIntroProperties') &&
        !ctx.hasModule('OakTrainProperties')) {
      missing.add('OakTrainProperties');
    }
    if (isLastStand && !existing.contains('SeedBankProperties')) {
      missing.add('SeedBankProperties');
    }

    return missing
        .where(
          (cls) =>
              ModuleRegistry.getMetadata(cls).titleKey !=
                  ModuleRegistry.defaultMetadataKey &&
              !conflictModuleRules.any(
                (rule) =>
                    rule.conflictingClasses.contains(cls) &&
                    rule.conflictingClasses.every(
                      (other) => other == cls || existing.contains(other),
                    ),
              ),
        )
        .toList();
  }

  static String _conflictDescription(AppLocalizations l10n, String key) {
    switch (key) {
      case 'conflictDesc_SeedBankConveyor':
        return l10n.conflictDesc_SeedBankConveyor;
      case 'conflictDesc_VaseBreakerIntro':
        return l10n.conflictDesc_VaseBreakerIntro;
      case 'conflictDesc_LastStandIntro':
        return l10n.conflictDesc_LastStandIntro;
      case 'conflictDesc_CowboyIntro':
        return l10n.conflictDesc_CowboyIntro;
      case 'conflictDesc_SingleHandedIntro':
        return l10n.conflictDesc_SingleHandedIntro;
      case 'conflictDesc_SingleHandedTutorialIntro':
        return l10n.conflictDesc_SingleHandedTutorialIntro;
      case 'conflictDesc_CamelMinigameIntro':
        return l10n.conflictDesc_CamelMinigameIntro;
      case 'conflictDesc_EvilDaveZombieDrop':
        return l10n.conflictDesc_EvilDaveZombieDrop;
      case 'conflictDesc_EvilDaveVictory':
        return l10n.conflictDesc_EvilDaveVictory;
      case 'conflictDesc_ZombossDeathDrop':
        return l10n.conflictDesc_ZombossDeathDrop;
      case 'conflictDesc_ZombossTwoIntros':
        return l10n.conflictDesc_ZombossTwoIntros;
      case 'conflictDesc_WinConditionExclusive':
        return l10n.conflictDesc_WinConditionExclusive;
      case 'conflictDesc_InitialPlantEntryRoof':
        return l10n.conflictDesc_InitialPlantEntryRoof;
      case 'conflictDesc_InitialPlantRoof':
        return l10n.conflictDesc_InitialPlantRoof;
      case 'conflictDesc_ProtectPlantRoof':
        return l10n.conflictDesc_ProtectPlantRoof;
      case 'conflictDesc_LawnMowerYard':
        return l10n.conflictDesc_LawnMowerYard;
      case 'conflictDesc_MoonExpertYard':
        return l10n.conflictDesc_MoonExpertYard;
      case 'conflictDesc_WaveGeneratorWaveManagerModule':
        return l10n.conflictDesc_WaveGeneratorWaveManagerModule;
      case 'conflictDesc_WaveGeneratorWaveManager':
        return l10n.conflictDesc_WaveGeneratorWaveManager;
      default:
        return key;
    }
  }

  static String _defaultConflictDescription(
    BuildContext context,
    AppLocalizations l10n,
    ModuleConflictRule rule,
  ) {
    final names = rule.conflictingClasses
        .map((cls) => ModuleRegistry.getMetadata(cls).getTitle(context))
        .toList();
    return l10n.conflictDefaultDescription(
      names[0],
      names.length > 1 ? names[1] : names[0],
    );
  }

  static String _plantDisplayName(
    BuildContext context,
    PlantRepository repo,
    String plantId,
  ) {
    final key = repo.getName(plantId);
    final localized = ResourceNames.lookup(context, key);
    if (localized != key) return localized;
    return plantId
        .split('_')
        .map(
          (s) => s.isEmpty
              ? ''
              : s[0].toUpperCase() + s.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
