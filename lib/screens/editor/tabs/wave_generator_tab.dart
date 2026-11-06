import 'package:c_editor/data/oak_archery_preview.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show EditorFilledButton, isDesktopPlatform;
import 'package:c_editor/widgets/grid_override_preview_dialog.dart';
import 'package:c_editor/widgets/initial_kongfu_grid_items_card.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:c_editor/widgets/wave_module_preview_dialogs.dart';
import 'package:c_editor/widgets/wave_number_label.dart';

/// Waves tab for levels using [WaveGeneratorProperties] (embedded wave data).
class WaveGeneratorTab extends StatefulWidget {
  const WaveGeneratorTab({
    super.key,
    required this.levelFile,
    required this.parsed,
    required this.onChanged,
    this.onOpenModule,
    this.onEditWaveGeneratorSettings,
    required this.onEditWave,
  });

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final VoidCallback onChanged;
  final OpenModuleCallback? onOpenModule;
  final VoidCallback? onEditWaveGeneratorSettings;
  final void Function(int waveIndex) onEditWave;

  @override
  State<WaveGeneratorTab> createState() => _WaveGeneratorTabState();
}

class _WaveGeneratorTabState extends State<WaveGeneratorTab> {
  WaveGeneratorPropertiesData? _data;
  PvzObject? _obj;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant WaveGeneratorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelFile != widget.levelFile ||
        oldWidget.parsed != widget.parsed) {
      _reload();
    }
  }

  void _reload() {
    _obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    if (_obj != null) {
      _data = WaveGeneratorLevelUtils.parseObject(_obj!);
    } else {
      _data = null;
    }
  }

  void _sync() {
    if (_obj == null || _data == null) return;
    _data!.syncWaveCount();
    _obj!.objData = _data!.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addWave() {
    if (_data == null) return;
    _data!.waves = [..._data!.waves, WaveGeneratorWaveData()];
    _sync();
  }

  void _deleteWave(int index) {
    if (_data == null || index < 0 || index >= _data!.waves.length) return;
    final waves = List<WaveGeneratorWaveData>.from(_data!.waves)
      ..removeAt(index);
    _data!.waves = waves;
    _sync();
  }

  List<WaveGeneratorPoolEntryData> _cumulativeWavePoolEntriesForWave(
    WaveGeneratorPropertiesData data,
    int waveIndex,
  ) {
    final result = <WaveGeneratorPoolEntryData>[];
    final upper = waveIndex.clamp(0, data.waves.length).toInt();
    for (var i = 0; i < upper; i++) {
      result.addAll(data.waves[i].addToZombiePool);
    }
    return result;
  }

  String? _getModuleRtid(String objClass) {
    final def = widget.parsed.levelDef;
    if (def == null) return null;
    for (final rtid in def.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null || info.source != 'CurrentLevel') continue;
      final obj = widget.parsed.objectMap[info.alias];
      if (obj?.objClass == objClass) return rtid;
    }
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == objClass,
    );
    if (obj?.aliases?.isNotEmpty == true) {
      return RtidParser.build(obj!.aliases!.first, 'CurrentLevel');
    }
    return null;
  }

  DropShipPropertiesData? _getDropShipModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'DropShipProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return DropShipPropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  ArmrackPropertiesData? _getArmrackModuleData() {
    return readArmrackModuleData(widget.levelFile);
  }

  EnergyGridPropertiesData? _getEnergyGridModuleData() {
    return readEnergyGridModuleData(widget.levelFile);
  }

  HeianWindModulePropertiesData? _getHeianWindModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'HeianWindModuleProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return HeianWindModulePropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  bool _waveHasDropShipActivity(int waveIndex) {
    final dropShip = _getDropShipModuleData();
    if (dropShip == null) return false;
    return dropShip.appearWaves.any((w) => w.wave + 1 == waveIndex);
  }

  bool _waveHasArmrackActivity(int waveIndex) {
    return waveGeneratorWaveHasArmrackActivity(
      waveGeneratorWaveIndex: waveIndex,
      data: _getArmrackModuleData(),
    );
  }

  bool _waveHasEnergyGridActivity(int waveIndex) {
    return waveGeneratorWaveHasEnergyGridActivity(
      waveGeneratorWaveIndex: waveIndex,
      data: _getEnergyGridModuleData(),
    );
  }

  bool _waveHasHeianWindActivity(int waveIndex) {
    final heianWind = _getHeianWindModuleData();
    if (heianWind == null) return false;
    return heianWind.waveWindInfos.any((w) => w.waveNumber + 1 == waveIndex);
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

  Future<void> _confirmDeleteWave(int index) async {
    if (_data == null || index < 0 || index >= _data!.waves.length) return;
    final l10n = AppLocalizations.of(context);
    final waveIndex = index + 1;
    final wave = _data!.waves[index];
    final zombieCount = wave.zombies.length;
    var confirm = false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            (l10n?.deleteWave != null && l10n?.waveLabel != null)
                ? '${l10n?.deleteWave} ${l10n?.waveLabel} $waveIndex?'
                : 'Delete Wave $waveIndex?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.waveGeneratorDeleteWaveConfirm(zombieCount) ??
                    'This will remove the wave and its $zombieCount fixed '
                        '${zombieCount == 1 ? 'spawn' : 'spawns'}.',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: confirm,
                onChanged: (v) => setDialogState(() => confirm = v ?? false),
                title: Text(
                  l10n?.deleteWaveConfirmCheckbox ??
                      'I confirm permanent deletion of this wave',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: confirm ? () => Navigator.pop(ctx, true) : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n?.delete ?? 'Delete'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) _deleteWave(index);
  }

  void _openWaveEditor(int index) {
    widget.onEditWave(index + 1);
  }

  void _showExpectationDialog(int waveIndex) {
    if (_data == null) return;
    showWaveGeneratorExpectationDialog(
      context,
      data: _data!,
      waveIndex: waveIndex,
    );
  }

  void _openModule(String moduleClass, {ModuleOpenHint? hint}) {
    if (widget.onOpenModule == null) return;
    final rtid = _getModuleRtid(moduleClass);
    if (rtid == null) return;
    widget.onOpenModule!(rtid, hint: hint);
  }

  void _showHeianWindInfoDialog(BuildContext context, int waveIndex) {
    final heianWind = _getHeianWindModuleData();
    if (heianWind == null) return;
    final waves = heianWind.waveWindInfos
        .where((w) => w.waveNumber + 1 == waveIndex)
        .toList();
    if (waves.isEmpty) return;
    showHeianWindWavePreviewDialog(
      context,
      waveIndex: waveIndex,
      waves: waves,
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
              'HeianWindModuleProperties',
              hint: ModuleOpenHint(heianWindWaveNumber: waveIndex - 1),
            ),
    );
  }

  void _showDropShipInfoDialog(BuildContext context, int waveIndex) {
    final dropShip = _getDropShipModuleData();
    if (dropShip == null) return;
    final waves = dropShip.appearWaves
        .where((w) => w.wave + 1 == waveIndex)
        .toList();
    if (waves.isEmpty) return;
    showDropShipWavePreviewDialog(
      context,
      levelFile: widget.levelFile,
      waveIndex: waveIndex,
      waves: waves,
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
              'DropShipProperties',
              hint: ModuleOpenHint(dropShipWave: waves.first.wave),
            ),
    );
  }

  void _showArmrackInfoDialog(BuildContext context, int waveIndex) {
    final l10n = AppLocalizations.of(context);
    final data = _getArmrackModuleData();
    if (data == null) return;
    final moduleWave = moduleWaveForWaveGeneratorWave(waveIndex);
    final items = armrackItemsForModuleWave(data, moduleWave);
    if (items.isEmpty) return;
    final label = l10n?.armrackModuleExpectationLabel ?? 'Weapon stands';
    showArmrackGridPreviewDialog(
      context,
      levelFile: widget.levelFile,
      items: items,
      title:
          l10n?.waveGeneratorGridOverrideWavePreviewTitle(waveIndex, label) ??
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex — $label',
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
              'ArmrackProperties',
              hint: ModuleOpenHint(gridOverrideModuleWave: moduleWave),
            ),
    );
  }

  void _showEnergyGridInfoDialog(BuildContext context, int waveIndex) {
    final l10n = AppLocalizations.of(context);
    final data = _getEnergyGridModuleData();
    if (data == null) return;
    final moduleWave = moduleWaveForWaveGeneratorWave(waveIndex);
    final items = energyGridItemsForModuleWave(data, moduleWave);
    if (items.isEmpty) return;
    final label = l10n?.energyGridModuleExpectationLabel ?? 'Taiji tiles';
    showEnergyGridPreviewDialog(
      context,
      levelFile: widget.levelFile,
      items: items,
      title:
          l10n?.waveGeneratorGridOverrideWavePreviewTitle(waveIndex, label) ??
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex — $label',
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
              'EnergyGridProperties',
              hint: ModuleOpenHint(gridOverrideModuleWave: moduleWave),
            ),
    );
  }

  void _showBlackHoleInfoDialog(BuildContext context, int waveIndex, int cols) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.eventTitle_BlackHoleWaveActionProps ?? 'Black Hole'}',
        ),
        content: Text(
          l10n?.waveGeneratorBlackHoleWaveHint(cols) ??
              'Built-in black hole on this wave (ColNumPlantIsDragged: $cols).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveGeneratorSettingsCard(
    BuildContext context,
    WaveGeneratorPropertiesData data,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.tune),
            title: Text(
              l10n?.waveGeneratorGlobalParams ?? 'Wave Generator Parameters',
            ),
            subtitle: Text(
              l10n?.waveGeneratorTabSummary(
                    data.flagWaveInterval,
                    data.waveSpendingPoints,
                    data.waveSpendingPointIncrement,
                  ) ??
                  'Flag interval: ${data.flagWaveInterval}, Spending: ${data.waveSpendingPoints} + ${data.waveSpendingPointIncrement}/wave',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: widget.onEditWaveGeneratorSettings,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _reload();
    final l10n = AppLocalizations.of(context);
    final data = _data;

    if (data == null) {
      return Center(
        child: Text(
          l10n?.waveGeneratorTabMissingModule ??
              'Add Wave Generator module to edit waves.',
        ),
      );
    }

    final waveStates = WaveGeneratorPointAnalysis.calculateStates(data);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWaveGeneratorSettingsCard(context, data),
          InitialKongfuGridItemsCard(
            levelFile: widget.levelFile,
            onOpenModule: widget.onOpenModule,
          ),
          const SizedBox(height: 16),
          if (data.waves.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    l10n?.waveGeneratorNoWaves ?? 'No waves defined.',
                  ),
                ),
              ),
            )
          else
            ...List.generate(data.waves.length, (index) {
              final waveIndex = index + 1;
              final wave = data.waves[index];
              final waveState = waveStates[index];
              final isFlagWave = waveState.isFlagWave;
              final actionButtons = <({String label, VoidCallback onTap})>[];
              if (WaveGeneratorPointAnalysis.showExpectationForWave(
                data,
                waveIndex,
              )) {
                actionButtons.add((
                  label:
                      l10n?.waveGeneratorStatisticalPreview ??
                      'Statistical preview',
                  onTap: () => _showExpectationDialog(waveIndex),
                ));
              }
              if (waveIndex != data.waves.length &&
                  wave.waitUntilAllZombiesDie == true &&
                  wave.colNumPlantIsDragged != null) {
                actionButtons.add((
                  label:
                      l10n?.eventTitle_BlackHoleWaveActionProps ?? 'Black Hole',
                  onTap: () => _showBlackHoleInfoDialog(
                    context,
                    waveIndex,
                    wave.colNumPlantIsDragged!,
                  ),
                ));
              }
              if (_waveHasDropShipActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.airDropShipModuleExpectationLabel ?? 'Imp drops',
                  onTap: () => _showDropShipInfoDialog(context, waveIndex),
                ));
              }
              if (_waveHasArmrackActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.armrackModuleExpectationLabel ?? 'Weapon stands',
                  onTap: () => _showArmrackInfoDialog(context, waveIndex),
                ));
              }
              if (_waveHasEnergyGridActivity(waveIndex)) {
                actionButtons.add((
                  label:
                      l10n?.energyGridModuleExpectationLabel ?? 'Taiji tiles',
                  onTap: () => _showEnergyGridInfoDialog(context, waveIndex),
                ));
              }
              if (_waveHasHeianWindActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.heianWindModuleExpectationLabel ?? 'Divine Wind',
                  onTap: () => _showHeianWindInfoDialog(context, waveIndex),
                ));
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _WaveRowCard(
                  generator: data,
                  waveIndex: waveIndex,
                  isFlagWave: isFlagWave,
                  wave: wave,
                  waveState: waveState,
                  globalPool: data.addToZombiePool,
                  wavePoolEntries: _cumulativeWavePoolEntriesForWave(
                    data,
                    waveIndex,
                  ),
                  actionButtons: actionButtons,
                  zombieDisplayName: _zombieDisplayName,
                  zombieCodename: _zombieCodename,
                  zombieIcon: _zombieIcon,
                  onTap: () => _openWaveEditor(index),
                  onDelete: () => _confirmDeleteWave(index),
                  l10n: l10n,
                ),
              );
            }),
          const SizedBox(height: 16),
          Center(
            child: EditorFilledButton(
              onPressed: _addWave,
              icon: const Icon(Icons.add),
              label: Text(l10n?.addWave ?? 'Add wave'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveRowCard extends StatelessWidget {
  const _WaveRowCard({
    required this.generator,
    required this.waveIndex,
    required this.isFlagWave,
    required this.wave,
    required this.waveState,
    required this.globalPool,
    required this.wavePoolEntries,
    required this.actionButtons,
    required this.zombieDisplayName,
    required this.zombieCodename,
    required this.zombieIcon,
    required this.onTap,
    required this.onDelete,
    required this.l10n,
  });

  final WaveGeneratorPropertiesData generator;
  final int waveIndex;
  final bool isFlagWave;
  final WaveGeneratorWaveData wave;
  final WaveGeneratorWaveState waveState;
  final List<WaveGeneratorPoolEntryData> globalPool;
  final List<WaveGeneratorPoolEntryData> wavePoolEntries;
  final List<({String label, VoidCallback onTap})> actionButtons;
  final String Function(String rtid) zombieDisplayName;
  final String Function(String rtid) zombieCodename;
  final String? Function(String rtid) zombieIcon;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopPlatformView = isDesktopPlatform(context);
    final showRandomPool = !wave.disableRandomSpawns;
    final hasRandomPool =
        showRandomPool && (globalPool.isNotEmpty || wavePoolEntries.isNotEmpty);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactWidth = constraints.maxWidth < 560;
        final veryCompactWidth = constraints.maxWidth < 420;
        final isDesktop = isDesktopPlatformView && !compactWidth;
        final cardPadding = isDesktop ? 14.0 : 10.0;
        final waveNumber = WaveNumberLabel(
          waveNumber: waveIndex,
          isFlagWave: isFlagWave,
          fontSize: isDesktop ? 18 : 16,
          flagSize: isDesktop ? 14 : 12,
        );
        final waveNumberWidth = waveNumber
            .minimumSize(context, minWidth: isDesktop ? 52 : 28)
            .width;
        final actionColumnWidth = isDesktop
            ? 220.0
            : (constraints.maxWidth * (veryCompactWidth ? 0.26 : 0.24))
                  .clamp(86.0, 132.0)
                  .toDouble();
        final chipFontSize = isDesktop ? 12.0 : 10.5;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: waveNumberWidth,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: waveNumber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            l10n?.waveGeneratorFixedSpawnCount(
                                  waveState.fixedSpawnCount,
                                ) ??
                                'Fixed spawns: ${waveState.fixedSpawnCount}',
                            if (waveState.addedToPool.isNotEmpty)
                              l10n?.waveGeneratorPoolAddedCount(
                                    waveState.addedToPool.length,
                                  ) ??
                                  'Pool additions: ${waveState.addedToPool.length}',
                            if (wave.waveSpawnTime != null && l10n != null)
                              waveSpawnDelaySummary(l10n!, generator, wave),
                            if (wave.waitUntilAllZombiesDie == true)
                              l10n?.waveGeneratorWaitStatus ??
                                  'Waits for previous wave',
                          ].join(' · '),

                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (wave.zombies.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              l10n?.waveGeneratorEmptyWaveRow ??
                                  'No fixed spawns',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        else
                          _CollapsibleWaveZombieList(
                            entries: [
                              for (final z in wave.zombies)
                                WaveGeneratorZombieIconChip(
                                  localizedName: zombieDisplayName(z.type),
                                  codename: zombieCodename(z.type),
                                  iconPath: zombieIcon(z.type),
                                  rowLabel: generator.isRiseFromGroundMode
                                      ? (int.tryParse(z.riseGridY ?? '') == null
                                            ? '?'
                                            : '${int.parse(z.riseGridY!) + 1}')
                                      : waveGeneratorRowDisplay(z.row),
                                  positionTooltip:
                                      generator.isRiseFromGroundMode &&
                                          l10n != null
                                      ? waveSpawnPositionSummary(l10n!, z)
                                      : null,
                                ),
                            ],
                          ),
                        if (hasRandomPool) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n?.waveGeneratorRandomZombiesLabel ??
                                'Random zombies:',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _CollapsibleWaveZombieList(
                            entries: [
                              for (final entry in globalPool)
                                WaveGeneratorZombieIconChip(
                                  sourceBadge: 'Z',
                                  localizedName: zombieDisplayName(entry.type),
                                  codename: zombieCodename(entry.type),
                                  iconPath: zombieIcon(entry.type),
                                ),
                              for (final entry in wavePoolEntries)
                                WaveGeneratorZombieIconChip(
                                  sourceBadge: 'W',
                                  localizedName: zombieDisplayName(entry.type),
                                  codename: zombieCodename(entry.type),
                                  iconPath: zombieIcon(entry.type),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: actionColumnWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final b in actionButtons)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ActionChip(
                                    label: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: actionColumnWidth - 28,
                                      ),
                                      child: Text(
                                        b.label,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: chipFontSize,
                                        ),
                                      ),
                                    ),
                                    onPressed: b.onTap,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(
                              l10n?.deleteWave ?? 'Delete wave',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
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
      },
    );
  }
}

class _CollapsibleWaveZombieList extends StatefulWidget {
  const _CollapsibleWaveZombieList({required this.entries});

  final List<Widget> entries;

  @override
  State<_CollapsibleWaveZombieList> createState() =>
      _CollapsibleWaveZombieListState();
}

class _CollapsibleWaveZombieListState
    extends State<_CollapsibleWaveZombieList> {
  static const _spacing = 6.0;
  static const _expandButtonExtent = 40.0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entryExtent = isDesktopPlatform(context) ? 36.0 : 32.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final entriesPerFullRow =
            ((availableWidth + _spacing) / (entryExtent + _spacing))
                .floor()
                .clamp(1, widget.entries.length.clamp(1, 1000000));
        final twoRowCapacity = entriesPerFullRow * 2;
        final canExpand = widget.entries.length > twoRowCapacity;

        // When collapsed, reserve the final position on row two for the
        // expand control. It is slightly wider than a zombie icon, so its
        // capacity is calculated separately to prevent a third row.
        final secondRowEntries =
            ((availableWidth - _expandButtonExtent) / (entryExtent + _spacing))
                .floor()
                .clamp(0, entriesPerFullRow);
        final collapsedEntryCount = entriesPerFullRow + secondRowEntries;
        final visibleEntries = canExpand && !_expanded
            ? widget.entries.take(collapsedEntryCount)
            : widget.entries;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...visibleEntries,
            if (canExpand)
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.primary,
                ),
                constraints: const BoxConstraints.tightFor(
                  width: _expandButtonExtent,
                  height: _expandButtonExtent,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.05,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size.square(_expandButtonExtent),
                ),
              ),
          ],
        );
      },
    );
  }
}
