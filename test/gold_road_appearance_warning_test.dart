import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _appearanceWarning = 'goldRoadNonLostCityLawnWarning';
const _deepseaWarning = 'goldRoadDeepseaLawnWarning';
const _lostCity = 'IMAGE_BACKGROUNDS_LOSTCITY';
const _egypt = 'IMAGE_BACKGROUNDS_EGYPT';
const _deepsea = 'IMAGE_BACKGROUNDS_DEEPSEA';
const _deepseaLand = 'IMAGE_BACKGROUNDS_DEEPSEALAND';

PvzLevelFile _level({
  String stage = 'RTID(LostCityStage@LevelModules)',
  String? customClass,
  Map<String, dynamic>? appearance,
  bool stockModule = true,
}) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: customClass == null
            ? stage
            : 'RTID(LostCityCustomStage@CurrentLevel)',
        modules: [
          stockModule
              ? 'RTID(DefaultGoldRoad@LevelModules)'
              : 'RTID(CustomGoldRoad@CurrentLevel)',
        ],
      ).toJson(),
    ),
    if (customClass != null)
      PvzObject(
        aliases: ['LostCityCustomStage'],
        objClass: customClass,
        objData: {
          'BelongsToWorld': 'lostcity',
          'ResourceGroupNames': [
            'DelayLoad_Background_LostCity_Compressed',
            'DelayLoad_Background_Deepsea',
          ],
          ...?appearance,
        },
      ),
    if (!stockModule)
      PvzObject(
        aliases: ['CustomGoldRoad'],
        objClass: 'GoldRoadProperties',
        objData: <String, dynamic>{},
      ),
  ],
);

List<LevelIssue> _warnings(BuildContext context, PvzLevelFile level) =>
    LevelIssueRegistry.forLevel(
      context,
      level,
      editorOnly: true,
    ).where((issue) => issue.id.startsWith('goldRoad')).toList();

Widget _app(Locale locale, WidgetBuilder builder) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(builder: builder),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ReferenceRepository.init);

  test('obsolete custom Lost City warning is removed from all locales', () {
    for (final locale in ['zh', 'en', 'ru']) {
      final arb =
          jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      expect(arb, isNot(contains('goldRoadCustomLostCityLawnWarningTitle')));
      expect(arb, isNot(contains('goldRoadCustomLostCityLawnWarning')));
    }
  });

  for (final language in ['zh', 'en', 'ru']) {
    final locale = Locale(language);
    testWidgets('$language: stock appearances select localized warnings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(locale, (context) {
          final l10n = AppLocalizations.of(context)!;
          for (final (alias, expected) in [
            ('LostCityStage', <String>[]),
            ('EgyptStage', [_appearanceWarning]),
            ('DeepseaStage', [_appearanceWarning, _deepseaWarning]),
            ('DeepseaLandStage', [_appearanceWarning, _deepseaWarning]),
          ]) {
            final level = _level(stage: 'RTID($alias@LevelModules)');
            final original = jsonEncode(level.toJson());
            final warnings = _warnings(context, level);
            expect(warnings.map((issue) => issue.id), expected, reason: alias);
            for (final warning in warnings) {
              expect(warning.isError, isFalse);
              final deepsea = warning.id == _deepseaWarning;
              expect(
                warning.title,
                deepsea
                    ? l10n.goldRoadDeepseaLawnWarningTitle
                    : l10n.goldRoadNonLostCityLawnWarningTitle,
              );
              expect(
                warning.message,
                deepsea
                    ? l10n.goldRoadDeepseaLawnWarning
                    : l10n.goldRoadNonLostCityLawnWarning,
              );
              expect(
                LevelValidator.validate(context, level).any(
                  (issue) => issue.message == warning.message && !issue.isError,
                ),
                isTrue,
              );
            }
            expect(jsonEncode(level.toJson()), original);
          }
          return const SizedBox.shrink();
        }),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$language: appearance overrides base, alias, world and resources',
      (tester) async {
        await tester.pumpWidget(
          _app(locale, (context) {
            for (final objClass in [
              'EgyptStageProperties',
              'LostCityStageProperties',
              'DeepseaStageProperties',
              'DeepseaStageLandProperties',
            ]) {
              final level = _level(customClass: objClass, stockModule: false);
              final stageData =
                  level.objects[1].objData as Map<String, dynamic>;
              for (final (prefix, group, expected) in [
                (_lostCity, 'DelayLoad_Background_Deepsea', <String>[]),
                (
                  _egypt,
                  'DelayLoad_Background_LostCity_Compressed',
                  [_appearanceWarning],
                ),
                (
                  _deepsea,
                  'DelayLoad_Background_LostCity_Compressed',
                  [_appearanceWarning, _deepseaWarning],
                ),
                (
                  _deepseaLand,
                  'DelayLoad_Background_LostCity_Compressed',
                  [_appearanceWarning, _deepseaWarning],
                ),
                (_lostCity, 'DelayLoad_Background_Deepsea', <String>[]),
              ]) {
                stageData['BackgroundImagePrefix'] = prefix;
                stageData['BackgroundResourceGroup'] = group;
                expect(
                  _warnings(context, level).map((issue) => issue.id),
                  expected,
                  reason: '$objClass: $prefix',
                );
              }
              // When no image prefix is supplied, use the selected background group.
              stageData.remove('BackgroundImagePrefix');
              stageData['BackgroundResourceGroup'] =
                  'DelayLoad_Background_LostCity_Compressed';
              expect(_warnings(context, level), isEmpty);
              stageData['BackgroundResourceGroup'] =
                  'DelayLoad_Background_Deepsea';
              expect(_warnings(context, level).map((issue) => issue.id), [
                _appearanceWarning,
                _deepseaWarning,
              ]);
            }
            return const SizedBox.shrink();
          }),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$language: warnings require an active Gold Road module', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(locale, (context) {
          for (final stock in [true, false]) {
            final level = _level(
              stage: 'RTID(DeepseaStage@LevelModules)',
              stockModule: stock,
            );
            expect(_warnings(context, level), hasLength(2));
            level.objects.first.objData['Modules'] = <String>[];
            expect(_warnings(context, level), isEmpty);
          }
          expect(
            _warnings(context, _level(stage: 'RTID(Missing@CurrentLevel)')),
            isEmpty,
          );
          return const SizedBox.shrink();
        }),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'settings banners clear after switching to Lost City appearance',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final level = _level(
        customClass: 'DeepseaStageProperties',
        appearance: {'BackgroundImagePrefix': _deepsea},
      );
      Widget app() => _app(const Locale('zh'), (context) {
        final parsed = LevelParser.parseLevel(level);
        return Scaffold(
          body: LevelSettingsTab(
            levelDef: parsed.levelDef,
            objectMap: parsed.objectMap,
            issues: _warnings(context, level),
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
        );
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      for (final id in [_appearanceWarning, _deepseaWarning]) {
        final banner = find.byKey(ValueKey(id));
        await tester.scrollUntilVisible(
          banner,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.widget(banner), isA<EditorWarningBanner>());
      }
      expect(tester.takeException(), isNull);
      level.objects[1].objData['BackgroundImagePrefix'] = _lostCity;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(_appearanceWarning)), findsNothing);
      expect(find.byKey(const ValueKey(_deepseaWarning)), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
