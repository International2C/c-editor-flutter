import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

String gladiatorZombieDisplayType(String type, PvzLevelFile level) {
  final alias = type.startsWith('RTID(')
      ? type.substring(5).split('@').first
      : type;
  for (final object in level.objects) {
    if (object.objClass == 'ZombieType' &&
        object.aliases?.contains(alias) == true &&
        object.objData is Map) {
      return (object.objData as Map)['TypeName'] as String? ?? alias;
    }
  }
  return ZombiePropertiesRepository.getTypeNameByAlias(alias);
}

class GladiatorZombieIcon extends StatelessWidget {
  const GladiatorZombieIcon({
    super.key,
    required this.type,
    required this.levelFile,
  });
  final String type;
  final PvzLevelFile levelFile;

  @override
  Widget build(BuildContext context) {
    final displayType = gladiatorZombieDisplayType(type, levelFile);
    final icon = ZombieRepository().getZombieById(displayType)?.iconAssetPath;
    return Tooltip(
      message:
          '${ResourceNames.lookupOrFallback(context, 'zombie_$displayType', type)}\n$type',
      child: AssetImageWidget(
        assetPath: icon ?? 'assets/images/others/unknown.webp',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// The arena covers columns 3–7; its central trophy occupies column 5.
class GladiatorRowPreview extends StatelessWidget {
  const GladiatorRowPreview({
    super.key,
    required this.encounter,
    required this.levelFile,
    required this.rows,
    required this.cols,
    this.onRowSelected,
  });
  final GladiatorEncounterData encounter;
  final PvzLevelFile levelFile;
  final int rows;
  final int cols;
  final ValueChanged<int>? onRowSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: AspectRatio(
          aspectRatio: cols / rows,
          child: Column(
            children: List.generate(
              rows,
              (row) => Expanded(
                child: Row(
                  children: List.generate(cols, (col) {
                    final active = row == encounter.row && col >= 2 && col <= 6;
                    final trophy = active && col == 4;
                    final spawns = encounter.spawns
                        .where(
                          (s) =>
                              row == encounter.row &&
                              col == s.gridX &&
                              s.count > 0,
                        )
                        .toList();
                    return Expanded(
                      child: GestureDetector(
                        onTap: onRowSelected == null
                            ? null
                            : () => onRowSelected!(row),
                        child: Container(
                          key: ValueKey('gladiator-cell-$col-$row'),
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: active
                                ? (trophy ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.45)
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 0.5,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Stack(
                              fit: StackFit.expand,
                              children: [
                                if (trophy)
                                  const Padding(
                                    padding: EdgeInsets.all(3),
                                    child: FittedBox(
                                      child: Icon(
                                        Icons.emoji_events,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                if (spawns.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(
                                      trophy ? constraints.maxWidth * 0.18 : 2,
                                    ),
                                    child: Row(
                                      children: [
                                        for (final spawn in spawns)
                                          Expanded(
                                            child: GladiatorZombieIcon(
                                              type: spawn.zombieType,
                                              levelFile: levelFile,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (spawns.fold<int>(
                                      0,
                                      (sum, s) => sum + s.count,
                                    ) >
                                    1)
                                  GridCellCountBadge(
                                    label:
                                        '${spawns.fold<int>(0, (sum, s) => sum + s.count)}',
                                    cellWidth: constraints.maxWidth,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
