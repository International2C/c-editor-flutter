import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

class ModuleSelectionResult {
  const ModuleSelectionResult({
    required this.metadata,
    this.requiredModuleObjClass,
  });

  final ModuleMetadata metadata;
  final String? requiredModuleObjClass;
}

class _ModuleSelectionViewState {
  _ModuleSelectionViewState({
    this.selectedCategory,
    this.searchQuery = '',
    this.scrollOffset = 0,
    this.tagScrollOffset = 0,
  });

  ModuleCategory? selectedCategory;
  String searchQuery;
  double scrollOffset;
  double tagScrollOffset;
}

final Map<String, _ModuleSelectionViewState> _moduleSelectionViewStates = {};

/// Module selection. Ported from Z-Editor-master ModuleSelectionScreen.kt
class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({
    super.key,
    required this.existingObjClasses,
    this.stateBucketId,
  });

  final Set<String> existingObjClasses;
  final String? stateBucketId;

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  String _searchQuery = '';
  ModuleCategory? _selectedCategory;
  late final ScrollController _listScrollController;

  String get _viewStateKey => widget.stateBucketId?.isNotEmpty == true
      ? widget.stateBucketId!
      : 'global';

  @override
  void initState() {
    super.initState();
    final remembered = _moduleSelectionViewStates[_viewStateKey];
    _selectedCategory = remembered?.selectedCategory;
    _searchQuery = remembered?.searchQuery ?? '';
    _listScrollController = ScrollController(
      initialScrollOffset: remembered?.scrollOffset ?? 0,
    )..addListener(_rememberViewState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
  }

  @override
  void dispose() {
    _rememberViewState();
    _listScrollController.removeListener(_rememberViewState);
    _listScrollController.dispose();
    super.dispose();
  }

  void _rememberViewState() {
    if (!_listScrollController.hasClients) return;
    final state = _moduleSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _ModuleSelectionViewState.new,
    );
    state
      ..selectedCategory = _selectedCategory
      ..searchQuery = _searchQuery
      ..scrollOffset = _listScrollController.offset;
  }

  void _rememberTagScrollOffset(double offset) {
    final state = _moduleSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _ModuleSelectionViewState.new,
    );
    state
      ..selectedCategory = _selectedCategory
      ..searchQuery = _searchQuery
      ..tagScrollOffset = offset;
  }

  void _restoreRememberedScrollOffset() {
    if (!mounted || !_listScrollController.hasClients) return;
    final remembered = _moduleSelectionViewStates[_viewStateKey];
    if (remembered == null) return;
    final position = _listScrollController.position;
    final target = remembered.scrollOffset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_listScrollController.offset != target) {
      _listScrollController.jumpTo(target);
    }
  }

  void _selectCategory(ModuleCategory? category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    final state = _moduleSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _ModuleSelectionViewState.new,
    );
    state
      ..selectedCategory = category
      ..searchQuery = _searchQuery
      ..scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScrollController.hasClients) return;
      _listScrollController.jumpTo(0);
    });
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    final state = _moduleSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _ModuleSelectionViewState.new,
    );
    state
      ..selectedCategory = _selectedCategory
      ..searchQuery = query
      ..scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScrollController.hasClients) return;
      _listScrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final allModules = ModuleRegistry.getAllModules();

    final filteredModules = allModules.where((meta) {
      final categoryMatch =
          _selectedCategory == null || meta.category == _selectedCategory;
      final searchMatch = matchesSelectionSearch(_searchQuery, [
        meta.getTitle(context),
        meta.getDescription(context),
        meta.defaultAlias,
        meta.objClass,
        meta.titleKey,
        meta.descriptionKey,
        meta.routeId,
      ]);
      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n?.addNewModule ?? 'Add module'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SelectionSearchField(
                  hintText: l10n?.search ?? 'Search',
                  query: _searchQuery,
                  onChanged: _setSearchQuery,
                  onClear: () => _setSearchQuery(''),
                ),
              ),
              HorizontalTagScroller(
                onAccentBar: true,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                initialScrollOffset:
                    _moduleSelectionViewStates[_viewStateKey]
                        ?.tagScrollOffset ??
                    0,
                onScrollOffsetChanged: _rememberTagScrollOffset,
                children: [
                  AccentBarChoiceChip(
                    key: const ValueKey('moduleCategory_all'),
                    label: l10n?.stageTypeAll ?? 'All',
                    selected: _selectedCategory == null,
                    onSelected: (_) => _selectCategory(null),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  ...ModuleCategory.values.map((cat) {
                    return AccentBarChoiceChip(
                      key: ValueKey('moduleCategory_${cat.name}'),
                      label: _categoryLabel(cat, l10n),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => _selectCategory(cat),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      body: filteredModules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? (l10n?.noResultsFor(_searchQuery) ??
                              'No results for "$_searchQuery"')
                        : (l10n?.noModulesInCategory ??
                              'No modules in this category'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              key: const ValueKey('moduleSelectionList'),
              controller: _listScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredModules.length,
              itemBuilder: (context, index) {
                final meta = filteredModules[index];
                final isAlreadyAdded = widget.existingObjClasses.contains(
                  meta.selectionKey,
                );
                final isEnabled = !isAlreadyAdded || meta.allowMultiple;
                final requiredModuleObjClass =
                    meta.objClass == 'CowboyMinigameProperties' &&
                        !widget.existingObjClasses.contains(
                          'ConveyorSeedBankProperties',
                        )
                    ? 'ConveyorSeedBankProperties'
                    : meta.objClass == 'OakTrainIntroProperties' &&
                            !widget.existingObjClasses.contains(
                              'OakTrainProperties',
                            )
                        ? 'OakTrainProperties'
                        : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ModuleSelectionCard(
                    meta: meta,
                    isAlreadyAdded: isAlreadyAdded,
                    isEnabled: isEnabled,
                    isDependencyMissing: requiredModuleObjClass != null,
                    onTap: () => _handleModuleTap(
                      meta,
                      isEnabled: isEnabled,
                      requiredModuleObjClass: requiredModuleObjClass,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _handleModuleTap(
    ModuleMetadata metadata, {
    required bool isEnabled,
    required String? requiredModuleObjClass,
  }) async {
    if (!isEnabled) return;
    if (requiredModuleObjClass == null) {
      Navigator.pop(context, ModuleSelectionResult(metadata: metadata));
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final requiredName = ModuleRegistry.getMetadata(
      requiredModuleObjClass,
    ).getTitle(context);
    final addRequiredModule = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.moduleDependencyRequiredMessage(requiredName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (addRequiredModule != true || !mounted) return;
    Navigator.pop(
      context,
      ModuleSelectionResult(
        metadata: metadata,
        requiredModuleObjClass: requiredModuleObjClass,
      ),
    );
  }

  String _categoryLabel(ModuleCategory cat, AppLocalizations? l10n) {
    if (l10n == null) {
      switch (cat) {
        case ModuleCategory.base:
          return 'Base';
        case ModuleCategory.mode:
          return 'Game Modes';
        case ModuleCategory.scene:
          return 'Scene';
        case ModuleCategory.gimmick:
          return 'Gimmick';
      }
    }
    switch (cat) {
      case ModuleCategory.base:
        return l10n.moduleCategoryBase;
      case ModuleCategory.mode:
        return l10n.moduleCategoryMode;
      case ModuleCategory.scene:
        return l10n.moduleCategoryScene;
      case ModuleCategory.gimmick:
        return l10n.moduleCategoryGimmick;
    }
  }
}

class _ModuleSelectionCard extends StatelessWidget {
  const _ModuleSelectionCard({
    required this.meta,
    required this.isAlreadyAdded,
    required this.isEnabled,
    required this.isDependencyMissing,
    required this.onTap,
  });

  final ModuleMetadata meta;
  final bool isAlreadyAdded;
  final bool isEnabled;
  final bool isDependencyMissing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVisuallyEnabled = isEnabled && !isDependencyMissing;
    final description = meta.getDescription(context);
    return Opacity(
      opacity: isVisuallyEnabled ? 1 : 0.6,
      child: Card(
        color: isVisuallyEnabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest,
        elevation: isVisuallyEnabled ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        (isVisuallyEnabled
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: meta.assetIconPath != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: AssetImageWidget(
                            assetPath: meta.assetIconPath!,
                            fit: BoxFit.contain,
                            altCandidates: imageAltCandidates(
                              meta.assetIconPath!,
                            ),
                          ),
                        )
                      : Icon(
                          meta.icon,
                          size: 28,
                          color: isVisuallyEnabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.getTitle(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isVisuallyEnabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Tooltip(
                        message: description,
                        child: Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAlreadyAdded)
                  Icon(
                    meta.allowMultiple ? Icons.add_circle : Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
