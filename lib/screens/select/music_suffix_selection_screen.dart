import 'package:flutter/material.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/selection_grid_layout.dart';

/// Picker for `MusicSuffix` (codename + icon + localized title).
///
/// Loads codenames/icons from `assets/resources/MusicSuffixes.json`; icons are shared with stage tiles under `assets/images/round_icons/`.
class MusicSuffixSelectionScreen extends StatefulWidget {
  const MusicSuffixSelectionScreen({
    super.key,
    required this.currentCodename,
    required this.onCodenameSelected,
    required this.onBack,
    this.stateBucketId,
  });

  final String currentCodename;
  final void Function(String codename) onCodenameSelected;
  final VoidCallback onBack;
  final String? stateBucketId;

  @override
  State<MusicSuffixSelectionScreen> createState() =>
      _MusicSuffixSelectionScreenState();
}

class _MusicSuffixSelectionScreenState
    extends State<MusicSuffixSelectionScreen> {
  String _searchQuery = '';
  late final SelectionViewMemory _memory;
  late final ScrollController _scrollController;

  static const double _iconLogicalSize = 96;

  @override
  void initState() {
    super.initState();
    final bucket = widget.stateBucketId?.isNotEmpty == true
        ? widget.stateBucketId!
        : 'global';
    _memory = SelectionViewMemoryStore.forKey('$bucket:music-suffix');
    _searchQuery = _memory.query;
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

  void _rememberScrollOffset() {
    if (_scrollController.hasClients) {
      _memory.scrollOffset = _scrollController.offset;
    }
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _memory
      ..query = query
      ..scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final allCodes = MusicSuffixCatalog.orderedCodes;
    var items = allCodes;
    if (normalizeSelectionSearchQuery(_searchQuery).isNotEmpty) {
      items = allCodes.where((code) {
        final nameKey = MusicSuffixCatalog.resourceKey(code);
        return matchesSelectionSearch(_searchQuery, [
          code,
          nameKey,
          ResourceNames.lookup(context, nameKey),
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
          l10n?.selectMusicSuffix ?? 'Select music suffix',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SelectionSearchField(
              hintText: l10n?.searchMusicSuffix ?? 'Search name or codename',
              query: _searchQuery,
              onChanged: _setSearchQuery,
              onClear: () => _setSearchQuery(''),
            ),
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
                    l10n?.noMusicSuffixFound ?? 'No music suffix found',
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
                final code = items[i];
                final isSelected =
                    MusicSuffixCatalog.canonicalCode(code) ==
                    MusicSuffixCatalog.canonicalCode(widget.currentCodename);
                return _MusicSuffixTile(
                  codename: code,
                  displayName: ResourceNames.lookup(
                    context,
                    MusicSuffixCatalog.resourceKey(code),
                  ),
                  iconSize: _iconLogicalSize,
                  isSelected: isSelected,
                  onTap: () => widget.onCodenameSelected(code),
                );
              },
            ),
    );
  }
}

class _MusicSuffixTile extends StatelessWidget {
  const _MusicSuffixTile({
    required this.codename,
    required this.displayName,
    required this.iconSize,
    required this.isSelected,
    required this.onTap,
  });

  final String codename;
  final String displayName;
  final double iconSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assetPath = MusicSuffixCatalog.iconAsset(codename);
    final isUnknown = assetPath == MusicSuffixCatalog.unknownIconAsset;

    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
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
                  width: iconSize,
                  height: iconSize,
                  child: AssetImageWidget(
                    assetPath: assetPath,
                    altCandidates: isUnknown
                        ? []
                        : imageAltCandidates(assetPath),
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                codename,
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
