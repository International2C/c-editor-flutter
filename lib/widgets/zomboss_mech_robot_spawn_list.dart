import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/models/zomboss_robot_spawn_entry.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

const _kUnknownZombieIcon = 'assets/images/others/unknown.webp';

/// PVZ1 robot `SpawnZombieTypes` editor (zombie + row + level + weight).
class ZombossMechRobotSpawnListEditor extends StatelessWidget {
  const ZombossMechRobotSpawnListEditor({
    super.key,
    required this.fieldLabel,
    required this.entries,
    required this.onChanged,
    this.levelFile,
    this.editable = true,
  });

  final String fieldLabel;
  final List<ZombossRobotSpawnEntry> entries;
  final ValueChanged<List<ZombossRobotSpawnEntry>> onChanged;
  final PvzLevelFile? levelFile;
  final bool editable;

  bool get _isDeepSeaLawn =>
      levelFile != null && LevelParser.isDeepSeaLawnFromFile(levelFile!);

  /// 0-based row indices: 0–4 standard lawn, 0–5 deep sea (6th row).
  int get _maxRowIndex => _isDeepSeaLawn ? 5 : 4;

  Future<void> _addEntry(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          multiSelect: true,
          levelFile: levelFile,
          onZombieSelected: (id) {
            Navigator.pop(ctx);
            onChanged([...entries, ZombossRobotSpawnEntry(zombieTypeName: id)]);
          },
          onMultiZombieSelected: (ids) {
            Navigator.pop(ctx);
            if (ids.isEmpty) return;
            onChanged([
              ...entries,
              for (final id in ids) ZombossRobotSpawnEntry(zombieTypeName: id),
            ]);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fieldLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(fieldLabel, style: theme.textTheme.titleSmall),
                ),
                if (editable)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n?.zombossMechAddZombie ?? 'Add zombie',
                    onPressed: () => _addEntry(context),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
              ],
            ),
          ),
        if (entries.isEmpty)
          Text(
            l10n?.zombossMechNoZombiesInList ?? 'No zombies in list',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (var i = 0; i < entries.length; i++)
            _RobotSpawnEntryCard(
              entry: entries[i],
              maxRowIndex: _maxRowIndex,
              editable: editable,
              onChanged: (updated) {
                final next = List<ZombossRobotSpawnEntry>.from(entries);
                next[i] = updated;
                onChanged(next);
              },
              onRemove: () {
                final next = List<ZombossRobotSpawnEntry>.from(entries)
                  ..removeAt(i);
                onChanged(next);
              },
              onPickZombie: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => ZombieSelectionScreen(
                      onZombieSelected: (id) {
                        Navigator.pop(ctx);
                        final next = List<ZombossRobotSpawnEntry>.from(entries);
                        next[i] = ZombossRobotSpawnEntry(
                          zombieTypeName: id,
                          row: entries[i].row,
                          level: entries[i].level,
                          hasPlantfood: entries[i].hasPlantfood,
                          weight: entries[i].weight,
                        );
                        onChanged(next);
                      },
                      onBack: () => Navigator.pop(ctx),
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _RobotSpawnEntryCard extends StatelessWidget {
  const _RobotSpawnEntryCard({
    required this.entry,
    required this.maxRowIndex,
    required this.editable,
    required this.onChanged,
    required this.onRemove,
    required this.onPickZombie,
  });

  final ZombossRobotSpawnEntry entry;
  final int maxRowIndex;
  final bool editable;
  final ValueChanged<ZombossRobotSpawnEntry> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onPickZombie;

  static const _levelOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final info = repo.getZombieById(entry.zombieTypeName);
    final nameKey = repo.getName(entry.zombieTypeName);
    final localized = ResourceNames.lookup(context, nameKey);
    final displayName = localized != nameKey && localized.isNotEmpty
        ? localized
        : entry.zombieTypeName;
    final iconPath = info?.iconAssetPath ?? _kUnknownZombieIcon;

    final rowValue =
        entry.row == -1 || (entry.row >= 0 && entry.row <= maxRowIndex)
        ? entry.row
        : -1;
    final levelValue = entry.level.clamp(0, 10);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AssetImageWidget(
                  assetPath: iconPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  altCandidates: imageAltCandidates(iconPath),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            entry.zombieTypeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (editable)
                        TextButton.icon(
                          onPressed: onPickZombie,
                          icon: const Icon(Icons.swap_horiz, size: 20),
                          label: Text(
                            l10n?.switchZombie ?? 'Switch zombie',
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
                if (editable)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onRemove,
                    tooltip: l10n?.remove ?? 'Remove',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            EditorResponsiveFieldRow(
              children: [
                Expanded(
                  flex: 2,
                  child: EditorResponsiveInputField(
                    label: l10n?.zombossMechRobotSpawnWeight ?? 'Weight',
                    builder: (context, decoration) => TextFormField(
                      initialValue: '${entry.weight}',
                      readOnly: !editable,
                      decoration: decoration,
                      keyboardType: TextInputType.number,
                      onChanged: editable
                          ? (v) {
                              final parsed = int.tryParse(v);
                              if (parsed != null && parsed >= 0) {
                                entry.weight = parsed;
                                onChanged(entry);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: EditorResponsiveInputField(
                    label: l10n?.zombossMechRobotSpawnRow ?? 'Row',
                    builder: (context, decoration) =>
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: rowValue,
                          decoration: decoration,
                          items: [
                            DropdownMenuItem(
                              value: -1,
                              child: Text(
                                l10n?.zombossMechRobotSpawnRowRandom ??
                                    'Random (-1)',
                              ),
                            ),
                            for (var r = 0; r <= maxRowIndex; r++)
                              DropdownMenuItem(value: r, child: Text('$r')),
                          ],
                          onChanged: editable
                              ? (v) {
                                  if (v == null) return;
                                  entry.row = v;
                                  onChanged(entry);
                                }
                              : null,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: EditorResponsiveInputField(
                    label: l10n?.zombossMechRobotSpawnLevel ?? 'Level',
                    builder: (context, decoration) =>
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: levelValue,
                          decoration: decoration,
                          items: [
                            for (final lv in _levelOptions)
                              DropdownMenuItem(value: lv, child: Text('$lv')),
                          ],
                          onChanged: editable
                              ? (v) {
                                  if (v == null) return;
                                  entry.level = v;
                                  onChanged(entry);
                                }
                              : null,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n?.zombossMechRobotSpawnPlantfood ?? 'Plant food',
                  style: theme.textTheme.bodyMedium,
                ),
                Switch(
                  value: entry.hasPlantfood,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: editable
                      ? (v) {
                          entry.hasPlantfood = v;
                          onChanged(entry);
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
