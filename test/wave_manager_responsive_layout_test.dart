import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/wave_manager_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required PvzLevelFile level, required ThemeMode themeMode}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: themeMode,
    home: Builder(
      builder: (context) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
          child: WaveManagerModuleScreen(
            rtid: 'RTID(NewWaves@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
            onOpenWaveTimeline: () {},
          ),
        );
      },
    ),
  );
}

void main() {
  testWidgets('wave manager repair button stays readable and wide', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.reset);

    PvzLevelFile buildLevel() {
      final module = PvzObject(
        aliases: const ['NewWaves'],
        objClass: 'WaveManagerModuleProperties',
        objData: WaveManagerModuleData().toJson(),
      );
      final props = PvzObject(
        aliases: const ['WaveManagerPropsWeek1'],
        objClass: 'WaveManagerProperties',
        objData: const <String, dynamic>{},
      );
      return PvzLevelFile(objects: [module, props]);
    }

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_app(level: buildLevel(), themeMode: mode));
      await tester.pumpAndSettle();

      final buttonFinder = find.byKey(
        const ValueKey('waveManagerPropsFixButton'),
      );
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(buttonFinder);
      final background = button.style?.backgroundColor?.resolve({});
      final foreground = button.style?.foregroundColor?.resolve({});
      expect(background, isNotNull);
      expect(foreground, isNotNull);
      expect(background, isNot(foreground));
      expect(tester.getSize(buttonFinder).width, greaterThan(240));
      expect(find.text('Fix to WaveManagerPropsWeek1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('wave manager zombie pool keeps text separate from actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.reset);

    final module = PvzObject(
      aliases: const ['NewWaves'],
      objClass: 'WaveManagerModuleProperties',
      objData: WaveManagerModuleData(
        waveManagerProps: 'RTID(WaveManagerPropsWeek1@CurrentLevel)',
        dynamicZombies: [
          DynamicZombieGroup(
            zombiePool: const ['RTID(tutorial@ZombieTypes)'],
            zombieLevel: const [1],
          ),
        ],
      ).toJson(),
    );
    final props = PvzObject(
      aliases: const ['WaveManagerPropsWeek1'],
      objClass: 'WaveManagerProperties',
      objData: const <String, dynamic>{},
    );

    await tester.pumpWidget(
      _app(
        level: PvzLevelFile(objects: [module, props]),
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();

    final details = find.byKey(
      const ValueKey('waveManagerZombiePoolDetails-0'),
    );
    final actions = find.byKey(
      const ValueKey('waveManagerZombiePoolActions-0'),
    );
    await tester.ensureVisible(details);
    await tester.pumpAndSettle();

    expect(tester.getSize(details).width, greaterThan(300));
    expect(
      tester.getRect(actions).top,
      greaterThanOrEqualTo(tester.getRect(details).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('runner-only wave manager accepts escalation configuration', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(500, 900);
    addTearDown(tester.view.reset);

    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            modules: const [
              'RTID(LevelEscalation@CurrentLevel)',
              'RTID(NewWaves@CurrentLevel)',
            ],
          ).toJson(),
        ),
        PvzObject(
          aliases: const ['LevelEscalation'],
          objClass: 'LevelEscalationModuleProperties',
          objData: LevelEscalationModuleData(
            waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
          ).toJson(),
        ),
        PvzObject(
          aliases: const ['NewWaves'],
          objClass: 'WaveManagerModuleProperties',
          objData: WaveManagerModuleData().toJson(),
        ),
        PvzObject(
          aliases: const ['WaveManagerProps'],
          objClass: 'WaveManagerProperties',
          objData: WaveManagerData(waves: [<String>[]]).toJson(),
        ),
      ],
    );

    await tester.pumpWidget(_app(level: level, themeMode: ThemeMode.light));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('provided by Escalation Spawning'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('waveManagerPropsFixButton')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
