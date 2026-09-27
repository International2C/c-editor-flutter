/// Optional focus when opening a module editor from a wave preview.
class ModuleOpenHint {
  const ModuleOpenHint({
    this.gridOverrideModuleWave,
    this.dropShipWave,
    this.gladiatorWave,
    this.heianWindWaveNumber,
  });

  /// 1-based wave in [ArmrackPropertiesData] / [EnergyGridPropertiesData].
  final int? gridOverrideModuleWave;

  /// 0-based wave in [DropShipPropertiesData].
  final int? dropShipWave;

  /// Zero-based encounter wave in GladiatorRowModuleProperties.
  final int? gladiatorWave;

  /// 0-based wave number in [HeianWindModulePropertiesData].
  final int? heianWindWaveNumber;
}

typedef OpenModuleCallback = void Function(String rtid, {ModuleOpenHint? hint});
