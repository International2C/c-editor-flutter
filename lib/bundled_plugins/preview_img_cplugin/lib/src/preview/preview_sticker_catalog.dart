import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/dino_type_catalog.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';

import 'preview_document.dart';
import 'preview_zomboss_extras.dart';

/// Display order, rather than the order of image directories in the manifest.
const kPreviewStickerTags = <String>[
  'plants',
  'zombies',
  'griditems',
  'creatures',
  'tool_packets',
  'components',
  'round_icons',
  'ui',
  'worlds',
  'others',
];

class PreviewSticker {
  const PreviewSticker({
    required this.assetPath,
    required this.tag,
    this.resourceNameKey,
    this.labelKey,
    this.searchTerms = const [],
    this.nameResolver,
  });

  final String assetPath;
  final String tag;
  final String? resourceNameKey;
  final String? labelKey;
  final List<String> searchTerms;
  final String Function(BuildContext context)? nameResolver;

  String localizedName(
    BuildContext context,
    String Function(String key, [String? fallback]) t,
  ) {
    if (nameResolver != null && AppLocalizations.of(context) != null) {
      return nameResolver!(context);
    }
    final fallback = labelKey == null
        ? t('previewStickerUnnamed', 'Sticker')
        : t(labelKey!);
    if (resourceNameKey == null) return fallback;
    return ResourceNames.lookupOrFallback(context, resourceNameKey!, fallback);
  }
}

String _imageStem(String path) => path.replaceFirst(RegExp(r'\.[^/.]+$'), '');

int _imagePriority(String path) {
  final extension = path.split('.').last.toLowerCase();
  return const ['gif', 'webp', 'png', 'jpg', 'jpeg'].indexOf(extension);
}

/// A stable partition, not a new catalog sort. Both parts retain the editor's
/// tag order and original item order; filtering either part keeps that order.
List<PreviewSticker> prioritizePreviewStickers({
  required List<PreviewSticker> stickers,
  required Iterable<String> priorityAssetPaths,
}) {
  final preferred = priorityAssetPaths
      .map((path) => _imageStem(path).toLowerCase())
      .toSet();
  if (preferred.isEmpty) return stickers;
  final currentLevel = <PreviewSticker>[];
  final other = <PreviewSticker>[];
  for (final sticker in stickers) {
    (preferred.contains(_imageStem(sticker.assetPath).toLowerCase())
            ? currentLevel
            : other)
        .add(sticker);
  }
  return List.unmodifiable([...currentLevel, ...other]);
}

String _resourceAlias(String raw, String tag) {
  var alias = raw.trim();
  if (alias.startsWith('RTID(')) alias = LevelParser.extractAlias(alias);
  final prefix = switch (tag) {
    'plants' => 'plant_',
    'zombies' => 'zombie_',
    'griditems' => 'griditem_',
    'tool_packets' => 'tool_',
    _ => '',
  };
  alias = alias.toLowerCase();
  return prefix.isNotEmpty && alias.startsWith(prefix)
      ? alias.substring(prefix.length)
      : alias;
}

/// Resources used in the current level, including overview-only lists (seed
/// blacklists, copycat, seed rain, themes) that are not in the initial image.
/// Use typed fields and existing overview discovery, never arbitrary prose or
/// image-directory order. Matching assets also handles shared/animated icons.
Set<String> previewCurrentLevelStickerAssetPaths({
  required List<PreviewSticker> stickers,
  required PvzLevelFile levelFile,
  required ParsedLevelData parsed,
  PreviewDocument? document,
}) {
  final assets = <String>{};
  final references = <String, Set<String>>{
    for (final tag in kPreviewStickerTags) tag: <String>{},
  };
  void addReference(String tag, String raw) {
    final alias = _resourceAlias(raw, tag);
    if (alias.isNotEmpty) references[tag]!.add(alias);
    // Resolve identities before the catalog's shared-image deduplication.
    // A second grid item/stage/theme using the same image must still promote
    // that image even when its first catalog entry has a different name.
    switch (tag) {
      case 'plants':
        final path = previewPlantLikeAssetPath(alias);
        if (!path.endsWith('/unknown.webp')) assets.add(path);
      case 'zombies':
        final path = ZombieRepository().getZombieById(alias)?.iconAssetPath;
        if (path != null) assets.add(path);
      case 'tool_packets':
        final tool =
            ToolRepository.get(alias) ?? ToolRepository.get('tool_$alias');
        final icon = tool?.icon;
        if (icon != null) {
          assets.add(
            icon.startsWith('assets/') ? icon : 'assets/images/tools/$icon',
          );
        }
      case 'griditems':
        final clean = raw.startsWith('RTID(')
            ? LevelParser.extractAlias(raw)
            : raw;
        final display = GridItemRepository.displayTypeNameForLevel(
          clean,
          levelFile,
        );
        final path = GridItemRepository.getIconPath(display ?? clean);
        if (!path.endsWith('/unknown.webp')) assets.add(path);
        final tool =
            ToolRepository.get(clean) ?? ToolRepository.get('tool_$clean');
        final toolIcon = tool?.icon;
        if (toolIcon != null) {
          assets.add(
            toolIcon.startsWith('assets/')
                ? toolIcon
                : 'assets/images/tools/$toolIcon',
          );
        }
      case 'others':
        if (alias == 'sun' || alias == 'sun_large') {
          assets.add('assets/images/others/sun_large.webp');
        } else if (alias == 'plantfood' || alias == 'tool_plantfood') {
          assets.add('assets/images/others/plantfood.webp');
        }
      case 'ui':
        if (RiftThemeRepository.themeIds.contains(alias)) {
          assets.add(RiftThemeRepository.iconAssetPath(alias));
        }
      case 'round_icons':
        for (final stage in StageRepository.allItems) {
          if (stage.alias.toLowerCase() == alias && stage.iconName != null) {
            final icon = stage.iconName!;
            assets.add(
              icon == 'unknown.webp'
                  ? 'assets/images/others/unknown.webp'
                  : 'assets/images/round_icons/$icon',
            );
          }
        }
        for (final code in MusicSuffixCatalog.orderedCodes) {
          if (code.toLowerCase() == alias) {
            assets.add(MusicSuffixCatalog.iconAsset(code));
          }
        }
      default:
        break;
    }
  }

  for (final id in ZombieDiscovery.discoverZombies(levelFile, parsed)) {
    addReference('zombies', id);
  }
  for (final id in GridItemDiscovery.discoverGridItems(levelFile)) {
    addReference('griditems', id);
  }
  final levelDef = parsed.levelDef;
  if (levelDef != null) {
    addReference('round_icons', levelDef.stageModule);
    addReference('round_icons', levelDef.musicSuffix);
    final stageRef = RtidParser.parse(levelDef.stageModule);
    if (stageRef?.source == CustomStageLevelUtils.currentLevel) {
      final stage = CustomStageLevelUtils.findStageObject(
        levelFile,
        stageRef!.alias,
      );
      if (stage != null && stage.objData is Map) {
        final icon = CustomStageLevelUtils.displayIconFileName(
          objclass: stage.objClass,
          objdata: Map<String, dynamic>.from(stage.objData as Map),
        );
        if (icon != null) assets.add('assets/images/round_icons/$icon');
      }
    }
  }

  // Keep module context for generic Type/TypeName entries, but only collect
  // resource-bearing fields. A title or description equal to an ID is not an
  // occurrence of that resource, and grid-item IDs cannot become plant IDs.
  void scan(dynamic value, String? scope, String seedScope, bool resource) {
    if (value is PvzModel) value = value.toJson();
    if (value is String) {
      if (resource && scope != null) addReference(scope, value);
    } else if (value is List) {
      for (final item in value) {
        scan(item, scope, seedScope, resource);
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        final field = '${entry.key}'.toLowerCase();
        final nextScope = switch (field) {
          _ when field.contains('rifttheme') => 'ui',
          'stagemodule' || 'musicsuffix' => 'round_icons',
          _ when field.contains('zombie') => 'zombies',
          _ when field.contains('griditem') => 'griditems',
          _ when field.contains('collectable') => 'others',
          _ when field.contains('plant') => seedScope,
          'tooltype' => 'tool_packets',
          'dinotype' || 'fishes' || 'creaturetype' => 'creatures',
          _ => scope,
        };
        final isResourceField =
            nextScope != scope ||
            field.contains('plant') ||
            field.contains('zombie') ||
            field.contains('griditem') ||
            field.contains('collectable') ||
            field.contains('rifttheme') ||
            field == 'stagemodule' ||
            field == 'musicsuffix' ||
            field == 'tooltype' ||
            field == 'dinotype' ||
            field == 'fishes' ||
            field == 'creaturetype' ||
            (scope == 'components' &&
                (field == 'orientation' || field == 'img')) ||
            field == 'type' ||
            field == 'typename' ||
            field == 'whitelist' ||
            field == 'blacklist';
        scan(entry.value, nextScope, seedScope, isResourceField);
      }
    }
  }

  for (final obj in levelFile.objects) {
    final data = obj.objData is PvzModel
        ? (obj.objData as PvzModel).toJson()
        : obj.objData;
    var seedScope = 'plants';
    if (obj.objClass == 'SeedBankProperties' && data is Map) {
      if (data['ZombieMode'] == true ||
          '${data['SeedPacketType'] ?? ''}'.contains('UIIZombieSeedPacket')) {
        seedScope = 'zombies';
      } else if (data['GridItemMode'] == true) {
        seedScope = 'griditems';
        for (final id in kSeedBankGridItemIds) {
          addReference('griditems', id);
        }
      }
    }
    final className = obj.objClass.toLowerCase();
    final scope = className.contains('tunnel')
        ? 'components'
        : obj.objClass == 'CreatureType'
        ? 'creatures'
        : className.contains('griditem')
        ? 'griditems'
        : className.contains('zombie')
        ? 'zombies'
        : className.contains('plant') ||
              className.contains('seedbank') ||
              className.contains('seedrain')
        ? seedScope
        : null;
    scan(data, scope, seedScope, false);
  }

  if (document != null) {
    for (final layer in document.layers) {
      // These paths already account for custom resources, bosses and dedicated
      // modules resolved by the initial composition and module-info readers.
      for (final item in layer.items) {
        assets.add(item.assetPath);
      }
      for (final section in layer.sections) {
        for (final item in section.items) {
          assets.add(item.assetPath);
        }
        for (final row in section.rows) {
          for (final item in row.items) {
            assets.add(item.assetPath);
          }
        }
      }
    }
  }
  for (final sticker in stickers) {
    // These are presentation tags, not new resource namespaces. Modules still
    // refer to tools and some components through grid-item fields.
    final referenceTags = switch (sticker.tag) {
      'tool_packets' => const ['tool_packets', 'plants', 'griditems'],
      'creatures' => const ['creatures', 'griditems'],
      'components' => const ['components', 'griditems', 'others'],
      _ => [sticker.tag],
    };
    if (sticker.searchTerms.any(
      (term) => referenceTags.any(
        (tag) => references[tag]!.contains(_resourceAlias(term, tag)),
      ),
    )) {
      assets.add(sticker.assetPath);
    }
  }
  return assets;
}

/// Include the level's boss and mech action resources even when the user has
/// removed their icon panel from the preview. The document is only an extra
/// resolved-resource source; editing it must not hide resources on the level.
Future<Set<String>> loadPreviewCurrentLevelStickerAssetPaths({
  required List<PreviewSticker> stickers,
  required PvzLevelFile levelFile,
  required ParsedLevelData parsed,
  PreviewDocument? document,
}) async {
  final assets = previewCurrentLevelStickerAssetPaths(
    stickers: stickers,
    levelFile: levelFile,
    parsed: parsed,
    document: document,
  );
  await ZombiePropertiesRepository.init();
  final extras = await PreviewZombossExtras.collect(levelFile);
  assets.addAll([
    for (final item in extras.bossItems) item.assetPath,
    for (final item in extras.spawnItems) item.assetPath,
  ]);
  return assets;
}

/// Matches catalog icons to their actual packaged format (including GIFs).
/// Shared icons occur once, at their first position in the editor catalogs.
List<PreviewSticker> orderPreviewStickers({
  required Iterable<String> assetPaths,
  required Iterable<PreviewSticker> orderedEntries,
}) {
  final images = <String, String>{};
  for (final path in assetPaths) {
    if (!path.startsWith('assets/images/') ||
        !RegExp(
          r'\.(gif|webp|png|jpe?g)$',
          caseSensitive: false,
        ).hasMatch(path)) {
      continue;
    }
    final stem = _imageStem(path).toLowerCase();
    final previous = images[stem];
    if (previous == null || _imagePriority(path) < _imagePriority(previous)) {
      images[stem] = path;
    }
  }

  final buckets = {
    for (final tag in kPreviewStickerTags) tag: <PreviewSticker>[],
  };
  final seen = <String>{};
  void add(PreviewSticker entry) {
    final stem = _imageStem(entry.assetPath).toLowerCase();
    final actual = images[stem];
    if (actual == null || !seen.add(stem)) return;
    final tag = buckets.containsKey(entry.tag) ? entry.tag : 'others';
    buckets[tag]!.add(
      PreviewSticker(
        assetPath: actual,
        tag: tag,
        resourceNameKey: entry.resourceNameKey,
        labelKey: entry.labelKey,
        searchTerms: entry.searchTerms,
        nameResolver: entry.nameResolver,
      ),
    );
  }

  for (final entry in orderedEntries) {
    add(entry);
  }
  // A newly shipped image remains selectable even before its catalog is updated.
  // Known images are all named below; this fallback never exposes filenames.
  for (final path in images.values.toList()..sort()) {
    if (seen.contains(_imageStem(path).toLowerCase())) continue;
    final folder = path.split('/')[2];
    final stem = path.split('/').last.split('.').first;
    String? resourceKey;
    for (final candidate in [
      stem,
      'plant_$stem',
      'zombie_$stem',
      'griditem_$stem',
    ]) {
      if (ResourceNames.lookupWithLocale('en', candidate) != candidate ||
          ResourceNames.lookupWithLocale('zh', candidate) != candidate) {
        resourceKey = candidate;
        break;
      }
    }
    add(
      PreviewSticker(
        assetPath: path,
        tag: kPreviewStickerTags.contains(folder) ? folder : 'others',
        resourceNameKey: resourceKey,
        searchTerms: [stem],
      ),
    );
  }
  return List.unmodifiable(buckets.values.expand((entries) => entries));
}

Future<List<PreviewSticker>> loadPreviewStickerCatalog() async {
  final catalogPaths = [
    'Plants',
    'Zombies',
    'ZombossMechs',
    'Zombosses',
    'GridItems',
  ];
  final catalogs = await Future.wait([
    for (final name in catalogPaths)
      loadJsonString(
        'assets/resources/$name.json',
      ).then((source) => (jsonDecode(source) as List).cast<Map>()),
  ]);
  await Future.wait([
    StageRepository.init(),
    CustomStagePresetRepository.init(),
    MusicSuffixCatalog.init(),
    FishTypeRepository().init(),
    GridItemRepository.init(),
    ReferenceRepository.init(),
    PlantRepository().init(),
    ZombieRepository().init(),
    ResourceNames.ensureLoaded(),
  ]);
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final ordered = <PreviewSticker>[];
  for (var catalogIndex = 0; catalogIndex < catalogs.length; catalogIndex++) {
    final folder = catalogIndex == 0
        ? 'plants'
        : catalogIndex == 4
        ? 'griditems'
        : 'zombies';
    for (final raw in catalogs[catalogIndex]) {
      final icon = raw['icon'] as String?;
      if (icon == null || icon.isEmpty) continue;
      final id = (raw['id'] ?? raw['typeName']) as String;
      final key =
          raw['name'] as String? ?? (catalogIndex == 4 ? 'griditem_$id' : id);
      ordered.add(
        PreviewSticker(
          assetPath: 'assets/images/$folder/$icon',
          tag: folder,
          resourceNameKey: key,
          labelKey: id == 'gravestone_tutorial'
              ? 'previewStickerNameTutorialGravestone'
              : null,
          searchTerms: [
            id,
            ...(raw['variations'] as List? ?? []).cast<String>(),
          ],
        ),
      );
    }
  }

  for (final stage in StageRepository.allItems) {
    final icon = stage.iconName;
    if (icon == null || icon == 'unknown.webp') continue;
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/round_icons/$icon',
        tag: 'round_icons',
        resourceNameKey: StageRepository.getName(stage.alias),
        searchTerms: [stage.alias],
      ),
    );
  }
  for (final preset in CustomStagePresetRepository.presets) {
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/round_icons/${preset.iconName}',
        tag: 'round_icons',
        resourceNameKey: preset.nameKey,
        searchTerms: [preset.alias],
      ),
    );
  }
  for (final code in MusicSuffixCatalog.orderedCodes) {
    final path = MusicSuffixCatalog.iconAsset(code);
    if (path == MusicSuffixCatalog.unknownIconAsset) continue;
    ordered.add(
      PreviewSticker(
        assetPath: path,
        tag: 'round_icons',
        resourceNameKey: MusicSuffixCatalog.resourceKey(code),
        searchTerms: [code],
      ),
    );
  }

  for (final card in ToolRepository.toolCards) {
    if (card.icon == null) continue;
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/tools/${card.icon}',
        tag: 'tool_packets',
        resourceNameKey: card.id,
        searchTerms: [card.id],
      ),
    );
  }
  for (final id in kDinoSpawnTypeIds) {
    ordered.add(
      PreviewSticker(
        assetPath: dinoSpawnImageAsset(id),
        tag: 'creatures',
        resourceNameKey: 'dinoType_$id',
        searchTerms: [id],
      ),
    );
  }
  for (final fish in FishTypeRepository().allFishes) {
    if (!FishInfo.hasEditorIcon(fish.alias)) continue;
    ordered.add(
      PreviewSticker(
        assetPath: fish.iconAssetPath,
        tag: 'creatures',
        resourceNameKey: 'creature_${FishInfo.normalizeFishAlias(fish.alias)}',
        searchTerms: [fish.alias, fish.typeName],
      ),
    );
  }
  for (final category in [
    PlantCategory.quality,
    PlantCategory.role,
    PlantCategory.attribute,
  ]) {
    for (final tag in PlantTag.values) {
      if (tag.category != category || tag.iconAssetPath == null) continue;
      ordered.add(
        PreviewSticker(
          assetPath: tag.iconAssetPath!,
          tag: 'ui',
          nameResolver: tag.getLabel,
          searchTerms: [tag.name],
        ),
      );
    }
  }
  for (final tag in ZombieTag.values) {
    if (tag.iconAssetPath == null) continue;
    ordered.add(
      PreviewSticker(
        assetPath: tag.iconAssetPath!,
        tag: 'ui',
        nameResolver: tag.getLabel,
        searchTerms: [tag.name],
      ),
    );
  }
  for (final id in RiftThemeRepository.themeIds) {
    final path = RiftThemeRepository.iconAssetPath(id);
    final isSharedPursuitIcon = path.endsWith('/pursuit.webp');
    ordered.add(
      PreviewSticker(
        assetPath: path,
        tag: 'ui',
        resourceNameKey: isSharedPursuitIcon ? null : 'rift_theme_$id',
        labelKey: isSharedPursuitIcon ? 'previewStickerNamePursuit' : null,
        searchTerms: [id],
      ),
    );
  }
  final perkNames = <String, String Function(AppLocalizations)>{
    'Crystal': (s) => s.ztPerkCategoryCrystal,
    'Attack': (s) => s.ztPerkCategoryAttack,
    'Speed': (s) => s.ztPerkCategorySpeed,
    'Shield': (s) => s.ztPerkCategoryShield,
    'Gravity': (s) => s.ztPerkCategoryGravity,
    'ImmuneControl': (s) => s.ztPerkCategoryImmuneControl,
    'AntiControl': (s) => s.ztPerkCategoryAntiControl,
  };
  for (final entry in perkNames.entries) {
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/ztalemate_perks/${entry.key}.webp',
        tag: 'ui',
        nameResolver: (context) => entry.value(AppLocalizations.of(context)!),
        searchTerms: [entry.key],
      ),
    );
  }
  ordered.addAll(_supplementalStickers());
  return orderPreviewStickers(
    assetPaths: manifest.listAssets(),
    orderedEntries: ordered,
  );
}

Iterable<PreviewSticker> _supplementalStickers() sync* {
  yield const PreviewSticker(
    assetPath: 'assets/images/zombies/zombie_renai_toxicwater.webp',
    tag: 'zombies',
    labelKey: 'previewStickerNameDisinfectionZombie',
    searchTerms: ['zombie_renai_toxicwater'],
  );
  const camelSymbolKeys = [
    'previewStickerNameCamelSunSymbol',
    'previewStickerNameCamelConeSymbol',
    'previewStickerNameCamelSkullSymbol',
    'previewStickerNameCamelBucketSymbol',
    'previewStickerNameCamelCloverSymbol',
    'previewStickerNameCamelBoneSymbol',
    'previewStickerNameCamelTorchSymbol',
  ];
  for (var i = 0; i < camelSymbolKeys.length; i++) {
    yield PreviewSticker(
      assetPath: 'assets/images/others/camelminigame_${i + 1}.webp',
      tag: 'others',
      labelKey: camelSymbolKeys[i],
      searchTerms: ['camelminigame_${i + 1}'],
    );
  }
  final arrowNames = <String, String Function(AppLocalizations)>{
    'oaktrain_normal': (s) => s.oakTrainInitArrowNormal,
    'oaktrain_power': (s) => s.oakTrainInitArrowPower,
    'oaktrain_triple': (s) => s.oakTrainInitArrowSplit,
  };
  for (final entry in arrowNames.entries) {
    yield PreviewSticker(
      assetPath: 'assets/images/others/${entry.key}.webp',
      tag: 'others',
      nameResolver: (context) => entry.value(AppLocalizations.of(context)!),
      searchTerms: [entry.key],
    );
  }
  const resources = <String, String>{
    'zombies/zombie_general_zmech_phase': 'zombie_general_zmech_phase1',
    'zombies/zombie_zombie_towerdefend_boss': 'zombie_zombie_towerdefend_boss',
    'zombies/zombie_zombie_towerdefend_wolf_fire':
        'zombie_zombie_towerdefend_wolf_fire',
    'zombies/zombie_zombie_towerdefend_wolf_imp':
        'zombie_zombie_towerdefend_wolf_imp',
    'griditems/ArmrackArmor': 'armrack_ArmrackArmor',
    'griditems/ArmrackBlade': 'armrack_ArmrackBlade',
    'griditems/ArmrackBomb': 'armrack_ArmrackBomb',
    'griditems/ArmrackFlag': 'armrack_ArmrackFlag',
    'griditems/ArmrackHammer': 'armrack_ArmrackHammer',
    'griditems/ArmrackNunchaku': 'armrack_ArmrackNunchaku',
    'griditems/ArmrackTorch': 'armrack_ArmrackTorch',
    'griditems/steam_up': 'griditem_steam_up',
    'griditems/steam_down': 'griditem_steam_down',
    'griditems/SmokeManhole': 'griditem_SmokeManhole',
    'griditems/lunar_mine_vein': 'griditem_lunar_mine_vein',
    'griditems/lunar_mine_vein_hardened': 'griditem_lunar_mine_vein_hardened',
    'griditems/lunar_mine_vein_fragile': 'griditem_lunar_mine_vein_fragile',
    'griditems/lunar_mine_vein_fragile_plantfood':
        'griditem_lunar_mine_vein_fragile_plantfood',
    'griditems/lunar_mine_vein_radiation': 'griditem_lunar_mine_vein_radiation',
    'griditems/radiation_meteor_ore': 'griditem_radiation_meteor_ore',
    'griditems/pumpkin_house': 'griditem_pumpkin_house',
    'griditems/magic_mirror': 'griditem_magic_mirror',
    'griditems/magic_mirror1': 'griditem_magic_mirror1',
    'griditems/magic_mirror2': 'griditem_magic_mirror2',
    'griditems/magic_mirror3': 'griditem_magic_mirror3',
    'round_icons/Stage_LostVolcano': 'customStagePreset_lostVolcano',
    'round_icons/Stage_TeamBoss': 'musicSuffix_TeamBoss',
    'round_icons/Suffix_TeamBoss': 'musicSuffix_TeamBoss',
    'others/sun_large': 'sun_large',
    'others/plantfood': 'tool_plantfood',
  };
  for (final entry in resources.entries) {
    yield PreviewSticker(
      assetPath: 'assets/images/${entry.key}.webp',
      tag: entry.key.split('/').first,
      resourceNameKey: entry.value,
      searchTerms: [entry.key.split('/').last],
    );
  }
  const labels = <String, String>{
    'others/unknown': 'Unknown',
    'others/rails': 'Rails',
    'others/railcarts': 'Railcart',
    'others/Pirate_Seas_Planks': 'PiratePlanks',
    'others/kongfu_minecart_tracks': 'KongfuTracks',
    'others/kongfu_minecart_left': 'KongfuCartLeft',
    'others/kongfu_minecart_middle': 'KongfuCartMiddle',
    'others/kongfu_minecart_right': 'KongfuCartRight',
    'tunnels/GULLIVERTUNNEL_ORIENTATION_BIG_ON_LEFT': 'GulliverLeft',
    'tunnels/GULLIVERTUNNEL_ORIENTATION_BIG_ON_RIGHT': 'GulliverRight',
    'tunnels/SouDaCheTunnelRoad': 'ExpeditionRoad',
    'tunnels/SouDaCheTunnelRoadBlocked': 'ExpeditionRoadBlocked',
  };
  for (final entry in labels.entries) {
    yield PreviewSticker(
      assetPath: 'assets/images/${entry.key}.webp',
      tag: entry.value == 'Unknown' ? 'others' : 'components',
      labelKey: 'previewStickerName${entry.value}',
      searchTerms: [entry.key.split('/').last],
    );
  }
  yield PreviewSticker(
    assetPath: 'assets/images/others/to_be_continued.webp',
    tag: 'others',
    nameResolver: (context) =>
        AppLocalizations.of(context)!.comingSoonPlantBlockedLabel,
  );
  // Same component order as the Underground Palace module's image picker.
  const directions = {
    'DOWN': [1, 2, 3],
    'DOWN_LEFT': [1, 2, 3],
    'LEFT': [1, 2, 3, 4, 5, 6, 7],
    'UP': [1, 2, 3],
    'UP_LEFT': [1, 2, 3],
    'UP_DOWN': [1, 2],
    'UP_DOWN_LEFT': [1, 2],
  };
  for (final direction in directions.entries) {
    for (final variant in direction.value) {
      final suffix = variant == 1 ? '' : '_$variant';
      yield PreviewSticker(
        assetPath:
            'assets/images/tunnels/IMAGE_UI_MAUSOLEUM_TUNNEL_${direction.key}$suffix.webp',
        tag: 'components',
        labelKey:
            'previewStickerNameTunnel${direction.key.replaceAll('_', '')}$variant',
        searchTerms: ['IMAGE_UI_MAUSOLEUM_TUNNEL_${direction.key}$suffix'],
      );
    }
  }
}
