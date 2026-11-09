import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/lunar_mine_vein_type_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart'
    show CustomResourceBadge;
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _preview(PvzLevelFile level) {
  if (!level.objects.any((object) => object.objClass == 'LevelDefinition')) {
    level.objects.insert(
      0,
      PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData().toJson(),
      ),
    );
  }
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LevelOverviewDialog(
      levelFile: level,
      parsed: LevelParser.parseLevel(level),
      fileName: 'grid_items.json',
      onClose: () {},
    ),
  );
}

Finder _placementTab(String label) => find.descendant(
  of: find.byKey(const ValueKey('prePlacedTabScrollbar')),
  matching: find.text(label),
);

void _setLargeViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1600);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _tapLawnCell(WidgetTester tester, int col, [int row = 0]) async {
  final lawn = tester.widget<LawnGrid>(find.byType(LawnGrid));
  final cells = find.descendant(
    of: find.byType(LawnGrid),
    matching: find.byWidgetPredicate(
      (widget) => widget is GestureDetector && widget.onTap != null,
    ),
  );
  await tester.tap(cells.at(row * lawn.cols + col));
  await tester.pumpAndSettle();
}

PvzObject _customGridItemType(String id) {
  return switch (id) {
    'armrack' => PvzObject(
      aliases: const ['armrack'],
      objClass: 'GridItemType',
      objData: const <String, dynamic>{
        'TypeName': 'armrack',
        'GridItemClass': 'GridItemArmrack',
        'Properties': 'RTID(GridItemArmrackDefault@PropertySheets)',
      },
    ),
    'energyGrid' => PvzObject(
      aliases: const ['energyGrid'],
      objClass: 'GridItemType',
      objData: const <String, dynamic>{
        'TypeName': 'energyGrid',
        'GridItemClass': 'GridItemEnergyGrid',
        'Properties': 'RTID(GridItemEnergyGridDefault@PropertySheets)',
      },
    ),
    _ => throw ArgumentError.value(id),
  };
}

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
      ResourceNames.ensureLoaded(),
    ]);
  });

  for (final combined in [false, true]) {
    testWidgets(
      'cauldrons fill their overview cells with combined layout $combined',
      (tester) async {
        _setLargeViewport(tester);
        final level = PvzLevelFile(
          objects: [
            PvzObject(
              aliases: const ['WizardCauldrons'],
              objClass: 'InitialGridItemWizardCrucibleProps',
              objData: const {
                'InitialGridItemWizardCrucibles': [
                  {'GridX': 2, 'GridY': 1},
                ],
              },
            ),
            if (combined)
              PvzObject(
                aliases: const ['SpeedUpTile'],
                objClass: 'SpeedUpTileModuleProperties',
                objData: const {'Roads': []},
              ),
          ],
        );
        await tester.pumpWidget(_preview(level));
        await tester.pumpAndSettle();
        if (combined) {
          final category = find.descendant(
            of: find.byType(ListView),
            matching: find.text('Initial Lawn Overview'),
          );
          await tester.ensureVisible(category);
          await tester.tap(category);
          await tester.pumpAndSettle();
        } else {
          expect(
            find.descendant(
              of: find.byKey(const ValueKey('gridSubCategoryScrollbar')),
              matching: find.text('Wizard Cauldron'),
            ),
            findsOneWidget,
          );
        }
        final lawn = find.byType(LawnGrid);
        await tester.ensureVisible(lawn);
        await tester.pumpAndSettle();
        final icon = find.descendant(
          of: lawn,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is GridItemIcon && widget.id == 'wizard_crucible',
          ),
        );
        expect(icon, findsOneWidget);
        final grid = tester.widget<LawnGrid>(lawn);
        final rect = tester.getRect(
          find.descendant(of: lawn, matching: find.byType(GridView)),
        );
        final cellWidth = rect.width / grid.cols;
        expect(tester.getSize(icon).width, closeTo(cellWidth * 0.9, 1));
        expect(tester.getSize(icon).height, closeTo(cellWidth * 0.9, 1));
        expect(
          tester.getCenter(icon).dx,
          closeTo(rect.left + 2.5 * cellWidth, 1),
        );
        expect(
          tester.getCenter(icon).dy,
          closeTo(rect.top + 1.5 * cellWidth, 1),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('single module retains its name above multiple wave tabs', (
    tester,
  ) async {
    _setLargeViewport(tester);
    await tester.pumpWidget(
      _preview(
        PvzLevelFile(
          objects: [
            PvzObject(
              aliases: const ['Meteor'],
              objClass: 'RadiationMeteorModuleProperties',
              objData: const {
                'SpawnSchedule': [
                  {'Wave': 2, 'GridX': 0, 'GridY': 0},
                  {'Wave': 5, 'GridX': 1, 'GridY': 1},
                ],
              },
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      find.text(l10n.moduleTitle_RadiationMeteorModuleProperties),
      findsOneWidget,
    );
    final tabs = find.byKey(const ValueKey('gridSubCategoryScrollbar'));
    for (final wave in [2, 5]) {
      expect(
        find.descendant(
          of: tabs,
          matching: find.text(l10n.customZombieWaveItem(wave)),
        ),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('overview renders speed-up arrows at zero-based grid positions', (
    tester,
  ) async {
    _setLargeViewport(tester);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['SpeedUpTile'],
          objClass: 'SpeedUpTileModuleProperties',
          objData: SpeedUpTileModulePropertiesData(
            roads: [
              for (var i = 0; i < SpeedUpTileCatalog.directions.length; i++)
                SpeedUpTileRoadData(
                  gridX: i,
                  gridY: 0,
                  img: SpeedUpTileCatalog.directions[i],
                ),
            ],
          ).toJson(),
        ),
      ],
    );
    await tester.pumpWidget(_preview(level));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('gridSubCategoryScrollbar')),
        matching: find.text(
          lookupAppLocalizations(
            const Locale('en'),
          ).moduleTitle_SpeedUpTileModuleProperties,
        ),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byType(LawnGrid));
    await tester.pumpAndSettle();

    final images = find.descendant(
      of: find.byType(LawnGrid),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is AssetImageWidget &&
            widget.assetPath.startsWith('assets/images/tunnels/speed_up_tile_'),
      ),
    );
    expect(
      tester
          .widgetList<AssetImageWidget>(images)
          .map((image) => image.assetPath),
      SpeedUpTileCatalog.directions.map(SpeedUpTileCatalog.assetForImage),
    );
    final grid = tester.widget<LawnGrid>(find.byType(LawnGrid));
    final gridRect = tester.getRect(
      find.descendant(
        of: find.byType(LawnGrid),
        matching: find.byType(GridView),
      ),
    );
    final firstTile = tester.getCenter(images.first);
    expect(firstTile.dx, lessThan(gridRect.left + gridRect.width / grid.cols));
    expect(firstTile.dy, lessThan(gridRect.top + gridRect.height / grid.rows));
    expect(tester.takeException(), isNull);
  });

  testWidgets('overview shows dormant vein variants and their grown crystals', (
    tester,
  ) async {
    _setLargeViewport(tester);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['InitialGridItems'],
          objClass: 'InitialGridItemProperties',
          objData: const {'InitialGridItemPlacements': []},
        ),
        PvzObject(
          aliases: ['LunarMineVeins'],
          objClass: 'LunarMineVeinModuleProperties',
          objData: LunarMineVeinModulePropertiesData(
            placements: [
              for (var i = 0; i < kLunarMineVeinTypes.length; i++)
                LunarMineVeinPlacementData(
                  typeName: kLunarMineVeinTypes[i].type,
                  gridX: i,
                  emergenceWave: 5,
                ),
            ],
          ).toJson(),
        ),
      ],
    );
    await tester.pumpWidget(_preview(level));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(LawnGrid));
    await tester.pumpAndSettle();

    List<String> lawnAssets() => tester
        .widgetList<AssetImageWidget>(
          find.descendant(
            of: find.byType(LawnGrid),
            matching: find.byType(AssetImageWidget),
          ),
        )
        .map((w) => w.assetPath)
        .toList();

    expect(lawnAssets(), kLunarMineVeinTypes.map((v) => v.iconAsset));
    final sidebarLabel = find.descendant(
      of: find.byType(ListView),
      matching: find.text('Crystal Veins'),
    );
    await tester.ensureVisible(sidebarLabel);
    await tester.tap(sidebarLabel);
    await tester.pumpAndSettle();
    expect(lawnAssets(), kLunarMineVeinTypes.map((v) => v.oreIconAsset));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected grid items retain their type when plant IDs overlap', (
    tester,
  ) async {
    _setLargeViewport(tester);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['InitialGridItems'],
          objClass: 'InitialGridItemProperties',
          objData: const <String, dynamic>{
            'InitialGridItemPlacements': [
              {'GridX': 0, 'GridY': 0, 'TypeName': 'cosmoss'},
              {'GridX': 1, 'GridY': 0, 'TypeName': 'lilypad'},
              {'GridX': 2, 'GridY': 0, 'TypeName': 'flowerpot'},
            ],
          },
        ),
      ],
    );
    await tester.pumpWidget(_preview(level));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(LawnGrid));
    await tester.pumpAndSettle();

    var col = 0;
    for (final entry in const {
      'cosmoss': 'Moss Tile',
      'lilypad': 'Lily Pad',
      'flowerpot': 'Flower Pot',
    }.entries) {
      await _tapLawnCell(tester, col++);

      final selectedIcon = find.byWidgetPredicate(
        (widget) =>
            widget is GridItemIcon &&
            widget.id == entry.key &&
            widget.size == 44,
      );
      expect(selectedIcon, findsOneWidget);
      expect(
        find.descendant(
          of: selectedIcon,
          matching: find.byWidgetPredicate(
            (widget) => widget is Tooltip && widget.message == entry.value,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: selectedIcon,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is AssetImageWidget &&
                widget.assetPath == 'assets/images/griditems/${entry.key}.webp',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is PlantIcon && widget.id == entry.key,
        ),
        findsNothing,
      );
    }
  });

  testWidgets(
    'Cosmoss plant and Moss Tile remain distinct after switching tabs',
    (tester) async {
      _setLargeViewport(tester);
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['InitialPlants'],
            objClass: 'InitialPlantEntryProperties',
            objData: const <String, dynamic>{
              'Plants': [
                {'GridX': 0, 'GridY': 0, 'TypeName': 'cosmoss'},
              ],
            },
          ),
          PvzObject(
            aliases: const ['InitialGridItems'],
            objClass: 'InitialGridItemProperties',
            objData: const <String, dynamic>{
              'InitialGridItemPlacements': [
                {'GridX': 0, 'GridY': 0, 'TypeName': 'cosmoss'},
              ],
            },
          ),
        ],
      );
      await tester.pumpWidget(_preview(level));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(LawnGrid));
      await tester.pumpAndSettle();

      for (var round = 0; round < 2; round++) {
        await _tapLawnCell(tester, 0);
        final plantFooter = find.byWidgetPredicate(
          (widget) =>
              widget is PlantIcon &&
              widget.id == 'cosmoss' &&
              widget.size == 44,
        );
        expect(plantFooter, findsOneWidget);
        expect(
          find.descendant(
            of: plantFooter,
            matching: find.byWidgetPredicate(
              (widget) => widget is Tooltip && widget.message == 'Cosmoss',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: plantFooter,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is AssetImageWidget &&
                  widget.assetPath == 'assets/images/plants/icon_cosmoss.webp',
            ),
          ),
          findsOneWidget,
        );

        await tester.tap(_placementTab('Grid Items'));
        await tester.pumpAndSettle();
        await _tapLawnCell(tester, 0);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is GridItemIcon &&
                widget.id == 'cosmoss' &&
                widget.size == 44,
          ),
          findsOneWidget,
        );
        await tester.tap(_placementTab('Plants'));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'protected Moss Tile grid and selection do not resolve to Cosmoss',
    (tester) async {
      _setLargeViewport(tester);
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['InitialGridItems'],
            objClass: 'InitialGridItemProperties',
            objData: const <String, dynamic>{
              'InitialGridItemPlacements': [
                {'GridX': 0, 'GridY': 0, 'TypeName': 'cosmoss'},
              ],
            },
          ),
          PvzObject(
            aliases: const ['ProtectedGridItems'],
            objClass: 'ProtectTheGridItemChallengeProperties',
            objData: const <String, dynamic>{
              'GridItems': [
                {'GridX': 0, 'GridY': 0, 'GridItemType': 'cosmoss'},
              ],
            },
          ),
        ],
      );
      await tester.pumpWidget(_preview(level));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(LawnGrid));
      await tester.pumpAndSettle();
      await tester.tap(_placementTab('Challenge Module Settings'));
      await tester.pumpAndSettle();

      final cellIcon = find.byWidgetPredicate(
        (widget) =>
            widget is GridItemIcon && widget.id == 'cosmoss' && widget.isGrid,
      );
      expect(cellIcon, findsOneWidget);
      await _tapLawnCell(tester, 0);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is GridItemIcon &&
              widget.id == 'cosmoss' &&
              widget.size == 44,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is PlantIcon && widget.id == 'cosmoss',
        ),
        findsNothing,
      );
    },
  );

  testWidgets('bronze matrix statues use their corresponding zombie icons', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['BronzeStatues'],
          objClass: 'BronzeProperties',
          objData: const <String, dynamic>{
            'data': [
              {
                'itemList': [
                  {'mX': 7, 'mY': 0, 'spawnTime': 60, 'type': 'strength'},
                  {'mX': 8, 'mY': 1, 'spawnTime': 60, 'type': 'mage'},
                  {'mX': 7, 'mY': 2, 'spawnTime': 60, 'type': 'agile'},
                ],
              },
            ],
          },
        ),
      ],
    );

    await tester.pumpWidget(_preview(level));
    await tester.pumpAndSettle();

    for (final id in const [
      'kongfu_strong_bronze',
      'kongfu_magic_bronze',
      'kongfu_agile_bronze',
    ]) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ZombieIcon && widget.id == id && widget.isGrid,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is GridItemIcon && widget.id == id,
        ),
        findsNothing,
      );
    }
  });

  testWidgets(
    'overview separates dedicated-module and generic custom grid items',
    (tester) async {
      final level = PvzLevelFile(
        objects: [
          _customGridItemType('armrack'),
          _customGridItemType('energyGrid'),
          PvzObject(
            aliases: const ['InitialGridItems'],
            objClass: 'InitialGridItemProperties',
            objData: const <String, dynamic>{
              'InitialGridItemPlacements': [
                {'GridX': 1, 'GridY': 0, 'TypeName': 'armrack'},
                {'GridX': 2, 'GridY': 0, 'TypeName': 'energyGrid'},
              ],
            },
          ),
          PvzObject(
            aliases: const ['Armrack'],
            objClass: 'ArmrackProperties',
            objData: const <String, dynamic>{
              'Overrides': [
                {
                  'wave': 2,
                  'itemList': [
                    {'mX': 3, 'mY': 0, 'type': 'armrack'},
                  ],
                },
              ],
            },
          ),
          PvzObject(
            aliases: const ['EnergyGrid'],
            objClass: 'EnergyGridProperties',
            objData: const <String, dynamic>{
              'Overrides': [
                {
                  'wave': 3,
                  'itemList': [
                    {'mX': 4, 'mY': 0},
                  ],
                },
              ],
            },
          ),
        ],
      );

      await tester.pumpWidget(_preview(level));
      await tester.pumpAndSettle();

      for (final id in const ['armrack', 'energyGrid']) {
        final dedicatedModule = find.byKey(
          ValueKey('levelOverviewGridItem_${id}_dedicatedModule'),
        );
        final genericCustom = find.byKey(
          ValueKey('levelOverviewGridItem_${id}_standard'),
        );

        expect(dedicatedModule, findsOneWidget);
        expect(genericCustom, findsOneWidget);
        expect(
          find.descendant(
            of: dedicatedModule,
            matching: find.byType(CustomResourceBadge),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: genericCustom,
            matching: find.byType(CustomResourceBadge),
          ),
          findsOneWidget,
        );
      }
    },
  );
}
