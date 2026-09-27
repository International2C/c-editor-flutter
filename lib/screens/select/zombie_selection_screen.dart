import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/kongfu_rocket_flick_prompt.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/utils/target_zombie_check.dart';
import 'package:c_editor/widgets/selection_grid_confirmation.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart'
    show
        AccentBarFilterTabRow,
        AccentBarTabBarStyle,
        ScrollableWithMouseDrag,
        SelectionSearchField;

/// Placeholder when a zombie has no icon or icon fails to load.
const String _kUnknownIconPath = 'assets/images/others/unknown.webp';
const String _kStayTunedZombieId = 'stay_tuned';

/// ZombieTag â module objClass required to enable those zombies.
const Map<ZombieTag, String> _moduleGatedZombieTags = {};

Set<String> _levelModuleObjClasses(PvzLevelFile levelFile) {
  return levelFile.objects.map((o) => o.objClass).toSet();
}

enum _ZombieBlockedReason {
  stayTunedMoon,
  stayTunedTaleZCorp,
  stayTunedFallback,
  missingModule,
}

class _ZombieSelectionViewState {
  _ZombieSelectionViewState({required this.category, required this.tag})
    : searchQuery = '',
      scrollOffset = 0,
      tagScrollOffset = 0;

  ZombieCategory category;
  ZombieTag tag;
  String searchQuery;
  double scrollOffset;
  double tagScrollOffset;
}

final Map<String, _ZombieSelectionViewState> _zombieSelectionViewStates = {};

/// Zombie selection. Ported from Z-Editor-master ZombieSelectionScreen.kt
class ZombieSelectionScreen extends StatefulWidget {
  const ZombieSelectionScreen({
    super.key,
    this.multiSelect = false,
    required this.onZombieSelected,
    this.onMultiZombieSelected,
    required this.onBack,
    this.editorCubit,
    this.excludeIds = const [],
    this.initialSelectedIds = const [],
    this.allowDuplicateSelection = false,
    this.stateBucketId,
    this.levelFile,
    this.onAddModule,
  });

  final bool multiSelect;
  final void Function(String) onZombieSelected;
  final void Function(List<String>)? onMultiZombieSelected;
  final VoidCallback onBack;

  /// When set (e.g. from the level editor), enables Kongfu rocket â flick module prompt.
  final EditorCubit? editorCubit;

  /// IDs hidden from the grid (e.g. entries in a conflicting list).
  final List<String> excludeIds;

  /// When unique multi-select is used, these IDs start selected (already in the parent list).
  final List<String> initialSelectedIds;

  /// When true, each tap adds another entry (batch append mode).
  final bool allowDuplicateSelection;

  /// Keeps chooser tab and scroll state local to the current editing context.
  final String? stateBucketId;

  /// When set, zombies gated by modules are disabled until the corresponding module is in the level.
  final PvzLevelFile? levelFile;

  /// Called when user taps "Add" in the "module required" dialog.
  final void Function(String objClass)? onAddModule;

  @override
  State<ZombieSelectionScreen> createState() => _ZombieSelectionScreenState();
}

class _ZombieSelectionScreenState extends State<ZombieSelectionScreen> {
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  final List<String> _selectedIdsWithDuplicates = [];
  bool _isLoaded = false;
  late ZombieCategory _selectedCategory;
  late ZombieTag _selectedTag;
  late final ScrollController _scrollController;

  String get _viewStateKey {
    final explicit = widget.stateBucketId;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final filePath = widget.editorCubit?.filePath;
    if (filePath != null && filePath.isNotEmpty) return 'level:$filePath';
    return 'global';
  }

  @override
  void initState() {
    super.initState();
    final rememberedState = _zombieSelectionViewStates[_viewStateKey];
    _selectedCategory = rememberedState?.category ?? ZombieCategory.main;
    _selectedTag = rememberedState?.tag ?? ZombieTag.all;
    _searchQuery = rememberedState?.searchQuery ?? '';
    _normalizeSelectedTag();
    _scrollController = ScrollController(
      initialScrollOffset: rememberedState?.scrollOffset ?? 0,
    )..addListener(_rememberScrollOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
    if (widget.multiSelect &&
        !widget.allowDuplicateSelection &&
        widget.initialSelectedIds.isNotEmpty) {
      _selectedIds.addAll(widget.initialSelectedIds);
    }
    ZombieRepository().init().then((_) {
      if (mounted) {
        setState(() {
          _removeBlockedSelections();
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

  int get _selectedCount => widget.allowDuplicateSelection
      ? _selectedIdsWithDuplicates.length
      : _selectedIds.length;

  List<ZombieTag> _visibleTagsFor(ZombieCategory category) {
    if (category == ZombieCategory.collection) return [];
    if (category == ZombieCategory.main) {
      return const [ZombieTag.all, ...zombieWorldTagOrder];
    }
    if (category == ZombieCategory.other) {
      return const [
        ZombieTag.all,
        ZombieTag.evildave,
        ZombieTag.custom,
        ZombieTag.pvp,
        ZombieTag.expedition,
        ZombieTag.chinese,
        ZombieTag.international,
      ];
    }
    return [
      ZombieTag.all,
      ...ZombieTag.values.where(
        (t) => t != ZombieTag.all && t.category == category,
      ),
    ];
  }

  void _setCategory(ZombieCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      final tags = _visibleTagsFor(category);
      _selectedTag = tags.isNotEmpty ? tags.first : ZombieTag.all;
    });
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0, tagScrollOffset: 0);
  }

  void _setTag(ZombieTag tag) {
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
    if (_selectedCategory == ZombieCategory.collection) {
      _selectedTag = ZombieTag.all;
      return;
    }
    final tags = _visibleTagsFor(_selectedCategory);
    if (!tags.contains(_selectedTag)) {
      _selectedTag = tags.first;
    }
  }

  void _rememberViewState({double? scrollOffset, double? tagScrollOffset}) {
    final state = _zombieSelectionViewStates.putIfAbsent(
      _viewStateKey,
      () => _ZombieSelectionViewState(
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
    final offset = _zombieSelectionViewStates[_viewStateKey]?.scrollOffset ?? 0;
    final position = _scrollController.position;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_scrollController.offset != target) {
      _scrollController.jumpTo(target);
    }
  }

  void _toggleFavorite(BuildContext context, String id) async {
    await ZombieRepository().toggleFavorite(id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final isFav = ZombieRepository().isFavorite(id);
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

  _ZombieBlockedReason? _zombieBlockedReason(ZombieInfo zombie) {
    if (zombie.id == _kStayTunedZombieId) {
      final hasMoon = zombie.tags.contains(ZombieTag.moon);
      final hasTaleZCorp = zombie.tags.contains(ZombieTag.taleZCorp);
      if (hasMoon && _selectedTag == ZombieTag.moon) {
        return _ZombieBlockedReason.stayTunedMoon;
      }
      if (hasTaleZCorp && _selectedTag == ZombieTag.taleZCorp) {
        return _ZombieBlockedReason.stayTunedTaleZCorp;
      }
      return _ZombieBlockedReason.stayTunedFallback;
    }
    // Module gating
    if (widget.levelFile != null) {
      final levelModules = _levelModuleObjClasses(widget.levelFile!);
      if (isTargetZombie(zombie.id) &&
          !levelModules.contains('OakTrainProperties')) {
        return _ZombieBlockedReason.missingModule;
      }
      if (isCamelTouchZombie(zombie.id) &&
          !levelModules.contains('CamelMinigameProperties')) {
        return _ZombieBlockedReason.missingModule;
      }
      for (final entry in _moduleGatedZombieTags.entries) {
        if (zombie.tags.contains(entry.key)) {
          if (!levelModules.contains(entry.value)) {
            return _ZombieBlockedReason.missingModule;
          }
        }
      }
    }
    return null;
  }

  _ZombieBlockedReason? _zombieBlockedReasonForId(String id) {
    final zombie = ZombieRepository().getZombieById(id);
    if (zombie == null) {
      if (id == _kStayTunedZombieId) {
        return _ZombieBlockedReason.stayTunedFallback;
      }
      return null;
    }
    return _zombieBlockedReason(zombie);
  }

  void _removeBlockedSelections() {
    bool isBlocked(String id) => _zombieBlockedReasonForId(id) != null;
    _selectedIds.removeWhere(isBlocked);
    _selectedIdsWithDuplicates.removeWhere(isBlocked);
  }

  List<String> _filterSelectableZombieIds(List<String> ids) {
    return ids.where((id) => _zombieBlockedReasonForId(id) == null).toList();
  }

  void _selectAllVisible(List<ZombieInfo> zombies) {
    final selectableIds = zombies
        .where((zombie) => _zombieBlockedReason(zombie) == null)
        .map((zombie) => zombie.id)
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

  String? _requiredModuleForZombie(ZombieInfo zombie) {
    if (isTargetZombie(zombie.id)) return 'OakTrainProperties';
    if (isCamelTouchZombie(zombie.id)) return 'CamelMinigameProperties';
    for (final entry in _moduleGatedZombieTags.entries) {
      if (zombie.tags.contains(entry.key)) return entry.value;
    }
    return null;
  }

  Future<void> _showZombieBlockedDialog(
    BuildContext context,
    _ZombieBlockedReason reason,
  ) async {
    final l10n = AppLocalizations.of(context);
    final (title, message) = switch (reason) {
      _ZombieBlockedReason.stayTunedMoon => (
        l10n?.stayTunedMoonZombieBlockedTitle ?? 'A Message from Space',
        l10n?.stayTunedMoonZombieBlockedMessage ??
            'The brand-new world, Moon Base, is coming in the '
                'not-too-distant future. Stay tuned!',
      ),
      _ZombieBlockedReason.stayTunedTaleZCorp => (
        l10n?.stayTunedTaleZCorpZombieBlockedTitle ?? 'To be continued',
        l10n?.stayTunedTaleZCorpZombieBlockedMessage ??
            'ZCorp Chapter Two is coming soon. Stay tuned!',
      ),
      _ZombieBlockedReason.stayTunedFallback => (
        l10n?.stayTunedZombieBlockedTitle ?? 'To be continued',
        l10n?.stayTunedZombieBlockedMessage ??
            'This content is not officially available yet. Stay tuned for '
                'future updates!',
      ),
      _ZombieBlockedReason.missingModule => (
        l10n?.warning ?? 'Warning',
        '',
      ),
    };
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onZombieTap(
    BuildContext context,
    ZombieInfo zombie,
    _ZombieBlockedReason? blockedReason,
  ) async {
    if (blockedReason == _ZombieBlockedReason.missingModule) {
      final requiredObjClass = _requiredModuleForZombie(zombie);
      if (requiredObjClass == null || widget.onAddModule == null) return;
      final l10n = AppLocalizations.of(context)!;
      final meta = ModuleRegistry.getMetadata(requiredObjClass);
      final moduleName = meta.getTitle(context);
      final message = l10n.zombieModuleRequiredMessage(moduleName);
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
        setState(() {});
      }
      return;
    }
    if (blockedReason != null) {
      await _showZombieBlockedDialog(context, blockedReason);
      return;
    }
    if (widget.multiSelect) {
      setState(() {
        if (widget.allowDuplicateSelection) {
          _selectedIdsWithDuplicates.add(zombie.id);
        } else if (_selectedIds.contains(zombie.id)) {
          _selectedIds.remove(zombie.id);
        } else {
          _selectedIds.add(zombie.id);
        }
      });
    } else {
      await maybeShowKongfuRocketFlickPrompt(context, [
        zombie.id,
      ], editorCubit: widget.editorCubit);
      if (!context.mounted) return;
      widget.onZombieSelected(zombie.id);
    }
  }

  List<ZombieInfo> _categoryFilteredZombies(ZombieRepository repo) {
    if (!repo.isLoaded) return [];
    if (_selectedCategory == ZombieCategory.collection) {
      return repo.allZombies
          .where((z) => repo.favoriteIds.contains(z.id))
          .toList();
    }
    if (_selectedTag != ZombieTag.all) {
      return repo.allZombies
          .where((z) => z.tags.contains(_selectedTag))
          .toList();
    }
    return repo.allZombies;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final repositoryZombies = repo.search(
      _searchQuery,
      _selectedCategory == ZombieCategory.collection ? null : _selectedTag,
      _selectedCategory,
    );
    final allZombies = _searchQuery.trim().isEmpty
        ? repositoryZombies
        : mergeUniqueSelectionResults(
            repositoryZombies,
            _categoryFilteredZombies(repo).where(
              (zombie) => matchesSelectionSearch(_searchQuery, [
                ResourceNames.lookup(context, zombie.name),
              ]),
            ),
            (zombie) => zombie.id,
          );
    final excludeSet = widget.excludeIds.toSet();
    final zombies = excludeSet.isEmpty
        ? allZombies
        : allZombies.where((z) => !excludeSet.contains(z.id)).toList();
    _normalizeSelectedTag();
    final visibleTags = _visibleTagsFor(_selectedCategory);
    final tagIndex = visibleTags.indexOf(_selectedTag);
    final safeTagIndex = tagIndex < 0 ? 0 : tagIndex;
    final themeColor = theme.brightness == Brightness.dark
        ? pvzPurpleDark
        : pvzPurpleLight;
    final filterMaxHeight = MediaQuery.sizeOf(context).height * 0.42;
    final tabColors = AccentBarTabBarStyle.colors(context);
    const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 72,
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      childAspectRatio: 0.65,
    );
    final confirmation = widget.multiSelect
        ? FloatingActionButton(
            backgroundColor: themeColor,
            foregroundColor: theme.colorScheme.surface,
            onPressed: _isLoaded
                ? () async {
                    final ids = _filterSelectableZombieIds(
                      widget.allowDuplicateSelection
                          ? List<String>.from(_selectedIdsWithDuplicates)
                          : _selectedIds.toList(),
                    );
                    await maybeShowKongfuRocketFlickPrompt(
                      context,
                      ids,
                      editorCubit: widget.editorCubit,
                    );
                    if (!context.mounted) return;
                    widget.onMultiZombieSelected?.call(ids);
                  }
                : null,
            child: const Icon(Icons.check),
          )
        : null;
    final selectAll = widget.multiSelect
        ? SelectionGridSelectAllButton(
            label: l10n?.selectAll ?? 'Select ALL',
            backgroundColor: themeColor,
            foregroundColor: theme.colorScheme.surface,
            onPressed: _isLoaded && zombies.isNotEmpty
                ? () => _selectAllVisible(zombies)
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
        title: Text(l10n?.selectZombie ?? 'Select zombie'),
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
                          hintText: widget.multiSelect
                              ? (l10n?.selectedCountTapToSearch(
                                      _selectedCount,
                                    ) ??
                                    'Selected $_selectedCount, tap to search')
                              : (l10n?.searchZombie ?? 'Search zombie'),
                          query: _searchQuery,
                          fillColor: theme.colorScheme.surface,
                          focusedBorderColor: themeColor,
                          onChanged: _setSearchQuery,
                          onClear: () => _setSearchQuery(''),
                        ),
                      ),
                      AccentBarFilterTabRow(
                        key: ValueKey(
                          'zombieCategory_${_selectedCategory.name}',
                        ),
                        selectedIndex: ZombieCategory.values.indexOf(
                          _selectedCategory,
                        ),
                        onSelected: (index) =>
                            _setCategory(ZombieCategory.values[index]),
                        tabs: ZombieCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (category == ZombieCategory.collection) ...[
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
                      if (_selectedCategory != ZombieCategory.collection)
                        AccentBarFilterTabRow(
                          key: ValueKey('${_selectedCategory.name}_tags'),
                          initialScrollOffset:
                              _zombieSelectionViewStates[_viewStateKey]
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
              itemCount: zombies.length,
              gridDelegate: gridDelegate,
              confirmation: confirmation,
              selectAll: selectAll,
              builder: (context, gridPadding) => !_isLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : zombies.isEmpty
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
                            _selectedCategory == ZombieCategory.collection
                                ? (l10n?.noFavoritesLongPress ??
                                      'No favorites. Long-press to favorite.')
                                : (l10n?.noZombieFound ?? 'No zombie found'),
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
                      itemCount: zombies.length,
                      itemBuilder: (_, i) {
                        final zombie = zombies[i];
                        final selectionCount = widget.allowDuplicateSelection
                            ? _selectedIdsWithDuplicates
                                  .where((id) => id == zombie.id)
                                  .length
                            : (_selectedIds.contains(zombie.id) ? 1 : 0);
                        final isSelected = selectionCount > 0;
                        final isFavorite = repo.isFavorite(zombie.id);
                        final blockedReason = _zombieBlockedReason(zombie);
                        final isEnabled = blockedReason == null;
                        return _ZombieGridItem(
                          zombie: zombie,
                          isSelected: isSelected,
                          isFavorite: isFavorite,
                          isEnabled: isEnabled,
                          selectionColor: widget.multiSelect
                              ? themeColor
                              : null,
                          onTap: () => _onZombieTap(
                            context,
                            zombie,
                            blockedReason,
                          ),
                          onLongPress: () =>
                              _toggleFavorite(context, zombie.id),
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

class _ZombieGridItem extends StatelessWidget {
  const _ZombieGridItem({
    required this.zombie,
    required this.isSelected,
    required this.isFavorite,
    required this.isEnabled,
    required this.onTap,
    required this.onLongPress,
    this.selectionColor,
  });

  final ZombieInfo zombie;
  final bool isSelected;
  final bool isFavorite;
  final bool isEnabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = zombie.iconAssetPath;
    final name = ResourceNames.lookup(context, zombie.name);
    final hasIcon = iconPath != null && iconPath.isNotEmpty;

    final accent = selectionColor ?? theme.colorScheme.primary;
    final borderColor = isSelected ? accent : Colors.transparent;
    final bgColor = isSelected
        ? accent.withValues(alpha: 0.08)
        : Colors.transparent;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Material(
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
                    ClipOval(
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
                  message: zombie.id,
                  child: Text(
                    zombie.id,
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
      ),
    );
  }
}
