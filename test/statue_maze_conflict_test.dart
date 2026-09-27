import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _maze = 'StatueMazeModuleProperties';

PvzLevelFile _level(
  Set<String> active, {
  Set<String> inactive = const {},
  List<StatueSetInfo>? rounds,
}) => PvzLevelFile(
  objects: [
    PvzObject(
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        modules: [for (final cls in active) 'RTID($cls@CurrentLevel)'],
      ).toJson(),
    ),
    for (final cls in {...active, ...inactive})
      PvzObject(
        aliases: [cls],
        objClass: cls,
        objData: cls == _maze
            ? StatueMazeModulePropertiesData(setInfos: rounds).toJson()
            : <String, dynamic>{},
      ),
  ],
);

Widget _app(Widget home, {String language = 'zh'}) => MaterialApp(
  locale: Locale(language),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

Future<BuildContext> _context(
  WidgetTester tester, {
  String language = 'zh',
}) async {
  late BuildContext result;
  await tester.pumpWidget(
    _app(
      Builder(
        builder: (context) {
          result = context;
          return const SizedBox();
        },
      ),
      language: language,
    ),
  );
  return result;
}

List<LevelIssue> _mazeIssues(BuildContext context, PvzLevelFile level) =>
    LevelIssueRegistry.forLevel(context, level)
        .where((issue) => issue.id.startsWith('statueMazeMissingRotations_'))
        .toList();

void main() {
  for (final language in ['zh', 'en', 'ru']) {
    testWidgets('$language: finds empty rotation lists in every active round', (
      tester,
    ) async {
      final context = await _context(tester, language: language);
      final l10n = AppLocalizations.of(context)!;
      final rounds = [
        StatueSetInfo(),
        StatueSetInfo(matrixInfos: [StatueMatrixInfo()]),
        StatueSetInfo(),
      ];
      final level = _level({
        _maze,
        'SeedBankProperties',
        'WaveGeneratorProperties',
      }, rounds: rounds);
      final expected = l10n.statueMazeMissingRotationsWarning('1, 3');
      expect(_mazeIssues(context, level).single.message, expected);
      expect(_mazeIssues(context, level).single.isError, isTrue);
      expect(
        LevelValidator.validate(
          context,
          level,
        ).where((issue) => issue.message == expected),
        hasLength(1),
      );
      final module = level.objects.firstWhere((o) => o.objClass == _maze);
      for (final round in rounds) {
        round.matrixInfos = [StatueMatrixInfo()];
      }
      module.objData = StatueMazeModulePropertiesData(
        setInfos: rounds,
      ).toJson();
      expect(_mazeIssues(context, level), isEmpty);
      expect(
        LevelIssueRegistry.forLevel(
          context,
          level,
        ).where((i) => i.id.startsWith('statueMazeIncompatible')),
        isEmpty,
      );
    });
  }

  testWidgets(
    'missing or empty round data is checked, unused objects are ignored',
    (tester) async {
      final context = await _context(tester);
      for (final data in [
        {},
        {'SetInfos': []},
        {
          'SetInfos': [{}],
        },
        {
          'SetInfos': [
            {'MatrixInfos': []},
          ],
        },
      ]) {
        final level = _level({_maze});
        level.objects.last.objData = data;
        expect(_mazeIssues(context, level), hasLength(1));
      }
      expect(
        _mazeIssues(context, _level({'SeedBankProperties'}, inactive: {_maze})),
        isEmpty,
      );
    },
  );

  for (final companion in [
    'ZombiesDeadWinConProperties',
    'BronzeDeadWinConProperties',
    'ZombieRushModuleProperties',
    _maze,
  ]) {
    testWidgets('Seeing Stars detects active $companion only', (tester) async {
      final context = await _context(tester);
      List<LevelIssue> issues(PvzLevelFile level) =>
          LevelIssueRegistry.forLevel(
            context,
            level,
          ).where((i) => i.id == 'seeingStarsWinConWarning').toList();
      expect(
        issues(_level({'PVZ1SeeingStarsModuleProperties', companion})),
        hasLength(1),
      );
      expect(
        issues(
          _level({'PVZ1SeeingStarsModuleProperties'}, inactive: {companion}),
        ),
        isEmpty,
      );
    });
  }

  for (final module in [_maze, 'CamelMinigameProperties']) {
    testWidgets('level settings displays the $module warning', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final parsed = LevelParser.parseLevel(
        _level({module, 'SeedBankProperties'}),
      );
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: LevelSettingsTab(
              levelDef: parsed.levelDef,
              objectMap: parsed.objectMap,
              onEditBasicInfo: () {},
              onEditModule: (_) {},
              onRemoveModule: (_) {},
              onReorderModules:
                  ({
                    required isCoreSection,
                    required oldIndex,
                    required newIndex,
                  }) {},
              onNavigateToAddModule: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = lookupAppLocalizations(const Locale('zh'));
      expect(
        find.text(
          module == _maze
              ? l10n.statueMazeMissingRotationsWarning('1')
              : l10n.conflictDesc_CamelMinigameChooser,
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.camelCompatibilityWarning), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
