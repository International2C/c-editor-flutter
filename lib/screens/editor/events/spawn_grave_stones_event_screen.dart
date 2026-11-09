import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Spawn gravestones event editor. Ported from Z-Editor-master SpawnGraveStonesEventEP.kt
class SpawnGraveStonesEventScreen extends StatefulWidget {
  const SpawnGraveStonesEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestGridItemSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestGridItemSelection;

  @override
  State<SpawnGraveStonesEventScreen> createState() =>
      _SpawnGraveStonesEventScreenState();
}

class _SpawnGraveStonesEventScreenState
    extends State<SpawnGraveStonesEventScreen> {
  static const _objClass = 'SpawnGravestonesWaveActionProps';
  static const _crashProneGridItemTypeNames = <String>{
    'heavy_shield',
    'cavalrygun',
  };

  late PvzObject _moduleObj;
  late SpawnGraveStonesData _data;
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
        objData: SpawnGraveStonesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpawnGraveStonesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpawnGraveStonesData();
    }
    _data = SpawnGraveStonesData(
      gravestonePool: List.from(_data.gravestonePool),
      spawnPositionsPool: List.from(_data.spawnPositionsPool),
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    GridItemRepository.cleanupUnusedCustomGridItemTypes(widget.levelFile);
    widget.onChanged();
    setState(() {});
  }

  void _togglePosition(int col, int row) {
    final existing = _data.spawnPositionsPool.firstWhereOrNull(
      (p) => p.x == col && p.y == row,
    );
    if (existing != null) {
      _data.spawnPositionsPool.remove(existing);
    } else {
      _data.spawnPositionsPool.add(LocationData(x: col, y: row));
    }
    _sync();
  }

  void _addItem() {
    widget.onRequestGridItemSelection((typeName) {
      if (_resolveCrashProneGridItemType(typeName) != null) {
        _showCrashProneGridItemBlockedDialog();
        return;
      }

      final fullRtid = GridItemRepository.buildGridItemTypeRtid(
        typeName,
        widget.levelFile,
      );
      final existingIdx = _data.gravestonePool.indexWhere(
        (i) => i.type == fullRtid,
      );
      if (existingIdx >= 0) {
        final item = _data.gravestonePool[existingIdx];
        _data.gravestonePool[existingIdx] = GravestonePoolItem(
          count: item.count + 1,
          type: item.type,
        );
      } else {
        _data.gravestonePool.add(GravestonePoolItem(count: 1, type: fullRtid));
      }
      _sync();
    });
  }

  String? _resolveCrashProneGridItemType(String typeName) {
    final parsed = RtidParser.parse(typeName);
    final alias = parsed?.alias ?? typeName;
    final actualTypeName =
        GridItemRepository.getByTypeName(alias)?.actualTypeName ?? alias;
    if (_crashProneGridItemTypeNames.contains(actualTypeName)) {
      return actualTypeName;
    }

    if (parsed?.source != 'CurrentLevel') return null;
    for (final object in widget.levelFile.objects) {
      if (object.objClass != 'GridItemType' ||
          object.aliases?.contains(alias) != true) {
        continue;
      }
      final objData = object.objData;
      final localTypeName = objData is Map ? objData['TypeName'] : null;
      if (localTypeName is String &&
          _crashProneGridItemTypeNames.contains(localTypeName)) {
        return localTypeName;
      }
    }
    return null;
  }

  bool get _levelHasCrashProneGridItem {
    if (_data.gravestonePool.any(
      (item) => _resolveCrashProneGridItemType(item.type) != null,
    )) {
      return true;
    }

    return widget.levelFile.objects.any((object) {
      if (identical(object, _moduleObj) || object.objClass != _objClass) {
        return false;
      }
      final objData = object.objData;
      if (objData is! Map) return false;
      final pool = objData['GravestonePool'];
      if (pool is! List) return false;
      return pool.any((entry) {
        if (entry is! Map) return false;
        final typeName = entry['Type'];
        return typeName is String &&
            _resolveCrashProneGridItemType(typeName) != null;
      });
    });
  }

  void _showCrashProneGridItemBlockedDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n?.warning ?? 'Warning'),
        content: Text(
          l10n?.spawnGravestonesCrashProneItemsWarning ??
              'Spawning Heavy Shield or Cavalry Lance through the "Grid Item Spawn" event causes the level to crash. Please spawn it another way.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    _data.gravestonePool.removeAt(index);
    _sync();
  }

  void _updateCount(int index, int count) {
    final item = _data.gravestonePool[index];
    _data.gravestonePool[index] = GravestonePoolItem(
      count: count,
      type: item.type,
    );
    _sync();
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final internalAliases = widget.levelFile.objects
        .expand<String>((o) => o.aliases ?? <String>[])
        .toSet();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
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
            tooltip: l10n?.tooltipAboutEvent ?? 'About this event',
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.eventSpawnGravestones ?? 'Spawn gravestones event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpGravestoneBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.logic ?? 'Logic',
                  body: l10n?.eventHelpGravestoneLogic ?? '',
                ),
                HelpSectionData(
                  title: l10n?.missingAssets ?? 'Missing assets',
                  body:
                      l10n?.eventHelpGravestoneMissingAssets ??
                      'Some maps without gravestone spawn effects may show sun textures instead.',
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
              if (_levelHasCrashProneGridItem) ...[
                _buildCrashProneGridItemWarning(theme, l10n),
                const SizedBox(height: 16),
              ],
              _buildPositionPoolCard(theme, l10n),
              const SizedBox(height: 16),
              _buildInfoCard(theme, l10n),
              const SizedBox(height: 16),
              _buildGravestonePoolHeader(theme, l10n),
              const SizedBox(height: 8),
              ..._data.gravestonePool.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return _buildGravestoneItem(
                  context,
                  theme,
                  item,
                  idx,
                  internalAliases,
                  l10n,
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrashProneGridItemWarning(
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      key: const ValueKey('spawnGravestonesCrashProneItemWarning'),
      color: theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(editorErrorIcon, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.spawnGravestonesCrashProneItemsWarning ??
                    'Spawning Heavy Shield or Cavalry Lance through the "Grid Item Spawn" event causes the level to crash. Please spawn it another way.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionPoolCard(ThemeData theme, AppLocalizations? l10n) {
    final posCount = _data.spawnPositionsPool.length;
    final itemCount = _data.gravestonePool.fold<int>(0, (s, i) => s + i.count);
    final isDark = theme.brightness == Brightness.dark;
    final gridColor = isDark
        ? const Color(0xFF3B332F)
        : const Color(0xFFD7CCC8);
    const borderColor = Color(0xFF8D6E63);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.positionPoolSpawnPositions ??
                  'Position pool (SpawnPositionsPool)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.tapCellsSelectDeselect ??
                  'Tap cells to select/deselect spawn positions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            scaleTableForDesktop(
              context: context,
              child: Builder(
                builder: (context) {
                  final parsed = LevelParser.parseLevel(widget.levelFile);
                  final isDeepSea = LevelParser.isDeepSeaLawn(
                    parsed.levelDef,
                    widget.levelFile,
                  );
                  final cols = isDeepSea ? 10 : 9;
                  final rows = isDeepSea ? 6 : 5;
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          EditorItemCardLayout.gridPreviewMaxWidth(context) *
                          0.7,
                    ),
                    child: AspectRatio(
                      aspectRatio: cols / rows,
                      child: Container(
                        key: const ValueKey(
                          'spawnGravestonesPositionPreviewGrid',
                        ),
                        decoration: BoxDecoration(
                          color: gridColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: List.generate(rows, (row) {
                            return Expanded(
                              child: Row(
                                children: List.generate(cols, (col) {
                                  final isSelected = _data.spawnPositionsPool
                                      .any((p) => p.x == col && p.y == row);
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => _togglePosition(col, row),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final cellSize = constraints.maxWidth;
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF2E7D32)
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: borderColor.withValues(
                                                  alpha: 0.5,
                                                ),
                                                width: 0.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: (cellSize * 0.85)
                                                        .clamp(16, 56),
                                                  )
                                                : null,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            EditorResponsiveFieldRow(
              breakpoint: 480,
              children: [
                Text(
                  l10n?.positionsCount(posCount) ?? 'Positions: $posCount',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n?.totalItemsCount(itemCount) ?? 'Total items: $itemCount',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: itemCount > posCount
                        ? theme.colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
            if (itemCount > posCount)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n?.itemCountExceedsPositionsWarning ??
                      'Warning: item count exceeds positions. Some will not spawn.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.gravestoneBlockedInfo ??
                    'Gravestones and similar obstacles blocked by plants cannot spawn. Use other methods to force spawn.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGravestonePoolHeader(ThemeData theme, AppLocalizations? l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            l10n?.gravestonePool ?? 'Gravestone pool (GravestonePool)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: l10n?.addType ?? 'Add type',
          child: PvzAddButton(onPressed: _addItem, size: 40),
        ),
      ],
    );
  }

  Widget _buildGravestoneItem(
    BuildContext context,
    ThemeData theme,
    GravestonePoolItem item,
    int index,
    Set<String> internalAliases,
    AppLocalizations? l10n,
  ) {
    final parsed = RtidParser.parse(item.type);
    final alias = parsed?.alias ?? item.type;
    final displayTypeName =
        GridItemRepository.getByTypeName(alias)?.actualTypeName ?? alias;
    final source = parsed?.source ?? '';
    final isValid = source == 'CurrentLevel'
        ? internalAliases.contains(alias)
        : GridItemRepository.isValid(displayTypeName);
    final resourceKey = 'griditem_$displayTypeName';
    final displayName = ResourceNames.lookup(context, resourceKey);
    final name = displayName != resourceKey ? displayName : displayTypeName;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isValid ? null : theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(
        side: isValid
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PresetAwareGridItemIcon(
              typeName: displayTypeName,
              size: 48,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    displayTypeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isValid
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 104,
              child: EditorResponsiveInputField(
                label: l10n?.count ?? 'Count',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                builder: (context, decoration) => TextFormField(
                  initialValue: '${item.count}',
                  decoration: decoration,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [PositiveIntegerInputFormatter()],
                  onChanged: (s) {
                    final v = int.tryParse(s) ?? 1;
                    _updateCount(index, v.clamp(1, 999));
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n?.delete ?? 'Delete',
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }
}
