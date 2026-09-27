import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/module_instance_display_name.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';

bool _isExpeditionTilesModule({
  required String alias,
  required String objClass,
  required dynamic objData,
}) {
  return isExpeditionTilesModule(
    alias: alias,
    objClass: objClass,
    objData: objData,
  );
}

class ModuleUIInfo {
  final String rtid;
  final String alias;
  final String objClass;
  final String friendlyName;
  final String description;
  final IconData icon;
  final String? assetIconPath;
  final bool isCore;
  final bool isExpeditionTiles;
  final bool canEdit;

  const ModuleUIInfo({
    required this.rtid,
    required this.alias,
    required this.objClass,
    required this.friendlyName,
    required this.description,
    required this.icon,
    this.assetIconPath,
    required this.isCore,
    this.isExpeditionTiles = false,
    required this.canEdit,
  });

  ModuleUIInfo copyWith({String? friendlyName}) => ModuleUIInfo(
    rtid: rtid,
    alias: alias,
    objClass: objClass,
    friendlyName: friendlyName ?? this.friendlyName,
    description: description,
    icon: icon,
    assetIconPath: assetIconPath,
    isCore: isCore,
    isExpeditionTiles: isExpeditionTiles,
    canEdit: canEdit,
  );
}

class LevelSettingsTab extends StatefulWidget {
  const LevelSettingsTab({
    super.key,
    required this.levelDef,
    required this.objectMap,
    this.issues,
    required this.onEditBasicInfo,
    required this.onEditModule,
    required this.onRemoveModule,
    required this.onReorderModules,
    required this.onNavigateToAddModule,
  });

  final LevelDefinitionData? levelDef;
  final Map<String, PvzObject> objectMap;

  /// Conflicts, missing modules, and advisories from [LevelIssueRegistry].
  /// When null, they are computed from [levelDef] + [objectMap].
  final List<LevelIssue>? issues;
  final VoidCallback onEditBasicInfo;
  final ValueChanged<String> onEditModule;
  final ValueChanged<String> onRemoveModule;
  final void Function({
    required bool isCoreSection,
    required int oldIndex,
    required int newIndex,
  })
  onReorderModules;
  final VoidCallback onNavigateToAddModule;

  @override
  State<LevelSettingsTab> createState() => _LevelSettingsTabState();
}

class _LevelSettingsTabState extends State<LevelSettingsTab> {
  static const _tabEditorModuleClasses = {
    'VaseBreakerPresetProperties',
    'VaseBreakerArcadeModuleProperties',
    'VaseBreakerFlowModuleProperties',
    'ZombossBattleModuleProperties',
    'ZombossBattleIntroProperties',
    'ZombossLastStandMinigameProperties',
  };

  String? pendingDeleteRtid;

  static bool _hasEditor(ModuleMetadata metadata, String objClass) {
    return (metadata.routeId != 'Unknown' &&
            metadata.routeId != 'UnknownDetail') ||
        _tabEditorModuleClasses.contains(objClass);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levelDef = widget.levelDef;

    if (levelDef == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noLevelDefinition ?? 'No level definition',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.noLevelDefinitionHint ??
                    'Level definition module is missing.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final unnumberedModules = levelDef.modules.map((rtid) {
      final info = RtidParser.parse(rtid);
      final alias = info?.alias ?? 'Unknown';
      String? objClass;

      if (info?.source == 'CurrentLevel') {
        objClass = widget.objectMap[alias]?.objClass;
      } else {
        objClass = ReferenceRepository.instance.getObjClass(alias);
      }
      objClass ??= 'UnknownObject';

      final metadata = ModuleRegistry.getMetadataForAlias(alias, objClass);
      final rawObjData = info?.source == 'CurrentLevel'
          ? widget.objectMap[alias]?.objData
          : ReferenceRepository.instance.objectForAlias(alias)?.objData;
      final isExpeditionTiles = _isExpeditionTilesModule(
        alias: alias,
        objClass: objClass,
        objData: rawObjData,
      );

      return ModuleUIInfo(
        rtid: rtid,
        alias: alias,
        objClass: objClass,
        friendlyName: metadata.getTitle(context),
        description: metadata.getDescription(context),
        icon: metadata.icon,
        assetIconPath: metadata.assetIconPath,
        isCore: metadata.isCore,
        isExpeditionTiles: isExpeditionTiles,
        canEdit: _hasEditor(metadata, objClass),
      );
    }).toList();

    final instanceCounts = <String, int>{};
    for (final module in unnumberedModules) {
      if (repeatableBossModuleObjClasses.contains(module.objClass)) {
        instanceCounts.update(
          module.objClass,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final seenInstances = <String, int>{};
    final currentModulesList = unnumberedModules.map((module) {
      final instanceIndex = seenInstances[module.objClass] ?? 0;
      if (repeatableBossModuleObjClasses.contains(module.objClass)) {
        seenInstances[module.objClass] = instanceIndex + 1;
      }
      return module.copyWith(
        friendlyName: moduleInstanceDisplayName(
          baseName: module.friendlyName,
          objClass: module.objClass,
          instanceCount: instanceCounts[module.objClass] ?? 1,
          instanceIndex: instanceIndex,
        ),
      );
    }).toList();

    final coreModules = currentModulesList.where((m) => m.isCore).toList();
    final miscModules = currentModulesList.where((m) => !m.isCore).toList();

    final levelIssues =
        widget.issues ??
        LevelIssueRegistry.forLevel(
          context,
          _levelFileWithDefinition(),
          editorOnly: true,
        );

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingEntryCard(
              title: l10n?.levelBasicInfo ?? 'Level basic info',
              subtitle:
                  l10n?.levelBasicInfoSubtitle ??
                  'Name, number, description, stage',
              icon: Icons.edit_note,
              onClick: widget.onEditBasicInfo,
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.editableModules ?? 'Editable modules',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (coreModules.isNotEmpty)
              _ReorderableModuleList(
                modules: coreModules,
                isCore: true,
                removeTooltip: l10n?.removeModule ?? 'Remove module',
                reorderHint: _moduleReorderHint(context, l10n),
                onEditModule: widget.onEditModule,
                onDelete: (rtid) => setState(() => pendingDeleteRtid = rtid),
                onReorder: (oldIndex, newIndex) => widget.onReorderModules(
                  isCoreSection: true,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                ),
              ),
            const SizedBox(height: 20),
            if (miscModules.isNotEmpty) ...[
              Text(
                l10n?.parameterModules ?? 'Parameter modules',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _ReorderableModuleList(
                modules: miscModules,
                isCore: false,
                removeTooltip: l10n?.removeModule ?? 'Remove module',
                reorderHint: _moduleReorderHint(context, l10n),
                onEditModule: widget.onEditModule,
                onDelete: (rtid) => setState(() => pendingDeleteRtid = rtid),
                onReorder: (oldIndex, newIndex) => widget.onReorderModules(
                  isCoreSection: false,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Add Module Button
            InkWell(
              onTap: widget.onNavigateToAddModule,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n?.addNewModule ?? 'Add new module',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conflicts, missing modules, and advisories
            for (final issue in levelIssues) ...[
              const SizedBox(height: 12),
              if (issue.isError)
                _ErrorBanner(
                  key: ValueKey(issue.id),
                  title: issue.title,
                  message: issue.message,
                )
              else
                EditorWarningBanner(
                  key: ValueKey(issue.id),
                  title: issue.title,
                  message: issue.message,
                  children: [
                    for (final bullet in issue.bulletPoints)
                      Text(
                        '• $bullet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: editorWarningBannerForeground(
                            Theme.of(context).brightness,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ],
        ),
        if (pendingDeleteRtid != null)
          AlertDialog(
            title: Text(l10n?.removeModule ?? 'Remove module'),
            content: Text(
              l10n?.removeModuleConfirm ??
                  'Remove this module? Local custom modules (@CurrentLevel) and their data will be deleted permanently.',
            ),
            actions: [
              TextButton(
                onPressed: () => setState(() => pendingDeleteRtid = null),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.onRemoveModule(pendingDeleteRtid!);
                  setState(() => pendingDeleteRtid = null);
                },
                child: Text(
                  l10n?.confirmRemove ?? 'Remove',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
      ],
    );
  }

  PvzLevelFile _levelFileWithDefinition() {
    final objects = <PvzObject>[
      ...widget.objectMap.values,
    ];
    if (widget.levelDef != null &&
        !objects.any((o) => o.objClass == 'LevelDefinition')) {
      objects.insert(
        0,
        PvzObject(
          aliases: const ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: widget.levelDef!.toJson(),
        ),
      );
    }
    return PvzLevelFile(objects: objects);
  }

  static String _moduleReorderHint(
    BuildContext context,
    AppLocalizations? l10n,
  ) {
    final desktop =
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;
    return desktop
        ? (l10n?.presetPlantListReorderHintDesktop ??
              'Drag the ⋮⋮ handle to reorder.')
        : (l10n?.presetPlantListReorderHint ??
              'Long press the ⋮⋮ handle and drag to reorder.');
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(editorErrorIcon, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
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

class _ReorderableModuleList extends StatelessWidget {
  const _ReorderableModuleList({
    required this.modules,
    required this.isCore,
    required this.removeTooltip,
    required this.reorderHint,
    required this.onEditModule,
    required this.onDelete,
    required this.onReorder,
  });

  final List<ModuleUIInfo> modules;
  final bool isCore;
  final String removeTooltip;
  final String reorderHint;
  final ValueChanged<String> onEditModule;
  final ValueChanged<String> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reorderHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: modules.length,
          onReorderItem: onReorder,
          itemBuilder: (context, index) {
            final item = modules[index];
            return _ReorderableModuleTile(
              key: ValueKey(item.rtid),
              info: item,
              isCore: isCore,
              reorderIndex: index,
              removeTooltip: removeTooltip,
              onClick: item.canEdit ? () => onEditModule(item.rtid) : null,
              onDelete: () => onDelete(item.rtid),
            );
          },
        ),
      ],
    );
  }
}

class _ReorderableModuleTile extends StatelessWidget {
  const _ReorderableModuleTile({
    super.key,
    required this.info,
    required this.isCore,
    required this.reorderIndex,
    required this.removeTooltip,
    this.onClick,
    required this.onDelete,
  });

  final ModuleUIInfo info;
  final bool isCore;
  final int reorderIndex;
  final String removeTooltip;
  final VoidCallback? onClick;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handleColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.85,
    );
    final iconColor = isCore ? theme.colorScheme.primary : Colors.grey;
    final titleStyle = isCore
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : const TextStyle(color: Colors.grey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: reorderIndex,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(Icons.drag_indicator, color: handleColor),
                  ),
                ),
              ),
              if (info.assetIconPath != null)
                SizedBox(
                  width: isCore ? 28 : 20,
                  height: isCore ? 28 : 20,
                  child: AssetImageWidget(
                    assetPath: info.assetIconPath!,
                    fit: BoxFit.contain,
                    altCandidates: imageAltCandidates(info.assetIconPath!),
                  ),
                )
              else
                Icon(info.icon, color: iconColor, size: isCore ? 28 : 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCore
                          ? info.friendlyName
                          : '${info.friendlyName} (${info.alias})',
                      style: titleStyle,
                    ),
                    if (isCore) ...[
                      Tooltip(
                        message: info.description,
                        child: Text(
                          info.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(info.alias, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: isCore ? 24 : 16,
                  color: iconColor,
                ),
                tooltip: removeTooltip,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClick;

  const _SettingEntryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
