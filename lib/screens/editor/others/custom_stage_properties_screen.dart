import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/models/stage_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/screens/select/music_suffix_selection_screen.dart';
import 'package:c_editor/screens/select/stage_background_selection_screen.dart';
import 'package:c_editor/screens/select/stage_resource_group_import_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/stage_resource_group_list_tile.dart';
import 'package:c_editor/widgets/stage_zombie_type_picker_row.dart';

enum _DisabledStreetCellsMode { empty, defaultCells }

/// Edits a level-local custom stage property sheet (`@CurrentLevel`).
class CustomStagePropertiesScreen extends StatefulWidget {
  const CustomStagePropertiesScreen({
    super.key,
    required this.alias,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String alias;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<CustomStagePropertiesScreen> createState() =>
      _CustomStagePropertiesScreenState();
}

class _CustomStagePropertiesScreenState
    extends State<CustomStagePropertiesScreen> {
  PvzObject? _stageObj;
  late String _alias;
  late String _objclass;
  late Map<String, dynamic> _objdata;
  StageBaseOption? _stageBaseOption;
  late TextEditingController _aliasCtrl;
  late TextEditingController _linkedAlphaCtrl;
  late TextEditingController _cosmicPlantfoodFillSecondsCtrl;
  late TextEditingController _submarineHpCtrl;
  final Map<String, TextEditingController> _skycityCtrls = {};

  @override
  void initState() {
    super.initState();
    _alias = widget.alias;
    _aliasCtrl = TextEditingController(text: _alias);
    _linkedAlphaCtrl = TextEditingController();
    _cosmicPlantfoodFillSecondsCtrl = TextEditingController();
    _submarineHpCtrl = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _linkedAlphaCtrl.dispose();
    _cosmicPlantfoodFillSecondsCtrl.dispose();
    _submarineHpCtrl.dispose();
    for (final ctrl in _skycityCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _loadData() {
    _stageObj = CustomStageLevelUtils.findStageObject(widget.levelFile, _alias);
    if (_stageObj == null) {
      setState(() {});
      return;
    }
    _objclass = _stageObj!.objClass;
    _objdata = Map<String, dynamic>.from(_stageObj!.objData as Map);
    _stageBaseOption = StageCatalogRepository.stageBaseOptionForObjdata(
      objclass: _objclass,
      objdata: _objdata,
    );
    _linkedAlphaCtrl.text = '${_objdata['LinkedTilePropagationAlpha'] ?? ''}';
    _cosmicPlantfoodFillSecondsCtrl.text =
        '${_objdata['CosmicPlantfoodFillSeconds'] ?? 50.0}';
    _submarineHpCtrl.text =
        '${CustomStageLevelUtils.readSubmarineHitpoints(_objdata)}';
    for (final key in CustomStageLevelUtils.skycityCannonFieldNames) {
      _skycityCtrls[key] = TextEditingController(
        text:
            '${_objdata[key] ?? CustomStageLevelUtils.skycityCannonDefaults[key] ?? ''}',
      );
    }
    setState(() {});
  }

  StageCatalogSection? get _section =>
      StageCatalogRepository.sectionForObjclass(_objclass);

  Map<String, dynamic> get _template =>
      _stageBaseOption?.objdata ??
      StageCatalogRepository.templateObjdataForStageObject(
        objclass: _objclass,
        objdata: _objdata,
      );

  List<String> get _resourceGroups =>
      CustomStageLevelUtils.stringList(_objdata['ResourceGroupNames']);

  List<String> get _groupsToUnload =>
      CustomStageLevelUtils.stringList(_objdata['GroupsToUnloadForAds']);

  bool get _ambientEnabled => CustomStageLevelUtils.isAmbientEnabled(_objdata);

  _DisabledStreetCellsMode get _disabledCellsMode =>
      CustomStageLevelUtils.usesDefaultDisabledStreetCells(_objdata, _objclass)
      ? _DisabledStreetCellsMode.defaultCells
      : _DisabledStreetCellsMode.empty;

  bool get _missingKnownBackground =>
      !StageCatalogRepository.hasKnownDelayLoadBackground(
        _resourceGroups,
        _groupsToUnload,
      );

  bool get _hasAdvancedSettings =>
      _objclass == 'FutureStageProperties' ||
      CustomStageLevelUtils.supportsCosmicPlantfoodFill(_objclass) ||
      CustomStageLevelUtils.supportsBeachMinigame(_objdata) ||
      CustomStageLevelUtils.supportsSubmarine(_objclass) ||
      CustomStageLevelUtils.supportsSkyCityAirship(_objclass);

  Color get _accentColor => customStageAccent(context);

  String _fieldLabel(BuildContext context, String fieldName) {
    final key = 'stageField_$fieldName';
    final localized = ResourceNames.lookup(context, key);
    return localized == key ? fieldName : localized;
  }

  void _sync({bool renameAlias = false}) {
    if (_stageObj == null) return;
    CustomStageLevelUtils.syncHiddenFieldsFromTemplate(
      objdata: _objdata,
      objclass: _objclass,
      template: _template,
    );
    _stageObj!.objClass = _objclass;
    _stageObj!.objData = _objdata;
    if (renameAlias) {
      _stageObj!.aliases =
          CustomStagePresetRepository.preservePresetMarkerAliases(
            primaryAlias: _alias,
            existingAliases: _stageObj!.aliases,
          );
      final levelDefObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.objClass == 'LevelDefinition',
      );
      if (levelDefObj?.objData is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(levelDefObj!.objData as Map);
        final stageModule = data['StageModule'] as String?;
        if (stageModule != null) {
          final info = RtidParser.parse(stageModule);
          if (info?.source == CustomStageLevelUtils.currentLevel &&
              info?.alias == widget.alias) {
            data['StageModule'] = RtidParser.build(
              _alias,
              CustomStageLevelUtils.currentLevel,
            );
            levelDefObj.objData = data;
          }
        }
      }
    }
    _syncDeepSeaBoardTypeIfActive();
    _stageBaseOption = StageCatalogRepository.stageBaseOptionForObjdata(
      objclass: _objclass,
      objdata: _objdata,
    );
    widget.onChanged();
    setState(() {});
  }

  void _syncDeepSeaBoardTypeIfActive() {
    final levelDefObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelDefinition',
    );
    if (levelDefObj?.objData is! Map) return;
    final levelDef = LevelDefinitionData.fromJson(
      Map<String, dynamic>.from(levelDefObj!.objData as Map),
    );
    final info = RtidParser.parse(levelDef.stageModule);
    if (info?.source != CustomStageLevelUtils.currentLevel) return;
    if (info?.alias != _alias && info?.alias != widget.alias) return;
    LevelParser.syncDeepSeaBoardType(levelDef, widget.levelFile);
  }

  void _setResourceGroups(List<String> values) {
    CustomStageLevelUtils.setStringList(_objdata, 'ResourceGroupNames', values);
    _sync();
  }

  void _setGroupsToUnload(List<String> values) {
    CustomStageLevelUtils.setStringList(
      _objdata,
      'GroupsToUnloadForAds',
      values,
    );
    _sync();
  }

  Future<bool> _importResourceGroup({
    required StageResourceGroupImportMode mode,
    required bool targetUnloadList,
    BuildContext? navigatorContext,
  }) async {
    final existing = targetUnloadList
        ? _groupsToUnload.toSet()
        : _resourceGroups.toSet();
    final nav = navigatorContext ?? context;
    var imported = false;
    await Navigator.push<void>(
      nav,
      MaterialPageRoute(
        builder: (ctx) => StageResourceGroupImportScreen(
          mode: mode,
          stateBucketId:
              'level:${identityHashCode(widget.levelFile)}:stage-resource',
          existingGroups: existing,
          onImport:
              ({
                required groups,
                sourceStageAlias,
                sourceStageObjdata,
                applySourceLawnAppearance = false,
              }) {
                Map<String, dynamic>? sourceObjdata = sourceStageObjdata;
                if (sourceObjdata == null && sourceStageAlias != null) {
                  sourceObjdata = StageCatalogRepository.catalogImplementation(
                    sourceStageAlias,
                  )?.objdata;
                }
                if (targetUnloadList) {
                  final toUnload =
                      mode == StageResourceGroupImportMode.fromStage &&
                          sourceObjdata != null
                      ? CustomStageLevelUtils.sourceUnloadGroupsForObjdata(
                          sourceObjdata: sourceObjdata,
                          importedGroups: groups,
                        )
                      : groups;
                  _setGroupsToUnload([..._groupsToUnload, ...toUnload]);
                } else {
                  final appearanceSnapshot =
                      CustomStageLevelUtils.snapshotLawnAppearance(_objdata);
                  CustomStageLevelUtils.setStringList(
                    _objdata,
                    'ResourceGroupNames',
                    [..._resourceGroups, ...groups],
                  );
                  if (mode == StageResourceGroupImportMode.fromStage &&
                      sourceObjdata != null) {
                    CustomStageLevelUtils.syncUnloadGroupsFromSourceObjdata(
                      objdata: _objdata,
                      sourceObjdata: sourceObjdata,
                      importedGroups: groups,
                    );
                    if (applySourceLawnAppearance) {
                      CustomStageLevelUtils.applyLawnAppearanceFromSource(
                        _objdata,
                        sourceObjdata,
                      );
                    } else {
                      CustomStageLevelUtils.restoreLawnAppearance(
                        _objdata,
                        appearanceSnapshot,
                      );
                    }
                  } else {
                    CustomStageLevelUtils.restoreLawnAppearance(
                      _objdata,
                      appearanceSnapshot,
                    );
                  }
                  _sync();
                }
                imported = true;
                Navigator.pop(ctx);
              },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
    return imported;
  }

  Future<void> _pickBackground() async {
    final current = _objdata['BackgroundImagePrefix'] as String? ?? '';
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => StageBackgroundSelectionScreen(
          stateBucketId:
              'level:${identityHashCode(widget.levelFile)}:stage-background',
          optionsBuilder: () {
            final delayLoads = StageCatalogRepository.delayLoadGroupsInLists(
              _resourceGroups,
              _groupsToUnload,
            );
            return StageCatalogRepository.backgroundOptionsForDelayLoads(
              delayLoads,
            );
          },
          currentImagePrefix: current,
          onImportFromStage: () async {
            final imported = await _importResourceGroup(
              navigatorContext: ctx,
              mode: StageResourceGroupImportMode.fromStage,
              targetUnloadList: false,
            );
            if (imported && ctx.mounted) {
              Navigator.pop(ctx);
            }
            return imported;
          },
          onSelected: (option) {
            _objdata['BackgroundImagePrefix'] = option.imagePrefix;
            _objdata['BackgroundResourceGroup'] = option.delayLoadGroup;
            _sync();
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  Future<void> _pickMusicSuffix() async {
    final current = _objdata['MusicSuffix'] as String? ?? '';
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => MusicSuffixSelectionScreen(
          stateBucketId:
              'level:${identityHashCode(widget.levelFile)}:music-suffix',
          currentCodename: current,
          onCodenameSelected: (code) {
            _objdata['MusicSuffix'] = code;
            _sync();
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: _accentColor,
        ),
      ),
    );
  }

  Widget _ellipsisText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }

  Widget _warningCard(String message) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resourceGroupSection({
    required String title,
    required List<String> groups,
    required ValueChanged<List<String>> onChanged,
    required bool targetUnloadList,
  }) {
    final l10n = AppLocalizations.of(context);
    final listHeight = groups.isEmpty
        ? kStageResourceGroupRowHeight
        : groups.length * (kStageResourceGroupRowHeight + 8);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _ellipsisText(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                PopupMenuButton<StageResourceGroupImportMode>(
                  tooltip: l10n?.importResourceGroup ?? 'Import',
                  onSelected: (mode) => _importResourceGroup(
                    mode: mode,
                    targetUnloadList: targetUnloadList,
                  ),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: StageResourceGroupImportMode.fromStage,
                      child: Text(
                        l10n?.importResourceGroupFromStage ?? 'From stage',
                      ),
                    ),
                    PopupMenuItem(
                      value: StageResourceGroupImportMode.global,
                      child: Text(
                        l10n?.importResourceGroupGlobal ?? 'From global list',
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n?.customStageNoResourceGroups ??
                      'No resource groups in list',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              SizedBox(
                height: listHeight,
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: groups.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final next = List<String>.from(groups);
                    final item = next.removeAt(oldIndex);
                    next.insert(newIndex, item);
                    onChanged(next);
                  },
                  itemBuilder: (_, index) {
                    final group = groups[index];
                    return StageResourceGroupListTile(
                      key: ValueKey('$title-$group'),
                      group: group,
                      reorderIndex: index,
                      onRemove: () {
                        final next = List<String>.from(groups)..removeAt(index);
                        onChanged(next);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pickerTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    String? iconFileName,
    String? iconAssetPath,
  }) {
    final iconPath =
        iconAssetPath ??
        (iconFileName != null
            ? 'assets/images/round_icons/$iconFileName'
            : null);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (iconPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: AssetImageWidget(
                      assetPath: iconPath,
                      altCandidates: imageAltCandidates(iconPath),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                const SizedBox(width: 96, height: 96),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ellipsisText(
                      label,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    _ellipsisText(
                      value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lawnAppearanceSummaryCard({
    required String label,
    required String value,
    String? iconFileName,
  }) {
    final iconPath = iconFileName == null
        ? 'assets/images/others/unknown.webp'
        : 'assets/images/round_icons/$iconFileName';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 64,
                height: 64,
                child: AssetImageWidget(
                  assetPath: iconPath,
                  altCandidates: imageAltCandidates(iconPath),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ellipsisText(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _ellipsisText(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = _accentColor;

    if (_stageObj == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: _ellipsisText(
            l10n?.customStageProperties ?? 'Custom stage properties',
          ),
        ),
        body: Center(
          child: Text(
            l10n?.customStageNotFound ?? 'Custom stage object not found.',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }

    final backgroundNameKey =
        CustomStageLevelUtils.displayLawnAppearanceNameKey(
          objclass: _objclass,
          objdata: _objdata,
        );
    final backgroundName = backgroundNameKey.isEmpty
        ? (_objdata['BackgroundImagePrefix'] as String? ?? '—')
        : ResourceNames.lookup(context, backgroundNameKey);
    final baseStageNameKey = _stageBaseOption == null
        ? ''
        : 'stage_${_stageBaseOption!.alias}';
    final baseStageName = baseStageNameKey.isEmpty
        ? (_stageBaseOption?.alias ?? _objclass)
        : ResourceNames.lookup(context, baseStageNameKey);
    final baseStageIcon = _stageBaseOption?.iconName;
    final musicSuffix = _objdata['MusicSuffix'] as String? ?? '';
    final musicName = ResourceNames.lookup(
      context,
      musicSuffix.isEmpty ? 'musicSuffix_default' : 'musicSuffix_$musicSuffix',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: _ellipsisText(
          l10n?.customStageProperties ?? 'Custom stage properties',
        ),
        backgroundColor: accent,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Theme(
        data: customStageInputTheme(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle(l10n?.customStageSectionGeneral ?? 'General'),
              _lawnAppearanceSummaryCard(
                label: l10n?.customStageBaseStage ?? 'Base stage',
                value: baseStageName,
                iconFileName: baseStageIcon,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: EditorResponsiveInputField(
                    label: l10n?.customStageAlias ?? 'Stage alias',
                    decoration: customStageInputDecoration(context),
                    builder: (context, decoration) => TextField(
                      controller: _aliasCtrl,
                      decoration: decoration,
                      onChanged: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isEmpty ||
                            widget.levelFile.objects.any(
                              (o) =>
                                  o != _stageObj &&
                                  o.aliases?.contains(trimmed) == true,
                            )) {
                          return;
                        }
                        _alias = trimmed;
                        _sync(renameAlias: true);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle(
                l10n?.customStageSectionMusicAndOther ??
                    'Lawn appearance, Music & Other',
              ),
              _pickerTile(
                label: l10n?.customStageLawnAppearance ?? 'Lawn appearance',
                value: backgroundName,
                iconFileName:
                    CustomStageLevelUtils.displayLawnAppearanceIconFileName(
                      objclass: _objclass,
                      objdata: _objdata,
                    ),
                onTap: _pickBackground,
              ),
              const SizedBox(height: 8),
              _pickerTile(
                label: _fieldLabel(context, 'MusicSuffix'),
                value: musicName,
                iconAssetPath: MusicSuffixCatalog.iconAsset(musicSuffix),
                onTap: _pickMusicSuffix,
              ),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile(
                  title: Text(
                    l10n?.customStageEnableAmbient ?? 'Enable ambient',
                  ),
                  value: _ambientEnabled,
                  activeThumbColor: accent,
                  onChanged: (enabled) {
                    CustomStageLevelUtils.applyAmbientEnabled(
                      _objdata,
                      enabled: enabled,
                    );
                    _sync();
                  },
                ),
              ),
              if (_ambientEnabled) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: EditorResponsiveInputField(
                      label: _fieldLabel(context, 'AmbientAudioSuffix'),
                      decoration: customStageInputDecoration(context),
                      builder: (context, decoration) {
                        final label = _fieldLabel(
                          context,
                          'AmbientAudioSuffix',
                        );
                        final value =
                            CustomStageLevelUtils.ambientAudioOptions.contains(
                              _objdata['AmbientAudioSuffix'],
                            )
                            ? _objdata['AmbientAudioSuffix'] as String
                            : CustomStageLevelUtils.ambientAudioOptions.first;
                        return SeparatedOptionPickerField<String>(
                          labelText: label,
                          value: value,
                          decoration: decoration,
                          items: [
                            for (final code
                                in CustomStageLevelUtils.ambientAudioOptions)
                              SeparatedOptionPickerItem(
                                value: code,
                                label: ResourceNames.lookup(
                                  context,
                                  'ambientAudio_$code',
                                ),
                                subtitle: code.isEmpty ? null : code,
                              ),
                          ],
                          onChanged: (value) {
                            _objdata['AmbientAudioSuffix'] = value;
                            _sync();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: EditorResponsiveInputField(
                    label: _fieldLabel(context, 'DisabledStreetCells'),
                    decoration: customStageInputDecoration(context),
                    builder: (context, decoration) =>
                        DropdownButtonFormField<_DisabledStreetCellsMode>(
                          isExpanded: true,
                          initialValue: _disabledCellsMode,
                          decoration: decoration,
                          items: [
                            DropdownMenuItem(
                              value: _DisabledStreetCellsMode.empty,
                              child: _ellipsisText(
                                l10n?.customStageDisabledCellsEmpty ?? 'Empty',
                              ),
                            ),
                            DropdownMenuItem(
                              value: _DisabledStreetCellsMode.defaultCells,
                              child: _ellipsisText(
                                l10n?.customStageDisabledCellsDefault ??
                                    'Default',
                              ),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode == null) return;
                            CustomStageLevelUtils.applyDisabledStreetCellsMode(
                              _objdata,
                              objclass: _objclass,
                              useDefault:
                                  mode == _DisabledStreetCellsMode.defaultCells,
                            );
                            _sync();
                          },
                        ),
                  ),
                ),
              ),
              if (_hasAdvancedSettings) ...[
                const SizedBox(height: 16),
                _sectionTitle(
                  l10n?.customStageSectionAdvanced ?? 'Advanced Settings',
                ),
                if (_objclass == 'FutureStageProperties')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: EditorResponsiveInputField(
                        label: _fieldLabel(
                          context,
                          'LinkedTilePropagationAlpha',
                        ),
                        decoration: customStageInputDecoration(context),
                        builder: (context, decoration) => TextField(
                          controller: _linkedAlphaCtrl,
                          decoration: decoration,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              _objdata['LinkedTilePropagationAlpha'] = parsed;
                              _sync();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                if (CustomStageLevelUtils.supportsCosmicPlantfoodFill(
                  _objclass,
                ))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: EditorResponsiveInputField(
                        label: _fieldLabel(
                          context,
                          'CosmicPlantfoodFillSeconds',
                        ),
                        decoration: customStageInputDecoration(context),
                        builder: (context, decoration) => TextField(
                          key: const ValueKey(
                            'cosmicPlantfoodFillSecondsField',
                          ),
                          controller: _cosmicPlantfoodFillSecondsCtrl,
                          decoration: decoration,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              _objdata['CosmicPlantfoodFillSeconds'] = parsed;
                              _sync();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                if (CustomStageLevelUtils.supportsBeachMinigame(_objdata)) ...[
                  if (_objclass == 'FutureStageProperties')
                    const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: Text(
                        l10n?.customStageBeachMinigame ??
                            'Use minigame version',
                      ),
                      value: CustomStageLevelUtils.isBeachMinigameEnabled(
                        _objdata,
                      ),
                      activeThumbColor: accent,
                      onChanged: (enabled) {
                        CustomStageLevelUtils.applyBeachMinigame(
                          _objdata,
                          enabled: enabled,
                        );
                        _sync();
                      },
                    ),
                  ),
                ],
                if (CustomStageLevelUtils.supportsSubmarine(_objclass)) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: Text(
                        l10n?.customStageEnableSubmarine ?? 'Enable submarine',
                      ),
                      value: CustomStageLevelUtils.isSubmarineEnabled(_objdata),
                      activeThumbColor: accent,
                      onChanged: (enabled) {
                        CustomStageLevelUtils.applySubmarineEnabled(
                          _objdata,
                          enabled: enabled,
                          hitpoints: double.tryParse(_submarineHpCtrl.text),
                        );
                        _sync();
                      },
                    ),
                  ),
                  if (CustomStageLevelUtils.isSubmarineEnabled(_objdata))
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: EditorResponsiveInputField(
                          label:
                              l10n?.customStageSubmarineHitpoints ??
                              'Submarine hitpoints',
                          decoration: customStageInputDecoration(context),
                          builder: (context, decoration) => TextField(
                            controller: _submarineHpCtrl,
                            decoration: decoration,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              final hp = double.tryParse(value);
                              if (hp == null) return;
                              CustomStageLevelUtils.applySubmarineEnabled(
                                _objdata,
                                enabled: true,
                                hitpoints: hp,
                              );
                              _sync();
                            },
                          ),
                        ),
                      ),
                    ),
                ],
                if (CustomStageLevelUtils.supportsSkyCityAirship(
                  _objclass,
                )) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: Text(_fieldLabel(context, 'HasGridItemAirShip')),
                      value: CustomStageLevelUtils.readBool(
                        _objdata,
                        'HasGridItemAirShip',
                      ),
                      activeThumbColor: accent,
                      onChanged: (enabled) {
                        CustomStageLevelUtils.applySkyCityAirship(
                          _objdata,
                          enabled: enabled,
                        );
                        _sync();
                      },
                    ),
                  ),
                  if (CustomStageLevelUtils.readBool(
                    _objdata,
                    'HasGridItemAirShip',
                  )) ...[
                    Card(
                      child: SwitchListTile(
                        title: Text(_fieldLabel(context, 'HasCannon')),
                        value: CustomStageLevelUtils.readBool(
                          _objdata,
                          'HasCannon',
                        ),
                        activeThumbColor: accent,
                        onChanged: (enabled) {
                          CustomStageLevelUtils.applySkyCityCannon(
                            _objdata,
                            enabled: enabled,
                          );
                          for (final key
                              in CustomStageLevelUtils
                                  .skycityCannonFieldNames) {
                            _skycityCtrls.putIfAbsent(
                              key,
                              () => TextEditingController(),
                            );
                            _skycityCtrls[key]!.text = '${_objdata[key] ?? ''}';
                          }
                          _sync();
                        },
                      ),
                    ),
                    if (CustomStageLevelUtils.readBool(_objdata, 'HasCannon'))
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              for (final key
                                  in CustomStageLevelUtils
                                      .skycityCannonFieldNames)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: EditorResponsiveInputField(
                                    label: _fieldLabel(context, key),
                                    decoration: customStageInputDecoration(
                                      context,
                                    ),
                                    builder: (context, decoration) => TextField(
                                      controller: _skycityCtrls.putIfAbsent(
                                        key,
                                        () => TextEditingController(
                                          text: '${_objdata[key] ?? ''}',
                                        ),
                                      ),
                                      decoration: decoration,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onChanged: (value) {
                                        final parsed = num.tryParse(value);
                                        if (parsed == null) return;
                                        _objdata[key] = parsed;
                                        _sync();
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ],
              const SizedBox(height: 16),
              _sectionTitle(l10n?.customStageSectionZombies ?? 'Zombie types'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      for (final field
                          in CustomStageLevelUtils.editableZombieFields(
                            _section,
                          ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: StageZombieTypePickerRow(
                            fieldLabel: _fieldLabel(context, field.name),
                            zombieId: _objdata[field.name] as String?,
                            onChanged: (id) {
                              _objdata[field.name] = id;
                              _sync();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle(
                l10n?.customStageSectionResourceGroups ?? 'Resource groups',
              ),
              if (_missingKnownBackground) ...[
                _warningCard(
                  l10n?.customStageMissingBackgroundWarning ??
                      'Import at least one DelayLoad_Background group listed in the stage helper, or the lawn may appear completely black.',
                ),
                const SizedBox(height: 8),
              ],
              _resourceGroupSection(
                title: _fieldLabel(context, 'ResourceGroupNames'),
                groups: _resourceGroups,
                onChanged: _setResourceGroups,
                targetUnloadList: false,
              ),
              const SizedBox(height: 8),
              _resourceGroupSection(
                title: _fieldLabel(context, 'GroupsToUnloadForAds'),
                groups: _groupsToUnload,
                onChanged: _setGroupsToUnload,
                targetUnloadList: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
