import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/gladiator_row_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/gladiator_row_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/gladiator_row_preview.dart';
import 'package:c_editor/widgets/grid_override_wave_groups_bar.dart';
import 'package:c_editor/widgets/wave_module_preview_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _class = 'GladiatorRowModuleProperties';
const _rtid = 'RTID(GladiatorRowModule@CurrentLevel)';

List<Map<String, dynamic>> _fixtures() =>
    (jsonDecode(
              File(
                'test/fixtures/gladiator_row_modules.json',
              ).readAsStringSync(),
            )
            as List)
        .cast<Map<String, dynamic>>();

PvzLevelFile _level([int fixture = 0]) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(modules: [_rtid]).toJson(),
    ),
    PvzObject.fromJson(_fixtures()[fixture]['module'] as Map<String, dynamic>),
  ],
);

Widget _app(Widget home, {String locale = 'en', double scale = 1}) =>
    MaterialApp(
      locale: Locale(locale),
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

Widget _editor(PvzLevelFile level, {int? wave, VoidCallback? changed}) =>
    GladiatorRowModuleScreen(
      rtid: _rtid,
      levelFile: level,
      initialWave: wave,
      onChanged: changed ?? () {},
      onBack: () {},
    );

void _setStage(PvzLevelFile level, String alias, {String? objClass}) {
  level.objects.first.objData['StageModule'] =
      'RTID($alias@${objClass == null ? 'LevelModules' : 'CurrentLevel'})';
  if (objClass != null) {
    level.objects.add(
      PvzObject(
        aliases: [alias],
        objClass: objClass,
        objData: <String, dynamic>{},
      ),
    );
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String field, String text) async {
  final finder = find.byKey(ValueKey('gladiator-$field'));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, text);
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
}

Future<void> _selectLevel(WidgetTester tester, String scope, int value) async {
  final field = find.byKey(ValueKey('gladiator-$scope-Level'));
  final dropdown = find.descendant(
    of: field,
    matching: find.byType(DropdownButton<int>),
  );
  expect(
    tester.widget<DropdownButton<int>>(dropdown).items!.map((e) => e.value),
    List.generate(11, (i) => i),
  );
  await _tap(tester, field);
  final item = find.text('$value').last;
  await _tap(tester, item);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
    ]);
  });

  for (final fixture in _fixtures()) {
    test(
      '${fixture['level']} imports and exports the official module unchanged',
      () {
        final original = fixture['module'] as Map<String, dynamic>;
        final object = PvzObject.fromJson(original);
        final data = GladiatorRowModulePropertiesData.fromJson(object.objData);
        object.objData = data.toJson();
        expect(object.toJson(), original);
        expect(object.objClass, _class);
        expect(
          data.encounters.first.spawns.first.values['Interval'],
          isA<double>(),
        );
      },
    );
  }

  test(
    'underwater warning follows the selected lawn and only active Gladiatorial Row modules',
    () {
      final rule = LevelIssueRegistry.rules.singleWhere(
        (rule) => rule.id == 'gladiatorRowUnderwaterMismatch',
      );
      expect(rule.severity, LevelIssueSeverity.warning);
      for (final (alias, objClass, incompatible) in <(String, String?, bool)>[
        ('DeepseaStage', null, true),
        ('DeepseaLandStage', null, true),
        ('CustomSea', 'DeepseaStageProperties', true),
        ('CustomAtlantis', 'DeepseaStageLandProperties', true),
        ('EgyptStage', null, false),
        ('CustomFiveRows', 'StageModuleProperties', false),
      ]) {
        final level = _level();
        _setStage(level, alias, objClass: objClass);
        expect(
          rule.isActive!(LevelIssueContext.fromLevel(level)),
          incompatible,
          reason: '$alias / $objClass',
        );
        level.objects.first.objData['Modules'] = <String>[];
        expect(
          rule.isActive!(LevelIssueContext.fromLevel(level)),
          isFalse,
          reason: 'Unused module object on $alias',
        );
      }
      // An unused six-row stage must not affect the active five-row lawn.
      final level = _level();
      _setStage(level, 'UnusedSea', objClass: 'DeepseaStageProperties');
      _setStage(level, 'EgyptStage');
      expect(rule.isActive!(LevelIssueContext.fromLevel(level)), isFalse);
    },
  );

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      'underwater notice and reminder are localized and clear after changing lawns in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final level = _level();
        _setStage(level, 'CustomSea', objClass: 'DeepseaStageProperties');
        final original = jsonEncode(level.toJson());
        final l10n = lookupAppLocalizations(Locale(locale));
        await tester.pumpWidget(_app(_editor(level), locale: locale, scale: 2));
        await tester.pumpAndSettle();
        final banner = find.byKey(
          const ValueKey('gladiatorRowUnderwaterMismatch'),
        );
        expect(banner, findsOneWidget);
        expect(
          find.descendant(
            of: banner,
            matching: find.text(l10n.gladiatorUnderwaterMismatchWarning),
          ),
          findsOneWidget,
        );
        final issue = LevelIssueRegistry.forLevel(
          tester.element(find.byType(GladiatorRowModuleScreen)),
          level,
        ).singleWhere((issue) => issue.id == 'gladiatorRowUnderwaterMismatch');
        expect(issue.message, l10n.gladiatorUnderwaterMismatchWarning);
        expect(issue.isError, isFalse);
        expect(jsonEncode(level.toJson()), original);
        await _tap(tester, find.byIcon(Icons.help_outline));
        expect(find.text(l10n.gladiatorHelpTips), findsOneWidget);
        expect(
          l10n.gladiatorHelpTips,
          contains(switch (locale) {
            'zh' => '六行地图中生成',
            'en' => 'six-row lawns',
            _ => 'шестирядных лужайках',
          }),
        );
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.byType(AlertDialog))).pop();
        await tester.pumpAndSettle();
        _setStage(level, 'EgyptStage');
        await tester.pumpWidget(_app(_editor(level), locale: locale, scale: 2));
        await tester.pumpAndSettle();
        expect(banner, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('new module belongs after Radiation Meteor in special mechanics', () {
    final modules = ModuleRegistry.getAllModules();
    final index = modules.indexWhere(
      (m) => m.defaultAlias == 'RadiationMeteorModule',
    );
    final meta = modules[index + 1];
    expect(meta.defaultAlias, 'GladiatorRowModule');
    expect(meta.category, ModuleCategory.gimmick);
    expect(
      ObjectOrderRegistry.getPriority(_class),
      ObjectOrderRegistry.getPriority('RadiationMeteorModuleProperties') + 1,
    );
    final data = meta.initialDataFactory!() as GladiatorRowModulePropertiesData;
    final json = data.toJson();
    expect(
      json['BaseConfig'],
      'RTID(DefaultGladiatorRowConfig@PropertySheets)',
    );
    expect(json['GameplayVersion'], 1);
    expect(json['ResourceGroupNames'], contains('GladiatorRow'));
    expect(json.containsKey('ArenaDuration'), isFalse);
    final sheet =
        (jsonDecode(
                  File(
                    'assets/reference/PropertySheets.json',
                  ).readAsStringSync(),
                )['objects']
                as List)
            .singleWhere(
              (o) =>
                  (o['aliases'] as List?)?.contains(
                    'DefaultGladiatorRowConfig',
                  ) ==
                  true,
            );
    for (final option in GladiatorRowModulePropertiesData.optionDefaults.keys) {
      expect(data.option(option), sheet['objdata'][option]);
    }
  });

  for (final version in [null, 0]) {
    testWidgets(
      'imported GameplayVersion $version is preserved until explicitly switching to trophy mode',
      (tester) async {
        final level = _level(1);
        final data = level.objects.last.objData as Map;
        if (version == null) {
          data.remove('GameplayVersion');
        } else {
          data['GameplayVersion'] = version;
        }
        // The guide includes this field without explaining how it affects trophy
        // mode. Preserve it rather than inferring a different arena footprint.
        data['PlantableGridCount'] = 2;
        final original = jsonEncode(data);
        await tester.pumpWidget(_app(_editor(level)));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('gladiatorLegacyModeWarning')),
          findsOneWidget,
        );
        expect(find.byType(GladiatorRowPreview), findsNothing);
        expect(jsonEncode(level.objects.last.objData), original);
        await showPreview(tester, level);
        expect(find.byType(GladiatorRowPreview), findsNothing);
        Navigator.of(tester.element(find.byType(Dialog))).pop();
        await tester.pumpAndSettle();
        await _tap(
          tester,
          find.byKey(const ValueKey('gladiator-use-trophy-mode')),
        );
        expect(readGladiatorRowModuleData(level)!.usesTrophyMode, isTrue);
        expect(level.objects.last.objData, {...data, 'GameplayVersion': 1});
        expect(find.byType(GladiatorRowPreview), findsOneWidget);
        expect(
          find.byKey(const ValueKey('gladiatorLegacyModeWarning')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'editing preserves inheritance, additional fields and original resource groups',
    () {
      final data = readGladiatorRowModuleData(_level())!;
      data.values['FutureOption'] = {'value': 7};
      data.encounters.first.values['FutureEncounterOption'] = true;
      data.encounters.first.spawns.first.values['FutureSpawnOption'] = 3.5;
      data.values['ArenaDuration'] = 30;
      data.encounters.first.wave = 0;
      data.addResourceGroups(['GladiatorRow', 'ExtraGroup']);
      final exported = data.toJson();
      final roundtrip = GladiatorRowModulePropertiesData.fromJson(exported);
      expect(roundtrip.toJson(), exported);
      expect(exported['FutureOption'], {'value': 7});
      expect(
        exported['BaseConfig'],
        'RTID(DefaultGladiatorRowConfig@PropertySheets)',
      );
      expect(exported['ResourceGroupNames'], [
        'GladiatorRow',
        'ZombieRomanTopShieldGroup',
        'ZombieRomanBasicResGroup',
        'ZombieRomanHealerGroup',
        'ExtraGroup',
      ]);
      expect(exported.containsKey('PlantWinPlantfoodCount'), isFalse);
    },
  );

  test(
    'timeline maps zero-based waves including multiple encounters in one wave',
    () {
      final data = readGladiatorRowModuleData(_level(1))!;
      data.encounters.add(GladiatorEncounterData(wave: 0));
      data.encounters.add(GladiatorEncounterData(wave: 4, row: 4));
      expect(gladiatorEncountersForWave(data, 1).single.wave, 0);
      expect(gladiatorEncountersForWave(data, 4), isEmpty);
      expect(gladiatorEncountersForWave(data, 5).map((e) => e.row), [1, 4]);
      expect(gladiatorEncountersForWave(data, 12), isEmpty);
      expect(gladiatorEncountersForWave(data, 13).single.row, 3);
      expect(
        gladiatorEncountersForWave(
          readGladiatorRowModuleData(_level())!,
          9,
        ).single.row,
        4,
      );
    },
  );

  test(
    'overview counts actual cage and punishment zombies without non-zombie fields',
    () {
      final level = _level(1);
      final data = readGladiatorRowModuleData(level)!;
      data.values['TrophyGridItemType'] = 'gladiator_trophy';
      data.encounters.first.spawns.add(
        GladiatorSpawnData(zombieType: 'disabled_spawn')..values['Count'] = 0,
      );
      data.punishmentPool.add(
        GladiatorPunishmentZombieData(zombieType: 'disabled_pool')
          ..values['Weight'] = 0,
      );
      level.objects.last.objData = data.toJson();
      expect(
        ZombieDiscovery.discoverZombies(level, LevelParser.parseLevel(level)),
        {
          'roman_shield_top',
          'gladiator_zombie',
          'roman_healer',
          'roman_flag',
          'roman_armor1',
          'roman_armor2',
          'roman_armor3',
        },
      );
    },
  );

  testWidgets(
    'preview colors exactly columns 3 through 7, with trophy at 5 and zombies at 7',
    (tester) async {
      final level = _level(1);
      final encounter = readGladiatorRowModuleData(level)!.encounters.first;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: GladiatorRowPreview(
              encounter: encounter,
              levelFile: level,
              rows: 5,
              cols: 9,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var row = 0; row < 5; row++) {
        for (var col = 0; col < 9; col++) {
          final cell = find.byKey(ValueKey('gladiator-cell-$col-$row'));
          final color =
              (tester.widget<Container>(cell).decoration as BoxDecoration)
                  .color;
          if (row == 1 && col >= 2 && col <= 6) {
            expect(
              color,
              (col == 4 ? Colors.green : Colors.red).withValues(alpha: 0.45),
            );
          } else {
            expect(color, isNot(Colors.red.withValues(alpha: 0.45)));
            expect(color, isNot(Colors.green.withValues(alpha: 0.45)));
          }
          expect(
            find.descendant(
              of: cell,
              matching: find.byIcon(Icons.emoji_events),
            ),
            row == 1 && col == 4 ? findsOneWidget : findsNothing,
          );
          expect(
            find.descendant(
              of: cell,
              matching: find.byType(GladiatorZombieIcon),
            ),
            row == 1 && col == 6 ? findsNWidgets(2) : findsNothing,
          );
        }
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'editor edits the selected wave, row, cage parameters and rewards without altering other groups',
    (tester) async {
      final level = _level(1);
      final original = jsonEncode(level.objects.last.objData);
      var changes = 0;
      await tester.pumpWidget(
        _app(_editor(level, wave: 12, changed: () => changes++)),
      );
      await tester.pumpAndSettle();
      expect(jsonEncode(level.objects.last.objData), original);
      expect(changes, 0);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('gladiator-encounter-Wave')),
            )
            .controller!
            .text,
        '12',
      );
      await _enter(tester, 'global-ArenaDuration', '25');
      await _enter(tester, 'global-PlantWinPlantfoodCount', '12');
      await _enter(tester, 'encounter-Wave', '0');
      await _enter(tester, 'encounter-Row', '4');
      await _enter(tester, 'encounter-WarningDuration', '4.5');
      await _enter(tester, 'encounter-FirstCageDelay', '1.5');
      await _tap(tester, find.byKey(const ValueKey('gladiator-cell-4-2')));
      await _enter(tester, 'spawn-0-Time', '2.5');
      await _enter(tester, 'spawn-0-GridX', '5');
      await _enter(tester, 'spawn-0-Count', '3');
      await _enter(tester, 'spawn-0-Interval', '2.0');
      await _selectLevel(tester, 'spawn-0', 0);
      expect(
        readGladiatorRowModuleData(level)!.encounters.last.spawns.first.level,
        0,
      );
      await _selectLevel(tester, 'spawn-0', 10);
      expect(
        readGladiatorRowModuleData(level)!.encounters.last.spawns.first.level,
        10,
      );
      await _selectLevel(tester, 'spawn-0', 4);
      await _selectLevel(tester, 'global', 10);
      expect(
        readGladiatorRowModuleData(
          level,
        )!.option('ZombieWinPunishmentZombieLevel'),
        10,
      );
      await _enter(tester, 'punishment-0-Weight', '15');
      final data = readGladiatorRowModuleData(level)!;
      expect(
        data.encounters.first.toJson(),
        ((jsonDecode(original) as Map)['Encounters'] as List).first,
      );
      final edited = data.encounters.last;
      expect(edited.wave, 0);
      expect(edited.row, 2);
      expect(edited.warningDuration, 4.5);
      expect(edited.firstCageDelay, 1.5);
      expect(edited.spawns.first.toJson(), {
        'Time': 2.5,
        'GridX': 5,
        'Count': 3,
        'Interval': 2.0,
        'Level': 4,
        'ZombieType': 'gladiator_zombie',
      });
      expect(data.option('ArenaDuration'), 25);
      expect(data.option('PlantWinPlantfoodCount'), 12);
      expect(data.punishmentPool.first.weight, 15);
      for (final invalid in ['-1', '2.5', 'NaN']) {
        await _enter(tester, 'encounter-Wave', invalid);
        expect(readGladiatorRowModuleData(level)!.encounters.last.wave, 0);
      }
      await _enter(tester, 'encounter-Row', '5');
      expect(readGladiatorRowModuleData(level)!.encounters.last.row, 2);
      expect(changes, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'new encounters and selected zombies export with required resources and can be removed',
    (tester) async {
      final level = PvzLevelFile(objects: []);
      await tester.pumpWidget(_app(_editor(level)));
      await tester.pumpAndSettle();
      expect(level.objects.single.objClass, _class);
      await _tap(
        tester,
        find.byKey(const ValueKey('addGridOverrideWaveGroup')),
      );
      expect(readGladiatorRowModuleData(level)!.encounters.single.wave, 0);
      await _tap(tester, find.byKey(const ValueKey('gladiator-add-spawn')));
      tester
          .widget<ZombieSelectionScreen>(find.byType(ZombieSelectionScreen))
          .onZombieSelected('roman_shield_top');
      await tester.pumpAndSettle();
      expect(
        readGladiatorRowModuleData(
          level,
        )!.encounters.single.spawns.single.zombieType,
        'roman_shield_top',
      );
      expect(
        level.objects.single.objData['ResourceGroupNames'],
        contains('ZombieRomanTopShieldGroup'),
      );
      await _tap(
        tester,
        find.byKey(const ValueKey('gladiator-add-punishment')),
      );
      tester
          .widget<ZombieSelectionScreen>(find.byType(ZombieSelectionScreen))
          .onZombieSelected('roman_healer');
      await tester.pumpAndSettle();
      expect(
        readGladiatorRowModuleData(level)!.punishmentPool.last.zombieType,
        'roman_healer',
      );
      expect(
        level.objects.single.objData['ResourceGroupNames'],
        contains('ZombieRomanHealerGroup'),
      );
      await _tap(
        tester,
        find
            .descendant(
              of: find.byType(GridOverrideWaveGroupsBar),
              matching: find.byIcon(Icons.delete_outline),
            )
            .first,
      );
      await tester.tap(
        find.widgetWithText(
          TextButton,
          lookupAppLocalizations(const Locale('en')).remove,
        ),
      );
      await tester.pumpAndSettle();
      expect(readGladiatorRowModuleData(level)!.encounters, isEmpty);
      expect(find.byType(GladiatorRowPreview), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final wave in [5, 13]) {
    testWidgets(
      'timeline opens the correct encounter and editor hint at wave $wave',
      (tester) async {
        final level = _level(1);
        String? opened;
        ModuleOpenHint? openHint;
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: WaveTimelineTab(
                levelFile: level,
                parsed: ParsedLevelData(
                  waveManager: WaveManagerData(
                    waveCount: 14,
                    waves: List.generate(14, (_) => []),
                  ),
                  objectMap: {'GladiatorRowModule': level.objects.last},
                ),
                onChanged: () {},
                onEditEvent: (_, _) async {},
                onAddEvent: (_) {},
                onEditWaveManagerSettings: () {},
                onOpenModule: (rtid, {hint}) {
                  opened = rtid;
                  openHint = hint;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final badge = find.byKey(ValueKey('waveTimelineExpectation-$wave-0'));
        await tester.scrollUntilVisible(badge, 300);
        await tester.tap(badge);
        await tester.pumpAndSettle();
        final preview = tester.widget<GladiatorRowPreview>(
          find.byType(GladiatorRowPreview),
        );
        expect(preview.encounter.wave, wave - 1);
        expect(preview.encounter.row, wave == 5 ? 1 : 3);
        await tester.tap(
          find.text(
            lookupAppLocalizations(const Locale('en')).openModuleSettings,
          ),
        );
        await tester.pumpAndSettle();
        expect(opened, _rtid);
        expect(openHint!.gladiatorWave, wave - 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      'narrow large-text editor, three help sections and preview resize correctly in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final level = _level(1);
        final l10n = lookupAppLocalizations(Locale(locale));
        await tester.pumpWidget(_app(_editor(level), locale: locale, scale: 2));
        await tester.pumpAndSettle();
        await _tap(
          tester,
          find.descendant(
            of: find.byType(GridOverrideWaveGroupsBar),
            matching: find.text(l10n.groupN(2)),
          ),
        );
        await tester.ensureVisible(find.byType(GladiatorRowPreview));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _tap(tester, find.byIcon(Icons.help_outline));
        expect(find.text(l10n.gladiatorHelpOverview), findsOneWidget);
        expect(find.text(l10n.gladiatorHelpUsage), findsOneWidget);
        expect(find.text(l10n.gladiatorHelpTips), findsOneWidget);
        final scroll = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(AlertDialog),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(
          find
              .text(l10n.gladiatorHelpTips)
              .hitTestable(at: const Alignment(0, 0.99)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.byType(AlertDialog))).pop();
        await tester.pumpAndSettle();
        await showPreview(tester, level);
        tester.view.physicalSize = const Size(800, 380);
        await tester.pumpAndSettle();
        expect(find.byType(GladiatorRowPreview), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> showPreview(WidgetTester tester, PvzLevelFile level) async {
  showGladiatorRowWavePreviewDialog(
    tester.element(find.byType(GladiatorRowModuleScreen)),
    levelFile: level,
    waveIndex: 13,
    data: readGladiatorRowModuleData(level)!,
  );
  await tester.pumpAndSettle();
}
