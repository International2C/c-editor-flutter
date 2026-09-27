import 'dart:convert';

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/gladiator_row_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child, {String locale = 'en', double scale = 1}) =>
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
      home: Scaffold(body: child),
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
    ]);
  });

  testWidgets(
    'overview switches arena, trophy and zombie positions by encounter',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final module = PvzObject(
        aliases: ['Gladiator'],
        objClass: 'GladiatorRowModuleProperties',
        objData: {
          'GameplayVersion': 1,
          'Encounters': [
            {
              'Wave': 0,
              'Row': 1,
              'Spawns': [
                {'GridX': 6, 'ZombieType': 'tutorial', 'Count': 2},
              ],
            },
            {
              'Wave': 4,
              'Row': 3,
              'Spawns': [
                {'GridX': 5, 'ZombieType': 'tutorial', 'Count': 1},
              ],
            },
            // Duplicate waves must remain independently selectable.
            {'Wave': 4, 'Row': 4, 'Spawns': []},
          ],
        },
      );
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            objClass: 'LevelDefinition',
            aliases: ['LevelDefinition'],
            objData: LevelDefinitionData(
              modules: ['RTID(Gladiator@CurrentLevel)'],
            ).toJson(),
          ),
          module,
        ],
      );
      final original = jsonEncode(level.toJson());
      await tester.pumpWidget(
        _app(
          LevelOverviewDialog(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            fileName: 'Gladiator.json',
            onClose: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(LevelOverviewDialog));
      final l10n = AppLocalizations.of(context)!;
      expect(levelHasPrePlacedGridPreview(level), isTrue);
      final categories = collectGridPreviewCategories(
        context,
        level,
        l10n,
      ).where((c) => c.kind == GridPreviewModuleKind.gladiatorRow).toList();
      expect(categories.map((c) => c.key).toSet(), hasLength(3));
      expect(categories.first.label, contains(l10n.customZombieWaveItem(1)));
      expect(categories.last.label, contains(l10n.customZombieWaveItem(5)));

      Future<void> checkRow(int row, int? zombieCol) async {
        final trophy = find.byKey(ValueKey('overview-gladiator-cell-4-$row'));
        await tester.ensureVisible(trophy);
        await tester.pumpAndSettle();
        for (var col = 2; col <= 6; col++) {
          final cell = find.byKey(
            ValueKey('overview-gladiator-cell-$col-$row'),
          );
          expect(
            tester.widget<ColoredBox>(cell).color,
            (col == 4 ? Colors.green : Colors.red).withValues(alpha: 0.45),
          );
          expect(
            find.descendant(
              of: cell,
              matching: find.byType(GladiatorZombieIcon),
            ),
            col == zombieCol ? findsOneWidget : findsNothing,
          );
        }
        expect(
          find.descendant(
            of: trophy,
            matching: find.byIcon(Icons.emoji_events),
          ),
          findsOneWidget,
        );
      }

      await checkRow(1, 6);
      for (final index in [1, 2]) {
        final choice = find.text(categories[index].label);
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        await tester.tap(choice);
        await tester.pumpAndSettle();
        await checkRow(index == 1 ? 3 : 4, index == 1 ? 5 : null);
        expect(
          find.byKey(const ValueKey('overview-gladiator-cell-4-1')),
          findsNothing,
        );
      }
      expect(jsonEncode(level.toJson()), original);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets('add-event alias label wraps at large text size in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      String? result;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showPvzAliasInputDialog(
                  context,
                  defaultAlias: 'Wave2EagleFlagEvent1',
                  title: AppLocalizations.of(context)!.addEvent,
                  objClass: 'SpawnEagleFlagsWaveActionProps',
                  levelFile: PvzLevelFile(objects: []),
                );
              },
              child: const Text('Open'),
            ),
          ),
          locale: locale,
          scale: 2,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      )!;
      final label = find.text(l10n.aliasLabel);
      expect(label, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: label, matching: find.byType(RichText)),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: l10n.aliasLabel.length),
      );
      expect(boxes.map((b) => b.top).toSet().length, greaterThan(1));
      expect(boxes.last.bottom, lessThanOrEqualTo(paragraph.size.height + 0.1));
      await tester.tap(find.widgetWithText(FilledButton, l10n.add));
      await tester.pumpAndSettle();
      expect(result, 'Wave2EagleFlagEvent1');
      expect(tester.takeException(), isNull);
    });
  }
}
