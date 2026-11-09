import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';

const _kUnknownZombieIcon = 'assets/images/others/unknown.webp';

/// Displays and edits zombie type ids for spawn actions (`List<zombieType>`).
class ZombossMechZombieTypeListEditor extends StatelessWidget {
  const ZombossMechZombieTypeListEditor({
    super.key,
    required this.fieldLabel,
    required this.zombieIds,
    required this.editable,
    required this.isList,
    required this.onChanged,
    this.dense = false,
  });

  final String fieldLabel;
  final List<String> zombieIds;
  final bool editable;
  final bool isList;
  final ValueChanged<List<String>> onChanged;
  final bool dense;

  Future<void> _pickZombie(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          multiSelect: isList,
          excludeIds: isList ? zombieIds : const [],
          onZombieSelected: (id) {
            Navigator.pop(ctx);
            if (isList) {
              if (!zombieIds.contains(id)) {
                onChanged([...zombieIds, id]);
              }
            } else {
              onChanged([id]);
            }
          },
          onMultiZombieSelected: (ids) {
            Navigator.pop(ctx);
            if (ids.isEmpty) return;
            onChanged([
              ...zombieIds,
              ...ids.where((id) => !zombieIds.contains(id)),
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
            padding: EdgeInsets.only(
              left: dense ? 8 : 0,
              top: dense ? 6 : 8,
              bottom: dense ? 8 : 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(fieldLabel, style: theme.textTheme.titleSmall),
                ),
                if (editable && isList)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n?.zombossMechAddZombie ?? 'Add zombie',
                    onPressed: () => _pickZombie(context),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
              ],
            ),
          ),
        if (zombieIds.isEmpty)
          Padding(
            padding: EdgeInsets.only(left: dense ? 12 : 0, bottom: 6),
            child: Text(
              l10n?.zombossMechNoZombiesInList ?? 'No zombies in list',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...zombieIds.asMap().entries.map((entry) {
            final index = entry.key;
            final id = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: dense ? 4 : 6),
              child: _ZombieTypeRow(
                zombieId: id,
                dense: dense,
                editable: editable,
                onTap: editable
                    ? () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ZombieSelectionScreen(
                              onZombieSelected: (picked) {
                                Navigator.pop(ctx);
                                if (isList) {
                                  final next = List<String>.from(zombieIds);
                                  next[index] = picked;
                                  onChanged(next);
                                } else {
                                  onChanged([picked]);
                                }
                              },
                              onBack: () => Navigator.pop(ctx),
                            ),
                          ),
                        );
                      }
                    : null,
                onRemove: editable && isList
                    ? () {
                        final next = List<String>.from(zombieIds)
                          ..removeAt(index);
                        onChanged(next);
                      }
                    : editable && !isList
                    ? () => onChanged([])
                    : null,
              ),
            );
          }),
        if (editable && !isList && zombieIds.isEmpty)
          TextButton.icon(
            onPressed: () => _pickZombie(context),
            icon: const Icon(Icons.add),
            label: Text(l10n?.zombossMechPickZombie ?? 'Pick zombie'),
          ),
      ],
    );
  }
}

class _ZombieTypeRow extends StatelessWidget {
  const _ZombieTypeRow({
    required this.zombieId,
    required this.dense,
    required this.editable,
    this.onTap,
    this.onRemove,
  });

  final String zombieId;
  final bool dense;
  final bool editable;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final info = repo.getZombieById(zombieId);
    final nameKey = repo.getName(zombieId);
    final localized = ResourceNames.lookup(context, nameKey);
    final displayName = localized != nameKey && localized.isNotEmpty
        ? localized
        : zombieId;
    final iconPath = info?.iconAssetPath ?? _kUnknownZombieIcon;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: editable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 8 : 10,
            vertical: dense ? 6 : 8,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AssetImageWidget(
                  assetPath: iconPath,
                  width: dense ? 40 : 48,
                  height: dense ? 40 : 48,
                  fit: BoxFit.contain,
                  altCandidates: imageAltCandidates(iconPath),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zombieId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                  tooltip: AppLocalizations.of(context)?.remove ?? 'Remove',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// All zombie-list fields on a resolved action.
class ZombossMechActionZombieLists extends StatelessWidget {
  const ZombossMechActionZombieLists({
    super.key,
    required this.resolved,
    required this.onZombieListChanged,
    this.dense = false,
  });

  final ZombossResolvedAction resolved;
  final void Function(ZombossZombieListBinding binding, List<String> ids)
  onZombieListChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final lists = resolved.zombieLists
        .where((b) => b.zombieIds.isNotEmpty || resolved.editable)
        .toList();
    if (lists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final binding in lists)
          Padding(
            padding: EdgeInsets.only(top: dense ? 4 : 8),
            child: ZombossMechZombieTypeListEditor(
              fieldLabel: binding.fieldName,
              zombieIds: binding.zombieIds,
              editable: resolved.editable,
              isList: binding.isList,
              dense: dense,
              onChanged: (ids) => onZombieListChanged(binding, ids),
            ),
          ),
      ],
    );
  }
}
