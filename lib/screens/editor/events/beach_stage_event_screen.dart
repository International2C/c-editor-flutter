import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Beach stage / low tide event editor. Ported from Z-Editor-master BeachStageEventEP.kt
class BeachStageEventScreen extends StatefulWidget {
  const BeachStageEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<BeachStageEventScreen> createState() => _BeachStageEventScreenState();
}

class _BeachStageEventScreenState extends State<BeachStageEventScreen> {
  static const _objClass = 'BeachStageEventZombieSpawnerProps';

  late PvzObject _moduleObj;
  late BeachStageEventData _data;
  late String _alias;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: BeachStageEventData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = BeachStageEventData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = BeachStageEventData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title:
                  l10n?.eventTitle_BeachStageEventZombieSpawnerProps ??
                  'Low tide event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpBeachStageBody ??
                      'Zombies spawn at low tide. Used for Pirate Seas.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              _buildZombieConfigCard(context, theme, l10n),
              const SizedBox(height: 16),
              _buildCountCard(context, theme, l10n),
              const SizedBox(height: 16),
              _buildRangeTimeCard(context, theme, l10n),
              const SizedBox(height: 16),
              _buildMessageCard(context, theme, l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZombieConfigCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final realTypeName = ZombiePropertiesRepository.getTypeNameByAlias(
      _data.zombieName,
    );
    final zombieInfo = ZombieRepository().getZombieById(
      realTypeName.isEmpty ? _data.zombieName : realTypeName,
    );
    final typeName = realTypeName.isEmpty ? _data.zombieName : realTypeName;
    final nameKey = ZombieRepository().getName(typeName);
    final displayName = ResourceNames.lookup(context, nameKey);
    final iconPath = zombieInfo?.iconAssetPath;

    return Card(
      child: InkWell(
        onTap: () {
          widget.onRequestZombieSelection((id) {
            final aliases = ZombieRepository().buildZombieAliases(id);
            _data = BeachStageEventData(
              columnStart: _data.columnStart,
              columnEnd: _data.columnEnd,
              groupSize: _data.groupSize,
              zombieCount: _data.zombieCount,
              zombieName: aliases,
              timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
              timeBetweenGroups: _data.timeBetweenGroups,
              waveStartMessage: _data.waveStartMessage,
            );
            _sync();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: iconPath != null
                    ? AssetImageWidget(
                        assetPath: iconPath,
                        altCandidates: imageAltCandidates(iconPath),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          _data.zombieName.isEmpty
                              ? '?'
                              : displayName.isNotEmpty
                              ? displayName[0]
                              : '?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data.zombieName.isEmpty
                          ? (l10n?.jamNone ?? 'None')
                          : displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_data.zombieName.isNotEmpty && typeName.isNotEmpty)
                      Text(
                        typeName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.spawnCount ?? 'Spawn count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            EditorResponsiveFieldRow(
              children: [
                EditorResponsiveInputField(
                  label: l10n?.zombieCount ?? 'Zombie count (ZombieCount)',
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  builder: (context, decoration) => TextFormField(
                    initialValue: _data.zombieCount.toString(),
                    decoration: decoration,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = BeachStageEventData(
                          columnStart: _data.columnStart,
                          columnEnd: _data.columnEnd,
                          groupSize: _data.groupSize,
                          zombieCount: n,
                          zombieName: _data.zombieName,
                          timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                          timeBetweenGroups: _data.timeBetweenGroups,
                          waveStartMessage: _data.waveStartMessage,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
                EditorResponsiveInputField(
                  label: l10n?.groupSize ?? 'Group size',
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  builder: (context, decoration) => TextFormField(
                    initialValue: _data.groupSize.toString(),
                    decoration: decoration,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = BeachStageEventData(
                          columnStart: _data.columnStart,
                          columnEnd: _data.columnEnd,
                          groupSize: n,
                          zombieCount: _data.zombieCount,
                          zombieName: _data.zombieName,
                          timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                          timeBetweenGroups: _data.timeBetweenGroups,
                          waveStartMessage: _data.waveStartMessage,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeTimeCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.columnRangeTiming ?? 'Column range & timing',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            EditorResponsiveFieldRow(
              children: [
                EditorResponsiveInputField(
                  label: l10n?.columnStartLabel ?? 'Start column (ColumnStart)',
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  builder: (context, decoration) => TextFormField(
                    initialValue: _data.columnStart.toString(),
                    decoration: decoration,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = BeachStageEventData(
                          columnStart: n,
                          columnEnd: _data.columnEnd,
                          groupSize: _data.groupSize,
                          zombieCount: _data.zombieCount,
                          zombieName: _data.zombieName,
                          timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                          timeBetweenGroups: _data.timeBetweenGroups,
                          waveStartMessage: _data.waveStartMessage,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
                EditorResponsiveInputField(
                  label: l10n?.columnEndLabel ?? 'End column (ColumnEnd)',
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  builder: (context, decoration) => TextFormField(
                    initialValue: _data.columnEnd.toString(),
                    decoration: decoration,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = BeachStageEventData(
                          columnStart: _data.columnStart,
                          columnEnd: n,
                          groupSize: _data.groupSize,
                          zombieCount: _data.zombieCount,
                          zombieName: _data.zombieName,
                          timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                          timeBetweenGroups: _data.timeBetweenGroups,
                          waveStartMessage: _data.waveStartMessage,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const EventColumnRangeHint(),
            const SizedBox(height: 12),
            EditorResponsiveFieldRow(
              children: [
                EditorResponsiveInputField(
                  label: l10n?.timeBetweenGroups ?? 'Time between groups (s)',
                  builder: (context, decoration) => TextFormField(
                    initialValue: _data.timeBetweenGroups.toString(),
                    decoration: decoration,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null) {
                        _data = BeachStageEventData(
                          columnStart: _data.columnStart,
                          columnEnd: _data.columnEnd,
                          groupSize: _data.groupSize,
                          zombieCount: _data.zombieCount,
                          zombieName: _data.zombieName,
                          timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                          timeBetweenGroups: n,
                          waveStartMessage: _data.waveStartMessage,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
                EditorResponsiveInputField(
                  label:
                      l10n?.timeBeforeSpawn ??
                      'Time before spawn (TimeBeforeFullSpawn; seconds)',
                  builder: (context, decoration) => TextFormField(
                    initialValue: _data.timeBeforeFullSpawn.toString(),
                    decoration: decoration,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null) {
                        _data = BeachStageEventData(
                          columnStart: _data.columnStart,
                          columnEnd: _data.columnEnd,
                          groupSize: _data.groupSize,
                          zombieCount: _data.zombieCount,
                          zombieName: _data.zombieName,
                          timeBeforeFullSpawn: n,
                          timeBetweenGroups: _data.timeBetweenGroups,
                          waveStartMessage: _data.waveStartMessage,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.waveStartMessageLabel ??
                  'Red warning message (WaveStartMessage)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const ValueKey('waveStartMessageField'),
              initialValue: _data.waveStartMessage,
              decoration: InputDecoration(
                helperText:
                    l10n?.optionalWarningText ??
                    'Optional red warning text shown at the center of the screen when the event begins; Chinese is not supported',
                helperMaxLines: 3,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                _data = BeachStageEventData(
                  columnStart: _data.columnStart,
                  columnEnd: _data.columnEnd,
                  groupSize: _data.groupSize,
                  zombieCount: _data.zombieCount,
                  zombieName: _data.zombieName,
                  timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                  timeBetweenGroups: _data.timeBetweenGroups,
                  waveStartMessage: v,
                );
                _sync();
              },
            ),
          ],
        ),
      ),
    );
  }
}
