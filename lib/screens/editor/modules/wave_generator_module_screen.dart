import 'package:flutter/material.dart';
import 'package:c_editor/widgets/camel_minigame_conflicts.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Global settings editor for [WaveGeneratorProperties].
class WaveGeneratorModuleScreen extends StatefulWidget {
  const WaveGeneratorModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<WaveGeneratorModuleScreen> createState() =>
      _WaveGeneratorModuleScreenState();
}

class _WaveGeneratorModuleScreenState extends State<WaveGeneratorModuleScreen> {
  static const _objClass = 'WaveGeneratorProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late WaveGeneratorPropertiesData _data;
  late TextEditingController _flagIntervalCtrl;
  late TextEditingController _spendingPointsCtrl;
  late TextEditingController _spendingIncrementCtrl;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    _moduleObj = WaveGeneratorLevelUtils.loadOrCreate(
      widget.levelFile,
      widget.rtid,
    );
    _data = WaveGeneratorLevelUtils.parseObject(_moduleObj);
    _flagIntervalCtrl = TextEditingController(
      text: '${_data.flagWaveInterval}',
    );
    _spendingPointsCtrl = TextEditingController(
      text: '${_data.waveSpendingPoints}',
    );
    _spendingIncrementCtrl = TextEditingController(
      text: '${_data.waveSpendingPointIncrement}',
    );
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

  Map<int, Map<int, int?>> _readAllWaveZombieLevels(dynamic objData) {
    final waves = _waveJsonList(objData);
    if (waves == null) return {};
    final result = <int, Map<int, int?>>{};
    for (var waveIndex = 0; waveIndex < waves.length; waveIndex++) {
      final wave = waves[waveIndex];
      if (wave is! Map || wave['Zombies'] is! List) continue;
      final zombies = wave['Zombies'] as List;
      final levels = <int, int?>{};
      for (var i = 0; i < zombies.length; i++) {
        final zombie = zombies[i];
        if (zombie is Map && zombie.containsKey('Level')) {
          levels[i] = _readJsonInt(zombie['Level']);
        }
      }
      if (levels.isNotEmpty) result[waveIndex] = levels;
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

  void _sync() {
    final waveZombieLevels = _readAllWaveZombieLevels(_moduleObj.objData);
    _data.syncWaveCount();
    _moduleObj.objData = _data.toJson();
    _applyWaveZombieLevels(_moduleObj.objData, waveZombieLevels);
    WaveGeneratorLevelUtils.writeData(widget.levelFile, _data);
    final writtenObj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    if (writtenObj != null) {
      _applyWaveZombieLevels(writtenObj.objData, waveZombieLevels);
      _moduleObj = writtenObj;
    }
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

  void _addPoolZombie() {
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
                  'Custom zombies are not supported in wave generator levels.',
            ),
          ),
        );
        return;
      }
      _data = WaveGeneratorPropertiesData(
        addToZombiePool: [
          ..._data.addToZombiePool,
          WaveGeneratorPoolEntryData(type: rtid),
        ],
        flagWaveInterval: _data.flagWaveInterval,
        waveCount: _data.waveCount,
        waveSpendingPoints: _data.waveSpendingPoints,
        waveSpendingPointIncrement: _data.waveSpendingPointIncrement,
        waves: _data.waves,
        isRiseFromGroundMode: _data.isRiseFromGroundMode,
        ignoreFlagCarriers: _data.ignoreFlagCarriers,
        spawnColStart: _data.spawnColStart,
        spawnColEnd: _data.spawnColEnd,
      );
      _sync();
    });
  }

  void _removePoolZombie(int index) {
    final pool = List<WaveGeneratorPoolEntryData>.from(_data.addToZombiePool)
      ..removeAt(index);
    _data = WaveGeneratorPropertiesData(
      addToZombiePool: pool,
      flagWaveInterval: _data.flagWaveInterval,
      waveCount: _data.waveCount,
      waveSpendingPoints: _data.waveSpendingPoints,
      waveSpendingPointIncrement: _data.waveSpendingPointIncrement,
      waves: _data.waves,
      isRiseFromGroundMode: _data.isRiseFromGroundMode,
      ignoreFlagCarriers: _data.ignoreFlagCarriers,
      spawnColStart: _data.spawnColStart,
      spawnColEnd: _data.spawnColEnd,
    );
    _sync();
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

  @override
  void dispose() {
    _flagIntervalCtrl.dispose();
    _spendingPointsCtrl.dispose();
    _spendingIncrementCtrl.dispose();
    super.dispose();
  }

  Widget _buildLabeledNumberField({
    required TextEditingController controller,
    required String label,
    String? helperText,
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
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            helperText: helperText,
            helperMaxLines: helperText == null ? null : 4,
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final compatibilityWarnings =
        LevelIssueRegistry.forLevel(context, widget.levelFile).where(
          (issue) =>
              issue.id == 'seeingStarsCompatibilityWarning' ||
              issue.id == 'gladiatorWaveGeneratorCompatibilityWarning',
        );
    final sectionTitleColor = theme.brightness == Brightness.dark
        ? pvzPurpleDark
        : pvzPurpleLight;

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
              title: l10n?.waveGeneratorModuleHelpTitle ?? 'Wave Generator',
              themeColor: sectionTitleColor,
              sections: [
                HelpSectionData(
                  title: l10n?.waveGeneratorModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.waveGeneratorModuleHelpOverviewBody ??
                      'Legacy embedded wave definition used in campaign-style levels. Edit individual waves on the Waves tab.',
                ),
                HelpSectionData(
                  title:
                      l10n?.waveGeneratorModuleHelpSpending ??
                      'Spending points',
                  body:
                      l10n?.waveGeneratorModuleHelpSpendingBody ??
                      'WaveSpendingPoints must be less than or equal to WaveSpendingPointIncrement or the level crashes on load.',
                ),
                HelpSectionData(
                  title:
                      l10n?.waveGeneratorModuleHelpPointTrajectory ??
                      'Point trajectory',
                  body:
                      l10n?.waveGeneratorModuleHelpPointTrajectoryBody ??
                      'The random-spawn budget advances every wave, including waves where random spawning is disabled. Per-wave point settings can temporarily replace or reset this trajectory.',
                ),
                HelpSectionData(
                  title: l10n?.waveGeneratorModuleHelpPool ?? 'Zombie pool',
                  body:
                      l10n?.waveGeneratorModuleHelpPoolBody ??
                      'AddToZombiePool extends random spawn options. Only built-in zombie types are supported.',
                ),
                HelpSectionData(
                  title:
                      l10n?.waveGeneratorModuleHelpIncompat ??
                      'Incompatibilities',
                  body:
                      l10n?.waveGeneratorModuleHelpIncompatBody ??
                      'Wave Generator may be incompatible with modules such as Seeing Stars and cause the level to crash. Use with caution.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: sectionTitleColor,
            ),
            const SizedBox(height: 16),
            for (final warning in compatibilityWarnings) ...[
              EditorWarningBanner(
                key: ValueKey(warning.id),
                margin: EdgeInsets.zero,
                title: warning.title,
                message: warning.message,
              ),
              const SizedBox(height: 16),
            ],
            CamelMinigameConflicts(
              levelFile: widget.levelFile,
              onlyIds: const {'camelMinigameNonTouchZombies'},
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.waveGeneratorModuleGlobalParams ??
                          'Global parameters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledNumberField(
                      controller: _flagIntervalCtrl,
                      label:
                          l10n?.flagWaveInterval ??
                          'Flag wave interval (FlagWaveInterval)',
                      helperText: l10n?.waveGeneratorFlagIntervalHint,
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0) {
                          _data.flagWaveInterval = n;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledNumberField(
                      controller: _spendingPointsCtrl,
                      label:
                          l10n?.waveGeneratorSpendingPoints ??
                          'Spending points (WaveSpendingPoints)',
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _data.waveSpendingPoints = n;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledNumberField(
                      controller: _spendingIncrementCtrl,
                      label:
                          l10n?.waveGeneratorSpendingPointIncrement ??
                          'Point increment (WaveSpendingPointIncrement)',
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _data.waveSpendingPointIncrement = n;
                          _sync();
                        }
                      },
                    ),
                    if (!_data.spendingPointsValid) ...[
                      const SizedBox(height: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n?.waveGeneratorSpendingCompatibilityWarning ??
                                      'The initial points exceed the per-wave increment. Existing compatibility checks mark this as a level-load crash risk.',
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        l10n?.waveGeneratorRiseFromGround ??
                            'Rise from ground mode',
                      ),
                      subtitle: Text(
                        l10n?.waveGeneratorRiseFromGroundHint ??
                            'IsRiseFromGroundMode',
                        style: theme.textTheme.bodySmall,
                      ),
                      value: _data.isRiseFromGroundMode,
                      onChanged: (v) {
                        _data.isRiseFromGroundMode = v;
                        if (v) {
                          _data.spawnColStart = 2;
                          _data.spawnColEnd = 2;
                        }
                        _sync();
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_data.isRiseFromGroundMode)
                      EditorWarningBanner(
                        title: l10n!.waveGeneratorRiseFromGroundWarningTitle,
                        message: l10n.waveGeneratorRiseFromGroundWarning,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.waveGeneratorWaveCountSummary(_data.waves.length) ??
                          'Waves: ${_data.waves.length} (edit on Waves tab)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n?.waveGeneratorInitialPool ??
                                'Initial zombie pool (AddToZombiePool)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: l10n?.addType ?? 'Add',
                          onPressed: _addPoolZombie,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_data.addToZombiePool.isEmpty)
                      Text(
                        l10n?.waveGeneratorEmptyPool ??
                            'No zombies in the initial pool.',
                        style: theme.textTheme.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _data.addToZombiePool.length; i++)
                            WaveGeneratorZombieTile(
                              style: WaveGeneratorZombieTileStyle.poolCompact,
                              localizedName: _zombieDisplayName(
                                _data.addToZombiePool[i].type,
                              ),
                              codename: _zombieCodename(
                                _data.addToZombiePool[i].type,
                              ),
                              iconPath: _zombieIcon(
                                _data.addToZombiePool[i].type,
                              ),
                              onDelete: () => _removePoolZombie(i),
                            ),
                        ],
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
