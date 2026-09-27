import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('only parameter modules with editors respond to taps', (
    tester,
  ) async {
    const scoringRtid = 'RTID(LevelScoring@CurrentLevel)';
    const zombossRtid = 'RTID(ZombossBattle@CurrentLevel)';
    final edited = <String>[];
    final levelDef = LevelDefinitionData(
      modules: const [scoringRtid, zombossRtid],
    );
    final objects = <String, PvzObject>{
      'LevelScoring': PvzObject(
        aliases: ['LevelScoring'],
        objClass: 'LevelScoringModuleProperties',
        objData: <String, dynamic>{},
      ),
      'ZombossBattle': PvzObject(
        aliases: ['ZombossBattle'],
        objClass: 'ZombossBattleModuleProperties',
        objData: <String, dynamic>{},
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LevelSettingsTab(
            levelDef: levelDef,
            objectMap: objects,
            onEditBasicInfo: () {},
            onEditModule: edited.add,
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
    await tester.pump();

    await tester.tap(find.text('Scoring Module (LevelScoring)'));
    await tester.pump();
    expect(edited, isEmpty);

    await tester.tap(find.text('Zomboss Mech Battle (ZombossBattle)'));
    await tester.pump();
    expect(edited, [zombossRtid]);
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Life Support System and Last Stand coexist without a warning', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.reset);

    const lifeSupportRtid = 'RTID(MoonLifeSupportSystemModule@CurrentLevel)';
    const lastStandRtid = 'RTID(LastStand@CurrentLevel)';
    final levelDef = LevelDefinitionData(
      modules: const [lifeSupportRtid, lastStandRtid],
    );
    final objects = <String, PvzObject>{
      'MoonLifeSupportSystemModule': PvzObject(
        aliases: const ['MoonLifeSupportSystemModule'],
        objClass: 'MoonLifeSupportSystemProperties',
        objData: const <String, dynamic>{},
      ),
      'LastStand': PvzObject(
        aliases: const ['LastStand'],
        objClass: 'LastStandMinigameProperties',
        objData: const <String, dynamic>{},
      ),
    };
    final edited = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LevelSettingsTab(
            levelDef: levelDef,
            objectMap: objects,
            onEditBasicInfo: () {},
            onEditModule: edited.add,
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
    await tester.pump();

    final warning = find.byKey(
      const ValueKey('lifeSupportLastStandConflictWarning'),
    );
    expect(warning, findsNothing);
    expect(find.text('模块逻辑冲突'), findsNothing);
    for (final rtid in [lifeSupportRtid, lastStandRtid]) {
      final tile = find.byKey(ValueKey(rtid));
      expect(tile, findsOneWidget);
      final tapTarget = find
          .descendant(of: tile, matching: find.byType(InkWell))
          .first;
      expect(tester.widget<InkWell>(tapTarget).onTap, isNotNull);
      await tester.tap(tapTarget);
    }
    expect(edited, [lifeSupportRtid, lastStandRtid]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('warns when Not OK Corral and Intro Animation coexist', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.reset);

    const cowboyRtid = 'RTID(CowboyMinigame@CurrentLevel)';
    const introRtid = 'RTID(StandardIntro@CurrentLevel)';
    final levelDef = LevelDefinitionData(
      modules: const [cowboyRtid, introRtid],
    );
    final objects = <String, PvzObject>{
      'CowboyMinigame': PvzObject(
        aliases: const ['CowboyMinigame'],
        objClass: 'CowboyMinigameProperties',
        objData: const <String, dynamic>{},
      ),
      'StandardIntro': PvzObject(
        aliases: const ['StandardIntro'],
        objClass: 'StandardLevelIntroProperties',
        objData: const <String, dynamic>{},
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LevelSettingsTab(
            levelDef: levelDef,
            objectMap: objects,
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
    await tester.pump();

    final message = find.text('围栏之战与转场模块存在冲突，同时使用会导致开局时的僵尸预览和转场效果异常。');
    expect(message, findsOneWidget);
    expect(find.text('模块逻辑冲突'), findsOneWidget);
    final cardFinder = find.ancestor(of: message, matching: find.byType(Card));
    expect(cardFinder, findsOneWidget);
    final card = tester.widget<Card>(cardFinder);
    final context = tester.element(cardFinder);
    expect(card.color, Theme.of(context).colorScheme.errorContainer);
    expect(tester.takeException(), isNull);
  });
}
