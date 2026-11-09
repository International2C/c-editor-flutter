import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/grid_item_spawn_event_screen.dart';
import 'package:c_editor/screens/editor/events/zombie_tent_wave_event_screen.dart';
import 'package:c_editor/screens/editor/modules/glacier_module_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_flat_lane_drag_drop_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void _useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
      GridItemRepository.init(),
      ResourceNames.ensureLoaded(),
    ]);
  });

  testWidgets(
    'grid-item spawns batch-add zombies but replace one type at a time',
    (tester) async {
      _useLargeViewport(tester);
      final original = ZombieSpawnData(
        type: 'RTID(modern@ZombieTypes)',
        level: 4,
        direction: 'left',
        titles: ['ZTSpeed1'],
      );
      final module = PvzObject(
        aliases: ['GridSpawns'],
        objClass: 'SpawnZombiesFromGridItemSpawnerProps',
        objData: SpawnZombiesFromGridItemData(zombies: [original]).toJson(),
      );
      var singles = 0;
      var batches = 0;
      await tester.pumpWidget(
        _app(
          GridItemSpawnEventScreen(
            rtid: 'RTID(GridSpawns@CurrentLevel)',
            levelFile: PvzLevelFile(objects: [module]),
            onChanged: () {},
            onBack: () {},
            onRequestGridItemSelection: (_) {},
            onRequestZombieSelection: (selected) {
              singles++;
              selected('roman_healer');
            },
            onRequestZombieMultiSelection: (selected) {
              batches++;
              selected('conehead');
              selected('buckethead');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      tester
          .widget<ZombieFlatLaneDragDropEditor>(
            find.byType(ZombieFlatLaneDragDropEditor),
          )
          .onAdd();
      await tester.pumpAndSettle();
      var data = SpawnZombiesFromGridItemData.fromJson(module.objData);
      expect(batches, 1);
      expect(singles, 0);
      expect(data.zombies, hasLength(3));
      expect(data.zombies.first.toJson(), original.toJson());
      expect(data.zombies.skip(1).map((e) => e.level), [1, 1]);
      tester
          .widget<ZombieFlatLaneDragDropEditor>(
            find.byType(ZombieFlatLaneDragDropEditor),
          )
          .onTap(0);
      await tester.pumpAndSettle();
      tester
          .widget<ZombieEditSheetIdentityTile>(
            find.byType(ZombieEditSheetIdentityTile),
          )
          .onChange();
      await tester.pumpAndSettle();
      data = SpawnZombiesFromGridItemData.fromJson(module.objData);
      expect(singles, 1);
      expect(batches, 1);
      expect(data.zombies, hasLength(3));
      expect(data.zombies.first.type, contains('roman_healer'));
      expect(data.zombies.first.level, 4);
      expect(data.zombies.first.direction, 'left');
      expect(data.zombies.first.titles, ['ZTSpeed1']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tent pools batch-add with defaults and retain replacement metadata',
    (tester) async {
      _useLargeViewport(tester);
      final original = ZombieTentSpawnEntryData(
        zombieTypeName: 'modern',
        weight: 27,
        level: 4,
      );
      final module = PvzObject(
        aliases: ['Tents'],
        objClass: 'WaveActionZombieTentProps',
        objData: WaveActionZombieTentPropsData(
          zombieTents: [
            ZombieTentData(hitpoints: 3050, zombieTypesToSpawn: [original]),
          ],
        ).toJson(),
      );
      var singles = 0;
      var batches = 0;
      await tester.pumpWidget(
        _app(
          ZombieTentWaveEventScreen(
            rtid: 'RTID(Tents@CurrentLevel)',
            levelFile: PvzLevelFile(objects: [module]),
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (selected) {
              singles++;
              selected('roman_healer');
            },
            onRequestZombieMultiSelection: (selected) {
              batches++;
              selected('conehead');
              selected('buckethead');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final strings = lookupAppLocalizations(const Locale('en'));
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, strings.zombieTentAddZombie),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      var tent = WaveActionZombieTentPropsData.fromJson(
        module.objData,
      ).zombieTents.single;
      expect(batches, 1);
      expect(singles, 0);
      expect(tent.zombieTypesToSpawn, hasLength(3));
      expect(tent.zombieTypesToSpawn.first.toJson(), original.toJson());
      expect(tent.zombieTypesToSpawn.skip(1).map((e) => e.level), [0, 0]);
      expect(tent.zombieTypesToSpawn.skip(1).map((e) => e.weight), [10, 10]);
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, strings.switchZombie).first,
          )
          .onPressed!();
      await tester.pumpAndSettle();
      tent = WaveActionZombieTentPropsData.fromJson(
        module.objData,
      ).zombieTents.single;
      expect(singles, 1);
      expect(batches, 1);
      expect(tent.zombieTypesToSpawn, hasLength(3));
      expect(tent.hitpoints, 3050);
      expect(tent.zombieTypesToSpawn.first.toJson(), {
        ...original.toJson(),
        'ZombieTypeName': 'roman_healer',
      });
      expect(tester.takeException(), isNull);
    },
  );

  for (final useMulti in [false, true]) {
    testWidgets(
      'glacier add picker supports multi=$useMulti without changing replacement mode',
      (tester) async {
        _useLargeViewport(tester);
        final original = GlacierSpawnEntryData(
          typeName: 'modern',
          weight: 27,
          level: 4,
        );
        final module = PvzObject(
          aliases: ['Glacier'],
          objClass: 'GlacierModuleProperties',
          objData: GlacierModulePropertiesData(
            zombieSpawnData: [
              GlacierColumnSpawnData(entries: [original]),
            ],
          ).toJson(),
        );
        var singles = 0;
        var batches = 0;
        await tester.pumpWidget(
          _app(
            GlacierModuleScreen(
              rtid: 'RTID(Glacier@CurrentLevel)',
              levelFile: PvzLevelFile(objects: [module]),
              onChanged: () {},
              onBack: () {},
              onRequestZombieSelection: (selected) {
                singles++;
                selected('roman_healer');
              },
              onRequestZombieMultiSelection: useMulti
                  ? (selected) {
                      batches++;
                      selected('conehead');
                      selected('buckethead');
                    }
                  : null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final strings = lookupAppLocalizations(const Locale('en'));
        tester
            .widget<OutlinedButton>(
              find
                  .widgetWithText(OutlinedButton, strings.glacierModuleAddEntry)
                  .first,
            )
            .onPressed!();
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('editorChoiceOption_zombie')),
        );
        await tester.pumpAndSettle();
        var column = GlacierModulePropertiesData.fromJson(
          module.objData,
        ).zombieSpawnData.first;
        expect(batches, useMulti ? 1 : 0);
        expect(singles, useMulti ? 0 : 1);
        expect(column.entries, hasLength(useMulti ? 3 : 2));
        expect(column.entries.first.toJson(), original.toJson());
        expect(
          column.entries.skip(1).every((e) => e.weight == 1 && e.level == 0),
          isTrue,
        );
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, strings.switchZombie).first,
            )
            .onPressed!();
        await tester.pumpAndSettle();
        column = GlacierModulePropertiesData.fromJson(
          module.objData,
        ).zombieSpawnData.first;
        expect(singles, useMulti ? 1 : 2);
        expect(batches, useMulti ? 1 : 0);
        expect(column.entries.first.toJson(), {
          ...original.toJson(),
          'TypeName': 'roman_healer',
        });
        expect(tester.takeException(), isNull);
      },
    );
  }
}
