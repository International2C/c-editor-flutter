import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

const String _kUnknownIconPath = 'assets/images/others/unknown.webp';

/// Amber accent for the "Seeing Stars" minigame (dark / light theme).
const Color _kSeeingStarsAccentDark = Color(0xFFE0A72E);
const Color _kSeeingStarsAccentLight = Color(0xFFB8860B);

/// Editor for the PVZ1 "Seeing Stars" minigame module: a lawn pattern of
/// plants that wins the level once complete, a wave loop index and a
/// settlement delay.
class PVZ1SeeingStarsModuleScreen extends StatefulWidget {
  const PVZ1SeeingStarsModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;

  @override
  State<PVZ1SeeingStarsModuleScreen> createState() =>
      _PVZ1SeeingStarsModuleScreenState();
}

class _PVZ1SeeingStarsModuleScreenState
    extends State<PVZ1SeeingStarsModuleScreen> {
  static const _objClass = LevelIssueRegistry.seeingStarsModule;

  late String _alias;
  late PvzObject _moduleObj;
  late PVZ1SeeingStarsModulePropertiesData _data;
  late TextEditingController _cycleIndexCtrl;
  late TextEditingController _settlementCtrl;
  late FocusNode _cycleIndexFocus;
  late FocusNode _settlementFocus;
  int _selectedX = 0;
  int _selectedY = 0;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadRegistryData();
    _loadData();
    _cycleIndexFocus = FocusNode()..addListener(() => setState(() {}));
    _settlementFocus = FocusNode()..addListener(() => setState(() {}));
    _cycleIndexCtrl = TextEditingController(text: '${_data.cycleIndex}');
    _settlementCtrl = TextEditingController(
      text: _formatDouble(_data.settlementDuration),
    );
  }

  Future<void> _loadRegistryData() async {
    await Future.wait<void>([
      PlantRepository().init(),
      ResourceNames.ensureLoaded(),
    ]);
    if (mounted) setState(() {});
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
        objData: PVZ1SeeingStarsModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PVZ1SeeingStarsModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PVZ1SeeingStarsModulePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  static String _formatDouble(double v) {
    if (v == v.roundToDouble()) return '${v.toInt()}';
    final s = v.toStringAsFixed(4);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  void _addPlant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantSelectionScreen(
          isMultiSelect: false,
          onPlantSelected: (id) {
            Navigator.pop(context);
            _data.matchPlants
              ..removeWhere(
                (e) => e.gridX == _selectedX && e.gridY == _selectedY,
              )
              ..add(
                SeeingStarsMatchPlantData(
                  gridX: _selectedX,
                  gridY: _selectedY,
                  matchTypeName: id,
                ),
              );
            _sync();
          },
          onBack: () => Navigator.pop(context),
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
        ),
      ),
    );
  }

  void _removePlant(SeeingStarsMatchPlantData plant) {
    _data.matchPlants.remove(plant);
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
  void dispose() {
    _cycleIndexCtrl.dispose();
    _settlementCtrl.dispose();
    _cycleIndexFocus.dispose();
    _settlementFocus.dispose();
    super.dispose();
  }

  void _showHelp(BuildContext context, AppLocalizations l10n, Color accent) {
    showEditorHelpDialog(
      context,
      isEvent: false,
      title: l10n.pvz1SeeingStarsModuleTitle,
      themeColor: accent,
      sections: [
        HelpSectionData(
          title: l10n.overview,
          body: l10n.pvz1SeeingStarsHelpOverview,
        ),
        HelpSectionData(
          title: l10n.pvz1SeeingStarsHelpFieldsTitle,
          body:
              '${l10n.pvz1SeeingStarsSectionMatchPlants}\n'
              '${l10n.pvz1SeeingStarsHelpMatchPlants}\n\n'
              '${l10n.pvz1SeeingStarsFieldCycleIndexLabel}\n'
              '${l10n.pvz1SeeingStarsHelpCycleIndex}\n\n'
              '${l10n.pvz1SeeingStarsFieldSettlementDurationLabel}\n'
              '${l10n.pvz1SeeingStarsHelpSettlementDuration}',
        ),
        HelpSectionData(
          title: l10n.pvz1SeeingStarsHelpTipsTitle,
          body: l10n.pvz1SeeingStarsHelpWinCon,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? _kSeeingStarsAccentDark : _kSeeingStarsAccentLight;
    final onAccent =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final sorted = List<SeeingStarsMatchPlantData>.from(_data.matchPlants)
      ..sort((a, b) {
        final c = a.gridY.compareTo(b.gridY);
        return c != 0 ? c : a.gridX.compareTo(b.gridX);
      });
    final warnings = LevelIssueRegistry.forLevel(context, widget.levelFile)
        .where(
          (w) =>
              w.id == 'seeingStarsWinConWarning' ||
              w.id == 'seeingStarsCompatibilityWarning',
        );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: widget.onBack,
        ),
        backgroundColor: accent,
        foregroundColor: onAccent,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: onAccent,
        ),
        actions: [
          IconButton(
            key: const ValueKey('seeingStarsHelpButton'),
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tooltipAboutModule,
            onPressed: () => _showHelp(context, l10n, accent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            for (final warning in warnings) ...[
              const SizedBox(height: 16),
              EditorWarningBanner(
                key: ValueKey(warning.id),
                margin: EdgeInsets.zero,
                title: warning.title,
                message: warning.message,
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    EditorResponsiveActionRow(
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.selectedPosition,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'R${_selectedY + 1} : C${_selectedX + 1}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      action: EditorFilledButton(
                        key: const ValueKey('seeingStarsAddPlantButton'),
                        onPressed: _addPlant,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.addPlant),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGrid(theme, accent),
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
                      l10n.pvz1SeeingStarsSectionParams,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Tooltip(
                      message: l10n.pvz1SeeingStarsHelpCycleIndex,
                      child: EditorResponsiveInputField(
                        label: l10n.seeingStarsCycleWaveLabel,
                        decoration: editorInputDecoration(
                          context,
                          focusColor: accent,
                          isFocused: _cycleIndexFocus.hasFocus,
                        ),
                        builder: (context, decoration) => TextField(
                          key: const ValueKey('seeingStarsCycleIndexInput'),
                          focusNode: _cycleIndexFocus,
                          controller: _cycleIndexCtrl,
                          keyboardType: TextInputType.number,
                          decoration: decoration,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data.cycleIndex = n;
                              _sync();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Tooltip(
                      message: l10n.pvz1SeeingStarsHelpSettlementDuration,
                      child: EditorResponsiveInputField(
                        label: l10n.seeingStarsSettlementLabel,
                        decoration: editorInputDecoration(
                          context,
                          focusColor: accent,
                          isFocused: _settlementFocus.hasFocus,
                        ),
                        builder: (context, decoration) => TextField(
                          key: const ValueKey(
                            'seeingStarsSettlementDurationInput',
                          ),
                          focusNode: _settlementFocus,
                          controller: _settlementCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: decoration,
                          onChanged: (v) {
                            final n = double.tryParse(v.replaceAll(',', '.'));
                            if (n != null) {
                              _data.settlementDuration = n;
                              _sync();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pvz1SeeingStarsSectionMatchPlants,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.pvz1SeeingStarsMatchPlantsEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ...sorted.mapIndexed(
              (i, p) => _MatchPlantTile(
                key: ValueKey('seeingStarsMatchPlant$i'),
                plant: p,
                gridRows: _gridRows,
                gridCols: _gridCols,
                onDelete: () => _removePlant(p),
                onSelect: () => setState(() {
                  _selectedX = p.gridX;
                  _selectedY = p.gridY;
                }),
                deleteTooltip: l10n.delete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme, Color accent) {
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF3C483D)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final plant = _data.matchPlants.firstWhereOrNull(
                        (p) => p.gridX == col && p.gridY == row,
                      );
                      return Expanded(
                        child: GestureDetector(
                          key: ValueKey('seeingStarsCell_${col}_$row'),
                          onTap: () => setState(() {
                            _selectedX = col;
                            _selectedY = row;
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accent.withValues(alpha: 0.25)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? accent
                                    : const Color(0xFFA5D6A7),
                                width: isSelected ? 1.5 : 0.5,
                              ),
                            ),
                            child: plant != null
                                ? Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: _PlantIconSmall(
                                        plant.matchTypeName,
                                      ),
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
}

String _plantIconPath(String plantType) {
  final info = PlantRepository().getPlantInfoById(plantType);
  return info?.icon != null
      ? 'assets/images/plants/${info!.icon}'
      : _kUnknownIconPath;
}

class _PlantIconSmall extends StatelessWidget {
  const _PlantIconSmall(this.plantType);

  final String plantType;

  @override
  Widget build(BuildContext context) {
    final path = _plantIconPath(plantType);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AssetImageWidget(
        assetPath: path,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        altCandidates: imageAltCandidates(path),
      ),
    );
  }
}

class _MatchPlantTile extends StatelessWidget {
  const _MatchPlantTile({
    super.key,
    required this.plant,
    required this.gridRows,
    required this.gridCols,
    required this.onDelete,
    required this.onSelect,
    required this.deleteTooltip,
  });

  final SeeingStarsMatchPlantData plant;
  final int gridRows;
  final int gridCols;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final String deleteTooltip;

  bool get _isOutOfBounds => plant.gridX >= gridCols || plant.gridY >= gridRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = _plantIconPath(plant.matchTypeName);
    final name = ResourceNames.lookup(
      context,
      PlantRepository().getName(plant.matchTypeName),
    ).trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onSelect,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isOutOfBounds)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  editorWarningIcon,
                  color: editorWarningBannerForeground(theme.brightness),
                  size: 24,
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AssetImageWidget(
                assetPath: path,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                altCandidates: imageAltCandidates(path),
              ),
            ),
          ],
        ),
        title: Text(
          name.isEmpty ? plant.matchTypeName : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'R${plant.gridY + 1}:C${plant.gridX + 1}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: deleteTooltip,
          onPressed: onDelete,
        ),
      ),
    );
  }
}
