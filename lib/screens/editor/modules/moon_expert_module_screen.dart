import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart'
    show pvzLightOrangeDark, pvzLightOrangeLight;
import 'package:c_editor/widgets/editor_components.dart'
    show showEditorHelpDialog, HelpSectionData, editorInputDecoration;
import 'package:c_editor/widgets/editor_object_alias.dart';

class MoonExpertModuleScreen extends StatefulWidget {
  const MoonExpertModuleScreen({
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
  State<MoonExpertModuleScreen> createState() => _MoonExpertModuleScreenState();
}

class _MoonExpertModuleScreenState extends State<MoonExpertModuleScreen> {
  static const _objClass = 'MoonExpertProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late MoonExpertPropertiesData _data;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: MoonExpertPropertiesData().toJson(),
      ),
    );
    try {
      _data = MoonExpertPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = MoonExpertPropertiesData();
    }
  }

  void _save() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzLightOrangeDark : pvzLightOrangeLight;
    final zombieLevelTooltip =
        l10n?.moonExpertZombieLevelTooltip ??
        'Overwrites all zombie levels defined in the level to ZombieLevel, and sets all plants to level 1 regardless of plant levels configured in other modules.';
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
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                isEvent: false,
                title: l10n?.moonExpertHelpTitle ?? 'Moon Expert Mode',
                themeColor: accentColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.moonExpertHelpOverview ??
                        'Forces a single zombie level for the whole level and resets all plants to level 1.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            Tooltip(
              message: zombieLevelTooltip,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n?.moonExpertZombieLevel ??
                              'Zombie level (ZombieLevel)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('moonExpertZombieLevel'),
                    initialValue:
                        _data.zombieLevel >= 0 && _data.zombieLevel <= 10
                        ? _data.zombieLevel
                        : null,
                    isExpanded: true,
                    decoration: editorInputDecoration(
                      context,
                      focusColor: accentColor,
                    ),
                    items: [
                      for (var level = 0; level <= 10; level++)
                        DropdownMenuItem(value: level, child: Text('$level')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _data.zombieLevel = value;
                        _save();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
