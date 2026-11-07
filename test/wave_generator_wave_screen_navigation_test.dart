import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_wave_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updated localization is consistent in every locale', () {
    expect(
      lookupAppLocalizations(const Locale('zh')).failedToLoadLevel,
      '关卡加载失败。\n建议检查关卡文件是否为加密格式 (如热更新使用的JSON文件)。',
    );
    expect(
      lookupAppLocalizations(const Locale('en')).failedToLoadLevel,
      'Failed to load the level.\nWe recommend checking whether the level '
      'file is encrypted (for example, a JSON file used by hot updates).',
    );
    expect(
      lookupAppLocalizations(const Locale('ru')).failedToLoadLevel,
      'Не удалось загрузить уровень.\nРекомендуется проверить, не зашифрован '
      'ли файл уровня (например, JSON-файл из горячего обновления).',
    );
    expect(
      lookupAppLocalizations(
        const Locale('zh'),
      ).waveGeneratorStatisticalPreview,
      '随机出怪预览',
    );
    expect(
      lookupAppLocalizations(
        const Locale('en'),
      ).waveGeneratorStatisticalPreview,
      'Random-spawn preview',
    );
    expect(
      lookupAppLocalizations(
        const Locale('ru'),
      ).waveGeneratorStatisticalPreview,
      'Статистический предпросмотр',
    );
    final english = lookupAppLocalizations(const Locale('en'));
    expect(
      english.waveGeneratorFixedSummary(1),
      '1 zombie is guaranteed to appear',
    );
    expect(
      lookupAppLocalizations(const Locale('zh')).waveGeneratorFixedSummary(3),
      '必定出现3只僵尸',
    );
    expect(english.waveGeneratorRandomSummary(1), 'Enabled · 1 point');
    expect(
      english.waveGeneratorPoolSummaryNoAdditions(1),
      '1 current type · No additions on this wave',
    );
  });

  testWidgets('wave editor uses overview cards and preserves child edits', (
    tester,
  ) async {
    final generator = WaveGeneratorPropertiesData(
      waveSpendingPoints: 100,
      waveSpendingPointIncrement: 50,
      waves: [
        WaveGeneratorWaveData(
          disableRandomSpawns: false,
          spawnPlantFoodCount: 2,
        ),
      ],
    );
    final generatorObject = PvzObject(
      aliases: const ['WaveGenerator'],
      objClass: 'WaveGeneratorProperties',
      objData: generator.toJson(),
    );
    final levelFile = PvzLevelFile(objects: [generatorObject]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WaveGeneratorWaveScreen(
          waveIndex: 1,
          levelFile: levelFile,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('第1波'), findsOneWidget);
    expect(find.text('固定出怪'), findsOneWidget);
    expect(find.text('随机出怪'), findsOneWidget);
    expect(find.text('僵尸池'), findsOneWidget);
    expect(find.text('波次设置'), findsOneWidget);
    expect(find.textContaining('WavePointStart'), findsNothing);

    await tester.tap(find.text('随机出怪'));
    await tester.pumpAndSettle();
    expect(find.textContaining('WavePointStart'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byTooltip('关于此分区'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '120');
    await tester.pump();
    expect(
      ((generatorObject.objData as Map)['Waves'] as List)
          .first['WavePointStart'],
      120,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.textContaining('使用当前波次点数'), findsOneWidget);

    await tester.tap(find.text('波次设置'));
    await tester.pumpAndSettle();
    expect(find.textContaining('SpawnPlantFoodCount'), findsOneWidget);
    expect(find.textContaining('ColNumPlantIsDragged'), findsOneWidget);
    expect(find.textContaining('只有本波不是关卡的最后一波'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('固定出怪'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('zombie_lane_row_1')),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('僵尸池'));
    await tester.pumpAndSettle();
    expect(find.text('当前有效僵尸池'), findsOneWidget);
    expect(find.text('本波扩展僵尸池 (AddToZombiePool)'), findsOneWidget);
  });

  testWidgets('all wave sections remain usable at narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final generatorObject = PvzObject(
      aliases: const ['WaveGenerator'],
      objClass: 'WaveGeneratorProperties',
      objData: WaveGeneratorPropertiesData(
        waveSpendingPoints: 100,
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      ).toJson(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WaveGeneratorWaveScreen(
          waveIndex: 1,
          levelFile: PvzLevelFile(objects: [generatorObject]),
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final title in ['固定出怪', '随机出怪', '僵尸池', '波次设置']) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: title);
      expect(find.byTooltip('关于此分区'), findsOneWidget, reason: title);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$title 返回');
    }
  });
}
