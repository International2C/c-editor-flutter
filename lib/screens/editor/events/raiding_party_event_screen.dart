import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Raiding party event editor. Ported from Z-Editor-master RaidingPartyEventEP.kt
class RaidingPartyEventScreen extends StatefulWidget {
  const RaidingPartyEventScreen({
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
  State<RaidingPartyEventScreen> createState() =>
      _RaidingPartyEventScreenState();
}

class _RaidingPartyEventScreenState extends State<RaidingPartyEventScreen> {
  static const _objClass = 'RaidingPartyZombieSpawnerProps';

  late PvzObject _moduleObj;
  late RaidingPartyEventData _data;
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
        objData: RaidingPartyEventData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = RaidingPartyEventData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = RaidingPartyEventData();
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
              title: l10n?.eventRaidingParty ?? 'Raiding party event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpRaidingPartyBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.groupSize ?? 'Group size',
                  body: l10n?.eventHelpRaidingPartyGroup ?? '',
                ),
                HelpSectionData(
                  title: l10n?.swashbucklerCount ?? 'Swashbuckler count',
                  body: l10n?.eventHelpRaidingPartyCount ?? '',
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
                        l10n?.spawnParameters ?? 'Spawn parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildIntField(
                        theme,
                        l10n?.groupSize ?? 'Group size (GroupSize)',
                        _data.groupSize,
                        (v) {
                          _data = RaidingPartyEventData(
                            groupSize: v,
                            swashbucklerCount: _data.swashbucklerCount,
                            timeBetweenGroups: _data.timeBetweenGroups,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildIntField(
                        theme,
                        l10n?.swashbucklerCount ??
                            'Total zombies (SwashbucklerCount)',
                        _data.swashbucklerCount,
                        (v) {
                          _data = RaidingPartyEventData(
                            groupSize: _data.groupSize,
                            swashbucklerCount: v,
                            timeBetweenGroups: _data.timeBetweenGroups,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildIntField(
                        theme,
                        l10n?.timeBetweenGroups ??
                            'Time between groups (TimeBetweenGroups)',
                        _data.timeBetweenGroups,
                        (v) {
                          _data = RaidingPartyEventData(
                            groupSize: _data.groupSize,
                            swashbucklerCount: _data.swashbucklerCount,
                            timeBetweenGroups: v,
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

  Widget _buildIntField(
    ThemeData theme,
    String label,
    int value,
    void Function(int) onChanged,
  ) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null) onChanged(n);
        },
      ),
    );
  }
}
