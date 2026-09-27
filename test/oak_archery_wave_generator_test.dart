import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/oak_archery_preview.dart';
import 'package:c_editor/data/oak_train_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/oak_train_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_wave_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_generator_tab.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/widgets/wave_generator_position_fields.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:c_editor/widgets/zombie_row_lane_drag_drop_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzObject _object(String alias, String cls, Map<String, dynamic> data) =>
    PvzObject(aliases: [alias], objClass: cls, objData: data);

PvzLevelFile _level({String stage = 'EgyptStage', String? customClass}) =>
    PvzLevelFile(
      objects: [
        _object(
          'Level',
          'LevelDefinition',
          LevelDefinitionData(
            stageModule: customClass == null
                ? 'RTID($stage@LevelModules)'
                : 'RTID(Stage@CurrentLevel)',
            modules: ['RTID(Oak@CurrentLevel)', 'RTID(Generator@CurrentLevel)'],
          ).toJson(),
        ),
        if (customClass != null)
          _object('Stage', customClass, {
            'BackgroundPrefix': 'IMAGE_BACKGROUNDS_EGYPT',
          }),
        _object('Oak', 'OakTrainProperties', {
          ...OakTrainPropertiesData(
            totalLife: 4321,
            initArrowsNum: [12, 10, 5, 17],
          ).toJson(),
          'CustomField': {'keep': true},
        }),
        _object(
          'Generator',
          'WaveGeneratorProperties',
          WaveGeneratorPropertiesData(
            isRiseFromGroundMode: true,
            waves: [
              WaveGeneratorWaveData(
                waveSpawnTime: 2,
                waitUntilAllZombiesDie: true,
                zombies: [
                  WaveGeneratorZombieEntryData(
                    type: 'zombie_target_arrow_blue',
                    riseGridX: '0',
                    riseGridY: '2',
                    level: 3,
                  ),
                ],
              ),
            ],
          ).toJson(),
        ),
      ],
    );

Widget _app(Widget home, {String language = 'zh', double scale = 1}) =>
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: home,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ReferenceRepository.init();
  });

  test(
    'rise mode normalizes hidden column bounds without affecting disabled mode',
    () {
      for (final enabled in [false, true]) {
        final data = WaveGeneratorPropertiesData.fromJson({
          'SpawnColStart': 0,
          'SpawnColEnd': 8,
          'IsRiseFromGroundMode': enabled,
          'Waves': [
            {
              'Zombies': [
                {
                  'Type': 'zombie_target_wizard',
                  'Rise_GridX': 0,
                  'Rise_GridY': '?',
                  'Level': 7,
                },
              ],
            },
          ],
        });
        final json = data.toJson();
        expect(json['SpawnColStart'], enabled ? 2 : 0);
        expect(json['SpawnColEnd'], enabled ? 2 : 8);
        final zombie = (json['Waves'] as List).single['Zombies'].single as Map;
        expect(zombie['Rise_GridX'], '0');
        expect(zombie['Rise_GridY'], '?');
        expect(zombie['Level'], 7);
        expect(zombie['Type'], 'zombie_target_wizard');
      }
    },
  );

  test('target warnings distinguish ordinary, ground and custom spawns', () {
    for (final cls in [
      'SpawnZombiesJitteredWaveActionProps',
      'SpawnZombiesFishWaveActionProps',
      'SpawnZombiesFromGroundWaveActionProps',
    ]) {
      for (final type in [
        'RTID(zombie_target_arrow_blue@ZombieTypes)',
        'RTID(zombie_target_arrow_blue@CurrentLevel)',
        'RTID(tutorial@ZombieTypes)',
      ]) {
        final event = _object('Event', cls, {
          'Zombies': [
            {'Type': type},
          ],
        });
        expect(
          OakTrainUtils.hasIncompatibleTargets(event),
          cls != 'SpawnZombiesFromGroundWaveActionProps' &&
              type == 'RTID(zombie_target_arrow_blue@ZombieTypes)',
        );
      }
    }
  });

  for (final language in ['zh', 'en', 'ru']) {
    final l10n = lookupAppLocalizations(Locale(language));

    testWidgets(
      '$language: map warnings follow base class and require an active Oak module',
      (tester) async {
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) {
                for (final stage in [
                  'EgyptStage',
                  'DeepseaStage',
                  'DeepseaLandStage',
                  'MoonStage',
                ]) {
                  final level = _level(stage: stage);
                  final warnings = LevelIssueRegistry.forLevel(
                    context,
                    level,
                  ).where((i) => i.id == 'oakTrainUnderwaterWarning');
                  expect(
                    warnings.length,
                    stage == 'EgyptStage' ? 0 : 1,
                    reason: stage,
                  );
                  if (warnings.isNotEmpty) {
                    expect(
                      warnings.single.message,
                      l10n.oakTrainUnderwaterWarning,
                    );
                  }
                }
                for (final cls in [
                  'EgyptStageProperties',
                  'DeepseaStageProperties',
                  'DeepseaStageLandProperties',
                  'MoonStageProperties',
                ]) {
                  final level = _level(customClass: cls);
                  bool warning() => LevelIssueRegistry.forLevel(
                    context,
                    level,
                  ).any((i) => i.id == 'oakTrainUnderwaterWarning');
                  expect(warning(), cls != 'EgyptStageProperties', reason: cls);
                  (level.objects.first.objData as Map)['Modules'] = <String>[];
                  expect(
                    warning(),
                    isFalse,
                    reason: 'Unlinked module must not warn',
                  );
                }
                // A Moon appearance on an Egypt base must not trigger the warning.
                final level = _level(customClass: 'EgyptStageProperties');
                (level.objects[1].objData as Map)['BackgroundPrefix'] =
                    'IMAGE_BACKGROUNDS_MOON';
                expect(OakTrainUtils.needsOxygenSupport(level), isFalse);
                return const SizedBox();
              },
            ),
            language: language,
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$language: only referenced ordinary spawns produce the level warning',
      (tester) async {
        final level = _level();
        level.objects.addAll([
          _object('WaveModule', 'WaveManagerModuleProperties', {
            'WaveManagerProps': 'RTID(Waves@CurrentLevel)',
          }),
          _object('Waves', 'WaveManagerProperties', {
            'Waves': [
              ['RTID(Event@CurrentLevel)'],
            ],
          }),
          _object('Event', 'SpawnZombiesJitteredWaveActionProps', {
            'Zombies': [
              {'Type': 'RTID(zombie_target_wizard@ZombieTypes)'},
            ],
          }),
        ]);
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) {
                List<LevelIssue> warnings() =>
                    LevelIssueRegistry.forLevel(context, level)
                        .where(
                          (i) => i.id == 'targetZombieInWaveManagerWarning',
                        )
                        .toList();
                expect(warnings(), isEmpty);
                (level.objects.first.objData as Map)['Modules'] = [
                  'RTID(Oak@CurrentLevel)',
                  'RTID(WaveModule@CurrentLevel)',
                ];
                expect(
                  warnings().single.message,
                  l10n.targetZombieInWaveManagerWarning,
                );
                (level.objects[level.objects.length - 2].objData
                        as Map)['Waves'] =
                    <List<String>>[];
                expect(warnings(), isEmpty);
                return const SizedBox();
              },
            ),
            language: language,
          ),
        );
      },
    );

    testWidgets(
      '$language: Oak editor icons, long labels and edits survive narrow large-text layout',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final level = _level();
        final oak = level.objects.firstWhere(
          (o) => o.objClass == 'OakTrainProperties',
        );
        await tester.pumpWidget(
          _app(
            OakTrainScreen(
              rtid: 'RTID(Oak@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            ),
            language: language,
            scale: 1.5,
          ),
        );
        await tester.pumpAndSettle();
        for (final title in [
          l10n.oakTrainHealthTitle,
          l10n.oakTrainScoresTitle,
          l10n.oakTrainArrowsTitle,
          l10n.oakTrainInitArrowsNum,
        ]) {
          expect(find.text(title), findsOneWidget);
        }
        expect(find.byType(Image), findsNWidgets(11));
        for (final field in oakArcheryFields(OakTrainPropertiesData(), l10n)) {
          expect(
            File('assets/images/${field.icon}').existsSync(),
            isTrue,
            reason: field.icon,
          );
        }
        final hp = find.byWidgetPredicate(
          (w) => w is TextField && w.controller?.text == '4321',
        );
        await tester.ensureVisible(hp);
        await tester.enterText(hp, '54321');
        await tester.pump();
        expect((oak.objData as Map)['TotalLife'], 54321);
        expect((oak.objData as Map)['CustomField'], {'keep': true});
        expect(tester.testTextInput.isVisible, isTrue);
        final normal = find.byWidgetPredicate(
          (w) => w is TextField && w.controller?.text == '12',
        );
        await tester.ensureVisible(normal);
        await tester.enterText(normal, '24');
        await tester.pump();
        expect((oak.objData as Map)['InitArrowsNum'], [24, 10, 5, 17]);
        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();
        for (final body in [
          l10n.moduleHelpOakTrainOverviewBody,
          l10n.moduleHelpOakTrainArrowsBody,
          l10n.moduleHelpOakTrainScoresBody,
          l10n.moduleHelpOakTrainZombiesBody,
        ]) {
          expect(find.text(body), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$language: coordinate lists preserve unset, random and imported values',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        String? x = '12', y;
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) => WaveGeneratorPositionFields(
                    rows: 6,
                    columns: 10,
                    x: x,
                    y: y,
                    onChanged: (nextX, nextY) => setState(() {
                      x = nextX;
                      y = nextY;
                    }),
                  ),
                ),
              ),
            ),
            language: language,
            scale: 1.5,
          ),
        );
        await tester.pumpAndSettle();
        final xField = find.byKey(const ValueKey('waveRiseX'));
        final yField = find.byKey(const ValueKey('waveRiseY'));
        expect(
          tester.widget<DropdownButtonFormField<String>>(xField).initialValue,
          '12',
        );
        expect(
          tester.widget<DropdownButtonFormField<String>>(yField).initialValue,
          '',
        );
        await tester.ensureVisible(yField);
        await tester.tap(yField);
        await tester.pumpAndSettle();
        expect(find.text(l10n.waveGeneratorRowOption(6, '5')), findsWidgets);
        await tester.tap(find.text(l10n.waveGeneratorRowOption(1, '0')).last);
        await tester.pumpAndSettle();
        expect(y, '0');
        expect(x, '12');
        await tester.ensureVisible(xField);
        await tester.tap(xField);
        await tester.pumpAndSettle();
        await tester.tap(find.text('${l10n.random} (?)').last);
        await tester.pumpAndSettle();
        expect(x, '?');
        expect(y, '0');
        await tester.tap(xField);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.waveGeneratorPositionUnset).last);
        await tester.pumpAndSettle();
        expect(x, isNull);
        expect(y, '0');
        expect(tester.takeException(), isNull);
      },
    );

    test(
      '$language: image preview exposes localized Oak and generator content without mutating JSON',
      () {
        final level = _level();
        level.objects.add(
          _object('SeedBank', 'SeedBankProperties', SeedBankData().toJson()),
        );
        final before = jsonEncode(level.toJson());
        expect(
          previewPresentModuleObjClasses(level),
          containsAll([
            'OakTrainProperties',
            'WaveGeneratorProperties',
            'SeedBankProperties',
          ]),
        );
        PreviewModuleInfoPayload build(String cls) => previewModuleInfoBuild(
          levelFile: level,
          objClass: cls,
          t: (_, fallback, [args]) => fallback,
          appL10n: l10n,
          resourceName: (_, id) => 'Localized $id',
        );
        final oak = build('OakTrainProperties');
        expect(oak.lines, contains('${l10n.oakTrainTotalLife}: 4321'));
        expect(oak.lines.length, 11);
        expect(oak.isLawnGrid, isTrue);
        final plant = oak.sections.single.items.single;
        expect((plant.gridX, plant.gridY), (0, 2));
        final generator = build('WaveGeneratorProperties');
        expect(
          generator.textBody,
          contains(l10n.waveGeneratorDelaySummary('2')),
        );
        expect(
          generator.textBody,
          contains(l10n.waveGeneratorColumnOption(1, '0')),
        );
        expect(
          generator.textBody,
          contains(l10n.waveGeneratorRowOption(3, '2')),
        );
        expect(
          generator.textBody,
          contains('Localized zombie_target_arrow_blue'),
        );
        expect(
          generator.sections.single.items.single.label,
          contains(l10n.waveGeneratorRowOption(3, '2')),
        );
        expect(jsonEncode(level.toJson()), before);
      },
    );
  }

  testWidgets('wave settings delay is in overview summary and section help', (
    tester,
  ) async {
    final level = _level();
    final l10n = lookupAppLocalizations(const Locale('zh'));
    await tester.pumpWidget(
      _app(
        WaveGeneratorWaveScreen(
          waveIndex: 1,
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining(l10n.waveGeneratorDelaySummary('2')),
      findsOneWidget,
    );
    await tester.tap(find.text(l10n.waveGeneratorWaveSettingsTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text(l10n.waveGeneratorWaveSpawnTimeHint), findsOneWidget);
    expect(tester.takeException(), isNull);
    final data = WaveGeneratorPropertiesData(isRiseFromGroundMode: false);
    expect(
      waveSpawnDelaySummary(
        l10n,
        data,
        WaveGeneratorWaveData(waveSpawnTime: 2.5),
      ),
      l10n.waveGeneratorDelayInactiveSummary('2.5'),
    );
    expect(waveSpawnDelaySummary(l10n, data, WaveGeneratorWaveData()), isEmpty);
  });

  testWidgets(
    'coordinate edits and copying in the real wave sheet retain new values',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final level = _level();
      final l10n = lookupAppLocalizations(const Locale('zh'));
      await tester.pumpWidget(
        _app(
          WaveGeneratorWaveScreen(
            waveIndex: 1,
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.waveGeneratorFixedSpawns));
      await tester.pumpAndSettle();
      tester
          .widget<ZombieRowLaneDragDropEditor>(
            find.byType(ZombieRowLaneDragDropEditor),
          )
          .onTap(0);
      await tester.pumpAndSettle();
      for (final (key, label) in [
        ('waveRiseX', l10n.waveGeneratorColumnOption(3, '2')),
        ('waveRiseY', l10n.waveGeneratorRowOption(5, '4')),
      ]) {
        final field = find.byKey(ValueKey(key));
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
      }
      final copy = find.widgetWithText(OutlinedButton, l10n.copy);
      await tester.ensureVisible(copy);
      await tester.tap(copy);
      await tester.pumpAndSettle();
      final generator = level.objects.firstWhere(
        (o) => o.objClass == 'WaveGeneratorProperties',
      );
      final zombies =
          ((generator.objData as Map)['Waves'] as List).single['Zombies']
              as List;
      expect(zombies.length, 2);
      for (final zombie in zombies) {
        expect(zombie['Rise_GridX'], '2');
        expect(zombie['Rise_GridY'], '4');
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'timeline shows delay with compact row badge and full position tooltip',
    (tester) async {
      final level = _level();
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final l10n = lookupAppLocalizations(const Locale('zh'));
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: WaveGeneratorTab(
              levelFile: level,
              parsed: LevelParser.parseLevel(level),
              onChanged: () {},
              onEditWave: (_) {},
            ),
          ),
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining(l10n.waveGeneratorDelaySummary('2')),
        findsOneWidget,
      );
      final chip = tester.widget<WaveGeneratorZombieIconChip>(
        find.byType(WaveGeneratorZombieIconChip).first,
      );
      expect(chip.rowLabel, '3');
      expect(
        chip.positionTooltip,
        contains(l10n.waveGeneratorColumnOption(1, '0')),
      );
      expect(
        chip.positionTooltip,
        contains(l10n.waveGeneratorRowOption(3, '2')),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('level overview displays the same module values and wave delay', (
    tester,
  ) async {
    final level = _level();
    final l10n = lookupAppLocalizations(const Locale('zh'));
    await tester.pumpWidget(
      _app(
        LevelOverviewDialog(
          levelFile: level,
          parsed: LevelParser.parseLevel(level),
          fileName: 'test.json',
          onClose: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('${l10n.oakTrainTotalLife}: 4321'), findsOneWidget);
    expect(find.text(l10n.waveGeneratorDelaySummary('2')), findsOneWidget);
    expect(
      find.textContaining(l10n.waveGeneratorColumnOption(1, '0')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
