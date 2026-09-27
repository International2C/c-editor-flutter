import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:flutter/material.dart';

class ValidationIssue {
  final String title;
  final String message;
  final bool isError;
  final List<String> bulletPoints;

  ValidationIssue({
    required this.title,
    required this.message,
    this.isError = false,
    this.bulletPoints = const [],
  });
}

class LevelValidator {
  static List<ValidationIssue> validate(
    BuildContext context,
    PvzLevelFile levelFile,
  ) {
    final parsedData = LevelParser.parseLevel(levelFile);
    if (parsedData.levelDef == null) return const [];

    return LevelIssueRegistry.forLevel(
      context,
      levelFile,
      parsed: parsedData,
    ).map(
      (issue) => ValidationIssue(
        title: issue.title,
        message: issue.message,
        isError: issue.isError,
        bulletPoints: issue.bulletPoints,
      ),
    ).toList();
  }
}
