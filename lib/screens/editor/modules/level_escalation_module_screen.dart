import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_escalation_point_analysis.dart';
import 'package:c_editor/data/level_escalation_runtime.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/wave_point_analysis.dart';
import 'package:c_editor/data/zombie_count_simulation.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/wave_flag_strip.dart';
import 'package:c_editor/widgets/zombie_count_estimate_text.dart';

/// Level escalation module editor (LevelEscalationModuleProperties).
class LevelEscalationModuleScreen extends StatefulWidget {
  const LevelEscalationModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    this.onStructureChanged,
    this.onOpenWaveTimeline,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  /// Called after the screen creates new level objects (e.g. the wave
  /// timeline) so the editor can recalculate available tabs.
  final VoidCallback? onStructureChanged;

  /// Opens the wave timeline editor for the linked WaveManagerProps object.
  final VoidCallback? onOpenWaveTimeline;

  @override
  State<LevelEscalationModuleScreen> createState() =>
      _LevelEscalationModuleScreenState();
}

class _LevelEscalationModuleScreenState
    extends State<LevelEscalationModuleScreen> {
  static const _objClass = 'LevelEscalationModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late LevelEscalationModuleData _data;
  late TextEditingController _flagCountCtrl;
  late TextEditingController _wavesPerFlagCtrl;
  late TextEditingController _startingPointsCtrl;
  late TextEditingController _pointIncrementCtrl;
  late TextEditingController _plantfoodCountCtrl;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
        ).toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }

    try {
      _data = LevelEscalationModuleData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = LevelEscalationModuleData();
    }

    _flagCountCtrl = TextEditingController(text: '${_data.flagCount}');
    _wavesPerFlagCtrl = TextEditingController(text: '${_data.wavesPerFlag}');
    _startingPointsCtrl = TextEditingController(
      text: '${_data.startingPoints}',
    );
    _pointIncrementCtrl = TextEditingController(
      text: '${_data.pointIncrementPerWave}',
    );
    _plantfoodCountCtrl = TextEditingController(
      text: '${_data.plantfoodToSpawnCount}',
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _uniqueAlias(String base) {
    var alias = base;
    var count = 0;
    while (widget.levelFile.objects.any(
      (o) => o.aliases?.contains(alias) == true,
    )) {
      count++;
      alias = '${base}_$count';
    }
    return alias;
  }

  PvzObject? _linkedWaveManagerProps() {
    final info = RtidParser.parse(_data.waveManagerProps ?? '');
    if (info == null || info.source != 'CurrentLevel') return null;
    return widget.levelFile.objects.firstWhereOrNull(
      (object) =>
          object.objClass == 'WaveManagerProperties' &&
          object.aliases?.contains(info.alias) == true,
    );
  }

  /// Creates or reuses WaveManagerProperties and links it only to Escalation
  /// Spawning. A missing WaveManagerModule is added as a runner without an
  /// independent WaveManagerProps reference, matching official level data.
  void _addWaveTimeline() {
    final levelFile = widget.levelFile;
    final defObj = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelDefinition',
    );
    final definition = defObj?.objData is Map
        ? LevelDefinitionData.fromJson(
            Map<String, dynamic>.from(defObj!.objData as Map),
          )
        : null;

    var propsAlias = 'WaveManagerProps';
    final existingProps =
        _linkedWaveManagerProps() ??
        levelFile.objects.firstWhereOrNull(
          (o) => o.objClass == 'WaveManagerProperties',
        );
    if (existingProps != null) {
      propsAlias =
          existingProps.aliases?.firstOrNull ?? _uniqueAlias(propsAlias);
      existingProps.aliases ??= [propsAlias];
      if (existingProps.aliases!.isEmpty) {
        existingProps.aliases!.add(propsAlias);
      }
    } else {
      propsAlias = _uniqueAlias(propsAlias);
      levelFile.objects.add(
        PvzObject(
          aliases: [propsAlias],
          objClass: 'WaveManagerProperties',
          objData: WaveManagerData(waveCount: 0, waves: []).toJson(),
        ),
      );
    }
    final propsRtid = RtidParser.build(propsAlias, 'CurrentLevel');

    PvzObject? wmmObj;
    if (definition != null) {
      for (final moduleRtid in definition.modules) {
        final info = RtidParser.parse(moduleRtid);
        if (info == null || info.source != 'CurrentLevel') continue;
        final candidate = levelFile.objects.firstWhereOrNull(
          (object) =>
              object.objClass == 'WaveManagerModuleProperties' &&
              object.aliases?.contains(info.alias) == true,
        );
        if (candidate != null) {
          wmmObj = candidate;
          break;
        }
      }
    }
    if (wmmObj == null) {
      final moduleAlias = _uniqueAlias('NewWaves');
      wmmObj = PvzObject(
        aliases: [moduleAlias],
        objClass: 'WaveManagerModuleProperties',
        objData: WaveManagerModuleData(dynamicZombies: []).toJson(),
      );
      levelFile.objects.add(wmmObj);
    }

    final moduleAlias = wmmObj.aliases?.firstOrNull;
    if (moduleAlias != null && defObj != null && definition != null) {
      final moduleRtid = RtidParser.build(moduleAlias, 'CurrentLevel');
      if (!definition.modules.contains(moduleRtid)) {
        final escalationRtid = RtidParser.build(_alias, 'CurrentLevel');
        final escalationIndex = definition.modules.indexOf(escalationRtid);
        final insertAt = escalationIndex < 0
            ? definition.modules.length
            : escalationIndex + 1;
        final modules = [...definition.modules]..insert(insertAt, moduleRtid);
        definition.modules = modules;
        defObj.objData = definition.toJson();
      }
    }

    _data.waveManagerProps = propsRtid;
    _sync();
    widget.onStructureChanged?.call();
  }

  @override
  void dispose() {
    _flagCountCtrl.dispose();
    _wavesPerFlagCtrl.dispose();
    _startingPointsCtrl.dispose();
    _pointIncrementCtrl.dispose();
    _plantfoodCountCtrl.dispose();
    super.dispose();
  }

  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  bool _isYetiZombie(String id) {
    return id == 'yeti' || id == 'treasureyeti' || id == 'treasureyeti_egypt';
  }

  void _showBlockedMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _addZombie() {
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      if (_isYetiZombie(selectedId)) {
        _showBlockedMessage(
          l10n?.yetiZombiesNotAllowed ?? 'Yetis are not allowed here',
        );
        return;
      }
      if (ZombieRepository().isElite(selectedId)) {
        _showBlockedMessage(
          l10n?.eliteZombiesNotAllowed ?? 'Elite zombies are not allowed here',
        );
        return;
      }
      if (!ZombiePropertiesRepository.canSpawnFromPoints(selectedId)) {
        _showBlockedMessage(
          l10n?.pointSpawnOnlyZombiesBlocked ??
              'This zombie has no point cost (WavePointCost) data, so the '
                  'game cannot select and spawn it according to the wave\'s '
                  'points, and it cannot be added to the point-spawn pool.',
        );
        return;
      }
      final aliases = ZombieRepository().buildZombieAliases(selectedId);
      _data.zombiePool.add(RtidParser.build(aliases, 'ZombieTypes'));
      _sync();
    });
  }

  Future<void> _removeZombie(int index) async {
    if (index >= _data.zombiePool.length) return;
    final removed = _data.zombiePool[index];
    final info = RtidParser.parse(removed);
    var eraseOrphan = false;
    if (info?.source == 'CurrentLevel' && mounted) {
      final choice =
          await CustomZombieLevelUtils.maybePromptDeleteOrphanBeforeRemove(
            context: context,
            levelFile: widget.levelFile,
            alias: info!.alias,
          );
      if (!mounted || choice == null) return;
      eraseOrphan = choice;
    }
    _data.zombiePool.removeAt(index);
    _sync();
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _update({
    int? flagCount,
    int? wavesPerFlag,
    int? startingPoints,
    int? pointIncrementPerWave,
    int? plantfoodToSpawnCount,
  }) {
    _data.flagCount = flagCount ?? _data.flagCount;
    _data.wavesPerFlag = wavesPerFlag ?? _data.wavesPerFlag;
    _data.startingPoints = startingPoints ?? _data.startingPoints;
    _data.pointIncrementPerWave =
        pointIncrementPerWave ?? _data.pointIncrementPerWave;
    _data.plantfoodToSpawnCount =
        plantfoodToSpawnCount ?? _data.plantfoodToSpawnCount;
    _sync();
  }

  void _showPredictDialog() {
    final data = LevelEscalationModuleData.fromJson(
      Map<String, dynamic>.from(_data.toJson()),
    );
    final entries = WavePointAnalysis.resolveEntries(data.zombiePool);
    // Weight = 0 does not matter; only custom entries and zombies without
    // WavePointCost data are hidden.
    final hiddenIds = <String>{
      for (final e in entries)
        if (e.cost < 1 || e.custom) e.id,
    };
    // Pool zombies that have usable data at all (used for the empty state).
    final candidates = <String>{
      for (final e in entries)
        if (!hiddenIds.contains(e.id)) e.id,
    };
    // Pool zombies without usable WavePointCost data, reported as missing
    // (same ids the Wave Manager expectation dialog lists).
    final missingIds = <String>[
      for (final e in entries)
        if (e.cost < 1) e.id,
    ];
    final total = LevelEscalationPointAnalysis.totalWaves(data);
    final allocation = LevelEscalationRuntime(
      order: LevelEscalationModuleOrder.missing,
      data: data,
    );
    var selected = total > 0 ? total : 1;
    var cachedWave = -1;
    var cachedItems = const <MapEntry<String, double>>[];
    // Cost data of every pool zombie the game can actually buy; the same
    // pool serves every escalation wave.
    final validCosts = [
      for (final e in entries)
        if (e.cost >= 1) e.cost,
    ];
    // Simulated zombie count summed across all escalation waves.
    final totalEstimate = validCosts.isEmpty || total <= 0
        ? null
        : ZombieCountSimulation.simulateTotal([
            for (var w = 1; w <= total; w++)
              (
                costs: validCosts,
                points: LevelEscalationPointAnalysis.pointsAtWave(data, w),
              ),
          ]);
    var cachedWaveEstimate = const ZombieCountEstimate(
      average: 0,
      minimum: 0,
      maximum: 0,
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final theme = Theme.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setState) {
            final points = LevelEscalationPointAnalysis.pointsAtWave(
              data,
              selected,
            );
            if (cachedWave != selected) {
              final expectation = WavePointAnalysis.calculate(entries, points);
              final sorted = expectation.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              // Only zombies the game can actually buy from the point budget
              // get a row; custom and no-data zombies are hidden entirely.
              // Rows that round to 0.00 for this wave are dropped — a wave
              // with a richer budget still shows them.
              cachedItems = [
                for (final e in sorted)
                  if (e.value >= 0.005 && !hiddenIds.contains(e.key)) e,
              ];
              cachedWaveEstimate = validCosts.isEmpty || points <= 0
                  ? const ZombieCountEstimate(
                      average: 0,
                      minimum: 0,
                      maximum: 0,
                    )
                  : ZombieCountSimulation.simulateWave(validCosts, points);
              cachedWave = selected;
            }
            return AlertDialog(
              title: Text(l10n?.levelEscalationPredict ?? 'Point prediction'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (total > 0) ...[
                        Text(
                          '${l10n?.waveLabel ?? 'Wave'} $selected — '
                          '${l10n?.pointsLabel ?? 'Points'}: $points',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (var w = 1; w <= total; w++)
                              ChoiceChip(
                                key: ValueKey('levelEscalationPredictWave-$w'),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n?.customZombieWaveItem(w) ??
                                          'Wave $w',
                                    ),
                                    if (allocation.fixedPlantFoodAtWave(w) >
                                        0) ...[
                                      const SizedBox(width: 4),
                                      const AssetImageWidget(
                                        assetPath:
                                            'assets/images/others/plantfood.webp',
                                        width: 16,
                                        height: 16,
                                      ),
                                      Text(
                                        '×${allocation.fixedPlantFoodAtWave(w)}',
                                      ),
                                    ],
                                  ],
                                ),
                                avatar:
                                    LevelEscalationPointAnalysis.isFlagWave(
                                      data,
                                      w,
                                    )
                                    ? Icon(
                                        Icons.flag,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                                selected: w == selected,
                                onSelected: (_) => setState(() {
                                  selected = w;
                                }),
                              ),
                          ],
                        ),
                        if (cachedWaveEstimate.average > 0 ||
                            cachedWaveEstimate.maximum > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            zombieCountEstimateText(
                              l10n,
                              cachedWaveEstimate,
                              scope: ZombieCountEstimateScope.wave,
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (totalEstimate != null &&
                              (totalEstimate.average > 0 ||
                                  totalEstimate.maximum > 0))
                            Text(
                              zombieCountEstimateText(
                                l10n,
                                totalEstimate,
                                scope: ZombieCountEstimateScope.allWaves,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                        if (allocation.fixedPlantFoodAtWave(selected) > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n?.levelEscalationWavePlantfood(
                                  allocation.fixedPlantFoodAtWave(selected),
                                ) ??
                                'Plant Food fixed to this wave: '
                                    '${allocation.fixedPlantFoodAtWave(selected)}',
                          ),
                        ],
                        if (allocation.randomPlantFoodCount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n?.levelEscalationRandomPlantfood(
                                  allocation.randomPlantFoodCount,
                                  total,
                                ) ??
                                '${allocation.randomPlantFoodCount} additional '
                                    'Plant Food item(s) are randomly assigned '
                                    'to waves 1–$total.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (missingIds.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n?.waveManagerExpectationMissingData(
                                  missingIds.join(', '),
                                ) ??
                                'These zombies lack reliable WavePointCost '
                                    'data and are not counted: '
                                    '${missingIds.join(', ')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                      if (total > 0)
                        SizedBox(
                          height: 230,
                          child: cachedItems.isEmpty
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    candidates.isEmpty
                                        ? (l10n?.noDynamicZombies ??
                                              'No dynamic zombies')
                                        : (l10n?.expectationNoAffordableZombies ??
                                              'This wave does not have enough '
                                                  'points to select and spawn '
                                                  'any zombie from the pool.'),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: cachedItems.length,
                                  itemBuilder: (_, i) {
                                    final e = cachedItems[i];
                                    final info = ZombieRepository()
                                        .getZombieById(e.key);
                                    final nameKey =
                                        info?.name ??
                                        ZombieRepository().getName(e.key);
                                    final displayName = ResourceNames.lookup(
                                      ctx,
                                      nameKey,
                                    );
                                    final iconPath = info?.iconAssetPath;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: iconPath != null
                                                  ? AssetImageWidget(
                                                      assetPath: iconPath,
                                                      altCandidates:
                                                          imageAltCandidates(
                                                            iconPath,
                                                          ),
                                                      width: 32,
                                                      height: 32,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : ColoredBox(
                                                      color: theme
                                                          .colorScheme
                                                          .surfaceContainerHighest,
                                                      child: Center(
                                                        child: Text(
                                                          displayName.isNotEmpty
                                                              ? displayName[0]
                                                                    .toUpperCase()
                                                              : '?',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayName.isNotEmpty
                                                      ? displayName
                                                      : e.key,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                Text(
                                                  e.key,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                Text(
                                                  l10n?.zombiePointCost(
                                                        ZombiePropertiesRepository.getStats(
                                                          e.key,
                                                        ).cost,
                                                      ) ??
                                                      'Point cost: '
                                                          '${ZombiePropertiesRepository.getStats(e.key).cost}',
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n?.pointSpawnExpectedCount(
                                                  e.value.toStringAsFixed(2),
                                                ) ??
                                                e.value.toStringAsFixed(2),
                                            key: ValueKey(
                                              'levelEscalationExpectationCount-${e.key}',
                                            ),
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n?.close ?? 'Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionTitleColor = isDark ? pvzPurpleDark : pvzPurpleLight;
    final sectionColor = theme.colorScheme.primary;
    final contentCardColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;
    // Match Wave Manager linked-props card: light = light green card, dark =
    // vibrant green card.
    final propsCardColor = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE8F5E9);
    final propsTextColor = isDark ? Colors.white : const Color(0xFF1B5E20);
    final propsSubtextColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF689F38);
    final runtime = LevelEscalationRuntime.resolve(
      widget.levelFile,
      escalationAlias: _alias,
    );
    final flagCountValue = int.tryParse(_flagCountCtrl.text);
    final wavesPerFlagValue = int.tryParse(_wavesPerFlagCtrl.text);
    final plantfoodCountValue = int.tryParse(_plantfoodCountCtrl.text);
    final flagCountError = flagCountValue == null || flagCountValue <= 0
        ? (l10n?.levelEscalationFlagCountInvalid ??
              'Flag count must be a positive integer.')
        : null;
    final wavesPerFlagError =
        wavesPerFlagValue == null || wavesPerFlagValue <= 0
        ? (l10n?.levelEscalationWavesPerFlagInvalid ??
              'Waves per flag must be a positive integer.')
        : wavesPerFlagValue == 1 &&
              plantfoodCountValue != null &&
              plantfoodCountValue > 0
        ? (l10n?.levelEscalationPlantfoodWavesPerFlagInvalid ??
              'When Plant Food is allocated, Waves per flag must be at '
                  'least 2.')
        : null;
    final plantfoodCountError =
        plantfoodCountValue == null || plantfoodCountValue < 0
        ? (l10n?.levelEscalationPlantfoodCountInvalid ??
              'Plant Food count must be a non-negative integer.')
        : null;

    final linkedPropsObj = _linkedWaveManagerProps();
    final fallbackPropsObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'WaveManagerProperties',
    );
    final propsObj = linkedPropsObj ?? fallbackPropsObj;
    final propsAliases = propsObj?.aliases;
    final actualWaveMgrAlias = propsAliases != null && propsAliases.isNotEmpty
        ? propsAliases.first
        : null;
    final hasWaveManagerRunner = runtime.waveManagerIndex != null;
    final hasLinkedProps = linkedPropsObj != null;
    final isPropsValid = hasLinkedProps && hasWaveManagerRunner;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: sectionTitleColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title:
                  l10n?.levelEscalationModuleHelpTitle ?? 'Escalation Spawning',
              themeColor: sectionTitleColor,
              sections: [
                HelpSectionData(
                  title: l10n?.levelEscalationModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.levelEscalationModuleHelpOverviewBody ??
                      'Adds point-based difficulty escalation to the level.',
                ),
                HelpSectionData(
                  title:
                      l10n?.levelEscalationModuleHelpRuntime ??
                      'Wave configuration and runner',
                  body: l10n?.levelEscalationModuleHelpRuntimeBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.levelEscalationModuleHelpWaveLayout ??
                      'Waves and flags',
                  body: l10n?.levelEscalationModuleHelpWaveLayoutBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.levelEscalationModuleHelpSpending ??
                      'Point trajectory',
                  body: l10n?.levelEscalationModuleHelpSpendingBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.levelEscalationModuleHelpPlantfood ??
                      'Plant Food allocation',
                  body: l10n?.levelEscalationModuleHelpPlantfoodBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.levelEscalationModuleHelpPool ?? 'Zombie pool',
                  body: l10n?.levelEscalationModuleHelpPoolBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.levelEscalationModuleHelpLimits ??
                      'Parameter limits',
                  body: l10n?.levelEscalationModuleHelpLimitsBody ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            if (runtime.hasCompetingWaveManagerProps) ...[
              const SizedBox(height: 8),
              EditorWarningBanner(
                margin: EdgeInsets.zero,
                message:
                    runtime.order == LevelEscalationModuleOrder.afterWaveManager
                    ? (l10n?.levelEscalationAfterWaveManagerWarning ??
                          'Both modules use different wave configurations. '
                              'Escalation Spawning runs later, so its processed '
                              'configuration is previewed.')
                    : (l10n?.levelEscalationBeforeWaveManagerWarning ??
                          'Both modules use different wave configurations. '
                              'Wave Manager runs later and may replace the '
                              'escalated result with its own configuration.'),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              color: isPropsValid ? propsCardColor : theme.colorScheme.error,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onOpenWaveTimeline,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(16) / 16;
                      final compact =
                          constraints.maxWidth < 520 || textScale > 1.3;
                      final statusIcon = Icon(
                        isPropsValid ? Icons.check_circle : editorWarningIcon,
                        color: isPropsValid
                            ? (isDark ? Colors.white : const Color(0xFF2E7D32))
                            : theme.colorScheme.onError,
                      );
                      final chevron = Icon(
                        Icons.chevron_right,
                        color: isPropsValid
                            ? propsSubtextColor
                            : theme.colorScheme.onError,
                      );
                      final details = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.moduleTitle_WaveManagerProperties ??
                                'Wave Configuration (WaveManagerProperties)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPropsValid
                                  ? propsTextColor
                                  : theme.colorScheme.onError,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.waveManagerPropsCurrent(
                                  _data.waveManagerProps ?? 'null',
                                ) ??
                                'Current: ${_data.waveManagerProps ?? 'null'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isPropsValid
                                  ? propsSubtextColor
                                  : theme.colorScheme.onError,
                            ),
                          ),
                          if (actualWaveMgrAlias == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                l10n?.noWaveManagerPropsFound ??
                                    'No wave configuration '
                                        '(WaveManagerProperties) object was found.',
                                style: TextStyle(
                                  color: theme.colorScheme.onError,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (hasLinkedProps && !hasWaveManagerRunner)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                l10n?.levelEscalationWaveManagerRunnerMissing ??
                                    'The linked wave configuration exists, but '
                                        'the Wave Manager runner module is missing.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                            ),
                          if (!hasLinkedProps && fallbackPropsObj == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                l10n?.levelEscalationAddWaveTimelineHint ??
                                    'Creates an empty wave configuration and '
                                        'adds a runner-only Wave Manager module '
                                        'when needed.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                            ),
                        ],
                      );
                      Widget buildFixButton({
                        double? maxWidth,
                        bool stretch = false,
                      }) {
                        final button = FilledButton(
                          key: const ValueKey('levelEscalationPropsFixButton'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            backgroundColor: theme.colorScheme.onError,
                            foregroundColor: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            _data.waveManagerProps = RtidParser.build(
                              actualWaveMgrAlias!,
                              'CurrentLevel',
                            );
                            _sync();
                          },
                          child: Text(
                            l10n?.fixToAlias(actualWaveMgrAlias!) ??
                                'Fix to $actualWaveMgrAlias',
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        );
                        if (maxWidth != null) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: stretch
                                ? SizedBox(
                                    width: double.infinity,
                                    child: button,
                                  )
                                : button,
                          );
                        }
                        if (stretch) {
                          return SizedBox(
                            width: double.infinity,
                            child: button,
                          );
                        }
                        return button;
                      }

                      final showPropsFixButton =
                          !hasLinkedProps &&
                          actualWaveMgrAlias != null &&
                          hasWaveManagerRunner;
                      final addTimelineButton = FilledButton(
                        key: const ValueKey(
                          'levelEscalationAddWaveTimelineButton',
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          backgroundColor: theme.colorScheme.onError,
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: _addWaveTimeline,
                        child: Text(
                          l10n?.levelEscalationAddWaveTimeline ??
                              'Add wave timeline',
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      );
                      final showAddTimelineButton =
                          actualWaveMgrAlias == null || !hasWaveManagerRunner;

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                statusIcon,
                                const SizedBox(width: 8),
                                Expanded(child: details),
                                const SizedBox(width: 4),
                                chevron,
                              ],
                            ),
                            if (showAddTimelineButton) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: addTimelineButton,
                              ),
                            ],
                            if (showPropsFixButton) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: buildFixButton(stretch: true),
                              ),
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          statusIcon,
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                details,
                                if (showAddTimelineButton) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 440,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: addTimelineButton,
                                      ),
                                    ),
                                  ),
                                ],
                                if (showPropsFixButton) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: buildFixButton(
                                      maxWidth: 440,
                                      stretch: true,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          chevron,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.parameters ?? 'Parameters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: sectionColor,
              ),
            ),
            if (_data.totalWaves > 0) ...[
              WaveFlagStrip(
                color: sectionColor,
                waveCount: _data.totalWaves,
                isFlagWave: (w) =>
                    LevelEscalationPointAnalysis.isFlagWave(_data, w),
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 8),
            Card(
              color: contentCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _intField(
                            key: const ValueKey(
                              'levelEscalationFlagCountField',
                            ),
                            controller: _flagCountCtrl,
                            label:
                                l10n?.levelEscalationFlagCountShort ?? 'Flags',
                            errorText: flagCountError,
                            onChanged: (v) => _update(
                              flagCount: int.tryParse(v) ?? _data.flagCount,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _intField(
                            key: const ValueKey(
                              'levelEscalationWavesPerFlagField',
                            ),
                            controller: _wavesPerFlagCtrl,
                            label:
                                l10n?.levelEscalationFlagIntervalShort ??
                                'Interval',
                            errorText: wavesPerFlagError,
                            onChanged: (v) => _update(
                              wavesPerFlag:
                                  int.tryParse(v) ?? _data.wavesPerFlag,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _intField(
                      controller: _startingPointsCtrl,
                      label:
                          l10n?.startingPoints ??
                          'Starting points (StartingPoints)',
                      onChanged: (v) => _update(
                        startingPoints: int.tryParse(v) ?? _data.startingPoints,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _intField(
                      controller: _pointIncrementCtrl,
                      label:
                          l10n?.pointIncrement ??
                          'Point increase per wave (PointIncrementPerWave)',
                      onChanged: (v) => _update(
                        pointIncrementPerWave:
                            int.tryParse(v) ?? _data.pointIncrementPerWave,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _intField(
                      key: const ValueKey('levelEscalationPlantfoodCountField'),
                      controller: _plantfoodCountCtrl,
                      label:
                          l10n?.plantfoodToSpawnCount ??
                          'Plant Food count (PlantfoodToSpawnCount)',
                      errorText: plantfoodCountError,
                      onChanged: (v) => _update(
                        plantfoodToSpawnCount:
                            int.tryParse(v) ?? _data.plantfoodToSpawnCount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: contentCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.levelEscalationPredict ?? 'Point prediction',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: sectionColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.levelEscalationPredictHint ??
                          'Shows the expected zombie counts for each wave '
                              'of the configured pool.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('levelEscalationPredictButton'),
                        onPressed: _showPredictDialog,
                        icon: const Icon(Icons.query_stats),
                        label: Text(
                          l10n?.levelEscalationPredictShow ?? 'Show prediction',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            EditorResponsiveActionRow(
              content: Text(
                l10n?.zombiePool ?? 'Zombie pool',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sectionColor,
                ),
              ),
              action: TextButton.icon(
                onPressed: _addZombie,
                icon: const Icon(Icons.add),
                label: Text(l10n?.add ?? 'Add'),
              ),
            ),
            const SizedBox(height: 8),
            if (_data.zombiePool.isEmpty)
              Card(
                color: contentCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n?.emptyList ?? 'The list is empty',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ..._data.zombiePool.asMap().entries.map((entry) {
              final idx = entry.key;
              final rtid = entry.value;
              final zombieAlias = RtidParser.parse(rtid)?.alias ?? rtid;
              final typeName = ZombiePropertiesRepository.getTypeNameByAlias(
                zombieAlias,
              );
              final info = ZombieRepository().getZombieById(typeName);
              final nameKey =
                  info?.name ?? ZombieRepository().getName(typeName);
              final displayName = ResourceNames.lookup(context, nameKey);
              final pointCost = ZombiePropertiesRepository.getStats(
                typeName,
              ).cost;
              final iconPath = info?.iconAssetPath;
              return Card(
                key: ValueKey('levelEscalationZombie-$idx'),
                color: contentCardColor,
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: iconPath != null
                              ? AssetImageWidget(
                                  assetPath: iconPath,
                                  altCandidates: imageAltCandidates(iconPath),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n?.zombiePointCost(pointCost) ??
                                  'Point cost: $pointCost',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: l10n?.delete ?? 'Delete',
                        onPressed: () => _removeZombie(idx),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _intField({
    Key? key,
    required TextEditingController controller,
    required String label,
    String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    return EditorResponsiveInputField(
      key: key,
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: decoration.copyWith(
          errorText: errorText,
          errorMaxLines: errorText == null ? null : 3,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
