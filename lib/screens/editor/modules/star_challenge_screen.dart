import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/challenge_repository.dart';
import 'package:c_editor/screens/select/challenge_selection_screen.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/screens/editor/modules/challenge_editors.dart'
    show showChallengeEditorDialog;

class StarChallengeModuleScreen extends StatefulWidget {
  const StarChallengeModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
    this.onOpenCustomStageSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;
  final Future<void> Function()? onOpenCustomStageSelection;

  @override
  State<StarChallengeModuleScreen> createState() =>
      _StarChallengeModuleScreenState();
}

class _StarChallengeModuleScreenState extends State<StarChallengeModuleScreen> {
  static const _objClass = 'StarChallengeModuleProperties';

  late StarChallengeModuleData _data;
  late PvzObject _moduleObj;
  late String _alias;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;

    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(objClass: _objClass, objData: {}),
    );

    try {
      _data = StarChallengeModuleData.fromJson(_moduleObj.objData);
    } catch (e) {
      _data = StarChallengeModuleData();
    }

    // Ensure at least one list exists (for 1st star)
    if (_data.challenges.isEmpty) {
      _data.challenges.add([]);
    }
  }

  void _saveData() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
  }

  void _confirmRemoveChallenge(int index, String challengeRtid, String title) {
    final info = RtidParser.parse(challengeRtid);
    final isLocal = info?.source == 'CurrentLevel';
    final l10n = AppLocalizations.of(context);
    final message = isLocal
        ? (l10n?.deleteChallengeConfirmLocal(title) ??
              'Remove "$title"? Local challenge data will be deleted permanently.')
        : (l10n?.deleteChallengeConfirmRef(title) ??
              'Remove "$title"? Reference will be removed. Challenge stays in LevelModules.');

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteChallengeTitle ?? 'Delete challenge?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n?.delete ?? 'Delete',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _removeChallenge(index, challengeRtid);
    });
  }

  void _removeChallenge(int index, String challengeRtid) {
    if (_data.challenges.isEmpty) return;

    setState(() {
      _data.challenges[0].removeAt(index);

      // Also remove the object if it's local
      final info = RtidParser.parse(challengeRtid);
      if (info != null && info.source == 'CurrentLevel') {
        widget.levelFile.objects.removeWhere(
          (o) => o.aliases?.contains(info.alias) == true,
        );
      }

      _saveData();
    });
  }

  static const _noConfigChallenges = {
    'StarChallengeSaveMowersProps',
    'StarChallengePlantFoodNonuseProps',
    'StarChallengeSaveBombsProps',
  };

  void _editChallenge(String challengeRtid) {
    final info = RtidParser.parse(challengeRtid);
    final alias = info?.alias ?? challengeRtid;
    final obj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(objClass: 'Unknown', objData: {}),
    );

    if (_noConfigChallenges.contains(obj.objClass)) {
      _showNoConfigDialog(obj.objClass);
      return;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeColor = isDark ? pvzOrangeDark : pvzOrangeLight;
    showChallengeEditorDialog(
      context,
      object: obj,
      accentColor: themeColor,
      levelFile: widget.levelFile,
      onAddModule: widget.onAddModule,
      onOpenCustomStageSelection: widget.onOpenCustomStageSelection,
      onChanged: () {
        setState(() {
          _saveData();
        });
      },
    );
  }

  void _showNoConfigDialog(String objClass) {
    final l10n = AppLocalizations.of(context)!;
    String title;
    String message;
    switch (objClass) {
      case 'StarChallengeSaveMowersProps':
        title = l10n.starChallengeSaveMowersTitle;
        message = l10n.starChallengeSaveMowersNoConfigMessage;
        break;
      case 'StarChallengePlantFoodNonuseProps':
        title = l10n.starChallengePlantFoodNonuseTitle;
        message = l10n.starChallengePlantFoodNonuseNoConfigMessage;
        break;
      default:
        title = l10n.starChallengeNoConfigTitle;
        message = l10n.starChallengeNoConfigMessage;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Iterable<String> _referencedChallengeRtids() sync* {
    for (final group in _data.challenges) {
      if (group is! Iterable) continue;
      for (final value in group) {
        if (value is String) yield value;
      }
    }
  }

  Future<void> _addChallenge() async {
    final info = await Navigator.push<ChallengeTypeInfo>(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeSelectionScreen(
          stateBucketId:
              'level:${identityHashCode(widget.levelFile)}:challenge',
          onChallengeSelected: (i) => Navigator.pop(context, i),
          onBack: () => Navigator.pop(context),
        ),
      ),
    );

    if (info == null || !mounted) return;

    final l10n = AppLocalizations.of(context);
    final suggestedAlias = ChallengeRepository.suggestUniqueAlias(
      challenge: info,
      levelFile: widget.levelFile,
      referencedRtids: _referencedChallengeRtids(),
    );

    final alias = await showPvzAliasInputDialog(
      context,
      defaultAlias: suggestedAlias,
      title: l10n?.addChallenge ?? 'Add Challenge',
      objClass: info.objClass,
      levelFile: widget.levelFile,
      forCreation: true,
    );
    if (alias == null || !mounted) return;

    Map<String, dynamic> objDataMap = {};
    final objData = info.initialDataFactory?.call();
    if (objData is Map<String, dynamic>) {
      objDataMap = Map<String, dynamic>.from(objData);
    } else if (objData != null) {
      try {
        objDataMap = (objData as dynamic).toJson() as Map<String, dynamic>;
      } catch (_) {
        objDataMap = {};
      }
    }

    final newObj = PvzObject(
      aliases: [alias],
      objClass: info.objClass,
      objData: objDataMap,
    );

    setState(() {
      widget.levelFile.objects.add(newObj);
      _data.challenges[0].add('RTID($alias@CurrentLevel)');
      _saveData();
    });
  }

  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final challenges = _data.challenges.isNotEmpty
        ? _data.challenges[0]
        : <String>[];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeColor = isDark ? pvzOrangeDark : pvzOrangeLight;

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: themeColor,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                isEvent: false,
                title: l10n?.starChallengeHelpTitle ?? 'Star Challenge Module',
                themeColor: themeColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.starChallengeHelpOverview ??
                        'Select challenge modules used in the level here. You can set multiple challenge goals and use the same challenge type multiple times.',
                  ),
                  HelpSectionData(
                    title:
                        l10n?.starChallengeHelpSuggestionTitle ??
                        'Optimization suggestion',
                    body:
                        l10n?.starChallengeHelpSuggestion ??
                        'Some challenges have in-game progress stat boxes. When there are too many challenge modules, stat boxes may overlap.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ModuleAliasInputField(
            rtid: widget.rtid,
            alias: _alias,
            levelFile: widget.levelFile,
            onAliasChanged: _handleAliasChanged,
            onChanged: widget.onChanged,
            accentColor: themeColor,
          ),
          const SizedBox(height: 16),
          if (challenges.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  l10n?.noChallengesConfigured ?? 'No challenges configured',
                ),
              ),
            )
          else
            ...challenges.asMap().entries.map((entry) {
              final index = entry.key;
              final rtid = entry.value;
              final info = RtidParser.parse(rtid);
              final alias = info?.alias ?? rtid;
              final isLocal = info?.source == 'CurrentLevel';

              String? objClass;
              if (isLocal) {
                objClass = widget.levelFile.objects
                    .where((o) => o.aliases?.contains(alias) == true)
                    .firstOrNull
                    ?.objClass;
              } else {
                objClass = ReferenceRepository.instance.getObjClass(alias);
              }

              final meta = ChallengeRepository.getInfo(objClass ?? '');
              final title = objClass != null && objClass.isNotEmpty
                  ? ChallengeRepository.localizedTitle(context, objClass)
                  : (l10n?.unknownChallengeType ?? 'Unknown Challenge');
              final icon = meta?.icon ?? Icons.star_border;

              final challengeIcon = Container(
                key: ValueKey('starChallengeIcon$index'),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                ),
                child: Icon(icon, color: themeColor),
              );
              final identity = Column(
                key: ValueKey('starChallengeIdentity$index'),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    alias,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
              final actions = Row(
                key: ValueKey('starChallengeActions$index'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLocal)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: l10n?.tooltipEdit ?? 'Edit',
                      onPressed: () => _editChallenge(rtid),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: l10n?.delete ?? 'Delete',
                    color: Colors.red,
                    onPressed: () =>
                        _confirmRemoveChallenge(index, rtid, title),
                  ),
                ],
              );

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(16) / 16;
                      final compact =
                          constraints.maxWidth < 460 || textScale > 1.3;
                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                challengeIcon,
                                const SizedBox(width: 12),
                                Expanded(child: identity),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: actions,
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          challengeIcon,
                          const SizedBox(width: 12),
                          Expanded(child: identity),
                          const SizedBox(width: 8),
                          actions,
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          EditorFilledButton(
            onPressed: _addChallenge,
            style: FilledButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n?.addChallenge ?? 'Add Challenge'),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
