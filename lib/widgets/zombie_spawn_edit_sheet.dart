import 'package:flutter/material.dart';

import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_ztalemate_perks_editor.dart';
import 'package:c_editor/widgets/zombie_entry_side_fields.dart';

/// Which fields appear in a zombie spawn configuration bottom sheet.
class ZombieSpawnEditSheetOptions {
  const ZombieSpawnEditSheetOptions({
    this.showRow = false,
    this.maxRow = 5,
    this.showDirection = false,
    this.showLevel = true,
    this.showZtalematePerks = false,
    this.showCopyDelete = true,
  });

  final bool showRow;
  final int maxRow;
  final bool showDirection;
  final bool showLevel;
  final bool showZtalematePerks;
  final bool showCopyDelete;
}

/// Opens a zombie configuration bottom sheet with only the requested fields.
Future<void> showZombieSpawnEditSheet({
  required BuildContext context,
  required ZombieSpawnEditSheetOptions options,
  required String? iconPath,
  required String displayName,
  required bool isCustom,
  required bool isElite,
  required VoidCallback onChangeType,
  int rowValue = 0,
  ValueChanged<int>? onRowChanged,
  int levelValue = 0,
  ValueChanged<int>? onLevelChanged,
  String? direction,
  ValueChanged<String?>? onDirectionChanged,
  List<String> titles = const [],
  ValueChanged<List<String>>? onTitlesChanged,
  VoidCallback? onCopy,
  void Function(BuildContext sheetContext)? onDelete,
  Widget? customPropertiesActions,
}) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      var localRow = rowValue;
      var localLevel = levelValue;
      var localDirection = direction;
      var localTitles = List<String>.from(titles);

      return StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZombieEditSheetIdentityTile(
                    iconPath: iconPath,
                    displayName: displayName,
                    isCustom: isCustom,
                    customLabel: l10n?.customLabel ?? 'Custom',
                    onChange: () {
                      Navigator.pop(sheetContext);
                      onChangeType();
                    },
                  ),
                  if (options.showRow && onRowChanged != null) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: localRow,
                      decoration: InputDecoration(
                        labelText: l10n?.row ?? 'Row',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      selectedItemBuilder: (context) => [
                        Text(
                          l10n?.random ?? 'Random',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        ...List.generate(options.maxRow, (i) => i + 1).map(
                          (v) => Text(
                            l10n?.rowN(v) ?? 'Row $v',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(l10n?.random ?? 'Random'),
                        ),
                        ...List.generate(options.maxRow, (i) => i + 1).map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(l10n?.rowN(v) ?? 'Row $v'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setModalState(() => localRow = v);
                        onRowChanged(v);
                      },
                    ),
                  ],
                  if (options.showLevel && onLevelChanged != null) ...[
                    const SizedBox(height: 12),
                    if (isElite)
                      Text(
                        l10n?.eliteZombiesUseDefaultLevel ??
                            'Elite zombies use default level.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else ...[
                      SwitchListTile(
                        title: Text(l10n?.autoLevel ?? 'Auto level'),
                        value: localLevel == 0,
                        onChanged: (v) {
                          setModalState(() => localLevel = v ? 0 : 1);
                          onLevelChanged(v ? 0 : 1);
                        },
                      ),
                      if (localLevel != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.levelFormat(localLevel) ??
                                  'Level: $localLevel',
                            ),
                            Slider(
                              value: localLevel.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: '$localLevel',
                              onChanged: (v) {
                                final newLevel = v.round();
                                setModalState(() => localLevel = newLevel);
                                onLevelChanged(newLevel);
                              },
                            ),
                          ],
                        ),
                    ],
                  ],
                  if (options.showDirection && onDirectionChanged != null) ...[
                    const SizedBox(height: 12),
                    ZombieEntrySideFields(
                      key: const ValueKey('zombieEntrySide'),
                      direction: localDirection,
                      onChanged: (v) {
                        setModalState(() => localDirection = v);
                        onDirectionChanged(v);
                      },
                    ),
                  ],
                  if (options.showZtalematePerks &&
                      onTitlesChanged != null) ...[
                    const SizedBox(height: 12),
                    ZombieZtalematePerksEditor(
                      titles: localTitles,
                      onChanged: (next) {
                        setModalState(
                          () => localTitles = List<String>.from(next),
                        );
                        onTitlesChanged(next);
                      },
                    ),
                  ],
                  if (options.showCopyDelete &&
                      (onCopy != null || onDelete != null)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (onCopy != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                onCopy();
                                Navigator.pop(sheetContext);
                              },
                              icon: const Icon(Icons.copy),
                              label: Text(l10n?.copy ?? 'Copy'),
                            ),
                          ),
                        if (onCopy != null && onDelete != null)
                          const SizedBox(width: 8),
                        if (onDelete != null)
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              onPressed: () => onDelete(sheetContext),
                              icon: const Icon(Icons.delete),
                              label: Text(l10n?.delete ?? 'Delete'),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (customPropertiesActions != null) customPropertiesActions,
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
