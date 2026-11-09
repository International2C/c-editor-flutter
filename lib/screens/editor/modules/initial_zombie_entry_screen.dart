import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/condition_l10n.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/zombie_conditions.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

/// Initial zombie entry. Ported from Z-Editor-master InitialZombieEntryEP.kt
class InitialZombieEntryScreen extends StatefulWidget {
  const InitialZombieEntryScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.editorCubit,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final EditorCubit? editorCubit;

  /// Preset conditions for initial zombies (subset of [ZombieConditions.allIds]).
  static const presetConditionIds = ['icecubed', 'freeze', 'stun'];

  @override
  State<InitialZombieEntryScreen> createState() =>
      _InitialZombieEntryScreenState();
}

class _InitialZombieEntryScreenState extends State<InitialZombieEntryScreen> {
  late PvzObject _moduleObj;
  late InitialZombieEntryData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  InitialZombieData? _editingPlacement;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'InitialZombieProperties',
        objData: InitialZombieEntryData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = InitialZombieEntryData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = InitialZombieEntryData();
    }
    _data = InitialZombieEntryData(placements: List.from(_data.placements));
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleAddZombie() {
    final repo = ZombieRepository();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZombieSelectionScreen(
          editorCubit: widget.editorCubit,
          multiSelect: false,
          onZombieSelected: (id) {
            Navigator.pop(context);
            final isElite =
                repo.getZombieById(id)?.tags.contains(ZombieTag.elite) ?? false;
            if (isElite) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.cannotAddEliteZombies ??
                        'Cannot add elite zombies',
                  ),
                ),
              );
              return;
            }
            final aliases = repo.buildZombieAliases(id);
            final newList = List<InitialZombieData>.from(_data.placements);
            newList.add(
              InitialZombieData(
                gridX: _selectedX,
                gridY: _selectedY,
                typeName: aliases,
                condition: 'icecubed',
              ),
            );
            _data = InitialZombieEntryData(placements: newList);
            _sync();
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _updatePlacement(InitialZombieData oldItem, InitialZombieData newItem) {
    final newList = List<InitialZombieData>.from(_data.placements);
    final idx = newList.indexOf(oldItem);
    if (idx >= 0) {
      newList[idx] = newItem;
      _data = InitialZombieEntryData(placements: newList);
      _sync();
    }
  }

  void _deletePlacement(InitialZombieData target) {
    final newList = List<InitialZombieData>.from(_data.placements);
    newList.remove(target);
    _data = InitialZombieEntryData(placements: newList);
    _sync();
  }

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placementsAtPosition = _data.placements
        .where(
          (p) =>
              p.gridX == _selectedX &&
              p.gridY == _selectedY &&
              p.gridX >= 0 &&
              p.gridY >= 0 &&
              p.gridX < _gridCols &&
              p.gridY < _gridRows,
        )
        .toList();
    final placementsOutsideLawn = _data.placements
        .where(
          (p) =>
              p.gridX < 0 ||
              p.gridY < 0 ||
              p.gridX >= _gridCols ||
              p.gridY >= _gridRows,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.initialZombieLayout ??
              'Initial zombie layout',
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorPlacementGridCard(
                  header: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.selectedPosition ??
                                  'Selected position',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'R${_selectedY + 1} : C${_selectedX + 1}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  grid: _buildGrid(),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.zombieList ??
                      'Zombie list (row-first)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...placementsAtPosition.map(
                      (p) => _InitialZombieCard(
                        item: p,
                        gridRows: _gridRows,
                        gridCols: _gridCols,
                        showCoordinates: false,
                        onTap: () {
                          setState(() {
                            _selectedX = p.gridX;
                            _selectedY = p.gridY;
                            _editingPlacement = p;
                          });
                        },
                      ),
                    ),
                    AddItemCard(onPressed: _handleAddZombie),
                  ],
                ),
                if (placementsOutsideLawn.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)?.outsideLawnItems ??
                        'Objects outside the lawn',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: placementsOutsideLawn
                        .map(
                          (p) => _InitialZombieCard(
                            item: p,
                            gridRows: _gridRows,
                            gridCols: _gridCols,
                            showCoordinates: true,
                            onTap: () {
                              setState(() {
                                _selectedX = p.gridX;
                                _selectedY = p.gridY;
                                _editingPlacement = p;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (_editingPlacement != null) _buildEditDialog(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final theme = Theme.of(context);
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: EditorItemCardLayout.placementGridMaxWidth,
        ),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF40404B)
                  : const Color(0xFFEFEFFF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBAC4FA), width: 1),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final cellZombies = _data.placements
                          .where((p) => p.gridX == col && p.gridY == row)
                          .toList();
                      final firstZombie = cellZombies.firstOrNull;
                      final count = cellZombies.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedX = col;
                            _selectedY = row;
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF8581FA),
                                width: 0.5,
                              ),
                            ),
                            child: count > 0 && firstZombie != null
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: _ZombieIconSmall(
                                                  firstZombie.typeName,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (count > 1)
                                            GridCellCountBadge(
                                              label: '+$count',
                                              cellWidth: constraints.maxWidth,
                                            ),
                                        ],
                                      );
                                    },
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

  Widget _buildEditDialog() {
    final placement = _editingPlacement!;
    return _InitialZombieEditDialog(
      placement: placement,
      onSave: (updated) {
        _updatePlacement(placement, updated);
        setState(() => _editingPlacement = null);
      },
      onDelete: () {
        _deletePlacement(placement);
        setState(() => _editingPlacement = null);
      },
      onCancel: () => setState(() => _editingPlacement = null),
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

class _InitialZombieCard extends StatelessWidget {
  const _InitialZombieCard({
    required this.item,
    required this.gridRows,
    required this.gridCols,
    required this.showCoordinates,
    required this.onTap,
  });

  final InitialZombieData item;
  final int gridRows;
  final int gridCols;
  final bool showCoordinates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeId = ZombiePropertiesRepository.getTypeNameByAlias(item.typeName);
    final info =
        ZombieRepository().getZombieById(typeId) ??
        ZombieRepository().getZombieById(typeId.replaceAll('_elite', ''));
    final path = info?.icon != null
        ? 'assets/images/zombies/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    final nameKey = ZombieRepository().getName(typeId);
    final name = ResourceNames.lookup(context, nameKey);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AssetImageWidget(
                      assetPath: path,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      altCandidates: imageAltCandidates(path),
                      errorWidget: Container(
                        color: theme.colorScheme.onSurfaceVariant,
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ConditionL10n.zombieLabel(context, item.condition),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showCoordinates)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              editorWarningIcon,
                              color: editorWarningBannerForeground(
                                theme.brightness,
                              ),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'R${item.gridY + 1}:C${item.gridX + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: editorWarningBannerForeground(
                                  theme.brightness,
                                ),
                              ),
                            ),
                          ],
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

class _InitialZombieEditDialog extends StatefulWidget {
  const _InitialZombieEditDialog({
    required this.placement,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });

  final InitialZombieData placement;
  final void Function(InitialZombieData) onSave;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  State<_InitialZombieEditDialog> createState() =>
      _InitialZombieEditDialogState();
}

class _InitialZombieEditDialogState extends State<_InitialZombieEditDialog> {
  late String _condition;
  late bool _isCustomInput;
  late TextEditingController _conditionController;

  @override
  void initState() {
    super.initState();
    _condition = widget.placement.condition;
    _isCustomInput = !InitialZombieEntryScreen.presetConditionIds.contains(
      _condition,
    );
    _conditionController = TextEditingController(text: _condition);
  }

  @override
  void dispose() {
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeId = ZombiePropertiesRepository.getTypeNameByAlias(
      widget.placement.typeName,
    );
    final nameKey = ZombieRepository().getName(typeId);
    final name = ResourceNames.lookup(context, nameKey);
    return AlertDialog(
      scrollable: true,
      constraints: const BoxConstraints.tightFor(width: 560),
      title: Text(
        AppLocalizations.of(context)?.editPresetZombie(name) ??
            'Edit preset zombie: $name',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)?.manualInput ?? 'Manual input',
                  ),
                  value: _isCustomInput,
                  onChanged: (v) => setState(() => _isCustomInput = v),
                ),
                const SizedBox(height: 16),
                if (_isCustomInput) ...[
                  EditorResponsiveInputField(
                    label:
                        AppLocalizations.of(context)?.enterConditionValue ??
                        'Enter condition value',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                    ),
                    builder: (context, decoration) => TextField(
                      decoration: decoration,
                      controller: _conditionController,
                      onChanged: (v) => setState(() => _condition = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.customInputHint ??
                        'Custom input must be accurate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  EditorResponsiveInputField(
                    label:
                        AppLocalizations.of(context)?.presetConditions ??
                        'Preset conditions',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                    ),
                    builder: (context, decoration) =>
                        DropdownButtonFormField<String>(
                          itemHeight: null,
                          isExpanded: true,
                          initialValue:
                              InitialZombieEntryScreen.presetConditionIds
                                  .contains(_condition)
                              ? _condition
                              : InitialZombieEntryScreen
                                    .presetConditionIds
                                    .first,
                          decoration: decoration,
                          items: [
                            for (final id
                                in InitialZombieEntryScreen.presetConditionIds)
                              DropdownMenuItem(
                                value: id,
                                child: Text(
                                  ConditionL10n.zombieLabel(context, id),
                                ),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _condition = v);
                          },
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.selectFromPresetHint ??
                        'Select from preset condition list',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete();
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
        ),
        TextButton(
          onPressed: widget.onCancel,
          child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final cond = _isCustomInput
                ? _conditionController.text
                : _condition;
            widget.onSave(
              InitialZombieData(
                gridX: widget.placement.gridX,
                gridY: widget.placement.gridY,
                typeName: widget.placement.typeName,
                condition: cond,
              ),
            );
          },
          child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
        ),
      ],
    );
  }
}
