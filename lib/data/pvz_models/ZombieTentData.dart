import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/ZombieTentSpawnEntryData.dart';

/// One tent placement inside `WaveActionZombieTentProps.ZombieTents`.
///
/// [column] and [row] are 1-based lawn coordinates (matching game JSON).
class ZombieTentData extends PvzModel {
  ZombieTentData({
    this.column = 1,
    this.row = 1,
    this.hitpoints = 4000,
    this.productionInterval = 5.0,
    this.tentType = zombieTentTypeNormal,
    this.zombieTypesToSpawn = const [],
  });

  static const zombieTentTypeNormal = 'zombie_tent';
  static const zombieTentTypeFestival = 'zombie_festival_tent';

  /// 1-based column.
  int column;

  /// 1-based row.
  int row;
  int hitpoints;
  double productionInterval;

  /// `zombie_tent` or `zombie_festival_tent`.
  String tentType;
  List<ZombieTentSpawnEntryData> zombieTypesToSpawn;

  int get gridX => (column - 1).clamp(0, 99);
  int get gridY => (row - 1).clamp(0, 99);

  factory ZombieTentData.fromJson(Map<String, dynamic> json) {
    final raw = json['ZombieTypesToSpawn'] as List<dynamic>? ?? const [];
    return ZombieTentData(
      column: _parseInt(json['Column']) ?? 1,
      row: _parseInt(json['Row']) ?? 1,
      hitpoints: _parseInt(json['Hitpoints']) ?? 4000,
      productionInterval:
          _parseDouble(json['ProductionInterval']) ?? 5.0,
      tentType: json['TentType'] as String? ?? zombieTentTypeNormal,
      zombieTypesToSpawn: raw
          .whereType<Map>()
          .map(
            (e) => ZombieTentSpawnEntryData.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Column': column,
    'Row': row,
    'Hitpoints': hitpoints,
    'ProductionInterval': productionInterval,
    'TentType': tentType,
    'ZombieTypesToSpawn': zombieTypesToSpawn
        .map((e) => e.toJson())
        .toList(),
  };

  ZombieTentData copyWith({
    int? column,
    int? row,
    int? hitpoints,
    double? productionInterval,
    String? tentType,
    List<ZombieTentSpawnEntryData>? zombieTypesToSpawn,
  }) {
    return ZombieTentData(
      column: column ?? this.column,
      row: row ?? this.row,
      hitpoints: hitpoints ?? this.hitpoints,
      productionInterval: productionInterval ?? this.productionInterval,
      tentType: tentType ?? this.tentType,
      zombieTypesToSpawn:
          zombieTypesToSpawn ??
          this.zombieTypesToSpawn
              .map(
                (e) => ZombieTentSpawnEntryData(
                  zombieTypeName: e.zombieTypeName,
                  weight: e.weight,
                  level: e.level,
                ),
              )
              .toList(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
