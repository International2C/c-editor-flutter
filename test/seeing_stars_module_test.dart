import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/pvz1_seeing_stars_module_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _starsClass = 'PVZ1SeeingStarsModuleProperties';

PvzLevelFile seeingStarsLevel({
  int cycleIndex = 2,
  String? otherModule,
  bool wireOther = true,
}) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        modules: [
          'RTID(Stars@CurrentLevel)',
          if (otherModule != null && wireOther) 'RTID(Other@CurrentLevel)',
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: ['Stars'],
      objClass: _starsClass,
      objData: PVZ1SeeingStarsModulePropertiesData(
        cycleIndex: cycleIndex,
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
    ),
    if (otherModule != null)
      PvzObject(
        aliases: ['Other'],
        objClass: otherModule,
        objData: <String, dynamic>{},
      ),
  ],
);

Widget _app(Widget home, {String locale = 'en', double scale = 1}) =>
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: home,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ReferenceRepository.init();
    await PlantRepository().init();
  });

  test(
    'compatibility warning only applies to two active incompatible modules',
    () {
      final rule = LevelIssueRegistry.rules.singleWhere(
        (rule) => rule.id == 'seeingStarsCompatibilityWarning',
      );
      for (final module in [
        null,
        'WaveGeneratorProperties',
        'WaveManagerModuleProperties',
      ]) {
        final level = seeingStarsLevel(otherModule: module);
        expect(
          rule.isActive!(LevelIssueContext.fromLevel(level)),
          module == 'WaveGeneratorProperties',
        );
      }
      expect(
        rule.isActive!(
          LevelIssueContext.fromLevel(
            seeingStarsLevel(
              otherModule: 'WaveGeneratorProperties',
              wireOther: false,
            ),
          ),
        ),
        isFalse,
      );
    },
  );

  for (final locale in ['zh', 'en', 'ru']) {
    test(
      'Seeing Stars $locale translations have separate tips and target-plant keys',
      () {
        final copy =
            jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
                as Map;
        expect(copy.containsKey('seeingStarsPatternCells'), isFalse);
        final l10n = lookupAppLocalizations(Locale(locale));
        expect(l10n.seeingStarsMatchPlants, isNotEmpty);
        expect(
          l10n.pvz1SeeingStarsHelpTipsTitle,
          isNot(l10n.seeingStarsWinConWarningTitle),
        );
        expect(l10n.pvz1SeeingStarsHelpWinCon, contains('\n'));
        expect(l10n.seeingStarsCycleWaveInfo(6), contains('6'));
        expect(
          l10n.waveGeneratorModuleHelpIncompatBody,
          contains(
            locale == 'ru'
                ? '«Звёздным узором»'
                : l10n.pvz1SeeingStarsModuleTitle,
          ),
        );
      },
    );

    testWidgets(
      'Seeing Stars editor has responsive detailed labels and distinct help in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final l10n = lookupAppLocalizations(Locale(locale));
        final level = seeingStarsLevel(otherModule: 'WaveGeneratorProperties');
        await tester.pumpWidget(
          _app(
            PVZ1SeeingStarsModuleScreen(
              rtid: 'RTID(Stars@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            ),
            locale: locale,
            scale: 1.6,
          ),
        );
        await tester.pumpAndSettle();
        // Only the list heading remains; the heading above Selected position is gone.
        expect(
          find.text(l10n.pvz1SeeingStarsSectionMatchPlants),
          findsOneWidget,
        );
        final fields = tester.widgetList<EditorResponsiveInputField>(
          find.byType(EditorResponsiveInputField),
        );
        expect(
          fields.map((field) => field.label),
          containsAll([
            l10n.seeingStarsCycleWaveLabel,
            l10n.seeingStarsSettlementLabel,
          ]),
        );
        expect(
          find.byKey(const ValueKey('seeingStarsCompatibilityWarning')),
          findsOneWidget,
        );
        final cycleInput = find.byKey(
          const ValueKey('seeingStarsCycleIndexInput'),
        );
        await tester.ensureVisible(cycleInput);
        await tester.enterText(cycleInput, '5');
        await tester.pumpAndSettle();
        expect((level.objects[1].objData as Map)['CycleIndex'], 5);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('seeingStarsHelpButton')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining(l10n.pvz1SeeingStarsHelpTipsTitle),
          findsOneWidget,
        );
        expect(find.text(l10n.pvz1SeeingStarsHelpWinCon), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Wave Generator also shows the active Seeing Stars compatibility warning',
    (tester) async {
      await tester.pumpWidget(
        _app(
          WaveGeneratorModuleScreen(
            rtid: 'RTID(Other@CurrentLevel)',
            levelFile: seeingStarsLevel(otherModule: 'WaveGeneratorProperties'),
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('seeingStarsCompatibilityWarning')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final cycle in [0, 2, -1, 4]) {
    testWidgets('timeline marks the actual loop start for CycleIndex=$cycle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final level = seeingStarsLevel(cycleIndex: cycle);
      String? opened;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: WaveTimelineTab(
              levelFile: level,
              parsed: ParsedLevelData(
                waveManager: WaveManagerData(
                  waveCount: 4,
                  waves: [[], [], [], []],
                ),
                objectMap: {'Stars': level.objects[1]},
              ),
              onChanged: () {},
              onEditEvent: (_, _) async {},
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
              onOpenModule: (rtid, {hint}) => opened = rtid,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = lookupAppLocalizations(const Locale('en'));
      if (cycle < 0 || cycle >= 4) {
        expect(find.text(l10n.seeingStarsCycleWaveBadge), findsNothing);
        return;
      }
      final badge = find.byKey(
        ValueKey('waveTimelineExpectation-${cycle + 1}-0'),
      );
      await tester.scrollUntilVisible(badge, 300);
      expect(
        find.descendant(
          of: badge,
          matching: find.text(l10n.seeingStarsCycleWaveBadge),
        ),
        findsOneWidget,
      );
      await tester.tap(badge);
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.seeingStarsCycleWaveInfo(cycle + 1)),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.openModuleSettings));
      await tester.pumpAndSettle();
      expect(opened, 'RTID(Stars@CurrentLevel)');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'overview exposes the Seeing Stars lawn directly and selects an available tab',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final level = seeingStarsLevel();
      await tester.pumpWidget(
        _app(
          LevelOverviewDialog(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            fileName: 'seeing-stars.json',
            onClose: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final grid = find.byKey(const ValueKey('overviewSeeingStarsGrid'));
      expect(grid, findsOneWidget);
      await tester.ensureVisible(grid);
      await tester.pumpAndSettle();
      final lawnFinder = find.descendant(
        of: grid,
        matching: find.byType(LawnGrid),
      );
      expect(lawnFinder, findsOneWidget);
      final lawn = tester.widget<LawnGrid>(lawnFinder);
      expect((lawn.rows, lawn.cols), (5, 9));
      expect(
        find.descendant(of: grid, matching: find.byType(AssetImageWidget)),
        findsNWidgets(2),
      );
      // Both the module card and the main grid are visible without switching tabs.
      expect(find.byType(LawnGrid), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'generator preserves target-cell placement and displays one-based loop waves',
    () {
      for (final cycle in [0, 5]) {
        final level = seeingStarsLevel(cycleIndex: cycle);
        final original = jsonEncode(level.objects[1].objData);
        expect(previewPresentModuleObjClasses(level), contains(_starsClass));
        final payload = previewModuleInfoBuild(
          levelFile: level,
          objClass: _starsClass,
          t: (key, fallback, [args]) {
            var text = fallback;
            for (final entry in (args ?? <String, Object?>{}).entries) {
              text = text.replaceAll('{${entry.key}}', '${entry.value}');
            }
            return text;
          },
        );
        expect(payload.isLawnGrid, isTrue);
        expect((payload.lawnRows, payload.lawnCols), (5, 9));
        expect(
          payload.gridNotes,
          contains('Waves loop back to wave ${cycle + 1}'),
        );
        expect(
          payload.sections.single.items.map((item) => (item.gridX, item.gridY)),
          [(0, 1), (7, 1)],
        );
        expect(jsonEncode(level.objects[1].objData), original);
      }
    },
  );
}
