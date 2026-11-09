import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/zombie_fish_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/zombie_spawn_event_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/jitter_offsets_binding_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final underwater in [false, true]) {
    for (final initial in <String?>[null, 'right', 'left', 'random']) {
      testWidgets(
        '${underwater ? 'underwater' : 'ordinary'} entry-side controls preserve and switch $initial',
        (tester) async {
          final fishes = [
            {
              'Type': 'RTID(fish@CreatureTypes)',
              'Position': {'mX': 5, 'mY': 2},
            },
          ];
          final event = PvzObject(
            aliases: ['SideTest'],
            objClass: underwater
                ? 'SpawnZombiesFishWaveActionProps'
                : 'SpawnZombiesJitteredWaveActionProps',
            objData: {
              'Zombies': [
                {
                  'Type': 'RTID(zombie@ZombieTypes)',
                  'Level': 1,
                  'Row': 1,
                  if (initial != null) 'Direction': initial,
                },
              ],
              if (underwater) 'Fishes': fishes,
            },
          );
          final level = PvzLevelFile(objects: [event]);
          await _pumpEditor(
            tester,
            underwater
                ? ZombieFishWaveEventScreen(
                    rtid: 'RTID(SideTest@CurrentLevel)',
                    levelFile: level,
                    onChanged: () {},
                    onBack: () {},
                    onRequestZombieSelection: (_) {},
                  )
                : ZombieSpawnEventScreen(
                    rtid: 'RTID(SideTest@CurrentLevel)',
                    levelFile: level,
                    onChanged: () {},
                    onBack: () {},
                    eventSubtitle: 'Basic Spawner',
                    isGroundSpawner: false,
                    onRequestZombieSelection: (_) {},
                  ),
          );
          final card = find.byType(ZombieIconCard);
          await tester.ensureVisible(card);
          await tester.tap(card);
          await tester.pumpAndSettle();
          final random = find.byKey(const ValueKey('zombieRandomEntrySide'));
          final left = find.byKey(const ValueKey('zombieLeftEntrySide'));
          String? savedDirection() =>
              ((event.objData as Map)['Zombies'] as List).single['Direction']
                  as String?;
          expect(
            tester.widget<SwitchListTile>(random).value,
            initial == 'random',
          );
          expect(tester.widget<SwitchListTile>(left).value, initial == 'left');
          expect(savedDirection(), initial);
          if (initial == 'random') {
            expect(tester.widget<SwitchListTile>(left).onChanged, isNull);
            await tester.tap(random);
            await tester.pumpAndSettle();
            expect(savedDirection(), isNull);
          } else {
            await tester.tap(random);
            await tester.pumpAndSettle();
            expect(savedDirection(), 'random');
            expect(tester.widget<SwitchListTile>(left).onChanged, isNull);
            final row = find.byType(DropdownButtonFormField<int>);
            await tester.tap(row);
            await tester.pumpAndSettle();
            await tester.tap(find.text('第2行').last);
            await tester.pumpAndSettle();
            expect(savedDirection(), 'random');
            await tester.tap(random);
            await tester.pumpAndSettle();
            expect(savedDirection(), initial);
          }
          if (!tester.widget<SwitchListTile>(left).value) {
            await tester.tap(left);
            await tester.pumpAndSettle();
          }
          expect(savedDirection(), 'left');
          await tester.tap(random);
          await tester.pumpAndSettle();
          expect(savedDirection(), 'random');
          await tester.tap(random);
          await tester.pumpAndSettle();
          expect(savedDirection(), 'left');
          await tester.tap(random);
          await tester.pumpAndSettle();
          Navigator.of(tester.element(left)).pop();
          await tester.pumpAndSettle();
          await tester.ensureVisible(card);
          await tester.tap(card);
          await tester.pumpAndSettle();
          expect(tester.widget<SwitchListTile>(random).value, isTrue);
          expect(savedDirection(), 'random');
          if (underwater) expect((event.objData as Map)['Fishes'], fishes);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  test(
    'ordinary and underwater instructions share three entry-side values',
    () {
      expect(ZombieSpawnData.entersFromLeft('left'), isTrue);
      expect(ZombieSpawnData.entersFromLeft('right'), isFalse);
      expect(ZombieSpawnData.entersFromLeft(null), isFalse);
      expect(ZombieSpawnData.entersFromLeft('random'), isFalse);
      expect(ZombieSpawnData.directionForEntrySide(true), 'left');
      expect(ZombieSpawnData.directionForEntrySide(false), isNull);
      expect(
        ZombieSpawnData.directionForEntrySide(false, random: true),
        'random',
      );
    },
  );

  test('no ground track label contains no JSON null notation', () {
    for (final locale in ['zh', 'en', 'ru']) {
      final l10n = lookupAppLocalizations(Locale(locale));
      expect(l10n.groundTrackNone, isNot(contains('null')));
    }
    expect(lookupAppLocalizations(const Locale('zh')).groundTrackNone, '无');
  });

  testWidgets(
    'FixedOffset editor defaults to zero and rejects non-finite input',
    (tester) async {
      num? changed;
      await _pumpEditor(
        tester,
        Scaffold(
          body: FixedOffsetAdvancedSettingsCard(
            value: null,
            onChanged: (value) => changed = value,
          ),
        ),
      );

      final field = find.byKey(const ValueKey('fixedOffsetField'));
      expect(tester.widget<TextFormField>(field).initialValue, '0');

      await tester.enterText(field, 'NaN');
      await tester.pump();
      expect(changed, isNull);
      final l10n = AppLocalizations.of(tester.element(field))!;
      expect(find.text(l10n.jitterOffsetsFixedOffsetInvalid), findsOneWidget);

      await tester.enterText(field, 'Infinity');
      await tester.pump();
      expect(changed, isNull);

      for (final value in <double>[8.5, -8.5, 0.001, -0.0, 1e100]) {
        await tester.enterText(field, value.toString());
        await tester.pump();
        expect(changed, value);
        expect(changed!.isNegative, value.isNegative);
      }
    },
  );

  testWidgets('FixedOffset editor retains a large finite initial value', (
    tester,
  ) async {
    await _pumpEditor(
      tester,
      Scaffold(
        body: FixedOffsetAdvancedSettingsCard(value: 1e100, onChanged: (_) {}),
      ),
    );

    final field = tester.widget<TextFormField>(
      find.byKey(const ValueKey('fixedOffsetField')),
    );
    expect(num.parse(field.initialValue!), 1e100);
    expect(tester.takeException(), isNull);
  });

  test('basic and underwater models preserve all position controls', () {
    const source = <String, dynamic>{
      'JitterOffsets': 'RTID(Offsets@CurrentLevel)',
      'ZombieSpawnPattern': 'ZombieSpawnerPatternStaggered',
      'Zombies': <dynamic>[],
    };

    for (final value in <double>[8.5, -8.5, 0.001, -0.0]) {
      final input = <String, dynamic>{...source, 'FixedOffset': value};
      final basic = WaveActionData.fromJson(input);
      final underwater = SpawnZombiesFishWaveActionPropsData.fromJson(input);

      for (final restored in <Map<String, dynamic>>[
        basic.toJson(),
        underwater.toJson(),
      ]) {
        expect(restored['JitterOffsets'], 'RTID(Offsets@CurrentLevel)');
        expect(restored['ZombieSpawnPattern'], 'ZombieSpawnerPatternStaggered');
        expect(restored['FixedOffset'], value);
        expect((restored['FixedOffset'] as num).isNegative, value.isNegative);
      }
    }
  });

  testWidgets(
    'basic spawner exposes event-local FixedOffset and restores its preset at zero',
    (tester) async {
      final event = _event(
        alias: 'Wave1',
        objClass: 'SpawnZombiesJitteredWaveActionProps',
      );
      final level = PvzLevelFile(objects: [event, _offsetsPreset()]);

      await _pumpEditor(
        tester,
        ZombieSpawnEventScreen(
          rtid: 'RTID(Wave1@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          eventSubtitle: 'Basic Spawner',
          isGroundSpawner: false,
          onRequestZombieSelection: (_) {},
        ),
      );

      await _expectOverrideThenRestore(tester, event);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'underwater spawner exposes event-local FixedOffset and restores its preset at zero',
    (tester) async {
      final event = _event(
        alias: 'FishWave1',
        objClass: 'SpawnZombiesFishWaveActionProps',
      );
      final level = PvzLevelFile(objects: [event, _offsetsPreset()]);

      await _pumpEditor(
        tester,
        ZombieFishWaveEventScreen(
          rtid: 'RTID(FishWave1@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      );

      await _expectOverrideThenRestore(tester, event);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ZombieFishWaveEventScreen)),
      )!;
      expect(
        find.text(l10n.jitterOffsetsUnderwaterScopeDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'underwater direction switch maps entry side and unrelated edits preserve it',
    (tester) async {
      final event = PvzObject(
        aliases: ['FishDirection'],
        objClass: 'SpawnZombiesFishWaveActionProps',
        objData: <String, dynamic>{
          'Zombies': <dynamic>[
            <String, dynamic>{
              'Type': 'RTID(zombie@ZombieTypes)',
              'Level': 1,
              'Row': 1,
              'Direction': 'left',
              'Titles': <String>['ZTSpeed1'],
            },
          ],
          'JitterOffsets': 'RTID(Offsets@CurrentLevel)',
          'ZombieSpawnPattern': 'ZombieSpawnerPatternStaggered',
          'FixedOffset': 8.5,
          'Fishes': <dynamic>[
            <String, dynamic>{
              'Type': 'RTID(fish@CreatureTypes)',
              'Position': <String, dynamic>{'mX': 5, 'mY': 2},
            },
          ],
        },
      );

      await _pumpEditor(
        tester,
        ZombieFishWaveEventScreen(
          rtid: 'RTID(FishDirection@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [event]),
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      );

      final zombieCard = find.byType(ZombieIconCard);
      await tester.ensureVisible(zombieCard);
      await tester.tap(zombieCard);
      await tester.pumpAndSettle();

      final directionTile = find.widgetWithText(SwitchListTile, '从场地左侧出现');
      expect(tester.widget<SwitchListTile>(directionTile).value, isTrue);

      final rowField = find.byType(DropdownButtonFormField<int>);
      await tester.tap(rowField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('第2行').last);
      await tester.pumpAndSettle();
      _expectFishZombieFields(event, direction: 'left', row: 2);

      await tester.tap(directionTile);
      await tester.pumpAndSettle();
      _expectFishZombieFields(event, direction: null, row: 2);

      await tester.tap(directionTile);
      await tester.pumpAndSettle();
      _expectFishZombieFields(event, direction: 'left', row: 2);

      Navigator.of(tester.element(directionTile)).pop();
      await tester.pumpAndSettle();
      final applyButton = find.widgetWithText(FilledButton, '一键应用');
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '一键应用').last);
      await tester.pumpAndSettle();
      _expectFishZombieFields(event, direction: 'left', row: 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'basic spawner keeps editing the same zombie after a row reorder',
    (tester) async {
      final event = PvzObject(
        aliases: ['BasicDirection'],
        objClass: 'SpawnZombiesJitteredWaveActionProps',
        objData: <String, dynamic>{
          'Zombies': <dynamic>[
            <String, dynamic>{
              'Type': 'RTID(zombie@ZombieTypes)',
              'Level': 1,
              'Row': 1,
              'Direction': 'left',
              'Titles': <String>['ZTSpeed1'],
            },
            <String, dynamic>{
              'Type': 'RTID(conehead@ZombieTypes)',
              'Level': 2,
              'Row': 2,
              'Direction': 'right',
            },
          ],
        },
      );

      await _pumpEditor(
        tester,
        ZombieSpawnEventScreen(
          rtid: 'RTID(BasicDirection@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [event]),
          onChanged: () {},
          onBack: () {},
          eventSubtitle: 'Basic Spawner',
          isGroundSpawner: false,
          onRequestZombieSelection: (_) {},
        ),
      );

      final zombieCards = find.byType(ZombieIconCard);
      await tester.ensureVisible(zombieCards.first);
      await tester.tap(zombieCards.first);
      await tester.pumpAndSettle();

      final rowField = find.byType(DropdownButtonFormField<int>);
      await tester.tap(rowField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('第3行').last);
      await tester.pumpAndSettle();

      final directionTile = find.widgetWithText(SwitchListTile, '从场地左侧出现');
      expect(tester.widget<SwitchListTile>(directionTile).value, isTrue);
      await tester.tap(directionTile);
      await tester.pumpAndSettle();

      final zombies =
          ((event.objData as Map<String, dynamic>)['Zombies'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      final edited = zombies.singleWhere(
        (entry) => entry['Type'] == 'RTID(zombie@ZombieTypes)',
      );
      final untouched = zombies.singleWhere(
        (entry) => entry['Type'] == 'RTID(conehead@ZombieTypes)',
      );
      expect(edited['Row'], 3);
      expect(edited, isNot(contains('Direction')));
      expect(edited['Titles'], <String>['ZTSpeed1']);
      expect(untouched['Row'], 2);
      expect(untouched['Direction'], 'right');
      await tester.tap(directionTile);
      await tester.pumpAndSettle();
      final saved = ((event.objData as Map)['Zombies'] as List).cast<Map>();
      final savedEdited = saved.singleWhere(
        (entry) => entry['Type'] == 'RTID(zombie@ZombieTypes)',
      );
      expect(savedEdited['Direction'], 'left');
      expect(savedEdited['Row'], 3);
      expect(savedEdited['Titles'], <String>['ZTSpeed1']);
      expect(tester.takeException(), isNull);
    },
  );
}

void _expectFishZombieFields(
  PvzObject event, {
  required String? direction,
  required int row,
}) {
  final data = event.objData as Map<String, dynamic>;
  final zombie =
      (data['Zombies'] as List<dynamic>).single as Map<String, dynamic>;
  expect(zombie['Row'], row);
  if (direction == null) {
    expect(zombie, isNot(contains('Direction')));
  } else {
    expect(zombie['Direction'], direction);
  }
  expect(zombie['Titles'], <String>['ZTSpeed1']);
  expect(data['JitterOffsets'], 'RTID(Offsets@CurrentLevel)');
  expect(data['ZombieSpawnPattern'], 'ZombieSpawnerPatternStaggered');
  expect(data['FixedOffset'], 8.5);
  expect(data['Fishes'], <dynamic>[
    <String, dynamic>{
      'Type': 'RTID(fish@CreatureTypes)',
      'Position': <String, dynamic>{'mX': 5, 'mY': 2},
    },
  ]);
}

PvzObject _event({required String alias, required String objClass}) {
  return PvzObject(
    aliases: [alias],
    objClass: objClass,
    objData: <String, dynamic>{
      'JitterOffsets': 'RTID(Offsets@CurrentLevel)',
      'ZombieSpawnPattern': 'ZombieSpawnerPatternStaggered',
      'FixedOffset': 32,
      'Zombies': <dynamic>[],
    },
  );
}

PvzObject _offsetsPreset() {
  return PvzObject(
    aliases: ['Offsets'],
    objClass: 'ZombieJitterOffsets',
    objData: <String, dynamic>{
      'ZombieSpawningOffsetIncrement': 80,
      'ZombieSpawningRandomJitter': 30,
    },
  );
}

Future<void> _pumpEditor(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expectOverrideThenRestore(
  WidgetTester tester,
  PvzObject event,
) async {
  final section = find.byKey(const ValueKey('spawnPositionOffsetSettings'));
  await tester.ensureVisible(section);
  await tester.tap(section);
  await tester.pumpAndSettle();

  final picker = find.byKey(const ValueKey('jitterOffsetsPresetPicker'));
  await tester.ensureVisible(picker);
  expect(tester.widget<InkWell>(picker).onTap, isNull);
  expect(find.text('Offsets'), findsOneWidget);
  final l10n = AppLocalizations.of(tester.element(section))!;
  expect(find.text(l10n.jitterOffsetsFixedOffsetLabel), findsOneWidget);

  final field = find.byKey(const ValueKey('fixedOffsetField'));
  await tester.ensureVisible(field);
  for (final value in <double>[8.5, -8.5, 0.001]) {
    await tester.enterText(field, value.toString());
    await tester.pumpAndSettle();

    final json = event.objData as Map<String, dynamic>;
    expect(json['FixedOffset'], value);
    expect(json['JitterOffsets'], 'RTID(Offsets@CurrentLevel)');
    expect(json['ZombieSpawnPattern'], 'ZombieSpawnerPatternStaggered');
    expect(tester.widget<InkWell>(picker).onTap, isNull);
    expect(
      find.text(l10n.jitterOffsetsFixedOffsetOverrideWarning),
      findsOneWidget,
    );
  }

  await tester.enterText(field, '-0.0');
  await tester.pumpAndSettle();

  final json = event.objData as Map<String, dynamic>;
  expect(json['JitterOffsets'], 'RTID(Offsets@CurrentLevel)');
  expect(json['ZombieSpawnPattern'], 'ZombieSpawnerPatternStaggered');
  expect(json, isNot(contains('FixedOffset')));

  await tester.ensureVisible(picker);
  await tester.tap(picker);
  await tester.pumpAndSettle();
  expect(find.text('Offsets'), findsWidgets);
  await tester.tap(find.text('Offsets').last);
  await tester.pumpAndSettle();
}
