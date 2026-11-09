import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_sticker_catalog.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeRoot = 'lib/bundled_plugins/preview_img_cplugin/assets/l10n';

Map<String, dynamic> _messages(String locale) =>
    jsonDecode(File('$_localeRoot/$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

PreviewModuleL10n _localizer(String locale) {
  final messages = _messages(locale);
  return (key, fallback, [args]) {
    expect(messages, contains(key), reason: '$locale: $key');
    var text = messages[key] as String;
    for (final entry in (args ?? const <String, Object?>{}).entries) {
      text = text.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return text;
  };
}

PvzLevelFile _level() => PvzLevelFile(
  objects: [
    PvzObject(
      objClass: 'InitialGridItemProperties',
      objData: {
        'InitialGridItemPlacements': [
          {'TypeName': 'gravestone', 'GridX': 0, 'GridY': 0},
        ],
      },
    ),
    PvzObject(
      objClass: 'SpeedUpTileModuleProperties',
      objData: {
        'Roads': [
          for (var i = 0; i < SpeedUpTileCatalog.directions.length; i++)
            {
              'GridX': i == 3 ? 8 : i,
              'GridY': i == 3 ? 4 : 0,
              'Img': SpeedUpTileCatalog.directions[i],
            },
          {'GridX': 12, 'GridY': 6, 'Img': 'custom_imported_direction'},
        ],
        'ImportedExtra': 42,
      },
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<PreviewSticker> stickers;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    stickers = await loadPreviewStickerCatalog();
  });

  for (final locale in ['zh', 'en', 'ru']) {
    test(
      '$locale speed-up module info is localized and preserves lawn cells',
      () {
        final level = _level();
        final original = jsonEncode(level.toJson());
        final t = _localizer(locale);
        final payload = previewModuleInfoBuild(
          levelFile: level,
          objClass: 'SpeedUpTileModuleProperties',
          t: t,
        );
        expect(payload.isLawnGrid, isTrue);
        expect((payload.lawnCols, payload.lawnRows), (9, 5));
        expect(
          payload.lines.first,
          t('previewGenSpeedUpTileCount', '', {'count': 5}),
        );
        final items = payload.sections.single.items;
        expect(items, hasLength(5));
        for (var i = 0; i < 4; i++) {
          expect(
            items[i].assetPath,
            SpeedUpTileCatalog.assetForImage(SpeedUpTileCatalog.directions[i]),
          );
          expect(
            (items[i].gridX, items[i].gridY),
            (i == 3 ? 8 : i, i == 3 ? 4 : 0),
          );
          expect(items[i].label, isNot(contains('IMAGE_UI')));
          expect(payload.lines[i + 1], contains(items[i].label!));
        }
        expect(items.last.assetPath, 'assets/images/others/unknown.webp');
        expect((items.last.gridX, items.last.gridY), (12, 6));
        expect(items.last.label, t('previewStickerNameUnknown', ''));
        expect(payload.textBody, isNot(contains('custom_imported_direction')));
        expect(jsonEncode(level.toJson()), original);
      },
    );
  }

  test(
    'speed-up module is not hidden by other structured module summaries',
    () {
      expect(
        previewPresentModuleObjClasses(_level()),
        containsAll([
          'InitialGridItemProperties',
          'SpeedUpTileModuleProperties',
        ]),
      );
      final common = previewModuleInfoBuild(
        levelFile: _level(),
        objClass: 'InitialGridItemProperties',
        t: _localizer('zh'),
      );
      expect(common.sections.single.items, hasLength(1));
      expect(
        common.sections.single.items.single.assetPath,
        isNot(contains('speed_up_tile')),
      );
    },
  );

  test(
    'speed-up directional stickers are named components and level resources',
    () {
      final directional = stickers
          .where((sticker) => sticker.assetPath.contains('/speed_up_tile_'))
          .toList();
      expect(
        directional.map((sticker) => sticker.assetPath),
        SpeedUpTileCatalog.directions.map(SpeedUpTileCatalog.assetForImage),
      );
      for (final sticker in directional) {
        expect(sticker.tag, 'components');
        expect(sticker.searchTerms, isNotEmpty);
        for (final locale in ['zh', 'en', 'ru']) {
          final name = _messages(locale)[sticker.labelKey];
          expect(name, isNotEmpty);
          expect(name, isNot(sticker.assetPath.split('/').last));
        }
      }
      final level = _level();
      expect(
        previewCurrentLevelStickerAssetPaths(
          stickers: stickers,
          levelFile: level,
          parsed: LevelParser.parseLevel(level),
        ),
        containsAll(directional.map((sticker) => sticker.assetPath)),
      );
    },
  );

  testWidgets('scene feature labels use the localized module title', (
    tester,
  ) async {
    final groups = await PreviewFeatureGroups.load();
    for (final locale in ['zh', 'en', 'ru']) {
      late BuildContext appContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              appContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final title = AppLocalizations.of(
        appContext,
      )!.moduleTitle_SpeedUpTileModuleProperties;
      expect(
        groups.featureLabels(
          ['SpeedUpTileModuleProperties'],
          moduleTitle: (objClass) =>
              ModuleRegistry.getMetadata(objClass).getTitle(appContext),
        ),
        [title],
      );
    }
  });
}
