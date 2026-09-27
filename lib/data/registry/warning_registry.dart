import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';

export 'package:c_editor/data/registry/issue_registry.dart'
    show
        LevelIssueSeverity,
        LevelIssue,
        LevelIssueContext,
        LevelModuleRef,
        isExpeditionTilesModule,
        LevelIssueRegistry;

/// Back-compat aliases for the renamed issue types.
typedef LevelWarningSeverity = LevelIssueSeverity;
typedef LevelWarning = LevelIssue;
typedef LevelWarningContext = LevelIssueContext;

/// Compatibility wrapper — prefer [LevelIssueRegistry].
class WarningRegistry {
  static const seeingStarsModule = LevelIssueRegistry.seeingStarsModule;
  static const zombiesDeadWinCon = LevelIssueRegistry.zombiesDeadWinCon;
  static const bronzeDeadWinCon = LevelIssueRegistry.bronzeDeadWinCon;
  static const glacierModule = LevelIssueRegistry.glacierModule;
  static const zombossBattleModule = LevelIssueRegistry.zombossBattleModule;

  static List<LevelIssue> forLevel(
    BuildContext context,
    PvzLevelFile levelFile, {
    ParsedLevelData? parsed,
    bool editorOnly = false,
  }) => LevelIssueRegistry.forLevel(
    context,
    levelFile,
    parsed: parsed,
    editorOnly: editorOnly,
  );
}
