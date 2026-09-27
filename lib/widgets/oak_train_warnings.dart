import 'package:flutter/material.dart';
import 'package:c_editor/data/oak_train_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

class OakTrainWarnings extends StatelessWidget {
  const OakTrainWarnings({super.key, required this.levelFile, this.event});
  final PvzLevelFile levelFile;
  final PvzObject? event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (event != null) {
      return OakTrainUtils.hasIncompatibleTargets(event!)
          ? EditorWarningBanner(
              title: l10n.targetZombieInWaveManagerWarningTitle,
              message: l10n.targetZombieInWaveManagerWarning,
            )
          : const SizedBox.shrink();
    }
    final issues = LevelIssueRegistry.forLevel(context, levelFile).where(
      (i) =>
          i.id == 'oakTrainTutorialIntroWarning' ||
          i.id == 'oakTrainUnderwaterWarning' ||
          i.id == 'targetZombieInWaveManagerWarning',
    );
    return Column(
      children: [
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EditorWarningBanner(
              title: issue.title,
              message: issue.message,
            ),
          ),
      ],
    );
  }
}
