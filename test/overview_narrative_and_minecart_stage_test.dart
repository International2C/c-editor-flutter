import 'dart:convert';

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {String locale = 'en'}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(platform: TargetPlatform.android),
  home: home,
);

PvzLevelFile _level(LevelDefinitionData definition, [PvzObject? stage]) =>
    PvzLevelFile(
      objects: [
        PvzObject(objClass: 'LevelDefinition', objData: definition.toJson()),
        ?stage,
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
      for (final locale in ['en', 'zh', 'ru'])
        NarrativeCatalog.load(Locale(locale)),
    ]);
  });

  testWidgets(
    'minecarts require the real base class and refresh after lawn selection',
    (tester) async {
      final stage = PvzObject(
        aliases: ['MyStage'],
        objClass: 'StageModuleProperties',
        objData: {'BelongsToWorld': 'kongfu'},
      );
      final level = _level(
        LevelDefinitionData(stageModule: 'RTID(MyStage@CurrentLevel)'),
        stage,
      );
      var stageSelections = 0;
      ModuleSelectionResult? selected;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await Navigator.of(context)
                    .push<ModuleSelectionResult>(
                      MaterialPageRoute(
                        builder: (_) => ModuleSelectionScreen(
                          existingObjClasses: const {},
                          stateBucketId: 'minecart-stage-guard',
                          levelFile: level,
                          onSelectStage: () async {
                            stageSelections++;
                            stage.objClass = 'KongFuStageProperties';
                            stage.objData = {'BelongsToWorld': 'egypt'};
                          },
                        ),
                      ),
                    );
              },
              child: const Text('Open modules'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open modules'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'MechanismPlankProperties',
      );
      await tester.pumpAndSettle();
      final title = find.text('Connected Minecart');
      final opacity = find
          .ancestor(of: title, matching: find.byType(Opacity))
          .first;
      expect(tester.widget<Opacity>(opacity).opacity, 0.6);
      await tester.tap(title);
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      )!;
      expect(
        find.text(l10n.mechanismPlankStageRequiredMessage),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      expect(stageSelections, 0);
      expect(selected, isNull);

      await tester.tap(title);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.switchStage));
      await tester.pumpAndSettle();
      expect(stageSelections, 1);
      expect(tester.widget<Opacity>(opacity).opacity, 1);
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(selected?.metadata.objClass, 'MechanismPlankProperties');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('built-in Kongfu lawns enable Connected Minecarts', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ModuleSelectionScreen(
          existingObjClasses: const {},
          stateBucketId: 'minecart-builtin-stage',
          levelFile: _level(
            LevelDefinitionData(stageModule: 'RTID(KongfuStage@LevelModules)'),
          ),
        ),
      ),
    );
    await tester.enterText(
      find.byType(TextField).first,
      'MechanismPlankProperties',
    );
    await tester.pumpAndSettle();
    final opacity = find
        .ancestor(
          of: find.text('Connected Minecart'),
          matching: find.byType(Opacity),
        )
        .first;
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    expect(tester.takeException(), isNull);
  });

  for (final (locale, disablePeavine) in [
    ('en', true),
    ('zh', false),
    ('ru', null),
  ]) {
    testWidgets(
      '$locale overview shows localized dialogue and Pea Symbiosis status',
      (tester) async {
        tester.view.physicalSize = const Size(400, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final catalog = await NarrativeCatalog.load(Locale(locale));
        final entry = catalog.dialogues.first;
        final level = _level(
          LevelDefinitionData(
            firstIntroNarrative: entry.value,
            firstOutroNarrative: 'UNKNOWN_USER_DIALOGUE',
            disablePeavine: disablePeavine,
          ),
        );
        final before = jsonEncode(level.toJson());
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: LevelOverviewDialog(
                levelFile: level,
                parsed: LevelParser.parseLevel(level),
                fileName: 'Narrative.json',
                onClose: () {},
              ),
            ),
            locale: locale,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('${catalog.strings.firstIntro}: ${entry.title}'),
          findsOneWidget,
        );
        expect(
          find.text('${catalog.strings.firstOutro}: UNKNOWN_USER_DIALOGUE'),
          findsOneWidget,
        );
        final chip = tester.widget<ResourceChip>(
          find.byKey(const ValueKey('overview-pea-symbiosis')),
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(LevelOverviewDialog)),
        )!;
        expect(
          chip.tooltip,
          disablePeavine == true
              ? l10n.peaSymbiosisInactive
              : l10n.peaSymbiosisActive,
        );
        expect(chip.icon, disablePeavine == true ? Icons.link_off : Icons.link);
        expect(jsonEncode(level.toJson()), before);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
