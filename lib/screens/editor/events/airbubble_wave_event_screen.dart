import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Bubble rain wave event editor (ZombieAirbubbleActionProps).
class AirbubbleWaveEventScreen extends StatefulWidget {
  const AirbubbleWaveEventScreen({
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
  State<AirbubbleWaveEventScreen> createState() =>
      _AirbubbleWaveEventScreenState();
}

class _AirbubbleWaveEventScreenState extends State<AirbubbleWaveEventScreen> {
  static const _objClass = 'ZombieAirbubbleActionProps';

  late PvzObject _moduleObj;
  late ZombieAirbubbleActionPropsData _data;
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
        objData: ZombieAirbubbleActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ZombieAirbubbleActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ZombieAirbubbleActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
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

  Widget _intField({
    required String label,
    required int value,
    required ValueChanged<int> onParsed,
    String? hintText,
    String? helperText,
  }) {
    return EditorResponsiveInputField(
      label: label,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        helperText: helperText,
      ),
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null && n >= 0) {
            onParsed(n);
          }
        },
      ),
    );
  }

  Widget _doubleField({
    required String label,
    required double value,
    required ValueChanged<double> onParsed,
    String? hintText,
    String? helperText,
  }) {
    return EditorResponsiveInputField(
      label: label,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        helperText: helperText,
      ),
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) {
          final n = double.tryParse(v);
          if (n != null && n >= 0) {
            onParsed(n);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

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
              title: l10n?.eventAirbubble ?? 'Event: Bubble Rain',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpAirbubbleWaveBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.eventHelpAirbubbleWaveFieldsTitle ??
                      'Parameter Description',
                  body: l10n?.eventHelpAirbubbleWaveFields ?? '',
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.airbubbleParameters ?? 'Bubble rain parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _intField(
                        label:
                            l10n?.airbubbleBubbleNumber ??
                            'Bubble count (BubbleNumber)',
                        value: _data.bubbleNumber,
                        onParsed: (n) {
                          _data = ZombieAirbubbleActionPropsData(
                            bubbleNumber: n,
                            bubbleHealth: _data.bubbleHealth,
                            speedRangeMin: _data.speedRangeMin,
                            speedRangeMax: _data.speedRangeMax,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _intField(
                        label:
                            l10n?.airbubbleBubbleHealth ??
                            'Bubble health (BubbleHealth)',
                        value: _data.bubbleHealth,
                        onParsed: (n) {
                          _data = ZombieAirbubbleActionPropsData(
                            bubbleNumber: _data.bubbleNumber,
                            bubbleHealth: n,
                            speedRangeMin: _data.speedRangeMin,
                            speedRangeMax: _data.speedRangeMax,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _doubleField(
                        label:
                            l10n?.airbubbleSpeedRangeMin ??
                            'Min fall speed (SpeedRangeMin)',
                        value: _data.speedRangeMin,
                        onParsed: (n) {
                          _data = ZombieAirbubbleActionPropsData(
                            bubbleNumber: _data.bubbleNumber,
                            bubbleHealth: _data.bubbleHealth,
                            speedRangeMin: n,
                            speedRangeMax: _data.speedRangeMax,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _doubleField(
                        label:
                            l10n?.airbubbleSpeedRangeMax ??
                            'Max fall speed (SpeedRangeMax)',
                        value: _data.speedRangeMax,
                        onParsed: (n) {
                          _data = ZombieAirbubbleActionPropsData(
                            bubbleNumber: _data.bubbleNumber,
                            bubbleHealth: _data.bubbleHealth,
                            speedRangeMin: _data.speedRangeMin,
                            speedRangeMax: n,
                          );
                          _sync();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
