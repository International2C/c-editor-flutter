import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

class _EventSelectionViewState {
  _EventSelectionViewState({
    this.selectedCategory,
    this.searchQuery = '',
    this.scrollOffset = 0,
    this.tagScrollOffset = 0,
  });

  EventCategory? selectedCategory;
  String searchQuery;
  double scrollOffset;
  double tagScrollOffset;
}

final Map<String, _EventSelectionViewState> _eventSelectionViewStates = {};

/// Event selection for wave timeline. Ported from Z-Editor-master EventSelectionScreen.kt
class EventSelectionScreen extends StatefulWidget {
  const EventSelectionScreen({
    super.key,
    required this.waveIndex,
    required this.levelFile,
    required this.onEventSelected,
    required this.onBack,
  });

  final int waveIndex;
  final PvzLevelFile levelFile;
  final void Function(EventMetadata meta) onEventSelected;
  final VoidCallback onBack;

  @override
  State<EventSelectionScreen> createState() => _EventSelectionScreenState();

  /// Resolves event metadata to a localized display title. Shared for wave timeline and event chips.
  static String resolveEventTitle(
    BuildContext context,
    EventMetadata? meta,
    AppLocalizations? l10n,
  ) {
    if (meta == null) return '';
    return _resolveEventKeyStatic(meta.titleKey, 'eventTitle_', l10n);
  }

  static String resolveEventTitleByObjClass(
    BuildContext context,
    String objClass,
    AppLocalizations? l10n,
  ) {
    final meta = EventRegistry.getByObjClass(objClass);
    if (meta != null) return resolveEventTitle(context, meta, l10n);
    return objClass;
  }

  static String resolveEventDescription(
    BuildContext context,
    EventMetadata meta,
    AppLocalizations? l10n,
  ) {
    return _resolveEventKeyStatic(meta.descriptionKey, 'eventDesc_', l10n);
  }

  static String _resolveEventKeyStatic(
    String key,
    String prefix,
    AppLocalizations? l10n,
  ) {
    if (l10n == null) return key.replaceAll(prefix, '');
    try {
      final name = key.replaceAll(prefix, '');
      final isTitle = prefix == 'eventTitle_';
      switch (name) {
        case 'SpawnZombiesFromGroundSpawnerProps':
          return isTitle
              ? l10n.eventTitle_SpawnZombiesFromGroundSpawnerProps
              : l10n.eventDesc_SpawnZombiesFromGroundSpawnerProps;
        case 'SpawnZombiesJitteredWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SpawnZombiesJitteredWaveActionProps
              : l10n.eventDesc_SpawnZombiesJitteredWaveActionProps;
        case 'FrostWindWaveActionProps':
          return isTitle
              ? l10n.eventTitle_FrostWindWaveActionProps
              : l10n.eventDesc_FrostWindWaveActionProps;
        case 'BeachStageEventZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_BeachStageEventZombieSpawnerProps
              : l10n.eventDesc_BeachStageEventZombieSpawnerProps;
        case 'TidalChangeWaveActionProps':
          return isTitle
              ? l10n.eventTitle_TidalChangeWaveActionProps
              : l10n.eventDesc_TidalChangeWaveActionProps;
        case 'TideWaveWaveActionProps':
          return isTitle
              ? l10n.eventTitle_TideWaveWaveActionProps
              : l10n.eventDesc_TideWaveWaveActionProps;
        case 'SpawnZombiesFishWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SpawnZombiesFishWaveActionProps
              : l10n.eventDesc_SpawnZombiesFishWaveActionProps;
        case 'ModifyConveyorWaveActionProps':
          return isTitle
              ? l10n.eventTitle_ModifyConveyorWaveActionProps
              : l10n.eventDesc_ModifyConveyorWaveActionProps;
        case 'DinoWaveActionProps':
          return isTitle
              ? l10n.eventTitle_DinoWaveActionProps
              : l10n.eventDesc_DinoWaveActionProps;
        case 'DinoTreadActionProps':
          return isTitle
              ? l10n.eventTitle_DinoTreadActionProps
              : l10n.eventDesc_DinoTreadActionProps;
        case 'DinoRunActionProps':
          return isTitle
              ? l10n.eventTitle_DinoRunActionProps
              : l10n.eventDesc_DinoRunActionProps;
        case 'SpawnModernPortalsWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SpawnModernPortalsWaveActionProps
              : l10n.eventDesc_SpawnModernPortalsWaveActionProps;
        case 'SpawnRocketLandingWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SpawnRocketLandingWaveActionProps
              : l10n.eventDesc_SpawnRocketLandingWaveActionProps;
        case 'GravityGeneratorWaveActionProps':
          return isTitle
              ? l10n.eventTitle_GravityGeneratorWaveActionProps
              : l10n.eventDesc_GravityGeneratorWaveActionProps;
        case 'StormZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_StormZombieSpawnerProps
              : l10n.eventDesc_StormZombieSpawnerProps;
        case 'RaidingPartyZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_RaidingPartyZombieSpawnerProps
              : l10n.eventDesc_RaidingPartyZombieSpawnerProps;
        case 'ZombiePotionActionProps':
          return isTitle
              ? l10n.eventTitle_ZombiePotionActionProps
              : l10n.eventDesc_ZombiePotionActionProps;
        case 'ZombieAtlantisShellActionProps':
          return isTitle
              ? l10n.eventTitle_ZombieAtlantisShellActionProps
              : l10n.eventDesc_ZombieAtlantisShellActionProps;
        case 'SpawnEagleFlagsWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SpawnEagleFlagsWaveActionProps
              : l10n.eventDesc_SpawnEagleFlagsWaveActionProps;
        case 'PumpkinHouseActionProps':
          return isTitle
              ? l10n.eventTitle_PumpkinHouseActionProps
              : l10n.eventDesc_PumpkinHouseActionProps;
        case 'WaveActionZombieTentProps':
          return isTitle
              ? l10n.eventTitle_WaveActionZombieTentProps
              : l10n.eventDesc_WaveActionZombieTentProps;
        case 'SpawnGravestonesWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SpawnGravestonesWaveActionProps
              : l10n.eventDesc_SpawnGravestonesWaveActionProps;
        case 'SpawnZombiesFromGridItemSpawnerProps':
          return isTitle
              ? l10n.eventTitle_SpawnZombiesFromGridItemSpawnerProps
              : l10n.eventDesc_SpawnZombiesFromGridItemSpawnerProps;
        case 'FairyTaleFogWaveActionProps':
          return isTitle
              ? l10n.eventTitle_FairyTaleFogWaveActionProps
              : l10n.eventDesc_FairyTaleFogWaveActionProps;
        case 'FairyTaleWindWaveActionProps':
          return isTitle
              ? l10n.eventTitle_FairyTaleWindWaveActionProps
              : l10n.eventDesc_FairyTaleWindWaveActionProps;
        case 'SpiderRainZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_SpiderRainZombieSpawnerProps
              : l10n.eventDesc_SpiderRainZombieSpawnerProps;
        case 'ParachuteRainZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_ParachuteRainZombieSpawnerProps
              : l10n.eventDesc_ParachuteRainZombieSpawnerProps;
        case 'BassRainZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_BassRainZombieSpawnerProps
              : l10n.eventDesc_BassRainZombieSpawnerProps;
        case 'BlackHoleWaveActionProps':
          return isTitle
              ? l10n.eventTitle_BlackHoleWaveActionProps
              : l10n.eventDesc_BlackHoleWaveActionProps;
        case 'BarrelWaveActionProps':
          return isTitle
              ? l10n.eventTitle_BarrelWaveActionProps
              : l10n.eventDesc_BarrelWaveActionProps;
        case 'SchoolBusWaveActionProps':
          return isTitle
              ? l10n.eventTitle_SchoolBusWaveActionProps
              : l10n.eventDesc_SchoolBusWaveActionProps;
        case 'HamsterZombieSpawnerProps':
          return isTitle
              ? l10n.eventTitle_HamsterZombieSpawnerProps
              : l10n.eventDesc_HamsterZombieSpawnerProps;
        case 'BungeeWaveActionProps':
          return isTitle
              ? l10n.eventTitle_BungeeWaveActionProps
              : l10n.eventDesc_BungeeWaveActionProps;
        case 'ThunderWaveActionProps':
          return isTitle
              ? l10n.eventTitle_ThunderWaveActionProps
              : l10n.eventDesc_ThunderWaveActionProps;
        case 'MagicMirrorWaveActionProps':
        case 'WaveActionMagicMirrorTeleportationArrayProps':
          return isTitle
              ? l10n.eventTitle_MagicMirrorWaveActionProps
              : l10n.eventDesc_MagicMirrorWaveActionProps;
        default:
          return name;
      }
    } catch (_) {
      return key.replaceAll(prefix, '');
    }
  }
}

class _EventSelectionScreenState extends State<EventSelectionScreen> {
  String _searchQuery = '';
  EventCategory? _selectedCategory;
  late final ScrollController _listScrollController;

  String get _viewStateKey =>
      'level:${identityHashCode(widget.levelFile)}:event-selection';

  @override
  void initState() {
    super.initState();
    final remembered = _eventSelectionViewStates[_viewStateKey];
    _searchQuery = remembered?.searchQuery ?? '';
    _selectedCategory = remembered?.selectedCategory;
    _listScrollController = ScrollController(
      initialScrollOffset: remembered?.scrollOffset ?? 0,
    )..addListener(_rememberScrollOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _listScrollController.dispose();
    super.dispose();
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _resetRememberedScrollOffset();
  }

  void _setCategory(EventCategory? category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _resetRememberedScrollOffset();
  }

  void _rememberViewState({double? scrollOffset, double? tagScrollOffset}) {
    final state = _eventSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _EventSelectionViewState.new,
    );
    state
      ..selectedCategory = _selectedCategory
      ..searchQuery = _searchQuery;
    if (scrollOffset != null) state.scrollOffset = scrollOffset;
    if (tagScrollOffset != null) state.tagScrollOffset = tagScrollOffset;
  }

  void _rememberScrollOffset() {
    if (!_listScrollController.hasClients) return;
    _rememberViewState(scrollOffset: _listScrollController.offset);
  }

  void _resetRememberedScrollOffset() {
    _rememberViewState(scrollOffset: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScrollController.hasClients) return;
      _listScrollController.jumpTo(0);
    });
  }

  void _restoreRememberedScrollOffset() {
    if (!mounted || !_listScrollController.hasClients) return;
    final offset = _eventSelectionViewStates[_viewStateKey]?.scrollOffset ?? 0;
    final position = _listScrollController.position;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_listScrollController.offset != target) {
      _listScrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final levelDef = LevelParser.parseLevel(widget.levelFile).levelDef;
    final allEvents = EventRegistry.getAll()
        .where(
          (meta) => LevelParser.isWaveEventAvailable(
            meta.defaultObjClass,
            levelDef,
            widget.levelFile,
          ),
        )
        .toList();

    final filteredEvents = allEvents.where((meta) {
      final categoryMatch =
          _selectedCategory == null || meta.category == _selectedCategory;
      final title = EventSelectionScreen.resolveEventTitle(context, meta, l10n);
      final description = EventSelectionScreen.resolveEventDescription(
        context,
        meta,
        l10n,
      );
      final categoryLabel = _categoryLabel(meta.category, l10n);
      final searchMatch = matchesSelectionSearch(_searchQuery, [
        title,
        description,
        meta.defaultAlias,
        meta.defaultObjClass,
        meta.titleKey,
        meta.descriptionKey,
        categoryLabel,
      ]);
      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.addEventForWave(widget.waveIndex) ??
              'Add event for wave ${widget.waveIndex}',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
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
                    _eventSelectionViewStates[_viewStateKey]?.tagScrollOffset ??
                    0,
                onScrollOffsetChanged: (offset) {
                  _rememberViewState(tagScrollOffset: offset);
                },
                children: [
                  AccentBarChoiceChip(
                    label: l10n?.stageTypeAll ?? 'All',
                    selected: _selectedCategory == null,
                    onSelected: (_) => _setCategory(null),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  ...EventCategory.values.map((cat) {
                    return AccentBarChoiceChip(
                      label: _categoryLabel(cat, l10n),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => _setCategory(cat),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      body: filteredEvents.isEmpty
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
                        : (l10n?.noEventsInCategory ??
                              'No events in this category'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _listScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final meta = filteredEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EventSelectionCard(
                    meta: meta,
                    onTap: () => widget.onEventSelected(meta),
                  ),
                );
              },
            ),
    );
  }

  String _categoryLabel(EventCategory cat, AppLocalizations? l10n) {
    if (l10n == null) {
      switch (cat) {
        case EventCategory.zombieSpawn:
          return 'Zombie spawn';
        case EventCategory.gridItemSpawn:
          return 'Grid item spawn';
        case EventCategory.environmental:
          return 'Environmental';
        case EventCategory.other:
          return 'Other';
      }
    }
    switch (cat) {
      case EventCategory.zombieSpawn:
        return l10n.eventCategoryZombieSpawn;
      case EventCategory.gridItemSpawn:
        return l10n.eventCategoryGridItemSpawn;
      case EventCategory.environmental:
        return l10n.eventCategoryEnvironmental;
      case EventCategory.other:
        return l10n.eventCategoryOther;
    }
  }
}

class _EventSelectionCard extends StatelessWidget {
  const _EventSelectionCard({required this.meta, required this.onTap});

  final EventMetadata meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? meta.darkColor : meta.color;
    final description = EventSelectionScreen.resolveEventDescription(
      context,
      meta,
      l10n,
    );

    return Card(
      elevation: 2,
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
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: meta.assetIconPath == null
                    ? Icon(meta.icon, size: 28, color: accentColor)
                    : Padding(
                        padding: const EdgeInsets.all(4),
                        child: AssetImageWidget(
                          assetPath: meta.assetIconPath!,
                          fit: BoxFit.contain,
                          altCandidates: imageAltCandidates(
                            meta.assetIconPath!,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EventSelectionScreen.resolveEventTitle(
                        context,
                        meta,
                        l10n,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }
}
