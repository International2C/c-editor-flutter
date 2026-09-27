import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// Zombie spawn entry inside [WaveGeneratorWaveData].
/// Row is stored as a string in level JSON: "1"–"5", "?", or omitted for random.
class WaveGeneratorZombieEntryData extends PvzModel {
  WaveGeneratorZombieEntryData({
    this.type = '',
    this.row,
    this.level,
    this.targetValidTime,
    this.riseGridX,
    this.riseGridY,
  });

  String type;
  String? row;
  int? level;
  int? targetValidTime;
  String? riseGridX;
  String? riseGridY;

  factory WaveGeneratorZombieEntryData.fromJson(Map<String, dynamic> json) {
    final rawRow = json['Row'];
    String? row;
    if (rawRow is String) {
      row = rawRow;
    } else if (rawRow is num) {
      row = rawRow.toString();
    }
    return WaveGeneratorZombieEntryData(
      type: json['Type'] as String? ?? '',
      row: row,
      level: json['Level'] as int?,
      targetValidTime: json['TargetValidTime'] as int?,
      riseGridX: json['Rise_GridX']?.toString(),
      riseGridY: json['Rise_GridY']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'Type': type};
    if (row != null && row!.isNotEmpty) {
      data['Row'] = row;
    }
    if (level != null) data['Level'] = level;
    if (targetValidTime != null) data['TargetValidTime'] = targetValidTime;
    if (riseGridX != null) data['Rise_GridX'] = riseGridX;
    if (riseGridY != null) data['Rise_GridY'] = riseGridY;
    return data;
  }
}
