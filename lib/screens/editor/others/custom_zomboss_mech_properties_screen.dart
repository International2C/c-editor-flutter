import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_detail_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

/// Edits level-local zombossmech property sheet (`editableInstancePropsName`).
class CustomZombossMechPropertiesScreen extends StatefulWidget {
  const CustomZombossMechPropertiesScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.introData,
    this.onStageCountChanged,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final ZombossMechBattleIntroData? introData;
  final ValueChanged<int>? onStageCountChanged;

  @override
  State<CustomZombossMechPropertiesScreen> createState() =>
      _CustomZombossMechPropertiesScreenState();
}

class _CustomZombossMechPropertiesScreenState
    extends State<CustomZombossMechPropertiesScreen> {
  static const _kDefaultRetreatRtid = 'RTID(ZombossRetreatJump@ZombieActions)';
  static const _kEightiesCatalogId = 'ZombieZombossMech_Eighties';
  static const _kStageJamOrderKey = 'StageJamOrder';
  static const _kZombossAnimOrderKey = 'ZombossAnimOrder';
  static const _kStageJamOptions = [
    'jam_punk',
    'jam_pop',
    'jam_rap',
    'jam_8bit',
    'jam_metal',
  ];
  static const _kZombossAnimOptions = [
    'idle_punk',
    'idle_newwave',
    'idle_hiphop',
    'idle_8bit',
    'idle_metal',
  ];

  PvzObject? _propsObj;
  late Map<String, dynamic> _propsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _propsObj = ZombossMechRepository.ensureCustomPropertiesInLevel(
      catalog: widget.catalog,
      levelFile: widget.levelFile,
    );
    final raw = _propsObj!.objData;
    if (raw is Map<String, dynamic>) {
      _propsData = Map<String, dynamic>.from(raw);
    } else {
      _propsData = widget.catalog.templatePropsData();
    }
    _ensureStages();
    _ensureEightiesStageOrders();
    _ensureRetreatActions();
  }

  void _ensureStages() {
    final stages = _stages;
    if (stages.isNotEmpty) return;
    final template = widget.catalog.templatePropsData();
    final templateStages = template['Stages'];
    if (templateStages is List && templateStages.isNotEmpty) {
      _propsData['Stages'] = _deepClone(templateStages);
    } else {
      _propsData['Stages'] = [
        for (var i = 0; i < widget.catalog.defaultPhaseCount; i++)
          {
            'Actions': <String>[],
            'HitPoints': 10000,
            if (widget.catalog.supportsRetreatInStages)
              'RetreatAction': _kDefaultRetreatRtid,
          },
      ];
    }
  }

  bool get _supportsEightiesStageOrders =>
      widget.catalog.id == _kEightiesCatalogId;

  List<String> _stringOrder(String key) {
    final raw = _propsData[key];
    if (raw is! List) return [];
    return raw.map((value) => value.toString()).toList();
  }

  List<String> _templateStringOrder(String key) {
    final raw = widget.catalog.templatePropsData()[key];
    if (raw is! List) return [];
    return raw.map((value) => value.toString()).toList();
  }

  void _ensureEightiesStageOrders() {
    if (!_supportsEightiesStageOrders) return;
    final stageCount = _stages.length;
    for (final entry in [
      (_kStageJamOrderKey, _kStageJamOptions),
      (_kZombossAnimOrderKey, _kZombossAnimOptions),
    ]) {
      final key = entry.$1;
      final fallbacks = entry.$2;
      final order = _stringOrder(key);
      final template = _templateStringOrder(key);
      while (order.length < stageCount) {
        final index = order.length;
        order.add(
          index < template.length
              ? template[index]
              : fallbacks[index % fallbacks.length],
        );
      }
      if (order.length > stageCount) {
        order.removeRange(stageCount, order.length);
      }
      _propsData[key] = order;
    }
    _propsObj!.objData = _propsData;
  }

  void _ensureRetreatActions() {
    if (!_supportsRetreat) return;
    var changed = false;
    for (final stage in _stages) {
      final raw = stage['RetreatAction'];
      if (raw is! String || raw.isEmpty) {
        stage['RetreatAction'] = _kDefaultRetreatRtid;
        changed = true;
      }
    }
    if (changed) {
      _propsData['Stages'] = _stages;
      _propsObj!.objData = _propsData;
    }
  }

  List<Map<String, dynamic>> get _stages {
    final raw = _propsData['Stages'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool get _supportsRetreat => widget.catalog.supportsRetreatInStages;

  void _sync() {
    _propsObj!.objData = _propsData;
    final count = _stages.length;
    widget.onStageCountChanged?.call(count);
    widget.introData?.zombossPhaseCount = count;
    widget.onChanged();
    setState(() {});
  }

  dynamic _deepClone(dynamic value) {
    return switch (value) {
      Map() => Map<String, dynamic>.fromEntries(
        value.entries.map(
          (e) => MapEntry(e.key.toString(), _deepClone(e.value)),
        ),
      ),
      List() => value.map(_deepClone).toList(),
      _ => value,
    };
  }

  String _displayName(BuildContext context, String key) {
    final name = ResourceNames.lookup(context, key);
    return name == key ? key : name;
  }

  String _stageJamLabel(AppLocalizations? l10n, String value) {
    return switch (value) {
      'jam_punk' => l10n?.jamPunk ?? 'Punk',
      'jam_pop' => l10n?.jamPop ?? 'Pop',
      'jam_rap' => l10n?.jamRap ?? 'Rap',
      'jam_8bit' => l10n?.jam8Bit ?? '8-Bit',
      'jam_metal' => l10n?.jamMetal ?? 'Metal',
      _ => value,
    };
  }

  String _zombossAnimLabel(AppLocalizations? l10n, String value) {
    return switch (value) {
      'idle_punk' => l10n?.jamPunk ?? 'Punk',
      'idle_newwave' => l10n?.zombossAnimNewWave ?? 'New Wave',
      'idle_hiphop' => l10n?.zombossAnimHipHop ?? 'Hip-Hop',
      'idle_8bit' => l10n?.jam8Bit ?? '8-Bit',
      'idle_metal' => l10n?.jamMetal ?? 'Metal',
      _ => value,
    };
  }

  void _reorderStringOrder(String key, int oldIndex, int newIndex) {
    final order = _stringOrder(key);
    if (oldIndex < 0 || oldIndex >= order.length) return;
    if (newIndex < 0 || newIndex >= order.length) return;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _propsData[key] = order;
    _sync();
  }

  List<String> _stageActions(Map<String, dynamic> stage) {
    final raw = stage['Actions'];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  void _setStageActions(int index, List<String> rtids) {
    final stages = _stages;
    if (index < 0 || index >= stages.length) return;
    stages[index]['Actions'] = rtids;
    _propsData['Stages'] = stages;
    _sync();
  }

  void _setStageRetreat(int index, String? rtid) {
    final stages = _stages;
    if (index < 0 || index >= stages.length) return;
    if (rtid == null || rtid.isEmpty) {
      stages[index].remove('RetreatAction');
    } else {
      stages[index]['RetreatAction'] = rtid;
    }
    _propsData['Stages'] = stages;
    _sync();
  }

  String _retreatRtid(Map<String, dynamic> stage) {
    final raw = stage['RetreatAction'];
    if (raw is String && raw.isNotEmpty) return raw;
    return _kDefaultRetreatRtid;
  }

  void _updateScalar(String key, dynamic value) {
    _propsData[key] = value;
    _sync();
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _readBoolProperty(String key) {
    return ZombossMechRepository.boolPropertyWithTemplateFallback(
      data: _propsData,
      catalog: widget.catalog,
      key: key,
    );
  }

  Future<void> _confirmDeletePhase(int index) async {
    final l10n = AppLocalizations.of(context);
    final phaseNum = index + 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n?.zombossMechDeletePhaseTitle(phaseNum) ??
              'Delete phase $phaseNum?',
        ),
        content: Text(
          _supportsEightiesStageOrders
              ? (l10n?.zombossMechDeleteEightiesPhaseMessage ??
                    'This removes the phase, its action list, its music, and '
                        'its Zomboss animation. This cannot be undone.')
              : (l10n?.zombossMechDeletePhaseMessage ??
                    'This removes the phase and its action list. This cannot '
                        'be undone.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final next = List<Map<String, dynamic>>.from(_stages)..removeAt(index);
    _propsData['Stages'] = next;
    if (_supportsEightiesStageOrders) {
      for (final key in [_kStageJamOrderKey, _kZombossAnimOrderKey]) {
        final order = _stringOrder(key);
        if (index >= 0 && index < order.length) order.removeAt(index);
        _propsData[key] = order;
      }
    }
    _sync();
  }

  Future<void> _addPhase() async {
    String? jam;
    String? animation;
    if (_supportsEightiesStageOrders) {
      final l10n = AppLocalizations.of(context);
      final selection = await showDialog<({String jam, String animation})>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Theme(
          data: zombossMechInputTheme(context),
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              constraints: const BoxConstraints.tightFor(width: 560),
              scrollable: true,
              title: Text(
                l10n?.zombossMechAddEightiesPhaseTitle ??
                    'Choose phase music and animation',
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.zombossMechEightiesPhaseSelectionRequired ??
                          'Select both entries before creating the phase.',
                    ),
                    const SizedBox(height: 16),
                    EditorResponsiveInputField(
                      label:
                          l10n?.zombossMechStageJamOrder ??
                          'Music playback order (StageJamOrder)',
                      decoration: editorInputDecoration(context),
                      builder: (context, decoration) =>
                          DropdownButtonFormField<String>(
                            itemHeight: null,
                            key: const ValueKey('eightiesPhaseJamDropdown'),
                            isExpanded: true,
                            initialValue: jam,
                            decoration: decoration,
                            items: [
                              for (final value in _kStageJamOptions)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    '${_stageJamLabel(l10n, value)} · $value',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setDialogState(() => jam = value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    EditorResponsiveInputField(
                      label:
                          l10n?.zombossMechZombossAnimOrder ??
                          'Zomboss animation order (ZombossAnimOrder)',
                      decoration: editorInputDecoration(context),
                      builder: (context, decoration) =>
                          DropdownButtonFormField<String>(
                            itemHeight: null,
                            key: const ValueKey(
                              'eightiesPhaseAnimationDropdown',
                            ),
                            isExpanded: true,
                            initialValue: animation,
                            decoration: decoration,
                            items: [
                              for (final value in _kZombossAnimOptions)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    '${_zombossAnimLabel(l10n, value)} · $value',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setDialogState(() => animation = value),
                          ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                FilledButton(
                  key: const ValueKey('confirmAddEightiesPhase'),
                  onPressed: jam == null || animation == null
                      ? null
                      : () => Navigator.pop(dialogContext, (
                          jam: jam!,
                          animation: animation!,
                        )),
                  child: Text(l10n?.zombossMechCreatePhase ?? 'Create phase'),
                ),
              ],
            ),
          ),
        ),
      );
      if (selection == null || !mounted) return;
      jam = selection.jam;
      animation = selection.animation;
    }

    final next = List<Map<String, dynamic>>.from(_stages);
    final last = next.isNotEmpty ? next.last : null;
    next.add({
      'Actions': <String>[if (last != null) ..._stageActions(last)],
      'HitPoints': _readInt(last?['HitPoints'], 10000),
      if (_supportsRetreat) 'RetreatAction': _retreatRtid(last ?? {}),
    });
    _propsData['Stages'] = next;
    if (_supportsEightiesStageOrders) {
      _propsData[_kStageJamOrderKey] = _stringOrder(_kStageJamOrderKey)
        ..add(jam!);
      _propsData[_kZombossAnimOrderKey] = _stringOrder(_kZombossAnimOrderKey)
        ..add(animation!);
    }
    _sync();
  }

  Future<void> _pickAction({
    required int stageIndex,
    required bool retreat,
  }) async {
    final rtid = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechActionSelectionScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          retreatOnly: retreat,
        ),
      ),
    );
    if (rtid == null || !mounted) return;
    if (retreat) {
      _setStageRetreat(stageIndex, rtid);
    } else {
      final actions = List<String>.from(_stageActions(_stages[stageIndex]))
        ..add(rtid);
      _setStageActions(stageIndex, actions);
    }
  }

  Future<void> _editCustomAction(String rtid) async {
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomZombossMechActionEditorScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          existingRtid: rtid,
          propsData: _propsData,
          onPropsSync: _sync,
        ),
      ),
    );
    if (mounted) _sync();
  }

  Future<void> _editStageAction({
    required int stageIndex,
    required int actionIndex,
    required String rtid,
  }) async {
    var editRtid = rtid;
    final origin = ZombossCustomActionPresetRepository.originForRtid(
      widget.levelFile,
      rtid,
    );
    ZombossPresetActionCreation? temporaryDerived;

    if (origin == ZombossCustomActionOrigin.presetTemplate) {
      temporaryDerived =
          ZombossCustomActionPresetRepository.deriveFromPresetInstance(
            widget.levelFile,
            rtid,
          );
      if (temporaryDerived != null) {
        editRtid = temporaryDerived.rtid;
        final stages = _stages;
        if (stageIndex >= 0 && stageIndex < stages.length) {
          final actions = _stageActions(stages[stageIndex]);
          if (actionIndex >= 0 && actionIndex < actions.length) {
            actions[actionIndex] = editRtid;
            stages[stageIndex]['Actions'] = actions;
            _propsData['Stages'] = stages;
            _sync();
          }
        }
      }
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomZombossMechActionEditorScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          existingRtid: editRtid,
          propsData: _propsData,
          onPropsSync: _sync,
        ),
      ),
    );

    if (!mounted) return;
    if (temporaryDerived != null && result == null) {
      final stages = _stages;
      if (stageIndex >= 0 && stageIndex < stages.length) {
        final actions = _stageActions(stages[stageIndex]);
        if (actionIndex >= 0 && actionIndex < actions.length) {
          actions[actionIndex] = rtid;
          stages[stageIndex]['Actions'] = actions;
          _propsData['Stages'] = stages;
        }
      }
      ZombossCustomActionPresetRepository.removeCreatedObjects(
        widget.levelFile,
        temporaryDerived,
      );
      _sync();
      return;
    }
    _sync();
  }

  Future<void> _openActionDetails(String rtid) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechActionDetailScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          rtid: rtid,
        ),
      ),
    );
  }

  Future<void> _confirmRemoveStageAction(
    int stageIndex,
    int actionIndex,
  ) async {
    final actions = _stageActions(_stages[stageIndex]);
    if (actionIndex < 0 || actionIndex >= actions.length) return;
    final rtid = actions[actionIndex];
    final next = List<String>.from(actions)..removeAt(actionIndex);
    _setStageActions(stageIndex, next);

    if (!ZombossMechActionUtils.isCustomRtid(rtid) || !mounted) return;
    if (ZombossMechActionUtils.countReferences(widget.levelFile, rtid) > 0) {
      return;
    }

    final info = RtidParser.parse(rtid);
    final alias = info?.alias ?? rtid;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n?.zombossMechOrphanActionDeleteTitle ??
              'Remove custom action data?',
        ),
        content: Text(
          l10n?.zombossMechOrphanActionDeleteMessage(alias) ??
              '"$alias" is no longer used in this level. Remove its action object from the level file?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final origin = ZombossCustomActionPresetRepository.originForRtid(
        widget.levelFile,
        rtid,
      );
      if (origin == ZombossCustomActionOrigin.userCreated) {
        ZombossMechActionUtils.deleteCustomActionObject(widget.levelFile, rtid);
      } else {
        ZombossCustomActionPresetRepository.deleteActionObjectAndUnusedPresetDependencies(
          widget.levelFile,
          rtid,
        );
      }
      widget.onChanged();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stages = _stages;
    final accent = zombossMechAccent(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(
            l10n?.customZombossMechProperties ??
                'Custom ZombossMech properties',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: l10n?.tooltipAboutSection ?? 'About this section',
              onPressed: () {
                showEditorHelpDialog(
                  context,
                  title:
                      l10n?.customZombossMechProperties ??
                      'Custom ZombossMech properties',
                  sections: [
                    HelpSectionData(
                      title: l10n?.overview ?? 'Overview',
                      body:
                          l10n?.customZombossMechEditHint ??
                          'Edit level-local property sheet for the memo (custom) mech variation.',
                    ),
                    HelpSectionData(
                      title:
                          l10n?.zombossMechPhasesHelpTitle ?? 'Phase contents',
                      body:
                          l10n?.zombossMechPhasesHelp ??
                          'Each phase has hit points, an ordered action list, and optionally a retreat action.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Theme(
          data: zombossMechInputTheme(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            Card(
              color: accent.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: accent.withValues(alpha: 0.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(context, widget.catalog.id),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n?.zombossMechPropertiesLabel ?? 'Properties'}: ${widget.catalog.editableInstancePropsName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n?.zombossMechAliasLabel ?? 'Alias'}: ${widget.catalog.editableInstance}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.customZombossMechScalars ?? 'General',
              style: theme.textTheme.titleMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _ScalarStepper(
              label: l10n?.zombossMechMinColumn ?? 'Min column',
              value: _readInt(_propsData['MinColumn'], 1),
              min: 0,
              max: 9,
              onChanged: (v) => _updateScalar('MinColumn', v),
            ),
            _ScalarStepper(
              label: l10n?.zombossMechMaxColumn ?? 'Max column',
              value: _readInt(_propsData['MaxColumn'], 7),
              min: 0,
              max: 9,
              onChanged: (v) => _updateScalar('MaxColumn', v),
            ),
            SwitchListTile.adaptive(
              key: const ValueKey('squashZombiesSwitch'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n?.zombossMechSquashZombies ?? 'Can squash zombies',
              ),
              value: _readBoolProperty('SquashZombies'),
              onChanged: (value) => _updateScalar('SquashZombies', value),
            ),
            SwitchListTile.adaptive(
              key: const ValueKey('squashGridItemsSwitch'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n?.zombossMechSquashGridItems ?? 'Can squash grid items',
              ),
              value: _readBoolProperty('SquashGridItems'),
              onChanged: (value) => _updateScalar('SquashGridItems', value),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.customZombossMechStages ?? 'Battle phases',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n?.zombossMechAddPhase ?? 'Add phase',
                  onPressed: _addPhase,
                  icon: Icon(Icons.add_circle_outline, color: accent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_supportsEightiesStageOrders) ...[
              _EightiesStageOrderCard(
                key: const ValueKey('stageJamOrderCard'),
                title:
                    l10n?.zombossMechStageJamOrder ??
                    'Music playback order (StageJamOrder)',
                values: _stringOrder(_kStageJamOrderKey),
                valueLabel: (value) => _stageJamLabel(l10n, value),
                onReorderItem: (oldIndex, newIndex) =>
                    _reorderStringOrder(_kStageJamOrderKey, oldIndex, newIndex),
              ),
              const SizedBox(height: 4),
              _EightiesStageOrderCard(
                key: const ValueKey('zombossAnimOrderCard'),
                title:
                    l10n?.zombossMechZombossAnimOrder ??
                    'Zomboss animation order (ZombossAnimOrder)',
                values: _stringOrder(_kZombossAnimOrderKey),
                valueLabel: (value) => _zombossAnimLabel(l10n, value),
                onReorderItem: (oldIndex, newIndex) => _reorderStringOrder(
                  _kZombossAnimOrderKey,
                  oldIndex,
                  newIndex,
                ),
              ),
              const SizedBox(height: 4),
            ],
            for (var i = 0; i < stages.length; i++)
              _StageCard(
                index: i,
                catalog: widget.catalog,
                levelFile: widget.levelFile,
                accentColor: accent,
                stage: stages[i],
                canDelete: stages.length > 1,
                selectedActions: _stageActions(stages[i]),
                retreatRtid: _retreatRtid(stages[i]),
                supportsRetreat: _supportsRetreat,
                onDelete: () => _confirmDeletePhase(i),
                onHitPointsChanged: (hp) {
                  stages[i]['HitPoints'] = hp;
                  _propsData['Stages'] = stages;
                  _sync();
                },
                onActionsChanged: (rtids) => _setStageActions(i, rtids),
                onRemoveAction: (actionIndex) =>
                    _confirmRemoveStageAction(i, actionIndex),
                onAddAction: () => _pickAction(stageIndex: i, retreat: false),
                onPickRetreat: () => _pickAction(stageIndex: i, retreat: true),
                onEditStageAction: (actionIndex, rtid) => _editStageAction(
                  stageIndex: i,
                  actionIndex: actionIndex,
                  rtid: rtid,
                ),
                onEditRetreatAction: _editCustomAction,
                onInspectAction: _openActionDetails,
                phaseLabel:
                    l10n?.zombossMechPhaseNumber(i + 1) ?? 'Phase ${i + 1}',
                hitPointsLabel: l10n?.zombossMechHitPoints ?? 'Hit points',
                actionsLabel: l10n?.zombossMechActions ?? 'Actions',
                retreatLabel:
                    l10n?.zombossMechRetreatAction ?? 'Retreat action',
                deleteTooltip: l10n?.zombossMechDeletePhase ?? 'Delete phase',
                addActionTooltip: l10n?.zombossMechAddAction ?? 'Add action',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EightiesStageOrderCard extends StatelessWidget {
  const _EightiesStageOrderCard({
    super.key,
    required this.title,
    required this.values,
    required this.valueLabel,
    required this.onReorderItem,
  });

  final String title;
  final List<String> values;
  final String Function(String value) valueLabel;
  final ReorderCallback onReorderItem;

  static const _rowHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = zombossMechAccent(context);
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.presetPlantListReorderHintDesktop ??
                  'Drag the ⋮⋮ handle to reorder.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: SizedBox(
                  width: double.infinity,
                  height: values.length * _rowHeight,
                  child: ReorderableListView.builder(
                    clipBehavior: Clip.none,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: values.length,
                    onReorderItem: onReorderItem,
                    itemBuilder: (context, index) {
                      final value = values[index];
                      return Material(
                        key: ValueKey('$title-$index-$value'),
                        color: Colors.transparent,
                        child: SizedBox(
                          height: _rowHeight,
                          child: Row(
                            children: [
                              ReorderableDragStartListener(
                                key: ValueKey(
                                  'eightiesOrderDragHandle-$title-$index-$value',
                                ),
                                index: index,
                                child: SizedBox(
                                  width: 48,
                                  height: _rowHeight,
                                  child: Center(
                                    child: Icon(
                                      Icons.drag_indicator,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: accent.withValues(alpha: 0.14),
                                foregroundColor: accent,
                                child: Text('${index + 1}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      valueLabel(value),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScalarStepper extends StatelessWidget {
  const _ScalarStepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: EditorResponsiveStepperRow(
        label: label,
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.index,
    required this.catalog,
    required this.levelFile,
    required this.accentColor,
    required this.stage,
    required this.canDelete,
    required this.selectedActions,
    required this.retreatRtid,
    required this.supportsRetreat,
    required this.onDelete,
    required this.onHitPointsChanged,
    required this.onActionsChanged,
    required this.onRemoveAction,
    required this.onAddAction,
    required this.onPickRetreat,
    required this.onEditStageAction,
    required this.onEditRetreatAction,
    required this.onInspectAction,
    required this.phaseLabel,
    required this.hitPointsLabel,
    required this.actionsLabel,
    required this.retreatLabel,
    required this.deleteTooltip,
    required this.addActionTooltip,
  });

  final int index;
  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final Color accentColor;
  final Map<String, dynamic> stage;
  final bool canDelete;
  final List<String> selectedActions;
  final String retreatRtid;
  final bool supportsRetreat;
  final VoidCallback onDelete;
  final ValueChanged<int> onHitPointsChanged;
  final ValueChanged<List<String>> onActionsChanged;
  final ValueChanged<int> onRemoveAction;
  final VoidCallback onAddAction;
  final VoidCallback onPickRetreat;
  final void Function(int actionIndex, String rtid) onEditStageAction;
  final ValueChanged<String> onEditRetreatAction;
  final ValueChanged<String> onInspectAction;
  final String phaseLabel;
  final String hitPointsLabel;
  final String actionsLabel;
  final String retreatLabel;
  final String deleteTooltip;
  final String addActionTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hp = _hitPoints;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    phaseLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                if (canDelete)
                  IconButton(
                    tooltip: deleteTooltip,
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: accentColor),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _HitPointsField(
              label: hitPointsLabel,
              value: hp,
              onChanged: onHitPointsChanged,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              decoration: BoxDecoration(
                color: zombossMechActionTagColor(
                  'spawn',
                  context,
                ).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          actionsLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: addActionTooltip,
                        onPressed: onAddAction,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n?.presetPlantListReorderHintDesktop ??
                        'Drag the ⋮⋮ handle to reorder.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (selectedActions.isEmpty)
                    Text(
                      l10n?.zombossMechNoStageActions ?? 'No actions yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    SizedBox(
                      key: ValueKey('stageActionList-$index'),
                      height:
                          selectedActions.length * kZombossMechActionRowHeight,
                      child: ReorderableListView.builder(
                        clipBehavior: Clip.none,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: selectedActions.length,
                        onReorderItem: (oldIndex, newIndex) {
                          final next = List<String>.from(selectedActions);
                          final item = next.removeAt(oldIndex);
                          next.insert(newIndex, item);
                          onActionsChanged(next);
                        },
                        itemBuilder: (context, actionIndex) {
                          final rtid = selectedActions[actionIndex];
                          final isCustom = ZombossMechActionUtils.isCustomRtid(
                            rtid,
                          );
                          final resolved = ZombossMechActionUtils.resolveAction(
                            rtid: rtid,
                            catalog: catalog,
                            levelFile: levelFile,
                          );
                          final tag = resolved?.tag ?? '';

                          return ZombossMechActionListTile(
                            key: ValueKey('$index-$actionIndex-$rtid'),
                            mechId: catalog.id,
                            catalog: catalog,
                            levelFile: levelFile,
                            rtid: rtid,
                            tag: tag,
                            reorderIndex: actionIndex,
                            onEdit: isCustom
                                ? () => onEditStageAction(actionIndex, rtid)
                                : null,
                            onInspect: isCustom
                                ? null
                                : () => onInspectAction(rtid),
                            onRemove: () => onRemoveAction(actionIndex),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (supportsRetreat) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: zombossMechActionTagColor(
                    'retreat',
                    context,
                  ).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retreatLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ZombossMechRetreatActionTile(
                      mechId: catalog.id,
                      catalog: catalog,
                      levelFile: levelFile,
                      rtid: retreatRtid,
                      tag:
                          ZombossMechActionUtils.resolveAction(
                            rtid: retreatRtid,
                            catalog: catalog,
                            levelFile: levelFile,
                          )?.tag ??
                          'retreat',
                      onSwap: onPickRetreat,
                      onEdit: ZombossMechActionUtils.isCustomRtid(retreatRtid)
                          ? () => onEditRetreatAction(retreatRtid)
                          : null,
                      onInspect:
                          ZombossMechActionUtils.isCustomRtid(retreatRtid)
                          ? null
                          : () => onInspectAction(retreatRtid),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int get _hitPoints {
    final hp = stage['HitPoints'];
    if (hp is int) return hp;
    if (hp is num) return hp.toInt();
    if (hp is String) return int.tryParse(hp) ?? 10000;
    return 10000;
  }
}

class _HitPointsField extends StatefulWidget {
  const _HitPointsField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_HitPointsField> createState() => _HitPointsFieldState();
}

class _HitPointsFieldState extends State<_HitPointsField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode()
      ..addListener(() {
        final f = _focusNode.hasFocus;
        if (_focused != f) setState(() => _focused = f);
      });
  }

  @override
  void didUpdateWidget(covariant _HitPointsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focused && oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditorResponsiveInputField(
      label: widget.label,
      decoration: editorInputDecoration(context),
      builder: (context, decoration) => TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final parsed = int.tryParse(v);
          if (parsed != null && parsed > 0) widget.onChanged(parsed);
        },
      ),
    );
  }
}
