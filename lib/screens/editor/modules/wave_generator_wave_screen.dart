import 'package:c_editor/data/oak_archery_preview.dart';
import 'package:c_editor/widgets/wave_generator_position_fields.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:c_editor/widgets/zombie_row_lane_drag_drop_editor.dart';
import 'package:c_editor/widgets/zombie_row_lane_utils.dart';
import 'package:c_editor/widgets/zombie_selection_flow.dart';

enum _WaveGeneratorWaveSection { fixedSpawns, randomSpawns, pool, settings }

/// Full-screen editor for a single wave inside [WaveGeneratorProperties].
class WaveGeneratorWaveScreen extends StatefulWidget {
  const WaveGeneratorWaveScreen({
    super.key,
    required this.waveIndex,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  /// 1-based wave index.
  final int waveIndex;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<WaveGeneratorWaveScreen> createState() =>
      _WaveGeneratorWaveScreenState();
}

class _WaveGeneratorWaveScreenState extends State<WaveGeneratorWaveScreen> {
  late WaveGeneratorPropertiesData _generatorData;
  late WaveGeneratorWaveData _wave;
  late TextEditingController _plantFoodCtrl;
  late TextEditingController _pointStartCtrl;
  late TextEditingController _pointIncrementCtrl;
  late TextEditingController _blackHoleCtrl;
  late TextEditingController _waveSpawnTimeCtrl;
  Map<int, int?> _zombieLevels = {};
  bool _zombieDragging = false;
  _WaveGeneratorWaveSection? _activeSection;

  int get _rowCount {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int? _readJsonInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<dynamic>? _waveJsonList(dynamic objData) {
    if (objData is! Map) return null;
    final waves = objData['Waves'];
    return waves is List ? waves : null;
  }

  Map<int, int?> _readWaveZombieLevels(dynamic objData, int waveIndex) {
    final waves = _waveJsonList(objData);
    if (waves == null || waveIndex < 0 || waveIndex >= waves.length) {
      return {};
    }
    final wave = waves[waveIndex];
    if (wave is! Map || wave['Zombies'] is! List) return {};
    final zombies = wave['Zombies'] as List;
    final result = <int, int?>{};
    for (var i = 0; i < zombies.length; i++) {
      final zombie = zombies[i];
      if (zombie is Map && zombie.containsKey('Level')) {
        result[i] = _readJsonInt(zombie['Level']);
      }
    }
    return result;
  }

  Map<int, Map<int, int?>> _readAllWaveZombieLevels(dynamic objData) {
    final waves = _waveJsonList(objData);
    if (waves == null) return {};
    final result = <int, Map<int, int?>>{};
    for (var i = 0; i < waves.length; i++) {
      final levels = _readWaveZombieLevels(objData, i);
      if (levels.isNotEmpty) result[i] = levels;
    }
    return result;
  }

  Map<String, dynamic> _withLevelAfterType(
    Map<dynamic, dynamic> source,
    int? level,
  ) {
    final result = <String, dynamic>{};
    var inserted = false;
    source.forEach((key, value) {
      final keyString = key.toString();
      if (keyString == 'Level') return;
      result[keyString] = value;
      if (keyString == 'Type' && level != null) {
        result['Level'] = level;
        inserted = true;
      }
    });
    if (!inserted && level != null) {
      result['Level'] = level;
    }
    return result;
  }

  void _handleZombieDragDropMove(int fromIndex, int toRow, int rowInsertIndex) {
    final zombies = List<WaveGeneratorZombieEntryData>.from(_wave.zombies);
    final parallelLevels = List<int?>.generate(
      zombies.length,
      (i) => _zombieLevels[i],
    );
    moveWaveGeneratorZombieInListByRowSlot(
      zombies: zombies,
      fromIndex: fromIndex,
      toRow: toRow,
      maxRow: _rowCount,
      rowInsertIndex: rowInsertIndex,
      parallelLevels: parallelLevels,
    );
    // 袨斜薪芯胁谢褟械屑 褍褉芯胁薪懈 胁 锌邪屑褟褌懈 锌芯褋谢械 锌械褉械屑械褖械薪懈褟
    _zombieLevels = {};
    for (var i = 0; i < parallelLevels.length; i++) {
      final level = parallelLevels[i];
      if (level != null) {
        _zombieLevels[i] = level;
      }
    }
    _assignWaveZombies(zombies);
  }

  Future<void> _changeZombieTypeFromSheet({
    required BuildContext sheetContext,
    required int index,
    required String currentRow,
    required int levelValue,
    required bool isElite,
  }) async {
    final selected = await pushZombieSelection(context);
    if (!mounted || selected == null) return;

    final rtid = RtidParser.build(
      ZombieRepository().buildZombieAliases(selected),
      'ZombieTypes',
    );

    final l10n = AppLocalizations.of(context);
    if (RtidParser.parse(rtid)?.source == 'CurrentLevel') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.waveGeneratorCustomZombieBlocked ??
                  'Custom zombies not supported',
            ),
          ),
        );
      }
      return;
    }

    final isEliteNew = ZombieRepository().isElite(selected);
    final current = _wave.zombies[index];
    _updateZombie(
      index,
      WaveGeneratorZombieEntryData(
        type: rtid,
        row: currentRow,
        level: current.level,
        targetValidTime: current.targetValidTime,
        riseGridX: current.riseGridX,
        riseGridY: current.riseGridY,
      ),
      level: isEliteNew ? null : (levelValue == 0 ? null : levelValue),
      replaceLevel: true,
    );

    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
  }

  void _applyWaveZombieLevels(
    dynamic objData,
    Map<int, Map<int, int?>> levelsByWave,
  ) {
    final waves = _waveJsonList(objData);
    if (waves == null) return;
    levelsByWave.forEach((waveIndex, levels) {
      if (waveIndex < 0 || waveIndex >= waves.length) return;
      final wave = waves[waveIndex];
      if (wave is! Map || wave['Zombies'] is! List) return;
      final zombies = wave['Zombies'] as List;
      for (var i = 0; i < zombies.length; i++) {
        final zombie = zombies[i];
        if (zombie is Map) {
          zombies[i] = _withLevelAfterType(zombie, levels[i]);
        }
      }
    });
  }

  String _zombieBaseId(String rtid) {
    return RtidParser.parse(rtid)?.alias ?? ZombieDisplayUtils.codename(rtid);
  }

  bool _isEliteRtid(String rtid) {
    return ZombieRepository().isElite(_zombieBaseId(rtid));
  }

  int? _normalizeZombieLevel(String rtid, int? level) {
    if (_isEliteRtid(rtid) || level == null) return null;
    return level < 1 ? 1 : level;
  }

  int? _levelForZombie(int index) {
    if (index < 0 || index >= _wave.zombies.length) return null;
    return _normalizeZombieLevel(
      _wave.zombies[index].type,
      _zombieLevels[index],
    );
  }

  void _setZombieLevelInMemory(int index, String rtid, int? level) {
    final normalized = _normalizeZombieLevel(rtid, level);
    if (normalized == null) {
      _zombieLevels.remove(index);
    } else {
      _zombieLevels[index] = normalized;
    }
  }

  void _loadZombieLevels(dynamic objData, int waveIndex) {
    final rawLevels = _readWaveZombieLevels(objData, waveIndex);
    _zombieLevels = {};
    for (var i = 0; i < _wave.zombies.length; i++) {
      _setZombieLevelInMemory(i, _wave.zombies[i].type, rawLevels[i]);
    }
  }

  Map<int, int?> _normalizedCurrentWaveLevels() {
    final result = <int, int?>{};
    for (var i = 0; i < _wave.zombies.length; i++) {
      final level = _normalizeZombieLevel(
        _wave.zombies[i].type,
        _zombieLevels[i],
      );
      if (level != null) result[i] = level;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    final rawObjData = obj?.objData;
    _generatorData = obj != null
        ? WaveGeneratorLevelUtils.parseObject(obj)
        : WaveGeneratorPropertiesData(waves: [WaveGeneratorWaveData()]);
    final idx = widget.waveIndex - 1;
    if (idx >= 0 && idx < _generatorData.waves.length) {
      _wave = _generatorData.waves[idx];
    } else {
      _wave = WaveGeneratorWaveData();
    }
    _loadZombieLevels(rawObjData, idx);
    _plantFoodCtrl = TextEditingController(
      text: _wave.spawnPlantFoodCount?.toString() ?? '',
    );
    _pointStartCtrl = TextEditingController(
      text: _wave.wavePointStart?.toString() ?? '',
    );
    _pointIncrementCtrl = TextEditingController(
      text: _wave.wavePointIncrement?.toString() ?? '',
    );
    _blackHoleCtrl = TextEditingController(
      text: _wave.colNumPlantIsDragged?.toString() ?? '',
    );
    _waveSpawnTimeCtrl = TextEditingController(
      text: _wave.waveSpawnTime?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _plantFoodCtrl.dispose();
    _pointStartCtrl.dispose();
    _pointIncrementCtrl.dispose();
    _blackHoleCtrl.dispose();
    _waveSpawnTimeCtrl.dispose();
    super.dispose();
  }

  Widget _buildLabeledNumberField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    int? helperMaxLines,
    bool enabled = true,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          softWrap: true,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            helperText: helperText,
            helperMaxLines: helperMaxLines,
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _assignWaveZombies(
    List<WaveGeneratorZombieEntryData> zombies, {
    bool sortRows = false,
  }) {
    if (sortRows) {
      final parallelLevels = List<int?>.generate(
        zombies.length,
        (i) => _zombieLevels[i],
      );
      sortWaveGeneratorZombieListByRow(
        zombies,
        maxRow: _rowCount,
        parallelLevels: parallelLevels,
      );
      _zombieLevels = {};
      for (var i = 0; i < parallelLevels.length; i++) {
        final level = parallelLevels[i];
        if (level != null) {
          _zombieLevels[i] = level;
        }
      }
    }
    _wave = _copyWave(zombies: zombies);
    _sync();
  }

  void _sync() {
    final obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    if (obj == null) return;
    final idx = widget.waveIndex - 1;
    if (idx < 0 || idx >= _generatorData.waves.length) return;
    final allLevels = _readAllWaveZombieLevels(obj.objData);
    final waves = List<WaveGeneratorWaveData>.from(_generatorData.waves);
    waves[idx] = _wave;
    _generatorData = WaveGeneratorPropertiesData(
      addToZombiePool: _generatorData.addToZombiePool,
      flagWaveInterval: _generatorData.flagWaveInterval,
      waveCount: _generatorData.waveCount,
      waveSpendingPoints: _generatorData.waveSpendingPoints,
      waveSpendingPointIncrement: _generatorData.waveSpendingPointIncrement,
      waves: waves,
      isRiseFromGroundMode: _generatorData.isRiseFromGroundMode,
      ignoreFlagCarriers: _generatorData.ignoreFlagCarriers,
      spawnColStart: _generatorData.spawnColStart,
      spawnColEnd: _generatorData.spawnColEnd,
    );
    _generatorData.syncWaveCount();
    allLevels[idx] = _normalizedCurrentWaveLevels();
    obj.objData = _generatorData.toJson();
    _applyWaveZombieLevels(obj.objData, allLevels);
    widget.onChanged();
    setState(() {});
  }

  bool _isYetiZombie(String id) {
    return id == 'yeti' || id == 'treasureyeti' || id == 'treasureyeti_egypt';
  }

  void _showYetiZombieBlockedMessage(AppLocalizations? l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.yetiZombiesNotAllowed ?? 'Yetis are not allowed here',
        ),
      ),
    );
  }

  WaveGeneratorWaveData _copyWave({
    bool? disableRandomSpawns,
    List<WaveGeneratorZombieEntryData>? zombies,
    int? spawnPlantFoodCount,
    List<WaveGeneratorPoolEntryData>? addToZombiePool,
    int? wavePointStart,
    int? wavePointIncrement,
    bool? wavePointOverride,
    int? colNumPlantIsDragged,
    bool? waitUntilAllZombiesDie,
    num? waveSpawnTime,
    bool clearSpawnPlantFood = false,
    bool clearWavePointStart = false,
    bool clearWavePointIncrement = false,
    bool clearColNumPlantIsDragged = false,
    bool clearWaveSpawnTime = false,
  }) {
    return WaveGeneratorWaveData(
      disableRandomSpawns: disableRandomSpawns ?? _wave.disableRandomSpawns,
      zombies: zombies ?? _wave.zombies,
      spawnPlantFoodCount: clearSpawnPlantFood
          ? null
          : (spawnPlantFoodCount ?? _wave.spawnPlantFoodCount),
      addToZombiePool: addToZombiePool ?? _wave.addToZombiePool,
      wavePointStart: clearWavePointStart
          ? null
          : (wavePointStart ?? _wave.wavePointStart),
      wavePointIncrement: clearWavePointIncrement
          ? null
          : (wavePointIncrement ?? _wave.wavePointIncrement),
      wavePointOverride: wavePointOverride ?? _wave.wavePointOverride,
      colNumPlantIsDragged: clearColNumPlantIsDragged
          ? null
          : (colNumPlantIsDragged ?? _wave.colNumPlantIsDragged),
      waitUntilAllZombiesDie:
          waitUntilAllZombiesDie ?? _wave.waitUntilAllZombiesDie,
      waveSpawnTime: clearWaveSpawnTime
          ? null
          : (waveSpawnTime ?? _wave.waveSpawnTime),
    );
  }

  String _zombieDisplayName(String rtid) {
    return ZombieDisplayUtils.localizedName(
      context,
      typeOrRtid: rtid,
      levelFile: widget.levelFile,
    );
  }

  String _zombieCodename(String rtid) {
    return ZombieDisplayUtils.codename(rtid);
  }

  String? _zombieIcon(String rtid) {
    return ZombieDisplayUtils.iconPath(rtid, levelFile: widget.levelFile);
  }

  int _rowValue(String? row) {
    if (row == null || row.isEmpty || row == '?') {
      return 0;
    }
    return int.tryParse(row) ?? 0;
  }

  void _setZombieRow(int index, int rowValue) {
    final zombie = _wave.zombies[index];
    final rowStr = rowValue == 0 ? '?' : '$rowValue';
    _updateZombie(
      index,
      WaveGeneratorZombieEntryData(type: zombie.type, row: rowStr),
    );
  }

  void _updateZombie(
    int index,
    WaveGeneratorZombieEntryData updated, {
    int? level,
    bool replaceLevel = false,
  }) {
    final list = List<WaveGeneratorZombieEntryData>.from(_wave.zombies);
    final rowChanged = list[index].row != updated.row;
    list[index] = updated;
    _setZombieLevelInMemory(
      index,
      updated.type,
      replaceLevel ? level : _zombieLevels[index],
    );
    _assignWaveZombies(list, sortRows: rowChanged);
  }

  void _setZombieLevel(int index, int? level) {
    if (index < 0 || index >= _wave.zombies.length) return;
    _setZombieLevelInMemory(index, _wave.zombies[index].type, level);
    _sync();
  }

  void _removeZombie(int index) {
    final list = List<WaveGeneratorZombieEntryData>.from(_wave.zombies)
      ..removeAt(index);
    final shiftedLevels = <int, int?>{};
    _zombieLevels.forEach((key, value) {
      if (key < index) {
        shiftedLevels[key] = value;
      } else if (key > index) {
        shiftedLevels[key - 1] = value;
      }
    });
    _zombieLevels = shiftedLevels;
    _assignWaveZombies(list);
  }

  void _addZombie({required int rowValue}) {
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      final rtid = RtidParser.build(
        ZombieRepository().buildZombieAliases(selectedId),
        'ZombieTypes',
      );
      if (RtidParser.parse(rtid)?.source == 'CurrentLevel') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.waveGeneratorCustomZombieBlocked ??
                  'Custom zombies are not supported in wave generator levels.',
            ),
          ),
        );
        return;
      }
      final rowStr = rowValue == 0 ? '?' : '$rowValue';
      final newIndex = _wave.zombies.length;
      _setZombieLevelInMemory(newIndex, rtid, null);
      _assignWaveZombies([
        ..._wave.zombies,
        WaveGeneratorZombieEntryData(type: rtid, row: rowStr),
      ], sortRows: true);
    });
  }

  void _removePoolEntry(int index) {
    final pool = List<WaveGeneratorPoolEntryData>.from(_wave.addToZombiePool)
      ..removeAt(index);
    _wave = _copyWave(addToZombiePool: pool);
    _sync();
  }

  void _addPoolEntry() {
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      if (_isYetiZombie(selectedId)) {
        _showYetiZombieBlockedMessage(l10n);
        return;
      }
      if (ZombieRepository().isElite(selectedId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.eliteZombiesNotAllowed ??
                  'Elite zombies are not allowed here',
            ),
          ),
        );
        return;
      }
      final rtid = RtidParser.build(
        ZombieRepository().buildZombieAliases(selectedId),
        'ZombieTypes',
      );
      if (RtidParser.parse(rtid)?.source == 'CurrentLevel') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.waveGeneratorCustomZombieBlocked ??
                  'Custom zombies are not supported.',
            ),
          ),
        );
        return;
      }
      _wave = _copyWave(
        addToZombiePool: [
          ..._wave.addToZombiePool,
          WaveGeneratorPoolEntryData(type: rtid),
        ],
      );
      _sync();
    });
  }

  void _showExpectation() {
    showWaveGeneratorExpectationDialog(
      context,
      data: _generatorData,
      waveIndex: widget.waveIndex,
    );
  }

  Widget _buildPointTrajectoryPreview(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final firstWave = widget.waveIndex > 1 ? widget.waveIndex - 1 : 1;
    final lastWave = (_generatorData.waves.length < widget.waveIndex + 2)
        ? _generatorData.waves.length
        : widget.waveIndex + 2;
    final statusText = _wave.wavePointStart == null
        ? null
        : (_wave.wavePointOverride ?? false)
        ? (l10n?.waveGeneratorPointTrajectoryReset ??
              'The point trajectory is reset from this wave.')
        : (l10n?.waveGeneratorPointTrajectoryTemporary ??
              'Only this wave uses the current-wave point value.');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.waveGeneratorPointTrajectory ?? 'Point trajectory',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var wave = firstWave; wave <= lastWave; wave++)
                  Chip(
                    avatar: wave == widget.waveIndex
                        ? Icon(
                            Icons.my_location,
                            size: 16,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    label: Text(
                      l10n?.waveGeneratorPointTrajectoryWaveValue(
                            wave,
                            WaveGeneratorPointAnalysis.pointsAtWave(
                              _generatorData,
                              wave,
                            ),
                          ) ??
                          'W$wave · ${WaveGeneratorPointAnalysis.pointsAtWave(_generatorData, wave)}',
                    ),
                  ),
              ],
            ),
            if (statusText != null) ...[
              const SizedBox(height: 8),
              Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _sectionTitle(
    AppLocalizations? l10n,
    _WaveGeneratorWaveSection section,
  ) {
    return switch (section) {
      _WaveGeneratorWaveSection.fixedSpawns =>
        l10n?.waveGeneratorFixedSpawns ?? 'Fixed spawns',
      _WaveGeneratorWaveSection.randomSpawns =>
        l10n?.waveGeneratorRandomSpawnsSectionTitle ?? 'Random spawns',
      _WaveGeneratorWaveSection.pool =>
        l10n?.waveGeneratorZombiePoolSectionTitle ?? 'Zombie pool',
      _WaveGeneratorWaveSection.settings =>
        l10n?.waveGeneratorWaveSettingsTitle ?? 'Wave settings',
    };
  }

  void _showSectionHelp(
    AppLocalizations? l10n,
    _WaveGeneratorWaveSection section,
  ) {
    final sections = switch (section) {
      _WaveGeneratorWaveSection.fixedSpawns => [
        HelpSectionData(
          title: l10n?.waveGeneratorFixedSpawns ?? 'Fixed spawns',
          body:
              l10n?.waveGeneratorFixedSpawnsHelpBody ??
              'Fixed spawns are added directly to the wave and do not consume random-spawn points.',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorModuleHelpRow ?? 'Rows',
          body:
              l10n?.waveGeneratorModuleHelpRowBody ??
              'Rows are numbered from 1. Use “?” for a random row.',
        ),
      ],
      _WaveGeneratorWaveSection.randomSpawns => [
        HelpSectionData(
          title: l10n?.waveGeneratorModuleHelpSpending ?? 'Random spawning',
          body:
              l10n?.waveGeneratorModuleHelpSpendingBody ??
              'Random spawns buy zombies from the effective pool with the points available to this wave.',
        ),
        HelpSectionData(
          title:
              l10n?.waveGeneratorDisableRandomSpawns ?? 'Disable random spawns',
          body: l10n?.waveGeneratorDisableRandomSpawnsHint ?? '',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorWavePointStart ?? 'WavePointStart',
          body: l10n?.waveGeneratorWavePointStartHint ?? '',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorWavePointIncrement ?? 'WavePointIncrement',
          body: l10n?.waveGeneratorWavePointIncrementHint ?? '',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorWavePointOverride ?? 'WavePointOverride',
          body: l10n?.waveGeneratorWavePointOverrideHint ?? '',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorPointTrajectory ?? 'Point trajectory',
          body:
              l10n?.waveGeneratorPointTrajectoryHelpBody ??
              'The preview shows the effective random-spawn points calculated from the current configuration.',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorStatisticalPreview ?? 'Preview',
          body: l10n?.waveGeneratorExpectationPoolNote ?? '',
        ),
      ],
      _WaveGeneratorWaveSection.pool => [
        HelpSectionData(
          title:
              l10n?.waveGeneratorCurrentPool ?? 'Current effective zombie pool',
          body: l10n?.waveGeneratorModuleHelpPoolBody ?? '',
        ),
        HelpSectionData(
          title:
              l10n?.waveGeneratorWavePoolAdd ??
              'Added to the pool on this wave',
          body:
              l10n?.waveGeneratorWavePoolAddHelpBody ??
              'Zombies added here become available from this wave onward.',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorPoolCompatibilityTitle ?? 'Compatibility',
          body:
              l10n?.waveGeneratorPoolCompatibilityHelpBody ??
              'Only standard zombie types are supported in this pool.',
        ),
      ],
      _WaveGeneratorWaveSection.settings => [
        HelpSectionData(
          title:
              l10n?.waveGeneratorWaitUntilAllDie ??
              'Wait until all zombies die',
          body:
              l10n?.waveGeneratorWaitUntilAllDieHelpBody ??
              'Controls whether this wave waits for all zombies from the previous wave to be defeated.',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorSpawnPlantFood ?? 'Plant Food count',
          body:
              l10n?.waveGeneratorSpawnPlantFoodHelpBody ??
              'Sets how many zombies in this wave carry Plant Food.',
        ),
        HelpSectionData(
          title: l10n?.columnsDragged ?? 'Columns dragged',
          body: l10n?.waveGeneratorBlackHoleFieldHint ?? '',
        ),
        HelpSectionData(
          title: l10n?.waveGeneratorWaveSpawnTime ?? 'Wave spawn delay',
          body: l10n?.waveGeneratorWaveSpawnTimeHint ?? '',
        ),
      ],
    };

    showEditorHelpDialog(
      context,
      title: switch (section) {
        _WaveGeneratorWaveSection.fixedSpawns =>
          l10n?.waveGeneratorFixedSpawnsHelpTitle ?? 'Fixed spawns',
        _WaveGeneratorWaveSection.randomSpawns =>
          l10n?.waveGeneratorRandomSpawnsHelpTitle ?? 'Random spawns',
        _WaveGeneratorWaveSection.pool =>
          l10n?.waveGeneratorZombiePoolHelpTitle ?? 'Zombie pool',
        _WaveGeneratorWaveSection.settings =>
          l10n?.waveGeneratorWaveSettingsHelpTitle ?? 'Wave settings',
      },
      sections: sections,
    );
  }

  String _fixedSpawnsSummary(AppLocalizations? l10n) {
    if (_wave.zombies.isEmpty) {
      return l10n?.waveGeneratorFixedSummaryEmpty ?? 'No fixed spawns';
    }
    final spawnLabel = _wave.zombies.length == 1
        ? '1 fixed spawn'
        : '${_wave.zombies.length} fixed spawns';
    return l10n?.waveGeneratorFixedSummary(_wave.zombies.length) ?? spawnLabel;
  }

  String _randomSpawnsSummary(AppLocalizations? l10n, int points) {
    if (_wave.disableRandomSpawns) {
      return l10n?.waveGeneratorRandomSummaryDisabled ??
          'No random spawns on this wave';
    }
    if (_wave.wavePointStart != null) {
      return l10n?.waveGeneratorRandomLocalSummary(points) ??
          'Enabled · $points ${points == 1 ? 'point' : 'points'} · '
              'Current-wave points';
    }
    return l10n?.waveGeneratorRandomSummary(points) ??
        'Enabled · $points ${points == 1 ? 'point' : 'points'}';
  }

  String _poolSummary(AppLocalizations? l10n, List<String> effectivePool) {
    final currentCount = effectivePool.toSet().length;
    final addedCount = _wave.addToZombiePool.map((e) => e.type).toSet().length;
    if (addedCount == 0) {
      return l10n?.waveGeneratorPoolSummaryNoAdditions(currentCount) ??
          'Current: $currentCount ${currentCount == 1 ? 'type' : 'types'} · '
              'No additions on this wave';
    }
    return l10n?.waveGeneratorPoolSummary(currentCount, addedCount) ??
        'Current: $currentCount ${currentCount == 1 ? 'type' : 'types'} · '
            'Added $addedCount on this wave';
  }

  String _settingsSummary(AppLocalizations? l10n) {
    final parts = <String>[];
    if (_wave.waveSpawnTime != null) {
      parts.add(waveSpawnDelaySummary(l10n!, _generatorData, _wave));
    }
    if (_wave.waitUntilAllZombiesDie == true) {
      parts.add(l10n?.waveGeneratorWaitStatus ?? 'Wait for previous wave');
    }
    final plantFood = _wave.spawnPlantFoodCount;
    if (plantFood != null && plantFood > 0) {
      parts.add(
        l10n?.waveGeneratorWaveSettingsPlantFoodSummary(plantFood) ??
            'Plant Food ×$plantFood',
      );
    }
    final blackHole = _wave.colNumPlantIsDragged;
    if (blackHole != null && blackHole > 0) {
      parts.add(
        l10n?.waveGeneratorWaveSettingsBlackHoleSummary(blackHole) ??
            'Spacetime black hole: $blackHole columns',
      );
    }
    return parts.isEmpty
        ? (l10n?.waveGeneratorWaveSettingsDefaultSummary ?? 'Default settings')
        : parts.join(' · ');
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String summary,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(summary),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOverviewPage(
    AppLocalizations? l10n,
    int points,
    List<String> effectivePool,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOverviewCard(
          icon: Icons.format_list_numbered,
          title: _sectionTitle(l10n, _WaveGeneratorWaveSection.fixedSpawns),
          summary: _fixedSpawnsSummary(l10n),
          onTap: () => setState(
            () => _activeSection = _WaveGeneratorWaveSection.fixedSpawns,
          ),
        ),
        const SizedBox(height: 8),
        _buildOverviewCard(
          icon: Icons.casino_outlined,
          title: _sectionTitle(l10n, _WaveGeneratorWaveSection.randomSpawns),
          summary: _randomSpawnsSummary(l10n, points),
          onTap: () => setState(
            () => _activeSection = _WaveGeneratorWaveSection.randomSpawns,
          ),
        ),
        const SizedBox(height: 8),
        _buildOverviewCard(
          icon: Icons.groups_outlined,
          title: _sectionTitle(l10n, _WaveGeneratorWaveSection.pool),
          summary: _poolSummary(l10n, effectivePool),
          onTap: () =>
              setState(() => _activeSection = _WaveGeneratorWaveSection.pool),
        ),
        const SizedBox(height: 8),
        _buildOverviewCard(
          icon: Icons.tune,
          title: _sectionTitle(l10n, _WaveGeneratorWaveSection.settings),
          summary: _settingsSummary(l10n),
          onTap: () => setState(
            () => _activeSection = _WaveGeneratorWaveSection.settings,
          ),
        ),
      ],
    );
  }

  Widget _buildFixedSpawnsPage(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildLaneRows(context, theme, l10n),
      ),
    );
  }

  Widget _buildRandomSpawnsPage(
    ThemeData theme,
    AppLocalizations? l10n,
    int points,
    bool showExpectation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: SwitchListTile(
            title: Text(
              l10n?.waveGeneratorDisableRandomSpawns ??
                  'Disable random spawns (DisableRandomSpawns)',
            ),
            value: _wave.disableRandomSpawns,
            onChanged: (value) {
              _wave = _copyWave(disableRandomSpawns: value);
              _sync();
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.paid_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              l10n?.waveGeneratorEffectiveRandomPoints(points) ??
                  'Random-spawn points: $points',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabeledNumberField(
                  controller: _pointStartCtrl,
                  label:
                      l10n?.waveGeneratorWavePointStart ??
                      'Wave point start (WavePointStart)',
                  onChanged: (value) {
                    final trimmed = value.trim();
                    _wave = trimmed.isEmpty
                        ? _copyWave(clearWavePointStart: true)
                        : _copyWave(wavePointStart: int.tryParse(trimmed));
                    _sync();
                  },
                ),
                const SizedBox(height: 12),
                _buildLabeledNumberField(
                  controller: _pointIncrementCtrl,
                  label:
                      l10n?.waveGeneratorWavePointIncrement ??
                      'Wave point increment (WavePointIncrement)',
                  enabled: _wave.wavePointStart != null,
                  onChanged: (value) {
                    final trimmed = value.trim();
                    _wave = trimmed.isEmpty
                        ? _copyWave(clearWavePointIncrement: true)
                        : _copyWave(wavePointIncrement: int.tryParse(trimmed));
                    _sync();
                  },
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n?.waveGeneratorWavePointOverride ??
                        'Reset point trajectory (WavePointOverride)',
                  ),
                  value: _wave.wavePointOverride ?? false,
                  onChanged: _wave.wavePointStart == null
                      ? null
                      : (value) {
                          _wave = _copyWave(wavePointOverride: value);
                          _sync();
                        },
                ),
                const SizedBox(height: 8),
                _buildPointTrajectoryPreview(l10n),
              ],
            ),
          ),
        ),
        if (showExpectation) ...[
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                l10n?.waveGeneratorStatisticalPreview ?? 'Statistical preview',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                l10n?.waveGeneratorExpectationTapHint ??
                    'View random-spawn preview',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showExpectation,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPoolPage(
    ThemeData theme,
    AppLocalizations? l10n,
    List<String> effectivePool,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.waveGeneratorCurrentPool ?? 'Current effective zombie pool',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (effectivePool.isEmpty)
              Text(
                l10n?.waveGeneratorCurrentPoolEmpty ??
                    'The effective zombie pool is empty.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in effectivePool)
                    WaveGeneratorZombieTile(
                      style: WaveGeneratorZombieTileStyle.poolCompact,
                      localizedName: _zombieDisplayName(type),
                      codename: _zombieCodename(type),
                      iconPath: _zombieIcon(type),
                    ),
                ],
              ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.waveGeneratorWavePoolAdd ??
                        'Added to the pool on this wave',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: l10n?.addType ?? 'Add',
                  onPressed: _addPoolEntry,
                ),
              ],
            ),
            if (_wave.addToZombiePool.isEmpty)
              Text(
                l10n?.waveGeneratorWavePoolNoChanges ??
                    'This wave does not add zombies to the pool.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _wave.addToZombiePool.length; i++)
                    WaveGeneratorZombieTile(
                      style: WaveGeneratorZombieTileStyle.poolCompact,
                      localizedName: _zombieDisplayName(
                        _wave.addToZombiePool[i].type,
                      ),
                      codename: _zombieCodename(_wave.addToZombiePool[i].type),
                      iconPath: _zombieIcon(_wave.addToZombiePool[i].type),
                      onDelete: () => _removePoolEntry(i),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage(AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n?.waveGeneratorWaitUntilAllDie ??
                    'Wait until all zombies die (WaitUntilAllZombiesDie)',
              ),
              value: _wave.waitUntilAllZombiesDie ?? false,
              onChanged: (value) {
                _wave = _copyWave(waitUntilAllZombiesDie: value);
                _sync();
              },
            ),
            const SizedBox(height: 12),
            _buildLabeledNumberField(
              controller: _plantFoodCtrl,
              label:
                  l10n?.waveGeneratorSpawnPlantFood ??
                  'Plant Food count (SpawnPlantFoodCount)',
              onChanged: (value) {
                final trimmed = value.trim();
                _wave = trimmed.isEmpty
                    ? _copyWave(clearSpawnPlantFood: true)
                    : _copyWave(spawnPlantFoodCount: int.tryParse(trimmed));
                _sync();
              },
            ),
            const SizedBox(height: 12),
            _buildLabeledNumberField(
              controller: _blackHoleCtrl,
              label:
                  l10n?.columnsDragged ??
                  'Columns dragged (ColNumPlantIsDragged)',
              onChanged: (value) {
                final trimmed = value.trim();
                _wave = trimmed.isEmpty
                    ? _copyWave(clearColNumPlantIsDragged: true)
                    : _copyWave(colNumPlantIsDragged: int.tryParse(trimmed));
                _sync();
              },
            ),
            const SizedBox(height: 12),
            _buildLabeledNumberField(
              controller: _waveSpawnTimeCtrl,
              label:
                  l10n?.waveGeneratorWaveSpawnTime ??
                  'Wave spawn time (WaveSpawnTime)',
              onChanged: (value) {
                final trimmed = value.trim();
                _wave = trimmed.isEmpty
                    ? _copyWave(clearWaveSpawnTime: true)
                    : _copyWave(waveSpawnTime: num.tryParse(trimmed));
                _sync();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = WaveGeneratorPointAnalysis.pointsAtWave(
      _generatorData,
      widget.waveIndex,
    );
    final showExpectation = WaveGeneratorPointAnalysis.showExpectationForWave(
      _generatorData,
      widget.waveIndex,
    );
    final effectivePool = WaveGeneratorPointAnalysis.poolAtWave(
      _generatorData,
      widget.waveIndex,
    );
    final activeSection = _activeSection;

    final body = switch (activeSection) {
      null => _buildOverviewPage(l10n, points, effectivePool),
      _WaveGeneratorWaveSection.fixedSpawns => _buildFixedSpawnsPage(
        theme,
        l10n,
      ),
      _WaveGeneratorWaveSection.randomSpawns => _buildRandomSpawnsPage(
        theme,
        l10n,
        points,
        showExpectation,
      ),
      _WaveGeneratorWaveSection.pool => _buildPoolPage(
        theme,
        l10n,
        effectivePool,
      ),
      _WaveGeneratorWaveSection.settings => _buildSettingsPage(l10n),
    };

    return PopScope(
      canPop: activeSection == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _activeSection != null) {
          setState(() => _activeSection = null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n?.back ?? 'Back',
            onPressed: activeSection == null
                ? widget.onBack
                : () => setState(() => _activeSection = null),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activeSection == null
                    ? (l10n?.customZombieWaveItem(widget.waveIndex) ??
                          'Wave ${widget.waveIndex}')
                    : _sectionTitle(l10n, activeSection),
              ),
              Text(
                activeSection == null
                    ? (l10n?.waveGeneratorWaveScreenSubtitle ??
                          'Wave Generator module')
                    : (l10n?.customZombieWaveItem(widget.waveIndex) ??
                          'Wave ${widget.waveIndex}'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            if (activeSection != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: l10n?.tooltipAboutSection ?? 'About this section',
                onPressed: () => _showSectionHelp(l10n, activeSection),
              ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics:
                activeSection == _WaveGeneratorWaveSection.fixedSpawns &&
                    _zombieDragging
                ? const NeverScrollableScrollPhysics()
                : null,
            padding: const EdgeInsets.all(16),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _buildZombieEditSheetFields(
    BuildContext ctx,
    int index,
    WaveGeneratorZombieEntryData zombie,
    StateSetter setModalState,
  ) {
    final l10n = AppLocalizations.of(context);
    final alias = _zombieBaseId(zombie.type);
    final isTargetZombie =
        alias.startsWith('zombie_target_arrow') ||
        alias.startsWith('zombie_target_bottle');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isTargetZombie)
          TextFormField(
            initialValue: zombie.targetValidTime?.toString() ?? '',
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText:
                  l10n?.waveGeneratorZombieTargetValidTime ??
                  'Target valid time (TargetValidTime)',
              helperText: l10n?.waveGeneratorZombieTargetValidTimeHint,
              helperMaxLines: 3,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = int.tryParse(v.trim());
              final current = _wave.zombies[index];
              _updateZombie(
                index,
                WaveGeneratorZombieEntryData(
                  type: current.type,
                  row: current.row,
                  level: current.level,
                  targetValidTime: parsed,
                  riseGridX: current.riseGridX,
                  riseGridY: current.riseGridY,
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        if (_generatorData.isRiseFromGroundMode)
          WaveGeneratorPositionFields(
            rows: _rowCount,
            columns: LevelParser.getGridDimensionsFromFile(widget.levelFile).$2,
            x: _wave.zombies[index].riseGridX,
            y: _wave.zombies[index].riseGridY,
            onChanged: (x, y) {
              final current = _wave.zombies[index];
              final updated =
                  WaveGeneratorZombieEntryData.fromJson(current.toJson())
                    ..riseGridX = x
                    ..riseGridY = y;
              _updateZombie(index, updated);
              setModalState(() {});
            },
          ),
      ],
    );
  }

  Widget _buildLaneRows(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return ZombieRowLaneDragDropEditor(
      maxRow: _rowCount,
      rowLabel: (row) => l10n?.rowN(row) ?? 'Row $row',
      randomRowLabel: l10n?.randomRow ?? l10n?.random ?? 'Random row',
      items: _wave.zombies.asMap().entries.map((entry) {
        final idx = entry.key;
        final z = entry.value;
        final isElite = _isEliteRtid(z.type);
        final level = _levelForZombie(idx);
        return ZombieLaneIconData(
          identity: z,
          listIndex: idx,
          rowValue: _rowValue(z.row),
          iconPath: _zombieIcon(z.type),
          levelDisplay: isElite ? 'E' : (level == null ? '0' : '$level'),
          isElite: isElite,
          isCustom: CustomZombieLevelUtils.isCustomZombieRtid(z.type),
          isMissingCustomZombie: CustomZombieLevelUtils.isMissingCustomZombie(
            widget.levelFile,
            z.type,
          ),
        );
      }).toList(),
      onTap: _showZombieEditSheet,
      onMove: _handleZombieDragDropMove,
      onAddToRow: (row) => _addZombie(rowValue: row),
      onDraggingChanged: (dragging) =>
          setState(() => _zombieDragging = dragging),
    );
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final zombie = _wave.zombies[index];
    final iconPath = _zombieIcon(zombie.type);
    final displayName = _zombieDisplayName(zombie.type);
    final isElite = _isEliteRtid(zombie.type);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        var rowValue = _rowValue(zombie.row);
        var levelValue = _levelForZombie(index) ?? 0;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZombieEditSheetIdentityTile(
                      iconPath: iconPath,
                      displayName: displayName,
                      isCustom: false,
                      onChange: () => _changeZombieTypeFromSheet(
                        sheetContext: ctx,
                        index: index,
                        currentRow: rowValue == 0 ? '?' : '$rowValue',
                        levelValue: levelValue,
                        isElite: isElite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EditorResponsiveInputField(
                      label: l10n?.row ?? 'Row',
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      builder: (context, decoration) =>
                          DropdownButtonFormField<int>(
                            itemHeight: null,
                            isExpanded: true,
                            initialValue: rowValue,
                            decoration: decoration,
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Text(l10n?.random ?? 'Random'),
                              ),
                              ...List.generate(_rowCount, (i) => i + 1).map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(l10n?.rowN(v) ?? 'Row $v'),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setModalState(() => rowValue = v);
                              _setZombieRow(index, v);
                            },
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (isElite)
                      Text(
                        l10n?.eliteZombiesUseDefaultLevel ??
                            'Elite zombies use default level.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else ...[
                      SwitchListTile(
                        title: Text(l10n?.autoLevel ?? 'Auto level'),
                        value: levelValue == 0,
                        onChanged: (v) {
                          final nextLevel = v ? 0 : 1;
                          setModalState(() => levelValue = nextLevel);
                          _setZombieLevel(index, v ? null : 1);
                        },
                      ),
                      if (levelValue != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.levelFormat(levelValue) ??
                                  'Level: $levelValue',
                            ),
                            Slider(
                              value: levelValue.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: '$levelValue',
                              onChanged: (v) {
                                final newLevel = v.round();
                                setModalState(() => levelValue = newLevel);
                                _setZombieLevel(index, newLevel);
                              },
                            ),
                          ],
                        ),
                    ],
                    const SizedBox(height: 12),
                    _buildZombieEditSheetFields(
                      ctx,
                      index,
                      zombie,
                      setModalState,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final rowStr = rowValue == 0 ? '?' : '$rowValue';
                              final copy = WaveGeneratorZombieEntryData(
                                type: zombie.type,
                                row: rowStr,
                                targetValidTime:
                                    _wave.zombies[index].targetValidTime,
                                riseGridX: _wave.zombies[index].riseGridX,
                                riseGridY: _wave.zombies[index].riseGridY,
                              );
                              final newIndex = _wave.zombies.length;
                              _setZombieLevelInMemory(
                                newIndex,
                                zombie.type,
                                isElite
                                    ? null
                                    : (levelValue == 0 ? null : levelValue),
                              );
                              _wave = _copyWave(
                                zombies: [..._wave.zombies, copy],
                              );
                              _sync();
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.copy),
                            label: Text(l10n?.copy ?? 'Copy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _removeZombie(index);
                            },
                            icon: const Icon(Icons.delete),
                            label: Text(l10n?.delete ?? 'Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
