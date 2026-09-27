import 'package:flutter/material.dart';
import 'package:c_editor/data/gladiator_row_utils.dart';
import 'package:c_editor/widgets/gladiator_row_preview.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/lunar_mine_vein_type_catalog.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/moon_wave_preview_utils.dart';
import 'package:c_editor/data/renai_wave_preview_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/drop_ship_area_preview_grid.dart';
import 'package:c_editor/widgets/editor_preview_dialog.dart';
import 'package:c_editor/widgets/grid_override_preview_grid.dart';
import 'package:c_editor/widgets/heian_wind_preview_text.dart';
import 'package:c_editor/widgets/renai_statue_preview_grid.dart';

List<Widget> _previewDialogActions(
  BuildContext context, {
  required AppLocalizations? l10n,
  VoidCallback? onOpenModuleSettings,
}) {
  return [
    if (onOpenModuleSettings != null)
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () {
          Navigator.pop(context);
          onOpenModuleSettings();
        },
        child: Text(l10n?.openModuleSettings ?? 'Open module settings'),
      ),
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(l10n?.close ?? 'Close'),
    ),
  ];
}

Future<void> showSeeingStarsWavePreviewDialog(
  BuildContext context, {
  required int waveIndex,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(
      '${l10n.waveLabel} $waveIndex - ${l10n.pvz1SeeingStarsModuleTitle}',
    ),
    content: Text(l10n.seeingStarsCycleWaveInfo(waveIndex)),
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}

Future<void> showDropShipWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required List<DropShipAppearWaveData> waves,
  VoidCallback? onOpenModuleSettings,
}) {
  if (waves.isEmpty) return Future.value();
  final l10n = AppLocalizations.of(context);
  final title =
      '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.airDropShipModuleExpectationLabel ?? 'Airdropped Imps'}';
  final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(levelFile);

  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final w in waves) ...[
          Text(
            '${l10n?.airDropShipModuleExtraImpCount ?? 'Extra imp count (Imp)'}: ${w.imp}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.airDropShipModuleAreaDropPreviewLabel ?? 'Area drop preview:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropShipAreaPreviewGrid(
            gridRows: gridRows,
            gridCols: gridCols,
            rowRange: w.rowRange,
            colRange: w.colRange,
          ),
          const SizedBox(height: 16),
        ],
      ],
    ),
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}

Future<void> showHeianWindWavePreviewDialog(
  BuildContext context, {
  required int waveIndex,
  required List<HeianWindWaveWindInfoData> waves,
  VoidCallback? onOpenModuleSettings,
}) {
  if (waves.isEmpty) return Future.value();
  final l10n = AppLocalizations.of(context);

  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(
      '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.heianWindModuleExpectationLabel ?? 'Divine Wind'}',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final w in waves) ...[
          Text(
            '${l10n?.heianWindModuleWindDelay ?? 'Time between wind spawns (WindDelay)'}: ${w.windDelay}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          for (final wind in w.windInfos)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(heianWindEntryPreviewLine(context, wind)),
            ),
          const SizedBox(height: 8),
        ],
      ],
    ),
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}

void openModuleWithHint(
  OpenModuleCallback? onOpenModule,
  PvzLevelFile levelFile,
  String objClass, {
  ModuleOpenHint? hint,
}) {
  if (onOpenModule == null) return;
  final rtid = moduleRtidForClass(levelFile, objClass);
  if (rtid == null) return;
  onOpenModule(rtid, hint: hint);
}

Future<void> showRenaiWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required RenaiModulePropertiesData renai,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final nightStarts = renaiNightStartsOnWave(renai, waveIndex);
  final nightSpawnStatues = renaiNightSpawnStatuesForWave(renai, waveIndex);
  final revivingStatues = renaiRevivingStatuesForWave(renai, waveIndex);
  final isEmpty =
      !renai.nightEnabled &&
      renai.statueInfos.isEmpty &&
      renai.statueNightInfos.isEmpty;
  final hasWaveEvents =
      nightStarts || nightSpawnStatues.isNotEmpty || revivingStatues.isNotEmpty;

  final children = <Widget>[];

  if (isEmpty) {
    children.add(
      Text(
        l10n?.renaiWavePreviewEmpty ?? 'Empty (roller/tiles only)',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  } else {
    if (nightStarts) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.nightlight_round,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n?.renaiModuleNightStarts ?? 'Night begins'),
          ],
        ),
      );
      children.add(const SizedBox(height: 12));
    }
    if (nightSpawnStatues.isNotEmpty) {
      children.add(
        Text(
          l10n?.renaiModulePreviewNightStatues ?? 'Night statues:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      children.add(const SizedBox(height: 8));
      children.add(
        RenaiStatuePreviewGrid(
          levelFile: levelFile,
          statues: nightSpawnStatues,
          shrinkOnDesktop: false,
        ),
      );
      children.add(const SizedBox(height: 12));
    }
    if (revivingStatues.isNotEmpty) {
      children.add(
        Text(
          l10n?.renaiModulePreviewRevivingStatues ?? 'Reviving statues:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      children.add(const SizedBox(height: 8));
      children.add(
        RenaiStatuePreviewGrid(
          levelFile: levelFile,
          statues: revivingStatues,
          shrinkOnDesktop: false,
        ),
      );
    }
  }

  final content = !hasWaveEvents && !isEmpty
      ? Text(
          l10n?.noDynamicZombies ?? 'No events',
          style: Theme.of(context).textTheme.bodySmall,
        )
      : children.isEmpty
      ? Text(
          l10n?.noDynamicZombies ?? 'No events',
          style: Theme.of(context).textTheme.bodySmall,
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(
      '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.renaiModuleExpectationLabel ?? 'Renaissance event preview'}',
    ),
    content: content,
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}

Future<void> showLunarMineVeinWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required LunarMineVeinModulePropertiesData data,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final placements = lunarMineVeinEmergingPlacementsForWave(data, waveIndex);
  final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(levelFile);
  final cellAssets = {
    for (final placement in placements)
      '${placement.gridX},${placement.gridY}': lunarMineVeinOreIconAsset(
        placement.typeName,
      ),
  };

  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(
      '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.lunarMineVeinModuleExpectationLabel ?? 'Lunar Veins'}',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.lunarMineVeinModulePreviewEmerging ??
              'Lunar Energy Crystals emerging this wave:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridOverridePreviewGrid(
          gridRows: gridRows,
          gridCols: gridCols,
          cellImageAt: (col, row) => cellAssets['$col,$row'],
          cellImageScaleAt: (_, _) => 0.92,
        ),
      ],
    ),
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}

Future<void> showRadiationMeteorWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required RadiationMeteorModulePropertiesData data,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final spawns = radiationMeteorSpawnsForWave(data, waveIndex);
  final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(levelFile);
  const asset = 'assets/images/griditems/radiation_meteor_ore.webp';
  final cells = spawns.map((spawn) => '${spawn.gridX},${spawn.gridY}').toSet();

  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(
      '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.radiationMeteorModuleExpectationLabel ?? 'Radioactive Meteorite'}',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.radiationMeteorModulePreviewLanding ??
              'Meteorites landing this wave:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridOverridePreviewGrid(
          gridRows: gridRows,
          gridCols: gridCols,
          cellImageAt: (col, row) => cells.contains('$col,$row') ? asset : null,
          cellImageScaleAt: (_, _) => 0.92,
        ),
      ],
    ),
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}

Future<void> showGladiatorRowWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required GladiatorRowModulePropertiesData data,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context)!;
  final encounters = gladiatorEncountersForWave(data, waveIndex);
  final (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);
  return showEditorPreviewDialog<void>(
    context: context,
    title: Text(
      '${l10n.waveLabel} $waveIndex - ${l10n.moduleTitle_GladiatorRowModuleProperties}',
    ),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!data.usesTrophyMode)
          Text(l10n.gladiatorLegacyModeWarning)
        else ...[
          Text(l10n.gladiatorPreviewTitle),
          for (final encounter in encounters) ...[
            const SizedBox(height: 12),
            Text(
              'R${encounter.row + 1} · ${l10n.gladiatorArenaDuration}: ${data.option('ArenaDuration')}',
            ),
            const SizedBox(height: 8),
            GladiatorRowPreview(
              encounter: encounter,
              levelFile: levelFile,
              rows: rows,
              cols: cols,
            ),
          ],
        ],
      ],
    ),
    actions: _previewDialogActions(
      context,
      l10n: l10n,
      onOpenModuleSettings: onOpenModuleSettings,
    ),
  );
}
