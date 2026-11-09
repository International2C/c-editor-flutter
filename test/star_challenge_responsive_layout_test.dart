import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/challenge_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/challenge_editors.dart';
import 'package:c_editor/screens/editor/modules/star_challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

PvzObject _killChallenge() => PvzObject(
  aliases: const ['KillZombies'],
  objClass: 'StarChallengeKillZombiesInTimeProps',
  objData: StarChallengeKillZombiesInTimeData(
    zombiesToKill: 5,
    time: 5,
  ).toJson(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ResourceNames.ensureLoaded);

  test('every challenge type receives an unseparated numeric alias suffix', () {
    for (final challenge in ChallengeRepository.allChallenges) {
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: [challenge.defaultAlias],
            objClass: challenge.objClass,
            objData: const <String, dynamic>{},
          ),
        ],
      );

      expect(
        ChallengeRepository.suggestUniqueAlias(
          challenge: challenge,
          levelFile: level,
        ),
        '${challenge.defaultAlias}1',
        reason: challenge.objClass,
      );

      level.objects.add(
        PvzObject(
          aliases: ['${challenge.defaultAlias}1'],
          objClass: challenge.objClass,
          objData: const <String, dynamic>{},
        ),
      );
      expect(
        ChallengeRepository.suggestUniqueAlias(
          challenge: challenge,
          levelFile: level,
        ),
        '${challenge.defaultAlias}2',
        reason: challenge.objClass,
      );
    }
  });

  test(
    'plant survival uses its canonical alias and handles legacy spelling',
    () {
      final challenge = ChallengeRepository.getInfo(
        'StarChallengePlantsSurviveProps',
      )!;
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['PlantsSurive'],
            objClass: challenge.objClass,
            objData: const <String, dynamic>{},
          ),
        ],
      );

      expect(challenge.defaultAlias, 'PlantsSurvive');
      expect(
        ChallengeRepository.suggestUniqueAlias(
          challenge: challenge,
          levelFile: level,
        ),
        'PlantsSurvive1',
      );
    },
  );

  test('plant defeat zombie challenge defaults to KILL_DESC', () {
    final challenge = ChallengeRepository.getInfo(
      'PlantDefeatZombieChallengeProps',
    )!;

    expect(
      challenge.initialDataFactory!(),
      containsPair('Description', kPlantDefeatZombieDefaultDescription),
    );
    expect(kPlantDefeatZombieDefaultDescription, '[KILL_DESC]');
  });

  test('plant defeat zombie hint explains the KILL_DESC placeholder', () {
    expect(
      lookupAppLocalizations(
        const Locale('zh'),
      ).plantDefeatZombieDescriptionHint,
      '默认填写[KILL_DESC]可显示“用...击杀...只僵尸”，不支持直接输入中文',
    );
  });

  testWidgets('plant defeat zombie editor uses its dedicated hint', (
    tester,
  ) async {
    final info = ChallengeRepository.getInfo(
      'PlantDefeatZombieChallengeProps',
    )!;
    final challenge = PvzObject(
      aliases: [info.defaultAlias],
      objClass: info.objClass,
      objData: info.initialDataFactory!(),
    );

    await tester.pumpWidget(
      _localizedApp(
        Scaffold(
          body: SingleChildScrollView(
            child: ChallengeEditorContent(object: challenge, onChanged: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('[KILL_DESC]'), findsOneWidget);
    expect(
      find.text(
        'The default [KILL_DESC] displays ‘Use ... to defeat ... zombies’; '
        'direct Chinese input is not supported.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('challenge cards keep readable text width on narrow screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.reset);

    final module = PvzObject(
      aliases: const ['ChallengeModule'],
      objClass: 'StarChallengeModuleProperties',
      objData: StarChallengeModuleData(
        challenges: const [
          ['RTID(KillZombies@CurrentLevel)'],
        ],
      ).toJson(),
    );
    final level = PvzLevelFile(objects: [module, _killChallenge()]);

    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
              child: StarChallengeModuleScreen(
                rtid: 'RTID(ChallengeModule@CurrentLevel)',
                levelFile: level,
                onChanged: () {},
                onBack: () {},
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final icon = find.byKey(const ValueKey('starChallengeIcon0'));
    final identity = find.byKey(const ValueKey('starChallengeIdentity0'));
    final actions = find.byKey(const ValueKey('starChallengeActions0'));
    await tester.ensureVisible(identity);
    await tester.pumpAndSettle();

    expect(tester.getSize(identity).width, greaterThan(140));
    expect(
      find.text(
        'Defeat a specified number of zombies within a certain amount of time',
      ),
      findsNothing,
    );
    expect(
      tester.getRect(actions).top,
      greaterThanOrEqualTo(tester.getRect(icon).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('challenge dialog moves every input label above together', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(340, 720);
    addTearDown(tester.view.reset);

    final challenge = _killChallenge();
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.4)),
              child: Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => showChallengeEditorDialog(
                      context,
                      object: challenge,
                      onChanged: () {},
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    for (var index = 0; index < 2; index++) {
      final field = tester.widget<TextField>(fields.at(index));
      expect(field.decoration?.labelText, isNull);
    }
    expect(find.text('Zombies to Kill (ZombiesToKill)'), findsOneWidget);
    expect(find.text('Time Limit (seconds)'), findsOneWidget);
    expect(
      tester.getSize(find.text('Timed Zombie Defeat Challenge')).height,
      lessThan(80),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('speed boost explanation is shown below a clean label', (
    tester,
  ) async {
    final challenge = PvzObject(
      aliases: const ['ZombieSpeed'],
      objClass: 'StarChallengeZombieSpeedProps',
      objData: StarChallengeZombieSpeedData(speedModifier: 0.5).toJson(),
    );

    await tester.pumpWidget(
      _localizedApp(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ChallengeEditorContent(object: challenge, onChanged: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Speed boost multiplier (SpeedModifier)'), findsOneWidget);
    expect(
      find.text('Entering 0.5 increases zombie movement speed by 50%.'),
      findsOneWidget,
    );
    expect(
      tester
          .getRect(
            find.text('Entering 0.5 increases zombie movement speed by 50%.'),
          )
          .top,
      greaterThan(tester.getRect(find.byType(TextField)).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate challenge aliases use an unseparated numeric suffix', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: const ['ChallengeModule'],
      objClass: 'StarChallengeModuleProperties',
      objData: StarChallengeModuleData(
        challenges: [
          ['RTID(BeatTheLevel@CurrentLevel)'],
        ],
      ).toJson(),
    );
    final existing = PvzObject(
      aliases: const ['BeatTheLevel'],
      objClass: 'StarChallengeBeatTheLevelProps',
      objData: StarChallengeBeatTheLevelData().toJson(),
    );
    final level = PvzLevelFile(objects: [module, existing]);

    await tester.pumpWidget(
      _localizedApp(
        StarChallengeModuleScreen(
          rtid: 'RTID(ChallengeModule@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add challenge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Level Hint Text').first);
    await tester.pumpAndSettle();

    final aliasFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.controller?.text == 'BeatTheLevel1',
    );
    expect(aliasFinder, findsOneWidget);
    final aliasField = tester.widget<TextField>(aliasFinder);
    expect(aliasField.controller?.text, 'BeatTheLevel1');

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final saved = StarChallengeModuleData.fromJson(
      module.objData as Map<String, dynamic>,
    );
    expect(
      saved.challenges.single,
      contains('RTID(BeatTheLevel1@CurrentLevel)'),
    );
    expect(
      level.objects.any(
        (object) => object.aliases?.contains('BeatTheLevel1') == true,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'fresh JSON-loaded challenge module can add its first challenge',
    (tester) async {
      final module = PvzObject(
        aliases: const ['ChallengeModule'],
        objClass: 'StarChallengeModuleProperties',
        objData: jsonDecode(
          '{"ChallengesAlwaysAvailable":true,"Challenges":[[]]}',
        ),
      );
      final level = PvzLevelFile(objects: [module]);

      await tester.pumpWidget(
        _localizedApp(
          StarChallengeModuleScreen(
            rtid: 'RTID(ChallengeModule@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add challenge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Level Hint Text').first);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.controller?.text == 'BeatTheLevel',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final saved = StarChallengeModuleData.fromJson(
        module.objData as Map<String, dynamic>,
      );
      expect(
        saved.challenges.single,
        contains('RTID(BeatTheLevel@CurrentLevel)'),
      );
      expect(
        level.objects.any(
          (object) => object.aliases?.contains('BeatTheLevel') == true,
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('duplicate plant survival challenge uses PlantsSurvive1', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: const ['ChallengeModule'],
      objClass: 'StarChallengeModuleProperties',
      // jsonDecode deliberately preserves the real List<dynamic> nesting
      // produced when a level file is loaded from disk.
      objData: jsonDecode(
        '{"ChallengesAlwaysAvailable":true,'
        '"Challenges":[["RTID(PlantsSurvive@CurrentLevel)"]]}',
      ),
    );
    final existing = PvzObject(
      aliases: const ['PlantsSurvive'],
      objClass: 'StarChallengePlantsSurviveProps',
      objData: StarChallengePlantSurviveData().toJson(),
    );
    final level = PvzLevelFile(objects: [module, existing]);

    await tester.pumpWidget(
      _localizedApp(
        StarChallengeModuleScreen(
          rtid: 'RTID(ChallengeModule@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add challenge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plant Survival Challenge').first);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller?.text == 'PlantsSurvive1',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final saved = StarChallengeModuleData.fromJson(
      module.objData as Map<String, dynamic>,
    );
    expect(
      saved.challenges.single,
      contains('RTID(PlantsSurvive1@CurrentLevel)'),
    );
    expect(
      level.objects.any(
        (object) => object.aliases?.contains('PlantsSurvive1') == true,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('challenge description and level hint move into edit dialog', (
    tester,
  ) async {
    final challenge = PvzObject(
      aliases: const ['BeatTheLevel'],
      objClass: 'StarChallengeBeatTheLevelProps',
      objData: StarChallengeBeatTheLevelData().toJson(),
    );

    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showChallengeEditorDialog(
                  context,
                  object: challenge,
                  onChanged: () {},
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('Display a hint message in a pop-up when the level begins'),
      findsOneWidget,
    );
    expect(find.text('Hint text (Description)'), findsOneWidget);
    expect(
      find.text(
        'Supports Chinese; for multi-line text enter newlines directly, no need for \\n. Note: hints cannot be viewed in Creative Courtyard on iOS.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('no-config challenge dialog does not duplicate description', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: const ['ChallengeModule'],
      objClass: 'StarChallengeModuleProperties',
      objData: StarChallengeModuleData(
        challenges: [
          ['RTID(SaveMowers@CurrentLevel)'],
        ],
      ).toJson(),
    );
    final challenge = PvzObject(
      aliases: const ['SaveMowers'],
      objClass: 'StarChallengeSaveMowersProps',
      objData: StarChallengeSaveMowerData().toJson(),
    );

    await tester.pumpWidget(
      _localizedApp(
        StarChallengeModuleScreen(
          rtid: 'RTID(ChallengeModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module, challenge]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Do not lose any lawn mowers. This challenge causes a crash when used with the Creative Courtyard module',
      ),
      findsNothing,
    );
    expect(
      find.textContaining('This challenge has no configurable parameters.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selected plant and zombie status controls stay readable narrow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1100);
      addTearDown(tester.view.reset);

      Widget scaledEditor(PvzObject challenge) {
        return _localizedApp(
          Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ChallengeEditorContent(
                      object: challenge,
                      onChanged: () {},
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      final plantChallenge = PvzObject(
        aliases: const ['DefeatZombie'],
        objClass: 'PlantDefeatZombieChallengeProps',
        objData: {
          'Description': '',
          'NumZombiesToKill': 12,
          'PlantTypeName': 'peashooter',
        },
      );
      await tester.pumpWidget(scaledEditor(plantChallenge));
      await tester.pumpAndSettle();

      final plantIdentity = find.byKey(
        const ValueKey('starChallengePlantIdentity'),
      );
      final plantActions = find.byKey(
        const ValueKey('starChallengePlantActions'),
      );
      expect(tester.getSize(plantIdentity).width, greaterThan(200));
      expect(
        tester.getRect(plantIdentity).top,
        greaterThanOrEqualTo(tester.getRect(plantActions).bottom),
      );
      expect(tester.takeException(), isNull);

      final conditionChallenge = PvzObject(
        aliases: const ['ApplyZombieConditionsChallenge'],
        objClass: 'ApplyZombieConditionsChallengeProps',
        objData: {
          'ConditionToInflict': ['hypnotized'],
          'IncludeBurnedToAsh': true,
          'IncludeElectrified': true,
          'NumZombieConditionsToApply': 5,
        },
      );
      await tester.pumpWidget(scaledEditor(conditionChallenge));
      await tester.pumpAndSettle();

      const burnedLabel = 'Include zombies burned to ash (IncludeBurnedToAsh)';
      final boolLabel = find.byKey(
        const ValueKey('starChallengeBoolLabel_$burnedLabel'),
      );
      final boolSwitch = find.byKey(
        const ValueKey('starChallengeBoolSwitch_$burnedLabel'),
      );
      expect(tester.getSize(boolLabel).width, greaterThan(200));
      expect(
        tester.getRect(boolSwitch).top,
        greaterThanOrEqualTo(tester.getRect(boolLabel).bottom),
      );

      final conditionIdentity = find.byKey(
        const ValueKey('starChallengeConditionIdentity_0'),
      );
      final conditionActions = find.byKey(
        const ValueKey('starChallengeConditionActions_0'),
      );
      expect(tester.getSize(conditionIdentity).width, greaterThan(200));
      expect(
        tester.getRect(conditionActions).top,
        greaterThanOrEqualTo(tester.getRect(conditionIdentity).bottom),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
