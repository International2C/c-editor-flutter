import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

const _eagleStandardType = 'roman_eagle_flag';

/// Eagle Standard wave event editor (`SpawnEagleFlagsWaveActionProps`).
class EagleStandardEventScreen extends StatefulWidget {
  const EagleStandardEventScreen({
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
  State<EagleStandardEventScreen> createState() =>
      _EagleStandardEventScreenState();
}

class _EagleStandardEventScreenState extends State<EagleStandardEventScreen> {
  static const _objClass = 'SpawnEagleFlagsWaveActionProps';

  late PvzObject _moduleObj;
  late SpawnEagleFlagsWaveActionPropsData _data;
  late String _alias;
  int _selectedX = 0;
  int _selectedY = 0;
  EagleFlagData? _itemToDelete;

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
        objData: SpawnEagleFlagsWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpawnEagleFlagsWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpawnEagleFlagsWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addFlag() {
    final newItem = EagleFlagData(
      location: LocationData(x: _selectedX, y: _selectedY),
      type: _eagleStandardType,
    );
    _data.flags.add(newItem);
    _sync();
  }

  void _removeFlag(EagleFlagData item) {
    _data.flags.remove(item);
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
    final itemsAtPosition = _data.flags
        .where(
          (t) =>
              t.location.x == _selectedX &&
              t.location.y == _selectedY &&
              t.location.x >= 0 &&
              t.location.y >= 0 &&
              t.location.x < gridCols &&
              t.location.y < gridRows,
        )
        .toList();
    final itemsOutsideLawn = _data.flags
        .where(
          (t) =>
              t.location.x < 0 ||
              t.location.y < 0 ||
              t.location.x >= gridCols ||
              t.location.y >= gridRows,
        )
        .toList();

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
              title: eventTitle,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpEagleStandardBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.eventHelpEagleStandardEligibleZombiesTitle ??
                      'Eligible zombies',
                  body: l10n?.eventHelpEagleStandardEligibleZombiesBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.usage ?? 'Usage',
                  body: l10n?.eventHelpEagleStandardUsage ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditorAliasInputField(
                    alias: _alias,
                    levelFile: widget.levelFile,
                    onAliasChanged: _handleAliasChanged,
                    onChanged: widget.onChanged,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.selectedPosition ?? 'Selected position',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'R${_selectedY + 1} : C${_selectedX + 1}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildGrid(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.itemsSortedByRow ?? 'Items (sorted by row)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...itemsAtPosition.map(
                        (item) => _EagleStandardItemCard(
                          item: item,
                          showCoordinates: false,
                          onDelete: () => setState(() => _itemToDelete = item),
                          deleteTooltip: l10n?.delete ?? 'Delete',
                        ),
                      ),
                      AddItemCard(
                        key: const ValueKey('eagle-add-flag'),
                        onPressed: _addFlag,
                        minHeight: EditorItemCardLayout.gridItemCardHeight,
                      ),
                    ],
                  ),
                  if (itemsOutsideLawn.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n?.outsideLawnItems ?? 'Objects outside the lawn',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: itemsOutsideLawn
                          .map(
                            (item) => _EagleStandardItemCard(
                              item: item,
                              showCoordinates: true,
                              onDelete: () =>
                                  setState(() => _itemToDelete = item),
                              deleteTooltip: l10n?.delete ?? 'Delete',
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_itemToDelete != null) _buildDeleteDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final theme = Theme.of(context);
    final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: gridCols / gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF31383B)
                  : const Color(0xFFD7ECF1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6B899A), width: 1),
            ),
            child: Column(
              children: List.generate(gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final cellItems = _data.flags
                          .where(
                            (t) => t.location.x == col && t.location.y == row,
                          )
                          .toList();
                      final firstItem = cellItems.firstOrNull;
                      final count = cellItems.length;
                      return Expanded(
                        child: GestureDetector(
                          key: ValueKey('eagle-cell-$col-$row'),
                          onTap: () => setState(() {
                            _selectedX = col;
                            _selectedY = row;
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF6B899A),
                                width: 0.5,
                              ),
                            ),
                            child: count > 0 && firstItem != null
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: GridItemIcon(
                                                  typeName: firstItem.type,
                                                  fit: BoxFit.contain,
                                                  borderRadius: 0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (count > 1)
                                            GridCellCountBadge(
                                              label: '+${count - 1}',
                                              cellWidth: constraints.maxWidth,
                                            ),
                                        ],
                                      );
                                    },
                                  )
                                : null,
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
    );
  }

  Widget _buildDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    final item = _itemToDelete!;
    final displayName = ResourceNames.lookup(context, 'griditem_${item.type}');
    final name = displayName != 'griditem_${item.type}'
        ? displayName
        : item.type;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        l10n?.removeItemConfirm(
              'R${item.location.y + 1}:C${item.location.x + 1} $name',
            ) ??
            'Remove R${item.location.y + 1}:C${item.location.x + 1} $name?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _itemToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _removeFlag(item);
            setState(() => _itemToDelete = null);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n?.remove ?? 'Remove'),
        ),
      ],
    );
  }
}

class _EagleStandardItemCard extends StatelessWidget {
  const _EagleStandardItemCard({
    required this.item,
    required this.showCoordinates,
    required this.onDelete,
    required this.deleteTooltip,
  });

  final EagleFlagData item;
  final bool showCoordinates;
  final VoidCallback onDelete;
  final String deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = ResourceNames.lookup(context, 'griditem_${item.type}');
    final name = displayName != 'griditem_${item.type}'
        ? displayName
        : item.type;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: EditorItemCardLayout.cardWidth(context),
        constraints: const BoxConstraints(
          minHeight: EditorItemCardLayout.gridItemCardHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EditorDeletableIconHeader(
              onDelete: onDelete,
              deleteTooltip: deleteTooltip,
              icon: SizedBox(
                height: 64,
                child: GridItemIcon(
                  typeName: item.type,
                  size: 64,
                  fit: BoxFit.contain,
                  borderRadius: 0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Tooltip(
                    message: item.type,
                    child: Text(
                      item.type,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showCoordinates)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            editorWarningIcon,
                            color: editorWarningBannerForeground(
                              theme.brightness,
                            ),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'R${item.location.y + 1}:C${item.location.x + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: editorWarningBannerForeground(
                                  theme.brightness,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
