import 'package:c_editor/data/models/zomboss_robot_spawn_entry.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/tabs/vase_breaker_tab.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/zomboss_mech_robot_spawn_list.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:c_editor/widgets/zomboss_mech_zombie_type_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Future<ZombieSelectionScreen> _openZombiePicker(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add_circle_outline));
  await tester.pumpAndSettle();
  return tester.widget<ZombieSelectionScreen>(
    find.byType(ZombieSelectionScreen),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ZombieRepository().init(),
      PlantRepository().init(),
      ResourceNames.ensureLoaded(),
    ]);
  });

  testWidgets(
    'zombie type lists append a batch without rewriting existing entries',
    (tester) async {
      List<String>? result;
      var changes = 0;
      await tester.pumpWidget(
        _app(
          ZombossMechZombieTypeListEditor(
            fieldLabel: 'Spawn types',
            zombieIds: const ['modern', 'modern'],
            editable: true,
            isList: true,
            onChanged: (ids) {
              result = ids;
              changes++;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final picker = await _openZombiePicker(tester);
      expect(picker.multiSelect, isTrue);
      expect(picker.excludeIds, contains('modern'));
      picker.onMultiZombieSelected!(['conehead', 'buckethead']);
      await tester.pumpAndSettle();
      expect(result, ['modern', 'modern', 'conehead', 'buckethead']);
      expect(changes, 1);
      expect(find.byType(ZombieSelectionScreen), findsNothing);
      await tester.tap(find.text('modern').first);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ZombieSelectionScreen>(find.byType(ZombieSelectionScreen))
            .multiSelect,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'weighted pools retain weights and append a matching default per zombie',
    (tester) async {
      List<String>? ids;
      List<int>? weights;
      await tester.pumpWidget(
        _app(
          ZombossMechWeightedZombieListEditor(
            fieldLabel: 'Pool',
            weightLabel: 'Weight',
            zombieIds: const ['modern'],
            weights: const [37],
            defaultWeight: 12,
            editable: true,
            onChanged: (nextIds, nextWeights) {
              ids = nextIds;
              weights = nextWeights;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final picker = await _openZombiePicker(tester);
      expect(picker.multiSelect, isTrue);
      picker.onMultiZombieSelected!(['conehead', 'buckethead']);
      await tester.pumpAndSettle();
      expect(ids, ['modern', 'conehead', 'buckethead']);
      expect(weights, [37, 12, 12]);
      expect(find.byType(ZombieSelectionScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'robot pools append default entries and keep existing configuration',
    (tester) async {
      final original = ZombossRobotSpawnEntry(
        zombieTypeName: 'modern',
        row: 3,
        level: 4,
        hasPlantfood: true,
        weight: 27,
      );
      List<ZombossRobotSpawnEntry>? result;
      await tester.pumpWidget(
        _app(
          ZombossMechRobotSpawnListEditor(
            fieldLabel: 'Robot spawns',
            entries: [original],
            onChanged: (entries) => result = entries,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final picker = await _openZombiePicker(tester);
      expect(picker.multiSelect, isTrue);
      picker.onMultiZombieSelected!(['conehead', 'buckethead']);
      await tester.pumpAndSettle();
      expect(result!.first, same(original));
      expect(result!.map((e) => e.zombieTypeName), [
        'modern',
        'conehead',
        'buckethead',
      ]);
      for (final entry in result!.skip(1)) {
        expect(entry.row, -1);
        expect(entry.level, 1);
        expect(entry.weight, 100);
        expect(entry.hasPlantfood, isFalse);
      }
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      final replacement = tester.widget<ZombieSelectionScreen>(
        find.byType(ZombieSelectionScreen),
      );
      expect(replacement.multiSelect, isFalse);
      replacement.onZombieSelected('roman_healer');
      await tester.pumpAndSettle();
      expect(result!.single.toJson(), {
        ...original.toJson(),
        'ZombieTypeName': 'roman_healer',
      });
      expect(tester.takeException(), isNull);
    },
  );

  for (final isPlant in [true, false]) {
    testWidgets('vase lists append a complete batch for plants=$isPlant', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final module = PvzObject(
        aliases: ['Vases'],
        objClass: 'VaseBreakerPresetProperties',
        objData: VaseBreakerPresetData(
          vases: [VaseDefinition(collectableTypeName: 'plantfood', count: 2)],
        ).toJson(),
      );
      var changes = 0;
      await tester.pumpWidget(
        _app(
          VaseBreakerTab(
            levelFile: PvzLevelFile(objects: [module]),
            onChanged: () => changes++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final add = find.descendant(
        of: find.ancestor(
          of: find.text('Vase List'),
          matching: find.byType(Row),
        ),
        matching: find.byIcon(Icons.add),
      );
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          ValueKey('editorChoiceOption_${isPlant ? 'plant' : 'zombie'}'),
        ),
      );
      await tester.pumpAndSettle();
      final ids = isPlant
          ? ['peashooter', 'sunflower']
          : ['modern', 'conehead'];
      if (isPlant) {
        final picker = tester.widget<PlantSelectionScreen>(
          find.byType(PlantSelectionScreen),
        );
        expect(picker.isMultiSelect, isTrue);
        picker.onMultiPlantSelected!(ids);
      } else {
        final picker = tester.widget<ZombieSelectionScreen>(
          find.byType(ZombieSelectionScreen),
        );
        expect(picker.multiSelect, isTrue);
        picker.onMultiZombieSelected!(ids);
      }
      await tester.pumpAndSettle();
      final data = VaseBreakerPresetData.fromJson(module.objData);
      expect(data.vases, hasLength(3));
      expect(data.vases.first.collectableTypeName, 'plantfood');
      expect(data.vases.first.count, 2);
      expect(
        data.vases
            .skip(1)
            .map(
              (entry) => isPlant ? entry.plantTypeName : entry.zombieTypeName,
            ),
        ids,
      );
      expect(data.vases.skip(1).map((entry) => entry.count), [1, 1]);
      expect(changes, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
