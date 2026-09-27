import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Atlantis shell event editor. Based on ZombiePotionActionProps.
/// Only atlantis_shell type is supported.
class ShellEventScreen extends StatefulWidget {
  const ShellEventScreen({
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
  State<ShellEventScreen> createState() => _ShellEventScreenState();
}

class _ShellEventScreenState extends State<ShellEventScreen> {
  static const _objClass = 'ZombieAtlantisShellActionProps';

  late PvzObject _moduleObj;
  late ZombieAtlantisShellActionPropsData _data;
  late String _alias;
  int _selectedX = 0;
  int _selectedY = 0;
  AtlantisShellTileData? _itemToDelete;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

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
        objData: ZombieAtlantisShellActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ZombieAtlantisShellActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ZombieAtlantisShellActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addShell() {
    final newItem = AtlantisShellTileData(
      location: LocationData(x: _selectedX, y: _selectedY),
      type: 'atlantis_shell',
    );
    _data = ZombieAtlantisShellActionPropsData(
      tiles: [..._data.tiles, newItem],
    );
    _sync();
  }

  void _removeShell(AtlantisShellTileData item) {
    _data = ZombieAtlantisShellActionPropsData(
      tiles: _data.tiles.where((t) => t != item).toList(),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final itemsAtPosition = _data.tiles
        .where(
          (t) =>
              t.location.x == _selectedX &&
              t.location.y == _selectedY &&
              t.location.x >= 0 &&
              t.location.y >= 0 &&
              t.location.x < _gridCols &&
              t.location.y < _gridRows,
        )
        .toList();
    final itemsOutsideLawn = _data.tiles
        .where(
          (t) =>
              t.location.x < 0 ||
              t.location.y < 0 ||
              t.location.x >= _gridCols ||
              t.location.y >= _gridRows,
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
              title: l10n?.eventShellSpawn ?? 'Shell spawn event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpShellBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.usage ?? 'Usage',
                  body: l10n?.eventHelpShellUsage ?? '',
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
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.selectedPosition ??
                                          'Selected position',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      'R${_selectedY + 1} : C${_selectedX + 1}',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
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
                        (item) => _ShellItemCard(
                          item: item,
                          gridRows: _gridRows,
                          gridCols: _gridCols,
                          showCoordinates: false,
                          onDelete: () => setState(() => _itemToDelete = item),
                          deleteTooltip: l10n?.delete ?? 'Delete',
                        ),
                      ),
                      AddItemCard(
                        onPressed: _addShell,
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
                            (item) => _ShellItemCard(
                              item: item,
                              gridRows: _gridRows,
                              gridCols: _gridCols,
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
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF31383B)
                  : const Color(0xFFD7ECF1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6B899A), width: 1),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final cellItems = _data.tiles
                          .where(
                            (t) => t.location.x == col && t.location.y == row,
                          )
                          .toList();
                      final firstItem = cellItems.firstOrNull;
                      final count = cellItems.length;
                      return Expanded(
                        child: GestureDetector(
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
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.asset(
                                                    GridItemRepository.getIconPath(
                                                      firstItem.type,
                                                    ),
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality.medium,
                                                  ),
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
            _removeShell(item);
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

class _ShellItemCard extends StatelessWidget {
  const _ShellItemCard({
    required this.item,
    required this.gridRows,
    required this.gridCols,
    required this.showCoordinates,
    required this.onDelete,
    required this.deleteTooltip,
  });

  final AtlantisShellTileData item;
  final int gridRows;
  final int gridCols;
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
              icon: PresetAwareGridItemIcon(
                typeName: item.type,
                size: 64,
                fit: BoxFit.contain,
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
