import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _secondBasedLabels(AppLocalizations l10n) => [
  l10n.waveManagerFirstWaveDelayConveyor,
  l10n.waveManagerFirstWaveDelayNormal,
  l10n.waveManagerFlagWaveDelay,
  l10n.drawHealthBarTime,
  l10n.tideWaveDuration,
  l10n.tideWaveSpeedUpDuration,
  l10n.tideWaveSubmarineMovingTime,
  l10n.dinoTreadTimeIntervalLabel,
  l10n.hamsterballTimeBeforeFullSpawn,
  l10n.timeBetweenGroups,
  l10n.ztPerkPropDamageTakenInterval,
  l10n.timePerGrid,
  l10n.operationTimePerGrid,
  l10n.firstDropDelay,
  l10n.initialDropInterval,
  l10n.maxDropInterval,
  l10n.intervalFloatRange,
  l10n.pvz1PassageFieldTransferCooldown,
  l10n.pvz1PassageFieldRefreshTime,
  l10n.heianWindModuleWindDelay,
  l10n.heianWindModuleMoveTime,
  l10n.spermWhaleModuleSwallowInterval,
  l10n.spermWhaleModulePoisonSwallowInterval,
  l10n.spermWhaleModuleSwallowDuration,
];

void main() {
  test('second-based editor labels include units in every locale', () {
    final locales = <(Locale, String)>[
      (const Locale('en'), 'seconds'),
      (const Locale('zh'), '秒'),
      (const Locale('ru'), 'сек'),
    ];

    for (final (locale, marker) in locales) {
      final l10n = lookupAppLocalizations(locale);
      for (final label in _secondBasedLabels(l10n)) {
        expect(
          label.toLowerCase(),
          contains(marker),
          reason: '${locale.languageCode}: $label',
        );
      }
      expect(
        l10n.propertyLabelSeconds('Interval', 'TimeInterval').toLowerCase(),
        contains(marker),
      );
    }
  });
}
