import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _speedAsset = 'assets/images/tunnels/speed_up_tile_right.webp';
const _pathImage = 'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN';
const _pathAsset = 'assets/images/tunnels/$_pathImage.webp';
const _gulliverOrientation = 'GULLIVERTUNNEL_ORIENTATION_BIG_ON_LEFT';
const _gulliverAsset = 'assets/images/tunnels/$_gulliverOrientation.webp';

PvzObject _module(String objClass, Map<String, dynamic> data) =>
    PvzObject(aliases: [objClass], objClass: objClass, objData: data);

List<PvzObject> _roads({bool overlap = false}) => [
  _module('SpeedUpTileModuleProperties', {
    'Roads': [
      {'GridX': 0, 'GridY': 0, 'Img': SpeedUpTileCatalog.right},
    ],
  }),
  _module('TunnelDefendModuleProperties', {
    'Roads': [
      {'GridX': overlap ? 0 : 3, 'GridY': overlap ? 0 : 1, 'Img': _pathImage},
    ],
  }),
  _module('InitialGridItemGulliverTunnelProperties', {
    'TunnelPlacements': [
      {
        'GridX': overlap ? 0 : 8,
        'GridY': overlap ? 0 : 4,
        'Orientation': _gulliverOrientation,
      },
    ],
  }),
];

Widget _overview(List<PvzObject> modules, {double textScale = 1}) {
  final level = PvzLevelFile(
    objects: [
      _module('LevelDefinition', LevelDefinitionData().toJson()),
      ...modules,
    ],
  );
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: LevelOverviewDialog(
      levelFile: level,
      parsed: LevelParser.parseLevel(level),
      fileName: 'initial_terrain.json',
      onClose: () {},
    ),
  );
}

void _largeViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1600);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Finder _sidebarLabel(String label) =>
    find.descendant(of: find.byType(ListView), matching: find.text(label));

Future<void> _selectCategory(WidgetTester tester, String label) async {
  final target = _sidebarLabel(label);
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _lawnAsset(String path) => find.descendant(
  of: find.byType(LawnGrid),
  matching: find.byWidgetPredicate(
    (widget) => widget is AssetImageWidget && widget.assetPath == path,
  ),
);

Finder _terrainAsset(String kind, int col, int row, String path) =>
    find.descendant(
      of: find.byKey(ValueKey('initialTerrainLayer_$kind:$col:$row')),
      matching: find.byWidgetPredicate(
        (widget) => widget is AssetImageWidget && widget.assetPath == path,
      ),
    );

void _expectCell(WidgetTester tester, Finder content, int col, int row) {
  expect(content, findsOneWidget);
  final lawn = tester.widget<LawnGrid>(find.byType(LawnGrid));
  final gridRect = tester.getRect(
    find.descendant(of: find.byType(LawnGrid), matching: find.byType(GridView)),
  );
  final center = tester.getCenter(content);
  final cellWidth = gridRect.width / lawn.cols;
  final cellHeight = cellWidth / lawn.style.cellAspectRatio;
  expect(center.dx, closeTo(gridRect.left + (col + 0.5) * cellWidth, 1));
  expect(center.dy, closeTo(gridRect.top + (row + 0.5) * cellHeight, 1));
}

Future<void> _tapCell(WidgetTester tester, int col, int row) async {
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

  for (final waterColumns in [0, 9, -2, 20]) {
    testWidgets('initial tide paints safely at boundary $waterColumns', (
      tester,
    ) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _overview([
          _module('TideProperties', {'StartingWaveLocation': waterColumns}),
          _module('SpeedUpTileModuleProperties', {'Roads': []}),
        ]),
      );
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');
      expect(
        find.byKey(const ValueKey('initialTerrainBackground_tideSystem')),
        waterColumns > 0 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'terrain-only levels expose the combined grid with zero-based road positions',
    (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_overview(_roads()));
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');

      _expectCell(tester, _lawnAsset(_speedAsset), 0, 0);
      _expectCell(tester, _lawnAsset(_pathAsset), 3, 1);
      _expectCell(tester, _lawnAsset(_gulliverAsset), 8, 4);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'road underlays preserve overlapping grid-item icons and selection details',
    (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _overview([
          ..._roads(overlap: true),
          _module('InitialGridItemProperties', {
            'InitialGridItemPlacements': [
              {'GridX': 0, 'GridY': 0, 'TypeName': 'cosmoss'},
              {'GridX': 0, 'GridY': 0, 'TypeName': 'flowerpot'},
            ],
          }),
        ]),
      );
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');

      for (final path in [_speedAsset, _pathAsset, _gulliverAsset]) {
        _expectCell(tester, _lawnAsset(path), 0, 0);
      }
      final gridItems = find.descendant(
        of: find.byType(LawnGrid),
        matching: find.byType(GridItemIcon),
      );
      expect(
        tester.widgetList<GridItemIcon>(gridItems).map((item) => item.id),
        contains('cosmoss'),
      );
      // Terrain must not become fake grid-item IDs or replace real contents.
      expect(
        tester
            .widgetList<GridItemIcon>(gridItems)
            .every((item) => ['cosmoss', 'flowerpot'].contains(item.id)),
        isTrue,
      );
      await _tapCell(tester, 0, 0);
      for (final id in ['cosmoss', 'flowerpot']) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is GridItemIcon && widget.id == id && widget.size == 44,
          ),
          findsOneWidget,
        );
      }
      expect(
        find.byWidgetPredicate(
          (widget) => widget is PlantIcon && widget.id == 'cosmoss',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('combined grid paints roof pots power tiles and pirate planks', (
    tester,
  ) async {
    _largeViewport(tester);
    await tester.pumpWidget(
      _overview([
        _module('RoofProperties', {
          'FlowerPotStartColumn': 1,
          'FlowerPotEndColumn': 2,
        }),
        _module('PowerTileProperties', {
          'LinkedTiles': [
            {
              'Group': 'alpha',
              'Location': {'mX': 3, 'mY': 2},
            },
          ],
        }),
        _module('PiratePlankProperties', {
          'PlankRows': [2],
        }),
      ]),
    );
    await tester.pumpAndSettle();
    await _selectCategory(tester, 'Initial Lawn Overview');

    for (var row = 0; row < 5; row++) {
      for (var col = 1; col <= 2; col++) {
        _expectCell(
          tester,
          find.byKey(ValueKey('initialTerrainLayer_roofProperties:$col:$row')),
          col,
          row,
        );
      }
    }
    _expectCell(
      tester,
      find.byKey(const ValueKey('initialTerrainLayer_powerTile:3:2')),
      3,
      2,
    );
    expect(
      _lawnAsset('assets/images/others/Pirate_Seas_Planks.webp'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'combined grid paints initial armracks and energy tiles but not future waves',
    (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _overview([
          _module('ArmrackProperties', {
            'Overrides': [
              {
                'wave': 1,
                'itemList': [
                  {'mX': 2, 'mY': 1, 'type': 'ArmrackFlag'},
                ],
              },
              {
                'wave': 2,
                'itemList': [
                  {'mX': 4, 'mY': 2, 'type': 'ArmrackTorch'},
                ],
              },
            ],
          }),
          _module('EnergyGridProperties', {
            'Overrides': [
              {
                'wave': 1,
                'itemList': [
                  {'mX': 0, 'mY': 0},
                ],
              },
              {
                'wave': 3,
                'itemList': [
                  {'mX': 1, 'mY': 1},
                ],
              },
            ],
          }),
        ]),
      );
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');

      expect(
        _terrainAsset(
          'armrack',
          2,
          1,
          'assets/images/griditems/ArmrackFlag.webp',
        ),
        findsOneWidget,
      );
      expect(
        _lawnAsset('assets/images/griditems/ArmrackTorch.webp'),
        findsNothing,
      );
      const energyAsset = 'assets/images/griditems/energyGrid.webp';
      expect(_terrainAsset('energyGrid', 0, 0, energyAsset), findsOneWidget);
      expect(_terrainAsset('energyGrid', 1, 1, energyAsset), findsNothing);
      expect(_lawnAsset(energyAsset), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('combined overview includes both minecarts and their rails', (
    tester,
  ) async {
    _largeViewport(tester);
    await tester.pumpWidget(
      _overview([
        _module('RailcartProperties', {
          'Rails': [
            {'Column': 2, 'RowStart': 1, 'RowEnd': 3},
          ],
          'Railcarts': [
            {'Column': 2, 'Row': 2},
          ],
        }),
        _roads().first,
      ]),
    );
    await tester.pumpAndSettle();
    await _selectCategory(tester, 'Initial Lawn Overview');

    const railsAsset = 'assets/images/others/rails.webp';
    const cartAsset = 'assets/images/others/railcarts.webp';
    for (var row = 1; row <= 3; row++) {
      _expectCell(
        tester,
        _terrainAsset('railcart', 2, row, railsAsset),
        2,
        row,
      );
    }
    _expectCell(tester, _terrainAsset('railcart', 2, 2, cartAsset), 2, 2);
    _expectCell(tester, _lawnAsset(_speedAsset), 0, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'initial grid-items tab contains only its own module placements',
    (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _overview([
          ..._roads(),
          _module('InitialGridItemProperties', {
            'InitialGridItemPlacements': [
              {'GridX': 0, 'GridY': 0, 'TypeName': 'cosmoss'},
            ],
          }),
          _module('RoofProperties', {
            'FlowerPotStartColumn': 1,
            'FlowerPotEndColumn': 2,
          }),
          _module('LunarMineVeinModuleProperties', {
            'VeinPlacements': [
              {
                'GridX': 4,
                'GridY': 2,
                'TypeName': 'lunar_mine_vein',
                'EmergenceWave': 5,
              },
            ],
          }),
        ]),
      );
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');
      expect(_lawnAsset(_speedAsset), findsOneWidget);
      expect(
        _lawnAsset('assets/images/griditems/lunar_mine_vein.webp'),
        findsOneWidget,
      );

      await _selectCategory(tester, 'Initial Grid Items');
      for (final asset in [_speedAsset, _pathAsset, _gulliverAsset]) {
        expect(_lawnAsset(asset), findsNothing);
      }
      expect(
        _lawnAsset('assets/images/griditems/lunar_mine_vein.webp'),
        findsNothing,
      );
      final itemIcons = tester.widgetList<GridItemIcon>(
        find.descendant(
          of: find.byType(LawnGrid),
          matching: find.byType(GridItemIcon),
        ),
      );
      expect(itemIcons.map((item) => item.id), ['cosmoss']);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>).value.startsWith(
                'initialTerrain',
              ),
        ),
        findsNothing,
      );
      await _tapCell(tester, 0, 0);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is GridItemIcon &&
              widget.id == 'cosmoss' &&
              widget.size == 44,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('combined grid shows every manhole entrance and exit', (
    tester,
  ) async {
    _largeViewport(tester);
    await tester.pumpWidget(
      _overview([
        _module('ManholePipelineModuleProperties', {
          'PipelineList': [
            {'StartX': 0, 'StartY': 0, 'EndX': 8, 'EndY': 4},
            {'StartX': 3, 'StartY': 1, 'EndX': 5, 'EndY': 2},
          ],
        }),
        _module('SpeedUpTileModuleProperties', {'Roads': []}),
      ]),
    );
    await tester.pumpAndSettle();
    await _selectCategory(tester, 'Initial Lawn Overview');

    for (final cell in [
      (0, 0, 'down'),
      (3, 1, 'down'),
      (8, 4, 'up'),
      (5, 2, 'up'),
    ]) {
      _expectCell(
        tester,
        _terrainAsset(
          'manholePipeline',
          cell.$1,
          cell.$2,
          'assets/images/griditems/steam_${cell.$3}.webp',
        ),
        cell.$1,
        cell.$2,
      );
    }
    expect(
      _lawnAsset('assets/images/griditems/steam_down.webp'),
      findsNWidgets(2),
    );
    expect(
      _lawnAsset('assets/images/griditems/steam_up.webp'),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'combined grid preserves expedition roads and blocked positions',
    (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _overview([
          PvzObject(
            aliases: const ['SouDaCheTunnelDefendDefault'],
            objClass: 'TunnelDefendModuleProperties',
            objData: const {
              'BrickMapIndex': 3,
              'Roads': [
                {'GridX': 5, 'GridY': 1, 'Img': 'SouDaCheTunnelRoadBlocked'},
              ],
            },
          ),
          _module('SpeedUpTileModuleProperties', {'Roads': []}),
        ]),
      );
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');

      _expectCell(
        tester,
        _terrainAsset(
          'expeditionTiles',
          0,
          0,
          'assets/images/tunnels/SouDaCheTunnelRoad.webp',
        ),
        0,
        0,
      );
      _expectCell(
        tester,
        _terrainAsset(
          'expeditionTiles',
          5,
          1,
          'assets/images/tunnels/SouDaCheTunnelRoadBlocked.webp',
        ),
        5,
        1,
      );
      expect(
        _lawnAsset('assets/images/tunnels/SouDaCheTunnelRoad.webp'),
        findsNWidgets(13),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('combined terrain remains readable on a narrow scaled overview', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(285, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_overview(_roads(), textScale: 1.5));
    await tester.pumpAndSettle();
    await _selectCategory(tester, 'Initial Lawn Overview');
    await tester.ensureVisible(find.byType(LawnGrid));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(LawnGrid)).width, lessThanOrEqualTo(285));
    _expectCell(tester, _lawnAsset(_speedAsset), 0, 0);
    _expectCell(tester, _lawnAsset(_pathAsset), 3, 1);
    _expectCell(tester, _lawnAsset(_gulliverAsset), 8, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dedicated terrain categories remain independent from the combined grid',
    (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_overview(_roads()));
      await tester.pumpAndSettle();
      await _selectCategory(tester, 'Initial Lawn Overview');

      final categoryAssets = {
        'Speed-Up Tiles': _speedAsset,
        'Underground Palace Pathways': _pathAsset,
        'Gulliver Tunnels': _gulliverAsset,
      };
      for (final entry in categoryAssets.entries) {
        await _selectCategory(tester, entry.key);
        for (final asset in categoryAssets.values) {
          expect(
            _lawnAsset(asset),
            asset == entry.value ? findsOneWidget : findsNothing,
          );
        }
      }
      await _selectCategory(tester, 'Initial Lawn Overview');
      for (final asset in categoryAssets.values) {
        expect(_lawnAsset(asset), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
