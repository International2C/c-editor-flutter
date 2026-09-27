import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Host extends Fake implements CPluginHost {
  _Host(this.copy);
  final Map<String, dynamic> copy;

  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) {
    var text = copy[key] as String? ?? fallback ?? key;
    for (final entry in (args ?? <String, Object?>{}).entries) {
      text = text.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return text;
  }
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(finder, findsOneWidget);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      'Seeing Stars lawn can be added to generator with real $locale text',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        rootBundle.clear();
        tester.view.physicalSize = const Size(1500, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final copy =
            jsonDecode(
                  File(
                    'lib/bundled_plugins/preview_img_cplugin/assets/l10n/$locale.arb',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        final stars = PvzObject(
          aliases: ['Stars'],
          objClass: 'PVZ1SeeingStarsModuleProperties',
          objData: PVZ1SeeingStarsModulePropertiesData(
            cycleIndex: 5,
            matchPlants: [
              SeeingStarsMatchPlantData(
                gridX: 0,
                gridY: 1,
                matchTypeName: 'sunflower',
              ),
              SeeingStarsMatchPlantData(
                gridX: 7,
                gridY: 1,
                matchTypeName: 'sunflower',
              ),
            ],
          ).toJson(),
        );
        final level = PvzLevelFile(objects: [stars]);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PreviewGeneratorScreen(
              host: _Host(copy),
              levelFile: level,
              parsed: LevelParser.parseLevel(level),
              fileName: 'seeing-stars.json',
              initialStyle: PreviewAutoStyle.normal,
            ),
          ),
        );
        await _waitFor(tester, find.byType(PreviewCanvas));
        await _tap(
          tester,
          find.byKey(
            const ValueKey('previewToolbarAction-previewGenModuleInfo'),
          ),
        );
        await _tap(
          tester,
          find.byKey(
            const ValueKey('previewModuleInfo-PVZ1SeeingStarsModuleProperties'),
          ),
        );
        await _waitFor(
          tester,
          find.text(copy['previewGenModuleInfoGrid'] as String),
        );
        await _tap(
          tester,
          find.text(copy['previewGenModuleInfoGrid'] as String),
        );
        final document = tester
            .widget<PreviewCanvas>(find.byType(PreviewCanvas))
            .document;
        final layer = document.layers.singleWhere(
          (layer) => layer.lawnRows != null,
        );
        expect((layer.lawnRows, layer.lawnCols), (5, 9));
        expect(layer.items.map((item) => (item.gridX, item.gridY)), [
          (0, 1),
          (7, 1),
        ]);
        expect(
          layer.sourceLabel,
          contains(
            (copy['previewGenSeeingStarsCycle'] as String).replaceAll(
              '{wave}',
              '6',
            ),
          ),
        );
        final lawn = find.byType(LawnGrid);
        expect(lawn, findsOneWidget);
        final icons = find.descendant(
          of: lawn,
          matching: find.byType(AssetImageWidget),
        );
        expect(icons, findsNWidgets(2));
        expect(
          tester.getCenter(icons.first).dy,
          closeTo(tester.getCenter(icons.last).dy, 0.1),
        );
        expect(
          tester.getCenter(icons.first).dx,
          lessThan(tester.getCenter(icons.last).dx),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
