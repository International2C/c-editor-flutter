import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

import 'preview_sticker_catalog.dart';
import 'preview_sticker_picker_session.dart';
import 'preview_document.dart';
import 'preview_picker_scroll_area.dart';
import 'preview_picker_session.dart';

export 'preview_sticker_picker_session.dart';

class _PreviewBannerPresentation {
  const _PreviewBannerPresentation({required this.name, this.iconAssetPath});

  final String name;
  final String? iconAssetPath;
}

String _roundIconAssetPath(String iconName) {
  if (iconName.startsWith('assets/')) return iconName;
  if (iconName == 'unknown.webp' || iconName.endsWith('/unknown.webp')) {
    return 'assets/images/others/unknown.webp';
  }
  return 'assets/images/round_icons/$iconName';
}

_PreviewBannerPresentation _bannerPresentationFor({
  required BuildContext context,
  required String stem,
  required StageBannerResolver banners,
  required String Function(String key, [String? fallback]) t,
}) {
  if (stem == banners.defaultStem || stem.toLowerCase() == 'unknown') {
    return _PreviewBannerPresentation(
      name: t('previewGenUnknownBanner', 'Spacetime Main Menu'),
      iconAssetPath: 'assets/images/others/unknown.webp',
    );
  }

  final aliases = banners.stageAliasesForStem(stem);
  final candidates = [
    for (final stage in StageRepository.allItems)
      if (aliases.contains(stage.alias)) stage,
  ];
  final expectedAlias = '${stem}Stage'.toLowerCase();
  StageItem? representative;
  for (final stage in candidates) {
    if (stage.alias.toLowerCase() == expectedAlias) {
      representative = stage;
      break;
    }
  }
  if (representative == null) {
    for (final stage in candidates) {
      if (stage.type == StageType.main) {
        representative = stage;
        break;
      }
    }
  }
  if (representative == null && candidates.isNotEmpty) {
    representative = candidates.first;
  }
  if (representative != null) {
    final iconName = representative.iconName;
    return _PreviewBannerPresentation(
      name: ResourceNames.lookupOrFallback(
        context,
        StageRepository.getName(representative.alias),
        representative.alias,
      ),
      iconAssetPath: iconName == null ? null : _roundIconAssetPath(iconName),
    );
  }

  for (final alias in aliases) {
    final preset = CustomStagePresetRepository.presetForAlias(alias);
    if (preset == null) continue;
    final iconName = preset.iconName;
    return _PreviewBannerPresentation(
      name: ResourceNames.lookupOrFallback(
        context,
        preset.nameKey,
        preset.alias,
      ),
      iconAssetPath: _roundIconAssetPath(iconName),
    );
  }

  return _PreviewBannerPresentation(
    name: t('previewGenUnknownBanner', 'Spacetime Main Menu'),
    iconAssetPath: 'assets/images/others/unknown.webp',
  );
}

/// Catalog-ordered banner stems, with the main menu just before custom images.
List<String> previewBannerPickerEntries({
  required StageBannerResolver banners,
  required Iterable<String> stageAliases,
}) => [...banners.orderedStemsForStageAliases(stageAliases), '__custom__'];

/// Banner picker: catalog-ordered localized cards, round icons, custom entry.
/// The main-menu banner is followed by the custom-image action at the end.
Future<String?> showPreviewBannerPicker({
  required BuildContext context,
  required StageBannerResolver banners,
  required String Function(String key, [String? fallback]) t,
  String? currentStem,
  PreviewPickerSession? session,
}) async {
  await Future.wait([
    StageRepository.init(),
    CustomStagePresetRepository.init(),
    ResourceNames.ensureLoaded(),
  ]);
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final entries = previewBannerPickerEntries(
        banners: banners,
        stageAliases: StageRepository.allItems.map((stage) => stage.alias),
      );
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        content: SizedBox(
          width: 520,
          height: 620,
          child: PreviewPickerScrollArea(
            session: session,
            scrollbarKey: const ValueKey('previewBannerPickerScrollbar'),
            builder: (controller) => ListView.builder(
              key: const ValueKey('previewBannerPickerScroll'),
              controller: controller,
              itemCount: entries.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      t('previewGenChooseBanner', 'Choose banner'),
                      style: theme.textTheme.headlineSmall,
                    ),
                  );
                }
                final stem = entries[i - 1];
                if (stem == '__custom__') {
                  return Card(
                    key: const ValueKey('preview-banner-custom'),
                    margin: const EdgeInsets.only(bottom: 8),
                    clipBehavior: Clip.antiAlias,
                    child: EditorOptionTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.folder_open, size: 22),
                      ),
                      title: Text(
                        t('previewGenCustomBanner', 'Custom image'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => Navigator.pop(ctx, '__custom__'),
                    ),
                  );
                }
                final info = _bannerPresentationFor(
                  context: ctx,
                  stem: stem,
                  banners: banners,
                  t: t,
                );
                final isSelected = stem == currentStem;
                return Card(
                  key: ValueKey('preview-banner-$stem'),
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: EditorOptionTile(
                    onTap: () => Navigator.pop(ctx, stem),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: AssetImageWidget(
                        assetPath:
                            info.iconAssetPath ??
                            banners.roundIconAssetForStem(stem),
                        altCandidates: banners.roundIconAltCandidatesForStem(
                          stem,
                        ),
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text(
                      info.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      stem,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('previewGenCancel', 'Cancel')),
          ),
        ],
      );
    },
  );
}

/// Kept for callers that use the original image-picker category identifiers.
const kPreviewImageFolders = kPreviewStickerTags;

class PreviewAssetImageChoice {
  const PreviewAssetImageChoice.asset(this.assetPath) : isCustom = false;
  const PreviewAssetImageChoice.custom() : assetPath = null, isCustom = true;

  final String? assetPath;
  final bool isCustom;
}

Future<PreviewAssetImageChoice?> showPreviewAssetImagePicker({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
  PreviewStickerPickerSession? session,
  PvzLevelFile? levelFile,
  ParsedLevelData? parsed,
  PreviewDocument? document,
}) async {
  final stickers = await loadPreviewStickerCatalog();
  final priorityAssets = levelFile == null || parsed == null
      ? const <String>{}
      : await loadPreviewCurrentLevelStickerAssetPaths(
          stickers: stickers,
          levelFile: levelFile,
          parsed: parsed,
          document: document,
        );

  if (!context.mounted) return null;

  return showDialog<PreviewAssetImageChoice>(
    context: context,
    builder: (ctx) => PreviewStickerPickerDialog(
      stickers: stickers,
      priorityAssetPaths: priorityAssets,
      t: t,
      session: session,
    ),
  );
}

class PreviewStickerPickerDialog extends StatefulWidget {
  const PreviewStickerPickerDialog({
    super.key,
    required this.stickers,
    required this.t,
    this.session,
    this.priorityAssetPaths = const [],
  });

  final List<PreviewSticker> stickers;
  final String Function(String key, [String? fallback]) t;
  final PreviewStickerPickerSession? session;
  final Iterable<String> priorityAssetPaths;

  @override
  State<PreviewStickerPickerDialog> createState() =>
      _PreviewStickerPickerDialogState();
}

class _PreviewStickerPickerDialogState
    extends State<PreviewStickerPickerDialog> {
  late final PreviewStickerPickerSession _session;
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late List<PreviewSticker> _orderedStickers;
  bool _restoringPosition = true;
  int _positionRevision = 0;
  String? _folder;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _session = widget.session ?? PreviewStickerPickerSession();
    _orderStickers();
    _folder = _session.selectedTag;
    if (!_folders.contains(_folder)) _folder = null;
    _query = _session.query;
    _searchController = TextEditingController(text: _query);
    _scrollController = ScrollController(
      initialScrollOffset: _session.scrollOffsetFor(_folder, _query),
      keepScrollOffset: false,
    )..addListener(_rememberPosition);
    _restorePosition();
  }

  void _orderStickers() {
    _orderedStickers = prioritizePreviewStickers(
      stickers: widget.stickers,
      priorityAssetPaths: widget.priorityAssetPaths,
    );
  }

  @override
  void didUpdateWidget(covariant PreviewStickerPickerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stickers != widget.stickers ||
        oldWidget.priorityAssetPaths != widget.priorityAssetPaths) {
      _orderStickers();
    }
  }

  void _rememberPosition() {
    _session.selectedTag = _folder;
    _session.query = _query;
    if (_restoringPosition) return;
    if (_scrollController.hasClients) {
      _session.rememberScrollOffset(_folder, _query, _scrollController.offset);
    }
  }

  void _restorePosition({double fallback = 0}) {
    _restoringPosition = true;
    final revision = ++_positionRevision;
    final target = _session.scrollOffsetFor(
      _folder,
      _query,
      fallback: fallback,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _positionRevision) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          target.clamp(0.0, _scrollController.position.maxScrollExtent),
        );
      }
      _restoringPosition = false;
      _rememberPosition();
    });
  }

  void _setFilter(String? folder, String query) {
    if (_folder == folder && _query == query) return;
    final fallback = query == _query && _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    _rememberPosition();
    setState(() {
      _folder = folder;
      _query = query;
      _session.selectedTag = folder;
      _session.query = query;
    });
    // Keep the visible part of the header when first visiting a tag. Returning
    // to a tag still restores its own position; a new search starts at the top.
    _restorePosition(fallback: fallback);
  }

  @override
  void dispose() {
    _rememberPosition();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> get _folders {
    final found = widget.stickers.map((sticker) => sticker.tag).toSet();
    return [
      for (final f in kPreviewImageFolders)
        if (found.contains(f)) f,
    ];
  }

  List<PreviewSticker> get _filtered {
    final q = _query.trim().toLowerCase();
    return _orderedStickers.where((sticker) {
      if (_folder != null && sticker.tag != _folder) return false;
      return q.isEmpty ||
          sticker.localizedName(context, widget.t).toLowerCase().contains(q) ||
          sticker.searchTerms.any((term) => term.toLowerCase().contains(q));
    }).toList();
  }

  String _tagLabel(String tag) {
    const labels = {
      'plants': ('previewStickerTagPlants', 'Plants'),
      'zombies': ('previewStickerTagZombies', 'Zombies'),
      'griditems': ('previewStickerTagGridItems', 'Grid Items'),
      'creatures': ('previewStickerTagCreatures', 'Creatures'),
      'tool_packets': ('previewStickerTagToolPackets', 'Tool Packets'),
      'components': ('previewStickerTagComponents', 'Components'),
      'round_icons': ('previewStickerTagMapAndMusic', 'Lawns and music'),
      'ui': ('previewStickerTagUI', 'Tags and themes'),
      'worlds': ('previewStickerTagWorlds', 'Worlds'),
      'others': ('previewStickerTagOthers', 'Others'),
    };
    final label = labels[tag] ?? labels['others']!;
    return widget.t(label.$1, label.$2);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final folders = _folders;
    final items = _filtered;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SizedBox(
        width: 640,
        height: 560,
        child: Column(
          children: [
            Expanded(
              child: PreviewPickerScrollArea(
                scrollbarKey: const ValueKey('preview-sticker-scrollbar'),
                controller: _scrollController,
                builder: (controller) => CustomScrollView(
                  key: const ValueKey('preview-sticker-scroll'),
                  controller: controller,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('previewGenStickersTitle', 'Add stickers'),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              key: const ValueKey('preview-sticker-search'),
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                prefixIcon: const Icon(Icons.search),
                                hintText: t(
                                  'previewGenImageSearch',
                                  'Search stickers',
                                ),
                              ),
                              onChanged: (v) => _setFilter(_folder, v),
                            ),
                            const SizedBox(height: 8),
                            HorizontalTagScroller(
                              key: const ValueKey(
                                'preview-sticker-tags-scroll',
                              ),
                              padding: EdgeInsets.zero,
                              initialScrollOffset: _session.tagStripOffset,
                              onScrollOffsetChanged: (offset) =>
                                  _session.tagStripOffset = offset,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    key: const ValueKey(
                                      'preview-sticker-tag-all',
                                    ),
                                    label: Text(t('previewGenImageAll', 'All')),
                                    selected: _folder == null,
                                    onSelected: (_) => _setFilter(null, _query),
                                  ),
                                ),
                                for (final f in folders)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      key: ValueKey('preview-sticker-tag-$f'),
                                      label: Text(_tagLabel(f)),
                                      selected: _folder == f,
                                      onSelected: (_) => _setFilter(f, _query),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (items.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(t('previewGenImageEmpty', 'No images')),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 100,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final sticker = items[i];
                            return InkWell(
                              key: ValueKey(
                                'preview-sticker-${sticker.assetPath}',
                              ),
                              onTap: () => Navigator.pop(
                                context,
                                PreviewAssetImageChoice.asset(
                                  sticker.assetPath,
                                ),
                              ),
                              child: Tooltip(
                                message: sticker.localizedName(context, t),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: AssetImageWidget(
                                      assetPath: sticker.assetPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: OverflowBar(
                  spacing: 8,
                  overflowSpacing: 4,
                  overflowAlignment: OverflowBarAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t('previewGenCancel', 'Cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const PreviewAssetImageChoice.custom(),
                      ),
                      child: Text(t('previewGenCustomImage', 'Custom file')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
