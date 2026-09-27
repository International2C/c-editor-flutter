import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the Autosave settings dialog. Applies changes only when the user taps Confirm.
Future<void> showAutosaveSettingsDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final cubit = context.read<SettingsCubit>();
  final selected = {...cubit.state.autosaveTargets};
  final labels = <AutosaveTarget, String>{
    AutosaveTarget.level:
        l10n?.autosaveSubtitle ?? 'Save changes when leaving a level',
    AutosaveTarget.zombossAction:
        l10n?.autosaveZombossAction ?? 'Save custom Zomboss mech actions',
    AutosaveTarget.portal: l10n?.autosavePortal ?? 'Save custom portals',
    AutosaveTarget.resilienceShield:
        l10n?.autosaveResilienceShield ?? 'Save custom resilience shields',
    AutosaveTarget.previewImage:
        l10n?.autosavePreviewImage ?? 'Save preview images',
  };

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(l10n?.autosave ?? 'Autosave'),
        scrollable: true,
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                key: const ValueKey('autosaveSelectAll'),
                tristate: true,
                value: selected.isEmpty
                    ? false
                    : selected.length == AutosaveTarget.values.length
                    ? true
                    : null,
                onChanged: (_) => setDialogState(() {
                  if (selected.length == AutosaveTarget.values.length) {
                    selected.clear();
                  } else {
                    selected.addAll(AutosaveTarget.values);
                  }
                }),
                title: Text(l10n?.selectAll ?? 'Select all'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              for (final target in AutosaveTarget.values)
                CheckboxListTile(
                  key: ValueKey('autosave_${target.name}'),
                  value: selected.contains(target),
                  onChanged: (value) => setDialogState(() {
                    value == true
                        ? selected.add(target)
                        : selected.remove(target);
                  }),
                  title: Text(labels[target]!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.autosaveExit ?? 'Exit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    ),
  );

  if (saved == true && context.mounted) {
    cubit.setAutosaveTargets(selected);
  }
}
