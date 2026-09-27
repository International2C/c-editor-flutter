import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/gravity_range_preview.dart';

class GravityGeneratorEventScreen extends StatefulWidget {
  const GravityGeneratorEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<GravityGeneratorEventScreen> createState() =>
      _GravityGeneratorEventScreenState();
}

class _GravityGeneratorEventScreenState
    extends State<GravityGeneratorEventScreen> {
  static const _objClass = 'GravityGeneratorWaveActionProps';
  late String _alias;
  late PvzObject _object;
  late GravityGeneratorWaveActionPropsData _data;
  final _controllers = <String, TextEditingController>{};
  final _fieldKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _object =
        widget.levelFile.objects.firstWhereOrNull(
          (o) => o.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: GravityGeneratorWaveActionPropsData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_object)) {
      widget.levelFile.objects.add(_object);
    }
    _data = GravityGeneratorWaveActionPropsData.fromJson(
      Map<String, dynamic>.from(_object.objData as Map),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _sync() {
    _object.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  Future<void> _addRestrictions(bool plants) async {
    // Exclusions use raw type names, rather than resource RTIDs.
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (pickerContext) => plants
            ? PlantSelectionScreen(
                isMultiSelect: true,
                excludeIds: _data.targetRestriction,
                stateBucketId: 'gravity-excluded-plants',
                onPlantSelected: (id) => Navigator.pop(pickerContext, [id]),
                onMultiPlantSelected: (ids) =>
                    Navigator.pop(pickerContext, ids),
                onBack: () => Navigator.pop(pickerContext),
              )
            : ZombieSelectionScreen(
                multiSelect: true,
                excludeIds: _data.targetRestriction,
                stateBucketId: 'gravity-excluded-zombies',
                onZombieSelected: (id) => Navigator.pop(pickerContext, [id]),
                onMultiZombieSelected: (ids) =>
                    Navigator.pop(pickerContext, ids),
                onBack: () => Navigator.pop(pickerContext),
              ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _data.targetRestriction = {..._data.targetRestriction, ...result}.toList();
    _sync();
  }

  Widget _number(
    String key,
    String label,
    num value,
    ValueChanged<num> change, {
    bool integer = false,
    bool signed = false,
    num minimum = 0,
  }) {
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: '$value'),
    );
    return EditorResponsiveInputField(
      // Keep the input mounted when responsive rows switch to columns.
      key: _fieldKeys.putIfAbsent(key, () => GlobalKey()),
      label: label,
      builder: (context, decoration) => TextField(
        key: ValueKey('gravity-$key'),
        controller: controller,
        decoration: decoration,
        keyboardType: TextInputType.numberWithOptions(
          decimal: !integer,
          signed: signed,
        ),
        onChanged: (text) {
          final parsed = integer ? int.tryParse(text) : num.tryParse(text);
          if (parsed == null ||
              !parsed.isFinite ||
              (!signed && parsed < minimum)) {
            return;
          }
          change(parsed);
          _sync();
        },
      ),
    );
  }

  double get _fieldBreakpoint =>
      600 *
      (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
        1,
        double.infinity,
      );

  Widget _fieldRows(List<Widget> fields) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < fields.length; i += 2)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: EditorResponsiveFieldRow(
            breakpoint: _fieldBreakpoint,
            children: fields.skip(i).take(2).toList(),
          ),
        ),
    ],
  );

  Widget _card(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  Widget _heading(String title) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  );

  Widget _choice(
    String key,
    String value,
    Map<String, String> options,
    ValueChanged<String> change,
  ) => RadioGroup<String>(
    groupValue: value,
    onChanged: (selected) {
      if (selected != null) {
        change(selected);
        _sync();
      }
    },
    child: EditorResponsiveFieldRow(
      breakpoint: _fieldBreakpoint,
      spacing: 0,
      children: options.entries
          .map(
            (entry) => RadioListTile<String>(
              key: ValueKey('gravity-$key-${entry.key}'),
              value: entry.key,
              title: Text(entry.value),
              contentPadding: EdgeInsets.zero,
            ),
          )
          .toList(),
    ),
  );

  Widget _restriction(String id, AppLocalizations l10n) {
    final plant = ResourceNames.lookup(context, 'plant_$id');
    final zombie = ResourceNames.lookup(context, 'zombie_$id');
    final isPlant = plant != 'plant_$id';
    final isZombie = zombie != 'zombie_$id';
    final name = isPlant
        ? plant
        : isZombie
        ? zombie
        : id;
    final icon = isPlant
        ? PlantRepository().getPlantInfoById(id)?.iconAssetPath ??
              'assets/images/others/unknown.webp'
        : isZombie
        ? ZombieRepository().getZombieById(id)?.iconAssetPath ??
              'assets/images/others/unknown.webp'
        : 'assets/images/others/unknown.webp';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AssetImageWidget(
            assetPath: icon,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                if (name != id)
                  Text(id, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('gravity-remove-$id'),
            tooltip: l10n.remove,
            onPressed: () {
              _data.targetRestriction.remove(id);
              _sync();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gridMode = _data.targetType == 'grid';
    final (rows, cols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
    final parameters = <String, String>{
      'ActivationDelay': l10n.gravityActivationDelay,
      'Duration': l10n.gravityDuration,
      'DeployDuration': l10n.gravityDeployDuration,
      'ChargeDuration': l10n.gravityChargeDuration,
      'RetractDuration': l10n.gravityRetractDuration,
      'PlantExitDelay': l10n.gravityPlantExitDelay,
      'ZombieRiseDuration': l10n.gravityZombieRiseDuration,
      'ZombieTranslateDuration': l10n.gravityZombieTranslateDuration,
      'ZombieFallDuration': l10n.gravityZombieFallDuration,
      'ZombieLiftHeight': l10n.gravityZombieLiftHeight,
      'ZombieForwardDistance': l10n.gravityZombieForwardDistance,
      'HeavyPlantSinkDuration': l10n.gravityHeavyPlantSinkDuration,
    };
    Widget parameter(String key) => _number(
      key,
      parameters[key]!,
      _data.parameter(key),
      (n) => _data.parameters[key] = n,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: l10n.eventTitle_GravityGeneratorWaveActionProps,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n.eventTitle_GravityGeneratorWaveActionProps,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.gravityHelpOverview,
                ),
                HelpSectionData(
                  title: l10n.gravityAnti,
                  body: l10n.gravityHelpAnti,
                ),
                HelpSectionData(
                  title: l10n.gravityHeavy,
                  body: l10n.gravityHelpHeavy,
                ),
                HelpSectionData(
                  title: l10n.gravityHelpParametersTitle,
                  body: l10n.gravityHelpParameters,
                ),
                HelpSectionData(
                  title: l10n.gravityHelpTipsTitle,
                  body: l10n.gravitySequentialNotice,
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
            EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: (value) {
                renameLevelObjectAlias(
                  levelFile: widget.levelFile,
                  oldAlias: _alias,
                  newAlias: value,
                  onChanged: widget.onChanged,
                );
                setState(() => _alias = value);
              },
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 12),
            _card([
              _heading(l10n.gravityLevel),
              _choice('level', _data.gravityLevel, {
                'anti': l10n.gravityAnti,
                'heavy': l10n.gravityHeavy,
              }, (v) => _data.gravityLevel = v),
              _heading(l10n.gravityTargetType),
              _choice(
                'target',
                _data.targetType,
                {
                  'plant': l10n.gravityTargetPlant,
                  'grid': l10n.gravityTargetGrid,
                },
                (v) {
                  _data.targetType = v;
                  if (v == 'grid') _data.targetGrid ??= TileLocationData();
                },
              ),
              _fieldRows([parameter('ActivationDelay'), parameter('Duration')]),
            ]),
            const SizedBox(height: 12),
            _card([
              _heading(l10n.gravityPreviewTitle),
              const SizedBox(height: 8),
              Text(
                gridMode
                    ? l10n.gravityGridRangeHint
                    : l10n.gravityPlantRangeHint,
              ),
              const SizedBox(height: 12),
              GravityRangePreview(
                data: _data,
                rows: rows,
                cols: cols,
                onTargetChanged: (col, row) {
                  _data.targetGrid = TileLocationData(mx: col, my: row);
                  _controllers['TargetX']?.text = '$col';
                  _controllers['TargetY']?.text = '$row';
                  _sync();
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${_data.gravityLevel == 'heavy' ? l10n.gravityHeavy : l10n.gravityAnti} · ${l10n.gravityCenterLegend}',
              ),
              if (gridMode)
                _fieldRows([
                  _number(
                    'TargetX',
                    l10n.gravityTargetX,
                    _data.targetGrid?.mx ?? 0,
                    (n) => (_data.targetGrid ??= TileLocationData()).mx = n
                        .toInt(),
                    integer: true,
                    signed: true,
                  ),
                  _number(
                    'TargetY',
                    l10n.gravityTargetY,
                    _data.targetGrid?.my ?? 0,
                    (n) => (_data.targetGrid ??= TileLocationData()).my = n
                        .toInt(),
                    integer: true,
                    signed: true,
                  ),
                ]),
              _fieldRows([
                _number(
                  'RangeX',
                  l10n.gravityRangeX,
                  _data.range.mX,
                  (n) => _data.range.mX = n.toInt(),
                  integer: true,
                  signed: true,
                ),
                _number(
                  'RangeY',
                  l10n.gravityRangeY,
                  _data.range.mY,
                  (n) => _data.range.mY = n.toInt(),
                  integer: true,
                  signed: true,
                ),
                _number(
                  'RangeWidth',
                  l10n.gravityRangeWidth,
                  _data.range.mWidth,
                  (n) => _data.range.mWidth = n.toInt(),
                  integer: true,
                  minimum: 1,
                ),
                _number(
                  'RangeHeight',
                  l10n.gravityRangeHeight,
                  _data.range.mHeight,
                  (n) => _data.range.mHeight = n.toInt(),
                  integer: true,
                  minimum: 1,
                ),
              ]),
            ]),
            const SizedBox(height: 12),
            _card([
              _heading(l10n.gravityRestrictions),
              const SizedBox(height: 8),
              Text(l10n.gravityRestrictionHint),
              const SizedBox(height: 8),
              if (_data.targetRestriction.isEmpty) Text(l10n.emptyList),
              for (final id in _data.targetRestriction) _restriction(id, l10n),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('gravity-add-plants'),
                onPressed: () => _addRestrictions(true),
                icon: const Icon(Icons.eco),
                label: Text(l10n.gravityAddPlantRestriction),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('gravity-add-zombies'),
                onPressed: () => _addRestrictions(false),
                icon: const Icon(Icons.groups),
                label: Text(l10n.gravityAddZombieRestriction),
              ),
            ]),
            const SizedBox(height: 12),
            Card(
              child: ExpansionTile(
                key: const ValueKey('gravity-advanced-settings'),
                title: _heading(l10n.gravityAdvancedSettings),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _fieldRows([
                    for (final key in [
                      'DeployDuration',
                      'ChargeDuration',
                      'RetractDuration',
                    ])
                      parameter(key),
                  ]),
                  const SizedBox(height: 16),
                  _heading(
                    _data.gravityLevel == 'heavy'
                        ? l10n.gravityHeavy
                        : l10n.gravityAnti,
                  ),
                  _fieldRows([
                    if (_data.gravityLevel == 'heavy')
                      parameter('HeavyPlantSinkDuration')
                    else
                      for (final key in [
                        'PlantExitDelay',
                        'ZombieRiseDuration',
                        'ZombieTranslateDuration',
                        'ZombieFallDuration',
                        'ZombieLiftHeight',
                        'ZombieForwardDistance',
                      ])
                        parameter(key),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
