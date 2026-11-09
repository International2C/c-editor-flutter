import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/zombie_spawn_event_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _jitterRtid = 'RTID(Offsets@CurrentLevel)';
const _patternRtid = 'RTID(Pattern@CurrentLevel)';
const _customZombieRtid = 'RTID(CustomZombie@CurrentLevel)';

void main() {
  test('ground and obstacle spawners round-trip every position field', () {
    final ground = SpawnZombiesFromGroundData.fromJson(<String, dynamic>{
      'JitterOffsets': _jitterRtid,
      'ZombieSpawnPattern': _patternRtid,
      'FixedOffset': 24.5,
      'ColumnStart': 2,
      'ColumnEnd': 7,
      'Zombies': <dynamic>[],
    });
    expect(ground.toJson(), <String, dynamic>{
      'ColumnStart': 2,
      'ColumnEnd': 7,
      'Zombies': <dynamic>[],
      'JitterOffsets': _jitterRtid,
      'ZombieSpawnPattern': _patternRtid,
      'FixedOffset': 24.5,
    });

    final obstacle = SpawnZombiesFromGridItemData.fromJson(<String, dynamic>{
      'ZombieSpawnWaitTime': 3,
      'JitterOffsets': _jitterRtid,
      'ZombieSpawnPattern': _patternRtid,
      'FixedOffset': 16,
      'GridTypes': <String>['RTID(gravestone@GridItemTypes)'],
      'Zombies': <dynamic>[],
    });
    final updated = obstacle.copyWith(zombieSpawnWaitTime: 5);
    expect(updated.jitterOffsets, _jitterRtid);
    expect(updated.zombieSpawnPattern, _patternRtid);
    expect(updated.fixedOffset, 16);
    expect(updated.toJson(), containsPair('ZombieSpawnPattern', _patternRtid));
  });

  testWidgets('editing ground columns preserves ignored position fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final event = PvzObject(
      aliases: const ['GroundWave'],
      objClass: 'SpawnZombiesFromGroundSpawnerProps',
      objData: <String, dynamic>{
        'JitterOffsets': _jitterRtid,
        'ZombieSpawnPattern': _patternRtid,
        'FixedOffset': 12,
        'ColumnStart': 2,
        'ColumnEnd': 7,
        'Zombies': <dynamic>[],
      },
    );
    final offsets = PvzObject(
      aliases: const ['Offsets'],
      objClass: 'ZombieJitterOffsets',
      objData: <String, dynamic>{
        'ZombieSpawningOffsetIncrement': 80,
        'ZombieSpawningRandomJitter': 30,
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ZombieSpawnEventScreen(
          rtid: 'RTID(GroundWave@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [event, offsets]),
          onChanged: () {},
          onBack: () {},
          eventSubtitle: 'Ground spawn',
          isGroundSpawner: true,
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('spawnPositionOffsetSettings')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('spawnPositionOffsetsUnavailable')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('fixedOffsetField')), findsNothing);
    expect(
      find.byKey(const ValueKey('jitterOffsetsPresetPicker')),
      findsNothing,
    );
    final field = find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.initialValue == '7',
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, '8');
    await tester.pumpAndSettle();

    final json = event.objData as Map<String, dynamic>;
    expect(json['JitterOffsets'], _jitterRtid);
    expect(json['ZombieSpawnPattern'], _patternRtid);
    expect(json['FixedOffset'], 12);
    expect(json['ColumnEnd'], 8);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'timeline custom-zombie cleanup preserves position fields in all spawners',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Map<String, dynamic> zombies() => <String, dynamic>{
        'Zombies': <dynamic>[
          <String, dynamic>{'Type': _customZombieRtid},
          <String, dynamic>{'Type': 'RTID(zombie@ZombieTypes)'},
        ],
        'JitterOffsets': _jitterRtid,
        'ZombieSpawnPattern': _patternRtid,
        'FixedOffset': 18,
      };

      final basic = PvzObject(
        aliases: const ['Basic'],
        objClass: 'SpawnZombiesJitteredWaveActionProps',
        objData: zombies(),
      );
      final fish = PvzObject(
        aliases: const ['Fish'],
        objClass: 'SpawnZombiesFishWaveActionProps',
        objData: <String, dynamic>{
          ...zombies(),
          'Fishes': <dynamic>[
            <String, dynamic>{'Type': 'RTID(fish@CreatureTypes)'},
          ],
        },
      );
      final ground = PvzObject(
        aliases: const ['Ground'],
        objClass: 'SpawnZombiesFromGroundSpawnerProps',
        objData: <String, dynamic>{
          ...zombies(),
          'ColumnStart': 2,
          'ColumnEnd': 8,
        },
      );
      final obstacle = PvzObject(
        aliases: const ['Obstacle'],
        objClass: 'SpawnZombiesFromGridItemSpawnerProps',
        objData: <String, dynamic>{
          ...zombies(),
          'ZombieSpawnWaitTime': 4,
          'GridTypes': <String>['RTID(gravestone@GridItemTypes)'],
        },
      );
      final customType = PvzObject(
        aliases: const ['CustomZombie'],
        objClass: 'ZombieType',
        objData: <String, dynamic>{'TypeName': 'zombie'},
      );
      final waveManager = WaveManagerData(waveCount: 0, waves: const []);
      final level = PvzLevelFile(
        objects: [customType, basic, fish, ground, obstacle],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: WaveTimelineTab(
              levelFile: level,
              parsed: ParsedLevelData(
                waveManager: waveManager,
                objectMap: <String, PvzObject>{},
              ),
              onChanged: () {},
              onEditEvent: (_, _) async {},
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CustomZombie'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete entity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(level.objects, isNot(contains(customType)));
      for (final event in [basic, fish, ground, obstacle]) {
        final json = event.objData as Map<String, dynamic>;
        expect(json['JitterOffsets'], _jitterRtid, reason: event.objClass);
        expect(
          json['ZombieSpawnPattern'],
          _patternRtid,
          reason: event.objClass,
        );
        expect(json['FixedOffset'], 18, reason: event.objClass);
        expect((json['Zombies'] as List<dynamic>), hasLength(1));
        expect(
          ((json['Zombies'] as List<dynamic>).single
              as Map<String, dynamic>)['Type'],
          'RTID(zombie@ZombieTypes)',
        );
      }
      expect((fish.objData as Map<String, dynamic>)['Fishes'], isNotEmpty);
      expect(
        (obstacle.objData as Map<String, dynamic>)['GridTypes'],
        isNotEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
