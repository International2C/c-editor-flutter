import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'empty wave actions share a centered row and wrap on narrow screens',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1000);
      addTearDown(tester.view.reset);

      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['Waves'],
            objClass: 'WaveManagerProperties',
            objData: WaveManagerData(waveCount: 0, waves: []).toJson(),
          ),
        ],
      );
      var deletePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: WaveTimelineTab(
              levelFile: level,
              parsed: LevelParser.parseLevel(level),
              onChanged: () {},
              onEditEvent: (_, _) async {},
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
              onDeleteContainer: () => deletePressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const actionsKey = ValueKey('waveTimelineEmptyActions');
      const addKey = ValueKey('waveTimelineAddWaveButton');
      const deleteKey = ValueKey('waveTimelineDeleteEmptyContainerButton');

      Future<void> revealActions() async {
        await tester.scrollUntilVisible(
          find.byKey(actionsKey),
          300,
          maxScrolls: 20,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
      }

      await revealActions();
      expect(find.byKey(addKey), findsOneWidget);
      expect(find.byKey(deleteKey), findsOneWidget);
      expect(
        tester.getCenter(find.byKey(addKey)).dy,
        closeTo(tester.getCenter(find.byKey(deleteKey)).dy, 0.5),
      );

      tester.view.physicalSize = const Size(320, 1000);
      await tester.pumpAndSettle();
      await revealActions();
      final actionsCenter = tester.getCenter(find.byKey(actionsKey)).dx;
      expect(
        tester.getCenter(find.byKey(addKey)).dx,
        closeTo(actionsCenter, 0.5),
      );
      expect(
        tester.getCenter(find.byKey(deleteKey)).dx,
        closeTo(actionsCenter, 0.5),
      );
      expect(
        tester.getCenter(find.byKey(addKey)).dy,
        isNot(closeTo(tester.getCenter(find.byKey(deleteKey)).dy, 0.5)),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(deleteKey));
      expect(deletePressed, isTrue);

      await tester.tap(find.byKey(addKey));
      await tester.pumpAndSettle();
      expect(find.byKey(actionsKey), findsNothing);
      expect(find.byKey(addKey), findsOneWidget);
    },
  );
}
