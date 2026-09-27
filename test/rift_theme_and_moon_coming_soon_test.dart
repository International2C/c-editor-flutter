import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/rift_theme_module_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/rift_theme_selection_screen.dart';
import 'package:c_editor/widgets/rift_theme_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      PlantRepository().init(),
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
      RiftThemeRepository.ensureTargetListsLoaded(),
    ]);
  });

  test('rift theme help explains card details interaction in every locale', () {
    expect(
      lookupAppLocalizations(const Locale('zh')).riftThemeHelpOverview,
      contains('长按或右键点击主题卡片'),
    );
    expect(
      lookupAppLocalizations(const Locale('en')).riftThemeHelpOverview,
      contains('Long-press or right-click a theme card'),
    );
    expect(
      lookupAppLocalizations(const Locale('ru')).riftThemeHelpOverview,
      contains('Нажмите и удерживайте карточку темы'),
    );
  });

  testWidgets('all-plants coming soon keeps the general message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        PlantSelectionScreen(
          stateBucketId: 'coming-soon-all-test',
          onPlantSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'coming_soon');
    await tester.pumpAndSettle();
    await tester.tap(find.text('coming_soon').last);
    await tester.pumpAndSettle();

    expect(find.text('To Be Continued'), findsOneWidget);
    expect(
      find.text(
        'The plants are still growing strong. Stay tuned for future updates!',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Moon BaseZ no longer lists the coming-soon placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        PlantSelectionScreen(
          stateBucketId: 'coming-soon-moon-test',
          onPlantSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('By World'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Moon BaseZ'));
    await tester.tap(find.text('Moon BaseZ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'coming_soon');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('plantSelectionIcon-coming_soon')),
      findsNothing,
    );
    expect(find.byType(AlertDialog), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'cosmicsaucer');
    await tester.pumpAndSettle();
    expect(find.text('Cosmic Saucer'), findsOneWidget);
  });

  testWidgets('rift theme list uses icons and opens target details', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _localizedApp(
        RiftThemeSelectionScreen(
          initialSelectedIds: const [],
          accentColor: Colors.purple,
          onThemesConfirmed: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RiftThemeIcon), findsWidgets);
    expect(find.byIcon(Icons.palette_outlined), findsNothing);

    await tester.longPress(find.text('Fully Armored'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Unarmored basic zombies in the level receive bucket armor.'),
      findsOneWidget,
    );
    expect(find.text('Zombie list'), findsOneWidget);
    expect(find.text('roman'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('riftThemeTarget-roman'))).width,
      greaterThan(200),
    );
    expect(tester.widget<Text>(find.text('Roman Zombie')).maxLines, 2);
  });

  testWidgets('theme target cards share row height and center short content', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showRiftThemeDetailsDialog(context, 'nuke'),
            child: const Text('open-health-debuff'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-health-debuff'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    final shortCard = find.byKey(const ValueKey('riftThemeTarget-wallnut'));
    final tallCard = find.byKey(
      const ValueKey('riftThemeTarget-primalwallnut'),
    );
    final shortRect = tester.getRect(shortCard);
    final tallRect = tester.getRect(tallCard);

    expect(shortRect.top, closeTo(tallRect.top, 0.1));
    expect(shortRect.height, closeTo(tallRect.height, 0.1));

    final shortContentCenter =
        (tester.getTopLeft(find.text('Wall-nut')).dy +
            tester.getBottomLeft(find.text('wallnut')).dy) /
        2;
    expect(shortContentCenter, closeTo(shortRect.center.dy, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected themes use a neutral list number and support details', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: const ['RiftThemeModule'],
      objClass: 'RiftThemeDemoModuleProperties',
      objData: RiftThemeDemoModulePropertiesData(
        demoRiftThemeName: const ['zombie'],
      ).toJson(),
    );

    await tester.pumpWidget(
      _localizedApp(
        RiftThemeModuleScreen(
          rtid: 'RTID(RiftThemeModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(RiftThemeIcon), findsOneWidget);
    final indexText = tester.widget<Text>(find.text('1.'));
    expect(indexText.style?.fontWeight, FontWeight.normal);
    expect(indexText.style?.color, isNotNull);
    final selectedThemeCard = find.ancestor(
      of: find.text('Fully Armored'),
      matching: find.byType(Card),
    );
    final interactiveSurface = tester
        .widgetList<InkWell>(
          find.descendant(
            of: selectedThemeCard,
            matching: find.byType(InkWell),
          ),
        )
        .where(
          (inkWell) =>
              inkWell.onLongPress != null && inkWell.onSecondaryTap != null,
        );
    expect(interactiveSurface, isNotEmpty);

    await tester.longPress(find.text('Fully Armored'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zombie list'), findsOneWidget);
  });

  testWidgets('theme details hide every zombie blacklist', (tester) async {
    for (final themeId in const ['invisible', 'gravestone']) {
      final targetList = RiftThemeRepository.targetLists[themeId];
      expect(targetList, isNotNull);
      expect(targetList!.type, RiftThemeTargetType.zombies);
      expect(targetList.isBlacklist, isTrue);

      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showRiftThemeDetailsDialog(context, themeId),
              child: Text(themeId),
            ),
          ),
        ),
      );
      await tester.tap(find.text(themeId));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zombie list'), findsNothing);
      for (final zombieId in targetList.ids) {
        expect(
          find.byKey(ValueKey('riftThemeTarget-${zombieId.trim()}')),
          findsNothing,
        );
      }

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }
  });

  test('ZombieClass themes resolve exact classes in Zombies.json order', () {
    expect(
      ZombiePropertiesRepository.getZombieClassByAlias('modern_allstar'),
      'ZombieModernAllStar',
    );
    expect(
      ZombiePropertiesRepository.getZombieClassByAlias(
        'universe_uncharted_prospector',
      ),
      'ZombieProspectorUniverseUncharted',
    );

    List<String> affected(String themeId) =>
        RiftThemeRepository.getAffectedZombiesForRiftTheme(
          themeId,
        ).map((zombie) => zombie.id).toList();

    expect(affected('knight_cheating'), [
      'west_bull',
      'new_pvp_west_bull',
      'dark_cavalry',
      'new_pvp_dark_cavalry',
      'modern_allstar',
      'new_pvp_modern_allstar',
      'fairy_tale_knight',
      'fairy_tale_knight_memo',
      'journey_to_the_west_allstar',
    ]);
    expect(affected('mage_cheating'), [
      'ra',
      'tomb_raiser',
      'new_pvp_tomb_raiser',
      'dark_wizard',
      'new_pvp_dark_wizard',
      'dark_archmage',
      'beach_octopus',
      'new_pvp_beach_octopus',
      'renai_perfumer',
      'roman_healer',
      'new_pvp_roman_healer',
      'spring_wizard',
      'sportzball_wizard',
    ]);
    expect(affected('miner_cheating'), [
      'prospector',
      'new_pvp_prospector',
      'modern_miner',
      'new_pvp_modern_miner',
    ]);
    expect(
      affected('miner_cheating'),
      isNot(containsAll(['universe_uncharted_prospector', 'uncharted_miner'])),
    );
  });

  testWidgets('ZombieClass theme details show only registered matches', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showRiftThemeDetailsDialog(context, 'knight_cheating'),
            child: const Text('open-knight-theme'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-knight-theme'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zombie list'), findsOneWidget);
    for (final id in const [
      'west_bull',
      'new_pvp_west_bull',
      'dark_cavalry',
      'new_pvp_dark_cavalry',
      'modern_allstar',
      'new_pvp_modern_allstar',
      'fairy_tale_knight',
      'fairy_tale_knight_memo',
      'journey_to_the_west_allstar',
    ]) {
      expect(find.byKey(ValueKey('riftThemeTarget-$id')), findsOneWidget);
    }
    expect(
      find.byKey(
        const ValueKey('riftThemeTarget-universe_uncharted_prospector'),
      ),
      findsNothing,
    );
  });
}
