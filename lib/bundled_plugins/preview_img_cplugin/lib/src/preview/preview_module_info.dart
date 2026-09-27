import 'package:c_editor/data/oak_archery_preview.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'preview_module_resource_names.dart';
import 'package:c_editor/data/armrack_type_catalog.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';

typedef PreviewModuleL10n =
    String Function(String key, String fallback, [Map<String, Object?>? args]);

/// Structured module-info payload for text labels and/or icon grids.
class PreviewModuleInfoPayload {
  const PreviewModuleInfoPayload({
    required this.lines,
    this.gridNotes = const [],
    this.sections = const [],
    this.lawnRows,
    this.lawnCols,
  });

  /// Full human-readable lines for text-label mode (includes cells, counts…).
  final List<String> lines;

  /// Non-spatial notes for icon-grid chrome (brick map, timing, etc.).
  /// Cell coordinates and placement lists belong only in [lines].
  final List<String> gridNotes;

  /// Optional icon sections (may be empty for text-only modules).
  final List<PreviewIconSection> sections;

  /// When set with [lawnCols], the icon-grid is a mini lawn like level preview.
  final int? lawnRows;
  final int? lawnCols;

  String get textBody => lines.where((l) => l.trim().isNotEmpty).join('\n');

  String get gridChromeBody =>
      gridNotes.where((l) => l.trim().isNotEmpty).join('\n');

  bool get hasContent => lines.isNotEmpty || sections.isNotEmpty;

  bool get isLawnGrid =>
      lawnRows != null &&
      lawnCols != null &&
      lawnRows! > 0 &&
      lawnCols! > 0 &&
      sections.any((s) => s.items.any((i) => i.hasCell));
}

/// Builds informative content for a module present on the level.
PreviewModuleInfoPayload previewModuleInfoBuild({
  required PvzLevelFile levelFile,
  required String objClass,
  required PreviewModuleL10n t,
  PreviewModuleResourceName? resourceName,
  AppLocalizations? appL10n,
}) {
  final name = resourceName ?? _fallbackResourceName;
  final l10n = appL10n ?? AppLocalizationsEn();
  switch (objClass) {
    case 'OakTrainProperties':
      final raw = _objMap(levelFile, objClass);
      if (raw == null) return const PreviewModuleInfoPayload(lines: []);
      final fields = oakArcheryFields(
        OakTrainPropertiesData.fromJson(raw),
        l10n,
      );
      final lines = fields.map((f) => '${f.label}: ${f.value}').toList();
      final (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);
      return PreviewModuleInfoPayload(
        lines: lines,
        gridNotes: lines,
        lawnRows: rows,
        lawnCols: cols,
        sections: [
          PreviewIconSection(
            items: [
              _plantItem(
                'oakshooter',
                label: name(PreviewModuleResourceKind.plant, 'oakshooter'),
                gridX: 0,
                gridY: 2,
              ),
            ],
          ),
        ],
      );
    case 'WaveGeneratorProperties':
      final raw = _objMap(levelFile, objClass);
      if (raw == null) return const PreviewModuleInfoPayload(lines: []);
      final data = WaveGeneratorPropertiesData.fromJson(raw);
      return PreviewModuleInfoPayload(
        lines: waveGeneratorPreviewLines(
          data,
          l10n,
          (id) => name(PreviewModuleResourceKind.zombie, id),
        ),
        sections: [
          for (var i = 0; i < data.waves.length; i++)
            PreviewIconSection(
              title: [
                '${l10n.waveLabel} ${i + 1}',
                waveSpawnDelaySummary(l10n, data, data.waves[i]),
              ].where((s) => s.isNotEmpty).join(' · '),
              items: [
                for (final z in data.waves[i].zombies)
                  _zombieItem(
                    z.type,
                    label:
                        '${name(PreviewModuleResourceKind.zombie, z.type)}${data.isRiseFromGroundMode ? ' · ${waveSpawnPositionSummary(l10n, z)}' : ''}',
                  ),
              ],
            ),
        ],
      );

    case 'SeedBankProperties':
      return _seedBank(levelFile, t);
    case 'ConveyorSeedBankProperties':
      return _conveyor(levelFile, t);
    case 'InitialPlantEntryProperties':
    case 'InitialPlantProperties':
      return _initialPlants(levelFile, objClass, t, name);
    case 'InitialZombieProperties':
      return _initialZombies(levelFile, t, name);
    case 'ProtectThePlantChallengeProperties':
      return _protectPlants(levelFile, t, name);
    case 'ProtectTheGridItemChallengeProperties':
      return _protectGridItems(levelFile, t, name);
    case 'PVZ1SeeingStarsModuleProperties':
      return _seeingStars(levelFile, t, name);
    case 'VaseBreakerPresetProperties':
    case 'VaseBreakerArcadeModuleProperties':
    case 'VaseBreakerFlowModuleProperties':
      return _vases(levelFile, t, name);
    case 'ArmrackProperties':
      return _armrack(levelFile, t);
    case 'EnergyGridProperties':
      return _energy(levelFile, t);
    case 'LunarMineVeinModuleProperties':
      return _lunarVeins(levelFile, t);
    case 'RadiationMeteorModuleProperties':
      return _radiationMeteor(levelFile, t);
    case 'InitialGridItemGulliverTunnelProperties':
      return _gulliver(levelFile, t);
    case 'InitialGridItemProperties':
      return _initialGridItems(levelFile, t, name);
    case 'BronzeProperties':
      return _bronze(levelFile, t, name);
    case 'PowerTileProperties':
      return _powerTiles(levelFile, t, name);
    case 'RailcartProperties':
      return _railcart(levelFile, t);
    case 'SmokePollutionModuleProperties':
      return _smokePollution(levelFile, t);
    case 'RenaiModuleProperties':
      return _renai(levelFile, t, name);
    case 'TunnelDefendModuleProperties':
      return _tunnelDefend(levelFile, t);
    case 'ManholePipelineModuleProperties':
      return _manholePipeline(levelFile, t);
    case 'MoldColonyChallengeProps':
      return _moldColony(levelFile, t);
    case 'SunDropperProperties':
      return _sunDropper(levelFile, t);
    case 'LastStandMinigameProperties':
      return _lastStand(levelFile, t);
    case 'SeedRainProperties':
      return _seedRain(levelFile, t, name);
    case 'DropShipProperties':
      return _dropShip(levelFile, t);
    case 'PiratePlankProperties':
      return _piratePlank(levelFile, t);
    case 'TideProperties':
      return _tide(levelFile, t);
    default:
      return _genericDump(levelFile, objClass, t, name);
  }
}

/// Legacy wrappers used by older call sites.
List<PreviewIconSection>? previewModuleInfoSections({
  required PvzLevelFile levelFile,
  required String objClass,
  required PreviewModuleL10n t,
  PreviewModuleResourceName? resourceName,
  AppLocalizations? appL10n,
}) {
  final built = previewModuleInfoBuild(
    levelFile: levelFile,
    objClass: objClass,
    t: t,
    resourceName: resourceName,
    appL10n: appL10n,
  );
  return built.sections.isEmpty ? null : built.sections;
}

String? previewModuleInfoTextSummary({
  required PvzLevelFile levelFile,
  required String objClass,
  required PreviewModuleL10n t,
  PreviewModuleResourceName? resourceName,
  AppLocalizations? appL10n,
}) {
  final body = previewModuleInfoBuild(
    levelFile: levelFile,
    objClass: objClass,
    t: t,
    resourceName: resourceName,
    appL10n: appL10n,
  ).textBody;
  return body.isEmpty ? null : body;
}

/// ObjClasses on the level that Module Info can summarize with real data.
List<String> previewPresentModuleObjClasses(PvzLevelFile levelFile) {
  final present = <String>{};
  for (final obj in levelFile.objects) {
    if (ModuleRegistry.registry.containsKey(obj.objClass)) {
      present.add(obj.objClass);
    }
  }
  final parsed = LevelParser.parseLevel(levelFile);
  for (final rtid in parsed.levelDef?.modules ?? const <String>[]) {
    final info = RtidParser.parse(rtid);
    if (info == null) continue;
    final obj = parsed.objectMap[info.alias];
    if (obj != null && ModuleRegistry.registry.containsKey(obj.objClass)) {
      present.add(obj.objClass);
    }
  }

  // Prefer modules we have structured readers for; keep others as generic dump.
  const preferred = {
    'OakTrainProperties',
    'WaveGeneratorProperties',
    'SeedBankProperties',
    'ConveyorSeedBankProperties',
    'InitialPlantEntryProperties',
    'InitialPlantProperties',
    'InitialZombieProperties',
    'ProtectThePlantChallengeProperties',
    'ProtectTheGridItemChallengeProperties',
    'PVZ1SeeingStarsModuleProperties',
    'VaseBreakerPresetProperties',
    'VaseBreakerArcadeModuleProperties',
    'VaseBreakerFlowModuleProperties',
    'ArmrackProperties',
    'EnergyGridProperties',
    'LunarMineVeinModuleProperties',
    'RadiationMeteorModuleProperties',
    'InitialGridItemGulliverTunnelProperties',
    'InitialGridItemProperties',
    'BronzeProperties',
    'PowerTileProperties',
    'RailcartProperties',
    'SmokePollutionModuleProperties',
    'RenaiModuleProperties',
    'TunnelDefendModuleProperties',
    'ManholePipelineModuleProperties',
    'MoldColonyChallengeProps',
    'SunDropperProperties',
    'LastStandMinigameProperties',
    'SeedRainProperties',
    'DropShipProperties',
    'PiratePlankProperties',
    'TideProperties',
  };

  final preferredPresent = present.where(preferred.contains).toList()..sort();
  if (preferredPresent.isNotEmpty) return preferredPresent;
  return present.toList()..sort();
}

// --- helpers -----------------------------------------------------------------

String _fmtNum(num v) {
  if (v is int || v == v.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(1);
}

String _cell(PreviewModuleL10n t, int x, int y) =>
    t('previewGenCell', '({x},{y})', {'x': x, 'y': y});

String _cellsList(Iterable<(int, int)> cells) {
  final list = cells.toList();
  if (list.isEmpty) return '';
  final shown = list.take(10).map((c) => '(${c.$1},${c.$2})').join(' ');
  return list.length > 10 ? '$shown…' : shown;
}

String _waveWhen(PreviewModuleL10n t, int wave) {
  if (wave <= 1) return t('previewGenInitial', 'Initial');
  return t('previewGenWaveLabel', 'Wave {wave}', {'wave': wave});
}

String _waveWithCount(PreviewModuleL10n t, int wave, int count) {
  if (wave <= 1) {
    return t('previewGenInitialWithCount', 'Initial · {count}', {
      'count': count,
    });
  }
  return t('previewGenWaveWithCount', 'Wave {wave} · {count}', {
    'wave': wave,
    'count': count,
  });
}

String _times(PreviewModuleL10n t, int n) =>
    t('previewGenTimes', '×{n}', {'n': n});

String _clean(String raw) {
  var s = raw.trim();
  if (s.startsWith('RTID(')) s = LevelParser.extractAlias(s);
  return s;
}

String _fallbackResourceName(PreviewModuleResourceKind kind, String raw) =>
    _clean(raw);

String _seedBankMethod(PreviewModuleL10n t, String method) => switch (method) {
  'chooser' => t('previewGenSeedBankChooser', 'Choose Your Seeds'),
  'preset' => t('previewGenSeedBankPreset', 'Locked and Loaded'),
  _ => method,
};

String _railcartType(PreviewModuleL10n t, String type) => switch (type) {
  'railcart_cowboy' => t('previewGenRailcartCowboy', 'Wild West mine cart'),
  'railcart_future' => t('previewGenRailcartFuture', 'Far Future mine cart'),
  'railcart_egypt' => t('previewGenRailcartEgypt', 'Ancient Egypt mine cart'),
  'railcart_pirate' => t('previewGenRailcartPirate', 'Pirate Seas mine cart'),
  'railcart_worldcup' => t(
    'previewGenRailcartWorldcup',
    'Ice Hockey mine cart',
  ),
  _ => type,
};

String _weight(PreviewModuleL10n t, int weight) =>
    t('previewGenWeight', 'Weight: {weight}', {'weight': weight});

String _seconds(PreviewModuleL10n t, num seconds) =>
    t('previewGenSeconds', '{n}s', {'n': _fmtNum(seconds)});

String _unknownAsset() => 'assets/images/others/unknown.webp';

PvzObject? _obj(PvzLevelFile levelFile, String objClass) =>
    findModuleObject(levelFile, objClass) ??
    levelFile.objects.firstWhereOrNull((o) => o.objClass == objClass);

Map<String, dynamic>? _objMap(PvzLevelFile levelFile, String objClass) {
  final obj = _obj(levelFile, objClass);
  if (obj?.objData is! Map) return null;
  return Map<String, dynamic>.from(obj!.objData as Map);
}

PreviewItem _plantItem(String id, {String? label, int? gridX, int? gridY}) {
  return PreviewItem(
    id: id,
    assetPath: previewPlantLikeAssetPath(id),
    label: label,
    gridX: gridX,
    gridY: gridY,
  );
}

PreviewItem _zombieItem(String id, {String? label, int? gridX, int? gridY}) {
  return PreviewItem(
    id: id,
    assetPath:
        ZombieRepository().getZombieById(id)?.iconAssetPath ?? _unknownAsset(),
    label: label,
    gridX: gridX,
    gridY: gridY,
  );
}

PreviewItem _gridItem(String id, {String? label, int? gridX, int? gridY}) {
  return PreviewItem(
    id: id,
    assetPath: GridItemRepository.getIconPath(id),
    label: label,
    gridX: gridX,
    gridY: gridY,
  );
}

(int, int) _lawnDims(PvzLevelFile levelFile) => getGridDimensions(levelFile);

// --- module builders ---------------------------------------------------------

PreviewModuleInfoPayload _seedBank(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final map = _objMap(levelFile, 'SeedBankProperties');
  if (map == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final data = SeedBankData.fromJson(map);
  final preset = data.presetPlantList.map(_clean).where((e) => e.isNotEmpty);
  final white = data.plantWhiteList.map(_clean).where((e) => e.isNotEmpty);
  final black = data.plantBlackList.map(_clean).where((e) => e.isNotEmpty);
  final ids = <String>{...preset, ...white};
  final iZombie =
      data.zombieMode == true ||
      (data.seedPacketType ?? '').contains('UIIZombieSeedPacket');

  final lines = <String>[
    t('previewGenSeedBankMethod', 'Method: {method}', {
      'method': _seedBankMethod(t, data.selectionMethod),
    }),
    t('previewGenSeedBankSlots', 'Slots: {count}', {
      'count': data.overrideSeedSlotsCount ?? 8,
    }),
    if (iZombie) t('previewGenSeedBankZombieMode', 'Zombie seed bank'),
    if (data.gridItemMode == true)
      t('previewGenSeedBankGridItemMode', 'Grid-item seed bank'),
    if (preset.isNotEmpty)
      t('previewGenSeedBankPresetCount', 'Preset: {count}', {
        'count': preset.length,
      }),
    if (white.isNotEmpty)
      t('previewGenSeedBankWhitelistCount', 'Whitelist: {count}', {
        'count': white.length,
      }),
    if (black.isNotEmpty)
      t('previewGenSeedBankBlacklistCount', 'Blacklist: {count}', {
        'count': black.length,
      }),
  ];

  final items = <PreviewItem>[
    for (final id in ids)
      if (iZombie) _zombieItem(id) else _plantItem(id),
  ];

  return PreviewModuleInfoPayload(
    lines: lines,
    sections: items.isEmpty
        ? const []
        : [
            PreviewIconSection(
              title: t('previewGenTypeCount', '{count} types', {
                'count': items.length,
              }),
              items: items,
            ),
          ],
  );
}

PreviewModuleInfoPayload _conveyor(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final map = _objMap(levelFile, 'ConveyorSeedBankProperties');
  if (map == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final data = ConveyorBeltData.fromJson(map);
  final delays = data.dropDelayConditions.map((d) => d.delay).toList();
  final lines = <String>[
    t('previewGenConveyorPacketCount', '{count} packet types', {
      'count': data.initialPlantList.length,
    }),
    if (delays.isNotEmpty)
      t('previewGenConveyorDelay', 'Delay {n}', {'n': delays.first}),
    if (data.manualPacketSpawning == true)
      t('previewGenConveyorManual', 'Manual packet spawning'),
  ];

  final items = <PreviewItem>[];
  final seen = <String>{};
  for (final e in data.initialPlantList) {
    final id = _clean(e.plantType);
    if (id.isEmpty || !seen.add(id)) continue;
    final labelParts = <String>[];
    if (e.weight != 100) labelParts.add(_weight(t, e.weight));
    if (e.maxCount > 0) labelParts.add('≤${e.maxCount}');
    items.add(
      _plantItem(id, label: labelParts.isEmpty ? null : labelParts.join(' ')),
    );
  }

  return PreviewModuleInfoPayload(
    lines: lines,
    sections: items.isEmpty
        ? const []
        : [
            PreviewIconSection(
              title: delays.isEmpty
                  ? t('previewGenConveyor', 'Conveyor')
                  : '${t('previewGenConveyor', 'Conveyor')} · ${t('previewGenConveyorDelay', 'Delay {n}', {'n': delays.first})}',
              items: items,
            ),
          ],
  );
}

PreviewModuleInfoPayload _initialPlants(
  PvzLevelFile levelFile,
  String oc,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final placements = <(String, int, int)>[];
  for (final obj in levelFile.objects) {
    if (obj.objClass != oc) continue;
    final data = obj.objData;
    if (data is! Map) continue;
    final list =
        data['InitialPlantPlacements'] ??
        data['Plants'] ??
        data['PlantPlacements'] ??
        data['InitialPlantList'];
    if (list is! List) continue;
    for (final e in list) {
      if (e is String) {
        placements.add((_clean(e), 0, 0));
      } else if (e is Map) {
        final x = (e['GridX'] as num?)?.toInt() ?? 0;
        final y = (e['GridY'] as num?)?.toInt() ?? 0;
        final types = e['PlantTypes'];
        if (types is List) {
          for (final ty in types) {
            if (ty is String) placements.add((_clean(ty), x, y));
          }
        }
        final id =
            e['PlantType'] ?? e['PlantTypeName'] ?? e['TypeName'] ?? e['Type'];
        if (id is String) placements.add((_clean(id), x, y));
      }
    }
  }

  if (placements.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }

  final lines = <String>[
    t('previewGenProtectPlantCount', '{count} plants', {
      'count': placements.length,
    }),
    for (final p in placements.take(12))
      if (p.$1.isNotEmpty)
        '${name(PreviewModuleResourceKind.plant, p.$1)} ${_cell(t, p.$2, p.$3)}',
    if (placements.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);

  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final p in placements.take(96))
            if (p.$1.isNotEmpty) _plantItem(p.$1, gridX: p.$2, gridY: p.$3),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _initialZombies(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final placements = <(String, int, int, String?)>[];
  for (final obj in levelFile.objects) {
    if (obj.objClass != 'InitialZombieProperties') continue;
    final data = obj.objData;
    if (data is! Map) continue;
    final list = data['InitialZombiePlacements'] ?? data['Zombies'];
    if (list is! List) continue;
    for (final e in list) {
      if (e is! Map) continue;
      final raw = e['TypeName'] ?? e['ZombieType'] ?? e['Type'];
      if (raw is! String) continue;
      final id = _clean(raw);
      if (id.isEmpty) continue;
      placements.add((
        id,
        (e['GridX'] as num?)?.toInt() ?? 0,
        (e['GridY'] as num?)?.toInt() ?? 0,
        e['Condition'] as String?,
      ));
    }
  }

  if (placements.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }

  final lines = <String>[
    t('previewGenInitialZombieCount', '{count} zombies', {
      'count': placements.length,
    }),
    for (final p in placements.take(12))
      '${name(PreviewModuleResourceKind.zombie, p.$1)} ${_cell(t, p.$2, p.$3)}${p.$4 != null && p.$4!.isNotEmpty ? ' (${name(PreviewModuleResourceKind.zombieCondition, p.$4!)})' : ''}',
    if (placements.length > 12) '…',
  ];
  final conditionNotes = [
    for (final p in placements)
      if (p.$4 != null && p.$4!.isNotEmpty)
        '${name(PreviewModuleResourceKind.zombie, p.$1)}: ${name(PreviewModuleResourceKind.zombieCondition, p.$4!)}',
  ];
  final (rows, cols) = _lawnDims(levelFile);

  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: conditionNotes.take(6).toList(),
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final p in placements.take(96))
            _zombieItem(p.$1, gridX: p.$2, gridY: p.$3),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _protectPlants(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readProtectPlantData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenMustProtect', 'Must protect {count}', {
      'count': data.mustProtectCount,
    }),
    t('previewGenProtectPlantCount', '{count} plants', {
      'count': data.plants.length,
    }),
    for (final p in data.plants.take(12))
      '${name(PreviewModuleResourceKind.plant, p.plantType)} ${_cell(t, p.gridX, p.gridY)}',
    if (data.plants.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);

  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [
      t('previewGenMustProtect', 'Must protect {count}', {
        'count': data.mustProtectCount,
      }),
    ],
    lawnRows: rows,
    lawnCols: cols,
    sections: data.plants.isEmpty
        ? const []
        : [
            PreviewIconSection(
              items: [
                for (final p in data.plants.take(96))
                  if (_clean(p.plantType).isNotEmpty)
                    _plantItem(
                      _clean(p.plantType),
                      gridX: p.gridX,
                      gridY: p.gridY,
                    ),
              ],
            ),
          ],
  );
}

PreviewModuleInfoPayload _protectGridItems(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readProtectGridItemData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenMustProtect', 'Must protect {count}', {
      'count': data.mustProtectCount,
    }),
    t('previewGenGridItemCount', '{count} items', {
      'count': data.gridItems.length,
    }),
    for (final g in data.gridItems.take(12))
      '${name(PreviewModuleResourceKind.gridItem, g.gridItemType)} ${_cell(t, g.gridX, g.gridY)}',
    if (data.gridItems.length > 12) '…',
  ];

  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [
      t('previewGenMustProtect', 'Must protect {count}', {
        'count': data.mustProtectCount,
      }),
    ],
    lawnRows: _lawnDims(levelFile).$1,
    lawnCols: _lawnDims(levelFile).$2,
    sections: data.gridItems.isEmpty
        ? const []
        : [
            PreviewIconSection(
              items: [
                for (final g in data.gridItems.take(96))
                  if (_clean(g.gridItemType).isNotEmpty)
                    _gridItem(
                      _clean(g.gridItemType),
                      gridX: g.gridX,
                      gridY: g.gridY,
                    ),
              ],
            ),
          ],
  );
}

PreviewModuleInfoPayload _seeingStars(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readSeeingStarsModuleData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final cells = _cellsList(data.matchPlants.map((p) => (p.gridX, p.gridY)));
  final lines = <String>[
    t('previewGenSeeingStarsCells', 'Target plants: {count}', {
      'count': data.matchPlants.length,
    }),
    t('previewGenSeeingStarsCycle', 'Waves loop back to wave {wave}', {
      'wave': data.cycleIndex + 1,
    }),
    t(
      'previewGenSeeingStarsSettlement',
      'Win settles {n}s after the pattern is complete',
      {'n': _fmtNum(data.settlementDuration)},
    ),
    if (cells.isNotEmpty) cells,
  ];
  final (rows, cols) = _lawnDims(levelFile);

  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [
      t('previewGenSeeingStarsCycle', 'Waves loop back to wave {wave}', {
        'wave': data.cycleIndex + 1,
      }),
      t(
        'previewGenSeeingStarsSettlement',
        'Win settles {n}s after the pattern is complete',
        {'n': _fmtNum(data.settlementDuration)},
      ),
    ],
    lawnRows: rows,
    lawnCols: cols,
    sections: data.matchPlants.isEmpty
        ? const []
        : [
            PreviewIconSection(
              title: t('previewGenSeeingStarsCells', 'Target plants: {count}', {
                'count': data.matchPlants.length,
              }),
              items: [
                for (final p in data.matchPlants.take(96))
                  if (_clean(p.matchTypeName).isNotEmpty)
                    _plantItem(
                      _clean(p.matchTypeName),
                      gridX: p.gridX,
                      gridY: p.gridY,
                    ),
              ],
            ),
          ],
  );
}

PreviewModuleInfoPayload _vases(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  // Arcade/Flow store content in the Preset object when present.
  final data = readVaseBreakerData(levelFile);
  if (data == null || data.vases.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [
        t(
          'previewGenVaseNoPreset',
          'No vase preset data (Arcade/Flow may use external preset)',
        ),
      ],
    );
  }

  final plantCounts = <String, int>{};
  final zombieCounts = <String, int>{};
  final collectCounts = <String, int>{};
  var total = 0;
  for (final v in data.vases) {
    total += v.count;
    final p = v.plantTypeName;
    final z = v.zombieTypeName;
    final c = v.collectableTypeName;
    if (p != null && p.isNotEmpty) {
      final id = _clean(p);
      plantCounts[id] = (plantCounts[id] ?? 0) + v.count;
    }
    if (z != null && z.isNotEmpty) {
      final id = _clean(z);
      zombieCounts[id] = (zombieCounts[id] ?? 0) + v.count;
    }
    if (c != null && c.isNotEmpty) {
      final id = _clean(c);
      collectCounts[id] = (collectCounts[id] ?? 0) + v.count;
    }
  }

  final lines = <String>[
    t('previewGenVaseCount', '{count} vases', {'count': total}),
    t('previewGenColumnRange', 'Cols {min}–{max}', {
      'min': data.minColumnIndex + 1,
      'max': data.maxColumnIndex + 1,
    }),
    if (data.numColoredPlantVases > 0)
      t('previewGenColoredPlantVases', 'Colored plant vases: {count}', {
        'count': data.numColoredPlantVases,
      }),
    if (data.numColoredZombieVases > 0)
      t('previewGenColoredZombieVases', 'Colored zombie vases: {count}', {
        'count': data.numColoredZombieVases,
      }),
    for (final e in plantCounts.entries)
      '${name(PreviewModuleResourceKind.plant, e.key)} ${_times(t, e.value)}',
    for (final e in zombieCounts.entries)
      '${name(PreviewModuleResourceKind.zombie, e.key)} ${_times(t, e.value)}',
    for (final e in collectCounts.entries)
      '${name(PreviewModuleResourceKind.collectable, e.key)} ${_times(t, e.value)}',
  ];

  final col = t('previewGenColumnRange', 'Cols {min}–{max}', {
    'min': data.minColumnIndex + 1,
    'max': data.maxColumnIndex + 1,
  });
  final sections = <PreviewIconSection>[];
  if (plantCounts.isNotEmpty) {
    sections.add(
      PreviewIconSection(
        title: t('previewGenPlants', 'Plants'),
        items: [
          for (final e in plantCounts.entries)
            _plantItem(e.key, label: e.value > 1 ? _times(t, e.value) : null),
        ],
      ),
    );
  }
  if (zombieCounts.isNotEmpty) {
    sections.add(
      PreviewIconSection(
        title: t('previewGenZombies', 'Zombies'),
        items: [
          for (final e in zombieCounts.entries)
            _zombieItem(e.key, label: e.value > 1 ? _times(t, e.value) : null),
        ],
      ),
    );
  }
  if (collectCounts.isNotEmpty) {
    sections.add(
      PreviewIconSection(
        title: t('previewGenGridItems', 'Grid Items'),
        items: [
          for (final e in collectCounts.entries)
            _gridItem(e.key, label: e.value > 1 ? _times(t, e.value) : null),
        ],
      ),
    );
  }

  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [
      col,
      if (data.numColoredPlantVases > 0)
        t('previewGenColoredPlantVases', 'Colored plant vases: {count}', {
          'count': data.numColoredPlantVases,
        }),
      if (data.numColoredZombieVases > 0)
        t('previewGenColoredZombieVases', 'Colored zombie vases: {count}', {
          'count': data.numColoredZombieVases,
        }),
    ],
    sections: sections,
  );
}

PreviewModuleInfoPayload _armrack(PvzLevelFile levelFile, PreviewModuleL10n t) {
  final data = readArmrackModuleData(levelFile);
  if (data == null || data.overrides.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[];
  final sections = <PreviewIconSection>[];
  final (rows, cols) = _lawnDims(levelFile);
  final waves = data.overrides.toList()
    ..sort((a, b) => a.wave.compareTo(b.wave));
  for (final o in waves) {
    if (o.itemList.isEmpty) continue;
    final cells = _cellsList(o.itemList.map((i) => (i.mX, i.mY)));
    lines.add('${_waveWithCount(t, o.wave, o.itemList.length)}: $cells');
    sections.add(
      PreviewIconSection(
        title: _waveWithCount(t, o.wave, o.itemList.length),
        items: [
          for (final i in o.itemList.take(96))
            PreviewItem(
              id: i.type,
              assetPath: armrackIconAsset(i.type),
              gridX: i.mX,
              gridY: i.mY,
            ),
        ],
      ),
    );
  }
  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: sections,
  );
}

PreviewModuleInfoPayload _energy(PvzLevelFile levelFile, PreviewModuleL10n t) {
  final data = readEnergyGridModuleData(levelFile);
  if (data == null || data.overrides.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[];
  final sections = <PreviewIconSection>[];
  final (rows, cols) = _lawnDims(levelFile);
  final waves = data.overrides.toList()
    ..sort((a, b) => a.wave.compareTo(b.wave));
  for (final o in waves) {
    if (o.itemList.isEmpty) continue;
    final cells = _cellsList(o.itemList.map((i) => (i.mX, i.mY)));
    lines.add('${_waveWithCount(t, o.wave, o.itemList.length)}: $cells');
    sections.add(
      PreviewIconSection(
        title: _waveWithCount(t, o.wave, o.itemList.length),
        items: [
          for (final i in o.itemList.take(96))
            PreviewItem(
              id: 'energyGrid',
              assetPath: GridItemRepository.getIconPath('energyGrid'),
              gridX: i.mX,
              gridY: i.mY,
            ),
        ],
      ),
    );
  }
  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: sections,
  );
}

PreviewModuleInfoPayload _lunarVeins(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readLunarMineVeinModuleData(levelFile);
  if (data == null || data.placements.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final byWave = groupBy(data.placements, (p) => p.emergenceWave);
  final waves = byWave.keys.toList()..sort();
  final lines = <String>[
    t('previewGenLunarVeinCount', '{count} veins', {
      'count': data.placements.length,
    }),
    for (final w in waves)
      '${_waveWhen(t, w)}: ${_cellsList(byWave[w]!.map((p) => (p.gridX, p.gridY)))}',
  ];
  final (rows, cols) = _lawnDims(levelFile);
  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      for (final w in waves)
        PreviewIconSection(
          title: _waveWithCount(t, w, byWave[w]!.length),
          items: [
            for (final p in byWave[w]!)
              PreviewItem(
                id: '${p.typeName}_${p.gridX}_${p.gridY}',
                assetPath: GridItemRepository.getIconPath(p.typeName),
                gridX: p.gridX,
                gridY: p.gridY,
              ),
          ],
        ),
    ],
  );
}

PreviewModuleInfoPayload _radiationMeteor(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readRadiationMeteorModuleData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final byWave = groupBy(data.spawnSchedule, (p) => p.wave);
  final waves = byWave.keys.toList()..sort();
  final timing = t(
    'previewGenMeteorTiming',
    'Warn {warn}s · Pollution every {poll}s',
    {
      'warn': _fmtNum(data.warningDuration),
      'poll': _fmtNum(data.pollutionInterval),
    },
  );
  final mining = t('previewGenMeteorMining', 'Mining {n}s · Power {power}', {
    'n': _fmtNum(data.miningDurationRequired),
    'power': data.powerRewardOnDestroy,
  });
  final lines = <String>[
    t('previewGenMeteorCount', '{count} meteors', {
      'count': data.spawnSchedule.length,
    }),
    timing,
    mining,
    for (final w in waves)
      '${_waveWhen(t, w)}: ${_cellsList(byWave[w]!.map((p) => (p.gridX, p.gridY)))}',
  ];
  final (rows, cols) = _lawnDims(levelFile);

  final sections = waves.isEmpty
      ? <PreviewIconSection>[]
      : [
          for (final w in waves)
            PreviewIconSection(
              title: _waveWithCount(t, w, byWave[w]!.length),
              items: [
                for (final p in byWave[w]!)
                  PreviewItem(
                    id: 'radiation_meteor_${p.gridX}_${p.gridY}',
                    assetPath: GridItemRepository.getIconPath(
                      'radiation_meteor_ore',
                    ),
                    gridX: p.gridX,
                    gridY: p.gridY,
                  ),
              ],
            ),
        ];

  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [timing, mining],
    lawnRows: rows,
    lawnCols: cols,
    sections: sections,
  );
}

PreviewModuleInfoPayload _gulliver(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readGulliverTunnelData(levelFile);
  if (data == null || data.tunnelPlacements.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  String orient(String o) => o.contains('BIG_ON_RIGHT')
      ? t('previewGenTunnelBigOnRight', 'Big on right')
      : t('previewGenTunnelBigOnLeft', 'Big on left');

  final lines = <String>[
    t('previewGenTunnelCount', '{count} tunnels', {
      'count': data.tunnelPlacements.length,
    }),
    for (final p in data.tunnelPlacements)
      '${_cell(t, p.gridX, p.gridY)} · ${orient(p.orientation)}',
  ];
  final (rows, cols) = _lawnDims(levelFile);

  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final p in data.tunnelPlacements)
            PreviewItem(
              id: 'gulliver_tunnel_${p.gridX}_${p.gridY}',
              assetPath: 'assets/images/tunnels/${p.orientation}.webp',
              gridX: p.gridX,
              gridY: p.gridY,
            ),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _initialGridItems(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final placements = <(String, int, int)>[];
  for (final obj in levelFile.objects) {
    if (obj.objClass != 'InitialGridItemProperties') continue;
    final data = obj.objData;
    if (data is! Map) continue;
    final list = data['InitialGridItemPlacements'] ?? data['GridItems'];
    if (list is! List) continue;
    for (final e in list) {
      if (e is! Map) continue;
      final raw = e['TypeName'] ?? e['GridItemType'] ?? e['ItemType'];
      if (raw is! String) continue;
      final clean = _clean(raw);
      final id =
          GridItemRepository.displayTypeNameForLevel(clean, levelFile) ?? clean;
      if (id.isEmpty) continue;
      placements.add((
        id,
        (e['GridX'] as num?)?.toInt() ?? 0,
        (e['GridY'] as num?)?.toInt() ?? 0,
      ));
    }
  }
  if (placements.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }

  final lines = <String>[
    t('previewGenGridItemCount', '{count} items', {'count': placements.length}),
    for (final p in placements.take(12))
      '${name(PreviewModuleResourceKind.gridItem, p.$1)} ${_cell(t, p.$2, p.$3)}',
    if (placements.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);

  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final p in placements.take(96))
            _gridItem(p.$1, gridX: p.$2, gridY: p.$3),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _seedRain(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readSeedRainData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenSeedRainInterval', 'Rain interval: {n}s', {
      'n': data.rainInterval,
    }),
    t('previewGenSeedRainCount', '{count} rain entries', {
      'count': data.seedRains.length,
    }),
  ];
  final items = <PreviewItem>[];
  for (final e in data.seedRains) {
    final plant = e.plantTypeName;
    final zombie = e.zombieTypeName;
    if (plant != null && plant.isNotEmpty) {
      final id = _clean(plant);
      lines.add(
        '${name(PreviewModuleResourceKind.plant, id)} · ${_times(t, e.maxCount)} · ${_weight(t, e.weight)}',
      );
      items.add(_plantItem(id, label: _times(t, e.maxCount)));
    } else if (zombie != null && zombie.isNotEmpty) {
      final id = _clean(zombie);
      lines.add(
        '${name(PreviewModuleResourceKind.zombie, id)} · ${_times(t, e.maxCount)} · ${_weight(t, e.weight)}',
      );
      items.add(_zombieItem(id, label: _times(t, e.maxCount)));
    }
  }
  return PreviewModuleInfoPayload(
    lines: lines,
    sections: items.isEmpty
        ? const []
        : [
            PreviewIconSection(
              title: t('previewGenSeedRainInterval', 'Rain interval: {n}s', {
                'n': data.rainInterval,
              }),
              items: items,
            ),
          ],
  );
}

PreviewModuleInfoPayload _dropShip(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readDropShipData(levelFile);
  if (data == null || data.appearWaves.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenDropShipWaveCount', '{count} appear waves', {
      'count': data.appearWaves.length,
    }),
    for (final w in data.appearWaves)
      t(
        'previewGenDropShipWave',
        'Wave {wave}: imps +{imp} (lv{lv}) rows {rmin}–{rmax} cols {cmin}–{cmax}',
        {
          'wave': w.wave + 1,
          'imp': w.imp,
          'lv': w.impLv,
          'rmin': w.rowRange.min + 1,
          'rmax': w.rowRange.max + 1,
          'cmin': w.colRange.min + 1,
          'cmax': w.colRange.max + 1,
        },
      ),
  ];

  // Always at least one imp is dropped; Imp is extra count.
  final sections = <PreviewIconSection>[
    for (final w in data.appearWaves)
      PreviewIconSection(
        title: t(
          'previewGenDropShipWaveTitle',
          'Wave {wave} · +{imp} imps · area ({rmin},{cmin})–({rmax},{cmax})',
          {
            'wave': w.wave + 1,
            'imp': w.imp,
            'rmin': w.rowRange.min + 1,
            'rmax': w.rowRange.max + 1,
            'cmin': w.colRange.min + 1,
            'cmax': w.colRange.max + 1,
          },
        ),
        items: [
          for (var i = 0; i < (1 + w.imp).clamp(1, 12); i++)
            _zombieItem(
              _dropShipImpId(),
              label: i == 0
                  ? t('previewGenLevel', 'Lv{level}', {'level': w.impLv})
                  : null,
            ),
        ],
      ),
  ];

  return PreviewModuleInfoPayload(lines: lines, sections: sections);
}

/// Preferred Imp type for Transport Boat / air-assault previews.
String _dropShipImpId() {
  for (final id in const ['skycity_ggtimp', 'skycity_imp', 'future_imp']) {
    if (ZombieRepository().getZombieById(id) != null) return id;
  }
  return 'skycity_ggtimp';
}

String _bronzeZombieId(BronzeStatueKind kind) => switch (kind) {
  BronzeStatueKind.strength => 'kongfu_strong_bronze',
  BronzeStatueKind.mage => 'kongfu_magic_bronze',
  BronzeStatueKind.agile => 'kongfu_agile_bronze',
};

PreviewModuleInfoPayload _bronze(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readBronzeModuleData(levelFile);
  final items = data?.data.expand((b) => b.itemList).toList() ?? const [];
  if (items.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final byTime = groupBy(items, (i) => i.spawnTime);
  final times = byTime.keys.toList()..sort();
  final lines = <String>[
    t('previewGenBronzeCount', '{count} bronze statues', {
      'count': items.length,
    }),
    for (final time in times)
      t('previewGenBronzeBatch', 'Revive {time}s · {count}', {
        'time': time,
        'count': byTime[time]!.length,
      }),
    for (final i in items.take(10))
      '${name(PreviewModuleResourceKind.zombie, _bronzeZombieId(i.kind))} ${_cell(t, i.mX, i.mY)} @${_seconds(t, i.spawnTime)}',
    if (items.length > 10) '…',
  ];
  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: _lawnDims(levelFile).$1,
    lawnCols: _lawnDims(levelFile).$2,
    sections: [
      for (final time in times)
        PreviewIconSection(
          title: t('previewGenBronzeBatch', 'Revive {time}s · {count}', {
            'time': time,
            'count': byTime[time]!.length,
          }),
          items: [
            for (final i in byTime[time]!.take(96))
              _zombieItem(_bronzeZombieId(i.kind), gridX: i.mX, gridY: i.mY),
          ],
        ),
    ],
  );
}

PreviewModuleInfoPayload _powerTiles(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readPowerTileModuleData(levelFile);
  if (data == null || data.linkedTiles.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenPowerTileCount', '{count} power tiles', {
      'count': data.linkedTiles.length,
    }),
    for (final tile in data.linkedTiles.take(12))
      '${name(PreviewModuleResourceKind.tool, 'tool_powertile_${tile.group}')} ${_cell(t, tile.location.mx, tile.location.my)}',
    if (data.linkedTiles.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);
  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final tile in data.linkedTiles.take(96))
            PreviewItem(
              id: 'tool_powertile_${tile.group}',
              assetPath: GridItemRepository.getIconPath(
                'tool_powertile_${tile.group}',
              ),
              gridX: tile.location.mx,
              gridY: tile.location.my,
            ),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _railcart(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readRailcartModuleData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenRailcartType', 'Type: {type}', {
      'type': _railcartType(t, data.railcartType),
    }),
    t('previewGenRailcartCount', '{count} carts', {
      'count': data.railcarts.length,
    }),
    t('previewGenRailsCount', '{count} rails', {'count': data.rails.length}),
    for (final c in data.railcarts.take(8))
      '${t('previewGenRailcartLabel', 'Cart')} ${_cell(t, c.column, c.row)}',
    for (final r in data.rails.take(6))
      t('previewGenRailRange', 'Rail col {col} rows {start}–{end}', {
        'col': r.column + 1,
        'start': r.rowStart + 1,
        'end': r.rowEnd + 1,
      }),
  ];
  final (rows, cols) = _lawnDims(levelFile);
  final items = <PreviewItem>[
    for (final r in data.rails)
      for (
        var row = math.min(r.rowStart, r.rowEnd);
        row <= math.max(r.rowStart, r.rowEnd);
        row++
      )
        PreviewItem(
          id: 'rails_${r.column}_$row',
          assetPath: 'assets/images/others/rails.webp',
          gridX: r.column,
          gridY: row,
        ),
    for (final c in data.railcarts)
      PreviewItem(
        id: '${data.railcartType}_${c.column}_${c.row}',
        assetPath: 'assets/images/others/railcarts.webp',
        gridX: c.column,
        gridY: c.row,
      ),
  ];
  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [
      t('previewGenRailcartType', 'Type: {type}', {
        'type': _railcartType(t, data.railcartType),
      }),
    ],
    lawnRows: rows,
    lawnCols: cols,
    sections: items.isEmpty
        ? const []
        : [PreviewIconSection(items: items.take(96).toList())],
  );
}

PreviewModuleInfoPayload _smokePollution(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readSmokePollutionData(levelFile);
  if (data == null || data.smokeManholeList.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final type = data.gridItem.isEmpty
      ? SmokePollutionModulePropertiesData.gridItemType
      : data.gridItem;
  final lines = <String>[
    t('previewGenSmokeManholeCount', '{count} manholes', {
      'count': data.smokeManholeList.length,
    }),
    for (final m in data.smokeManholeList.take(12))
      '${_cell(t, m.gridColumn, m.gridRow)}${m.startTime > 0 ? ' @${m.startTime}s' : ''}',
    if (data.smokeManholeList.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);
  final timed = [
    for (final m in data.smokeManholeList)
      if (m.startTime > 0)
        '${_cell(t, m.gridColumn, m.gridRow)} @${m.startTime}s',
  ];
  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: timed.take(6).toList(),
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final m in data.smokeManholeList.take(96))
            _gridItem(type, gridX: m.gridColumn, gridY: m.gridRow),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _renai(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final data = readRenaiModuleData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final day = data.statueInfos;
  final night = data.statueNightInfos;
  if (day.isEmpty && night.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    if (day.isNotEmpty)
      t('previewGenRenaiDayCount', 'Day statues: {count}', {
        'count': day.length,
      }),
    if (data.nightEnabled)
      t('previewGenRenaiNightWave', 'Night from wave {wave}', {
        'wave': data.nightStartWaveNum + 1,
      }),
    if (night.isNotEmpty)
      t('previewGenRenaiNightCount', 'Night statues: {count}', {
        'count': night.length,
      }),
    for (final s in [...day, ...night].take(12))
      '${name(PreviewModuleResourceKind.gridItem, s.typeName)} ${_cell(t, s.gridX, s.gridY)}',
    if (day.length + night.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);
  final sections = <PreviewIconSection>[];
  if (day.isNotEmpty) {
    sections.add(
      PreviewIconSection(
        title: t('previewGenRenaiDayCount', 'Day statues: {count}', {
          'count': day.length,
        }),
        items: [
          for (final s in day.take(96))
            if (_clean(s.typeName).isNotEmpty)
              _gridItem(_clean(s.typeName), gridX: s.gridX, gridY: s.gridY),
        ],
      ),
    );
  }
  if (night.isNotEmpty) {
    sections.add(
      PreviewIconSection(
        title: t('previewGenRenaiNightCount', 'Night statues: {count}', {
          'count': night.length,
        }),
        items: [
          for (final s in night.take(96))
            if (_clean(s.typeName).isNotEmpty)
              _gridItem(_clean(s.typeName), gridX: s.gridX, gridY: s.gridY),
        ],
      ),
    );
  }
  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [
      if (data.nightEnabled)
        t('previewGenRenaiNightWave', 'Night from wave {wave}', {
          'wave': data.nightStartWaveNum + 1,
        }),
    ],
    lawnRows: rows,
    lawnCols: cols,
    sections: sections,
  );
}

PreviewModuleInfoPayload _tunnelDefend(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final isExpedition = levelHasExpeditionTilesModule(levelFile);
  final data = isExpedition
      ? readExpeditionTilesData(levelFile)
      : readTunnelDefendData(levelFile);
  if (data == null || data.roads.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final brick = t('previewGenTunnelBrickMap', 'Brick map: {n}', {
    'n': data.brickMapIndex,
  });
  final lines = <String>[
    t('previewGenTunnelRoadCount', '{count} tunnel tiles', {
      'count': data.roads.length,
    }),
    brick,
    for (final r in data.roads.take(12))
      '${r.img.isEmpty ? 'tile' : r.img} ${_cell(t, r.gridX, r.gridY)}',
    if (data.roads.length > 12) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);
  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [brick],
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final r in data.roads.take(96))
            PreviewItem(
              id: 'tunnel_${r.gridX}_${r.gridY}',
              assetPath: r.img.isEmpty
                  ? (isExpedition
                        ? 'assets/images/tunnels/SouDaCheTunnelRoad.webp'
                        : 'assets/images/tunnels/TunnelRoad.webp')
                  : 'assets/images/tunnels/${r.img}.webp',
              gridX: r.gridX,
              gridY: r.gridY,
            ),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _manholePipeline(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readManholePipelineData(levelFile);
  if (data == null || data.pipelineList.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final damage = t('previewGenPipelineDamage', 'Damage/s: {n}', {
    'n': data.damagePerSecond,
  });
  final lines = <String>[
    t('previewGenPipelineCount', '{count} pipelines', {
      'count': data.pipelineList.length,
    }),
    damage,
    for (final p in data.pipelineList.take(10))
      t('previewGenPipelineRange', '({sx},{sy}) → ({ex},{ey})', {
        'sx': p.startX,
        'sy': p.startY,
        'ex': p.endX,
        'ey': p.endY,
      }),
    if (data.pipelineList.length > 10) '…',
  ];
  final (rows, cols) = _lawnDims(levelFile);
  return PreviewModuleInfoPayload(
    lines: lines,
    gridNotes: [damage],
    lawnRows: rows,
    lawnCols: cols,
    sections: [
      PreviewIconSection(
        items: [
          for (final p in data.pipelineList.take(48)) ...[
            _gridItem('steam_down', gridX: p.startX, gridY: p.startY),
            _gridItem('steam_up', gridX: p.endX, gridY: p.endY),
          ],
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _moldColony(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final layout = readMoldColonyLayoutData(levelFile);
  if (layout == null || layout.values.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final cells = <(int, int)>[];
  for (var y = 0; y < layout.values.length; y++) {
    final row = layout.values[y];
    for (var x = 0; x < row.length; x++) {
      if (row[x] != 0) cells.add((x, y));
    }
  }
  if (cells.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final lines = <String>[
    t('previewGenMoldCount', '{count} mold cells', {'count': cells.length}),
    _cellsList(cells),
  ];
  final rows = layout.values.length;
  final cols = layout.values.map((r) => r.length).fold<int>(0, math.max);
  return PreviewModuleInfoPayload(
    lines: lines,
    lawnRows: rows > 0 ? rows : _lawnDims(levelFile).$1,
    lawnCols: cols > 0 ? cols : _lawnDims(levelFile).$2,
    sections: [
      PreviewIconSection(
        items: [
          for (final c in cells.take(96))
            _gridItem('fake_mold', gridX: c.$1, gridY: c.$2),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _sunDropper(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final map = _objMap(levelFile, 'SunDropperProperties');
  if (map == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final data = SunDropperPropertiesData.fromJson(map);
  final lines = <String>[
    t('previewGenSunInitialDelay', 'Initial delay {n}s', {
      'n': _fmtNum(data.initialSunDropDelay),
    }),
    t('previewGenSunCountdown', 'Countdown {base}–{max}s', {
      'base': _fmtNum(data.sunCountdownBase),
      'max': _fmtNum(data.sunCountdownMax),
    }),
  ];
  return PreviewModuleInfoPayload(
    lines: lines,
    sections: [
      PreviewIconSection(
        title: t('previewGenSunCountdown', 'Countdown {base}–{max}s', {
          'base': _fmtNum(data.sunCountdownBase),
          'max': _fmtNum(data.sunCountdownMax),
        }),
        items: [
          PreviewItem(
            id: 'sun',
            assetPath: 'assets/images/rift_themes/sun.webp',
            label: _seconds(t, data.initialSunDropDelay),
          ),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _lastStand(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final map = _objMap(levelFile, 'LastStandMinigameProperties');
  if (map == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  final data = LastStandMinigamePropertiesData.fromJson(map);
  final lines = <String>[
    t('previewGenLastStandSun', 'Starting sun: {n}', {'n': data.startingSun}),
    t('previewGenLastStandPlantFood', 'Starting plant food: {n}', {
      'n': data.startingPlantfood,
    }),
  ];
  return PreviewModuleInfoPayload(
    lines: lines,
    sections: [
      PreviewIconSection(
        title: t('previewGenLastStandSun', 'Starting sun: {n}', {
          'n': data.startingSun,
        }),
        items: [
          PreviewItem(
            id: 'sun',
            assetPath: 'assets/images/rift_themes/sun.webp',
            label: '${data.startingSun}',
          ),
        ],
      ),
    ],
  );
}

PreviewModuleInfoPayload _piratePlank(
  PvzLevelFile levelFile,
  PreviewModuleL10n t,
) {
  final data = readPiratePlankModuleData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  return PreviewModuleInfoPayload(
    lines: [
      t('previewGenPiratePlankRows', 'Plank rows: {rows}', {
        'rows': data.plankRows.isEmpty ? '—' : data.plankRows.join(', '),
      }),
    ],
  );
}

PreviewModuleInfoPayload _tide(PvzLevelFile levelFile, PreviewModuleL10n t) {
  final data = readTideModuleData(levelFile);
  if (data == null) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  return PreviewModuleInfoPayload(
    lines: [
      t('previewGenTideStart', 'Starting tide column: {n}', {
        'n': data.startingWaveLocation,
      }),
    ],
  );
}

PreviewModuleInfoPayload _genericDump(
  PvzLevelFile levelFile,
  String objClass,
  PreviewModuleL10n t,
  PreviewModuleResourceName name,
) {
  final map = _objMap(levelFile, objClass);
  if (map == null || map.isEmpty) {
    return PreviewModuleInfoPayload(
      lines: [t('previewGenModuleInfoNoData', 'No module data on this level')],
    );
  }
  PreviewModuleResourceKind? kindFor(String hint) {
    final value = hint.toLowerCase().replaceAll('_', '');
    if (value.contains('condition')) {
      if (value.contains('zombie')) {
        return PreviewModuleResourceKind.zombieCondition;
      }
      if (value.contains('plant')) {
        return PreviewModuleResourceKind.plantCondition;
      }
    }
    if (value.contains('tool')) return PreviewModuleResourceKind.tool;
    if (value.contains('griditem')) return PreviewModuleResourceKind.gridItem;
    if (value.contains('zombie')) return PreviewModuleResourceKind.zombie;
    if (value.contains('plant')) return PreviewModuleResourceKind.plant;
    if (value.contains('collectable') || value.contains('collectible')) {
      return PreviewModuleResourceKind.collectable;
    }
    if (value.contains('creature') ||
        value.contains('fish') ||
        value.contains('dino')) {
      return PreviewModuleResourceKind.creature;
    }
    return null;
  }

  String displayResource(String raw, String key, {String scope = ''}) {
    final genericType = const [
      'type',
      'typename',
      'itemtype',
    ].contains(key.toLowerCase());
    final kind =
        kindFor(key) ??
        (key.toLowerCase().contains('condition')
            ? kindFor('${objClass}Condition')
            : null) ??
        kindFor(RtidParser.parse(raw)?.source ?? '') ??
        (genericType ? kindFor(scope) ?? kindFor(objClass) : null);
    // Do not guess the resource type for arbitrary custom labels/aliases.
    return kind == null ? _clean(raw) : name(kind, raw);
  }

  final lines = <String>[];
  for (final e in map.entries) {
    if (lines.length >= 14) break;
    final key = e.key.toString();
    final v = e.value;
    if (v is bool) {
      final value = v
          ? t('previewGenValueYes', 'Yes')
          : t('previewGenValueNo', 'No');
      lines.add('$key: $value');
    } else if (v is num) {
      lines.add('$key: $v');
    } else if (v is String && v.length <= 48) {
      lines.add('$key: ${displayResource(v, key)}');
    } else if (v is List) {
      lines.add(
        t('previewGenListCount', '{key}: {count}', {
          'key': key,
          'count': v.length,
        }),
      );
      for (final item in v.take(4)) {
        if (item is Map) {
          final typeEntry = item.entries.firstWhereOrNull(
            (entry) => const {
              'PlantType',
              'PlantTypeName',
              'ZombieType',
              'ZombieTypeName',
              'GridItemType',
              'GridItemTypeName',
              'ToolType',
              'CollectableTypeName',
              'CollectibleTypeName',
              'CreatureType',
              'FishType',
              'DinoType',
              'TypeName',
              'Type',
              'type',
            }.contains(entry.key),
          );
          final x = item['GridX'] ?? item['mX'];
          final y = item['GridY'] ?? item['mY'];
          final wave = item['Wave'] ?? item['EmergenceWave'] ?? item['wave'];
          final parts = <String>[
            if (typeEntry?.value != null)
              displayResource(
                '${typeEntry!.value}',
                '${typeEntry.key}',
                scope: key,
              ),
            if (wave != null) _waveWhen(t, (wave as num).toInt()),
            if (x is num && y is num) _cell(t, x.toInt(), y.toInt()),
          ];
          if (parts.isNotEmpty) lines.add('  · ${parts.join(' ')}');
        } else if (item is String) {
          lines.add('  · ${displayResource(item, key)}');
        }
      }
    }
  }
  if (lines.isEmpty) {
    lines.add(t('previewGenModuleInfoNoData', 'No module data on this level'));
  }
  return PreviewModuleInfoPayload(lines: lines);
}
