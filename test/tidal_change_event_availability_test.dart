import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tidalChange = 'TidalChangeWaveActionProps';

PvzLevelFile _level({String? stageClass, bool submarine = false}) =>
    PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            stageModule: stageClass == null
                ? 'RTID(BeachStage@LevelModules)'
                : 'RTID(CustomStage@CurrentLevel)',
          ).toJson(),
        ),
        if (stageClass != null)
          PvzObject(
            aliases: ['CustomStage'],
            objClass: stageClass,
            objData: {
              'InitSubmarineInfo': {
                'Width': submarine ? 3 : 0,
                'Height': submarine ? 3 : 0,
              },
            },
          ),
      ],
    );

void main() {
  test('tide change is available independently of submarine-only currents', () {
    for (final (stageClass, submarine, currentsAvailable) in [
      (null, false, false),
      ('StageModuleProperties', false, false),
      ('DeepseaStageProperties', false, false),
      ('DeepseaStageProperties', true, true),
    ]) {
      final level = _level(stageClass: stageClass, submarine: submarine);
      final definition = LevelParser.parseLevel(level).levelDef;
      expect(
        LevelParser.isWaveEventAvailable(_tidalChange, definition, level),
        isTrue,
        reason: '$stageClass / submarine: $submarine',
      );
      expect(
        LevelParser.isWaveEventAvailable(
          'TideWaveWaveActionProps',
          definition,
          level,
        ),
        currentsAvailable,
      );
    }
  });

  test('tide change appears between potion drop and low tide', () {
    final events = EventRegistry.getAll();
    final potion = events.indexWhere(
      (event) => event.defaultObjClass == 'ZombiePotionActionProps',
    );
    expect(potion, greaterThanOrEqualTo(0));
    expect(events[potion + 1].defaultObjClass, _tidalChange);
    expect(
      events[potion + 2].defaultObjClass,
      'BeachStageEventZombieSpawnerProps',
    );
    expect(events[potion + 1].category, EventCategory.environmental);
  });

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets('beach picker can find and select tide change in $locale', (
      tester,
    ) async {
      final l10n = lookupAppLocalizations(Locale(locale));
      EventMetadata? selected;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EventSelectionScreen(
            waveIndex: 1,
            levelFile: _level(),
            onEventSelected: (event) => selected = event,
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, _tidalChange);
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.eventTitle_TidalChangeWaveActionProps),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text(l10n.eventCategoryEnvironmental));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.eventCategoryEnvironmental));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.eventDesc_TidalChangeWaveActionProps),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.eventTitle_TidalChangeWaveActionProps));
      expect(selected?.defaultObjClass, _tidalChange);
      final data = selected!.initialDataFactory() as TidalChangeWaveActionData;
      expect(data.toJson(), {
        'TidalChange': {'ChangeAmount': 0, 'ChangeType': 'absolute'},
      });
      expect(tester.takeException(), isNull);
    });
  }
}
