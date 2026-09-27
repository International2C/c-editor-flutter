import 'package:c_editor/data/oak_archery_preview.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/widgets/oak_train_warnings.dart';
import 'package:c_editor/data/gladiator_row_utils.dart';
import 'package:c_editor/widgets/gladiator_row_preview.dart';
import 'dart:math' as math;

import 'package:c_editor/widgets/editor_components.dart'
    show HorizontalTagScroller, isDesktopPlatform;
import 'package:c_editor/data/zombie_conditions.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/lunar_mine_vein_type_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/armrack_type_catalog.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:collection/collection.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/plant_food_discovery.dart';
import 'package:c_editor/data/challenge_resource_l10n.dart';
import 'package:c_editor/data/repository/challenge_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c_editor/widgets/rift_theme_widgets.dart';
import 'package:c_editor/widgets/explosive_barrels_preview_grid.dart';
import 'package:c_editor/widgets/local_scrollbar_region.dart';

/// Keeps card margins from consuming the text column in a scaled mobile view.
class _OverviewCardPadding extends StatelessWidget {
  const _OverviewCardPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (constraints.maxWidth * 0.06).clamp(0.0, 20.0),
        vertical: 20,
      ),
      child: child,
    ),
  );
}

class LevelOverviewDialog extends StatefulWidget {
  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final String fileName;
  final String? filePath;

  /// When true (opened from the level list), show an "Open level" action.
  final bool showOpenLevel;
  final VoidCallback onClose;

  const LevelOverviewDialog({
    super.key,
    required this.levelFile,
    required this.parsed,
    required this.fileName,
    required this.onClose,
    this.filePath,
    this.showOpenLevel = false,
  });

  @override
  State<LevelOverviewDialog> createState() => _LevelOverviewDialogState();
}

class _LevelOverviewDialogState extends State<LevelOverviewDialog> {
  String _p(String key, [String? fallback]) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'levelPreview':
        return l10n.levelOverview;
      case 'previewStartingPlantFood':
        return l10n.previewStartingPlantFood;
      case 'previewPrePlaced':
        return l10n.previewPrePlaced;
      case 'previewRegularPlants':
        return l10n.previewRegularPlants;
      case 'previewFrozenPlants':
        return l10n.previewFrozenPlants;
      case 'previewLevelContent':
        return l10n.previewLevelContent;
      case 'previewSeedBank':
        return l10n.previewSeedBank;
      case 'previewFeatures':
        return l10n.previewFeatures;
      case 'previewActiveModules':
        return l10n.previewActiveModules;
      case 'previewInitial':
        return l10n.previewInitial;
      case 'previewGenerateImagePreview':
        return l10n.previewGenerateImagePreview;
      default:
        return fallback ?? key;
    }
  }

  Future<void> _openPreviewGenerator(BuildContext context) async {
    final opener = PluginHostHooks.openPreviewImageGenerator;
    if (opener == null) return;
    await opener(
      context,
      levelFile: widget.levelFile,
      parsed: widget.parsed,
      fileName: widget.fileName,
    );
  }

  void _openLevel() {
    final path = widget.filePath;
    if (path == null || path.isEmpty) return;
    widget.onClose();
    context.read<AppNavigationCubit>().openLevel(widget.fileName, path);
  }

  int _prePlacedTabIndex = 0;
  int _plantTypeIndex = 0;
  String? _gridItemCategoryKey;
  bool _isLoadingRepos = true;

  List<String> _cachedZombies = [];
  List<DiscoveredGridItem> _cachedGridItems = [];
  List<String> _cachedEvents = [];
  int _cachedTotalPfCount = 0;
  List<GridPreviewCategoryOption> _cachedGridCategories = [];

  bool _blackListExpanded = false;
  bool _whiteListExpanded = false;

  bool _copycatBlackListExpanded = false;
  bool _copycatWhiteListExpanded = false;
  bool _seedRainExpanded = false;
  bool _seeingStarsPlantsExpanded = false;

  bool _encounterZombiesExpanded = false;
  bool _encounterGridItemsExpanded = false;
  bool _encounterEventsExpanded = false;
  bool _riftThemesExpanded = false;
  bool _challengesExpanded = false;
  bool _modulesExpanded = false;

  int? _selectedX;
  int? _selectedY;
  List<String> _selectedIds = [];
  // Bare IDs can belong to both plants and grid items, such as cosmoss.
  // Retain the selected grid's resource domain instead of guessing it again.
  int _selectedResourceTabIndex = 2;

  final ScrollController _subCategoryScrollController = ScrollController();
  final ScrollController _sidebarScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();
  final ScrollController _prePlacedTabScrollController = ScrollController();
  final ScrollController _plantTypeTabScrollController = ScrollController();

  @override
  void dispose() {
    _subCategoryScrollController.dispose();
    _sidebarScrollController.dispose();
    _contentScrollController.dispose();
    _prePlacedTabScrollController.dispose();
    _plantTypeTabScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
    ]);

    _cachedZombies = ZombieDiscovery.discoverZombies(
      widget.levelFile,
      widget.parsed,
    ).toList();
    _cachedGridItems = GridItemDiscovery.discoverGridItemEntries(
      widget.levelFile,
    );
    _cachedEvents = ZombieDiscovery.discoverEvents(widget.parsed).toList();
    _cachedTotalPfCount = PlantFoodDiscovery.calculateTotalPlantFood(
      widget.levelFile,
      widget.parsed,
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      final cats = collectGridPreviewCategories(
        context,
        widget.levelFile,
        l10n,
      );
      _cachedGridCategories = cats;

      if (cats.isNotEmpty) {
        if (cats.any((c) => c.kind == GridPreviewModuleKind.plants)) {
          _prePlacedTabIndex = 0;
        } else if (cats.any(
          (c) =>
              c.kind == GridPreviewModuleKind.zombies ||
              c.kind == GridPreviewModuleKind.dropShip,
        )) {
          _prePlacedTabIndex = 1;
        } else if (cats.any(
          (c) => c.kind == GridPreviewModuleKind.zombossMech,
        )) {
          _prePlacedTabIndex = 3;
        } else if (cats.any((c) => c.kind == GridPreviewModuleKind.zomboss)) {
          _prePlacedTabIndex = 4;
        } else if (cats.every((c) => _isChallengeKind(c.kind))) {
          _prePlacedTabIndex = 5;
        } else {
          _prePlacedTabIndex = 2;
        }
      }

      setState(() => _isLoadingRepos = false);
    }
  }

  String _getModuleLabel(GridPreviewModuleKind kind, AppLocalizations l10n) {
    switch (kind) {
      case GridPreviewModuleKind.plants:
        return l10n.previewTabPlants;
      case GridPreviewModuleKind.zombies:
        return _p('previewInitial', 'Initial');
      case GridPreviewModuleKind.common:
        return _p('previewInitial', 'Initial');
      case GridPreviewModuleKind.piratePlank:
        return l10n.moduleTitle_PiratePlankProperties;
      case GridPreviewModuleKind.railcart:
        return l10n.moduleTitle_RailcartProperties;
      case GridPreviewModuleKind.mechanismPlank:
        return l10n.moduleTitle_MechanismPlankProperties;
      case GridPreviewModuleKind.armrack:
        return l10n.moduleTitle_ArmrackProperties;
      case GridPreviewModuleKind.energyGrid:
        return l10n.moduleTitle_EnergyGridProperties;
      case GridPreviewModuleKind.lunarMineVein:
        return l10n.moduleTitle_LunarMineVeinModuleProperties;
      case GridPreviewModuleKind.radiationMeteor:
        return l10n.moduleTitle_RadiationMeteorModuleProperties;
      case GridPreviewModuleKind.gladiatorRow:
        return l10n.moduleTitle_GladiatorRowModuleProperties;
      case GridPreviewModuleKind.bronzeStatue:
        return l10n.moduleTitle_BronzeProperties;
      case GridPreviewModuleKind.powerTile:
        return l10n.moduleTitle_PowerTileProperties;
      case GridPreviewModuleKind.fogSystem:
        return l10n.moduleTitle_WarMistProperties;
      case GridPreviewModuleKind.tideSystem:
        return l10n.moduleTitle_TideProperties;
      case GridPreviewModuleKind.smokePollution:
        return l10n.moduleTitle_SmokePollutionModuleProperties;
      case GridPreviewModuleKind.manholePipeline:
        return l10n.moduleTitle_ManholePipelineModuleProperties;
      case GridPreviewModuleKind.roofProperties:
        return l10n.moduleTitle_RoofProperties;
      case GridPreviewModuleKind.tunnelDefend:
        return l10n.moduleTitle_TunnelDefendModuleProperties;
      case GridPreviewModuleKind.expeditionTiles:
        return l10n.moduleTitle_SouDaCheTunnelDefendDefault;
      case GridPreviewModuleKind.gulliverTunnel:
        return l10n.moduleTitle_InitialGridItemGulliverTunnelProperties;
      case GridPreviewModuleKind.renaissance:
        return l10n.renaissanceStatues;
      case GridPreviewModuleKind.vases:
        return l10n.vaseBreaker;
      case GridPreviewModuleKind.explosiveBarrels:
        return l10n.moduleTitle_BombProperties;
      case GridPreviewModuleKind.portalFight:
        return l10n.moduleTitle_PVZ1PassageModuleProperties;
      case GridPreviewModuleKind.bowlingFoulLine:
        return l10n.moduleTitle_BowlingMinigameProperties;
      case GridPreviewModuleKind.moldColony:
        return l10n.moduleTitle_MoldColonyChallengeProps;
      case GridPreviewModuleKind.dropShip:
        return l10n.moduleTitle_DropShipProperties;
      case GridPreviewModuleKind.protectPlants:
        return l10n.moduleTitle_ProtectThePlantChallengeProperties;
      case GridPreviewModuleKind.seeingStars:
        return l10n.moduleTitle_PVZ1SeeingStarsModuleProperties;
      case GridPreviewModuleKind.protectItems:
        return l10n.moduleTitle_ProtectTheGridItemChallengeProperties;
      case GridPreviewModuleKind.flowers:
        return ChallengeResourceL10n.title(
          context,
          'StarChallengeZombieDistanceProps',
        );
      case GridPreviewModuleKind.zombossMech:
        return l10n.zomboss;
      case GridPreviewModuleKind.zomboss:
        return l10n.boss;
      case GridPreviewModuleKind.empty:
        return _p('previewInitial', 'Initial');
    }
  }

  String _cleanId(String id) {
    if (id.contains('(') && id.contains('@')) {
      return LevelParser.extractAlias(id);
    }
    return id;
  }

  bool _isChallengeKind(GridPreviewModuleKind kind) {
    return kind == GridPreviewModuleKind.protectPlants ||
        kind == GridPreviewModuleKind.protectItems ||
        kind == GridPreviewModuleKind.flowers ||
        kind == GridPreviewModuleKind.seeingStars;
  }

  int _parseCoord(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return double.tryParse(val.toString())?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final levelDef = widget.parsed.levelDef;
    final isDesktop = isDesktopPlatform(context);

    if (_isLoadingRepos) {
      // Prefer Dialog over AlertDialog: AlertDialog wraps content in
      // IntrinsicWidth + Flexible, which can end up with size MISSING.
      return const Dialog(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (levelDef == null) {
      return Dialog(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.fileName, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(l10n.noLevelDefinitionHint),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onClose,
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bodyCards =
        [
          _buildSummaryCard(context, levelDef, theme, l10n),
          _buildSeedBankCard(context, theme, l10n),
          _buildConveyorCard(context, theme, l10n),
          _buildCopycatCard(context, theme, l10n),
          _buildSeeingStarsCard(context, theme, l10n),
          _buildOakArcheryCard(theme, l10n),
          _buildWaveGeneratorCard(theme, l10n),
          _buildSingleHandedCard(context, theme, l10n),
          _buildSeedRainCard(context, theme, l10n),
          _buildHeianWindCard(context, theme, l10n),
          _buildPrePlacedCard(context, theme, l10n),
          _buildEncounterCard(context, theme, l10n),
          _buildModulesCard(context, theme, l10n),
        ].fold<List<Widget>>([], (list, card) {
          if (card is SizedBox &&
              (card.height ?? 0) == 0 &&
              card.child == null) {
            return list;
          }
          if (list.isNotEmpty) {
            list.add(const SizedBox(height: 12));
          }
          list.add(card);
          return list;
        });

    return LayoutBuilder(
      builder: (context, available) {
        final media = MediaQuery.of(context);
        final availableWidth = available.hasBoundedWidth
            ? available.maxWidth
            : media.size.width;
        final availableHeight = available.hasBoundedHeight
            ? available.maxHeight
            : media.size.height;
        final horizontalInset = (availableWidth * 0.04).clamp(
          0.0,
          isDesktop ? 40.0 : 12.0,
        );
        final usableHeight = (availableHeight - media.viewInsets.vertical)
            .clamp(0.0, availableHeight);
        final verticalInset = (usableHeight * 0.04).clamp(
          0.0,
          isDesktop ? 40.0 : 12.0,
        );
        // Keep a non-zero tight height so Expanded children always get a size
        // (loose/zero maxHeight under UI scale / keyboard can break hit-testing).
        final contentMaxHeight = (usableHeight - verticalInset * 2).clamp(
          1.0,
          math.max(1.0, usableHeight * 0.9),
        );
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: verticalInset,
          ),
          child: SizedBox(
            width: isDesktop
                ? math
                      .min(900.0, availableWidth - horizontalInset * 2)
                      .toDouble()
                : double.infinity,
            height: contentMaxHeight.toDouble(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hPad = (constraints.maxWidth * 0.04).clamp(0.0, 20.0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Scrollbar(
                        key: const ValueKey('levelOverviewScrollbar'),
                        controller: _contentScrollController,
                        thumbVisibility: true,
                        interactive: true,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            key: const ValueKey('levelOverviewScroll'),
                            controller: _contentScrollController,
                            primary: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    hPad,
                                    16,
                                    hPad,
                                    8,
                                  ),
                                  child: _buildOverviewHeader(
                                    context,
                                    theme,
                                    l10n,
                                  ),
                                ),
                                const Divider(height: 1),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    hPad,
                                    12,
                                    hPad,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: bodyCards,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton(
                            onPressed: widget.onClose,
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                            child: Text(l10n.close),
                          ),
                          if (widget.showOpenLevel &&
                              widget.filePath != null &&
                              widget.filePath!.isNotEmpty) ...[
                            FilledButton(
                              onPressed: _openLevel,
                              child: Text(l10n.levelOverviewOpenLevel),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(24) / 24;
        final isNarrow = constraints.maxWidth / textScale < 600;
        final title = Text(
          '${l10n.levelOverview}: ${widget.fileName}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
        final canGenerate = PluginHostHooks.openPreviewImageGenerator != null;
        final buttonStyle = TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        );
        final Widget generateButton = constraints.maxWidth / textScale < 240
            ? TextButton(
                onPressed: () => _openPreviewGenerator(context),
                style: buttonStyle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      l10n.previewGenerateImagePreview,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : TextButton.icon(
                onPressed: () => _openPreviewGenerator(context),
                style: buttonStyle,
                icon: const Icon(Icons.image_outlined, size: 20),
                label: Text(l10n.previewGenerateImagePreview),
              );
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              if (canGenerate) ...[const SizedBox(height: 4), generateButton],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: title),
            if (canGenerate) ...[
              const SizedBox(width: 12),
              Flexible(flex: 2, child: generateButton),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, {Color? color}) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: color ?? theme.colorScheme.primary.withValues(alpha: 0.9),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    LevelDefinitionData def,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final stageInfo = RtidParser.parse(def.stageModule);
    final stageAlias = stageInfo?.alias ?? 'Unknown';
    final stageSource = stageInfo?.source ?? 'Unknown';

    String worldName;
    String customSuffix = "";
    String? stageIconFile;

    if (stageSource == CustomStageLevelUtils.currentLevel) {
      customSuffix = " (${l10n.customLabel.toLowerCase()})";
      final stageObj = CustomStageLevelUtils.findStageObject(
        widget.levelFile,
        stageAlias,
      );
      if (stageObj != null && stageObj.objData is Map) {
        final objDataMap = Map<String, dynamic>.from(stageObj.objData as Map);
        worldName = ResourceNames.lookup(
          context,
          CustomStageLevelUtils.displayStageBaseNameKey(
            objclass: stageObj.objClass,
            objdata: objDataMap,
          ),
        );
        stageIconFile = CustomStageLevelUtils.displayIconFileName(
          objclass: stageObj.objClass,
          objdata: objDataMap,
        );
      } else {
        worldName = l10n.customLabel;
      }
    } else {
      final stageNameKey = StageRepository.getName(stageAlias);
      worldName = ResourceNames.lookup(context, stageNameKey);
      final stageItem = StageRepository.allItems.firstWhereOrNull(
        (s) => s.alias == stageAlias,
      );
      stageIconFile = stageItem?.iconName;
    }

    final stageIconPath = stageIconFile != null
        ? 'assets/images/round_icons/$stageIconFile'
        : null;

    int startingSun = def.startingSun ?? 0;
    int pfCount = PlantFoodDiscovery.getStartingPlantFood(
      widget.levelFile,
      widget.parsed,
    );

    bool skySunEnabled =
        widget.levelFile.objects.any(
          (o) =>
              o.objClass == 'SunDropperProperties' ||
              o.objClass == 'SunDroppingModuleProperties' ||
              o.objClass == 'SunDropperModuleProperties',
        ) ||
        def.modules.any((m) => m.contains('SunDropper'));

    bool hasSunBombModule =
        widget.levelFile.objects.any(
          (o) => o.objClass == 'SunBombChallengeProperties',
        ) ||
        def.modules.any((m) => m.contains('SunBomb'));

    bool sunBombsActive = skySunEnabled && hasSunBombModule;

    bool hasOverwhelm = levelHasModule(
      widget.levelFile,
      'PVZ1OverwhelmModuleProperties',
    );
    bool hasFastEntry = levelHasModule(
      widget.levelFile,
      'ZombieMoveFastModuleProperties',
    );
    bool hasWeather = levelHasWeather(widget.levelFile);
    bool hasSpermWhale = levelHasModule(
      widget.levelFile,
      'SpermWhaleModuleProperties',
    );
    bool hasLifeSupportSystem = levelHasModule(
      widget.levelFile,
      'MoonLifeSupportSystemProperties',
    );
    // LevelModules default uses InitialCapacity 10; CurrentLevel overrides when present.
    final lifeSupportData = hasLifeSupportSystem
        ? (readMoonLifeSupportSystemData(widget.levelFile) ??
              MoonLifeSupportSystemPropertiesData())
        : null;
    final lifeSupportCapacity = lifeSupportData?.initialCapacity;
    bool hasLunarTerminal = levelHasModule(
      widget.levelFile,
      'LunarTerminalModuleProperties',
    );
    bool hasWitch = levelHasModule(widget.levelFile, 'WitchModuleProperties');
    bool hasZombieRush = levelHasModule(
      widget.levelFile,
      'ZombieRushModuleProperties',
    );

    int? rushTime;
    if (hasZombieRush) {
      final rushObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.objClass == 'ZombieRushModuleProperties',
      );
      if (rushObj != null && rushObj.objData is Map) {
        final data = rushObj.objData as Map;
        rushTime = (data['TimeCountDown'] ?? data['LevelCountdown'] ?? 120)
            .toInt();
      }
    }

    final mowerAlias = findLawnMowerAlias(def);
    String? mowerName;
    if (mowerAlias != null) {
      final key = 'lawnMower_$mowerAlias';
      final localized = ResourceNames.lookup(context, key);
      mowerName = localized != key ? localized : mowerAlias;
    }

    for (var o in widget.levelFile.objects) {
      final data = o.objData;
      if (data is Map) {
        if (o.objClass == 'LevelMutatorStartingPlantfoodProps') {
          pfCount =
              (data['StartingPlantfoodOverride'] ??
                      data['StartingPlantfood'] ??
                      pfCount)
                  .toInt();
        } else if (o.objClass == 'LastStandMinigameProperties' ||
            o.objClass == 'ZombossLastStandMinigameProperties') {
          if (data['StartingSun'] != null)
            startingSun = (data['StartingSun'] as num).toInt();
          if (data['StartingPlantfood'] != null)
            pfCount = (data['StartingPlantfood'] as num).toInt();
        }
      }
    }

    final isDesktop = isDesktopPlatform(context);
    final List<({String title, IconData? icon, String? iconId, Color color})>
    summaryLegends = [];
    if (hasLifeSupportSystem) {
      summaryLegends.add((
        title: l10n.moduleTitle_MoonLifeSupportSystemProperties,
        icon: Icons.battery_charging_full,
        iconId: null,
        color: Colors.lightBlueAccent,
      ));
    } else {
      summaryLegends.add((
        title: l10n.startingSun,
        icon: null,
        iconId: 'sun',
        color: Colors.orange,
      ));
    }
    summaryLegends.add((
      title: _p('previewStartingPlantFood', 'Starting Plant Food'),
      icon: null,
      iconId: 'plantfood',
      color: Colors.greenAccent,
    ));
    summaryLegends.add((
      title: sunBombsActive
          ? l10n.sunBombFalling
          : (skySunEnabled ? l10n.sunDroppingActive : l10n.sunDroppingInactive),
      icon: sunBombsActive
          ? Icons.wb_iridescent
          : (skySunEnabled ? Icons.wb_sunny_outlined : Icons.sunny_snowing),
      iconId: null,
      color: sunBombsActive
          ? Colors.deepPurpleAccent
          : (skySunEnabled ? Colors.lightBlueAccent : Colors.redAccent),
    ));
    if (hasOverwhelm)
      summaryLegends.add((
        title: l10n.overwhelmLabel,
        icon: Icons.view_column,
        iconId: null,
        color: Colors.blueGrey,
      ));
    if (hasFastEntry)
      summaryLegends.add((
        title: l10n.fastEntryLabel,
        icon: Icons.fast_forward,
        iconId: null,
        color: Colors.limeAccent,
      ));
    if (hasWeather) {
      final weather = getLevelWeatherType(widget.levelFile);
      if (weather != null) {
        summaryLegends.add((
          title: getWeatherLabel(weather, l10n) ?? '',
          icon: switch (weather) {
            LevelWeatherType.snow => Icons.ac_unit,
            LevelWeatherType.lightning => Icons.thunderstorm,
            LevelWeatherType.rain => Icons.cloud,
          },
          iconId: null,
          color: Colors.blueAccent,
        ));
      }
    }
    if (hasSpermWhale)
      summaryLegends.add((
        title: l10n.spermWhaleLabel,
        icon: Icons.waves,
        iconId: null,
        color: Colors.cyanAccent,
      ));
    if (hasLunarTerminal) {
      summaryLegends.add((
        title: l10n.moduleTitle_LunarTerminalModuleProperties,
        icon: Icons.precision_manufacturing,
        iconId: null,
        color: Colors.purpleAccent,
      ));
    }
    if (hasWitch)
      summaryLegends.add((
        title: l10n.witchLabel,
        icon: Icons.auto_fix_high,
        iconId: null,
        color: Colors.purpleAccent,
      ));
    if (hasZombieRush && rushTime != null)
      summaryLegends.add((
        title: l10n.zombieRushLabel,
        icon: Icons.timer,
        iconId: null,
        color: Colors.redAccent,
      ));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  ),
                  _buildSectionTitle(l10n.levelBasicInfo, theme),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.name}: ${def.name.isEmpty ? widget.fileName : def.name}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (def.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.description}: ${def.description}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${l10n.overviewLawn}: $worldName$customSuffix',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (hasLifeSupportSystem && lifeSupportCapacity != null)
                          ResourceChip(
                            icon: Icons.battery_charging_full,
                            label: '$lifeSupportCapacity',
                            color: Colors.lightBlueAccent,
                            tooltip: l10n
                                .moduleTitle_MoonLifeSupportSystemProperties,
                          )
                        else
                          _buildSummaryAssetChip(
                            iconId: 'sun',
                            label: '$startingSun',
                            color: Colors.orange,
                            tooltip: l10n.startingSun,
                          ),
                        _buildSummaryAssetChip(
                          iconId: 'plantfood',
                          label: '$pfCount',
                          color: Colors.greenAccent,
                          tooltip: _p(
                            'previewStartingPlantFood',
                            'Starting Plant Food',
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                if (constraints.maxWidth > 500) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content),
                      if (stageIconPath != null) ...[
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.05),
                          child: AssetImageWidget(
                            assetPath: stageIconPath,
                            width: 84,
                            height: 84,
                          ),
                        ),
                      ],
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stageIconPath != null) ...[
                      Center(
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.05),
                          child: AssetImageWidget(
                            assetPath: stageIconPath,
                            width: 84,
                            height: 84,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    content,
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ResourceChip(
                  icon: sunBombsActive
                      ? Icons.wb_iridescent
                      : (skySunEnabled
                            ? Icons.wb_sunny_outlined
                            : Icons.sunny_snowing),
                  label: isDesktop
                      ? ''
                      : (sunBombsActive ? '!' : (skySunEnabled ? '✓' : '✕')),
                  color: sunBombsActive
                      ? Colors.deepPurpleAccent
                      : (skySunEnabled
                            ? Colors.lightBlueAccent
                            : Colors.redAccent),
                  tooltip: sunBombsActive
                      ? l10n.sunBombFalling
                      : (skySunEnabled
                            ? l10n.sunDroppingActive
                            : l10n.sunDroppingInactive),
                ),
                if (hasOverwhelm)
                  ResourceChip(
                    icon: Icons.view_column,
                    label: isDesktop ? '' : '5',
                    color: Colors.blueGrey,
                    tooltip: l10n.overwhelmLabel,
                  ),
                if (hasFastEntry)
                  ResourceChip(
                    icon: Icons.fast_forward,
                    label: isDesktop ? '' : '>>',
                    color: Colors.limeAccent,
                    tooltip: l10n.fastEntryLabel,
                  ),
                if (hasWeather)
                  Builder(
                    builder: (context) {
                      final weather = getLevelWeatherType(widget.levelFile);
                      if (weather == null) return const SizedBox.shrink();
                      final icon = switch (weather) {
                        LevelWeatherType.snow => Icons.ac_unit,
                        LevelWeatherType.lightning => Icons.thunderstorm,
                        LevelWeatherType.rain => Icons.cloud,
                      };
                      return ResourceChip(
                        icon: icon,
                        label: '',
                        color: Colors.blueAccent,
                        tooltip: getWeatherLabel(weather, l10n),
                      );
                    },
                  ),
                if (hasSpermWhale)
                  ResourceChip(
                    icon: Icons.waves,
                    label: '',
                    color: Colors.cyanAccent,
                    tooltip: l10n.spermWhaleLabel,
                  ),
                if (hasLunarTerminal)
                  ResourceChip(
                    icon: Icons.precision_manufacturing,
                    label: '',
                    color: Colors.purpleAccent,
                    tooltip: l10n.moduleTitle_LunarTerminalModuleProperties,
                  ),
                if (hasWitch)
                  ResourceChip(
                    icon: Icons.auto_fix_high,
                    label: '',
                    color: Colors.purpleAccent,
                    tooltip: l10n.witchLabel,
                  ),
                if (hasZombieRush && rushTime != null)
                  ResourceChip(
                    icon: Icons.timer_outlined,
                    label: '${rushTime}s',
                    color: Colors.redAccent,
                    tooltip: l10n.zombieRushLabel,
                  ),
              ],
            ),
            if (summaryLegends.isNotEmpty && !isDesktop) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: summaryLegends
                    .map(
                      (leg) => Wrap(
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (leg.icon != null)
                            Icon(
                              leg.icon,
                              size: 12,
                              color: leg.color.withValues(alpha: 0.6),
                            )
                          else if (leg.iconId != null)
                            UniversalIcon(id: leg.iconId!, size: 12),
                          Text(
                            leg.title,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
            if (mowerName != null) ...[
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  Icon(Icons.grass, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.lawnMowerTypeLabel}: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    mowerName,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeedBankCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    PvzObject? sbObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'SeedBankProperties',
    );
    if (sbObj == null) return const SizedBox.shrink();

    final data = sbObj.objData as Map;
    final List<String> presetPlants = [];
    final List<String> blackList = [];
    final List<String> whiteList = [];

    final method = data['SelectionMethod'] ?? 'chooser';
    final plantLevel = data['GlobalLevel'] ?? data['PlantLevel'] ?? 0;
    final isZombieMode = data['ZombieMode'] == true;
    final isReversedFaction = data['SeedPacketType'] == 'UIIZombieSeedPacket';

    void addList(dynamic raw, List<String> out) {
      if (raw is List) {
        for (var e in raw) {
          if (e is String) {
            out.add(_cleanId(e));
          } else if (e is Map) {
            final id =
                e['PlantType'] ??
                e['PlantTypeName'] ??
                e['TypeName'] ??
                e['Type'];
            if (id is String) {
              out.add(_cleanId(id));
            }
          }
        }
      }
    }

    addList(data['PresetPlantList'], presetPlants);
    addList(data['PlantBlackList'] ?? data['BlackList'], blackList);
    addList(data['PlantWhiteList'] ?? data['WhiteList'], whiteList);

    final bool isDataEmpty =
        presetPlants.isEmpty && blackList.isEmpty && whiteList.isEmpty;
    final String levelText = plantLevel == 0
        ? l10n.levelAccount
        : "${l10n.plantLevelLabel}: $plantLevel";

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  _buildSectionTitle(_p('previewSeedBank', 'Seed Bank'), theme),
                ],
              ),
            ),

            if (isDataEmpty) ...[
              if (method == 'preset')
                Text(
                  l10n.overviewSeedChooser,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                )
              else if (!isZombieMode)
                Text(
                  l10n.overviewSeedChooser,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],

            if (presetPlants.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPlantListSection(
                isZombieMode
                    ? l10n.overviewPresetZombies
                    : l10n.overviewPresetPlants,
                presetPlants,
                true,
              ),
            ],
            if (whiteList.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPlantListSection(
                l10n.overviewWhitelist,
                whiteList,
                _whiteListExpanded,
                onToggle: () =>
                    setState(() => _whiteListExpanded = !_whiteListExpanded),
              ),
            ],
            if (blackList.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPlantListSection(
                l10n.overviewBlacklist,
                blackList,
                _blackListExpanded,
                onToggle: () =>
                    setState(() => _blackListExpanded = !_blackListExpanded),
              ),
            ],

            const SizedBox(height: 20),
            if (isZombieMode)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    size: 18,
                    color: Colors.blueAccent,
                  ),
                  Text(
                    "${l10n.reverseZombieFactionTitle}: ",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Icon(
                    isReversedFaction ? Icons.check : Icons.close,
                    size: 18,
                    color: isReversedFaction
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 18,
                    color: Colors.blueAccent,
                  ),
                  Text(
                    levelText,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConveyorCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    PvzObject? convObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ConveyorSeedBankProperties',
    );
    if (convObj == null) return const SizedBox.shrink();

    final data = convObj.objData as Map;
    final List<String> plants = [];
    final List<({String id, int wave, bool isAdd})> changes = [];

    void addList(dynamic raw, List<String> out) {
      if (raw is List) {
        for (var e in raw) {
          if (e is String) {
            out.add(_cleanId(e));
          } else if (e is Map) {
            final id =
                e['PlantType'] ??
                e['PlantTypeName'] ??
                e['TypeName'] ??
                e['Type'];
            if (id is String) {
              out.add(_cleanId(id));
            }
          }
        }
      }
    }

    addList(data['Plants'] ?? data['InitialPlantList'], plants);

    final wm = widget.parsed.waveManager;
    if (wm is WaveManagerData) {
      for (int i = 0; i < wm.waves.length; i++) {
        final waveNum = i + 1;
        for (var rtid in wm.waves[i]) {
          final alias = LevelParser.extractAlias(rtid);
          final obj = widget.parsed.objectMap[alias];
          if (obj != null && obj.objClass == 'ModifyConveyorWaveActionProps') {
            final d = obj.objData;
            if (d is Map) {
              final adds = d['Add'] as List?;
              if (adds != null) {
                for (var e in adds) {
                  if (e is Map) {
                    final t = e['Type'] ?? e['ToolType'];
                    if (t is String) {
                      changes.add((
                        id: _cleanId(t),
                        wave: waveNum,
                        isAdd: true,
                      ));
                    }
                  }
                }
              }
              final removes = d['Remove'] as List?;
              if (removes != null) {
                for (var e in removes) {
                  if (e is Map) {
                    final t = e['Type'] ?? e['ToolType'];
                    if (t is String) {
                      changes.add((
                        id: _cleanId(t),
                        wave: waveNum,
                        isAdd: false,
                      ));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.conveyor_belt,
                    size: 20,
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  _buildSectionTitle(
                    l10n.moduleTitle_ConveyorSeedBankProperties,
                    theme,
                  ),
                ],
              ),
            ),

            if (plants.isNotEmpty)
              _buildPlantListSection(l10n.overviewConveyorPlants, plants, true),

            if (changes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.conveyorChanges,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _legendItem(Colors.green, l10n.willBeAdded, theme),
                  _legendItem(Colors.red, l10n.willBeRemoved, theme),
                  Text(
                    "• ${l10n.waveNumberLegend}",
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.38,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: changes
                    .map(
                      (c) => _ConveyorBadgeIcon(
                        id: c.id,
                        wave: c.wave,
                        isAdd: c.isAdd,
                        levelFile: widget.levelFile,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, ThemeData theme) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantFoodChip(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context)!;
    final label = l10n.totalLabel;
    final tooltip = l10n.totalPlantFoodTooltip;

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              '$label ',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const UniversalIcon(id: 'plantfood', size: 18),
            Text(
              ': $count',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryAssetChip({
    required String iconId,
    required String label,
    required Color color,
    String? tooltip,
  }) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          UniversalIcon(id: iconId, size: 18),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    if (tooltip != null) {
      content = Tooltip(message: tooltip, child: content);
    }
    return content;
  }

  Widget _buildPlantListSection(
    String title,
    List<String> items,
    bool expanded, {
    VoidCallback? onToggle,
    PvzLevelFile? levelFile,
    bool showGridItemIcons = false,
  }) {
    final bool canExpand = items.length > 8;
    final displayItems = (canExpand && !expanded)
        ? items.take(3).toList()
        : items;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle(title, theme),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...displayItems
                .where((id) => id.isNotEmpty)
                .map(
                  (id) => showGridItemIcons
                      ? GridItemIcon(
                          id: id,
                          size: 40,
                          levelFile: levelFile ?? widget.levelFile,
                        )
                      : UniversalIcon(
                          id: id,
                          size: 40,
                          levelFile: levelFile ?? widget.levelFile,
                        ),
                ),
            if (canExpand && onToggle != null)
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  expanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.blueAccent,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.05,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItemListSection(
    String title,
    List<DiscoveredGridItem> items,
    bool expanded, {
    VoidCallback? onToggle,
  }) {
    final canExpand = items.length > 8;
    final displayItems = (canExpand && !expanded)
        ? items.take(3).toList()
        : items;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle(title, theme),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...displayItems
                .where((entry) => entry.id.isNotEmpty)
                .map(
                  (entry) => GridItemIcon(
                    key: ValueKey(
                      'levelOverviewGridItem_${entry.id}_${entry.isDedicatedModuleItem ? 'dedicatedModule' : 'standard'}',
                    ),
                    id: entry.id,
                    size: 40,
                    suppressCustomBadge: entry.isDedicatedModuleItem,
                    levelFile: widget.levelFile,
                  ),
                ),
            if (canExpand && onToggle != null)
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  expanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.blueAccent,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.05,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrePlacedCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final (rows, cols) = getGridDimensions(widget.levelFile);
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    final allGridCategories = _cachedGridCategories;
    final activeTabIndex = _prePlacedTabIndex;

    final List<GridPreviewCategoryOption> gridCategories;
    if (activeTabIndex == 1) {
      gridCategories = allGridCategories
          .where(
            (c) =>
                c.kind == GridPreviewModuleKind.zombies ||
                c.kind == GridPreviewModuleKind.dropShip,
          )
          .toList();
    } else if (activeTabIndex == 2) {
      gridCategories = allGridCategories
          .where(
            (c) =>
                c.kind != GridPreviewModuleKind.zombies &&
                c.kind != GridPreviewModuleKind.dropShip &&
                c.kind != GridPreviewModuleKind.plants &&
                c.kind != GridPreviewModuleKind.zombossMech &&
                c.kind != GridPreviewModuleKind.zomboss &&
                !_isChallengeKind(c.kind),
          )
          .toList();
    } else if (activeTabIndex == 3) {
      gridCategories = allGridCategories
          .where((c) => c.kind == GridPreviewModuleKind.zombossMech)
          .toList();
    } else if (activeTabIndex == 4) {
      gridCategories = allGridCategories
          .where((c) => c.kind == GridPreviewModuleKind.zomboss)
          .toList();
    } else if (activeTabIndex == 5) {
      gridCategories = allGridCategories
          .where((c) => _isChallengeKind(c.kind))
          .toList();
    } else {
      gridCategories = allGridCategories
          .where((c) => c.kind == GridPreviewModuleKind.plants)
          .toList();
    }

    final activeGridKey = _resolveGridItemCategoryKey(gridCategories);

    Color tabColor = const Color(0xFF4A5C61); // Default grey
    if (allGridCategories.isNotEmpty) {
      if (activeTabIndex == 0) {
        tabColor = const Color(0xFF2E7D32);
      } else if (activeTabIndex == 1) {
        tabColor = const Color(0xFF8F76BB);
      } else if (activeTabIndex == 2) {
        tabColor = const Color(0xFFD5925E);
      } else if (activeTabIndex == 3 || activeTabIndex == 4) {
        tabColor = const Color(0xFF8F9E82);
      } else if (activeTabIndex == 5) {
        tabColor = const Color(0xFFD32F2F);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final switcher = allGridCategories.isNotEmpty
                    ? _buildPrePlacedTabSwitcher(l10n, allGridCategories)
                    : const SizedBox.shrink();

                final titlePart = Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.grid_view,
                      size: 20,
                      color: tabColor.withValues(alpha: 0.9),
                    ),
                    _buildSectionTitle(
                      _p('previewPrePlaced', 'Placement'),
                      theme,
                      color: tabColor,
                    ),
                  ],
                );

                if (constraints.maxWidth > 550) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titlePart),
                      const SizedBox(width: 8),
                      Flexible(child: switcher),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titlePart, const SizedBox(height: 8), switcher],
                );
              },
            ),

            const SizedBox(height: 16),

            if (activeTabIndex == 3)
              _buildDedicatedZombossGrid(rows, cols, l10n, theme)
            else if (activeTabIndex == 4)
              _buildDedicatedBossGrid(rows, cols, l10n, theme)
            else if (allGridCategories.isEmpty)
              _buildLawnGrid([], '', activeTabIndex, isEmptyGrid: true)
            else if (activeTabIndex == 1 ||
                activeTabIndex == 2 ||
                activeTabIndex == 5)
              LayoutBuilder(
                builder: (context, constraints) {
                  final kinds = gridCategories
                      .map((c) => c.kind)
                      .toSet()
                      .toList();
                  final showSidebar = kinds.length > 1 || activeTabIndex == 5;
                  final useVerticalLayout = constraints.maxWidth < 450;

                  if (!showSidebar) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubCategoryHeader(
                          gridCategories,
                          activeGridKey,
                          l10n,
                          theme,
                        ),
                        const SizedBox(height: 12),
                        _buildLawnGrid(
                          gridCategories,
                          activeGridKey,
                          activeTabIndex,
                        ),
                        if (activeTabIndex == 1 &&
                            gridCategories.any(
                              (c) => c.kind == GridPreviewModuleKind.dropShip,
                            ))
                          _buildDropShipFooter(
                            gridCategories,
                            activeGridKey,
                            theme,
                            l10n,
                          ),
                        _buildCellContentFooter(theme, l10n),
                      ],
                    );
                  }

                  if (useVerticalLayout) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 120,
                          child: _buildModuleSidebar(
                            gridCategories,
                            activeGridKey,
                            l10n,
                            theme,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSubCategoryHeader(
                          gridCategories,
                          activeGridKey,
                          l10n,
                          theme,
                        ),
                        const SizedBox(height: 12),
                        _buildLawnGrid(
                          gridCategories,
                          activeGridKey,
                          activeTabIndex,
                        ),
                        if (activeTabIndex == 1 &&
                            gridCategories.any(
                              (c) => c.kind == GridPreviewModuleKind.dropShip,
                            ))
                          _buildDropShipFooter(
                            gridCategories,
                            activeGridKey,
                            theme,
                            l10n,
                          ),
                        _buildCellContentFooter(theme, l10n),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 380,
                        child: _buildModuleSidebar(
                          gridCategories,
                          activeGridKey,
                          l10n,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubCategoryHeader(
                              gridCategories,
                              activeGridKey,
                              l10n,
                              theme,
                            ),
                            const SizedBox(height: 12),
                            _buildLawnGrid(
                              gridCategories,
                              activeGridKey,
                              activeTabIndex,
                            ),
                            if (activeTabIndex == 1 &&
                                gridCategories.any(
                                  (c) =>
                                      c.kind == GridPreviewModuleKind.dropShip,
                                ))
                              _buildDropShipFooter(
                                gridCategories,
                                activeGridKey,
                                theme,
                                l10n,
                              ),
                            _buildCellContentFooter(theme, l10n),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            else ...[
              if (activeTabIndex == 0 &&
                  widget.levelFile.objects.any(
                    (o) =>
                        o.objClass == 'FrozenPlantPlacement' ||
                        o.objClass == 'InitialPlantProperties',
                  ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPlantTypeTabSwitcher(l10n),
                ),
              _buildLawnGrid(gridCategories, activeGridKey, activeTabIndex),
              _buildCellContentFooter(theme, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrePlacedTabSwitcher(
    AppLocalizations l10n,
    List<GridPreviewCategoryOption> allCategories,
  ) {
    final hasPlants = allCategories.any(
      (c) => c.kind == GridPreviewModuleKind.plants,
    );
    final hasZombies = allCategories.any(
      (c) =>
          c.kind == GridPreviewModuleKind.zombies ||
          c.kind == GridPreviewModuleKind.dropShip,
    );
    final hasObjects = allCategories.any(
      (c) =>
          c.kind != GridPreviewModuleKind.plants &&
          c.kind != GridPreviewModuleKind.zombies &&
          c.kind != GridPreviewModuleKind.dropShip &&
          c.kind != GridPreviewModuleKind.zombossMech &&
          c.kind != GridPreviewModuleKind.zomboss &&
          !_isChallengeKind(c.kind),
    );
    final hasZomboss = allCategories.any(
      (c) => c.kind == GridPreviewModuleKind.zombossMech,
    );
    final hasBoss = allCategories.any(
      (c) => c.kind == GridPreviewModuleKind.zomboss,
    );
    final hasChallenges = allCategories.any((c) => _isChallengeKind(c.kind));

    final theme = Theme.of(context);

    Widget content = SingleChildScrollView(
      controller: _prePlacedTabScrollController,
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPlants)
                  _tabItem(
                    0,
                    l10n.previewTabPlants,
                    Icons.local_florist,
                    const Color(0xFF2E7D32),
                    theme,
                  ),
                if (hasZombies)
                  _tabItem(
                    1,
                    l10n.previewTabZombies,
                    Icons.emoji_nature,
                    const Color(0xFF42A5F5),
                    theme,
                  ),
                if (hasObjects)
                  _tabItem(
                    2,
                    l10n.previewTabGridItems,
                    Icons.grid_on,
                    const Color(0xFFFFA726),
                    theme,
                  ),
                if (hasZomboss)
                  _tabItem(
                    3,
                    l10n.zomboss,
                    Icons.face,
                    const Color(0xFF8F9E82),
                    theme,
                  ),
                if (hasBoss)
                  _tabItem(
                    4,
                    l10n.boss,
                    Icons.security,
                    const Color(0xFF8F9E82),
                    theme,
                  ),
                if (hasChallenges)
                  _tabItem(
                    5,
                    l10n.starChallenges,
                    Icons.security,
                    const Color(0xFFD32F2F),
                    theme,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    return LocalScrollbarRegion(
      child: Scrollbar(
        key: const ValueKey('prePlacedTabScrollbar'),
        controller: _prePlacedTabScrollController,
        thumbVisibility: true,
        interactive: true,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        child: content,
      ),
    );
  }

  Widget _tabItem(
    int index,
    String label,
    IconData icon,
    Color activeColor,
    ThemeData theme,
  ) {
    final isSelected = _prePlacedTabIndex == index;
    return InkWell(
      onTap: () => setState(() {
        _prePlacedTabIndex = index;
        _selectedX = null;
        _selectedY = null;
      }),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantTypeTabSwitcher(AppLocalizations l10n) {
    final theme = Theme.of(context);
    Widget content = SingleChildScrollView(
      controller: _plantTypeTabScrollController,
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _subTabItem(
                  0,
                  _p('previewRegularPlants', 'Regular Plants'),
                  theme,
                ),
                _subTabItem(
                  1,
                  _p('previewFrozenPlants', 'Frozen Plants'),
                  theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    return LocalScrollbarRegion(
      child: Scrollbar(
        key: const ValueKey('plantTypeTabScrollbar'),
        controller: _plantTypeTabScrollController,
        thumbVisibility: true,
        interactive: true,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        child: content,
      ),
    );
  }

  Widget _subTabItem(int index, String label, ThemeData theme) {
    final isSelected = _plantTypeIndex == index;
    return InkWell(
      onTap: () => setState(() {
        _plantTypeIndex = index;
        _selectedX = null;
        _selectedY = null;
      }),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCellContentFooter(ThemeData theme, AppLocalizations l10n) {
    if (_selectedX == null || _selectedY == null || _selectedIds.isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Text(
            '${l10n.itemListRowFirst} (R${_selectedY! + 1}:C${_selectedX! + 1}):',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: _selectedIds
                .map(
                  (id) => _getIconForId(
                    id,
                    _selectedResourceTabIndex,
                    size: 44,
                    levelFile: widget.levelFile,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSidebar(
    List<GridPreviewCategoryOption> categories,
    String activeKey,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final kinds = categories.map((c) => c.kind).toSet().toList();
    final selectedOption = _selectedGridCategory(categories, activeKey);
    final selectedKind = selectedOption?.kind ?? kinds.first;

    final isMobile =
        theme.platform == TargetPlatform.android ||
        theme.platform == TargetPlatform.iOS;
    final sideColor =
        selectedKind == GridPreviewModuleKind.zombies ||
            selectedKind == GridPreviewModuleKind.dropShip
        ? const Color(0xFF42A5F5)
        : (selectedKind == GridPreviewModuleKind.plants ||
                  _isChallengeKind(selectedKind)
              ? const Color(0xFF2E7D32)
              : const Color(0xFFFFA726));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Scrollbar(
        controller: _sidebarScrollController,
        thumbVisibility: !isMobile,
        interactive: true,
        child: ListView.builder(
          controller: _sidebarScrollController,
          padding: EdgeInsets.zero,
          itemCount: kinds.length,
          itemBuilder: (context, index) {
            final kind = kinds[index];
            final isSelected = kind == selectedKind;
            return InkWell(
              onTap: () {
                final firstOfKind = categories.firstWhere(
                  (c) => c.kind == kind,
                );
                setState(() {
                  _gridItemCategoryKey = firstOfKind.key;
                  _selectedX = null;
                  _selectedY = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                      : null,
                  border: isSelected
                      ? Border(left: BorderSide(color: sideColor, width: 3))
                      : null,
                ),
                child: Text(
                  _getModuleLabel(kind, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubCategoryHeader(
    List<GridPreviewCategoryOption> categories,
    String activeKey,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final selectedOption = _selectedGridCategory(categories, activeKey);
    if (selectedOption == null) return const SizedBox.shrink();

    final optionsForKind = categories
        .where((c) => c.kind == selectedOption.kind)
        .toList();
    if (optionsForKind.length <= 1) return const SizedBox.shrink();

    Widget content = SingleChildScrollView(
      controller: _subCategoryScrollController,
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: optionsForKind.map((option) {
                final isSelected = activeKey == option.key;
                String label = option.wave != null
                    ? l10n.customZombieWaveItem(option.wave!)
                    : option.label;
                return InkWell(
                  onTap: () => setState(() {
                    _gridItemCategoryKey = option.key;
                    _selectedX = null;
                    _selectedY = null;
                  }),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalScrollbarRegion(
            child: Scrollbar(
              key: const ValueKey('gridSubCategoryScrollbar'),
              controller: _subCategoryScrollController,
              thumbVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveGridItemCategoryKey(
    List<GridPreviewCategoryOption> categories,
  ) {
    if (categories.isEmpty) return '';
    if (_gridItemCategoryKey != null &&
        categories.any((c) => c.key == _gridItemCategoryKey)) {
      return _gridItemCategoryKey!;
    }
    return categories.first.key;
  }

  GridPreviewCategoryOption? _selectedGridCategory(
    List<GridPreviewCategoryOption> categories,
    String key,
  ) {
    return categories.firstWhereOrNull((c) => c.key == key);
  }

  Widget _buildBronzeStatueGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final result = <String, List<String>>{};
    final data = readBronzeModuleData(widget.levelFile);
    if (data != null) {
      for (var batch in data.data) {
        for (var item in batch.itemList) {
          String zombieId = switch (item.kind) {
            BronzeStatueKind.strength => 'kongfu_strong_bronze',
            BronzeStatueKind.mage => 'kongfu_magic_bronze',
            BronzeStatueKind.agile => 'kongfu_agile_bronze',
          };
          final key = '${item.mX},${item.mY}';
          result[key] ??= [];
          result[key]!.add(zombieId);
        }
      }
    }
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: result,
      activeTabIndex: 1,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildPowerTileGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final result = <String, List<String>>{};
    final data = readPowerTileModuleData(widget.levelFile);
    if (data != null) {
      for (var tile in data.linkedTiles) {
        String toolId = 'tool_powertile_${tile.group}';
        final key = '${tile.location.mx},${tile.location.my}';
        result[key] ??= [];
        result[key]!.add(toolId);
      }
    }
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: result,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildWarMistGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final data = readWarMistModuleData(widget.levelFile);
    final mistCol = data?.initMistPosX ?? 5;
    final normVal = data?.normValX ?? 0;
    final unitsPerTile = 64;

    double fogFillFraction(int col) {
      final startUnit = mistCol * unitsPerTile;
      final endUnit = startUnit + normVal;
      final colStart = col * unitsPerTile;
      final colEnd = (col + 1) * unitsPerTile;
      final overlapStart = startUnit > colStart ? startUnit : colStart;
      final overlapEnd = endUnit < colEnd ? endUnit : colEnd;
      if (overlapEnd <= overlapStart) return 0;
      return (overlapEnd - overlapStart) / unitsPerTile;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fogColor = isDark
        ? Color.lerp(Colors.white, Colors.grey, 0.45)!.withValues(alpha: 0.72)
        : Color.lerp(
            const Color(0xFFBDBDBD),
            const Color(0xFF616161),
            0.55,
          )!.withValues(alpha: 0.72);

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final fill = fogFillFraction(col);
        if (fill <= 0) return null;
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fill,
            heightFactor: 1,
            child: ColoredBox(color: fogColor),
          ),
        );
      },
    );
  }

  Widget _buildTideGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final tideData = readTideModuleData(widget.levelFile);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      background: tideData != null
          ? Row(
              children: [
                Spacer(
                  flex: (cols - tideData.startingWaveLocation).clamp(0, cols),
                ),
                Expanded(
                  flex: tideData.startingWaveLocation.clamp(0, cols),
                  child: Container(color: Colors.blue.withValues(alpha: 0.25)),
                ),
              ],
            )
          : null,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildSmokeGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final smokeData = readSmokePollutionData(widget.levelFile);
    final result = <String, List<String>>{};
    if (smokeData != null) {
      for (var m in smokeData.smokeManholeList) {
        final key = '${m.gridColumn},${m.gridRow}';
        result[key] ??= [];
        result[key]!.add(smokeData.gridItem);
      }
    }

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: result,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildManholeGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    GridPreviewCategoryOption category,
  ) {
    final pipeData = readManholePipelineData(widget.levelFile);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedIndex = category.index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompositeLawnGrid(
          rows: rows,
          cols: cols,
          style: style,
          cellBuilder: (col, row) {
            final markers = <({bool isStart, int index})>[];
            if (pipeData != null) {
              for (int i = 0; i < pipeData.pipelineList.length; i++) {
                final p = pipeData.pipelineList[i];
                if (p.startX == col && p.startY == row)
                  markers.add((isStart: true, index: i));
                if (p.endX == col && p.endY == row)
                  markers.add((isStart: false, index: i));
              }
            }

            if (markers.isEmpty) return null;

            final isTarget =
                selectedIndex != null &&
                pipeData != null &&
                selectedIndex < pipeData.pipelineList.length &&
                ((pipeData.pipelineList[selectedIndex].startX == col &&
                        pipeData.pipelineList[selectedIndex].startY == row) ||
                    (pipeData.pipelineList[selectedIndex].endX == col &&
                        pipeData.pipelineList[selectedIndex].endY == row));

            return Container(
              color: isTarget
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final m in markers)
                    Opacity(
                      opacity:
                          (selectedIndex == null || selectedIndex == m.index)
                          ? 1.0
                          : 0.4,
                      child: AssetImageWidget(
                        assetPath: m.isStart
                            ? 'assets/images/griditems/steam_down.webp'
                            : 'assets/images/griditems/steam_up.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (selectedIndex != null &&
            pipeData != null &&
            selectedIndex < pipeData.pipelineList.length)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.manholePipelineStartEndFormat(
                pipeData.pipelineList[selectedIndex].startX,
                pipeData.pipelineList[selectedIndex].startY,
                pipeData.pipelineList[selectedIndex].endX,
                pipeData.pipelineList[selectedIndex].endY,
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRenaiGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    GridPreviewCategoryOption category,
  ) {
    final result = <String, List<String>>{};
    final data = readRenaiModuleData(widget.levelFile);
    if (data != null) {
      final statues = category.index == 1
          ? data.statueNightInfos
          : data.statueInfos;
      for (var s in statues) {
        final key = '${s.gridX},${s.gridY}';
        result[key] ??= [];
        result[key]!.add(s.typeName);
      }
    }
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: result,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildTunnelDefendGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final data = readTunnelDefendData(widget.levelFile);
    final selectionColor =
        style.selectionColor ?? Theme.of(context).colorScheme.primary;

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellDecorationBuilder: (col, row, isSelected, isStripe) {
        final hasRoad =
            data?.roads.any((r) => r.gridX == col && r.gridY == row) ?? false;
        if (hasRoad) {
          return BoxDecoration(
            color: isSelected ? selectionColor.withValues(alpha: 0.25) : null,
            border: isSelected
                ? Border.all(color: selectionColor, width: 1.5)
                : const Border(),
          );
        }
        return null;
      },
      cellBuilder: (col, row) {
        final road = data?.roads.firstWhereOrNull(
          (r) => r.gridX == col && r.gridY == row,
        );
        if (road == null) return null;
        final path = 'assets/images/tunnels/${road.img}.webp';
        return AssetImageWidget(
          assetPath: path,
          altCandidates: imageAltCandidates(path),
          fit: BoxFit.fill,
        );
      },
    );
  }

  Widget _buildExpeditionTilesGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    const previewRoads = <(int, int)>[
      (0, 0),
      (1, 0),
      (0, 1),
      (1, 1),
      (5, 1),
      (0, 2),
      (1, 2),
      (5, 2),
      (0, 3),
      (1, 3),
      (5, 3),
      (0, 4),
      (1, 4),
    ];
    const roadAsset = 'assets/images/tunnels/SouDaCheTunnelRoad.webp';
    const blockedAsset = 'assets/images/tunnels/SouDaCheTunnelRoadBlocked.webp';
    final blockedTiles = readExpeditionTilesData(widget.levelFile)?.roads ?? [];

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final hasRoad = previewRoads.contains((col, row));
        final isBlocked = blockedTiles.any(
          (tile) => tile.gridX == col && tile.gridY == row,
        );
        if (!hasRoad && !isBlocked) return null;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (hasRoad)
              AssetImageWidget(
                assetPath: roadAsset,
                altCandidates: imageAltCandidates(roadAsset),
                fit: BoxFit.cover,
              ),
            if (isBlocked)
              AssetImageWidget(
                assetPath: blockedAsset,
                altCandidates: imageAltCandidates(blockedAsset),
                fit: BoxFit.cover,
              ),
          ],
        );
      },
    );
  }

  Widget _buildProtectPlantsGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final pData = readProtectPlantData(widget.levelFile);
    if (pData == null)
      return _buildCompositeLawnGrid(
        rows: rows,
        cols: cols,
        style: style,
        cellBuilder: (col, row) => null,
      );

    final data = <String, List<String>>{};
    for (var p in pData.plants) {
      final key = '${p.gridX},${p.gridY}';
      data[key] ??= [];
      data[key]!.add(_cleanId(p.plantType));
    }

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: data,
      activeTabIndex: 0,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildSeeingStarsGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final sData = readSeeingStarsModuleData(widget.levelFile);
    if (sData == null) {
      return _buildCompositeLawnGrid(
        rows: rows,
        cols: cols,
        style: style,
        cellBuilder: (col, row) => null,
      );
    }

    final data = <String, List<String>>{};
    for (final p in sData.matchPlants) {
      final key = '${p.gridX},${p.gridY}';
      data[key] ??= [];
      data[key]!.add(_cleanId(p.matchTypeName));
    }

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: data,
      activeTabIndex: 0,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildProtectItemsGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final iData = readProtectGridItemData(widget.levelFile);
    if (iData == null)
      return _buildCompositeLawnGrid(
        rows: rows,
        cols: cols,
        style: style,
        cellBuilder: (col, row) => null,
      );

    final data = <String, List<String>>{};
    for (var i in iData.gridItems) {
      final key = '${i.gridX},${i.gridY}';
      data[key] ??= [];
      data[key]!.add(_cleanId(i.gridItemType));
    }

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: data,
      activeTabIndex: 2,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildGulliverGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final data = readGulliverTunnelData(widget.levelFile);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final t = data?.tunnelPlacements.firstWhereOrNull(
          (p) => p.gridX == col && p.gridY == row,
        );
        if (t == null) return null;
        final path = 'assets/images/tunnels/${t.orientation}.webp';
        return AssetImageWidget(
          assetPath: path,
          altCandidates: imageAltCandidates(path),
          fit: BoxFit.contain,
        );
      },
    );
  }

  Widget _buildRoofGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final data = readRoofPropertiesData(widget.levelFile);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        if (data != null &&
            col >= data.flowerPotStartColumn &&
            col <= data.flowerPotEndColumn) {
          return Container(
            color: Colors.brown.withValues(alpha: 0.3),
            child: Center(
              child: GridItemIcon(
                id: 'flowerpot',
                size: 18,
                isGrid: true,
                levelFile: widget.levelFile,
              ),
            ),
          );
        }
        return null;
      },
    );
  }

  Widget _buildLawnGrid(
    List<GridPreviewCategoryOption> gridCategories,
    String activeGridKey,
    int activeTabIndex, {
    bool isEmptyGrid = false,
  }) {
    final GridPreviewModuleKind activeKind;
    final category = _selectedGridCategory(gridCategories, activeGridKey);

    if (isEmptyGrid) {
      activeKind = GridPreviewModuleKind.empty;
    } else if (activeTabIndex == 3) {
      activeKind = GridPreviewModuleKind.zombossMech;
    } else if (activeTabIndex == 4) {
      activeKind = GridPreviewModuleKind.zomboss;
    } else if (category != null) {
      activeKind = category.kind;
    } else {
      activeKind = activeTabIndex == 0
          ? GridPreviewModuleKind.plants
          : (activeTabIndex == 1
                ? GridPreviewModuleKind.zombies
                : GridPreviewModuleKind.common);
    }

    final (rows, cols) = activeKind == GridPreviewModuleKind.expeditionTiles
        ? (5, 9)
        : getGridDimensions(widget.levelFile);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final theme = Theme.of(context);
    final isDesktop = isDesktopPlatform(context);
    final isMobile =
        theme.platform == TargetPlatform.android ||
        theme.platform == TargetPlatform.iOS;
    final style = resolveGridStyle(context, activeKind).copyWith(
      maxWidth: isDesktop
          ? 650
          : (isMobile ? 550 * textScale : 400 * textScale).clamp(300.0, 1000.0),
    );

    if (activeKind != GridPreviewModuleKind.plants &&
        activeKind != GridPreviewModuleKind.zombies &&
        activeKind != GridPreviewModuleKind.common &&
        activeKind != GridPreviewModuleKind.empty) {
      return _buildGridItemCategoryGrid(
        rows,
        cols,
        style,
        category,
        activeTabIndex,
        forcedKind: activeKind,
      );
    }

    final data = _getGridData(activeTabIndex);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: data,
      activeTabIndex: activeTabIndex,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildFlowersGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final fData = readFlowersChallengeData(widget.levelFile);
    if (fData == null) {
      return _buildCompositeLawnGrid(
        rows: rows,
        cols: cols,
        style: style,
        cellBuilder: (col, row) => null,
      );
    }

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: {},
      activeTabIndex: 5,
      cellBuilder: (col, row) => null,
      foreground: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / cols;
          final x = fData.targetDistance * cellWidth;
          return Stack(
            children: [
              Positioned(
                left: x - 2,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(color: Colors.pinkAccent),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridItemCategoryGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    GridPreviewCategoryOption? category,
    int activeTabIndex, {
    GridPreviewModuleKind? forcedKind,
  }) {
    final kind = forcedKind ?? category?.kind ?? GridPreviewModuleKind.common;
    switch (kind) {
      case GridPreviewModuleKind.plants:
        return _buildCompositeLawnGrid(
          rows: rows,
          cols: cols,
          style: style,
          moduleData: _getGridDataForCategory(category!, activeTabIndex),
          activeTabIndex: activeTabIndex,
          cellBuilder: (col, row) => null,
        );
      case GridPreviewModuleKind.zombies:
        return _buildCompositeLawnGrid(
          rows: rows,
          cols: cols,
          style: style,
          moduleData: _getGridDataForCategory(category!, activeTabIndex),
          activeTabIndex: activeTabIndex,
          cellBuilder: (col, row) => null,
        );
      case GridPreviewModuleKind.common:
        return _buildCommonGridItemsPreview(rows, cols, style);
      case GridPreviewModuleKind.piratePlank:
        return _buildPiratePlankGrid(rows, cols, style);
      case GridPreviewModuleKind.railcart:
        return _buildRailcartGrid(rows, cols, style);
      case GridPreviewModuleKind.mechanismPlank:
        return _buildMechanismPlankGrid(rows, cols, style);
      case GridPreviewModuleKind.armrack:
        return _buildArmrackGrid(
          rows,
          cols,
          style,
          category?.wave ?? gridOverrideInitialWave,
        );
      case GridPreviewModuleKind.energyGrid:
        return _buildEnergyGridPreview(
          rows,
          cols,
          style,
          category?.wave ?? gridOverrideInitialWave,
        );
      case GridPreviewModuleKind.lunarMineVein:
        return _buildLunarMineVeinGrid(rows, cols, style, category?.wave ?? 1);
      case GridPreviewModuleKind.radiationMeteor:
        return _buildRadiationMeteorGrid(
          rows,
          cols,
          style,
          category?.wave ?? 1,
        );
      case GridPreviewModuleKind.gladiatorRow:
        return _buildGladiatorGrid(rows, cols, style, category?.index ?? 0);
      case GridPreviewModuleKind.bronzeStatue:
        return _buildBronzeStatueGrid(rows, cols, style);
      case GridPreviewModuleKind.powerTile:
        return _buildPowerTileGrid(rows, cols, style);
      case GridPreviewModuleKind.fogSystem:
        return _buildWarMistGrid(rows, cols, style);
      case GridPreviewModuleKind.tideSystem:
        return _buildTideGrid(rows, cols, style);
      case GridPreviewModuleKind.smokePollution:
        return _buildSmokeGrid(rows, cols, style);
      case GridPreviewModuleKind.manholePipeline:
        return _buildManholeGrid(rows, cols, style, category!);
      case GridPreviewModuleKind.renaissance:
        return _buildRenaiGrid(rows, cols, style, category!);
      case GridPreviewModuleKind.roofProperties:
        return _buildRoofGrid(rows, cols, style);
      case GridPreviewModuleKind.tunnelDefend:
        return _buildTunnelDefendGrid(rows, cols, style);
      case GridPreviewModuleKind.expeditionTiles:
        return _buildExpeditionTilesGrid(rows, cols, style);
      case GridPreviewModuleKind.gulliverTunnel:
        return _buildGulliverGrid(rows, cols, style);
      case GridPreviewModuleKind.protectPlants:
        return _buildProtectPlantsGrid(rows, cols, style);
      case GridPreviewModuleKind.seeingStars:
        return _buildSeeingStarsGrid(rows, cols, style);
      case GridPreviewModuleKind.protectItems:
        return _buildProtectItemsGrid(rows, cols, style);
      case GridPreviewModuleKind.flowers:
        return _buildFlowersGrid(rows, cols, style);
      case GridPreviewModuleKind.vases:
        return _buildVasesGrid(rows, cols, style);
      case GridPreviewModuleKind.explosiveBarrels:
        return _buildExplosiveBarrelsGrid(rows, cols, style);
      case GridPreviewModuleKind.portalFight:
        return _buildPassageGrid(rows, cols, style);
      case GridPreviewModuleKind.bowlingFoulLine:
        return _buildBowlingFoulLineGrid(rows, cols, style);
      case GridPreviewModuleKind.moldColony:
        return _buildMoldColonyGrid(rows, cols, style);
      case GridPreviewModuleKind.dropShip:
        return _buildDropShipGrid(rows, cols, style, category!);
      case GridPreviewModuleKind.zombossMech:
        return _buildZombossMechGrid(rows, cols, style);
      case GridPreviewModuleKind.zomboss:
        return _buildBossGrid(rows, cols, style);
      case GridPreviewModuleKind.empty:
        return _buildCompositeLawnGrid(
          rows: rows,
          cols: cols,
          style: style,
          moduleData: {},
          activeTabIndex: 2,
          cellBuilder: (col, row) => null,
        );
    }
  }

  Map<String, List<String>> _getGridDataForCategory(
    GridPreviewCategoryOption category,
    int activeTabIndex,
  ) {
    if (category.kind == GridPreviewModuleKind.plants) {
      return _getPlacementGridData(0);
    } else if (category.kind == GridPreviewModuleKind.zombies) {
      return _getPlacementGridData(1);
    }
    return {};
  }

  Widget _buildVasesGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final data = readVaseBreakerData(widget.levelFile);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = isDesktopPlatform(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompositeLawnGrid(
          rows: rows,
          cols: cols,
          style: style,
          cellBuilder: (col, row) {
            if (data == null) return null;
            final isBlacklisted = data.gridSquareBlacklist.any(
              (loc) => loc.x == col && loc.y == row,
            );
            if (isBlacklisted) {
              return Container(
                color: Colors.red.withValues(alpha: 0.45),
                child: const Center(
                  child: Icon(Icons.block, color: Colors.white, size: 16),
                ),
              );
            }
            if (col >= data.minColumnIndex && col <= data.maxColumnIndex) {
              return Container(color: Colors.green.withValues(alpha: 0.35));
            }
            return null;
          },
        ),
        if (data != null && data.vases.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            l10n.contentsLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final Map<String, int> counts = {};
              for (var v in data.vases) {
                final id =
                    v.plantTypeName ??
                    v.zombieTypeName ??
                    v.collectableTypeName;
                if (id != null) counts[id] = (counts[id] ?? 0) + v.count;
              }
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: counts.entries
                    .map(
                      (e) => Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          UniversalIcon(id: e.key, size: 36),
                          Text(
                            'x${e.value}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
            },
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    _legendDot(Colors.green),
                    Text(
                      l10n.vaseSpawnArea,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    _legendDot(Colors.red),
                    Text(
                      l10n.overviewBlacklist,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildExplosiveBarrelsGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final data = readBombPropertiesData(widget.levelFile);
    return ExplosiveBarrelsPreviewGrid(
      rows: rows,
      cols: cols,
      style: style,
      fuseLengths: data?.fuseLengths ?? const [],
      selectedX: _selectedX,
      selectedY: _selectedY,
      onCellTap: (col, row) {
        setState(() {
          if (_selectedX == col && _selectedY == row) {
            _selectedX = null;
            _selectedY = null;
          } else {
            _selectedX = col;
            _selectedY = row;
          }
          _selectedIds = [];
        });
      },
    );
  }

  Widget _buildPassageGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final data = readPassageModuleData(widget.levelFile);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        if (data != null && col >= data.gridXMin && col <= data.gridXMax) {
          return Container(color: Colors.orange.withValues(alpha: 0.45));
        }
        return null;
      },
    );
  }

  Widget _buildBowlingFoulLineGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final data = readBowlingMinigameData(widget.levelFile);
    final isDeepSeaLawn = LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
    final minFoulLine = isDeepSeaLawn ? -1 : 0;
    final maxFoulLine = isDeepSeaLawn ? cols - 1 : cols;
    final foulLine = (data?.bowlingFoulLine ?? 2)
        .clamp(minFoulLine, maxFoulLine)
        .toInt();
    final previewBoundary = foulLine + (isDeepSeaLawn ? 1 : 0);

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) => null,
      foreground: LayoutBuilder(
        builder: (context, constraints) {
          const lineWidth = 4.0;
          final boundaryX = constraints.maxWidth * previewBoundary / cols;
          final lineLeft = (boundaryX - lineWidth / 2)
              .clamp(0.0, constraints.maxWidth - lineWidth)
              .toDouble();
          return Stack(
            children: [
              Positioned(
                left: lineLeft,
                top: 0,
                bottom: 0,
                width: lineWidth,
                child: const ColoredBox(color: Colors.red),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoldColonyGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final layout = readMoldColonyLayoutData(
      widget.levelFile,
    )?.normalized(rows: rows, columns: cols);
    final data = <String, List<String>>{};
    if (layout != null) {
      for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
          if (layout.values[row][col] != 0) {
            data['$col,$row'] = const ['fake_mold'];
          }
        }
      }
    }
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: data,
      activeTabIndex: 2,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildOakArcheryCard(ThemeData theme, AppLocalizations l10n) {
    final obj = findModuleObject(widget.levelFile, 'OakTrainProperties');
    if (obj?.objData is! Map) return const SizedBox.shrink();
    final data = OakTrainPropertiesData.fromJson(
      Map<String, dynamic>.from(obj!.objData as Map),
    );
    return Card(
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(l10n.moduleTitle_OakTrainProperties, theme),
            const SizedBox(height: 12),
            OakTrainWarnings(levelFile: widget.levelFile),
            for (final field in oakArcheryFields(data, l10n))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/${field.icon}',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${field.label}: ${field.value}')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveGeneratorCard(ThemeData theme, AppLocalizations l10n) {
    final data = WaveGeneratorLevelUtils.readData(widget.levelFile);
    if (data == null) return const SizedBox.shrink();
    return Card(
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(l10n.moduleTitle_WaveGeneratorProperties, theme),
            const SizedBox(height: 12),
            for (final line in waveGeneratorPreviewLines(
              data,
              l10n,
              (id) => ZombieDisplayUtils.localizedName(
                context,
                typeOrRtid: id,
                levelFile: widget.levelFile,
              ),
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final zombies = _cachedZombies;
    final gridItems = _cachedGridItems;
    final events = _cachedEvents;
    final totalPfCount = _cachedTotalPfCount;

    bool hasWaveModule = widget.levelFile.objects.any(
      (o) =>
          o.objClass == 'WaveManagerModuleProperties' ||
          o.objClass == 'WaveManagerProperties' ||
          o.objClass == 'WaveGeneratorProperties',
    );

    if (!hasWaveModule &&
        zombies.isEmpty &&
        gridItems.isEmpty &&
        events.isEmpty)
      return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final titlePart = Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.layers_outlined,
                        size: 20,
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                      ),
                      _buildSectionTitle(
                        _p('previewLevelContent', 'Level Content'),
                        theme,
                      ),
                    ],
                  );

                  if (constraints.maxWidth > 500) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: titlePart),
                        if (totalPfCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: _buildPlantFoodChip(context, totalPfCount),
                          ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titlePart,
                      if (totalPfCount > 0) ...[
                        const SizedBox(height: 8),
                        _buildPlantFoodChip(context, totalPfCount),
                      ],
                    ],
                  );
                },
              ),
            ),
            if (zombies.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPlantListSection(
                l10n.allZombiesInLevel,
                zombies,
                _encounterZombiesExpanded,
                onToggle: () => setState(
                  () => _encounterZombiesExpanded = !_encounterZombiesExpanded,
                ),
                levelFile: widget.levelFile,
              ),
            ],
            if (gridItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildGridItemListSection(
                l10n.allObjectsInLevel,
                gridItems,
                _encounterGridItemsExpanded,
                onToggle: () => setState(
                  () => _encounterGridItemsExpanded =
                      !_encounterGridItemsExpanded,
                ),
              ),
            ],
            if (events.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildChipListSection(
                l10n.allEventsInLevel,
                events,
                _encounterEventsExpanded,
                onToggle: () => setState(
                  () => _encounterEventsExpanded = !_encounterEventsExpanded,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCopycatCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final data = readCopycatsModuleData(widget.levelFile);
    if (data == null) return const SizedBox.shrink();

    final title = l10n.guessWhoIAm;
    final blackListTitle = l10n.overviewPlantBlacklist;
    final whiteListTitle = l10n.overviewZombieWhitelist;
    final weightLabel = l10n.zombieWeight;
    final levelLabel = l10n.plantLevelLabel;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.question_mark,
                    size: 20,
                    color: const Color(0xFF4AC380),
                  ),
                  _buildSectionTitle(
                    title,
                    theme,
                    color: const Color(0xFF4AC380),
                  ),
                ],
              ),
            ),
            if (data.plantBlackList.isNotEmpty) ...[
              _buildPlantListSection(
                blackListTitle,
                data.plantBlackList,
                _copycatBlackListExpanded,
                onToggle: () => setState(
                  () => _copycatBlackListExpanded = !_copycatBlackListExpanded,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (data.zombieWhiteList.isNotEmpty) ...[
              _buildPlantListSection(
                whiteListTitle,
                data.zombieWhiteList,
                _copycatWhiteListExpanded,
                onToggle: () => setState(
                  () => _copycatWhiteListExpanded = !_copycatWhiteListExpanded,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _buildInfoChip(
                  icon: Icons.person,
                  label: '$weightLabel: ${(data.zombieWeight * 100).toInt()}%',
                  color: Colors.orange,
                  theme: theme,
                ),
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: '$levelLabel: ${data.spawnPlantLevel}',
                  color: Colors.blueAccent,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeingStarsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final data = readSeeingStarsModuleData(widget.levelFile);
    if (data == null) return const SizedBox.shrink();
    final (rows, cols) = getGridDimensions(widget.levelFile);

    const accent = Color(0xFFD5A021);
    final plantIds = data.matchPlants
        .map((p) => _cleanId(p.matchTypeName))
        .where((id) => id.isNotEmpty)
        .toList();
    final settlement =
        data.settlementDuration == data.settlementDuration.roundToDouble()
        ? data.settlementDuration.toInt().toString()
        : data.settlementDuration.toString();

    return Container(
      key: const ValueKey('overviewSeeingStarsCard'),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Icon(Icons.star, size: 20, color: accent),
                  _buildSectionTitle(
                    l10n.moduleTitle_PVZ1SeeingStarsModuleProperties,
                    theme,
                    color: accent,
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _buildInfoChip(
                  icon: Icons.loop,
                  label:
                      '${l10n.seeingStarsCycleWaveLabel}: ${data.cycleIndex}',
                  color: accent,
                  theme: theme,
                ),
                _buildInfoChip(
                  icon: Icons.timer_outlined,
                  label: '${l10n.seeingStarsSettlementLabel}: ${settlement}s',
                  color: accent,
                  theme: theme,
                ),
              ],
            ),
            if (plantIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPlantListSection(
                l10n.seeingStarsMatchPlants,
                plantIds,
                _seeingStarsPlantsExpanded,
                onToggle: () => setState(
                  () =>
                      _seeingStarsPlantsExpanded = !_seeingStarsPlantsExpanded,
                ),
              ),
            ],
            const SizedBox(height: 16),
            KeyedSubtree(
              key: const ValueKey('overviewSeeingStarsGrid'),
              child: _buildSeeingStarsGrid(
                rows,
                cols,
                resolveGridStyle(context, GridPreviewModuleKind.seeingStars),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleHandedCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final moduleObject = widget.levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'SingleHandedProperties',
    );
    final tutorialObject = widget.levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'IntroSingleHandedProperties',
    );
    if (moduleObject == null && tutorialObject == null) {
      return const SizedBox.shrink();
    }

    SingleHandedPropertiesData? data;
    IntroSingleHandedPropertiesData? tutorialData;
    try {
      if (moduleObject?.objData is Map) {
        data = SingleHandedPropertiesData.fromJson(
          Map<String, dynamic>.from(moduleObject!.objData as Map),
        );
      }
    } catch (_) {}
    try {
      if (tutorialObject?.objData is Map) {
        tutorialData = IntroSingleHandedPropertiesData.fromJson(
          Map<String, dynamic>.from(tutorialObject!.objData as Map),
        );
      }
    } catch (_) {}
    if (data == null && tutorialData == null) {
      return const SizedBox.shrink();
    }

    const accent = Color(0xFF29B6F6);
    final title = data != null
        ? l10n.moduleTitle_SingleHandedProperties
        : l10n.moduleTitle_IntroSingleHandedProperties;

    return Container(
      key: const ValueKey('singleHandedOverviewCard'),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Icon(Icons.sledding, size: 20, color: accent),
                  _buildSectionTitle(title, theme, color: accent),
                ],
              ),
            ),
            if (data != null) ...[
              _buildSubSectionTitle(
                l10n.singleHandedOverviewBasicConfiguration,
                theme,
              ),
              const SizedBox(height: 10),
              _buildSingleHandedPlantPath(context, data, theme, l10n),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildInfoChip(
                    icon: Icons.rocket_launch,
                    label:
                        '${l10n.singleHandedMissileCount}: ${data.missileCount}',
                    color: Colors.deepOrangeAccent,
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.schedule,
                    label:
                        '${l10n.singleHandedMissileInterval}: ${_formatSingleHandedNumber(data.missileInterval)}',
                    color: Colors.orangeAccent,
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.notification_important_outlined,
                    label:
                        '${l10n.singleHandedWarningTime}: ${_formatSingleHandedNumber(data.rocketHitTime)}',
                    color: Colors.amber,
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.speed,
                    label:
                        '${l10n.singleHandedRocketSpeed}: ${_formatSingleHandedNumber(data.rocketSpeed)}',
                    color: Colors.lightBlueAccent,
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.directions_run,
                    label:
                        '${l10n.singleHandedZombieSpeedMultiplier}: x${_formatSingleHandedNumber(data.zombiesWalkSpeed)}',
                    color: Colors.purpleAccent,
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.favorite_outline,
                    label:
                        '${l10n.singleHandedZombieHealthMultiplier}: x${_formatSingleHandedNumber(data.zombiesHitpointsPercent)}',
                    color: Colors.redAccent,
                    theme: theme,
                  ),
                ],
              ),
              if (data.specialWaveDatas.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSubSectionTitle(l10n.singleHandedSpecialWaves, theme),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.specialWaveDatas.map((wave) {
                    final subtitle = l10n.singleHandedSpecialWaveSubtitle(
                      _formatSingleHandedNumber(wave.zombiesWalkSpeed),
                      _formatSingleHandedNumber(wave.zombiesHitpointsPercent),
                    );
                    final healthBar = wave.showHealthBar
                        ? l10n.singleHandedHealthBarEnabled
                        : l10n.singleHandedHealthBarDisabled;
                    return Tooltip(
                      message: '$subtitle\n$healthBar',
                      child: Chip(
                        avatar: Icon(
                          wave.showHealthBar
                              ? Icons.monitor_heart_outlined
                              : Icons.favorite_border,
                          size: 17,
                          color: accent,
                        ),
                        label: Text(
                          '${l10n.singleHandedWaveNumber(wave.wave)} · $subtitle',
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
            if (tutorialData != null) ...[
              if (data != null) ...[
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildSubSectionTitle(
                  l10n.moduleTitle_IntroSingleHandedProperties,
                  theme,
                ),
                const SizedBox(height: 10),
              ],
              _buildInfoChip(
                icon: Icons.school_outlined,
                label:
                    '${l10n.singleHandedTutorialWaveForStartRocket}: ${tutorialData.waveForStartRocket}',
                color: Colors.greenAccent,
                theme: theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSingleHandedPlantPath(
    BuildContext context,
    SingleHandedPropertiesData data,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final stages = <({String id, String detail})>[
      (
        id: data.initWeapon,
        detail: l10n.singleHandedInitialPlantSubtitle(
          _formatSingleHandedNumber(data.initWeaponLaunchTimePercent),
        ),
      ),
      ...data.dropWeaponDatas.map(
        (entry) => (
          id: entry.weaponName,
          detail: l10n.singleHandedUpgradePlantSubtitle(
            entry.killCount,
            _formatSingleHandedNumber(entry.launchTimePercent),
          ),
        ),
      ),
    ].where((stage) => stage.id.isNotEmpty).toList(growable: false);

    return HorizontalTagScroller(
      key: const ValueKey('singleHandedPlantPathScroller'),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
      children: [
        Row(
          key: const ValueKey('singleHandedPlantUpgradePath'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < stages.length; index++) ...[
              Tooltip(
                message: stages[index].detail,
                child: PlantIcon(
                  key: ValueKey(
                    'singleHandedPlantStage_${stages[index].id}_$index',
                  ),
                  id: stages[index].id,
                  size: 48,
                ),
              ),
              if (index != stages.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    key: ValueKey('singleHandedUpgradeArrow_$index'),
                    size: 22,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatSingleHandedNumber(num value) {
    final number = value.toDouble();
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toString();
  }

  Widget _buildSeedRainCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final data = readSeedRainData(widget.levelFile);
    if (data == null) return const SizedBox.shrink();

    final title = l10n.seedRain;
    final contentTitle = l10n.rainContent;

    final items = data.seedRains
        .map((e) {
          if (e.plantTypeName != null && e.plantTypeName!.isNotEmpty)
            return _cleanId(e.plantTypeName!);
          if (e.zombieTypeName != null && e.zombieTypeName!.isNotEmpty)
            return _cleanId(e.zombieTypeName!);
          if (e.seedRainType == 2) return 'tool_plantfood';
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.umbrella,
                    size: 20,
                    color: const Color(0xFF4CAF50),
                  ),
                  _buildSectionTitle(
                    title,
                    theme,
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
            _buildPlantListSection(
              contentTitle,
              items,
              _seedRainExpanded,
              onToggle: () =>
                  setState(() => _seedRainExpanded = !_seedRainExpanded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeianWindCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final data = readHeianWindData(widget.levelFile);
    if (data == null || data.waveWindInfos.isEmpty)
      return const SizedBox.shrink();

    final title = l10n.heianWind;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Icon(Icons.air, size: 20, color: const Color(0xFF607D8B)),
                  _buildSectionTitle(
                    title,
                    theme,
                    color: const Color(0xFF607D8B),
                  ),
                ],
              ),
            ),
            ...data.waveWindInfos.map((info) {
              final wave = info.waveNumber + 1;
              final rows = info.windInfos
                  .map((w) => w.row == -1 ? l10n.all : l10n.rowN(w.row + 1))
                  .join(', ');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.air, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.customZombieWaveItem(wave)}: $rows',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String? _getEventTitle(String? objClass, AppLocalizations l10n) {
    if (objClass == null) return null;
    return EventSelectionScreen.resolveEventTitleByObjClass(
      context,
      objClass,
      l10n,
    ).replaceAll('WaveActionProps', '');
  }

  Widget _buildChipListSection(
    String title,
    List<String> items,
    bool expanded, {
    VoidCallback? onToggle,
  }) {
    final bool canExpand = items.length > 8;
    final displayItems = (canExpand && !expanded)
        ? items.take(5).toList()
        : items;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final eventTitles = displayItems
        .map((e) => _getEventTitle(e, l10n))
        .whereType<String>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle(title, theme),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...eventTitles.map(
              (title) => Chip(
                label: Text(title, style: const TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (canExpand && onToggle != null)
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  expanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.blueAccent,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.05,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<({String key, String title, String description, IconData icon})>
  _collectActiveModules(BuildContext context) {
    final levelDef = widget.parsed.levelDef;
    if (levelDef == null) return const [];

    final available = ModuleRegistry.getAllModules();
    final seen = <String>{};
    final result =
        <({String key, String title, String description, IconData icon})>[];

    for (final rawRtid in levelDef.modules) {
      final info = RtidParser.parse(rawRtid);
      if (info == null) continue;
      final key = '${info.source}:${info.alias}';
      if (!seen.add(key)) continue;

      String? objClass;
      if (info.source == 'CurrentLevel') {
        objClass = widget.parsed.objectMap[info.alias]?.objClass;
      } else {
        objClass = ReferenceRepository.instance.getObjClass(info.alias);
      }

      ModuleMetadata metadata;
      if (objClass != null && objClass.isNotEmpty) {
        metadata = ModuleRegistry.getMetadataForAlias(info.alias, objClass);
      } else {
        metadata =
            available.firstWhereOrNull(
              (item) =>
                  item.defaultAlias == info.alias &&
                  item.defaultSource == info.source,
            ) ??
            ModuleRegistry.getMetadata(info.alias);
      }

      final isKnown = metadata.titleKey != ModuleRegistry.defaultMetadataKey;
      final title = isKnown ? metadata.getTitle(context) : info.alias;
      final description = isKnown
          ? metadata.getDescription(context)
          : info.alias;
      result.add((
        key: key,
        title: title,
        description: description,
        icon: metadata.icon,
      ));
    }

    return result;
  }

  Widget _buildModulesCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final activeModules = _collectActiveModules(context);
    final starChallengeObjs = widget.levelFile.objects.where(
      (o) => o.objClass == 'StarChallengeModuleProperties',
    );
    final List<
      ({
        String title,
        String objClass,
        Map<String, dynamic> objData,
        IconData icon,
      })
    >
    featureInfos = [];

    for (var obj in starChallengeObjs) {
      final data = StarChallengeModuleData.fromJson(obj.objData);
      if (data.challenges.isNotEmpty) {
        for (var starList in data.challenges) {
          if (starList is! List) continue;
          for (var rtid in starList) {
            if (rtid is! String) continue;
            final info = RtidParser.parse(rtid);
            final alias = info?.alias ?? rtid;
            final isLocal = info?.source == 'CurrentLevel';

            String? objClass;
            Map<String, dynamic>? objData;

            if (isLocal) {
              final localObj = widget.levelFile.objects.firstWhereOrNull(
                (o) => o.aliases?.contains(alias) == true,
              );
              objClass = localObj?.objClass;
              if (localObj?.objData is Map) {
                objData = Map<String, dynamic>.from(localObj!.objData as Map);
              }
            } else {
              objClass = ReferenceRepository.instance.getObjClass(alias);
              final refObj = ReferenceRepository.instance.objectForAlias(alias);
              if (refObj?.objData is Map) {
                objData = Map<String, dynamic>.from(refObj!.objData as Map);
              }
            }

            if (objClass != null && objClass.isNotEmpty) {
              featureInfos.add((
                title: ChallengeRepository.localizedTitle(context, objClass),
                objClass: objClass,
                objData: objData ?? {},
                icon: ChallengeRepository.getInfo(objClass)?.icon ?? Icons.star,
              ));
            } else {
              featureInfos.add((
                title: alias,
                objClass: 'Unknown',
                objData: {},
                icon: Icons.star,
              ));
            }
          }
        }
      }
    }

    final otherModuleClasses = {
      'ProtectThePlantChallengeProperties': (
        l10n.moduleTitle_ProtectThePlantChallengeProperties,
        Icons.security,
      ),
      'ProtectTheGridItemChallengeProperties': (
        l10n.moduleTitle_ProtectTheGridItemChallengeProperties,
        Icons.security,
      ),
      'LastStandMinigameProperties': (
        l10n.moduleTitle_LastStandMinigameProperties,
        Icons.shield,
      ),
    };

    for (var entry in otherModuleClasses.entries) {
      final obj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.objClass == entry.key,
      );
      if (obj != null) {
        featureInfos.add((
          title: entry.value.$1,
          objClass: entry.key,
          objData: obj.objData is Map
              ? Map<String, dynamic>.from(obj.objData as Map)
              : {},
          icon: entry.value.$2,
        ));
      }
    }

    final List<({String title, IconData icon, Color color, String? label})>
    statusIcons = [];

    final maxSunObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelMutatorMaxSunProps',
    );
    if (maxSunObj != null && maxSunObj.objData is Map) {
      final data = LevelMutatorMaxSunPropsData.fromJson(
        Map<String, dynamic>.from(maxSunObj.objData as Map),
      );
      statusIcons.add((
        title: l10n.moduleTitle_LevelMutatorMaxSunProps,
        icon: Icons.wb_sunny_outlined,
        color: Colors.orangeAccent,
        label: '${data.maxSunOverride}',
      ));
    }

    final inflationObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'IncreasedCostModuleProperties',
    );
    if (inflationObj != null && inflationObj.objData is Map) {
      final data = IncreasedCostModulePropertiesData.fromJson(
        Map<String, dynamic>.from(inflationObj.objData as Map),
      );
      statusIcons.add((
        title: l10n.moduleTitle_IncreasedCostModuleProperties,
        icon: Icons.trending_up,
        color: Colors.greenAccent,
        label: '${data.baseCostIncreased}/${data.maxIncreasedCount}',
      ));
    }

    final statusModuleMappings = {
      'LevelScoringModuleProperties': (
        l10n.moduleTitle_LevelScoringModuleProperties,
        Icons.scoreboard,
        Colors.blueGrey,
      ),
      'LevelMutatorRiftTimedSunProps': (
        l10n.moduleTitle_LevelMutatorRiftTimedSunProps,
        Icons.sunny,
        Colors.orange,
      ),
    };

    for (var entry in statusModuleMappings.entries) {
      if (widget.levelFile.objects.any((o) => o.objClass == entry.key)) {
        statusIcons.add((
          title: entry.value.$1,
          icon: entry.value.$2,
          color: entry.value.$3,
          label: null,
        ));
      }
    }

    final riftThemeObjs = widget.levelFile.objects.where(
      (o) => o.objClass == 'RiftThemeDemoModuleProperties',
    );
    final List<({String id, String title})> riftThemes = [];
    for (var obj in riftThemeObjs) {
      final data = RiftThemeDemoModulePropertiesData.fromJson(
        Map<String, dynamic>.from(obj.objData as Map),
      );
      for (var themeId in data.demoRiftThemeName) {
        final key = RiftThemeRepository.nameKey(themeId);
        final localized = ResourceNames.lookup(context, key);
        riftThemes.add((
          id: themeId,
          title: localized != key ? localized : themeId,
        ));
      }
    }

    if (activeModules.isEmpty &&
        featureInfos.isEmpty &&
        riftThemes.isEmpty &&
        statusIcons.isEmpty) {
      return const SizedBox.shrink();
    }

    final canExpandModules = activeModules.length > 10;
    final displayModules = canExpandModules && !_modulesExpanded
        ? activeModules.take(10).toList()
        : activeModules;

    final bool canExpandThemes = riftThemes.length > 8;
    final displayThemes = (canExpandThemes && !_riftThemesExpanded)
        ? riftThemes.take(8).toList()
        : riftThemes;

    final targetChallengeClasses = {
      'ApplyZombieConditionsChallengeProps',
      'PlantDefeatZombieChallengeProps',
      'DefeatZombiesOfTypeChallengeProps',
      'DestroyGridItemsChallengeProps',
    };

    final featuresLabel = _p('previewFeatures', 'Level Features');

    final isDesktop = isDesktopPlatform(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: _OverviewCardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  final titlePart = Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                      ),
                      _buildSectionTitle(featuresLabel, theme),
                    ],
                  );

                  final statusPart = statusIcons.isNotEmpty
                      ? Wrap(
                          spacing: 12,
                          alignment: WrapAlignment.end,
                          children: statusIcons
                              .map(
                                (si) => Tooltip(
                                  message: si.title,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(si.icon, size: 20, color: si.color),
                                      if (si.label != null && !isDesktop)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            si.label!,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: si.color.withValues(
                                                alpha: 0.8,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const SizedBox.shrink();

                  if (isWide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: titlePart),
                        const SizedBox(width: 16),
                        Flexible(child: statusPart),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titlePart,
                      if (statusIcons.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        statusPart,
                      ],
                    ],
                  );
                },
              ),
            ),
            if (statusIcons.isNotEmpty && !isDesktop) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: statusIcons
                    .map(
                      (si) => Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Icon(
                            si.icon,
                            size: 12,
                            color: si.color.withValues(alpha: 0.6),
                          ),
                          Text(
                            si.title,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
            ],
            if (activeModules.isNotEmpty) ...[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildSubSectionTitle(
                    _p('previewActiveModules', 'Active Modules'),
                    theme,
                  ),
                  if (canExpandModules)
                    IconButton(
                      onPressed: () =>
                          setState(() => _modulesExpanded = !_modulesExpanded),
                      icon: Icon(
                        _modulesExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayModules
                    .map(
                      (module) => Tooltip(
                        message: module.description,
                        child: Chip(
                          avatar: Icon(
                            module.icon,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            module.title,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (featureInfos.isNotEmpty) ...[
              if (activeModules.isNotEmpty) const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildSubSectionTitle(
                    l10n.moduleTitle_StarChallengeModuleProperties,
                    theme,
                  ),
                  if (featureInfos.length > 5)
                    IconButton(
                      onPressed: () => setState(
                        () => _challengesExpanded = !_challengesExpanded,
                      ),
                      icon: Icon(
                        _challengesExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blueAccent,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...((_challengesExpanded ? featureInfos : featureInfos.take(3))
                  .map((info) {
                    final isClickable = targetChallengeClasses.contains(
                      info.objClass,
                    );
                    final param = _getChallengeParam(
                      info.objClass,
                      info.objData,
                    );
                    final title =
                        param != null &&
                            info.objClass != 'StarChallengeDisablePlantProps'
                        ? '${info.title} ($param)'
                        : info.title;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              info.icon,
                              size: 16,
                              color: info.icon == Icons.star
                                  ? Colors.amber
                                  : Colors.greenAccent,
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              isClickable
                                  ? InkWell(
                                      onTap: () => _showChallengeDetails(
                                        context,
                                        info.objClass,
                                        info.objData,
                                        info.title,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      title,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                              if (info.objClass ==
                                      'StarChallengeDisablePlantProps' &&
                                  param != null)
                                AssetImageWidget(
                                  assetPath: StarChallengeProfessions.iconAsset(
                                    param,
                                  ),
                                  width: 20,
                                  height: 20,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })),
            ],
            if (riftThemes.isNotEmpty) ...[
              if (activeModules.isNotEmpty || featureInfos.isNotEmpty)
                const SizedBox(height: 20),
              _buildSubSectionTitle(
                l10n.moduleTitle_RiftThemeDemoModuleProperties,
                theme,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...displayThemes.map(
                    (entry) => Chip(
                      avatar: RiftThemeIcon(
                        themeId: entry.id,
                        size: 22,
                        borderRadius: 5,
                      ),
                      label: Text(
                        entry.title,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.blue.withValues(alpha: 0.15),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (canExpandThemes)
                    IconButton(
                      onPressed: () => setState(
                        () => _riftThemesExpanded = !_riftThemesExpanded,
                      ),
                      icon: Icon(
                        _riftThemesExpanded
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: Colors.blueAccent,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showChallengeDetails(
    BuildContext context,
    String objClass,
    Map<String, dynamic> data,
    String title,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final maxW = math.min(
          500.0,
          MediaQuery.sizeOf(dialogContext).width - 48,
        );
        final maxH = MediaQuery.sizeOf(dialogContext).height * 0.75;
        // Avoid AlertDialog: its IntrinsicWidth + Flexible layout can leave
        // ConstrainedBoxes with size MISSING under the app UI scaler.
        return EscapeClosesModal(
          child: Dialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: maxW.clamp(1.0, 500.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxH.clamp(1.0, double.infinity),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildChallengeDetailContent(
                        dialogContext,
                        objClass,
                        data,
                        theme,
                        l10n,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => safeNavPop(dialogContext),
                          child: Text(l10n.ok),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _getChallengeParam(String objClass, Map<String, dynamic> data) {
    // Skip Level Hint
    if (objClass == 'StageIntroductionModuleProperties') return null;

    dynamic val;
    switch (objClass) {
      case 'StarChallengeZombieDistanceProps':
        return null;
      case 'StarChallengeKillZombiesInTimeProps':
        final count = data['ZombiesToKill'];
        final time = data['Time'];
        if (count != null && time != null) {
          return '$count/$time';
        }
        return null;
      case 'StarChallengeSunProducedProps':
        val = data['TargetSun'];
        break;
      case 'StarChallengeSunUsedProps':
        val = data['MaximumSun'];
        break;
      case 'StarChallengeSpendSunHoldoutProps':
        val = data['HoldoutSeconds'];
        break;
      case 'StarChallengePlantsLostProps':
        val = data['MaximumPlantsLost'];
        break;
      case 'StarChallengeSimultaneousPlantsProps':
        val = data['MaximumPlants'];
        break;
      case 'StarChallengeTargetScoreProps':
        val = data['TargetScore'];
        break;
      case 'StarChallengePlantsSurviveProps':
      case 'StarChallengeBlowZombieProps':
      case 'StarChallengeUnfreezePlantsProps':
      case 'StarChallengeSandstormZombieKillProps':
      case 'StarChallengeTentZombieKillProps':
      case 'StarChallengeBufferTileZombieKillProps':
      case 'StarChallengePotionZombieKillProps':
      case 'StarChallengeBarrelPowderZombieKillProps':
      case 'StarChallengeBlowBarrelZombieProps':
      case 'StarChallengeFirecrackerZombieKillProps':
      case 'StarChallengeFireworksZombieKillProps':
        val = data['Count'];
        break;
      case 'StarChallengeZombieSpeedProps':
        val = data['SpeedModifier'];
        break;
      case 'StarChallengeSunReducedProps':
        val = data['sunModifier'];
        break;
      case 'StarChallengeDisablePlantProps':
        val = data['Profession'];
        break;
      case 'ZombiePerfumerChallengeProps':
        val = data['PoisonToClean'];
        break;
      case 'BalletSlipChallengeProps':
        val = data['BalletToSlip'];
        break;
      case 'ZombieExplodenutChallengeProps':
        val = data['MaximumExplode'];
        break;
      case 'ZombieJalapenoChallengeProps':
        val = data['MaximumJalapeno'];
        break;
      case 'RenaiRollerChallengeProps':
        val = data['MaximumPlantsDied'];
        break;
      case 'ZombiePeaChallengeProps':
        val = data['MaximumPlantsHitted'];
        break;
      case 'SteamManholeChallengeProps':
        val = data['MaximumManholeEntered'];
        break;
    }

    if (val == null) return null;
    if (val is double)
      return val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
    return val.toString();
  }

  List<Widget> _buildChallengeDetailContent(
    BuildContext context,
    String objClass,
    Map<String, dynamic> data,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final List<Widget> children = [];

    switch (objClass) {
      case 'ApplyZombieConditionsChallengeProps':
        final count = data['NumZombieConditionsToApply'] ?? 0;
        final burned = data['IncludeBurnedToAsh'] == true;
        final electrified = data['IncludeElectrified'] == true;
        final conditions = data['ConditionToInflict'] as List?;

        children.add(
          _detailItem(
            ChallengeResourceL10n.property(
              context,
              objClass,
              'NumZombieConditionsToApply',
            ),
            '$count',
            theme,
          ),
        );
        children.add(
          _detailSwitch(
            ChallengeResourceL10n.property(
              context,
              objClass,
              'IncludeBurnedToAsh',
            ),
            burned,
            theme,
          ),
        );
        children.add(
          _detailSwitch(
            ChallengeResourceL10n.property(
              context,
              objClass,
              'IncludeElectrified',
            ),
            electrified,
            theme,
          ),
        );

        if (conditions != null && conditions.isNotEmpty) {
          children.add(const SizedBox(height: 12));
          children.add(
            Text(
              ChallengeResourceL10n.property(
                context,
                objClass,
                'ConditionToInflict',
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          );
          children.add(const SizedBox(height: 8));
          for (var c in conditions) {
            final id = c.toString();
            final name = ResourceNames.lookup(context, id);
            children.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name != id ? name : id,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      id,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        break;

      case 'PlantDefeatZombieChallengeProps':
        final count = data['NumZombiesToKill'] ?? 0;
        final plantId = data['PlantTypeName'] as String?;

        children.add(
          _detailItem(
            ChallengeResourceL10n.property(
              context,
              objClass,
              'NumZombiesToKill',
            ),
            '$count',
            theme,
          ),
        );
        if (plantId != null) {
          children.add(const SizedBox(height: 12));
          children.add(
            Text(
              ChallengeResourceL10n.property(
                context,
                objClass,
                'PlantTypeName',
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          );
          children.add(const SizedBox(height: 8));
          children.add(
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: UniversalIcon(id: plantId, size: 48),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ResourceNames.lookup(context, 'plant_$plantId'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        break;

      case 'DefeatZombiesOfTypeChallengeProps':
        final count = data['NumZombiesToKill'] ?? 0;
        final typesToKill = data['TypesToKill'] as Map?;
        final listType = typesToKill?['ListType'] ?? 'whitelist';
        final zombies = typesToKill?['List'] as List?;

        children.add(
          _detailItem(
            ChallengeResourceL10n.property(
              context,
              objClass,
              'NumZombiesToKill',
            ),
            '$count',
            theme,
          ),
        );
        children.add(
          _detailItem(
            ChallengeResourceL10n.property(context, objClass, 'ListType'),
            ChallengeResourceL10n.listTypeOption(context, objClass, listType),
            theme,
          ),
        );

        if (zombies != null && zombies.isNotEmpty) {
          children.add(const SizedBox(height: 12));
          children.add(
            Text(
              ChallengeResourceL10n.property(context, objClass, 'TypesToKill'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          );
          children.add(const SizedBox(height: 8));
          children.add(
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: zombies
                  .map((z) => UniversalIcon(id: z.toString(), size: 44))
                  .toList(),
            ),
          );
        }
        break;

      case 'DestroyGridItemsChallengeProps':
        final count = data['GridItemsToDestroy'] ?? 0;
        final itemType = data['GridItemType'] as String?;

        children.add(
          _detailItem(
            ChallengeResourceL10n.property(
              context,
              objClass,
              'GridItemsToDestroy',
            ),
            '$count',
            theme,
          ),
        );
        if (itemType != null) {
          children.add(const SizedBox(height: 12));
          children.add(
            Text(
              ChallengeResourceL10n.property(context, objClass, 'GridItemType'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          );
          children.add(const SizedBox(height: 8));
          children.add(
            Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: GridItemIcon(
                    id: itemType,
                    size: 40,
                    isGrid: true,
                    levelFile: widget.levelFile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    GridItemRepository.getByTypeName(itemType)?.source ==
                                GridItemSource.custom &&
                            !GridItemRepository.isRecognizedCustomGridItem(
                              itemType,
                              widget.levelFile,
                            )
                        ? itemType
                        : ResourceNames.lookup(context, 'griditem_$itemType'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        break;
    }

    return children;
  }

  Widget _detailItem(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSwitch(String label, bool value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            value ? Icons.toggle_on : Icons.toggle_off,
            color: value
                ? const Color(0xFFD5925E)
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildDedicatedZombossGrid(
    int rows,
    int cols,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final theme = Theme.of(context);
    final isMobile =
        theme.platform == TargetPlatform.android ||
        theme.platform == TargetPlatform.iOS;
    final style = resolveGridStyle(context, GridPreviewModuleKind.zombossMech)
        .copyWith(
          maxWidth: isDesktopPlatform(context)
              ? 650
              : (isMobile ? 550 * textScale : 400 * textScale).clamp(
                  300.0,
                  1000.0,
                ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildZombossMechGrid(rows, cols, style),
        const SizedBox(height: 16),
        _buildZombossDataCard(theme, l10n),
      ],
    );
  }

  Widget _buildDedicatedBossGrid(
    int rows,
    int cols,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final theme = Theme.of(context);
    final isMobile =
        theme.platform == TargetPlatform.android ||
        theme.platform == TargetPlatform.iOS;
    final style = resolveGridStyle(context, GridPreviewModuleKind.zomboss)
        .copyWith(
          maxWidth: isDesktopPlatform(context)
              ? 650
              : (isMobile ? 550 * textScale : 400 * textScale).clamp(
                  300.0,
                  1000.0,
                ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBossGrid(rows, cols, style),
        const SizedBox(height: 16),
        _buildBossDataCard(theme, l10n),
      ],
    );
  }

  Widget _buildZombossMechGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final data = readZombossBattleData(widget.levelFile);
    final reserved = data?.reservedColumnCount ?? 2;
    return _buildReservedGrid(rows, cols, style, reserved, showIcon: false);
  }

  Widget _buildBossGrid(int rows, int cols, LevelPreviewGridStyle style) {
    final data = readZombossLastStandData(widget.levelFile);
    final reserved = data?.reservedColumnCount ?? 3;
    return _buildReservedGrid(rows, cols, style, reserved, showIcon: false);
  }

  Widget _buildZombossDataCard(ThemeData theme, AppLocalizations l10n) {
    final data = readZombossBattleData(widget.levelFile);
    if (data == null) return const SizedBox.shrink();

    final base = ZombossMechRepository.findBaseForVariation(
      data.zombossMechType,
    );
    final catalog = ZombossMechRepository.findCatalogForVariation(
      data.zombossMechType,
    );
    final isCustom = ZombossMechRepository.isCustomVariation(
      data.zombossMechType,
      catalog,
    );

    String displayName = base != null
        ? ResourceNames.lookup(context, base.id)
        : data.zombossMechType;

    if (isCustom) {
      displayName += " (${l10n.customLabel.toLowerCase()})";
    }

    final String? iconPath = base != null
        ? 'assets/images/zombies/${base.icon}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.zombossData,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AssetImageWidget(
                          assetPath: iconPath,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.face,
                          size: 21,
                          color: Colors.white24,
                        ),
                      ),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '${l10n.overviewReservedColumns}: ${data.reservedColumnCount}',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBossDataCard(ThemeData theme, AppLocalizations l10n) {
    final data = readZombossLastStandData(widget.levelFile);
    if (data == null) return const SizedBox.shrink();

    final base = ZombossBattleRepository.findBaseForVariation(
      data.zombossTypeName,
    );
    final isCustom =
        data.zombossTypeName.contains('@CurrentLevel') ||
        data.zombossTypeName.endsWith('_memo');

    String displayName = base != null
        ? ResourceNames.lookup(context, base.id)
        : data.zombossTypeName;

    if (isCustom) {
      displayName += " (${l10n.customLabel.toLowerCase()})";
    }

    final String? iconPath = base != null
        ? 'assets/images/zombies/${base.icon}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.boss,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AssetImageWidget(
                          assetPath: iconPath,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.security,
                          size: 21,
                          color: Colors.white24,
                        ),
                      ),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '${l10n.overviewReservedColumns}: ${data.reservedColumnCount}',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReservedGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    int reservedCount, {
    bool showIcon = true,
  }) {
    final reservedStart = cols - reservedCount;
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        if (col >= reservedStart) {
          return Container(
            color: Colors.red.withValues(alpha: 0.3),
            child: showIcon && col == reservedStart && row == 0
                ? const Center(
                    child: Icon(Icons.lock, color: Colors.redAccent, size: 16),
                  )
                : null,
          );
        }
        return null;
      },
    );
  }

  Widget _buildDropShipGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    GridPreviewCategoryOption category,
  ) {
    final data = readDropShipData(widget.levelFile);
    final waveIndex = category.index;
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        if (data != null &&
            waveIndex != null &&
            waveIndex < data.appearWaves.length) {
          final wave = data.appearWaves[waveIndex];
          if (col >= wave.colRange.min &&
              col <= wave.colRange.max &&
              row >= wave.rowRange.min &&
              row <= wave.rowRange.max) {
            return Container(color: Colors.orange.withValues(alpha: 0.5));
          }
        }
        return null;
      },
    );
  }

  Widget _buildDropShipFooter(
    List<GridPreviewCategoryOption> categories,
    String activeKey,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final category = _selectedGridCategory(categories, activeKey);
    if (category == null || category.kind != GridPreviewModuleKind.dropShip)
      return const SizedBox.shrink();
    final data = readDropShipData(widget.levelFile);
    if (data == null ||
        category.index == null ||
        category.index! >= data.appearWaves.length)
      return const SizedBox.shrink();

    final wave = data.appearWaves[category.index!];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                icon: Icons.person,
                label: '${l10n.impLv}: ${wave.impLv}',
                color: const Color(0xFF4AC380),
                theme: theme,
              ),
              _buildInfoChip(
                icon: Icons.group,
                label: '+${l10n.impsCount(wave.imp)}',
                color: const Color(0xFF42A5F5),
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF4AC380)),
              const SizedBox(width: 8),
              Text(
                l10n.dropShip,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompositeLawnGrid({
    required int rows,
    required int cols,
    required LevelPreviewGridStyle style,
    required Widget? Function(int col, int row) cellBuilder,
    BoxDecoration? Function(int col, int row, bool isSelected, bool isStripe)?
    cellDecorationBuilder,
    BoxDecoration? Function(int col, int row, bool isSelected)?
    foregroundDecorationBuilder,
    Map<String, List<String>>? moduleData,
    int? activeTabIndex,
    Widget? background,
    Widget? foreground,
  }) {
    return LawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      selectedX: _selectedX,
      selectedY: _selectedY,
      background: background,
      foreground: foreground,
      cellDecorationBuilder: cellDecorationBuilder,
      foregroundDecorationBuilder: foregroundDecorationBuilder,
      onCellTap: (col, row) {
        final ids = moduleData?['$col,$row'] ?? [];
        setState(() {
          if (_selectedX == col && _selectedY == row) {
            _selectedX = null;
            _selectedY = null;
            _selectedIds = [];
          } else {
            _selectedX = col;
            _selectedY = row;
            _selectedIds = ids;
            _selectedResourceTabIndex = activeTabIndex ?? 2;
          }
        });
      },
      cellBuilder: (context, col, row) {
        final ids = moduleData?['$col,$row'] ?? [];

        return Stack(
          alignment: Alignment.center,
          children: [
            if (ids.isNotEmpty)
              Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: _getIconForId(
                          ids.first,
                          activeTabIndex ?? 2,
                          isGrid: true,
                          levelFile: widget.levelFile,
                        ),
                      ),
                    ),
                  ),
                  if (ids.length > 1)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellWidth = constraints.maxWidth > 0
                              ? constraints.maxWidth
                              : 50.0;

                          final double badgeScale =
                              (cellWidth / 50.0) * (cellWidth / 50.0);

                          return Transform.scale(
                            scale: badgeScale.clamp(0.1, 1.0),
                            alignment: Alignment.topRight,
                            child: ObjectCountBadge(count: ids.length - 1),
                          );
                        },
                      ),
                    ),
                ],
              ),
            cellBuilder(col, row) ?? const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildPiratePlankGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    final pirateData = readPiratePlankModuleData(widget.levelFile);
    final selectionColor =
        style.selectionColor ?? Theme.of(context).colorScheme.primary;

    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      background: pirateData != null
          ? Column(
              children: List.generate(
                rows,
                (row) => Expanded(
                  child: Row(
                    children: [
                      Spacer(flex: cols - 4),
                      if (pirateData.plankRows.contains(row))
                        Expanded(
                          flex: 4,
                          child: AssetImageWidget(
                            assetPath:
                                'assets/images/others/Pirate_Seas_Planks.webp',
                            fit: BoxFit.fill,
                          ),
                        )
                      else
                        Spacer(flex: 4),
                    ],
                  ),
                ),
              ),
            )
          : null,
      cellDecorationBuilder: (col, row, isSelected, isStripe) {
        final isPlankArea =
            pirateData != null &&
            pirateData.plankRows.contains(row) &&
            col >= cols - 4;

        if (isPlankArea) {
          return BoxDecoration(
            color: isSelected ? selectionColor.withValues(alpha: 0.25) : null,
          );
        }
        return null;
      },
      foregroundDecorationBuilder: (col, row, isSelected) {
        final isPlankArea =
            pirateData != null &&
            pirateData.plankRows.contains(row) &&
            col >= cols - 4;

        if (isPlankArea) {
          final color = isSelected ? selectionColor : style.cellBorderColor;
          final width = isSelected ? 1.5 : 0.5;

          return BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: width),
              bottom: BorderSide(color: color, width: width),
              left: col == (cols - 4)
                  ? BorderSide(color: color, width: width)
                  : BorderSide.none,
              right: col == (cols - 1)
                  ? BorderSide(color: color, width: width)
                  : BorderSide.none,
            ),
          );
        }
        return null;
      },
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildRailcartGrid(int rows, int cols, LevelPreviewGridStyle style) {
    const railsAsset = 'assets/images/others/rails.webp';
    const cartsAsset = 'assets/images/others/railcarts.webp';
    final data = readRailcartModuleData(widget.levelFile);
    if (data == null)
      return _buildCompositeLawnGrid(
        rows: rows,
        cols: cols,
        style: style,
        cellBuilder: (col, row) => null,
      );
    final railsGrid = buildRailcartRailsGrid(data, rows, cols);
    final cartSet = buildRailcartCartSet(data);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final hasRail = railsGrid[col][row];
        final hasCart = cartSet.contains('$col,$row');
        if (!hasRail && !hasCart) return null;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (hasRail)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.85,
                  child: AssetImageWidget(
                    assetPath: railsAsset,
                    altCandidates: imageAltCandidates(railsAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (hasCart)
              Positioned.fill(
                child: Center(
                  child: Transform.scale(
                    scale: 0.9,
                    child: AssetImageWidget(
                      assetPath: cartsAsset,
                      altCandidates: imageAltCandidates(cartsAsset),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMechanismPlankGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    const railsAsset = 'assets/images/others/kongfu_minecart_tracks.webp';
    const cartLeftAsset = 'assets/images/others/kongfu_minecart_left.webp';
    const cartMiddleAsset = 'assets/images/others/kongfu_minecart_middle.webp';
    const cartRightAsset = 'assets/images/others/kongfu_minecart_right.webp';
    final state = buildMechanismPlankPreviewState(
      readMechanismPlankModuleData(widget.levelFile),
    );
    if (state == null)
      return _buildCompositeLawnGrid(
        rows: rows,
        cols: cols,
        style: style,
        cellBuilder: (col, row) => null,
      );
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final hasRail = state.hasRailAt(col, row);
        final hasCart = state.hasCartAt(col, row);
        if (!hasRail && !hasCart) return null;
        final cartAsset = state.cartAssetKind(col) == 'left'
            ? cartLeftAsset
            : (state.cartAssetKind(col) == 'right'
                  ? cartRightAsset
                  : cartMiddleAsset);
        return Stack(
          alignment: Alignment.center,
          children: [
            if (hasRail)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.85,
                  child: AssetImageWidget(
                    assetPath: railsAsset,
                    altCandidates: imageAltCandidates(railsAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (hasCart)
              Positioned.fill(
                child: Center(
                  child: Transform.scale(
                    scale: 0.9,
                    child: AssetImageWidget(
                      assetPath: cartAsset,
                      altCandidates: imageAltCandidates(cartAsset),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildArmrackGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    int wave,
  ) {
    final items = armrackItemsForModuleWave(
      readArmrackModuleData(widget.levelFile),
      wave,
    );
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final item = items.firstWhereOrNull((e) => e.mX == col && e.mY == row);
        if (item == null) return null;
        final asset = armrackIconAsset(item.type);
        final scale = armrackGridScale(item.type);
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth * scale;
            final h = constraints.maxHeight * scale;
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: w,
                height: h,
                child: AssetImageWidget(
                  assetPath: asset,
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnergyGridPreview(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    int wave,
  ) {
    const tileAsset = 'assets/images/griditems/energyGrid.webp';
    final items = energyGridItemsForModuleWave(
      readEnergyGridModuleData(widget.levelFile),
      wave,
    );
    final tileSet = items.map((e) => '${e.mX},${e.mY}').toSet();
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        if (!tileSet.contains('$col,$row')) return null;
        return LayoutBuilder(
          builder: (context, constraints) {
            const scale = 0.92;
            final w = constraints.maxWidth * scale;
            final h = constraints.maxHeight * scale;
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: w,
                height: h,
                child: AssetImageWidget(
                  assetPath: tileAsset,
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommonGridItemsPreview(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
  ) {
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      moduleData: _getCommonGridData(),
      activeTabIndex: 2,
      cellBuilder: (col, row) => null,
    );
  }

  Widget _buildLunarMineVeinGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    int wave,
  ) {
    // Emerging veins on this wave use the ore (active) art.
    final placements =
        readLunarMineVeinModuleData(
          widget.levelFile,
        )?.placements.where((placement) => placement.emergenceWave == wave) ??
        const <LunarMineVeinPlacementData>[];
    final cellAssets = {
      for (final placement in placements)
        '${placement.gridX},${placement.gridY}': lunarMineVeinOreIconAsset(
          placement.typeName,
        ),
    };
    return _buildMoonGridItemPreview(rows, cols, style, cellAssets);
  }

  Widget _buildRadiationMeteorGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    int wave,
  ) {
    const asset = 'assets/images/griditems/radiation_meteor_ore.webp';
    final placements =
        readRadiationMeteorModuleData(
          widget.levelFile,
        )?.spawnSchedule.where((spawn) => spawn.wave == wave) ??
        const <RadiationMeteorSpawnData>[];
    final cellAssets = {
      for (final spawn in placements) '${spawn.gridX},${spawn.gridY}': asset,
    };
    return _buildMoonGridItemPreview(rows, cols, style, cellAssets);
  }

  Widget _buildGladiatorGrid(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    int index,
  ) {
    final data = readGladiatorRowModuleData(widget.levelFile);
    final encounter = data?.encounters.elementAtOrNull(index);
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        if (encounter == null || data?.usesTrophyMode != true) return null;
        final active = row == encounter.row && col >= 2 && col <= 6;
        final trophy = active && col == 4;
        final spawns = encounter.spawns
            .where((s) => row == encounter.row && col == s.gridX && s.count > 0)
            .toList();
        if (!active && spawns.isEmpty) return null;
        return ColoredBox(
          key: ValueKey('overview-gladiator-cell-$col-$row'),
          color: active
              ? (trophy ? Colors.green : Colors.red).withValues(alpha: 0.45)
              : Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (trophy)
                const Padding(
                  padding: EdgeInsets.all(3),
                  child: FittedBox(
                    child: Icon(Icons.emoji_events, color: Colors.white),
                  ),
                ),
              if (spawns.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      for (final spawn in spawns)
                        Expanded(
                          child: GladiatorZombieIcon(
                            type: spawn.zombieType,
                            levelFile: widget.levelFile,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoonGridItemPreview(
    int rows,
    int cols,
    LevelPreviewGridStyle style,
    Map<String, String> cellAssets,
  ) {
    return _buildCompositeLawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      cellBuilder: (col, row) {
        final asset = cellAssets['$col,$row'];
        if (asset == null) return null;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth * 0.92;
            final height = constraints.maxHeight * 0.92;
            return Center(
              child: AssetImageWidget(
                assetPath: asset,
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
            );
          },
        );
      },
    );
  }

  Map<String, List<String>> _getGridData(int activeTabIndex) {
    if (activeTabIndex == 2) return _getCommonGridData();
    return _getPlacementGridData(activeTabIndex);
  }

  Map<String, List<String>> _getCommonGridData() {
    final result = <String, List<String>>{};
    for (var obj in widget.levelFile.objects) {
      if (obj.objClass != 'InitialGridItemProperties') continue;
      final data = obj.objData;
      if (data is Map)
        _addPlacementsToGrid(
          result,
          data['InitialGridItemPlacements'] ?? data['GridItems'],
          'TypeName',
        );
    }

    // Overlay every lunar vein (all waves) as dormant vein art on the
    // Initial grid-items preview; duplicate cells get a count badge.
    final lunarMineData = readLunarMineVeinModuleData(widget.levelFile);
    if (lunarMineData != null) {
      for (final placement in lunarMineData.placements) {
        final key = '${placement.gridX},${placement.gridY}';
        result[key] ??= [];
        result[key]!.add(placement.typeName);
      }
    }
    return result;
  }

  Map<String, List<String>> _getPlacementGridData(int activeTabIndex) {
    final result = <String, List<String>>{};
    for (var obj in widget.levelFile.objects) {
      final data = obj.objData;
      if (data is! Map) continue;
      if (activeTabIndex == 0) {
        if (_plantTypeIndex == 0) {
          if (obj.objClass == 'InitialPlantEntryProperties')
            _addPlacementsToGrid(
              result,
              data['Plants'] ??
                  data['Placements'] ??
                  data['InitialPlantPlacements'] ??
                  data['InitialPlantList'],
              'TypeName',
            );
        } else {
          if (obj.objClass == 'FrozenPlantPlacement') {
            _addPlacementsToGrid(
              result,
              data['InitialPlantPlacements'] ?? data['InitialPlantList'],
              'PlantType',
            );
          } else if (obj.objClass == 'InitialPlantProperties') {
            _addPlacementsToGrid(
              result,
              data['Plants'] ??
                  data['Placements'] ??
                  data['InitialPlantPlacements'] ??
                  data['InitialPlantList'],
              'TypeName',
            );
          }
        }
      } else if (activeTabIndex == 1 &&
          obj.objClass == 'InitialZombieProperties') {
        _addPlacementsToGrid(
          result,
          data['InitialZombiePlacements'] ?? data['Zombies'],
          'TypeName',
        );
      }
    }
    return result;
  }

  void _addPlacementsToGrid(
    Map<String, List<String>> result,
    dynamic list,
    String typeKey,
  ) {
    if (list is! List) return;
    for (var e in list) {
      if (e is! Map) continue;
      final dynamic rawX = e['GridX'] ?? e['gridX'] ?? e['mX'] ?? e['X'];
      final dynamic rawY = e['GridY'] ?? e['gridY'] ?? e['mY'] ?? e['Y'];
      dynamic rawType =
          e[typeKey] ??
          e['TypeName'] ??
          e['PlantType'] ??
          e['ZombieType'] ??
          e['Type'];
      if (rawType == null &&
          e['PlantTypes'] is List &&
          (e['PlantTypes'] as List).isNotEmpty)
        rawType = (e['PlantTypes'] as List).first;
      if (rawX != null && rawY != null && rawType is String) {
        final x = _parseCoord(rawX);
        final y = _parseCoord(rawY);
        final key = '$x,$y';
        result[key] ??= [];
        result[key]!.add(_cleanId(rawType));
      }
    }
  }

  Widget _getIconForId(
    String id,
    int activeTabIndex, {
    double size = 42,
    bool isGrid = false,
    PvzLevelFile? levelFile,
  }) {
    if (activeTabIndex == 2) {
      return GridItemIcon(
        id: id,
        size: size,
        isGrid: isGrid,
        levelFile: levelFile ?? widget.levelFile,
      );
    }
    return UniversalIcon(
      id: id,
      size: size,
      isGrid: isGrid,
      levelFile: levelFile,
    );
  }
}

class _ConveyorBadgeIcon extends StatelessWidget {
  final String id;
  final int wave;
  final bool isAdd;
  final PvzLevelFile? levelFile;
  const _ConveyorBadgeIcon({
    required this.id,
    required this.wave,
    required this.isAdd,
    this.levelFile,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        UniversalIcon(id: id, size: 40, levelFile: levelFile),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isAdd ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
            child: Text(
              '$wave',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
