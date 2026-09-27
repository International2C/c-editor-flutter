import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Conveyor belt properties. Ported from Z-Editor-master ConveyorSeedBankPropertiesEP.kt
class ConveyorSeedBankPropertiesScreen extends StatefulWidget {
  const ConveyorSeedBankPropertiesScreen({
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

  /// Injects a level module by [objClass] (e.g. [PowerTileProperties]).
  final void Function(String objClass)? onAddModule;

  @override
  State<ConveyorSeedBankPropertiesScreen> createState() =>
      _ConveyorSeedBankPropertiesScreenState();
}

class _ConveyorSeedBankPropertiesScreenState
    extends State<ConveyorSeedBankPropertiesScreen> {
  static const _objClass = 'ConveyorSeedBankProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late ConveyorBeltData _data;
  int _listKey = 0;

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
        objClass: 'ConveyorSeedBankProperties',
        objData: _createDefaultConveyorData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ConveyorBeltData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
      if (_data.dropDelayConditions.isEmpty && _data.speedConditions.isEmpty) {
        final manualPacketSpawning = _data.manualPacketSpawning;
        _data = _createDefaultConveyorData()
          ..manualPacketSpawning = manualPacketSpawning;
      }
    } catch (_) {
      _data = _createDefaultConveyorData();
    }
    _data = ConveyorBeltData(
      initialPlantList: List.from(_data.initialPlantList),
      dropDelayConditions: List.from(_data.dropDelayConditions),
      speedConditions: List.from(_data.speedConditions),
      manualPacketSpawning: _data.manualPacketSpawning,
    );
  }

  ConveyorBeltData _createDefaultConveyorData() {
    return ConveyorBeltData(
      initialPlantList: [],
      speedConditions: [SpeedConditionData(maxPacketsSpeed: 0, speed: 100)],
      dropDelayConditions: [
        DropDelayConditionData(maxPacketsDelay: 0, delay: 3),
        DropDelayConditionData(maxPacketsDelay: 2, delay: 6),
        DropDelayConditionData(maxPacketsDelay: 4, delay: 8),
        DropDelayConditionData(maxPacketsDelay: 9, delay: 10),
      ],
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addPlant() {
    widget.onRequestPlantSelection((id) {
      setState(() {
        _data.initialPlantList.add(InitialPlantListData(plantType: id));
        _listKey++;
        _sync();
      });
    });
  }

  bool _hasPowerTileModule() =>
      widget.levelFile.objects.any((o) => o.objClass == 'PowerTileProperties');

  static bool _isPowerTileTool(String id) => id.startsWith('tool_powertile_');

  void _addTool() {
    widget.onRequestToolSelection((id) {
      void commit() {
        setState(() {
          _data.initialPlantList.add(InitialPlantListData(plantType: id));
          _listKey++;
          _sync();
        });
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
                  'Power tile tools need the Power Tiles module in this level. Add the default module now?',
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
                  commit();
                },
                child: Text(l10n?.add ?? 'Add'),
              ),
            ],
          ),
        );
      } else {
        commit();
      }
    });
  }

  void _removePlant(int index) {
    setState(() {
      _data.initialPlantList.removeAt(index);
      _listKey++;
      _sync();
    });
  }

  void _editPlant(InitialPlantListData item, AppLocalizations? l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _PlantDetailDialog(
        l10n: l10n,
        data: item,
        hasCustomLevelModule: widget.levelFile.objects.any(
          (o) => o.objClass == 'CustomLevelModuleProperties',
        ),
        onDismiss: () => Navigator.pop(ctx),
        onConfirm: () {
          _listKey++;
          _sync();
          Navigator.pop(ctx);
        },
      ),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(l10n),
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
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              _ConveyorPlantListEditor(
                l10n: l10n,
                items: _data.initialPlantList,
                onAddPlant: _addPlant,
                onAddTool: _addTool,
                onEdit: (item) => _editPlant(item, l10n),
                onRemove: _removePlant,
                listKey: _listKey,
              ),
              const SizedBox(height: 20),
              _ConveyorConditionEditor(
                title:
                    l10n?.dropDelayConditions ??
                    'Drop delay (DropDelayConditions)',
                subtitle: l10n?.unitSeconds ?? 'Unit: seconds',
                items: _data.dropDelayConditions,
                extractMaxPackets: (e) => e.maxPacketsDelay,
                onValueChange: _sync,
                onAdd: () {
                  var next =
                      (_data.dropDelayConditions
                          .map((e) => e.maxPacketsDelay)
                          .fold<int>(0, (a, b) => a > b ? a : b)) +
                      2;
                  if (next >= 9) next = 9;
                  _data.dropDelayConditions.add(
                    DropDelayConditionData(delay: 6, maxPacketsDelay: next),
                  );
                  _sync();
                },
                onRemove: (i) {
                  _data.dropDelayConditions.removeAt(i);
                  _sync();
                },
                buildRow: (item, sync) => Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: '${l10n?.threshold ?? 'Threshold'} (MaxPackets)',
                        value: item.maxPacketsDelay,
                        onChanged: (v) {
                          item.maxPacketsDelay = v;
                          sync();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: '${l10n?.delay ?? 'Delay'} (Delay)',
                        value: item.delay,
                        onChanged: (v) {
                          item.delay = v;
                          sync();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ConveyorConditionEditor(
                title: l10n?.speedConditions ?? 'Speed (SpeedConditions)',
                subtitle:
                    l10n?.speedConditionsSubtitle ??
                    'Standard value 100, higher = faster',
                items: _data.speedConditions,
                extractMaxPackets: (e) => e.maxPacketsSpeed,
                onValueChange: _sync,
                onAdd: () {
                  var next =
                      (_data.speedConditions
                          .map((e) => e.maxPacketsSpeed)
                          .fold<int>(0, (a, b) => a > b ? a : b)) +
                      2;
                  if (next >= 9) next = 9;
                  _data.speedConditions.add(
                    SpeedConditionData(speed: 100, maxPacketsSpeed: next),
                  );
                  _sync();
                },
                onRemove: (i) {
                  _data.speedConditions.removeAt(i);
                  _sync();
                },
                buildRow: (item, sync) => Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: '${l10n?.threshold ?? 'Threshold'} (MaxPackets)',
                        value: item.maxPacketsSpeed,
                        onChanged: (v) {
                          item.maxPacketsSpeed = v;
                          sync();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: l10n?.speed ?? 'Speed',
                        value: item.speed,
                        onChanged: (v) {
                          item.speed = v;
                          sync();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelp(AppLocalizations? l10n) {
    showEditorHelpDialog(
      context,
      isEvent: false,
      title: l10n?.conveyorBeltHelp ?? 'Conveyor Belt',
      sections: [
        HelpSectionData(
          title: l10n?.overview ?? 'Overview',
          body:
              l10n?.conveyorBeltHelpIntro ??
              'Conveyor mode randomly generates cards by weight. Configure plant pool and refresh delay.',
        ),
        HelpSectionData(
          title: l10n?.conveyorCardPool ?? 'Conveyor Pool',
          body:
              l10n?.conveyorBeltHelpPool ??
              'Plant pool & weight: Probability = weight / total weight. Use thresholds to adjust dynamically.',
        ),
        HelpSectionData(
          title: l10n?.dropDelayConditions ?? 'Seed packet delay',
          body:
              l10n?.conveyorBeltHelpDropDelay ??
              'Drop delay controls the card spawn interval.',
        ),
        HelpSectionData(
          title: l10n?.speedConditions ?? 'Conveyor speed',
          body:
              l10n?.conveyorBeltHelpSpeed ??
              'Speed controls the physical belt speed.',
        ),
      ],
    );
  }
}

class _ConveyorPlantListEditor extends StatelessWidget {
  const _ConveyorPlantListEditor({
    required this.l10n,
    required this.items,
    required this.onAddPlant,
    required this.onAddTool,
    required this.onEdit,
    required this.onRemove,
    required this.listKey,
  });

  final AppLocalizations? l10n;
  final List<InitialPlantListData> items;
  final VoidCallback onAddPlant;
  final VoidCallback onAddTool;
  final void Function(InitialPlantListData) onEdit;
  final void Function(int) onRemove;
  final int listKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.linear_scale, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.conveyorCardPool ?? 'Conveyor card pool',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EditorResponsiveFieldRow(
              children: [
                OutlinedButton.icon(
                  onPressed: onAddPlant,
                  icon: const Icon(Icons.eco, size: 18),
                  label: Text(l10n?.addPlantConveyor ?? 'Add plant'),
                ),
                OutlinedButton.icon(
                  onPressed: onAddTool,
                  icon: const Icon(Icons.build, size: 18),
                  label: Text(l10n?.addTool ?? 'Add tool'),
                ),
              ],
            ),
            const Divider(height: 24),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  l10n?.noCardsYetAddPlants ??
                      'No cards yet. Add plants or tools.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...List.generate(items.length, (i) {
                final item = items[i];
                return _PlantRow(
                  key: ValueKey('$listKey-$i-${item.plantType}'),
                  l10n: l10n,
                  plant: item,
                  onEdit: () => onEdit(item),
                  onDelete: () => onRemove(i),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _PlantRow extends StatelessWidget {
  const _PlantRow({
    super.key,
    required this.l10n,
    required this.plant,
    required this.onEdit,
    required this.onDelete,
  });

  final AppLocalizations? l10n;
  final InitialPlantListData plant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolInfo = ToolRepository.get(plant.plantType);
    final isTool = toolInfo != null;
    final plantInfo = PlantRepository().getPlantInfoById(plant.plantType);
    final displayName = isTool
        ? ToolRepository.localizedName(context, plant.plantType)
        : ResourceNames.lookup(
            context,
            PlantRepository().getName(plant.plantType),
          );
    final iconPath = isTool
        ? (toolInfo.icon != null
              ? 'assets/images/tools/${toolInfo.icon}'
              : null)
        : plantInfo?.iconAssetPath;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                iconPath != null
                    ? (isTool
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 48,
                                height: 58,
                                child: AssetImageWidget(
                                  assetPath: iconPath,
                                  width: 48,
                                  height: 58,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 52,
                                height: 52,
                                child: AssetImageWidget(
                                  assetPath: iconPath,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))
                    : SizedBox(
                        width: isTool ? 48 : 52,
                        height: isTool ? 58 : 52,
                        child: Container(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Text(
                            '${l10n?.weight ?? 'Weight'}: ${plant.weight}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (!isTool) ...[
                            Text(
                              plant.iLevel != null
                                  ? (l10n?.levelFormat(plant.iLevel!) ??
                                        'Level: ${plant.iLevel}')
                                  : (l10n?.levelAccount ?? 'Level: account'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantDetailDialog extends StatefulWidget {
  const _PlantDetailDialog({
    required this.l10n,
    required this.data,
    required this.hasCustomLevelModule,
    required this.onDismiss,
    required this.onConfirm,
  });

  final AppLocalizations? l10n;
  final InitialPlantListData data;
  final bool hasCustomLevelModule;
  final VoidCallback onDismiss;
  final VoidCallback onConfirm;

  @override
  State<_PlantDetailDialog> createState() => _PlantDetailDialogState();
}

class _PlantDetailDialogState extends State<_PlantDetailDialog> {
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
    _weight = widget.data.weight;
    _level = widget.data.iLevel ?? 0;
    _iAvatar = widget.data.iAvatar ?? false;
    _maxCount = widget.data.maxCount;
    _maxWeightFactor = widget.data.maxWeightFactor;
    _minCount = widget.data.minCount;
    _minWeightFactor = widget.data.minWeightFactor;
  }

  void _save() {
    final isTool = widget.data.isToolEntry;
    widget.data.weight = _weight;
    widget.data.maxCount = _maxCount;
    widget.data.maxWeightFactor = _maxWeightFactor;
    widget.data.minCount = _minCount;
    widget.data.minWeightFactor = _minWeightFactor;
    if (isTool) {
      widget.data.iLevel = null;
      widget.data.iAvatar = null;
    } else {
      widget.data.iLevel = _level <= 0 ? null : _level;
      widget.data.iAvatar = _iAvatar;
    }
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    final toolInfo = ToolRepository.get(widget.data.plantType);
    final isTool = toolInfo != null;
    final displayName = isTool
        ? ToolRepository.localizedName(context, widget.data.plantType)
        : ResourceNames.lookup(
            context,
            PlantRepository().getName(widget.data.plantType),
          );

    // AlertDialog uses IntrinsicWidth, which cannot measure LayoutBuilder
    // (EditorResponsiveInputField). Use a fixed-width Dialog instead.
    final media = MediaQuery.of(context);
    final inset = media.size.width < 600
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    final dialogWidth = (media.size.width - inset.horizontal).clamp(
      280.0,
      480.0,
    );
    const dialogPadding = EdgeInsets.fromLTRB(24, 20, 24, 12);
    const actionsGap = 12.0;
    const estimatedActionsHeight = 52.0;
    final maxDialogHeight =
        media.size.height - inset.vertical - media.viewInsets.bottom;
    final bodyMaxHeight =
        maxDialogHeight - dialogPadding.vertical - estimatedActionsHeight;

    final form = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n?.editAlias(displayName) ?? 'Edit: $displayName',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (isTool)
          _NumberField(
            label: l10n?.initialWeight ?? 'Initial weight',
            value: _weight,
            onChanged: (v) => setState(() => _weight = v),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  label: l10n?.initialWeight ?? 'Initial weight',
                  value: _weight,
                  onChanged: (v) => setState(() => _weight = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberField(
                  label: l10n?.plantLevelLabel ?? 'Plant level',
                  value: _level,
                  onChanged: (v) => setState(() => _level = v.clamp(0, 5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.followAccountLevel ??
                'Level 0 plants use their corresponding tier from the player\'s account.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: widget.hasCustomLevelModule ? 0.5 : 1.0,
            child: Tooltip(
              message:
                  l10n?.conveyorPlantWearCostumeTooltip ??
                  'When enabled, the seed packet may show a plant costume. '
                      'Not available in Creative Courtyard levels.',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n?.conveyorPlantWearCostume ?? 'Wear costume (iAvatar)',
                ),
                value: _iAvatar,
                onChanged: widget.hasCustomLevelModule
                    ? null
                    : (v) => setState(() => _iAvatar = v),
              ),
            ),
          ),
        ],
        const Divider(height: 24),
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
              child: _NumberField(
                label: l10n?.maxCountThreshold ?? 'Max count threshold',
                value: _maxCount,
                onChanged: (v) => setState(() => _maxCount = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DoubleField(
                label: l10n?.weightFactor ?? 'Weight factor',
                value: _maxWeightFactor,
                onChanged: (v) => setState(() => _maxWeightFactor = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              child: _NumberField(
                label: l10n?.minCountThreshold ?? 'Min count threshold',
                value: _minCount,
                onChanged: (v) => setState(() => _minCount = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DoubleField(
                label: l10n?.weightFactor ?? 'Weight factor',
                value: _minWeightFactor,
                onChanged: (v) => setState(() => _minWeightFactor = v),
              ),
            ),
          ],
        ),
      ],
    );

    return Dialog(
      insetPadding: inset,
      child: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxDialogHeight),
          child: Padding(
            padding: dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: bodyMaxHeight),
                  child: SingleChildScrollView(child: form),
                ),
                const SizedBox(height: actionsGap),
                OverflowBar(
                  spacing: 8,
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onDismiss,
                      child: Text(l10n?.cancel ?? 'Cancel'),
                    ),
                    FilledButton(
                      onPressed: _save,
                      child: Text(l10n?.ok ?? 'OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConveyorConditionEditor<T> extends StatelessWidget {
  const _ConveyorConditionEditor({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.extractMaxPackets,
    required this.onValueChange,
    required this.onAdd,
    required this.onRemove,
    required this.buildRow,
  });

  final String title;
  final String subtitle;
  final List<T> items;
  final int Function(T) extractMaxPackets;
  final VoidCallback onValueChange;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final Widget Function(T, VoidCallback) buildRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const double trailingSlot = 48;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
              ],
            ),
            const SizedBox(height: 8),
            ...items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isBase = extractMaxPackets(item) == 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: buildRow(item, onValueChange)),
                    SizedBox(
                      width: trailingSlot,
                      height: trailingSlot,
                      child: isBase
                          ? Center(
                              child: Icon(
                                Icons.lock_outline,
                                size: 22,
                                color: theme.colorScheme.outline,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => onRemove(idx),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
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
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (s) {
          final v = int.tryParse(s) ?? 0;
          onChanged(v);
        },
      ),
    );
  }
}

class _DoubleField extends StatelessWidget {
  const _DoubleField({
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
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (s) {
          final v = double.tryParse(s) ?? 0.0;
          onChanged(v);
        },
      ),
    );
  }
}
