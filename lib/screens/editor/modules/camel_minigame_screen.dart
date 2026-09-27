import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/camel_minigame_conflicts.dart';
import 'package:c_editor/widgets/camel_spawn_distance_preview.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class CamelMinigameScreen extends StatefulWidget {
  const CamelMinigameScreen({
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
  State<CamelMinigameScreen> createState() => _CamelMinigameScreenState();
}

class _CamelMinigameScreenState extends State<CamelMinigameScreen> {
  static const _objClass = 'CamelMinigameProperties';
  late PvzObject _moduleObj;
  late Map<String, dynamic> _data;
  late String _alias;
  final _controllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(_alias) == true,
    );
    _moduleObj =
        existing ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: CamelMinigamePropertiesData().toJson(),
        );
    if (existing == null) widget.levelFile.objects.add(_moduleObj);
    _data = {
      ...CamelMinigamePropertiesData().toJson(),
      if (_moduleObj.objData is Map)
        ...Map<String, dynamic>.from(_moduleObj.objData as Map),
    };
    for (final entry in _data.entries) {
      if (entry.value is num) {
        _controllers[entry.key] = TextEditingController(text: '${entry.value}');
      }
    }
  }

  void _set(String field, dynamic value) {
    setState(() {
      _data[field] = value;
      _moduleObj.objData = Map<String, dynamic>.from(_data);
    });
    widget.onChanged();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (rows, columns) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: l10n.moduleTitle_CamelMinigameProperties,
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.moduleTitle_CamelMinigameProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpCamelOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.camelHelpSpawningTitle,
                  body: l10n.moduleHelpCamelSpawningBody,
                ),
                HelpSectionData(
                  title: l10n.camelHelpTutorialTitle,
                  body: l10n.moduleHelpCamelTutorialBody,
                ),
                HelpSectionData(
                  title: l10n.camelHelpTipsTitle,
                  body: l10n.moduleHelpCamelTipsBody,
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
            const SizedBox(height: 16),
            EditorWarningBanner(
              key: const ValueKey('camelCompatibilityWarning'),
              title: l10n.camelHelpTipsTitle,
              message: l10n.camelCompatibilityWarning,
            ),
            CamelMinigameConflicts(levelFile: widget.levelFile),
            const SizedBox(height: 12),
            _card(l10n.camelGenerationParameters, [
              _cardTypes(l10n),
              const SizedBox(height: 12),
              _number(
                'CamelSegmentRiseStagger',
                l10n.camelRiseStagger,
                decimal: true,
              ),
              _number('CardMatchTime', l10n.camelCardMatchTime, decimal: true),
              _number(
                'CardMatchingTime',
                l10n.camelCardMatchingTime,
                decimal: true,
              ),
              _number(
                'CardNoMatchTime',
                l10n.camelCardNoMatchTime,
                decimal: true,
              ),
              _number(
                'InitialTutorialZombieRiseDelay',
                l10n.camelTutorialRiseDelay,
                decimal: true,
              ),
            ]),
            const SizedBox(height: 12),
            _card(l10n.camelSpawnDistance, [
              _number('MaxSpawnX', l10n.camelMaxSpawnX, signed: true),
              _number('MinSpawnXStart', l10n.camelMinSpawnXStart, signed: true),
              _number('MinSpawnXEnd', l10n.camelMinSpawnXEnd, signed: true),
              _number(
                'AdditionalXBufferBetweenChains',
                l10n.camelAdditionalXBuffer,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.camelSpawnPreview,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.camelSpawnCoordinatesHint),
              const SizedBox(height: 12),
              CamelSpawnDistancePreview(
                rows: rows,
                columns: columns,
                maxSpawnX: (_data['MaxSpawnX'] as num).toDouble(),
                minSpawnXStart: (_data['MinSpawnXStart'] as num).toDouble(),
                minSpawnXEnd: (_data['MinSpawnXEnd'] as num).toDouble(),
              ),
            ]),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                key: const ValueKey('camelShowTutorial'),
                title: Text(l10n.camelShowTutorial),
                value: _data['ShowTutorial'] == true,
                onChanged: (value) => _set('ShowTutorial', value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );

  Widget _cardTypes(AppLocalizations l10n) {
    final used = (_data['CardTypesUsed'] as num).toInt();
    return Container(
      key: const ValueKey('camelCardTypesControl'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorResponsiveStepperRow(
            label: l10n.camelCardTypesUsed,
            value: used,
            min: 1,
            max: 7,
            decreaseKey: const ValueKey('camelCardTypesDecrease'),
            increaseKey: const ValueKey('camelCardTypesIncrease'),
            onChanged: (value) => _set('CardTypesUsed', value.clamp(1, 7)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 1; i <= 7; i++)
                Opacity(
                  opacity: i <= used ? 1 : 0.25,
                  child: Image.asset(
                    'assets/images/others/camelminigame_$i.webp',
                    key: ValueKey('camelCardTypeIcon$i'),
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _number(
    String field,
    String label, {
    bool decimal = false,
    bool signed = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        key: ValueKey('camel$field'),
        controller: _controllers[field],
        keyboardType: TextInputType.numberWithOptions(
          decimal: decimal,
          signed: signed,
        ),
        decoration: decoration,
        onChanged: (text) {
          final value = decimal ? double.tryParse(text) : int.tryParse(text);
          if (value != null && value.isFinite && (signed || value >= 0)) {
            _set(field, value);
          }
        },
      ),
    ),
  );
}
