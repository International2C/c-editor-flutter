import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/grid_item_module_prompt.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/selection_grid_layout.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';

/// Grid item selection. Ported from Z-Editor-master GridItemSelectionScreen.kt
class GridItemSelectionScreen extends StatefulWidget {
  const GridItemSelectionScreen({
    super.key,
    required this.onGridItemSelected,
    required this.onBack,
    required this.filterMode,
    this.levelFile,
    this.onAddModule,
    this.onOpenCustomStageSelection,
  });

  final void Function(String id) onGridItemSelected;
  final VoidCallback onBack;
  final GridItemFilterMode filterMode;
  final PvzLevelFile? levelFile;
  final void Function(String objClass)? onAddModule;
  final Future<void> Function()? onOpenCustomStageSelection;

  @override
  State<GridItemSelectionScreen> createState() =>
      _GridItemSelectionScreenState();
}

class _GridItemSelectionScreenState extends State<GridItemSelectionScreen> {
  String _searchQuery = '';
  GridItemCategory _selectedCategory = GridItemCategory.all;
  late final SelectionViewMemory _memory;
  late final ScrollController _scrollController;

  String get _memoryKey {
    final level = widget.levelFile;
    final bucket = level == null
        ? 'global'
        : 'level:${identityHashCode(level)}';
    return '$bucket:grid-item:${widget.filterMode.name}';
  }

  @override
  void initState() {
    super.initState();
    _memory = SelectionViewMemoryStore.forKey(_memoryKey);
    _searchQuery = _memory.query;
    final categoryName = _memory.filters['category'] as String?;
    _selectedCategory = GridItemCategory.values.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => GridItemCategory.all,
    );
    _scrollController = ScrollController(
      initialScrollOffset: _memory.scrollOffset,
    )..addListener(_rememberScrollOffset);
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _scrollController.dispose();
    super.dispose();
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _memory.query = query;
    _resetScrollOffset();
  }

  void _setCategory(GridItemCategory category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _memory.filters['category'] = category.name;
    _resetScrollOffset();
  }

  void _rememberScrollOffset() {
    if (_scrollController.hasClients) {
      _memory.scrollOffset = _scrollController.offset;
    }
  }

  void _resetScrollOffset() {
    _memory.scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  List<GridItemInfo> get _displayList {
    final baseList = switch (widget.filterMode) {
      GridItemFilterMode.renaiStatues =>
        GridItemRepository.getRenaiStatueItems(),
      _ =>
        _selectedCategory == GridItemCategory.all
            ? GridItemRepository.getAll()
            : GridItemRepository.getByCategory(_selectedCategory),
    };

    return baseList.where((item) {
      final isModeMatched = switch (widget.filterMode) {
        GridItemFilterMode.all => true,
        GridItemFilterMode.restricted => item.tag == GridItemTag.normal,
        GridItemFilterMode.renaiStatues => true,
      };
      final nameKey = 'griditem_${item.actualTypeName}';
      final isSearchMatched = matchesSelectionSearch(_searchQuery, [
        item.actualTypeName,
        nameKey,
        ResourceNames.lookup(context, nameKey),
      ]);
      return isModeMatched && isSearchMatched;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeColor = isDark ? pvzBrownDark : pvzBrownLight;
    final displayList = _displayList;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          title: AppBarSearchField(
            hintText: l10n?.searchGridItems ?? 'Search grid items',
            query: _searchQuery,
            onChanged: _setSearchQuery,
            onClear: () => _setSearchQuery(''),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: themeColor,
              child: HorizontalTagScroller(
                onAccentBar: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                initialScrollOffset: _memory.tagScrollOffset,
                onScrollOffsetChanged: (offset) {
                  _memory.tagScrollOffset = offset;
                },
                children: GridItemCategory.values.map((cat) {
                  return AccentBarChoiceChip(
                    label: _categoryLabel(cat, l10n),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => _setCategory(cat),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_module,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.noItems ?? 'No items',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = _selectionGridColumnCount(
                            constraints.maxWidth,
                          );

                          return GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisExtent:
                                      responsiveSelectionGridTileExtent(
                                        context,
                                        baseExtent: 190,
                                      ),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final item = displayList[index];
                              final displayName = ResourceNames.lookup(
                                context,
                                'griditem_${item.actualTypeName}',
                              );
                              final name =
                                  displayName !=
                                      'griditem_${item.actualTypeName}'
                                  ? displayName
                                  : item.actualTypeName;
                              return _GridItemCard(
                                item: item,
                                name: name,
                                theme: theme,
                                onTap: () => _handleItemTap(item),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleItemTap(GridItemInfo item) async {
    final levelFile = widget.levelFile;
    if (levelFile != null) {
      final proceed = await confirmGridItemModuleRequirements(
        context,
        typeName: item.actualTypeName,
        levelFile: levelFile,
        onAddModule: widget.onAddModule,
      );
      if (!proceed || !mounted) return;
      if (item.typeName == 'gravestone_tutorial' &&
          !_activeStageHasResourceGroup(levelFile, 'Modern_Gravestone')) {
        final l10n = AppLocalizations.of(context)!;
        final openCustomStage = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(l10n.customGravestoneResourceGroupPrompt),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.openCustomStageSelection),
              ),
            ],
          ),
        );
        if (openCustomStage == true && mounted) {
          await widget.onOpenCustomStageSelection?.call();
        }
        return;
      }
      if (GridItemRepository.hasConflictingExclusivePreset(
        item.typeName,
        levelFile,
      )) {
        final l10n = AppLocalizations.of(context)!;
        final nameKey = 'griditem_${item.actualTypeName}';
        final localizedName = ResourceNames.lookup(context, nameKey);
        final displayName = localizedName == nameKey
            ? item.actualTypeName
            : localizedName;
        final shouldReplace = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(l10n.customGravestoneReplacePrompt(displayName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.customGridItemReplaceAction),
              ),
            ],
          ),
        );
        if (shouldReplace != true || !mounted) return;
        GridItemRepository.replaceExclusivePreset(item.typeName, levelFile);
      } else {
        GridItemRepository.ensureCustomGridItemInLevel(
          item.typeName,
          levelFile,
        );
      }
    }
    widget.onGridItemSelected(GridItemRepository.toGameTypeName(item.typeName));
  }

  bool _activeStageHasResourceGroup(PvzLevelFile levelFile, String group) {
    final parsed = LevelParser.parseLevel(levelFile);
    final objdata = LevelParser.resolveStageObjdata(parsed.levelDef, levelFile);
    final groups = objdata?['ResourceGroupNames'];
    return groups is List && groups.contains(group);
  }

  String _categoryLabel(GridItemCategory cat, AppLocalizations? l10n) {
    if (l10n == null) return cat.label;
    switch (cat) {
      case GridItemCategory.all:
        return l10n.gridItemCategoryAll;
      case GridItemCategory.scene:
        return l10n.gridItemCategoryScene;
      case GridItemCategory.trap:
        return l10n.gridItemCategoryTrap;
      case GridItemCategory.spawnableObjects:
        return l10n.gridItemCategorySpawnableObjects;
    }
  }
}

int _selectionGridColumnCount(double width) {
  final columns = (width / 180).floor();
  if (columns < 2) return 2;
  if (columns > 6) return 6;
  return columns;
}

class _GridItemCard extends StatelessWidget {
  const _GridItemCard({
    required this.item,
    required this.name,
    required this.theme,
    required this.onTap,
  });

  final GridItemInfo item;
  final String name;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GridItemIcon(
                          typeName: item.typeName,
                          size: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: item.actualTypeName,
                    child: Text(
                      item.actualTypeName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.source == GridItemSource.custom)
                Positioned(
                  top: 0,
                  left: 0,
                  child: CustomResourceBadge(
                    color: presetCustomResourceBadgeColor(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
