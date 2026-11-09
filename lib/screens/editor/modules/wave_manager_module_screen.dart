import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_escalation_runtime.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/wave_flag_strip.dart';

/// Wave manager module editor. Ported from WaveManagerModulesPropertiesEP.kt
class WaveManagerModuleScreen extends StatefulWidget {
  const WaveManagerModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    required this.onOpenWaveTimeline,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final VoidCallback onOpenWaveTimeline;

  @override
  State<WaveManagerModuleScreen> createState() =>
      _WaveManagerModuleScreenState();
}

class _WaveManagerModuleScreenState extends State<WaveManagerModuleScreen> {
  static const _objClass = 'WaveManagerModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late WaveManagerModuleData _data;
  late TextEditingController _startWaveCtrl;
  late TextEditingController _startPointsCtrl;
  late TextEditingController _pointIncrementCtrl;
  bool _pointSpawningEnabled = true;

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
        objClass: 'WaveManagerModuleProperties',
        objData: WaveManagerModuleData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }

    try {
      _data = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = WaveManagerModuleData();
    }

    _pointSpawningEnabled = _data.dynamicZombies.isNotEmpty;
    if (_data.dynamicZombies.isEmpty) {
      _data.dynamicZombies.add(DynamicZombieGroup());
    } else {
      for (final group in _data.dynamicZombies) {
        while (group.zombieLevel.length < group.zombiePool.length) {
          group.zombieLevel.add(1);
        }
      }
    }

    final hasLastStand = widget.levelFile.objects.any(
      (o) => o.objClass == 'LastStandMinigameProperties',
    );
    if (hasLastStand && _data.manualStartup != true) {
      _data.manualStartup = true;
      _sync();
    }

    final first = _data.dynamicZombies.first;
    _startWaveCtrl = TextEditingController(text: '${first.startingWave}');
    _startPointsCtrl = TextEditingController(text: '${first.startingPoints}');
    _pointIncrementCtrl = TextEditingController(
      text: '${first.pointIncrement}',
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _isYetiZombie(String id) {
    return id == 'yeti' || id == 'treasureyeti' || id == 'treasureyeti_egypt';
  }

  void _showYetiZombieBlockedMessage(AppLocalizations? l10n) {
    _showBlockedMessage(
      l10n?.yetiZombiesNotAllowed ?? 'Yetis are not allowed here',
    );
  }

  void _showBlockedMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  DynamicZombieGroup get _firstGroup => _data.dynamicZombies.first;

  void _updateFirstGroup({
    int? startingWave,
    int? startingPoints,
    int? pointIncrement,
  }) {
    _firstGroup.startingWave = startingWave ?? _firstGroup.startingWave;
    _firstGroup.startingPoints = startingPoints ?? _firstGroup.startingPoints;
    _firstGroup.pointIncrement = pointIncrement ?? _firstGroup.pointIncrement;
    _sync();
  }

  void _addZombie() {
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      if (_isYetiZombie(selectedId)) {
        _showYetiZombieBlockedMessage(l10n);
        return;
      }
      final isElite = ZombieRepository().isElite(selectedId);
      if (isElite) {
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
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      _firstGroup.zombiePool.add(rtid);
      _firstGroup.zombieLevel.add(1);
      _sync();
    });
  }

  Future<void> _removeZombie(int index) async {
    if (index >= _firstGroup.zombiePool.length) return;
    final removed = _firstGroup.zombiePool[index];
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
    _firstGroup.zombiePool.removeAt(index);
    if (index < _firstGroup.zombieLevel.length) {
      _firstGroup.zombieLevel.removeAt(index);
    }
    _sync();
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _changeLevel(int index, int delta) {
    final current = _firstGroup.zombieLevel[index];
    final next = (current + delta).clamp(1, 10);
    _firstGroup.zombieLevel[index] = next;
    _sync();
  }

  @override
  void dispose() {
    _startWaveCtrl.dispose();
    _startPointsCtrl.dispose();
    _pointIncrementCtrl.dispose();
    super.dispose();
  }

  String _localizedText(
    BuildContext context, {
    required String zh,
    required String en,
  }) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale.startsWith('zh') ? zh : en;
  }

  String _waveManagerPropsTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.moduleTitle_WaveManagerProperties ??
        _localizedText(context, zh: '波次管理属性', en: 'Wave Manager Properties');
  }

  String _currentWaveManagerPropsText(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context);
    return l10n?.waveManagerPropsCurrent(value) ??
        _localizedText(context, zh: '当前值：$value', en: 'Current: $value');
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
    final isDark = theme.brightness == Brightness.dark;
    // Light: light green card, purple section titles. Dark: vibrant green card, purplish-pink titles.
    final propsCardColor = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE8F5E9);
    final propsTextColor = isDark ? Colors.white : const Color(0xFF1B5E20);
    final propsSubtextColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF689F38);
    final sectionTitleColor = isDark ? pvzPurpleDark : pvzPurpleLight;
    final sectionColor = theme.colorScheme.primary;
    final contentCardColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;

    final escalationRuntime = LevelEscalationRuntime.resolve(
      widget.levelFile,
      waveManagerAlias: _alias,
    );
    final pointSpawningOverridden =
        _pointSpawningEnabled && escalationRuntime.isEffective;
    final ownPropsInfo = RtidParser.parse(_data.waveManagerProps ?? '');
    final ownPropsObj = ownPropsInfo?.source == 'CurrentLevel'
        ? widget.levelFile.objects.firstWhereOrNull(
            (object) =>
                object.objClass == 'WaveManagerProperties' &&
                object.aliases?.contains(ownPropsInfo!.alias) == true,
          )
        : null;
    final escalationPropsInfo = RtidParser.parse(
      escalationRuntime.escalationWaveManagerProps ?? '',
    );
    final escalationPropsObj = escalationPropsInfo?.source == 'CurrentLevel'
        ? widget.levelFile.objects.firstWhereOrNull(
            (object) =>
                object.objClass == 'WaveManagerProperties' &&
                object.aliases?.contains(escalationPropsInfo!.alias) == true,
          )
        : null;
    final configurationProvidedByEscalation =
        ownPropsObj == null && escalationPropsObj != null;
    final propsObj = ownPropsObj ?? escalationPropsObj;
    final fallbackPropsObj = widget.levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'WaveManagerProperties',
    );
    final actualWaveMgrAlias =
        (propsObj ?? fallbackPropsObj)?.aliases?.firstOrNull;
    final isPropsValid = propsObj != null;
    final waveManagerPropsTitle = _waveManagerPropsTitle(context);
    final providedPropsRtid = escalationRuntime.escalationWaveManagerProps;
    final currentWaveManagerPropsText = configurationProvidedByEscalation
        ? (l10n?.waveManagerPropsProvidedByEscalation(
                providedPropsRtid ?? 'null',
              ) ??
              'Runtime configuration is provided by Escalation Spawning: '
                  '${providedPropsRtid ?? 'null'}')
        : _currentWaveManagerPropsText(
            context,
            _data.waveManagerProps ?? 'null',
          );
    final showPropsFixButton = !isPropsValid && actualWaveMgrAlias != null;

    // Read the linked WaveManagerProperties for the wave ruler.
    WaveManagerData? linkedWaveManager;
    try {
      final objData = propsObj?.objData;
      if (objData is Map) {
        linkedWaveManager = WaveManagerData.fromJson(
          Map<String, dynamic>.from(objData),
        );
      }
    } catch (_) {
      linkedWaveManager = null;
    }
    final linkedWaves = linkedWaveManager?.waves ?? const <List<String>>[];
    final rawFlagInterval = linkedWaveManager?.flagWaveInterval ?? 0;
    final linkedFlagInterval = rawFlagInterval <= 0 ? 10 : rawFlagInterval;
    Widget buildPropsDetails() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            waveManagerPropsTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPropsValid ? propsTextColor : theme.colorScheme.onError,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentWaveManagerPropsText,
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
                l10n?.waveManagerContainerMissing ??
                    'No WaveManagerProperties object found.',
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }

    Widget buildPropsFixButton() {
      return FilledButton(
        key: const ValueKey('waveManagerPropsFixButton'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          l10n?.fixToAlias(actualWaveMgrAlias!) ?? 'Fix to $actualWaveMgrAlias',
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      );
    }

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
            onPressed: () {
              showEditorHelpDialog(
                context,
                isEvent: false,
                title: l10n?.waveManagerModule ?? 'Wave manager module',
                themeColor: sectionTitleColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.waveManagerHelpOverview ??
                        'Enables wave manager. Without this module, wave editing is disabled.',
                  ),
                  HelpSectionData(
                    title: l10n?.pointsSection ?? 'Points',
                    body:
                        l10n?.waveManagerHelpPoints ??
                        'Point-based spawning uses this pool. Avoid elite and custom zombies.',
                  ),
                ],
              );
            },
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
            if (escalationRuntime.hasCompetingWaveManagerProps) ...[
              const SizedBox(height: 8),
              EditorWarningBanner(
                margin: EdgeInsets.zero,
                message:
                    escalationRuntime.order ==
                        LevelEscalationModuleOrder.afterWaveManager
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
                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                statusIcon,
                                const SizedBox(width: 8),
                                Expanded(child: buildPropsDetails()),
                                const SizedBox(width: 4),
                                chevron,
                              ],
                            ),
                            if (showPropsFixButton) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: buildPropsFixButton(),
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
                                buildPropsDetails(),
                                if (showPropsFixButton) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 440,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: buildPropsFixButton(),
                                      ),
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
            Card(
              color: contentCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.enablePointSpawning ??
                                'Enable point spawning',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!pointSpawningOverridden) ...[
                            const SizedBox(height: 4),
                            Text(
                              _pointSpawningEnabled
                                  ? (l10n?.pointSpawningEnabledDesc ??
                                        'Enabled (uses extra points for spawning)')
                                  : (l10n?.pointSpawningDisabledDesc ??
                                        'Disabled (wave events only)'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Switch(
                      value: _pointSpawningEnabled,
                      onChanged: (v) {
                        setState(() {
                          _pointSpawningEnabled = v;
                          if (v) {
                            if (_data.dynamicZombies.isEmpty) {
                              _data.dynamicZombies.add(
                                DynamicZombieGroup(
                                  startingWave: 3,
                                  startingPoints: 100,
                                  pointIncrement: 40,
                                  zombiePool: [],
                                  zombieLevel: [],
                                ),
                              );
                            }
                          } else {
                            _data.dynamicZombies = [];
                          }
                          _sync();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (pointSpawningOverridden) ...[
              const SizedBox(height: 8),
              EditorWarningBanner(
                message:
                    l10n?.waveManagerPointsOverriddenByEscalation ??
                    'Escalation Spawning supplies the wave container and '
                        'overrides point spawning. Remove Escalation Spawning '
                        'to use point spawning.',
              ),
            ],
            if (_pointSpawningEnabled) ...[
              const SizedBox(height: 16),
              Text(
                l10n?.pointSettings ?? 'Point settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sectionColor,
                ),
              ),
              if (linkedWaves.isNotEmpty) ...[
                WaveFlagStrip(
                  color: sectionColor,
                  waveCount: linkedWaves.length,
                  isFlagWave: (w) =>
                      w % linkedFlagInterval == 0 || w == linkedWaves.length,
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 8),
              Card(
                color: contentCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _intField(
                        controller: _startWaveCtrl,
                        label:
                            l10n?.startingWave ??
                            'Starting wave (StartingWave, zero-based)',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) _updateFirstGroup(startingWave: n);
                        },
                      ),
                      const SizedBox(height: 8),
                      _intField(
                        controller: _startPointsCtrl,
                        label:
                            l10n?.startingPoints ??
                            'Starting points (StartingPoints)',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) _updateFirstGroup(startingPoints: n);
                        },
                      ),
                      const SizedBox(height: 8),
                      _intField(
                        controller: _pointIncrementCtrl,
                        label:
                            l10n?.pointIncrement ??
                            'Point increment (PointIncrementPerWave)',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) _updateFirstGroup(pointIncrement: n);
                        },
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
              ..._firstGroup.zombiePool.asMap().entries.map((entry) {
                final idx = entry.key;
                final rtid = entry.value;
                final alias = RtidParser.parse(rtid)?.alias ?? rtid;
                final typeName = ZombiePropertiesRepository.getTypeNameByAlias(
                  alias,
                );
                final info = ZombieRepository().getZombieById(typeName);
                final nameKey =
                    info?.name ?? ZombieRepository().getName(typeName);
                final displayName = ResourceNames.lookup(context, nameKey);
                final cost = ZombiePropertiesRepository.getStats(typeName).cost;
                final level = _firstGroup.zombieLevel.elementAt(idx);
                final iconPath = info?.iconAssetPath;
                final details = Row(
                  key: ValueKey('waveManagerZombiePoolDetails-$idx'),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n?.zombiePointCost(cost) ?? 'Point cost: $cost',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            l10n?.levelFormat(level) ?? 'Level: $level',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: level >= 6
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                final actions = Row(
                  key: ValueKey('waveManagerZombiePoolActions-$idx'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      tooltip: l10n?.remove ?? 'Remove',
                      onPressed: level > 1 ? () => _changeLevel(idx, -1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: l10n?.add ?? 'Add',
                      onPressed: level < 10 ? () => _changeLevel(idx, 1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: l10n?.delete ?? 'Delete',
                      onPressed: () => _removeZombie(idx),
                    ),
                  ],
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: contentCardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 560) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              details,
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: actions,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: details),
                            actions,
                          ],
                        );
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _intField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
