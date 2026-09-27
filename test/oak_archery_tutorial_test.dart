import 'dart:convert';

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/oak_train_warnings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The alias, class and empty data match DARK15's local tutorial definition.
const _tutorialJson = <String, dynamic>{
  'aliases': ['OakTrainTutorial'],
  'objclass': 'OakTrainIntroProperties',
  'objdata': <String, dynamic>{},
};

PvzLevelFile _level({
  bool tutorial = true,
  bool intro = true,
  bool localIntro = false,
}) => PvzLevelFile(
  objects: [
    PvzObject(
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: 'RTID(DarkStage@LevelModules)',
        modules: [
          if (tutorial) 'RTID(OakTrainTutorial@CurrentLevel)',
          if (intro)
            localIntro
                ? 'RTID(CustomIntro@CurrentLevel)'
                : 'RTID(StandardIntro@LevelModules)',
        ],
      ).toJson(),
    ),
    PvzObject.fromJson(_tutorialJson),
    if (localIntro)
      PvzObject(
        aliases: ['CustomIntro'],
        objClass: 'StandardLevelIntroProperties',
        objData: <String, dynamic>{},
      ),
  ],
);

Widget _app(String language, Widget child) => MaterialApp(
  locale: Locale(language),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ReferenceRepository.init);

  for (final language in ['zh', 'en', 'ru']) {
    final l10n = lookupAppLocalizations(Locale(language));

    testWidgets(
      '$language: selecting the tutorial yields DARK15 local object data',
      (tester) async {
        ModuleSelectionResult? selection;
        await tester.pumpWidget(
          _app(
            language,
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    selection = await Navigator.of(context)
                        .push<ModuleSelectionResult>(
                          MaterialPageRoute(
                            builder: (_) => ModuleSelectionScreen(
                              existingObjClasses: const {'OakTrainProperties'},
                              stateBucketId: 'tutorial-$language',
                            ),
                          ),
                        );
                  },
                  child: const Text('Select'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          'OakTrainIntroProperties',
        );
        await tester.pumpAndSettle();
        expect(
          find.text(l10n.moduleTitle_OakTrainIntroProperties),
          findsOneWidget,
        );
        expect(
          find.text(l10n.moduleDesc_OakTrainIntroProperties),
          findsOneWidget,
        );
        await tester.tap(find.text(l10n.moduleTitle_OakTrainIntroProperties));
        await tester.pumpAndSettle();
        final metadata = selection!.metadata;
        expect(metadata.defaultSource, 'CurrentLevel');
        expect(metadata.initialData, isEmpty);
        final reference =
            'RTID(${metadata.effectiveAlias}@${metadata.defaultSource})';
        expect(reference, 'RTID(OakTrainTutorial@CurrentLevel)');
        final object = PvzObject(
          aliases: [metadata.effectiveAlias],
          objClass: metadata.objClass,
          objData: metadata.initialData!,
        );
        expect(object.toJson(), _tutorialJson);
        expect(
          PvzObject.fromJson(jsonDecode(jsonEncode(object.toJson()))).toJson(),
          _tutorialJson,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$language: tutorial/intro conflict is a warning only for active pairs',
      (tester) async {
        await tester.pumpWidget(
          _app(
            language,
            Builder(
              builder: (context) {
                for (final tutorial in [false, true]) {
                  for (final intro in [false, true]) {
                    for (final localIntro in [false, true]) {
                      final level = _level(
                        tutorial: tutorial,
                        intro: intro,
                        localIntro: localIntro,
                      );
                      final before = jsonEncode(level.toJson());
                      final missing = LevelIssueRegistry.forLevel(
                        context,
                        level,
                      ).singleWhere((issue) => issue.id == 'missingEssentials');
                      expect(
                        missing.bulletPoints.contains(
                          l10n.moduleTitle_StandardLevelIntroProperties,
                        ),
                        !tutorial && !intro,
                        reason:
                            'An active tutorial replaces the standard intro; an unlinked tutorial does not.',
                      );
                      final issues = LevelIssueRegistry.forLevel(context, level)
                          .where(
                            (issue) =>
                                issue.id == 'oakTrainTutorialIntroWarning',
                          )
                          .toList();
                      expect(issues.length, tutorial && intro ? 1 : 0);
                      if (issues.isNotEmpty) {
                        expect(
                          issues.single.severity,
                          LevelIssueSeverity.warning,
                        );
                        expect(
                          issues.single.message,
                          l10n.oakTrainTutorialIntroWarning,
                        );
                        expect(
                          issues.single.title,
                          l10n.oakTrainTutorialIntroWarningTitle,
                        );
                        final validation =
                            LevelValidator.validate(context, level).where(
                              (issue) =>
                                  issue.message ==
                                  l10n.oakTrainTutorialIntroWarning,
                            );
                        expect(validation.single.isError, isFalse);
                      }
                      expect(jsonEncode(level.toJson()), before);
                    }
                  }
                }
                return const SizedBox();
              },
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$language: settings and Oak editor use the yellow banner', (
      tester,
    ) async {
      final level = _level();
      final parsed = LevelParser.parseLevel(level);
      await tester.pumpWidget(
        _app(
          language,
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
      final warningFinder = find.byKey(
        const ValueKey('oakTrainTutorialIntroWarning'),
      );
      await tester.scrollUntilVisible(
        warningFinder,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      final banner = tester.widget<EditorWarningBanner>(warningFinder);
      expect(banner.message, l10n.oakTrainTutorialIntroWarning);
      await tester.pumpWidget(
        _app(language, Scaffold(body: OakTrainWarnings(levelFile: level))),
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(
          EditorWarningBanner,
          l10n.oakTrainTutorialIntroWarning,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
