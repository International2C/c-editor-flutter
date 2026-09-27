import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart'
    show CustomResourceBadge, presetCustomResourceBadgeColor;
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:collection/collection.dart';

String _normalizeId(String id) {
  var normalized = id.replaceAll(RegExp(r'^(Zombie|Plant)'), '');
  normalized = normalized.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (Match m) => '${m[1]}_${m[2]}',
  );
  return normalized.toLowerCase();
}

class ResourceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? tooltip;

  const ResourceChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 4,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
    if (tooltip != null) {
      content = Tooltip(message: tooltip!, child: content);
    }
    return content;
  }
}

class UniversalIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;
  final PvzLevelFile? levelFile;

  const UniversalIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
    this.levelFile,
  });

  @override
  Widget build(BuildContext context) {
    final clean = id.replaceAll(
      RegExp(r'^RTID\(|@CurrentLevel\)$|@LevelModules\)$'),
      '',
    );

    if (clean == 'plantfood' || clean == 'tool_plantfood') {
      return _IconWrapper(
        id: clean,
        tooltip: ResourceNames.lookup(context, 'tool_plantfood'),
        asset: 'assets/images/others/plantfood.webp',
        size: size,
        isGrid: isGrid,
        fallbackIcon: Icons.build,
      );
    }
    if (clean == 'sun' || clean == 'sun_large') {
      return _IconWrapper(
        id: clean,
        tooltip: ResourceNames.lookup(context, 'sun_large'),
        asset: 'assets/images/others/sun_large.webp',
        size: size,
        isGrid: isGrid,
        fallbackIcon: Icons.wb_sunny,
      );
    }

    if (ZombossMechRepository.findBaseForVariation(clean) != null) {
      return ZombossMechIcon(id: clean, size: size, isGrid: isGrid);
    }

    if (ZombossBattleRepository.findBaseForVariation(clean) != null) {
      return BossIcon(id: clean, size: size, isGrid: isGrid);
    }

    if (ToolRepository.get(clean) != null) {
      return ToolIcon(id: clean, size: size, isGrid: isGrid);
    }

    final isCustomZombie =
        levelFile != null &&
        CustomZombieLevelUtils.resolveCustomZombieAlias(levelFile!, clean) !=
            null;

    if (isCustomZombie ||
        ZombieRepository().getZombieById(clean) != null ||
        ZombieRepository().getZombieById(_normalizeId(clean)) != null) {
      return ZombieIcon(
        id: clean,
        size: size,
        isGrid: isGrid,
        levelFile: levelFile,
      );
    }
    if (PlantRepository().getPlantInfoById(clean) != null ||
        PlantRepository().getPlantInfoById(_normalizeId(clean)) != null) {
      return PlantIcon(id: clean, size: size, isGrid: isGrid);
    }

    final isKnownGridItem =
        GridItemRepository.getByTypeName(clean) != null ||
        (ReferenceRepository.instance.isLoaded &&
            ReferenceRepository.instance.isValidGridItem(clean));
    if (isKnownGridItem) {
      return GridItemIcon(
        id: clean,
        size: size,
        isGrid: isGrid,
        levelFile: levelFile,
      );
    }

    // A resource that is not recognized as a plant, zombie, tool, boss, or
    // grid item should keep its original code name. Treating every unknown
    // resource as a grid item incorrectly adds a `griditem_` prefix to its
    // tooltip and obscures what is actually stored in the level.
    return _IconWrapper(
      id: clean,
      tooltip: clean,
      asset: 'assets/images/others/unknown.webp',
      size: size,
      isGrid: isGrid,
      fallbackIcon: Icons.help_outline,
    );
  }
}

class ToolIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;

  const ToolIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = ToolRepository.get(id);
    final tooltip = ToolRepository.localizedName(context, id);

    String? asset;
    if (info?.icon != null) {
      if (info!.icon!.startsWith('assets/')) {
        asset = info.icon;
      } else {
        asset = 'assets/images/tools/${info.icon}';
      }
    }

    return _IconWrapper(
      id: id,
      tooltip: tooltip,
      asset: asset,
      size: size,
      isGrid: isGrid,
      fallbackIcon: Icons.build,
    );
  }
}

class PlantIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;

  const PlantIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final info =
        PlantRepository().getPlantInfoById(id) ??
        PlantRepository().getPlantInfoById(_normalizeId(id));
    final asset = info?.iconAssetPath;
    final tooltip = ResourceNames.lookup(context, info?.name ?? id);

    return _IconWrapper(
      id: id,
      tooltip: tooltip,
      asset: asset,
      size: size,
      isGrid: isGrid,
      fallbackIcon: Icons.help_outline,
    );
  }
}

class ZombieIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;
  final PvzLevelFile? levelFile;

  const ZombieIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
    this.levelFile,
  });

  @override
  Widget build(BuildContext context) {
    String? baseId;
    bool isCustom = false;

    if (levelFile != null) {
      final customAlias = CustomZombieLevelUtils.resolveCustomZombieAlias(
        levelFile!,
        id,
      );
      if (customAlias != null) {
        isCustom = true;
        final obj = levelFile!.objects.firstWhereOrNull(
          (o) =>
              o.objClass == 'ZombieType' &&
              o.aliases?.contains(customAlias) == true,
        );
        baseId = (obj?.objData as Map?)?['TypeName'];
      }
    }

    final targetId = baseId ?? id;
    final repo = ZombieRepository();
    final info =
        repo.getZombieById(targetId) ??
        repo.getZombieById(_normalizeId(targetId));

    final nameKey = isCustom
        ? id
        : (info != null ? repo.getName(info.id) : repo.getName(targetId));
    final tooltip = ResourceNames.lookup(context, nameKey);

    String? asset;
    if (info?.icon != null) {
      asset = 'assets/images/zombies/${info!.icon}';
    } else if (isCustom) {
      final normalizedBase = _normalizeId(targetId);
      final classInfo = repo.getZombieById(normalizedBase);
      if (classInfo?.icon != null) {
        asset = 'assets/images/zombies/${classInfo!.icon}';
      }
    }

    final finalAsset = asset ?? 'assets/images/others/unknown.webp';

    return _IconWrapper(
      id: targetId,
      tooltip: tooltip,
      asset: finalAsset,
      size: size,
      isGrid: isGrid,
      fallbackIcon: Icons.help_outline,
      isCustom: isCustom,
    );
  }
}

class GridItemIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;
  final bool suppressCustomBadge;
  final PvzLevelFile? levelFile;

  const GridItemIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
    this.suppressCustomBadge = false,
    this.levelFile,
  });

  @override
  Widget build(BuildContext context) {
    final item = GridItemRepository.getByTypeName(id);
    // Custom presets can share their game type name with unrelated level
    // definitions. Only use preset art when the actual properties match.
    final isUnknownPreset =
        levelFile != null &&
        item?.source == GridItemSource.custom &&
        !GridItemRepository.isRecognizedCustomGridItem(id, levelFile!);
    final path = isUnknownPreset
        ? 'assets/images/others/unknown.webp'
        : GridItemRepository.getIconPath(id);
    final resourceKey = id.startsWith('Armrack')
        ? 'armrack_$id'
        : 'griditem_$id';
    final tooltip = isUnknownPreset
        ? id
        : ResourceNames.lookup(context, resourceKey);
    final isPreset =
        !suppressCustomBadge &&
        !isGrid &&
        !isUnknownPreset &&
        item?.source == GridItemSource.custom;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _IconWrapper(
            id: id,
            tooltip: tooltip,
            asset: path,
            size: size,
            isGrid: isGrid,
            fallbackIcon: Icons.grid_on,
          ),
          if (isPreset)
            Positioned(
              top: 0,
              left: 0,
              child: CustomResourceBadge(
                color: presetCustomResourceBadgeColor(context),
              ),
            ),
        ],
      ),
    );
  }
}

class ZombossMechIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;

  const ZombossMechIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = ZombossMechRepository.findBaseForVariation(id);
    final asset = base != null ? 'assets/images/zombies/${base.icon}' : null;
    final tooltip = base != null ? ResourceNames.lookup(context, base.id) : id;

    return _IconWrapper(
      id: id,
      tooltip: tooltip,
      asset: asset,
      size: size,
      isGrid: isGrid,
      fallbackIcon: Icons.face,
    );
  }
}

class BossIcon extends StatelessWidget {
  final String id;
  final double size;
  final bool isGrid;

  const BossIcon({
    super.key,
    required this.id,
    this.size = 42,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = ZombossBattleRepository.findBaseForVariation(id);
    final asset = base != null ? 'assets/images/zombies/${base.icon}' : null;
    final tooltip = base != null ? ResourceNames.lookup(context, base.id) : id;

    return _IconWrapper(
      id: id,
      tooltip: tooltip,
      asset: asset,
      size: size,
      isGrid: isGrid,
      fallbackIcon: Icons.security,
    );
  }
}

class _IconWrapper extends StatelessWidget {
  final String id;
  final String tooltip;
  final String? asset;
  final double size;
  final bool isGrid;
  final IconData fallbackIcon;
  final bool isCustom;

  const _IconWrapper({
    required this.id,
    required this.tooltip,
    required this.asset,
    required this.size,
    required this.isGrid,
    required this.fallbackIcon,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget main;
    if (isGrid) {
      main = asset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AssetImageWidget(assetPath: asset!, fit: BoxFit.contain),
            )
          : Icon(fallbackIcon, size: size, color: Colors.white24);
    } else {
      main = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: asset != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AssetImageWidget(assetPath: asset!, fit: BoxFit.contain),
              )
            : Center(
                child: Icon(
                  fallbackIcon,
                  size: size / 2,
                  color: Colors.white24,
                ),
              ),
      );
    }

    if (isCustom) {
      main = Stack(
        clipBehavior: Clip.none,
        children: [
          main,
          Positioned(top: -2, left: -2, child: _CustomBadge(size: size)),
        ],
      );
    }

    return Tooltip(message: tooltip, child: main);
  }
}

class _CustomBadge extends StatelessWidget {
  final double size;
  const _CustomBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    final badgeSize = (size * 0.35).clamp(14.0, 24.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726), // matched with editor
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 0.5),
      ),
      child: Text(
        'C',
        style: TextStyle(
          fontSize: badgeSize * 0.7,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

class ObjectCountBadge extends StatelessWidget {
  final int count;
  final double scale;

  const ObjectCountBadge({super.key, required this.count, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        child: Text(
          '+$count',
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
