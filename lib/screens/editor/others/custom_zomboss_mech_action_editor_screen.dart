import 'package:c_editor/widgets/autosave.dart';
import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_ordering.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_selection_screen.dart';
import 'package:c_editor/widgets/alias_rename_dialog.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/zomboss_mech_action_fields.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

/// Creates or edits a level-local zomboss action ([CurrentLevel]).
class CustomZombossMechActionEditorScreen extends StatefulWidget {
  const CustomZombossMechActionEditorScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    this.existingRtid,
    this.retreatOnly = false,
    this.jumpOnly = false,
    this.propsData,
    this.onPropsSync,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final String? existingRtid;
  final bool retreatOnly;
  final bool jumpOnly;
  final Map<String, dynamic>? propsData;
  final VoidCallback? onPropsSync;

  @override
  State<CustomZombossMechActionEditorScreen> createState() =>
      _CustomZombossMechActionEditorScreenState();
}

class _CustomZombossMechActionEditorScreenState
    extends State<CustomZombossMechActionEditorScreen> {
  PvzObject? _obj;
  late Map<String, dynamic> _data;
  late String _alias;
  late String _objclass;
  late String _baseActionAlias;
  late TextEditingController _aliasCtrl;
  late bool _aliasManuallyEdited;
  late final PvzLevelFile _initialLevelSnapshot;
  late final Map<String, dynamic>? _initialPropsSnapshot;
  late final Map<String, dynamic> _initialDataSnapshot;
  late final String _initialAliasText;
  late final String _initialObjclass;
  late final String _initialBaseActionAlias;
  bool _canPop = false;
  bool _exitDialogOpen = false;

  bool get _isEditing => widget.existingRtid != null;

  List<ZombossMechCatalogAction> get _baseActions {
    if (widget.jumpOnly) return widget.catalog.jumpCatalogActions;
    if (widget.retreatOnly) return widget.catalog.retreatCatalogActions;
    return ZombossMechActionOrdering.sortedCatalogActions(widget.catalog);
  }

  List<ZombossMechObjclassGroup> get _groups {
    if (widget.jumpOnly) {
      final seen = <String>{};
      return widget.catalog.actions
          .where(
            (g) =>
                isZombossJumpActionObjclass(g.objclass) && seen.add(g.objclass),
          )
          .toList();
    }
    final groups = widget.retreatOnly
        ? widget.catalog.actions.where(isRetreatPhaseActionGroup)
        : widget.catalog.actions.where(isRegularPhaseActionGroup);
    final seen = <String>{};
    final list = groups.where((g) => seen.add(g.objclass)).toList();
    if (!widget.retreatOnly) {
      for (final group
          in ZombossCustomActionPresetRepository.actionGroupsForMech(
            widget.catalog.editableInstance,
          )) {
        if (seen.add(group.objclass)) {
          list.add(group);
        }
      }
    }
    return list;
  }

  /// Schema for the current action type — always keyed by level/state objclass.
  ZombossMechObjclassGroup? get _group {
    final exact = _groups.where((g) => g.objclass == _objclass).firstOrNull;
    if (exact != null) return exact;
    return widget.catalog.actions
            .where((g) => g.objclass == _objclass)
            .firstOrNull ??
        ZombossCustomActionPresetRepository.groupForObjclass(
          widget.catalog.editableInstance,
          _objclass,
        );
  }

  List<ZombossMechFieldSpec> get _fields {
    final group = _group;
    if (group != null) return group.fields;
    return ZombossMechActionUtils.fieldsForObjclass(
      catalog: widget.catalog,
      objclass: _objclass,
      editableInstance: widget.catalog.editableInstance,
    );
  }

  ZombossCustomActionOrigin get _actionOrigin => _obj == null
      ? ZombossCustomActionOrigin.userCreated
      : ZombossCustomActionPresetRepository.originForObject(_obj!);

  /// New user-created actions pick a catalog template to seed type + defaults.
  bool get _usesTemplatePicker =>
      !_isEditing && _actionOrigin == ZombossCustomActionOrigin.userCreated;

  ZombossCustomActionPreset? get _dependencyPreset {
    if (_obj == null || _usesTemplatePicker) return null;
    return ZombossCustomActionPresetRepository.presetForObject(_obj!);
  }

  ZombossCustomActionPresetDependency? get _awardDropDependencySpec {
    final preset = _dependencyPreset;
    if (preset == null) return null;
    final dependencyId = preset.dependencyRtidFields['AwardDrop'];
    if (dependencyId == null) return null;
    return preset.dependencies.firstWhereOrNull(
      (dependency) => dependency.id == dependencyId,
    );
  }

  String _actionTypeName(BuildContext context, ZombossMechObjclassGroup group) {
    return ZombossMechL10n.actionLabel(
      context,
      widget.catalog.id,
      group.objclass,
      fallback: group.objclass,
    );
  }

  String _baseActionLabel(
    BuildContext context,
    ZombossMechCatalogAction action,
  ) {
    return ZombossMechL10n.implementationDisplayLabel(
      context,
      widget.catalog.id,
      action.alias,
    );
  }

  String _objclassDisplayLabel(BuildContext context) {
    final group = _group;
    if (group != null) return _actionTypeName(context, group);
    return ZombossMechL10n.actionLabel(
      context,
      widget.catalog.id,
      _objclass,
      fallback: _objclass,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingRtid != null) {
      _loadExisting(widget.existingRtid!);
    } else {
      final action = _baseActions.firstOrNull;
      final group =
          _groups.firstOrNull ??
          (widget.jumpOnly ? null : widget.catalog.actions.firstOrNull);
      _objclass = action?.objclass ?? group?.objclass ?? '';
      _baseActionAlias =
          action?.alias ??
          group?.implementations.keys.firstOrNull ??
          'CustomAction';
      final sampleAlias = _baseActionAlias;
      _alias = ZombossMechActionUtils.uniqueCustomAlias(
        widget.levelFile,
        sampleAlias,
      );
      _data = action != null
          ? ZombossMechActionUtils.dataFromCatalogAction(action)
          : ZombossMechActionUtils.defaultsFromFields(
              group?.fields ?? const [],
            );
    }
    _aliasCtrl = TextEditingController(text: _alias);
    _aliasManuallyEdited =
        widget.existingRtid != null &&
        !_looksLikeGeneratedAlias(_alias, _baseActionAlias);
    _initialLevelSnapshot = _cloneLevel(widget.levelFile);
    _initialPropsSnapshot = widget.propsData == null
        ? null
        : _cloneMap(widget.propsData!);
    _initialDataSnapshot = _cloneMap(_data);
    _initialAliasText = _aliasCtrl.text;
    _initialObjclass = _objclass;
    _initialBaseActionAlias = _baseActionAlias;
  }

  PvzLevelFile _cloneLevel(PvzLevelFile levelFile) => PvzLevelFile.fromJson(
    jsonDecode(jsonEncode(levelFile.toJson())) as Map<String, dynamic>,
  );

  Map<String, dynamic> _cloneMap(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(
        jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
      );

  bool get _hasUnsavedChanges {
    const equality = DeepCollectionEquality();
    return _aliasCtrl.text != _initialAliasText ||
        _objclass != _initialObjclass ||
        _baseActionAlias != _initialBaseActionAlias ||
        !equality.equals(_data, _initialDataSnapshot) ||
        !equality.equals(
          widget.levelFile.toJson(),
          _initialLevelSnapshot.toJson(),
        ) ||
        !equality.equals(widget.propsData, _initialPropsSnapshot);
  }

  bool _looksLikeGeneratedAlias(String alias, String baseAlias) {
    if (baseAlias.isEmpty) return false;
    if (alias == baseAlias) return true;
    return RegExp('^${RegExp.escape(baseAlias)}_[0-9]+\$').hasMatch(alias);
  }

  void _loadExisting(String rtid) {
    final info = RtidParser.parse(rtid);
    _alias = info?.alias ?? 'CustomAction';
    _obj = ZombossMechActionUtils.findLevelObject(widget.levelFile, rtid);
    // Always trust the level object's objclass — never fall back to the first
    // catalog action type (that was showing the wrong field schema on edit).
    final levelObjclass = _obj?.objClass.trim() ?? '';
    _objclass = levelObjclass.isNotEmpty
        ? levelObjclass
        : (_groups.firstOrNull?.objclass ??
              widget.catalog.actions.firstOrNull?.objclass ??
              '');
    final raw = _obj?.objData;
    _data = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : {};
    _baseActionAlias =
        ZombossMechActionUtils.inferBaseCatalogAction(
          catalog: widget.catalog,
          customAlias: _alias,
          objclass: _objclass,
          data: _data,
          retreatOnly: widget.retreatOnly,
          jumpOnly: widget.jumpOnly,
        )?.alias ??
        _baseActions
            .where((action) => action.objclass == _objclass)
            .firstOrNull
            ?.alias ??
        '';
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    super.dispose();
  }

  void _syncObject() {
    if (_obj == null) {
      _obj = ZombossMechActionUtils.createCustomAction(
        levelFile: widget.levelFile,
        objclass: _objclass,
        alias: _alias,
        data: _data,
      );
    } else {
      _obj!.aliases =
          ZombossCustomActionPresetRepository.aliasesWithPrimaryAlias(
            _alias,
            _obj!.aliases,
          );
      _obj!.objClass = _objclass;
      _obj!.objData = Map<String, dynamic>.from(_data);
    }
    widget.onPropsSync?.call();
  }

  PvzObject? _awardDropObject() {
    final value = _data['AwardDrop']?.toString() ?? '';
    return ZombossMechActionUtils.findLevelObject(widget.levelFile, value);
  }

  bool _hasValidAwardDrop() {
    final spec = _awardDropDependencySpec;
    if (spec == null) return true;
    return ZombossCustomActionPresetRepository.isValidDependencyObject(
      _awardDropObject(),
      spec,
    );
  }

  void _restoreDefaultAwardDrop() {
    final spec = _awardDropDependencySpec;
    if (spec == null) return;
    final created =
        ZombossCustomActionPresetRepository.createDependencyForField(
          levelFile: widget.levelFile,
          spec: spec,
        );
    setState(() {
      _data['AwardDrop'] = created.rtid;
      _syncObject();
    });
  }

  Future<String?> _pickJumpAction(String currentRtid) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechActionSelectionScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          jumpOnly: true,
        ),
      ),
    );
  }

  Widget _buildAwardDropEditor(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _awardDropDependencySpec;
    if (spec == null) return const SizedBox.shrink();
    final rtid = _data['AwardDrop']?.toString() ?? '';
    final dependency = _awardDropObject();
    final valid = ZombossCustomActionPresetRepository.isValidDependencyObject(
      dependency,
      spec,
    );
    if (!valid) {
      final colors = Theme.of(context).colorScheme;
      return Card(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: colors.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.zombossMechAwardDropInvalidTitle ??
                          'Invalid SpawnBall reference',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.zombossMechAwardDropInvalidBody(rtid) ??
                    'AwardDrop points to "$rtid", but it is not a valid CurrentLevel ZombieDropProps object.',
                style: TextStyle(color: colors.onErrorContainer),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: _restoreDefaultAwardDrop,
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: Text(
                    l10n?.zombossMechAwardDropClearInvalid ??
                        'Clear invalid value and restore default',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final raw = dependency!.objData;
    final dependencyData = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.zombossMechSpawnBallSettings ??
                  'SpawnBall contents (ZombieDropProps)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              rtid,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ZombossMechActionFieldsEditor(
              mechId: widget.catalog.id,
              fields: spec.fields,
              data: dependencyData,
              objclass: spec.objclass,
              levelFile: widget.levelFile,
              catalog: widget.catalog,
              onPickJumpAction: _pickJumpAction,
              onChanged: () {
                dependency.objData =
                    ZombossCustomActionPresetRepository.cloneDependencyData(
                      dependencyData,
                    );
                _syncObject();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _tryApplyAlias(
    String newAlias, {
    bool confirmRename = true,
  }) async {
    final trimmed = newAlias.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == _alias) {
      _aliasCtrl.text = trimmed;
      return true;
    }

    if (!ZombossMechActionUtils.isAliasAvailable(
      widget.levelFile,
      trimmed,
      except: _obj,
    )) {
      await showAliasAlreadyTakenDialog(context);
      _aliasCtrl.text = _alias;
      return false;
    }

    if (widget.existingRtid != null || _obj != null) {
      if (confirmRename) {
        final confirmed = await showAliasRenameConfirmDialog(
          context,
          oldAlias: _alias,
          newAlias: trimmed,
        );
        if (!confirmed) {
          _aliasCtrl.text = _alias;
          return false;
        }
      }
      ZombossMechActionUtils.renameCustomActionInLevel(
        levelFile: widget.levelFile,
        oldAlias: _alias,
        newAlias: trimmed,
        obj: _obj,
      );
      if (widget.propsData != null) {
        ZombossMechActionUtils.renameCustomActionReferences(
          propsData: widget.propsData!,
          oldAlias: _alias,
          newAlias: trimmed,
        );
      }
      widget.onPropsSync?.call();
    }

    setState(() {
      _alias = trimmed;
      _aliasCtrl.text = trimmed;
      _syncObject();
    });
    return true;
  }

  void _applyAlias(String newAlias) {
    unawaited(_tryApplyAlias(newAlias));
  }

  Future<void> _applyTemplate(
    ZombossMechCatalogAction action, {
    required bool confirmAliasSync,
  }) async {
    final suggestedAlias = ZombossMechActionUtils.uniqueCustomAlias(
      widget.levelFile,
      action.alias,
      except: _obj,
    );
    var syncAlias = !_aliasManuallyEdited;
    if (confirmAliasSync && _aliasManuallyEdited) {
      final l10n = AppLocalizations.of(context);
      syncAlias =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(
                l10n?.zombossMechBaseActionAliasSyncTitle ??
                    'Update the action codename?',
              ),
              content: Text(
                l10n?.zombossMechBaseActionAliasSyncMessage(suggestedAlias) ??
                    'Also update the action codename to "$suggestedAlias"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    l10n?.zombossMechBaseActionAliasKeep ??
                        'Keep current codename',
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                    l10n?.zombossMechBaseActionAliasUpdate ?? 'Update codename',
                  ),
                ),
              ],
            ),
          ) ??
          false;
      if (!mounted) return;
    }

    if (syncAlias) {
      final applied = await _tryApplyAlias(
        suggestedAlias,
        confirmRename: false,
      );
      if (!mounted) return;
      if (applied) _aliasManuallyEdited = false;
    }
    setState(() {
      _baseActionAlias = action.alias;
      _objclass = action.objclass;
      _data = ZombossMechActionUtils.dataFromCatalogAction(action);
      _syncObject();
    });
  }

  Future<void> _onBaseActionChanged(String alias) async {
    if (alias == _baseActionAlias) return;
    final action = _baseActions
        .where((candidate) => candidate.alias == alias)
        .firstOrNull;
    if (action == null) return;
    await _applyTemplate(action, confirmAliasSync: true);
  }

  Future<void> _recreateFromTemplate() async {
    if (_baseActions.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  child: Text(
                    l10n?.zombossMechRecreateFromTemplate ??
                        'Recreate from template',
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Text(
                    l10n?.zombossMechRecreateFromTemplateMessage ??
                        'This replaces the action type and all field values.',
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.bodyMedium
                        ?.copyWith(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const Divider(height: 1),
                for (var index = 0; index < _baseActions.length; index++) ...[
                  if (index > 0) const Divider(height: 1),
                  Builder(
                    builder: (context) {
                      final action = _baseActions[index];
                      final selected = action.alias == _baseActionAlias;
                      return EditorOptionTile(
                        selected: selected,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: Text(
                          ZombossMechL10n.implementationLabel(
                            context,
                            widget.catalog.id,
                            action.alias,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text('${action.alias}\n${action.objclass}'),
                        ),
                        trailing: selected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, action.alias),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    final action = _baseActions
        .where((candidate) => candidate.alias == selected)
        .firstOrNull;
    if (action == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n?.zombossMechRecreateFromTemplateTitle ?? 'Replace this action?',
        ),
        content: Text(
          l10n?.zombossMechRecreateFromTemplateMessage ??
              'This replaces the action type and all field values with the selected template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n?.zombossMechRecreateFromTemplate ?? 'Recreate from template',
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _applyTemplate(action, confirmAliasSync: true);
  }

  Future<String?> _saveAction() async {
    if (widget.existingRtid == null && _obj == null) {
      final trimmed = _aliasCtrl.text.trim();
      if (trimmed.isEmpty) return null;
      if (!ZombossMechActionUtils.isAliasAvailable(widget.levelFile, trimmed)) {
        await showAliasAlreadyTakenDialog(context);
        return null;
      }
      _alias = trimmed;
    } else {
      final aliasOk = await _tryApplyAlias(_aliasCtrl.text);
      if (!aliasOk || !mounted) return null;
    }
    if (_obj == null && !_hasValidAwardDrop()) {
      _restoreDefaultAwardDrop();
    }
    _syncObject();
    return RtidParser.build(_alias, ZombossMechActionUtils.customSource);
  }

  void _exitWithResult(String? result) {
    if (!mounted) return;
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  Future<void> _saveAndExit({bool automatic = false}) async {
    final result = await _saveAction();
    if (result != null && mounted) {
      if (automatic) showAutosavedMessage(context);
      _exitWithResult(result);
    }
  }

  void _restoreInitialState() {
    final restored = _cloneLevel(_initialLevelSnapshot);
    widget.levelFile
      ..objects.clear()
      ..objects.addAll(restored.objects)
      ..version = restored.version;
    if (widget.propsData != null && _initialPropsSnapshot != null) {
      widget.propsData!
        ..clear()
        ..addAll(_cloneMap(_initialPropsSnapshot));
    }
    widget.onPropsSync?.call();
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    if (!_hasUnsavedChanges) {
      _exitWithResult(null);
      return;
    }
    _exitDialogOpen = true;
    if (autosaveEnabled(context, AutosaveTarget.zombossAction)) {
      try {
        await _saveAndExit(automatic: true);
      } finally {
        _exitDialogOpen = false;
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_CustomActionExitChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.unsavedChanges ?? 'Unsaved changes'),
        content: Text(l10n?.saveBeforeLeaving ?? 'Save before leaving?'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomActionExitChoice.discard),
            child: Text(l10n?.discard ?? 'Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.stayInEditor ?? 'Stay'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomActionExitChoice.save),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (!mounted) return;
    switch (choice) {
      case _CustomActionExitChoice.discard:
        _restoreInitialState();
        _exitWithResult(null);
        return;
      case _CustomActionExitChoice.save:
        await _saveAndExit();
        return;
      case null:
        return;
    }
  }

  Widget _buildTypeSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_usesTemplatePicker) {
      final selectedAlias =
          _baseActions.any((action) => action.alias == _baseActionAlias)
          ? _baseActionAlias
          : _baseActions.firstOrNull?.alias;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SeparatedOptionPickerField<String>(
            labelText: l10n?.zombossMechActionBaseAction ?? 'Base Action',
            value: selectedAlias,
            items: [
              for (final action in _baseActions)
                SeparatedOptionPickerItem(
                  value: action.alias,
                  label: ZombossMechL10n.implementationLabel(
                    context,
                    widget.catalog.id,
                    action.alias,
                  ),
                  subtitle: '${action.alias} · ${action.objclass}',
                  fieldLabel: _baseActionLabel(context, action),
                ),
            ],
            onChanged: _onBaseActionChanged,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.zombossMechActionTemplateHint ??
                'Pick a built-in action to copy its type and default values.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Editing (and preset-derived): lock to the level object's objclass.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorResponsiveInputField(
          label: l10n?.zombossMechActionBaseObjclass ?? 'Action Type',
          decoration: editorInputDecoration(context),
          builder: (context, decoration) => InputDecorator(
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _objclassDisplayLabel(context),
                  style: theme.textTheme.bodyLarge,
                ),
                if (_objclass.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _objclass,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_actionOrigin == ZombossCustomActionOrigin.userCreated &&
            _baseActions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _recreateFromTemplate,
              icon: const Icon(Icons.find_replace_outlined),
              label: Text(
                l10n?.zombossMechRecreateFromTemplate ??
                    'Recreate from template',
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fields = _fields;
    final isNew = !_isEditing;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: zombossMechAccent(context),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _confirmExit,
          ),
          title: Text(
            isNew
                ? (l10n?.zombossMechCreateCustomAction ?? 'New custom action')
                : (l10n?.zombossMechEditCustomAction ?? 'Edit custom action'),
          ),
          actions: [
            IconButton(
              onPressed: _saveAndExit,
              tooltip: l10n?.save ?? 'Save',
              icon: const Icon(Icons.save, color: Colors.white),
            ),
          ],
        ),
        body: Theme(
          data: zombossMechInputTheme(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EditorResponsiveInputField(
                label: l10n?.aliasLabel ?? 'Alias',
                decoration: editorInputDecoration(
                  context,
                  hintText:
                      l10n?.zombossMechActionAliasHint ??
                      'Codename used in RTID(alias@CurrentLevel).',
                ),
                builder: (context, decoration) => TextFormField(
                  controller: _aliasCtrl,
                  decoration: decoration,
                  onChanged: (_) => _aliasManuallyEdited = true,
                  onFieldSubmitted: _applyAlias,
                ),
              ),
              const SizedBox(height: 12),
              _buildTypeSection(context),
              const SizedBox(height: 16),
              if (fields.isNotEmpty)
                ZombossMechActionFieldsEditor(
                  mechId: widget.catalog.id,
                  fields: fields,
                  data: _data,
                  objclass: _objclass,
                  levelFile: widget.levelFile,
                  catalog: widget.catalog,
                  onPickJumpAction: _pickJumpAction,
                  hiddenFieldNames: _awardDropDependencySpec == null
                      ? const {}
                      : const {'AwardDrop'},
                  onChanged: () {
                    _syncObject();
                    setState(() {});
                  },
                ),
              if (_awardDropDependencySpec != null) ...[
                const SizedBox(height: 16),
                _buildAwardDropEditor(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _CustomActionExitChoice { discard, save }
