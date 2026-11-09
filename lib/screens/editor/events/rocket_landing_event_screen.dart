import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class RocketLandingEventScreen extends StatefulWidget {
  const RocketLandingEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<RocketLandingEventScreen> createState() =>
      _RocketLandingEventScreenState();
}

class _RocketLandingEventScreenState extends State<RocketLandingEventScreen> {
  static const _objClass = 'SpawnRocketLandingWaveActionProps';

  late String _alias;
  late PvzObject _eventObject;
  late SpawnRocketLandingWaveActionPropsData _data;
  late TextEditingController _countCtrl;
  late TextEditingController _intervalCtrl;

  int get _gridRows =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$1;
  int get _gridCols =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$2;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _eventObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: SpawnRocketLandingWaveActionPropsData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_eventObject)) {
      widget.levelFile.objects.add(_eventObject);
    }
    try {
      _data = SpawnRocketLandingWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_eventObject.objData as Map),
      );
    } catch (_) {
      _data = SpawnRocketLandingWaveActionPropsData();
    }
    if (_data.rocketPool.isEmpty) {
      _data.rocketPool.add(RocketPoolEntryData());
    }
    _countCtrl = TextEditingController(text: '${_data.spawnCount}');
    _intervalCtrl = TextEditingController(text: '${_data.spawnInterval}');
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    _eventObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasAt(int col, int row) => _data.spawnPositionsPool.any(
    (entry) => entry.mx == col && entry.my == row,
  );

  void _togglePosition(int col, int row) {
    if (_hasAt(col, row)) {
      _data.spawnPositionsPool.removeWhere(
        (entry) => entry.mx == col && entry.my == row,
      );
    } else {
      _data.spawnPositionsPool.add(TileLocationData(mx: col, my: row));
    }
    _sync();
  }

  void _handleAliasChanged(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
              title: l10n?.rocketLandingHelpTitle ?? 'Rocket Landing',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.rocketLandingHelpOverview ?? '',
                ),
                HelpSectionData(
                  title: l10n?.logic ?? 'Logic',
                  body: l10n?.rocketLandingHelpLogic ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.rocketLandingHelpPlantsTitle ??
                      'Plants take control',
                  body: l10n?.rocketLandingHelpPlants ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.rocketLandingHelpZombiesTitle ??
                      'Zombies take control',
                  body: l10n?.rocketLandingHelpZombies ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            _buildPositionPoolCard(theme, l10n),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.rocketLandingSettings ?? 'Rocket settings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRocketPoolItem(theme, l10n),
                    const SizedBox(height: 12),
                    _numberField(
                      controller: _intervalCtrl,
                      label:
                          l10n?.rocketSpawnInterval ??
                          'Spawn interval (SpawnInterval, seconds)',
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.spawnInterval = parsed;
                          _sync();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRocketPoolItem(ThemeData theme, AppLocalizations? l10n) {
    final alias = LevelParser.extractAlias(_data.rocketPool.first.type);
    final displayTypeName =
        GridItemRepository.getByTypeName(alias)?.actualTypeName ?? alias;
    final resourceKey = 'griditem_$displayTypeName';
    final localizedName = ResourceNames.lookup(context, resourceKey);
    final displayName = localizedName != resourceKey
        ? localizedName
        : displayTypeName;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final rocketIdentity = Row(
              children: [
                GridItemIcon(
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
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        displayTypeName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
            final countField = SizedBox(
              width: 160,
              child: EditorResponsiveInputField(
                label: l10n?.count ?? 'Count',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                builder: (context, decoration) => TextField(
                  key: const ValueKey('rocketLandingCountField'),
                  controller: _countCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [PositiveIntegerInputFormatter()],
                  decoration: decoration,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed >= 1) {
                      _data.rocketPool.first.count = parsed;
                      _data.spawnCount = parsed;
                      _sync();
                    }
                  },
                ),
              ),
            );

            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  rocketIdentity,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: countField),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: rocketIdentity),
                const SizedBox(width: 12),
                countField,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPositionPoolCard(ThemeData theme, AppLocalizations? l10n) {
    final positionCount = _data.spawnPositionsPool.length;
    final spawnCount = _data.spawnCount;
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      EditorItemCardLayout.gridPreviewMaxWidth(context) * 0.7,
                ),
                child: AspectRatio(
                  aspectRatio: _gridCols / _gridRows,
                  child: Container(
                    key: const ValueKey('rocketLandingPositionPreviewGrid'),
                    decoration: BoxDecoration(
                      color: gridColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: List.generate(_gridRows, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(_gridCols, (col) {
                              final isSelected = _hasAt(col, row);
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
                                                size: (cellSize * 0.85).clamp(
                                                  16,
                                                  56,
                                                ),
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
              ),
            ),
            const SizedBox(height: 8),
            EditorResponsiveFieldRow(
              breakpoint: 480,
              children: [
                Text(
                  l10n?.positionsCount(positionCount) ??
                      'Positions: $positionCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n?.totalItemsCount(spawnCount) ??
                      'Total items: $spawnCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: spawnCount > positionCount
                        ? theme.colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
            if (spawnCount > positionCount)
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

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool decimal = true,
    bool integersOnly = false,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: integersOnly
            ? <TextInputFormatter>[const PositiveIntegerInputFormatter()]
            : null,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
