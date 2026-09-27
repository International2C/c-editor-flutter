import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/screens/editor/events/zombie_tent_wave_event_screen.dart';
import 'package:c_editor/screens/editor/modules/glacier_module_screen.dart';
import 'package:c_editor/screens/editor/modules/lawn_mower_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/star_challenge_property_editors.dart';
import 'package:c_editor/screens/editor/others/custom_fish_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

Future<void> _typeContinuously(
  WidgetTester tester,
  Finder field,
  List<String> updates,
) async {
  await tester.ensureVisible(field);
  await tester.showKeyboard(field);
  final editable = find.descendant(
    of: field,
    matching: find.byType(EditableText),
  );
  final original = tester.widget<EditableText>(editable);
  for (final text in updates) {
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
    await tester.pump();
    final current = tester.widget<EditableText>(editable);
    expect(current.focusNode, same(original.focusNode));
    expect(
      current.focusNode.hasFocus,
      isTrue,
      reason: 'Lost focus after "$text"',
    );
    expect(current.controller.text, text);
    expect(current.controller.selection.baseOffset, text.length);
  }
}

PvzObject _tents() => PvzObject(
  aliases: ['Tents'],
  objClass: 'WaveActionZombieTentProps',
  objData: WaveActionZombieTentPropsData(
    zombieTents: [
      ZombieTentData(
        zombieTypesToSpawn: [
          ZombieTentSpawnEntryData(
            zombieTypeName: 'tutorial',
            weight: 10,
            level: 3,
          ),
        ],
      ),
      ZombieTentData(column: 2, hitpoints: 8000, productionInterval: 8),
    ],
  ).toJson(),
);

Widget _tentScreen(PvzObject object) => ZombieTentWaveEventScreen(
  rtid: 'RTID(Tents@CurrentLevel)',
  levelFile: PvzLevelFile(objects: [object]),
  onChanged: () {},
  onBack: () {},
  onRequestZombieSelection: (_) {},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      ZombieRepository().init(),
      GridItemRepository.init(),
    ]);
  });

  testWidgets(
    'tent numbers retain focus and partial decimals after every save',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final object = _tents();
      await tester.pumpWidget(_app(_tentScreen(object)));
      await tester.pumpAndSettle();
      await _typeContinuously(
        tester,
        find.byKey(const ValueKey('tentHitpoints')),
        ['', '1', '12', '1234'],
      );
      await _typeContinuously(
        tester,
        find.byKey(const ValueKey('tentProductionInterval')),
        ['', '1', '1.', '1.2', '1.25'],
      );
      await _typeContinuously(
        tester,
        find.byKey(const ValueKey('tentZombieWeight')),
        ['', '2', '23', '23.', '23.5'],
      );
      final data = WaveActionZombieTentPropsData.fromJson(
        object.objData as Map<String, dynamic>,
      );
      expect(data.zombieTents.first.hitpoints, 1234);
      expect(data.zombieTents.first.productionInterval, 1.25);
      expect(data.zombieTents.first.zombieTypesToSpawn.single.weight, 23.5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tent levels select 0 and 10; switching tiles refreshes numbers',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final object = _tents();
      await tester.pumpWidget(_app(_tentScreen(object)));
      await tester.pumpAndSettle();
      final levelField = find.byKey(const ValueKey('tentZombieLevel'));
      expect(
        tester
            .widget<DropdownButton<int>>(
              find.descendant(
                of: levelField,
                matching: find.byType(DropdownButton<int>),
              ),
            )
            .items!
            .map((item) => item.value),
        List.generate(11, (i) => i),
      );
      for (final level in [10, 0]) {
        await tester.ensureVisible(levelField);
        await tester.tap(levelField);
        await tester.pumpAndSettle();
        await tester.tap(find.text('$level').last);
        await tester.pumpAndSettle();
        final data = WaveActionZombieTentPropsData.fromJson(
          object.objData as Map<String, dynamic>,
        );
        expect(data.zombieTents.first.zombieTypesToSpawn.single.level, level);
      }
      final cells = find.descendant(
        of: find.byType(AspectRatio),
        matching: find.byType(GestureDetector),
      );
      await tester.ensureVisible(cells.at(1));
      await tester.tap(cells.at(1));
      await tester.pumpAndSettle();
      EditableText input(String key) => tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(EditableText),
        ),
      );
      expect(input('tentHitpoints').controller.text, '8000');
      expect(input('tentProductionInterval').controller.text, '8');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('glacier weight keeps focus through parent entry rebuilds', (
    tester,
  ) async {
    final object = PvzObject(
      aliases: ['Glacier'],
      objClass: 'GlacierModuleProperties',
      objData: GlacierModulePropertiesData(
        zombieSpawnData: [
          GlacierColumnSpawnData(
            entries: [
              GlacierSpawnEntryData(typeName: 'mummy', weight: 2, level: 4),
            ],
          ),
        ],
      ).toJson(),
    );
    await tester.pumpWidget(
      _app(
        GlacierModuleScreen(
          rtid: 'RTID(Glacier@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _typeContinuously(
      tester,
      find.byKey(const ValueKey('glacierZombieWeight')),
      ['', '1', '12', '12.', '12.5'],
    );
    expect(
      GlacierModulePropertiesData.fromJson(
        object.objData as Map<String, dynamic>,
      ).zombieSpawnData.first.entries.single.weight,
      12.5,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('challenge numbers retain focus and refresh external changes', (
    tester,
  ) async {
    var value = 10;
    late StateSetter rebuild;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return StarChallengeLabeledIntField(
                label: 'Count',
                value: value,
                onChanged: (next) => setState(() => value = next),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _typeContinuously(tester, find.byType(StarChallengeLabeledIntField), [
      '',
      '1',
      '12',
      '123',
    ]);
    expect(value, 123);
    rebuild(() => value = 42);
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '42',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom fish numeric fields retain focus after saving', (
    tester,
  ) async {
    final props = PvzObject(
      aliases: ['FishProps'],
      objClass: 'CreatureFishProperties',
      objData: <String, dynamic>{'Hitpoints': 100.0},
    );
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['Fish'],
          objClass: 'CreatureType',
          objData: {
            'TypeName': 'testfish',
            'Properties': 'RTID(FishProps@CurrentLevel)',
          },
        ),
        props,
      ],
    );
    await tester.pumpWidget(
      _app(
        CustomFishPropertiesScreen(
          rtid: 'RTID(Fish@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _typeContinuously(tester, find.byKey(const ValueKey('Hitpoints')), [
      '',
      '1',
      '12',
      '123',
    ]);
    expect((props.objData as Map)['Hitpoints'], 123);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Roman Glory mower follows Qin Ghost and is recognized after export',
    (tester) async {
      final object = PvzObject(
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: ['RTID(MoonMowers@LevelModules)'],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [object]);
      await tester.pumpWidget(
        _app(
          LawnMowerPropertiesScreen(
            rtid: 'RTID(MoonMowers@LevelModules)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final roman = find.text('Roman Glory lawn mower');
      await tester.scrollUntilVisible(roman, 400);
      final qinGhost = find.text(
        'Underground Palace Spirit Suppression lawn mower',
      );
      await tester.ensureVisible(qinGhost);
      expect(
        tester.getTopLeft(roman).dy,
        greaterThan(tester.getTopLeft(qinGhost).dy),
      );
      await tester.ensureVisible(roman);
      await tester.tap(roman);
      await tester.pumpAndSettle();
      final exported = PvzLevelFile.fromJson(level.toJson());
      final def = LevelDefinitionData.fromJson(
        exported.objects.single.objData as Map<String, dynamic>,
      );
      expect(def.modules, ['RTID(RomanMowers2@LevelModules)']);
      expect(findLawnMowerAlias(def), 'RomanMowers2');
      expect(tester.takeException(), isNull);
    },
  );
}
