import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_auto_composer.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('composer follows the Moon appearance part of a custom lawn', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final banners = (await tester.runAsync(StageBannerResolver.load))!;
    for (final objclass in ['MoonStageProperties', 'EgyptStageProperties']) {
      final stage = PvzObject(
        aliases: const ['CustomMoon'],
        objClass: objclass,
        objData: {'BackgroundImagePrefix': 'IMAGE_BACKGROUNDS_MOON'},
      );
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            objClass: 'LevelDefinition',
            objData: {'StageModule': 'RTID(CustomMoon@CurrentLevel)'},
          ),
          stage,
        ],
      );
      for (final secondPart in [false, true, false]) {
        CustomStageLevelUtils.applyMoonPart2Appearance(
          stage.objData as Map<String, dynamic>,
          enabled: secondPart,
        );
        final document = (await tester.runAsync(
          () => PreviewAutoComposer(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            fileName: 'moon.json',
            banners: banners,
            featureGroups: PreviewFeatureGroups.forTest(groups: const []),
          ).compose(),
        ))!;
        expect(document.banner.stem, secondPart ? 'Moon2' : 'Moon');
        expect(
          document.banner.assetPath,
          banners.assetPathForStem(secondPart ? 'Moon2' : 'Moon'),
        );
      }
    }
    expect(banners.resolveStem('MoonStage'), 'Moon');
    expect(
      banners.resolveStem(
        'MoonGrappleStage',
        stageObjdata: {
          'BackgroundImagePrefix': 'IMAGE_BACKGROUNDS_MOONGRAPPLE',
          'BackgroundImageMiddle': 'MOONPART2',
          'BackgroundImageRight': 'MOONPART2_RIGHT',
        },
      ),
      'MoonGrapple',
    );
  });

  group('preview generator available width', () {
    test('uses the actual width threshold', () {
      expect(
        isPreviewGeneratorWidthAvailable(kPreviewGeneratorMinimumWidth - 1),
        isFalse,
      );
      expect(
        isPreviewGeneratorWidthAvailable(kPreviewGeneratorMinimumWidth),
        isTrue,
      );
    });

    test('uses rotation guidance only on native mobile platforms', () {
      expect(
        useMobilePreviewGeneratorNarrowPrompt(platform: TargetPlatform.android),
        isTrue,
      );
      expect(
        useMobilePreviewGeneratorNarrowPrompt(platform: TargetPlatform.windows),
        isFalse,
      );
      expect(
        useMobilePreviewGeneratorNarrowPrompt(
          platform: TargetPlatform.android,
          isWeb: true,
        ),
        isFalse,
      );
    });
  });

  testWidgets('seed-bank plants and IZombie zombies use distinct sources', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    Future<PreviewDocument> composeSeedBank(Map<String, dynamic> mode) {
      final seedBank = PvzObject(
        aliases: const ['SeedBank'],
        objClass: 'SeedBankProperties',
        objData: {
          ...mode,
          'PresetPlantList': [mode.isEmpty ? 'peashooter' : 'tutorial'],
        },
      );
      return PreviewAutoComposer(
        levelFile: PvzLevelFile(objects: [seedBank]),
        parsed: ParsedLevelData(objectMap: {'SeedBank': seedBank}),
        fileName: 'source-labels.json',
        banners: StageBannerResolver.forTest(stages: const {}),
        featureGroups: PreviewFeatureGroups.forTest(groups: const []),
        seedBankLabel: '卡槽植物',
        zombieSeedBankLabel: '卡槽僵尸',
      ).compose();
    }

    // Repository initialization reads assets outside the widget fake clock.
    final plantDocument = (await tester.runAsync(() => composeSeedBank({})))!;
    final plants = plantDocument.layerById('plants')!;
    expect(plants.items.single.sourceLabel, '卡槽植物');
    expect(plants.sourceLabel, '卡槽植物');

    for (final mode in [
      <String, dynamic>{'ZombieMode': true},
      <String, dynamic>{'SeedPacketType': 'UIIZombieSeedPacket'},
    ]) {
      final zombieDocument = (await tester.runAsync(
        () => composeSeedBank(mode),
      ))!;
      final zombies = zombieDocument.layerById('zombies')!;
      expect(zombieDocument.layerById('plants'), isNull);
      expect(zombies.items.single.sourceLabel, '卡槽僵尸');
      expect(zombies.sourceLabel, '卡槽僵尸');
    }
  });

  group('preview canvas sub-elements', () {
    PreviewItem item(String id) =>
        PreviewItem(id: id, assetPath: 'assets/meta/icon.png');

    test('larger icon rows require more intrinsic space', () {
      final items = [for (var i = 0; i < 6; i++) item('item_$i')];
      final small = previewIconGridIntrinsicSize(
        maxWidth: 180,
        sections: [PreviewIconSection(items: items, iconSize: 20)],
        showChrome: false,
      );
      final large = previewIconGridIntrinsicSize(
        maxWidth: 180,
        sections: [PreviewIconSection(items: items, iconSize: 60)],
        showChrome: false,
      );

      expect(large.height, greaterThan(small.height));
    });

    test('simple layout grows sparse icon groups to banner scale', () {
      final sections = [
        PreviewIconSection(items: [item('one'), item('two')], iconSize: 36),
      ];

      fitSimplePreviewIconSections(
        sections: sections,
        maxWidth: kPreviewCanvasSize.width * 0.40,
      );
      final size = previewIconGridIntrinsicSize(
        maxWidth: kPreviewCanvasSize.width * 0.40,
        sections: sections,
        showChrome: false,
      );

      expect(sections.single.iconSize, greaterThan(100));
      expect(
        size.height,
        greaterThanOrEqualTo(kPreviewCanvasSize.height * 0.34),
      );
    });

    test('simple layout shrinks dense icon groups to avoid overflow', () {
      final sections = [
        PreviewIconSection(
          items: [for (var i = 0; i < 80; i++) item('item_$i')],
          iconSize: 36,
        ),
      ];

      fitSimplePreviewIconSections(
        sections: sections,
        maxWidth: kPreviewCanvasSize.width * 0.40,
      );
      final size = previewIconGridIntrinsicSize(
        maxWidth: kPreviewCanvasSize.width * 0.40,
        sections: sections,
        showChrome: false,
      );

      expect(sections.single.iconSize, lessThan(36));
      expect(size.height, lessThanOrEqualTo(kPreviewCanvasSize.height * 0.58));
    });

    test('copy preserves contained text and rounded shape appearance', () {
      final layer = PreviewLayer(
        id: 'panel',
        kind: PreviewLayerKind.shape,
        shapeKind: PreviewShapeKind.rect,
        bounds: const Rect.fromLTWH(0.1, 0.1, 0.5, 0.5),
        cornerRadius: 10,
        strokeWidth: 0,
        containedTexts: [PreviewContainedText(id: 'caption', text: 'Caption')],
      );

      final copy = layer.copy();
      expect(copy.cornerRadius, 10);
      expect(copy.strokeWidth, 0);
      expect(copy.containedTexts.single.text, 'Caption');
      expect(
        copy.containedTexts.single,
        isNot(same(layer.containedTexts.single)),
      );
    });

    test('document snapshots preserve both rich styles and sub-elements', () {
      final document = PreviewDocument(
        banner: PreviewBannerRef(
          kind: PreviewBannerSourceKind.assetStem,
          stem: 'Modern',
        ),
        autoStyle: PreviewAutoStyle.simple,
        layers: [
          PreviewLayer(
            id: 'title',
            kind: PreviewLayerKind.text,
            bounds: const Rect.fromLTWH(0.05, 0.1, 0.4, 0.2),
            opacity: 0.7,
            textAlign: TextAlign.center,
            textBackgroundColor: Colors.black,
            textRuns: [
              PreviewTextRun(
                text: 'Title',
                style: PreviewTextStyleData(
                  fontSize: 40,
                  outlineColor: Colors.red,
                  outlineWidth: 5,
                ),
              ),
            ],
          ),
          PreviewLayer(
            id: 'panel',
            kind: PreviewLayerKind.iconGrid,
            bounds: const Rect.fromLTWH(0.5, 0.1, 0.4, 0.6),
            iconAlign: TextAlign.right,
            sections: [
              PreviewIconSection(items: [item('pea')], iconSize: 80),
            ],
            containedTexts: [
              PreviewContainedText(
                id: 'caption',
                text: 'Caption',
                style: PreviewTextStyleData(fontSize: 28),
              ),
            ],
          ),
          PreviewLayer(
            id: 'shape',
            kind: PreviewLayerKind.shape,
            bounds: const Rect.fromLTWH(0.1, 0.5, 0.3, 0.3),
            shapeKind: PreviewShapeKind.rect,
            shapeFilled: true,
            fillColor: Colors.green,
            strokeWidth: 0,
            cornerRadius: 12,
          ),
        ],
      );

      final snapshot = document.copy();
      document.banner.stem = 'Unknown';
      document.layerById('title')!.textRuns.single.style.fontSize = 60;
      document.layerById('panel')!.sections.single.iconSize = 36;
      document.layerById('panel')!.containedTexts.single.text = 'Edited';
      document.layerById('panel')!.containedTexts.single.style.fontSize = 48;
      document.layerById('shape')!.shapeFilled = false;
      document.layerById('shape')!.cornerRadius = 0;

      final title = snapshot.layerById('title')!;
      final panel = snapshot.layerById('panel')!;
      final shape = snapshot.layerById('shape')!;
      expect(snapshot.banner.stem, 'Modern');
      expect(snapshot.autoStyle, PreviewAutoStyle.simple);
      expect(title.opacity, 0.7);
      expect(title.textAlign, TextAlign.center);
      expect(title.textBackgroundColor, Colors.black);
      expect(title.textRuns.single.style.fontSize, 40);
      expect(title.textRuns.single.style.outlineColor, Colors.red);
      expect(title.textRuns.single.style.outlineWidth, 5);
      expect(panel.iconAlign, TextAlign.right);
      expect(panel.sections.single.iconSize, 80);
      expect(panel.containedTexts.single.text, 'Caption');
      expect(panel.containedTexts.single.style.fontSize, 28);
      expect(shape.shapeFilled, isTrue);
      expect(shape.fillColor, Colors.green);
      expect(shape.strokeWidth, 0);
      expect(shape.cornerRadius, 12);
    });

    testWidgets('selects an icon group and panel text independently', (
      tester,
    ) async {
      String? selectedLayer;
      PreviewTextPartSelection? selectedText;
      final layer = PreviewLayer(
        id: 'plants',
        kind: PreviewLayerKind.iconGrid,
        bounds: const Rect.fromLTWH(0.05, 0.05, 0.5, 0.6),
        gridTitle: 'Plants',
        sections: [
          PreviewIconSection(items: [item('pea')]),
        ],
        containedTexts: [PreviewContainedText(id: 'caption', text: 'Caption')],
      );
      final document = PreviewDocument(
        banner: PreviewBannerRef(
          kind: PreviewBannerSourceKind.assetStem,
          assetPath: 'assets/meta/icon.png',
        ),
        layers: [layer],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1200,
            height: 600,
            child: PreviewCanvas(
              document: document,
              interactive: true,
              selectedLayerId: layer.id,
              onSelectLayer: (id) => selectedLayer = id,
              onSelectTextPart: (selection) => selectedText = selection,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('preview-icon-item-plants-0-0-0')),
      );
      expect(selectedLayer, 'plants');

      await tester.tap(
        find.byKey(const ValueKey('preview-text-part-plants-grid-title')),
      );
      expect(selectedText?.kind, PreviewTextPartKind.gridTitle);

      await tester.tap(
        find.byKey(
          const ValueKey('preview-text-part-plants-contained-caption'),
        ),
      );
      expect(selectedText?.kind, PreviewTextPartKind.contained);
      expect(selectedText?.containedTextId, 'caption');
    });
  });

  group('sanitizePreviewFileBaseName', () {
    test('strips extension and illegal chars', () {
      expect(sanitizePreviewFileBaseName('My Level.json'), 'My Level');
      expect(sanitizePreviewFileBaseName('a/b:c*.png'), 'a_b_c_');
      expect(sanitizePreviewFileBaseName('   '), 'preview');
    });
  });

  group('PreviewExportPrefs.sanitizeFolderName', () {
    test('blocks path traversal and separators', () {
      expect(PreviewExportPrefs.sanitizeFolderName('previews'), 'previews');
      expect(PreviewExportPrefs.sanitizeFolderName('../x'), 'x');
      expect(PreviewExportPrefs.sanitizeFolderName(r'a\b/c'), 'a_b_c');
      expect(PreviewExportPrefs.sanitizeFolderName(''), 'previews');
    });
  });

  group('PreviewFeatureGroups', () {
    String localize(String key, String fallback) {
      const map = {
        'previewFeaturesPrefix': 'Особенности: ',
        'previewFeature_vasebreaker': 'Вазобой',
        'previewFeature_last_stand': 'Последний Выживший',
        'previewFeature_zomboss_mech': 'Бой с Зомботом',
        'previewFeature_conveyor': 'Конвейер',
      };
      return map[key] ?? fallback;
    }

    String moduleTitle(String objClass) {
      const map = {
        'LastStandMinigameProperties': 'Последний Выживший',
        'ZombossBattleModuleProperties': 'Бой с Зомботом',
        'ZombossLastStandMinigameProperties': 'Бой с Боссом',
        'ConveyorSeedBankProperties': 'Конвейер',
      };
      return map[objClass] ?? objClass;
    }

    test('groups vase modules into one feature', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'vasebreaker',
            nameKey: 'previewFeature_vasebreaker',
            fallbackName: 'Vasebreaker',
            objClasses: {
              'VaseBreakerPresetProperties',
              'VaseBreakerArcadeModuleProperties',
              'VaseBreakerFlowModuleProperties',
            },
          ),
          const PreviewFeatureGroup(
            id: 'last_stand',
            nameKey: 'previewFeature_last_stand',
            titleObjClass: 'LastStandMinigameProperties',
            fallbackName: 'Last Stand',
            objClasses: {'LastStandMinigameProperties'},
          ),
        ],
        excludeObjClasses: {'RiftThemeDemoModuleProperties'},
      );

      final subtitle = groups.buildSubtitle(
        [
          'VaseBreakerPresetProperties',
          'VaseBreakerArcadeModuleProperties',
          'VaseBreakerFlowModuleProperties',
          'LastStandMinigameProperties',
          'RiftThemeDemoModuleProperties',
        ],
        localize: localize,
        moduleTitle: moduleTitle,
      );

      expect(subtitle, 'Особенности: Вазобой, Последний Выживший');
    });

    test('collapses zomboss mech battle + intro', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'zomboss_mech',
            nameKey: 'previewFeature_zomboss_mech',
            titleObjClass: 'ZombossBattleModuleProperties',
            fallbackName: 'Zomboss Mech Battle',
            objClasses: {
              'ZombossBattleModuleProperties',
              'ZombossBattleIntroProperties',
            },
          ),
        ],
      );
      expect(
        groups.buildSubtitle(
          ['ZombossBattleModuleProperties', 'ZombossBattleIntroProperties'],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Особенности: Бой с Зомботом',
      );
    });

    test('picks first feature by module order within the same category', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'vasebreaker',
            nameKey: 'previewFeature_vasebreaker',
            fallbackName: 'Vasebreaker',
            objClasses: {
              'VaseBreakerPresetProperties',
              'VaseBreakerArcadeModuleProperties',
            },
          ),
          const PreviewFeatureGroup(
            id: 'last_stand',
            nameKey: 'previewFeature_last_stand',
            titleObjClass: 'LastStandMinigameProperties',
            fallbackName: 'Last Stand',
            objClasses: {'LastStandMinigameProperties'},
          ),
        ],
      );
      expect(
        groups.firstFeatureLabel(
          ['LastStandMinigameProperties', 'VaseBreakerArcadeModuleProperties'],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Последний Выживший',
      );
      expect(
        groups.firstFeatureLabel(
          ['VaseBreakerArcadeModuleProperties'],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Вазобой',
      );
    });

    test('includes conveyor and zomboss groups', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'zomboss_mech',
            nameKey: 'previewFeature_zomboss_mech',
            titleObjClass: 'ZombossBattleModuleProperties',
            fallbackName: 'Zomboss Mech Battle',
            objClasses: {
              'ZombossBattleModuleProperties',
              'ZombossBattleIntroProperties',
            },
          ),
          const PreviewFeatureGroup(
            id: 'zomboss_non_mech',
            nameKey: 'previewFeature_zomboss_non_mech',
            titleObjClass: 'ZombossLastStandMinigameProperties',
            fallbackName: 'Non-mech Zomboss Battle',
            objClasses: {'ZombossLastStandMinigameProperties'},
          ),
          const PreviewFeatureGroup(
            id: 'conveyor',
            nameKey: 'previewFeature_conveyor',
            titleObjClass: 'ConveyorSeedBankProperties',
            fallbackName: 'Conveyor Belt',
            objClasses: {'ConveyorSeedBankProperties'},
          ),
        ],
      );

      expect(
        groups.buildSubtitle(
          [
            'ZombossBattleIntroProperties',
            'ConveyorSeedBankProperties',
            'ZombossLastStandMinigameProperties',
          ],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Особенности: Бой с Зомботом, Бой с Боссом, Конвейер',
      );
      expect(
        groups.firstFeatureLabel(
          ['ConveyorSeedBankProperties', 'ZombossBattleModuleProperties'],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        // Upstream prioritizes Special Modes over base modules like Conveyor.
        'Бой с Зомботом',
      );
      expect(
        groups.firstFeatureLabel(
          ['ConveyorSeedBankProperties'],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Конвейер',
      );
    });
  });

  group('StageBannerResolver', () {
    test('uses map and default fallback', () {
      final r = StageBannerResolver.forTest(
        defaultStem: 'Unknown',
        stages: {
          'ModernStage': 'Modern',
          'BowlingStage': 'Modern',
          'LostVolcanoCustom': 'VolcanoLostCity',
        },
      );
      expect(r.resolveStem('ModernStage'), 'Modern');
      expect(r.resolveStem('BowlingStage'), 'Modern');
      expect(r.resolveStem('LostVolcanoCustom'), 'VolcanoLostCity');
      expect(r.resolveStem('MissingStage'), 'Unknown');
      expect(r.stageAliasesForStem('Modern'), ['ModernStage', 'BowlingStage']);
      expect(r.stageAliasesForStem('Unknown'), isEmpty);
      expect(
        r.orderedStemsForStageAliases(['LostVolcanoCustom', 'BowlingStage']),
        ['VolcanoLostCity', 'Modern', 'Unknown'],
      );
      expect(
        r.assetPathForStem('Unknown'),
        'lib/bundled_plugins/preview_img_cplugin/assets/banners/Unknown.png',
      );
      expect(
        r.roundIconAssetForStem('Unknown'),
        'assets/images/others/unknown.webp',
      );
      expect(r.roundIconAltCandidatesForStem('Unknown'), isEmpty);
    });
  });

  group('PreviewLayer text styles', () {
    PreviewLayer textLayer(List<PreviewTextRun> runs) => PreviewLayer(
      id: 't',
      kind: PreviewLayerKind.text,
      bounds: const Rect.fromLTWH(0, 0, 1, 1),
      textRuns: runs,
    );

    test('insert inherits previous character style', () {
      final small = PreviewTextStyleData(fontSize: 12);
      final large = PreviewTextStyleData(fontSize: 48);
      final layer = textLayer([
        PreviewTextRun(text: 'Ab', style: small),
        PreviewTextRun(text: 'C', style: large),
      ]);
      // Insert 'x' before C (after "Ab") → inherits small from 'b'.
      layer.updatePlainTextPreservingStyles('AbxC');
      expect(layer.plainText, 'AbxC');
      expect(layer.textRuns.length, 2);
      expect(layer.textRuns[0].text, 'Abx');
      expect(layer.textRuns[0].style.fontSize, 12);
      expect(layer.textRuns[1].text, 'C');
      expect(layer.textRuns[1].style.fontSize, 48);
    });

    test('insert at start inherits first character style', () {
      final small = PreviewTextStyleData(fontSize: 12);
      final large = PreviewTextStyleData(fontSize: 48);
      final layer = textLayer([
        PreviewTextRun(text: 'A', style: small),
        PreviewTextRun(text: 'B', style: large),
      ]);
      layer.updatePlainTextPreservingStyles('xAB');
      expect(layer.textRuns.first.style.fontSize, 12);
      expect(layer.textRuns.first.text, 'xA');
    });

    test('typingStyle override wins over inherited style', () {
      final small = PreviewTextStyleData(fontSize: 12);
      final layer = textLayer([PreviewTextRun(text: 'Hi', style: small)]);
      layer.updatePlainTextPreservingStyles(
        'Hi!',
        typingStyle: PreviewTextStyleData(fontSize: 64),
      );
      expect(layer.textRuns.length, 2);
      expect(layer.textRuns[0].style.fontSize, 12);
      expect(layer.textRuns[1].text, '!');
      expect(layer.textRuns[1].style.fontSize, 64);
    });
  });

  group('PreviewRichTextController', () {
    test('buildTextSpan keeps one style per run after typing', () {
      final controller = PreviewRichTextController();
      final layer = PreviewLayer(
        id: 't',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0, 0, 1, 1),
        textRuns: [
          PreviewTextRun(
            text: 'Hi',
            style: PreviewTextStyleData(
              fontFamily: kPreviewCustomFontFamily,
              fontSize: 36,
            ),
          ),
        ],
      );
      controller.loadFromLayer(layer);
      controller.value = TextEditingValue(
        text: 'Hi!',
        selection: const TextSelection.collapsed(offset: 3),
      );
      expect(controller.runs, hasLength(1));
      expect(controller.runs.single.style.fontFamily, kPreviewCustomFontFamily);
      expect(controller.runs.single.style.fontSize, 36);
      controller.dispose();
    });

    test('styleAtCaret uses previous character', () {
      final controller = PreviewRichTextController();
      controller.loadFromLayer(
        PreviewLayer(
          id: 't',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          textRuns: [
            PreviewTextRun(
              text: 'A',
              style: PreviewTextStyleData(fontSize: 12),
            ),
            PreviewTextRun(
              text: 'B',
              style: PreviewTextStyleData(fontSize: 48),
            ),
          ],
        ),
      );
      controller.selection = const TextSelection.collapsed(offset: 2);
      expect(controller.styleAtCaret().fontSize, 48);
      controller.selection = const TextSelection.collapsed(offset: 0);
      expect(controller.styleAtCaret().fontSize, 12);
      controller.dispose();
    });
  });
}
