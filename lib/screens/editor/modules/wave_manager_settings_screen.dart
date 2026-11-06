import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/level_jam_picker.dart';
import 'package:c_editor/widgets/wave_flag_strip.dart';

/// Wave manager settings. Ported from Z-Editor-master WaveManagerPropertiesEP.kt
class WaveManagerSettingsScreen extends StatefulWidget {
  const WaveManagerSettingsScreen({
    super.key,
    required this.levelFile,
    this.waveManagerAlias,
    required this.hasConveyor,
    required this.onChanged,
    required this.onBack,
  });

  final PvzLevelFile levelFile;
  final String? waveManagerAlias;
  final bool hasConveyor;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<WaveManagerSettingsScreen> createState() =>
      _WaveManagerSettingsScreenState();
}

class _WaveManagerSettingsScreenState extends State<WaveManagerSettingsScreen> {
  late PvzObject _wmObj;
  late WaveManagerData _wm;
  late TextEditingController _flagIntervalController;
  late TextEditingController _firstWaveController;
  late TextEditingController _hugeWaveController;
  late TextEditingController _maxHealthController;
  late TextEditingController _minHealthController;

  static const _defaultFirstWave = 12;
  static const _defaultFirstWaveConveyor = 5;
  static const _defaultHugeDelay = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _wmObj = widget.levelFile.objects.firstWhere(
      (o) =>
          o.objClass == 'WaveManagerProperties' &&
          (widget.waveManagerAlias == null ||
              o.aliases?.contains(widget.waveManagerAlias) == true),
      orElse: () => PvzObject(
        aliases: ['WaveManager'],
        objClass: 'WaveManagerProperties',
        objData: WaveManagerData().toJson(),
      ),
    );
    _wm = WaveManagerData.fromJson(
      Map<String, dynamic>.from(_wmObj.objData as Map),
    );
    _flagIntervalController = TextEditingController(
      text: '${_wm.flagWaveInterval}',
    );
    final firstVal = widget.hasConveyor
        ? (_wm.zombieCountDownFirstWaveConveyorSecs ??
              _defaultFirstWaveConveyor)
        : (_wm.zombieCountDownFirstWaveSecs ?? _defaultFirstWave);
    final hugeVal = _wm.zombieCountDownHugeWaveDelay ?? _defaultHugeDelay;
    _firstWaveController = TextEditingController(text: '$firstVal');
    _hugeWaveController = TextEditingController(text: '$hugeVal');
    _maxHealthController = TextEditingController(
      text: _wm.maxNextWaveHealthPercentage.toString(),
    );
    _minHealthController = TextEditingController(
      text: _wm.minNextWaveHealthPercentage.toString(),
    );
  }

  void _save() {
    _wmObj.objData = _wm.toJson();
    widget.onChanged();
  }

  void _updateFlagInterval(String v) {
    final n = int.tryParse(v);
    if (n != null && n > 0) {
      _wm.flagWaveInterval = n;
      _save();
      // Rebuild so the flag strip reflects the new interval live.
      setState(() {});
    }
  }

  void _updateTimeSettings() {
    final first =
        int.tryParse(_firstWaveController.text) ??
        (widget.hasConveyor ? _defaultFirstWaveConveyor : _defaultFirstWave);
    final huge = int.tryParse(_hugeWaveController.text) ?? _defaultHugeDelay;
    if (widget.hasConveyor) {
      _wm.zombieCountDownFirstWaveSecs = null;
      _wm.zombieCountDownFirstWaveConveyorSecs =
          first == _defaultFirstWaveConveyor ? null : first;
      _wm.zombieCountDownHugeWaveDelay = huge == _defaultHugeDelay
          ? null
          : huge;
    } else {
      _wm.zombieCountDownFirstWaveSecs = first == _defaultFirstWave
          ? null
          : first;
      _wm.zombieCountDownFirstWaveConveyorSecs = null;
      _wm.zombieCountDownHugeWaveDelay = huge == _defaultHugeDelay
          ? null
          : huge;
    }
    _save();
  }

  @override
  void dispose() {
    _flagIntervalController.dispose();
    _firstWaveController.dispose();
    _hugeWaveController.dispose();
    _maxHealthController.dispose();
    _minHealthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Use secondary (blue) to match Kotlin WaveManagerPropertiesEP PvzBlueLight/Dark
    final themeColor = theme.colorScheme.secondary;
    final onAccent = theme.colorScheme.onPrimary;
    // Drive TextField focus, switches, and other accents from the AppBar color
    // instead of the app-wide primary (green).
    final screenTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: themeColor),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return TextStyle(color: themeColor);
          }
          return TextStyle(color: theme.colorScheme.onSurface);
        }),
        focusColor: themeColor,
      ),
      textSelectionTheme: theme.textSelectionTheme.copyWith(
        cursorColor: themeColor,
        selectionHandleColor: themeColor,
      ),
      switchTheme: theme.switchTheme.copyWith(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return onAccent;
          return theme.colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return themeColor;
          return theme.colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return themeColor;
          return theme.colorScheme.outline;
        }),
      ),
    );
    return Theme(
      data: screenTheme,
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n?.waveManagerSettings ?? 'Wave manager settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: themeColor,
        foregroundColor: onAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.waveManagerHelpTitle ?? 'Wave manager',
              themeColor: themeColor,
              sections: [
                HelpSectionData(
                  title: l10n?.waveManagerHelpOverviewTitle ?? 'Overview',
                  body:
                      l10n?.waveManagerHelpOverviewBody ??
                      'Global parameters for wave events and health thresholds.',
                ),
                HelpSectionData(
                  title: l10n?.waveManagerHelpFlagTitle ?? 'Flag interval',
                  body:
                      l10n?.waveManagerHelpFlagBody ??
                      'Every N waves is a flag wave; the final wave is always flag.',
                ),
                HelpSectionData(
                  title: l10n?.waveManagerHelpTimeTitle ?? 'Time control',
                  body: [
                    l10n?.waveManagerHelpTimeBody ??
                        'First wave delay changes when a conveyor is present.',
                    l10n?.waveManagerFirstWaveDelayConveyorOnlyHelp ??
                        'Editing the current first-wave delay only affects conveyor levels. Regular levels use the default value.',
                  ].join('\n\n'),
                ),
                HelpSectionData(
                  title: l10n?.waveManagerHelpMusicTitle ?? 'Music type',
                  body:
                      l10n?.waveManagerHelpMusicBody ??
                      'Modern world only; provides fixed background jam type.',
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
            Text(
              l10n?.waveManagerBasicParams ?? 'Basic params',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            if (_wm.waves.isNotEmpty) ...[
              WaveFlagStrip(
                color: themeColor,
                waveCount: _wm.waves.length,
                isFlagWave: (w) {
                  final interval = _wm.flagWaveInterval <= 0
                      ? 10
                      : _wm.flagWaveInterval;
                  return w % interval == 0 || w == _wm.waves.length;
                },
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 12),
            EditorResponsiveInputField(
              label: l10n?.flagInterval ?? 'Flag interval (FlagWaveInterval)',
              builder: (context, decoration) => TextField(
                controller: _flagIntervalController,
                keyboardType: TextInputType.number,
                decoration: decoration,
                onChanged: _updateFlagInterval,
              ),
            ),
            const SizedBox(height: 16),
            EditorResponsiveFieldRow(
              children: [
                EditorResponsiveInputField(
                  label:
                      l10n?.waveManagerMaxHealthThreshold ??
                      'Max health threshold',
                  builder: (context, decoration) => TextField(
                    controller: _maxHealthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null && n >= 0 && n <= 1) {
                        _wm.maxNextWaveHealthPercentage = n;
                        _save();
                      }
                    },
                  ),
                ),
                EditorResponsiveInputField(
                  label:
                      l10n?.waveManagerMinHealthThreshold ??
                      'Min health threshold',
                  builder: (context, decoration) => TextField(
                    controller: _minHealthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null && n >= 0 && n <= 1) {
                        _wm.minNextWaveHealthPercentage = n;
                        _save();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.waveManagerThresholdHint ??
                  'Threshold must be between 0 and 1.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              l10n?.waveManagerTimeControl ?? 'Time control',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            EditorResponsiveFieldRow(
              children: [
                EditorResponsiveInputField(
                  label: widget.hasConveyor
                      ? (l10n?.waveManagerFirstWaveDelayConveyor ??
                            'First wave delay (conveyor)')
                      : (l10n?.waveManagerFirstWaveDelayNormal ??
                            'First wave delay (normal)'),
                  builder: (context, decoration) => TextField(
                    controller: _firstWaveController,
                    keyboardType: TextInputType.number,
                    decoration: decoration,
                    onChanged: (_) => _updateTimeSettings(),
                  ),
                ),
                EditorResponsiveInputField(
                  label: l10n?.waveManagerFlagWaveDelay ?? 'Flag wave delay',
                  builder: (context, decoration) => TextField(
                    controller: _hugeWaveController,
                    keyboardType: TextInputType.number,
                    decoration: decoration,
                    onChanged: (_) => _updateTimeSettings(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.hasConveyor
                  ? (l10n?.waveManagerConveyorDetected ??
                        'Conveyor module detected; conveyor delay applied.')
                  : (l10n?.waveManagerConveyorNotDetected ??
                        'No conveyor module; normal delay applied.'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.waveManagerFirstWaveDelayConveyorOnlyHint ??
                  'Editing the current first-wave delay only affects conveyor levels; regular levels use the default value',
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              l10n?.waveManagerSpecial ?? 'Special',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.waveManagerSuppressFlagZombieTitle ??
                                'Suppress flag zombie',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n?.waveManagerSuppressFlagZombieField ??
                                'SuppressFlagZombie',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _wm.suppressFlagZombie == true,
                      onChanged: (v) {
                        _wm.suppressFlagZombie = v ? true : null;
                        _save();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.waveManagerSuppressFlagZombieHint ??
                  'When enabled, flag waves won’t spawn a flag zombie.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LevelJamPickerField(
              labelText: l10n?.waveManagerLevelJam ?? 'Level Jam',
              value: _wm.levelJam,
              onChanged: (v) {
                setState(() {
                  _wm.levelJam = v;
                  _save();
                });
              },
            ),
            const SizedBox(height: 6),
            Text(
              l10n?.waveManagerLevelJamHint ??
                  'Only applies to Modern world; provides fixed background music.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
