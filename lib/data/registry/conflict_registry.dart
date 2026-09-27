import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/issue_registry.dart';

export 'package:c_editor/data/registry/issue_registry.dart'
    show ModuleConflictRule;

/// Compatibility wrapper around [LevelIssueRegistry] pairwise conflicts.
class ConflictRegistry {
  static List<ModuleConflictRule> get rules =>
      LevelIssueRegistry.conflictModuleRules;

  /// Returns list of (localized title, localized description) for active conflicts.
  static List<Pair<String, String>> getActiveConflicts(
    BuildContext context,
    Set<String> existingObjClasses,
  ) {
    return LevelIssueRegistry.conflictsForClasses(
      context,
      existingObjClasses,
    ).map((issue) => Pair(issue.title, issue.message)).toList();
  }
}

class Pair<A, B> {
  final A first;
  final B second;
  const Pair(this.first, this.second);
}
