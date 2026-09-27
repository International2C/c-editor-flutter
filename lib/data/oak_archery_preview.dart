import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';

String waveGeneratorPositionLabel(
  AppLocalizations l10n,
  String? value, {
  required bool column,
}) {
  if (value == null || value.isEmpty) {
    return l10n.waveGeneratorPositionUnset;
  }
  if (value == '?') {
    return '${l10n.random} (?)';
  }
  final index = int.tryParse(value);
  if (index == null) {
    return value;
  }
  return column
      ? l10n.waveGeneratorColumnOption(index + 1, value)
      : l10n.waveGeneratorRowOption(index + 1, value);
}

typedef OakArcheryField = ({String label, int value, String icon});

List<OakArcheryField> oakArcheryFields(
  OakTrainPropertiesData data,
  AppLocalizations l10n,
) => [
  (
    label: l10n.oakTrainTotalLife,
    value: data.totalLife,
    icon: 'plants/icon_oakshooter.webp',
  ),
  (
    label: l10n.oakTrainHealNum,
    value: data.healNum,
    icon: 'zombies/zombie_target_bottle.webp',
  ),
  (
    label: l10n.oakTrainArrowScore,
    value: data.arrowScore,
    icon: 'others/oaktrain_normal.webp',
  ),
  (
    label: l10n.oakTrainWizardScore,
    value: data.wizardScore,
    icon: 'zombies/zombie_dark_wizard.webp',
  ),
  (
    label: l10n.oakTrainArchmageScore,
    value: data.archmageScore,
    icon: 'zombies/zombie_dark_archmage.webp',
  ),
  (
    label: l10n.oakTrainBossScore,
    value: data.bossScore,
    icon: 'zombies/zombie_dark_gargantuar.webp',
  ),
  (
    label: l10n.oakTrainArrowPowerNum,
    value: data.arrowPowerNum,
    icon: 'zombies/zombie_target_arrow_blue.webp',
  ),
  (
    label: l10n.oakTrainArrowMultipleNum,
    value: data.arrowMultipleNum,
    icon: 'zombies/zombie_target_arrow_yellow.webp',
  ),
  for (var i = 0; i < 3; i++)
    (
      label:
          '${l10n.oakTrainInitArrowsNum} · ${[l10n.oakTrainInitArrowNormal, l10n.oakTrainInitArrowPower, l10n.oakTrainInitArrowSplit][i]}',
      value: i < data.initArrowsNum.length ? data.initArrowsNum[i] : 0,
      icon:
          'others/${['oaktrain_normal.webp', 'oaktrain_power.webp', 'oaktrain_triple.webp'][i]}',
    ),
];

String waveSpawnDelaySummary(
  AppLocalizations l10n,
  WaveGeneratorPropertiesData data,
  WaveGeneratorWaveData wave,
) {
  final delay = wave.waveSpawnTime;
  if (delay == null) return '';
  final value = delay == delay.roundToDouble()
      ? delay.toInt().toString()
      : delay.toString();
  return data.isRiseFromGroundMode
      ? l10n.waveGeneratorDelaySummary(value)
      : l10n.waveGeneratorDelayInactiveSummary(value);
}

String waveSpawnPositionSummary(
  AppLocalizations l10n,
  WaveGeneratorZombieEntryData zombie,
) => l10n.waveGeneratorPositionSummary(
  waveGeneratorPositionLabel(l10n, zombie.riseGridX, column: true),
  waveGeneratorPositionLabel(l10n, zombie.riseGridY, column: false),
);

List<String> waveGeneratorPreviewLines(
  WaveGeneratorPropertiesData data,
  AppLocalizations l10n,
  String Function(String) zombieName,
) {
  final states = WaveGeneratorPointAnalysis.calculateStates(data);
  return [
    l10n.waveGeneratorWaveCountSummary(data.waves.length),
    '${l10n.waveGeneratorRiseFromGround}: ${data.isRiseFromGroundMode ? l10n.pluginEnabled : l10n.pluginDisabled}',
    if (data.addToZombiePool.isNotEmpty)
      '${l10n.waveGeneratorInitialPool}: ${data.addToZombiePool.map((z) => zombieName(z.type)).join(', ')}',
    for (var i = 0; i < data.waves.length; i++) ...[
      '${l10n.waveLabel} ${i + 1} · ${l10n.waveGeneratorFixedSpawnCount(data.waves[i].zombies.length)}',
      states[i].randomSpawnsEnabled
          ? l10n.waveGeneratorRandomSummary(states[i].randomSpawnPoints)
          : l10n.waveGeneratorRandomSummaryDisabled,
      if (states[i].effectivePool.isNotEmpty)
        '${l10n.waveGeneratorCurrentPool}: ${states[i].effectivePool.map(zombieName).join(', ')}',
      if (data.waves[i].waveSpawnTime != null)
        waveSpawnDelaySummary(l10n, data, data.waves[i]),
      if (data.waves[i].waitUntilAllZombiesDie == true)
        l10n.waveGeneratorWaitStatus,
      if (data.waves[i].spawnPlantFoodCount != null)
        l10n.waveGeneratorWaveSettingsPlantFoodSummary(
          data.waves[i].spawnPlantFoodCount!,
        ),
      if (data.waves[i].colNumPlantIsDragged != null)
        l10n.waveGeneratorWaveSettingsBlackHoleSummary(
          data.waves[i].colNumPlantIsDragged!,
        ),
      for (final zombie in data.waves[i].zombies)
        '${zombieName(zombie.type)} · ${data.isRiseFromGroundMode ? waveSpawnPositionSummary(l10n, zombie) : '${l10n.row}: ${zombie.row ?? '?'}'}',
    ],
  ];
}
