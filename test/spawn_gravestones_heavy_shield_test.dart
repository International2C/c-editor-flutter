import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/spawn_grave_stones_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _warning = '通过「障碍物生成」事件生成近卫重盾或骑兵长枪会导致关卡闪退，请通过其他方式生成。';
const _crashProneItems = <String, String>{
  'heavy_shield': 'Heavy Shield',
  'cavalrygun': 'Cavalry Lance',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });

  for (final item in _crashProneItems.entries) {
    testWidgets('blocks adding ${item.value} and explains the crash risk', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final event = _eventWithPool(const []);
      var changeCount = 0;

      await tester.pumpWidget(
        _localizedApp(
          event: event,
          onChanged: () => changeCount++,
          onRequestGridItemSelection: (onSelected) {
            onSelected(item.key);
          },
        ),
      );
      await tester.pumpAndSettle();

      final addButton = find.byTooltip('添加');
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(_warning), findsOneWidget);
      expect(changeCount, 0);
      expect(
        (event.objData as Map<String, dynamic>)['GravestonePool'],
        isEmpty,
      );
    });

    testWidgets('shows a red warning when ${item.value} already exists', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final event = _eventWithPool(const []);
      final otherEvent = _eventWithPool([
        {'Type': 'RTID(${item.key}@GridItemTypes)', 'Count': 1},
      ], alias: 'OtherGravestoneSpawn');

      await tester.pumpWidget(
        _localizedApp(event: event, additionalObjects: [otherEvent]),
      );
      await tester.pumpAndSettle();

      final warning = find.byKey(
        const ValueKey('spawnGravestonesCrashProneItemWarning'),
      );
      expect(warning, findsOneWidget);
      expect(
        find.descendant(of: warning, matching: find.text(_warning)),
        findsOneWidget,
      );

      final theme = Theme.of(tester.element(warning));
      expect(
        tester.widget<Card>(warning).color,
        theme.colorScheme.errorContainer,
      );
      final warningText = tester.widget<Text>(
        find.descendant(of: warning, matching: find.text(_warning)),
      );
      expect(warningText.style?.color, theme.colorScheme.error);
    });
  }
}

PvzObject _eventWithPool(
  List<Map<String, dynamic>> pool, {
  String alias = 'GravestoneSpawn',
}) {
  return PvzObject(
    aliases: [alias],
    objClass: 'SpawnGravestonesWaveActionProps',
    objData: <String, dynamic>{
      'GravestonePool': pool,
      'SpawnPositionsPool': <dynamic>[],
    },
  );
}

Widget _localizedApp({
  required PvzObject event,
  List<PvzObject> additionalObjects = const [],
  VoidCallback? onChanged,
  void Function(void Function(String) onSelected)? onRequestGridItemSelection,
}) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: SpawnGraveStonesEventScreen(
      rtid: 'RTID(GravestoneSpawn@CurrentLevel)',
      levelFile: PvzLevelFile(objects: [event, ...additionalObjects]),
      onChanged: onChanged ?? () {},
      onBack: () {},
      onRequestGridItemSelection: onRequestGridItemSelection ?? (_) {},
    ),
  );
}
