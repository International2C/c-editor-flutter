import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/warning_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/glacier_module_screen.dart';
import 'package:c_editor/screens/editor/modules/zombie_sun_drop_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('zh')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets(
    'glacier entry keeps weight and level visible on narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['GlacierModule'],
            objClass: 'GlacierModuleProperties',
            objData: GlacierModulePropertiesData(
              zombieSpawnData: [
                GlacierColumnSpawnData(
                  entries: [
                    GlacierSpawnEntryData(
                      typeName: 'mummy',
                      weight: 2,
                      level: 4,
                    ),
                  ],
                ),
              ],
            ).toJson(),
          ),
        ],
      );

      await tester.pumpWidget(
        _localizedApp(
          GlacierModuleScreen(
            rtid: 'RTID(GlacierModule@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
      );

      final weight = find.byKey(const ValueKey('glacierZombieWeight'));
      final levelField = find.byKey(const ValueKey('lv_mummy_4'));
      expect(weight, findsOneWidget);
      expect(levelField, findsOneWidget);
      expect(tester.getTopRight(weight).dx, lessThanOrEqualTo(360));
      expect(tester.getTopRight(levelField).dx, lessThanOrEqualTo(360));

      await tester.tap(levelField);
      await tester.pumpAndSettle();
      final levelItems = tester.widgetList<DropdownMenuItem<int>>(
        find.byWidgetPredicate((widget) => widget is DropdownMenuItem<int>),
      );
      final availableLevels = levelItems.map((item) => item.value).toSet();
      expect(availableLevels, containsAll(<int>{0, 1, 2, 3, 4}));
      expect(availableLevels, isNot(contains(5)));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'sun drop editor shows tiers 1 through 6 and preserves ten values',
    (tester) async {
      final originalValues = List<int>.generate(10, (index) => index + 10);
      final module = PvzObject(
        aliases: const ['RiftTimedSun'],
        objClass: 'LevelMutatorRiftTimedSunProps',
        objData: RiftTimedSunModuleData(
          sunDrops: [
            RiftTimedSunData(
              zombieTypeName: 'RTID(mummy@ZombieTypes)',
              sunDropValues: originalValues,
            ),
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [module]);

      await tester.pumpWidget(
        _localizedApp(
          ZombieSunDropModuleScreen(
            rtid: 'RTID(RiftTimedSun@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('默认掉落: 10 阳光'));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      for (var tier = 1; tier <= 6; tier++) {
        expect(
          find.descendant(of: dialog, matching: find.text('$tier阶')),
          findsOneWidget,
        );
      }
      expect(find.text('7阶'), findsNothing);
      expect(
        find.descendant(of: dialog, matching: find.byType(TextField)),
        findsNWidgets(6),
      );

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      final saved = RiftTimedSunModuleData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      ).sunDrops.single.sunDropValues;
      expect(saved, originalValues);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('glacier compatibility warnings use independent titles', (
    tester,
  ) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: LevelSettingsTab(
                levelDef: LevelDefinitionData(),
                objectMap: const {},
                issues: [
                  LevelWarning(
                    id: 'glacierModuleCompatibilityWarning',
                    severity: LevelWarningSeverity.warning,
                    title: l10n.glacierModuleCompatibilityWarningTitle,
                    message: l10n.glacierModuleCompatibilityWarning,
                  ),
                  LevelWarning(
                    id: 'glacierModuleUnderwaterWarning',
                    severity: LevelWarningSeverity.warning,
                    title: l10n.glacierModuleUnderwaterWarningTitle,
                    message: l10n.glacierModuleUnderwaterWarning,
                  ),
                  LevelWarning(
                    id: 'iceAgePlantPuzzleWarning',
                    severity: LevelWarningSeverity.warning,
                    title: l10n.iceAgePlantPuzzleVariationWarningTitle,
                    message: l10n.iceAgePlantPuzzleVariationWarning,
                  ),
                ],
                onEditBasicInfo: () {},
                onEditModule: (_) {},
                onRemoveModule: (_) {},
                onReorderModules:
                    ({
                      required isCoreSection,
                      required oldIndex,
                      required newIndex,
                    }) {},
                onNavigateToAddModule: () {},
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('模块使用条件提示'), findsOneWidget);
    expect(find.text('海底世界外观不兼容'), findsOneWidget);
    expect(find.text('植物迷阵变体无需冰堆模块'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('iceAgePlantPuzzleWarning')),
      findsOneWidget,
    );
    expect(find.textContaining('不建议在海底世界外观的地图中使用冰河世界僵王'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
