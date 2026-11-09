import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _speedUpTileClass = 'SpeedUpTileModuleProperties';

PvzObject _speedUpTileObject(Map<String, dynamic> data) => PvzObject(
  aliases: const ['SpeedUpTile'],
  objClass: _speedUpTileClass,
  objData: data,
);

Widget _localizedApp(Widget child, {String locale = 'en'}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  test('speed-up tiles are a single local scene module with empty roads', () {
    final metadata = ModuleRegistry.getMetadata(_speedUpTileClass);

    expect(metadata.objClass, _speedUpTileClass);
    expect(metadata.assetIconPath, isNull);
    expect(metadata.icon, Icons.fast_forward);
    expect(metadata.isCore, isTrue);
    expect(metadata.category, ModuleCategory.scene);
    expect(metadata.defaultAlias, 'SpeedUpTile');
    expect(metadata.defaultSource, 'CurrentLevel');
    expect(metadata.allowMultiple, isFalse);
    expect(metadata.routeId, 'SpeedUpTileModule');
    expect(metadata.initialData, {'Roads': <dynamic>[]});
    expect(
      ModuleRegistry.getAllModules().where(
        (module) => module.objClass == _speedUpTileClass,
      ),
      hasLength(1),
    );
  });

  test(
    'speed-up tiles appear immediately after roof pots and before pathways',
    () {
      final classes = ModuleRegistry.registry.keys.toList();
      final index = classes.indexOf(_speedUpTileClass);

      expect(index, greaterThan(0));
      expect(classes.sublist(index - 1, index + 2), [
        'RoofProperties',
        _speedUpTileClass,
        'TunnelDefendModuleProperties',
      ]);
    },
  );

  for (final translation in const {
    'zh': ('加速带', '在场地上预置极品飞车联动秘境的加速带'),
    'en': (
      'Speed-Up Tiles',
      'Places preset Speed-Up Tiles from the Need for Speed crossover secret realm on the lawn',
    ),
    'ru': (
      'Ускоряющие плитки',
      'Размещает на газоне ускоряющие плитки из тайного мира коллаборации с Need for Speed',
    ),
  }.entries) {
    testWidgets('speed-up tile metadata resolves ${translation.key} text', (
      tester,
    ) async {
      late String title;
      late String description;
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) {
              final metadata = ModuleRegistry.getMetadata(_speedUpTileClass);
              title = metadata.getTitle(context);
              description = metadata.getDescription(context);
              return const SizedBox.shrink();
            },
          ),
          locale: translation.key,
        ),
      );
      await tester.pumpAndSettle();

      expect(title, translation.value.$1);
      expect(description, translation.value.$2);
    });
  }

  test('preview reads zero-based roads without dropping imported metadata', () {
    final original = <String, dynamic>{
      'Roads': [
        {
          'GridX': 0,
          'GridY': 0,
          'Img': SpeedUpTileCatalog.left,
          'CustomRoadData': {'retained': true},
        },
        {'GridX': 8, 'GridY': 4, 'Img': SpeedUpTileCatalog.down},
      ],
      'CustomModuleData': 42,
    };
    final level = PvzLevelFile(objects: [_speedUpTileObject(original)]);

    expect(levelHasPrePlacedGridPreview(level), isTrue);
    final data = readSpeedUpTileData(level)!;
    expect(data.roads.first.gridX, 0);
    expect(data.roads.first.gridY, 0);
    expect(data.roads.last.gridX, 8);
    expect(data.roads.last.gridY, 4);
    expect(data.toJson(), original);
    expect(readSpeedUpTileData(PvzLevelFile(objects: [])), isNull);
  });

  testWidgets(
    'preview category places speed-up tiles between roof and pathways',
    (tester) async {
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['RoofProps'],
            objClass: 'RoofProperties',
            objData: RoofPropertiesData().toJson(),
          ),
          _speedUpTileObject({'Roads': <dynamic>[]}),
          PvzObject(
            aliases: const ['TunnelDefend'],
            objClass: 'TunnelDefendModuleProperties',
            objData: const {'BrickMapIndex': 1, 'Roads': <dynamic>[]},
          ),
        ],
      );
      late List<GridPreviewCategoryOption> categories;
      await tester.pumpWidget(
        _localizedApp(
          Builder(
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

      expect(categories.map((category) => category.kind), [
        GridPreviewModuleKind.initialLawnOverview,
        GridPreviewModuleKind.roofProperties,
        GridPreviewModuleKind.speedUpTile,
        GridPreviewModuleKind.tunnelDefend,
      ]);
      expect(categories[2].label, 'Speed-Up Tiles');
      expect(levelHasPrePlacedGridPreview(level), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
