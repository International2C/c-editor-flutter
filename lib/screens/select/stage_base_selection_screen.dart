import 'package:flutter/material.dart';
import 'package:c_editor/data/models/stage_catalog.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/selection_grid_layout.dart';

class _StageBaseSelectionViewState {
  _StageBaseSelectionViewState({
    required this.selectedType,
    required this.searchQuery,
    required this.scrollOffset,
    required this.tagScrollOffset,
  });

  String selectedType;
  String searchQuery;
  double scrollOffset;
  double tagScrollOffset;
}

final Map<String, _StageBaseSelectionViewState> _stageBaseSelectionViewStates =
    {};

/// Pick the source stage implementation for a level-local custom lawn.
class StageBaseSelectionScreen extends StatefulWidget {
  const StageBaseSelectionScreen({
    super.key,
    required this.onStageBaseSelected,
    required this.onBack,
    this.stateBucketId,
  });

  final void Function(StageBaseOption option) onStageBaseSelected;
  final VoidCallback onBack;
  final String? stateBucketId;

  @override
  State<StageBaseSelectionScreen> createState() =>
      _StageBaseSelectionScreenState();
}

class _StageBaseSelectionScreenState extends State<StageBaseSelectionScreen> {
  static const _typeTabs = ['all', 'main', 'extra', 'seasons', 'special'];

  String _searchQuery = '';
  late String _selectedType;
  late final ScrollController _scrollController;

  String get _viewStateKey => widget.stateBucketId?.isNotEmpty == true
      ? widget.stateBucketId!
      : 'global';

  @override
  void initState() {
    super.initState();
    final remembered = _stageBaseSelectionViewStates[_viewStateKey];
    _selectedType = _typeTabs.contains(remembered?.selectedType)
        ? remembered!.selectedType
        : 'all';
    _searchQuery = remembered?.searchQuery ?? '';
    _scrollController = ScrollController(
      initialScrollOffset: remembered?.scrollOffset ?? 0,
    )..addListener(_rememberScrollOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _scrollController.dispose();
    super.dispose();
  }

  void _setType(String type) {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0);
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _resetRememberedScrollOffset();
  }

  void _rememberViewState({double? scrollOffset, double? tagScrollOffset}) {
    final state = _stageBaseSelectionViewStates.putIfAbsent(
      _viewStateKey,
      () => _StageBaseSelectionViewState(
        selectedType: _selectedType,
        searchQuery: _searchQuery,
        scrollOffset: 0,
        tagScrollOffset: 0,
      ),
    );
    state.selectedType = _selectedType;
    state.searchQuery = _searchQuery;
    if (scrollOffset != null) state.scrollOffset = scrollOffset;
    if (tagScrollOffset != null) state.tagScrollOffset = tagScrollOffset;
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
    final offset =
        _stageBaseSelectionViewStates[_viewStateKey]?.scrollOffset ?? 0;
    final position = _scrollController.position;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_scrollController.offset != target) {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var items = StageCatalogRepository.stageBaseOptions();

    if (_selectedType != 'all') {
      items = items
          .where((option) => _optionTypeName(option) == _selectedType)
          .toList();
    }

    if (normalizeSelectionSearchQuery(_searchQuery).isNotEmpty) {
      items = items.where((option) {
        final nameKey = _stageNameKey(option.alias);
        final name = ResourceNames.lookup(context, nameKey);
        return matchesSelectionSearch(_searchQuery, [
          name,
          nameKey,
          option.alias,
          option.objclass,
          option.backgroundImagePrefix ?? '',
          option.backgroundResourceGroup ?? '',
        ]);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: responsiveSelectionToolbarHeight(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.selectCustomStageBase ?? 'Select base lawn',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SelectionSearchField(
                  hintText: l10n?.searchStage ?? 'Search stage',
                  query: _searchQuery,
                  onChanged: _setSearchQuery,
                  onClear: () => _setSearchQuery(''),
                ),
              ),
              HorizontalTagScroller(
                onAccentBar: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                initialScrollOffset:
                    _stageBaseSelectionViewStates[_viewStateKey]
                        ?.tagScrollOffset ??
                    0,
                onScrollOffsetChanged: _rememberTagScrollOffset,
                children: _typeTabs.map((type) {
                  return AccentBarChoiceChip(
                    label: _typeLabel(type, l10n),
                    selected: _selectedType == type,
                    onSelected: (_) => _setType(type),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: items.isEmpty
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
                    l10n?.noStageBaseFound ?? 'No lawn found',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: responsiveSelectionGridTileExtent(
                  context,
                  baseExtent: 224,
                ),
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final option = items[i];
                return _StageBaseGridItem(
                  option: option,
                  stageName: ResourceNames.lookup(
                    context,
                    _stageNameKey(option.alias),
                  ),
                  onTap: () => widget.onStageBaseSelected(option),
                );
              },
            ),
    );
  }

  String _optionTypeName(StageBaseOption option) {
    final raw = option.type.toString();
    final dot = raw.lastIndexOf('.');
    return dot < 0 ? raw : raw.substring(dot + 1);
  }

  String _typeLabel(String type, AppLocalizations? l10n) {
    switch (type) {
      case 'all':
        return l10n?.stageTypeAll ?? 'All';
      case 'main':
        return l10n?.stageTypeMain ?? 'Main';
      case 'extra':
        return l10n?.stageTypeExtra ?? 'Extra';
      case 'seasons':
        return l10n?.stageTypeSeasons ?? 'Seasons';
      case 'special':
        return l10n?.stageTypeSpecial ?? 'Special';
    }
    return type;
  }

  String _stageNameKey(String alias) => 'stage_$alias';
}

class _StageBaseGridItem extends StatelessWidget {
  const _StageBaseGridItem({
    required this.option,
    required this.stageName,
    required this.onTap,
  });

  final StageBaseOption option;
  final String stageName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = 'assets/images/round_icons/${option.iconName}';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: AssetImageWidget(
                    assetPath: iconPath,
                    altCandidates: imageAltCandidates(iconPath),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stageName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                option.alias,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
