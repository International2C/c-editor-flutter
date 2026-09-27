import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/magic_hat_spawn_preview_screen.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/selection_grid_confirmation.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart'
    show
        AccentBarFilterTabRow,
        AccentBarTabBarStyle,
        ScrollableWithMouseDrag,
        SelectionSearchField;

/// Placeholder when a plant has no icon or icon fails to load.
const String _kUnknownIconPath = 'assets/images/others/unknown.webp';
const String _kComingSoonPlantId = 'coming_soon';

/// Internal tag → module objClass required to enable those plants.
const Map<String, String> _moduleGatedPlantTags = {
  '_internal_copycats': 'PVZ1CopycatsModuleProperties',
};

bool _isRealmExclusivePlant(PlantInfo plant) =>
    plant.hasInternalTag('_internal_no42') ||
    plant.hasInternalTag('_internal_mausoleum');

bool _isHiddenPlant(PlantInfo plant) => plant.tags.contains(PlantTag.hidden);

bool _isComingSoonPlantId(String id) => id == _kComingSoonPlantId;

enum _PlantBlockedReason {
  comingSoon,
  realmExclusiveChooser,
  hiddenChooser,
  missingModule,
}

class _PlantSelectionViewState {
  _PlantSelectionViewState({required this.category, required this.tag})
    : searchQuery = '',
      scrollOffset = 0,
      tagScrollOffset = 0;

  PlantCategory category;
  PlantTag tag;
  String searchQuery;
  double scrollOffset;
  double tagScrollOffset;
}

final Map<String, _PlantSelectionViewState> _plantSelectionViewStates = {};

/// Plant selection. Ported from Z-Editor-master PlantSelectionScreen.kt
class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({
    super.key,
    this.isMultiSelect = false,
    required this.onPlantSelected,
    this.onMultiPlantSelected,
    required this.onBack,
    this.excludeIds = const [],
    this.initialSelectedIds = const [],
    this.levelFile,
    this.onAddModule,
    this.blockRealmExclusiveInChooser = false,
    this.blockHiddenPlantsInChooser = false,
    this.allowDuplicateSelection = false,
    this.stateBucketId,
  });

  final bool isMultiSelect;
  final void Function(String) onPlantSelected;
  final void Function(List<String>)? onMultiPlantSelected;
  final VoidCallback onBack;

  /// IDs to exclude from selection (e.g. entries in a conflicting list).
  final List<String> excludeIds;

  /// When unique multi-select is used, these IDs start selected (already in the parent list).
  final List<String> initialSelectedIds;

  /// When set, parallel plants gated by modules are disabled until the corresponding module is in the level.
  final PvzLevelFile? levelFile;

  /// Called when user taps "Add" in the "module required" dialog. Must add the module to the level and sync.
  final void Function(String objClass)? onAddModule;

  /// When true, realm-exclusive plants cannot be picked (seed bank chooser white/black lists).
  final bool blockRealmExclusiveInChooser;

  /// When true, Hidden plants cannot be picked (seed bank chooser mode only).
  final bool blockHiddenPlantsInChooser;

  /// When true, each tap in multi-select adds another entry (preset seed bank list).
  final bool allowDuplicateSelection;

  /// Keeps chooser tab and scroll state local to the current editing context.
  final String? stateBucketId;

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  final List<String> _selectedIdsWithDuplicates = [];
  bool _isLoaded = false;
  late PlantCategory _selectedCategory;
  late PlantTag _selectedTag;
  late final ScrollController _scrollController;

  String get _viewStateKey {
    final explicit = widget.stateBucketId;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final levelFile = widget.levelFile;
    if (levelFile != null) return 'level:${identityHashCode(levelFile)}';
    return 'global';
  }

  @override
  void initState() {
    super.initState();
    final rememberedState = _plantSelectionViewStates[_viewStateKey];
    _selectedCategory = rememberedState?.category ?? PlantCategory.quality;
    _selectedTag = rememberedState?.tag ?? PlantTag.all;
    _searchQuery = rememberedState?.searchQuery ?? '';
    _normalizeSelectedTag();
    _scrollController = ScrollController(
      initialScrollOffset: rememberedState?.scrollOffset ?? 0,
    )..addListener(_rememberScrollOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
    if (widget.isMultiSelect &&
        !widget.allowDuplicateSelection &&
        widget.initialSelectedIds.isNotEmpty) {
      _selectedIds.addAll(widget.initialSelectedIds);
    }
    PlantRepository().init().then((_) {
      if (mounted) {
        setState(() {
          _removeChooserBlockedSelections();
          _isLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _scrollController.dispose();
    super.dispose();
  }

  List<PlantTag> _visibleTagsFor(PlantCategory category) {
    if (category == PlantCategory.collection) return [];
    return [
      PlantTag.all,
      ...PlantTag.values.where(
        (t) => t != PlantTag.all && t.category == category,
      ),
    ];
  }

  void _setCategory(PlantCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      final tags = _visibleTagsFor(category);
      _selectedTag = tags.isNotEmpty ? tags.first : PlantTag.all;
    });
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0, tagScrollOffset: 0);
  }

  void _setTag(PlantTag tag) {
    if (_selectedTag == tag) return;
    setState(() => _selectedTag = tag);
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0);
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _resetRememberedScrollOffset();
  }

  void _normalizeSelectedTag() {
    if (_selectedCategory == PlantCategory.collection) {
      _selectedTag = PlantTag.all;
      return;
    }
    final tags = _visibleTagsFor(_selectedCategory);
    if (!tags.contains(_selectedTag)) {
      _selectedTag = tags.first;
    }
  }

  void _rememberViewState({double? scrollOffset, double? tagScrollOffset}) {
    final state = _plantSelectionViewStates.putIfAbsent(
      _viewStateKey,
      () => _PlantSelectionViewState(
        category: _selectedCategory,
        tag: _selectedTag,
      ),
    );
    state.category = _selectedCategory;
    state.tag = _selectedTag;
    state.searchQuery = _searchQuery;
    if (scrollOffset != null) state.scrollOffset = scrollOffset;
    if (tagScrollOffset != null) {
      state.tagScrollOffset = tagScrollOffset;
    }
  }

  void _rememberTagScrollOffset(double offset) {
    _rememberViewState(tagScrollOffset: offset);
  }

  void _rememberScrollOffset() {
    if (!_scrollController.hasClients) return;
    _rememberViewState(scrollOffset: _scrollController.offset);
  }

  void _resetRememberedScrollOffset({bool persist = true}) {
    if (persist) _rememberViewState(scrollOffset: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  void _restoreRememberedScrollOffset() {
    if (!mounted || !_scrollController.hasClients) return;
    final offset = _plantSelectionViewStates[_viewStateKey]?.scrollOffset ?? 0;
    final position = _scrollController.position;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_scrollController.offset != target) {
      _scrollController.jumpTo(target);
    }
  }

  void _toggleFavorite(BuildContext context, String id) async {
    await PlantRepository().toggleFavorite(id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final isFav = PlantRepository().isFavorite(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFav
              ? (l10n?.addedToFavorites ?? 'Added to favorites')
              : (l10n?.removedFromFavorites ?? 'Removed from favorites'),
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
    setState(() {});
  }

  Set<String> _levelModuleObjClasses() {
    final lf = widget.levelFile;
    if (lf == null) return {};
    return LevelIssueContext.fromLevel(lf).moduleObjClasses;
  }

  _PlantBlockedReason? _chooserBlockedReasonForPlant(PlantInfo plant) {
    if (_isComingSoonPlantId(plant.id)) return _PlantBlockedReason.comingSoon;
    if (widget.blockRealmExclusiveInChooser && _isRealmExclusivePlant(plant)) {
      return _PlantBlockedReason.realmExclusiveChooser;
    }
    if (widget.blockHiddenPlantsInChooser && _isHiddenPlant(plant)) {
      return _PlantBlockedReason.hiddenChooser;
    }
    return null;
  }

  _PlantBlockedReason? _chooserBlockedReasonForPlantId(String id) {
    if (_isComingSoonPlantId(id)) return _PlantBlockedReason.comingSoon;
    final plant = PlantRepository().getPlantInfoById(id);
    if (plant == null) return null;
    return _chooserBlockedReasonForPlant(plant);
  }

  _PlantBlockedReason? _plantBlockedReason(
    PlantInfo plant,
    Set<String> levelModules,
  ) {
    final chooserReason = _chooserBlockedReasonForPlant(plant);
    if (chooserReason != null) return chooserReason;
    for (final entry in _moduleGatedPlantTags.entries) {
      if (plant.hasInternalTag(entry.key)) {
        if (!levelModules.contains(entry.value)) {
          return _PlantBlockedReason.missingModule;
        }
      }
    }
    return null;
  }

  void _removeChooserBlockedSelections() {
    bool isBlocked(String id) => _chooserBlockedReasonForPlantId(id) != null;
    _selectedIds.removeWhere(isBlocked);
    _selectedIdsWithDuplicates.removeWhere(isBlocked);
  }

  List<String> _filterChooserSelectablePlantIds(List<String> ids) {
    return ids
        .where((id) => _chooserBlockedReasonForPlantId(id) == null)
        .toList();
  }

  String? _requiredModuleForPlant(PlantInfo plant) {
    for (final entry in _moduleGatedPlantTags.entries) {
      if (plant.hasInternalTag(entry.key)) return entry.value;
    }
    return null;
  }

  Future<void> _showRealmExclusiveChooserBlockedDialog(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n?.realmExclusivePlantChooserBlockedTitle ?? 'Cannot select plant',
        ),
        content: Text(
          l10n?.realmExclusivePlantChooserBlockedMessage ??
              'Realm-exclusive plants cannot be selected in Chooser Mode. '
                  'To use them, please refer to other methods such as Preset Mode, '
                  'Conveyor Belt, or Packet Drops.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHiddenPlantChooserBlockedDialog(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n?.hiddenPlantChooserBlockedTitle ?? 'Cannot select plant',
        ),
        content: Text(
          l10n?.hiddenPlantChooserBlockedMessage ??
              'Hidden plants cannot be selected in Chooser Mode. Use Preset '
                  'Mode, Conveyor Belt, Packet Drops, or other methods instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showComingSoonPlantBlockedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(l10n?.comingSoonPlantBlockedTitle ?? 'To Be Continued'),
        content: Text(
          l10n?.comingSoonPlantBlockedMessage ??
              'The plants are still growing strong. Stay tuned for '
                  'future updates!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChooserBlockedDialog(
    BuildContext context,
    _PlantBlockedReason reason,
  ) async {
    switch (reason) {
      case _PlantBlockedReason.comingSoon:
        await _showComingSoonPlantBlockedDialog(context);
        return;
      case _PlantBlockedReason.realmExclusiveChooser:
        await _showRealmExclusiveChooserBlockedDialog(context);
        return;
      case _PlantBlockedReason.hiddenChooser:
        await _showHiddenPlantChooserBlockedDialog(context);
        return;
      case _PlantBlockedReason.missingModule:
        return;
    }
  }

  Future<void> _onPlantTap(
    BuildContext context,
    PlantInfo plant,
    _PlantBlockedReason? blockedReason,
  ) async {
    if (blockedReason == _PlantBlockedReason.comingSoon ||
        blockedReason == _PlantBlockedReason.realmExclusiveChooser ||
        blockedReason == _PlantBlockedReason.hiddenChooser) {
      await _showChooserBlockedDialog(context, blockedReason!);
      return;
    }
    if (blockedReason == null) {
      if (widget.isMultiSelect) {
        setState(() {
          if (widget.allowDuplicateSelection) {
            _selectedIdsWithDuplicates.add(plant.id);
          } else if (_selectedIds.contains(plant.id)) {
            _selectedIds.remove(plant.id);
          } else {
            _selectedIds.add(plant.id);
          }
        });
      } else {
        widget.onPlantSelected(plant.id);
      }
      return;
    }
    if (blockedReason != _PlantBlockedReason.missingModule) return;
    final requiredObjClass = _requiredModuleForPlant(plant);
    if (requiredObjClass == null || widget.onAddModule == null) return;
    final l10n = AppLocalizations.of(context)!;
    final meta = ModuleRegistry.getMetadata(requiredObjClass);
    final moduleName = meta.getTitle(context);
    final message = l10n.plantModuleRequiredMessage(moduleName);
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (added == true && mounted) {
      widget.onAddModule!(requiredObjClass);
      if (!widget.isMultiSelect &&
          requiredObjClass == 'PVZ1CopycatsModuleProperties') {
        widget.onPlantSelected(plant.id);
      }
      setState(() {});
    }
  }

  void _deselectPlant(String plantId) {
    setState(() {
      _selectedIds.remove(plantId);
      _selectedIdsWithDuplicates.removeWhere((id) => id == plantId);
    });
  }

  void _selectAllVisible(
    List<PlantInfo> plants,
    Set<String> levelModuleObjClasses,
  ) {
    final selectableIds = plants
        .where(
          (plant) => _plantBlockedReason(plant, levelModuleObjClasses) == null,
        )
        .map((plant) => plant.id)
        .toList(growable: false);
    if (selectableIds.isEmpty) return;

    setState(() {
      if (widget.allowDuplicateSelection) {
        final existing = _selectedIdsWithDuplicates.toSet();
        final missing = selectableIds
            .where((id) => !existing.contains(id))
            .toList(growable: false);
        if (missing.isEmpty) {
          _selectedIdsWithDuplicates.removeWhere(selectableIds.contains);
        } else {
          _selectedIdsWithDuplicates.addAll(missing);
        }
      } else {
        final allSelected = selectableIds.every(_selectedIds.contains);
        if (allSelected) {
          _selectedIds.removeAll(selectableIds);
        } else {
          _selectedIds.addAll(selectableIds);
        }
      }
    });
  }

  bool _isMagicHatPlant(PlantInfo plant) =>
      plant.id.startsWith('minigame_imitater');

  void _openMagicHatPreview(BuildContext context, String hatPlantId) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => MagicHatSpawnPreviewScreen(
          hatPlantId: hatPlantId,
          levelFile: widget.levelFile,
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  List<PlantInfo> _categoryFilteredPlants(PlantRepository repo) {
    if (!repo.isLoaded) return [];
    return repo.search(
      '',
      _selectedCategory == PlantCategory.collection ? null : _selectedTag,
      _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = PlantRepository();
    final levelModuleObjClasses = _levelModuleObjClasses();
    final repositoryPlants = repo.search(
      _searchQuery,
      _selectedCategory == PlantCategory.collection ? null : _selectedTag,
      _selectedCategory,
    );
    final allPlants = _searchQuery.trim().isEmpty
        ? repositoryPlants
        : mergeUniqueSelectionResults(
            repositoryPlants,
            _categoryFilteredPlants(repo).where(
              (plant) => matchesSelectionSearch(_searchQuery, [
                ResourceNames.lookup(context, plant.name),
              ]),
            ),
            (plant) => plant.id,
          );
    final excludeSet = widget.excludeIds.toSet();
    final plants = excludeSet.isEmpty
        ? allPlants
        : allPlants.where((p) => !excludeSet.contains(p.id)).toList();
    _normalizeSelectedTag();
    final visibleTags = _visibleTagsFor(_selectedCategory);
    final tagIndex = visibleTags.indexOf(_selectedTag);
    final safeTagIndex = tagIndex < 0 ? 0 : tagIndex;
    final themeColor = theme.colorScheme.primary;
    final filterMaxHeight = MediaQuery.sizeOf(context).height * 0.42;
    final tabColors = AccentBarTabBarStyle.colors(context);
    const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 72,
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      childAspectRatio: 0.65,
    );
    final fabBackground = theme.colorScheme.primaryContainer;
    final fabForeground = theme.colorScheme.onPrimaryContainer;
    final confirmation = widget.isMultiSelect
        ? FloatingActionButton(
            backgroundColor: fabBackground,
            foregroundColor: fabForeground,
            onPressed: _isLoaded
                ? () {
                    final ids = _filterChooserSelectablePlantIds(
                      widget.allowDuplicateSelection
                          ? List<String>.from(_selectedIdsWithDuplicates)
                          : _selectedIds.toList(),
                    );
                    widget.onMultiPlantSelected?.call(ids);
                  }
                : null,
            child: const Icon(Icons.check),
          )
        : null;
    final selectAll = widget.isMultiSelect
        ? SelectionGridSelectAllButton(
            label: l10n?.selectAll ?? 'Select ALL',
            backgroundColor: fabBackground,
            foregroundColor: fabForeground,
            onPressed: _isLoaded && plants.isNotEmpty
                ? () => _selectAllVisible(plants, levelModuleObjClasses)
                : null,
          )
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.selectPlant ?? 'Select plant'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: themeColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: filterMaxHeight),
              child: ScrollableWithMouseDrag(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: SelectionSearchField(
                          hintText: widget.isMultiSelect
                              ? (l10n?.selectedCountTapToSearch(
                                      widget.allowDuplicateSelection
                                          ? _selectedIdsWithDuplicates.length
                                          : _selectedIds.length,
                                    ) ??
                                    'Selected ${widget.allowDuplicateSelection ? _selectedIdsWithDuplicates.length : _selectedIds.length}, tap to search')
                              : (l10n?.searchPlant ?? 'Search plant'),
                          query: _searchQuery,
                          fillColor: theme.colorScheme.surface,
                          focusedBorderColor: themeColor,
                          onChanged: _setSearchQuery,
                          onClear: () => _setSearchQuery(''),
                        ),
                      ),
                      AccentBarFilterTabRow(
                        key: ValueKey(
                          'plantCategory_${_selectedCategory.name}',
                        ),
                        selectedIndex: PlantCategory.values.indexOf(
                          _selectedCategory,
                        ),
                        onSelected: (index) =>
                            _setCategory(PlantCategory.values[index]),
                        tabs: PlantCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (category == PlantCategory.collection) ...[
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: isSelected
                                      ? tabColors.label
                                      : tabColors.unselectedLabel,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                category.getLabel(context),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      if (_selectedCategory != PlantCategory.collection)
                        AccentBarFilterTabRow(
                          key: ValueKey('${_selectedCategory.name}_tags'),
                          initialScrollOffset:
                              _plantSelectionViewStates[_viewStateKey]
                                  ?.tagScrollOffset ??
                              0,
                          onScrollOffsetChanged: _rememberTagScrollOffset,
                          selectedIndex: safeTagIndex,
                          onSelected: (index) => _setTag(visibleTags[index]),
                          tabs: visibleTags.map((tag) {
                            final iconPath = tag.iconAssetPath;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (iconPath != null) ...[
                                  AssetImageWidget(
                                    assetPath: iconPath,
                                    width: 18,
                                    height: 18,
                                    altCandidates: imageAltCandidates(iconPath),
                                    cacheWidth: 36,
                                    cacheHeight: 36,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(tag.getLabel(context)),
                              ],
                            );
                          }).toList(),
                        )
                      else
                        const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SelectionGridConfirmation(
              itemCount: plants.length,
              gridDelegate: gridDelegate,
              confirmation: confirmation,
              selectAll: selectAll,
              builder: (context, gridPadding) => !_isLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : plants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == PlantCategory.collection
                                ? (l10n?.noFavoritesLongPress ??
                                      'No favorites. Long-press to favorite.')
                                : (l10n?.noPlantFound ?? 'No plant found'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: gridPadding,
                      gridDelegate: gridDelegate,
                      itemCount: plants.length,
                      itemBuilder: (_, i) {
                        final plant = plants[i];
                        final selectionCount = widget.allowDuplicateSelection
                            ? _selectedIdsWithDuplicates
                                  .where((id) => id == plant.id)
                                  .length
                            : (_selectedIds.contains(plant.id) ? 1 : 0);
                        final isSelected = selectionCount > 0;
                        final isFavorite = repo.isFavorite(plant.id);
                        final blockedReason = _plantBlockedReason(
                          plant,
                          levelModuleObjClasses,
                        );
                        final isEnabled = blockedReason == null;
                        final isHat = _isMagicHatPlant(plant);
                        return _PlantGridItem(
                          plant: plant,
                          isSelected: isSelected,
                          isFavorite: isFavorite,
                          isEnabled: isEnabled,
                          onTap: () =>
                              _onPlantTap(context, plant, blockedReason),
                          onSelectedIconTap: widget.isMultiSelect && isSelected
                              ? () => _deselectPlant(plant.id)
                              : null,
                          onSecondaryTap: isHat
                              ? () => _openMagicHatPreview(context, plant.id)
                              : null,
                          onLongPress: isHat
                              ? () => _openMagicHatPreview(context, plant.id)
                              : () => _toggleFavorite(context, plant.id),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantGridItem extends StatelessWidget {
  const _PlantGridItem({
    required this.plant,
    required this.isSelected,
    required this.isFavorite,
    required this.isEnabled,
    required this.onTap,
    this.onSelectedIconTap,
    this.onSecondaryTap,
    required this.onLongPress,
  });

  final PlantInfo plant;
  final bool isSelected;
  final bool isFavorite;
  final bool isEnabled;
  final VoidCallback onTap;
  final VoidCallback? onSelectedIconTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = plant.iconAssetPath;
    final name = ResourceNames.lookup(context, plant.name);
    final hasIcon = iconPath != null && iconPath.isNotEmpty;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : Colors.transparent;
    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    final ink = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isSelected ? 2 : 0),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    key: ValueKey('plantSelectionIcon-${plant.id}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: onSelectedIconTap,
                    child: ClipOval(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: hasIcon
                            ? AssetImageWidget(
                                assetPath: iconPath,
                                altCandidates: imageAltCandidates(iconPath),
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                cacheWidth: 88,
                                cacheHeight: 88,
                                errorWidget: Image.asset(
                                  _kUnknownIconPath,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                _kUnknownIconPath,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  if (isFavorite)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFC107),
                            width: 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: name,
                child: Text(
                  name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tooltip(
                message: plant.id,
                child: Text(
                  plant.id,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: onSecondaryTap == null
          ? ink
          : GestureDetector(onSecondaryTap: onSecondaryTap, child: ink),
    );
  }
}
