import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/beach_stage_event_screen.dart';
import 'package:c_editor/screens/editor/events/dino_run_event_screen.dart';
import 'package:c_editor/screens/editor/events/dino_tread_event_screen.dart';
import 'package:c_editor/screens/editor/events/grid_item_spawn_event_screen.dart';
import 'package:c_editor/screens/editor/events/parachute_rain_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      GridItemRepository.init(),
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
    ]);
  });

  final cases =
      <({String name, String alias, Widget Function(PvzLevelFile) build})>[
        (
          name: 'Beach Stage',
          alias: 'BeachSpawn',
          build: (level) => BeachStageEventScreen(
            rtid: 'RTID(BeachSpawn@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
        (
          name: 'Grid Item Spawn',
          alias: 'GridItemSpawn',
          build: (level) => GridItemSpawnEventScreen(
            rtid: 'RTID(GridItemSpawn@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestGridItemSelection: (_) {},
            onRequestZombieSelection: (_) {},
          ),
        ),
        (
          name: 'Parachute Rain',
          alias: 'ParachuteRain',
          build: (level) => ParachuteRainEventScreen(
            rtid: 'RTID(ParachuteRain@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            eventSubtitle: 'Parachute Rain',
            eventObjClass: 'ParachuteRainZombieSpawnerProps',
            onRequestZombieSelection: (_) {},
          ),
        ),
        (
          name: 'Dino Run',
          alias: 'DinoRun',
          build: (level) => DinoRunEventScreen(
            rtid: 'RTID(DinoRun@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
        (
          name: 'Dino Tread',
          alias: 'DinoTread',
          build: (level) => DinoTreadEventScreen(
            rtid: 'RTID(DinoTread@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      ];

  for (final testCase in cases) {
    testWidgets('${testCase.name} uses the shared warning label and helper', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final level = PvzLevelFile(objects: []);
      final l10n = lookupAppLocalizations(const Locale('zh'));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: testCase.build(level),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.waveStartMessageLabel), findsOneWidget);
      final field = find.byKey(const ValueKey('waveStartMessageField'));
      expect(field, findsOneWidget);

      final widget = tester.widget<Widget>(field);
      final renderedTextField = widget is TextField
          ? widget
          : tester.widget<TextField>(
              find.descendant(of: field, matching: find.byType(TextField)),
            );
      final decoration = renderedTextField.decoration!;
      expect(decoration.helperText, l10n.optionalWarningText);
      expect(decoration.hintText, isNull);

      await tester.ensureVisible(field);
      await tester.enterText(field, '[WARNING_TEST]');
      await tester.pump();
      final event = level.objects.firstWhere(
        (object) => object.aliases?.contains(testCase.alias) == true,
      );
      expect((event.objData as Map)['WaveStartMessage'], '[WARNING_TEST]');
      expect(tester.takeException(), isNull);
    });
  }
}
