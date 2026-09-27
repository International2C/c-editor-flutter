import 'package:flutter/material.dart';
import 'package:c_editor/data/challenge_resource_l10n.dart';
import 'package:c_editor/data/condition_l10n.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/zombie_conditions.dart'
    show StarChallengeProfessions;
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_condition_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_numeric_text_field.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';

String _resolveZombieDisplayType(String typeName) {
  final alias = ZombiePropertiesRepository.getTypeNameByAlias(typeName);
  return typeName.contains('_') ? typeName : alias;
}

String _localizedZombieName(BuildContext context, String typeName) {
  final displayType = _resolveZombieDisplayType(typeName);
  final zombie = ZombieRepository().getZombieById(displayType);
  if (zombie != null) {
    final localized = ResourceNames.lookup(context, zombie.name);
    if (localized != zombie.name) return localized;
  }
  return displayType;
}

Widget _starChallengeEntityCard({
  required BuildContext context,
  required String title,
  Widget? leading,
  String? subtitle,
  VoidCallback? onEdit,
  VoidCallback? onRemove,
  Key? cardKey,
  Key? identityKey,
  Key? actionsKey,
}) {
  final theme = Theme.of(context);
  final identity = Column(
    key: identityKey,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      if (subtitle?.trim().isNotEmpty == true)
        Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
    ],
  );
  final hasActions = onEdit != null || onRemove != null;
  final actions = Row(
    key: actionsKey,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (onEdit != null)
        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
      if (onRemove != null)
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onRemove,
        ),
    ],
  );
  return Card(
    key: cardKey,
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
          final compact = constraints.maxWidth < 320 || textScale > 1.3;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (leading != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      leading,
                      if (hasActions) ...[const Spacer(), actions],
                    ],
                  ),
                if (leading != null) const SizedBox(height: 8),
                identity,
                if (leading == null && hasActions)
                  Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 12)],
              Expanded(child: identity),
              if (hasActions) ...[const SizedBox(width: 8), actions],
            ],
          );
        },
      ),
    ),
  );
}

/// Shared labeled int field (no stepper buttons).
class StarChallengeLabeledIntField extends StatelessWidget {
  const StarChallengeLabeledIntField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => EditorNumericTextField(
        value: value,
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (s) => onChanged(int.tryParse(s) ?? value),
      ),
    );
  }
}

/// Resizable multiline description field.
class StarChallengeDescriptionField extends StatefulWidget {
  const StarChallengeDescriptionField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.minLines = 3,
    this.maxLines = 8,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int minLines;
  final int maxLines;

  @override
  State<StarChallengeDescriptionField> createState() =>
      _StarChallengeDescriptionFieldState();
}

class _StarChallengeDescriptionFieldState
    extends State<StarChallengeDescriptionField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(StarChallengeDescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorResponsiveInputField(
          label: widget.label,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          builder: (context, decoration) => TextField(
            controller: _controller,
            decoration: decoration,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
          ),
        ),
        if (widget.hint?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(
            widget.hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class StarChallengeLabeledBoolField extends StatelessWidget {
  const StarChallengeLabeledBoolField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final compact = constraints.maxWidth < 360 || textScale > 1.3;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, key: ValueKey('starChallengeBoolLabel_$label')),
              Align(
                alignment: Alignment.centerRight,
                child: Switch(
                  key: ValueKey('starChallengeBoolSwitch_$label'),
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ],
          );
        }
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label, key: ValueKey('starChallengeBoolLabel_$label')),
          value: value,
          onChanged: onChanged,
        );
      },
    );
  }
}

// --- ApplyZombieConditionsChallengeProps ---

class ApplyZombieConditionsChallengeEditor extends StatefulWidget {
  const ApplyZombieConditionsChallengeEditor({
    super.key,
    required this.object,
    required this.onChanged,
  });

  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<ApplyZombieConditionsChallengeEditor> createState() =>
      _ApplyZombieConditionsChallengeEditorState();
}

class _ApplyZombieConditionsChallengeEditorState
    extends State<ApplyZombieConditionsChallengeEditor> {
  late Map<String, dynamic> _data;

  String get _objClass => widget.object.objClass;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.object.objData as Map);
    _ensureDefaults();
  }

  void _ensureDefaults() {
    _data.putIfAbsent('ConditionToInflict', () => <String>[]);
    _data.putIfAbsent('IncludeBurnedToAsh', () => true);
    _data.putIfAbsent('IncludeElectrified', () => true);
    _data.putIfAbsent('NumZombieConditionsToApply', () => 5);
  }

  List<String> get _conditions =>
      (_data['ConditionToInflict'] as List?)?.cast<String>().toList() ?? [];

  void _save() {
    widget.object.objData = _data;
    widget.onChanged();
  }

  void _openConditionPicker() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieConditionSelectionScreen(
          stateBucketId:
              'challenge:${identityHashCode(widget.object)}:zombie-condition',
          initialSelected: _conditions,
          onBack: () => Navigator.pop(ctx),
          onDone: (selected) {
            Navigator.pop(ctx);
            setState(() {
              _data['ConditionToInflict'] = selected;
              _save();
            });
          },
        ),
      ),
    );
  }

  void _removeConditionAt(int index) {
    setState(() {
      final list = List<String>.from(_conditions);
      list.removeAt(index);
      _data['ConditionToInflict'] = list;
      _save();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final conditions = _conditions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarChallengeLabeledIntField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'NumZombieConditionsToApply',
          ),
          value: _data['NumZombieConditionsToApply'] as int? ?? 5,
          onChanged: (v) {
            setState(() {
              _data['NumZombieConditionsToApply'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        StarChallengeLabeledBoolField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'IncludeBurnedToAsh',
          ),
          value: _data['IncludeBurnedToAsh'] as bool? ?? true,
          onChanged: (v) {
            setState(() {
              _data['IncludeBurnedToAsh'] = v;
              _save();
            });
          },
        ),
        StarChallengeLabeledBoolField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'IncludeElectrified',
          ),
          value: _data['IncludeElectrified'] as bool? ?? true,
          onChanged: (v) {
            setState(() {
              _data['IncludeElectrified'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          ChallengeResourceL10n.property(
            context,
            _objClass,
            'ConditionToInflict',
          ),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (conditions.isEmpty)
          Text(
            l10n?.emptyList ?? 'Empty list',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...conditions.asMap().entries.map((e) {
            final id = e.value;
            return _starChallengeEntityCard(
              context: context,
              title: ConditionL10n.zombieLabel(context, id),
              subtitle: id,
              onRemove: () => _removeConditionAt(e.key),
              cardKey: ValueKey('starChallengeConditionCard_${e.key}'),
              identityKey: ValueKey('starChallengeConditionIdentity_${e.key}'),
              actionsKey: ValueKey('starChallengeConditionActions_${e.key}'),
            );
          }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openConditionPicker,
          icon: const Icon(Icons.checklist),
          label: Text(l10n?.starChallengeEditConditions ?? 'Edit conditions'),
        ),
      ],
    );
  }
}

// --- PlantDefeatZombieChallengeProps ---

class PlantDefeatZombieChallengeEditor extends StatefulWidget {
  const PlantDefeatZombieChallengeEditor({
    super.key,
    required this.object,
    required this.onChanged,
    this.levelFile,
  });

  final PvzObject object;
  final VoidCallback onChanged;
  final PvzLevelFile? levelFile;

  @override
  State<PlantDefeatZombieChallengeEditor> createState() =>
      _PlantDefeatZombieChallengeEditorState();
}

class _PlantDefeatZombieChallengeEditorState
    extends State<PlantDefeatZombieChallengeEditor> {
  late Map<String, dynamic> _data;

  String get _objClass => widget.object.objClass;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.object.objData as Map);
    _data.putIfAbsent('Description', () => '');
    _data.putIfAbsent('NumZombiesToKill', () => 12);
    _data.putIfAbsent('PlantTypeName', () => 'peashooter');
  }

  void _save() {
    widget.object.objData = _data;
    widget.onChanged();
  }

  String _plantLabel(String id) {
    final plant = PlantRepository().getPlantInfoById(id);
    if (plant == null) return id;
    final localized = ResourceNames.lookup(context, plant.name);
    return localized != plant.name ? localized : id;
  }

  void _pickPlant() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => PlantSelectionScreen(
          onPlantSelected: (id) {
            Navigator.pop(ctx);
            setState(() {
              _data['PlantTypeName'] = id;
              _save();
            });
          },
          onBack: () => Navigator.pop(ctx),
          levelFile: widget.levelFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plantId = _data['PlantTypeName'] as String? ?? '';
    final plant = PlantRepository().getPlantInfoById(plantId);
    final plantIconPath =
        plant?.iconAssetPath ?? 'assets/images/others/unknown.webp';
    final plantName = _plantLabel(plantId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarChallengeDescriptionField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'Description',
          ),
          hint: l10n?.starChallengeChineseUnsupportedHint,
          value: _data['Description'] as String? ?? '',
          onChanged: (v) {
            setState(() {
              _data['Description'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        StarChallengeLabeledIntField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'NumZombiesToKill',
          ),
          value: _data['NumZombiesToKill'] as int? ?? 12,
          onChanged: (v) {
            setState(() {
              _data['NumZombiesToKill'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        Text(
          ChallengeResourceL10n.property(context, _objClass, 'PlantTypeName'),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _starChallengeEntityCard(
          context: context,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: AssetImageWidget(
                assetPath: plantIconPath,
                fit: BoxFit.contain,
                altCandidates: imageAltCandidates(plantIconPath),
              ),
            ),
          ),
          title: plantName,
          subtitle: plantId,
          onEdit: _pickPlant,
          cardKey: const ValueKey('starChallengePlantCard'),
          identityKey: const ValueKey('starChallengePlantIdentity'),
          actionsKey: const ValueKey('starChallengePlantActions'),
        ),
      ],
    );
  }
}

// --- DefeatZombiesOfTypeChallengeProps ---

class DefeatZombiesOfTypeChallengeEditor extends StatefulWidget {
  const DefeatZombiesOfTypeChallengeEditor({
    super.key,
    required this.object,
    required this.onChanged,
    this.levelFile,
  });

  final PvzObject object;
  final VoidCallback onChanged;
  final PvzLevelFile? levelFile;

  @override
  State<DefeatZombiesOfTypeChallengeEditor> createState() =>
      _DefeatZombiesOfTypeChallengeEditorState();
}

class _DefeatZombiesOfTypeChallengeEditorState
    extends State<DefeatZombiesOfTypeChallengeEditor> {
  late Map<String, dynamic> _data;

  String get _objClass => widget.object.objClass;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.object.objData as Map);
    _data.putIfAbsent('Description', () => '');
    _data.putIfAbsent('NumZombiesToKill', () => 30);
    _data.putIfAbsent(
      'TypesToKill',
      () => <String, dynamic>{'List': <String>[], 'ListType': 'whitelist'},
    );
  }

  Map<String, dynamic> get _typesToKill {
    final raw = _data['TypesToKill'];
    if (raw is Map<String, dynamic>) return raw;
    return {'List': <String>[], 'ListType': 'whitelist'};
  }

  List<String> get _zombieList =>
      (_typesToKill['List'] as List?)?.cast<String>().toList() ?? [];

  String get _listType => _typesToKill['ListType'] as String? ?? 'whitelist';

  void _save() {
    widget.object.objData = _data;
    widget.onChanged();
  }

  void _setTypesToKill(List<String> list, String listType) {
    _data['TypesToKill'] = {'List': list, 'ListType': listType};
  }

  String _zombieLabel(String typeName) =>
      _localizedZombieName(context, typeName);

  void _addZombies() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          multiSelect: true,
          onZombieSelected: (_) {},
          onMultiZombieSelected: (ids) {
            Navigator.pop(ctx);
            setState(() {
              _setTypesToKill(List<String>.from(ids), _listType);
              _save();
            });
          },
          onBack: () => Navigator.pop(ctx),
          initialSelectedIds: _zombieList,
        ),
      ),
    );
  }

  void _removeZombieAt(int index) {
    setState(() {
      final list = List<String>.from(_zombieList);
      list.removeAt(index);
      _setTypesToKill(list, _listType);
      _save();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listType = _listType;
    final zombies = _zombieList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarChallengeDescriptionField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'Description',
          ),
          hint: l10n?.starChallengeChineseUnsupportedHint,
          value: _data['Description'] as String? ?? '',
          onChanged: (v) {
            setState(() {
              _data['Description'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        StarChallengeLabeledIntField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'NumZombiesToKill',
          ),
          value: _data['NumZombiesToKill'] as int? ?? 30,
          onChanged: (v) {
            setState(() {
              _data['NumZombiesToKill'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        EditorResponsiveInputField(
          label: ChallengeResourceL10n.property(context, _objClass, 'ListType'),
          builder: (context, decoration) => DropdownButtonFormField<String>(
            isExpanded: true,
            key: ValueKey(listType),
            initialValue: listType == 'blacklist' ? 'blacklist' : 'whitelist',
            decoration: decoration,
            items: ['whitelist', 'blacklist']
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      ChallengeResourceL10n.listTypeOption(
                        context,
                        _objClass,
                        t,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _setTypesToKill(_zombieList, v);
                _save();
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                ChallengeResourceL10n.property(
                  context,
                  _objClass,
                  'TypesToKill',
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: _addZombies),
          ],
        ),
        if (zombies.isEmpty)
          Text(l10n?.emptyList ?? 'Empty list')
        else
          ...zombies.asMap().entries.map((e) {
            final typeName = e.value;
            final displayType = _resolveZombieDisplayType(typeName);
            final zombie = ZombieRepository().getZombieById(displayType);
            final iconPath =
                zombie?.iconAssetPath ?? 'assets/images/others/unknown.webp';
            final name = _zombieLabel(typeName);
            return _starChallengeEntityCard(
              context: context,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: AssetImageWidget(
                    assetPath: iconPath,
                    fit: BoxFit.contain,
                    altCandidates: imageAltCandidates(iconPath),
                  ),
                ),
              ),
              title: name,
              subtitle: typeName,
              onRemove: () => _removeZombieAt(e.key),
              cardKey: ValueKey('starChallengeZombieCard_${e.key}'),
              identityKey: ValueKey('starChallengeZombieIdentity_${e.key}'),
              actionsKey: ValueKey('starChallengeZombieActions_${e.key}'),
            );
          }),
      ],
    );
  }
}

// --- DestroyGridItemsChallengeProps ---

class DestroyGridItemsChallengeEditor extends StatefulWidget {
  const DestroyGridItemsChallengeEditor({
    super.key,
    required this.object,
    required this.onChanged,
    required this.levelFile,
    this.onAddModule,
    this.onOpenCustomStageSelection,
  });

  final PvzObject object;
  final VoidCallback onChanged;
  final PvzLevelFile? levelFile;
  final void Function(String objClass)? onAddModule;
  final Future<void> Function()? onOpenCustomStageSelection;

  @override
  State<DestroyGridItemsChallengeEditor> createState() =>
      _DestroyGridItemsChallengeEditorState();
}

class _DestroyGridItemsChallengeEditorState
    extends State<DestroyGridItemsChallengeEditor> {
  late Map<String, dynamic> _data;

  String get _objClass => widget.object.objClass;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.object.objData as Map);
    _data.putIfAbsent('GridItemType', () => 'gravestone');
    _data.putIfAbsent('GridItemsToDestroy', () => 10);
    _data.putIfAbsent('ChallengeDescription', () => '');
  }

  void _save() {
    widget.object.objData = _data;
    widget.onChanged();
  }

  String _gridLabel(String typeName) {
    final key = 'griditem_$typeName';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : typeName;
  }

  void _pickGridItem() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => GridItemSelectionScreen(
          filterMode: GridItemFilterMode.all,
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
          onOpenCustomStageSelection: widget.onOpenCustomStageSelection,
          onGridItemSelected: (id) {
            Navigator.pop(ctx);
            setState(() {
              final stored = GridItemRepository.buildGridAliases(id);
              _data['GridItemType'] = stored;
              _save();
            });
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gridType = _data['GridItemType'] as String? ?? 'gravestone';
    final displayType = gridType == 'gravestone'
        ? 'gravestone_egypt'
        : gridType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarChallengeDescriptionField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'ChallengeDescription',
          ),
          hint: l10n?.starChallengeChineseUnsupportedHint,
          value: _data['ChallengeDescription'] as String? ?? '',
          onChanged: (v) {
            setState(() {
              _data['ChallengeDescription'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        StarChallengeLabeledIntField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'GridItemsToDestroy',
          ),
          value: _data['GridItemsToDestroy'] as int? ?? 10,
          onChanged: (v) {
            setState(() {
              _data['GridItemsToDestroy'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        _starChallengeEntityCard(
          context: context,
          leading: PresetAwareGridItemIcon(
            typeName: displayType,
            size: 44,
            fit: BoxFit.contain,
          ),
          title: _gridLabel(displayType),
          subtitle: gridType,
          onEdit: _pickGridItem,
          cardKey: const ValueKey('starChallengeGridItemCard'),
          identityKey: const ValueKey('starChallengeGridItemIdentity'),
          actionsKey: const ValueKey('starChallengeGridItemActions'),
        ),
      ],
    );
  }
}

// --- StarChallengeDisablePlantProps ---

class StarChallengeDisablePlantEditor extends StatefulWidget {
  const StarChallengeDisablePlantEditor({
    super.key,
    required this.object,
    required this.onChanged,
  });

  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<StarChallengeDisablePlantEditor> createState() =>
      _StarChallengeDisablePlantEditorState();
}

class _StarChallengeDisablePlantEditorState
    extends State<StarChallengeDisablePlantEditor> {
  late Map<String, dynamic> _data;

  String get _objClass => widget.object.objClass;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.object.objData as Map);
    _data.putIfAbsent('Profession', () => 'warrior');
  }

  void _save() {
    widget.object.objData = _data;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _data['Profession'] as String? ?? 'warrior';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ChallengeResourceL10n.property(context, _objClass, 'Profession'),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...StarChallengeProfessions.ids.map((id) {
          final isSelected = selected == id;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _data['Profession'] = id;
                  _save();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale =
                        MediaQuery.textScalerOf(context).scale(16) / 16;
                    final compact =
                        constraints.maxWidth < 280 || textScale > 1.3;
                    final icon = ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        StarChallengeProfessions.iconAsset(id),
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.yard),
                      ),
                    );
                    final check = isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null;
                    final label = Text(
                      ChallengeResourceL10n.profession(context, id),
                    );
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              icon,
                              if (check != null) ...[const Spacer(), check],
                            ],
                          ),
                          const SizedBox(height: 8),
                          label,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        icon,
                        const SizedBox(width: 12),
                        Expanded(child: label),
                        if (check != null) ...[const SizedBox(width: 8), check],
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Single integer field challenge (Count, PoisonToClean, etc.).
class StarChallengeCountFieldEditor extends StatefulWidget {
  const StarChallengeCountFieldEditor({
    super.key,
    required this.object,
    required this.onChanged,
    required this.field,
    this.defaultValue = 8,
  });

  final PvzObject object;
  final VoidCallback onChanged;
  final String field;
  final int defaultValue;

  @override
  State<StarChallengeCountFieldEditor> createState() =>
      _StarChallengeCountFieldEditorState();
}

class _StarChallengeCountFieldEditorState
    extends State<StarChallengeCountFieldEditor> {
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.object.objData as Map);
    _data.putIfAbsent(widget.field, () => widget.defaultValue);
  }

  void _save() {
    widget.object.objData = _data;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final value = _data[widget.field];
    final intVal = value is int
        ? value
        : int.tryParse('$value') ?? widget.defaultValue;
    return StarChallengeLabeledIntField(
      label: ChallengeResourceL10n.property(
        context,
        widget.object.objClass,
        widget.field,
      ),
      value: intVal,
      onChanged: (v) {
        setState(() {
          _data[widget.field] = v;
          _save();
        });
      },
    );
  }
}
