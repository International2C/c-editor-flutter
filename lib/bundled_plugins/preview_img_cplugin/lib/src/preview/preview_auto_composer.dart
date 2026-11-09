import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_zomboss_extras.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/armrack_type_catalog.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_module_order_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';

/// Fits a simple-layout icon group into a useful visual height.
///
/// Small groups are enlarged so the actual icons occupy roughly one third of
/// the banner height. Large groups are reduced to keep them clear of the theme
/// caption. Relative sizes (for example boss icons versus wave icons) are
/// retained until an individual row reaches the supported size limits.
void fitSimplePreviewIconSections({
  required List<PreviewIconSection> sections,
  required double maxWidth,
  double? targetHeight,
  double? minimumHeight,
  double? maximumHeight,
  double minimumIconSize = 24,
  double maximumIconSize = 152,
}) {
  final populated = sections.where((section) => section.items.isNotEmpty);
  if (populated.isEmpty || maxWidth <= 0) return;
  final desiredHeight = targetHeight ?? kPreviewCanvasSize.height * 0.42;
  final minHeight = minimumHeight ?? kPreviewCanvasSize.height * 0.34;
  final maxHeight = maximumHeight ?? kPreviewCanvasSize.height * 0.58;

  final originalSizes = [for (final section in sections) section.iconSize];
  var bestScale = 1.0;
  var bestScore = double.infinity;
  var bestDistance = double.infinity;

  // Sampling handles the deliberate row-wrap discontinuities better than a
  // binary search: a slightly larger icon can create an extra row and become
  // much taller even though the scale changed very little.
  for (var step = 0; step <= 500; step++) {
    final scale = 0.25 + step * 0.01;
    for (var i = 0; i < sections.length; i++) {
      sections[i].iconSize = (originalSizes[i] * scale).clamp(
        minimumIconSize,
        maximumIconSize,
      );
    }
    final height = previewIconGridIntrinsicSize(
      maxWidth: maxWidth,
      sections: sections,
      showChrome: false,
    ).height;
    final below = height < minHeight ? minHeight - height : 0.0;
    final above = height > maxHeight ? height - maxHeight : 0.0;
    final distance = (height - desiredHeight).abs();
    final score = distance + (below + above) * 8;
    if (score < bestScore || (score == bestScore && distance < bestDistance)) {
      bestScale = scale;
      bestScore = score;
      bestDistance = distance;
    }
  }

  for (var i = 0; i < sections.length; i++) {
    sections[i].iconSize = (originalSizes[i] * bestScale).clamp(
      minimumIconSize,
      maximumIconSize,
    );
  }
}

/// Packs the initial icon panels using their measured content, not clipped
/// rectangles. The third panel can occupy the spare space below either column.
/// Dense levels reduce icon sizes before reducing the entire panel's scale.
void arrangePreviewIconGrids(
  List<PreviewLayer> panels, {
  required Rect availableBounds,
}) {
  if (panels.isEmpty) return;
  final area = Rect.fromLTWH(
    availableBounds.left * kPreviewCanvasSize.width,
    availableBounds.top * kPreviewCanvasSize.height,
    availableBounds.width * kPreviewCanvasSize.width,
    availableBounds.height * kPreviewCanvasSize.height,
  );
  final originalSizes = [
    for (final panel in panels)
      [for (final section in panel.sections) section.iconSize],
  ];

  void resizeIcons(double factor) {
    for (var p = 0; p < panels.length; p++) {
      for (var s = 0; s < panels[p].sections.length; s++) {
        panels[p].sections[s].iconSize = math.max(
          20.0,
          originalSizes[p][s] * factor,
        );
      }
    }
  }

  _PreviewPanelPacking? packing;
  // Row wrapping is discontinuous, so test actual content at each size.
  for (var step = 0; step <= 40; step++) {
    resizeIcons(1 - step * 0.02);
    final candidate = _packPreviewPanels(panels, area, 1);
    if (candidate.height <= area.height) {
      packing = candidate;
      break;
    }
  }
  // Section headings also take space. In unusually dense levels, scale their
  // whole panels rather than silently cropping the final rows or headings.
  if (packing == null) {
    for (var step = 1; step <= 75; step++) {
      final candidate = _packPreviewPanels(panels, area, 1 - step * 0.01);
      if (candidate.height <= area.height) {
        packing = candidate;
        break;
      }
    }
  }
  // The minimum editable scale is 0.25. Keep the measured content intact even
  // for pathological input exceeding what can fit in a fixed-size banner.
  packing ??= _packPreviewPanels(panels, area, 0.25);
  for (var p = 0; p < panels.length; p++) {
    final bounds = packing.bounds[p];
    panels[p].scale = packing.scale;
    panels[p].bounds = Rect.fromLTWH(
      bounds.left / kPreviewCanvasSize.width,
      bounds.top / kPreviewCanvasSize.height,
      bounds.width / kPreviewCanvasSize.width,
      bounds.height / kPreviewCanvasSize.height,
    );
  }
}

class _PreviewPanelPacking {
  const _PreviewPanelPacking(this.bounds, this.height, this.scale);

  final List<Rect> bounds;
  final double height;
  final double scale;
}

_PreviewPanelPacking _packPreviewPanels(
  List<PreviewLayer> panels,
  Rect area,
  double scale,
) {
  const gap = 10.0;
  _PreviewPanelPacking? best;

  double panelHeight(int index, double visibleWidth) {
    final panel = panels[index];
    final width = math.min(visibleWidth / scale, kPreviewCanvasSize.width);
    return previewIconGridIntrinsicSize(
      maxWidth: width,
      sections: panel.sections,
      showChrome: panel.showChrome,
      gridTitle: panel.gridTitle,
      sourceLabel: panel.sourceLabel,
    ).height;
  }

  Rect panelRect(int index, double x, double y, double width) => Rect.fromLTWH(
    x,
    y,
    math.min(width / scale, kPreviewCanvasSize.width),
    panelHeight(index, width),
  );

  void consider(List<Rect> bounds) {
    final height = bounds
        .map((rect) => rect.top + rect.height * scale - area.top)
        .reduce(math.max);
    if (best == null || height < best!.height) {
      best = _PreviewPanelPacking(bounds, height, scale);
    }
  }

  // A full-width stack is useful when there is only one main content group,
  // or when both groups contain many icons but few rows at full width.
  var y = area.top;
  final stack = <Rect>[];
  for (var i = 0; i < panels.length; i++) {
    final rect = panelRect(i, area.left, y, area.width);
    stack.add(rect);
    y += rect.height * scale + gap;
  }
  consider(stack);

  if (panels.length >= 2 && panels.length <= 3) {
    for (var step = 0; step <= 24; step++) {
      final leftWidth = (area.width - gap) * (0.20 + step * 0.025);
      final rightWidth = area.width - gap - leftWidth;
      final rightX = area.left + leftWidth + gap;
      final left = panelRect(0, area.left, area.top, leftWidth);
      final right = panelRect(1, rightX, area.top, rightWidth);
      if (panels.length == 2) {
        consider([left, right]);
        continue;
      }
      // Try both columns rather than putting extra content below the taller
      // column. This is what lets grid items fit beneath a short zombie panel.
      for (final beneathLeft in [false, true]) {
        final anchor = beneathLeft ? left : right;
        final extra = panelRect(
          2,
          beneathLeft ? area.left : rightX,
          anchor.top + anchor.height * scale + gap,
          beneathLeft ? leftWidth : rightWidth,
        );
        consider([left, right, extra]);
      }
      final extra = panelRect(
        2,
        area.left,
        area.top + math.max(left.height, right.height) * scale + gap,
        area.width,
      );
      consider([left, right, extra]);
    }
  }
  return best!;
}

/// Builds a [PreviewDocument] from the open level.
class PreviewAutoComposer {
  PreviewAutoComposer({
    required this.levelFile,
    required this.parsed,
    required this.fileName,
    required this.banners,
    required this.featureGroups,
    this.style = PreviewAutoStyle.normal,
    this.localize,
    this.moduleTitle,
    this.plantsSourceLabel = 'Plants',
    this.zombiesSourceLabel = 'Zombies',
    this.gridItemsSourceLabel = 'Grid Items',
    this.seedBankLabel = 'Seed Bank',
    this.zombieSeedBankLabel = 'Seed Bank (I, Zombie)',
    this.conveyorLabel = 'Conveyor',
    this.prePlacedLabel = 'Preset layout',
    this.protectLabel = 'Endangered targets',
    this.challengeLabel = 'Challenge',
    this.wavesLabel = 'Waves',
    this.initialZombiesLabel = 'Initial',
    this.vasebreakerLabel = 'Vase content',
    this.zombotPrefix = 'Zombot: ',
    this.zombossPrefix = 'Zomboss: ',
    this.spawnedZombiesLabel = 'Spawned zombies: ',
    this.resourceName,
  });

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final String fileName;
  final StageBannerResolver banners;
  final PreviewFeatureGroups featureGroups;
  final PreviewAutoStyle style;
  final PreviewLabelLookup? localize;
  final PreviewModuleTitleLookup? moduleTitle;
  final String Function(String id)? resourceName;

  final String plantsSourceLabel;
  final String zombiesSourceLabel;
  final String gridItemsSourceLabel;
  final String seedBankLabel;
  final String zombieSeedBankLabel;
  final String conveyorLabel;
  final String prePlacedLabel;
  final String protectLabel;
  final String challengeLabel;
  final String wavesLabel;
  final String initialZombiesLabel;
  final String vasebreakerLabel;
  final String zombotPrefix;
  final String zombossPrefix;
  final String spawnedZombiesLabel;

  Future<PreviewDocument> compose() async {
    await PlantRepository().init();
    await ZombieRepository().init();
    await GridItemRepository.init();
    await ReferenceRepository.init();

    final levelDef = parsed.levelDef;
    final stageAlias = RtidParser.parse(levelDef?.stageModule ?? '')?.alias;
    final stem = banners.resolveStem(
      stageAlias,
      stageObjdata: LevelParser.resolveStageObjdata(levelDef, levelFile),
    );
    final banner = PreviewBannerRef(
      kind: PreviewBannerSourceKind.stageMapped,
      stem: stem,
      assetPath: banners.assetPathForStem(stem),
    );

    final plantItems = _collectPlants();
    final extras = await PreviewZombossExtras.collect(levelFile);
    final bossExclude = {
      ...extras.bossItems.map((e) => e.id),
      if (style == PreviewAutoStyle.normal)
        ...extras.spawnItems.map((e) => e.id),
    };
    final seedBankZombies = _collectSeedBankZombies(excludeIds: bossExclude);
    final vaseZombies = _collectVasebreakerZombies(
      excludeIds: {...bossExclude, ...seedBankZombies.map((e) => e.id)},
    );
    final waveZombies = _collectWaveZombies(
      excludeIds: {
        ...bossExclude,
        ...seedBankZombies.map((e) => e.id),
        ...vaseZombies.map((e) => e.id),
      },
    );
    final zombieItems = [...seedBankZombies, ...vaseZombies, ...waveZombies];
    final layers = style == PreviewAutoStyle.simple
        ? _composeSimple(levelDef, plantItems, extras, zombieItems)
        : _composeNormal(levelDef, plantItems, extras, zombieItems);

    return PreviewDocument(
      banner: banner,
      layers: layers,
      levelFileName: fileName,
      autoStyle: style,
    );
  }

  List<PreviewIconSection> _zombieSections({
    required PreviewZombossExtras extras,
    required List<PreviewItem> waveZombies,
    required bool normal,
  }) {
    final sections = <PreviewIconSection>[];
    for (final boss in extras.bosses) {
      final name = resourceName?.call(boss.item.id) ?? boss.item.id;
      final title = normal
          ? '${boss.kind == PreviewBossKind.zombot ? zombotPrefix : zombossPrefix}$name'
          : null;
      sections.add(
        PreviewIconSection(
          title: title,
          items: [boss.item],
          iconSize: normal ? 72 : 64,
        ),
      );
    }
    if (normal && extras.spawnItems.isNotEmpty) {
      sections.add(
        PreviewIconSection(
          title: spawnedZombiesLabel,
          items: extras.spawnItems,
          iconSize: 36,
        ),
      );
    }
    if (waveZombies.isNotEmpty) {
      sections.add(PreviewIconSection(items: waveZombies, iconSize: 36));
    }
    return sections;
  }

  List<PreviewLayer> _composeNormal(
    LevelDefinitionData? levelDef,
    List<PreviewItem> plantItems,
    PreviewZombossExtras extras,
    List<PreviewItem> waveZombies,
  ) {
    final layers = <PreviewLayer>[];
    var z = 0;

    layers.add(
      PreviewLayer(
        id: 'title',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0.025, 0.03, 0.94, 0.14),
        zIndex: z++,
        text: _levelTitle(levelDef),
        textStyle: PreviewTextStyleData(
          fontFamily: kPreviewCustomFontFamily,
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFFFFF),
          outline: true,
          outlineWidth: 4,
        ),
      ),
    );

    final subtitle = featureGroups.buildSubtitle(
      _themeObjClassesOrdered(),
      localize: localize,
      moduleTitle: moduleTitle,
    );
    if (subtitle.isNotEmpty) {
      layers.add(
        PreviewLayer(
          id: 'subtitle',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0.025, 0.18, 0.94, 0.12),
          zIndex: z++,
          text: subtitle,
          textStyle: PreviewTextStyleData(
            fontFamily: kPreviewCustomFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFFFE082),
            outline: true,
            outlineWidth: 2.5,
          ),
        ),
      );
    }

    final gridItems = _collectGridItems();
    final zombieSections = _zombieSections(
      extras: extras,
      waveZombies: waveZombies,
      normal: true,
    );
    final hasPlants = plantItems.isNotEmpty;
    final hasZombies = zombieSections.isNotEmpty;
    if (hasPlants) {
      final plantSections = [
        PreviewIconSection(items: plantItems, iconSize: 36),
      ];
      final source = _combinedSources(plantItems);
      layers.add(
        PreviewLayer(
          id: 'plants',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.plants,
          gridTitle: plantsSourceLabel,
          sourceLabel: source,
          showChrome: true,
          bounds: Rect.zero,
          zIndex: z++,
          items: plantItems,
          sections: plantSections,
        ),
      );
    }
    if (hasZombies) {
      final source = _combinedSources(waveZombies);
      layers.add(
        PreviewLayer(
          id: 'zombies',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.zombies,
          gridTitle: zombiesSourceLabel,
          sourceLabel: source.isEmpty ? null : source,
          showChrome: true,
          bounds: Rect.zero,
          zIndex: z++,
          items: [...extras.bossItems, ...extras.spawnItems, ...waveZombies],
          sections: zombieSections,
        ),
      );
    }
    if (gridItems.isNotEmpty) {
      final gridSections = [PreviewIconSection(items: gridItems, iconSize: 36)];
      final source = _combinedSources(gridItems);
      layers.add(
        PreviewLayer(
          id: 'grid_items',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.gridItems,
          gridTitle: gridItemsSourceLabel,
          sourceLabel: source,
          showChrome: true,
          bounds: Rect.zero,
          zIndex: z++,
          items: gridItems,
          sections: gridSections,
        ),
      );
    }
    arrangePreviewIconGrids(
      layers.where((layer) => layer.kind == PreviewLayerKind.iconGrid).toList(),
      availableBounds: Rect.fromLTWH(
        0.03,
        subtitle.isEmpty ? 0.20 : 0.32,
        0.94,
        subtitle.isEmpty ? 0.77 : 0.65,
      ),
    );
    return layers;
  }

  List<PreviewLayer> _composeSimple(
    LevelDefinitionData? levelDef,
    List<PreviewItem> plantItems,
    PreviewZombossExtras extras,
    List<PreviewItem> waveZombies,
  ) {
    final layers = <PreviewLayer>[];
    var z = 0;

    final theme =
        featureGroups.firstFeatureLabel(
          _themeObjClassesOrdered(),
          localize: localize,
          moduleTitle: moduleTitle,
        ) ??
        _levelTitle(levelDef);

    final zombieSections = _zombieSections(
      extras: extras,
      waveZombies: waveZombies,
      normal: false,
    );

    if (plantItems.isNotEmpty) {
      final plantSections = [
        PreviewIconSection(items: plantItems, iconSize: 36),
      ];
      final maxWidthNorm = zombieSections.isNotEmpty ? 0.40 : 0.90;
      fitSimplePreviewIconSections(
        sections: plantSections,
        maxWidth: maxWidthNorm * kPreviewCanvasSize.width,
      );
      layers.add(
        PreviewLayer(
          id: 'plants',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.plants,
          showChrome: false,
          bounds: Rect.zero,
          zIndex: z++,
          items: plantItems,
          sections: plantSections,
        ),
      );
    }
    if (zombieSections.isNotEmpty) {
      final maxWidthNorm = plantItems.isNotEmpty ? 0.48 : 0.90;
      fitSimplePreviewIconSections(
        sections: zombieSections,
        maxWidth: maxWidthNorm * kPreviewCanvasSize.width,
      );
      layers.add(
        PreviewLayer(
          id: 'zombies',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.zombies,
          showChrome: false,
          bounds: Rect.zero,
          zIndex: z++,
          items: [...extras.bossItems, ...waveZombies],
          sections: zombieSections,
        ),
      );
    }

    arrangePreviewIconGrids(
      layers,
      availableBounds: const Rect.fromLTWH(0.04, 0.06, 0.92, 0.64),
    );
    layers.add(
      PreviewLayer(
        id: 'theme',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0.04, 0.72, 0.92, 0.22),
        zIndex: z++,
        text: theme,
        textStyle: PreviewTextStyleData(
          fontFamily: kPreviewCustomFontFamily,
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFFFFF),
          outline: true,
          outlineWidth: 5,
        ),
      ),
    );
    return layers;
  }

  String _levelTitle(LevelDefinitionData? def) {
    final name = def?.name.trim() ?? '';
    if (name.isNotEmpty) return name;
    final base = fileName.replaceAll(
      RegExp(r'\.(json|hujson|rton)$', caseSensitive: false),
      '',
    );
    return base.isEmpty ? 'Level' : base;
  }

  /// Theme modules in level-definition order (Special Modes + tracked extras).
  ///
  /// Resolves `@LevelModules` RTIDs via [ReferenceRepository] so Zomboss intro
  /// (and similar shared modules) are not skipped.
  List<String> _themeObjClassesOrdered() {
    final out = <String>[];
    final seen = <String>{};
    final tracked = featureGroups.trackedObjClasses;

    bool isThemeCandidate(String objClass) {
      if (featureGroups.excludeObjClasses.contains(objClass)) return false;
      if (tracked.contains(objClass)) return true;
      final meta = ModuleRegistry.registry[objClass];
      return meta != null && meta.category == ModuleCategory.mode;
    }

    void add(String? objClass) {
      if (objClass == null || objClass.isEmpty) return;
      if (!isThemeCandidate(objClass)) return;
      if (seen.add(objClass)) out.add(objClass);
    }

    final def = parsed.levelDef;
    if (def != null) {
      for (final rtid in def.modules) {
        add(_resolveModuleObjClass(rtid));
      }
    }
    for (final obj in levelFile.objects) {
      add(obj.objClass);
    }
    return PreviewFeatureGroups.sortObjClassesByCategory(out);
  }

  String? _resolveModuleObjClass(String rtid) {
    final resolved = LevelModuleOrderUtils.resolveModuleObjClass(
      rtid,
      parsed.objectMap,
    );
    if (resolved != null && resolved.isNotEmpty) return resolved;

    final info = RtidParser.parse(rtid);
    if (info == null) return null;

    // CurrentLevel object indexed under a secondary alias.
    final local = levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(info.alias) == true,
    );
    if (local?.objClass != null && local!.objClass.isNotEmpty) {
      return local.objClass;
    }

    // allowMultiple aliases: ZombossBattle2 → ZombossBattleModuleProperties
    for (final entry in ModuleRegistry.registry.entries) {
      final meta = entry.value;
      final alias = meta.defaultAlias;
      if (alias == info.alias) return entry.key;
      if (meta.allowMultiple &&
          info.alias.startsWith(alias) &&
          info.alias.length > alias.length) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isIZombieSeedBank(Map data) {
    return data['ZombieMode'] == true ||
        '${data['SeedPacketType'] ?? ''}'.contains('UIIZombieSeedPacket');
  }

  List<PreviewItem> _collectPlants() {
    final seen = <String>{};
    final items = <PreviewItem>[];

    void addPlant(String rawId, String source) {
      final id = _cleanId(rawId);
      if (id.isEmpty || !seen.add('$source::$id')) return;
      // Deduplicate by id across sources for display uniqueness, but keep first source.
      if (items.any((e) => e.id == id)) return;
      final path = previewPlantLikeAssetPath(id);
      items.add(PreviewItem(id: id, assetPath: path, sourceLabel: source));
    }

    void addFromList(dynamic raw, String source) {
      if (raw is! List) return;
      for (final e in raw) {
        if (e is String) {
          addPlant(e, source);
        } else if (e is Map) {
          final types = e['PlantTypes'];
          if (types is List) {
            for (final t in types) {
              if (t is String) addPlant(t, source);
            }
          }
          final id =
              e['ToolType'] ??
              e['PlantType'] ??
              e['PlantTypeName'] ??
              e['TypeName'] ??
              e['Type'];
          if (id is String) addPlant(id, source);
        }
      }
    }

    final sb = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'SeedBankProperties',
    );
    if (sb?.objData is Map) {
      final data = sb!.objData as Map;
      // I-zombie seed packets are zombies — collected separately.
      if (!_isIZombieSeedBank(data)) {
        addFromList(data['PresetPlantList'], seedBankLabel);
        addFromList(data['PlantWhiteList'] ?? data['WhiteList'], seedBankLabel);
      }
    }

    final conv = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ConveyorSeedBankProperties',
    );
    if (conv?.objData is Map) {
      final data = conv!.objData as Map;
      addFromList(data['Plants'] ?? data['InitialPlantList'], conveyorLabel);
    }

    for (final obj in levelFile.objects) {
      if (obj.objClass == 'InitialPlantEntryProperties' ||
          obj.objClass == 'InitialPlantProperties' ||
          obj.objClass == 'FrozenPlantPlacement') {
        final data = obj.objData;
        if (data is Map) {
          addFromList(
            data['InitialPlantPlacements'] ??
                data['Plants'] ??
                data['PlantPlacements'] ??
                data['InitialPlantList'],
            prePlacedLabel,
          );
          final single = data['PlantType'] ?? data['PlantTypeName'];
          if (single is String) addPlant(single, prePlacedLabel);
          // Nested plant type fields.
          _scanPlantFields(data, prePlacedLabel, addPlant);
        }
      }
      if (obj.objClass == 'ProtectThePlantChallengeProperties') {
        final data = obj.objData;
        if (data is Map) {
          addFromList(data['Plants'], protectLabel);
          _scanPlantFields(data, protectLabel, addPlant);
        }
      }
      if (obj.objClass == 'PlantDefeatZombieChallengeProps') {
        final data = obj.objData;
        if (data is Map) {
          final t = data['PlantTypeName'] ?? data['PlantType'];
          if (t is String) addPlant(t, challengeLabel);
        }
      }
    }

    final vaseData = readVaseBreakerData(levelFile);
    if (vaseData != null) {
      for (final v in vaseData.vases) {
        final p = v.plantTypeName;
        if (p != null && p.isNotEmpty) addPlant(p, vasebreakerLabel);
      }
    }

    return items;
  }

  /// I-zombie seed bank presets/whitelist → zombie icons for zombie sections.
  List<PreviewItem> _collectSeedBankZombies({
    Set<String> excludeIds = const {},
  }) {
    final items = <PreviewItem>[];
    final seen = <String>{...excludeIds};

    final sb = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'SeedBankProperties',
    );
    if (sb?.objData is! Map) return items;
    final data = sb!.objData as Map;
    if (!_isIZombieSeedBank(data)) return items;

    void addZombie(String rawId) {
      final id = _cleanId(rawId);
      if (id.isEmpty || !seen.add(id)) return;
      final info = ZombieRepository().getZombieById(id);
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      items.add(
        PreviewItem(id: id, assetPath: path, sourceLabel: zombieSeedBankLabel),
      );
    }

    void addFromList(dynamic raw) {
      if (raw is! List) return;
      for (final e in raw) {
        if (e is String) {
          addZombie(e);
        } else if (e is Map) {
          final types = e['PlantTypes'];
          if (types is List) {
            for (final t in types) {
              if (t is String) addZombie(t);
            }
          }
          final id =
              e['PlantType'] ??
              e['PlantTypeName'] ??
              e['TypeName'] ??
              e['Type'] ??
              e['ZombieType'];
          if (id is String) addZombie(id);
        }
      }
    }

    addFromList(data['PresetPlantList']);
    addFromList(data['PlantWhiteList'] ?? data['WhiteList']);
    return items;
  }

  List<PreviewItem> _collectVasebreakerZombies({
    Set<String> excludeIds = const {},
  }) {
    final items = <PreviewItem>[];
    final seen = <String>{...excludeIds};
    final vaseData = readVaseBreakerData(levelFile);
    if (vaseData == null) return items;
    for (final v in vaseData.vases) {
      final z = v.zombieTypeName;
      if (z == null || z.isEmpty) continue;
      final id = _cleanId(z);
      if (id.isEmpty || !seen.add(id)) continue;
      final info = ZombieRepository().getZombieById(id);
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      items.add(
        PreviewItem(id: id, assetPath: path, sourceLabel: vasebreakerLabel),
      );
    }
    return items;
  }

  void _scanPlantFields(
    dynamic node,
    String source,
    void Function(String, String) addPlant,
  ) {
    if (node is Map) {
      for (final e in node.entries) {
        final k = e.key.toString();
        if (k.contains('Plant') && e.value is String) {
          addPlant(e.value as String, source);
        } else {
          _scanPlantFields(e.value, source, addPlant);
        }
      }
    } else if (node is List) {
      for (final e in node) {
        _scanPlantFields(e, source, addPlant);
      }
    }
  }

  List<PreviewItem> _collectWaveZombies({Set<String> excludeIds = const {}}) {
    final items = <PreviewItem>[];
    final seen = <String>{...excludeIds};
    final ids = ZombieDiscovery.discoverZombies(levelFile, parsed);

    final initial = <String>{};
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'InitialZombieProperties') continue;
      final data = obj.objData;
      if (data is! Map) continue;
      final list = data['InitialZombiePlacements'] ?? data['Zombies'];
      if (list is! List) continue;
      for (final e in list) {
        if (e is Map) {
          final type = e['TypeName'] ?? e['ZombieType'];
          if (type is String) initial.add(_cleanId(type));
        }
      }
    }

    for (final id in ids) {
      final clean = _cleanId(id);
      if (clean.isEmpty || !seen.add(clean)) continue;
      final info = ZombieRepository().getZombieById(clean);
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      final source = initial.contains(clean) ? initialZombiesLabel : wavesLabel;
      items.add(PreviewItem(id: clean, assetPath: path, sourceLabel: source));
    }
    return items;
  }

  List<PreviewItem> _collectGridItems() {
    final items = <PreviewItem>[];
    final seen = <String>{};

    void addItem({
      required String id,
      required String assetPath,
      String? source,
    }) {
      final clean = _cleanId(id);
      if (clean.isEmpty || !seen.add(clean)) return;
      items.add(
        PreviewItem(
          id: clean,
          assetPath: assetPath,
          sourceLabel: source ?? gridItemsSourceLabel,
        ),
      );
    }

    void addGridType(String raw) {
      final clean = _cleanId(raw);
      if (clean.isEmpty || clean == 'flowerpot') return;
      final id =
          GridItemRepository.displayTypeNameForLevel(clean, levelFile) ?? clean;
      if (id.isEmpty) return;
      addItem(id: id, assetPath: GridItemRepository.getIconPath(id));
    }

    // True InitialGridItemProperties placements.
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'InitialGridItemProperties') continue;
      final data = obj.objData;
      if (data is! Map) continue;
      final list = data['InitialGridItemPlacements'] ?? data['GridItems'];
      if (list is! List) continue;
      for (final entry in list) {
        if (entry is! Map) continue;
        final raw =
            entry['TypeName'] ??
            entry['GridItemType'] ??
            entry['GridItemTypeName'] ??
            entry['ItemType'];
        if (raw is String && raw.isNotEmpty) addGridType(raw);
      }
    }

    // Renai day statues only (night spawns are wave-timed, not initial).
    final renai = readRenaiModuleData(levelFile);
    if (renai != null) {
      for (final s in renai.statueInfos) {
        if (s.typeName.isNotEmpty) addGridType(s.typeName);
      }
    }

    // Kongfu initial armrack / Taiji (energy grid) wave-1 presets.
    for (final item in initialArmrackItems(readArmrackModuleData(levelFile))) {
      if (item.type.isEmpty) continue;
      addItem(id: item.type, assetPath: armrackIconAsset(item.type));
    }
    if (initialEnergyGridItems(
      readEnergyGridModuleData(levelFile),
    ).isNotEmpty) {
      addItem(
        id: 'energyGrid',
        assetPath: GridItemRepository.getIconPath('energyGrid'),
      );
    }

    return items;
  }

  String _combinedSources(List<PreviewItem> items) {
    final labels = <String>[];
    for (final i in items) {
      final s = i.sourceLabel;
      if (s == null || s.isEmpty) continue;
      if (!labels.contains(s)) labels.add(s);
    }
    return labels.join(' · ');
  }

  String _cleanId(String raw) {
    var s = raw.trim();
    if (s.startsWith('RTID(')) {
      s = LevelParser.extractAlias(s);
    }
    s = s.replaceAll(RegExp(r'^(Zombie|Plant)'), '');
    return s;
  }
}
