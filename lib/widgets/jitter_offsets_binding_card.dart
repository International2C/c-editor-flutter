import 'package:flutter/material.dart';

import 'package:c_editor/data/jitter_offsets_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Shared preset picker used by compatible zombie-spawning events.
class JitterOffsetsBindingCard extends StatelessWidget {
  const JitterOffsetsBindingCard({
    super.key,
    required this.levelFile,
    required this.currentValue,
    required this.onChanged,
    required this.onManage,
    this.overrideWarning,
    this.enabled = true,
    this.fixedOffset,
    this.onFixedOffsetChanged,
    this.scopeDescription,
  });

  final PvzLevelFile levelFile;
  final String? currentValue;
  final ValueChanged<String?> onChanged;
  final VoidCallback onManage;
  final String? overrideWarning;
  final bool enabled;
  final num? fixedOffset;
  final ValueChanged<num>? onFixedOffsetChanged;
  final String? scopeDescription;

  Future<void> _showPresetPicker({
    required BuildContext context,
    required List<String> choices,
    required String selectedAlias,
    required String Function(String alias) labelFor,
    required bool Function(String alias) isEnabled,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showDialog<_JitterOffsetsSelection>(
      context: context,
      builder: (dialogContext) => _JitterOffsetsPresetPickerDialog(
        choices: choices,
        selectedAlias: selectedAlias,
        labelFor: labelFor,
        isEnabled: isEnabled,
      ),
    );
    if (selected == null || !context.mounted) return;
    if (selected.manage) {
      onManage();
    } else {
      onSelected(selected.alias);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final presets = JitterOffsetsUtils.listPresets(levelFile);
    final presetsByAlias = <String, PvzObject>{};
    for (final preset in presets) {
      final aliases = preset.aliases;
      if (aliases == null || aliases.isEmpty || aliases.first.isEmpty) {
        continue;
      }
      presetsByAlias.putIfAbsent(aliases.first, () => preset);
    }

    final hasBinding = currentValue?.trim().isNotEmpty == true;
    final boundInfo = hasBinding ? RtidParser.parse(currentValue!) : null;
    final boundAlias = boundInfo?.alias;
    final boundIsLocal = boundInfo?.source == 'CurrentLevel';
    final boundPreset = boundIsLocal && boundAlias != null
        ? presetsByAlias[boundAlias]
        : null;
    final dangling = hasBinding && (!boundIsLocal || boundPreset == null);
    final danglingLabel = boundAlias ?? currentValue?.trim() ?? '';
    final danglingChoice = dangling ? '\u0000dangling:$currentValue' : null;
    final invalid =
        boundPreset != null && !JitterOffsetsUtils.isPresetValid(boundPreset);
    final choices = <String>['', ...presetsByAlias.keys, ?danglingChoice];

    String labelFor(String choice) {
      if (choice.isEmpty) {
        return l10n?.jitterOffsetsEventNone ??
            'Unbound (use the game\'s default parameters)';
      }
      if (choice == danglingChoice) {
        return l10n?.jitterOffsetsEventDangling(danglingLabel) ??
            '$danglingLabel (missing)';
      }
      final preset = presetsByAlias[choice];
      if (preset != null && !JitterOffsetsUtils.isPresetValid(preset)) {
        return l10n?.jitterOffsetsEventInvalidOption(choice) ??
            '$choice (invalid values)';
      }
      return choice;
    }

    final errorText = !enabled
        ? null
        : dangling
        ? (l10n?.jitterOffsetsEventDangling(danglingLabel) ??
              '$danglingLabel (missing)')
        : invalid
        ? (l10n?.jitterOffsetsEventInvalidPreset ??
              'This preset contains invalid parameters. Under "Manage Presets", set "Random offset upper bound" to a positive value.')
        : null;

    return Card(
      child: ExpansionTile(
        key: const ValueKey('spawnPositionOffsetSettings'),
        initiallyExpanded: false,
        iconColor: theme.colorScheme.secondary,
        collapsedIconColor: theme.colorScheme.secondary,
        leading: Icon(Icons.speed, color: theme.colorScheme.secondary),
        title: Text(
          l10n?.jitterOffsetsEventLabel ?? 'Spawn Position Offset',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                key: const ValueKey('jitterOffsetsPresetPicker'),
                borderRadius: BorderRadius.circular(4),
                onTap: enabled
                    ? () => _showPresetPicker(
                        context: context,
                        choices: choices,
                        selectedAlias: danglingChoice ?? boundAlias ?? '',
                        labelFor: labelFor,
                        isEnabled: (choice) {
                          if (choice == danglingChoice) return false;
                          final preset = presetsByAlias[choice];
                          final isInvalidOption =
                              preset != null &&
                              !JitterOffsetsUtils.isPresetValid(preset);
                          return choice.isEmpty || !isInvalidOption;
                        },
                        onSelected: (alias) {
                          if (alias.isEmpty) {
                            onChanged(null);
                            return;
                          }
                          onChanged(RtidParser.build(alias, 'CurrentLevel'));
                        },
                      )
                    : null,
                child: InputDecorator(
                  decoration: InputDecoration(
                    enabled: enabled,
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    errorText: errorText,
                    errorMaxLines: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          labelFor(danglingChoice ?? boundAlias ?? ''),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: enabled ? null : theme.disabledColor,
                      ),
                    ],
                  ),
                ),
              ),
              if (overrideWarning case final warning?) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        warning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (errorText == null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n?.jitterOffsetsEventDescription ??
                      'Controls the horizontal offset added to each zombie\'s base spawn position within the same event and row. Facing determines the offset direction.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (scopeDescription case final description?) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (onFixedOffsetChanged case final updateFixedOffset?) ...[
                const SizedBox(height: 16),
                FixedOffsetAdvancedSettingsCard(
                  value: fixedOffset,
                  onChanged: updateFixedOffset,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Event-local advanced controls that override the bound position-offset
/// preset. This deliberately lives outside the preset editor because
/// `FixedOffset` belongs to each spawn event rather than to
/// `ZombieJitterOffsets`.
class FixedOffsetAdvancedSettingsCard extends StatelessWidget {
  const FixedOffsetAdvancedSettingsCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final num? value;
  final ValueChanged<num> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initialValue = value ?? 0;
    final rawText = initialValue.toString();
    // Converting integral doubles to int can clamp very large values. Trim a
    // cosmetic decimal suffix without changing the imported numeric value.
    final initialText = initialValue == 0
        ? '0'
        : rawText.endsWith('.0')
        ? rawText.substring(0, rawText.length - 2)
        : rawText;

    return EditorResponsiveInputField(
      label:
          l10n?.jitterOffsetsFixedOffsetLabel ??
          'Batch-index fixed offset (FixedOffset)',
      decoration: InputDecoration(border: const OutlineInputBorder()),
      builder: (context, decoration) => TextFormField(
        key: const ValueKey('fixedOffsetField'),
        initialValue: initialText,
        decoration: decoration,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (text) {
          final parsed = num.tryParse(text?.trim() ?? '');
          if (parsed != null && parsed.isFinite) return null;
          return l10n?.jitterOffsetsFixedOffsetInvalid ??
              'Enter a valid number.';
        },
        onChanged: (text) {
          final parsed = num.tryParse(text.trim());
          if (parsed != null && parsed.isFinite) onChanged(parsed);
        },
      ),
    );
  }
}

class _JitterOffsetsSelection {
  const _JitterOffsetsSelection(this.alias) : manage = false;
  const _JitterOffsetsSelection.manage() : alias = '', manage = true;

  final String alias;
  final bool manage;
}

class _JitterOffsetsPresetPickerDialog extends StatefulWidget {
  const _JitterOffsetsPresetPickerDialog({
    required this.choices,
    required this.selectedAlias,
    required this.labelFor,
    required this.isEnabled,
  });

  final List<String> choices;
  final String selectedAlias;
  final String Function(String alias) labelFor;
  final bool Function(String alias) isEnabled;

  @override
  State<_JitterOffsetsPresetPickerDialog> createState() =>
      _JitterOffsetsPresetPickerDialogState();
}

class _JitterOffsetsPresetPickerDialogState
    extends State<_JitterOffsetsPresetPickerDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: Material(
              key: const ValueKey('jitterOffsetsPresetDialog'),
              color:
                  theme.dialogTheme.backgroundColor ??
                  theme.colorScheme.surface,
              elevation: theme.dialogTheme.elevation ?? 6,
              shape:
                  theme.dialogTheme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: constraints.maxWidth.clamp(0.0, 560.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (constraints.maxHeight * 0.85).clamp(0.0, 620.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Text(
                          l10n?.jitterOffsetsSelectTitle ??
                              'Select Spawn Position Offset',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      Flexible(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          interactive: true,
                          scrollbarOrientation: ScrollbarOrientation.right,
                          child: ListView.separated(
                            controller: _scrollController,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.choices.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final alias = widget.choices[index];
                              final enabled = widget.isEnabled(alias);
                              return EditorOptionTile(
                                enabled: enabled,
                                selected: alias == widget.selectedAlias,
                                title: Text(
                                  widget.labelFor(alias),
                                  softWrap: true,
                                ),
                                trailing: alias == widget.selectedAlias
                                    ? Icon(
                                        Icons.check,
                                        color: theme.colorScheme.secondary,
                                      )
                                    : null,
                                onTap: enabled
                                    ? () => Navigator.pop(
                                        context,
                                        _JitterOffsetsSelection(alias),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n?.cancel ?? 'Cancel'),
                            ),
                            TextButton.icon(
                              key: const ValueKey('jitterOffsetsAddFromPicker'),
                              onPressed: () => Navigator.pop(
                                context,
                                const _JitterOffsetsSelection.manage(),
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(
                                l10n?.jitterOffsetsAdd ?? 'Add offset',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
