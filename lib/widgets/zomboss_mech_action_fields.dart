import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/models/zomboss_robot_spawn_entry.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/portal_type_selector.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';
import 'package:c_editor/widgets/zomboss_mech_robot_spawn_list.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:c_editor/widgets/zomboss_mech_zombie_type_list.dart';

/// Dynamic editors for zomboss action objdata from catalog field specs.
class ZombossMechActionFieldsEditor extends StatelessWidget {
  const ZombossMechActionFieldsEditor({
    super.key,
    required this.mechId,
    required this.fields,
    required this.data,
    required this.onChanged,
    this.editable = true,
    this.objclass = '',
    this.levelFile,
    this.depth = 0,
    this.fieldNamePrefix = '',
    this.hiddenFieldNames = const {},
    this.catalog,
    this.onPickJumpAction,
  });

  final String mechId;
  final List<ZombossMechFieldSpec> fields;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;
  final bool editable;
  final String objclass;
  final PvzLevelFile? levelFile;
  final int depth;
  final String fieldNamePrefix;
  final Set<String> hiddenFieldNames;
  final ZombossMechCatalogEntry? catalog;
  final Future<String?> Function(String currentRtid)? onPickJumpAction;

  String _fullFieldName(ZombossMechFieldSpec field) {
    if (fieldNamePrefix.isEmpty) return field.name;
    return '${fieldNamePrefix}_${field.name}';
  }

  String _fieldLabel(BuildContext context, ZombossMechFieldSpec field) {
    final label = mechId.isEmpty || objclass.isEmpty
        ? field.name
        : ZombossMechL10n.fieldLabel(
            context,
            mechId,
            objclass,
            _fullFieldName(field),
            fallback: field.name,
          );
    if (!ZombossMechActionUtils.usesSecondsUnit(field) ||
        _alreadyHasSecondsUnit(label)) {
      return label;
    }
    var unit = AppLocalizations.of(context)?.unitSeconds ?? 'Unit: seconds';
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode != 'zh' && unit.isNotEmpty) {
      unit = '${unit[0].toLowerCase()}${unit.substring(1)}';
    }
    final closeParen = label.lastIndexOf(')');
    if (closeParen < 0) return '$label ($unit)';
    final separator = languageCode == 'zh' ? '，' : ', ';
    return '${label.substring(0, closeParen)}$separator$unit${label.substring(closeParen)}';
  }

  bool _alreadyHasSecondsUnit(String label) {
    final normalized = label.toLowerCase();
    return normalized.contains('秒') ||
        normalized.contains('second') ||
        normalized.contains('секунд');
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final hasWeightedZombieList =
        fields.any((field) => field.name == 'ZombieNames') &&
        fields.any((field) => field.name == 'ZombieWeights');
    for (final field in fields) {
      if (field.name.isEmpty || field.name.startsWith('#')) continue;
      if (hiddenFieldNames.contains(field.name)) continue;
      if (hasWeightedZombieList && field.name == 'ZombieWeights') continue;
      children.add(_buildField(context, field));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildField(BuildContext context, ZombossMechFieldSpec field) {
    final padding = EdgeInsets.only(left: depth * 12.0, top: 8, bottom: 4);
    final label = _fieldLabel(context, field);

    if (field.name == 'ZombieNames' &&
        fields.any((item) => item.name == 'ZombieWeights')) {
      final weightField = fields.firstWhere(
        (item) => item.name == 'ZombieWeights',
        orElse: () =>
            ZombossMechFieldSpec(name: 'ZombieWeights', type: 'List<int>'),
      );
      final ids = ZombossMechActionUtils.parseZombieTypeList(data[field.name]);
      final weights = _parseIntList(data['ZombieWeights'], ids.length);
      return Padding(
        padding: padding,
        child: ZombossMechWeightedZombieListEditor(
          fieldLabel: label,
          weightLabel: _fieldLabel(context, weightField),
          zombieIds: ids,
          weights: weights,
          editable: editable,
          onChanged: (nextIds, nextWeights) {
            data[field.name] = nextIds;
            data['ZombieWeights'] = nextWeights;
            onChanged();
          },
        ),
      );
    }

    if (ZombossMechActionUtils.isZombieTypeField(field)) {
      final raw = data[field.name];
      if (field.name == 'SpawnZombieTypes' &&
          (zombossActionUsesRobotSpawnList(objclass) ||
              ZombossRobotSpawnEntry.isRobotSpawnList(raw))) {
        final entries = ZombossRobotSpawnEntry.parseList(raw);
        return Padding(
          padding: padding,
          child: ZombossMechRobotSpawnListEditor(
            fieldLabel: label,
            entries: entries,
            levelFile: levelFile,
            editable: editable,
            onChanged: (next) {
              data[field.name] = ZombossRobotSpawnEntry.toJsonList(next);
              onChanged();
            },
          ),
        );
      }

      final isList = ZombossMechActionUtils.isZombieTypeListField(field);
      final ids = isList
          ? ZombossMechActionUtils.parseZombieTypeList(raw)
          : [if (raw != null && raw.toString().isNotEmpty) raw.toString()];
      return Padding(
        padding: padding,
        child: ZombossMechZombieTypeListEditor(
          fieldLabel: label,
          zombieIds: ids,
          editable: editable,
          isList: isList,
          onChanged: (next) {
            if (isList) {
              data[field.name] = next;
            } else {
              data[field.name] = next.isNotEmpty ? next.first : '';
            }
            onChanged();
          },
        ),
      );
    }

    if (isZombossJumpActionField(field)) {
      return _buildJumpActionField(context, field, padding, label);
    }

    if (field.name == 'PortalType' && field.type == 'string') {
      final value = data[field.name] ?? field.defaultValue ?? '';
      return Padding(
        padding: padding,
        child: PortalTypeSingleSelectField(
          label: label,
          value: value.toString(),
          editable: editable,
          levelFile: levelFile,
          onLevelChanged: onChanged,
          catalog: objclass == 'ZombossSpawnPortalActionDefinition'
              ? PortalTypeCatalog.zomboss
              : PortalTypeCatalog.regular,
          onChanged: (next) {
            data[field.name] = next;
            onChanged();
          },
        ),
      );
    }

    if (field.type == 'object' && field.objectFields.isNotEmpty) {
      final nested = data[field.name];
      final nestedMap = nested is Map<String, dynamic>
          ? nested
          : nested is Map
          ? Map<String, dynamic>.from(nested)
          : ZombossMechActionUtils.defaultsFromFields(field.objectFields);
      if (nested is! Map) data[field.name] = nestedMap;
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            ZombossMechActionFieldsEditor(
              mechId: mechId,
              fields: field.objectFields,
              data: nestedMap,
              onChanged: onChanged,
              editable: editable,
              objclass: objclass,
              levelFile: levelFile,
              depth: depth,
              fieldNamePrefix: _fullFieldName(field),
              catalog: catalog,
              onPickJumpAction: onPickJumpAction,
            ),
          ],
        ),
      );
    }

    if (field.type == 'List<object>' && field.objectFields.isNotEmpty) {
      final raw = data[field.name];
      final entries = raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (entry) => ZombossMechActionUtils.cloneMap(
                    Map<String, dynamic>.from(entry),
                  ),
                )
                .toList()
          : <Map<String, dynamic>>[];
      return Padding(
        padding: padding,
        child: _ObjectListField(
          label: label,
          entries: entries,
          editable: editable,
          onAdd: () {
            entries.add(
              ZombossMechActionUtils.defaultsFromFields(field.objectFields),
            );
            data[field.name] = entries;
            onChanged();
          },
          onRemove: (index) {
            entries.removeAt(index);
            data[field.name] = entries;
            onChanged();
          },
          itemBuilder: (entry, index) => ZombossMechActionFieldsEditor(
            mechId: mechId,
            fields: field.objectFields,
            data: entry,
            onChanged: () {
              data[field.name] = entries;
              onChanged();
            },
            editable: editable,
            objclass: objclass,
            levelFile: levelFile,
            depth: depth + 1,
            fieldNamePrefix: _fullFieldName(field),
            catalog: catalog,
            onPickJumpAction: onPickJumpAction,
          ),
        ),
      );
    }

    if (field.type == 'List<string>') {
      final raw = data[field.name];
      final values = raw is List
          ? raw.map((value) => value.toString()).toList()
          : <String>[];
      return Padding(
        padding: padding,
        child: _StringListField(
          label: label,
          values: values,
          editable: editable,
          onChanged: (next) {
            data[field.name] = next;
            onChanged();
          },
        ),
      );
    }

    return Padding(
      padding: padding,
      child: _ScalarField(
        field: field,
        label: label,
        value: data[field.name],
        editable: editable,
        onChanged: (v) {
          data[field.name] = v;
          onChanged();
        },
      ),
    );
  }

  List<int> _parseIntList(dynamic raw, int expectedLength) {
    final values = <int>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is int) {
          values.add(item);
        } else if (item is num) {
          values.add(item.toInt());
        } else {
          values.add(int.tryParse(item.toString()) ?? 100);
        }
      }
    }
    while (values.length < expectedLength) {
      values.add(100);
    }
    if (values.length > expectedLength) {
      return values.take(expectedLength).toList();
    }
    return values;
  }

  Widget _buildJumpActionField(
    BuildContext context,
    ZombossMechFieldSpec field,
    EdgeInsets padding,
    String label,
  ) {
    final l10n = AppLocalizations.of(context);
    final isSpawnJump = field.name == 'SpawnJumpAction';
    final raw =
        data[field.name] ?? (isSpawnJump ? null : field.defaultValue) ?? '';
    final rtid = raw.toString();
    final isBuiltInSpawnJump = rtid == zombossSpawnJumpActionRtid;
    var tag = 'movement';
    Widget? leading;
    final catalog = this.catalog;
    final levelFile = this.levelFile;
    if (catalog != null && levelFile != null && rtid.isNotEmpty) {
      final resolved = ZombossMechActionUtils.resolveAction(
        rtid: rtid,
        catalog: catalog,
        levelFile: levelFile,
      );
      if (resolved != null && resolved.tag.isNotEmpty) {
        tag = resolved.tag;
      }
      leading = customActionOriginBadge(
        context: context,
        levelFile: levelFile,
        rtid: rtid,
      );
    }
    final picker = onPickJumpAction;
    final canPick =
        editable && (isSpawnJump ? !isBuiltInSpawnJump : picker != null);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ZombossMechActionRow(
            key: ValueKey('zomboss-jump-field-${field.name}'),
            label: isBuiltInSpawnJump
                ? l10n?.zombossMechSummonJump ?? 'Summon jump'
                : rtid.isEmpty
                ? '—'
                : ZombossMechActionUtils.displayLabel(rtid),
            tag: tag,
            mutedLabel: rtid.isEmpty,
            leading: leading,
            showRemoveButton: false,
            trailing: canPick
                ? IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.swap_horiz, size: 22),
                    tooltip: l10n?.zombossMechSelectAction ?? 'Select action',
                    onPressed: () async {
                      final next = isSpawnJump
                          ? await _pickSpawnJumpAction(context)
                          : await picker!(rtid);
                      if (next == null || next.isEmpty) return;
                      if (!context.mounted) return;
                      data[field.name] = next;
                      onChanged();
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Future<String?> _pickSpawnJumpAction(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n?.zombossMechSelectAction ?? 'Select action'),
        content: EditorOptionTile(
          selected: false,
          title: Text(l10n?.zombossMechSummonJump ?? 'Summon jump'),
          subtitle: const Text(zombossSpawnJumpActionRtid),
          onTap: () => Navigator.pop(dialogContext, zombossSpawnJumpActionRtid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ObjectListField extends StatelessWidget {
  const _ObjectListField({
    required this.label,
    required this.entries,
    required this.editable,
    required this.onAdd,
    required this.onRemove,
    required this.itemBuilder,
  });

  final String label;
  final List<Map<String, dynamic>> entries;
  final bool editable;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final Widget Function(Map<String, dynamic> entry, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
            if (editable)
              IconButton(
                tooltip: l10n?.add ?? 'Add',
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
              ),
          ],
        ),
        for (final indexed in entries.indexed)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${indexed.$1 + 1}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (editable)
                        IconButton(
                          tooltip: l10n?.remove ?? 'Remove',
                          onPressed: () => onRemove(indexed.$1),
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                  itemBuilder(indexed.$2, indexed.$1),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StringListField extends StatelessWidget {
  const _StringListField({
    required this.label,
    required this.values,
    required this.editable,
    required this.onChanged,
  });

  final String label;
  final List<String> values;
  final bool editable;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
            if (editable)
              IconButton(
                tooltip: l10n?.add ?? 'Add',
                onPressed: () => onChanged([...values, '']),
                icon: const Icon(Icons.add_circle_outline),
              ),
          ],
        ),
        for (final indexed in values.indexed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              key: ValueKey('string-list-${indexed.$1}-${indexed.$2}'),
              initialValue: indexed.$2,
              readOnly: !editable,
              decoration:
                  editorInputDecoration(
                    context,
                    labelText: '${indexed.$1 + 1}',
                  ).copyWith(
                    suffixIcon: editable
                        ? IconButton(
                            tooltip: l10n?.remove ?? 'Remove',
                            onPressed: () {
                              final next = List<String>.from(values)
                                ..removeAt(indexed.$1);
                              onChanged(next);
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
              onChanged: editable
                  ? (value) {
                      final next = List<String>.from(values);
                      next[indexed.$1] = value;
                      onChanged(next);
                    }
                  : null,
            ),
          ),
      ],
    );
  }
}

class _ScalarField extends StatefulWidget {
  const _ScalarField({
    required this.field,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.editable,
  });

  final ZombossMechFieldSpec field;
  final String label;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool editable;

  @override
  State<_ScalarField> createState() => _ScalarFieldState();
}

class _ScalarFieldState extends State<_ScalarField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textValue);
    _focusNode = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() {
    final f = _focusNode.hasFocus;
    if (_focused != f) setState(() => _focused = f);
  }

  String get _textValue {
    final v = widget.value ?? widget.field.defaultValue ?? '';
    return v.toString();
  }

  @override
  void didUpdateWidget(covariant _ScalarField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focused && oldWidget.value != widget.value) {
      _controller.text = _textValue;
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
    final field = widget.field;
    final label = widget.label;
    if (ZombossMechActionUtils.usesDecimalInput(field)) {
      return _buildResponsiveTextField(
        context,
        label: label,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        onChanged: widget.editable
            ? (v) {
                final parsed = num.tryParse(v);
                if (parsed != null) widget.onChanged(parsed);
              }
            : null,
      );
    }
    switch (field.type) {
      case 'bool':
        final checked = widget.value == true;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: checked,
          onChanged: widget.editable ? (v) => widget.onChanged(v) : null,
        );
      case 'int':
        if (ZombossMechActionUtils.usesLabeledIntInput(field)) {
          return _buildResponsiveTextField(
            context,
            label: label,
            keyboardType: TextInputType.number,
            onChanged: widget.editable
                ? (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null) widget.onChanged(parsed);
                  }
                : null,
          );
        }
        final intVal = _asInt(widget.value, field);
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 280;
            if (!widget.editable) {
              return Row(
                children: [
                  Expanded(child: Text(label)),
                  Text(
                    '$intVal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              );
            }
            final stepper = Row(
              mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: intVal > -999999
                      ? () => widget.onChanged(intVal - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$intVal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => widget.onChanged(intVal + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Text(label), stepper],
              );
            }
            return Row(
              children: [
                Expanded(child: Text(label)),
                stepper,
              ],
            );
          },
        );
      default:
        return _buildResponsiveTextField(
          context,
          label: label,
          onChanged: widget.editable ? (v) => widget.onChanged(v) : null,
        );
    }
  }

  Widget _buildResponsiveTextField(
    BuildContext context, {
    required String label,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return EditorResponsiveInputField(
      label: label,
      decoration: editorInputDecoration(context),
      builder: (context, decoration) => TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: !widget.editable,
        decoration: decoration,
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  int _asInt(dynamic value, ZombossMechFieldSpec field) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (field.defaultValue is int) return field.defaultValue as int;
    if (field.defaultValue is num) return (field.defaultValue as num).toInt();
    return 0;
  }
}
