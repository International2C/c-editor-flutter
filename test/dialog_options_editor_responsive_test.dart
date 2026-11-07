import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/fish_properties_entry_screen.dart';
import 'package:c_editor/screens/editor/modules/bronze_module_screen.dart';
import 'package:c_editor/screens/editor/modules/initial_plant_entry_screen.dart';
import 'package:c_editor/screens/editor/others/custom_fish_properties_screen.dart';
import 'package:c_editor/screens/editor/others/custom_zombie_properties_screen.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpEditor(
  WidgetTester tester,
  Widget editor, {
  required double width,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 2200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: editor,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _resize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
}

AppLocalizations _strings(WidgetTester tester, Type screen) =>
    AppLocalizations.of(tester.element(find.byType(screen)))!;

Finder _dialogText(String text) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

void main() {
  setUpAll(ResourceNames.ensureLoaded);

  for (final size in [const Size(320, 700), const Size(900, 280)]) {
    testWidgets('bronze choices remain readable and selectable at $size', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: ['BronzeProps'],
        objClass: 'BronzeProperties',
        objData: BronzePropertiesData().toJson(),
      );
      final level = PvzLevelFile(objects: [module]);
      var changed = 0;
      await _pumpEditor(
        tester,
        BronzeModuleScreen(
          rtid: 'RTID(BronzeProps@CurrentLevel)',
          levelFile: level,
          onChanged: () => changed++,
          onBack: () {},
        ),
        width: size.width,
      );
      await tester.ensureVisible(find.byType(AddItemCard));
      await tester.tap(find.byType(AddItemCard));
      await tester.pumpAndSettle();
      await _resize(tester, size);

      expect(
        tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
        true,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(EditorOptionTile),
        ),
        findsNWidgets(3),
      );
      final lastChoice = _dialogText(
        ResourceNames.lookup(
          tester.element(find.byType(AlertDialog)),
          'zombie_kongfu_agile_bronze',
        ),
      );
      await tester.ensureVisible(lastChoice);
      await tester.pumpAndSettle();
      if (size.width < 400) {
        expect(
          tester.getSize(lastChoice).width,
          greaterThan(tester.getSize(find.byType(AlertDialog)).width * 0.7),
        );
      }
      expect(tester.takeException(), isNull);
      await tester.tap(lastChoice);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      final data = BronzePropertiesData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      );
      expect(data.data.single.itemList.single.kind, BronzeStatueKind.agile);
      expect(changed, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom fish options and edit actions scroll at $size', (
      tester,
    ) async {
      final aliases = List.generate(
        16,
        (i) => 'CustomFishWithAnIntentionallyLongCodename$i',
      );
      final level = PvzLevelFile(
        objects: [
          for (final alias in aliases)
            PvzObject(
              aliases: [alias],
              objClass: 'CreatureType',
              objData: {'TypeName': 'test_fish'},
            ),
        ],
      );
      var fishes = [
        FishSpawnData(
          type: 'RTID(${aliases.first}@CurrentLevel)',
          position: FishPositionData(mX: 0, mY: 0),
        ),
      ];
      await _pumpEditor(
        tester,
        FishPropertiesEntryScreen(
          levelFile: level,
          fishes: fishes,
          onChanged: (value) => fishes = value,
          onBack: () {},
          onEditCustomFish: (_) {},
        ),
        width: size.width,
      );
      final strings = _strings(tester, FishPropertiesEntryScreen);
      final card = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_FishIconCard',
      );
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      await _resize(tester, size);
      final edit = find.text(strings.editCustomFishProperties);
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      expect(tester.getRect(edit).bottom, lessThanOrEqualTo(size.height));
      expect(tester.takeException(), isNull);
      final switchAction = find.byIcon(Icons.swap_horiz);
      await tester.ensureVisible(switchAction);
      await tester.tap(switchAction);
      await tester.pumpAndSettle();

      final options = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(EditorOptionTile),
      );
      expect(options, findsNWidgets(aliases.length - 1));
      expect(
        tester
            .widgetList<EditorOptionTile>(options)
            .map((option) => (option.title as Text).data),
        orderedEquals(aliases.skip(1)),
      );
      final lastChoice = _dialogText(aliases.last);
      await tester.ensureVisible(lastChoice);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(lastChoice);
      await tester.pumpAndSettle();
      expect(fishes.single.type, 'RTID(${aliases.last}@CurrentLevel)');
      expect(fishes.single.position.mX, 0);
      expect(fishes.single.position.mY, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('short custom zombie size dialog preserves confirm and cancel', (
    tester,
  ) async {
    final props = PvzObject(
      aliases: ['CustomProps'],
      objClass: 'ZombiePropertySheet',
      objData: ZombiePropertySheetData(sizeType: 'mid').toJson(),
    );
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['CustomZombie'],
          objClass: 'ZombieType',
          objData: ZombieTypeData(
            typeName: 'tutorial',
            properties: 'RTID(CustomProps@CurrentLevel)',
          ).toJson(),
        ),
        props,
      ],
    );
    var changed = 0;
    await _pumpEditor(
      tester,
      CustomZombiePropertiesScreen(
        rtid: 'RTID(CustomZombie@CurrentLevel)',
        levelFile: level,
        onChanged: () => changed++,
        onBack: () {},
      ),
      width: 900,
    );
    final strings = _strings(tester, CustomZombiePropertiesScreen);
    final sizeField = find.text(strings.sizeType);
    await tester.ensureVisible(sizeField);
    await tester.tap(sizeField);
    await tester.pumpAndSettle();
    await _resize(tester, const Size(900, 280));
    await tester.ensureVisible(_dialogText('large'));
    await tester.tap(_dialogText('large'));
    await tester.pumpAndSettle();
    expect((props.objData as Map)['SizeType'], 'mid');
    await tester.tap(_dialogText(strings.cancel));
    await tester.pumpAndSettle();
    expect((props.objData as Map)['SizeType'], 'mid');
    expect(changed, 0);
    await tester.ensureVisible(sizeField);
    await tester.tap(sizeField);
    await tester.pumpAndSettle();
    await tester.ensureVisible(_dialogText('large'));
    await tester.tap(_dialogText('large'));
    await tester.pumpAndSettle();
    await tester.tap(_dialogText(strings.ok));
    await tester.pumpAndSettle();
    expect((props.objData as Map)['SizeType'], 'large');
    expect(changed, 1);
    expect(tester.takeException(), isNull);
  });

  for (final isFish in [false, true]) {
    testWidgets(
      'custom ${isFish ? 'fish' : 'zombie'} fields clear the footer with the keyboard open',
      (tester) async {
        final props = PvzObject(
          aliases: ['CustomProps'],
          objClass: isFish ? 'CreatureFishProperties' : 'ZombiePropertySheet',
          objData: {
            'HitRect': {'mX': 1, 'mY': 2, 'mWidth': 3, 'mHeight': 4},
          },
        );
        final level = PvzLevelFile(
          objects: [
            PvzObject(
              aliases: ['CustomType'],
              objClass: isFish ? 'CreatureType' : 'ZombieType',
              objData: {
                'TypeName': 'test_type',
                'Properties': 'RTID(CustomProps@CurrentLevel)',
              },
            ),
            props,
          ],
        );
        const rtid = 'RTID(CustomType@CurrentLevel)';
        void noop() {}
        final screen = isFish
            ? CustomFishPropertiesScreen(
                rtid: rtid,
                levelFile: level,
                onChanged: noop,
                onBack: noop,
              )
            : CustomZombiePropertiesScreen(
                rtid: rtid,
                levelFile: level,
                onChanged: noop,
                onBack: noop,
              );
        await _pumpEditor(tester, screen, width: 430);
        addTearDown(tester.view.resetViewInsets);
        final strings = _strings(tester, screen.runtimeType);
        final labels = [
          isFish ? strings.fishPropHitRect : strings.hitRect,
          if (!isFish) strings.shadowOffset,
        ];
        for (final label in labels) {
          final field = find.text(label);
          await tester.ensureVisible(field);
          await tester.tap(field);
          await tester.pumpAndSettle();
          final dialog = find.byType(AlertDialog);
          final dialogFields = find.descendant(
            of: dialog,
            matching: find.byType(TextField),
          );
          await tester.showKeyboard(dialogFields.first);
          tester.view.physicalSize = const Size(430, 500);
          tester.view.viewInsets = const FakeViewPadding(bottom: 220);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final confirm = find.widgetWithText(FilledButton, strings.ok);
          final close = find.widgetWithText(TextButton, strings.cancel);
          final confirmBounds = tester.getRect(confirm);
          expect(confirmBounds.bottom, lessThanOrEqualTo(280));
          await tester.ensureVisible(dialogFields.last);
          await tester.pumpAndSettle();
          expect(dialogFields.last.hitTestable(), findsOneWidget);
          expect(
            tester.getBottomRight(dialogFields.last).dy,
            lessThanOrEqualTo(confirmBounds.top),
          );
          expect(tester.getRect(confirm), confirmBounds);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(dialog, findsNothing);
          tester.view.resetViewInsets();
          await _resize(tester, const Size(430, 2200));
        }
      },
    );
  }

  testWidgets('short initial plant editor keeps actions below the fields', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: ['InitialPlantEntry'],
      objClass: 'InitialPlantEntryProperties',
      objData: InitialPlantEntryData(
        plants: [InitialPlantData(plantTypes: ['peashooter'])],
      ).toJson(),
    );
    await _pumpEditor(
      tester,
      InitialPlantEntryScreen(
        rtid: 'RTID(InitialPlantEntry@CurrentLevel)',
        levelFile: PvzLevelFile(objects: [module]),
        onChanged: () {},
        onBack: () {},
      ),
      width: 420,
    );
    final strings = _strings(tester, InitialPlantEntryScreen);
    await tester.tap(find.text(strings.costumeOff));
    await tester.pumpAndSettle();
    await _resize(tester, const Size(420, 360));

    final dialog = find.byType(AlertDialog);
    final cancel = find.widgetWithText(TextButton, strings.cancel);
    final save = find.widgetWithText(FilledButton, strings.save);
    expect(tester.takeException(), isNull);
    final viewport = find.descendant(
      of: dialog,
      matching: find.byType(SingleChildScrollView),
    );
    final footer = tester.getRect(save);
    expect(tester.getRect(viewport).bottom, lessThanOrEqualTo(footer.top));
    final costume = find.byType(Switch);
    await tester.ensureVisible(costume);
    await tester.pumpAndSettle();
    expect(costume.hitTestable(), findsOneWidget);
    expect(tester.getRect(save), footer);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('template header and long choices share short-screen scrolling', (
    tester,
  ) async {
    final aliases = List.generate(
      20,
      (index) => 'AnIntentionallyLongTemplateActionCodename$index',
    );
    final catalog = ZombossMechCatalogEntry(
      id: 'ResponsiveTestMech',
      icon: 'unknown.webp',
      defaultPhaseCount: 1,
      variations: [],
      editableInstance: 'responsive_test_mech',
      editableInstancePropsName: 'ResponsiveTestMechProps',
      actions: [
        ZombossMechObjclassGroup(
          objclass: 'TestActionDefinition',
          tag: 'attack',
          fields: const [
            ZombossMechFieldSpec(name: 'Weight', type: 'int', defaultValue: 1),
          ],
          implementations: {
            for (var i = 0; i < aliases.length; i++) aliases[i]: {'Weight': i},
          },
        ),
      ],
      properties: [],
    );
    final action = PvzObject(
      aliases: ['ExistingAction'],
      objClass: 'TestActionDefinition',
      objData: {'Weight': 0},
    );
    final level = PvzLevelFile(objects: [action]);
    await _pumpEditor(
      tester,
      CustomZombossMechActionEditorScreen(
        catalog: catalog,
        levelFile: level,
        existingRtid: 'RTID(ExistingAction@CurrentLevel)',
      ),
      width: 900,
    );
    final strings = _strings(tester, CustomZombossMechActionEditorScreen);
    await tester.ensureVisible(
      find.text(strings.zombossMechRecreateFromTemplate),
    );
    await tester.tap(find.text(strings.zombossMechRecreateFromTemplate));
    await tester.pumpAndSettle();
    await _resize(tester, const Size(900, 280));
    final scrollable = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsOneWidget);
    final lastChoice = find.byWidgetPredicate(
      (widget) =>
          widget is EditorOptionTile &&
          widget.title is Text &&
          (widget.title as Text).data == aliases.last,
    );
    await tester.scrollUntilVisible(lastChoice, 180, scrollable: scrollable);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(lastChoice);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
      true,
    );
    expect((action.objData as Map)['Weight'], 0);
    await tester.tap(_dialogText(strings.cancel));
    await tester.pumpAndSettle();
    expect((action.objData as Map)['Weight'], 0);
    expect(tester.takeException(), isNull);
  });
}
