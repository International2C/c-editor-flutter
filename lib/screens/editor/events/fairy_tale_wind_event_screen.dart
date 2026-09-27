import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Fairy tale wind event editor. Ported from Z-Editor-master FairyTaleWindWaveActionPropsEP.kt
class FairyTaleWindEventScreen extends StatefulWidget {
  const FairyTaleWindEventScreen({
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
  State<FairyTaleWindEventScreen> createState() =>
      _FairyTaleWindEventScreenState();
}

class _FairyTaleWindEventScreenState extends State<FairyTaleWindEventScreen> {
  static const _objClass = 'FairyTaleWindWaveActionProps';

  late PvzObject _moduleObj;
  late FairyTaleWindWaveActionData _data;
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
        objData: FairyTaleWindWaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = FairyTaleWindWaveActionData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = FairyTaleWindWaveActionData();
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
              title: l10n?.eventFairyWind ?? 'Fairy wind event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpFairyWindBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.velocityScale ?? 'Velocity scale',
                  body: l10n?.eventHelpFairyWindVelocity ?? '',
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
                        l10n?.fairyWindParameters ?? 'Wind parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      EditorResponsiveInputField(
                        label:
                            l10n?.fairyWindDuration ??
                            'Duration (Duration; seconds)',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.duration.toString(),
                          decoration: decoration,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) {
                            final n = double.tryParse(v);
                            if (n != null) {
                              _data = FairyTaleWindWaveActionData(
                                duration: n,
                                velocityScale: _data.velocityScale,
                              );
                              _sync();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label:
                            l10n?.velocityScale ??
                            'Speed multiplier (VelocityScale)',
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.velocityScale.toString(),
                          decoration: decoration,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) {
                            final n = double.tryParse(v);
                            if (n != null) {
                              _data = FairyTaleWindWaveActionData(
                                duration: _data.duration,
                                velocityScale: n,
                              );
                              _sync();
                            }
                          },
                        ),
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
