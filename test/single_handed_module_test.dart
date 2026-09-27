import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/cowboy_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/intro_single_handed_properties_screen.dart';
import 'package:c_editor/screens/editor/tabs/single_handed_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Map<String, dynamic> _sampleData() => {
  'ResourceGroupNames': ['SingleHandedGroup'],
  'InitWeapon': 'peashooter',
  'InitWeaponLaunchTimePercent': 1,
  'MissileCount': 1,
  'MissileInterval': 30,
  'RocketHitTime': 6,
  'RocketSpeed': 500,
  'TimeSpeed': 2,
  'ZombiesWalkSpeed': 1,
  'ZombiesHitpointsPercent': 0.1,
  'DropWeaponDatas': [
    {'weaponname': 'repeater', 'killnum': 30, 'launchtimepercent': 1},
  ],
  'SpecialWaveDatas': [
    {
      'wave': 5,
      'ZombiesWalkSpeed': 0.5,
      'ZombiesHitpointsPercent': 15,
      'ShowHealthBar': true,
    },
  ],
};

PvzLevelFile _singleHandedLevel(Map<String, dynamic> data) => PvzLevelFile(
  objects: [
    PvzObject(
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        modules: const ['RTID(SingleHanded@CurrentLevel)'],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['SingleHanded'],
      objClass: 'SingleHandedProperties',
      objData: data,
    ),
  ],
);

void main() {
  test('Single Handed data round-trips the reference level schema', () {
    final json = _sampleData()..['FutureOfficialField'] = 42;
    final data = SingleHandedPropertiesData.fromJson(json);

    expect(data.initWeapon, 'peashooter');
    expect(data.dropWeaponDatas.single.weaponName, 'repeater');
    expect(data.dropWeaponDatas.single.killCount, 30);
    expect(data.specialWaveDatas.single.wave, 5);
    expect(data.specialWaveDatas.single.showHealthBar, isTrue);
    expect(data.toJson(), json);
  });

  test('Single Handed is registered as a mode with functional defaults', () {
    final metadata = ModuleRegistry.getMetadata('SingleHandedProperties');
    expect(metadata.category, ModuleCategory.mode);
    expect(metadata.defaultAlias, 'SingleHanded');
    expect(metadata.routeId, 'SingleHanded');
    expect(metadata.icon, Icons.sledding);
    expect(metadata.initialData, SingleHandedPropertiesData().toJson());

    final tutorial = ModuleRegistry.getMetadata('IntroSingleHandedProperties');
    expect(tutorial.category, ModuleCategory.mode);
    expect(tutorial.isCore, isFalse);
    expect(tutorial.defaultAlias, 'SingleHandedTutorial');
    expect(tutorial.icon, Icons.sledding);
    expect(tutorial.initialData, {'WaveForStartRocket': 1});

    final moduleClasses = ModuleRegistry.getAllModules()
        .map((entry) => entry.objClass)
        .toList();
    final sunBombIndex = moduleClasses.indexOf('SunBombChallengeProperties');
    expect(moduleClasses[sunBombIndex + 1], 'SingleHandedProperties');
    expect(moduleClasses[sunBombIndex + 2], 'IntroSingleHandedProperties');
  });

  test('Single Handed tutorial data preserves future fields', () {
    final source = {'WaveForStartRocket': 7, 'FutureTutorialField': true};
    final data = IntroSingleHandedPropertiesData.fromJson(source);
    expect(data.waveForStartRocket, 7);
    expect(data.toJson(), source);
  });

  test('Single Handed adds its own editor tab', () async {
    final cubit = EditorCubit(fileName: 'test.json', filePath: 'test.json');
    addTearDown(cubit.close);
    final level = _singleHandedLevel(_sampleData());
    final definition = level.objects.first;
    final definitionJson = Map<String, dynamic>.from(definition.objData as Map);
    definitionJson['Modules'] = [
      ...(definitionJson['Modules'] as List),
      'RTID(SingleHandedTutorial@CurrentLevel)',
    ];
    definition.objData = definitionJson;
    level.objects.add(
      PvzObject(
        aliases: const ['SingleHandedTutorial'],
        objClass: 'IntroSingleHandedProperties',
        objData: {'WaveForStartRocket': 1},
      ),
    );
    cubit.applyLevelFile(level);
    expect(cubit.state.availableTabs, contains(EditorTabType.singleHanded));
    expect(
      cubit.state.availableTabs.where(
        (tab) => tab == EditorTabType.singleHanded,
      ),
      hasLength(1),
    );
  });

  testWidgets('Single Handed tab exposes reference fields and updates JSON', (
    tester,
  ) async {
    final data = _sampleData();
    final level = _singleHandedLevel(data);
    await tester.pumpWidget(
      _localizedApp(
        Scaffold(
          body: SingleHandedTab(levelFile: level, onChanged: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basic Parameters'), findsOneWidget);
    expect(find.text('Plant Configuration'), findsOneWidget);
    expect(find.text('Special Waves'), findsOneWidget);
    expect(find.text('Wave 5'), findsOneWidget);
    expect(find.text('Add All by Oneself Tutorial'), findsOneWidget);
    expect(
      find.text('Missile launch interval (MissileInterval; seconds)'),
      findsOneWidget,
    );
    expect(find.text('Warning time (RocketHitTime; seconds)'), findsOneWidget);

    final basicHeading = tester.widget<Text>(find.text('Basic Parameters'));
    final headingTheme = Theme.of(
      tester.element(find.text('Basic Parameters')),
    );
    expect(
      basicHeading.style?.fontSize,
      headingTheme.textTheme.titleMedium?.fontSize,
    );
    expect(basicHeading.style?.color, headingTheme.colorScheme.primary);

    final missileField = find.byKey(const ValueKey('singleHandedMissileCount'));
    await tester.enterText(missileField, '3');
    await tester.pump();
    final module = level.objects.singleWhere(
      (object) => object.objClass == 'SingleHandedProperties',
    );
    expect((module.objData as Map)['MissileCount'], 3);
  });

  testWidgets(
    'Single Handed plant cards move actions below text on narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final level = _singleHandedLevel(_sampleData());
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
                child: Scaffold(
                  body: SingleHandedTab(levelFile: level, onChanged: () {}),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final identity = find.byKey(
        const ValueKey('singleHandedPlantIdentity_repeater'),
      );
      final icon = find.byKey(const ValueKey('singleHandedPlantIcon_repeater'));
      final action = find.byKey(
        const ValueKey('singleHandedPlantAction_repeater'),
      );
      await tester.ensureVisible(identity);
      await tester.pumpAndSettle();

      expect(identity, findsOneWidget);
      expect(icon, findsOneWidget);
      expect(action, findsOneWidget);
      expect(
        (tester.getRect(action).center.dy - tester.getRect(icon).center.dy)
            .abs(),
        lessThan(1),
      );
      expect(
        tester.getRect(identity).top,
        greaterThanOrEqualTo(tester.getRect(icon).bottom),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Single Handed special-wave dialog separates scrollable content and actions',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 560);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final level = _singleHandedLevel(_sampleData());
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(textScaler: const TextScaler.linear(1.3)),
                child: Scaffold(
                  body: SingleHandedTab(levelFile: level, onChanged: () {}),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final waveCard = find.text('Wave 5');
      await tester.ensureVisible(waveCard);
      await tester.tap(waveCard);
      await tester.pumpAndSettle();

      final scrollArea = find.byKey(
        const ValueKey('singleHandedSpecialWaveDialogScroll'),
      );
      expect(scrollArea, findsOneWidget);
      final cancel = find.byKey(
        const ValueKey('singleHandedSpecialWaveCancel'),
      );
      final confirm = find.byKey(
        const ValueKey('singleHandedSpecialWaveConfirm'),
      );
      expect(cancel, findsOneWidget);
      expect(confirm, findsOneWidget);
      expect(
        tester.getRect(scrollArea).bottom,
        lessThanOrEqualTo(tester.getRect(cancel).top),
      );
      expect(tester.getRect(cancel).overlaps(tester.getRect(confirm)), isFalse);
      expect(tester.getRect(confirm).bottom, lessThanOrEqualTo(560));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Not OK Corral preserves an old empty prompt as custom text', (
    tester,
  ) async {
    var changes = 0;
    final object = PvzObject(
      aliases: const ['CowboyMinigame'],
      objClass: 'CowboyMinigameProperties',
      objData: const {'BeginString': '', 'ShowTutorial': true},
    );
    final level = PvzLevelFile(objects: [object]);
    await tester.pumpWidget(
      _localizedApp(
        CowboyMinigameScreen(
          rtid: 'RTID(CowboyMinigame@CurrentLevel)',
          levelFile: level,
          onChanged: () => changes++,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Do not show text'), findsNothing);
    expect(find.text('Custom text (Chinese supported)'), findsOneWidget);
    expect(find.text('Custom prompt text'), findsOneWidget);
    expect((object.objData as Map)['BeginString'], '');
    expect(changes, 0);
  });

  testWidgets('Single Handed tutorial edits its start wave and shows help', (
    tester,
  ) async {
    final tutorialObject = PvzObject(
      aliases: const ['SingleHandedTutorial'],
      objClass: 'IntroSingleHandedProperties',
      objData: {'WaveForStartRocket': 1},
    );
    final level = PvzLevelFile(objects: [tutorialObject]);
    await tester.pumpWidget(
      _localizedApp(
        IntroSingleHandedPropertiesScreen(
          rtid: 'RTID(SingleHandedTutorial@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All by Oneself Tutorial Settings'), findsNothing);
    expect(find.byIcon(Icons.sledding), findsNothing);
    final aliasField = tester.widget<TextField>(find.byType(TextField).first);
    final aliasDecoration = aliasField.decoration!;
    expect(aliasDecoration.isDense, isFalse);
    expect(aliasDecoration.labelStyle?.height, greaterThan(1));
    expect(aliasDecoration.floatingLabelStyle?.height, greaterThan(1));
    expect(
      (aliasDecoration.contentPadding! as EdgeInsets).vertical,
      greaterThanOrEqualTo(32),
    );
    await tester.enterText(
      find.byKey(const ValueKey('singleHandedTutorialWaveForStartRocket')),
      '7',
    );
    expect((tutorialObject.objData as Map)['WaveForStartRocket'], 7);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('30 seconds after wave 7 begins'),
      findsOneWidget,
    );
  });

  testWidgets('Alias label moves above the field when scaled text cannot fit', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    addTearDown(tester.view.reset);

    final tutorialObject = PvzObject(
      aliases: const ['SingleHandedTutorial'],
      objClass: 'IntroSingleHandedProperties',
      objData: {'WaveForStartRocket': 1},
    );
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.8)),
              child: IntroSingleHandedPropertiesScreen(
                rtid: 'RTID(SingleHandedTutorial@CurrentLevel)',
                levelFile: PvzLevelFile(objects: [tutorialObject]),
                onChanged: () {},
                onBack: () {},
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final label = find.text('Alias (English letters only; no spaces)');
    final aliasField = find.byType(TextField).first;
    expect(label, findsOneWidget);
    expect(tester.widget<TextField>(aliasField).decoration?.labelText, isNull);
    final labelWidget = tester.widget<Text>(label);
    final labelTheme = Theme.of(tester.element(label));
    expect(
      labelWidget.style?.fontSize,
      labelTheme.textTheme.bodySmall?.fontSize,
    );
    expect(
      tester.getBottomLeft(label).dy,
      lessThan(tester.getTopLeft(aliasField).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Single Handed and Intro Animation report a logic conflict', (
    tester,
  ) async {
    late List<Pair<String, String>> conflicts;
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            conflicts = ConflictRegistry.getActiveConflicts(context, const {
              'SingleHandedProperties',
              'StandardLevelIntroProperties',
            });
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(conflicts, hasLength(1));
    expect(
      conflicts.single.second,
      'All by Oneself conflicts with the Intro Animation module. Using them together will cause the transition effect at the start of the level to behave incorrectly.',
    );
  });

  test('export note keeps Note and item 1 on the same line', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    expect(zh.exportSuccessMessage('dynamic.rsb.smf'), contains('注意：1. 替换前'));
    expect(
      zh.exportSuccessMessage('dynamic.rsb.smf'),
      isNot(contains('注意：\n1.')),
    );
  });
}
