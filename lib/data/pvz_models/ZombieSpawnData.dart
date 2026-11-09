import 'package:c_editor/data/pvz_models/PvzModel.dart';

class ZombieSpawnData extends PvzModel {
  ZombieSpawnData({
    this.type = '',
    this.level,
    this.row,
    this.direction,
    this.titles,
  });

  String type;
  int? level;
  int? row;

  /// Spawn side shared by ordinary and underwater spawners: right (default),
  /// left, or random (chosen independently for each zombie at creation).
  String? direction;

  static bool entersFromLeft(String? direction) => direction == 'left';

  /// Omit the default right side; random is a real string, not editor RNG.
  static String? directionForEntrySide(bool fromLeft, {bool random = false}) =>
      random ? 'random' : (fromLeft ? 'left' : null);

  /// Ztalemate Escape perk aliases (e.g. ZTSpeed1, ZTAttack1).
  List<String>? titles;

  ZombieSpawnData copyWith({
    String? type,
    int? level,
    int? row,
    String? direction,
    List<String>? titles,
    bool clearLevel = false,
    bool clearRow = false,
    bool clearDirection = false,
    bool clearTitles = false,
  }) {
    return ZombieSpawnData(
      type: type ?? this.type,
      level: clearLevel ? null : (level ?? this.level),
      row: clearRow ? null : (row ?? this.row),
      direction: clearDirection ? null : (direction ?? this.direction),
      titles: clearTitles
          ? null
          : (titles ??
                (this.titles == null ? null : List<String>.from(this.titles!))),
    );
  }

  factory ZombieSpawnData.fromJson(Map<String, dynamic> json) {
    List<String>? titles;
    final rawTitles = json['Titles'];
    if (rawTitles is List) {
      titles = rawTitles.map((e) => e.toString()).toList();
      if (titles.isEmpty) titles = null;
    }
    return ZombieSpawnData(
      type: json['Type'] as String? ?? '',
      level: _parseOptionalInt(json['Level']),
      row: _parseOptionalInt(json['Row']),
      direction: json['Direction'] as String?,
      titles: titles,
    );
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'Type': type};
    if (level != null) data['Level'] = level;
    if (row != null) data['Row'] = row;
    if (direction != null) data['Direction'] = direction;
    if (titles != null && titles!.isNotEmpty) data['Titles'] = titles;
    return data;
  }
}
