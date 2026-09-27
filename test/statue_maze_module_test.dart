import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/statue_maze_module_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing-step warning clears after adding a rotation', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: ['Maze'],
      objClass: 'StatueMazeModuleProperties',
      objData: StatueMazeModulePropertiesData().toJson(),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatueMazeModuleScreen(
          rtid: 'RTID(Maze@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final warning = find.byKey(const ValueKey('statueMazeMissingRotations'));
    expect(warning, findsOneWidget);
    final addRotation = find.byIcon(Icons.add).last;
    await tester.ensureVisible(addRotation);
    await tester.tap(addRotation);
    await tester.pumpAndSettle();
    expect(warning, findsNothing);
    expect((module.objData as Map)['SetInfos'][0]['MatrixInfos'], hasLength(1));
    expect(tester.takeException(), isNull);
  });

  for (final language in ['zh', 'en', 'ru']) {
    testWidgets(
      'Bemarbled timing controls remain usable on narrow $language screens',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final module = PvzObject(
          aliases: ['StatueMazeModule'],
          objClass: 'StatueMazeModuleProperties',
          objData: StatueMazeModulePropertiesData(
            setInfos: [
              StatueSetInfo(matrixInfos: [StatueMatrixInfo()]),
            ],
          ).toJson(),
        );
        final l10n = lookupAppLocalizations(Locale(language));
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: StatueMazeModuleScreen(
              rtid: 'RTID(StatueMazeModule@CurrentLevel)',
              levelFile: PvzLevelFile(objects: [module]),
              onChanged: () {},
              onBack: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final step = find.text('2.0s / 1.5s');
        await tester.ensureVisible(step);
        await tester.tap(step);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        Finder field(String label) => find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is EditorResponsiveInputField && widget.label == label,
          ),
          matching: find.byType(TextField),
        );
        await tester.enterText(field(l10n.statueMazeWaitDuration), '3.5');
        await tester.enterText(field(l10n.statueMazeRotateTime), '0.8');
        await tester.tap(find.widgetWithText(FilledButton, l10n.confirm));
        await tester.pumpAndSettle();
        final saved = StatueMazeModulePropertiesData.fromJson(
          Map<String, dynamic>.from(module.objData as Map),
        ).setInfos.single.matrixInfos.single;
        expect(saved.waitDuration, 3.5);
        expect(saved.rotateTime, 0.8);
        expect(saved.type, 'c');

        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();
        final dialog = find.byType(AlertDialog);
        expect(
          find.descendant(
            of: dialog,
            matching: find.text('• ${l10n.moduleHelpStatueMazeTimingTitle}'),
          ),
          findsOneWidget,
        );
        final scroll = find.descendant(
          of: dialog,
          matching: find.byType(SingleChildScrollView),
        );
        final position = tester
            .state<ScrollableState>(
              find.descendant(of: scroll, matching: find.byType(Scrollable)),
            )
            .position;
        await tester.drag(scroll, Offset(0, -position.maxScrollExtent - 100));
        await tester.pumpAndSettle();
        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: scroll, matching: find.byType(Scrollable)),
        );
        expect(scrollable.position.pixels, scrollable.position.maxScrollExtent);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
