import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show compareNatural;
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/screens/select/narrative_preview_screen.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/selection_grid_layout.dart';

class NarrativeSearchResults {
  const NarrativeSearchResults({
    required this.byTitle,
    required this.byContent,
    required this.bySpeaker,
  });

  final List<NarrativeEntry> byTitle;
  final List<NarrativeEntry> byContent;
  final List<NarrativeEntry> bySpeaker;

  bool get isEmpty => byTitle.isEmpty && byContent.isEmpty && bySpeaker.isEmpty;
}

NarrativeSearchResults searchNarratives(
  NarrativeCatalog catalog,
  NarrativeCategory category,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  var entries = catalog.forCategory(category);
  if (normalized.isEmpty) {
    return NarrativeSearchResults(
      byTitle: entries,
      byContent: const [],
      bySpeaker: const [],
    );
  }
  entries = _orderSearchProgression(catalog, entries);

  bool contains(Iterable<String> values) =>
      values.any((value) => value.toLowerCase().contains(normalized));

  return NarrativeSearchResults(
    byTitle: entries
        .where((entry) => contains([entry.title, entry.id, entry.groupId]))
        .toList(growable: false),
    byContent: entries
        .where((entry) => contains(entry.dialogueText))
        .toList(growable: false),
    bySpeaker: entries
        .where(
          (entry) => contains([...entry.speakerNames, ...entry.characters]),
        )
        .toList(growable: false),
  );
}

List<NarrativeEntry> _orderSearchProgression(
  NarrativeCatalog catalog,
  List<NarrativeEntry> entries,
) {
  // Sort numbered title families in their existing slots so section grouping,
  // tutorial placement and same-day variant order stay consistent.
  final numberedGroups =
      <(NarrativeSectionId, String), List<({int index, String numbers})>>{};
  final numberPattern = RegExp(r'\d+');
  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index];
    final title = entry.title.split(RegExp(r'[（(:：]')).first;
    final numbers = numberPattern.allMatches(title).toList();
    if (numbers.isEmpty) continue;
    final key = (
      catalog.sectionForEntry(entry).id,
      title.substring(0, numbers.first.start),
    );
    numberedGroups.putIfAbsent(key, () => []).add((
      index: index,
      numbers: numbers.map((match) => match.group(0)!).join('.'),
    ));
  }

  final ordered = List<NarrativeEntry>.of(entries);
  for (final group in numberedGroups.values) {
    final positions = group.map((item) => item.index).toList();
    group.sort((a, b) {
      final numericOrder = compareNatural(a.numbers, b.numbers);
      return numericOrder != 0 ? numericOrder : a.index.compareTo(b.index);
    });
    for (var index = 0; index < group.length; index++) {
      ordered[positions[index]] = entries[group[index].index];
    }
  }
  return ordered;
}

class NarrativeSelectionScreen extends StatefulWidget {
  const NarrativeSelectionScreen({
    super.key,
    required this.currentValue,
    required this.onSelected,
    required this.catalog,
    this.stateBucketId,
  });

  final Object? currentValue;
  final ValueChanged<Object?> onSelected;
  final NarrativeCatalog catalog;

  /// Keeps browsing state local to the level being edited. Intro and outro
  /// intentionally share this bucket so returning to the picker resumes the
  /// same section and scroll position.
  final String? stateBucketId;

  @override
  State<NarrativeSelectionScreen> createState() =>
      _NarrativeSelectionScreenState();
}

class _NarrativeSelectionScreenState extends State<NarrativeSelectionScreen> {
  NarrativeCategory _category = NarrativeCategory.all;
  String _query = '';
  NarrativeSectionId? _selectedSectionId;
  late final SelectionViewMemory _memory;
  late final ScrollController _scrollController;
  NarrativeSearchResults? _cachedSearchResults;
  String? _cachedSearchKey;
  final Map<String, bool> _expandedSearchGroups = {
    'title': true,
    'content': true,
    'speaker': true,
  };

  bool get _searching => _query.trim().isNotEmpty;

  NarrativeSection? get _selectedSection {
    final id = _selectedSectionId;
    if (id == null) return null;
    for (final section in widget.catalog.sectionsForCategory(
      NarrativeCategory.all,
    )) {
      if (section.id == id) return section;
    }
    return null;
  }

  String get _memoryKey {
    final bucket =
        widget.stateBucketId ?? 'catalog:${identityHashCode(widget.catalog)}';
    return '$bucket:narrative-selection';
  }

  String get _viewKey {
    if (_searching) return 'search:${_category.name}';
    final section = _selectedSection;
    if (section != null) return 'section:${section.id.name}';
    if (_category == NarrativeCategory.all) return 'list:all';
    if (_category == NarrativeCategory.systemTutorials) {
      return 'section:${NarrativeSectionId.systemTutorials.name}';
    }
    return 'grid:${_category.name}';
  }

  @override
  void initState() {
    super.initState();
    _memory = SelectionViewMemoryStore.forKey(_memoryKey);
    _query = _memory.query;
    final categoryName = _memory.filters['category'] as String?;
    _category = NarrativeCategory.values.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => NarrativeCategory.all,
    );
    final sectionName = _memory.filters['section'] as String?;
    if (sectionName != null) {
      for (final id in NarrativeSectionId.values) {
        if (id.name == sectionName) {
          _selectedSectionId = id;
          break;
        }
      }
    }
    if (_selectedSection != null &&
        _category != NarrativeCategory.all &&
        _selectedSection!.category != _category) {
      _selectedSectionId = null;
    }
    if (_category == NarrativeCategory.all) {
      _selectedSectionId = null;
    }
    for (final name in _expandedSearchGroups.keys) {
      final remembered = _memory.filters['searchExpanded:$name'];
      if (remembered is bool) _expandedSearchGroups[name] = remembered;
    }
    _scrollController = ScrollController(
      initialScrollOffset: _memory.scrollOffsets[_viewKey] ?? 0,
    )..addListener(_rememberScrollOffset);
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _scrollController.dispose();
    super.dispose();
  }

  void _rememberScrollOffset() {
    if (_scrollController.hasClients) {
      _memory.scrollOffsets[_viewKey] = _scrollController.offset;
    }
  }

  void _restoreScrollOffset({bool reset = false}) {
    if (reset) _memory.scrollOffsets[_viewKey] = 0;
    final target = _memory.scrollOffsets[_viewKey] ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      _scrollController.jumpTo(
        target
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble(),
      );
    });
  }

  void _changeView(VoidCallback change, {bool resetScroll = false}) {
    _rememberScrollOffset();
    setState(change);
    _memory.query = _query;
    _memory.filters['category'] = _category.name;
    _memory.filters['section'] = _selectedSectionId?.name;
    _restoreScrollOffset(reset: resetScroll);
  }

  void _setCategory(NarrativeCategory category) {
    if (_category == category && _selectedSectionId == null) return;
    _changeView(() {
      _category = category;
      _selectedSectionId = null;
      _cachedSearchResults = null;
    });
  }

  void _setQuery(String value) {
    if (_query == value) return;
    _changeView(() {
      _query = value;
      _cachedSearchResults = null;
    }, resetScroll: value.trim().isNotEmpty);
  }

  void _openSection(NarrativeSection section) {
    _changeView(() => _selectedSectionId = section.id);
  }

  void _closeSection() {
    if (_selectedSectionId == null) return;
    _changeView(() => _selectedSectionId = null);
  }

  NarrativeSearchResults get _searchResults {
    final cacheKey = '${_category.name}\u0000$_query';
    if (_cachedSearchKey != cacheKey || _cachedSearchResults == null) {
      _cachedSearchKey = cacheKey;
      _cachedSearchResults = searchNarratives(
        widget.catalog,
        _category,
        _query,
      );
    }
    return _cachedSearchResults!;
  }

  void _toggleSearchGroup(String name) {
    setState(() {
      final expanded = !(_expandedSearchGroups[name] ?? true);
      _expandedSearchGroups[name] = expanded;
      _memory.filters['searchExpanded:$name'] = expanded;
    });
  }

  void _handleBack() {
    if (!_searching && _selectedSectionId != null) {
      _closeSection();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = widget.catalog;
    final strings = catalog.strings;
    final selectedSection = _selectedSection;
    final canCloseSection = !_searching && selectedSection != null;

    return PopScope(
      canPop: !canCloseSection,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && canCloseSection) _closeSection();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _handleBack),
          title: Text(
            canCloseSection
                ? strings.sectionLabel(selectedSection)
                : strings.selectTitle,
          ),
        ),
        body: Column(
          children: [
            Material(
              color:
                  Theme.of(context).appBarTheme.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SelectionSearchField(
                      hintText: strings.searchHint,
                      query: _query,
                      onChanged: _setQuery,
                      onClear: () => _setQuery(''),
                    ),
                  ),
                  HorizontalTagScroller(
                    onAccentBar: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    initialScrollOffset: _memory.tagScrollOffset,
                    onScrollOffsetChanged: (offset) {
                      _memory.tagScrollOffset = offset;
                    },
                    children: [
                      for (final category in NarrativeCategory.values)
                        AccentBarChoiceChip(
                          label: strings.categoryLabel(category),
                          selected: _category == category,
                          onSelected: (_) => _setCategory(category),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent(catalog, selectedSection)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    NarrativeCatalog catalog,
    NarrativeSection? selectedSection,
  ) {
    if (_searching) {
      return _NarrativeSearchResultList(
        controller: _scrollController,
        catalog: catalog,
        results: _searchResults,
        expandedGroups: _expandedSearchGroups,
        onToggleGroup: _toggleSearchGroup,
        currentValue: widget.currentValue,
        onSelected: widget.onSelected,
      );
    }

    if (_category == NarrativeCategory.all) {
      return _NarrativeFlatList(
        key: const ValueKey('narrative-all-dialogue-list'),
        controller: _scrollController,
        catalog: catalog,
        entries: catalog.forCategory(NarrativeCategory.all),
        includeNoDialogue: true,
        currentValue: widget.currentValue,
        onSelected: widget.onSelected,
      );
    }

    if (selectedSection != null) {
      return _NarrativeFlatList(
        key: ValueKey('narrative-section-list-${selectedSection.id.name}'),
        controller: _scrollController,
        catalog: catalog,
        entries: catalog.entriesForSection(selectedSection.id),
        iconAsset: selectedSection.iconAsset,
        currentValue: widget.currentValue,
        onSelected: widget.onSelected,
      );
    }

    if (_category == NarrativeCategory.systemTutorials) {
      final section = catalog.sectionsForCategory(_category).single;
      return _NarrativeFlatList(
        key: const ValueKey('narrative-system-tutorial-list'),
        controller: _scrollController,
        catalog: catalog,
        entries: catalog.entriesForSection(section.id),
        iconAsset: section.iconAsset,
        includeNoDialogue: true,
        currentValue: widget.currentValue,
        onSelected: widget.onSelected,
      );
    }

    return _NarrativeSectionGrid(
      key: ValueKey('narrative-section-grid-${_category.name}'),
      controller: _scrollController,
      catalog: catalog,
      sections: catalog.sectionsForCategory(_category),
      noDialogueSelected: widget.currentValue == null,
      onNoDialogueSelected: () => widget.onSelected(null),
      onSectionSelected: _openSection,
    );
  }
}

class _NarrativeFlatList extends StatelessWidget {
  const _NarrativeFlatList({
    super.key,
    required this.controller,
    required this.catalog,
    required this.entries,
    required this.currentValue,
    required this.onSelected,
    this.iconAsset,
    this.includeNoDialogue = false,
  });

  final ScrollController controller;
  final NarrativeCatalog catalog;
  final List<NarrativeEntry> entries;
  final String? iconAsset;
  final Object? currentValue;
  final ValueChanged<Object?> onSelected;
  final bool includeNoDialogue;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: entries.length + (includeNoDialogue ? 1 : 0),
      itemBuilder: (context, index) {
        if (includeNoDialogue && index == 0) {
          return _NoNarrativeCard(
            label: catalog.strings.noDialogue,
            selected: currentValue == null,
            onTap: () => onSelected(null),
          );
        }
        final entry = entries[index - (includeNoDialogue ? 1 : 0)];
        return _NarrativeCard(
          key: ValueKey('narrative-entry-${entry.groupId}'),
          catalog: catalog,
          entry: entry,
          iconAsset: iconAsset ?? catalog.displayIcon(entry),
          selected: currentValue?.toString() == entry.valueKey,
          onSelected: onSelected,
        );
      },
    );
  }
}

class _NarrativeSearchResultList extends StatelessWidget {
  const _NarrativeSearchResultList({
    required this.controller,
    required this.catalog,
    required this.results,
    required this.expandedGroups,
    required this.onToggleGroup,
    required this.currentValue,
    required this.onSelected,
  });

  final ScrollController controller;
  final NarrativeCatalog catalog;
  final NarrativeSearchResults results;
  final Map<String, bool> expandedGroups;
  final ValueChanged<String> onToggleGroup;
  final Object? currentValue;
  final ValueChanged<Object?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            catalog.strings.noResults,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final groups = <(String, String, List<NarrativeEntry>)>[
      (
        'title',
        catalog.strings.searchGroupLabel(
          'searchByTitle',
          results.byTitle.length,
        ),
        results.byTitle,
      ),
      (
        'content',
        catalog.strings.searchGroupLabel(
          'searchByContent',
          results.byContent.length,
        ),
        results.byContent,
      ),
      (
        'speaker',
        catalog.strings.searchGroupLabel(
          'searchBySpeaker',
          results.bySpeaker.length,
        ),
        results.bySpeaker,
      ),
    ];

    return CustomScrollView(
      key: const ValueKey('narrative-search-results'),
      controller: controller,
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: _NarrativeSearchGroupHeader(
              key: ValueKey('narrative-search-header-${group.$1}'),
              label: group.$2,
              expanded: expandedGroups[group.$1] ?? true,
              onTap: () => onToggleGroup(group.$1),
            ),
          ),
          if (expandedGroups[group.$1] ?? true)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              sliver: SliverList.builder(
                itemCount: group.$3.length,
                itemBuilder: (context, index) {
                  final entry = group.$3[index];
                  return _NarrativeCard(
                    key: ValueKey(
                      'narrative-search-${group.$1}-${entry.groupId}',
                    ),
                    catalog: catalog,
                    entry: entry,
                    iconAsset: catalog.displayIcon(entry),
                    selected: currentValue?.toString() == entry.valueKey,
                    onSelected: onSelected,
                  );
                },
              ),
            ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _NarrativeSearchGroupHeader extends StatelessWidget {
  const _NarrativeSearchGroupHeader({
    super.key,
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 16, 4),
        child: Row(
          children: [
            Icon(expanded ? Icons.expand_more : Icons.chevron_right),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NarrativeSectionGrid extends StatelessWidget {
  const _NarrativeSectionGrid({
    super.key,
    required this.controller,
    required this.catalog,
    required this.sections,
    required this.noDialogueSelected,
    required this.onNoDialogueSelected,
    required this.onSectionSelected,
  });

  final ScrollController controller;
  final NarrativeCatalog catalog;
  final List<NarrativeSection> sections;
  final bool noDialogueSelected;
  final VoidCallback onNoDialogueSelected;
  final ValueChanged<NarrativeSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('narrative-section-grid'),
      controller: controller,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: responsiveSelectionGridTileExtent(
          context,
          baseExtent: 196,
        ),
      ),
      itemCount: sections.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _NarrativeSectionCard.noDialogue(
            label: catalog.strings.noDialogue,
            selected: noDialogueSelected,
            onTap: onNoDialogueSelected,
          );
        }
        final section = sections[index - 1];
        return _NarrativeSectionCard(
          key: ValueKey('narrative-section-${section.id.name}'),
          label: catalog.strings.sectionLabel(section),
          subtitle: catalog.strings.dialogueCount(
            catalog.entriesForSection(section.id).length,
          ),
          iconAsset: section.iconAsset,
          selected: false,
          onTap: () => onSectionSelected(section),
        );
      },
    );
  }
}

class _NarrativeSectionCard extends StatelessWidget {
  const _NarrativeSectionCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  }) : noDialogue = false;

  const _NarrativeSectionCard.noDialogue({
    required this.label,
    required this.selected,
    required this.onTap,
  }) : subtitle = '',
       iconAsset = '',
       noDialogue = true,
       super(key: const ValueKey('narrative-no-dialogue-grid'));

  final String label;
  final String subtitle;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;
  final bool noDialogue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preserveIconBounds = iconAsset.contains('/Mode_MemoryLane');
    return Card(
      color: selected ? theme.colorScheme.primaryContainer : null,
      shape: _cardShape(theme, selected),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: noDialogue
                    ? ClipOval(
                        child: ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.block,
                            size: 42,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : preserveIconBounds
                    ? Padding(
                        padding: const EdgeInsets.all(3),
                        child: AssetImageWidget(
                          assetPath: iconAsset,
                          altCandidates: imageAltCandidates(iconAsset),
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      )
                    : ClipOval(
                        child: AssetImageWidget(
                          assetPath: iconAsset,
                          altCandidates: imageAltCandidates(iconAsset),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoNarrativeCard extends StatelessWidget {
  const _NoNarrativeCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: _cardShape(theme, selected),
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.block),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({
    super.key,
    required this.catalog,
    required this.entry,
    required this.iconAsset,
    required this.selected,
    required this.onSelected,
  });

  final NarrativeCatalog catalog;
  final NarrativeEntry entry;
  final String iconAsset;
  final bool selected;
  final ValueChanged<Object?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preserveIconBounds = iconAsset.contains('/Mode_MemoryLane');
    return Opacity(
      opacity: entry.selectable ? 1 : 0.6,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: _cardShape(theme, selected),
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : null,
        child: InkWell(
          onTap: entry.selectable ? () => onSelected(entry.value) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (preserveIconBounds)
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: AssetImageWidget(
                      assetPath: iconAsset,
                      altCandidates: imageAltCandidates(iconAsset),
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AssetImageWidget(
                      assetPath: iconAsset,
                      altCandidates: imageAltCandidates(iconAsset),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entry.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!entry.selectable)
                  Tooltip(
                    message: catalog.strings.unavailableDialogue,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.lock_outline, size: 20),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: catalog.strings.detailsTitle,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (previewContext) => NarrativePreviewScreen(
                        catalog: catalog,
                        dialogue: entry,
                        onSelect: entry.selectable
                            ? () {
                                Navigator.of(previewContext).pop();
                                onSelected(entry.value);
                              }
                            : null,
                      ),
                    ),
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

ShapeBorder _cardShape(ThemeData theme, bool selected) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: selected
          ? theme.colorScheme.primary
          : theme.dividerColor.withValues(alpha: 0.3),
      width: selected ? 2 : 1,
    ),
  );
}
