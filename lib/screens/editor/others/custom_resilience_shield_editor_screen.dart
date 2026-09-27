import 'package:c_editor/widgets/autosave.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:c_editor/data/pvz_models.dart';

import 'package:c_editor/data/resilience_weak_type.dart';

import 'package:c_editor/data/resilience_shield_utils.dart';

import 'package:c_editor/data/rtid_parser.dart';

import 'package:c_editor/l10n/app_localizations.dart';

import 'package:c_editor/widgets/alias_rename_dialog.dart';

import 'package:c_editor/widgets/editor_components.dart';

import 'package:c_editor/widgets/resilience_shield_widgets.dart';

/// Creates or edits a level-local [ZombieResilience] object. Object is added on save only.

class CustomResilienceShieldEditorScreen extends StatefulWidget {
  const CustomResilienceShieldEditorScreen({
    super.key,

    required this.levelFile,

    this.existingRtid,

    this.onChanged,
  });

  final PvzLevelFile levelFile;

  final String? existingRtid;

  final VoidCallback? onChanged;

  @override
  State<CustomResilienceShieldEditorScreen> createState() =>
      _CustomResilienceShieldEditorScreenState();
}

class _CustomResilienceShieldEditorScreenState
    extends State<CustomResilienceShieldEditorScreen> {
  PvzObject? _obj;

  late ZombieResilienceData _data;

  late String _alias;

  late TextEditingController _codenameCtrl;

  late TextEditingController _amountCtrl;

  late TextEditingController _recoverSpeedCtrl;

  late TextEditingController _damageThresholdCtrl;

  late TextEditingController _baseThresholdCtrl;

  late TextEditingController _extraThresholdCtrl;

  late final PvzLevelFile _initialLevelSnapshot;

  bool _canPop = false;

  bool _exitDialogOpen = false;

  bool _levelMutatedDuringEditing = false;

  bool get _isNew => widget.existingRtid == null;

  @override
  void initState() {
    super.initState();

    _initialLevelSnapshot = _cloneLevel(widget.levelFile);

    if (widget.existingRtid != null) {
      _loadExisting(widget.existingRtid!);
    } else {
      _data = ZombieResilienceData();

      _alias = ResilienceShieldUtils.nextCustomCodename(widget.levelFile);

      _codenameCtrl = TextEditingController(text: _alias);
    }

    _amountCtrl = TextEditingController(text: '${_data.amount}');

    _recoverSpeedCtrl = TextEditingController(text: '${_data.recoverSpeed}');

    _damageThresholdCtrl = TextEditingController(
      text: '${_data.damageThresholdPerSecond}',
    );

    _baseThresholdCtrl = TextEditingController(
      text: '${_data.resilienceBaseDamageThreshold}',
    );

    _extraThresholdCtrl = TextEditingController(
      text: '${_data.resilienceExtraDamageThreshold}',
    );
  }

  PvzLevelFile _cloneLevel(PvzLevelFile levelFile) => PvzLevelFile.fromJson(
    jsonDecode(jsonEncode(levelFile.toJson())) as Map<String, dynamic>,
  );

  void _loadExisting(String rtid) {
    _obj = ResilienceShieldUtils.findLevelObject(widget.levelFile, rtid);

    final info = RtidParser.parse(rtid);

    _alias = info?.alias ?? '';

    _codenameCtrl = TextEditingController(text: _alias);

    final raw = _obj?.objData;

    _data = raw is Map
        ? ZombieResilienceData.fromJson(Map<String, dynamic>.from(raw))
        : ZombieResilienceData();
  }

  @override
  void dispose() {
    _codenameCtrl.dispose();

    _amountCtrl.dispose();

    _recoverSpeedCtrl.dispose();

    _damageThresholdCtrl.dispose();

    _baseThresholdCtrl.dispose();

    _extraThresholdCtrl.dispose();

    super.dispose();
  }

  Future<bool> _tryApplyAlias(String newAlias) async {
    final trimmed = newAlias.trim();

    if (trimmed.isEmpty) return false;

    if (trimmed == _alias) return true;

    if (!ResilienceShieldUtils.isCodenameAvailable(
      widget.levelFile,

      trimmed,

      except: _obj,
    )) {
      await showAliasAlreadyTakenDialog(context);

      _codenameCtrl.text = _alias;

      return false;
    }

    if (!_isNew) {
      final confirmed = await showAliasRenameConfirmDialog(
        context,

        oldAlias: _alias,

        newAlias: trimmed,
      );

      if (!confirmed) {
        _codenameCtrl.text = _alias;

        return false;
      }

      ResilienceShieldUtils.renameCustomShield(
        levelFile: widget.levelFile,

        oldAlias: _alias,

        newAlias: trimmed,

        obj: _obj,
      );

      _levelMutatedDuringEditing = true;

      widget.onChanged?.call();
    }

    setState(() => _alias = trimmed);

    return true;
  }

  Future<String?> _saveShield() async {
    final codename = _codenameCtrl.text.trim();

    if (codename.isEmpty) return null;

    if (!_isNew) {
      final aliasOk = await _tryApplyAlias(codename);

      if (!aliasOk || !mounted) return null;
    } else if (!ResilienceShieldUtils.isCodenameAvailable(
      widget.levelFile,

      codename,
    )) {
      await showAliasAlreadyTakenDialog(context);

      return null;
    } else {
      _alias = codename;
    }

    final amount = int.tryParse(_amountCtrl.text);

    final recoverSpeed = double.tryParse(_recoverSpeedCtrl.text);

    final damageThreshold = double.tryParse(_damageThresholdCtrl.text);

    final baseThreshold = int.tryParse(_baseThresholdCtrl.text);

    final extraThreshold = int.tryParse(_extraThresholdCtrl.text);

    if (amount != null) _data.amount = amount;

    if (recoverSpeed != null) _data.recoverSpeed = recoverSpeed;

    if (damageThreshold != null) {
      _data.damageThresholdPerSecond = damageThreshold;
    }

    if (baseThreshold != null) {
      _data.resilienceBaseDamageThreshold = baseThreshold;
    }

    if (extraThreshold != null) {
      _data.resilienceExtraDamageThreshold = extraThreshold;
    }

    final payload = _data.toLevelJson();

    if (_obj == null) {
      _obj = ResilienceShieldUtils.createCustomShield(
        levelFile: widget.levelFile,

        alias: _alias,

        data: _data,
      );
    } else {
      _obj!.aliases = [_alias];

      _obj!.objData = payload;
    }

    widget.onChanged?.call();

    return RtidParser.build(_alias, ResilienceShieldUtils.customSource);
  }

  void _exitWithResult(String? result) {
    if (!mounted) return;

    setState(() => _canPop = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  Future<void> _saveAndExit({bool automatic = false}) async {
    final result = await _saveShield();

    if (result != null && mounted) {
      if (automatic) showAutosavedMessage(context);
      _exitWithResult(result);
    }
  }

  void _restoreInitialState() {
    if (!_levelMutatedDuringEditing) return;

    final restored = _cloneLevel(_initialLevelSnapshot);

    widget.levelFile
      ..objects.clear()
      ..objects.addAll(restored.objects)
      ..version = restored.version;

    widget.onChanged?.call();
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;

    _exitDialogOpen = true;
    if (autosaveEnabled(context, AutosaveTarget.resilienceShield)) {
      try {
        await _saveAndExit(automatic: true);
      } finally {
        _exitDialogOpen = false;
      }
      return;
    }

    final l10n = AppLocalizations.of(context);

    final choice = await showDialog<_CustomShieldExitChoice>(
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
                Navigator.pop(dialogContext, _CustomShieldExitChoice.discard),
            child: Text(l10n?.discard ?? 'Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.stayInEditor ?? 'Stay'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomShieldExitChoice.save),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );

    _exitDialogOpen = false;

    if (!mounted) return;

    switch (choice) {
      case _CustomShieldExitChoice.discard:
        _restoreInitialState();
        _exitWithResult(null);
        return;
      case _CustomShieldExitChoice.save:
        await _saveAndExit();
        return;
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _confirmExit,
          ),
          title: Text(
            _isNew
                ? (l10n?.resilienceCreateCustom ?? 'New custom shield')
                : (l10n?.resilienceEditCustom ?? 'Edit custom shield'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          actions: [
            IconButton(
              onPressed: _saveAndExit,
              tooltip: l10n?.save ?? 'Save',
              icon: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),

        body: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            EditorResponsiveInputField(
              label:
                  l10n?.resilienceCodename ?? 'Resilience codename (aliases)',
              decoration: InputDecoration(
                hintText:
                    l10n?.resilienceCodenameHint ?? 'e.g. CustomResilience0',
                border: const OutlineInputBorder(),
              ),
              builder: (context, decoration) => TextFormField(
                controller: _codenameCtrl,
                decoration: decoration,
                onFieldSubmitted: _tryApplyAlias,
                onEditingComplete: () => _tryApplyAlias(_codenameCtrl.text),
              ),
            ),

            const SizedBox(height: 12),

            EditorResponsiveInputField(
              label: l10n?.resilienceAmount ?? 'Resilience value (Amount)',
              builder: (context, decoration) => TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: decoration,
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) setState(() => _data.amount = n);
                },
              ),
            ),

            const SizedBox(height: 12),

            EditorResponsiveInputField(
              label: l10n?.resilienceWeakType ?? 'Resilience type (WeakType)',
              builder: (context, decoration) => DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue:
                    resilienceWeakTypeJsonValues.contains(_data.weakType)
                    ? _data.weakType
                    : null,
                decoration: decoration,
                hint: resilienceWeakTypeJsonValues.contains(_data.weakType)
                    ? null
                    : Text(
                        resilienceWeakTypeLabel(l10n, _data.weakType),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                items: resilienceWeakTypeJsonValues.map((wt) {
                  return DropdownMenuItem(
                    value: wt,
                    child: ResilienceWeakTypeLabelRow(
                      weakType: wt,
                      label: resilienceWeakTypeLabel(l10n, wt),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _data.weakType = v);
                },
              ),
            ),

            const SizedBox(height: 12),

            EditorResponsiveInputField(
              label:
                  l10n?.resilienceRecoverSpeed ??
                  'Resilience bar recovery speed (RecoverSpeed)',
              builder: (context, decoration) => TextFormField(
                controller: _recoverSpeedCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: decoration,
                onChanged: (v) {
                  final n = double.tryParse(v);
                  if (n != null) setState(() => _data.recoverSpeed = n);
                },
              ),
            ),

            const SizedBox(height: 12),

            EditorResponsiveInputField(
              label:
                  l10n?.resilienceDamageThresholdPerSecond ??
                  'Zombie damage threshold per second (DamageThresholdPerSecond)',
              builder: (context, decoration) => TextFormField(
                controller: _damageThresholdCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: decoration,
                onChanged: (v) {
                  final n = double.tryParse(v);
                  if (n != null) {
                    setState(() => _data.damageThresholdPerSecond = n);
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            EditorResponsiveInputField(
              label:
                  l10n?.resilienceBaseDamageThreshold ??
                  'Resilience base damage threshold (ResilienceBaseDamageThreshold)',
              builder: (context, decoration) => TextFormField(
                controller: _baseThresholdCtrl,
                keyboardType: TextInputType.number,
                decoration: decoration,
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) {
                    setState(() => _data.resilienceBaseDamageThreshold = n);
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            EditorResponsiveInputField(
              label:
                  l10n?.resilienceExtraDamageThreshold ??
                  'Resilience extra damage threshold (ResilienceExtraDamageThreshold)',
              builder: (context, decoration) => TextFormField(
                controller: _extraThresholdCtrl,
                keyboardType: TextInputType.number,
                decoration: decoration,
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) {
                    setState(() => _data.resilienceExtraDamageThreshold = n);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CustomShieldExitChoice { discard, save }
