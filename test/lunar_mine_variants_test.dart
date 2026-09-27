import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/lunar_mine_vein_type_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/pumpkin_house_event_screen.dart';
import 'package:c_editor/screens/editor/events/shell_event_screen.dart';
import 'package:c_editor/screens/editor/modules/lunar_mine_vein_module_screen.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';
import 'package:c_editor/widgets/grid_override_preview_grid.dart';
import 'package:c_editor/widgets/wave_module_preview_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Module excerpt from the official MOON14 level supplied as the format reference.
const _moon14Module = <String, dynamic>{
  'aliases': ['LunarMineVeins'],
  'objclass': 'LunarMineVeinModuleProperties',
  'objdata': {
    'VeinPlacements': [
      {
        'TypeName': 'lunar_mine_vein_fragile_plantfood',
        'GridX': 3,
        'GridY': 2,
        'EmergenceWave': 5,
      },
      {
        'TypeName': 'lunar_mine_vein',
        'GridX': 5,
        'GridY': 2,
        'EmergenceWave': 4,
      },
    ],
  },
};

PvzObject _moon14Object() => PvzObject.fromJson(
  jsonDecode(jsonEncode(_moon14Module)) as Map<String, dynamic>,
);

Widget _localizedApp(
  Widget child, {
  double textScale = 1,
  String locale = 'en',
}) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: child,
);

Map<String, Map<String, dynamic>> _referenceObjects(String file) {
  final root =
      jsonDecode(File('assets/reference/$file.json').readAsStringSync()) as Map;
  return {
    for (final object in root['objects'] as List)
      for (final alias in object['aliases'] as List? ?? [])
        alias as String: object as Map<String, dynamic>,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('MOON14 TypeName fields survive a module import and export', () {
    final object = _moon14Object();
    final data = LunarMineVeinModulePropertiesData.fromJson(object.objData);
    expect(data.placements.map((p) => p.typeName), [
      'lunar_mine_vein_fragile_plantfood',
      'lunar_mine_vein',
    ]);
    object.objData = data.toJson();
    expect(jsonDecode(jsonEncode(object.toJson())), _moon14Module);
  });

  test(
    'legacy placements default to regular and unknown types are preserved',
    () {
      final data = LunarMineVeinModulePropertiesData.fromJson({
        'VeinPlacements': [
          {'GridX': 1, 'GridY': 2, 'EmergenceWave': 4},
          {
            'TypeName': 'future_vein',
            'GridX': 2,
            'GridY': 2,
            'EmergenceWave': 5,
          },
        ],
      });
      expect(data.placements.map((p) => p.typeName), [
        'lunar_mine_vein',
        'future_vein',
      ]);
      expect(data.toJson()['VeinPlacements'], [
        {
          'TypeName': 'lunar_mine_vein',
          'GridX': 1,
          'GridY': 2,
          'EmergenceWave': 4,
        },
        {'TypeName': 'future_vein', 'GridX': 2, 'GridY': 2, 'EmergenceWave': 5},
      ]);
      expect(
        lunarMineVeinIconAsset('future_vein'),
        'assets/images/others/unknown.webp',
      );
      expect(
        lunarMineVeinOreIconAsset('future_vein'),
        'assets/images/others/unknown.webp',
      );
    },
  );

  test('discovery and preview image module retain each vein variant', () {
    final placements = [
      for (var i = 0; i < kLunarMineVeinTypes.length; i++)
        LunarMineVeinPlacementData(
          typeName: kLunarMineVeinTypes[i].type,
          gridX: i,
          gridY: 2,
          emergenceWave: 5,
        ),
    ];
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LunarMineVeins'],
          objClass: 'LunarMineVeinModuleProperties',
          objData: LunarMineVeinModulePropertiesData(
            placements: placements,
          ).toJson(),
        ),
      ],
    );
    final original = jsonEncode(level.toJson());
    expect(
      GridItemDiscovery.discoverGridItems(level),
      kLunarMineVeinTypes.map((v) => v.type).toSet(),
    );
    final payload = previewModuleInfoBuild(
      levelFile: level,
      objClass: 'LunarMineVeinModuleProperties',
      t: (key, fallback, [args]) => fallback,
    );
    final items = payload.sections.single.items;
    expect(
      items.map((item) => item.assetPath),
      kLunarMineVeinTypes.map((v) => v.iconAsset),
    );
    expect(items.map((item) => (item.gridX, item.gridY)), [
      (0, 2),
      (1, 2),
      (2, 2),
      (3, 2),
      (4, 2),
    ]);
    expect(jsonEncode(level.toJson()), original);
  });

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets('vein cards share each row height while resizing in $locale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(760, 1000);
      addTearDown(tester.view.reset);
      final object = _moon14Object();
      final original = jsonEncode(object.toJson());
      await tester.pumpWidget(
        _localizedApp(
          LunarMineVeinModuleScreen(
            rtid: 'RTID(LunarMineVeins@CurrentLevel)',
            levelFile: PvzLevelFile(objects: [object]),
            onChanged: () {},
            onBack: () {},
          ),
          textScale: 1.8,
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      for (final width in [760.0, 380.0, 220.0, 760.0]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpAndSettle();
        final rows = <double, List<Rect>>{};
        for (final info in kLunarMineVeinTypes) {
          final card = find.byKey(ValueKey('lunar-vein-type-${info.type}'));
          final rect = tester.getRect(card);
          rows.putIfAbsent(rect.top, () => []).add(rect);
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(width));
          final context = tester.element(card);
          final label = ResourceNames.lookup(context, 'griditem_${info.type}');
          expect(
            find.descendant(of: card, matching: find.byTooltip(label)),
            findsOneWidget,
          );
        }
        if (width == 760) expect(rows, hasLength(1));
        for (final row in rows.values) {
          for (final rect in row) {
            expect(rect.height, closeTo(row.first.height, 0.1));
          }
        }
        expect(tester.takeException(), isNull);
      }
      expect(jsonEncode(object.toJson()), original);
    });
  }

  testWidgets('vein picker edits types and waves without losing MOON14 data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(380, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final object = _moon14Object();
    var changeCount = 0;
    await tester.pumpWidget(
      _localizedApp(
        LunarMineVeinModuleScreen(
          rtid: 'RTID(LunarMineVeins@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () => changeCount++,
          onBack: () {},
        ),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(changeCount, 0);
    expect(object.toJson(), _moon14Module);
    expect(tester.takeException(), isNull);

    final waveField = find.byKey(const ValueKey('vein-wave-3-2'));
    await tester.ensureVisible(waveField);
    await tester.enterText(waveField, '8');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    expect(object.objData['VeinPlacements'][0], {
      'TypeName': 'lunar_mine_vein_fragile_plantfood',
      'GridX': 3,
      'GridY': 2,
      'EmergenceWave': 8,
    });

    final hardened = find.byKey(
      const ValueKey('lunar-vein-type-lunar_mine_vein_hardened'),
    );
    await tester.ensureVisible(hardened);
    await tester.tap(hardened);
    await tester.pumpAndSettle();

    Future<void> tapCell(int col, int row) async {
      final grid = find.byType(GridOverridePlacementGrid);
      await tester.ensureVisible(grid);
      await tester.pumpAndSettle();
      final cells = find.descendant(
        of: grid,
        matching: find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onTap != null,
        ),
      );
      await tester.tap(cells.at(row * 9 + col));
      await tester.pumpAndSettle();
    }

    await tapCell(3, 2);
    expect(object.objData['VeinPlacements'][0], {
      'TypeName': 'lunar_mine_vein_hardened',
      'GridX': 3,
      'GridY': 2,
      'EmergenceWave': 8,
    });
    await tapCell(0, 0);
    expect(object.objData['VeinPlacements'][2], {
      'TypeName': 'lunar_mine_vein_hardened',
      'GridX': 0,
      'GridY': 0,
      'EmergenceWave': 1,
    });
    final grid = tester.widget<GridOverridePlacementGrid>(
      find.byType(GridOverridePlacementGrid),
    );
    expect(
      grid.cellImageAt!(3, 2),
      'assets/images/griditems/lunar_mine_vein_hardened.webp',
    );
    expect(
      grid.cellImageAt!(5, 2),
      'assets/images/griditems/lunar_mine_vein.webp',
    );
    grid.onRemoveAt!(0, 0);
    await tester.pumpAndSettle();
    expect(object.objData['VeinPlacements'], hasLength(2));
    expect(
      object.objData['VeinPlacements'][1],
      (_moon14Module['objdata'] as Map)['VeinPlacements'][1],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('wave preview uses each crystal type only on its growth wave', (
    tester,
  ) async {
    final data = LunarMineVeinModulePropertiesData(
      placements: [
        for (var i = 0; i < kLunarMineVeinTypes.length; i++)
          LunarMineVeinPlacementData(
            typeName: kLunarMineVeinTypes[i].type,
            gridX: i,
            emergenceWave: 5,
          ),
        LunarMineVeinPlacementData(gridX: 5, emergenceWave: 6),
      ],
    );
    await tester.pumpWidget(
      _localizedApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showLunarMineVeinWavePreviewDialog(
                context,
                levelFile: PvzLevelFile(objects: []),
                waveIndex: 5,
                data: data,
              ),
              child: const Text('Preview'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    final grid = tester.widget<GridOverridePreviewGrid>(
      find.byType(GridOverridePreviewGrid),
    );
    for (var i = 0; i < kLunarMineVeinTypes.length; i++) {
      expect(grid.cellImageAt(i, 0), kLunarMineVeinTypes[i].oreIconAsset);
    }
    expect(grid.cellImageAt(5, 0), isNull);
    expect(tester.takeException(), isNull);
  });

  test(
    'newly supplied Eagle Standard, hard-shell vein and core icons resolve',
    () {
      for (final type in [
        'roman_eagle_flag',
        'lunar_mine_vein_hardened',
        'lunar_mine_ore_hardened_core',
      ]) {
        final path = 'assets/images/griditems/$type.webp';
        expect(GridItemRepository.getIconPath(type), path);
        expect(File(path).existsSync(), isTrue);
      }
    },
  );

  test('vein previews match the crystals defined by the game references', () {
    final types = _referenceObjects('GridItemTypes');
    final properties = _referenceObjects('PropertySheets');
    expect(kLunarMineVeinTypes.first.type, 'lunar_mine_vein');
    for (final vein in kLunarMineVeinTypes) {
      final propertyRtid = types[vein.type]!['objdata']['Properties'] as String;
      final propertyAlias = propertyRtid.substring(5).split('@').first;
      final data = properties[propertyAlias]!['objdata'] as Map;
      expect(data['SpawnOreTypeName'] ?? 'lunar_mine_ore', vein.oreType);
      expect(GridItemRepository.getIconPath(vein.type), vein.iconAsset);
      expect(File(vein.iconAsset).existsSync(), isTrue);
      expect(File(vein.oreIconAsset).existsSync(), isTrue);
    }
    final hardened = lunarMineVeinTypeInfo('lunar_mine_vein_hardened')!;
    expect(hardened.oreType, 'lunar_mine_ore_hardened_shell');
    final oreRtid = types[hardened.oreType]!['objdata']['Properties'] as String;
    final oreProps = properties[oreRtid.substring(5).split('@').first]!;
    expect(oreProps['objdata']['Hitpoints'], 3000);
  });

  test('Eagle Standard and Pumpkin House follow the Moon Rocket', () {
    final items = GridItemRepository.allItems;
    final rocket = items.indexWhere(
      (item) => item.typeName == 'rocket_landing',
    );
    expect(rocket, greaterThanOrEqualTo(0));
    final additions = items.skip(rocket + 1).take(2).toList();
    expect(additions.map((item) => item.typeName), [
      'roman_eagle_flag',
      'pumpkin_house',
    ]);
    for (final item in additions) {
      expect(item.category, GridItemCategory.spawnableObjects);
      expect(
        GridItemRepository.buildGridItemTypeRtid(
          item.typeName,
          PvzLevelFile(objects: []),
        ),
        'RTID(${item.typeName}@GridItemTypes)',
      );
    }
  });

  for (final type in ['atlantis_shell', 'pumpkin_house']) {
    testWidgets('$type cards show codenames without large-text overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final object = PvzObject(
        aliases: ['Event'],
        objClass: type == 'atlantis_shell'
            ? 'ZombieAtlantisShellActionProps'
            : 'PumpkinHouseActionProps',
        objData: {
          'Tiles': [
            {
              'Location': {'mX': 0, 'mY': 0},
              'Type': type,
            },
            {
              'Location': {'mX': 20, 'mY': 20},
              'Type': type,
            },
          ],
        },
      );
      final level = PvzLevelFile(objects: [object]);
      final screen = type == 'atlantis_shell'
          ? ShellEventScreen(
              rtid: 'RTID(Event@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            )
          : PumpkinHouseEventScreen(
              rtid: 'RTID(Event@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(type), findsNWidgets(2));
      expect(find.byTooltip(type), findsNWidgets(2));
      for (final code in [find.text(type).first, find.text(type).last]) {
        await tester.ensureVisible(code);
        await tester.pumpAndSettle();
        final card = find.ancestor(of: code, matching: find.byType(Card)).first;
        expect(tester.getRect(card).contains(tester.getCenter(code)), isTrue);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
