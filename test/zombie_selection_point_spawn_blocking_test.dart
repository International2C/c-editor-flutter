import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
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

  test('point-spawn blocking copy describes selection and spawning', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    expect(
      zh.pointSpawnOnlyZombiesBlocked,
      '此僵尸没有「消耗点数 (WavePointCost)」数据，游戏无法根据波次点数将其加入出怪，'
      '因此也无法添加到按点数出怪池中。',
    );
    expect(zh.pointSpawnOnlyZombieBlockedTitle, '不能用于按点数自动出怪');
    expect(
      zh.pointSpawnOnlyZombieBlockedMessage,
      '此僵尸没有「消耗点数 (WavePointCost)」数据。游戏需要读取该字段，根据波次点数'
      '选择并生成僵尸，因此该僵尸无法用于按点数自动出怪。',
    );
  });

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
    ]);
  });

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pumpAndSettle();
  }

  Finder idText(String id) => find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == id,
    description: 'grid label $id',
  );

  Finder dimmedItem(String id) => find.ancestor(
    of: idText(id),
    matching: find.byWidgetPredicate(
      (widget) => widget is Opacity && widget.opacity == 0.5,
      description: 'dimmed grid item',
    ),
  );

  testWidgets('point-spawn pool blocks a zombie without point cost data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final blocked = ZombieInfo(
      id: 'missing_spawn_stats_test',
      name: 'zombie_missing_spawn_stats_test',
      tags: const [ZombieTag.all],
    );
    ZombieRepository().allZombies.add(blocked);
    addTearDown(() => ZombieRepository().allZombies.remove(blocked));

    String? selected;
    await tester.pumpWidget(
      _localizedApp(
        ZombieSelectionScreen(
          stateBucketId: 'point-spawn-block-test',
          pointSpawnOnly: true,
          onZombieSelected: (id) => selected = id,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await search(tester, blocked.id);
    expect(idText(blocked.id), findsOneWidget);
    expect(dimmedItem(blocked.id), findsOneWidget);

    await tester.tap(idText(blocked.id));
    await tester.pumpAndSettle();

    expect(find.text('Cannot be used in point auto-spawn'), findsOneWidget);
    expect(
      find.text(
        'This zombie has no point cost (WavePointCost) data. The game needs '
        'this field to select and spawn zombies according to the wave\'s '
        'points, so this zombie cannot be used in point auto-spawn.',
      ),
      findsOneWidget,
    );
    expect(selected, isNull);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Cannot be used in point auto-spawn'), findsNothing);
  });

  testWidgets('point-spawn pool allows a Weight = 0 flag carrier', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? selected;
    await tester.pumpWidget(
      _localizedApp(
        ZombieSelectionScreen(
          stateBucketId: 'point-spawn-flag-test',
          pointSpawnOnly: true,
          onZombieSelected: (id) => selected = id,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Flag carriers have WavePointCost data; Weight = 0 does not matter.
    await search(tester, 'pirate_flag');
    expect(idText('pirate_flag'), findsOneWidget);
    expect(dimmedItem('pirate_flag'), findsNothing);

    await tester.tap(idText('pirate_flag'));
    await tester.pumpAndSettle();

    expect(selected, 'pirate_flag');
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('point-spawn pool still allows a spawnable zombie', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? selected;
    await tester.pumpWidget(
      _localizedApp(
        ZombieSelectionScreen(
          stateBucketId: 'point-spawn-allow-test',
          pointSpawnOnly: true,
          onZombieSelected: (id) => selected = id,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await search(tester, 'modern_balloon');
    expect(idText('modern_balloon'), findsOneWidget);
    expect(dimmedItem('modern_balloon'), findsNothing);

    await tester.tap(idText('modern_balloon'));
    await tester.pumpAndSettle();

    expect(selected, 'modern_balloon');
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'flag zombie stays selectable when the picker is not point-spawn only',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? selected;
      await tester.pumpWidget(
        _localizedApp(
          ZombieSelectionScreen(
            stateBucketId: 'point-spawn-off-test',
            onZombieSelected: (id) => selected = id,
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await search(tester, 'pirate_flag');
      expect(idText('pirate_flag'), findsOneWidget);
      expect(dimmedItem('pirate_flag'), findsNothing);

      await tester.tap(idText('pirate_flag'));
      await tester.pumpAndSettle();

      expect(selected, 'pirate_flag');
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
}
