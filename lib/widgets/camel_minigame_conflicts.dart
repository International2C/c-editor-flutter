import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/theme/app_theme.dart' show editorErrorIcon;

/// The same detected conflicts as the level settings and export validation.
class CamelMinigameConflicts extends StatelessWidget {
  const CamelMinigameConflicts({
    super.key,
    required this.levelFile,
    this.onlyIds,
  });
  final PvzLevelFile levelFile;
  final Set<String>? onlyIds;

  @override
  Widget build(BuildContext context) {
    final issueContext = LevelIssueContext.fromLevel(levelFile);
    if (!issueContext.hasModule('CamelMinigameProperties')) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).colorScheme;
    final issues = LevelIssueRegistry.getActiveIssues(context, issueContext)
        .where(
          (issue) =>
              onlyIds?.contains(issue.id) ??
              (issue.id.startsWith('camelMinigame') ||
                  issue.id == 'conflict_conflictDesc_CamelMinigameIntro'),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              key: ValueKey(issue.id),
              color: colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(editorErrorIcon, color: colors.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            issue.title,
                            style: TextStyle(
                              color: colors.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      issue.message,
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
