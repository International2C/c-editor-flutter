import 'dart:convert';

import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/gladiator_row_module_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzLevelFile _levelWithModules(Set<String> classes) {
  final objects = [
    for (final (index, objClass) in classes.indexed)
      PvzObject(
        aliases: ['Module$index'],
        objClass: objClass,
        objData: <String, dynamic>{
          'UntouchedField': {'value': index},
        },
      ),
  ];
  return PvzLevelFile(
    objects: [
      PvzObject(
        aliases: ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: [
            for (var index = 0; index < objects.length; index++)
              'RTID(Module$index@CurrentLevel)',
          ],
        ).toJson(),
      ),
      ...objects,
    ],
  );
}

Future<void> _withContext(
  WidgetTester tester,
  Locale locale,
  void Function(BuildContext context) verify,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          verify(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();
  expect(tester.takeException(), isNull);
}

void main() {
  const compatibleGroups = [
    {'MoonLifeSupportSystemProperties', 'LastStandMinigameProperties'},
    {'WaveGeneratorProperties', 'RenaiModuleProperties'},
    {'WaveGeneratorProperties', 'WitchModuleProperties'},
    {
      'MoonLifeSupportSystemProperties',
      'LastStandMinigameProperties',
      'WaveGeneratorProperties',
      'RenaiModuleProperties',
      'WitchModuleProperties',
    },
  ];

  for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
    testWidgets(
      '${locale.languageCode}: Speed-Up Tiles warn only with active conflicting tile modules',
      (tester) async {
        await _withContext(tester, locale, (context) {
          final l10n = AppLocalizations.of(context)!;
          for (final classes in [
            {'SpeedUpTileModuleProperties'},
            {'TunnelDefendModuleProperties'},
            {'SpeedUpTileModuleProperties', 'TunnelDefendModuleProperties'},
          ]) {
            for (final brickMapIndex in [0, 3]) {
              final level = _levelWithModules(classes);
              for (final object in level.objects) {
                if (object.objClass == 'TunnelDefendModuleProperties') {
                  object.objData['BrickMapIndex'] = brickMapIndex;
                }
              }
              final original = jsonEncode(level.toJson());
              final issues = LevelIssueRegistry.forLevel(
                context,
                level,
              ).where((issue) => issue.id == 'speedUpTileCompatibilityWarning');
              final incompatible =
                  classes.contains('SpeedUpTileModuleProperties') &&
                  classes.contains('TunnelDefendModuleProperties');
              expect(issues, hasLength(incompatible ? 1 : 0));
              if (incompatible) {
                expect(issues.single.isError, isFalse);
                expect(
                  issues.single.message,
                  l10n.speedUpTileCompatibilityWarning,
                );
              }
              expect(jsonEncode(level.toJson()), original);

              if (incompatible) {
                // Existing objects are not active modules after their references are removed.
                for (final retained in [null, 0, 1]) {
                  level.objects.first.objData['Modules'] = [
                    if (retained != null) 'RTID(Module$retained@CurrentLevel)',
                  ];
                  expect(
                    LevelIssueRegistry.forLevel(context, level).where(
                      (issue) => issue.id == 'speedUpTileCompatibilityWarning',
                    ),
                    isEmpty,
                  );
                }
              }
            }
          }
        });
      },
    );

    testWidgets(
      '${locale.languageCode}: level settings follows active Speed-Up Tiles conflicts',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final l10n = lookupAppLocalizations(locale);
        final banner = find.byKey(
          const ValueKey('speedUpTileCompatibilityWarning'),
        );
        for (final brickMapIndex in [0, 3]) {
          final level = _levelWithModules({
            'SpeedUpTileModuleProperties',
            'TunnelDefendModuleProperties',
          });
          level.objects[1].objData = {'Roads': []};
          level.objects[2].objData = {'BrickMapIndex': brickMapIndex};
          final definition = level.objects.first;
          Widget app() => MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: LevelSettingsTab(
                levelDef: LevelDefinitionData.fromJson(
                  Map<String, dynamic>.from(definition.objData as Map),
                ),
                objectMap: {
                  for (final object in level.objects)
                    for (final alias in object.aliases ?? const <String>[])
                      alias: object,
                },
                onEditBasicInfo: () {},
                onEditModule: (_) {},
                onRemoveModule: (_) {},
                onReorderModules:
                    ({
                      required isCoreSection,
                      required oldIndex,
                      required newIndex,
                    }) {},
                onNavigateToAddModule: () {},
              ),
            ),
          );

          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
          expect(banner, findsOneWidget);
          expect(
            find.descendant(
              of: banner,
              matching: find.text(l10n.speedUpTileCompatibilityWarning),
            ),
            findsOneWidget,
          );

          for (final retained in [0, 1]) {
            definition.objData['Modules'] = [
              'RTID(Module$retained@CurrentLevel)',
            ];
            await tester.pumpWidget(app());
            await tester.pumpAndSettle();
            expect(banner, findsNothing);
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );

    testWidgets(
      '${locale.languageCode}: Gladiatorial Row warns only with an active Wave Generator',
      (tester) async {
        await _withContext(tester, locale, (context) {
          final l10n = AppLocalizations.of(context)!;
          for (final classes in [
            {'GladiatorRowModuleProperties'},
            {'WaveGeneratorProperties'},
            {'GladiatorRowModuleProperties', 'WaveManagerModuleProperties'},
            {'GladiatorRowModuleProperties', 'WaveGeneratorProperties'},
          ]) {
            final level = _levelWithModules(classes);
            final original = jsonEncode(level.toJson());
            final issues = LevelValidator.validate(context, level).where(
              (issue) =>
                  issue.message ==
                  l10n.gladiatorWaveGeneratorCompatibilityWarning,
            );
            final incompatible =
                classes.contains('GladiatorRowModuleProperties') &&
                classes.contains('WaveGeneratorProperties');
            expect(issues, hasLength(incompatible ? 1 : 0));
            if (incompatible) expect(issues.single.isError, isFalse);
            expect(jsonEncode(level.toJson()), original);
            if (incompatible) {
              // Either module being unlinked must clear the warning, even if its object remains.
              for (final retained in [0, 1]) {
                level.objects.first.objData['Modules'] = [
                  'RTID(Module$retained@CurrentLevel)',
                ];
                expect(
                  LevelIssueRegistry.forLevel(context, level).where(
                    (issue) =>
                        issue.id ==
                        'gladiatorWaveGeneratorCompatibilityWarning',
                  ),
                  isEmpty,
                );
              }
            }
          }
        });
      },
    );

    testWidgets(
      '${locale.languageCode}: both editors display and clear the Gladiatorial Row warning',
      (tester) async {
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final l10n = lookupAppLocalizations(locale);
        for (final generatorEditor in [false, true]) {
          final level = _levelWithModules({
            'GladiatorRowModuleProperties',
            'WaveGeneratorProperties',
          });
          level.objects[1].objData = GladiatorRowModulePropertiesData()
              .toJson();
          level.objects[2].objData = WaveGeneratorPropertiesData().toJson();
          Widget app() => MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.6)),
              child: child!,
            ),
            home: generatorEditor
                ? WaveGeneratorModuleScreen(
                    rtid: 'RTID(Module1@CurrentLevel)',
                    levelFile: level,
                    onChanged: () {},
                    onBack: () {},
                    onRequestZombieSelection: (_) {},
                  )
                : GladiatorRowModuleScreen(
                    rtid: 'RTID(Module0@CurrentLevel)',
                    levelFile: level,
                    onChanged: () {},
                    onBack: () {},
                  ),
          );
          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
          final banner = find.byKey(
            const ValueKey('gladiatorWaveGeneratorCompatibilityWarning'),
          );
          expect(banner, findsOneWidget);
          expect(
            find.descendant(
              of: banner,
              matching: find.text(
                l10n.gladiatorWaveGeneratorCompatibilityWarning,
              ),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          level.objects.first.objData['Modules'] = [
            'RTID(Module${generatorEditor ? 1 : 0}@CurrentLevel)',
          ];
          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
          expect(banner, findsNothing);
          expect(tester.takeException(), isNull);
        }
      },
    );

    for (final classes in compatibleGroups) {
      testWidgets(
        '${locale.languageCode}: verified-compatible modules do not warn: ${classes.join(', ')}',
        (tester) async {
          await _withContext(tester, locale, (context) {
            final level = _levelWithModules(classes);
            final original = jsonDecode(jsonEncode(level.toJson()));

            expect(
              ConflictRegistry.getActiveConflicts(context, classes),
              isEmpty,
            );
            expect(
              LevelValidator.validate(
                context,
                level,
              ).where((issue) => issue.isError),
              isEmpty,
            );
            expect(level.toJson(), original);
          });
        },
      );
    }

    testWidgets(
      '${locale.languageCode}: Wave Manager conflicts remain with compatible modules',
      (tester) async {
        await _withContext(tester, locale, (context) {
          const classes = {
            'WaveGeneratorProperties',
            'WaveManagerModuleProperties',
            'WaveManagerProperties',
            'RenaiModuleProperties',
            'WitchModuleProperties',
          };
          final l10n = AppLocalizations.of(context)!;
          final expected = [
            l10n.conflictDesc_WaveGeneratorWaveManagerModule,
            l10n.conflictDesc_WaveGeneratorWaveManager,
          ];
          expect(
            ConflictRegistry.getActiveConflicts(
              context,
              classes,
            ).map((pair) => pair.second),
            unorderedEquals(expected),
          );
          expect(
            LevelValidator.validate(
              context,
              _levelWithModules(classes),
            ).where((issue) => issue.isError).map((issue) => issue.message),
            unorderedEquals(expected),
          );
        });
      },
    );

    testWidgets(
      '${locale.languageCode}: Wave Generator conflicts with Level Escalation',
      (tester) async {
        await _withContext(tester, locale, (context) {
          final l10n = AppLocalizations.of(context)!;
          const classes = {
            'WaveGeneratorProperties',
            'LevelEscalationModuleProperties',
          };
          expect(
            ConflictRegistry.getActiveConflicts(
              context,
              classes,
            ).map((pair) => pair.second),
            [l10n.conflictDesc_WaveGeneratorLevelEscalation],
          );
          expect(
            LevelValidator.validate(
              context,
              _levelWithModules(classes),
            ).where((issue) => issue.isError).map((issue) => issue.message),
            [l10n.conflictDesc_WaveGeneratorLevelEscalation],
          );
          // Level Escalation alone or with Wave Manager stays conflict-free.
          for (final alone in [
            {'LevelEscalationModuleProperties'},
            {
              'LevelEscalationModuleProperties',
              'WaveManagerModuleProperties',
              'WaveManagerProperties',
            },
          ]) {
            expect(
              ConflictRegistry.getActiveConflicts(context, alone),
              isEmpty,
            );
          }
        });
      },
    );

    testWidgets(
      '${locale.languageCode}: Last Stand intro conflict remains with Life Support',
      (tester) async {
        await _withContext(tester, locale, (context) {
          const classes = {
            'MoonLifeSupportSystemProperties',
            'LastStandMinigameProperties',
            'StandardLevelIntroProperties',
          };
          final l10n = AppLocalizations.of(context)!;
          expect(
            ConflictRegistry.getActiveConflicts(
              context,
              classes,
            ).map((pair) => pair.second),
            [l10n.conflictDesc_LastStandIntro],
          );
          expect(
            LevelValidator.validate(
              context,
              _levelWithModules(classes),
            ).where((issue) => issue.isError).map((issue) => issue.message),
            [l10n.conflictDesc_LastStandIntro],
          );
        });
      },
    );
  }
}
