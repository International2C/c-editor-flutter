import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/screens/editor/basic_info_screen.dart';
import 'package:c_editor/screens/editor/others/custom_portal_properties_screen.dart';
import 'package:c_editor/screens/select/music_suffix_selection_screen.dart';
import 'package:c_editor/screens/select/stage_resource_group_import_screen.dart';
import 'package:c_editor/screens/select/stage_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await MusicSuffixCatalog.init();
    await StageRepository.init();
    await StageCatalogRepository.init();
    await CustomStagePresetRepository.init();
  });

  Future<void> setNarrowView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget maxTextApp(Widget home) {
    return MaterialApp(
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        );
      },
      home: home,
    );
  }

  test('unused BGMe and circus music suffixes are not selectable', () {
    expect(MusicSuffixCatalog.orderedCodes, isNot(contains('BGMe')));
    expect(MusicSuffixCatalog.orderedCodes, isNot(contains('circus')));
  });

  test('Roman music entries use the requested order and their own icons', () {
    final codes = MusicSuffixCatalog.orderedCodes;
    expect(codes[codes.indexOf('TeamBoss') + 1], 'TeamBossRoman');
    expect(codes[codes.indexOf('SilkRoad') + 1], 'Roman');
    expect(
      MusicSuffixCatalog.iconAsset('TeamBossRoman'),
      'assets/images/round_icons/Suffix_TeamBossRoman.webp',
    );
    expect(
      MusicSuffixCatalog.iconAsset('Roman'),
      'assets/images/round_icons/Suffix_Roman.webp',
    );
  });

  testWidgets('lawn and music grids contain maximum-scale text', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      maxTextApp(
        StageSelectionScreen(
          currentStageRtid: 'RTID(EgyptStage@LevelModules)',
          levelFile: PvzLevelFile(objects: []),
          onStageSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      maxTextApp(
        MusicSuffixSelectionScreen(
          currentCodename: '',
          onCodenameSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('preset custom lawns stack details below the image', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      maxTextApp(
        StageSelectionScreen(
          currentStageRtid: 'RTID(EgyptStage@LevelModules)',
          levelFile: PvzLevelFile(objects: []),
          onStageSelected: (_) {},
          onBack: () {},
          onCreateCustomStage: () {},
          onCreateCustomStageFromPreset: (_) async => null,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    final preset = CustomStagePresetRepository.presets.first;
    await tester.scrollUntilVisible(
      find.text(preset.alias),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    final iconRect = tester.getRect(find.byType(AssetImageWidget).first);
    final aliasRect = tester.getRect(find.text(preset.alias));
    expect(aliasRect.top, greaterThan(iconRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('preset-derived custom lawn uses the purple C badge', (
    tester,
  ) async {
    final preset = CustomStagePresetRepository.presets.first;
    final derivedData =
        CustomStageLevelUtils.cloneJson(preset.objdata) as Map<String, dynamic>;
    derivedData['MusicSuffix'] = 'customized_from_preset';
    final stageObject = PvzObject(
      aliases: [preset.alias],
      objClass: preset.objclass,
      objData: derivedData,
    );
    final levelDef = LevelDefinitionData(
      stageModule: 'RTID(${preset.alias}@CurrentLevel)',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BasicInfoScreen(
          levelFile: PvzLevelFile(objects: [stageObject]),
          levelDef: levelDef,
          onBack: () {},
          onStageTap: null,
          onChanged: () {},
        ),
      ),
    );
    await tester.pump();

    final badge = tester.widget<CustomResourceBadge>(
      find.byType(CustomResourceBadge),
    );
    expect(badge.color, const Color(0xFF6A1B9A));
    expect(tester.takeException(), isNull);
  });

  testWidgets('resource warning can open the lawn picker on Custom', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: StageSelectionScreen(
          currentStageRtid: 'RTID(EgyptStage@LevelModules)',
          levelFile: PvzLevelFile(objects: []),
          openCustomSection: true,
          onStageSelected: (_) {},
          onBack: () {},
          onCreateCustomStage: () {},
          onCreateCustomStageFromPreset: (_) async => null,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Create custom lawn'), findsOneWidget);
  });

  testWidgets('resource group import exposes custom lawn presets', (
    tester,
  ) async {
    await setNarrowView(tester);
    List<String>? importedGroups;
    Map<String, dynamic>? importedSource;
    await tester.pumpWidget(
      MaterialApp(
        home: StageResourceGroupImportScreen(
          mode: StageResourceGroupImportMode.fromStage,
          existingGroups: const {},
          onImport:
              ({
                required groups,
                sourceStageAlias,
                sourceStageObjdata,
                applySourceLawnAppearance = false,
              }) {
                importedGroups = groups;
                importedSource = sourceStageObjdata;
              },
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final tagScroller = find.descendant(
      of: find.byKey(const ValueKey('horizontalTagScrollerScrollbar')),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(tagScroller, const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom Presets'));
    await tester.pumpAndSettle();

    final preset = CustomStagePresetRepository.presets.first;
    expect(find.text(preset.alias), findsOneWidget);
    expect(find.byType(CustomResourceBadge), findsWidgets);
    await tester.tap(find.text(preset.alias));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    final expectedGroups = <String>{
      ...CustomStageLevelUtils.stringList(preset.objdata['ResourceGroupNames']),
      ...CustomStageLevelUtils.stringList(
        preset.objdata['GroupsToUnloadForAds'],
      ),
    };
    expect(importedGroups, containsAll(expectedGroups));
    expect(importedSource, equals(preset.objdata));
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom portal animation uses the separated picker', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomPortalPropertiesScreen(
          levelFile: PvzLevelFile(objects: []),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SeparatedOptionPickerField<String>), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
