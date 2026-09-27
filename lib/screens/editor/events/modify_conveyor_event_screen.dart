import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Modify conveyor event editor. Ported from Z-Editor-master ModifyConveyorEventEP.kt
class ModifyConveyorEventScreen extends StatefulWidget {
  const ModifyConveyorEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestPlantSelection,
    required this.onRequestToolSelection,
    this.onAddModule,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected) onRequestPlantSelection;
  final void Function(void Function(String) onSelected) onRequestToolSelection;
  final void Function(String objClass)? onAddModule;

  @override
  State<ModifyConveyorEventScreen> createState() =>
      _ModifyConveyorEventScreenState();
}

class _ModifyConveyorEventScreenState extends State<ModifyConveyorEventScreen> {
  static const _objClass = 'ModifyConveyorWaveActionProps';

  late PvzObject _moduleObj;
  late ModifyConveyorWaveActionData _data;
  late String _alias;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: ModifyConveyorWaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ModifyConveyorWaveActionData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ModifyConveyorWaveActionData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _wrapRtid(String plantId) => 'RTID($plantId@PlantTypes)';
  String _unwrapRtid(String rtid) => RtidParser.parse(rtid)?.alias ?? rtid;

  bool _hasPowerTileModule() =>
      widget.levelFile.objects.any((o) => o.objClass == 'PowerTileProperties');

  static bool _isPowerTileTool(String id) => id.startsWith('tool_powertile_');

  bool _hasCustomLevelModule() => widget.levelFile.objects.any(
    (o) => o.objClass == 'CustomLevelModuleProperties',
  );

  void _openAddPlantPicker() {
    widget.onRequestPlantSelection((id) {
      final rtid = _wrapRtid(id);
      final existing = _data.addList.indexWhere((p) => p.type == rtid);
      final base = ModifyConveyorPlantData(
        type: rtid,
        weight: existing >= 0 ? _data.addList[existing].weight : 100,
        maxCount: existing >= 0 ? _data.addList[existing].maxCount : 0,
        maxWeightFactor: existing >= 0
            ? _data.addList[existing].maxWeightFactor
            : 1.0,
        minCount: existing >= 0 ? _data.addList[existing].minCount : 0,
        minWeightFactor: existing >= 0
            ? _data.addList[existing].minWeightFactor
            : 1.0,
        iLevel: existing >= 0 ? _data.addList[existing].iLevel : null,
        iAvatar: existing >= 0 ? _data.addList[existing].iAvatar : null,
      );
      _showModifyEntryDialog(base, isTool: false);
    });
  }

  void _openAddToolPicker() {
    widget.onRequestToolSelection((id) {
      void openEditor() {
        final existing = _data.addList.indexWhere((p) => p.type == id);
        final base = ModifyConveyorPlantData(
          type: id,
          weight: existing >= 0 ? _data.addList[existing].weight : 100,
          maxCount: existing >= 0 ? _data.addList[existing].maxCount : 0,
          maxWeightFactor: existing >= 0
              ? _data.addList[existing].maxWeightFactor
              : 1.0,
          minCount: existing >= 0 ? _data.addList[existing].minCount : 0,
          minWeightFactor: existing >= 0
              ? _data.addList[existing].minWeightFactor
              : 1.0,
        );
        _showModifyEntryDialog(base, isTool: true);
      }

      if (_isPowerTileTool(id) && !_hasPowerTileModule()) {
        final l10n = AppLocalizations.of(context);
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              l10n?.powerTileModuleRequiredTitle ??
                  'Power Tiles module required',
            ),
            content: Text(
              l10n?.powerTileModuleRequiredBody ??
                  'Power tile tools need the Power Tiles module in this level.',
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onAddModule?.call('PowerTileProperties');
                  openEditor();
                },
                child: Text(l10n?.add ?? 'Add'),
              ),
            ],
          ),
        );
      } else {
        openEditor();
      }
    });
  }

  void _showModifyEntryDialog(
    ModifyConveyorPlantData entry, {
    required bool isTool,
  }) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => _ModifyConveyorEntryDialog(
        l10n: l10n,
        entry: entry,
        isTool: isTool,
        hasCustomLevelModule: _hasCustomLevelModule(),
        onDismiss: () => Navigator.pop(ctx),
        onConfirm: () {
          final i = _data.addList.indexWhere((p) => p.type == entry.type);
          if (i >= 0) {
            _data.addList[i] = entry;
          } else {
            _data.addList.add(entry);
          }
          _sync();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _editAddEntry(int index) {
    final p = _data.addList[index];
    _showModifyEntryDialog(
      ModifyConveyorPlantData(
        type: p.type,
        iLevel: p.iLevel,
        iAvatar: p.iAvatar,
        weight: p.weight,
        maxCount: p.maxCount,
        maxWeightFactor: p.maxWeightFactor,
        minCount: p.minCount,
        minWeightFactor: p.minWeightFactor,
      ),
      isTool: p.isToolEntry,
    );
  }

  void _openRemovePlantPicker() {
    widget.onRequestPlantSelection((id) {
      final rtid = _wrapRtid(id);
      if (!_data.removeList.any((r) => r.type == rtid)) {
        _data.removeList.add(ModifyConveyorRemoveData(type: rtid));
        _sync();
      }
    });
  }

  void _openRemoveToolPicker() {
    widget.onRequestToolSelection((id) {
      if (!_data.removeList.any((r) => r.type == id)) {
        _data.removeList.add(ModifyConveyorRemoveData(type: id));
        _sync();
      }
    });
  }

  String _addEntryTitle(ModifyConveyorPlantData p, AppLocalizations? l10n) {
    if (p.isToolEntry) {
      return ToolRepository.localizedName(context, p.type);
    }
    final plantId = _unwrapRtid(p.type);
    return ResourceNames.lookup(context, PlantRepository().getName(plantId));
  }

  String? _addEntryIconPath(ModifyConveyorPlantData p) {
    if (p.isToolEntry) {
      final t = ToolRepository.get(p.type);
      return t?.icon != null ? 'assets/images/tools/${t!.icon}' : null;
    }
    final plantId = _unwrapRtid(p.type);
    return PlantRepository().getPlantInfoById(plantId)?.iconAssetPath;
  }

  String _removeEntryTitle(ModifyConveyorRemoveData r, AppLocalizations? l10n) {
    if (r.isToolEntry) {
      return ToolRepository.localizedName(context, r.type);
    }
    final plantId = _unwrapRtid(r.type);
    return ResourceNames.lookup(context, PlantRepository().getName(plantId));
  }

  String? _removeEntryIconPath(ModifyConveyorRemoveData r) {
    if (r.isToolEntry) {
      final t = ToolRepository.get(r.type);
      return t?.icon != null ? 'assets/images/tools/${t!.icon}' : null;
    }
    final plantId = _unwrapRtid(r.type);
    return PlantRepository().getPlantInfoById(plantId)?.iconAssetPath;
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final hasConveyor = widget.levelFile.objects.any(
      (o) => o.objClass == 'ConveyorSeedBankProperties',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.eventConveyorModify ?? 'Conveyor modify event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpModifyConveyorBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.add ?? 'Add',
                  body: l10n?.eventHelpModifyConveyorAdd ?? '',
                ),
                HelpSectionData(
                  title: l10n?.remove ?? 'Remove',
                  body: l10n?.eventHelpModifyConveyorRemove ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              if (!hasConveyor)
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(editorErrorIcon, color: theme.colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n?.modifyConveyorMissingModule ??
                                'Level has no conveyor module. This event may not work.',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!hasConveyor) const SizedBox(height: 16),
              _buildAddListCard(theme, l10n),
              const SizedBox(height: 16),
              _buildRemoveListCard(theme, l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddListCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.modifyConveyorAddPoolTitle ?? 'Add to conveyor pool',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            EditorResponsiveFieldRow(
              children: [
                OutlinedButton.icon(
                  onPressed: _openAddPlantPicker,
                  icon: const Icon(Icons.eco, size: 18),
                  label: Text(l10n?.addPlantConveyor ?? 'Add plant'),
                ),
                OutlinedButton.icon(
                  onPressed: _openAddToolPicker,
                  icon: const Icon(Icons.build, size: 18),
                  label: Text(l10n?.addTool ?? 'Add tool'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_data.addList.isEmpty)
              Text(
                l10n?.modifyConveyorAddPoolEmpty ??
                    'No entries. Add a plant or tool, then configure weights.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ..._data.addList.asMap().entries.map((e) {
                final idx = e.key;
                final p = e.value;
                final iconPath = _addEntryIconPath(p);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () => _editAddEntry(idx),
                    leading: _modifyConveyorLeadingAvatar(
                      theme,
                      iconPath,
                      p.isToolEntry,
                    ),
                    title: Text(_addEntryTitle(p, l10n)),
                    subtitle: Text(
                      l10n?.weightMaxFormat(p.weight, p.maxCount) ??
                          'Weight: ${p.weight}, Max: ${p.maxCount}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _data.addList.removeAt(idx);
                        _sync();
                      },
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveListCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.modifyConveyorRemovePoolTitle ?? 'Remove from conveyor',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            EditorResponsiveFieldRow(
              children: [
                OutlinedButton.icon(
                  onPressed: _openRemovePlantPicker,
                  icon: const Icon(Icons.eco, size: 18),
                  label: Text(l10n?.addPlantConveyor ?? 'Add plant'),
                ),
                OutlinedButton.icon(
                  onPressed: _openRemoveToolPicker,
                  icon: const Icon(Icons.build, size: 18),
                  label: Text(l10n?.addTool ?? 'Add tool'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._data.removeList.asMap().entries.map((e) {
              final idx = e.key;
              final r = e.value;
              final iconPath = _removeEntryIconPath(r);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _modifyConveyorLeadingAvatar(
                    theme,
                    iconPath,
                    r.isToolEntry,
                  ),
                  title: Text(_removeEntryTitle(r, l10n)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _data.removeList.removeAt(idx);
                      _sync();
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Tool art is portrait (~130×155); plants use square icons with rounded corners.
  Widget _modifyConveyorLeadingAvatar(
    ThemeData theme,
    String? iconPath,
    bool isTool,
  ) {
    if (iconPath == null) {
      return Icon(
        isTool ? Icons.build : Icons.eco,
        color: theme.colorScheme.primary,
        size: 40,
      );
    }
    if (isTool) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 58,
          child: AssetImageWidget(
            assetPath: iconPath,
            altCandidates: imageAltCandidates(iconPath),
            width: 48,
            height: 58,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 52,
        height: 52,
        child: AssetImageWidget(
          assetPath: iconPath,
          altCandidates: imageAltCandidates(iconPath),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ModifyConveyorEntryDialog extends StatefulWidget {
  const _ModifyConveyorEntryDialog({
    required this.l10n,
    required this.entry,
    required this.isTool,
    required this.hasCustomLevelModule,
    required this.onDismiss,
    required this.onConfirm,
  });

  final AppLocalizations? l10n;
  final ModifyConveyorPlantData entry;
  final bool isTool;
  final bool hasCustomLevelModule;
  final VoidCallback onDismiss;
  final VoidCallback onConfirm;

  @override
  State<_ModifyConveyorEntryDialog> createState() =>
      _ModifyConveyorEntryDialogState();
}

class _ModifyConveyorEntryDialogState
    extends State<_ModifyConveyorEntryDialog> {
  late int _weight;
  late int _level;
  late bool _iAvatar;
  late int _maxCount;
  late double _maxWeightFactor;
  late int _minCount;
  late double _minWeightFactor;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _weight = e.weight;
    _level = e.iLevel ?? 0;
    _iAvatar = e.iAvatar ?? false;
    _maxCount = e.maxCount;
    _maxWeightFactor = e.maxWeightFactor;
    _minCount = e.minCount;
    _minWeightFactor = e.minWeightFactor;
  }

  void _apply() {
    final e = widget.entry;
    e.weight = _weight;
    e.maxCount = _maxCount;
    e.maxWeightFactor = _maxWeightFactor;
    e.minCount = _minCount;
    e.minWeightFactor = _minWeightFactor;
    if (widget.isTool) {
      e.iLevel = null;
      e.iAvatar = null;
    } else {
      e.iLevel = _level <= 0 ? null : _level;
      e.iAvatar = _iAvatar;
    }
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    final isTool = widget.isTool;
    return AlertDialog(
      title: Text(l10n?.modifyConveyorEntryEditTitle ?? 'Conveyor entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isTool)
              _McNumField(
                label: l10n?.initialWeight ?? 'Weight',
                value: _weight,
                onChanged: (v) => setState(() => _weight = v),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _McNumField(
                      label: l10n?.initialWeight ?? 'Weight',
                      value: _weight,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _McNumField(
                      label: l10n?.plantLevelLabel ?? 'Plant level (iLevel)',
                      value: _level,
                      onChanged: (v) => setState(() => _level = v.clamp(0, 5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: widget.hasCustomLevelModule ? 0.5 : 1.0,
                child: Tooltip(
                  message: l10n?.conveyorPlantWearCostumeTooltip ?? '',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n?.conveyorPlantWearCostume ??
                          'Wear costume (iAvatar)',
                    ),
                    value: _iAvatar,
                    onChanged: widget.hasCustomLevelModule
                        ? null
                        : (v) => setState(() => _iAvatar = v),
                  ),
                ),
              ),
            ],
            const Divider(height: 20),
            Text(
              l10n?.maxLimits ?? 'Max limits',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _McNumField(
                    label: l10n?.maxCountThreshold ?? 'Max count',
                    value: _maxCount,
                    onChanged: (v) => setState(() => _maxCount = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _McDoubleField(
                    label: l10n?.weightFactor ?? 'Max weight factor',
                    value: _maxWeightFactor,
                    onChanged: (v) => setState(() => _maxWeightFactor = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.minLimits ?? 'Min limits',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _McNumField(
                    label: l10n?.minCountThreshold ?? 'Min count',
                    value: _minCount,
                    onChanged: (v) => setState(() => _minCount = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _McDoubleField(
                    label: l10n?.weightFactor ?? 'Min weight factor',
                    value: _minWeightFactor,
                    onChanged: (v) => setState(() => _minWeightFactor = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(onPressed: _apply, child: Text(l10n?.ok ?? 'OK')),
      ],
    );
  }
}

class _McNumField extends StatelessWidget {
  const _McNumField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return EditorResponsiveInputField(
      label: label,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (s) => onChanged(int.tryParse(s) ?? 0),
      ),
    );
  }
}

class _McDoubleField extends StatelessWidget {
  const _McDoubleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return EditorResponsiveInputField(
      label: label,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (s) => onChanged(double.tryParse(s) ?? 0.0),
      ),
    );
  }
}
