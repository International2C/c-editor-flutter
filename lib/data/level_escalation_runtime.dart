import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'pvz_models.dart';
import 'repository/reference_repository.dart';
import 'rtid_parser.dart';

enum LevelEscalationModuleOrder { missing, beforeWaveManager, afterWaveManager }

/// Runtime relationship between Escalation Spawning, its wave configuration,
/// and the Wave Manager module that owns the actual runtime WaveManager.
///
/// The normal game layout gives WaveManagerProperties only to Escalation
/// Spawning. WaveManagerModule then acts as a runner and does not initialize a
/// second configuration. Module order matters only when both modules point to
/// different, valid WaveManagerProperties objects.
class LevelEscalationRuntime {
  const LevelEscalationRuntime({
    required this.order,
    this.data,
    this.escalationIndex,
    this.escalationModuleRtid,
    this.waveManagerIndex,
    this.escalationWaveManagerProps,
    this.waveManagerWaveManagerProps,
    this.hasValidEscalationProps = false,
    this.hasValidWaveManagerProps = false,
    this.hasCompetingWaveManagerProps = false,
    this.waveManagerPointSpawningEnabled = false,
  });

  final LevelEscalationModuleOrder order;
  final LevelEscalationModuleData? data;
  final int? escalationIndex;
  final String? escalationModuleRtid;
  final int? waveManagerIndex;
  final String? escalationWaveManagerProps;
  final String? waveManagerWaveManagerProps;
  final bool hasValidEscalationProps;
  final bool hasValidWaveManagerProps;
  final bool waveManagerPointSpawningEnabled;

  /// True only when both modules hold different, valid wave configurations.
  final bool hasCompetingWaveManagerProps;

  bool get isEffective =>
      data != null &&
      waveManagerIndex != null &&
      hasValidEscalationProps &&
      (!hasCompetingWaveManagerProps ||
          order == LevelEscalationModuleOrder.afterWaveManager);

  /// Configuration the editor should show for the final runtime result.
  ///
  /// A runner-only WaveManagerModule leaves this to Escalation Spawning. If
  /// two independent configurations compete, the later initializer wins.
  String? get effectiveWaveManagerProps {
    if (hasCompetingWaveManagerProps &&
        order == LevelEscalationModuleOrder.beforeWaveManager) {
      return waveManagerWaveManagerProps;
    }
    if (hasValidEscalationProps) return escalationWaveManagerProps;
    if (hasValidWaveManagerProps) return waveManagerWaveManagerProps;
    return null;
  }

  static LevelEscalationRuntime resolve(
    PvzLevelFile levelFile, {
    String? escalationAlias,
    String? waveManagerAlias,
  }) {
    final definitionObject = levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'LevelDefinition',
    );
    if (definitionObject?.objData is! Map) {
      return const LevelEscalationRuntime(
        order: LevelEscalationModuleOrder.missing,
      );
    }
    final definition = LevelDefinitionData.fromJson(
      Map<String, dynamic>.from(definitionObject!.objData as Map),
    );

    int? escalationIndex;
    String? escalationModuleRtid;
    int? waveManagerIndex;
    LevelEscalationModuleData? escalationData;
    WaveManagerModuleData? waveManagerData;

    for (var index = 0; index < definition.modules.length; index++) {
      final parsed = RtidParser.parse(definition.modules[index]);
      if (parsed == null || parsed.source != 'CurrentLevel') continue;
      final object = levelFile.objects.firstWhereOrNull(
        (candidate) => candidate.aliases?.contains(parsed.alias) == true,
      );
      if (object == null) continue;
      final aliases = object.aliases!;
      if (object.objClass == 'LevelEscalationModuleProperties' &&
          (escalationAlias == null || aliases.contains(escalationAlias)) &&
          object.objData is Map) {
        escalationIndex = index;
        escalationModuleRtid = RtidParser.build(aliases.first, 'CurrentLevel');
        escalationData = LevelEscalationModuleData.fromJson(
          Map<String, dynamic>.from(object.objData as Map),
        );
      }
      if (object.objClass == 'WaveManagerModuleProperties' &&
          (waveManagerAlias == null || parsed.alias == waveManagerAlias)) {
        waveManagerIndex = index;
        waveManagerData = object.objData is Map
            ? WaveManagerModuleData.fromJson(
                Map<String, dynamic>.from(object.objData as Map),
              )
            : null;
      }
    }

    final escalationProps = escalationData?.waveManagerProps;
    final waveManagerProps = waveManagerData?.waveManagerProps;
    final validEscalationProps = _isValidWaveManagerProps(
      levelFile,
      escalationProps,
    );
    final validWaveManagerProps = _isValidWaveManagerProps(
      levelFile,
      waveManagerProps,
    );
    final competing =
        validEscalationProps &&
        validWaveManagerProps &&
        !_sameRtid(escalationProps!, waveManagerProps!);
    final order = escalationIndex == null || waveManagerIndex == null
        ? LevelEscalationModuleOrder.missing
        : escalationIndex > waveManagerIndex
        ? LevelEscalationModuleOrder.afterWaveManager
        : LevelEscalationModuleOrder.beforeWaveManager;

    return LevelEscalationRuntime(
      order: order,
      data: escalationData,
      escalationIndex: escalationIndex,
      escalationModuleRtid: escalationModuleRtid,
      waveManagerIndex: waveManagerIndex,
      escalationWaveManagerProps: escalationProps,
      waveManagerWaveManagerProps: waveManagerProps,
      hasValidEscalationProps: validEscalationProps,
      hasValidWaveManagerProps: validWaveManagerProps,
      hasCompetingWaveManagerProps: competing,
      waveManagerPointSpawningEnabled:
          waveManagerData?.dynamicZombies.isNotEmpty ?? false,
    );
  }

  static bool _sameRtid(String left, String right) {
    final leftInfo = RtidParser.parse(left);
    final rightInfo = RtidParser.parse(right);
    if (leftInfo == null || rightInfo == null) return left == right;
    return leftInfo.alias == rightInfo.alias &&
        leftInfo.source == rightInfo.source;
  }

  static bool _isValidWaveManagerProps(PvzLevelFile levelFile, String? rtid) {
    if (rtid == null || rtid.isEmpty) return false;
    final info = RtidParser.parse(rtid);
    if (info == null) return false;
    if (info.source == 'CurrentLevel') {
      return levelFile.objects.any(
        (object) =>
            object.objClass == 'WaveManagerProperties' &&
            object.aliases?.contains(info.alias) == true,
      );
    }
    return ReferenceRepository.instance.getObjClass(info.alias) ==
        'WaveManagerProperties';
  }

  /// Number of waves the initialized Wave Manager will actually run.
  int effectiveWaveCount(WaveManagerData manager) {
    if (!isEffective) return _baseWaveCount(manager);
    final generated = data!.totalWaves;
    final stored = manager.waves.length;
    if (stored < generated) return generated;
    return _baseWaveCount(manager);
  }

  static int _baseWaveCount(WaveManagerData manager) {
    if (manager.waveCount <= 0) return manager.waves.length;
    return math.min(manager.waveCount, manager.waves.length);
  }

  /// Deterministic Plant Food assigned to [waveNumber] before random extras.
  int fixedPlantFoodAtWave(int waveNumber) {
    final module = data;
    if (module == null || waveNumber < 1 || module.wavesPerFlag < 2) return 0;
    var remaining = math.max(0, module.plantfoodToSpawnCount);
    var count = 0;
    for (
      var wave = module.wavesPerFlag - 1;
      wave <= module.totalWaves && remaining > 0;
      wave += module.wavesPerFlag
    ) {
      if (wave == waveNumber) count++;
      remaining--;
    }
    return count;
  }

  int get randomPlantFoodCount {
    final module = data;
    if (module == null) return 0;
    return math.max(
      0,
      module.plantfoodToSpawnCount - math.max(0, module.flagCount),
    );
  }
}
