import 'dart:convert';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document_snapshot.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzObject _object(String type, Map<String, dynamic> data) =>
    PvzObject(aliases: [type], objClass: type, objData: data);

PvzLevelFile _level() => PvzLevelFile(
  objects: [
    _object('LevelDefinition', LevelDefinitionData().toJson()),
    _object('SpeedUpTileModuleProperties', {
      'Roads': [
        {'GridX': 0, 'GridY': 0, 'Img': SpeedUpTileCatalog.right},
      ],
    }),
    _object('RailcartProperties', {
      'Rails': [
        {'Column': 2, 'RowStart': 1, 'RowEnd': 3},
      ],
      'Railcarts': [
        {'Column': 2, 'Row': 2},
      ],
    }),
    _object('RoofProperties', {
      'FlowerPotStartColumn': 4,
      'FlowerPotEndColumn': 4,
    }),
  ],
);

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

  test(
    'initial layout is a conditional editor option and keeps an immutable copy',
    () {
      final level = _level();
      final original = jsonEncode(level.toJson());
      expect(
        previewPresentModuleObjClasses(level).first,
        previewInitialLawnOverviewOption,
      );
      expect(
        ModuleRegistry.registry.containsKey(previewInitialLawnOverviewOption),
        isFalse,
      );
      expect(
        previewPresentModuleObjClasses(
          PvzLevelFile(objects: [level.objects[1]]),
        ),
        isNot(contains(previewInitialLawnOverviewOption)),
      );
      final payload = previewModuleInfoBuild(
        levelFile: level,
        objClass: previewInitialLawnOverviewOption,
        t: (key, fallback, [args]) => fallback,
      );
      expect(payload.isLawnGrid, isTrue);
      expect(payload.initialLawnJson, original);
      expect((payload.lawnRows, payload.lawnCols), (5, 9));
      final layer = PreviewLayer(
        id: 'layout',
        kind: PreviewLayerKind.iconGrid,
        bounds: const Rect.fromLTWH(.1, .1, .6, .8),
        initialLawnJson: payload.initialLawnJson,
        sections: payload.sections,
        lawnRows: payload.lawnRows,
        lawnCols: payload.lawnCols,
      );
      final document = PreviewDocument(
        banner: PreviewBannerRef(kind: PreviewBannerSourceKind.assetStem),
        layers: [layer],
      );
      final snapshot = PreviewDocumentSnapshot.capture(document);
      final copied = document.copy();
      expect(copied.layers.single.initialLawnJson, original);
      expect(snapshot.matches(copied), isTrue);
      layer.initialLawnJson = '{}';
      expect(snapshot.matches(document), isFalse);
      expect(copied.layers.single.initialLawnJson, original);
      expect(
        previewIconGridIntrinsicSize(
          maxWidth: 400,
          sections: payload.sections,
          lawnRows: 5,
          lawnCols: 9,
          hasInitialLawn: true,
        ).height,
        greaterThan(200),
      );
    },
  );

  testWidgets(
    'generator paints the shared initial layout including carts, rails and arrows',
    (tester) async {
      final level = _level();
      final payload = previewModuleInfoBuild(
        levelFile: level,
        objClass: previewInitialLawnOverviewOption,
        t: (key, fallback, [args]) => fallback,
      );
      final document = PreviewDocument(
        banner: PreviewBannerRef(kind: PreviewBannerSourceKind.assetStem),
        layers: [
          PreviewLayer(
            id: 'layout',
            kind: PreviewLayerKind.iconGrid,
            bounds: const Rect.fromLTWH(.1, .1, .6, .8),
            initialLawnJson: payload.initialLawnJson,
            sections: payload.sections,
            lawnRows: payload.lawnRows,
            lawnCols: payload.lawnCols,
          ),
        ],
      );
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PreviewCanvas(document: document, boundaryKey: boundaryKey),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LawnGrid), findsOneWidget);
      final paths = tester
          .widgetList<AssetImageWidget>(
            find.descendant(
              of: find.byType(LawnGrid),
              matching: find.byType(AssetImageWidget),
            ),
          )
          .map((image) => image.assetPath);
      expect(
        paths,
        containsAll([
          'assets/images/others/railcarts.webp',
          'assets/images/others/rails.webp',
          'assets/images/tunnels/speed_up_tile_right.webp',
        ]),
      );
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        try {
          expect(image.width, kPreviewCanvasSize.width.round());
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          expect(bytes!.lengthInBytes, greaterThan(1000));
        } finally {
          image.dispose();
        }
      });
    },
  );

  test('Moon Grapple resolves to the supplied banner asset', () async {
    final resolver = await StageBannerResolver.load();
    expect(
      resolver.resolveAssetPath('MoonGrappleStage'),
      '${StageBannerResolver.flutterAssetsRoot}/banners/MoonGrapple.png',
    );
  });
}
