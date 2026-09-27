import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/death_hole_module_screen.dart';
import 'package:c_editor/screens/editor/modules/railcart_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_rain_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/tide_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/zombie_move_fast_module_screen.dart';
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

void main() {
  final helpCases =
      <
        ({
          String title,
          List<String> sectionTitles,
          String bodyExcerpt,
          Widget Function(PvzLevelFile level) build,
        })
      >[
        (
          title: 'Death Craters module',
          sectionTitles: ['• Overview'],
          bodyExcerpt: 'leaves an unplantable crater',
          build: (level) => DeathHoleModuleScreen(
            rtid: 'RTID(DeathHoleModule@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
        (
          title: 'Fast Entry module',
          sectionTitles: ['• Overview'],
          bodyExcerpt: 'Zombie Elimination Initiative',
          build: (level) => ZombieMoveFastModuleScreen(
            rtid: 'RTID(ZombieMoveFast@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
        (
          title: "It's Raining Seeds module",
          sectionTitles: [
            '• Overview',
            '• Parameter settings',
            '• Plant levels',
          ],
          bodyExcerpt: 'most zombies do not have matching zombie card icons',
          build: (level) => SeedRainPropertiesScreen(
            rtid: 'RTID(SeedRain@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
        (
          title: 'Minecart and Rail module',
          sectionTitles: ['• Overview', '• Lay rails', '• Place minecarts'],
          bodyExcerpt: 'combines consecutive tiles',
          build: (level) => RailcartPropertiesScreen(
            rtid: 'RTID(Railcarts@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      ];

  for (final helpCase in helpCases) {
    testWidgets('${helpCase.title} exposes localized module help', (
      tester,
    ) async {
      await tester.pumpWidget(
        _localizedApp(helpCase.build(PvzLevelFile(objects: []))),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text(helpCase.title)),
        findsOneWidget,
      );
      for (final sectionTitle in helpCase.sectionTitles) {
        expect(
          find.descendant(of: dialog, matching: find.text(sectionTitle)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(helpCase.bodyExcerpt),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Tide System shows legend and coordinate/order hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        TidePropertiesScreen(
          rtid: 'RTID(Tide@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Land'), findsOneWidget);
    expect(find.byKey(const ValueKey('tidePositionOrderHint')), findsOneWidget);
    expect(
      find.textContaining('rightmost lawn coordinate is 0'),
      findsOneWidget,
    );
    expect(find.textContaining('must be added last'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
