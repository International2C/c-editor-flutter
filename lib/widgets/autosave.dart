import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:c_editor/bloc/settings/settings_cubit.dart' show AutosaveTarget;

bool autosaveEnabled(BuildContext context, AutosaveTarget target) =>
    context.read<SettingsCubit?>()?.state.autosaveTargets.contains(target) ??
    false;

void showAutosavedMessage(BuildContext context, {String? path}) {
  final l10n = AppLocalizations.of(context);
  AppMessage.show(
    context,
    path == null
        ? l10n?.automaticallySaved ?? 'Automatically saved'
        : l10n?.automaticallySavedTo(path) ?? 'Automatically saved to: $path',
    icon: Icons.check_circle,
  );
}
