import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/screens/editor/events/zombie_spawn_event_screen.dart';
import 'package:c_editor/screens/editor/events/zombie_fish_wave_event_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:c_editor/screens/editor/others/custom_zombie_properties_screen.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  for (final underwater in [false, true]) {
    testWidgets(
      'returning from custom properties reloads ${underwater ? 'underwater' : 'ordinary'} zombie aliases',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1500);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final event = PvzObject(
          aliases: ['Spawn'],
          objClass: underwater
              ? 'SpawnZombiesFishWaveActionProps'
              : 'SpawnZombiesJitteredWaveActionProps',
          objData: {
            'Zombies': [
              {'Type': 'RTID(CustomZombie@CurrentLevel)', 'Row': 1},
            ],
          },
        );
        final level = PvzLevelFile(
          objects: [
            event,
            PvzObject(
              aliases: ['CustomZombie'],
              objClass: 'ZombieType',
              objData: {'TypeName': 'tutorial'},
            ),
          ],
        );
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) {
                Future<void> edit(String rtid) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => Scaffold(
                        body: TextButton(
                          onPressed: () {
                            PvzAliasUtils.renameAlias(
                              levelFile: level,
                              oldAlias: 'CustomZombie',
                              newAlias: 'RenamedZombie',
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text('Finish rename'),
                        ),
                      ),
                    ),
                  );
                }

                return underwater
                    ? ZombieFishWaveEventScreen(
                        rtid: 'RTID(Spawn@CurrentLevel)',
                        levelFile: level,
                        onChanged: () {},
                        onBack: () {},
                        onRequestZombieSelection: (_) {},
                        onEditCustomZombie: edit,
                      )
                    : ZombieSpawnEventScreen(
                        rtid: 'RTID(Spawn@CurrentLevel)',
                        levelFile: level,
                        onChanged: () {},
                        onBack: () {},
                        onRequestZombieSelection: (_) {},
                        eventSubtitle: 'Spawn',
                        isGroundSpawner: false,
                        onEditCustomZombie: edit,
                      );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        final card = find.byType(ZombieIconCard);
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        final strings = lookupAppLocalizations(const Locale('en'));
        final edit = find.text(strings.editCustomZombieAlias('CustomZombie'));
        await tester.ensureVisible(edit);
        await tester.tap(edit);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Finish rename'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(
          find.text(strings.editCustomZombieAlias('RenamedZombie')),
          findsOneWidget,
          reason:
              'Stored: ${event.objData}; labels: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList()}',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  test(
    'rename conflicts distinguish event, module and generic aliases in all locales',
    () {
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: ['Event'],
            objClass: 'SpawnZombiesJitteredWaveActionProps',
            objData: {},
          ),
          PvzObject(
            aliases: ['Module'],
            objClass: 'SeedBankProperties',
            objData: {},
          ),
          PvzObject(aliases: ['Other'], objClass: 'OtherObject', objData: {}),
        ],
      );
      for (final locale in ['zh', 'en', 'ru']) {
        final strings = lookupAppLocalizations(Locale(locale));
        expect(
          aliasRenameFailureMessage(level, 'Event', strings),
          strings.renameEventFail,
        );
        expect(
          aliasRenameFailureMessage(level, 'Module', strings),
          strings.renameModuleFail,
        );
        expect(
          aliasRenameFailureMessage(level, 'Other', strings),
          strings.renameAliasFail,
        );
        expect(strings.copyEventAliasFail, isNot(strings.renameEventFail));
      }
    },
  );
  testWidgets('renaming a new custom zombie updates wave references', (
    tester,
  ) async {
    final type = PvzObject(
      aliases: ['CustomZombie'],
      objClass: 'ZombieType',
      objData: ZombieTypeData(
        typeName: 'tutorial',
        properties: 'RTID(CustomProps@CurrentLevel)',
      ).toJson(),
    );
    final spawn = PvzObject(
      aliases: ['Spawn'],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: {
        'Zombies': [
          {'Type': 'RTID(CustomZombie@CurrentLevel)'},
        ],
      },
    );
    final level = PvzLevelFile(
      objects: [
        type,
        spawn,
        PvzObject(
          aliases: ['CustomProps'],
          objClass: 'ZombiePropertySheet',
          objData: ZombiePropertySheetData().toJson(),
        ),
      ],
    );
    await tester.pumpWidget(
      app(
        CustomZombiePropertiesScreen(
          rtid: 'RTID(CustomZombie@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.byType(EditorAliasInputField),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, 'RenamedZombie');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    expect(type.aliases, ['RenamedZombie']);
    expect(
      (spawn.objData as Map)['Zombies'][0]['Type'],
      'RTID(RenamedZombie@CurrentLevel)',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('raw search centers wrapped matches and navigates both ways', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['Text'],
          objClass: 'Fixture',
          objData: {
            'Lines': List.generate(
              100,
              (i) => i == 35 || i == 70
                  ? 'find_this_marker'
                  : 'Long wrapped source line $i ${'abcdefghij' * 12}',
            ),
          },
        ),
      ],
    );
    await tester.pumpWidget(
      app(
        JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'find_this_marker');
    await tester.pumpAndSettle();
    final paragraphFinder = find.byWidgetPredicate(
      (w) =>
          w is RichText &&
          w.text.toPlainText().contains('Long wrapped source line 99'),
    );
    final paragraph = tester.renderObject<RenderParagraph>(paragraphFinder);
    final text = paragraph.text.toPlainText();
    final scrollableFinder = find
        .ancestor(of: paragraphFinder, matching: find.byType(Scrollable))
        .first;
    final scrollable = tester.state<ScrollableState>(scrollableFinder);
    void expectCentered(int offset) {
      final box = paragraph
          .getBoxesForSelection(
            TextSelection(baseOffset: offset, extentOffset: offset + 16),
          )
          .first
          .toRect();
      final center = paragraph.localToGlobal(box.center).dy;
      final viewport = tester.getRect(scrollableFinder);
      expect(center, closeTo(viewport.center.dy, 3));
    }

    final firstOffset = scrollable.position.pixels;
    expect(firstOffset, greaterThan(0));
    expectCentered(text.indexOf('find_this_marker'));
    await tester.tap(find.byTooltip('Next match'));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(firstOffset));
    expectCentered(text.lastIndexOf('find_this_marker'));
    await tester.tap(find.byTooltip('Previous match'));
    await tester.pumpAndSettle();
    expectCentered(text.indexOf('find_this_marker'));
    expect(tester.takeException(), isNull);
  });
}
