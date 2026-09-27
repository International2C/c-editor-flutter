import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _appLocale(String locale) =>
    jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const locales = ['zh', 'en', 'ru'];
  const removedKeys = [
    'conflictDesc_WaveGeneratorRenai',
    'conflictDesc_WaveGeneratorWitch',
    'lifeSupportLastStandConflictWarning',
  ];

  test('removes disproven compatibility warnings in every app locale', () {
    for (final locale in locales) {
      final arb = _appLocale(locale);
      for (final key in removedKeys) {
        expect(arb, isNot(contains(key)), reason: '$locale: $key');
        expect(arb, isNot(contains('@$key')), reason: '$locale: @$key');
      }
    }
  });

  test(
    'wave generator and Gladiatorial Row help include the compatibility warning',
    () {
      for (final locale in locales) {
        final arb = _appLocale(locale);
        final warning =
            arb['gladiatorWaveGeneratorCompatibilityWarning'] as String;
        expect(warning, isNotEmpty, reason: locale);
        expect(
          arb['waveGeneratorModuleHelpIncompatBody'],
          contains(warning),
          reason: locale,
        );
        // Help may summarize the incompatibility without repeating the banner.
        expect(
          arb['gladiatorHelpTips'],
          contains(switch (locale) {
            'zh' => '波次生成器下也不会生效',
            'en' => 'does not work with Wave Generator',
            _ => 'не работает с Генератором волн',
          }),
          reason: locale,
        );
        expect(arb['gladiatorCompatibilityWarningTitle'], isNotEmpty);
        expect(arb['waveGeneratorModuleHelpIncompat'], isNotEmpty);
      }
    },
  );

  test('retains actual wave system conflicts and unrelated module help', () {
    for (final locale in locales) {
      final arb = _appLocale(locale);
      for (final key in const [
        'conflictDesc_WaveGeneratorWaveManagerModule',
        'conflictDesc_WaveGeneratorWaveManager',
        'conflictDesc_SeedBankConveyor',
        'moonLifeSupportHelpOverview',
        'lastStandHelpNotesBody',
        'witchModuleHelpIntro',
        'renaiModuleHelpOverviewBody',
      ]) {
        expect(arb[key], isNotEmpty, reason: '$locale: $key');
      }
    }
  });
}
