import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/initial_plant_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ResourceNames.ensureLoaded);

  testWidgets('plant state picker preserves legacy values until changed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final module = PvzObject(
      aliases: const ['InitialPlants'],
      objClass: 'InitialPlantProperties',
      objData: InitialPlantPropertiesData(
        placements: [
          InitialPlantPlacementData(typeName: 'walnut'),
          InitialPlantPlacementData(typeName: 'peashooter', condition: 'chill'),
        ],
      ).toJson(),
    );
    var saves = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: InitialPlantPropertiesScreen(
          rtid: 'RTID(InitialPlants@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module]),
          onChanged: () => saves++,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('无状态'), findsOneWidget);

    final legacyCard = find.text('冰减速');
    final dropdown = find.byType(DropdownButton<String>);
    final save = find.widgetWithText(FilledButton, '保存');
    await tester.ensureVisible(legacyCard);
    await tester.tap(legacyCard);
    await tester.pumpAndSettle();
    final choices = tester.widget<DropdownButton<String>>(dropdown).items!;
    expect(choices.map((item) => item.value), [
      '',
      'froststage1',
      'froststage2',
      'icecubed',
      'shadowboosted',
    ]);
    expect(choices.map((item) => (item.child as Text).data), [
      '无状态 (null)',
      '轻度积冰',
      '重度积冰',
      '完全冻住',
      '暗影状态',
    ]);

    Object? savedCondition() {
      final data = module.objData as Map;
      final placements = data['InitialPlantPlacements'] as List;
      return (placements.last as Map)['Condition'];
    }

    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saves, 1);
    expect(savedCondition(), 'chill');

    await tester.tap(legacyCard);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('重度积冰').last);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saves, 2);
    expect(savedCondition(), 'froststage2');

    await tester.tap(find.text('重度积冰'));
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('无状态 (null)').last);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(savedCondition(), isNull);
    expect(tester.takeException(), isNull);
  });
}
