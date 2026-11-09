import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/halloween_content.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class HalloweenPlacementScreen extends StatefulWidget {
  const HalloweenPlacementScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.cauldron,
    required this.onChanged,
    required this.onBack,
  });
  final String rtid;
  final PvzLevelFile levelFile;
  final bool cauldron;
  final VoidCallback onChanged, onBack;
  @override
  State<HalloweenPlacementScreen> createState() => _HalloweenPlacementState();
}

class _HalloweenPlacementState extends State<HalloweenPlacementScreen> {
  late PvzObject object;
  late Map<String, dynamic> data;
  late String alias;
  int selectedX = 0;
  int selectedY = 0;
  int get selected => positions.indexWhere(
    (p) => p['GridX'] == selectedX && p['GridY'] == selectedY,
  );
  String get listKey =>
      widget.cauldron ? 'InitialGridItemWizardCrucibles' : 'SpawnPositionsPool';
  List<dynamic> get positions => data[listKey] as List;
  @override
  void initState() {
    super.initState();
    alias = aliasFromRtid(widget.rtid);
    object = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
    );
    data = Map<String, dynamic>.from(object.objData as Map);
    data.putIfAbsent(listKey, () => <dynamic>[]);
    data[listKey] = [
      for (final item in positions) Map<String, dynamic>.from(item as Map),
    ];
    if (widget.cauldron && positions.isNotEmpty) {
      selectedX = (positions.first['GridX'] as num?)?.toInt() ?? 0;
      selectedY = (positions.first['GridY'] as num?)?.toInt() ?? 0;
    }
    if (!widget.cauldron) {
      data.putIfAbsent('Hitpoints', () => 4000);
      data.putIfAbsent('Level', () => 0);
      data.putIfAbsent(
        'PumpkinScarecrowPool',
        () => [
          {'Count': 1, 'Type': 'RTID(pumpkin_scarecrow@GridItemTypes)'},
        ],
      );
    }
  }

  void sync() {
    object.objData = data;
    widget.onChanged();
    setState(() {});
  }

  Widget number(Map target, String key, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: EditorResponsiveInputField(
      label: label,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      builder: (context, decoration) => TextFormField(
        key: ValueKey('${identityHashCode(target)}_$key'),
        initialValue: '${target[key] ?? 0}',
        textAlign: TextAlign.start,
        decoration: decoration,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (text) {
          final value = num.tryParse(text);
          if (value == null || !value.isFinite || value < 0) return;
          if (key == 'Count' && value != value.truncate()) {
            return;
          }
          target[key] = key == 'Count' ? value.toInt() : value;
          sync();
        },
      ),
    ),
  );

  Widget crowLevel(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: EditorResponsiveInputField(
      label: label,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      builder: (context, decoration) => DropdownButtonFormField<int>(
        key: const ValueKey('pumpkinScarecrowCrowLevel'),
        initialValue: (data['Level'] as num? ?? 0).toInt().clamp(0, 10),
        isExpanded: true,
        decoration: decoration,
        items: List.generate(
          11,
          (value) => DropdownMenuItem(value: value, child: Text('$value')),
        ),
        onChanged: (value) {
          if (value == null) return;
          data['Level'] = value;
          sync();
        },
      ),
    ),
  );

  Widget card(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  void editCell(int x, int y) {
    if (widget.cauldron) {
      final index = positions.indexWhere(
        (p) => p['GridX'] == x && p['GridY'] == y,
      );
      selectedX = x;
      selectedY = y;
      if (index >= 0) {
        setState(() {});
        return;
      } else {
        positions.add(newCauldron(x, y));
      }
    } else {
      final index = positions.indexWhere((p) => p['mX'] == x && p['mY'] == y);
      if (index >= 0) {
        positions.removeWhere((p) => p['mX'] == x && p['mY'] == y);
      } else {
        positions.add({'mX': x, 'mY': y});
      }
    }
    sync();
  }

  Future<void> confirmRemoveCauldron() async {
    if (selected < 0) return;
    final target = positions[selected];
    final l = AppLocalizations.of(context)!;
    final name = ResourceNames.lookupOrFallback(
      context,
      'griditem_wizard_crucible',
      'wizard_crucible',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.removeItem),
        content: Text(
          l.removeItemConfirm(
            'R${target['GridY'] + 1} : C${target['GridX'] + 1} $name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l.remove),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    positions.remove(target);
    sync();
  }

  Widget grid() {
    final dims = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    final rows = dims.$1, cols = dims.$2;
    final theme = Theme.of(context);
    final borderColor = widget.cauldron
        ? const Color(0xFF6B899A)
        : Colors.brown;
    return scaleTableForDesktop(
      context: context,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: cols / rows,
          child: Container(
            key: ValueKey(
              widget.cauldron
                  ? 'wizardCauldronGrid'
                  : 'scarecrowPositionPoolGrid',
            ),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? widget.cauldron
                        ? const Color(0xFF31383B)
                        : const Color(0xFF2A2A2A)
                  : widget.cauldron
                  ? const Color(0xFFD7ECF1)
                  : const Color(0xFFD7CCC8),
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(
                rows,
                (y) => Expanded(
                  child: Row(
                    children: List.generate(cols, (x) {
                      final matches = positions.asMap().entries.where(
                        (e) =>
                            e.value[widget.cauldron ? 'GridX' : 'mX'] == x &&
                            e.value[widget.cauldron ? 'GridY' : 'mY'] == y,
                      );
                      final highlighted = widget.cauldron
                          ? x == selectedX && y == selectedY
                          : matches.isNotEmpty;
                      return Expanded(
                        child: InkWell(
                          key: ValueKey('placementCell_${x}_$y'),
                          onTap: () => editCell(x, y),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.cauldron && highlighted
                                    ? theme.colorScheme.primary
                                    : borderColor.withValues(alpha: .5),
                                width: widget.cauldron && highlighted
                                    ? 1.5
                                    : .5,
                              ),
                              color: highlighted
                                  ? widget.cauldron
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: .3,
                                          )
                                        : const Color(0xFF2E7D32)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: matches.isEmpty
                                ? null
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final cellSize = constraints.maxWidth;
                                      return widget.cauldron
                                          ? Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: GridItemIcon(
                                                typeName: 'wizard_crucible',
                                                size: cellSize,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: (cellSize * .85).clamp(
                                                16,
                                                56,
                                              ),
                                            );
                                    },
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget identity(String type, {VoidCallback? onDelete}) => Row(
    children: [
      GridItemIcon(typeName: type, size: 48, fit: BoxFit.contain),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ResourceNames.lookupOrFallback(context, 'griditem_$type', type),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(type, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      if (onDelete != null)
        IconButton(
          key: const ValueKey('deleteSelectedWizardCauldron'),
          tooltip: AppLocalizations.of(context)!.delete,
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = widget.cauldron
        ? l.moduleTitle_InitialGridItemWizardCrucibleProps
        : l.eventTitle_SpawnPumpkinScarecrowWaveActionProps;
    final objClass = widget.cauldron ? cauldronClass : scarecrowClass;
    final count = widget.cauldron
        ? positions.length
        : (data['PumpkinScarecrowPool'] as List).fold<int>(
            0,
            (sum, e) => sum + (e['Count'] as num? ?? 0).toInt(),
          );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: title,
          isEvent: !widget.cauldron,
          objClass: objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: widget.cauldron
                ? l.tooltipAboutModule
                : l.tooltipAboutEvent,
            onPressed: () => showEditorHelpDialog(
              context,
              title: title,
              isEvent: !widget.cauldron,
              sections: [
                HelpSectionData(
                  title: l.overview,
                  body: widget.cauldron
                      ? l.wizardCauldronHelpOverview
                      : l.pumpkinScarecrowHelpOverview,
                ),
                HelpSectionData(
                  title: widget.cauldron ? l.usage : l.logic,
                  body: widget.cauldron
                      ? l.wizardCauldronHelpUsage
                      : l.pumpkinScarecrowHelpLogic,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.cauldron)
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: alias,
                levelFile: widget.levelFile,
                onAliasChanged: rename,
              )
            else
              EditorAliasInputField(
                alias: alias,
                levelFile: widget.levelFile,
                onAliasChanged: rename,
              ),
            const SizedBox(height: 16),
            if (widget.cauldron) ...[
              EditorPlacementGridCard(
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.selectedPosition,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'R${selectedY + 1} : C${selectedX + 1}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                grid: grid(),
              ),
              const SizedBox(height: 16),
              if (selected >= 0)
                card([
                  identity('wizard_crucible', onDelete: confirmRemoveCauldron),
                  const SizedBox(height: 12),
                  number(
                    positions[selected],
                    'CrucibleHitpoints',
                    l.wizardCauldronHitpoints,
                  ),
                  number(
                    positions[selected],
                    'BoilingDuration',
                    l.wizardCauldronBoilingDuration,
                  ),
                  number(
                    positions[selected],
                    'ExplodeDamageAmount',
                    l.wizardCauldronExplosionDamage,
                  ),
                  number(
                    positions[selected],
                    'VenomDamageAmountPerSecond',
                    l.wizardCauldronVenomDamagePerSecond,
                  ),
                  number(
                    positions[selected],
                    'VenomExistDuration',
                    l.wizardCauldronVenomDuration,
                  ),
                ]),
            ] else ...[
              card([
                Text(
                  l.positionPoolSpawnPositions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.tapCellsSelectDeselect,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                grid(),
                const SizedBox(height: 8),
                EditorResponsiveFieldRow(
                  breakpoint: 480,
                  children: [
                    Text(l.positionsCount(positions.length)),
                    Text(l.totalItemsCount(count)),
                  ],
                ),
                if (count > positions.length)
                  Text(
                    l.itemCountExceedsPositionsWarning,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ]),
              const SizedBox(height: 16),
              card([
                identity('pumpkin_scarecrow'),
                const SizedBox(height: 12),
                for (final pool in data['PumpkinScarecrowPool'] as List)
                  number(pool, 'Count', l.pumpkinScarecrowSpawnCount),
                number(data, 'Hitpoints', l.pumpkinScarecrowHitpoints),
                crowLevel(l.pumpkinScarecrowCrowLevel),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  void rename(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => alias = value);
  }
}
