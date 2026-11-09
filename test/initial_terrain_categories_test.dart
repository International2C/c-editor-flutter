import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _module(
  String objClass, {
  Map<String, dynamic> data = const {},
  String alias = 'InitialTerrain',
}) => PvzObject(aliases: [alias], objClass: objClass, objData: data);

Future<List<GridPreviewModuleKind>> _categories(
  WidgetTester tester,
  PvzLevelFile level,
) async {
  late List<GridPreviewCategoryOption> categories;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          categories = collectGridPreviewCategories(
            context,
            level,
            AppLocalizations.of(context)!,
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return categories.map((category) => category.kind).toList();
}

void main() {
  test('initial lawn overview label is localized', () {
    expect(
      lookupAppLocalizations(const Locale('zh')).previewTabInitialLawnOverview,
      '场地初始布局',
    );
    expect(
      lookupAppLocalizations(const Locale('en')).previewTabInitialLawnOverview,
      'Initial Lawn Overview',
    );
    expect(
      lookupAppLocalizations(const Locale('ru')).previewTabInitialLawnOverview,
      isNotEmpty,
    );
  });

  for (final entry in initialTerrainModuleKinds.entries) {
    testWidgets('${entry.key} alone keeps only its dedicated terrain tab', (
      tester,
    ) async {
      final level = PvzLevelFile(objects: [_module(entry.key)]);
      final original = jsonEncode(level.toJson());
      final kinds = await _categories(tester, level);

      expect(levelHasInitialTerrain(level), isTrue);
      expect(levelHasPrePlacedGridPreview(level), isTrue);
      expect(levelHasCommonGridItems(level), isFalse);
      expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
      expect(kinds, isNot(contains(GridPreviewModuleKind.initialLawnOverview)));
      expect(kinds, contains(entry.value));
      expect(jsonEncode(level.toJson()), original);
    });
  }

  testWidgets(
    'combined terrain overview is first and common remains explicit',
    (tester) async {
      final level = PvzLevelFile(
        objects: [
          _module('InitialGridItemProperties'),
          _module('SpeedUpTileModuleProperties'),
          _module('TunnelDefendModuleProperties'),
          _module('InitialGridItemGulliverTunnelProperties'),
        ],
      );
      final kinds = await _categories(tester, level);

      expect(levelHasCommonGridItems(level), isTrue);
      expect(kinds.first, GridPreviewModuleKind.initialLawnOverview);
      expect(
        kinds.where(
          (kind) => kind == GridPreviewModuleKind.initialLawnOverview,
        ),
        hasLength(1),
      );
      expect(
        kinds.where((kind) => kind == GridPreviewModuleKind.common),
        hasLength(1),
      );
      expect(
        kinds,
        containsAll([
          GridPreviewModuleKind.speedUpTile,
          GridPreviewModuleKind.tunnelDefend,
          GridPreviewModuleKind.gulliverTunnel,
        ]),
      );
    },
  );

  testWidgets('repeated modules do not create a combined overview', (
    tester,
  ) async {
    final kinds = await _categories(
      tester,
      PvzLevelFile(
        objects: [
          _module('SpeedUpTileModuleProperties', alias: 'FirstRoad'),
          _module('SpeedUpTileModuleProperties', alias: 'SecondRoad'),
        ],
      ),
    );

    expect(kinds, isNot(contains(GridPreviewModuleKind.initialLawnOverview)));
    expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
    expect(kinds, contains(GridPreviewModuleKind.speedUpTile));
  });

  testWidgets('initial grid-items module alone keeps its original category', (
    tester,
  ) async {
    final kinds = await _categories(
      tester,
      PvzLevelFile(objects: [_module('InitialGridItemProperties')]),
    );

    expect(kinds, [GridPreviewModuleKind.common]);
  });

  testWidgets(
    'expedition alias alone exposes its dedicated category without local data',
    (tester) async {
      final level = PvzLevelFile(
        objects: [
          _module(
            'LevelDefinition',
            data: {
              'Modules': ['RTID(SouDaCheTunnelDefendDefault@LevelModules)'],
            },
          ),
        ],
      );
      final kinds = await _categories(tester, level);

      expect(levelHasInitialTerrain(level), isTrue);
      expect(kinds, contains(GridPreviewModuleKind.expeditionTiles));
      expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
      expect(kinds, isNot(contains(GridPreviewModuleKind.initialLawnOverview)));
    },
  );

  for (final module in {
    'ArmrackProperties': GridPreviewModuleKind.armrack,
    'EnergyGridProperties': GridPreviewModuleKind.energyGrid,
  }.entries) {
    for (final wave in [1, 2, 5]) {
      testWidgets('${module.key} initial gating respects module wave $wave', (
        tester,
      ) async {
        final level = PvzLevelFile(
          objects: [
            _module(
              module.key,
              data: {
                'Overrides': [
                  {
                    'wave': wave,
                    'itemList': [
                      {'mX': 0, 'mY': 0},
                    ],
                  },
                ],
              },
            ),
          ],
        );
        final kinds = await _categories(tester, level);

        expect(levelHasInitialTerrain(level), wave == 1);
        expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
        expect(
          kinds,
          isNot(contains(GridPreviewModuleKind.initialLawnOverview)),
        );
        expect(kinds, contains(module.value));
      });
    }
  }

  testWidgets('future-only presets do not trigger a combined overview', (
    tester,
  ) async {
    final kinds = await _categories(
      tester,
      PvzLevelFile(
        objects: [
          _module('SpeedUpTileModuleProperties'),
          for (final objClass in ['ArmrackProperties', 'EnergyGridProperties'])
            _module(
              objClass,
              data: {
                'Overrides': [
                  {
                    'wave': 2,
                    'itemList': [
                      {'mX': 0, 'mY': 0},
                    ],
                  },
                ],
              },
            ),
        ],
      ),
    );

    expect(kinds, isNot(contains(GridPreviewModuleKind.initialLawnOverview)));
    expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
  });

  for (final objClass in [
    'RadiationMeteorModuleProperties',
    'GladiatorRowModuleProperties',
    'BombProperties',
    'PVZ1PassageModuleProperties',
    'BowlingMinigameProperties',
  ]) {
    testWidgets('$objClass alone does not imply initial terrain', (
      tester,
    ) async {
      final level = PvzLevelFile(objects: [_module(objClass)]);
      final kinds = await _categories(tester, level);

      expect(levelHasInitialTerrain(level), isFalse);
      expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
    });
  }

  testWidgets('lunar veins no longer expose an initial grid-items category', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        _module(
          'LunarMineVeinModuleProperties',
          data: {
            'VeinPlacements': [
              {'GridX': 0, 'GridY': 0, 'EmergenceWave': 4},
            ],
          },
        ),
      ],
    );
    final kinds = await _categories(tester, level);

    expect(levelHasInitialTerrain(level), isFalse);
    expect(kinds, contains(GridPreviewModuleKind.lunarMineVein));
    expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
    expect(kinds, isNot(contains(GridPreviewModuleKind.initialLawnOverview)));
  });

  testWidgets('dormant lunar veins combine with another initial module', (
    tester,
  ) async {
    final kinds = await _categories(
      tester,
      PvzLevelFile(
        objects: [
          _module('SpeedUpTileModuleProperties'),
          _module(
            'LunarMineVeinModuleProperties',
            data: {
              'VeinPlacements': [
                {'GridX': 0, 'GridY': 0, 'EmergenceWave': 4},
                {'GridX': 1, 'GridY': 0, 'EmergenceWave': 6},
              ],
            },
          ),
        ],
      ),
    );

    expect(kinds.first, GridPreviewModuleKind.initialLawnOverview);
    expect(kinds, isNot(contains(GridPreviewModuleKind.common)));
  });

  test(
    'initial terrain classification preserves imported road coordinates',
    () {
      final level = PvzLevelFile(
        objects: [
          _module(
            'SpeedUpTileModuleProperties',
            data: {
              'Roads': [
                {'GridX': 0, 'GridY': 0, 'Img': 'IMAGE_SPEED_UP_TILE_LEFT'},
                {'GridX': 8, 'GridY': 4, 'Img': 'IMAGE_SPEED_UP_TILE_RIGHT'},
              ],
            },
          ),
          _module(
            'TunnelDefendModuleProperties',
            data: {
              'Roads': [
                {'GridX': 1, 'GridY': 2, 'Img': 'ROAD'},
              ],
            },
          ),
          _module(
            'InitialGridItemGulliverTunnelProperties',
            data: {
              'TunnelPlacements': [
                {'GridX': 3, 'GridY': 0},
              ],
            },
          ),
        ],
      );
      final original = jsonEncode(level.toJson());

      expect(levelHasInitialTerrain(level), isTrue);
      expect(readSpeedUpTileData(level)!.roads.first.gridX, 0);
      expect(readSpeedUpTileData(level)!.roads.last.gridY, 4);
      expect(readTunnelDefendData(level)!.roads.single.gridX, 1);
      expect(readTunnelDefendData(level)!.roads.single.gridY, 2);
      expect(readGulliverTunnelData(level)!.tunnelPlacements.single.gridY, 0);
      expect(jsonEncode(level.toJson()), original);
    },
  );
}
