import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

/// Initial plant entry. Ported from Z-Editor-master InitialPlantEntryEP.kt
class InitialPlantEntryScreen extends StatefulWidget {
  const InitialPlantEntryScreen({
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
  State<InitialPlantEntryScreen> createState() =>
      _InitialPlantEntryScreenState();
}

class _InitialPlantEntryScreenState extends State<InitialPlantEntryScreen> {
  late PvzObject _moduleObj;
  late InitialPlantEntryData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  InitialPlantData? _editingPlant;

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
        objClass: 'InitialPlantEntryProperties',
        objData: InitialPlantEntryData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = InitialPlantEntryData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = InitialPlantEntryData();
    }
    _data = InitialPlantEntryData(plants: List.from(_data.plants));
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleSelectPlant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantSelectionScreen(
          isMultiSelect: false,
          onPlantSelected: (id) {
            Navigator.pop(context);
            final newList = List<InitialPlantData>.from(_data.plants);
            newList.add(
              InitialPlantData(
                gridX: _selectedX,
                gridY: _selectedY,
                level: 1,
                plantTypes: [id],
                avatar: false,
              ),
            );
            _data = InitialPlantEntryData(plants: newList);
            _sync();
          },
          onBack: () => Navigator.pop(context),
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
        ),
      ),
    );
  }

  void _updatePlant(InitialPlantData oldPlant, InitialPlantData newPlant) {
    final newList = List<InitialPlantData>.from(_data.plants);
    final idx = newList.indexOf(oldPlant);
    if (idx >= 0) {
      newList[idx] = newPlant;
      _data = InitialPlantEntryData(plants: newList);
      _sync();
    }
  }

  void _deletePlant(InitialPlantData target) {
    final newList = List<InitialPlantData>.from(_data.plants);
    newList.remove(target);
    _data = InitialPlantEntryData(plants: newList);
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
    final l10n = AppLocalizations.of(context);
    final plantsAtPosition = _data.plants
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
    final plantsOutsideLawn = _data.plants
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
          l10n?.initialPlantLayout ?? 'Initial plant layout',
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
                              l10n?.selectedPosition ?? 'Selected position',
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
                  l10n?.plantList ?? 'Plant list (row-first)',
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
                    ...plantsAtPosition.map(
                      (p) => _InitialPlantCard(
                        plant: p,
                        gridRows: _gridRows,
                        gridCols: _gridCols,
                        showCoordinates: false,
                        onTap: () {
                          setState(() {
                            _selectedX = p.gridX;
                            _selectedY = p.gridY;
                            _editingPlant = p;
                          });
                        },
                      ),
                    ),
                    AddItemCard(onPressed: _handleSelectPlant),
                  ],
                ),
                if (plantsOutsideLawn.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n?.outsideLawnItems ?? 'Objects outside the lawn',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: plantsOutsideLawn
                        .map(
                          (p) => _InitialPlantCard(
                            plant: p,
                            gridRows: _gridRows,
                            gridCols: _gridCols,
                            showCoordinates: true,
                            onTap: () {
                              setState(() {
                                _selectedX = p.gridX;
                                _selectedY = p.gridY;
                                _editingPlant = p;
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
          if (_editingPlant != null) _buildEditDialog(l10n),
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
                  ? const Color(0xFF3C483D)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final cellPlants = _data.plants
                          .where((p) => p.gridX == col && p.gridY == row)
                          .toList();
                      final firstPlant = cellPlants.isNotEmpty
                          ? cellPlants.first
                          : null;
                      final count = cellPlants.length;
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
                                    : const Color(0xFFA5D6A7),
                                width: 0.5,
                              ),
                            ),
                            child: count > 0 && firstPlant != null
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
                                                child: _PlantIconSmall(
                                                  firstPlant
                                                          .plantTypes
                                                          .firstOrNull ??
                                                      '',
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (count > 1)
                                            GridCellCountBadge(
                                              label: '+${count - 1}',
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

  Widget _buildEditDialog(AppLocalizations? l10n) {
    final plant = _editingPlant!;
    return _InitialPlantEditDialog(
      l10n: l10n,
      plant: plant,
      onSave: (updated) {
        _updatePlant(plant, updated);
        setState(() => _editingPlant = null);
      },
      onDelete: () {
        _deletePlant(plant);
        setState(() => _editingPlant = null);
      },
      onCancel: () => setState(() => _editingPlant = null),
    );
  }
}

class _PlantIconSmall extends StatelessWidget {
  const _PlantIconSmall(this.plantType);

  final String plantType;

  @override
  Widget build(BuildContext context) {
    final info = PlantRepository().getPlantInfoById(plantType);
    final path = info?.icon != null
        ? 'assets/images/plants/${info!.icon}'
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

class _InitialPlantCard extends StatelessWidget {
  const _InitialPlantCard({
    required this.plant,
    required this.gridRows,
    required this.gridCols,
    required this.showCoordinates,
    required this.onTap,
  });

  final InitialPlantData plant;
  final int gridRows;
  final int gridCols;
  final bool showCoordinates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final plantType = plant.plantTypes.firstOrNull ?? '';
    final info = PlantRepository().getPlantInfoById(plantType);
    final plantName = ResourceNames.lookup(
      context,
      PlantRepository().getName(plantType),
    );
    final path = info?.icon != null
        ? 'assets/images/plants/${info!.icon}'
        : 'assets/images/others/unknown.webp';

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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
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
                      if (plant.avatar)
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Icon(
                              Icons.checkroom,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n?.levelFormat(plant.level) ?? 'Level: ${plant.level}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      plant.avatar
                          ? (l10n?.costumeOn ?? 'Costume: on')
                          : (l10n?.costumeOff ?? 'Costume: off'),
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
                            Expanded(
                              child: Text(
                                'R${plant.gridY + 1}:C${plant.gridX + 1}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: editorWarningBannerForeground(
                                    theme.brightness,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
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

class _InitialPlantEditDialog extends StatefulWidget {
  const _InitialPlantEditDialog({
    required this.l10n,
    required this.plant,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });

  final AppLocalizations? l10n;
  final InitialPlantData plant;
  final void Function(InitialPlantData) onSave;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  State<_InitialPlantEditDialog> createState() =>
      _InitialPlantEditDialogState();
}

class _InitialPlantEditDialogState extends State<_InitialPlantEditDialog> {
  late int _level;
  late bool _avatar;

  @override
  void initState() {
    super.initState();
    _level = widget.plant.level;
    _avatar = widget.plant.avatar;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    final nameKey = PlantRepository().getName(
      widget.plant.plantTypes.firstOrNull ?? '',
    );
    final name = ResourceNames.lookup(context, nameKey);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n?.editAlias(name) ?? 'Edit $name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${l10n?.level ?? 'Level'}: $_level',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _level.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => setState(() => _level = v.round()),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n?.firstCostume ?? 'First costume (Avatar)'),
            value: _avatar,
            onChanged: (v) => setState(() => _avatar = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete();
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n?.delete ?? 'Delete'),
        ),
        TextButton(
          onPressed: widget.onCancel,
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(
              InitialPlantData(
                gridX: widget.plant.gridX,
                gridY: widget.plant.gridY,
                level: _level,
                avatar: _avatar,
                plantTypes: widget.plant.plantTypes,
              ),
            );
          },
          child: Text(l10n?.save ?? 'Save'),
        ),
      ],
    );
  }
}
