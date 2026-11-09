import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/halloween_content.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/halloween_placement_screen.dart';
import 'package:c_editor/screens/editor_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ResourceNames.ensureLoaded);
  test(
    'scarecrow and cauldron labels use separate namespaces and established terminology',
    () async {
      for (final locale in ['zh', 'en', 'ru']) {
        final raw = await File('assets/l10n/app_$locale.arb').readAsString();
        final copy = jsonDecode(raw) as Map;
        expect(
          copy.keys.where((key) => key.toString().startsWith('halloween')),
          isEmpty,
        );
        expect(
          copy['pumpkinScarecrowHitpoints'],
          isNot(copy['wizardCauldronHitpoints']),
        );
        expect(copy['wizardCauldronHelpOverview'], contains('\n'));
        for (final line
            in raw
                .split('\n')
                .where(
                  (line) => RegExp(
                    r'^\s*"(?:pumpkinScarecrow|wizardCauldron)',
                  ).hasMatch(line),
                )) {
          expect(line.startsWith('  "'), isTrue);
        }
        if (locale == 'zh') {
          expect(copy['pumpkinScarecrowCrowLevel'], '乌鸦阶级 (Level)');
          expect(
            copy['pumpkinScarecrowHelpOverview'],
            contains('乌鸦阶级（0阶表示随地图阶级，庭院模式下即为1阶）'),
          );
          expect(copy['wizardCauldronBoilingDuration'], contains('单位：秒'));
          expect(
            copy['wizardCauldronHelpUsage'],
            endsWith(
              '放置坩埚后，可自定义该坩埚的生命值、投入能量豆后沸腾的时间、爆炸对植物和僵尸的伤害、毒液遗留时间和毒液每秒的伤害。',
            ),
          );
          expect(copy['wizardCauldronHelpOverview'], isNot(contains('自定义')));
          expect(copy['rocketLandingHelpLogic'], contains('生成火箭'));
          expect(copy['pumpkinScarecrowHelpLogic'], contains('生成稻草人'));
        }
        if (locale == 'en') {
          expect(
            copy['moduleDesc_InitialGridItemWizardCrucibleProps'],
            contains('Fairy Forest'),
          );
          expect(copy['pumpkinScarecrowCrowLevel'], 'Crow level (Level)');
        }
      }
    },
  );
  test(
    'new PvP names use the existing base names and mode suffix in all locales',
    () async {
      for (final locale in ['zh', 'en', 'ru']) {
        final raw = await rootBundle.loadString(
          'assets/l10n/resource_$locale.json',
        );
        final names = jsonDecode(raw) as Map;
        final suffix = {
          'zh': ' (双人对决)',
          'en': ' (Two-Player Mode)',
          'ru': ' (PvP)',
        }[locale]!;
        for (final id in [
          'future_imp',
          'eighties_mc',
          'teleport_left',
          'gladiator_zombie',
          'nutcracker',
        ]) {
          expect(names['zombie_new_pvp_$id'], '${names['zombie_$id']}$suffix');
        }
        if (locale == 'en')
          expect(names['lawnMower_RomanMowers'], startsWith('Spacetime Rift'));
        final lines = raw.split('\n');
        for (final key in [
          'plant_mangofier',
          'zombie_werewolf',
          'griditem_living_armor_left',
          'musicSuffix_Halloween',
        ]) {
          final i = lines.indexWhere((line) => line.contains('"$key":'));
          expect(i, greaterThan(20));
          String keyAt(int index) => RegExp(
            r'"([^"]+)"',
          ).firstMatch(lines[index])!.group(1)!.toLowerCase();
          expect(keyAt(i - 1).compareTo(key.toLowerCase()), lessThan(0));
          expect(keyAt(i + 1).compareTo(key.toLowerCase()), greaterThan(0));
        }
      }
    },
  );
  test('new event and module defaults preserve game schema', () {
    expect(EditorScreen, isNotNull);
    expect(
      EventRegistry.getByObjClass(scarecrowClass)!.defaultAlias,
      'PumpkinScarecrowEvent',
    );
    expect(
      ModuleRegistry
          .registry[cauldronClass]!
          .initialData!['InitialGridItemWizardCrucibles'],
      isEmpty,
    );
    expect(HalloweenContentData(cauldron: false).toJson()['Hitpoints'], 4000);
    expect(newCauldron(0, 0)['GridX'], 0);
  });
  test(
    'switching backgrounds uses each source schema split-texture defaults',
    () async {
      await StageCatalogRepository.init();
      for (final alias in ['MoonStage', 'EgyptStage', 'KongfuStage']) {
        final candidates = StageCatalogRepository.stageBaseOptions().where(
          (s) => s.alias.toLowerCase() == alias.toLowerCase(),
        );
        if (candidates.isEmpty) continue;
        final stage = candidates.first;
        final section = StageCatalogRepository.sections.firstWhere(
          (s) => s.objclass == stage.objclass,
        );
        final effective = {
          for (final field in section.fields) field.name: field.defaultValue,
          ...stage.objdata,
        };
        final textures = StageCatalogRepository.backgroundTextures(
          effective['BackgroundResourceGroup'] as String,
          effective['BackgroundImagePrefix'] as String? ?? '',
        );
        expect(
          textures.keys,
          containsAll([
            'BackgroundImageLeft',
            'BackgroundImageMiddle',
            'BackgroundImageRight',
          ]),
        );
        expect(
          textures['BackgroundImageMiddle'],
          alias == 'MoonStage' ? 'MOON' : 'TEXTURE',
        );
      }
      final halloween = StageCatalogRepository.stageBaseOptions().firstWhere(
        (s) => s.alias == 'HalloweenStage',
      );
      expect(halloween.objdata['MusicSuffix'], 'Halloween');
    },
  );
  test('resource catalogs contain exact reference type names', () async {
    final zombies =
        jsonDecode(await rootBundle.loadString('assets/resources/Zombies.json'))
            as List;
    for (final id in ['zombie_werewolf', 'zombie_werewolf_wolf']) {
      expect(zombies.where((e) => e['id'] == id), hasLength(1));
    }
    final items =
        jsonDecode(
              await rootBundle.loadString('assets/resources/GridItems.json'),
            )
            as List;
    final names = items.map((e) => e['typeName']).toList();
    expect(
      names.indexOf('pumpkin_scarecrow'),
      names.indexOf('roman_eagle_flag') + 1,
    );
    expect(
      names.indexOf('living_armor_left'),
      names.indexOf('zombie_changer') + 1,
    );
    for (final locale in ['zh', 'en', 'ru']) {
      final resources =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/l10n/resource_$locale.json',
                ),
              )
              as Map;
      expect(resources['musicSuffix_Halloween'], isNotEmpty);
      expect(resources['plant_mangofier'], isNotEmpty);
    }
  });
  for (final cauldron in [false, true]) {
    testWidgets(
      'placement grid writes zero-based coordinates and retains unknown fields $cauldron',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1500);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final object = PvzObject(
          aliases: ['New'],
          objClass: cauldron ? cauldronClass : scarecrowClass,
          objData: {
            ...HalloweenContentData(cauldron: cauldron).toJson(),
            'FutureField': 42,
          },
        );
        final level = PvzLevelFile(objects: [object]);
        var changes = 0;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HalloweenPlacementScreen(
              rtid: 'RTID(New@CurrentLevel)',
              levelFile: level,
              cauldron: cauldron,
              onChanged: () => changes++,
              onBack: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(cauldron ? cauldronClass : scarecrowClass),
          findsOneWidget,
        );
        if (cauldron) {
          expect(find.byType(FilterChip), findsNothing);
          expect(find.text('选中位置'), findsOneWidget);
          expect(find.text('R1 : C1'), findsOneWidget);
        }
        final cell = find.byKey(const ValueKey('placementCell_0_0'));
        await tester.tap(cell);
        await tester.pumpAndSettle();
        final data = object.objData as Map;
        final position =
            (data[cauldron
                        ? 'InitialGridItemWizardCrucibles'
                        : 'SpawnPositionsPool']
                    as List)
                .single;
        expect(position[cauldron ? 'GridX' : 'mX'], 0);
        expect(position[cauldron ? 'GridY' : 'mY'], 0);
        expect(data['FutureField'], 42);
        expect(find.byType(GridItemIcon), findsWidgets);
        if (!cauldron) {
          expect(
            find.descendant(of: cell, matching: find.byType(GridItemIcon)),
            findsNothing,
          );
          final check = tester.widget<Icon>(
            find.descendant(of: cell, matching: find.byIcon(Icons.check)),
          );
          expect(check.color, Colors.white);
          final background =
              tester
                      .widget<Container>(
                        find
                            .descendant(
                              of: cell,
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .decoration
                  as BoxDecoration;
          expect(background.color, const Color(0xFF2E7D32));
          await tester.tap(cell);
          await tester.pumpAndSettle();
          expect(data['SpawnPositionsPool'], isEmpty);
          await tester.tap(cell);
          await tester.pumpAndSettle();
          final crowLevel = find.byKey(
            const ValueKey('pumpkinScarecrowCrowLevel'),
          );
          expect(
            tester
                .widget<DropdownButton<int>>(
                  find.descendant(
                    of: crowLevel,
                    matching: find.byType(DropdownButton<int>),
                  ),
                )
                .items!
                .map((item) => item.value),
            List.generate(11, (value) => value),
          );
          await tester.ensureVisible(crowLevel);
          await tester.tap(crowLevel);
          await tester.pumpAndSettle();
          await tester.tap(find.text('10').last);
          await tester.pumpAndSettle();
          expect(data['Level'], 10);
          expect(data['Level'], isA<int>());
          await tester.tap(crowLevel);
          await tester.pumpAndSettle();
          await tester.tap(find.text('0').last);
          await tester.pumpAndSettle();
          expect(data['Level'], 0);
          expect(data['Hitpoints'], 4000);
          expect(data['FutureField'], 42);
        }
        if (cauldron) {
          await tester.tap(find.byKey(const ValueKey('placementCell_1_0')));
          await tester.pumpAndSettle();
          expect(
            (data['InitialGridItemWizardCrucibles'] as List),
            hasLength(2),
          );
          expect(position['GridX'], 0);
          await tester.tap(cell);
          await tester.pumpAndSettle();
          expect(
            (data['InitialGridItemWizardCrucibles'] as List),
            hasLength(2),
          );
          final preview = previewModuleInfoBuild(
            levelFile: level,
            objClass: cauldronClass,
            t: (key, fallback, [args]) => fallback,
          );
          expect(preview.sections.single.items.last.gridX, 1);
          await tester.tap(find.byKey(const ValueKey('placementCell_2_0')));
          await tester.pumpAndSettle();
          final cauldrons = data['InitialGridItemWizardCrucibles'] as List;
          expect(cauldrons, hasLength(3));
          expect(cauldrons.last['GridX'], 2);
          expect(cauldrons.last['GridY'], 0);
          cauldrons.last['CrucibleHitpoints'] = 1234;
          expect(find.text('R1 : C3'), findsOneWidget);
          final changesBeforeSelection = changes;
          await tester.tap(cell);
          await tester.pumpAndSettle();
          expect(find.text('R1 : C1'), findsOneWidget);
          expect(changes, changesBeforeSelection);
          await tester.tap(find.byKey(const ValueKey('placementCell_2_0')));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TextFormField>(
                  find.byKey(
                    ValueKey(
                      '${identityHashCode(cauldrons.last)}_CrucibleHitpoints',
                    ),
                  ),
                )
                .initialValue,
            '1234',
          );
          await tester.tap(
            find.byKey(const ValueKey('placementCell_1_0')),
            buttons: kSecondaryMouseButton,
          );
          await tester.pumpAndSettle();
          expect(cauldrons, hasLength(3));
          expect(cauldrons.last['CrucibleHitpoints'], 1234);
          expect(find.text('R1 : C3'), findsOneWidget);
          await tester.longPress(cell);
          await tester.pumpAndSettle();
          expect(cauldrons, hasLength(3));
          await tester.tap(find.byKey(const ValueKey('placementCell_2_0')));
          await tester.pumpAndSettle();
          expect(find.text('R1 : C3'), findsOneWidget);
          final deleteButton = find.byKey(
            const ValueKey('deleteSelectedWizardCauldron'),
          );
          await tester.ensureVisible(deleteButton);
          await tester.tap(deleteButton);
          await tester.pumpAndSettle();
          final strings = lookupAppLocalizations(const Locale('zh'));
          expect(
            find.text(strings.removeItemConfirm('R1 : C3 巫师坩埚')),
            findsOneWidget,
          );
          expect(cauldrons, hasLength(3));
          await tester.tap(find.text(strings.cancel));
          await tester.pumpAndSettle();
          expect(cauldrons, hasLength(3));
          await tester.tap(deleteButton);
          await tester.pumpAndSettle();
          await tester.tap(find.text(strings.remove));
          await tester.pumpAndSettle();
          expect(cauldrons, hasLength(2));
          expect(cauldrons.any((p) => p['GridX'] == 2), isFalse);
          expect(data['FutureField'], 42);
          expect(deleteButton, findsNothing);
        }
        // Every cell fills the original lawn, including when SafeArea padding
        // would otherwise be inherited by a nested scrollable grid.
        tester.view.padding = const FakeViewPadding(
          left: 12,
          right: 12,
          bottom: 24,
        );
        for (final size in [const Size(1600, 1200), const Size(320, 900)]) {
          tester.view.physicalSize = size;
          await tester.pumpAndSettle();
          final gridRect = tester.getRect(
            find.byKey(
              ValueKey(
                cauldron ? 'wizardCauldronGrid' : 'scarecrowPositionPoolGrid',
              ),
            ),
          );
          final firstCellRect = tester.getRect(cell);
          final lastCellRect = tester.getRect(
            find.byKey(const ValueKey('placementCell_8_4')),
          );
          expect(firstCellRect.left - gridRect.left, closeTo(1, .001));
          expect(firstCellRect.top - gridRect.top, closeTo(1, .001));
          expect(gridRect.right - lastCellRect.right, closeTo(1, .001));
          expect(gridRect.bottom - lastCellRect.bottom, closeTo(1, .001));
          expect(tester.takeException(), isNull);
        }
        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        final strings = lookupAppLocalizations(const Locale('zh'));
        final body = find.text(
          cauldron
              ? strings.wizardCauldronHelpOverview
              : strings.pumpkinScarecrowHelpOverview,
        );
        expect(tester.widget<Text>(body).textAlign, TextAlign.start);
        expect(
          find.text(
            cauldron
                ? strings.wizardCauldronHelpUsage
                : strings.pumpkinScarecrowHelpLogic,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
