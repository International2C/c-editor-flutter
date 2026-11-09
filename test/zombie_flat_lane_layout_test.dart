import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/grid_item_spawn_event_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_flat_lane_drag_drop_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flat zombie lists wrap across the full available mobile width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              child: ZombieFlatLaneDragDropEditor(
                items: List.generate(
                  8,
                  (i) => ZombieLaneIconData(
                    identity: i,
                    listIndex: i,
                    rowValue: 0,
                    iconPath: null,
                    levelDisplay: '1',
                    isElite: false,
                    isCustom: false,
                    isMissingCustomZombie: false,
                  ),
                ),
                onTap: (_) {},
                onMove: (_, _) {},
                onAdd: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final cards = find.byType(ZombieIconCard);
    expect(cards, findsNWidgets(8));
    final first = tester.getRect(cards.at(0));
    final fifth = tester.getRect(cards.at(4));
    final sixth = tester.getRect(cards.at(5));
    expect(fifth.top, first.top);
    expect(fifth.right, greaterThan(300));
    expect(sixth.top, greaterThan(first.bottom));
    expect(sixth.left, first.left);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'grid-item spawn heading and add action stay together on phones',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GridItemSpawnEventScreen(
            rtid: 'RTID(GridSpawn@CurrentLevel)',
            levelFile: PvzLevelFile(objects: []),
            onChanged: () {},
            onBack: () {},
            onRequestGridItemSelection: (_) {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final heading = find.text('Grid item types (GridTypes)');
      final action = find.byWidgetPredicate(
        (widget) => widget is PvzAddButton && widget.label == 'Add',
      );
      expect(heading, findsOneWidget);
      expect(action, findsOneWidget);
      final headingRect = tester.getRect(heading);
      final actionRect = tester.getRect(action);
      expect(actionRect.center.dy, closeTo(headingRect.center.dy, 0.1));
      expect(actionRect.left, greaterThan(headingRect.right));
      expect(find.textContaining('ZombieSpawnWaitTime'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
