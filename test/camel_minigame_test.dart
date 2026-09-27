import 'dart:convert';
import 'dart:io';
import 'package:c_editor/data/camel_minigame_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/camel_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:c_editor/theme/app_theme.dart' show editorErrorIcon;
import 'package:c_editor/widgets/camel_minigame_conflicts.dart';
import 'package:c_editor/widgets/camel_spawn_distance_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _object(String alias, String cls, Map<String, dynamic> data) =>
    PvzObject(aliases: [alias], objClass: cls, objData: data);

PvzLevelFile _level({
  String selection = 'preset',
  bool generator = false,
  List<String> zombies = const ['camel_onehump_touch'],
}) => PvzLevelFile(
  objects: [
    _object(
      'LevelDefinition',
      'LevelDefinition',
      LevelDefinitionData(
        stageModule: 'RTID(EgyptStage@LevelModules)',
        modules: [
          'RTID(Camel@CurrentLevel)',
          'RTID(SeedBank@CurrentLevel)',
          'RTID(${generator ? 'Generator' : 'WaveModule'}@CurrentLevel)',
        ],
      ).toJson(),
    ),
    _object('Camel', 'CamelMinigameProperties', {
      ...CamelMinigamePropertiesData().toJson(),
      'KeepCustomField': {'value': 23},
    }),
    _object(
      'SeedBank',
      'SeedBankProperties',
      SeedBankData(selectionMethod: selection).toJson(),
    ),
    if (generator)
      _object('Generator', 'WaveGeneratorProperties', {
        'Waves': [
          {
            'Zombies': [
              for (final zombie in zombies) {'Type': zombie},
            ],
          },
        ],
      })
    else ...[
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
          for (final zombie in zombies)
            {
              'Type': zombie.startsWith('RTID(')
                  ? zombie
                  : 'RTID($zombie@ZombieTypes)',
            },
        ],
      }),
    ],
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

Widget _editor(PvzLevelFile level) => CamelMinigameScreen(
  rtid: 'RTID(Camel@CurrentLevel)',
  levelFile: level,
  onChanged: () {},
  onBack: () {},
);

List<LevelIssue> _issues(BuildContext context, PvzLevelFile level) =>
    LevelIssueRegistry.forLevel(context, level)
        .where(
          (issue) =>
              issue.id.startsWith('camelMinigame') ||
              issue.id.contains('CamelMinigameIntro'),
        )
        .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ReferenceRepository.init);

  test(
    'Mummy Memory appears immediately before Last Stand with unchanged defaults',
    () {
      final modules = ModuleRegistry.all;
      final index = modules.indexWhere(
        (m) => m.objClass == 'CamelMinigameProperties',
      );
      expect(index, greaterThanOrEqualTo(0));
      expect(modules[index + 1].objClass, 'LastStandMinigameProperties');
      expect(CamelMinigamePropertiesData().toJson(), {
        'AdditionalXBufferBetweenChains': 50,
        'CamelSegmentRiseStagger': 0.33,
        'CardMatchTime': 0,
        'CardMatchingTime': 0.5,
        'CardNoMatchTime': 1.5,
        'CardTypesUsed': 3,
        'InitialTutorialZombieRiseDelay': 2,
        'MaxSpawnX': 600,
        'MinSpawnXEnd': 500,
        'MinSpawnXStart': 550,
        'ShowTutorial': true,
      });
    },
  );

  test(
    'locales remove obsolete advice and provide dedicated help sections',
    () {
      for (final locale in ['zh', 'en', 'ru']) {
        final text =
            jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
                as Map;
        for (final key in [
          'camelMinigameWaveManagerHint',
          'camelMinigameWaveManagerHintTitle',
          'camelRiseFromGroundOnlyCamelTouch',
          'moduleHelpCamelTimingsBody',
        ]) {
          expect(text, isNot(contains(key)));
        }
        for (final key in [
          'moduleHelpCamelOverviewBody',
          'moduleHelpCamelSpawningBody',
          'moduleHelpCamelTutorialBody',
          'moduleHelpCamelTipsBody',
        ]) {
          expect(text[key], isNotEmpty);
        }
        expect(
          text['moduleHelpCamelTipsBody'],
          startsWith(text['camelCompatibilityWarning'] as String),
        );
        expect(text['camelCardTypesUsed'], contains('CardTypesUsed'));
        if (locale == 'zh') {
          expect(text['moduleTitle_CamelMinigameProperties'], '记忆骆驼牌');
          for (final key in [
            'camelRiseStagger',
            'camelCardMatchTime',
            'camelCardMatchingTime',
            'camelCardNoMatchTime',
            'camelTutorialRiseDelay',
          ]) {
            expect(text[key], contains('单位：秒'));
          }
        }
      }
    },
  );

  for (final generator in [false, true]) {
    test(
      'detects incompatible spawns in ${generator ? 'generator' : 'wave manager'}',
      () {
        final level = _level(
          generator: generator,
          zombies: [
            ...CamelMinigameUtils.memoryZombieTypes,
            'tutorial',
            'camel_onehump',
          ],
        );
        final original = jsonEncode(level.toJson());
        expect(CamelMinigameUtils.incompatibleZombies(level), [
          'camel_onehump',
          'tutorial',
        ]);
        expect(jsonEncode(level.toJson()), original);
      },
    );
  }

  test(
    'ignores unused events, stage defaults, zombie definitions and restrictions',
    () {
      final level = _level();
      level.objects.addAll([
        _object('Unused', 'SpawnZombiesJitteredWaveActionProps', {
          'Zombies': [
            {'Type': 'RTID(tutorial@ZombieTypes)'},
          ],
        }),
        _object('UnusedZombie', 'ZombieType', {'TypeName': 'tutorial'}),
        _object('UnusedGenerator', 'WaveGeneratorProperties', {
          'AddToZombiePool': [
            {'Type': 'tutorial'},
          ],
        }),
        _object('Gravity', 'GravityGeneratorWaveActionProps', {
          'TargetRestriction': ['RTID(UnusedZombie@CurrentLevel)'],
        }),
      ]);
      level.objects[4].objData['Waves'][0].add('RTID(Gravity@CurrentLevel)');
      expect(CamelMinigameUtils.incompatibleZombies(level), isEmpty);
    },
  );

  test(
    'custom memory zombies are recognized by behavior, not alias spelling',
    () {
      final level = _level(zombies: ['RTID(CustomCamel@CurrentLevel)']);
      level.objects.add(
        _object('CustomCamel', 'ZombieType', {
          'TypeName': 'camel_segment_touch',
          'ZombieClass': 'ZombieCamelTouch',
        }),
      );
      expect(CamelMinigameUtils.incompatibleZombies(level), isEmpty);
      level.objects.last.objData['ZombieClass'] = 'ZombieBasic';
      expect(CamelMinigameUtils.incompatibleZombies(level), ['CustomCamel']);
    },
  );

  test('global and per-wave pools and seed rain are checked', () {
    final level = _level(generator: true);
    level.objects[3].objData['AddToZombiePool'] = [
      {'Type': 'tutorial'},
    ];
    level.objects[3].objData['Waves'][0]['AddToZombiePool'] = [
      {'Type': 'camel_twohump'},
    ];
    level.objects.first.objData['Modules'].add('RTID(Rain@CurrentLevel)');
    level.objects.add(
      _object('Rain', 'SeedRainProperties', {
        'SeedRains': [
          {'ZombieTypeName': 'conehead'},
        ],
      }),
    );
    expect(CamelMinigameUtils.incompatibleZombies(level), [
      'camel_twohump',
      'conehead',
      'tutorial',
    ]);
  });

  for (final language in ['zh', 'en', 'ru']) {
    testWidgets('$language: conflict icons and titles fit narrow large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          _editor(_level(selection: 'chooser', zombies: ['tutorial'])),
          language: language,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      final conflicts = find.byType(CamelMinigameConflicts);
      final cards = find.descendant(of: conflicts, matching: find.byType(Card));
      expect(cards, findsNWidgets(2));
      for (var i = 0; i < 2; i++) {
        final card = cards.at(i);
        final icon = find.descendant(
          of: card,
          matching: find.byIcon(editorErrorIcon),
        );
        expect(icon, findsOneWidget);
        final title = find
            .descendant(of: card, matching: find.byType(Text))
            .first;
        expect(
          tester.getRect(icon).right,
          lessThan(tester.getRect(title).left),
        );
        expect(
          tester.getRect(title).right,
          lessThanOrEqualTo(tester.getRect(card).right),
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$language: conflicts are active, localized and clear after fixing',
      (tester) async {
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final level = _level(
                  selection: 'chooser',
                  zombies: ['tutorial'],
                );
                level.objects.first.objData['Modules'].add(
                  'RTID(Intro@CurrentLevel)',
                );
                level.objects.add(
                  _object('Intro', 'StandardLevelIntroProperties', {}),
                );
                final issues = _issues(context, level);
                expect(issues, hasLength(3));
                expect(issues.every((i) => i.isError), isTrue);
                expect(
                  issues.map((i) => i.message),
                  contains(l10n.conflictDesc_CamelMinigameIntro),
                );
                expect(
                  issues.map((i) => i.message),
                  contains(l10n.conflictDesc_CamelMinigameChooser),
                );
                level.objects.first.objData['Modules'] = [
                  'RTID(Camel@CurrentLevel)',
                  'RTID(SeedBank@CurrentLevel)',
                ];
                level.objects[2].objData['SelectionMethod'] = 'preset';
                expect(_issues(context, level), isEmpty);
                final missing = LevelIssueRegistry.forLevel(
                  context,
                  level,
                ).where((i) => i.id == 'missingEssentials');
                expect(
                  missing.expand((i) => i.bulletPoints),
                  isNot(
                    contains(l10n.moduleTitle_StandardLevelIntroProperties),
                  ),
                );
                level.objects.first.objData['Modules'] = [
                  'RTID(SeedBank@CurrentLevel)',
                ];
                level.objects[2].objData['SelectionMethod'] = 'chooser';
                expect(_issues(context, level), isEmpty);
                return const SizedBox.shrink();
              },
            ),
            language: language,
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$language: narrow layout, card controls, timings and help', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final level = _level();
      final l10n = lookupAppLocalizations(Locale(language));
      await tester.pumpWidget(
        _app(_editor(level), language: language, scale: 1.6),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('camelCompatibilityWarning')))
            .dy,
        lessThan(
          tester.getTopLeft(find.text(l10n.camelGenerationParameters)).dy,
        ),
      );
      final card = find.byKey(const ValueKey('camelCardTypesControl'));
      expect(
        find.descendant(of: card, matching: find.byType(Image)),
        findsNWidgets(7),
      );
      expect(
        find.descendant(of: card, matching: find.byType(TextField)),
        findsNothing,
      );
      for (var i = 0; i < 4; i++) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('camelCardTypesIncrease')),
        );
        await tester.tap(find.byKey(const ValueKey('camelCardTypesIncrease')));
        await tester.pump();
      }
      expect(level.objects[1].objData['CardTypesUsed'], 7);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('camelCardTypesIncrease')),
            )
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(const ValueKey('camelCardTypesDecrease')));
        await tester.pump();
      }
      expect(level.objects[1].objData['CardTypesUsed'], 1);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('camelCardTypesDecrease')),
            )
            .onPressed,
        isNull,
      );
      final field = find.byKey(const ValueKey('camelCardMatchingTime'));
      await tester.ensureVisible(field);
      await tester.showKeyboard(field);
      final editable = find.descendant(
        of: field,
        matching: find.byType(EditableText),
      );
      final focus = tester.widget<EditableText>(editable).focusNode;
      for (final text in ['', '1', '1.', '1.25']) {
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        );
        await tester.pump();
        expect(tester.widget<EditableText>(editable).focusNode, same(focus));
        expect(focus.hasFocus, isTrue);
      }
      expect(level.objects[1].objData['CardMatchingTime'], 1.25);
      expect(level.objects[1].objData['KeepCustomField'], {'value': 23});
      tester.view.physicalSize = const Size(260, 850);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text(l10n.moduleHelpCamelOverviewBody), findsOneWidget);
      expect(find.text(l10n.moduleHelpCamelSpawningBody), findsOneWidget);
      expect(find.text(l10n.moduleHelpCamelTutorialBody), findsOneWidget);
      expect(find.text(l10n.moduleHelpCamelTipsBody), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('preview uses 64-unit tile edges and updates outside the lawn', (
    tester,
  ) async {
    Future<void> preview(double maximum) => tester.pumpWidget(
      _app(
        Scaffold(
          body: CamelSpawnDistancePreview(
            rows: 5,
            columns: 9,
            maxSpawnX: maximum,
            minSpawnXStart: 64,
            minSpawnXEnd: 0,
          ),
        ),
      ),
    );
    await preview(600);
    final first = tester.getRect(
      find.byKey(const ValueKey('camelSpawnCell-0-0')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('camelSpawnCell-0-1')),
    );
    final end = tester.getRect(
      find.byKey(const ValueKey('camelSpawnCell-0-8')),
    );
    final startLine = tester.getCenter(
      find.byKey(const ValueKey('camelSpawnLine-MinSpawnXStart')),
    );
    final endLine = tester.getCenter(
      find.byKey(const ValueKey('camelSpawnLine-MinSpawnXEnd')),
    );
    expect(endLine.dx, closeTo(first.left, 0.01));
    expect(startLine.dx, closeTo(second.left, 0.01));
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('camelSpawnLine-MaxSpawnX')))
          .dx,
      greaterThan(end.right),
    );
    await preview(128);
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('camelSpawnLine-MaxSpawnX')))
          .dx,
      closeTo(
        tester.getRect(find.byKey(const ValueKey('camelSpawnCell-0-2'))).left,
        0.01,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('seed bank conflict clears immediately when preset is selected', (
    tester,
  ) async {
    final level = _level(selection: 'chooser');
    await tester.pumpWidget(
      _app(
        SeedBankPropertiesScreen(
          rtid: 'RTID(SeedBank@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection:
              (
                _, {
                excludeIds,
                initialSelectedIds,
                blockRealmExclusiveInChooser = false,
                blockHiddenPlantsInChooser = false,
                allowDuplicateSelection = false,
              }) {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('camelMinigameChooserConflict')),
      findsOneWidget,
    );
    final preset = find.byKey(const ValueKey('seedBankPresetModeChip'));
    await tester.ensureVisible(preset);
    await tester.tap(preset);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('camelMinigameChooserConflict')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
