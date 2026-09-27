import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/zombie_spawn_event_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const unknownIcon = 'assets/images/others/unknown.webp';

Widget app(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

PvzObject customType() => PvzObject(
  aliases: ['custom_without_icon', 'second_alias'],
  objClass: 'ZombieType',
  objData: {'TypeName': 'unlisted_base_type'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ZombieRepository().init();
  });

  test('unknown built-in names do not imply a missing custom zombie', () {
    final level = PvzLevelFile(objects: []);
    for (final value in ['RTID(unlisted@ZombieTypes)', 'unlisted', '']) {
      expect(
        CustomZombieLevelUtils.isMissingCustomZombie(level, value),
        isFalse,
      );
    }
  });

  test(
    'local references require a ZombieType, including secondary aliases',
    () {
      final level = PvzLevelFile(objects: [customType()]);
      for (final source in ['CurrentLevel', '.']) {
        expect(
          CustomZombieLevelUtils.isMissingCustomZombie(
            level,
            'RTID(missing@$source)',
          ),
          isTrue,
        );
        for (final alias in ['custom_without_icon', 'second_alias']) {
          expect(
            CustomZombieLevelUtils.isMissingCustomZombie(
              level,
              'RTID($alias@$source)',
            ),
            isFalse,
          );
        }
      }
    },
  );

  test('a same-name property object does not count as a custom ZombieType', () {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['missing'],
          objClass: 'ZombiePropertySheet',
          objData: {},
        ),
      ],
    );
    expect(
      CustomZombieLevelUtils.isMissingCustomZombie(
        level,
        'RTID(missing@CurrentLevel)',
      ),
      isTrue,
    );
  });

  for (final isCustom in [false, true]) {
    for (final path in <String?>[null, '', '   ']) {
      testWidgets(
        'empty icon uses question mark (custom=$isCustom, path=$path)',
        (tester) async {
          await tester.pumpWidget(
            app(
              Scaffold(
                body: ZombieIconCard(
                  iconPath: path,
                  levelDisplay: '3',
                  isElite: false,
                  isCustom: isCustom,
                  onTap: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byIcon(Icons.warning), findsNothing);
          expect(
            tester
                .widget<AssetImageWidget>(find.byType(AssetImageWidget))
                .assetPath,
            unknownIcon,
          );
          final image = tester.widget<Image>(find.byType(Image));
          expect((image.image as AssetImage).assetName, unknownIcon);
          expect(find.text('3'), findsOneWidget);
          expect(find.text('C'), isCustom ? findsOneWidget : findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('missing custom reference overrides a coincidental valid icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Scaffold(
          body: ZombieIconCard(
            iconPath: unknownIcon,
            levelDisplay: '0',
            isElite: false,
            isCustom: true,
            isMissingCustomZombie: true,
            onTap: () {},
          ),
        ),
      ),
    );
    final warning = find.byIcon(Icons.warning);
    expect(warning, findsOneWidget);
    expect(
      tester.widget<Icon>(warning).color,
      Theme.of(tester.element(warning)).colorScheme.error,
    );
    expect(find.byType(AssetImageWidget), findsNothing);
  });

  testWidgets('drag feedback preserves the missing-custom warning', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Center(
            child: buildZombieLaneDragFeedback(
              const ZombieLaneIconData(
                identity: 'missing',
                listIndex: 0,
                rowValue: 1,
                iconPath: null,
                levelDisplay: '0',
                isElite: false,
                isCustom: true,
                isMissingCustomZombie: true,
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.byType(AssetImageWidget), findsNothing);
  });

  for (final ground in [false, true]) {
    testWidgets(
      'spawn editor distinguishes unknown icons from broken local types (ground=$ground)',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final event = PvzObject(
          aliases: ['Spawn'],
          objClass: ground
              ? 'SpawnZombiesFromGroundSpawnerProps'
              : 'SpawnZombiesJitteredWaveActionProps',
          objData: {
            'Zombies': [
              {'Type': 'RTID(unlisted@ZombieTypes)', 'Row': 1},
              {'Type': 'RTID(custom_without_icon@CurrentLevel)', 'Row': 1},
              {'Type': 'RTID(missing@CurrentLevel)', 'Row': 1},
              {'Type': 'RTID(mummy@CurrentLevel)', 'Row': 1},
            ],
          },
        );
        final level = PvzLevelFile(objects: [event, customType()]);
        await tester.pumpWidget(
          app(
            ZombieSpawnEventScreen(
              rtid: 'RTID(Spawn@CurrentLevel)',
              levelFile: level,
              eventSubtitle: 'Spawn',
              isGroundSpawner: ground,
              onChanged: () {},
              onBack: () {},
              onRequestZombieSelection: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final cards = find.byType(ZombieIconCard);
        expect(cards, findsNWidgets(4));
        final warnings = tester
            .widgetList<ZombieIconCard>(cards)
            .map((card) => card.isMissingCustomZombie);
        expect(warnings, [false, false, true, true]);
        expect(find.byIcon(Icons.warning), findsNWidgets(2));
        for (var i = 0; i < 2; i++) {
          final image = find.descendant(
            of: cards.at(i),
            matching: find.byType(AssetImageWidget),
          );
          expect(tester.widget<AssetImageWidget>(image).assetPath, unknownIcon);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
