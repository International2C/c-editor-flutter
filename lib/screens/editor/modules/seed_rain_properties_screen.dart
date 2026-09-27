import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show
        EditorResponsiveInputField,
        EditorFilledButton,
        EditorChoiceDialogOption,
        HelpSectionData,
        showEditorChoiceDialog,
        showEditorHelpDialog;
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Seed rain properties editor. Ported from Z-Editor-master SeedRainPropertiesEP.kt
class SeedRainPropertiesScreen extends StatefulWidget {
  const SeedRainPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
    this.editorCubit,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;
  final EditorCubit? editorCubit;

  @override
  State<SeedRainPropertiesScreen> createState() =>
      _SeedRainPropertiesScreenState();
}

class _SeedRainPropertiesScreenState extends State<SeedRainPropertiesScreen> {
  static const _objClass = 'SeedRainProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late SeedRainPropertiesData _data;
  late TextEditingController _rainIntervalCtrl;

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
        objClass: 'SeedRainProperties',
        objData: SeedRainPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SeedRainPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SeedRainPropertiesData();
    }
    _rainIntervalCtrl = TextEditingController(text: '${_data.rainInterval}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addPlant(List<String> ids) {
    final newList = List<SeedRainItem>.from(_data.seedRains);
    for (final id in ids) {
      newList.add(
        SeedRainItem(seedRainType: 0, plantTypeName: id, zombieTypeName: null),
      );
    }
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  void _addZombie(List<String> ids) {
    final newList = List<SeedRainItem>.from(_data.seedRains);
    for (final id in ids) {
      newList.add(
        SeedRainItem(
          seedRainType: 1,
          plantTypeName: null,
          zombieTypeName: ZombieRepository().buildZombieAliases(id),
        ),
      );
    }
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  void _addCollectable() {
    final newList = List<SeedRainItem>.from(_data.seedRains);
    newList.add(SeedRainItem(seedRainType: 2));
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  void _updateItem(SeedRainItem oldItem, SeedRainItem newItem) {
    final idx = _data.seedRains.indexOf(oldItem);
    if (idx >= 0) {
      final newList = List<SeedRainItem>.from(_data.seedRains);
      newList[idx] = newItem;
      _data = SeedRainPropertiesData(
        rainInterval: _data.rainInterval,
        seedRains: newList,
      );
      _sync();
    }
  }

  void _deleteItem(SeedRainItem item) {
    final newList = _data.seedRains.where((e) => e != item).toList();
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  Future<void> _showAddDialog(AppLocalizations? l10n) async {
    final choice = await showEditorChoiceDialog<String>(
      context,
      title: l10n?.seedRainAddContentTitle ?? 'Add seed-rain content',
      options: [
        EditorChoiceDialogOption(
          value: 'plant',
          icon: Icons.local_florist_outlined,
          title: l10n?.plant ?? 'Plant',
        ),
        EditorChoiceDialogOption(
          value: 'zombie',
          icon: Icons.pest_control_outlined,
          title: l10n?.zombie ?? 'Zombie',
        ),
        EditorChoiceDialogOption(
          value: 'collectable',
          icon: Icons.eco_outlined,
          title: l10n?.collectable ?? 'Collectible (Plant Food)',
        ),
      ],
    );
    if (choice == null || !mounted) return;
    if (choice == 'plant') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => PlantSelectionScreen(
            isMultiSelect: true,
            onPlantSelected: (_) {},
            onMultiPlantSelected: (ids) {
              _addPlant(ids);
              Navigator.pop(ctx);
            },
            onBack: () => Navigator.pop(ctx),
            levelFile: widget.levelFile,
            onAddModule: widget.onAddModule,
          ),
        ),
      );
    } else if (choice == 'zombie') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ZombieSelectionScreen(
            editorCubit: widget.editorCubit,
            multiSelect: true,
            onZombieSelected: (_) {},
            onMultiZombieSelected: (ids) {
              _addZombie(ids);
              Navigator.pop(ctx);
            },
            onBack: () => Navigator.pop(ctx),
          ),
        ),
      );
    } else if (choice == 'collectable') {
      _addCollectable();
    }
    if (mounted) setState(() {});
  }

  String _getItemName(BuildContext context, SeedRainItem item) {
    switch (item.seedRainType) {
      case 0:
        final alias =
            RtidParser.parse(item.plantTypeName ?? '')?.alias ??
            item.plantTypeName ??
            '';
        return ResourceNames.lookup(context, PlantRepository().getName(alias));
      case 1:
        final alias =
            RtidParser.parse(item.zombieTypeName ?? '')?.alias ??
            item.zombieTypeName ??
            '';
        final typeName = ZombiePropertiesRepository.getTypeNameByAlias(alias);
        return ResourceNames.lookup(
          context,
          ZombieRepository().getName(typeName),
        );
      case 2:
        return AppLocalizations.of(context)?.plantFood ?? 'Plant Food';
      default:
        return AppLocalizations.of(context)?.seedRainUnknownItem ?? 'Unknown';
    }
  }

  void _openEditDialog(SeedRainItem item, AppLocalizations? l10n) {
    var tempWeight = item.weight;
    var tempMaxCount = item.maxCount;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              constraints: const BoxConstraints.tightFor(width: 560),
              scrollable: true,
              title: Text(
                l10n?.editAlias(_getItemName(ctx, item)) ??
                    'Edit: ${_getItemName(ctx, item)}',
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditorResponsiveInputField(
                      label: l10n?.weight ?? 'Weight',
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      builder: (context, decoration) => TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: decoration,
                        initialValue: '$tempWeight',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) tempWeight = n;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditorResponsiveInputField(
                      label: l10n?.maxCount ?? 'Max count',
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      builder: (context, decoration) => TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: decoration,
                        initialValue: '$tempMaxCount',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) tempMaxCount = n;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    _updateItem(
                      item,
                      SeedRainItem(
                        seedRainType: item.seedRainType,
                        plantTypeName: item.plantTypeName,
                        zombieTypeName: item.zombieTypeName,
                        weight: tempWeight,
                        maxCount: tempMaxCount,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openDeleteDialog(SeedRainItem item, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.confirmDelete ?? 'Confirm delete'),
        content: Text(
          l10n?.removeItemConfirm(_getItemName(ctx, item)) ??
              'Remove ${_getItemName(ctx, item)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _deleteItem(item);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
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
    final theme = Theme.of(context);
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
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.moduleTitle_SeedRainProperties ?? 'Seed Rain',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.moduleHelpSeedRainBody ??
                      'At fixed intervals, this module causes item cards to fall from the sky.',
                ),
                HelpSectionData(
                  title:
                      l10n?.moduleHelpSeedRainParameters ??
                      'Parameter settings',
                  body:
                      l10n?.moduleHelpSeedRainParametersBody ??
                      'Weight determines an item\'s chance of dropping, while Max count limits how many copies may be present at once. Most zombies do not have matching zombie card icons.',
                ),
                HelpSectionData(
                  title: l10n?.moduleHelpSeedRainPlantLevels ?? 'Plant tiers',
                  body:
                      l10n?.plantLevelsFollowGlobal ??
                      'Plant cards dropped by this module use the tiers from the player\'s account. The Tier Definition module can override them uniformly.',
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
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditorResponsiveInputField(
                      label:
                          l10n?.rainIntervalSeconds ??
                          'Rain interval (seconds)',
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      builder: (context, decoration) => TextField(
                        key: const ValueKey('seedRainInterval'),
                        controller: _rainIntervalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: decoration,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = SeedRainPropertiesData(
                              rainInterval: n,
                              seedRains: _data.seedRains,
                            );
                            _sync();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: EditorFilledButton(
                        key: const ValueKey('seedRainAddItem'),
                        onPressed: () => _showAddDialog(l10n),
                        icon: const Icon(Icons.add),
                        label: Text(l10n?.addDropItem ?? 'Add drop item'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_data.seedRains.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n?.noItemsAddHint ??
                          'No items. Add plants, zombies, or collectables.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              ..._data.seedRains.map(
                (item) => _SeedRainRowCard(
                  item: item,
                  onTap: () => _openEditDialog(item, l10n),
                  onDelete: () => _openDeleteDialog(item, l10n),
                  getItemName: _getItemName,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeedRainRowCard extends StatelessWidget {
  const _SeedRainRowCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.getItemName,
  });

  final SeedRainItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(BuildContext, SeedRainItem) getItemName;

  String _localizedDropType(AppLocalizations? l10n, SeedRainItem item) {
    switch (item.seedRainType) {
      case 0:
        return l10n?.plant ?? 'Plant';
      case 1:
        return l10n?.zombie ?? 'Zombie';
      case 2:
        return l10n?.collectable ?? 'Collectible';
      default:
        return l10n?.seedRainUnknownItem ?? 'Unknown';
    }
  }

  String? _getIconPath(SeedRainItem item) {
    switch (item.seedRainType) {
      case 0:
        final alias =
            RtidParser.parse(item.plantTypeName ?? '')?.alias ??
            item.plantTypeName ??
            '';
        final info = PlantRepository().getPlantInfoById(alias);
        if (info?.icon != null) return 'assets/images/plants/${info!.icon}';
        return null;
      case 1:
        final alias =
            RtidParser.parse(item.zombieTypeName ?? '')?.alias ??
            item.zombieTypeName ??
            '';
        final typeName = ZombiePropertiesRepository.getTypeNameByAlias(alias);
        final info = ZombieRepository().getZombieById(typeName);
        if (info?.icon != null) return 'assets/images/zombies/${info!.icon}';
        return null;
      case 2:
        return 'assets/images/others/plantfood.webp';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final typeName = getItemName(context, item);
    final dropType = _localizedDropType(l10n, item);
    final iconPath = _getIconPath(item);
    final metaStyle = theme.textTheme.bodySmall;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconPath != null
                    ? AssetImageWidget(
                        assetPath: iconPath,
                        fit: BoxFit.contain,
                        width: 48,
                        height: 48,
                      )
                    : Center(
                        child: Text(
                          typeName.isNotEmpty ? typeName[0] : '?',
                          style: theme.textTheme.titleLarge?.copyWith(
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
                      typeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          l10n?.seedRainTypeLabel(dropType) ??
                              'Type: $dropType',
                          style: metaStyle,
                        ),
                        Text(
                          l10n?.seedRainWeightLabel(item.weight) ??
                              'Weight: ${item.weight}',
                          style: metaStyle,
                        ),
                        Text(
                          l10n?.seedRainMaxLabel(item.maxCount) ??
                              'Max: ${item.maxCount}',
                          style: metaStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
