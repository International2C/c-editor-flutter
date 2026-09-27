import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/theme/app_theme.dart'
    show pvzPurpleDark, pvzPurpleLight;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/utils/target_zombie_check.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Zombie Sun Drop module: editable sun drop values for tiers 1–6.
/// The serialized list retains ten values for game-format compatibility.
class ZombieSunDropModuleScreen extends StatefulWidget {
  const ZombieSunDropModuleScreen({
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
  final void Function(void Function(List<String>) onSelected)
  onRequestZombieSelection;

  @override
  State<ZombieSunDropModuleScreen> createState() =>
      _ZombieSunDropModuleScreenState();
}

class _ZombieSunDropModuleScreenState extends State<ZombieSunDropModuleScreen> {
  static const _objClass = 'LevelMutatorRiftTimedSunProps';
  late String _alias;
  late PvzObject _moduleObj;
  late RiftTimedSunModuleData _data;
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
        objClass: 'LevelMutatorRiftTimedSunProps',
        objData: RiftTimedSunModuleData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = RiftTimedSunModuleData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = RiftTimedSunModuleData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addZombies(List<String> selectedIds) {
    if (selectedIds.isEmpty) return;
    final repo = ZombieRepository();
    final newList = List<RiftTimedSunData>.from(_data.sunDrops);
    for (final id in selectedIds) {
      final alias = repo.buildZombieAliases(id);
      if (newList.none((e) => e.zombieTypeName == alias)) {
        newList.add(
          RiftTimedSunData(
            zombieTypeName: alias,
            sunDropValues: List.filled(10, 0),
          ),
        );
      }
    }
    _data = RiftTimedSunModuleData(sunDrops: newList);
    _sync();
  }

  void _deleteItem(RiftTimedSunData item) {
    final newList = List<RiftTimedSunData>.from(_data.sunDrops);
    newList.remove(item);
    _data = RiftTimedSunModuleData(sunDrops: newList);
    _sync();
  }

  void _updateItem(RiftTimedSunData oldItem, RiftTimedSunData newItem) {
    final newList = List<RiftTimedSunData>.from(_data.sunDrops);
    final idx = newList.indexOf(oldItem);
    if (idx >= 0) {
      newList[idx] = newItem;
      _data = RiftTimedSunModuleData(sunDrops: newList);
      _sync();
    }
  }

  void _openEditDialog(RiftTimedSunData item) {
    final themeColor = Theme.of(context).brightness == Brightness.dark
        ? pvzPurpleDark
        : pvzPurpleLight;
    showDialog<void>(
      context: context,
      builder: (ctx) => _SunValuesEditDialog(
        item: item,
        themeColor: themeColor,
        onDismiss: () => Navigator.pop(ctx),
        onConfirm: (updated) {
          _updateItem(item, updated);
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarColor = isDark ? pvzPurpleDark : pvzPurpleLight;

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.zombieSunDropHelpTitle ?? 'Zombie sun drop',
              themeColor: appBarColor,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.zombieSunDropHelpOverview ??
                      'Set sun dropped by specific zombies per tier (used in Pursuit). This module also disables sun shovel.',
                ),
                HelpSectionData(
                  title: l10n?.zombieSunDropHelpValues ?? 'Values',
                  body:
                      l10n?.zombieSunDropHelpValuesBody ??
                      'Six integers correspond to tiers 1–6. If the tier exceeds 6, the tier 1 value is used.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: appBarColor,
            ),
          ),
          Expanded(
            child: _data.sunDrops.isEmpty
                ? Center(
                    child: Text(
                      l10n?.zombieSunDropEmpty ?? 'No entries. Tap + to add.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _data.sunDrops.length,
                    itemBuilder: (context, index) {
                      final item = _data.sunDrops[index];
                      return _ZombieSunDropItemCard(
                        item: item,
                        themeColor: appBarColor,
                        onEdit: () => _openEditDialog(item),
                        onDelete: () => _deleteItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onRequestZombieSelection((selectedIds) {
            final l10n = AppLocalizations.of(context);
            for (final id in selectedIds) {
              if (isTargetZombieBlocked(id, widget.levelFile)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.targetZombieRequiresOakTrain ??
                          'Target zombies require the OakTrain module. Please add OakTrain to the level first.',
                    ),
                  ),
                );
                return;
              }
            }
            _addZombies(selectedIds);
          });
        },
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ZombieSunDropItemCard extends StatelessWidget {
  const _ZombieSunDropItemCard({
    required this.item,
    required this.themeColor,
    required this.onEdit,
    required this.onDelete,
  });

  final RiftTimedSunData item;
  final Color themeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeId = ZombiePropertiesRepository.getTypeNameByAlias(
      item.zombieTypeName,
    );
    final info =
        ZombieRepository().getZombieById(typeId) ??
        ZombieRepository().getZombieById(typeId.replaceAll('_elite', ''));
    final path = info?.icon != null
        ? 'assets/images/zombies/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    final nameKey = ZombieRepository().getName(typeId);
    final name = ResourceNames.lookup(context, nameKey);
    final firstDrop = item.sunDropValues.isNotEmpty ? item.sunDropValues[0] : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: AssetImageWidget(
                    assetPath: path,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    altCandidates: imageAltCandidates(path),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)?.zombieSunDropDefaultDrop ?? 'Default drop'}: $firstDrop ${AppLocalizations.of(context)?.zombieSunDropSun ?? 'sun'}',
                      style: TextStyle(fontSize: 12, color: themeColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunValuesEditDialog extends StatefulWidget {
  const _SunValuesEditDialog({
    required this.item,
    required this.themeColor,
    required this.onDismiss,
    required this.onConfirm,
  });

  final RiftTimedSunData item;
  final Color themeColor;
  final VoidCallback onDismiss;
  final void Function(RiftTimedSunData) onConfirm;

  @override
  State<_SunValuesEditDialog> createState() => _SunValuesEditDialogState();
}

class _SunValuesEditDialogState extends State<_SunValuesEditDialog> {
  static const _editableTierCount = 6;

  late List<int> _values;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _values = List<int>.from(widget.item.sunDropValues);
    while (_values.length < 10) {
      _values.add(0);
    }
    _values = _values.take(10).toList();
    _controllers = _values
        .take(_editableTierCount)
        .map((v) => TextEditingController(text: '$v'))
        .toList();
    _focusNodes = List.generate(_editableTierCount, (_) => FocusNode());
    for (final fn in _focusNodes) {
      fn.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final fn in _focusNodes) {
      fn.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      scrollable: true,
      constraints: const BoxConstraints.tightFor(width: 560),
      title: Text(
        l10n?.zombieSunDropEditTitle ?? 'Edit values',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.zombieSunDropEditHint ??
                      'Configure sun drops for tiers 1–6. Tiers above 6 use the tier 1 value.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_editableTierCount ~/ 2, (row) {
                  final i = row * 2;
                  final j = i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EditorResponsiveFieldRow(
                      children: [
                        EditorResponsiveInputField(
                          label:
                              l10n?.zombieSunDropTierLabel(i + 1) ??
                              'Tier ${i + 1}',
                          decoration: editorInputDecoration(
                            context,

                            focusColor: widget.themeColor,
                            isFocused: _focusNodes[i].hasFocus,
                          ),
                          builder: (context, decoration) => TextField(
                            focusNode: _focusNodes[i],
                            controller: _controllers[i],
                            decoration: decoration,
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 0) {
                                setState(() => _values[i] = n);
                              }
                            },
                          ),
                        ),
                        EditorResponsiveInputField(
                          label:
                              l10n?.zombieSunDropTierLabel(j + 1) ??
                              'Tier ${j + 1}',
                          decoration: editorInputDecoration(
                            context,

                            focusColor: widget.themeColor,
                            isFocused: _focusNodes[j].hasFocus,
                          ),
                          builder: (context, decoration) => TextField(
                            focusNode: _focusNodes[j],
                            controller: _controllers[j],
                            decoration: decoration,
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 0) {
                                setState(() => _values[j] = n);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfirm(
              RiftTimedSunData(
                zombieTypeName: widget.item.zombieTypeName,
                sunDropValues: List<int>.from(_values),
              ),
            );
          },
          child: Text(l10n?.save ?? 'Save'),
        ),
      ],
    );
  }
}
