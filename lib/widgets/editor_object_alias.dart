import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Resolves a localized event title from its [objClass].
String resolveEventTitleByObjClass(
  BuildContext context,
  String objClass,
  AppLocalizations? l10n,
) {
  return EventSelectionScreen.resolveEventTitleByObjClass(
    context,
    objClass,
    l10n,
  );
}

/// Resolves a localized module title from its [objClass].
String resolveModuleTitleByObjClass(BuildContext context, String objClass) {
  return ModuleRegistry.getMetadata(objClass).getTitle(context);
}

/// App bar title: "Edit {name} event/module" with [objClass] underneath.
Widget buildEditorObjectAppBarTitle({
  required BuildContext context,
  required String localizedName,
  required bool isEvent,
  required String objClass,
  Color? foregroundColor,
}) {
  final theme = Theme.of(context);
  final fg =
      foregroundColor ??
      theme.appBarTheme.foregroundColor ??
      theme.colorScheme.onSurface;
  final titleText = _editorObjectTitleText(
    context: context,
    localizedName: localizedName,
    isEvent: isEvent,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(titleText, overflow: TextOverflow.ellipsis),
      Text(
        objClass,
        style: theme.textTheme.bodySmall?.copyWith(
          color: fg.withValues(alpha: 0.85),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

String _editorObjectTitleText({
  required BuildContext context,
  required String localizedName,
  required bool isEvent,
}) {
  final l10n = AppLocalizations.of(context);
  if (_nameAlreadyIncludesObjectKind(localizedName, isEvent: isEvent)) {
    final edit = l10n?.edit ?? 'Edit';
    final separator = Localizations.localeOf(context).languageCode == 'zh'
        ? ''
        : ' ';
    return '$edit$separator$localizedName';
  }
  return isEvent
      ? (l10n?.editNamedEvent(localizedName) ?? 'Edit $localizedName event')
      : (l10n?.editNamedModule(localizedName) ?? 'Edit $localizedName module');
}

bool _nameAlreadyIncludesObjectKind(
  String localizedName, {
  required bool isEvent,
}) {
  final normalized = localizedName.trim().toLowerCase();
  final suffixes = isEvent
      ? const [
          '\u4e8b\u4ef6',
          'event',
          '\u0441\u043e\u0431\u044b\u0442\u0438\u0435',
        ]
      : const [
          '\u6a21\u5757',
          'module',
          '\u043c\u043e\u0434\u0443\u043b\u044c',
        ];
  return suffixes.any(normalized.endsWith);
}

Color editorObjectAccentColor(BuildContext context, {Color? appBarColor}) {
  if (appBarColor != null) return appBarColor;
  return Theme.of(context).colorScheme.primary;
}

/// Labeled alias field; border/focus uses [accentColor] (app bar color) when set.
class EditorAliasInputField extends StatefulWidget {
  const EditorAliasInputField({
    super.key,
    required this.alias,
    required this.levelFile,
    required this.onAliasChanged,
    this.accentColor,
    this.onChanged,
    this.wrapInCard = true,
  });

  final String alias;
  final PvzLevelFile levelFile;
  final ValueChanged<String> onAliasChanged;
  final Color? accentColor;
  final VoidCallback? onChanged;
  final bool wrapInCard;

  @override
  State<EditorAliasInputField> createState() => _EditorAliasInputFieldState();
}

class _EditorAliasInputFieldState extends State<EditorAliasInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.alias);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(EditorAliasInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alias != widget.alias &&
        _controller.text.trim() != widget.alias) {
      _controller.text = widget.alias;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && mounted) {
      _commit();
    }
  }

  Future<void> _commit() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final next = _controller.text.trim();
    if (next.isEmpty || next == widget.alias) {
      if (mounted) {
        _controller.text = widget.alias;
      }
      return;
    }
    if (!PvzAliasUtils.isAliasAvailable(
      widget.levelFile,
      next,
      excludeAlias: widget.alias,
    )) {
      if (!mounted) return;
      AppMessage.show(
        context,
        l10n?.aliasAlreadyExists ?? 'Alias already exists in this level.',
        icon: Icons.warning_amber_rounded,
      );
      if (mounted) {
        _controller.text = widget.alias;
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.aliasRenameConfirmTitle ?? 'Rename alias?'),
        content: Text(
          l10n?.aliasRenameConfirmMessage(widget.alias, next) ??
              'Rename "${widget.alias}" to "$next"? All references in this level will be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm != true) {
      _controller.text = widget.alias;
      return;
    }
    widget.onAliasChanged(next);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = editorObjectAccentColor(
      context,
      appBarColor: widget.accentColor,
    );
    final isDirty = _controller.text.trim() != widget.alias;
    final aliasLabel = l10n?.aliasLabel ?? 'Alias';
    final labelStyle =
        (theme.inputDecorationTheme.labelStyle ??
                theme.textTheme.bodyLarge ??
                const TextStyle(fontSize: 16))
            .copyWith(
              color: isDirty ? accent : null,
              height: 1.25,
              leadingDistribution: TextLeadingDistribution.even,
            );
    final externalLabelStyle =
        (theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
          color: isDirty ? accent : theme.colorScheme.onSurfaceVariant,
          height: 1.25,
          leadingDistribution: TextLeadingDistribution.even,
        );

    final decoration = InputDecoration(
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isDirty
              ? accent
              : theme.colorScheme.outline.withValues(alpha: 0.5),
          width: isDirty ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent, width: 2),
      ),
      labelStyle: labelStyle,
      floatingLabelStyle: labelStyle,
    );
    final field = EditorResponsiveInputField(
      label: aliasLabel,
      decoration: decoration,
      externalLabelStyle: externalLabelStyle,
      builder: (context, responsiveDecoration) => TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _commit(),
        decoration: responsiveDecoration,
        onChanged: (_) => setState(() {}),
      ),
    );

    if (!widget.wrapInCard) {
      return SizedBox(width: double.infinity, child: field);
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(padding: const EdgeInsets.all(16), child: field),
      ),
    );
  }
}

/// Prompts for an alias when adding an event or module.
Future<String?> showPvzAliasInputDialog(
  BuildContext context, {
  required String defaultAlias,
  required String title,
  required String objClass,
  required PvzLevelFile levelFile,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _PvzAliasInputDialog(
      defaultAlias: defaultAlias,
      title: title,
      objClass: objClass,
      levelFile: levelFile,
    ),
  );
}

class _PvzAliasInputDialog extends StatefulWidget {
  const _PvzAliasInputDialog({
    required this.defaultAlias,
    required this.title,
    required this.objClass,
    required this.levelFile,
  });

  final String defaultAlias;
  final String title;
  final String objClass;
  final PvzLevelFile levelFile;

  @override
  State<_PvzAliasInputDialog> createState() => _PvzAliasInputDialogState();
}

class _PvzAliasInputDialogState extends State<_PvzAliasInputDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultAlias);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final alias = _controller.text.trim();
    if (alias.isEmpty ||
        !PvzAliasUtils.isAliasAvailable(widget.levelFile, alias)) {
      setState(
        () => _errorText =
            l10n?.aliasAlreadyExists ?? 'Alias already exists in this level.',
      );
      return;
    }
    Navigator.pop(context, alias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Tight width so AlertDialog's IntrinsicWidth does not measure children.
    // EditorResponsiveInputField uses LayoutBuilder, which cannot report
    // intrinsic dimensions (see Flutter LayoutBuilder docs).
    return AlertDialog(
      scrollable: true,
      constraints: const BoxConstraints.tightFor(width: 400),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.objClass,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          EditorResponsiveInputField(
            label: l10n?.aliasLabel ?? 'Alias',
            decoration: InputDecoration(errorText: _errorText),
            builder: (context, decoration) => TextField(
              controller: _controller,
              autofocus: true,
              decoration: decoration,
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n?.add ?? 'Add')),
      ],
    );
  }
}

/// Commits an alias rename for a level object referenced by [rtid].
void renameLevelObjectAlias({
  required PvzLevelFile levelFile,
  required String oldAlias,
  required String newAlias,
  String source = 'CurrentLevel',
  required VoidCallback onChanged,
}) {
  PvzAliasUtils.renameAlias(
    levelFile: levelFile,
    oldAlias: oldAlias,
    newAlias: newAlias,
    source: source,
  );
  onChanged();
}

String aliasFromRtid(String rtid) {
  return RtidParser.parse(rtid)?.alias ?? rtid;
}

bool isLevelModulesRtid(String rtid) {
  return RtidParser.parse(rtid)?.source == 'LevelModules';
}

/// Whether the alias editor should appear for a module screen.
bool moduleAliasFieldVisible({
  required String rtid,
  bool requiresCustomLocal = false,
  bool customLocalEnabled = true,
}) {
  if (isLevelModulesRtid(rtid)) return false;
  if (requiresCustomLocal && !customLocalEnabled) return false;
  return true;
}

/// Alias field for module editors. Hidden for `@LevelModules` references and,
/// when [requiresCustomLocal] is set, until custom local overrides are enabled.
class ModuleAliasInputField extends StatelessWidget {
  const ModuleAliasInputField({
    super.key,
    required this.rtid,
    required this.alias,
    required this.levelFile,
    required this.onAliasChanged,
    this.accentColor,
    this.onChanged,
    this.wrapInCard = true,
    this.requiresCustomLocal = false,
    this.customLocalEnabled = true,
  });

  final String rtid;
  final String alias;
  final PvzLevelFile levelFile;
  final ValueChanged<String> onAliasChanged;
  final Color? accentColor;
  final VoidCallback? onChanged;
  final bool wrapInCard;
  final bool requiresCustomLocal;
  final bool customLocalEnabled;

  @override
  Widget build(BuildContext context) {
    if (!moduleAliasFieldVisible(
      rtid: rtid,
      requiresCustomLocal: requiresCustomLocal,
      customLocalEnabled: customLocalEnabled,
    )) {
      return const SizedBox.shrink();
    }
    return EditorAliasInputField(
      alias: alias,
      levelFile: levelFile,
      onAliasChanged: onAliasChanged,
      accentColor: accentColor,
      onChanged: onChanged,
      wrapInCard: wrapInCard,
    );
  }
}

int _findModuleIndex({
  required LevelDefinitionData levelDef,
  required String currentRtid,
  required String currentAlias,
  required String defaultAlias,
}) {
  var index = levelDef.modules.indexWhere((rtid) => rtid == currentRtid);
  if (index != -1) return index;
  return levelDef.modules.indexWhere((rtid) {
    final alias = RtidParser.parse(rtid)?.alias ?? '';
    return alias == currentAlias || alias == defaultAlias;
  });
}

/// Switches a toggleable module back to its built-in `@LevelModules` reference.
String revertToggleableModuleToLevelModules({
  required PvzLevelFile levelFile,
  required LevelDefinitionData levelDef,
  required String currentRtid,
  required String currentAlias,
  required String defaultAlias,
  required VoidCallback onAliasUpdated,
}) {
  final moduleIndex = _findModuleIndex(
    levelDef: levelDef,
    currentRtid: currentRtid,
    currentAlias: currentAlias,
    defaultAlias: defaultAlias,
  );

  var alias = currentAlias;
  if (alias != defaultAlias) {
    renameLevelObjectAlias(
      levelFile: levelFile,
      oldAlias: alias,
      newAlias: defaultAlias,
      onChanged: () {},
    );
    alias = defaultAlias;
    onAliasUpdated();
  }

  levelFile.objects.removeWhere(
    (o) => o.aliases?.contains(defaultAlias) == true,
  );

  final newRtid = RtidParser.build(defaultAlias, 'LevelModules');
  if (moduleIndex != -1) {
    levelDef.modules[moduleIndex] = newRtid;
  } else {
    levelDef.modules.add(newRtid);
  }

  final levelDefObj = levelFile.objects.firstWhereOrNull(
    (o) => o.objClass == 'LevelDefinition',
  );
  if (levelDefObj != null) {
    levelDefObj.objData = levelDef.toJson();
  }
  return newRtid;
}

/// Enables custom `@CurrentLevel` overrides for a toggleable module.
String enableToggleableModuleCustomLevel({
  required PvzLevelFile levelFile,
  required LevelDefinitionData levelDef,
  required String currentRtid,
  required String currentAlias,
  required String defaultAlias,
  required String objClass,
  required Map<String, dynamic> objData,
}) {
  final moduleIndex = _findModuleIndex(
    levelDef: levelDef,
    currentRtid: currentRtid,
    currentAlias: currentAlias,
    defaultAlias: defaultAlias,
  );

  final alias = currentAlias.isEmpty ? defaultAlias : currentAlias;
  final newRtid = RtidParser.build(alias, 'CurrentLevel');
  if (moduleIndex != -1) {
    levelDef.modules[moduleIndex] = newRtid;
  } else {
    levelDef.modules.add(newRtid);
  }

  final existing = levelFile.objects.firstWhereOrNull(
    (o) => o.aliases?.contains(alias) == true,
  );
  if (existing == null) {
    levelFile.objects.add(
      PvzObject(aliases: [alias], objClass: objClass, objData: objData),
    );
  } else {
    existing.objData = objData;
  }

  final levelDefObj = levelFile.objects.firstWhereOrNull(
    (o) => o.objClass == 'LevelDefinition',
  );
  if (levelDefObj != null) {
    levelDefObj.objData = levelDef.toJson();
  }
  return newRtid;
}
