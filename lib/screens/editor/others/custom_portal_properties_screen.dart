import 'package:c_editor/widgets/autosave.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_portal_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';

class CustomPortalPropertiesScreen extends StatefulWidget {
  const CustomPortalPropertiesScreen({
    super.key,
    required this.levelFile,
    this.existingPortalType,
    this.basePortalType,
  });

  final PvzLevelFile levelFile;
  final String? existingPortalType;
  final String? basePortalType;

  @override
  State<CustomPortalPropertiesScreen> createState() =>
      _CustomPortalPropertiesScreenState();
}

class _CustomPortalPropertiesScreenState
    extends State<CustomPortalPropertiesScreen> {
  late Map<String, dynamic> _data;
  CustomPortalInfo? _existing;
  bool _canPop = false;
  bool _exitDialogOpen = false;

  bool get _isNew => _existing == null;

  @override
  void initState() {
    super.initState();
    final type = widget.existingPortalType;
    _existing = type == null
        ? null
        : CustomPortalLevelUtils.find(widget.levelFile, type);
    final existingData = _existing?.properties.objData;
    _data = existingData is Map
        ? PortalRepository.cloneMap(Map<String, dynamic>.from(existingData))
        : PortalRepository.clonePropertiesData(widget.basePortalType);
    _replaceBuggyHydraOptions();
  }

  void _replaceBuggyHydraOptions() {
    if (_data['PopAnim'] == 'POPANIM_EFFECTS_ZOMBOSS_HYDRA_MIRROR') {
      _data['PopAnim'] = PortalRepository.popAnimCodes.first;
      _data['PopAnimRenderOffset'] = {'x': 96, 'y': 125};
      _data['SpawnAnimation'] = 'spawn';
      _data['CloseAnimation'] = 'end';
    }
    if (_data['ZombieSpawnMethod'] == 'HydraRandom') {
      _data['ZombieSpawnMethod'] = PortalRepository.spawnMethodCodes.first;
      _data.remove('MinQuantity');
      _data.remove('MaxQuantity');
    }
  }

  List<String> get _zombieIds {
    final raw = _data['ZombieTypesToSpawn'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => entry['ZombieTypeName']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  List<int> get _zombieWeights {
    final raw = _data['ZombieTypesToSpawn'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => _asInt(entry['Weight'], 1))
        .toList();
  }

  void _setZombies(List<String> ids, List<int> weights) {
    setState(() {
      _data['ZombieTypesToSpawn'] = [
        for (var index = 0; index < ids.length; index++)
          {
            'ZombieTypeName': ids[index],
            'Weight': index < weights.length ? weights[index] : 1,
          },
      ];
    });
  }

  void _setPopAnim(String value) {
    setState(() {
      _data['PopAnim'] = value;
      final usesLargeOffset = value == 'POPANIM_EFFECTS_MODERN_PORTAL_PVZ1';
      _data['PopAnimRenderOffset'] = usesLargeOffset
          ? {'x': 105, 'y': 115}
          : {'x': 96, 'y': 125};
      _data['SpawnAnimation'] = 'spawn';
      _data['CloseAnimation'] = 'end';
    });
  }

  String _savePortal() {
    final existing = _existing;
    final portalType = existing == null
        ? CustomPortalLevelUtils.create(
            levelFile: widget.levelFile,
            propertiesData: _data,
          )
        : existing.portalType;
    if (existing != null) {
      CustomPortalLevelUtils.updateProperties(existing, _data);
    }
    return portalType;
  }

  void _exitWithResult(String? result) {
    if (!mounted) return;
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  void _saveAndExit({bool automatic = false}) {
    final result = _savePortal();
    if (automatic) showAutosavedMessage(context);
    _exitWithResult(result);
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;
    if (autosaveEnabled(context, AutosaveTarget.portal)) {
      try {
        _saveAndExit(automatic: true);
      } finally {
        _exitDialogOpen = false;
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_CustomPortalExitChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.unsavedChanges ?? 'Unsaved changes'),
        content: Text(l10n?.saveBeforeLeaving ?? 'Save before leaving?'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomPortalExitChoice.discard),
            child: Text(l10n?.discard ?? 'Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.stayInEditor ?? 'Stay'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomPortalExitChoice.save),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (!mounted) return;
    switch (choice) {
      case _CustomPortalExitChoice.discard:
        _exitWithResult(null);
        return;
      case _CustomPortalExitChoice.save:
        _saveAndExit();
        return;
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spawnMethod =
        _data['ZombieSpawnMethod']?.toString() ??
        PortalRepository.spawnMethodCodes.first;
    final hasInterval = _data['TimeBetweenSpawns'] is Map;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _confirmExit,
          ),
          title: Text(
            _isNew
                ? (l10n?.customPortalCreateTitle ?? 'Create custom portal')
                : (l10n?.customPortalEditTitle ?? 'Edit custom portal'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: _saveAndExit,
              tooltip: l10n?.save ?? 'Save',
              icon: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.customPortalAppearanceSection ??
                          'Portal appearance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EditorResponsiveInputField(
                      label: _portalPropertyLabel(
                        l10n?.customPortalWorld ?? 'World',
                        'World',
                      ),
                      decoration: editorInputDecoration(context),
                      builder: (context, decoration) =>
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue:
                                PortalRepository.worldCodes.contains(
                                  _data['World'],
                                )
                                ? _data['World'].toString()
                                : null,
                            decoration: decoration,
                            items: [
                              for (final code in PortalRepository.worldCodes)
                                DropdownMenuItem(
                                  value: code,
                                  child: Text(
                                    '${_worldName(context, code)} ($code)',
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _data['World'] = value);
                            },
                          ),
                    ),
                    const SizedBox(height: 12),
                    SeparatedOptionPickerField<String>(
                      labelText: _portalPropertyLabel(
                        l10n?.customPortalPopAnimation ?? 'Portal animation',
                        'PopAnim',
                      ),
                      value:
                          PortalRepository.popAnimCodes.contains(
                            _data['PopAnim'],
                          )
                          ? _data['PopAnim'].toString()
                          : null,
                      items: [
                        for (final code in PortalRepository.popAnimCodes)
                          SeparatedOptionPickerItem(
                            value: code,
                            label: _popAnimName(l10n, code),
                            subtitle: code,
                            fieldLabel: '${_popAnimName(l10n, code)} ($code)',
                          ),
                      ],
                      onChanged: _setPopAnim,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.customPortalSpawnSection ?? 'Zombie spawning',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SeparatedOptionPickerField<String>(
                      labelText: _portalPropertyLabel(
                        l10n?.customPortalSpawnMethod ?? 'Spawn method',
                        'ZombieSpawnMethod',
                      ),
                      value:
                          PortalRepository.spawnMethodCodes.contains(
                            spawnMethod,
                          )
                          ? spawnMethod
                          : null,
                      items: [
                        for (final code in PortalRepository.spawnMethodCodes)
                          SeparatedOptionPickerItem(
                            value: code,
                            label: _spawnMethodName(l10n, code),
                            subtitle: code,
                            fieldLabel:
                                '${_spawnMethodName(l10n, code)} ($code)',
                          ),
                      ],
                      onChanged: (value) {
                        setState(() => _data['ZombieSpawnMethod'] = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    ZombossMechWeightedZombieListEditor(
                      fieldLabel: _portalPropertyLabel(
                        l10n?.customPortalZombieTypes ?? 'Zombie types',
                        'ZombieTypesToSpawn',
                      ),
                      weightLabel: _portalPropertyLabel(
                        l10n?.zombieWeight ?? 'Zombie weight',
                        'Weight',
                      ),
                      zombieIds: _zombieIds,
                      weights: _zombieWeights,
                      defaultWeight: 1,
                      editable: true,
                      onChanged: _setZombies,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _portalPropertyLabel(
                          l10n?.customPortalSpawnInterval ?? 'Spawn interval',
                          'TimeBetweenSpawns',
                        ),
                      ),
                      subtitle: Text(
                        l10n?.customPortalSpawnIntervalSubtitle ??
                            'Optionally limit the time between zombie spawns.',
                      ),
                      value: hasInterval,
                      onChanged: (enabled) {
                        setState(() {
                          if (enabled) {
                            _data['TimeBetweenSpawns'] = {
                              'Min': 1.0,
                              'Max': 1.0,
                            };
                          } else {
                            _data.remove('TimeBetweenSpawns');
                          }
                        });
                      },
                    ),
                    if (hasInterval) ...[
                      const SizedBox(height: 8),
                      _intervalField(
                        context,
                        field: 'Min',
                        label:
                            l10n?.minimumIntervalSeconds ??
                            'Minimum interval (seconds)',
                      ),
                      const SizedBox(height: 12),
                      _intervalField(
                        context,
                        field: 'Max',
                        label:
                            l10n?.maximumIntervalSeconds ??
                            'Maximum interval (seconds)',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intervalField(
    BuildContext context, {
    required String field,
    required String label,
  }) {
    final interval = Map<String, dynamic>.from(
      _data['TimeBetweenSpawns'] as Map,
    );
    return EditorResponsiveInputField(
      label: _portalPropertyLabel(label, field),
      decoration: editorInputDecoration(context),
      builder: (context, decoration) => TextFormField(
        initialValue: '${interval[field] ?? 1.0}',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoration,
        onChanged: (value) {
          final parsed = double.tryParse(value);
          if (parsed == null) return;
          final next = Map<String, dynamic>.from(
            _data['TimeBetweenSpawns'] as Map,
          );
          next[field] = parsed;
          _data['TimeBetweenSpawns'] = next;
        },
      ),
    );
  }

  String _worldName(BuildContext context, String code) {
    if (code == 'twister') {
      return AppLocalizations.of(context)?.customPortalWorldTwister ??
          'Temporal Energy';
    }
    final stage = switch (code) {
      'egypt' => 'EgyptStage',
      'pirate' => 'PirateStage',
      'west' => 'WestStage',
      'future' => 'FutureStage',
      'dark' => 'DarkStage',
      'beach' => 'BeachStage',
      'iceage' => 'IceageStage',
      'lostcity' => 'LostCityStage',
      'eighties' => 'EightiesStage',
      'dino' => 'DinoStage',
      'kongfu' => 'KongfuStage',
      'steam' => 'SteamStage',
      'renai' => 'RenaiStage',
      'heian' => 'HeianStage',
      _ => '',
    };
    if (stage.isEmpty) return code;
    final key = 'stage_$stage';
    final localized = ResourceNames.lookup(context, key);
    return localized == key ? code : localized;
  }

  String _popAnimName(AppLocalizations? l10n, String code) => switch (code) {
    'POPANIM_EFFECTS_MODERN_PORTAL' =>
      l10n?.customPortalAnimationModern ?? 'Modern Day portal',
    'POPANIM_EFFECTS_MODERN_PORTAL_PVZ1' =>
      l10n?.customPortalAnimationMemoryLane ?? 'Memory Lane portal',
    'POPANIM_EFFECTS_ZOMBOSS_HYDRA_MIRROR' =>
      l10n?.customPortalAnimationHydra ?? 'Spell Chanter mirror',
    _ => code,
  };

  String _spawnMethodName(AppLocalizations? l10n, String code) =>
      switch (code) {
        'NonRandomShuffled' =>
          l10n?.customPortalSpawnMethodShuffled ?? 'Shuffled sequence',
        'NonRandomInOrder' =>
          l10n?.customPortalSpawnMethodInOrder ?? 'In order',
        'HydraRandom' =>
          l10n?.customPortalSpawnMethodHydra ?? 'Spell Chanter random',
        _ => code,
      };

  String _portalPropertyLabel(String localizedName, String codeName) {
    final normalizedName = localizedName
        .replaceAll('（', ' (')
        .replaceAll('）', ')');
    return '$normalizedName ($codeName)';
  }

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

enum _CustomPortalExitChoice { discard, save }
