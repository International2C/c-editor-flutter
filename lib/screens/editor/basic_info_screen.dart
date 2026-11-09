import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/music_type_catalog.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/narrative_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';

const _lootOptions = [
  'RTID(DefaultLoot@LevelModules)',
  'RTID(NoLoot@LevelModules)',
];
const _victoryOptions = [
  'RTID(VictoryOutro@LevelModules)',
  'RTID(ZombossVictoryOutro@LevelModules)',
];

String _lootOptionLabel(AppLocalizations? l10n, String value) =>
    switch (value) {
      'RTID(NoLoot@LevelModules)' => l10n?.lootOptionNone ?? 'No Loot (NoLoot)',
      _ => l10n?.lootOptionDefault ?? 'Default Loot (DefaultLoot)',
    };

String _victoryOptionLabel(AppLocalizations? l10n, String value) =>
    switch (value) {
      'RTID(ZombossVictoryOutro@LevelModules)' =>
        l10n?.victoryOptionZomboss ??
            'Zomboss Battle Victory (ZombossVictoryOutro)',
      _ => l10n?.victoryOptionDefault ?? 'Default Victory (VictoryOutro)',
    };

class _BasicInfoEscapeIntent extends Intent {
  const _BasicInfoEscapeIntent();
}

/// Full-screen level basic info editor. Ported from Z-Editor-master LevelDefinitionEP.kt
class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({
    super.key,
    required this.levelFile,
    required this.levelDef,
    required this.onBack,
    required this.onStageTap,
    required this.onChanged,
  });

  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onBack;
  final Future<void> Function(
    LevelDefinitionData levelDef,
    VoidCallback onStagePicked,
  )?
  onStageTap;
  final VoidCallback onChanged;

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _levelNumCtrl;
  late TextEditingController _sunCtrl;
  Future<NarrativeCatalog>? _narrativeCatalogFuture;
  Locale? _narrativeLocale;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.levelDef.name);
    _descCtrl = TextEditingController(text: widget.levelDef.description);
    _levelNumCtrl = TextEditingController(
      text: '${widget.levelDef.levelNumber ?? 1}',
    );
    _sunCtrl = TextEditingController(
      text: '${widget.levelDef.startingSun ?? 200}',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _levelNumCtrl.dispose();
    _sunCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_narrativeLocale == locale) return;
    _narrativeLocale = locale;
    _narrativeCatalogFuture = NarrativeCatalog.load(locale);
  }

  Widget _rectangularTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    required VoidCallback onChanged,
  }) {
    final focusColor = Theme.of(context).colorScheme.primary;
    return EditorResponsiveInputField(
      label: label,
      decoration: editorInputDecoration(context, focusColor: focusColor),
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.top,
        decoration: decoration,
        onChanged: (_) => onChanged(),
      ),
    );
  }

  void _sync() {
    final def = widget.levelDef;
    def.name = _nameCtrl.text;
    def.description = _descCtrl.text;
    def.levelNumber = int.tryParse(_levelNumCtrl.text) ?? 1;
    def.startingSun = int.tryParse(_sunCtrl.text) ?? 200;
    _writeLevelDefinition();
    widget.onChanged();
  }

  void _writeLevelDefinition() {
    LevelParser.syncAndWriteLevelDefinition(widget.levelDef, widget.levelFile);
  }

  bool _resetMissingCustomStageReference() {
    final def = widget.levelDef;
    if (!CustomStageLevelUtils.isCustomStageRtid(def.stageModule)) {
      return false;
    }
    final stageInfo = RtidParser.parse(def.stageModule);
    if (stageInfo == null) return false;
    final stageObj = CustomStageLevelUtils.findStageObject(
      widget.levelFile,
      stageInfo.alias,
    );
    if (stageObj != null) return false;

    def.stageModule = CustomStageLevelUtils.defaultBuiltinStageRtid;
    _writeLevelDefinition();
    widget.onChanged();
    return true;
  }

  Future<void> _openStageSelection(LevelDefinitionData def) async {
    final onStageTap = widget.onStageTap;
    if (onStageTap == null) return;
    await onStageTap(def, () {
      if (mounted) setState(() {});
    });
    if (!mounted) return;
    _resetMissingCustomStageReference();
    setState(() {});
  }

  Future<void> _openNarrativeSelection(
    NarrativeCatalog catalog, {
    required bool intro,
  }) async {
    final def = widget.levelDef;
    final currentValue = intro
        ? def.firstIntroNarrative
        : def.firstOutroNarrative;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (routeContext) => NarrativeSelectionScreen(
          catalog: catalog,
          currentValue: currentValue,
          stateBucketId: 'level:${identityHashCode(widget.levelFile)}',
          onSelected: (value) {
            Navigator.of(routeContext).pop();
            if (!mounted) return;
            setState(() {
              if (intro) {
                def.firstIntroNarrative = value;
              } else {
                def.firstOutroNarrative = value;
              }
              _writeLevelDefinition();
              widget.onChanged();
            });
          },
        ),
      ),
    );
  }

  Widget _narrativeSettingCard(
    BuildContext context, {
    required NarrativeCatalog catalog,
    required String label,
    required String fieldName,
    required Object? value,
    required bool intro,
  }) {
    final theme = Theme.of(context);
    final entry = catalog.findByValue(value);
    final displayTitle = value == null
        ? catalog.strings.noDialogue
        : entry?.title ?? value.toString();
    final iconAsset = entry != null
        ? catalog.displayIcon(entry)
        : value != null
        ? 'assets/images/others/unknown.webp'
        : null;

    return Card(
      key: ValueKey('narrative-setting-$fieldName'),
      child: InkWell(
        onTap: () => _openNarrativeSelection(catalog, intro: intro),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: iconAsset == null
                      ? ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            value == null
                                ? Icons.chat_bubble_outline
                                : Icons.help_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : AssetImageWidget(
                          assetPath: iconAsset,
                          altCandidates: imageAltCandidates(iconAsset),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label ($fieldName)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(displayTitle, style: theme.textTheme.titleMedium),
                    if (entry != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final def = widget.levelDef;
    final theme = Theme.of(context);
    final stageInfo = RtidParser.parse(def.stageModule);
    final isCustomStage = CustomStageLevelUtils.isCustomStageRtid(
      def.stageModule,
    );
    PvzObject? customStageObj;
    Map<String, dynamic>? customStageData;
    if (isCustomStage && stageInfo != null) {
      customStageObj = CustomStageLevelUtils.findStageObject(
        widget.levelFile,
        stageInfo.alias,
      );
      if (customStageObj?.objData is Map) {
        customStageData = Map<String, dynamic>.from(
          customStageObj!.objData as Map,
        );
      }
    }
    final stageObjdata =
        customStageData ??
        LevelParser.resolveStageObjdata(def, widget.levelFile);
    final stageMusicSuffix = stageObjdata?['MusicSuffix'];
    final musicSuffix = stageMusicSuffix is String
        ? stageMusicSuffix
        : def.musicSuffix;
    final musicModule = MusicTypeCatalog.forSuffix(musicSuffix);
    final currentMusicType = def.musicType.isEmpty
        ? MusicTypeCatalog.mainPath
        : def.musicType;
    final musicTypeChoices =
        musicModule?.choices ??
        MusicTypeCatalog.fallbackChoicesForSuffix(musicSuffix);
    final displayMusicSuffix = musicModule?.suffix ?? musicSuffix.trim();
    final musicSuffixName = displayMusicSuffix.isEmpty
        ? '—'
        : ResourceNames.lookupOrFallback(
            context,
            musicModule?.suffixNameKey ??
                MusicSuffixCatalog.resourceKey(displayMusicSuffix),
            displayMusicSuffix,
          );
    String localizedMusicTypeLabel(MusicTypeChoice choice) =>
        ResourceNames.lookupOrFallback(
          context,
          choice.labelKey,
          choice.labelKey.startsWith('musicSuffix_')
              ? musicSuffixName
              : choice.value,
        );
    String? musicTypeSubtitle(MusicTypeChoice choice) {
      final label = localizedMusicTypeLabel(choice);
      return label == choice.value ? null : choice.value;
    }

    String musicTypeFieldLabel(MusicTypeChoice choice) {
      final label = localizedMusicTypeLabel(choice);
      return label == choice.value ? label : '$label (${choice.value})';
    }

    final musicSuffixCode = displayMusicSuffix.isEmpty
        ? '—'
        : displayMusicSuffix;
    final musicSuffixIconAsset = MusicSuffixCatalog.iconAsset(
      displayMusicSuffix,
    );
    final musicPickerHeader = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AssetImageWidget(
            assetPath: musicSuffixIconAsset,
            altCandidates: imageAltCandidates(musicSuffixIconAsset),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n?.currentMusicModule ?? 'Current music module'} '
                '(MusicSuffix)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                musicSuffixName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                musicSuffixCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final musicPickerNotes = [
      for (final noteKey in musicModule?.noteKeys ?? const <String>[])
        ResourceNames.lookupOrFallback(context, noteKey, ''),
    ];
    final customStageOrigin = customStageObj == null
        ? null
        : CustomStagePresetRepository.originForObject(customStageObj);
    final customSuffix =
        l10n?.customStageNameSuffix ??
        CustomStageLevelUtils.displayNameSuffixDefault;
    final isDesktop =
        theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.linux;
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    Widget scaffold = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.levelBasicInfo ?? 'Level basic info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () async {
              final catalog = await _narrativeCatalogFuture!;
              if (!mounted || !context.mounted) return;
              showEditorHelpDialog(
                context,
                title:
                    l10n?.levelBasicInfoHelpTitle ?? 'Level Definition Basics',
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.levelBasicInfoHelpOverviewBody ??
                        'The level definition is the root node of a PvZ2 level. '
                            "It stores the level's global properties and links to "
                            'every module in the level through its module list. '
                            "This page lets you edit the level's global properties.",
                  ),
                  HelpSectionData(
                    title:
                        l10n?.levelBasicInfoHelpBasicInfoTitle ??
                        'Basic Information Screen',
                    body:
                        l10n?.levelBasicInfoHelpBasicInfoBody ??
                        'Here you can define basic information such as the level '
                            'name, description, and starting sun. The level '
                            'description appears as white subtitle text during the '
                            'transition into the level. Starting sun is the amount '
                            "available before the account's sun upgrade is applied.",
                  ),
                  HelpSectionData(
                    title: l10n?.sceneSettingsSection ?? 'Scene settings',
                    body:
                        l10n?.levelBasicInfoHelpSceneBody ??
                        "Here you can choose scene information such as the level's "
                            'lawn and music type from the list. The Pirate Seas '
                            'lawn has no planks by default.\n'
                            "The available music types depend on the lawn's default "
                            'music module. After customizing the lawn, you can '
                            'change its music module to use music from other lawns '
                            'in the level.\n'
                            'The settlement setting only applies to certain special '
                            'level types and generally should not be changed.',
                  ),
                  HelpSectionData(
                    title: catalog.strings.sectionTitle,
                    body: catalog.strings.helpBody,
                  ),
                  HelpSectionData(
                    title: l10n?.restrictionsSection ?? 'Restrictions',
                    body:
                        l10n?.levelBasicInfoHelpRestrictionsBody ??
                        'This section provides switches for disabling Pea '
                            "Symbiosis and Artifacts. Pea Symbiosis is Pea Vine's "
                            'Level 5 ability. If a player owns a Level 5 Pea Vine '
                            'and enables the ability, planting a pea plant also '
                            'plants a Pea Vine and may affect the intended level '
                            'experience. In Creative Courtyard levels, Artifacts '
                            'are disabled automatically.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n?.basicInfoSection ?? 'Basic info', style: sectionStyle),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _rectangularTextField(
                      context,
                      controller: _nameCtrl,
                      label: '${l10n?.name ?? 'Name'} (Name)',
                      onChanged: _sync,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _rectangularTextField(
                            context,
                            controller: _levelNumCtrl,
                            label: l10n?.levelNumber ?? 'Level number',
                            keyboardType: TextInputType.number,
                            onChanged: _sync,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _rectangularTextField(
                            context,
                            controller: _sunCtrl,
                            label: l10n?.startingSun ?? 'Initial sun',
                            keyboardType: TextInputType.number,
                            onChanged: _sync,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _rectangularTextField(
                      context,
                      controller: _descCtrl,
                      label:
                          '${l10n?.description ?? 'Description'} (Description)',
                      maxLines: 2,
                      onChanged: _sync,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.sceneSettingsSection ?? 'Scene settings',
              style: sectionStyle,
            ),
            const SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: () => _openStageSelection(def),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: () {
                            if (stageInfo == null) {
                              return const AssetImageWidget(
                                assetPath: 'assets/images/others/unknown.webp',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              );
                            }
                            if (isCustomStage && customStageData != null) {
                              final iconFile =
                                  CustomStageLevelUtils.displayIconFileName(
                                    objclass: customStageObj!.objClass,
                                    objdata: customStageData,
                                  );
                              final iconPath = iconFile == null
                                  ? 'assets/images/others/unknown.webp'
                                  : 'assets/images/round_icons/$iconFile';
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  AssetImageWidget(
                                    assetPath: iconPath,
                                    altCandidates: imageAltCandidates(iconPath),
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: _CurrentCustomStageBadge(
                                      origin:
                                          customStageOrigin ??
                                          CustomStageOrigin.userCreated,
                                    ),
                                  ),
                                ],
                              );
                            }
                            final stageItem = StageRepository.allItems
                                .where((s) => s.alias == stageInfo.alias)
                                .firstOrNull;
                            final iconName = stageItem?.iconName;
                            if (iconName != null) {
                              return AssetImageWidget(
                                assetPath:
                                    'assets/images/round_icons/$iconName',
                                altCandidates: imageAltCandidates(
                                  'assets/images/round_icons/$iconName',
                                ),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              );
                            }
                            return const AssetImageWidget(
                              assetPath: 'assets/images/others/unknown.webp',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            );
                          }(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l10n?.stageModule ?? 'Stage module'} (StageModule)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(() {
                              if (stageInfo == null) return def.stageModule;
                              if (isCustomStage && customStageData != null) {
                                final nameKey =
                                    CustomStageLevelUtils.displayStageBaseNameKey(
                                      objclass: customStageObj!.objClass,
                                      objdata: customStageData,
                                    );
                                if (nameKey.isNotEmpty) {
                                  return '${ResourceNames.lookup(context, nameKey)}$customSuffix';
                                }
                                return '${stageInfo.alias}$customSuffix';
                              }
                              return ResourceNames.lookup(
                                context,
                                StageRepository.getName(stageInfo.alias),
                              );
                            }(), style: theme.textTheme.titleMedium),
                            if (stageInfo != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${stageInfo.alias}@${stageInfo.source}',
                                softWrap: true,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SeparatedOptionPickerField<String>(
                  labelText: '${l10n?.musicType ?? 'Music type'} (MusicType)',
                  sheetTitle:
                      '${l10n?.currentMusicModule ?? 'Current music module'} '
                      '(MusicSuffix)',
                  sheetHeader: musicPickerHeader,
                  sheetSubtitleLines: musicPickerNotes,
                  value: currentMusicType,
                  fallbackLabel: currentMusicType,
                  selectedTextStyle: theme.textTheme.titleMedium,
                  items: [
                    for (final choice in musicTypeChoices)
                      SeparatedOptionPickerItem(
                        value: choice.value,
                        label: localizedMusicTypeLabel(choice),
                        subtitle: musicTypeSubtitle(choice),
                        fieldLabel: musicTypeFieldLabel(choice),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      def.musicType = value;
                      _sync();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EditorResponsiveInputField(
                  label: '${l10n?.loot ?? 'Loot'} (Loot)',
                  decoration: editorInputDecoration(
                    context,
                    focusColor: theme.colorScheme.primary,
                  ),
                  builder: (context, decoration) =>
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _lootOptions.contains(def.loot)
                            ? def.loot
                            : _lootOptions.first,
                        decoration: decoration,
                        items: _lootOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(_lootOptionLabel(l10n, e)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              def.loot = v;
                              _sync();
                            });
                          }
                        },
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EditorResponsiveInputField(
                  label:
                      '${l10n?.victoryModule ?? 'Victory module'} (VictoryModule)',
                  decoration: editorInputDecoration(
                    context,
                    focusColor: theme.colorScheme.primary,
                  ),
                  builder: (context, decoration) =>
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue:
                            _victoryOptions.contains(def.victoryModule)
                            ? def.victoryModule
                            : _victoryOptions.first,
                        decoration: decoration,
                        items: _victoryOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(_victoryOptionLabel(l10n, e)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              def.victoryModule = v;
                              _sync();
                            });
                          }
                        },
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            EditorWarningBanner(
              margin: EdgeInsets.zero,
              message:
                  l10n?.victoryModuleWarning ??
                  'Using non-default victory modules may cause level crashes due to module conflicts. Use with caution.',
            ),
            const SizedBox(height: 24),
            FutureBuilder<NarrativeCatalog>(
              future: _narrativeCatalogFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final catalog = snapshot.requireData;
                return Column(
                  key: const ValueKey('narrative-settings-section'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(catalog.strings.sectionTitle, style: sectionStyle),
                    const SizedBox(height: 12),
                    _narrativeSettingCard(
                      context,
                      catalog: catalog,
                      label: catalog.strings.firstIntro,
                      fieldName: 'FirstIntroNarrative',
                      value: def.firstIntroNarrative,
                      intro: true,
                    ),
                    _narrativeSettingCard(
                      context,
                      catalog: catalog,
                      label: catalog.strings.firstOutro,
                      fieldName: 'FirstOutroNarrative',
                      value: def.firstOutroNarrative,
                      intro: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            Text(
              l10n?.restrictionsSection ?? 'Restrictions',
              style: sectionStyle,
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: Text(
                  l10n?.disablePeavine ?? 'Disable peavine',
                  style: theme.textTheme.bodyMedium,
                ),
                value: def.disablePeavine ?? false,
                onChanged: (v) {
                  setState(() {
                    def.disablePeavine = v;
                    _sync();
                  });
                },
              ),
            ),
            Card(
              child: SwitchListTile(
                title: Text(
                  l10n?.disableArtifact ?? 'Disable artifact',
                  style: theme.textTheme.bodyMedium,
                ),
                value: def.isArtifactDisabled ?? false,
                onChanged: (v) {
                  setState(() {
                    def.isArtifactDisabled = v;
                    _sync();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      scaffold = Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): _BasicInfoEscapeIntent(),
        },
        child: Actions(
          actions: {
            _BasicInfoEscapeIntent: CallbackAction<_BasicInfoEscapeIntent>(
              onInvoke: (_) {
                widget.onBack();
                return null;
              },
            ),
          },
          child: scaffold,
        ),
      );
    }
    return scaffold;
  }
}

class _CurrentCustomStageBadge extends StatelessWidget {
  const _CurrentCustomStageBadge({required this.origin});

  final CustomStageOrigin origin;

  @override
  Widget build(BuildContext context) {
    return CustomResourceBadge(color: _badgeColor(context));
  }

  Color _badgeColor(BuildContext context) {
    return switch (origin) {
      CustomStageOrigin.presetTemplate => presetCustomResourceBadgeColor(
        context,
      ),
      CustomStageOrigin.presetDerived => presetDerivedCustomResourceBadgeColor(
        context,
      ),
      CustomStageOrigin.userCreated => userCustomResourceBadgeColor(context),
    };
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
