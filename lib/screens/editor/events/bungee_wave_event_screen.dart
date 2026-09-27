import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/theme/app_theme.dart'
    show pvzLightOrangeDark, pvzLightOrangeLight;

/// Bungee drop event: set zombie type, level, and lawn cell for one bungee drop.
/// Ported from Z-Editor-master BungeeWaveActionEP.kt
class BungeeWaveEventScreen extends StatefulWidget {
  const BungeeWaveEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<BungeeWaveEventScreen> createState() => _BungeeWaveEventScreenState();
}

class _BungeeWaveEventScreenState extends State<BungeeWaveEventScreen> {
  static const _objClass = 'BungeeWaveActionProps';

  late PvzObject _moduleObj;
  late BungeeWaveActionData _data;
  late String _alias;

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: BungeeWaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = BungeeWaveActionData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = BungeeWaveActionData();
    }
    // Default to tutorial zombie when none selected (or legacy wrong alias).
    if (_data.zombieName.isEmpty || _data.zombieName == 'zombie_tutorial') {
      final alias = ZombieRepository().buildZombieAliases('tutorial');
      _data = BungeeWaveActionData(
        target: _data.target,
        zombieName: alias,
        level: _data.level,
      );
      _moduleObj.objData = _data.toJson();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
    }
    // Clamp target to current grid
    final tx = _data.target.mX.clamp(0, _gridCols - 1);
    final ty = _data.target.mY.clamp(0, _gridRows - 1);
    if (tx != _data.target.mX || ty != _data.target.mY) {
      _data = BungeeWaveActionData(
        target: BungeeWaveTargetData(mX: tx, mY: ty),
        zombieName: _data.zombieName,
        level: _data.level,
      );
      _moduleObj.objData = _data.toJson();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _setTarget(int col, int row) {
    _data = BungeeWaveActionData(
      target: BungeeWaveTargetData(mX: col, mY: row),
      zombieName: _data.zombieName,
      level: _data.level,
    );
    _sync();
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarColor = isDark ? pvzLightOrangeDark : pvzLightOrangeLight;
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.bungeeWaveEventHelpTitle ?? 'Bungee drop event',
              themeColor: appBarColor,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.bungeeWaveEventHelpOverview ??
                      'Set the zombie type and lawn cell for a single bungee drop. One event drops one zombie.',
                ),
                HelpSectionData(
                  title: l10n?.bungeeWaveEventHelpGrid ?? 'Grid',
                  body:
                      l10n?.bungeeWaveEventHelpGridBody ??
                      'Tap a cell in the grid to set where the bungee zombie will land.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
                accentColor: appBarColor,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorResponsiveFieldRow(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.bungeeWaveCurrentTarget ??
                                    'Current target',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${l10n?.bungeeWaveCol ?? 'Col'} ${_data.target.mX + 1}, ${l10n?.bungeeWaveRow ?? 'Row'} ${_data.target.mY + 1}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: appBarColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '(X: ${_data.target.mX}, Y: ${_data.target.mY})',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildGrid(theme, appBarColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.bungeeWavePropertiesConfig ?? 'Properties',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appBarColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildZombieSelector(theme, appBarColor, l10n),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label:
                            l10n?.bungeeWaveZombieLevel ??
                            'Zombie level (Level)',
                        decoration: editorInputDecoration(
                          context,

                          focusColor: appBarColor,
                        ),
                        builder: (context, decoration) =>
                            DropdownButtonFormField<int>(
                              key: const ValueKey('bungeeZombieLevel'),
                              initialValue: _data.level.clamp(0, 10),
                              isExpanded: true,
                              items: List.generate(
                                11,
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text('$level'),
                                ),
                              ),
                              decoration: decoration,
                              onChanged: (level) {
                                if (level != null) {
                                  _data = BungeeWaveActionData(
                                    target: _data.target,
                                    zombieName: _data.zombieName,
                                    level: level,
                                  );
                                  _sync();
                                }
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EditorWarningBanner(
                margin: EdgeInsets.zero,
                message:
                    l10n?.bungeeWaveRoofWarning ??
                    'On roof maps, bungee drops intercepted by umbrellas may trigger instant brain-eating. Use with care.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme, Color appBarColor) {
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF403A33)
                  : const Color(0xFFFFF9EF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: appBarColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected =
                          _data.target.mX == col && _data.target.mY == row;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _setTarget(col, row),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? appBarColor.withValues(alpha: 0.35)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? appBarColor
                                    : appBarColor.withValues(alpha: 0.4),
                                width: 0.5,
                              ),
                            ),
                            child: isSelected && _data.zombieName.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: _ZombieIconSmall(_data.zombieName),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZombieSelector(
    ThemeData theme,
    Color appBarColor,
    AppLocalizations? l10n,
  ) {
    final typeId = ZombiePropertiesRepository.getTypeNameByAlias(
      _data.zombieName,
    );
    final info =
        ZombieRepository().getZombieById(typeId) ??
        ZombieRepository().getZombieById(typeId.replaceAll('_elite', ''));
    final path = info?.icon != null
        ? 'assets/images/zombies/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    final nameKey = ZombieRepository().getName(typeId);
    final name = ResourceNames.lookup(context, nameKey);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          widget.onRequestZombieSelection((selectedId) {
            final alias = ZombieRepository().buildZombieAliases(selectedId);
            _data = BungeeWaveActionData(
              target: _data.target,
              zombieName: alias,
              level: _data.level,
            );
            _sync();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AssetImageWidget(
                  assetPath: path,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  altCandidates: imageAltCandidates(path),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _data.zombieName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZombieIconSmall extends StatelessWidget {
  const _ZombieIconSmall(this.typeName);

  final String typeName;

  @override
  Widget build(BuildContext context) {
    final typeId = ZombiePropertiesRepository.getTypeNameByAlias(typeName);
    final info =
        ZombieRepository().getZombieById(typeId) ??
        ZombieRepository().getZombieById(typeId.replaceAll('_elite', ''));
    final path = info?.icon != null
        ? 'assets/images/zombies/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AssetImageWidget(
        assetPath: path,
        fit: BoxFit.cover,
        width: 32,
        height: 32,
        altCandidates: imageAltCandidates(path),
      ),
    );
  }
}
